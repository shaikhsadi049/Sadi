package com.oracle.fcr.ngi.mfcifinq.payload.request;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class CustomerInqMFCIFInqWrapperReq {
   
    private String svcCode;
    private String traceId;
    private String txnDate;
    private String channelId;
    private int codOrgBrn;
    private String userId;
    private String svcRequestId;
    private String timestamp;
    private String timeoutPeriod;
    
    
    private String typeId;
    private String acctId;
   
}
