#!/bin/bash
# Setup Kafka and create test topics

set -ex
if [ -n "${KAFKA_VERSION+1}" ]; then
  echo "KAFKA_VERSION is $KAFKA_VERSION"
else
   KAFKA_VERSION=0.9.0.0
fi

echo "Downloading Kafka version $KAFKA_VERSION"
curl -s -o kafka.tgz "http://ftp.wayne.edu/apache/kafka/$KAFKA_VERSION/kafka_2.11-$KAFKA_VERSION.tgz"
mkdir kafka && tar xzf kafka.tgz -C kafka --strip-components 1

echo "Starting ZooKeeper"
kafka/bin/zookeeper-server-start.sh kafka/config/zookeeper.properties &
sleep 10
echo "Starting Kafka broker"
kafka/bin/kafka-server-start.sh kafka/config/server.properties &
sleep 10

echo "Setting up test topics with test data"
kafka/bin/kafka-topics.sh --create --partitions 3 --replication-factor 1 --topic logstash_topic_plain --zookeeper localhost:2181
sleep 10
kafka/bin/kafka-topics.sh --create --partitions 3 --replication-factor 1 --topic logstash_topic_snappy --zookeeper localhost:2181
sleep 10
kafka/bin/kafka-topics.sh --create --partitions 3 --replication-factor 1 --topic logstash_topic_lz4 --zookeeper localhost:2181
wget https://s3.amazonaws.com/data.elasticsearch.org/apache_logs/apache_logs.txt
sleep 60
cat apache_logs.txt | kafka/bin/kafka-console-producer.sh --topic logstash_topic_plain --broker-list localhost:9092
sleep 10
cat apache_logs.txt | kafka/bin/kafka-console-producer.sh --topic logstash_topic_snappy --broker-list localhost:9092 --compression-codec snappy
sleep 10
cat apache_logs.txt | kafka/bin/kafka-console-producer.sh --topic logstash_topic_lz4 --broker-list localhost:9092 --compression-codec lz4
sleep 10
echo "Setup complete, running specs"
