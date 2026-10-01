package com.oracle.fcr.ngi.customer.inq.exception.payload.request;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.oracle.fcr.ngi.util.SessionMap;
import lombok.AllArgsConstructor;
import lombok.Data;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.validation.ConstraintViolation;
import javax.validation.Validation;
import javax.validation.Validator;
import javax.validation.ValidatorFactory;
import javax.validation.ConstraintViolationException;
import javax.validation.constraints.NotEmpty;
import javax.validation.constraints.Pattern;
import javax.validation.constraints.Size;
import java.io.Serializable;
import java.util.Set;

import static com.oracle.fcr.ngi.util.GlobalConstant.*;


@Data
@AllArgsConstructor
public class TxnHeaderRequest implements Serializable {
    private static final Logger LOGGER = LoggerFactory.getLogger(TxnHeaderRequest.class);
    private static final long serialVersionUID = -3817005678284208574L;

    @Size(max = 10, message = "channelID  size must be less then 11 characters")
    @JsonProperty(value = "channelID")
    private String channelID;

    private String svcCode;
    @Size(max = 40, message = "Invalid svcRqID")
    @NotEmpty(message = "svcRqID Is Mandatory")
    @JsonProperty(value = "svcRqID")
    private String svcRqId;

    @Size(min = 14, max = 14, message = "TxnDate  size must be 14 characters")
    @Pattern(regexp = "^(19|20|21)\\d{2}(0[1-9]|1[0-2])(0[1-9]|[1-2][\\d]|3[0-1])([01][\\d]|2[0-3])([0-5][\\d])([0-5][\\d])$", message = "Date format must be yyyyMMddHHmmss")
    @NotEmpty(message = "TxnDate Is Mandatory")
    private String txnDate;

    @JsonProperty(value = "TxnKey")
    private String txnKey;

    @NotEmpty(message = "userId Is Mandatory")
    @JsonProperty(value = "userID")
    private String userID;

    @NotEmpty(message = "channelDirect Is Mandatory")
    @Pattern(regexp = "\\b[YN]\\b", message = "only Y or N are allowed.")
    @Size(max = 1, message = "Invalid channelDirect")
    @JsonProperty(value = "channelDirect")
    private String channelDirect;


    public static TxnHeaderRequest createAndValidate() {
        TxnHeaderRequest header = new TxnHeaderRequest();
        ValidatorFactory factory = Validation.buildDefaultValidatorFactory();
        Validator validator = factory.getValidator();
        Set<ConstraintViolation<TxnHeaderRequest>> violations = validator.validate(header);
        if (!violations.isEmpty()) {
            throw new ConstraintViolationException(violations);
        }
        return header;
    }

    public TxnHeaderRequest() {
        this.userID = (String) SessionMap.getValue(KEY_MAP_USER_ID);
        this.channelID = (String) SessionMap.getValue(KEY_MAP_CHANNEL_ID);
        this.svcCode = (String) SessionMap.getValue(KEY_MAP_SVC_CODE);
        this.svcRqId = (String) SessionMap.getValue(KEY_MAP_SVC_RQ_ID);
        this.txnDate = (String) SessionMap.getValue(KEY_MAP_TXN_DATE);
        this.channelDirect = (String) SessionMap.getValue(KEY_MAP_CHANNEL_DIRECT);
        this.txnKey = (String) SessionMap.getValue(KEY_MAP_TXN_KEY);
    }

    @Override
    public String toString() {
        return "TxnHeaderRequest{" +
                ", channelId='" + channelID + '\'' +
                ", svcCode='" + svcCode + '\'' +
                ", svcRqId='" + svcRqId + '\'' +
                ", txnDate='" + txnDate + '\'' +
                ", txnKey='" + txnKey + '\'' +
                ", userId='" + userID + '\'' +
                ", channelDirect='" + channelDirect + '\'' +
                '}';
    }

    public String getTxnHeaderKey() {
        String txnHeaderKey = "";
        try {
            txnHeaderKey = channelID + svcCode + svcRqId + txnDate + userID + channelDirect;
            LOGGER.info("TxnHeader key: {}", txnHeaderKey);
        } catch (Exception e) {
            LOGGER.error("An exception occurred while creating txnKey");
        }
        return txnHeaderKey;
    }
}
