-- ============================================================================
-- NGI-206 - verification queries
--
-- Section 0 runs before the package is deployed and needs no transaction.
-- Everything after it reads the transaction the bank reported, and then the
-- one posted after the fix.
--
-- :svc_rq_id   the bdiSvcRqId / svcRqId the channel sent
-- :ref_txn_no  the host reference (PO_REF_NO), if it is already known
-- ============================================================================


-- ----------------------------------------------------------------------------
-- 0.  Dry run of the new logic.  Paste the real memo in place of the sample
--     and see exactly what the patched package will send, without deploying
--     anything.  Both expressions are copied verbatim from the patch.
-- ----------------------------------------------------------------------------
WITH t AS (SELECT 'Transfer gaji bulan Oktober untuk PT Maju & Jaya cabang' AS memo FROM dual)
SELECT LENGTH(memo)                                                   AS memo_len,
       REGEXP_REPLACE(SUBSTR(memo,   1, 35), q'{[^A-Za-z0-9/?:().,'+ -]}', ' ') AS paydet1,
       REGEXP_REPLACE(SUBSTR(memo,  36, 35), q'{[^A-Za-z0-9/?:().,'+ -]}', ' ') AS paydet2,
       REGEXP_REPLACE(SUBSTR(memo,  71, 35), q'{[^A-Za-z0-9/?:().,'+ -]}', ' ') AS paydet3,
       REGEXP_REPLACE(SUBSTR(memo, 106, 35), q'{[^A-Za-z0-9/?:().,'+ -]}', ' ') AS paydet4
  FROM t;

-- Expected for a 60 character memo: PAYDET1 holds 35, PAYDET2 holds 25,
-- PAYDET3 and PAYDET4 come back NULL, and every '&' or '<' is a space.


-- ----------------------------------------------------------------------------
-- 1.  Find the transaction the channel's request belongs to.
-- ----------------------------------------------------------------------------
SELECT REF_TXN_NO, REF_USR_NO
  FROM XF_OL_ST_EXT_TXN_XREF
 WHERE REF_USR_NO = :svc_rq_id;

-- If nothing comes back, try the cross reference the duplicate check reads:
SELECT REF_TXN_NO, REF_USR_NO, ORG_CHNL_ID, DAT_TXN,
       FROM_MEMO_1, LENGTH(FROM_MEMO_1) AS memo_len
  FROM channel_txn_xref
 WHERE REF_USR_NO = :svc_rq_id;


-- ----------------------------------------------------------------------------
-- 2.  Did the FCC push succeed?
--     On the failing transaction TXN_STAT / MSG_STAT were never set and the
--     swift cross reference row was never written, because that INSERT sits
--     inside the IF VAR_L_SWIFT_OK = 1 block.
-- ----------------------------------------------------------------------------
SELECT TXN_STAT, MSG_STAT, REF_USR_NO
  FROM PM_TXN_LOG
 WHERE REF_TXN_NO = :ref_txn_no;
-- after the fix: TXN_STAT = 1, MSG_STAT = 5

SELECT COUNT(*) AS swift_xref_rows
  FROM channel_swift_payment_xref
 WHERE ref_usr_no = :svc_rq_id;
-- failing: 0        after the fix: 1

SELECT COD_CTPARTY_ACCT
  FROM PM_REL_TXN_STORE
 WHERE REF_TXN_NO = :ref_txn_no;
-- the leading '/' is only applied after FCC accepts, so no slash means the
-- push was masked


-- ----------------------------------------------------------------------------
-- 3.  What was stored from the memo.  These are unchanged by the fix - the
--     patch touches the FCC message only - so they should read the same
--     before and after.
-- ----------------------------------------------------------------------------
SELECT COD_ORG_REMIT,    LENGTH(COD_ORG_REMIT)    AS remit_len,
       NAM_REMITTER,     LENGTH(NAM_REMITTER)     AS name_len,
       REMITTER_NATL_ID, PHONE_REMITTER,
       TXT_NARRATIVE,    LENGTH(TXT_NARRATIVE)    AS narrative_len
  FROM PM_REL_TXN_STORE
 WHERE REF_TXN_NO = :ref_txn_no;

-- COD_ORG_REMIT is memo 1-35 whatever happens.  NAM_REMITTER, REMITTER_NATL_ID
-- and PHONE_REMITTER only carry memo 36-70, 71-105 and 106-140 when the SIMODIS
-- macro is on - section 4.  TXT_NARRATIVE is memo1+memo2 cut to 40.


-- ----------------------------------------------------------------------------
-- 4.  The SIMODIS macro, which decides whether the payment log keeps 35 or 140
--     characters of the memo.  This is separate from the FCC message, which now
--     carries 140 either way.
-- ----------------------------------------------------------------------------
SELECT MACRO_NAME, MACRO_VALUE, FLG_MNT_STATUS
  FROM ba_site
 WHERE MACRO_NAME = 'ENABLE_SIMODIS_DCC';


-- ----------------------------------------------------------------------------
-- 5.  Column widths, to confirm nothing overflows.
-- ----------------------------------------------------------------------------
SELECT table_name, column_name, data_type, data_length
  FROM all_tab_columns
 WHERE (table_name, column_name) IN (('PM_REL_TXN_STORE', 'COD_ORG_REMIT'),
                                     ('PM_REL_TXN_STORE', 'NAM_REMITTER'),
                                     ('PM_REL_TXN_STORE', 'TXT_NARRATIVE'),
                                     ('CHANNEL_TXN_XREF', 'FROM_MEMO_1'),
                                     ('CHANNEL_TXN_XREF', 'TO_MEMO_1'))
 ORDER BY table_name, column_name;


-- ----------------------------------------------------------------------------
-- 6.  After deployment, before any transaction is posted.
-- ----------------------------------------------------------------------------
SELECT object_name, object_type, status
  FROM all_objects
 WHERE object_name = 'PK_OL_XFINT';
-- both PACKAGE and PACKAGE BODY must read VALID

SELECT line, position, text
  FROM all_errors
 WHERE name = 'PK_OL_XFINT'
 ORDER BY sequence;
-- no rows
