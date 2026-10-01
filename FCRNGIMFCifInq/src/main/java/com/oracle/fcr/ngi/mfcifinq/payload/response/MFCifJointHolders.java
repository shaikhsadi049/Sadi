package com.oracle.fcr.ngi.mfcifinq.payload.response;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class MFCifJointHolders {

    private String joinCifNo;
    private String joinHolders;
    private String joinRelationship;
}
