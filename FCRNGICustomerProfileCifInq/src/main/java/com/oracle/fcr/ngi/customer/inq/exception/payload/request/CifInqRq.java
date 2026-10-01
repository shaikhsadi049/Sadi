package com.oracle.fcr.ngi.customer.inq.exception.payload.request;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.Size;
import java.io.Serializable;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class CifInqRq implements Serializable {

    private static final long serialVersionUID = -5778710934010214902L;

    @NotBlank(message = "Account ID is mandatory")
    @Size(max = 20, message = "Invalid account ID Length")
    private String acctId;

    @NotBlank(message = "Account Type is mandatory")
    @Size(min = 1, max = 2, message = "Invalid acctType Length")
    private String acctType;

    @Override
    public String toString() {
        return "CifInqRq{" +
                "cifId=" + acctId +
                ", acctType=" + acctType +
                '}';
    }
}
