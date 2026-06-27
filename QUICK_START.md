# 🎯 QUICK REFERENCE - 5-MINUTE START GUIDE

## Your Issue Fixed ✅

**Problem**: `POST http://api/order` → `EAI_AGAIN api`  
**Solution**: Use `POST http://localhost:8080/api/order`

The error means the hostname "api" cannot be resolved. Always use the full URL with `localhost:8080`.

---

## 📋 File Guide - What Was Created/Fixed

### ✅ Code Fixes
- `OrderProducerService.java` - Fixed imports and imports (SendResult from spring-kafka)
- `OrderController.java` - Now accepts Order objects via REST endpoint
- `pom.xml` - Already correct with all dependencies

### 📚 Documentation Created
1. **KAFKA_SETUP_AND_RUN_COMMANDS.md** - Detailed Kafka startup commands
2. **PRODUCER_README.md** - Producer application guide
3. **API_TESTING_GUIDE.md** - How to test the API
4. **COMPLETE_SETUP_GUIDE.md** - Full project documentation
5. **start-kafka.sh** - Automated startup script
6. **Kafka_Producer_API.postman_collection.json** - Postman collection

---

## 🚀 START IN 30 SECONDS

### Terminal 1-4: Start Kafka (in separate terminals)
```bash
# Set your Kafka path
export KAFKA_HOME=/path/to/kafka
cd $KAFKA_HOME

# Generate cluster ID (run once)
bin/kafka-storage.sh random-uuid
# Save the output, e.g., "abcd1234efgh5678"

# Format all nodes (replace abcd1234efgh5678 with your cluster ID)
CLUSTER_ID="abcd1234efgh5678"
bin/kafka-storage.sh format -t $CLUSTER_ID -c /home/utkarsh/Desktop/Kafkaesque/Basic\ cluster\ setup/controller1.properties
bin/kafka-storage.sh format -t $CLUSTER_ID -c /home/utkarsh/Desktop/Kafkaesque/Basic\ cluster\ setup/controller2.properties
bin/kafka-storage.sh format -t $CLUSTER_ID -c /home/utkarsh/Desktop/Kafkaesque/Basic\ cluster\ setup/broker1.properties
bin/kafka-storage.sh format -t $CLUSTER_ID -c /home/utkarsh/Desktop/Kafkaesque/Basic\ cluster\ setup/broker2.properties

# Terminal 1
bin/kafka-server-start.sh /home/utkarsh/Desktop/Kafkaesque/Basic\ cluster\ setup/controller1.properties

# Terminal 2
bin/kafka-server-start.sh /home/utkarsh/Desktop/Kafkaesque/Basic\ cluster\ setup/controller2.properties

# Terminal 3
bin/kafka-server-start.sh /home/utkarsh/Desktop/Kafkaesque/Basic\ cluster\ setup/broker1.properties

# Terminal 4
bin/kafka-server-start.sh /home/utkarsh/Desktop/Kafkaesque/Basic\ cluster\ setup/broker2.properties
```

### Terminal 5: Start Producer
```bash
cd /home/utkarsh/Desktop/Kafkaesque/ProducerSetup
mvn clean install
mvn spring-boot:run
```

### Terminal 6: Send Test Request
```bash
curl -X POST http://localhost:8080/api/order \
  -H "Content-Type: application/json" \
  -d '{
    "orderId": "ORD-001",
    "customerId": "CUST-001",
    "quantity": 5,
    "totalAmount": 100.00
  }'
```

**Expected Response:**
```
HTTP 202 Accepted
Order sent successfully to Kafka topic
```

**You should see in Terminal 5 (Producer Console):**
```
Order event sent successfully
Partition: 0
Offset: 0
```

---

## 🎮 Using Postman (Easier Way)

1. Open Postman
2. File → Import → `Kafka_Producer_API.postman_collection.json`
3. Select "Create Order - Full Details"
4. Click "Send"
5. Done! ✅

---

## 🏗️ Architecture Summary

```
Client Request (Postman/cURL)
         │
         ▼
Spring Boot App (8080)
         │
         ▼
OrderController → OrderProducerService
         │
         ▼
KafkaTemplate (Async)
         │
    ┌────┴────┐
    ▼         ▼
Broker1    Broker2
    │         │
    └────┬────┘
         ▼
    Topic: order-events
    (4 partitions, RF=2)
    
Managed by:
Controller1 (Active) ←→ Controller2 (Standby)
```

---

## 📊 REST API Endpoint

**URL**: `http://localhost:8080/api/order`  
**Method**: `POST`  
**Content-Type**: `application/json`

**Request Body**:
```json
{
  "orderId": "ORD-001",           // Required
  "customerId": "CUST-001",       // Required
  "productId": "PROD-001",        // Optional
  "quantity": 5,                  // Optional
  "totalAmount": 100.00,          // Optional
  "status": "PENDING"             // Optional
}
```

**Response**:
```
Status: 202 Accepted
Body: Order sent successfully to Kafka topic
```

---

## ✨ Key Features

✅ **2 Active Controllers** (Quorum-based leadership)  
✅ **2 Brokers** (Message replication)  
✅ **Auto Topic Creation** (on app startup)  
✅ **Async Message Sending** (Non-blocking)  
✅ **Message Keying** (By orderId)  
✅ **7-Day Retention** (Automatic)  
✅ **High Availability** (2x replication)  

---

## 🔍 Verify Everything Works

### Check Cluster Status
```bash
cd /path/to/kafka
bin/kafka-broker-api-versions.sh --bootstrap-server localhost:9092
```
Expected: JSON output with broker info

### List Topics
```bash
cd /path/to/kafka
bin/kafka-topics.sh --list --bootstrap-server localhost:9092
```
Expected: `order-events` in the list

### See Messages
```bash
cd /path/to/kafka
bin/kafka-console-consumer.sh \
  --topic order-events \
  --bootstrap-server localhost:9092 \
  --from-beginning \
  --property print.key=true
```
Expected: Order data with orderId as key

---

## ⚡ Common Commands

| What | Command |
|------|---------|
| **Start all 4 Kafka nodes** | Use `start-kafka.sh full-setup` or run 4 terminals manually |
| **Start producer app** | `cd ProducerSetup && mvn spring-boot:run` |
| **Send test order** | `curl -X POST http://localhost:8080/api/order ...` |
| **Check cluster status** | `bin/kafka-broker-api-versions.sh --bootstrap-server localhost:9092` |
| **List topics** | `bin/kafka-topics.sh --list --bootstrap-server localhost:9092` |
| **View messages** | `bin/kafka-console-consumer.sh --topic order-events --bootstrap-server localhost:9092 --from-beginning` |
| **Stop all** | `start-kafka.sh stop-all` |

---

## 🐛 Troubleshooting Quick Tips

| Error | Fix |
|-------|-----|
| `EAI_AGAIN api` | Use `http://localhost:8080/api/order` not `http://api/order` |
| Connection refused 8080 | Start producer with `mvn spring-boot:run` |
| Connection refused 9092 | Start Kafka brokers |
| Topic not found | Auto-created on app startup (wait 5 secs) |
| 400 Bad Request | Add `orderId` and `customerId` fields |
| Maven offline error | Run `mvn clean install -U` |

---

## 📁 Important Directories

```
/home/utkarsh/Desktop/Kafkaesque/
├── COMPLETE_SETUP_GUIDE.md          ← Full documentation
├── KAFKA_SETUP_AND_RUN_COMMANDS.md  ← Kafka commands
├── start-kafka.sh                    ← Automated startup
├── Basic cluster setup/
│   ├── controller1.properties
│   ├── controller2.properties
│   ├── broker1.properties
│   └── broker2.properties
└── ProducerSetup/
    ├── PRODUCER_README.md
    ├── API_TESTING_GUIDE.md
    ├── Kafka_Producer_API.postman_collection.json
    ├── pom.xml
    └── src/main/java/org/example/
        ├── KafkaProducerApplication.java
        ├── config/KafkaProducerConfig.java
        ├── controller/OrderController.java
        ├── model/Order.java
        ├── serializer/OrderSummarySerializer.java
        └── service/OrderProducerService.java
```

---

## 🎯 Test Scenarios

### Scenario 1: Send Single Order
```bash
curl -X POST http://localhost:8080/api/order \
  -H "Content-Type: application/json" \
  -d '{"orderId":"ORD-001","customerId":"CUST-001"}'
```

### Scenario 2: Send with All Fields
```bash
curl -X POST http://localhost:8080/api/order \
  -H "Content-Type: application/json" \
  -d '{
    "orderId":"ORD-002",
    "customerId":"CUST-002",
    "productId":"PROD-ABC",
    "quantity":10,
    "totalAmount":999.99,
    "status":"CONFIRMED"
  }'
```

### Scenario 3: Load Test (5 orders)
```bash
for i in {1..5}; do
  curl -X POST http://localhost:8080/api/order \
    -H "Content-Type: application/json" \
    -d "{\"orderId\":\"ORD-$i\",\"customerId\":\"CUST-$i\"}"
  sleep 1
done
```

---

## 📱 Postman Quick Steps

1. **Create New Request**
   - Method: `POST`
   - URL: `http://localhost:8080/api/order`

2. **Add Headers**
   - Key: `Content-Type`
   - Value: `application/json`

3. **Add Body (raw JSON)**
   ```json
   {
     "orderId": "ORD-001",
     "customerId": "CUST-001"
   }
   ```

4. **Send** → See response ✅

---

## ✅ Success Checklist

- [ ] Kafka cluster running (all 4 nodes)
- [ ] Spring Boot app running on port 8080
- [ ] Can send POST to `http://localhost:8080/api/order`
- [ ] Get `202 Accepted` response
- [ ] See "Order event sent successfully" in app console
- [ ] Can see messages in Kafka topic consumer

---

**🎉 You're all set! Your Kafka Producer is ready to use!**

For detailed documentation, see `COMPLETE_SETUP_GUIDE.md`

