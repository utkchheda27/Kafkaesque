package org.example.model;


import lombok.Data;
import lombok.Generated;

@Data
@Generated
public class Order{
    private String orderId;
    private String customerId;
    private String productId;
    private Integer quantity;
    private Double totalAmount;
    private String status;

}
