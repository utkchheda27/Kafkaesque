# Kafka Setup and Run Commands

## Prerequisites
- Kafka binary should be downloaded and extracted
- All configuration files are in `/home/utkarsh/Desktop/Kafkaesque/Basic cluster setup/`
- This uses KRaft mode (no ZooKeeper required)

---

## Step 1: Generate Cluster ID

Run this once to generate a unique cluster ID (save this ID for later use):

```bash
cd /path/to/kafka  # Navigate to your Kafka installation directory
bin/kafka-storage.sh random-uuid
```

**Example output:** `abcd1234efgh5678` (save this)

---

## Step 2: Format Storage for Controllers

Format storage for **Controller 1** (node.id=1):
```bash
cd /path/to/kafka
bin/kafka-storage.sh format -t <CLUSTER_ID> -c /home/utkarsh/Desktop/Kafkaesque/Basic\ cluster\ setup/controller1.properties
```

Format storage for **Controller 2** (node.id=2):
```bash
cd /path/to/kafka
bin/kafka-storage.sh format -t <CLUSTER_ID> -c /home/utkarsh/Desktop/Kafkaesque/Basic\ cluster\ setup/controller2.properties
```

Replace `<CLUSTER_ID>` with the ID generated in Step 1.

---

## Step 3: Format Storage for Brokers

Format storage for **Broker 1** (node.id=3):
```bash
cd /path/to/kafka
bin/kafka-storage.sh format -t <CLUSTER_ID> -c /home/utkarsh/Desktop/Kafkaesque/Basic\ cluster\ setup/broker1.properties
```

Format storage for **Broker 2** (node.id=4):
```bash
cd /path/to/kafka
bin/kafka-storage.sh format -t <CLUSTER_ID> -c /home/utkarsh/Desktop/Kafkaesque/Basic\ cluster\ setup/broker2.properties
```

---

## Step 4: Start the Cluster (Run in Separate Terminals)

### Start Controller 1 (Active)
```bash
cd /path/to/kafka
bin/kafka-server-start.sh /home/utkarsh/Desktop/Kafkaesque/Basic\ cluster\ setup/controller1.properties
```

### Start Controller 2 (Watcher/Standby)
```bash
cd /path/to/kafka
bin/kafka-server-start.sh /home/utkarsh/Desktop/Kafkaesque/Basic\ cluster\ setup/controller2.properties
```

### Start Broker 1
```bash
cd /path/to/kafka
bin/kafka-server-start.sh /home/utkarsh/Desktop/Kafkaesque/Basic\ cluster\ setup/broker1.properties
```

### Start Broker 2
```bash
cd /path/to/kafka
bin/kafka-server-start.sh /home/utkarsh/Desktop/Kafkaesque/Basic\ cluster\ setup/broker2.properties
```

---

## Step 5: Verify Cluster is Running

Check if all nodes are up:
```bash
cd /path/to/kafka
bin/kafka-broker-api-versions.sh --bootstrap-server localhost:9092
```

---

## Step 6: Create Topics (Run after cluster is ready)

Create the `order-events` topic for your producer:
```bash
cd /path/to/kafka
bin/kafka-topics.sh --create \
  --topic order-events \
  --bootstrap-server localhost:9092 \
  --partitions 3 \
  --replication-factor 2
```

Verify topic creation:
```bash
cd /path/to/kafka
bin/kafka-topics.sh --list --bootstrap-server localhost:9092
```

---

## Step 7: Build and Run the Producer Application

Navigate to ProducerSetup directory:
```bash
cd /home/utkarsh/Desktop/Kafkaesque/ProducerSetup
```

### Build the application
```bash
mvn clean install
```

### Run the Spring Boot application
```bash
mvn spring-boot:run
```

Or run the generated JAR:
```bash
java -jar target/ProducerSetup-1.0-SNAPSHOT.jar
```

The application will start on `http://localhost:8080`

---

## Step 8: Test the Producer

Send an order event via REST API:
```bash
curl -X POST http://localhost:8080/api/order \
  -H "Content-Type: application/json" \
  -d '{
    "orderId": "ORD123",
    "customerId": "CUST456",
    "productName": "Laptop",
    "quantity": 2,
    "price": 1200.00
  }'
```

You should see output in the producer console:
```
Order event sent successfully
Partition: <partition_number>
Offset: <offset_number>
```

---

## Step 9: Consume Messages (Optional)

To verify messages are being sent to Kafka:
```bash
cd /path/to/kafka
bin/kafka-console-consumer.sh \
  --topic order-events \
  --bootstrap-server localhost:9092 \
  --from-beginning
```

---

## Quick Reference - Running Everything

**Terminal 1 - Controller 1 (Active):**
```bash
cd /path/to/kafka && bin/kafka-server-start.sh /home/utkarsh/Desktop/Kafkaesque/Basic\ cluster\ setup/controller1.properties
```

**Terminal 2 - Controller 2 (Watcher):**
```bash
cd /path/to/kafka && bin/kafka-server-start.sh /home/utkarsh/Desktop/Kafkaesque/Basic\ cluster\ setup/controller2.properties
```

**Terminal 3 - Broker 1:**
```bash
cd /path/to/kafka && bin/kafka-server-start.sh /home/utkarsh/Desktop/Kafkaesque/Basic\ cluster\ setup/broker1.properties
```

**Terminal 4 - Broker 2:**
```bash
cd /path/to/kafka && bin/kafka-server-start.sh /home/utkarsh/Desktop/Kafkaesque/Basic\ cluster\ setup/broker2.properties
```

**Terminal 5 - Producer Application:**
```bash
cd /home/utkarsh/Desktop/Kafkaesque/ProducerSetup && mvn spring-boot:run
```

---

## Controller Role Explanation

- **Active Controller (Controller 1)**: Manages cluster metadata, topic leadership, and broker coordination
- **Watcher Controller (Controller 2)**: Standby controller that syncs with the active controller. Takes over if Controller 1 fails
- **Brokers (1 & 2)**: Store and serve messages, replicate data between brokers

The controller.quorum.voters setting ensures quorum-based leadership election between the two controllers.

