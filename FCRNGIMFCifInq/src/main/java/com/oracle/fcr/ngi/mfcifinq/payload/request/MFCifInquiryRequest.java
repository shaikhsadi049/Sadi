package com.oracle.fcr.ngi.mfcifinq.payload.request;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.Pattern;
import javax.validation.constraints.Size;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class MFCifInquiryRequest {

	private static final Logger logger = LoggerFactory.getLogger(MFCifInquiryRequest.class);
	@Size(max = 2, message = "Invalid account type size must be 2 characters")
    @Pattern(regexp = "^(99|90|00|16|30|50|91)$", message = "Invalid account type. ")
	private String typeId;
	@Size(max = 16, message = "Invalid  Account No. size must be 16 characters or less")
	@NotBlank(message = "Account No. is Mandatory Input")
	@Pattern(regexp = "^[0-9]*$", message = "Account No. must be numeric.")
    private String acctId;
	
	public String getTxnBodyKey() {
		 String txnKey = "";
	        try {
	            txnKey = typeId + acctId;
	            logger.info("Transaction string is : {}", txnKey);
	        }catch (Exception e){
	            logger.error("An exception occurred while creating txnKey");
	        }
	        return txnKey;
	}

    @Override
    public String toString() {
        return "MFCifInquiryRequest [typeId=" + typeId + ", acctId=" + acctId + ","
                 + "]";
    }

    

	
}
