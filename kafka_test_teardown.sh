#!/bin/bash
set -ex

echo "Stopping Kafka broker"
build/kafka/bin/kafka-server-stop.sh
echo "Stopping zookeeper"
build/kafka/bin/zookeeper-server-stop.sh
echo "Stopped"
cat Gemfile.lock
