package com.oracle.fcr.ngi.mfcifinq.payload.request;


import com.oracle.fcr.ngi.annotations.DatePattern;
import com.oracle.fcr.ngi.util.SessionMap;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.Getter;
import lombok.Setter;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.validation.ConstraintViolationException;
import javax.validation.ConstraintViolation;
import javax.validation.Validation;
import javax.validation.Validator;
import javax.validation.ValidatorFactory;
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.Pattern;
import javax.validation.constraints.Size;
import java.io.Serializable;
import java.util.Set;

import static com.oracle.fcr.ngi.util.GlobalConstant.*;

@Data
@AllArgsConstructor
@Setter
@Getter
public class HeaderRequest implements Serializable {

    private static final Logger LOGGER = LoggerFactory.getLogger(HeaderRequest.class);
    private static final long serialVersionUID = -3817005678284208574L;

    private String channelId;
    @NotBlank(message = "svcCode Is Mandatory Input")
    @Size(max = 20, message = "svcCode len/size must be 20 characters or less")
    private String svcCode;
    @NotBlank(message = "svcRqId Is Mandatory Input")
    @Size(max = 40, message = "Service Req ID size must be 40 characters or less")
    private String svcRqId;
    @NotBlank(message = "userId Is Mandatory Input")
    @Size(max = 20, message = "userId size must be 10 characters or less")
    private String userId;
    @DatePattern(pattern = "yyyyMMddHHmmss")
    @NotBlank(message = "txnDate Is Mandatory Input")
    @Size(min = 14, max = 14, message = "txnDate  size must be 14 characters")
    @Pattern(regexp = "^\\d*$", message = "txnDate must be numeric. And Format: yyyymmddhhmmss")
    private String txnDate;
    @NotBlank(message = "channelDirect Is Mandatory Input")
    @Pattern(regexp = "\\b[YN]\\b", message = "only Y or N are allowed.")
    @Size(max = 1, message = "channelDirect must be 1 character")
    private String channelDirect;

    private String txnKey;

    public HeaderRequest() {
        this.channelId = (String) SessionMap.getValue(KEY_MAP_CHANNEL_ID);
        this.userId = (String) SessionMap.getValue(KEY_MAP_USER_ID);
        this.svcCode = (String) SessionMap.getValue(KEY_MAP_SVC_CODE);
        this.svcRqId = (String) SessionMap.getValue(KEY_MAP_SVC_RQ_ID);
        this.txnDate = (String) SessionMap.getValue(KEY_MAP_TXN_DATE);
        this.channelDirect = (String) SessionMap.getValue(KEY_MAP_CHANNEL_DIRECT);
        this.txnKey = (String) SessionMap.getValue(KEY_MAP_TXN_KEY);
    }

    public static HeaderRequest createAndValidate() {
        HeaderRequest header = new HeaderRequest();
        ValidatorFactory factory = Validation.buildDefaultValidatorFactory();
        Validator validator = factory.getValidator();
        Set<ConstraintViolation<HeaderRequest>> violations = validator.validate(header);
        if (!violations.isEmpty()) {
            throw new ConstraintViolationException(violations);
        }
        return header;
    }

    public String getTxnHeaderKey() {
        String txnHeaderKey = "";
        try {
            txnHeaderKey = channelId + svcCode + svcRqId + txnDate + userId + channelDirect;
            LOGGER.info("TxnHeader key: {}", txnHeaderKey);
        } catch (Exception e) {
            LOGGER.error("An exception occurred while creating txnBodyKey");
            LOGGER.info(String.valueOf(e));
        }
        return txnHeaderKey;
    }
}
