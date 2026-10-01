package com.oracle.fcr.ngi.mfcifinq;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.transaction.annotation.EnableTransactionManagement;

@SpringBootApplication
@EnableScheduling
@EnableTransactionManagement
@ComponentScan(basePackages = "com.oracle.fcr.ngi")
public class FCRNGIMFCifInqApplication {

    public static void main(String[] args) {
        SpringApplication.run(FCRNGIMFCifInqApplication.class, args);
    }

}
