package com.oracle.fcr.ngi.customer.inq.exception.payload.response;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;
import java.math.BigDecimal;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class AcctRec implements Serializable {

    private static final long serialVersionUID = -3543016853116563773L;

    private String acctId;
    private String acctType;
    private String acctStatus;
    private int curCode;
    private String prodType;
    private BigDecimal balance1;
    private BigDecimal balance2;
    private BigDecimal balance3;
    private BigDecimal balance4;
    private String dueDate;
    private String atmCard;
    private String isStmnt;

    @Override
    public String toString() {
        return "AcctRec{" +
                "acctId=" + acctId +
                ", acctType=" + acctType +
                ", acctStatus=" + acctStatus +
                ", curCode=" + curCode +
                ", prodType='" + prodType + '\'' +
                ", balance1=" + balance1 +
                ", balance2=" + balance2 +
                ", balance3=" + balance3 +
                ", balance4=" + balance4 +
                ", dueDate='" + dueDate + '\'' +
                ", aTMCard='" + atmCard + '\'' +
                ", isStmnt='" + isStmnt + '\'' +
                '}';
    }
}
