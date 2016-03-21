# encoding: utf-8
require "logstash/devutils/rspec/spec_helper"
require "logstash/inputs/kafka"
require 'jruby-kafka'

class LogStash::Inputs::TestKafka < LogStash::Inputs::Kafka
  private
  def queue_event(msg, output_queue)
    super(msg, output_queue)
    do_stop
  end
end

class TestMessageAndMetadata
  attr_reader :topic, :partition, :key, :message, :offset
  def initialize(topic, partition, key, message, offset)
    @topic = topic
    @partition = partition
    @key = key
    @message = message
    @offset = offset
  end
end

class TestMessageStreamIterator < Queue
  def initialize(stopper)
    super()
    @shutdown_called = stopper
  end

  def hasNext
    !self.empty?
  end

  def next
    self.pop
  end
end

class TestInfiniteStreamIterator < TestMessageStreamIterator
  def initialize(stopper)
    super(stopper)
  end

  def hasNext
    unless @shutdown_called.value
      blah = TestMessageAndMetadata.new(@topic, 0, nil, 'Kafka message', 1)
      self << blah
    end
    super
  end
end

class TestMessageStream
  attr_reader :iterator
  def initialize(iterator)
    @iterator = iterator
  end
end

class TestKafkaConsumer < Kafka::Consumer
  def initialize(options)
    super(options)
    @shutdown_called = Concurrent::AtomicBoolean.new(false)
  end

  def connect
    nil
  end

  def message_streams
    stream = TestMessageStream.new(TestMessageStreamIterator.new(@shutdown_called))
    blah = TestMessageAndMetadata.new(@topic, 0, nil, 'Kafka message', 1)
    stream.iterator << blah
    [stream]
  end

  def shutdown
    @shutdown_called.make_true
  end
end

class LogStash::Inputs::TestInfiniteKafka < LogStash::Inputs::Kafka
  private
  def queue_event(msg, output_queue)
    super(msg, output_queue)
  end
end

class TestInfiniteKafkaConsumer < TestKafkaConsumer
  def message_streams
    [TestMessageStream.new(TestInfiniteStreamIterator.new(@shutdown_called))]
  end
end

describe LogStash::Inputs::Kafka do
  let (:kafka_config) {{'topic_id' => 'test', 'consumer_restart_on_error' => 'false'}}
  let (:empty_config) {{}}
  let (:bad_kafka_config) {{'topic_id' => 'test', 'white_list' => 'other_topic'}}
  let (:white_list_kafka_config) {{'white_list' => 'other_topic', 'consumer_restart_on_error' => 'false'}}
  let (:decorated_kafka_config) {{'topic_id' => 'test', 'decorate_events' => true, 'consumer_restart_on_error' => 'false'}}

  it "should register" do
    input = LogStash::Plugin.lookup("input", "kafka").new(kafka_config)
    expect {input.register}.to_not raise_error
  end

  it "should register with whitelist" do
    input = LogStash::Plugin.lookup("input", "kafka").new(white_list_kafka_config)
    expect {input.register}.to_not raise_error
  end

  it "should fail with multiple topic configs" do
    input = LogStash::Plugin.lookup("input", "kafka").new(empty_config)
    expect {input.register}.to raise_error
  end

  it "should fail without topic configs" do
    input = LogStash::Plugin.lookup("input", "kafka").new(bad_kafka_config)
    expect {input.register}.to raise_error
  end

  it_behaves_like "an interruptible input plugin" do
    let(:config) { kafka_config }
    let(:mock_kafka_plugin) { LogStash::Inputs::TestInfiniteKafka.new(config) }

    before :each do
      allow(LogStash::Inputs::Kafka).to receive(:new).and_return(mock_kafka_plugin)
      expect(subject).to receive(:create_consumer) do |options|
        TestInfiniteKafkaConsumer.new(options)
      end
    end
  end

  it 'should populate kafka config with default values' do
    kafka = LogStash::Inputs::TestKafka.new(kafka_config)
    insist {kafka.zk_connect} == 'localhost:2181'
    insist {kafka.topic_id} == 'test'
    insist {kafka.group_id} == 'logstash'
    !insist { kafka.reset_beginning }
  end

  it 'should retrieve event from kafka' do
    kafka = LogStash::Inputs::TestKafka.new(kafka_config)
    expect(kafka).to receive(:create_consumer) do |options|
      TestKafkaConsumer.new(options)
    end
    kafka.register

    logstash_queue = Queue.new
    kafka.run logstash_queue
    e = logstash_queue.pop
    insist { e['message'] } == 'Kafka message'
    # no metadata by default
    insist { e['kafka'] } == nil
  end

  it 'should retrieve a decorated event from kafka' do
    kafka = LogStash::Inputs::TestKafka.new(decorated_kafka_config)
    expect(kafka).to receive(:create_consumer) do |options|
      TestKafkaConsumer.new(options)
    end
    kafka.register

    logstash_queue = Queue.new
    kafka.run logstash_queue
    e = logstash_queue.pop
    insist { e['message'] } == 'Kafka message'
    # no metadata by default
    insist { e['kafka']['topic'] } == 'test'
    insist { e['kafka']['consumer_group'] } == 'logstash'
    insist { e['kafka']['msg_size'] } == 13
    insist { e['kafka']['partition'] } == 0
    insist { e['kafka']['key'] } == nil
    insist { e['kafka']['offset'] } == 1
  end
end
