package org.example.serializer;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.apache.kafka.common.serialization.Serializer;
import org.example.model.Order;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.nio.charset.StandardCharsets;

/**
 * Custom serializer for Order objects to JSON format.
 * Implements Kafka Serializer interface for Order class.
 */
public class OrderSerializer implements Serializer<Order> {

    private static final Logger logger = LoggerFactory.getLogger(OrderSerializer.class);
    private static final ObjectMapper objectMapper = new ObjectMapper();

    //while sending key,value we also send their serialized byte array: byte[]
    @Override
    public byte[] serialize(String topic, Order order) {
        if (order == null) {
            logger.warn("Received null Order object for topic: {}", topic);
            return new byte[0];
        }

        try {
            //objectMapper is a jackson library class to serialize objects to intended type
            //here serializing order object to string type

            //readValue: parsing or deserializing json string to object
            //writeValue: java object to serialized json string....writeValue(),.writeValueAsString()

            String json = objectMapper.writeValueAsString(order);
            logger.debug("Serialized Order {} to JSON: {}", order.getOrderId(), json);
            return json.getBytes(StandardCharsets.UTF_8);
        } catch (Exception e) {
            logger.error("Failed to serialize Order object: {}", order.getOrderId(), e);
            throw new RuntimeException("Error serializing Order to JSON", e);
        }
    }

    @Override
    public void close() {
        // No resources to close
    }
}

