package com.oracle.fcr.ngi.mfcifinq.service;

import com.oracle.fcr.ngi.exception.GlobalException;
import com.oracle.fcr.ngi.exception.NGISQLException;
import com.oracle.fcr.ngi.exception.NotFoundException;
import com.oracle.fcr.ngi.mfcifinq.payload.request.MFCifInquiryRequest;
import com.oracle.fcr.ngi.payload.response.Response;

public interface CustomerMFInqCIFService {

	Response mfCifInquiry(MFCifInquiryRequest requestBody) throws NGISQLException, GlobalException, NotFoundException;

}
