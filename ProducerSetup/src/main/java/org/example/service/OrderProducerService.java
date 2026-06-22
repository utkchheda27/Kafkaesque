package org.example.service;

import org.example.model.Order;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.kafka.support.SendResult;
import org.springframework.stereotype.Service;

import java.util.concurrent.CompletableFuture;

@Service
public class OrderProducerService {

    private static final Logger logger = LoggerFactory.getLogger(OrderProducerService.class);

    @Autowired
    private KafkaTemplate<String, Order> kafkaTemplate; //<Key,Value>

    /**
     * Send order to Kafka topic with order ID as key
     * Returns true if sent successfully, false otherwise
     */
    public boolean sendWithKey(Order order) {
        // Validate input
        if (order == null) {
            logger.error("Cannot send null order");
            return false;
        }

        String key = order.getOrderId();
        if (key == null || key.isEmpty()) {
            logger.error("Order ID cannot be null or empty");
            return false;
        }

        try {
            logger.info("Sending order with ID: {} to Kafka topic", key);

            // Send message to Kafka
            CompletableFuture<SendResult<String, Order>> future = kafkaTemplate.send("order-events", key, order);

            // Check if future is null (shouldn't happen but defensive programming)
            if (future == null) {
                logger.error("KafkaTemplate.send() returned null for order: {}", key);
                return false;
            }

            // Handle callback from sender thread
            future.whenComplete((result, ex) -> {
                if (ex == null) {
                    // Success case
                    System.out.println("Order event sent successfully");
                    System.out.println("Partition: " + result.getRecordMetadata().partition());
                    System.out.println("Offset: " + result.getRecordMetadata().offset());

                    logger.info("Order {} sent to partition {} with offset {}",
                        key,
                        result.getRecordMetadata().partition(),
                        result.getRecordMetadata().offset());
                } else {
                    // Error case
                    System.out.println("Failed to send order event: " + ex.getMessage());
                    logger.error("Failed to send order {}: {}", key, ex.getMessage(), ex);
                }
            });

            return true; // Message queued (async, so actual send happens in background)

        } catch (Exception e) {
            logger.error("Exception while sending order {}: {}", key, e.getMessage(), e);
            System.out.println("Failed to send order event: " + e.getMessage());
            return false;
        }
    }
}