package com.oracle.fcr.ngi.mfcifinq.dbutil;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import com.oracle.fcr.ngi.mfcifinq.payload.response.MFCifInqResponse;
import com.oracle.fcr.ngi.mfcifinq.payload.response.MFCifJointHolders;
import com.oracle.fcr.ngi.mfcifinq.payload.response.MFCifAcctMonthlyAvg;
import com.oracle.fcr.ngi.mfcifinq.payload.response.MFCifInfoRes;
import com.oracle.fcr.ngi.mfcifinq.payload.response.MFCifInqAcctDet;

public class MFCIFInqAcctResWrapper {
	public static MFCifInqResponse mapToWrappeCifInqAcctRes(Map<String, Object> outValues, MFCifInqResponse res){
		List<MFCifInqAcctDet> cifList = (List<MFCifInqAcctDet>) outValues.get("VAR_O_INQ_RESULT");

		 // res.getCifInfo().get(0).setAcctList(cifList);;
		  List<MFCifInqAcctDet> cifRes =new ArrayList<MFCifInqAcctDet>();
			
			for (Object cifAcctData : cifList) {
			Map<String, Object> map = (Map<String, Object>) cifAcctData;
			MFCifInqAcctDet mFAcctDet=new MFCifInqAcctDet();
			mFAcctDet.setAcctHolderName((String)map.get("ACCTHOLDERNAME"));
			mFAcctDet.setAcctType((String.valueOf(map.get("ACCTTYPE"))));
			mFAcctDet.setAcctNo((String)map.get("ACCTNO"));
			mFAcctDet.setAcctOpenDate((String)map.get("ACCTOPENDATE"));
			mFAcctDet.setAcctBranchCode((String.valueOf(map.get("ACCTBRANCHCODE"))));
			mFAcctDet.setAcctBranchName((String)map.get("ACCTBRANCHNAME"));
			mFAcctDet.setAcctProductCode((String.valueOf(map.get("ACCTPRODUCTCODE"))));
			mFAcctDet.setAcctProductName((String)map.get("ACCTPRODUCTNAME"));
			mFAcctDet.setAcctCcyCode(String.valueOf(map.get("ACCTCCYCODE")));
			mFAcctDet.setAcctCcyName((String)map.get("ACCTCCYNAME"));
			mFAcctDet.setAcctJoinFlag((String)map.get("ACCTJOINFLAG"));
			mFAcctDet.setAcctAvailBalance(String.valueOf(map.get("ACCTAVAILBALANCE")).equals("null")?null:String.valueOf(map.get("ACCTAVAILBALANCE")));
			mFAcctDet.setAcctHoldBalance(String.valueOf(map.get("ACCTHOLDBALANCE")).equals("null")?null:String.valueOf(map.get("ACCTHOLDBALANCE")));
			mFAcctDet.setAcctCasaBalance(String.valueOf(map.get("ACCTCASABALANCE")).equals("null")?null:String.valueOf(map.get("ACCTCASABALANCE")));
			mFAcctDet.setAcctOsBalance(String.valueOf(map.get("ACCTOSBALANCE")).equals("null")?null:String.valueOf(map.get("ACCTOSBALANCE")));
			mFAcctDet.setAcctInstallmnt(String.valueOf(map.get("ACCTINSTALLMNT")).equals("null")?null:String.valueOf(map.get("ACCTINSTALLMNT")));
			mFAcctDet.setAcctMonthlyInstllmnt(String.valueOf(map.get("ACCTMONTHLYINSTLLMNT")).equals("null")?null:String.valueOf(map.get("ACCTMONTHLYINSTLLMNT")));
			mFAcctDet.setAcctDpd(String.valueOf(map.get("ACCTDPD")).equals("null")?null:String.valueOf(map.get("ACCTDPD")));
			mFAcctDet.setAcctTermLoan(String.valueOf(map.get("ACCTTERMLOAN")).equals("null")?null:String.valueOf(map.get("ACCTTERMLOAN")));
			mFAcctDet.setAcctDisbursed(String.valueOf(map.get("ACCTDISBURSED")).equals("null")?null:String.valueOf(map.get("ACCTDISBURSED")));
			mFAcctDet.setAcctRateLoan(String.valueOf(map.get("ACCTRATELOAN")).equals("null")?null:String.valueOf(map.get("ACCTRATELOAN")));
			mFAcctDet.setAcctPrincipalBal(String.valueOf(map.get("ACCTPRINCIPALBAL")).equals("null")?null:String.valueOf(map.get("ACCTPRINCIPALBAL")));
			mFAcctDet.setAcctMaturityDat((String)map.get("ACCTMATURITYDAT"));
			mFAcctDet.setAcctDepNo(String.valueOf(map.get("ACCTDEPNO")).equals("null")?null:String.valueOf(map.get("ACCTDEPNO")));
			mFAcctDet.setAcctStatus((String.valueOf(map.get("ACCTSTATUS"))));
			mFAcctDet.setAcctRealStatus(String.valueOf(map.get("ACCTREALSTATUS")));
			if(map.get("JOINCIF") != null && map.get("JOINHOLDERS")!=null && map.get("JOINRELATIONSHIP")!=null)
			  mFAcctDet.setJoinHoldRel(getAcctJoinHolders((String) map.get("JOINCIF"), (String)map.get("JOINHOLDERS"),(String)map.get("JOINRELATIONSHIP")));
			if(map.get("AVGBALMONTH")!= null && map.get("AVGBALAMT")!= null)
			  mFAcctDet.setAcctavgList(getAcctAvgAtmnt((String)map.get("AVGBALMONTH"),(String)map.get("AVGBALAMT")));			
			cifRes.add(mFAcctDet);
			
			}
			res.getCifInfo().get(0).setAcctList(cifRes);
		return res;
	}
	private static List<MFCifJointHolders> getAcctJoinHolders(String joinCifNo, String joinHolders, String joinRel) {
		List<MFCifJointHolders> stmnt= new ArrayList<MFCifJointHolders>();
		MFCifJointHolders jointHolders=null;
		String jCifNo[] = joinCifNo.split("\\|");
		String jHolds[]= joinHolders.split("\\|");
		String jRels[]=joinRel.split("\\|");
		for(int i =0;i<jCifNo.length;i++) {
			jointHolders=new MFCifJointHolders();
			jointHolders.setJoinCifNo(jCifNo[i]);
			jointHolders.setJoinHolders(jHolds[i]);
			jointHolders.setJoinRelationship(jRels[i]);
			stmnt.add(jointHolders);
		}
		return stmnt;
	}
	
	private static  List<MFCifAcctMonthlyAvg> getAcctAvgAtmnt(String avgBalMonth, String avgBalAmt) {
		
		List<MFCifAcctMonthlyAvg> stmnt= new ArrayList<MFCifAcctMonthlyAvg>();
		MFCifAcctMonthlyAvg avgamt=null;
		String balMonth[]= avgBalMonth.split("\\|");
		String balAmnt[]=avgBalAmt.split("\\|");
		for(int i=0;i<balMonth.length;i++) {
			avgamt=new MFCifAcctMonthlyAvg();
			avgamt.setAvgbalMonth(balMonth[i]);
			avgamt.setAvgbalAmt(balAmnt[i]);
			stmnt.add(avgamt);
		}
		return stmnt;
	}
}