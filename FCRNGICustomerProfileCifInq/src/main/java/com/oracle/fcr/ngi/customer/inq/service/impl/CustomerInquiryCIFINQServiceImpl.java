package com.oracle.fcr.ngi.customer.inq.service.impl;

import com.oracle.fcr.ngi.customer.inq.dbutil.QueryExecutorCustomerInquiry;
import com.oracle.fcr.ngi.customer.inq.exception.payload.request.CustomerProfileInquiryCifinqRequest;
import com.oracle.fcr.ngi.customer.inq.exception.payload.request.TxnHeaderRequest;
import com.oracle.fcr.ngi.customer.inq.exception.payload.response.CifRec;
import com.oracle.fcr.ngi.customer.inq.exception.payload.response.CustomerProfileInquiryCifinqResponse;
import com.oracle.fcr.ngi.customer.inq.service.CustomerInquiryCIFINQService;
import com.oracle.fcr.ngi.enumeration.StatusType;
import com.oracle.fcr.ngi.exception.CustomerInquiryException;
import com.oracle.fcr.ngi.exception.ExceptionManager;
import com.oracle.fcr.ngi.exception.GlobalException;
import com.oracle.fcr.ngi.exception.NGISQLException;
import com.oracle.fcr.ngi.il.entity.Customer;
import com.oracle.fcr.ngi.il.entity.CustomerAddress;
import com.oracle.fcr.ngi.il.entity.CustomerCard;
import com.oracle.fcr.ngi.il.entity.Individual;
import com.oracle.fcr.ngi.il.enumeration.LoanAccountStatusType;
import com.oracle.fcr.ngi.il.enumeration.AddressType;
import com.oracle.fcr.ngi.il.enumeration.TermDepositAccountStatusType;
import com.oracle.fcr.ngi.il.enumeration.CardStatusType;
import com.oracle.fcr.ngi.il.enumeration.CurrentAndSavingsAccountStatusType;
import com.oracle.fcr.ngi.il.enumeration.CustomerProfileInquiryType;
import com.oracle.fcr.ngi.il.model.CasaMiniInfo;
import com.oracle.fcr.ngi.il.repository.CustomerCardRepository;
import com.oracle.fcr.ngi.il.repository.CustomerRepository;
import com.oracle.fcr.ngi.il.service.CustomerAddressService;
import com.oracle.fcr.ngi.model.CustomError;
import com.oracle.fcr.ngi.payload.response.Response;
import com.oracle.fcr.ngi.util.CommonFCRJErrorConstants;
import com.oracle.fcr.ngi.util.CommonUtils;
import com.oracle.fcr.ngi.util.GlobalConstant;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

import javax.persistence.PersistenceException;
import javax.validation.Valid;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeFormatterBuilder;
import java.time.format.DateTimeParseException;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Locale;
import java.util.Objects;
import java.util.Optional;

@Service
@RequiredArgsConstructor(onConstructor_ = {@Autowired})
public class CustomerInquiryCIFINQServiceImpl implements CustomerInquiryCIFINQService {
    private static final Logger LOGGER = LoggerFactory.getLogger(CustomerInquiryCIFINQServiceImpl.class);
    private static final String MOTHER_MAIDEN_NAME_TAG = "TXT_691";
    private static final String IC_TYPE_TAG = "TXT_696";
    private static final String PASSPORT_EXPIRY_DATE_TAG = "TXT_762";
    private static final String IC_TYPE_PASSPORT = "PAS";
    public static final String MNT_CUSTOMER = "CIM09";
    public static final String ACCOUNT_NOT_FOUND_MESSAGE = "No account found for this account {}";
    public static final String CUSTOMER_NOT_FOUND_MESSAGE = "No customer found for this customer {}";
    public static final String ACCOUNT_CLOSED_MESSAGE = "Account is closed {}";
    public static final String START_GETTING_CUSTOMERS_MESSAGE = "Start getting customers {}";
    public static final String END_GETTING_CUSTOMERS_MESSAGE = "End getting customers {}";

    private static final DateTimeFormatter PASSPORT_EXPIRY_DATE_OUTPUT_FORMAT = DateTimeFormatter.ofPattern("yyyyMMdd");
    /**
     * The passport expiry date is kept as free text in the UDF table, so the value is normalised to the
     * YYYYMMDD format expected by the consumer instead of being passed through as it was captured.
     */
    private static final List<DateTimeFormatter> PASSPORT_EXPIRY_DATE_INPUT_FORMATS = Collections.unmodifiableList(
            Arrays.asList(
                    passportExpiryDateFormat("yyyyMMdd"),
                    passportExpiryDateFormat("dd/MM/yyyy"),
                    passportExpiryDateFormat("dd-MM-yyyy"),
                    passportExpiryDateFormat("dd.MM.yyyy"),
                    passportExpiryDateFormat("dd-MMM-yyyy"),
                    passportExpiryDateFormat("yyyy-MM-dd"),
                    passportExpiryDateFormat("yyyy/MM/dd")));

    private final CustomerCardRepository customerCardRepository;
    private final CustomerRepository customerRepository;
    private final CustomerAddressService customerAddressService;
    private final QueryExecutorCustomerInquiry queryExecutorCustomerInquiry;
    private final CommonUtils commonUtils;

    @Override
    public Response inquireCustomerProfile(@Valid CustomerProfileInquiryCifinqRequest requestBody) throws  GlobalException {
        LOGGER.info("Request received for Cifinq. {}", requestBody);
        TxnHeaderRequest header = TxnHeaderRequest.createAndValidate();
        commonUtils.validateTxnKey(header.getTxnKey(),
                CommonUtils.generateSHA256Key(header.getTxnHeaderKey() + requestBody.getTxnBodyKey()));

        CustomerProfileInquiryCifinqResponse response = new CustomerProfileInquiryCifinqResponse();
        CifRec cifRec;
        Customer customer;
        long customerId = 0;
        try {
            customer = verifyAndPrepareCustomer(requestBody, customerId);

            cifRec = populateCustomerProfile(customer, requestBody);

            response.setCifRec(cifRec);
            response.setResponseCode(GlobalConstant.SUCCESS_CODE);
            response.setResponseMessage(GlobalConstant.SUCCESS_MESSAGE);
        } catch (CustomerInquiryException e) {
            LOGGER.error("An CustomerInquiryException occurred during inquireCustomerAccountSummary", e);
            if (e.getErrors() != null && !e.getErrors().isEmpty()) {
                CustomError error = e.getErrors().get(0);
                response.setResponseCode(error.getCode());
                response.setResponseMessage(error.getMessage());
            }
        } catch (NGISQLException e) {
            LOGGER.error("An NGISQLException occurred during inquireCustomerAccountSummary", e);
            if (e.getErrors() != null && !e.getErrors().isEmpty()) {
                CustomError error = e.getErrors().get(0);
                response.setResponseCode(error.getCode());
                response.setResponseMessage(error.getMessage());
            }
        } catch (Exception e) {
            LOGGER.error("An Exception occurred during inquireCustomerAccountSummary", e);
            ExceptionManager.throwGlobalException(GlobalConstant.ACCOUNT_ID_REQUIRED_ERROR_CODE, GlobalConstant.ACCOUNT_ID_REQUIRED_ERROR_MESSAGE, GlobalConstant.ACCOUNT_ID_REQUIRED_ERROR_TYPE);
        }
        return response;
    }

    private Customer verifyAndPrepareCustomer(CustomerProfileInquiryCifinqRequest requestBody, long customerId) throws CustomerInquiryException {
        Customer customer;
        if (requestBody.getCifInqRq().getAcctType().equalsIgnoreCase(CustomerProfileInquiryType.ATM_CARD.getValue())) {
            customer = verifyAndGetCustomerForATMCard(requestBody);
        } else if (requestBody.getCifInqRq().getAcctType().equalsIgnoreCase(CustomerProfileInquiryType.CASA.getValue())
                || requestBody.getCifInqRq().getAcctType().equalsIgnoreCase(CustomerProfileInquiryType.CURRENT.getValue())
                || requestBody.getCifInqRq().getAcctType().equalsIgnoreCase(CustomerProfileInquiryType.SAVINGS.getValue())) {

            customer = verifyAndGetCustomerForCASA(requestBody);
        } else if (requestBody.getCifInqRq().getAcctType().equals(CustomerProfileInquiryType.CIF.getValue())) {
            customer = verifyAndGetCustomerForCIF(requestBody);
        } else if (requestBody.getCifInqRq().getAcctType().equalsIgnoreCase(CustomerProfileInquiryType.LOANS.getValue())) {
            customer = verifyAndGetCustomerForLOANS(requestBody);
        } else if (requestBody.getCifInqRq().getAcctType().equalsIgnoreCase(CustomerProfileInquiryType.TIME_DEPOSIT.getValue())) {
            customer = verifyAndGetCustomerForTimeDeposit(requestBody);
        } else {
            LOGGER.info(CUSTOMER_NOT_FOUND_MESSAGE, customerId);
            CustomError error = new CustomError(CommonFCRJErrorConstants.MID_EGL_INPUT_REQD, String.format(CommonFCRJErrorConstants.MID_EGL_INPUT_REQD_MESSAGE, "ACCT_TYPE"), HttpStatus.BAD_REQUEST.getReasonPhrase());
            throw new CustomerInquiryException(Collections.singletonList(error));
        }
        return customer;
    }

    private Customer verifyAndGetCustomerForTimeDeposit(CustomerProfileInquiryCifinqRequest requestBody) throws CustomerInquiryException {
        long customerId;
        LOGGER.info("Start getting tdMiniInfo {}", LocalDateTime.now());
        List<CasaMiniInfo> tdMiniInfo = queryExecutorCustomerInquiry.getTDCustIdByAcct(requestBody.getCifInqRq().getAcctId());

        LOGGER.info("End getting tdMiniInfo {}", LocalDateTime.now());
        if (tdMiniInfo == null || tdMiniInfo.isEmpty()) {
            LOGGER.info(ACCOUNT_NOT_FOUND_MESSAGE, requestBody.getCifInqRq().getAcctId());
            CustomError error = new CustomError(CommonFCRJErrorConstants.MID_EHS_REC_NOT_AUTHORIZED, CommonFCRJErrorConstants.MID_EHS_REC_NOT_AUTHORIZED_MESSAGE, HttpStatus.NOT_FOUND.getReasonPhrase());
            throw new CustomerInquiryException(Collections.singletonList(error));
        }
        CasaMiniInfo termDeposit = tdMiniInfo.get(0);
        if (Objects.equals(TermDepositAccountStatusType.TD_ACCT_STAT_CLO_TODAY.getValue(), termDeposit.getAccountStatus())
                || Objects.equals(TermDepositAccountStatusType.TD_ACCT_STAT_CLOSED.getValue(), termDeposit.getAccountStatus())) {
            LOGGER.info(ACCOUNT_CLOSED_MESSAGE, requestBody.getCifInqRq().getAcctId());
            CustomError error = new CustomError(CommonFCRJErrorConstants.MID_ACNOCLOS, CommonFCRJErrorConstants.MID_ACNOCLOS_MESSAGE, HttpStatus.NOT_FOUND.getReasonPhrase());
            throw new CustomerInquiryException(Collections.singletonList(error));
        }

        customerId = termDeposit.getCustomerId();
        LOGGER.info(START_GETTING_CUSTOMERS_MESSAGE, LocalDateTime.now());
        return getCustomer(customerId);
    }

    private Customer verifyAndGetCustomerForLOANS(CustomerProfileInquiryCifinqRequest requestBody) throws CustomerInquiryException {
        long customerId;
        LOGGER.info("Start getting loanMiniInfo {}", LocalDateTime.now());
        List<CasaMiniInfo> loanMiniInfo = queryExecutorCustomerInquiry.getLNCustIdByAcct(requestBody.getCifInqRq().getAcctId());
        LOGGER.info("End getting loanMiniInfo {}", LocalDateTime.now());
        if (loanMiniInfo == null || loanMiniInfo.isEmpty()) {
            LOGGER.info(ACCOUNT_NOT_FOUND_MESSAGE, requestBody.getCifInqRq().getAcctId());
            CustomError error = new CustomError(CommonFCRJErrorConstants.MID_EHS_REC_NOT_AUTHORIZED, CommonFCRJErrorConstants.MID_EHS_REC_NOT_AUTHORIZED_MESSAGE, HttpStatus.NOT_FOUND.getReasonPhrase());
            throw new CustomerInquiryException(Collections.singletonList(error));
        }
        CasaMiniInfo loan = loanMiniInfo.get(0);
        if (LoanAccountStatusType.CLOSED.getValue().equals(loan.getAccountStatus())
                || LoanAccountStatusType.CLOSED_TODAY.getValue().equals(loan.getAccountStatus())) {
            LOGGER.info(ACCOUNT_CLOSED_MESSAGE, requestBody.getCifInqRq().getAcctId());
            CustomError error = new CustomError(CommonFCRJErrorConstants.MID_ACNOCLOS, CommonFCRJErrorConstants.MID_ACNOCLOS_MESSAGE, HttpStatus.NOT_FOUND.getReasonPhrase());
            throw new CustomerInquiryException(Collections.singletonList(error));
        }

        customerId = loan.getCustomerId();
        LOGGER.info(START_GETTING_CUSTOMERS_MESSAGE, LocalDateTime.now());
        return getCustomer(customerId);
    }

    private Customer verifyAndGetCustomerForCIF(CustomerProfileInquiryCifinqRequest requestBody) throws CustomerInquiryException {
        long customerId;
        customerId = Long.parseLong(requestBody.getCifInqRq().getAcctId());
        LOGGER.info(START_GETTING_CUSTOMERS_MESSAGE, LocalDateTime.now());
        return getCustomer(customerId);
    }

    private Customer getCustomer(long customerId) throws CustomerInquiryException {
        Optional<Customer> customerOptional = customerRepository.getByIdAndStatus(customerId, StatusType.A);
        LOGGER.info(END_GETTING_CUSTOMERS_MESSAGE, LocalDateTime.now());
        if (!customerOptional.isPresent()) {
            LOGGER.info(CUSTOMER_NOT_FOUND_MESSAGE, customerId);
            CustomError error = new CustomError(CommonFCRJErrorConstants.MID_ETD_COD_CUST_INV, CommonFCRJErrorConstants.MID_ETD_COD_CUST_INV_MESSAGE + " Or not authorized.", HttpStatus.NOT_FOUND.getReasonPhrase());
            throw new CustomerInquiryException(Collections.singletonList(error));
        }
        return customerOptional.get();
    }

    private Customer verifyAndGetCustomerForCASA(CustomerProfileInquiryCifinqRequest requestBody) throws CustomerInquiryException {
        long customerId;
        LOGGER.info("Start getting casaMiniInfo {}", LocalDateTime.now());
        List<CasaMiniInfo> casaMiniInfo = queryExecutorCustomerInquiry.getCHCustIdByAcct(requestBody.getCifInqRq().getAcctId());
        LOGGER.info("End getting casaMiniInfo {}", LocalDateTime.now());

        if (casaMiniInfo == null || casaMiniInfo.isEmpty()) {
            LOGGER.info(ACCOUNT_NOT_FOUND_MESSAGE, requestBody.getCifInqRq().getAcctId());
            CustomError error = new CustomError(CommonFCRJErrorConstants.MID_EHS_REC_NOT_AUTHORIZED, CommonFCRJErrorConstants.MID_EHS_REC_NOT_AUTHORIZED_MESSAGE, HttpStatus.NOT_FOUND.getReasonPhrase());
            throw new CustomerInquiryException(Collections.singletonList(error));
        }
        if (CurrentAndSavingsAccountStatusType.CLOSED.getValue().equalsIgnoreCase(casaMiniInfo.get(0).getAccountStatus())
                || CurrentAndSavingsAccountStatusType.CLOSED_TODAY.getValue().equalsIgnoreCase(casaMiniInfo.get(0).getAccountStatus())) {
            LOGGER.info(ACCOUNT_CLOSED_MESSAGE, requestBody.getCifInqRq().getAcctId());
            CustomError error = new CustomError(CommonFCRJErrorConstants.MID_ACNOCLOS, CommonFCRJErrorConstants.MID_ACNOCLOS_MESSAGE, HttpStatus.NOT_FOUND.getReasonPhrase());
            throw new CustomerInquiryException(Collections.singletonList(error));
        }

        customerId = casaMiniInfo.get(0).getCustomerId();
        LOGGER.info(START_GETTING_CUSTOMERS_MESSAGE, LocalDateTime.now());
        return getCustomer(customerId);
    }

    private Customer verifyAndGetCustomerForATMCard(CustomerProfileInquiryCifinqRequest requestBody) throws CustomerInquiryException {
        long customerId;
        LOGGER.info("Start getting customer card {}", LocalDateTime.now());
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
        CustomerCard customerCard = customerCardOptional.get();
        customerId = customerCard.getCustomerId();
        LOGGER.info("Start getting customer {}", LocalDateTime.now());
        return getCustomer(customerId);
    }

    private CifRec populateCustomerProfile(Customer customer, CustomerProfileInquiryCifinqRequest requestBody) throws NGISQLException {
        LOGGER.info("Start populateCustomerProfile {}", LocalDateTime.now());
        CifRec response = new CifRec();
        response.setCifId(customer.getId());
        response.setCifDob(customer.getBirthDate());

        CustomerAddress currentAddress = customerAddressService.fetchCustomerAddressDetailById(customer.getId(), AddressType.CURRENT.getValue());
        if (currentAddress != null) {
            response.setAddress1(currentAddress.getLine1());
            response.setAddress2(currentAddress.getLine2());
            response.setAddress3(currentAddress.getLine3());
            response.setAddress5(currentAddress.getCity() + "," + currentAddress.getCountry());
            response.setPostCode(currentAddress.getZip());
        }
        if (customer.getContactDetail() != null) {
            response.setEmailAddr(customer.getContactDetail().getEmail());
        }
        response.setCifName(customer.getFullName());
        response.setMobileNo(customer.getContactDetail().getMobile());

        response.setCifMotherName(fetchCustomerMotherMaidenName(customer.getId()));
        if (customer instanceof Individual) {
            Individual individual = (Individual) customer;
            if (individual.getSex() != null) {
                response.setCifGender(individual.getSex().getValue());
            }
        }

        populatePassportDetails(response, customer.getId());
        LOGGER.info("End populateCustomerProfile {}", LocalDateTime.now());
        if (requestBody.getCifInqRq().getAcctType().equalsIgnoreCase(CustomerProfileInquiryType.ATM_CARD.getValue())) {
            response.setAtmCardNo(requestBody.getCifInqRq().getAcctId());
        } else {
            String atmCardNumber = null;
            try {
                atmCardNumber = fetchCardForCIF(customer.getId());
            } catch (NGISQLException e) {
                LOGGER.error("An exception occurred during getting ATM card by cifid {}", customer.getId(), e);
            }
            if (atmCardNumber == null || "".equals(atmCardNumber)) {
                response.setAtmCardNo(" ");
            } else {
                response.setAtmCardNo(atmCardNumber);
            }
        }
        return response;
    }

    private String fetchCustomerMotherMaidenName(long customerId) throws NGISQLException {
        return fetchCustomerUdfFieldValue(customerId, MOTHER_MAIDEN_NAME_TAG);
    }

    private String fetchCustomerUdfFieldValue(long customerId, String fieldTag) throws NGISQLException {
        String fieldValue;
        try {
            String customerIdStr = customerId + "";
            LOGGER.info("Start getting udf field {} {}", fieldTag, LocalDateTime.now());
            fieldValue = queryExecutorCustomerInquiry.getUdfFieldValueByCustId(customerIdStr, fieldTag, MNT_CUSTOMER);
            LOGGER.info("End getting udf field {} {}", fieldTag, LocalDateTime.now());
        } catch (PersistenceException e) {
            LOGGER.error("IB fetchCustomerUdfFieldValue error for customerId {} and field tag {}", customerId, fieldTag);
            CustomError error = new CustomError(MNT_CUSTOMER, "IB fetchCustomerUdfFieldValue error ", HttpStatus.NOT_FOUND.getReasonPhrase());
            throw new NGISQLException(Collections.singletonList(error));
        }
        return fieldValue;
    }

    /**
     * Populates the identity card type together with the passport number and passport expiry date.
     * The passport fields are only meaningful for a passport holder, so they are left empty for every
     * other identity card type.
     */
    private void populatePassportDetails(CifRec response, long customerId) throws NGISQLException {
        String icType = trimToNull(fetchCustomerUdfFieldValue(customerId, IC_TYPE_TAG));
        response.setIcType(icType);

        if (!IC_TYPE_PASSPORT.equalsIgnoreCase(icType)) {
            LOGGER.info("Skipping passport details for customer {} because icType is {}", customerId, icType);
            response.setPassportNo(null);
            response.setPassportExpiryDate(null);
            return;
        }

        response.setPassportNo(trimToNull(fetchCustomerNationalId(customerId)));
        String passportExpiryDate = trimToNull(fetchCustomerUdfFieldValue(customerId, PASSPORT_EXPIRY_DATE_TAG));
        response.setPassportExpiryDate(passportExpiryDate == null ? null : formatPassportExpiryDate(passportExpiryDate));
    }

    private String fetchCustomerNationalId(long customerId) throws NGISQLException {
        try {
            LOGGER.info("Start getting national id {}", LocalDateTime.now());
            String nationalId = queryExecutorCustomerInquiry.getNationalIdByCustomerId(customerId);
            LOGGER.info("End getting national id {}", LocalDateTime.now());
            return nationalId;
        } catch (PersistenceException e) {
            LOGGER.error("IB fetchCustomerNationalId error for customerId {}", customerId);
            CustomError error = new CustomError(MNT_CUSTOMER, "IB fetchCustomerNationalId error ", HttpStatus.NOT_FOUND.getReasonPhrase());
            throw new NGISQLException(Collections.singletonList(error));
        }
    }

    private static String formatPassportExpiryDate(String passportExpiryDate) {
        for (DateTimeFormatter inputFormat : PASSPORT_EXPIRY_DATE_INPUT_FORMATS) {
            try {
                return LocalDate.parse(passportExpiryDate, inputFormat).format(PASSPORT_EXPIRY_DATE_OUTPUT_FORMAT);
            } catch (DateTimeParseException e) {
                LOGGER.debug("Passport expiry date {} does not match one of the supported formats", passportExpiryDate);
            }
        }
        LOGGER.warn("Passport expiry date {} is in an unsupported format, it is returned as it is stored", passportExpiryDate);
        return passportExpiryDate;
    }

    private static DateTimeFormatter passportExpiryDateFormat(String pattern) {
        return new DateTimeFormatterBuilder()
                .parseCaseInsensitive()
                .appendPattern(pattern)
                .toFormatter(Locale.ENGLISH);
    }

    private static String trimToNull(String value) {
        if (value == null) {
            return null;
        }
        String trimmedValue = value.trim();
        return trimmedValue.isEmpty() ? null : trimmedValue;
    }

    private String fetchCardForCIF(final long customerId) throws NGISQLException {
        String cardNumber = null;
        try {
            LOGGER.info("Start getting cardNumber {}", LocalDateTime.now());
            cardNumber = queryExecutorCustomerInquiry.getAtmCardNoByCustomerId(customerId);
            LOGGER.info("End getting cardNumber {}", LocalDateTime.now());
        } catch (PersistenceException e) {
            LOGGER.error("No card in card master with active status for CIF {}", customerId, e);
            CustomError error = new CustomError(CommonFCRJErrorConstants.MID_EREC_NOT_FOUND, CommonFCRJErrorConstants.MID_EREC_NOT_FOUND_MESSAGE, HttpStatus.NOT_FOUND.getReasonPhrase());
            throw new NGISQLException(Collections.singletonList(error));
        }

        if (cardNumber == null) {
            LOGGER.error("No card in card master with active status for CIF {}", customerId);
            CustomError error = new CustomError(CommonFCRJErrorConstants.MID_EREC_NOT_FOUND, CommonFCRJErrorConstants.MID_EREC_NOT_FOUND_MESSAGE, HttpStatus.NOT_FOUND.getReasonPhrase());
            throw new NGISQLException(Collections.singletonList(error));
        }

        return cardNumber;
    }
}
