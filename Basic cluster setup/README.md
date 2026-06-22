Setup was done on Ubuntu 24.04 LTS:

Generating a cluster configuration file using properties and script files:
```bash 
bin/kafka-storage.sh random-uuid
```
Example Cluster id:
```bash
abcd1234
```
Formatting Storage:
```bash
bin/kafka-storage.sh format -t abcd1234 -c config/kraft/server.properties
```
Starting the cluster:
```bash
bin/kafka-server-start.sh config/server.properties
```
Start controller1 (node.id=1)
```bash
bin/kafka-storage.sh format -t abcd1234 -c config/controller1.properties
```

Start controller2 (node.id=2)
```bash
bin/kafka-storage.sh format -t abcd1234 -c config/controller1.properties
```
Starting broker 1:
```bash
bin/kafka-storage.sh format -t abcd1234 -c config/broker1.properties
```
Starting broker 2:
```bash
bin/kafka-storage.sh format -t abcd1234 -c config/broker2.properties
```
Creating a topic:
```bash
bin/kafka-topics.sh --create --topic my-topic --bootstrap-server localhost:9092
```
Producing messages to the topic:
```bash
bin/kafka-console-producer.sh --topic my-topic --bootstrap-server localhost:9092
```
Consuming messages from the topic:
```bash
bin/kafka-console-consumer.sh --topic my-topic --bootstrap-server localhost:9092 --from-beginning
```
This setup allows you to run a Kafka cluster using the KRaft mode, which eliminates the need for ZooKeeper. The cluster configuration is defined in the `server.properties` file, and you can manage topics and messages using the provided Kafka scripts.
