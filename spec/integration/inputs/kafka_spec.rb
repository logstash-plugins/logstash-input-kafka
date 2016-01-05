# encoding: utf-8
require "logstash/devutils/rspec/spec_helper"
require "logstash/inputs/kafka"
require_relative "../logstash-input-kafka_test_jars.rb"

java_import "kafka.admin.AdminUtils"                                                                                    
java_import "kafka.utils.ZKStringSerializer"                                                                            
#java_import "org.I0Itec.zkclient.ZkClient"                                                                              
java_import "java.util.Properties"                                                                                      
java_import "kafka.utils.ZkUtils"
java_import "org.apache.kafka.clients.producer.KafkaProducer"
java_import "org.apache.kafka.clients.producer.ProducerRecord"

describe "input/kafka", :integration => true do
  before do
    props = Properties.new
    props.put("bootstrap.servers", bootstrap_servers)
    props.put("acks", "all")
    props.put("retries", "0")
    props.put("batch.size", "16384")
    props.put("linger.ms", "1")
    props.put("buffer.memory", "33554432")
    props.put("key.serializer", "org.apache.kafka.common.serialization.StringSerializer")
    props.put("value.serializer", "org.apache.kafka.common.serialization.StringSerializer")
    producer = KafkaProducer.new(props)
    1000.times do |i|
      producer.send(ProducerRecord("test", i.to_s, i.to_s))
    end
  end
end
