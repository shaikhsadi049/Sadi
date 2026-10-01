-- ============================================================================
-- NGI FC_MF_CIFINQ - passport fields (ITRD MF_CIFINQ_Passport v.1.0)
-- Verification queries, run as the FCR schema owner (fcr24).
--
-- Run Q1 FIRST. It answers the one open question in the change: whether
-- TXT_696 / TXT_762 live under a single COD_TASK, and therefore whether the
-- Java read should pin COD_TASK instead of only preferring CIM09.
--
-- Replace 1001 / 1002 with real CIF numbers where marked.
-- ============================================================================


-- ---------------------------------------------------------------------------
-- Q1. Which COD_TASK holds the two field tags, and how many rows each
--     -> if one task dominates, pin the Java query to it
-- ---------------------------------------------------------------------------
SELECT cod_field_tag,
       cod_task,
       flg_mnt_status,
       COUNT(*)                    AS row_count,
       COUNT(DISTINCT cod_cust_id) AS cust_count
FROM   udf_cust_log_details
WHERE  cod_field_tag IN ('TXT_696', 'TXT_762')
GROUP  BY cod_field_tag, cod_task, flg_mnt_status
ORDER  BY cod_field_tag, row_count DESC;


-- ---------------------------------------------------------------------------
-- Q2. Distinct icType values held in TXT_696
--     -> confirms the passport code really is 'PAS' and shows padding / case
-- ---------------------------------------------------------------------------
SELECT cod_task,
       '[' || field_value || ']' AS raw_value,
       TRIM(field_value)         AS trimmed_value,
       COUNT(*)                  AS cnt
FROM   udf_cust_log_details
WHERE  cod_field_tag  = 'TXT_696'
AND    flg_mnt_status = 'A'
GROUP  BY cod_task, field_value
ORDER  BY cnt DESC;


-- ---------------------------------------------------------------------------
-- Q3. What format is the passport expiry date (TXT_762) actually stored in?
--     -> every row that comes back as UNSUPPORTED is a value the Java code
--        cannot normalise and will return exactly as stored
-- ---------------------------------------------------------------------------
SELECT cod_task,
       detected_format,
       COUNT(*)  AS cnt,
       MIN(v)    AS sample_min,
       MAX(v)    AS sample_max
FROM (
    SELECT cod_task,
           v,
           CASE
             WHEN REGEXP_LIKE(v, '^[0-9]{8}$')                      THEN 'YYYYMMDD    (ok)'
             WHEN REGEXP_LIKE(v, '^[0-9]{2}/[0-9]{2}/[0-9]{4}$')    THEN 'DD/MM/YYYY  (ok)'
             WHEN REGEXP_LIKE(v, '^[0-9]{2}-[0-9]{2}-[0-9]{4}$')    THEN 'DD-MM-YYYY  (ok)'
             WHEN REGEXP_LIKE(v, '^[0-9]{2}\.[0-9]{2}\.[0-9]{4}$')  THEN 'DD.MM.YYYY  (ok)'
             WHEN REGEXP_LIKE(v, '^[0-9]{2}-[A-Za-z]{3}-[0-9]{4}$') THEN 'DD-MON-YYYY (ok)'
             WHEN REGEXP_LIKE(v, '^[0-9]{4}-[0-9]{2}-[0-9]{2}$')    THEN 'YYYY-MM-DD  (ok)'
             WHEN REGEXP_LIKE(v, '^[0-9]{4}/[0-9]{2}/[0-9]{2}$')    THEN 'YYYY/MM/DD  (ok)'
             ELSE 'UNSUPPORTED -> returned as stored'
           END AS detected_format
    FROM ( SELECT cod_task, TRIM(field_value) AS v
           FROM   udf_cust_log_details
           WHERE  cod_field_tag  = 'TXT_762'
           AND    flg_mnt_status = 'A'
           AND    TRIM(field_value) IS NOT NULL )
)
GROUP  BY cod_task, detected_format
ORDER  BY cnt DESC;


-- ---------------------------------------------------------------------------
-- Q4. Does any customer hold the same tag more than once under the SAME task?
--     -> if this returns rows, the row the service picks among them is
--        arbitrary and the read needs a further tie breaker
-- ---------------------------------------------------------------------------
SELECT *
FROM (
    SELECT cod_cust_id,
           cod_task,
           cod_field_tag,
           COUNT(*) AS active_rows
    FROM   udf_cust_log_details
    WHERE  cod_field_tag IN ('TXT_696', 'TXT_762')
    AND    flg_mnt_status = 'A'
    GROUP  BY cod_cust_id, cod_task, cod_field_tag
    HAVING COUNT(*) > 1
    ORDER  BY active_rows DESC
)
WHERE rownum <= 50;


-- ---------------------------------------------------------------------------
-- Q5. The exact UDF read the Java code runs (icType)
--     QueryExecutorCustomerInquiry.GET_UDF_FIELD_VALUE_BY_CUST_ID
--     Swap 'TXT_696' for 'TXT_762' to check the expiry date instead.
-- ---------------------------------------------------------------------------
SELECT field_value
FROM ( SELECT field_value
       FROM   udf_cust_log_details
       WHERE  cod_field_tag  = 'TXT_696'
       AND    cod_cust_id    = '1001'            -- << CIF
       AND    flg_mnt_status = 'A'
       ORDER  BY CASE WHEN cod_task = 'CIM09' THEN 0 ELSE 1 END, cod_task )
WHERE rownum < 2;


-- ---------------------------------------------------------------------------
-- Q6. The exact national id read the Java code runs (passportNo source)
--     QueryExecutorCustomerInquiry.GET_NATIONAL_ID_BY_CUSTOMER_ID
-- ---------------------------------------------------------------------------
SELECT cod_cust_natl_id
FROM   ci_custmast
WHERE  cod_cust_id = '1001'                      -- << CIF
AND    rownum < 2;


-- ---------------------------------------------------------------------------
-- Q7. What the service will now return, for a list of CIFs
--     This reproduces the whole ITRD rule in one query: icType always,
--     passportNo and passportExpiryDate only when icType = 'PAS'.
--     passport_expiry_raw is the stored value; Java normalises it to YYYYMMDD.
-- ---------------------------------------------------------------------------
SELECT customer_no,
       ic_type,
       CASE WHEN UPPER(ic_type) = 'PAS' THEN natl_id    END AS passport_no,
       CASE WHEN UPPER(ic_type) = 'PAS' THEN expiry_raw END AS passport_expiry_raw
FROM (
    SELECT c.cod_cust_id             AS customer_no,
           TRIM(c.cod_cust_natl_id)  AS natl_id,
           (SELECT MAX(TRIM(u.field_value)) KEEP (DENSE_RANK FIRST
                       ORDER BY CASE WHEN u.cod_task = 'CIM09' THEN 0 ELSE 1 END,
                                u.cod_task)
              FROM   udf_cust_log_details u
              WHERE  u.cod_field_tag  = 'TXT_696'
              AND    u.cod_cust_id    = c.cod_cust_id
              AND    u.flg_mnt_status = 'A')     AS ic_type,
           (SELECT MAX(TRIM(u.field_value)) KEEP (DENSE_RANK FIRST
                       ORDER BY CASE WHEN u.cod_task = 'CIM09' THEN 0 ELSE 1 END,
                                u.cod_task)
              FROM   udf_cust_log_details u
              WHERE  u.cod_field_tag  = 'TXT_762'
              AND    u.cod_cust_id    = c.cod_cust_id
              AND    u.flg_mnt_status = 'A')     AS expiry_raw
    FROM   ci_custmast c
    WHERE  c.cod_cust_id IN ('1001', '1002')     -- << CIF list
);


-- ---------------------------------------------------------------------------
-- Q8. Find passport holders to test with
--     -> pick CIFs from here for Q5 / Q6 / Q7 and for the service SIT call
-- ---------------------------------------------------------------------------
SELECT *
FROM (
    SELECT u.cod_cust_id,
           u.cod_task,
           TRIM(u.field_value)      AS ic_type,
           TRIM(c.cod_cust_natl_id) AS natl_id_passport_no,
           (SELECT TRIM(e.field_value)
              FROM   udf_cust_log_details e
              WHERE  e.cod_field_tag  = 'TXT_762'
              AND    e.cod_cust_id    = u.cod_cust_id
              AND    e.cod_task       = u.cod_task
              AND    e.flg_mnt_status = 'A'
              AND    rownum < 2)     AS expiry_raw
    FROM   udf_cust_log_details u
    JOIN   ci_custmast c ON c.cod_cust_id = u.cod_cust_id
    WHERE  u.cod_field_tag  = 'TXT_696'
    AND    u.flg_mnt_status = 'A'
    AND    UPPER(TRIM(u.field_value)) = 'PAS'
)
WHERE rownum <= 50;


-- ---------------------------------------------------------------------------
-- Q9. Column / table sanity check, in case a name differs in this schema
-- ---------------------------------------------------------------------------
SELECT table_name, column_name, data_type, data_length, nullable
FROM   all_tab_columns
WHERE  ( table_name = 'UDF_CUST_LOG_DETAILS'
         AND column_name IN ('COD_CUST_ID','COD_TASK','COD_FIELD_TAG','FIELD_VALUE','FLG_MNT_STATUS') )
OR     ( table_name = 'CI_CUSTMAST'
         AND column_name IN ('COD_CUST_ID','COD_CUST_NATL_ID') )
ORDER  BY table_name, column_name;
