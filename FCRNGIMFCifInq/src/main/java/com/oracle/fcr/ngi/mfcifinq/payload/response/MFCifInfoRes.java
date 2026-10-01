package com.oracle.fcr.ngi.mfcifinq.payload.response;

import java.util.List;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class MFCifInfoRes {
	
	private String customerNo;
	private String customerName;
	private String firstName;
	private String middleName;
	private String lastName;
	private String atmCardNo;
	private String customerDob;
	private String customerPob;
	private String customerGender;
	private String customerMothersMaiden;
	private String customerEmail;
	private String customerMobileNo;
	private String customerAddress1;
	private String customerAddress2;
	private String customerAddress3;
	private String customerAddress4;
	private String customerAddress5;
	private String customerAddress6;
	private String customerPostCode;
	private String customerPhoneCode;
	private String customerNatlId;
	private String customerTaxId;
	private String officeName;
	private String officeAddress1;
	private String officeAddress2;
	private String officeAddress3;
	private String officeAddress4;
	private String officeAddress5;
	private String officeAddress6;
	private String officePostCode;
	private String officePhoneCode;
	private String correspondentAddress1;
	private String correspondentAddress2;
	private String correspondentAddress3;
	private String correspondentAddress4;
	private String correspondentAddress5;
	private String correspondentAddress6;
	private String dhnCustNam;
	private String dhnCustAddress;
	private String dhnExpiryDat;
	private String multipleCif;
	private String customerShrtNam;
	private String officerId;
	private String customerSicCode;
	private String customerCrrCode;
	private String cifType;
	private String flgReplicate;
	private String icType;
	private String custType;
	private String citizenType;
	private String cifLob;
	private String passportNo;
	private String passportExpiryDate;
	private String isEmployee;
	private String employeeID;
	private String religion;
	private String customerResidence;
	private String customerFaxNo;
	private String incomeCategory;
	private String nameSignatory1;
	private String designationSignatory1;
	private String nameSignatory2;
	private String designationSignatory2;
	private String nameSignatory3;
	private String designationSignatory3;
	private String nameSignatory4;
	private String designationSignatory4;
	private String nameSignatory5;
	private String designationSignatory5;
	private String investmentRiskProfile;
	private String treasuryStructuredProduct;
	private String postalCode;
	private String telexNo;
	private String customerNationality;
	private String customerNationalityDesc;
	private String customerSalutation;
	private String customerCifBranchCode;
	private String customerAddress4Code;
	private String customerAddress5Code;
	private String maritalStatus;
	private String professionalDesc;
	private String education;
	private String officeAddress4Code;
	private String officeAddress5Code;
	private String correspondentAddress4Code;
	private String correspondentAddress5Code;
	private String rrm01PrivilegeFlag;
	private String rrm01PrivilegeCode;
	private String lobDesc;
	private String customerJobTitle;
	private List<MFCifInqAcctDet> acctList;
	
}
