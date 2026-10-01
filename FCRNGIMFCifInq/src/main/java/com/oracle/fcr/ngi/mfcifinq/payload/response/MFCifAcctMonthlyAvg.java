package com.oracle.fcr.ngi.mfcifinq.payload.response;

import java.util.List;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class MFCifAcctMonthlyAvg {
	private String avgbalMonth;
	private String avgbalAmt;

}
