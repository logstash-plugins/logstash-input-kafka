# encoding: utf-8
require "logstash/devutils/rspec/spec_helper"
require "logstash/inputs/kafka"
require_relative "../logstash-input-kafka_test_jars.rb"

java_import "java.util.Properties"                                                                                      
java_import "kafka.server.KafkaConfig"
java_import "kafka.server.KafkaServerStartable"
java_import "org.apache.zookeeper.server.ServerConfig"
java_import "org.apache.zookeeper.server.ZooKeeperServerMain"
java_import "org.apache.zookeeper.server.quorum.QuorumPeerConfig"


describe "input/kafka", :integration => true do
  before do
    zk_props = Properties.new
    zk_props.set_property("dataDir", "/tmp/zk")
    zk_props.set_property("clientPort", "2181")
    zk = ZooKeeperServerMain.new
    quorum_configuration = QuorumPeerConfig.new
    quorum_configuration.parse_properties(zk_props)
    config = ServerConfig.new
    config.read_from(quorum_configuration)

    Thread.new do
      zk.run_from_config(config)
    end
    sleep 1

    kafka_props = Properties.new
    kafka_props.set_property("zookeeper.connect", "localhost:2181")
    kafka_props.set_property("broker.id", "0")
    kafka_config = KafkaConfig.new(kafka_props)
    server = KafkaServerStartable.new(kafka_config)
    server.startup
    sleep 5
    server.shutdown
    server.await_shutdown
  end

  it "works" do
  end
end
