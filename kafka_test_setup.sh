#!/bin/bash
# Setup Kafka and create test topics

set -ex

echo "Downloading Kafka version $KAFKA_VERSION"
curl -s -o kafka.tgz "http://ftp.wayne.edu/apache/kafka/$KAFKA_VERSION/kafka_2.11-$KAFKA_VERSION.tgz"
mkdir kafka && tar -xzvf kafka.tgz -C kafka --strip-components 1

echo "Starting ZooKeeper"
kafka/bin/zookeeper-server-start.sh kafka/config/zookeeper.properties &
echo "Starting Kafka broker"
kafka/bin/kafka-server-start.sh kafka/config/server.properties &
sleep 3

echo "Setting up test topics with test data"
kafka/bin/kafka-topics.sh --create --partitions 3 --replication-factor 1 --topic topic3 --zookeeper localhost:2181
kafka/bin/kafka-topics.sh --create --partitions 3 --replication-factor 1 --topic snappy_topic --zookeeper localhost:2181
kafka/bin/kafka-topics.sh --create --partitions 3 --replication-factor 1 --topic lz4_topic --zookeeper localhost:2181
wget https://s3.amazonaws.com/data.elasticsearch.org/apache_logs/apache_logs.txt
cat apache_logs.txt | kafka/bin/kafka-console-producer.sh --topic topic3 --broker-list localhost:9092
cat apache_logs.txt | kafka/bin/kafka-console-producer.sh --topic snappy_topic --broker-list localhost:9092 --compression-codec snappy
cat apache_logs.txt | kafka/bin/kafka-console-producer.sh --topic lz4_topic --broker-list localhost:9092 --compression-codec lz4

echo "Setup complete, running specs"
