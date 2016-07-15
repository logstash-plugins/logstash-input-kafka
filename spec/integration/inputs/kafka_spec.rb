# encoding: utf-8
require "logstash/devutils/rspec/spec_helper"
require "logstash/inputs/kafka"
require "digest"
require "rspec/wait"

# Please run kafka_test_setup.sh prior to executing this integration test.
describe "inputs/kafka", :integration => true do
  # Group ids to make sure that the consumers get all the logs.
  let(:group_id_1) {rand(36**8).to_s(36)}
  let(:group_id_2) {rand(36**8).to_s(36)}
  let(:group_id_3) {rand(36**8).to_s(36)}
  let(:plain_config) { { 'topics' => ['logstash_topic_plain'], 'codec' => 'plain', 'group_id' => group_id_1, 'auto_offset_reset' => 'earliest'} }
  let(:snappy_config) { { 'topics' => ['logstash_topic_snappy'], 'codec' => 'plain', 'group_id' => group_id_1, 'auto_offset_reset' => 'earliest'} }
  let(:lz4_config) { { 'topics' => ['logstash_topic_lz4'], 'codec' => 'plain', 'group_id' => group_id_1, 'auto_offset_reset' => 'earliest'} }
  let(:pattern_config) { { 'topics_pattern' => 'logstash_topic_.*', 'group_id' => group_id_2, 'codec' => 'plain', 'auto_offset_reset' => 'earliest'} }  
  let(:decorate_config) { { 'topics' => ['logstash_topic_plain'], 'codec' => 'plain', 'group_id' => group_id_3, 'auto_offset_reset' => 'earliest', 'decorate_events' => true} }
  let(:timeout_seconds) { 120 }
  let(:num_events) { 103 }

  describe "#kafka-topics" do
    def thread_it(kafka_input, queue)
      Thread.new do
        begin
          kafka_input.run(queue)
        end
      end
    end

    it "should consume all messages from plain 3-partition topic" do
      kafka_input = LogStash::Inputs::Kafka.new(plain_config)
      queue = Array.new
      t = thread_it(kafka_input, queue)
      t.run
      wait(timeout_seconds).for { queue.length }.to eq(num_events)
      expect(queue.length).to eq(num_events)
    end

    it "should consume all messages from snappy 3-partition topic" do
      kafka_input = LogStash::Inputs::Kafka.new(snappy_config)
      queue = Array.new
      t = thread_it(kafka_input, queue)
      t.run
      wait(timeout_seconds).for { queue.length }.to eq(num_events)
      expect(queue.length).to eq(num_events)
    end

    it "should consume all messages from lz4 3-partition topic" do
      kafka_input = LogStash::Inputs::Kafka.new(lz4_config)
      queue = Array.new
      t = thread_it(kafka_input, queue)
      t.run
      wait(timeout_seconds).for { queue.length }.to eq(num_events)
      expect(queue.length).to eq(num_events)
    end
    
  end

  describe "#kafka-topics-pattern" do
    
    def thread_it(kafka_input, queue)
      Thread.new do
        begin
          kafka_input.run(queue)
        end
      end
    end
      
    it "should consume all messages from all 3 topics" do
      kafka_input = LogStash::Inputs::Kafka.new(pattern_config)
      queue = Array.new
      t = thread_it(kafka_input, queue)
      t.run
      wait(timeout_seconds).for { queue.length }.to eq(3*num_events)
      expect(queue.length).to eq(3*num_events)
    end    
  end

  describe "#kafka-decorate" do
    def thread_it(kafka_input, queue)
      Thread.new do
        begin
          kafka_input.run(queue)
        end
      end
    end
      
    it "should show the right topic and group name in decorated kafka section" do
      kafka_input = LogStash::Inputs::Kafka.new(decorate_config)
      queue = Queue.new
      t = thread_it(kafka_input, queue)
      t.run
      wait(timeout_seconds).for { queue.length }.to eq(num_events)
      expect(queue.length).to eq(num_events)
      event = queue.shift
      expect(event.get("kafka")["topic"]).to eq("logstash_topic_plain")
      expect(event.get("kafka")["consumer_group"]).to eq(group_id_3)
    end
  end
end
