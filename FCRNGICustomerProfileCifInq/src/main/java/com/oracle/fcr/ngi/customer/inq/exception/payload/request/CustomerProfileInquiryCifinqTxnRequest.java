package com.oracle.fcr.ngi.customer.inq.exception.payload.request;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import java.io.Serializable;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class CustomerProfileInquiryCifinqTxnRequest implements Serializable {
    private static final Logger logger = LoggerFactory.getLogger(CustomerProfileInquiryCifinqTxnRequest.class);
    private static final long serialVersionUID = -589311404892496375L;

    private CifInqRq cifInqRq;

    @Override
    public String toString() {
        return "CustomerProfileInquiryCifsumRequest{" +
                "acctSummRq=" + cifInqRq +
                '}';
    }

    public String getTxnBodyKey(){
        String txnKey = "";
        try {
            txnKey = cifInqRq.getAcctId() + cifInqRq.getAcctType() ;
            logger.info("Transaction string is : {}", txnKey);
        }catch (Exception e){
            logger.error("An exception occurred while creating txnKey");
        }
        return txnKey;
    }
}
