# NGI XFINT — `bdiMemo1` is cut to 35 characters (NGI-206)

Defect **NGI-206**, raised by Bank Danamon on 15 October 2026. Service: **NGI
XFINT**. Package studied: `PK_OL_XFINT` (5554 lines), `bdiMemo1` arrives as
`PI_MEMO1`.

The channel sends up to 256 characters. The cut is in the package, not in the
Java validation.

## Where the 35 comes from

`35` appears against the memo in exactly two places, both inside
`AP_OL_XFINT_S_MAIN` (lines 601-2910), and they run in this order:

### 1. Line 1323 — unconditional, this is the cut

```sql
VAR_REL_TXN_STORE.ORIGINAL_REMIT_NO := SUBSTR(PI_MEMO1, 1, 35);
```

It runs on **every** transaction. The comment above it (lines 1317-1322) says it
was added under **NGI-197** to stop a long memo raising `ORA-06502` before the
SIMODIS block is reached, and that it cuts to "the same 35 characters the
SIMODIS path uses". `ORIGINAL_REMIT_NO` is declared `VARCHAR2(50)` (line 101),
so the field itself would hold 50; the 35 is a choice, not the field's limit.

### 2. Lines 2246-2262 — the SIMODIS split, macro gated

```sql
IF VAR_MACRO_SIMODIS_DCC = 'Y' AND PI_MEMO1 IS NOT NULL THEN
  VAR_REL_TXN_STORE.ORIGINAL_REMIT_NO := SUBSTR(PI_MEMO1, 1, 35);
  IF var_l_memo_length >  35 THEN ... REMITTER_NAME     := SUBSTR(PI_MEMO1,  36, 35);
  IF var_l_memo_length >  70 THEN ... REMITTER_NATL_ID  := SUBSTR(PI_MEMO1,  71, 35);
  IF var_l_memo_length > 105 THEN ... REMITTER_PHONE    := SUBSTR(PI_MEMO1, 106, 35);
```

The gate is `ba_site.MACRO_VALUE` for `MACRO_NAME = 'ENABLE_SIMODIS_DCC'`,
read at lines 2227-2231. Nothing handles characters past 140.

### What a 256 character memo therefore produces

| `ENABLE_SIMODIS_DCC` | Kept | Lost |
|---|---|---|
| `'Y'` | 1-140, in four pieces | **141-256** |
| anything else | **1-35 only** (line 1323) | **36-256** |

The second row is the likely one in the bank's environment: a single
35-character value and nothing else, which is what they are reporting.

## Where those pieces land

`AP_SAVE_PAYMENT_LOG` is called at line 2277, after both cuts, and inserts into
`PM_REL_TXN_STORE` (columns at lines 3750-3753 and 3808-3811):

| Column | Value | Length |
|---|---|---|
| `COD_ORG_REMIT` | `ORIGINAL_REMIT_NO` | memo 1-35 |
| `NAM_REMITTER` | `REMITTER_NAME` | memo 36-70, SIMODIS only |
| `REMITTER_NATL_ID` | `REMITTER_NATL_ID` | memo 71-105, SIMODIS only |
| `PHONE_REMITTER` | `REMITTER_PHONE` | memo 106-140, SIMODIS only |
| `TXT_NARRATIVE` | `NARRATIVE` | **memo1+memo2 cut to 40**, line 1582 |

The narrative is a separate, third cut: line 1582 sets
`SUBSTR(TRIM(TRIM(PI_MEMO1) || TRIM(PI_MEMO2)), 1, 40)`, and the ledger legs take
the same value through `VAR_TXN_DESC_NARRATIVE` (line 1890) with
`'Outgoing Payment Initiation'` as the fallback. `NARRATIVE` is `VARCHAR2(200)`
(line 103) and `VAR_L_NARRATIVE` is `VARCHAR(255)` (line 741), so the 40 is also
a choice rather than a field limit.

## Two places that still get the whole 256, uncut

* **Line 2657** — `<PAYDET1>` in the FCUBS `CreateCPMessage` XML gets
  `PI_MEMO1` raw, while every other field in that same XML is pre-cut to 35
  (beneficiary name 2178, bank address 2188-2204, counterparty address
  1337-1346). `SWIFT_REQ_MESSAGE` is `VARCHAR2(32767)` (line 853), so nothing
  raises locally — the full 256 is handed to FCC.
* **Lines 2866-2869** — `channel_txn_xref.FROM_MEMO_1 / TO_MEMO_1` are inserted
  raw, and that insert's handler is `WHEN OTHERS THEN NULL` (lines 2870-2874).
  If the column is narrower than the memo, `ORA-12899` is swallowed and the
  whole xref row is silently not written — the row the next day's duplicate
  check reads back.

## How this becomes "fails STP"

`<PAYDET1>` is MT103 field 70, which SWIFT caps at 4 lines of 35 = 140
characters. A 256 character memo is over that, so FCC is expected to reject the
message. What the package then does:

1. Line 2705-2713 — any warning code other than `ST-SAVE-002` sets
   `VAR_L_SWIFT_OK := 0`.
2. Lines 2716-2752 are skipped, so **`PM_TXN_LOG.TXN_STAT = 1`,
   `MSG_STAT = 5`** and the `PM_REL_TXN_STORE.COD_CTPARTY_ACCT` update never
   happen.
3. Lines 2759 and 2794 — `channel_txn_xref` and `channel_swift_payment_xref`
   are not written.
4. Line 2880 — **`PO_RESPONSE_CODE := '0000000'` all the same.** BR-18 returns
   success to the channel, with line 2882-2885 putting the real outcome in the
   message: `SUCCESS-BR18: FCC push failed; booked legs committed, pending ops
   re-push.`

So the legs post, the channel is told success, the SWIFT message never goes out
and the transaction status is never marked — it waits for ops to re-push. That
is a transaction that does not go straight through while NGI reports no error,
which matches the report exactly. IL does not go down this path, so it STPs.

## Separate bug found on the way

Lines 2163-2171 set `REMITTER_NAME`, `REMITTER_NATL_ID` and `REMITTER_PHONE`
from the customer master on the special-rate path (mnemonic `2030`). The SIMODIS
block at lines 2252-2261 then **overwrites all three** with memo slices whenever
the memo is longer than 35. On a `2030` transaction with a long memo, the real
remitter name, national id and phone are replaced by memo text in
`PM_REL_TXN_STORE`. This is independent of NGI-206 and should be raised on its
own.

## To confirm before changing anything

1. `SELECT MACRO_VALUE FROM ba_site WHERE MACRO_NAME = 'ENABLE_SIMODIS_DCC' AND FLG_MNT_STATUS = 'A';`
   in each environment — it decides whether 35 or 140 characters survive.
2. The `VAR_L_SWIFT_FAIL_REASON` text on a failing transaction, which is
   returned in `PO_RESPONSE_MESSAGE` — it names what FCC actually said.
3. `ALL_TAB_COLUMNS.DATA_LENGTH` for `PM_REL_TXN_STORE.COD_ORG_REMIT`,
   `TXT_NARRATIVE` and `channel_txn_xref.FROM_MEMO_1`.
4. What IL writes for the same transaction, and what the agreed `bdiMemo1`
   length is in the XFINT mapping sheet. MT103 field 70 caps the SWIFT leg at
   140 whatever is agreed, so above 140 the question is what to do with the
   remainder, not how to widen a column.
