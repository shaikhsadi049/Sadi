# NGI XFINT — handover, 15 to 16 October 2026

Continues `NGI-206-handover.md`, which covers the `bdiMemo1` defect up to its
fix being tested in UAT. This document covers everything after that: the field
length defects the bank found on re-testing, what was fixed, and what is still
open.

**Line numbers refer to the 5574 line extract of `PK_OL_XFINT`.** The patched
script is longer; where a line in the patched file is meant, it says so.

---

## 1. Where NGI-206 ended

`bdiMemo1` over 35 characters now reaches FCC. Verified in UAT: `PM_TXN_LOG`
shows `TXN_STAT = 1` / `MSG_STAT = 5`, the `channel_swift_payment_xref` row is
written, and the FCC message carries `PAYDET1` with 35 characters and `PAYDET2`
with 25. Resolution mail sent on the existing chain.

The bank confirmed this on re-test. Then found more.

## 2. `bdiBenfBName` over 35 fails STP — same defect, second field

Reported 15 October.

`PI_BENF_BNAME` goes to `<AWI2>` at line 2665, raw. A truncation for it does
exist, at line 2198:

```sql
IF PI_BENF_BNAME IS NOT NULL AND LENGTH(PI_BENF_BNAME) > 35 THEN
  VAR_REL_TXN_STORE.CUSTOMER_BANK_NAME := SUBSTR(PI_BENF_BNAME, 1, 35);
```

but it assigns to `CUSTOMER_BANK_NAME`, which goes to
`PM_REL_TXN_STORE.NAM_CUST_BANK` (line 3823). The XML never uses it. Exactly the
`PAYDET1` pattern: the cut exists, in the wrong variable.

### The audit that followed

Rather than fix one field and wait for the next report, the whole XML block was
audited. **Nine elements were going out uncut:**

| Element | Value | Line |
|---|---|---|
| `BYODROF2` | `BENEFICIARY_NAME`, straight from `vwe_ci_custmast.NAM_CUST_SHRT` (1507) | 2650 |
| `BYODROF3` / `BYODROF4` / `BYODROF5` | `CUSTOMER_ADDRESS1/2/3`, straight from `VWE_CI_CUSTMAST_ADD` (1526) | 2652-2656 |
| `INTERMEDY3` / `INTERMEDY4` | `PI_BANK_CORESPONDENT1/2`, raw parameters | 2660, 2662 |
| `AWI2` | `PI_BENF_BNAME`, raw parameter | 2665 |
| `AWI5` | 14 chars + `,` + `PI_BENF_BCOUNTRY`, country never bounded | 2668 |
| `BENINST2` | `PI_BENF_NAME`, raw parameter | 2671 |

`AWI4` is exposed on one branch too: at line 2210, when the bank address is 35
or shorter, it takes `PI_BENF_BCOUNTRY` uncut. That field carries a country
**name**, not a code — XFINX widened its `LLD_COUNTRY` to `VARCHAR2(100)` for
that reason.

Genuinely pre-cut before the XML: `AWI3`, `AWI4` (other branches, 2212-2221),
`BENINST3` (1359), `BENINST4` (1364).

### The fix

All thirteen free-text elements now read `SWIFT_X(SUBSTR(.., 1, 35))`, including
the four that were already correct, so every element reads the same way and none
depends on an assignment hundreds of lines earlier — the habit that produced
this defect.

Truncation, not a split. Unlike `PAYDET1`-`PAYDET4`, these elements have
neighbours that are already occupied — `AWI2` is the bank name while `AWI3` to
`AWI5` hold its address — so a long value has nowhere to spill.

`SUBSTR` never lengthens a value and returns `NULL` for `NULL`, so nothing that
works today changes.

### A correction to the NGI-206 note

The NGI-206 analysis cited `AWI2` among the elements "already pre-cut to 35",
on the strength of the `SUBSTR` at 2198. That was wrong. The argument still
stands on `AWI3`, `AWI4`, `BENINST3` and `BENINST4`, but `AWI2` should not have
been in that list. Recorded in `NGI-207-xml-field-length-audit.md`.

## 3. The request to raise `bdiBenfBName` to 120

Oracle relayed that the bank wants 120, because their existing IL accepts that
length and they will send the same to NGI.

120 cannot go into `AWI2`. It is a single line of MT103 field 57, so it holds
35. `AWI2` to `AWI5` give four lines, 140 in total, but `AWI3`, `AWI4` and
`AWI5` already carry the bank address and country. A 120 character name would
need `AWI2` through part of `AWI5` and leave nothing for the address.

**Accepting 120 is not the problem.** Nothing in NGI rejects a long value — the
service takes whatever the channel sends. The question is only what reaches FCC,
and a SWIFT field 57 line cannot carry 120 whichever channel it comes through.
So IL must already be cutting it before its own FCC call, which is what
`SUBSTR(.., 1, 35)` now does here.

Put to Oracle, still unanswered: is the 120 to be stored in FCR only, or also
sent? `CUSTOMER_BANK_NAME` is already `VARCHAR2(200)`, so storing 120 needs no
change at all.

### One clarification worth keeping

Oracle asked whether `SWIFT_X` trims to 35. It does not. `SWIFT_X` only replaces
characters outside the SWIFT X set with a space, one for one, so length is
unchanged. The trimming is the `SUBSTR` wrapped inside it. Worth repeating
because it was about to be passed on to the FCC team in that form.

## 4. 16 October — two more fields, two different causes

Reported: `bdiBenfName` (max 70) fails above 35, and `bdiBenfAcct` (max 50)
fails above 49.

### `bdiBenfName` — already covered

`PI_BENF_NAME` to `<BENINST2>`, line 2671. It was one of the nine in the 15
October pass:

```sql
'</BENINST1><BENINST2>' || SWIFT_X(SUBSTR(PI_BENF_NAME, 1, 35)) ||
```

Nothing further needed. It has not been deployed yet, which is why it still
fails.

### `bdiBenfAcct` — not an XML defect at all

"Max 50, fails above 49" is one character of headroom, and that character is a
slash. Lines 2739-2748:

```sql
UPDATE PM_REL_TXN_STORE
   SET COD_CTPARTY_ACCT = '/' || VAR_COUNTER_PARTY_DETAIL.COUNTER_PARTY_ACCOUNT_ID
 WHERE REF_TXN_NO = VAR_ARD_PO_REF_TXN_NO;
EXCEPTION
  WHEN OTHERS THEN
    PO_RESPONSE_CODE    := 1001;
    PO_RESPONSE_MESSAGE := 'Update failed for PM_REL_TXN_STORE ' || substring(SQLERRM, 1, 100);
    RETURN 1;
```

* `COUNTER_PARTY_ACCOUNT_ID` is `VARCHAR2(50)` (line 81) — the account fits.
* `AP_SAVE_PAYMENT_LOG` inserts it into `COD_CTPARTY_ACCT` **without** the slash
  (line 3802) — the insert is fine at 50.
* This UPDATE, which runs only after FCC accepts, adds the slash. At 49 it
  writes 50 and fits. At 50 it writes 51 and raises `ORA-12899`.
* The handler returns 1, and the wrapper rolls the whole transaction back.

**Confirmed, not inferred:** `COD_CTPARTY_ACCT` is `VARCHAR2(50)`, verified by
query on 16 October.

Unlike the memo defect this one fails loudly — the channel gets an error and
nothing stays posted.

#### Why it cannot be fixed in the package

Truncating would corrupt an account number, and a payment would go to the wrong
place or nowhere. The slash is not optional either: XFINX's comment on the same
field records that FCC's validation re-derives the account by prefixing a slash
itself and compares it against the XML, which is why the slash is applied after
the send rather than before.

If the bank genuinely sends 50 character accounts, the column has to hold 51 —
DDL on a live table, which belongs to the DBA and the bank.

#### What IL does

IL writes the same column. Per the XFINX notes IL also stores it with the
leading slash on the standard-rate path (`/903694484449`), so IL has the same 49
character ceiling. This is not an NGI-versus-IL difference.

One query answers both what IL stores and what the accounts really look like:

```sql
SELECT MAX(LENGTH(COD_CTPARTY_ACCT)) AS longest, COUNT(*) AS rows_so_far
  FROM PM_REL_TXN_STORE;
```

Every transaction ever written to that column, IL and NGI together. If the
longest is well under 50, nobody has ever sent an account near that length and
the 50 in the mapping sheet is simply wider than reality.

## 5. Open items

| # | Item | With whom |
|---|---|---|
| 1 | **Deploy the thirteen-element script.** Fixes `bdiBenfBName` and `bdiBenfName` together. Bank asked for deployment on 16 October | ready, pending deployment |
| 2 | **FCC's accepted length per element** (`BYODROF`, `INTERMEDY`, `AWI`, `BENINST`, `PAYDET`) from the FCUBS gateway XSD or the MS payment tables. If any takes more than 35, only that number in the `SUBSTR` changes | Niraj, FCC side |
| 3 | **The real maximum for `bdiBenfAcct`.** MT103 field 59 allows 34 on that line, so 50 may be wider than anything actually sent. If 50 is real, `COD_CTPARTY_ACCT` needs widening | bank |
| 4 | **Is the 120 for `bdiBenfBName` store-only or send-too?** | bank |
| 5 | **What IL puts in `PAYDET1`-`PAYDET5`** for the same 60 character memo, `ext_ref_no 7101262870000117` | one query |
| 6 | **BR-18 masks a failed FCC push** — raised, deliberately parked. See NGI-206 handover section 7.1 | parked |
| 7 | **SIMODIS block overwrites remitter identification** on 2030 transactions (2183-2191 set from customer master, 2272-2281 overwrite with memo slices) | not raised yet |
| 8 | **`channel_txn_xref` swallows its own failure** — `WHEN OTHERS THEN NULL` at 2890-2894 | not raised yet |

Items 7 and 8 were found while reading the code. Neither has been reported to
Oracle or the bank.

## 6. The pattern worth remembering

Three defects, one shape: a value that must fit a 35 character SWIFT line is
concatenated into the message without being cut, while a correct truncation sits
a few hundred lines away assigned to a different variable. `PAYDET1` had it,
`AWI2` had it, `BENINST2` had it.

The fix applied the cut at the point of use, on every element, rather than
trusting an earlier assignment. That is what should stop the next report.

`bdiBenfAcct` is the exception and worth keeping separate in your head — it is a
database column overflowing by one character, not a SWIFT line.

## 7. Files added since the NGI-206 handover

| Path | What |
|---|---|
| `docs/NGI-207-xml-field-length-audit.md` | the full audit of the XML block, and the `AWI2` correction |
| `docs/NGI-207-benfname-benfacct.md` | the two 16 October fields, separated by cause |
| `docs/NGI-XFINT-handover-day2.md` | this document |
| `db/PK_OL_XFINT_NGI-206.sql` | updated — now carries the thirteen-element truncation as well |

`db/PK_OL_XFINT_OLD.sql` is unchanged and remains the rollback.
