package com.oracle.fcr.ngi.mfcifinq.dbutil;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

import com.oracle.fcr.ngi.mfcifinq.payload.request.CustomerInqMFCIFInqWrapperReq;
import com.oracle.fcr.ngi.mfcifinq.payload.request.HeaderRequest;
import com.oracle.fcr.ngi.mfcifinq.payload.request.MFCifInquiryRequest;
import com.oracle.fcr.ngi.util.GlobalConstant;
import com.oracle.fcr.ngi.util.SessionMap;

public class MFCIFInqReqMapper {
	 private MFCIFInqReqMapper() {}

	    public static CustomerInqMFCIFInqWrapperReq mapToWrapperReq(MFCifInquiryRequest request, HeaderRequest header) {
	    	CustomerInqMFCIFInqWrapperReq wrapperReq = new CustomerInqMFCIFInqWrapperReq();
	    	DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

	        wrapperReq.setTraceId((String) SessionMap.getValue(GlobalConstant.KEY_MAP_TRACE_ID));
			// Map headers values
	        wrapperReq.setSvcCode(header.getSvcCode());
	        wrapperReq.setTxnDate(header.getTxnDate());
	        wrapperReq.setUserId(header.getUserId());
	        wrapperReq.setSvcRequestId(header.getSvcRqId());
	        wrapperReq.setTimestamp(LocalDateTime.now().format(formatter));
	       // System.out.println("Timestamp :"+LocalDateTime.now().format(formatter));

	        wrapperReq.setAcctId(request.getAcctId());;
	        wrapperReq.setTypeId(request.getTypeId());;
	        

	        return wrapperReq;
	    }
}
