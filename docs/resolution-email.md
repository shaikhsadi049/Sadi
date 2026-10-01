Subject: [RESOLVED] NGI FC_MF_CIFINQ - Update The Source for Passport Fields (ITRD MF_CIFINQ_Passport v1.0)

Hi Harsh,

I have resolved the issue for NGI FC_MF_CIFINQ raised by Bank Danamon. Please
find the resolution details and deployment prerequisites below.

| Category | Details |
|---|---|
| **Issue** | DBank PRO consumes `passportNo` and `passportExpiryDate` from the NGI FC_MF_CIFINQ service for SID opening. BDI reported both values as invalid and requested the data source for these response fields to be changed. Reference: ITRD NGI Service - MF_CIFINQ_Passport v.1.0. |
| **Analysis** | The root cause was in the database layer, in `FCR24.ap_ngi_ext_mf_cif_inq`. The inquiry cursor sourced `passportNo` from `ci_custdetl.REF_CUST_PSPT` and `passportExpiryDate` from `ci_custdetl.DAT_PSPT_EXPIRY`, neither of which the bank maintains. The cursor also returned no `icType` column at all, so the Java layer was mapping `icType` from `flg_replicate`, a replication flag unrelated to the identity card type. |
| **Fix Details** | Re-sourced the three fields inside the function as per the ITRD, applied to all six `var_pi_id_type` branches (99, 00, 30, 50, 90, 91):<br>• `icType` — new cursor column, from `UDF_CUST_LOG_DETAILS.FIELD_VALUE` where `COD_FIELD_TAG = 'TXT_696'`<br>• `passportNo` — from `CI_CUSTMAST.COD_CUST_NATL_ID`, only when `icType = 'PAS'`, otherwise NULL<br>• `passportExpiryDate` — from `UDF_CUST_LOG_DETAILS.FIELD_VALUE` where `COD_FIELD_TAG = 'TXT_762'`, only when `icType = 'PAS'`, otherwise NULL<br><br>`TXT_762` is free text, held as `YYYYMMDD`, `DDMMYYYY` and `DD/MM/YYYY`, so the value is rearranged to `YYYYMMDD` with `REGEXP_LIKE` and `SUBSTR` once the shape is confirmed. No `TO_DATE` is used, so no stored value can raise and none can be read under the wrong format; a value that is not a date returns NULL.<br><br>Java change is a single line in `MFCIFInqResWrapper`, reading `icType` from the new cursor column instead of `flg_replicate`. No new database object is created, and the remaining ~90 response fields are untouched. |
| **Testing Done** | Verified in UAT via Postman. CIF `1786984` (KTP) now returns `icType = "KTP"` with `passportNo` and `passportExpiryDate` as NULL, per the ITRD rule. Previously `icType` returned the replication flag `"N"`. The expiry date conversion was validated against every distinct `TXT_762` value present in the schema. |
| **Deployment Prerequisite** | **Crucial:** the function must be deployed **before** the JAR, as the JAR reads the new `icType` cursor column.<br><br>The UDF reads are scoped to `COD_TASK = 'CIM09'`. Verified in UAT that `TXT_696` and `TXT_762` exist only under `CIM09`, one row per customer. Please confirm the same holds in the target environment. |
| **Artifact Location** | DB script and updated JAR: `D:\OpenShift\FCRNGIMFCifInq\<date>\`<br>The pre-change version of the function is kept alongside as `ap_ngi_ext_mf_cif_inq_OLD.sql` for rollback. |
| **Rollback** | Run `ap_ngi_ext_mf_cif_inq_OLD.sql` and redeploy the backup JAR. Both must be rolled back together, as the old JAR expects the old cursor. |
| **Next Step** | Deployment to the UAT Linux environment, followed by end-to-end testing with DBank PRO. |
| **Impacted Units** | Service: FCRNGIMFCifInq<br>DB Function: `FCR24.ap_ngi_ext_mf_cif_inq`<br>Java Class: `MFCIFInqResWrapper` |
| **Open Point for BDI** | The only customer in the UAT schema with `icType = 'PAS'` is CIF `14508534`, whose `COD_CUST_NATL_ID` holds `5876567876545678` — sixteen digits, the shape of a NIK, whereas the ITRD sample is `AB1234567Z`. The mapping follows the ITRD exactly, but it has not been exercised against a realistic passport number. Request BDI to confirm this against production data before SIT sign off. |

Please let me know if any further detail is required.

Thanks & Regards,
Shaikh Sadi
