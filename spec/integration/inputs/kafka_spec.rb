# encoding: utf-8
require "logstash/devutils/rspec/spec_helper"
require "logstash/inputs/kafka"
require "digest"
require "rspec/wait"

# Please run kafka_test_setup.sh prior to executing this integration test.
describe "inputs/kafka", :integration => true do

  describe "#kafka-topics" do
    let(:group_id) {rand(36**8).to_s(36)}
    let(:partition3_config) { { 'topics' => ['logstash_topic_uncompressed'], 'codec' => 'plain', 'group_id' => group_id, 'auto_offset_reset' => 'earliest'} }
    let(:snappy_config) { { 'topics' => ['logstash_topic_snappy'], 'codec' => 'plain', 'group_id' => group_id, 'auto_offset_reset' => 'earliest'} }
    let(:lz4_config) { { 'topics' => ['logstash_topic_lz4'], 'codec' => 'plain', 'group_id' => group_id, 'auto_offset_reset' => 'earliest'} }
    
    let(:timeout_seconds) { 10 }
    let(:num_events) { 103 }
    
    def thread_it(kafka_input, queue)
      Thread.new do
        begin
          kafka_input.run(queue)
        end
      end
    end
      
    it "should consume all messages from 3-partition topic" do
      kafka_input = LogStash::Inputs::Kafka.new(partition3_config)
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
    let(:group_id) {rand(36**8).to_s(36)}
    let(:pattern_config) { { 'topics_pattern' => 'logstash_topic_.*', 'group_id' => group_id, 'codec' => 'plain', 'auto_offset_reset' => 'earliest'} }  
    let(:timeout_seconds) { 10 }
    let(:num_events) { 309 }
    
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
      wait(timeout_seconds).for { queue.length }.to eq(num_events)
      expect(queue.length).to eq(num_events)
    end    
  end

  describe "#kafka-decorate" do
    let(:group_id) {rand(36**8).to_s(36)}
    let(:topic) {"logstash_topic_uncompressed"}
    let(:partition3_config) { { 'topics' => [topic], 'group_id' => group_id, 'codec' => 'plain', 'auto_offset_reset' => 'earliest', 'decorate_events' => true} }    
    let(:timeout_seconds) { 10 }
    let(:num_events) { 103 }
    
    def thread_it(kafka_input, queue)
      Thread.new do
        begin
          kafka_input.run(queue)
        end
      end
    end
      
    it "should show the right topic name in decorate" do
      kafka_input = LogStash::Inputs::Kafka.new(partition3_config)
      queue = Queue.new
      t = thread_it(kafka_input, queue)
      t.run
      wait(timeout_seconds).for { queue.length }.to eq(num_events)
      expect(queue.length).to eq(num_events)
      event = queue.shift
      expect(event.get("kafka")["topic"]).to eq(topic)
      expect(event.get("kafka")["consumer_group"]).to eq(group_id)
    end
  end
end
