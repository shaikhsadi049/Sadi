package com.oracle.fcr.ngi.customer.inq.exception.payload.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class SubDetail implements Serializable {

    public static final long serialVersionUID = -4815651539830144772L;

    private String codTag;
    private String fieldValue;

}
