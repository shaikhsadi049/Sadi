package com.oracle.fcr.ngi.customer.inq.service;

import com.oracle.fcr.ngi.customer.inq.exception.payload.request.CustomerProfileInquiryCifinqRequest;
import com.oracle.fcr.ngi.exception.CustomerInquiryException;
import com.oracle.fcr.ngi.exception.GlobalException;
import com.oracle.fcr.ngi.payload.response.Response;

public interface CustomerInquiryCIFINQService {

    Response inquireCustomerProfile(CustomerProfileInquiryCifinqRequest requestBody) throws CustomerInquiryException, GlobalException;

}
