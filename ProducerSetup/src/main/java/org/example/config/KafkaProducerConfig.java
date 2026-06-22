package org.example.config;

import org.apache.kafka.clients.admin.NewTopic;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.kafka.config.TopicBuilder;

@Configuration
public class KafkaProducerConfig {

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
}