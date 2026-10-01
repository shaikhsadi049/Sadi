package com.oracle.fcr.ngi.customer.inq.exception.payload.response;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;
import java.util.List;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class AcctSummRs implements Serializable {

    public static final long serialVersionUID = 1170028198840167078L;

    @JsonProperty("recCtrOut")
    private RecCtrOut recCtrOut;

    @JsonProperty("fccAvail")
    private String fccAvail = "Y";

    @JsonProperty("eStatement")
    private EStatement estatement;

    @JsonProperty("acctRec")
    private List<AcctRec> acctRec;

}
