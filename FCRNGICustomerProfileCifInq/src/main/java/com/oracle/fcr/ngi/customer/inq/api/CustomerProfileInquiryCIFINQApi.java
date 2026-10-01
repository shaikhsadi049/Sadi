package com.oracle.fcr.ngi.customer.inq.api;

import com.oracle.fcr.ngi.customer.inq.exception.payload.request.CustomerProfileInquiryCifinqRequest;
import com.oracle.fcr.ngi.customer.inq.exception.payload.request.CustomerProfileInquiryCifinqTxnRequest;
import com.oracle.fcr.ngi.customer.inq.exception.payload.request.TxnHeaderRequest;
import com.oracle.fcr.ngi.customer.inq.service.CustomerInquiryCIFINQService;
import com.oracle.fcr.ngi.exception.CustomerInquiryException;
import com.oracle.fcr.ngi.exception.GlobalException;
import com.oracle.fcr.ngi.model.CustomResponse;
import com.oracle.fcr.ngi.payload.response.Response;
import com.oracle.fcr.ngi.util.CommonUtils;
import com.oracle.fcr.ngi.util.GlobalProperties;
import com.oracle.fcr.ngi.util.ResponseBuilder;
import com.oracle.fcr.ngi.util.SessionMap;
import lombok.extern.slf4j.Slf4j;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;

import javax.servlet.http.HttpServletRequest;
import javax.validation.Valid;
import java.util.Collections;

import static com.oracle.fcr.ngi.util.GlobalConstant.KEY_MAP_API_VERSION;
import static com.oracle.fcr.ngi.util.GlobalConstant.KEY_MAP_TRACE_ID;

@CrossOrigin
@Slf4j
@RestController
@RequestMapping("/fcr/ngi/")
@Validated
public class CustomerProfileInquiryCIFINQApi {

    private static final Logger LOGGER = LoggerFactory.getLogger(CustomerProfileInquiryCIFINQApi.class);
    @Autowired
    private ResponseBuilder<Response> responseResponseBuilder;
    @Autowired
    private GlobalProperties properties;

    @Autowired
    CustomerInquiryCIFINQService customerInquiryCIFINQService;

    @PostMapping(value = "{version}/customer/profile/inquiry/cifinq")
    public ResponseEntity<CustomResponse<Response>> customerProfileInquiryCIFINQ(
            @PathVariable("version") String version,
            @Valid @RequestBody CustomerProfileInquiryCifinqRequest requestBody,
            HttpServletRequest httpServletRequest
    ) throws CustomerInquiryException, GlobalException {
        LOGGER.info("Entered in method-customerProfileInquiryCIFINQ of class-CustomerProfileInquiryApi at {}", System.currentTimeMillis());
        LOGGER.info("Request received for customer profile inquiry cifinq {}", requestBody);
        SessionMap.setContext(KEY_MAP_API_VERSION, version);

        Response vo = customerInquiryCIFINQService.inquireCustomerProfile(requestBody);
        String traceId = (String) SessionMap.getValue(KEY_MAP_TRACE_ID);

        CustomResponse<Response> response = new CustomResponse<>();
        response.setResponse(Collections.singletonList(vo));
        response.setTraceId(traceId);
        return ResponseEntity.ok().body(responseResponseBuilder.buildResponse(response));
    }

    @PostMapping(value = "{version}/customer/profile/inquiry/cifinq/txn-key")
    public ResponseEntity<CustomResponse<String>> customerProfileInquiryCIFINQTxnKey(@PathVariable("version") String version,
                                                                                     @Valid @RequestBody CustomerProfileInquiryCifinqTxnRequest requestBody,
                                                                                     HttpServletRequest httpServletRequest) {

        LOGGER.info("Entered in method-customerProfileInquiryCIFINQ of class-CustomerProfileInquiryApi at {}", System.currentTimeMillis());

        LOGGER.info("Request received for customer profile inquiry cifinq {}", requestBody);
        TxnHeaderRequest header = new TxnHeaderRequest();
        String txnKey = CommonUtils.generateSHA256Key(header.getTxnHeaderKey() + requestBody.getTxnBodyKey());

        SessionMap.setContext(KEY_MAP_API_VERSION, version);
        String traceId = (String) SessionMap.getValue(KEY_MAP_TRACE_ID);

        CustomResponse<String> response = new CustomResponse<>();
        response.setResponse(Collections.singletonList(txnKey));
        response.setErrors(Collections.emptyList());
        response.setTraceId(traceId);
        return ResponseEntity.ok().body(response);
    }

}