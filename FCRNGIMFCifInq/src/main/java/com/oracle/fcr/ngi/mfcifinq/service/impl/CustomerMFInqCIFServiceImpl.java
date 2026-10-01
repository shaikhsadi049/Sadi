package com.oracle.fcr.ngi.mfcifinq.service.impl;
import java.util.List;
import java.util.Objects;
import java.util.Optional;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Collections;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

import com.oracle.fcr.ngi.enumeration.StatusType;
import com.oracle.fcr.ngi.exception.CustomerInquiryException;
import com.oracle.fcr.ngi.exception.ExceptionManager;
import com.oracle.fcr.ngi.exception.GlobalException;
import com.oracle.fcr.ngi.exception.NGISQLException;
import com.oracle.fcr.ngi.exception.NotFoundException;
import com.oracle.fcr.ngi.il.entity.Customer;
import com.oracle.fcr.ngi.il.enumeration.CurrentAndSavingsAccountStatusType;
import com.oracle.fcr.ngi.il.enumeration.CustomerProfileInquiryType;
import com.oracle.fcr.ngi.il.enumeration.LoanAccountStatusType;
import com.oracle.fcr.ngi.il.enumeration.TermDepositAccountStatusType;
import com.oracle.fcr.ngi.il.model.CasaMiniInfo;
import com.oracle.fcr.ngi.il.repository.CustomerCardRepository;
import com.oracle.fcr.ngi.il.repository.CustomerRepository;
import com.oracle.fcr.ngi.il.service.CustomerAddressService;
import com.oracle.fcr.ngi.mfcifinq.dbutil.MFCIFInqReqMapper;
import com.oracle.fcr.ngi.mfcifinq.dbutil.ProcedureExecutorMFAcctCIFInq;
import com.oracle.fcr.ngi.mfcifinq.dbutil.ProcedureExecutorMFCIFInq;
import com.oracle.fcr.ngi.mfcifinq.dbutil.QueryExecutorCustomerInquiry;
import com.oracle.fcr.ngi.mfcifinq.payload.request.CustomerInqMFCIFInqWrapperReq;
import com.oracle.fcr.ngi.mfcifinq.payload.request.HeaderRequest;
import com.oracle.fcr.ngi.mfcifinq.payload.request.MFCifInquiryRequest;
import com.oracle.fcr.ngi.mfcifinq.payload.response.MFCifInfoRes;
import com.oracle.fcr.ngi.mfcifinq.payload.response.MFCifInqResponse;
import com.oracle.fcr.ngi.mfcifinq.service.CustomerMFInqCIFService;
import com.oracle.fcr.ngi.model.CustomError;
import com.oracle.fcr.ngi.payload.response.Response;
import com.oracle.fcr.ngi.util.CommonFCRJErrorConstants;
import com.oracle.fcr.ngi.util.CommonUtils;
import com.oracle.fcr.ngi.util.GlobalConstant;

import lombok.RequiredArgsConstructor;


@Service
@RequiredArgsConstructor(onConstructor_ = {@Autowired})
public class CustomerMFInqCIFServiceImpl implements CustomerMFInqCIFService {

    private static final Logger logger = LoggerFactory.getLogger(CustomerMFInqCIFServiceImpl.class);
    
    private final ProcedureExecutorMFCIFInq procedureExecutorMFCifInq;
    private final ProcedureExecutorMFAcctCIFInq procedureExecutorMFAcctCIFInq;
    private final QueryExecutorCustomerInquiry queryExecutorCustomerInquiry;  
    private final CustomerRepository customerRepository;

    @Autowired
    private CommonUtils commonUtils;
    public static final String CUSTOMER_NOT_FOUND_MESSAGE = "No customer found for this customer {}";
    public static final String START_GETTING_CUSTOMERS_MESSAGE = "Start getting customers {}";
    public static final String END_GETTING_CUSTOMERS_MESSAGE = "End getting customers {}";
    public static final String ACCOUNT_NOT_FOUND_MESSAGE = "No account found for this account {}";
    public static final String ACCOUNT_CLOSED_MESSAGE = "Account is closed {}";
    

	@Override
	public Response mfCifInquiry(MFCifInquiryRequest requestBody)
			throws NGISQLException, GlobalException, NotFoundException {
		logger.info("Inside call mfCifInquiry");
        logger.info("--------------------------------");

        MFCifInqResponse response = new MFCifInqResponse();
        List<MFCifInfoRes> cifInfo=new ArrayList<MFCifInfoRes>();

        try {
		commonUtils.printLog("Request received for MF CIFSUM Inquiry" + requestBody.toString());
        HeaderRequest requestHeader = HeaderRequest.createAndValidate();
        commonUtils.validateTxnKey(requestHeader.getTxnKey(),
                CommonUtils.generateSHA256Key(requestHeader.getTxnHeaderKey() + requestBody.getTxnBodyKey()));
        logger.info("Request Header for MF CIFSUM Inquiry{}", requestHeader);
        CustomerInqMFCIFInqWrapperReq req = MFCIFInqReqMapper.mapToWrapperReq(requestBody, requestHeader);
        String acctId=req.getAcctId();
        String acctType=req.getTypeId();
        if (requestBody.getTypeId().equalsIgnoreCase(CustomerProfileInquiryType.ATM_CARD.getValue())) {
        	acctId=String.valueOf(verifyAndGetCustomerForATMCard(requestBody));
        	acctType="90";
        }
        cifInfo = procedureExecutorMFCifInq.getMFCifsumData(req,acctId,acctType);
        if(cifInfo.size()>1||requestBody.getTypeId().equals("91")||requestBody.getTypeId().equals("99")) {
        	response.setCifInfo(cifInfo);
        	response.setResponseCode(GlobalConstant.SUCCESS_CODE);
			response.setResponseMessage(GlobalConstant.SUCCESS_MESSAGE);
			response.setAcctId(requestBody.getAcctId());
			response.setTypeId(requestBody.getTypeId());
			return response;
        }
       
        response.setCifInfo(cifInfo);
        
        
        response=procedureExecutorMFAcctCIFInq.getMFCifSumAcctData(req, acctId, acctType, response);
        commonUtils.printLog("Response Generate for MF CIFSUM Inquiry. " + response);
        } catch (NGISQLException e) {
            throw new GlobalException(e.getErrors());
        }catch (Exception e) {
            logger.error("Exception [{}]", e.getMessage());
            throw new GlobalException(e.getMessage());
        }
		return response;
	}
	 private long verifyAndGetCustomerForATMCard(MFCifInquiryRequest requestBody) throws CustomerInquiryException {
	        long customerId=0;
	        
	       /* LOGGER.info("Start getting customer card {}", LocalDateTime.now());
	        Optional<CustomerCard> customerCardOptional = customerCardRepository.getByCardNumberAndStatusAndCardStatus(
	                requestBody.getCifInqRq().getAcctId(),
	                StatusType.A,
	                CardStatusType.ACTIVE
	        );
	        LOGGER.info("End getting customer card {}", LocalDateTime.now());
	        if (!customerCardOptional.isPresent()) {
	            LOGGER.info("No account found for this customer {}", requestBody.getCifInqRq().getAcctId());
	            CustomError error = new CustomError(CommonFCRJErrorConstants.Ecm_card_nof, CommonFCRJErrorConstants.Ecm_card_nof_Message, HttpStatus.NOT_FOUND.getReasonPhrase());
	            throw new CustomerInquiryException(Collections.singletonList(error));
	        }
	        CustomerCard customerCard = customerCardOptional.get();*/
	        String custId=queryExecutorCustomerInquiry.getCustomerIdByAtmCard(requestBody.getAcctId());
	        customerId=Long.parseLong(custId==null?"0":custId);
	        if (customerId==0) {
	        	logger.info(CUSTOMER_NOT_FOUND_MESSAGE, customerId);
	            CustomError error = new CustomError(CommonFCRJErrorConstants.MID_ETD_COD_CUST_INV, CommonFCRJErrorConstants.MID_ETD_COD_CUST_INV_MESSAGE + " Or not authorized.", HttpStatus.NOT_FOUND.getReasonPhrase());
	            throw new CustomerInquiryException(Collections.singletonList(error));
	        }
	        logger.info(" Customer Id for card {}", customerId);
	        logger.info("Start getting customer {}", LocalDateTime.now());
	       return customerId;
	 }
	    
	


}
