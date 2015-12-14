# encoding: utf-8
require "logstash/devutils/rspec/spec_helper"
require "logstash/inputs/kafka"

describe "input/kafka", :integration => true do
  before do
    props = java.util.Properties.new
    props.put("bootstrap.servers", bootstrap_servers)
    props.put("acks", "all")
    props.put("retries", "0")
    props.put("batch.size", "16384")
    props.put("linger.ms", "1")
    props.put("buffer.memory", "33554432")
    props.put("key.serializer", "org.apache.kafka.common.serialization.StringSerializer")
    props.put("value.serializer", "org.apache.kafka.common.serialization.StringSerializer")
    producer = org.apache.kafka.clients.producer.KafkaProducer.new(props)
    1000.times do |i|
      producer.send(org.apache.kafka.clients.producer.ProducerRecord("test", i.to_s, i.to_s))
    end
  end
end
