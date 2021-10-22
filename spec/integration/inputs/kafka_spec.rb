# encoding: utf-8
require "logstash/devutils/rspec/spec_helper"
require "logstash/inputs/kafka"
require "digest"
require "rspec/wait"

def thread_it(kafka_input, queue)
  Thread.new do
    begin
      kafka_input.run(queue)
    end
  end
end

def run_with_kafka(&block)
  queue = Queue.new
  t = thread_it(kafka_input, queue)
  begin
    wait(timeout_seconds).for {queue.length}.to eq(expected_num_events)
    yield(queue)
  ensure
    t.kill
    t.join(30_000)
  end
end

shared_examples 'consumes all expected messages' do
  it 'should consume all expected messages' do
    run_with_kafka do |queue|
      expect(queue.length).to eq(expected_num_events)
    end
  end
end

# Please run kafka_test_setup.sh prior to executing this integration test.
describe "inputs/kafka", :integration => true do
  subject(:kafka_input) { LogStash::Inputs::Kafka.new(config) }
  let(:execution_context) { double("execution_context")}

  before :each do
    allow(kafka_input).to receive(:execution_context).and_return(execution_context)
    allow(execution_context).to receive(:pipeline_id).and_return(pipeline_id)
  end

  # Group ids to make sure that the consumers get all the logs.
  let(:group_id_1) {rand(36**8).to_s(36)}
  let(:group_id_2) {rand(36**8).to_s(36)}
  let(:group_id_3) {rand(36**8).to_s(36)}
  let(:group_id_4) {rand(36**8).to_s(36)}
  let(:pipeline_id) {rand(36**8).to_s(36)}
  let(:config) { { 'codec' => 'plain', 'auto_offset_reset' => 'earliest'}}
  let(:timeout_seconds) { 30 }
  let(:num_events) { 103 }
  let(:expected_num_events) { num_events }

  context 'from a plain 3 partition topic' do
    let(:config)  { super.merge({ 'topics' => ['logstash_topic_plain'], 'group_id' => group_id_1}) }
    it_behaves_like 'consumes all expected messages'
  end

  context 'from snappy 3 partition topic' do
    let(:config) { { 'topics' => ['logstash_topic_snappy'], 'codec' => 'plain', 'group_id' => group_id_1, 'auto_offset_reset' => 'earliest'} }
    it_behaves_like 'consumes all expected messages'
  end

  context 'from lz4 3 partition topic' do
    let(:config) { { 'topics' => ['logstash_topic_lz4'], 'codec' => 'plain', 'group_id' => group_id_1, 'auto_offset_reset' => 'earliest'} }
    it_behaves_like 'consumes all expected messages'
  end

  context 'manually committing' do
    let(:config) { { 'topics' => ['logstash_topic_plain'], 'codec' => 'plain', 'group_id' => group_id_2, 'auto_offset_reset' => 'earliest', 'enable_auto_commit' => 'false'} }
    it_behaves_like 'consumes all expected messages'
  end

  context 'using a pattern to consume from all 3 topics' do
    let(:config) { { 'topics_pattern' => 'logstash_topic_.*', 'group_id' => group_id_3, 'codec' => 'plain', 'auto_offset_reset' => 'earliest'} }
    let(:expected_num_events) { 3*num_events }
    it_behaves_like 'consumes all expected messages'
  end

  context "with multiple consumers" do
    let(:config) { super.merge({'topics' => ['logstash_topic_plain'], "group_id" => group_id_4, "client_id" => "spec", "consumer_threads" => 3}) }
    it 'should should consume all messages' do
      run_with_kafka do |queue|
        expect(queue.length).to eq(num_events)
        kafka_input.kafka_consumers.each_with_index do |consumer, i|
          expect(consumer.metrics.keys.first.tags["client-id"]).to eq("spec-#{i}-#{pipeline_id}")
        end
      end
    end
  end

  context 'with decorate events set to true' do
    let(:config) { { 'topics' => ['logstash_topic_plain'], 'codec' => 'plain', 'group_id' => group_id_3, 'auto_offset_reset' => 'earliest', 'decorate_events' => true} }
    it "should show the right topic and group name in decorated kafka section" do
      start = LogStash::Timestamp.now.time.to_i
      run_with_kafka do  |queue|
        expect(queue.length).to eq(num_events)
        event = queue.shift
        expect(event.get("[@metadata][kafka][topic]")).to eq("logstash_topic_plain")
        expect(event.get("[@metadata][kafka][consumer_group]")).to eq(group_id_3)
        expect(event.get("[@metadata][kafka][timestamp]")).to be >= start
      end
    end
  end
end
