package com.oracle.fcr.ngi.customer.inq.exception.payload.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class ReturnVOApILFCCCheck {
    private long returnValue;

    private String flgReplicate;

    private String errMsg;
}
