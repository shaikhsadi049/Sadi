-- ============================================================================
-- NGI-206 - verification, with the three UAT transactions from
-- defect_log_xfint_uat_bdiMemo1_Length.xlsx (14 October 2026)
--
--  sheet         bdiMemo1  ref_txn_no                        svcRqId                  FCC ext_ref_no    outcome
--  ------------  --------  --------------------------------  -----------------------  ----------------  -------
--  NGI               60    182092026101423293500025460742    20250806LLSWIFTLINUX77   7101262870000116  no FCC message
--  IL                60    182092026101423375300025460743    26101401061930799981     7101262870000117  ok
--  NGI 35 CHAR       35    182092026101423521400025460744    20250806LLSWIFTLINUX78   7101262870000118  ok
--
-- All three carry the same memo text, cut to a different length:
--   60: 2012/SIN5030348(1163.68)SIN5035358(23558.48)SIN5035351(1328)
--   35: 2012/SIN5030348(1163.68)SIN5035358(
-- ============================================================================


-- ----------------------------------------------------------------------------
-- 0.  Dry run.  No deployment needed - these are the patched expressions,
--     copied verbatim, run against the real memo.
-- ----------------------------------------------------------------------------
WITH t AS (SELECT '2012/SIN5030348(1163.68)SIN5035358(23558.48)SIN5035351(1328)' AS memo FROM dual)
SELECT LENGTH(memo)                                                             AS memo_len,
       REGEXP_REPLACE(SUBSTR(memo,   1, 35), q'{[^A-Za-z0-9/?:().,'+ -]}', ' ') AS paydet1,
       REGEXP_REPLACE(SUBSTR(memo,  36, 35), q'{[^A-Za-z0-9/?:().,'+ -]}', ' ') AS paydet2,
       REGEXP_REPLACE(SUBSTR(memo,  71, 35), q'{[^A-Za-z0-9/?:().,'+ -]}', ' ') AS paydet3,
       REGEXP_REPLACE(SUBSTR(memo, 106, 35), q'{[^A-Za-z0-9/?:().,'+ -]}', ' ') AS paydet4
  FROM dual, t;

-- Expected:
--   memo_len 60
--   paydet1  2012/SIN5030348(1163.68)SIN5035358(     <- 35, identical to the
--                                                       memo the NGI 35 CHAR
--                                                       run sent and FCC took
--   paydet2  23558.48)SIN5035351(1328)               <- 25
--   paydet3  NULL
--   paydet4  NULL
--
-- Note this memo holds nothing outside the SWIFT X set - only digits, letters,
-- / ( ) . - so SWIFT_X leaves it untouched and this run tests the PAYDET split
-- on its own.  A memo with '&' is a separate test, section 5.


-- ----------------------------------------------------------------------------
-- 1.  The three transactions side by side.  This is the evidence the fix is
--     aimed at: the 35 character run and the IL run reached FCC, the 60
--     character NGI run did not.
-- ----------------------------------------------------------------------------
SELECT REF_TXN_NO, TXN_STAT, MSG_STAT, REF_USR_NO
  FROM ncbshost.pm_txn_log
 WHERE REF_TXN_NO IN ('182092026101423293500025460742',   -- NGI 60
                      '182092026101423375300025460743',   -- IL  60
                      '182092026101423521400025460744');  -- NGI 35

-- The 60 character NGI row should differ from the other two: TXN_STAT and
-- MSG_STAT were never set to 1 and 5, because that UPDATE sits inside the
-- IF VAR_L_SWIFT_OK = 1 block that a rejected FCC reply skips.


-- ----------------------------------------------------------------------------
-- 2.  The FCC side.  This is the question the bank actually asked - whether
--     the message arrived.
-- ----------------------------------------------------------------------------
SELECT ext_ref_no, paydet1, paydet2, paydet3, paydet4
  FROM fccprd.mstm_com_pmt_in
 WHERE ext_ref_no IN ('7101262870000116',   -- NGI 60, expect NO ROW
                      '7101262870000117',   -- IL  60
                      '7101262870000118');  -- NGI 35

-- Two things to read here:
--   * whether 7101262870000116 exists at all;
--   * what IL put in PAYDET1..PAYDET5 for the same 60 characters, which tells
--     us whether IL splits the memo or truncates it.  That is the one open
--     question the fix still rests on.


-- ----------------------------------------------------------------------------
-- 3.  What each run stored.  The patch does not touch any of this, so these
--     values must read the same before and after.
-- ----------------------------------------------------------------------------
SELECT REF_TXN_NO,
       COD_ORG_REMIT,  LENGTH(COD_ORG_REMIT) AS remit_len,
       NAM_REMITTER,   REMITTER_NATL_ID, PHONE_REMITTER,
       TXT_NARRATIVE,  LENGTH(TXT_NARRATIVE) AS narrative_len,
       COD_CTPARTY_ACCT
  FROM PM_REL_TXN_STORE
 WHERE REF_TXN_NO IN ('182092026101423293500025460742',
                      '182092026101423375300025460743',
                      '182092026101423521400025460744');

-- COD_ORG_REMIT is memo 1-35 on every path.
-- COD_CTPARTY_ACCT gets its leading '/' only after FCC accepts, so the 60
-- character NGI row should be missing the slash the other two have.
-- TXT_NARRATIVE is memo1 + memo2 cut to 40, so all three should hold
-- "2012/SIN5030348(1163.68)SIN5035358(23558" or the 35 character equivalent.


-- ----------------------------------------------------------------------------
-- 4.  The SIMODIS macro.  It decides whether the payment log keeps 35 or 140
--     characters of the memo.  Separate from the FCC message, which carries
--     140 after the fix either way.
-- ----------------------------------------------------------------------------
SELECT MACRO_NAME, MACRO_VALUE, FLG_MNT_STATUS
  FROM ba_site
 WHERE MACRO_NAME = 'ENABLE_SIMODIS_DCC';

-- If this is 'Y', NAM_REMITTER on the 60 character runs should hold
-- "23558.48)SIN5035351(1328)" - memo 36-60.  If it is not 'Y', those three
-- remitter columns carry customer master values or nothing.


-- ----------------------------------------------------------------------------
-- 5.  After deployment.
-- ----------------------------------------------------------------------------
SELECT object_name, object_type, status
  FROM all_objects
 WHERE object_name = 'PK_OL_XFINT';
-- PACKAGE and PACKAGE BODY both VALID

SELECT line, position, text
  FROM all_errors
 WHERE name = 'PK_OL_XFINT'
 ORDER BY sequence;
-- no rows

-- Then re-post the failing case with the same 60 character memo and read
-- sections 1, 2 and 3 again.  Pass means: TXN_STAT 1 / MSG_STAT 5, a row in
-- mstm_com_pmt_in with PAYDET1 holding 35 characters and PAYDET2 holding 25,
-- and PM_REL_TXN_STORE reading exactly as it does today.
--
-- Then one more run with '&' in the memo, for the SWIFT_X half of the change:
-- it should reach FCC with the '&' as a space, while PM_REL_TXN_STORE keeps
-- the original character.
