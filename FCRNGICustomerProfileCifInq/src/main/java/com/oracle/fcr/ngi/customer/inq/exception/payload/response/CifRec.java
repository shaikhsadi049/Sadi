package com.oracle.fcr.ngi.customer.inq.exception.payload.response;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;
import java.time.LocalDate;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class CifRec implements Serializable {

    public static final long serialVersionUID = 2112317068069443087L;

    private Long cifId;
    private String cifName;
    private String atmCardNo;
    private LocalDate cifDob; // DDMMYY
    private String cifGender; // F/M/O
    private String cifMotherName;
    private String emailAddr;
    private String mobileNo;
    private String address1;
    private String address2;
    private String address3;
    private String address4;
    private String address5;
    private String postCode;

    @Override
    public String toString() {
        return "CifRec{" +
                "cifId=" + cifId +
                ", cifName='" + cifName + '\'' +
                ", atmCardNo='" + atmCardNo + '\'' +
                ", cifDob='" + cifDob + '\'' +
                ", cifGender='" + cifGender + '\'' +
                ", cifMotherName='" + cifMotherName + '\'' +
                ", emailAddr='" + emailAddr + '\'' +
                ", mobileNo='" + mobileNo + '\'' +
                ", address1='" + address1 + '\'' +
                ", address2='" + address2 + '\'' +
                ", address3='" + address3 + '\'' +
                ", address4='" + address4 + '\'' +
                ", address5='" + address5 + '\'' +
                ", postCode='" + postCode + '\'' +
                '}';
    }
}
