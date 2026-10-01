package com.oracle.fcr.ngi.mfcifinq.dbutil;

import java.math.BigDecimal;
import java.util.Map;
import java.util.List;
import java.util.ArrayList;

import com.oracle.fcr.ngi.mfcifinq.payload.response.MFCifInfoRes;

public class MFCIFInqResWrapper {
	public static List<MFCifInfoRes> mapToWrapperCIFInqRes(Map<String, Object> outValues, String acctId,String typeId){
		
		MFCifInfoRes res=null;
		List<MFCifInfoRes> cifList = (List<MFCifInfoRes>) outValues.get("var_po_inq_result");
		List<MFCifInfoRes> cifRes =new ArrayList<MFCifInfoRes>();
		
		for (Object cifData : cifList) {
		Map<String, Object> map = (Map<String, Object>) cifData;
		 res=new MFCifInfoRes();
		res.setCustomerNo(String.valueOf(map.get("cod_cust_id")));
		res.setFirstName((String)map.get("nam_cust_first"));
		res.setMiddleName((String)map.get("nam_cust_mid"));
		res.setLastName((String)map.get("nam_cust_last"));
		res.setCustomerName((String)map.get("nam_cust_full"));
		res.setAtmCardNo((String)map.get("atmCardNo"));
		res.setCustomerDob((String)map.get("DOB"));
		res.setCustomerPob((String)map.get("POB"));
		res.setCustomerGender((String)map.get("gender"));
		res.setCustomerMothersMaiden((String)map.get("mother_name"));
		res.setCustomerEmail((String)map.get("email"));
		res.setCustomerMobileNo((String)map.get("mobile_no"));
		res.setCustomerAddress1((String)map.get("add_1"));
		res.setCustomerAddress2((String)map.get("add_2"));
		res.setCustomerAddress3((String)map.get("add_3"));
		res.setCustomerAddress4((String)map.get("city"));
		res.setCustomerAddress5((String)map.get("state"));
		res.setCustomerAddress6((String)map.get("country"));
		res.setCustomerPostCode((String)map.get("postal_code"));
		res.setCustomerPhoneCode((String)map.get("phone_no"));
		res.setCustomerNatlId((String)map.get("natl_id"));
		res.setCustomerTaxId((String)map.get("tax_id"));
		res.setOfficeName((String)map.get("office_name"));
		res.setOfficeAddress1((String)map.get("office_addr_1"));
		res.setOfficeAddress2((String)map.get("office_addr_2"));
		res.setOfficeAddress3((String)map.get("office_addr_3"));
		res.setOfficeAddress4((String)map.get("office_city"));
		res.setOfficeAddress5((String)map.get("office_state"));
		res.setOfficeAddress6((String)map.get("office_country"));
		res.setOfficePostCode((String)map.get("office_zip"));
		res.setOfficePhoneCode((String)map.get("office_phone"));
		res.setCorrespondentAddress1((String)map.get("mailing_addr_1"));
		res.setCorrespondentAddress2((String)map.get("mailing_addr_2"));
		res.setCorrespondentAddress3((String)map.get("mailing_addr_3"));
		res.setCorrespondentAddress4((String)map.get("mailing_addr_city"));
		res.setCorrespondentAddress5((String)map.get("mailing_addr_state"));
		res.setCorrespondentAddress6((String)map.get("mailing_addr_country"));
		res.setDhnCustNam((String)map.get("dhn_cust_name"));
		res.setDhnCustAddress((String)map.get("dhn_cust_address_1"));
		res.setDhnExpiryDat((String)map.get("dhn_expiry_date"));
		res.setMultipleCif((String)map.get("multiple_cif"));
		res.setCustomerShrtNam((String)map.get("customer_shortname"));
		res.setOfficerId((String)map.get("officer_id"));
		res.setCustomerSicCode((String)map.get("customer_sic_code"));
		res.setCustomerCrrCode(String.valueOf(map.get("cust_crr_code")).equals("null")?null:String.valueOf(map.get("cust_crr_code")));
		res.setCifType((String)map.get("flg_ic_typ"));
		res.setFlgReplicate((String)map.get("flg_replicate"));
		res.setIcType((String)map.get("ICTYPE"));
		res.setCustType((String)map.get("FLG_CUST_TYP"));
		res.setCitizenType((String)map.get("CITIZENTYPE"));
		res.setCifLob(String.valueOf(map.get("CIFLOB")));
		res.setPassportNo((String)map.get("PASSPORTNO"));
		res.setPassportExpiryDate((String)map.get("PASSPORTEXPIRYDATE"));
		res.setIsEmployee((String)map.get("ISEMPLOYEE"));
		res.setEmployeeID((String)map.get("EMPLOYEEID"));
		res.setReligion((String)map.get("RELIGION"));
		res.setCustomerResidence((String)map.get("CUSTOMERRESIDENCE"));
		res.setCustomerFaxNo((String)map.get("CUSTOMERFAXNO"));
		res.setIncomeCategory((String)map.get("INCOMECATEGORY"));
		res.setNameSignatory1((String)map.get("NAMESIGNATORY1"));
		res.setDesignationSignatory1((String)map.get("DESIGNATIONSIGNATORY1"));
		res.setNameSignatory2((String)map.get("NAMESIGNATORY2"));
		res.setDesignationSignatory2((String)map.get("DESIGNATIONSIGNATORY2"));
		res.setNameSignatory3((String)map.get("NAMESIGNATORY3"));
		res.setDesignationSignatory3((String)map.get("DESIGNATIONSIGNATORY3"));
		res.setNameSignatory4((String)map.get("NAMESIGNATORY4"));
		res.setDesignationSignatory4((String)map.get("DESIGNATIONSIGNATORY4"));
		res.setNameSignatory5((String)map.get("NAMESIGNATORY5"));
		res.setDesignationSignatory5((String)map.get("DESIGNATIONSIGNATORY5"));
		res.setInvestmentRiskProfile((String)map.get("INVESTMENTRISKPROFILE"));
		res.setTreasuryStructuredProduct((String)map.get("TREASURYSTRUCTUREDPRODUCT"));
		res.setPostalCode((String) map.get("POSTALCODE"));
		res.setTelexNo((String) map.get("TELEXNO"));
		res.setCustomerNationality((String) map.get("CUSTOMERNATIONALITY"));
		res.setCustomerNationalityDesc((String) map.get("CUSTOMERNATIONALITYDESC"));
		res.setCustomerSalutation((String) map.get("CUSTOMERSALUTATION"));
		res.setCustomerCifBranchCode(String.valueOf((map.get("CUSTOMERCIFBRANCHCODE")) ));
		res.setCustomerAddress4Code((String) map.get("CITY"));
		res.setCustomerAddress5Code((String) map.get("STATE"));
		res.setMaritalStatus(String.valueOf(map.get("MARITALSTATUS")));
		res.setProfessionalDesc((String) map.get("PROFESSIONALDESC"));
		res.setEducation((String) map.get("EDUCATION"));
		res.setOfficeAddress4Code((String) map.get("OFFICE_CITY"));
		res.setOfficeAddress5Code((String) map.get("OFFICE_STATE"));
		res.setCorrespondentAddress4Code((String) map.get("MAILING_ADDR_CITY"));
		res.setCorrespondentAddress5Code((String) map.get("MAILING_ADDR_STATE"));
		res.setRrm01PrivilegeFlag((String) map.get("RRM01PRIVILEGEFLAG"));
		res.setRrm01PrivilegeCode((String) map.get("RRM01PRIVILEGECODE"));
		res.setLobDesc((String) map.get("LOB_DESC"));
		res.setCustomerJobTitle((String) map.get("CUSTOMERJOBTITLE"));
		cifRes.add(res);
		}
		
		return cifRes;
	}

	
}
