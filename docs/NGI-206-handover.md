# NGI-206 — NGI XFINT, `bdiMemo1` length. Full handover

Everything established on this defect, from the bank's mail of 15 October 2026
to the fix being deployed and tested in UAT. Written to be read without the
conversation it came from.

**All line numbers refer to the 5574 line extract of `PK_OL_XFINT`** (the one
with 20 blank lines after line 522). An earlier extract of the same package ran
to 5554 lines with identical code; against that one, subtract 20 from every
number here.

---

## 1. What was reported

Bank Danamon, 15 October 2026, Jira **NGI-206**:

> NGI has a maximum length limit of 35 characters for `bdiMemo1`, which causes
> transactions to fail STP when the value exceeds this limit. Meanwhile,
> transactions processed through IL can still be successfully STP even when the
> `bdiMemo1` length is greater than 35 characters.

The wording points at a validation limit. It is not one. Nothing in NGI rejects
a long memo - the channel sends up to 256 characters and the service accepts
them.

## 2. The evidence that settled it

`defect_log_xfint_uat_bdiMemo1_Length.xlsx` holds three UAT runs from 14
October, identical in every field except the memo:

| Sheet | Channel | `bdiMemo1` | `ref_txn_no` | `svcRqId` | FCC `ext_ref_no` | Outcome |
|---|---|---|---|---|---|---|
| NGI | REST | **60** | 182092026101423293500025460742 | 20250806LLSWIFTLINUX77 | 7101262870000116 | **no FCC message** |
| IL | PCM XML | 60 | 182092026101423375300025460743 | 26101401061930799981 | 7101262870000117 | ok |
| NGI 35 CHAR | REST | 35 | 182092026101423521400025460744 | 20250806LLSWIFTLINUX78 | 7101262870000118 | ok |

The memo, cut to two lengths:

```
60: 2012/SIN5030348(1163.68)SIN5035358(23558.48)SIN5035351(1328)
35: 2012/SIN5030348(1163.68)SIN5035358(
```

The 35 character run is the control. Same account, same beneficiary, same
amount, same everything - and it reached FCC. That rules out every explanation
except the memo, and narrows it to how the memo is placed in the FCC message.

The failing run's response is worth keeping in mind:

```json
"responseMessage": "Success",
"responseCode": "0000000",
"success": true
```

The channel was told the transaction succeeded.

## 3. Root cause

In `AP_OL_XFINT_S_MAIN`, where `SWIFT_REQ_MESSAGE` is built, **line 2677**:

```sql
'</BENINST4><BENINST5/><PAYDET1>' ||
PI_MEMO1 ||
'</PAYDET1><PAYDET2/><PAYDET3/><PAYDET4/><PAYDET5/><MSGTYPE>MT103</MSGTYPE>...
```

The whole memo goes into `PAYDET1` while `PAYDET2` to `PAYDET5` go out empty.

`PAYDET` is **one line of MT103 field 70**, whose format is `4*35x` - four
lines of 35 characters. So a single `PAYDET` element carries 35, and the four
lines together carry 140. Sixty characters in `PAYDET1` overflows one line, and
FCC does not accept the message.

That every sibling element in the same XML is pre-cut to 35 before it is
concatenated is what makes this plainly a defect rather than an FCC limitation:

| Element | Cut at | Line |
|---|---|---|
| `AWI2` (beneficiary bank name) | 35 | 2198 |
| `AWI3` / `AWI4` / `AWI5` (bank address) | 35 | 2208-2224 |
| `BENINST3` / `BENINST4` (counterparty address) | 35 | 1357-1366 |
| `PAYDET1` (the memo) | **not cut** | 2677 |

### Why the channel still saw success

This is the second half of the defect and the reason it was the bank, not us,
who found it.

| Line | What happens |
|---|---|
| 839 | `VAR_L_SWIFT_OK NUMBER := 1;` |
| 2725-2733 | any FCC warning code other than `ST-SAVE-002` sets `VAR_L_SWIFT_OK := 0` |
| 2736-2772 | skipped, so **`PM_TXN_LOG.TXN_STAT = 1` and `MSG_STAT = 5` are never set**, and `PM_REL_TXN_STORE.COD_CTPARTY_ACCT` never gets its leading `/` |
| 2779-2814 | skipped, so **no `channel_swift_payment_xref` row is written** |
| 2899-2905 | `PO_RESPONSE_CODE := '0000000'` regardless, with the real outcome only in `PO_RESPONSE_MESSAGE`: `SUCCESS-BR18: FCC push failed; booked legs committed, pending ops re-push.` |

The comment at line 2692 states the intent: *"BR-18: a failed FCC push is
swallowed - the booked legs stay committed and the channel still gets a
success."*

So the legs post, the customer is debited, SWIFT never goes out, the status is
never marked, and the channel is told `0000000`. That is a transaction that
does not go straight through while NGI reports no error - exactly the bank's
complaint, and invisible from our side.

## 4. The fix

Two changes, both inside the `DECLARE` block of `AP_OL_XFINT_S_MAIN` that
builds `SWIFT_REQ_MESSAGE`. Nothing outside the FCC message is touched.

### 4.1 Split the memo over `PAYDET1`-`PAYDET4`

Agreed with Oracle (Harsh) on 15 October: 140 characters, 35+35+35+35.

Declarations, after `VAR_XML_INTERMEDY1` at line 2628:

```sql
VAR_XML_PAYDET1    VARCHAR2(35);
VAR_XML_PAYDET2    VARCHAR2(35);
VAR_XML_PAYDET3    VARCHAR2(35);
VAR_XML_PAYDET4    VARCHAR2(35);
```

The split, after `VAR_XML_AWI4 := ...` at line 2636:

```sql
VAR_XML_PAYDET1 := SUBSTR(PI_MEMO1, 1, 35);
VAR_XML_PAYDET2 := SUBSTR(PI_MEMO1, 36, 35);
VAR_XML_PAYDET3 := SUBSTR(PI_MEMO1, 71, 35);
VAR_XML_PAYDET4 := SUBSTR(PI_MEMO1, 106, 35);
```

No `IF` ladder is needed. `SUBSTR` returns `NULL` once the start position is
past the end of the string, so a short memo leaves the later lines null on its
own. (The SIMODIS block at 2266-2282 needs its `IF` ladder only because it
assigns to fields that must keep a previous value.)

The XML, lines 2676-2678:

```sql
'</BENINST4><BENINST5/><PAYDET1>' ||
SWIFT_X(VAR_XML_PAYDET1) ||
'</PAYDET1><PAYDET2>' ||
SWIFT_X(VAR_XML_PAYDET2) ||
'</PAYDET2><PAYDET3>' ||
SWIFT_X(VAR_XML_PAYDET3) ||
'</PAYDET3><PAYDET4>' ||
SWIFT_X(VAR_XML_PAYDET4) ||
'</PAYDET4><PAYDET5/><MSGTYPE>MT103</MSGTYPE>...
```

`PAYDET5` stays empty: field 70 has four lines, the fifth tag belongs to the
FCUBS envelope, not to the SWIFT field.

For the reported memo this produces:

| | Value | Length |
|---|---|---|
| `PAYDET1` | `2012/SIN5030348(1163.68)SIN5035358(` | 35 |
| `PAYDET2` | `23558.48)SIN5035351(1328)` | 25 |
| `PAYDET3` | `NULL` | - |
| `PAYDET4` | `NULL` | - |

`PAYDET1` is now byte for byte the memo the 35 character control run sent and
FCC accepted on `7101262870000118`.

### 4.2 `SWIFT_X`

Free text was concatenated into the XML unescaped, so a memo containing `&` or
`<` makes the request malformed and FCC rejects it - a failure identical in
symptom to the one above but with nothing to do with length.

Added to the package **body** before `AP_OL_RESET_TXN_CACHE`, so the
specification is unchanged and only the body recompiles:

```sql
FUNCTION SWIFT_X(P_TEXT IN VARCHAR2) RETURN VARCHAR2 IS
BEGIN
  RETURN REGEXP_REPLACE(P_TEXT, q'{[^A-Za-z0-9/?:().,'+ -]}', ' ');
END SWIFT_X;
```

**This matches IL, and that is documented rather than assumed.** The
`PK_NGI_CAW_XFINX` package carries the same helper with the evidence in its
comment: the customer is stored as ``WILLIAM AGUS`SE`` and the backtick
survives 16 times in the IL log, so the logger is not stripping it - but inside
IL's own FCC message it is a space, `<BYODROF2>WILLIAM AGUS SE</BYODROF2>`,
while `<BYODROF4>001/012</BYODROF4>` keeps its slash.

Two things follow:

1. IL does not clean only `&` and `<`. It reduces the message text to the SWIFT
   X character set - anything outside `A-Za-z0-9` and `/ - ? : ( ) . , ' +` and
   space becomes a space.
2. **IL cleans the message text only.** The stored columns keep the original,
   which is why `PM_REL_TXN_STORE` still shows the backtick. So `SWIFT_X` must
   not be applied to `ORIGINAL_REMIT_NO` or anything `AP_SAVE_PAYMENT_LOG`
   writes.

Thirteen free-text elements are wrapped. Ten are the ones XFINX wraps:
`BYODROF2`, `BYODROF3`, `BYODROF4`, `BYODROF5`, `AWI2`, `AWI3`, `AWI4`,
`BENINST2`, `BENINST3`, `PAYDET1`. The other three - `INTERMEDY3`,
`INTERMEDY4`, `AWI5`, `BENINST4` - are elements XFINX leaves empty, so the IL
log proves nothing about them; they are wrapped anyway because they are free
text reaching the same XML and an unwrapped one leaves the same hole open.
Dropping those four `SWIFT_X(..)` calls keeps strictly to the IL-evidenced ten.

Note the reported memo contains nothing outside the SWIFT X set, so `SWIFT_X`
does not alter it and the UAT re-test exercised the split alone.

### 4.3 What is deliberately NOT changed

* **Line 1343** still does `ORIGINAL_REMIT_NO := SUBSTR(PI_MEMO1, 1, 35)`, so
  `PM_REL_TXN_STORE.COD_ORG_REMIT` keeps 35 characters. How much of the memo is
  *stored* is a separate question from what is *sent*.
* The SIMODIS block (2266-2282) is untouched, so the FCC split no longer
  depends on `ba_site.ENABLE_SIMODIS_DCC` at all.
* No validation anywhere. A memo over 140 still reaches the package; the
  characters past 140 simply are not sent, which is all field 70 allows.
* **BR-18 masking is untouched.** See open points.

## 5. Deployment

The first deploy left the package invalid and the service returned:

```
ORA-06550: PLS-00905: object NCBSHOST.PK_OL_XFINT is invalid
```

Cause: the script was built from an `ALL_SOURCE` extract, which carries **no
`/` terminators**. Without one after the specification's `END PK_OL_XFINT;`,
SQL*Plus never submits it and reads the body as a continuation of the same
statement.

The delivered scripts carry a `/` after the specification and after the body,
and nothing else - no `SET` commands, no `SHOW ERRORS`.

```sql
@PK_OL_XFINT_NGI-206.sql

SELECT object_name, object_type, status FROM all_objects
 WHERE object_name = 'PK_OL_XFINT';          -- PACKAGE and PACKAGE BODY both VALID

SELECT line, position, text FROM all_errors
 WHERE name = 'PK_OL_XFINT' ORDER BY sequence;  -- no rows
```

Only the body changed, so deploying the body alone is enough. No JAR change, no
DB object created or dropped. Rollback is `PK_OL_XFINT_OLD.sql`, which is the
pre-change source byte for byte with only the two terminators added.

A structural check against the original extract gave `BEGIN +1, END +1,
FUNCTION +1`, and zero for `IF`, `LOOP` and `CASE` - that is `SWIFT_X` and
nothing else.

## 6. Verification

Deployed to the UAT Linux environment, compiled clean, both objects `VALID`,
no rows in `ALL_ERRORS`.

The reported case was re-posted with the same 60 character memo. `PM_TXN_LOG`
shows `TXN_STAT = 1` and `MSG_STAT = 5`, the `channel_swift_payment_xref` row
is written, the FCC message carries `PAYDET1` with 35 characters and `PAYDET2`
with 25, and `PM_REL_TXN_STORE` reads exactly as before the change.

`docs/NGI-206-verify.sql` holds the queries, including a dry run that applies
the patched `SUBSTR` and `REGEXP_REPLACE` to a memo in a plain `SELECT`, so the
logic can be checked without deploying anything.

When re-firing, use a **new `svcRqId`** - the duplicate check reads
`channel_txn_xref` by `REF_USR_NO`. And copy the `lldInfo` line whole: its
trailing spaces are significant (`USA0YA012`, spaces to column 57, then
`LUX SIMODIS 1`).

## 7. Open points

### 7.1 BR-18 masks a failed FCC push (raised, deliberately not actioned)

The rollback machinery already exists and is simply not used:

| Line | |
|---|---|
| 3004 | `SAVEPOINT SP_OL_XFINT_START;` at the top of the wrapper |
| 2993-3002 | `AP_OL_UNDO_TXN` = `ROLLBACK TO SAVEPOINT SP_OL_XFINT_START` |
| 3046-3049 | the wrapper calls it whenever the main function returns non-zero |

So returning 1 instead of 0 at the SWIFT-failure point would roll everything
back on its own. `PK_NGI_CAW_XFINX` does exactly that at its equivalent point:
`SAFE_ROLLBACK`, `PO_RESPONSE_CODE := 'ONL_BDI_008'`,
`'Fcc Remote Error : ' || SWIFT_ERR_CODE || ' - ' || SWIFT_ERR_DESC`,
`RETURN 1`.

Two things to settle before changing it:

* **Is BR-18 copied from IL?** The `BR-` prefix suggests a business rule derived
  from IL analysis. If IL also posts the legs and reports success, changing NGI
  breaks the parity the bank asked for. XFINX rolling back is suggestive but not
  proof, since it is a different service. The IL code for this point needs
  reading.
* **What does ops do today?** The message says *"pending ops re-push"*. A
  rollback removes the transaction they would re-push, so the customer must
  send it again. That is a business decision, not a code one.

A middle option: keep the legs but return a distinct response code rather than
`0000000`, so the channel can tell that SWIFT did not go out while the ops
re-push process survives.

Decision as of now: **not actioned, raise separately.** It was kept out of
NGI-206 so the tested fix is not re-opened.

### 7.2 The SIMODIS block overwrites remitter identification

Lines 2183-2191 set `REMITTER_NAME`, `REMITTER_NATL_ID` and `REMITTER_PHONE`
from the customer master on the special-rate path (mnemonic `2030`). The
SIMODIS block at 2272-2281 then **overwrites all three** with memo slices
whenever the memo is longer than 35. On a `2030` transaction with a long memo,
the real remitter name, national id and phone are replaced by memo text in
`PM_REL_TXN_STORE`. Independent of NGI-206, not raised yet.

### 7.3 `channel_txn_xref` swallows its own failure

Lines 2822-2894 insert the raw `PI_MEMO1` and `PI_MEMO2` into `FROM_MEMO_1`,
`FROM_MEMO_2`, `TO_MEMO_1`, `TO_MEMO_2`, and the handler is
`WHEN OTHERS THEN NULL`. If a column is narrower than the memo, `ORA-12899` is
swallowed and the whole row is silently not written - and that row is what the
next day's duplicate check reads. Worth checking the column widths.

### 7.4 The 140 ceiling

MT103 field 70 holds 140 characters whatever is agreed, so a longer memo still
cannot be carried in full. BDI should confirm the agreed maximum for `bdiMemo1`
and whether a longer memo should be rejected at the channel rather than carried
partially.

### 7.5 Unverified: what IL actually puts in `PAYDET1`-`PAYDET5`

The split matches the SWIFT format and matches the control run, but IL's own
message for the same 60 characters has not been read. One query settles it:

```sql
SELECT ext_ref_no, paydet1, paydet2, paydet3, paydet4
  FROM fccprd.mstm_com_pmt_in
 WHERE ext_ref_no = '7101262870000117';
```

### 7.6 `ENABLE_SIMODIS_DCC`

Decides whether the payment log keeps 35 or 140 characters of the memo - a
separate question from the FCC message, which now carries 140 either way. Its
value per environment has not been read:

```sql
SELECT MACRO_VALUE FROM ba_site
 WHERE MACRO_NAME = 'ENABLE_SIMODIS_DCC' AND FLG_MNT_STATUS = 'A';
```

## 8. Reference — where the memo goes

`AP_SAVE_PAYMENT_LOG` is called at line 2297, after both cuts, and inserts into
`PM_REL_TXN_STORE` (columns at 3770-3773, values at 3828-3831):

| Column | Source | Content |
|---|---|---|
| `COD_ORG_REMIT` | `ORIGINAL_REMIT_NO` | memo 1-35, always |
| `NAM_REMITTER` | `REMITTER_NAME` | memo 36-70, SIMODIS only |
| `REMITTER_NATL_ID` | `REMITTER_NATL_ID` | memo 71-105, SIMODIS only |
| `PHONE_REMITTER` | `REMITTER_PHONE` | memo 106-140, SIMODIS only |
| `TXT_NARRATIVE` | `NARRATIVE` | memo1 + memo2 cut to 40, line 1602 |

## 9. The other package

`PK_NGI_CAW_XFINX` (`XFINX_1_PRE_SWIFT2026.sql`, 8867 lines) is a **different
package**, not a revision of this one - `AP_OL_XFINX_S_WRAPPER` carries
everything in one function, where `PK_OL_XFINT` splits wrapper and main. It was
used here only as a reference for `SWIFT_X` and for how a rejected FCC reply is
handled. Differences that matter if the two are ever compared:

| | `PK_OL_XFINT` | `PK_NGI_CAW_XFINX` |
|---|---|---|
| FCC rejection | masked, `0000000`, legs committed | `SAFE_ROLLBACK`, `ONL_BDI_008`, `RETURN 1` |
| `ORIGINAL_REMIT_NO` | `SUBSTR(.., 1, 35)` | `SUBSTR(.., 1, 50)` |
| XML escaping | none (until this fix) | `SWIFT_X` throughout |
| Empty XML elements | `<PAYDET2/>` | `<PAYDET2></PAYDET2>`, with *"All 48 of them - do not tidy these into `<X/>`"* |
| `LLD_COUNTRY` | `VARCHAR2(10)` | `VARCHAR2(100)` |

## 10. Files

In `shaikhsadi049/Sadi`, branch `claude/wizardly-ptolemy-dv6zrp`:

| Path | What |
|---|---|
| `db/PK_OL_XFINT_NGI-206.sql` | the patched package, deploy this |
| `db/PK_OL_XFINT_OLD.sql` | pre-change package, rollback |
| `db/NGI-206-README.md` | deploy and verify steps |
| `docs/NGI-206-verify.sql` | verification queries, with the three UAT references |
| `docs/NGI-206-handover.md` | this document |
| `docs/NGI-206-xfint-bdimemo1.md` | the original analysis, with the full line trace |
| `docs/NGI-206-paydet-split-patch.md` | the PAYDET patch on its own |
| `docs/NGI-206-swift-x-patch.md` | the `SWIFT_X` patch on its own |
| `docs/NGI-206-version-comparison.md` | `PK_OL_XFINT` against `PK_NGI_CAW_XFINX` |
| `docs/ngi-206-resolution-email.html` | the resolution mail |
| `requests/` | the three UAT request payloads, ready to re-fire |
