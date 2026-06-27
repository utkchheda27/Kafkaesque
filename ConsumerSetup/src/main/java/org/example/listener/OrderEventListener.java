package org.example.listener;

import org.example.model.Order;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Component;

@Component
public class OrderEventListener {
    /*
    Topic the consumer is interested in
     */
    @KafkaListener(topics = "order-events")
    public void consume(Order order){
        System.out.println("Order event received: " + order);
        System.out.println("Order ID: " + order.getOrderId());
    }
}
