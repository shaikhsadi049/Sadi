package com.oracle.fcr.ngi.customer.inq.exception.payload.response;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class EStatement implements Serializable {

    public static final long serialVersionUID = -3216374569148903106L;

    private String email;
    private String verCode;
    private String branchCode;

    @Override
    public String toString() {
        return "EStatement{" +
                "email='" + email + '\'' +
                ", verCode='" + verCode + '\'' +
                ", branchCode='" + branchCode + '\'' +
                '}';
    }
}
