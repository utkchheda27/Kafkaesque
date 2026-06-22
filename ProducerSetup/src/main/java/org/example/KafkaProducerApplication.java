package org.example;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class KafkaProducerApplication {

    public static void main(String[] args) {
        System.out.println("Kafka Producer Application is starting...");
        System.out.println();
        SpringApplication.run(KafkaProducerApplication.class, args);
    }
}
