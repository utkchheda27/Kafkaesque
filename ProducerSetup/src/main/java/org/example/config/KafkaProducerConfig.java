package org.example.config;

import org.apache.kafka.clients.admin.NewTopic;
import org.apache.kafka.clients.producer.ProducerConfig;
import org.apache.kafka.common.serialization.StringSerializer;
import org.example.model.Order;
import org.example.serializer.OrderSerializer;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.kafka.annotation.EnableKafka;
import org.springframework.kafka.config.TopicBuilder;
import org.springframework.kafka.core.DefaultKafkaProducerFactory;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.kafka.core.ProducerFactory;

import java.util.HashMap;
import java.util.Map;

@Configuration
@EnableKafka  //@EnableKafka enables detection of KafkaListener annotations on any Spring-managed bean in the container.
// It is required to enable Kafka listener functionality in the application. Without this annotation, any methods annotated with @KafkaListener will not be registered as message listeners,
// and the application will not be able to consume messages from Kafka topics.
public class KafkaProducerConfig {

    //configs for topic
    //creating topic using topicBuilder with added custom configs instead of from properties file
    @Bean
    public NewTopic orderEventsTopic(){ //NewTopic is object type from Kafka..can have custom type too
        return TopicBuilder.name("order-events")
                .partitions(4)
                .replicas(2)
                .config("cleanup.policy", "delete")
                .config("min.insync.replicas", "2")
                .config("retention.ms", "604800000") // 7 days
                .config("segment.bytes", "1073741824") // 1 GB
                .build();
    }

    // Configure ProducerFactory with custom OrderSerializer for Order objects
    @Bean
    public ProducerFactory<String, Order> producerFactory() {
        Map<String, Object> configProps = new HashMap<>();
        // Include BOTH brokers for high availability and automatic failover
        configProps.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9092,localhost:9192");
        configProps.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class);
        configProps.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, OrderSerializer.class);

        // Reliability settings
        configProps.put(ProducerConfig.ACKS_CONFIG, "all");  // Wait for all replicas
        configProps.put(ProducerConfig.RETRIES_CONFIG, 5);   // Increased retries for failover
        configProps.put(ProducerConfig.RETRY_BACKOFF_MS_CONFIG, 100);  // Backoff between retries

        // Performance settings
        configProps.put(ProducerConfig.BATCH_SIZE_CONFIG, 16384);
        configProps.put(ProducerConfig.LINGER_MS_CONFIG, 100);
        configProps.put(ProducerConfig.BUFFER_MEMORY_CONFIG, 33554432);

        // Idempotence & ordering
        configProps.put(ProducerConfig.ENABLE_IDEMPOTENCE_CONFIG, true);  // No duplicate messages
        configProps.put(ProducerConfig.MAX_IN_FLIGHT_REQUESTS_PER_CONNECTION, 5);

        // Connection stability
        configProps.put(ProducerConfig.CONNECTIONS_MAX_IDLE_MS_CONFIG, 540000);

        return new DefaultKafkaProducerFactory<>(configProps);
    }

    // Configure KafkaTemplate with the ProducerFactory
    @Bean
    public KafkaTemplate<String, Order> kafkaTemplate() {
        return new KafkaTemplate<>(producerFactory());
    }
}