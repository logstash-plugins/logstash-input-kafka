# encoding: utf-8
require 'spec_helper'

describe 'inputs/kafka' do

  let (:kafka_config) {{'topic_id' => 'test'}}

  it "should register" do
    input = LogStash::Plugin.lookup("input", "kafka").new(kafka_config)
    expect {input.register}.to_not raise_error
  end

  it 'should populate kafka config with default values' do
    kafka = LogStash::Inputs::Kafka.new(kafka_config)
    insist {kafka.zk_connect} == 'localhost:2181'
    insist {kafka.topic_id} == 'test'
    insist {kafka.group_id} == 'logstash'
    !insist { kafka.reset_beginning }
  end

  it 'should retrieve event from kafka' do
    # Extend class to control behavior
    class LogStash::Inputs::TestKafka < LogStash::Inputs::Kafka
      milestone 1
      private
      def queue_event(msg, output_queue)
        super(msg, output_queue)
        # need to raise exception here to stop the infinite loop
        raise LogStash::ShutdownSignal
      end
    end

    kafka = LogStash::Inputs::TestKafka.new(kafka_config)
    kafka.register

    class Kafka::Group
      public
      def run(a_num_threads, a_queue)
        a_queue << 'Kafka message'
      end
    end

    logstash_queue = Queue.new
    kafka.run logstash_queue
    e = logstash_queue.pop
    insist { e['message'] } == 'Kafka message'
    # no metadata by default
    insist { e['kafka'] } == nil
  end

end
