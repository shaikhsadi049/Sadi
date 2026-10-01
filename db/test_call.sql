-- ============================================================================
-- Test call for ap_ngi_ext_mf_cif_inq after the passport change
--
-- SQL Developer: open this file and press F5 (Run Script).
--                Ctrl+Enter runs one statement only and will not work here.
--
-- IMPORTANT: the function starts with ap_val_dup_svc_req, a duplicate service
-- request check. If the trace id / service request id has been used before it
-- returns non zero and never opens the cursor. Change RQ1 below on every run,
-- or the second run will look like a failure.
-- ============================================================================

SET SERVEROUTPUT ON SIZE UNLIMITED

VARIABLE c  REFCURSOR
VARIABLE rc VARCHAR2(100)
VARIABLE rm VARCHAR2(500)

DECLARE
  var_l_ret NUMBER;
BEGIN
  var_l_ret := FCR24.ap_ngi_ext_mf_cif_inq(
                 'T1',          -- var_pi_trace_id    << change every run
                 'CH',          -- var_pi_channel_id
                 'SC',          -- var_pi_serv_code
                 'RQ1',         -- var_pi_svc_rq_id   << change every run
                 '20261001',    -- var_pi_dat_txn
                 '14508534',    -- var_pi_id          << CIF
                 '90',          -- var_pi_id_type     90 = CIF
                 :rc, :rm, :c);
  DBMS_OUTPUT.PUT_LINE('return code = ' || var_l_ret);
END;
/

PRINT rc
PRINT rm
PRINT c


-- ============================================================================
-- If PRINT c still gives trouble, run this block instead. It calls the same
-- function and prints only the three passport fields, no bind variables.
-- ============================================================================

SET SERVEROUTPUT ON SIZE UNLIMITED

DECLARE
  var_l_ret   NUMBER;
  var_l_rc    VARCHAR2(100);
  var_l_rm    VARCHAR2(500);
  var_l_cur   SYS_REFCURSOR;
  var_l_cid   NUMBER;
  var_l_cols  DBMS_SQL.DESC_TAB;
  var_l_ncols NUMBER;
  var_l_val   VARCHAR2(4000);
  var_l_rows  NUMBER := 0;
BEGIN
  var_l_ret := FCR24.ap_ngi_ext_mf_cif_inq('T2', 'CH', 'SC', 'RQ2', '20261001',
                                           '14508534', '90',
                                           var_l_rc, var_l_rm, var_l_cur);

  DBMS_OUTPUT.PUT_LINE('return code = ' || var_l_ret);
  DBMS_OUTPUT.PUT_LINE('response    = ' || var_l_rc || ' ' || var_l_rm);

  IF var_l_ret <> 0 THEN
    DBMS_OUTPUT.PUT_LINE('function returned non zero, no cursor to read');
    RETURN;
  END IF;

  var_l_cid := DBMS_SQL.TO_CURSOR_NUMBER(var_l_cur);
  DBMS_SQL.DESCRIBE_COLUMNS(var_l_cid, var_l_ncols, var_l_cols);

  -- only the three fields of this change, all of them character columns
  FOR i IN 1 .. var_l_ncols LOOP
    IF UPPER(var_l_cols(i).col_name) IN
       ('ICTYPE', 'PASSPORTNO', 'PASSPORTEXPIRYDATE') THEN
      DBMS_SQL.DEFINE_COLUMN(var_l_cid, i, var_l_val, 4000);
    END IF;
  END LOOP;

  WHILE DBMS_SQL.FETCH_ROWS(var_l_cid) > 0 LOOP
    var_l_rows := var_l_rows + 1;
    DBMS_OUTPUT.PUT_LINE('--- row ' || var_l_rows || ' ---');
    FOR i IN 1 .. var_l_ncols LOOP
      IF UPPER(var_l_cols(i).col_name) IN
         ('ICTYPE', 'PASSPORTNO', 'PASSPORTEXPIRYDATE') THEN
        DBMS_SQL.COLUMN_VALUE(var_l_cid, i, var_l_val);
        DBMS_OUTPUT.PUT_LINE(RPAD(var_l_cols(i).col_name, 20) || ' = [' ||
                             var_l_val || ']');
      END IF;
    END LOOP;
  END LOOP;

  IF var_l_rows = 0 THEN
    DBMS_OUTPUT.PUT_LINE('cursor returned no rows for this CIF');
  END IF;

  DBMS_SQL.CLOSE_CURSOR(var_l_cid);
END;
/
