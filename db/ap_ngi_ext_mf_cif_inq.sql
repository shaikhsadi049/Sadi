-- ============================================================================
-- ap_ngi_ext_mf_cif_inq - updated source for the passport response fields
-- ITRD NGI Service - MF_CIFINQ_Passport v.1.0
--
-- Applied to all six var_pi_id_type branches ('99','00','30','50','90','91'):
--
--   icType              new column, the cursor returned none, which is why the
--                       service was reading icType off flg_replicate.
--                       Now UDF_CUST_LOG_DETAILS.FIELD_VALUE, TXT_696.
--   passportNo          was ci_custdetl.REF_CUST_PSPT, now
--                       ci_custmast.COD_CUST_NATL_ID when icType = 'PAS',
--                       otherwise NULL.
--   passportExpiryDate  was ci_custdetl.DAT_PSPT_EXPIRY, now
--                       UDF_CUST_LOG_DETAILS.FIELD_VALUE, TXT_762, when
--                       icType = 'PAS', otherwise NULL.
--
-- TXT_762 is free text. The schema holds it as YYYYMMDD, as DDMMYYYY and as
-- DD/MM/YYYY, so it is rearranged to YYYYMMDD with SUBSTR after a REGEXP_LIKE
-- has confirmed the shape. No TO_DATE is used, so no value can raise and no
-- value can be read under the wrong format. A value that is not a date, such
-- as SEUMUR HDP, falls off the end of the CASE and returns NULL.
--
-- Every other column is untouched, and nothing else is created or dropped.
-- ============================================================================

CREATE OR REPLACE FUNCTION FCR24.ap_ngi_ext_mf_cif_inq(var_pi_trace_id      IN VARCHAR2,
                                                 var_pi_channel_id    IN VARCHAR2,
                                                 var_pi_serv_code     IN VARCHAR2,
                                                 var_pi_svc_rq_id     IN VARCHAR2,
                                                 var_pi_dat_txn       IN VARCHAR2,
                                                 var_pi_id            char,
                                                 var_pi_id_type       char,
                                                 var_po_response_code OUT VARCHAR2,
                                                 var_po_response_msg  OUT VARCHAR2,
                                                 var_po_inq_result    OUT sys_refcursor)
  RETURN NUMBER AS

  var_l_ret_code NUMBER;
BEGIN

  BEGIN
    var_l_ret_code := ap_val_dup_svc_req(var_pi_trace_id,
                                         var_pi_channel_id,
                                         var_pi_serv_code,
                                         var_pi_svc_rq_id,
                                         var_pi_dat_txn,
                                         var_po_response_code,
                                         var_po_response_msg);

    IF var_l_ret_code <> 0 THEN
      RETURN var_l_ret_code;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN var_l_ret_code;
  END;
  ------------------------------------------------------------------------------------------------------
  --debug_api_run(1416, 'AP_NGI_EXT_MF_CIF_ACCTINQ0' || SYSTIMESTAMP);
  IF (var_pi_id_type = '99') THEN
    OPEN var_po_inq_result FOR
      SELECT a.cod_cust_id,
             a.nam_cust_first,
             a.nam_cust_mid,
             a.nam_cust_last,
             a.nam_cust_full,
             (SELECT cod_card_no
                FROM cm_x_custcard_acct_xref
               WHERE cod_cust_id = TO_CHAR(a.cod_cust_id)
                 AND flg_link_unlink = 'L'
                 AND flg_mnt_status = 'A'
                 AND ROWNUM = 1) AS atmCardNo,
             TO_CHAR(a.dat_birth_cust, 'YYYYMMDD') AS DOB,
             (SELECT field_value
                FROM udf_cust_log_details
               WHERE cod_cust_id = TO_CHAR(a.cod_cust_id)
                 AND flg_mnt_status = 'A'
                 AND cod_field_tag = 'TXT_699'
                 AND cod_task = 'CIM09') AS POB,
             txt_cust_sex as gender,
             (SELECT field_value
                FROM udf_cust_log_details
               WHERE cod_cust_id = TO_CHAR(a.cod_cust_id)
                 AND flg_mnt_status = 'A'
                 AND cod_field_tag = 'TXT_691'
                 AND cod_task = 'CIM09') AS mother_name,
             a.ref_cust_email AS email,
             a.ref_phone_mobile AS mobile_no,
             a.txt_permadr_add1 AS add_1,
             a.txt_permadr_add2 AS add_2,
             a.txt_permadr_add3 AS add_3,
             a.nam_permadr_city AS city,
             a.nam_permadr_state AS state,
             a.nam_permadr_cntry AS country,
             a.txt_permadr_zip AS postal_code,
             a.ref_cust_phone AS phone_no,
             cod_cust_natl_id AS natl_id,
             a.ref_cust_it_num AS tax_id,
             x.nam_cust_emp AS office_name,
             x.txt_empadr_add1 AS office_addr_1,
             x.txt_empadr_add2 AS office_addr_2,
             x.txt_empadr_add3 AS office_addr_3,
             x.nam_empadr_city AS office_city,
             x.nam_empadr_state AS office_state,
             x.nam_empadr_cntry AS office_country,
             x.txt_empadr_zip AS office_zip,
             a.ref_office_phone_area || a.ref_cust_phone_off || ' ' ||
             a.ref_office_phone_extn AS office_phone,
             a.txt_custadr_add1 AS mailing_addr_1,
             a.txt_custadr_add2 AS mailing_addr_2,
             a.txt_custadr_add3 AS mailing_addr_3,
             a.nam_custadr_city AS mailing_addr_city,
             a.nam_custadr_state AS mailing_addr_state,
             a.nam_custadr_cntry AS mailing_addr_country,
             y.nam_cust_full AS dhn_cust_name,
             y.cust_add1 AS dhn_cust_address_1,
            to_char(y.dat_instr_exp,'YYYYMMDD') AS dhn_expiry_date,
             (CASE
               WHEN (SELECT count(1)
                       FROM ci_custmast ax
                      WHERE ax.cod_cust_natl_id = var_pi_id
                        AND ax.flg_mnt_status = 'A'
                      GROUP BY ax.cod_cust_natl_id
                     HAVING COUNT(1) > 1) > 0 THEN
                'Y'
               ELSE
                'N'
             END) AS multiple_cif,
             a.nam_cust_shrt AS customer_shortname,
             a.cod_officr_id AS officer_id,
             (SELECT NVL(field_value, '')
                FROM udf_cust_log_details
               WHERE cod_field_tag = 'TXT_700'
                 AND cod_cust_id = TO_CHAR(a.cod_cust_id)
                 AND flg_mnt_status = 'A') AS customer_sic_code,
             (SELECT DISTINCT cod_crr_cust
                FROM ac_acct_crr_code
               WHERE cod_cust_id = TO_CHAR(a.cod_cust_id)
                 AND flg_mnt_status = 'A') AS cust_crr_code,
             a.cif_type AS cif_type,
             NVL(a.flg_replicate, 'N') flg_replicate,
             (select txt_ic_typ
                from ci_ic_types
               where flg_ic_typ = a.flg_ic_typ
                 and flg_mnt_status = 'A') AS flg_ic_typ,
             (select txt_cust_typ
                from CI_CUST_TYPES
               where flg_cust_typ = a.flg_cust_typ
                 and flg_mnt_status = 'A') AS flg_cust_typ,
             (SELECT NVL(field_value, '')
                FROM udf_cust_log_details
               WHERE cod_field_tag = 'TXT_774'
                 AND cod_task = 'CIM09'
                 AND cod_cust_id = TO_CHAR(a.cod_cust_id)
                 AND flg_mnt_status = 'A') AS citizenType,
             pk_ba_lob_codes.get_custid_lob_code(a.cod_cust_id) AS cifLOB,
             (SELECT field_value
                FROM udf_cust_log_details
               WHERE cod_field_tag = 'TXT_696'
                 AND cod_task = 'CIM09'
                 AND cod_cust_id = TO_CHAR(a.cod_cust_id)
                 AND flg_mnt_status = 'A'
                 AND ROWNUM = 1) AS icType,
             CASE
               WHEN UPPER(TRIM((SELECT field_value
                                  FROM udf_cust_log_details
                                 WHERE cod_field_tag = 'TXT_696'
                                   AND cod_task = 'CIM09'
                                   AND cod_cust_id = TO_CHAR(a.cod_cust_id)
                                   AND flg_mnt_status = 'A'
                                   AND ROWNUM = 1))) = 'PAS' THEN
                TRIM(a.cod_cust_natl_id)
             END AS passportNo,
             CASE
               WHEN UPPER(TRIM((SELECT field_value
                                  FROM udf_cust_log_details
                                 WHERE cod_field_tag = 'TXT_696'
                                   AND cod_task = 'CIM09'
                                   AND cod_cust_id = TO_CHAR(a.cod_cust_id)
                                   AND flg_mnt_status = 'A'
                                   AND ROWNUM = 1))) = 'PAS' THEN
                (SELECT CASE
                          WHEN REGEXP_LIKE(TRIM(u.field_value),
                                           '^(19|20)[0-9]{2}(0[1-9]|1[0-2])(0[1-9]|[12][0-9]|3[01])$') THEN
                           TRIM(u.field_value)
                          WHEN REGEXP_LIKE(TRIM(u.field_value),
                                           '^(0[1-9]|[12][0-9]|3[01])(0[1-9]|1[0-2])(19|20)[0-9]{2}$') THEN
                           SUBSTR(TRIM(u.field_value), 5, 4) ||
                           SUBSTR(TRIM(u.field_value), 3, 2) ||
                           SUBSTR(TRIM(u.field_value), 1, 2)
                          WHEN REGEXP_LIKE(TRIM(u.field_value),
                                           '^[0-9]{1,2}/[0-9]{1,2}/(19|20)[0-9]{2}$') THEN
                           SUBSTR(TRIM(u.field_value), -4) ||
                           LPAD(REGEXP_SUBSTR(TRIM(u.field_value), '[^/]+', 1, 2), 2, '0') ||
                           LPAD(REGEXP_SUBSTR(TRIM(u.field_value), '[^/]+', 1, 1), 2, '0')
                        END
                   FROM udf_cust_log_details u
                  WHERE u.cod_field_tag = 'TXT_762'
                    AND u.cod_task = 'CIM09'
                    AND u.cod_cust_id = TO_CHAR(a.cod_cust_id)
                    AND u.flg_mnt_status = 'A'
                    AND ROWNUM = 1)
             END AS passportExpiryDate,
             a.flg_staff AS isEmployee,
             a.cod_employee_id AS employeeID,
             a.txt_ethnic_origin AS religion,
             a.txt_cust_residence AS customerResidence,
             a.Ref_Cust_Fax AS customerFaxNo,
             (SELECT NVL(field_value, '')
                FROM udf_cust_log_details
               WHERE cod_field_tag = 'TXT_759'
                 AND cod_task = 'CIM09'
                 AND cod_cust_id = TO_CHAR(a.cod_cust_id)
                 AND flg_mnt_status = 'A') AS incomeCategory,
             a.nam_signatory1 AS nameSignatory1,
             a.txt_desgn_signtry1 AS designationSignatory1,
             a.nam_signatory2 AS nameSignatory2,
             a.txt_desgn_signtry2 AS designationSignatory2,
             a.nam_signatory3 AS nameSignatory3,
             a.txt_desgn_signtry3 AS designationSignatory3,
             a.nam_signatory4 AS nameSignatory4,
             a.txt_desgn_signtry4 AS designationSignatory4,
             a.nam_signatory5 AS nameSignatory5,
             a.txt_desgn_signtry5 AS designationSignatory5,
             (SELECT NVL(field_value, '')
                FROM udf_cust_log_details
               WHERE cod_field_tag = 'TXT_773'
                 AND cod_task = 'CIM09'
                 AND cod_cust_id = TO_CHAR(a.cod_cust_id)
                 AND flg_mnt_status = 'A') AS investmentRiskProfile,
             (SELECT NVL(field_value, '')
                FROM udf_cust_log_details
               WHERE cod_field_tag = 'TXT_728'
                 AND cod_task = 'CIM09'
                 AND cod_cust_id = TO_CHAR(a.cod_cust_id)
                 AND flg_mnt_status = 'A') AS treasuryStructuredProduct,
             a.txt_custadr_zip AS postalCode,
             a.ref_cust_telex AS telexNo,
             a.txt_cust_natnlty AS customerNationality,
             (SELECT description
                FROM ba_ifst_country
               WHERE country_code = a.txt_cust_natnlty
                 AND flg_mnt_status = 'A') AS customerNationalityDesc,
             a.txt_cust_prefix AS customerSalutation,
             a.cod_cc_homebrn AS customercifBranchCode,
             a.cod_cust_marstat AS maritalStatus,
             (SELECT txt_profession
                FROM ci_prof_codes
               WHERE txt_profess_cat = a.txt_profess_cat
                 AND flg_mnt_status = 'A') AS professionalDesc,
             a.txt_cust_educn AS education,
             (CASE
               WHEN (SELECT count(1)
                       FROM udf_mnt_log_details
                      WHERE ref_udf_no IN
                            (SELECT ref_udf_no
                               FROM rr_cust_service_bdi
                              WHERE cod_id = CAST(a.cod_cust_id AS CHAR(16))
                                AND flg_mnt_status = 'A')
                        AND cod_field_tag = 'TXT_869'
                        AND flg_mnt_status = 'A') > 0 THEN
                'Y'
               ELSE
                'N'
             END) AS rrm01PrivilegeFlag,
             (SELECT field_value
                FROM udf_mnt_log_details
               WHERE ref_udf_no IN
                     (SELECT ref_udf_no
                        FROM rr_cust_service_bdi
                       WHERE cod_id = CAST(a.cod_cust_id AS CHAR(16))
                         AND flg_mnt_status = 'A')
                 AND cod_field_tag = 'TXT_869'
                 AND flg_mnt_status = 'A') AS rrm01PrivilegeCode,
             (SELECT nam_lob
                FROM ba_lob_mast
               WHERE COD_LOB =
                     pk_ba_lob_codes.get_custid_lob_code(a.cod_cust_id)) AS lob_desc,
             a.txt_cust_desgn AS customerJobTitle
        FROM ci_custmast a
        LEFT JOIN ci_custdetl x ON a.cod_cust_id = x.cod_cust_id
        LEFT JOIN st_dhn_ext_unmatched_cust y ON a.cod_cust_natl_id =
                                                 y.cust_natl_id
                                             AND A.dat_birth_cust =
                                                 y.dat_birth_cust
       wHERE cod_cust_natl_id = var_pi_id
         AND a.flg_mnt_status = 'A'
       ORDER BY a.dat_cust_open DESC;
  ELSIF (var_pi_id_type = '00') THEN
    OPEN var_po_inq_result for
      SELECT a.cod_cust_id,
             a.nam_cust_first,
             a.nam_cust_mid,
             a.nam_cust_last,
             a.nam_cust_full,
             (SELECT cod_card_no
                FROM cm_x_custcard_acct_xref
               WHERE cod_cust_id = TO_CHAR(a.cod_cust_id)
                 AND flg_link_unlink = 'L'
                 AND flg_mnt_status = 'A'
                 AND ROWNUM = 1) AS atmCardNo,
             TO_CHAR(a.dat_birth_cust, 'YYYYMMDD') AS DOB,
             (SELECT field_value
                FROM udf_cust_log_details
               WHERE cod_cust_id = TO_CHAR(a.cod_cust_id)
                 AND flg_mnt_status = 'A'
                 AND cod_field_tag = 'TXT_699'
                 AND cod_task = 'CIM09') AS POB,
             txt_cust_sex AS gender,
             (SELECT field_value
                FROM udf_cust_log_details
               WHERE cod_cust_id = to_char(a.cod_cust_id)
                 AND flg_mnt_status = 'A'
                 AND cod_field_tag = 'TXT_691'
                 AND cod_task = 'CIM09') AS mother_name,
             a.ref_cust_email AS email,
             a.ref_phone_mobile AS mobile_no,
             a.txt_permadr_add1 AS add_1,
             a.txt_permadr_add2 AS add_2,
             a.txt_permadr_add3 AS add_3,
             a.nam_permadr_city AS city,
             a.nam_permadr_state AS state,
             a.nam_permadr_cntry AS country,
             a.txt_permadr_zip AS postal_code,
             ref_cust_phone AS phone_no,
             cod_cust_natl_id AS natl_id,
             a.ref_cust_it_num AS tax_id,
             x.nam_cust_emp AS office_name,
             x.txt_empadr_add1 AS office_addr_1,
             x.txt_empadr_add2 AS office_addr_2,
             x.txt_empadr_add3 AS office_addr_3,
             x.nam_empadr_city AS office_city,
             x.nam_empadr_state AS office_state,
             x.nam_empadr_cntry AS office_country,
             x.txt_empadr_zip AS office_zip,
             --a.ref_office_phone_area || ' ' || a.ref_office_phone_extn as office_phone,
             a.ref_office_phone_area || a.ref_cust_phone_off || ' ' ||
             a.ref_office_phone_extn AS office_phone,
             a.txt_custadr_add1 AS mailing_addr_1,
             a.txt_custadr_add2 AS mailing_addr_2,
             a.txt_custadr_add3 AS mailing_addr_3,
             a.nam_custadr_city AS mailing_addr_city,
             a.nam_custadr_state AS mailing_addr_state,
             a.nam_custadr_cntry AS mailing_addr_country,
             y.nam_cust_full AS dhn_cust_name,
             y.cust_add1 AS dhn_cust_address_1,
            to_char( y.dat_instr_exp,'YYYYMMDD') AS dhn_expiry_date,
             'N' AS multiple_cif,
             a.nam_cust_shrt AS customer_shortname,
             a.cod_officr_id AS officer_id,
             (SELECT NVL(field_value, '')
                FROM udf_cust_log_details
               WHERE cod_field_tag = 'TXT_700'
                 AND cod_cust_id = TO_CHAR(a.cod_cust_id)
                 AND flg_mnt_status = 'A') AS customer_sic_code,
             (SELECT DISTINCT cod_crr_cust
                FROM ac_acct_crr_code
               WHERE cod_cust_id = TO_CHAR(a.cod_cust_id)
                 AND flg_mnt_status = 'A') AS cust_crr_code,
             a.cif_type AS cif_type,
             NVL(a.flg_replicate, 'N') flg_replicate,
             (select txt_ic_typ
                from ci_ic_types
               where flg_ic_typ = a.flg_ic_typ
                 and flg_mnt_status = 'A') AS flg_ic_typ,
             (select txt_cust_typ
                from CI_CUST_TYPES
               where flg_cust_typ = a.flg_cust_typ
                 and flg_mnt_status = 'A') AS flg_cust_typ,
             (SELECT NVL(field_value, '')
                FROM udf_cust_log_details
               WHERE cod_field_tag = 'TXT_774'
                 AND cod_task = 'CIM09'
                 AND cod_cust_id = TO_CHAR(a.cod_cust_id)
                 AND flg_mnt_status = 'A') AS citizenType,
             pk_ba_lob_codes.get_custid_lob_code(a.cod_cust_id) AS cifLOB,
             (SELECT field_value
                FROM udf_cust_log_details
               WHERE cod_field_tag = 'TXT_696'
                 AND cod_task = 'CIM09'
                 AND cod_cust_id = TO_CHAR(a.cod_cust_id)
                 AND flg_mnt_status = 'A'
                 AND ROWNUM = 1) AS icType,
             CASE
               WHEN UPPER(TRIM((SELECT field_value
                                  FROM udf_cust_log_details
                                 WHERE cod_field_tag = 'TXT_696'
                                   AND cod_task = 'CIM09'
                                   AND cod_cust_id = TO_CHAR(a.cod_cust_id)
                                   AND flg_mnt_status = 'A'
                                   AND ROWNUM = 1))) = 'PAS' THEN
                TRIM(a.cod_cust_natl_id)
             END AS passportNo,
             CASE
               WHEN UPPER(TRIM((SELECT field_value
                                  FROM udf_cust_log_details
                                 WHERE cod_field_tag = 'TXT_696'
                                   AND cod_task = 'CIM09'
                                   AND cod_cust_id = TO_CHAR(a.cod_cust_id)
                                   AND flg_mnt_status = 'A'
                                   AND ROWNUM = 1))) = 'PAS' THEN
                (SELECT CASE
                          WHEN REGEXP_LIKE(TRIM(u.field_value),
                                           '^(19|20)[0-9]{2}(0[1-9]|1[0-2])(0[1-9]|[12][0-9]|3[01])$') THEN
                           TRIM(u.field_value)
                          WHEN REGEXP_LIKE(TRIM(u.field_value),
                                           '^(0[1-9]|[12][0-9]|3[01])(0[1-9]|1[0-2])(19|20)[0-9]{2}$') THEN
                           SUBSTR(TRIM(u.field_value), 5, 4) ||
                           SUBSTR(TRIM(u.field_value), 3, 2) ||
                           SUBSTR(TRIM(u.field_value), 1, 2)
                          WHEN REGEXP_LIKE(TRIM(u.field_value),
                                           '^[0-9]{1,2}/[0-9]{1,2}/(19|20)[0-9]{2}$') THEN
                           SUBSTR(TRIM(u.field_value), -4) ||
                           LPAD(REGEXP_SUBSTR(TRIM(u.field_value), '[^/]+', 1, 2), 2, '0') ||
                           LPAD(REGEXP_SUBSTR(TRIM(u.field_value), '[^/]+', 1, 1), 2, '0')
                        END
                   FROM udf_cust_log_details u
                  WHERE u.cod_field_tag = 'TXT_762'
                    AND u.cod_task = 'CIM09'
                    AND u.cod_cust_id = TO_CHAR(a.cod_cust_id)
                    AND u.flg_mnt_status = 'A'
                    AND ROWNUM = 1)
             END AS passportExpiryDate,
             a.flg_staff AS isEmployee,
             a.cod_employee_id AS employeeID,
             a.txt_ethnic_origin AS religion,
             a.txt_cust_residence AS customerResidence,
             a.Ref_Cust_Fax AS customerFaxNo,
             (SELECT NVL(field_value, '')
                FROM udf_cust_log_details
               WHERE cod_field_tag = 'TXT_759'
                 AND cod_task = 'CIM09'
                 AND cod_cust_id = TO_CHAR(a.cod_cust_id)
                 AND flg_mnt_status = 'A') AS incomeCategory,
             a.nam_signatory1 AS nameSignatory1,
             a.txt_desgn_signtry1 AS designationSignatory1,
             a.nam_signatory2 AS nameSignatory2,
             a.txt_desgn_signtry2 AS designationSignatory2,
             a.nam_signatory3 AS nameSignatory3,
             a.txt_desgn_signtry3 AS designationSignatory3,
             a.nam_signatory4 AS nameSignatory4,
             a.txt_desgn_signtry4 AS designationSignatory4,
             a.nam_signatory5 AS nameSignatory5,
             a.txt_desgn_signtry5 AS designationSignatory5,
             (SELECT NVL(field_value, '')
                FROM udf_cust_log_details
               WHERE cod_field_tag = 'TXT_773'
                 AND cod_task = 'CIM09'
                 AND cod_cust_id = TO_CHAR(a.cod_cust_id)
                 AND flg_mnt_status = 'A') AS investmentRiskProfile,
             (SELECT NVL(field_value, '')
                FROM udf_cust_log_details
               WHERE cod_field_tag = 'TXT_728'
                 AND cod_task = 'CIM09'
                 AND cod_cust_id = TO_CHAR(a.cod_cust_id)
                 AND flg_mnt_status = 'A') AS treasuryStructuredProduct,
             a.txt_custadr_zip AS postalCode,
             a.ref_cust_telex AS telexNo,
             a.txt_cust_natnlty AS customerNationality,
             (SELECT description
                FROM ba_ifst_country
               WHERE country_code = a.txt_cust_natnlty
                 AND flg_mnt_status = 'A') AS customerNationalityDesc,
             a.txt_cust_prefix AS customerSalutation,
             a.cod_cc_homebrn AS customercifBranchCode,
             a.cod_cust_marstat AS maritalStatus,
             (SELECT txt_profession
                FROM ci_prof_codes
               WHERE txt_profess_cat = a.txt_profess_cat
                 AND flg_mnt_status = 'A') AS professionalDesc,
             a.txt_cust_educn AS education,
             (CASE
               WHEN (SELECT count(1)
                       FROM udf_mnt_log_details
                      WHERE ref_udf_no IN
                            (SELECT ref_udf_no
                               FROM rr_cust_service_bdi
                              WHERE cod_id = CAST(a.cod_cust_id AS CHAR(16))
                                AND flg_mnt_status = 'A')
                        AND cod_field_tag = 'TXT_869'
                        AND flg_mnt_status = 'A') > 0 THEN
                'Y'
               ELSE
                'N'
             END) AS rrm01PrivilegeFlag,
             (SELECT field_value
                FROM udf_mnt_log_details
               WHERE ref_udf_no IN
                     (SELECT ref_udf_no
                        FROM rr_cust_service_bdi
                       WHERE cod_id = CAST(a.cod_cust_id AS CHAR(16))
                         AND flg_mnt_status = 'A')
                 AND cod_field_tag = 'TXT_869'
                 AND flg_mnt_status = 'A') AS rrm01PrivilegeCode,
             (SELECT nam_lob
                FROM ba_lob_mast
               WHERE COD_LOB =
                     pk_ba_lob_codes.get_custid_lob_code(a.cod_cust_id)) AS lob_desc,
             a.txt_cust_desgn AS customerJobTitle
        FROM ci_custmast a
        LEFT JOIN ci_custdetl x ON a.cod_cust_id = x.cod_cust_id
        LEFT JOIN st_dhn_ext_unmatched_cust y ON A.cod_cust_natl_id =
                                                 y.cust_natl_id
                                             AND A.dat_birth_cust =
                                                 y.dat_birth_cust
       WHERE EXISTS (SELECT 1
                FROM ch_acct_mast b
               WHERE b.cod_cust = a.cod_cust_id
                 AND b.flg_mnt_status = 'A'
                 AND b.cod_acct_no = var_pi_id);
  ELSIF (var_pi_id_type = '30') THEN
    OPEN var_po_inq_result FOR
      SELECT a.cod_cust_id,
             a.nam_cust_first,
             a.nam_cust_mid,
             a.nam_cust_last,
             a.nam_cust_full,
             (SELECT cod_card_no
                FROM cm_x_custcard_acct_xref
               WHERE cod_cust_id = TO_CHAR(a.cod_cust_id)
                 AND flg_link_unlink = 'L'
                 AND flg_mnt_status = 'A'
                 AND ROWNUM = 1) AS atmCardNo,
             TO_CHAR(a.dat_birth_cust, 'YYYYMMDD') AS DOB,
             (SELECT field_value
                FROM udf_cust_log_details
               WHERE cod_cust_id = TO_CHAR(a.cod_cust_id)
                 AND flg_mnt_status = 'A'
                 AND cod_field_tag = 'TXT_699'
                 AND cod_task = 'CIM09') AS POB,
             txt_cust_sex AS gender,
             (SELECT field_value
                FROM udf_cust_log_details
               WHERE cod_cust_id = TO_CHAR(a.cod_cust_id)
                 AND flg_mnt_status = 'A'
                 AND cod_field_tag = 'TXT_691'
                 AND cod_task = 'CIM09') AS mother_name,
             a.ref_cust_email AS email,
             a.ref_phone_mobile AS mobile_no,
             a.txt_permadr_add1 AS add_1,
             a.txt_permadr_add2 AS add_2,
             a.txt_permadr_add3 AS add_3,
             a.nam_permadr_city AS city,
             a.nam_permadr_state AS state,
             a.nam_permadr_cntry AS country,
             a.txt_permadr_zip AS postal_code,
             ref_cust_phone AS phone_no,
             cod_cust_natl_id AS natl_id,
             a.ref_cust_it_num AS tax_id,
             x.nam_cust_emp AS office_name,
             x.txt_empadr_add1 AS office_addr_1,
             x.txt_empadr_add2 AS office_addr_2,
             x.txt_empadr_add3 AS office_addr_3,
             x.nam_empadr_city AS office_city,
             x.nam_empadr_state AS office_state,
             x.nam_empadr_cntry AS office_country,
             x.txt_empadr_zip AS office_zip,
             -- a.ref_office_phone_area || ' ' || a.ref_office_phone_extn as office_phone,
             a.ref_office_phone_area || a.ref_cust_phone_off || ' ' ||
             a.ref_office_phone_extn AS office_phone,
             a.txt_custadr_add1 AS mailing_addr_1,
             a.txt_custadr_add2 AS mailing_addr_2,
             a.txt_custadr_add3 AS mailing_addr_3,
             a.nam_custadr_city AS mailing_addr_city,
             a.nam_custadr_state AS mailing_addr_state,
             a.nam_custadr_cntry AS mailing_addr_country,
             y.nam_cust_full AS dhn_cust_name,
             y.cust_add1 AS dhn_cust_address_1,
            TO_CHAR(y.dat_instr_exp,'YYYYMMDD') AS dhn_expiry_date,
             'N' AS multiple_cif,
             a.nam_cust_shrt AS customer_shortname,
             a.cod_officr_id AS officer_id,
             (SELECT NVL(FIELD_VALUE, '')
                FROM udf_cust_log_details
               WHERE cod_field_tag = 'TXT_700'
                 AND cod_cust_id = TO_CHAR(a.cod_cust_id)
                 AND flg_mnt_status = 'A') AS customer_sic_code,
             (SELECT DISTINCT cod_crr_cust
                FROM ac_acct_crr_code
               WHERE cod_cust_id = TO_CHAR(a.cod_cust_id)
                 AND flg_mnt_status = 'A') AS cust_crr_code,
             a.cif_type AS cif_type,
             NVL(a.flg_replicate, 'N') flg_replicate,
             (select txt_ic_typ
                from ci_ic_types
               where flg_ic_typ = a.flg_ic_typ
                 and flg_mnt_status = 'A') AS flg_ic_typ,
             (select txt_cust_typ
                from CI_CUST_TYPES
               where flg_cust_typ = a.flg_cust_typ
                 and flg_mnt_status = 'A') AS flg_cust_typ,
             (SELECT NVL(field_value, '')
                FROM udf_cust_log_details
               WHERE cod_field_tag = 'TXT_774'
                 AND cod_task = 'CIM09'
                 AND cod_cust_id = TO_CHAR(a.cod_cust_id)
                 AND flg_mnt_status = 'A') AS citizenType,
             pk_ba_lob_codes.get_custid_lob_code(a.cod_cust_id) AS cifLOB,
             (SELECT field_value
                FROM udf_cust_log_details
               WHERE cod_field_tag = 'TXT_696'
                 AND cod_task = 'CIM09'
                 AND cod_cust_id = TO_CHAR(a.cod_cust_id)
                 AND flg_mnt_status = 'A'
                 AND ROWNUM = 1) AS icType,
             CASE
               WHEN UPPER(TRIM((SELECT field_value
                                  FROM udf_cust_log_details
                                 WHERE cod_field_tag = 'TXT_696'
                                   AND cod_task = 'CIM09'
                                   AND cod_cust_id = TO_CHAR(a.cod_cust_id)
                                   AND flg_mnt_status = 'A'
                                   AND ROWNUM = 1))) = 'PAS' THEN
                TRIM(a.cod_cust_natl_id)
             END AS passportNo,
             CASE
               WHEN UPPER(TRIM((SELECT field_value
                                  FROM udf_cust_log_details
                                 WHERE cod_field_tag = 'TXT_696'
                                   AND cod_task = 'CIM09'
                                   AND cod_cust_id = TO_CHAR(a.cod_cust_id)
                                   AND flg_mnt_status = 'A'
                                   AND ROWNUM = 1))) = 'PAS' THEN
                (SELECT CASE
                          WHEN REGEXP_LIKE(TRIM(u.field_value),
                                           '^(19|20)[0-9]{2}(0[1-9]|1[0-2])(0[1-9]|[12][0-9]|3[01])$') THEN
                           TRIM(u.field_value)
                          WHEN REGEXP_LIKE(TRIM(u.field_value),
                                           '^(0[1-9]|[12][0-9]|3[01])(0[1-9]|1[0-2])(19|20)[0-9]{2}$') THEN
                           SUBSTR(TRIM(u.field_value), 5, 4) ||
                           SUBSTR(TRIM(u.field_value), 3, 2) ||
                           SUBSTR(TRIM(u.field_value), 1, 2)
                          WHEN REGEXP_LIKE(TRIM(u.field_value),
                                           '^[0-9]{1,2}/[0-9]{1,2}/(19|20)[0-9]{2}$') THEN
                           SUBSTR(TRIM(u.field_value), -4) ||
                           LPAD(REGEXP_SUBSTR(TRIM(u.field_value), '[^/]+', 1, 2), 2, '0') ||
                           LPAD(REGEXP_SUBSTR(TRIM(u.field_value), '[^/]+', 1, 1), 2, '0')
                        END
                   FROM udf_cust_log_details u
                  WHERE u.cod_field_tag = 'TXT_762'
                    AND u.cod_task = 'CIM09'
                    AND u.cod_cust_id = TO_CHAR(a.cod_cust_id)
                    AND u.flg_mnt_status = 'A'
                    AND ROWNUM = 1)
             END AS passportExpiryDate,
             a.flg_staff AS isEmployee,
             a.cod_employee_id AS employeeID,
             a.txt_ethnic_origin AS religion,
             a.txt_cust_residence AS customerResidence,
             a.Ref_Cust_Fax AS customerFaxNo,
             (SELECT NVL(field_value, '')
                FROM udf_cust_log_details
               WHERE cod_field_tag = 'TXT_759'
                 AND cod_task = 'CIM09'
                 AND cod_cust_id = TO_CHAR(a.cod_cust_id)
                 AND flg_mnt_status = 'A') AS incomeCategory,
             a.nam_signatory1 AS nameSignatory1,
             a.txt_desgn_signtry1 AS designationSignatory1,
             a.nam_signatory2 AS nameSignatory2,
             a.txt_desgn_signtry2 AS designationSignatory2,
             a.nam_signatory3 AS nameSignatory3,
             a.txt_desgn_signtry3 AS designationSignatory3,
             a.nam_signatory4 AS nameSignatory4,
             a.txt_desgn_signtry4 AS designationSignatory4,
             a.nam_signatory5 AS nameSignatory5,
             a.txt_desgn_signtry5 AS designationSignatory5,
             (SELECT NVL(field_value, '')
                FROM udf_cust_log_details
               WHERE cod_field_tag = 'TXT_773'
                 AND cod_task = 'CIM09'
                 AND cod_cust_id = TO_CHAR(a.cod_cust_id)
                 AND flg_mnt_status = 'A') AS investmentRiskProfile,
             (SELECT NVL(field_value, '')
                FROM udf_cust_log_details
               WHERE cod_field_tag = 'TXT_728'
                 AND cod_task = 'CIM09'
                 AND cod_cust_id = TO_CHAR(a.cod_cust_id)
                 AND flg_mnt_status = 'A') AS treasuryStructuredProduct,
             a.txt_custadr_zip AS postalCode,
             a.ref_cust_telex AS telexNo,
             a.txt_cust_natnlty AS customerNationality,
             (SELECT description
                FROM ba_ifst_country
               WHERE country_code = a.txt_cust_natnlty
                 AND flg_mnt_status = 'A') AS customerNationalityDesc,
             a.txt_cust_prefix AS customerSalutation,
             a.cod_cc_homebrn AS customercifBranchCode,
             a.cod_cust_marstat AS maritalStatus,
             (SELECT txt_profession
                FROM ci_prof_codes
               WHERE txt_profess_cat = a.txt_profess_cat
                 AND flg_mnt_status = 'A') AS professionalDesc,
             a.txt_cust_educn AS education,
             (CASE
               WHEN (SELECT count(1)
                       FROM udf_mnt_log_details
                      WHERE ref_udf_no IN
                            (SELECT ref_udf_no
                               FROM rr_cust_service_bdi
                              WHERE cod_id = CAST(a.cod_cust_id AS CHAR(16))
                                AND flg_mnt_status = 'A')
                        AND cod_field_tag = 'TXT_869'
                        AND flg_mnt_status = 'A') > 0 THEN
                'Y'
               ELSE
                'N'
             END) AS rrm01PrivilegeFlag,
             (SELECT field_value
                FROM udf_mnt_log_details
               WHERE ref_udf_no IN
                     (SELECT ref_udf_no
                        FROM rr_cust_service_bdi
                       WHERE cod_id = CAST(a.cod_cust_id AS CHAR(16))
                         AND flg_mnt_status = 'A')
                 AND cod_field_tag = 'TXT_869'
                 AND flg_mnt_status = 'A') AS rrm01PrivilegeCode,
             (SELECT nam_lob
                FROM ba_lob_mast
               WHERE COD_LOB =
                     pk_ba_lob_codes.get_custid_lob_code(a.cod_cust_id)) AS lob_desc,
             a.txt_cust_desgn AS customerJobTitle
        FROM ci_custmast a
        LEFT JOIN ci_custdetl x ON a.cod_cust_id = x.cod_cust_id
        LEFT JOIN st_dhn_ext_unmatched_cust y ON A.cod_cust_natl_id =
                                                 y.cust_natl_id
                                             AND A.dat_birth_cust =
                                                 y.dat_birth_cust
       WHERE EXISTS (SELECT 1
                FROM td_acct_mast b
               WHERE b.cod_cust = a.cod_cust_id
                 AND flg_mnt_status = 'A'
                 AND b.cod_acct_stat = 8
                 AND b.cod_acct_no = var_pi_id);
  ELSIF (var_pi_id_type = '50') THEN
    OPEN var_po_inq_result FOR
      SELECT a.cod_cust_id,
             a.nam_cust_first,
             a.nam_cust_mid,
             a.nam_cust_last,
             a.nam_cust_full,
             (SELECT cod_card_no
                FROM cm_x_custcard_acct_xref
               WHERE cod_cust_id = TO_CHAR(a.cod_cust_id)
                 AND flg_link_unlink = 'L'
                 AND flg_mnt_status = 'A'
                 AND ROWNUM = 1) AS atmCardNo,
             TO_CHAR(a.dat_birth_cust, 'YYYYMMDD') AS DOB,
             (SELECT field_value
                FROM udf_cust_log_details
               WHERE cod_cust_id = TO_CHAR(a.cod_cust_id)
                 AND flg_mnt_status = 'A'
                 AND cod_field_tag = 'TXT_699'
                 AND cod_task = 'CIM09') AS POB,
             txt_cust_sex AS gender,
             (SELECT field_value
                FROM udf_cust_log_details
               WHERE cod_cust_id = TO_CHAR(a.cod_cust_id)
                 AND flg_mnt_status = 'A'
                 AND cod_field_tag = 'TXT_691'
                 AND cod_task = 'CIM09') AS mother_name,
             a.ref_cust_email AS email,
             a.ref_phone_mobile AS mobile_no,
             a.txt_permadr_add1 AS add_1,
             a.txt_permadr_add2 AS add_2,
             a.txt_permadr_add3 AS add_3,
             a.nam_permadr_city AS city,
             a.nam_permadr_state AS state,
             a.nam_permadr_cntry AS country,
             a.txt_permadr_zip AS postal_code,
             ref_cust_phone AS phone_no,
             cod_cust_natl_id AS natl_id,
             a.ref_cust_it_num AS tax_id,
             x.nam_cust_emp AS office_name,
             x.txt_empadr_add1 AS office_addr_1,
             x.txt_empadr_add2 AS office_addr_2,
             x.txt_empadr_add3 AS office_addr_3,
             x.nam_empadr_city AS office_city,
             x.nam_empadr_state AS office_state,
             x.nam_empadr_cntry AS office_country,
             x.txt_empadr_zip AS office_zip,
             -- a.ref_office_phone_area || ' ' || a.ref_office_phone_extn as office_phone,
             a.ref_office_phone_area || a.ref_cust_phone_off || ' ' ||
             a.ref_office_phone_extn AS office_phone,
             a.txt_custadr_add1 AS mailing_addr_1,
             a.txt_custadr_add2 AS mailing_addr_2,
             a.txt_custadr_add3 AS mailing_addr_3,
             a.nam_custadr_city AS mailing_addr_city,
             a.nam_custadr_state AS mailing_addr_state,
             a.nam_custadr_cntry AS mailing_addr_country,
             y.nam_cust_full AS dhn_cust_name,
             y.cust_add1 AS dhn_cust_address_1,
            TO_CHAR(y.dat_instr_exp,'YYYYMMDD') AS dhn_expiry_date,
             'N' AS multiple_cif,
             a.nam_cust_shrt AS customer_shortname,
             a.cod_officr_id AS officer_id,
             (SELECT NVL(field_value, '')
                FROM udf_cust_log_details
               WHERE cod_field_tag = 'TXT_700'
                 AND cod_cust_id = TO_CHAR(a.cod_cust_id)
                 and flg_mnt_status = 'A') AS customer_sic_code,
             (SELECT DISTINCT cod_crr_cust
                FROM ac_acct_crr_code
               WHERE cod_cust_id = TO_CHAR(a.cod_cust_id)
                 AND flg_mnt_status = 'A') AS cust_crr_code,
             a.cif_type AS cif_type,
             NVL(a.flg_replicate, 'N') flg_replicate,
             (select txt_ic_typ
                from ci_ic_types
               where flg_ic_typ = a.flg_ic_typ
                 and flg_mnt_status = 'A') AS flg_ic_typ,
             (select txt_cust_typ
                from CI_CUST_TYPES
               where flg_cust_typ = a.flg_cust_typ
                 and flg_mnt_status = 'A') AS flg_cust_typ,
             (SELECT NVL(field_value, '')
                FROM udf_cust_log_details
               WHERE cod_field_tag = 'TXT_774'
                 AND cod_task = 'CIM09'
                 AND cod_cust_id = TO_CHAR(a.cod_cust_id)
                 AND flg_mnt_status = 'A') AS citizenType,
             pk_ba_lob_codes.get_custid_lob_code(a.cod_cust_id) AS cifLOB,
             (SELECT field_value
                FROM udf_cust_log_details
               WHERE cod_field_tag = 'TXT_696'
                 AND cod_task = 'CIM09'
                 AND cod_cust_id = TO_CHAR(a.cod_cust_id)
                 AND flg_mnt_status = 'A'
                 AND ROWNUM = 1) AS icType,
             CASE
               WHEN UPPER(TRIM((SELECT field_value
                                  FROM udf_cust_log_details
                                 WHERE cod_field_tag = 'TXT_696'
                                   AND cod_task = 'CIM09'
                                   AND cod_cust_id = TO_CHAR(a.cod_cust_id)
                                   AND flg_mnt_status = 'A'
                                   AND ROWNUM = 1))) = 'PAS' THEN
                TRIM(a.cod_cust_natl_id)
             END AS passportNo,
             CASE
               WHEN UPPER(TRIM((SELECT field_value
                                  FROM udf_cust_log_details
                                 WHERE cod_field_tag = 'TXT_696'
                                   AND cod_task = 'CIM09'
                                   AND cod_cust_id = TO_CHAR(a.cod_cust_id)
                                   AND flg_mnt_status = 'A'
                                   AND ROWNUM = 1))) = 'PAS' THEN
                (SELECT CASE
                          WHEN REGEXP_LIKE(TRIM(u.field_value),
                                           '^(19|20)[0-9]{2}(0[1-9]|1[0-2])(0[1-9]|[12][0-9]|3[01])$') THEN
                           TRIM(u.field_value)
                          WHEN REGEXP_LIKE(TRIM(u.field_value),
                                           '^(0[1-9]|[12][0-9]|3[01])(0[1-9]|1[0-2])(19|20)[0-9]{2}$') THEN
                           SUBSTR(TRIM(u.field_value), 5, 4) ||
                           SUBSTR(TRIM(u.field_value), 3, 2) ||
                           SUBSTR(TRIM(u.field_value), 1, 2)
                          WHEN REGEXP_LIKE(TRIM(u.field_value),
                                           '^[0-9]{1,2}/[0-9]{1,2}/(19|20)[0-9]{2}$') THEN
                           SUBSTR(TRIM(u.field_value), -4) ||
                           LPAD(REGEXP_SUBSTR(TRIM(u.field_value), '[^/]+', 1, 2), 2, '0') ||
                           LPAD(REGEXP_SUBSTR(TRIM(u.field_value), '[^/]+', 1, 1), 2, '0')
                        END
                   FROM udf_cust_log_details u
                  WHERE u.cod_field_tag = 'TXT_762'
                    AND u.cod_task = 'CIM09'
                    AND u.cod_cust_id = TO_CHAR(a.cod_cust_id)
                    AND u.flg_mnt_status = 'A'
                    AND ROWNUM = 1)
             END AS passportExpiryDate,
             a.flg_staff AS isEmployee,
             a.cod_employee_id AS employeeID,
             a.txt_ethnic_origin AS religion,
             a.txt_cust_residence AS customerResidence,
             a.Ref_Cust_Fax AS customerFaxNo,
             (SELECT NVL(field_value, '')
                FROM udf_cust_log_details
               WHERE cod_field_tag = 'TXT_759'
                 AND cod_task = 'CIM09'
                 AND cod_cust_id = TO_CHAR(a.cod_cust_id)
                 AND flg_mnt_status = 'A') AS incomeCategory,
             a.nam_signatory1 AS nameSignatory1,
             a.txt_desgn_signtry1 AS designationSignatory1,
             a.nam_signatory2 AS nameSignatory2,
             a.txt_desgn_signtry2 AS designationSignatory2,
             a.nam_signatory3 AS nameSignatory3,
             a.txt_desgn_signtry3 AS designationSignatory3,
             a.nam_signatory4 AS nameSignatory4,
             a.txt_desgn_signtry4 AS designationSignatory4,
             a.nam_signatory5 AS nameSignatory5,
             a.txt_desgn_signtry5 AS designationSignatory5,
             (SELECT NVL(field_value, '')
                FROM udf_cust_log_details
               WHERE cod_field_tag = 'TXT_773'
                 AND cod_task = 'CIM09'
                 AND cod_cust_id = TO_CHAR(a.cod_cust_id)
                 AND flg_mnt_status = 'A') AS investmentRiskProfile,
             (SELECT NVL(field_value, '')
                FROM udf_cust_log_details
               WHERE cod_field_tag = 'TXT_728'
                 AND cod_task = 'CIM09'
                 AND cod_cust_id = TO_CHAR(a.cod_cust_id)
                 AND flg_mnt_status = 'A') AS treasuryStructuredProduct,
             a.txt_custadr_zip AS postalCode,
             a.ref_cust_telex AS telexNo,
             a.txt_cust_natnlty AS customerNationality,
             (SELECT description
                FROM ba_ifst_country
               WHERE country_code = a.txt_cust_natnlty
                 AND flg_mnt_status = 'A') AS customerNationalityDesc,
             a.txt_cust_prefix AS customerSalutation,
             a.cod_cc_homebrn AS customercifBranchCode,
             a.cod_cust_marstat AS maritalStatus,
             (SELECT txt_profession
                FROM ci_prof_codes
               WHERE txt_profess_cat = a.txt_profess_cat
                 AND flg_mnt_status = 'A') AS professionalDesc,
             a.txt_cust_educn AS education,
             (CASE
               WHEN (SELECT count(1)
                       FROM udf_mnt_log_details
                      WHERE ref_udf_no IN
                            (SELECT ref_udf_no
                               FROM rr_cust_service_bdi
                              WHERE cod_id = CAST(a.cod_cust_id AS CHAR(16))
                                AND flg_mnt_status = 'A')
                        AND cod_field_tag = 'TXT_869'
                        AND flg_mnt_status = 'A') > 0 THEN
                'Y'
               ELSE
                'N'
             END) AS rrm01PrivilegeFlag,
             (SELECT field_value
                FROM udf_mnt_log_details
               WHERE ref_udf_no IN
                     (SELECT ref_udf_no
                        FROM rr_cust_service_bdi
                       WHERE cod_id = CAST(a.cod_cust_id AS CHAR(16))
                         AND flg_mnt_status = 'A')
                 AND cod_field_tag = 'TXT_869'
                 AND flg_mnt_status = 'A') AS rrm01PrivilegeCode,
             (SELECT nam_lob
                FROM ba_lob_mast
               WHERE COD_LOB =
                     pk_ba_lob_codes.get_custid_lob_code(a.cod_cust_id)) AS lob_desc,
             a.txt_cust_desgn AS customerJobTitle
        FROM ci_custmast a
        LEFT JOIN ci_custdetl x ON a.cod_cust_id = x.cod_cust_id
        LEFT JOIN st_dhn_ext_unmatched_cust y ON a.cod_cust_natl_id =
                                                 y.cust_natl_id
                                             AND a.dat_birth_cust =
                                                 y.dat_birth_cust
       WHERE EXISTS (select 1
                FROM ln_acct_dtls b
               WHERE b.cod_cust_id = a.cod_cust_id
                 AND flg_mnt_status = 'A'
                 AND b.cod_acct_no = var_pi_id);
  ELSIF (var_pi_id_type = '90') THEN
    OPEN var_po_inq_result FOR
      SELECT a.cod_cust_id,
             a.nam_cust_first,
             a.nam_cust_mid,
             a.nam_cust_last,
             a.nam_cust_full,
             (SELECT cod_card_no
                FROM cm_x_custcard_acct_xref
               WHERE cod_cust_id = TO_CHAR(a.cod_cust_id)
                 AND flg_link_unlink = 'L'
                 AND flg_mnt_status = 'A'
                 AND ROWNUM = 1) AS atmCardNo,
             TO_CHAR(a.dat_birth_cust, 'YYYYMMDD') AS DOB,
             (SELECT field_value
                FROM udf_cust_log_details
               WHERE cod_cust_id = TO_CHAR(a.cod_cust_id)
                 AND flg_mnt_status = 'A'
                 AND cod_field_tag = 'TXT_699'
                 AND cod_task = 'CIM09') AS POB,
             txt_cust_sex AS gender,
             (SELECT field_value
                FROM udf_cust_log_details
               WHERE cod_cust_id = TO_CHAR(a.cod_cust_id)
                 AND flg_mnt_status = 'A'
                 AND cod_field_tag = 'TXT_691'
                 AND cod_task = 'CIM09') AS mother_name,
             a.ref_cust_email AS email,
             a.ref_phone_mobile AS mobile_no,
             a.txt_permadr_add1 AS add_1,
             a.txt_permadr_add2 AS add_2,
             a.txt_permadr_add3 AS add_3,
             a.nam_permadr_city AS city,
             a.nam_permadr_state AS state,
             a.nam_permadr_cntry AS country,
             a.txt_permadr_zip AS postal_code,
             ref_cust_phone AS phone_no,
             cod_cust_natl_id AS natl_id,
             a.ref_cust_it_num AS tax_id,
             x.nam_cust_emp AS office_name,
             x.txt_empadr_add1 AS office_addr_1,
             x.txt_empadr_add2 AS office_addr_2,
             x.txt_empadr_add3 AS office_addr_3,
             x.nam_empadr_city AS office_city,
             x.nam_empadr_state AS office_state,
             x.nam_empadr_cntry AS office_country,
             x.txt_empadr_zip AS office_zip,
             -- a.ref_office_phone_area || ' ' || a.ref_office_phone_extn as office_phone,
             a.ref_office_phone_area || a.ref_cust_phone_off || ' ' ||
             a.ref_office_phone_extn AS office_phone,
             a.txt_custadr_add1 AS mailing_addr_1,
             a.txt_custadr_add2 AS mailing_addr_2,
             a.txt_custadr_add3 AS mailing_addr_3,
             a.nam_custadr_city AS mailing_addr_city,
             a.nam_custadr_state AS mailing_addr_state,
             a.nam_custadr_cntry AS mailing_addr_country,
             y.nam_cust_full AS dhn_cust_name,
             y.cust_add1 AS dhn_cust_address_1,
             TO_CHAR(y.dat_instr_exp,'YYYYMMDD') AS dhn_expiry_date,
             'N' AS multiple_cif,
             a.nam_cust_shrt AS customer_shortname,
             a.cod_officr_id AS officer_id,
             (SELECT NVL(field_value, '')
                FROM udf_cust_log_details
               WHERE cod_field_tag = 'TXT_700'
                 AND cod_cust_id = TO_CHAR(a.cod_cust_id)
                 AND flg_mnt_status = 'A') AS customer_sic_code,
             (SELECT DISTINCT cod_crr_cust
                FROM ac_acct_crr_code
               WHERE cod_cust_id = TO_CHAR(a.cod_cust_id)
                 AND flg_mnt_status = 'A') AS cust_crr_code,
             a.cif_type AS cif_type,
             NVL(a.flg_replicate, 'N') flg_replicate,
             (select txt_ic_typ
                from ci_ic_types
               where flg_ic_typ = a.flg_ic_typ
                 and flg_mnt_status = 'A') AS flg_ic_typ,
             (select txt_cust_typ
                from CI_CUST_TYPES
               where flg_cust_typ = a.flg_cust_typ
                 and flg_mnt_status = 'A') AS flg_cust_typ,
             (SELECT NVL(field_value, '')
                FROM udf_cust_log_details
               WHERE cod_field_tag = 'TXT_774'
                 AND cod_task = 'CIM09'
                 AND cod_cust_id = TO_CHAR(a.cod_cust_id)
                 AND flg_mnt_status = 'A') AS citizenType,
             pk_ba_lob_codes.get_custid_lob_code(a.cod_cust_id) AS cifLOB,
             (SELECT field_value
                FROM udf_cust_log_details
               WHERE cod_field_tag = 'TXT_696'
                 AND cod_task = 'CIM09'
                 AND cod_cust_id = TO_CHAR(a.cod_cust_id)
                 AND flg_mnt_status = 'A'
                 AND ROWNUM = 1) AS icType,
             CASE
               WHEN UPPER(TRIM((SELECT field_value
                                  FROM udf_cust_log_details
                                 WHERE cod_field_tag = 'TXT_696'
                                   AND cod_task = 'CIM09'
                                   AND cod_cust_id = TO_CHAR(a.cod_cust_id)
                                   AND flg_mnt_status = 'A'
                                   AND ROWNUM = 1))) = 'PAS' THEN
                TRIM(a.cod_cust_natl_id)
             END AS passportNo,
             CASE
               WHEN UPPER(TRIM((SELECT field_value
                                  FROM udf_cust_log_details
                                 WHERE cod_field_tag = 'TXT_696'
                                   AND cod_task = 'CIM09'
                                   AND cod_cust_id = TO_CHAR(a.cod_cust_id)
                                   AND flg_mnt_status = 'A'
                                   AND ROWNUM = 1))) = 'PAS' THEN
                (SELECT CASE
                          WHEN REGEXP_LIKE(TRIM(u.field_value),
                                           '^(19|20)[0-9]{2}(0[1-9]|1[0-2])(0[1-9]|[12][0-9]|3[01])$') THEN
                           TRIM(u.field_value)
                          WHEN REGEXP_LIKE(TRIM(u.field_value),
                                           '^(0[1-9]|[12][0-9]|3[01])(0[1-9]|1[0-2])(19|20)[0-9]{2}$') THEN
                           SUBSTR(TRIM(u.field_value), 5, 4) ||
                           SUBSTR(TRIM(u.field_value), 3, 2) ||
                           SUBSTR(TRIM(u.field_value), 1, 2)
                          WHEN REGEXP_LIKE(TRIM(u.field_value),
                                           '^[0-9]{1,2}/[0-9]{1,2}/(19|20)[0-9]{2}$') THEN
                           SUBSTR(TRIM(u.field_value), -4) ||
                           LPAD(REGEXP_SUBSTR(TRIM(u.field_value), '[^/]+', 1, 2), 2, '0') ||
                           LPAD(REGEXP_SUBSTR(TRIM(u.field_value), '[^/]+', 1, 1), 2, '0')
                        END
                   FROM udf_cust_log_details u
                  WHERE u.cod_field_tag = 'TXT_762'
                    AND u.cod_task = 'CIM09'
                    AND u.cod_cust_id = TO_CHAR(a.cod_cust_id)
                    AND u.flg_mnt_status = 'A'
                    AND ROWNUM = 1)
             END AS passportExpiryDate,
             a.flg_staff AS isEmployee,
             a.cod_employee_id AS employeeID,
             a.txt_ethnic_origin AS religion,
             a.txt_cust_residence AS customerResidence,
             a.Ref_Cust_Fax AS customerFaxNo,
             (SELECT NVL(field_value, '')
                FROM udf_cust_log_details
               WHERE cod_field_tag = 'TXT_759'
                 AND cod_task = 'CIM09'
                 AND cod_cust_id = TO_CHAR(a.cod_cust_id)
                 AND flg_mnt_status = 'A') AS incomeCategory,
             a.nam_signatory1 AS nameSignatory1,
             a.txt_desgn_signtry1 AS designationSignatory1,
             a.nam_signatory2 AS nameSignatory2,
             a.txt_desgn_signtry2 AS designationSignatory2,
             a.nam_signatory3 AS nameSignatory3,
             a.txt_desgn_signtry3 AS designationSignatory3,
             a.nam_signatory4 AS nameSignatory4,
             a.txt_desgn_signtry4 AS designationSignatory4,
             a.nam_signatory5 AS nameSignatory5,
             a.txt_desgn_signtry5 AS designationSignatory5,
             (SELECT NVL(field_value, '')
                FROM udf_cust_log_details
               WHERE cod_field_tag = 'TXT_773'
                 AND cod_task = 'CIM09'
                 AND cod_cust_id = TO_CHAR(a.cod_cust_id)
                 AND flg_mnt_status = 'A') AS investmentRiskProfile,
             (SELECT NVL(field_value, '')
                FROM udf_cust_log_details
               WHERE cod_field_tag = 'TXT_728'
                 AND cod_task = 'CIM09'
                 AND cod_cust_id = TO_CHAR(a.cod_cust_id)
                 AND flg_mnt_status = 'A') AS treasuryStructuredProduct,
             a.txt_custadr_zip AS postalCode,
             a.ref_cust_telex AS telexNo,
             a.txt_cust_natnlty AS customerNationality,
             (SELECT description
                FROM ba_ifst_country
               WHERE country_code = a.txt_cust_natnlty
                 AND flg_mnt_status = 'A') AS customerNationalityDesc,
             a.txt_cust_prefix AS customerSalutation,
             a.cod_cc_homebrn AS customercifBranchCode,
             a.cod_cust_marstat AS maritalStatus,
             (SELECT txt_profession
                FROM ci_prof_codes
               WHERE txt_profess_cat = a.txt_profess_cat
                 AND flg_mnt_status = 'A') AS professionalDesc,
             a.txt_cust_educn AS education,
             (CASE
               WHEN (SELECT count(1)
                       FROM udf_mnt_log_details
                      WHERE ref_udf_no IN
                            (SELECT ref_udf_no
                               FROM rr_cust_service_bdi
                              WHERE cod_id = CAST(a.cod_cust_id AS CHAR(16))
                                AND flg_mnt_status = 'A')
                        AND cod_field_tag = 'TXT_869'
                        AND flg_mnt_status = 'A') > 0 THEN
                'Y'
               ELSE
                'N'
             END) AS rrm01PrivilegeFlag,
             (SELECT field_value
                FROM udf_mnt_log_details
               WHERE ref_udf_no IN
                     (SELECT ref_udf_no
                        FROM rr_cust_service_bdi
                       WHERE cod_id = CAST(a.cod_cust_id AS CHAR(16))
                         AND flg_mnt_status = 'A')
                 AND cod_field_tag = 'TXT_869'
                 AND flg_mnt_status = 'A') AS rrm01PrivilegeCode,
             (SELECT nam_lob
                FROM ba_lob_mast
               WHERE COD_LOB =
                     pk_ba_lob_codes.get_custid_lob_code(a.cod_cust_id)) AS lob_desc,
             a.txt_cust_desgn AS customerJobTitle
        FROM ci_custmast a
        LEFT JOIN ci_custdetl x ON a.cod_cust_id = x.cod_cust_id
        LEFT JOIN st_dhn_ext_unmatched_cust y ON a.cod_cust_natl_id =
                                                 y.cust_natl_id
                                             AND a.dat_birth_cust =
                                                 y.dat_birth_cust
       WHERE a.cod_cust_id = var_pi_id
         AND a.flg_mnt_status = 'A';
  ELSIF (var_pi_id_type = '91') THEN
    OPEN var_po_inq_result FOR
      SELECT a.cod_cust_id,
             a.nam_cust_first,
             a.nam_cust_mid,
             a.nam_cust_last,
             a.nam_cust_full,
             (SELECT cod_card_no
                FROM cm_x_custcard_acct_xref
               WHERE cod_cust_id = TO_CHAR(a.cod_cust_id)
                 AND flg_link_unlink = 'L'
                 AND flg_mnt_status = 'A'
                 AND ROWNUM = 1) AS atmCardNo,
             TO_CHAR(a.dat_birth_cust, 'YYYYMMDD') AS DOB,
             (SELECT field_value
                FROM udf_cust_log_details
               WHERE cod_cust_id = TO_CHAR(a.cod_cust_id)
                 AND flg_mnt_status = 'A'
                 AND cod_field_tag = 'TXT_699'
                 AND cod_task = 'CIM09') AS POB,
             txt_cust_sex AS gender,
             (SELECT field_value
                FROM udf_cust_log_details
               WHERE cod_cust_id = TO_CHAR(a.cod_cust_id)
                 AND flg_mnt_status = 'A'
                 AND cod_field_tag = 'TXT_691'
                 AND cod_task = 'CIM09') AS mother_name,
             a.ref_cust_email AS email,
             a.ref_phone_mobile AS mobile_no,
             a.txt_permadr_add1 AS add_1,
             a.txt_permadr_add2 AS add_2,
             a.txt_permadr_add3 AS add_3,
             a.nam_permadr_city AS city,
             a.nam_permadr_state AS state,
             a.nam_permadr_cntry AS country,
             a.txt_permadr_zip AS postal_code,
             ref_cust_phone AS phone_no,
             COD_CUST_NATL_ID AS natl_id,
             a.REF_CUST_IT_NUM AS tax_id,
             x.nam_cust_emp AS office_name,
             x.txt_empadr_add1 AS office_addr_1,
             x.txt_empadr_add2 AS office_addr_2,
             x.txt_empadr_add3 AS office_addr_3,
             x.nam_empadr_city AS office_city,
             x.nam_empadr_state AS office_state,
             x.nam_empadr_cntry AS office_country,
             x.txt_empadr_zip AS office_zip,
             -- a.ref_office_phone_area || ' ' || a.ref_office_phone_extn as office_phone,
             a.ref_office_phone_area || a.ref_cust_phone_off || ' ' ||
             a.ref_office_phone_extn AS office_phone,
             a.txt_custadr_add1 AS mailing_addr_1,
             a.txt_custadr_add2 AS mailing_addr_2,
             a.txt_custadr_add3 AS mailing_addr_3,
             a.nam_custadr_city AS mailing_addr_city,
             a.nam_custadr_state AS mailing_addr_state,
             a.nam_custadr_cntry AS mailing_addr_country,
             y.nam_cust_full AS dhn_cust_name,
             y.cust_add1 AS dhn_cust_address_1,
             TO_CHAR(y.dat_instr_exp,'YYYYMMDD') AS dhn_expiry_date,
             (CASE
               WHEN (SELECT COUNT(1)
                       FROM ci_custmast ax
                      WHERE ax.ref_cust_it_num = var_pi_id
                        AND ax.flg_mnt_status = 'A'
                      GROUP by ax.ref_cust_it_num
                     HAVING COUNT(1) > 1) > 0 THEN
                'Y'
               ELSE
                'N'
             END) as multiple_cif,
             a.nam_cust_shrt AS customer_shortname,
             a.cod_officr_id AS officer_id,
             (SELECT NVL(FIELD_VALUE, '')
                FROM udf_cust_log_details
               WHERE cod_field_tag = 'TXT_700'
                 AND cod_cust_id = TO_CHAR(a.cod_cust_id)
                 AND flg_mnt_status = 'A') AS customer_sic_code,
             (SELECT distinct cod_crr_cust
                FROM ac_acct_crr_code
               WHERE cod_cust_id = TO_CHAR(a.cod_cust_id)
                 AND flg_mnt_status = 'A') AS cust_crr_code,
             a.cif_type AS cif_type,
             NVL(a.flg_replicate, 'N') flg_replicate,
             (select txt_ic_typ
                from ci_ic_types
               where flg_ic_typ = a.flg_ic_typ
                 and flg_mnt_status = 'A') AS flg_ic_typ,
             (select txt_cust_typ
                from CI_CUST_TYPES
               where flg_cust_typ = a.flg_cust_typ
                 and flg_mnt_status = 'A') AS flg_cust_typ,
             (SELECT NVL(field_value, '')
                FROM udf_cust_log_details
               WHERE cod_field_tag = 'TXT_774'
                 AND cod_task = 'CIM09'
                 AND cod_cust_id = TO_CHAR(a.cod_cust_id)
                 AND flg_mnt_status = 'A') AS citizenType,
             pk_ba_lob_codes.get_custid_lob_code(a.cod_cust_id) AS cifLOB,
             (SELECT field_value
                FROM udf_cust_log_details
               WHERE cod_field_tag = 'TXT_696'
                 AND cod_task = 'CIM09'
                 AND cod_cust_id = TO_CHAR(a.cod_cust_id)
                 AND flg_mnt_status = 'A'
                 AND ROWNUM = 1) AS icType,
             CASE
               WHEN UPPER(TRIM((SELECT field_value
                                  FROM udf_cust_log_details
                                 WHERE cod_field_tag = 'TXT_696'
                                   AND cod_task = 'CIM09'
                                   AND cod_cust_id = TO_CHAR(a.cod_cust_id)
                                   AND flg_mnt_status = 'A'
                                   AND ROWNUM = 1))) = 'PAS' THEN
                TRIM(a.cod_cust_natl_id)
             END AS passportNo,
             CASE
               WHEN UPPER(TRIM((SELECT field_value
                                  FROM udf_cust_log_details
                                 WHERE cod_field_tag = 'TXT_696'
                                   AND cod_task = 'CIM09'
                                   AND cod_cust_id = TO_CHAR(a.cod_cust_id)
                                   AND flg_mnt_status = 'A'
                                   AND ROWNUM = 1))) = 'PAS' THEN
                (SELECT CASE
                          WHEN REGEXP_LIKE(TRIM(u.field_value),
                                           '^(19|20)[0-9]{2}(0[1-9]|1[0-2])(0[1-9]|[12][0-9]|3[01])$') THEN
                           TRIM(u.field_value)
                          WHEN REGEXP_LIKE(TRIM(u.field_value),
                                           '^(0[1-9]|[12][0-9]|3[01])(0[1-9]|1[0-2])(19|20)[0-9]{2}$') THEN
                           SUBSTR(TRIM(u.field_value), 5, 4) ||
                           SUBSTR(TRIM(u.field_value), 3, 2) ||
                           SUBSTR(TRIM(u.field_value), 1, 2)
                          WHEN REGEXP_LIKE(TRIM(u.field_value),
                                           '^[0-9]{1,2}/[0-9]{1,2}/(19|20)[0-9]{2}$') THEN
                           SUBSTR(TRIM(u.field_value), -4) ||
                           LPAD(REGEXP_SUBSTR(TRIM(u.field_value), '[^/]+', 1, 2), 2, '0') ||
                           LPAD(REGEXP_SUBSTR(TRIM(u.field_value), '[^/]+', 1, 1), 2, '0')
                        END
                   FROM udf_cust_log_details u
                  WHERE u.cod_field_tag = 'TXT_762'
                    AND u.cod_task = 'CIM09'
                    AND u.cod_cust_id = TO_CHAR(a.cod_cust_id)
                    AND u.flg_mnt_status = 'A'
                    AND ROWNUM = 1)
             END AS passportExpiryDate,
             a.flg_staff AS isEmployee,
             a.cod_employee_id AS employeeID,
             a.txt_ethnic_origin AS religion,
             a.txt_cust_residence AS customerResidence,
             a.Ref_Cust_Fax AS customerFaxNo,
             (SELECT NVL(field_value, '')
                FROM udf_cust_log_details
               WHERE cod_field_tag = 'TXT_759'
                 AND cod_task = 'CIM09'
                 AND cod_cust_id = TO_CHAR(a.cod_cust_id)
                 AND flg_mnt_status = 'A') AS incomeCategory,
             a.nam_signatory1 AS nameSignatory1,
             a.txt_desgn_signtry1 AS designationSignatory1,
             a.nam_signatory2 AS nameSignatory2,
             a.txt_desgn_signtry2 AS designationSignatory2,
             a.nam_signatory3 AS nameSignatory3,
             a.txt_desgn_signtry3 AS designationSignatory3,
             a.nam_signatory4 AS nameSignatory4,
             a.txt_desgn_signtry4 AS designationSignatory4,
             a.nam_signatory5 AS nameSignatory5,
             a.txt_desgn_signtry5 AS designationSignatory5,
             (SELECT NVL(field_value, '')
                FROM udf_cust_log_details
               WHERE cod_field_tag = 'TXT_773'
                 AND cod_task = 'CIM09'
                 AND cod_cust_id = TO_CHAR(a.cod_cust_id)
                 AND flg_mnt_status = 'A') AS investmentRiskProfile,
             (SELECT NVL(field_value, '')
                FROM udf_cust_log_details
               WHERE cod_field_tag = 'TXT_728'
                 AND cod_task = 'CIM09'
                 AND cod_cust_id = TO_CHAR(a.cod_cust_id)
                 AND flg_mnt_status = 'A') AS treasuryStructuredProduct,
             a.txt_custadr_zip AS postalCode,
             a.ref_cust_telex AS telexNo,
             a.txt_cust_natnlty AS customerNationality,
             (SELECT description
                FROM ba_ifst_country
               WHERE country_code = a.txt_cust_natnlty
                 AND flg_mnt_status = 'A') AS customerNationalityDesc,
             a.txt_cust_prefix AS customerSalutation,
             a.cod_cc_homebrn AS customercifBranchCode,
             a.cod_cust_marstat AS maritalStatus,
             (SELECT txt_profession
                FROM ci_prof_codes
               WHERE txt_profess_cat = a.txt_profess_cat
                 AND flg_mnt_status = 'A') AS professionalDesc,
             a.txt_cust_educn AS education,
             (CASE
               WHEN (SELECT count(1)
                       FROM udf_mnt_log_details
                      WHERE ref_udf_no IN
                            (SELECT ref_udf_no
                               FROM rr_cust_service_bdi
                              WHERE cod_id = CAST(a.cod_cust_id AS CHAR(16))
                                AND flg_mnt_status = 'A')
                        AND cod_field_tag = 'TXT_869'
                        AND flg_mnt_status = 'A') > 0 THEN
                'Y'
               ELSE
                'N'
             END) AS rrm01PrivilegeFlag,
             (SELECT field_value
                FROM udf_mnt_log_details
               WHERE ref_udf_no IN
                     (SELECT ref_udf_no
                        FROM rr_cust_service_bdi
                       WHERE cod_id = CAST(a.cod_cust_id AS CHAR(16))
                         AND flg_mnt_status = 'A')
                 AND cod_field_tag = 'TXT_869'
                 AND flg_mnt_status = 'A') AS rrm01PrivilegeCode,
             (SELECT nam_lob
                FROM ba_lob_mast
               WHERE COD_LOB =
                     pk_ba_lob_codes.get_custid_lob_code(a.cod_cust_id)) AS lob_desc,
             a.txt_cust_desgn AS customerJobTitle
        FROM ci_custmast a
        LEFT JOIN ci_custdetl x ON a.cod_cust_id = x.cod_cust_id
        LEFT JOIN st_dhn_ext_unmatched_cust y ON a.cod_cust_natl_id =
                                                 y.cust_natl_id
                                             AND a.dat_birth_cust =
                                                 y.dat_birth_cust
       WHERE a.ref_cust_it_num = var_pi_id
         AND a.flg_mnt_status = 'A'
       ORDER BY a.dat_cust_open DESC;
  END IF;
  --debug_api_run(1416, 'AP_NGI_EXT_MF_CIF_ACCTINQ2' || SYSTIMESTAMP);
  RETURN 0;
EXCEPTION
  WHEN OTHERS THEN
    ora_raiserror(SQLCODE,
                  'FAILED IN EXECUTION OF ap_ngi_ext_mf_cif_inq',
                  85020);
END;



/

