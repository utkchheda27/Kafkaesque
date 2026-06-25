
# Kafka Producer Setup - Complete Documentation

## 📋 Project Overview

This is a **Spring Boot Kafka Producer Application** that sends order events to a Kafka cluster using **KRaft mode** (no ZooKeeper required). The application has been fully configured with proper controllers and brokers for high availability.

---

## ✅ What Has Been Set Up

### 1. Kafka Cluster Architecture
- **2 Controllers** (quorum-based leadership)
  - Controller 1: Active controller (node.id=1, port 9093)
  - Controller 2: Watcher/Standby (node.id=2, port 9193)
- **2 Brokers** (for message replication)
  - Broker 1: node.id=3, port 9092
  - Broker 2: node.id=4, port 9092 (different server)

### 2. Spring Boot Application
- **Endpoint**: `POST /api/order`
- **Base URL**: `http://localhost:8080`
- **Framework**: Spring Boot 3.2.0
- **Java Version**: 22
- **Build Tool**: Maven

### 3. Configuration Files
- ✅ `controller1.properties` - Active controller configuration
- ✅ `controller2.properties` - Standby controller configuration  
- ✅ `broker1.properties` - Broker 1 configuration
- ✅ `broker2.properties` - Broker 2 configuration (needs to be created)
- ✅ `pom.xml` - Maven dependencies (all correct)

### 4. Code Fixes Applied
- ✅ Fixed `OrderProducerService.java` - Corrected imports and imports
- ✅ Fixed `OrderController.java` - Updated to accept Order objects via REST
- ✅ Verified `Order.java` - Model with Lombok annotations
- ✅ Verified `KafkaProducerConfig.java` - Topic creation configuration

---

## 🚀 Quick Start Commands

### Option 1: Automatic Setup (Using Script)

```bash
cd /home/utkarsh/Desktop/Kafkaesque

# Full setup (format + start cluster)
./start-kafka.sh full-setup

# In another terminal, start producer
./start-kafka.sh start-producer
```

### Option 2: Manual Setup

#### Step 1: Generate Cluster ID
```bash
cd /path/to/kafka
CLUSTER_ID=$(bin/kafka-storage.sh random-uuid)
echo "Cluster ID: $CLUSTER_ID"
# Save this ID for next commands
```

#### Step 2: Format Storage
```bash
cd /path/to/kafka
CLUSTER_ID="<your-cluster-id>"

bin/kafka-storage.sh format -t $CLUSTER_ID -c /home/utkarsh/Desktop/Kafkaesque/Basic\ cluster\ setup/controller1.properties
bin/kafka-storage.sh format -t $CLUSTER_ID -c /home/utkarsh/Desktop/Kafkaesque/Basic\ cluster\ setup/controller2.properties
bin/kafka-storage.sh format -t $CLUSTER_ID -c /home/utkarsh/Desktop/Kafkaesque/Basic\ cluster\ setup/broker1.properties
bin/kafka-storage.sh format -t $CLUSTER_ID -c /home/utkarsh/Desktop/Kafkaesque/Basic\ cluster\ setup/broker2.properties
```

#### Step 3: Start All Components (Open in Separate Terminals)

**Terminal 1 - Controller 1 (Active)**
```bash
cd /path/to/kafka
bin/kafka-server-start.sh /home/utkarsh/Desktop/Kafkaesque/Basic\ cluster\ setup/controller1.properties
```

**Terminal 2 - Controller 2 (Watcher)**
```bash
cd /path/to/kafka
bin/kafka-server-start.sh /home/utkarsh/Desktop/Kafkaesque/Basic\ cluster\ setup/controller2.properties
```

**Terminal 3 - Broker 1**
```bash
cd /path/to/kafka
bin/kafka-server-start.sh /home/utkarsh/Desktop/Kafkaesque/Basic\ cluster\ setup/broker1.properties
```

**Terminal 4 - Broker 2**
```bash
cd /path/to/kafka
bin/kafka-server-start.sh /home/utkarsh/Desktop/Kafkaesque/Basic\ cluster\ setup/broker2.properties
```

**Terminal 5 - Producer Application**
```bash
cd /home/utkarsh/Desktop/Kafkaesque/ProducerSetup
mvn clean install
mvn spring-boot:run
```

---

## 📝 Testing the API

### Using cURL

```bash
# Correct URL
curl -X POST http://localhost:8080/api/order \
  -H "Content-Type: application/json" \
  -d '{
    "orderId": "ORD-2026-001",
    "customerId": "CUST-789",
    "productId": "PROD-456",
    "quantity": 5,
    "totalAmount": 5999.99,
    "status": "PENDING"
  }'
```

**Expected Response:**
```
HTTP 202 Accepted
Order sent successfully to Kafka topic
```

### Using Postman

1. Import collection: `/home/utkarsh/Desktop/Kafkaesque/ProducerSetup/Kafka_Producer_API.postman_collection.json`
2. Use any of the pre-configured requests
3. Click Send

### Common Mistakes to Avoid

❌ **WRONG**: `http://api/order` → `EAI_AGAIN api` error
✅ **CORRECT**: `http://localhost:8080/api/order`

---

## 🔍 Monitoring & Verification

### Check Cluster Status
```bash
cd /path/to/kafka
bin/kafka-broker-api-versions.sh --bootstrap-server localhost:9092
```

### List Topics
```bash
cd /path/to/kafka
bin/kafka-topics.sh --list --bootstrap-server localhost:9092
```

### Describe Topic
```bash
cd /path/to/kafka
bin/kafka-topics.sh --describe \
  --topic order-events \
  --bootstrap-server localhost:9092
```

### Consume Messages
```bash
cd /path/to/kafka
bin/kafka-console-consumer.sh \
  --topic order-events \
  --bootstrap-server localhost:9092 \
  --from-beginning \
  --property print.key=true
```

---

## 📚 Documentation Files

Created in this setup:

| File | Purpose |
|------|---------|
| `KAFKA_SETUP_AND_RUN_COMMANDS.md` | Detailed Kafka cluster setup commands |
| `PRODUCER_README.md` | Producer application documentation |
| `API_TESTING_GUIDE.md` | Complete API testing guide |
| `Kafka_Producer_API.postman_collection.json` | Postman collection for testing |
| `start-kafka.sh` | Automated startup script |

---

## 🏗️ Application Architecture

```
┌─────────────────────────────────────────────┐
│        Spring Boot Application              │
│     (Kafka Producer Service)                │
│  Running on http://localhost:8080          │
└────────────────────┬────────────────────────┘
                     │
                     ▼
        ┌────────────────────────┐
        │  OrderController       │
        │  POST /api/order       │
        └────────────┬───────────┘
                     │
                     ▼
        ┌────────────────────────┐
        │ OrderProducerService   │
        │ sendWithKey(order)     │
        └────────────┬───────────┘
                     │
                     ▼
        ┌────────────────────────┐
        │   KafkaTemplate        │
        │  (Async Producer)      │
        └────────────┬───────────┘
                     │
         ┌───────────┴───────────┐
         ▼                       ▼
    ┌─────────┐            ┌─────────┐
    │ Broker1 │ ◄─────────►│ Broker2 │
    │ port 9092           port 9092  │
    └────┬────┘            └────┬────┘
         │                      │
         └──────────┬───────────┘
                    ▼
         ┌──────────────────┐
         │ Topic:           │
         │ order-events     │
         │ Partitions: 4    │
         │ RF: 2            │
         └──────────────────┘
         
    ▲                   ▲
    │                   │
    ├─────┬─────┬───────┤
    │     │     │       │
    │     │     │       └─ Partition 3
    │     │     └────────── Partition 2  
    │     └──────────────── Partition 1
    └────────────────────── Partition 0
    
    Coordinated by:
    ┌──────────────┐    ┌──────────────┐
    │ Controller 1 │◄───►│ Controller 2 │
    │  (Active)    │    │ (Standby)    │
    │  Port 9093   │    │  Port 9193   │
    └──────────────┘    └──────────────┘
```

---

## 🔧 Controller vs Broker Roles

### Controllers
- **Role**: Manage cluster metadata and leadership
- **Responsibility**: Topic creation, leader election, partition assignment
- **Quorum**: 2 controllers in quorum (one active, one standby)
- **Port**: 9093 (Controller 1), 9193 (Controller 2)

### Brokers
- **Role**: Store and serve messages
- **Responsibility**: Replicate data, serve consumer requests
- **Replication Factor**: 2 (messages replicated to both brokers)
- **Port**: 9092 (both, on different servers)

---

## 🐛 Troubleshooting

| Problem | Cause | Solution |
|---------|-------|----------|
| Connection refused on 8080 | App not running | Start with `mvn spring-boot:run` |
| EAI_AGAIN api | Wrong URL | Use `http://localhost:8080/api/order` |
| Cannot connect to Kafka | Kafka not running | Start all 4 nodes (2 controllers + 2 brokers) |
| Topic doesn't exist | Not created | Auto-creates on app startup |
| 400 Bad Request | Missing required fields | Include `orderId` and `customerId` |
| Maven offline error | No internet | Run `mvn clean install -U` |

---

## 📊 Order Model

```json
{
  "orderId": "string (required)",
  "customerId": "string (required)",
  "productId": "string (optional)",
  "quantity": "integer (optional)",
  "totalAmount": "double (optional)",
  "status": "string (optional)"
}
```

---

## 🎯 Expected Behavior

### Request
```bash
POST http://localhost:8080/api/order
Content-Type: application/json

{
  "orderId": "ORD-2026-001",
  "customerId": "CUST-789",
  "productId": "PROD-456",
  "quantity": 5,
  "totalAmount": 5999.99,
  "status": "PENDING"
}
```

### Response
```
HTTP/1.1 202 Accepted
Content-Type: text/plain;charset=UTF-8
Content-Length: 43

Order sent successfully to Kafka topic
```

### Producer Console Output
```
Order event sent successfully
Partition: 2
Offset: 15
```

---

## 🚦 Next Steps

1. ✅ **Start Kafka Cluster** - Use the startup script or manual commands
2. ✅ **Start Producer App** - Run with Maven
3. ✅ **Test API** - Send test orders via cURL or Postman
4. 📋 **Monitor Messages** - Use Kafka consumer to verify
5. 🔄 **Create Consumer** - Build a consumer app to process orders
6. 💾 **Add Database** - Store processed orders in a database
7. 📈 **Add Monitoring** - Implement metrics and alerting

---

## 📞 Quick Reference

**Base Directory**: `/home/utkarsh/Desktop/Kafkaesque`

**Key Locations**:
- Kafka Config: `./Basic cluster setup/`
- Producer Code: `./ProducerSetup/src/main/java/org/example/`
- Startup Script: `./start-kafka.sh`

**Ports Used**:
- Controller 1: 9093
- Controller 2: 9193
- Broker 1 & 2: 9092
- Producer App: 8080

**Commands Cheat Sheet**:
```bash
# Start cluster
./start-kafka.sh full-setup

# Start producer
./start-kafka.sh start-producer

# Check cluster status
cd /path/to/kafka && bin/kafka-broker-api-versions.sh --bootstrap-server localhost:9092

# List topics
cd /path/to/kafka && bin/kafka-topics.sh --list --bootstrap-server localhost:9092

# Consume messages
cd /path/to/kafka && bin/kafka-console-consumer.sh --topic order-events --bootstrap-server localhost:9092 --from-beginning

# Stop all
./start-kafka.sh stop-all
```

---

## ✨ Features

✅ **High Availability**: 2 controller quorum + 2 broker replication
✅ **Async Processing**: Non-blocking message sending
✅ **Topic Auto-Creation**: Automatic topic creation on startup
✅ **Error Handling**: Comprehensive error logging
✅ **REST API**: Simple POST endpoint for order submission
✅ **Message Keying**: Orders keyed by orderId for partitioning
✅ **7-Day Retention**: Messages kept for one week
✅ **Production-Ready**: Spring Boot best practices followed

---

## 📖 References

- [Spring Kafka Documentation](https://spring.io/projects/spring-kafka)
- [Apache Kafka Official Docs](https://kafka.apache.org/documentation/)
- [KRaft Mode Guide](https://kafka.apache.org/documentation/#kraft)
- [Spring Boot 3.2 Guide](https://spring.io/projects/spring-boot)

---

