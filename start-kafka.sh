#!/bin/bash

# Kafka Complete Startup Script
# This script sets up and starts the entire Kafka cluster with the producer application

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}Kafka Cluster Setup and Startup Script${NC}"
echo -e "${YELLOW}========================================${NC}"

# Configuration
KAFKA_HOME="${KAFKA_HOME:-.}"
CLUSTER_BASE_DIR="/home/utkarsh/Desktop/Kafkaesque/Basic cluster setup"
PRODUCER_DIR="/home/utkarsh/Desktop/Kafkaesque/ProducerSetup"

# Function to display usage
usage() {
    echo "Usage: $0 [option]"
    echo "Options:"
    echo "  setup      - Format storage for all nodes (run once)"
    echo "  start-all  - Start all controllers and brokers in background"
    echo "  stop-all   - Stop all Kafka processes"
    echo "  start-producer - Start producer application"
    echo "  full-setup - Complete setup (format + start)"
    echo "  help       - Show this help message"
}

# Function to check if Kafka is installed
check_kafka() {
    if [ ! -f "$KAFKA_HOME/bin/kafka-storage.sh" ]; then
        echo -e "${RED}ERROR: Kafka not found at $KAFKA_HOME${NC}"
        echo "Please set KAFKA_HOME environment variable correctly"
        exit 1
    fi
}

# Function to generate cluster ID
generate_cluster_id() {
    echo -e "${YELLOW}Generating Cluster ID...${NC}"
    CLUSTER_ID=$("$KAFKA_HOME/bin/kafka-storage.sh" random-uuid)
    echo -e "${GREEN}Cluster ID: $CLUSTER_ID${NC}"
    echo "$CLUSTER_ID" > /tmp/kafka_cluster_id.txt
}

# Function to format storage
format_storage() {
    echo -e "${YELLOW}Formatting storage for all nodes...${NC}"

    CLUSTER_ID=$(cat /tmp/kafka_cluster_id.txt 2>/dev/null || generate_cluster_id)

    echo -e "${YELLOW}Formatting Controller 1...${NC}"
    "$KAFKA_HOME/bin/kafka-storage.sh" format \
        -t "$CLUSTER_ID" \
        -c "$CLUSTER_BASE_DIR/controller1.properties" \
        --force 2>/dev/null || true

    echo -e "${YELLOW}Formatting Controller 2...${NC}"
    "$KAFKA_HOME/bin/kafka-storage.sh" format \
        -t "$CLUSTER_ID" \
        -c "$CLUSTER_BASE_DIR/controller2.properties" \
        --force 2>/dev/null || true

    echo -e "${YELLOW}Formatting Broker 1...${NC}"
    "$KAFKA_HOME/bin/kafka-storage.sh" format \
        -t "$CLUSTER_ID" \
        -c "$CLUSTER_BASE_DIR/broker1.properties" \
        --force 2>/dev/null || true

    echo -e "${YELLOW}Formatting Broker 2...${NC}"
    "$KAFKA_HOME/bin/kafka-storage.sh" format \
        -t "$CLUSTER_ID" \
        -c "$CLUSTER_BASE_DIR/broker2.properties" \
        --force 2>/dev/null || true

    echo -e "${GREEN}Storage formatting complete!${NC}"
}

# Function to start all nodes
start_all() {
    echo -e "${YELLOW}Starting Kafka Cluster...${NC}"

    # Create log directories
    mkdir -p /tmp/controller1-logs /tmp/controller2-logs /tmp/broker1-logs /tmp/broker2-logs

    # Start Controller 1
    echo -e "${YELLOW}Starting Controller 1 (Active)...${NC}"
    nohup "$KAFKA_HOME/bin/kafka-server-start.sh" \
        "$CLUSTER_BASE_DIR/controller1.properties" \
        > /tmp/controller1.log 2>&1 &
    echo $! > /tmp/controller1.pid

    # Start Controller 2
    echo -e "${YELLOW}Starting Controller 2 (Watcher)...${NC}"
    nohup "$KAFKA_HOME/bin/kafka-server-start.sh" \
        "$CLUSTER_BASE_DIR/controller2.properties" \
        > /tmp/controller2.log 2>&1 &
    echo $! > /tmp/controller2.pid

    # Wait for controllers to start
    sleep 3

    # Start Broker 1
    echo -e "${YELLOW}Starting Broker 1...${NC}"
    nohup "$KAFKA_HOME/bin/kafka-server-start.sh" \
        "$CLUSTER_BASE_DIR/broker1.properties" \
        > /tmp/broker1.log 2>&1 &
    echo $! > /tmp/broker1.pid

    # Start Broker 2
    echo -e "${YELLOW}Starting Broker 2...${NC}"
    nohup "$KAFKA_HOME/bin/kafka-server-start.sh" \
        "$CLUSTER_BASE_DIR/broker2.properties" \
        > /tmp/broker2.log 2>&1 &
    echo $! > /tmp/broker2.pid

    echo -e "${GREEN}Kafka cluster started in background!${NC}"
    echo -e "${YELLOW}Waiting for cluster to stabilize (10 seconds)...${NC}"
    sleep 10

    # Create topic
    create_topic
}

# Function to create topic
create_topic() {
    echo -e "${YELLOW}Creating order-events topic...${NC}"
    "$KAFKA_HOME/bin/kafka-topics.sh" --create \
        --topic order-events \
        --bootstrap-server localhost:9092 \
        --partitions 4 \
        --replication-factor 2 \
        --config cleanup.policy=delete \
        --config min.insync.replicas=2 \
        --config retention.ms=604800000 \
        --if-not-exists 2>/dev/null || true

    echo -e "${GREEN}Topic created/verified!${NC}"
}

# Function to stop all processes
stop_all() {
    echo -e "${YELLOW}Stopping Kafka cluster...${NC}"

    for pid_file in /tmp/controller1.pid /tmp/controller2.pid /tmp/broker1.pid /tmp/broker2.pid; do
        if [ -f "$pid_file" ]; then
            pid=$(cat "$pid_file")
            if kill -0 "$pid" 2>/dev/null; then
                echo -e "${YELLOW}Stopping process $pid...${NC}"
                kill "$pid" 2>/dev/null || true
                rm "$pid_file"
            fi
        fi
    done

    echo -e "${GREEN}Kafka cluster stopped!${NC}"
}

# Function to start producer
start_producer() {
    echo -e "${YELLOW}Starting Producer Application...${NC}"

    if [ ! -d "$PRODUCER_DIR" ]; then
        echo -e "${RED}ERROR: Producer directory not found at $PRODUCER_DIR${NC}"
        exit 1
    fi

    cd "$PRODUCER_DIR"

    # Build first
    echo -e "${YELLOW}Building producer application...${NC}"
    mvn clean install -q

    # Run
    echo -e "${GREEN}Producer application starting on http://localhost:8080${NC}"
    mvn spring-boot:run
}

# Function to show cluster status
status() {
    echo -e "${YELLOW}Kafka Cluster Status:${NC}"
    "$KAFKA_HOME/bin/kafka-broker-api-versions.sh" \
        --bootstrap-server localhost:9092 2>/dev/null || echo -e "${RED}Cluster not responding${NC}"
}

# Main script logic
check_kafka

case "${1:-help}" in
    setup)
        generate_cluster_id
        format_storage
        ;;
    start-all)
        start_all
        ;;
    stop-all)
        stop_all
        ;;
    start-producer)
        start_producer
        ;;
    full-setup)
        generate_cluster_id
        format_storage
        start_all
        ;;
    status)
        status
        ;;
    help)
        usage
        ;;
    *)
        echo -e "${RED}Unknown option: $1${NC}"
        usage
        exit 1
        ;;
esac

echo -e "${GREEN}Done!${NC}"

