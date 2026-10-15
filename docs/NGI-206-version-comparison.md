# The two XFINT/XFINX packages compared

Two different packages, not two revisions of one.

| | Earlier file | Production file |
|---|---|---|
| File | `PK_OL_XFINT.txt` | `XFINX_1_PRE_SWIFT2026.sql` |
| Package | `PK_OL_XFINT` | `PK_NGI_CAW_XFINX` |
| Entry point | `AP_OL_XFINT_S_WRAPPER` -> `AP_OL_XFINT_S_MAIN` | `AP_OL_XFINX_S_WRAPPER` only |
| Lines | 5554 | 8867 |
| Shape | wrapper (2931-3041) delegates to a main function (601-2910) | one function carries everything (796-5326) |

The service name differs by one letter, `XFINT` against `XFIN**X**`, and every
subprogram follows it. So a patch cannot be moved across by line number; it has
to be re-placed.

## What matters for NGI-206

### 1. A rejected FCC message behaves completely differently

**Earlier file** — the failure is masked. `VAR_L_SWIFT_OK := 0`, the booked legs
stay committed, `PM_TXN_LOG` is left unmarked, and the channel is told
`'0000000'` with the reason buried in the message text
(`SUCCESS-BR18: FCC push failed; ... pending ops re-push`).

**Production** (lines 4267-4285) — the transaction fails outright:

```sql
IF TRIM (SWIFT_WARN_CODE) IS NULL OR SWIFT_WARN_CODE <> 'ST-SAVE-002' THEN
    SAFE_ROLLBACK;
    PO_RESPONSE_CODE := 'ONL_BDI_008';
    PO_RESPONSE_MESSAGE := CASE WHEN SWIFT_ERR_CODE IS NOT NULL
                                THEN 'Fcc Remote Error : ' || SWIFT_ERR_CODE || ' - ' || SWIFT_ERR_DESC
                                ELSE 'Fcc Remote Error' END;
    RETURN 1;
END IF;
```

Nothing is left posted, and the FCC error code and description are handed back
to the caller.

**This decides which environment the reported transaction ran in.** The symptom
Oracle describes - the transaction posted, `TXN_STAT` / `MSG_STAT` were not
updated, the channel saw success - is the masked path. Production cannot produce
it; there the same rejection rolls back and returns `ONL_BDI_008`.

### 2. The memo cut is at a different width

| | Earlier | Production |
|---|---|---|
| `ORIGINAL_REMIT_NO` | `SUBSTR(PI_MEMO1, 1, 35)`, line 1323 | `SUBSTR(PI_MEMO1, 1, 50)`, line 1911 |

The production comment states the input length outright: *"bdiMemo1 accepts up
to 60 characters and the record field is 50, so a bare assignment raised
ORA-06502 for any long memo."* So 60 characters arriving is expected behaviour
there, and the 35 in the earlier file is the narrower of the two.

### 3. `PAYDET1` carries the whole memo in **both**

| | Earlier (2657) | Production (4088) |
|---|---|---|
| | `PI_MEMO1` | `SWIFT_X (PI_MEMO1)` |

`SWIFT_X` (708-715) is a production-only helper that reduces free text to the
SWIFT X character set with `REGEXP_REPLACE`. It substitutes character for
character, so **it does not shorten anything**. The whole memo still goes into
`PAYDET1` alone while `PAYDET2`-`PAYDET5` go out empty.

**So NGI-206 is present in production too**, with the same root cause, at line
4088 instead of 2657.

`SWIFT_X` does settle the escaping question raised against the earlier file: a
memo containing `&` or `<` is already neutralised in production.

### 4. The SIMODIS split

Same four 35-character slices in both, written differently: the earlier file
tests `> 35`, `> 70`, `> 105` (2246-2262); production uses closed ranges,
`<= 35`, `36-70`, `71-105`, `106-140`, `> 140` (2097-2152), with the trailing
slice sized to what is left rather than a flat 35. Same result, and the macro
`ENABLE_SIMODIS_DCC` gates both.

## Other differences worth knowing

* **Empty XML elements.** Production writes them paired, `<PAYDET2></PAYDET2>`,
  and carries the instruction *"All 48 of them - do not tidy these into <X/>."*
  The earlier file uses `<PAYDET2/>`. Any production edit must keep the paired
  form.
* **`LLD_COUNTRY`** is `VARCHAR2(10)` in the earlier file and `VARCHAR2(100)` in
  production, widened because the field carries a country **name**, not a code,
  and `New Zealand` overflowed 10.
* **Narrative.** Both end at 40 characters. Production trims each memo, then
  concatenates, then trims again, then truncates (2572+), which matters when the
  memo columns are `CHAR` padded.
* **Production-only subprograms:** `SWIFT_X`, `AS_FLOAT`, `SAFE_ROLLBACK`,
  `AP_calc_AND_POST_FX_Rates_TXN`, `AP_FETCH_GL_ACCT_NAME`,
  `AP_OL_CALL_GL_TXNS_SWIFT_LR`. `AP_OL_CALL_PROCESS_SC` is named
  `AP_OL_PROCESS_SC` there.
* **`channel_txn_xref`** is only read in production, for the duplicate check
  (1345). This package has no `INSERT` into it, where the earlier file writes
  one at 2802. If the row is written in production it is written somewhere else.

## Consequence for the diagnosis given earlier

The two queries suggested to Oracle - `channel_swift_payment_xref` empty and
`channel_txn_xref` present - only read that way against the **earlier**
package. In production a rejected message rolls everything back, so neither row
exists and the failure is visible in the response instead. Worth establishing
which package the failing transaction ran under before those queries are used
as evidence.
