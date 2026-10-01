package com.oracle.fcr.ngi.mfcifinq.payload.response;

import java.util.List;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class MFCifInqAcctDet {
	private String acctHolderName;
	private String acctType;
	private String acctNo;
	private String acctOpenDate;
	private String acctBranchCode;
	private String acctBranchName;
	private String acctProductCode;
	private String acctProductName;
	private String acctCcyCode;
	private String acctCcyName;
	private String acctJoinFlag;
	private String acctAvailBalance;
	private String acctHoldBalance;
	private String acctCasaBalance;
	private String acctOsBalance;
	private String acctInstallmnt;
	private String acctMonthlyInstllmnt;
	private String acctDpd;
	private String acctTermLoan;
	private String acctDisbursed;
	private String acctRateLoan;
	private String acctPrincipalBal;
	private String acctMaturityDat;
	private String acctDepNo;
	private String acctStatus;
	private String acctRealStatus;
	private List<MFCifJointHolders> joinHoldRel;
	private List<MFCifAcctMonthlyAvg> acctavgList;
	
	
}
