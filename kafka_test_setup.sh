#!/bin/bash
# Setup Kafka and create test topics

set -ex
if [ -n "${KAFKA_VERSION+1}" ]; then
  echo "KAFKA_VERSION is $KAFKA_VERSION"
else
   KAFKA_VERSION==0.10.0.0
fi

echo "Downloading Kafka version $KAFKA_VERSION"
curl -s -o kafka.tgz "http://ftp.wayne.edu/apache/kafka/$KAFKA_VERSION/kafka_2.11-$KAFKA_VERSION.tgz"
mkdir kafka && tar xzf kafka.tgz -C kafka --strip-components 1

echo "Starting ZooKeeper"
kafka/bin/zookeeper-server-start.sh kafka/config/zookeeper.properties &
echo "Starting Kafka broker"
kafka/bin/kafka-server-start.sh kafka/config/server.properties &
sleep 3

echo "Setting up test topics with test data"
kafka/bin/kafka-topics.sh --create --partitions 3 --replication-factor 1 --topic logstash_topic_uncompressed --zookeeper localhost:2181
kafka/bin/kafka-topics.sh --create --partitions 3 --replication-factor 1 --topic logstash_topic_snappy --zookeeper localhost:2181
kafka/bin/kafka-topics.sh --create --partitions 3 --replication-factor 1 --topic logstash_topic_lz4 --zookeeper localhost:2181
wget https://s3.amazonaws.com/data.elasticsearch.org/apache_logs/apache_logs.txt
cat apache_logs.txt | kafka/bin/kafka-console-producer.sh --topic logstash_topic_uncompressed --broker-list localhost:9092
cat apache_logs.txt | kafka/bin/kafka-console-producer.sh --topic logstash_topic_snappy --broker-list localhost:9092 --compression-codec snappy
cat apache_logs.txt | kafka/bin/kafka-console-producer.sh --topic logstash_topic_lz4 --broker-list localhost:9092 --compression-codec lz4

echo "Setup complete, running specs"
