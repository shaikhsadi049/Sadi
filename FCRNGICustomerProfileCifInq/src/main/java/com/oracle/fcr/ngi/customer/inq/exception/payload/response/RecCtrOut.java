package com.oracle.fcr.ngi.customer.inq.exception.payload.response;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class RecCtrOut implements Serializable {

    public static final long serialVersionUID = -6370686852482484736L;

    private int maxRec;
    private String nextRec;
    private String matchedRec;

    @Override
    public String toString() {
        return "RecCtrOut{" +
                "maxRec=" + maxRec +
                ", nextRec='" + nextRec + '\'' +
                ", matchedRec='" + matchedRec + '\'' +
                '}';
    }
}
