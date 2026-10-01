package com.oracle.fcr.ngi.customer.inq;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.transaction.annotation.EnableTransactionManagement;

@SpringBootApplication
@EnableScheduling
@EnableTransactionManagement
@ComponentScan(basePackages = "com.oracle.fcr.ngi")
public class FCRNGICustomerProfileCifInqApplication {

    public static void main(String[] args) {
        SpringApplication.run(FCRNGICustomerProfileCifInqApplication.class, args);
    }

}
