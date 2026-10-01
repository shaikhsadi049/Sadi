package com.oracle.fcr.ngi.mfcifinq.api;

import static com.oracle.fcr.ngi.util.GlobalConstant.KEY_MAP_API_VERSION;
import static com.oracle.fcr.ngi.util.GlobalConstant.KEY_MAP_TRACE_ID;

import java.util.Collections;

import javax.servlet.http.HttpServletRequest;
import javax.validation.Valid;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import com.oracle.fcr.ngi.exception.GlobalException;
import com.oracle.fcr.ngi.exception.NGISQLException;
import com.oracle.fcr.ngi.exception.NotFoundException;
import com.oracle.fcr.ngi.mfcifinq.payload.request.HeaderRequest;
import com.oracle.fcr.ngi.mfcifinq.payload.request.MFCifInquiryRequest;
import com.oracle.fcr.ngi.mfcifinq.service.CustomerMFInqCIFService;
import com.oracle.fcr.ngi.model.CustomResponse;
import com.oracle.fcr.ngi.payload.response.Response;
import com.oracle.fcr.ngi.util.CommonUtils;
import com.oracle.fcr.ngi.util.ResponseBuilder;
import com.oracle.fcr.ngi.util.SessionMap;

import lombok.RequiredArgsConstructor;


@CrossOrigin
@RestController
@RequestMapping("/fcr/ngi/")
@Validated
@RequiredArgsConstructor(onConstructor_ = {@Autowired} )
public class MFCifInquiryApi { // rename it
	 private static final Logger LOGGER = LoggerFactory.getLogger(MFCifInquiryApi.class);
	 private final CustomerMFInqCIFService mfCifSumInq;
	 private final ResponseBuilder<Response> responseBuilder;
	 @PostMapping(value = "{version}/mf/cif/inq")
	    public ResponseEntity<CustomResponse<Response>> mfCifInquiry(@PathVariable("version") String version, @Valid @RequestBody MFCifInquiryRequest requestBody) throws GlobalException, NGISQLException, NotFoundException {

	    	LOGGER.info("Entered in method-C of class-MfCIfInquiryApiController at {}", System.currentTimeMillis());

	        LOGGER.info("Request received for mfCifInquiry {}", requestBody);

	        SessionMap.setContext(KEY_MAP_API_VERSION, version);

	        Response vo = mfCifSumInq.mfCifInquiry(requestBody);
	        CustomResponse<Response> response = new CustomResponse<>();
	        response.setResponse(Collections.singletonList(vo));
	        response.setErrors(Collections.emptyList());
	        return ResponseEntity.ok().body(responseBuilder.buildResponse(response));
	    }
	
	  @PostMapping(value = "{version}/mf/cif/inq/txn-key")
	    public ResponseEntity<CustomResponse<String>> mfCifInquiryTxnKey(@PathVariable("version") String version, @Valid @RequestBody MFCifInquiryRequest requestBody, HttpServletRequest httpServletRequest) throws GlobalException {
	    	LOGGER.info("Entered in method-mfCifInquiryTxnKey of class-MfCIfInquiryApi at {}", System.currentTimeMillis());
	    	LOGGER.info("Request received for Mf Cif Inquiry Maintenance {}", requestBody.toString());
	        HeaderRequest header = new HeaderRequest();
	        String txnKey = CommonUtils.generateSHA256Key(header.getTxnHeaderKey() + requestBody.getTxnBodyKey());
	        SessionMap.setContext(KEY_MAP_API_VERSION, version);
	        String traceId = (String) SessionMap.getValue(KEY_MAP_TRACE_ID);
	        CustomResponse<String> response = new CustomResponse<>();
	        response.setResponse(Collections.singletonList(txnKey));
	        response.setErrors(Collections.emptyList());
	        response.setTraceId(traceId);
	        response.setSuccess(true);
	        return ResponseEntity.ok().body(response);
	    }
}