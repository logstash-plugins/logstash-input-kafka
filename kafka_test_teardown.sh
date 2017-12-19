#!/bin/bash
set -ex

echo "Stopping Kafka broker"
build/kafka/bin/kafka-server-stop.sh
echo "Stopping zookeeper"
build/kafka/bin/zookeeper-server-stop.sh
echo "See what processes are hanging around"
ps aux
