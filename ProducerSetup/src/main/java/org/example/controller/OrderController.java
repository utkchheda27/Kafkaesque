package org.example.controller;

import org.example.model.Order;
import org.example.service.OrderProducerService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/order")
public class OrderController {

    @Autowired
    private OrderProducerService orderProducerService;

    @PostMapping
    public ResponseEntity<String> createOrder(@RequestBody Order order) {
        orderProducerService.sendWithKey(order);
        return ResponseEntity.accepted().body("Order sent successfully to Kafka topic");
    }
}
