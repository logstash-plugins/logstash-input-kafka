# encoding: utf-8
require "logstash/devutils/rspec/spec_helper"
require "logstash/inputs/kafka"
require "digest"

describe "input/kafka", :integration => true do
  let(:partition3_config) { { 'topics' => ['topic3'], 'codec' => 'plain', 'auto_offset_reset' => 'earliest'} }
  
  let(:tries) { 60 }
  let(:num_events) { 103 }
  
  def wait_until_count(queue)
    num_tries = tries
    while (num_tries > 0)
      break if queue.size == num_events
      num_tries -= 1
      sleep 1
    end
  end
  
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
    
    wait_until_count(queue)
    
    expect(queue.size).to eq(num_events)
  end

end
