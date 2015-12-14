# encoding: utf-8
require "logstash/devutils/rspec/spec_helper"
require "logstash/inputs/kafka"
require "concurrent"

class MockConsumer
  def initialize
    @wake = Concurrent::AtomicBoolean.new(false)
  end

  def subscribe(topics)
  end
  
  def poll(ms)
    if @wake.value
      raise org.apache.kafka.common.errors.WakeupException.new
    else
      10.times.map do
        org.apache.kafka.clients.consumer.ConsumerRecord.new("test", 0, 0, "key", "value")
      end
    end
  end

  def close
  end

  def wakeup
    @wake.make_true
  end
end

describe LogStash::Inputs::Kafka do
  let(:config) { { 'topics' => ['test'], 'num_threads' => 4 } }
  subject { LogStash::Inputs::Kafka.new(config) }

  it "should register" do
    expect {subject.register}.to_not raise_error
  end

  it "should run" do
    expect(subject).to receive(:new_consumer) do
      MockConsumer.new
    end.exactly(4).times

    subject.register
    q = Queue.new
    Thread.new do
      while q.size < 13
      end
      subject.do_stop
    end
    subject.run(q)

    expect(q.size).to eq(40)
  end
end
