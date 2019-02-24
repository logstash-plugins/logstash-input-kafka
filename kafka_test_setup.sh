#!/bin/bash
# Setup Kafka and create test topics

set -ex
if [ -n "${KAFKA_VERSION+1}" ]; then
  echo "KAFKA_VERSION is $KAFKA_VERSION"
else
   KAFKA_VERSION=2.1.1
fi

export _JAVA_OPTIONS="-Djava.net.preferIPv4Stack=true"

rm -rf build
mkdir build

echo "Downloading Kafka version $KAFKA_VERSION"
curl -s -o build/kafka.tgz "http://ftp.wayne.edu/apache/kafka/$KAFKA_VERSION/kafka_2.11-$KAFKA_VERSION.tgz"
mkdir build/kafka && tar xzf build/kafka.tgz -C build/kafka --strip-components 1

echo "Starting ZooKeeper"
build/kafka/bin/zookeeper-server-start.sh -daemon build/kafka/config/zookeeper.properties
sleep 10
echo "Starting Kafka broker"
build/kafka/bin/kafka-server-start.sh -daemon build/kafka/config/server.properties --override advertised.host.name=127.0.0.1 --override log.dirs="${PWD}/build/kafka-logs"
sleep 10

echo "Setting up test topics with test data"
build/kafka/bin/kafka-topics.sh --create --partitions 3 --replication-factor 1 --topic logstash_topic_plain --zookeeper localhost:2181
build/kafka/bin/kafka-topics.sh --create --partitions 3 --replication-factor 1 --topic logstash_topic_snappy --zookeeper localhost:2181
build/kafka/bin/kafka-topics.sh --create --partitions 3 --replication-factor 1 --topic logstash_topic_lz4 --zookeeper localhost:2181
curl -s -o build/apache_logs.txt https://s3.amazonaws.com/data.elasticsearch.org/apache_logs/apache_logs.txt
cat build/apache_logs.txt | build/kafka/bin/kafka-console-producer.sh --topic logstash_topic_plain --broker-list localhost:9092
cat build/apache_logs.txt | build/kafka/bin/kafka-console-producer.sh --topic logstash_topic_snappy --broker-list localhost:9092 --compression-codec snappy
cat build/apache_logs.txt | build/kafka/bin/kafka-console-producer.sh --topic logstash_topic_lz4 --broker-list localhost:9092 --compression-codec lz4
echo "Setup complete, running specs"
