-- ============================================================================
-- Helper for the MF_CIFINQ passport enhancement
-- ITRD NGI Service - MF_CIFINQ_Passport v.1.0
--
-- UDF_CUST_LOG_DETAILS.FIELD_VALUE is free text, so the passport expiry date
-- held under TXT_762 is captured in several shapes. The FCR schema holds
-- dd/MM/yyyy and ddMMyyyy, plus markers that are not dates at all, such as
-- SEUMUR HDP (lifetime validity), 0 and six digit values.
--
-- Returns the value as YYYYMMDD, or NULL when it is not a date.
-- The format is decided by a regular expression before TO_DATE is attempted,
-- so a value is never read under the wrong format.
-- ============================================================================

CREATE OR REPLACE FUNCTION FCR24.ap_ngi_fmt_udf_date(var_pi_value IN VARCHAR2)
  RETURN VARCHAR2 AS

  var_l_value VARCHAR2(200) := TRIM(var_pi_value);
  var_l_fmt   VARCHAR2(20);
BEGIN
  IF var_l_value IS NULL THEN
    RETURN NULL;
  END IF;

  -- Eight digits read as YYYYMMDD first, then as DDMMYYYY. The two do not
  -- collide for an expiry date: a DDMMYYYY value in the 20xx range puts 20
  -- where YYYYMMDD expects a month, so it fails as YYYYMMDD first.
  IF REGEXP_LIKE(var_l_value, '^[0-9]{8}$') THEN
    BEGIN
      RETURN TO_CHAR(TO_DATE(var_l_value, 'YYYYMMDD'), 'YYYYMMDD');
    EXCEPTION
      WHEN OTHERS THEN
        BEGIN
          RETURN TO_CHAR(TO_DATE(var_l_value, 'DDMMYYYY'), 'YYYYMMDD');
        EXCEPTION
          WHEN OTHERS THEN
            RETURN NULL;
        END;
    END;
  END IF;

  -- A month name is tried in English first, then in the session language,
  -- so both AUG and AGU are accepted.
  IF REGEXP_LIKE(var_l_value, '^[0-9]{1,2}-[A-Za-z]{3}-[0-9]{4}$') THEN
    BEGIN
      RETURN TO_CHAR(TO_DATE(var_l_value, 'DD-MON-YYYY', 'NLS_DATE_LANGUAGE=ENGLISH'),
                     'YYYYMMDD');
    EXCEPTION
      WHEN OTHERS THEN
        BEGIN
          RETURN TO_CHAR(TO_DATE(var_l_value, 'DD-MON-YYYY'), 'YYYYMMDD');
        EXCEPTION
          WHEN OTHERS THEN
            RETURN NULL;
        END;
    END;
  END IF;

  IF REGEXP_LIKE(var_l_value, '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{4}$') THEN
    var_l_fmt := 'DD/MM/YYYY';
  ELSIF REGEXP_LIKE(var_l_value, '^[0-9]{1,2}-[0-9]{1,2}-[0-9]{4}$') THEN
    var_l_fmt := 'DD-MM-YYYY';
  ELSIF REGEXP_LIKE(var_l_value, '^[0-9]{1,2}\.[0-9]{1,2}\.[0-9]{4}$') THEN
    var_l_fmt := 'DD.MM.YYYY';
  ELSIF REGEXP_LIKE(var_l_value, '^[0-9]{4}-[0-9]{1,2}-[0-9]{1,2}$') THEN
    var_l_fmt := 'YYYY-MM-DD';
  ELSIF REGEXP_LIKE(var_l_value, '^[0-9]{4}/[0-9]{1,2}/[0-9]{1,2}$') THEN
    var_l_fmt := 'YYYY/MM/DD';
  ELSE
    -- SEUMUR HDP, SEUMUR-HDP, 0, 220326 and anything else that is not a date
    RETURN NULL;
  END IF;

  BEGIN
    RETURN TO_CHAR(TO_DATE(var_l_value, var_l_fmt), 'YYYYMMDD');
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;
END;
/

-- Check it against every value the FCR schema holds under TXT_762
-- SELECT DISTINCT TRIM(field_value)                       AS stored,
--        FCR24.ap_ngi_fmt_udf_date(field_value)           AS returned
--   FROM udf_cust_log_details
--  WHERE cod_field_tag = 'TXT_762' AND cod_task = 'CIM09' AND flg_mnt_status = 'A'
--  ORDER BY 1;
