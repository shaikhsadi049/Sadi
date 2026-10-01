package com.oracle.fcr.ngi.customer.inq.exception.payload.dto;

import com.oracle.fcr.ngi.customer.inq.exception.payload.response.AcctRec;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;
import java.util.List;
@Data
@AllArgsConstructor
@NoArgsConstructor
public class AccountPage implements Serializable {

    public static final long serialVersionUID = -4815651539830144772L;

    private List<AcctRec> listOfAccounts;
    private boolean isNextPageAvailable;

}
