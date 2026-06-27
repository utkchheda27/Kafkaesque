#!/bin/bash

set -e

KAFKA_HOME="$HOME/Downloads/kafka_2.13-4.3.0"

echo "Moving to Kafka directory..."
cd "$KAFKA_HOME" || {
  echo "Kafka directory not found!"
  exit 1
}

echo "Generating Cluster ID..."
CLUSTER_ID=$(bin/kafka-storage.sh random-uuid)

echo "Generated Cluster ID: $CLUSTER_ID"

echo "Formatting Controller 1..."
bin/kafka-storage.sh format -t "$CLUSTER_ID" -c config/controller1.properties

echo "Formatting Controller 2..."
bin/kafka-storage.sh format -t "$CLUSTER_ID" -c config/controller2.properties

echo "Formatting Broker 1..."
bin/kafka-storage.sh format -t "$CLUSTER_ID" -c config/broker1.properties

echo "Formatting Broker 2..."
bin/kafka-storage.sh format -t "$CLUSTER_ID" -c config/broker2.properties

echo "Starting Controller 1..."
bin/kafka-server-start.sh config/controller1.properties > logs/controller1.log 2>&1 &
CONTROLLER1_PID=$!

sleep 2

echo "Starting Controller 2..."
bin/kafka-server-start.sh config/controller2.properties > logs/controller2.log 2>&1 &
CONTROLLER2_PID=$!

sleep 2

echo "Starting Broker 1..."
bin/kafka-server-start.sh config/broker1.properties > logs/broker1.log 2>&1 &
BROKER1_PID=$!

sleep 2

echo "Starting Broker 2..."
bin/kafka-server-start.sh config/broker2.properties > logs/broker2.log 2>&1 &
BROKER2_PID=$!

echo
echo "Kafka processes started:"
echo "Controller1 PID: $CONTROLLER1_PID"
echo "Controller2 PID: $CONTROLLER2_PID"
echo "Broker1 PID: $BROKER1_PID"
echo "Broker2 PID: $BROKER2_PID"

echo
echo "Waiting for brokers to become available..."
sleep 15

echo
echo "Topic Description: order-events"
bin/kafka-topics.sh \
  --bootstrap-server localhost:9092 \
  --describe \
  --topic order-events

echo
echo "Kafka cluster is up."
echo "Cluster ID: $CLUSTER_ID"