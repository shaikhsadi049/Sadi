# NGI-206 — carry the memo over `PAYDET1`-`PAYDET4`

Agreed with Oracle on 15 October: 140 characters, split 35+35+35+35.

`PK_OL_XFINT`, function `AP_OL_XFINT_S_MAIN`, inside the `DECLARE` block that
builds `SWIFT_REQ_MESSAGE`. Three edits, nothing outside this block changes.

Line numbers below are for the 5574 line file. An earlier copy of the same
package ran to 5554 lines - identical code, 20 blank lines fewer after line 522 -
so against that copy every number here is 20 lower.

## 1. Declarations - lines 2625-2629

Was:

```sql
        DECLARE
          VAR_XML_AWI3       VARCHAR2(255);
          VAR_XML_AWI4       VARCHAR2(255);
          VAR_XML_INTERMEDY1 VARCHAR2(20);
        BEGIN
```

Now:

```sql
        DECLARE
          VAR_XML_AWI3       VARCHAR2(255);
          VAR_XML_AWI4       VARCHAR2(255);
          VAR_XML_INTERMEDY1 VARCHAR2(20);
          --  NGI-206: MT103 field 70 is 4*35x, so the memo is carried over
          --  PAYDET1-PAYDET4, 35 characters each.  The whole memo used to go
          --  into PAYDET1 alone, which FCC does not accept past 35.
          VAR_XML_PAYDET1    VARCHAR2(35);
          VAR_XML_PAYDET2    VARCHAR2(35);
          VAR_XML_PAYDET3    VARCHAR2(35);
          VAR_XML_PAYDET4    VARCHAR2(35);
        BEGIN
```

## 2. The split - after `VAR_XML_AWI4 := ...;`, line 2636

Add:

```sql
          VAR_XML_PAYDET1 := SUBSTR(PI_MEMO1, 1, 35);
          VAR_XML_PAYDET2 := SUBSTR(PI_MEMO1, 36, 35);
          VAR_XML_PAYDET3 := SUBSTR(PI_MEMO1, 71, 35);
          VAR_XML_PAYDET4 := SUBSTR(PI_MEMO1, 106, 35);
```

No `IF` is needed around these. `SUBSTR` returns `NULL` once the start position
is past the end of the string, so a 60 character memo fills `PAYDET1` and
`PAYDET2` and leaves `PAYDET3` and `PAYDET4` null, and a null memo leaves all
four null. That is why this is shorter than the SIMODIS block, which needs its
`IF` ladder because it is assigning to fields that must keep their previous
value when the memo is short.

## 3. The XML - lines 2676-2678

Was:

```sql
                               '</BENINST4><BENINST5/><PAYDET1>' ||
                               PI_MEMO1 ||
                               '</PAYDET1><PAYDET2/><PAYDET3/><PAYDET4/><PAYDET5/><MSGTYPE>MT103</MSGTYPE><VERNO>1</VERNO><LATVERNO>1</LATVERNO><PRDCODE>' ||
```

Now:

```sql
                               '</BENINST4><BENINST5/><PAYDET1>' ||
                               VAR_XML_PAYDET1 ||
                               '</PAYDET1><PAYDET2>' ||
                               VAR_XML_PAYDET2 ||
                               '</PAYDET2><PAYDET3>' ||
                               VAR_XML_PAYDET3 ||
                               '</PAYDET3><PAYDET4>' ||
                               VAR_XML_PAYDET4 ||
                               '</PAYDET4><PAYDET5/><MSGTYPE>MT103</MSGTYPE><VERNO>1</VERNO><LATVERNO>1</LATVERNO><PRDCODE>' ||
```

`PAYDET5` stays empty: field 70 has four lines, the fifth tag is part of the
FCUBS envelope but not part of the SWIFT field.

## What this does not change

* **Line 1343** still does `ORIGINAL_REMIT_NO := SUBSTR(PI_MEMO1, 1, 35)`, so
  `PM_REL_TXN_STORE.COD_ORG_REMIT` keeps holding 35 characters. Storing more of
  the memo on the payment log is a separate decision and a separate change.
* The SIMODIS block (2266-2282) is untouched, so nothing depends on
  `ENABLE_SIMODIS_DCC` here. The FCC split now happens on every standard
  transaction whatever that macro holds.
* No validation anywhere is changed. A memo longer than 140 still reaches the
  package; characters past 140 simply do not go to FCC, which is what field 70
  allows.

## Test

| Memo length | `PAYDET1` | `PAYDET2` | `PAYDET3` | `PAYDET4` |
|---|---|---|---|---|
| null | null | null | null | null |
| 20 | 20 chars | null | null | null |
| 35 | 35 chars | null | null | null |
| 36 | 35 chars | 1 char | null | null |
| **60** (the reported case) | 35 chars | 25 chars | null | null |
| 140 | 35 | 35 | 35 | 35 |
| 256 | 35 | 35 | 35 | 35 (141-256 dropped) |

After the 60 character run, confirm the push was accepted:

```sql
SELECT TXN_STAT, MSG_STAT FROM PM_TXN_LOG WHERE REF_TXN_NO = :ref;             -- 1 and 5
SELECT COUNT(*) FROM channel_swift_payment_xref WHERE ref_usr_no = :svcRqId;   -- 1
```

Both of those are what the failing transaction did not have.

## One open point

`PI_MEMO1` is free text and goes into the XML unescaped, as it always has. A
memo containing `&`, `<` or `>` makes the request malformed and FCC rejects it
for a reason that has nothing to do with length. Wrapping each slice in
`DBMS_XMLGEN.CONVERT` would fix it, but that changes what FCC receives, so it is
worth agreeing separately rather than folding into this fix. Worth asking
whether the channel already blocks those characters.
