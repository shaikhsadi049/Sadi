# NGI XFINT — every free-text element in the FCC message, audited

Raised after NGI-206: with the memo fixed, a `bdiBenfBName` longer than 35
characters stops the transaction going STP. It is the same defect in a second
field, and it is not the last one. This is the full audit of the XML block in
`AP_OL_XFINT_S_MAIN`, so the remaining ones can be fixed in a single change
instead of being reported one at a time.

Line numbers are for the 5574 line extract of `PK_OL_XFINT`.

## The pattern

Every element in that message is one SWIFT line and carries 35 characters.
Some elements are given a value that was already cut to 35; others are given a
raw parameter or a raw column. The cut often exists a few hundred lines
earlier, but is assigned to a **different variable** than the one the XML uses.

`bdiBenfBName` is exactly that:

```sql
-- line 2198: the cut exists, and goes to the payment log field
IF PI_BENF_BNAME IS NOT NULL AND LENGTH(PI_BENF_BNAME) > 35 THEN
  VAR_REL_TXN_STORE.CUSTOMER_BANK_NAME := SUBSTR(PI_BENF_BNAME, 1, 35);
ELSE
  VAR_REL_TXN_STORE.CUSTOMER_BANK_NAME := PI_BENF_BNAME;
END IF;

-- line 2665: the XML uses the raw parameter instead
PI_BENF_BNAME || '</AWI2><AWI3>' ||
```

`CUSTOMER_BANK_NAME` goes to `PM_REL_TXN_STORE.NAM_CUST_BANK` (line 3823) and
is correct there. `AWI2` never sees it.

## The audit

| Line | Element | Value sent | Cut to 35 before the XML? |
|---|---|---|---|
| 2650 | `BYODROF2` | `VAR_REL_TXN_STORE.BENEFICIARY_NAME` | **No** — read straight from `vwe_ci_custmast.NAM_CUST_SHRT` at 1507, field is `VARCHAR2(200)` |
| 2652 | `BYODROF3` | `CUSTOMER_ADDRESS1` | **No** — `VWE_CI_CUSTMAST_ADD.LINE1` at 1526 |
| 2654 | `BYODROF4` | `CUSTOMER_ADDRESS2` | **No** — `LINE2` |
| 2656 | `BYODROF5` | `CUSTOMER_ADDRESS3` | **No** — `LINE3` |
| 2660 | `INTERMEDY3` | `PI_BANK_CORESPONDENT1` | **No** — raw parameter |
| 2662 | `INTERMEDY4` | `PI_BANK_CORESPONDENT2` | **No** — raw parameter |
| 2664 | `AWI1` | `PI_BENF_ID` | n/a, a BIC is 8 or 11 |
| 2665 | `AWI2` | `PI_BENF_BNAME` | **No** ← **the reported defect** |
| 2666 | `AWI3` | `VAR_XML_AWI3` = `CUSTOMER_BANK_ADDRESS1` | Yes, 2212-2221 |
| 2667 | `AWI4` | `VAR_XML_AWI4` = `CUSTOMER_BANK_ADDRESS2` | Yes when the address is over 35 — **but on the `<= 35` branch at line 2210 it is `PI_BENF_BCOUNTRY`, uncut** |
| 2668 | `AWI5` | `CUSTOMER_BANK_ADDRESS3` | **Partly** — 14 characters plus `','` plus `PI_BENF_BCOUNTRY`, and the country is never bounded, so a country longer than 20 characters overflows |
| 2671 | `BENINST2` | `PI_BENF_NAME` | **No** — raw parameter |
| 2673 | `BENINST3` | `ADDRESS_LINE_1` | Yes, 1359 |
| 2675 | `BENINST4` | `ADDRESS_LINE_2` | Yes, 1364 |
| 2677 | `PAYDET1`-`PAYDET4` | memo | Yes, NGI-206 |

**Nine elements can still exceed 35**: `BYODROF2`, `BYODROF3`, `BYODROF4`,
`BYODROF5`, `INTERMEDY3`, `INTERMEDY4`, `AWI2`, `AWI5`, `BENINST2`, and `AWI4`
on one branch.

`PI_BENF_BCOUNTRY` deserves its own mention: it carries a country **name**, not
a code. XFINX widened its `LLD_COUNTRY` to `VARCHAR2(100)` for exactly that
reason, because `New Zealand` overflowed a `VARCHAR2(10)`. So `AWI4` and `AWI5`
are real risks, not theoretical ones.

## Correction to the NGI-206 note

The NGI-206 analysis cited `AWI2` as one of the elements "already pre-cut to 35",
on the strength of the `SUBSTR` at line 2198. That was wrong: the cut goes to
`CUSTOMER_BANK_NAME`, which the XML does not use. The argument it supported
still stands on `AWI3`, `AWI4`, `BENINST3` and `BENINST4`, which genuinely are
cut before they reach the message, but `AWI2` should not have been in that list.

## The fix

Truncation, not a split. For the memo a split was right because `PAYDET1`-`4`
are four lines of one SWIFT field with nothing else in them. Here the
neighbouring slots are already taken - `AWI2` is the bank name while `AWI3` to
`AWI5` hold its address - so a long name has nowhere to spill and must be cut.

Apply `SUBSTR(.., 1, 35)` to each of the nine, inside `SWIFT_X`:

```sql
SWIFT_X(SUBSTR(VAR_REL_TXN_STORE.BENEFICIARY_NAME, 1, 35))    -- BYODROF2, 2650
SWIFT_X(SUBSTR(VAR_REL_TXN_STORE.CUSTOMER_ADDRESS1, 1, 35))   -- BYODROF3, 2652
SWIFT_X(SUBSTR(VAR_REL_TXN_STORE.CUSTOMER_ADDRESS2, 1, 35))   -- BYODROF4, 2654
SWIFT_X(SUBSTR(VAR_REL_TXN_STORE.CUSTOMER_ADDRESS3, 1, 35))   -- BYODROF5, 2656
SWIFT_X(SUBSTR(PI_BANK_CORESPONDENT1, 1, 35))                 -- INTERMEDY3, 2660
SWIFT_X(SUBSTR(PI_BANK_CORESPONDENT2, 1, 35))                 -- INTERMEDY4, 2662
SWIFT_X(SUBSTR(PI_BENF_BNAME, 1, 35))                         -- AWI2, 2665
SWIFT_X(SUBSTR(VAR_REL_TXN_STORE.CUSTOMER_BANK_ADDRESS3, 1, 35)) -- AWI5, 2668
SWIFT_X(SUBSTR(PI_BENF_NAME, 1, 35))                          -- BENINST2, 2671
```

`AWI3` and `AWI4` are wrapped the same way for the sake of the one branch where
`AWI4` takes the country uncut, and because it costs nothing on the branches
that are already correct.

`SUBSTR` on a `NULL` returns `NULL`, so an absent value stays absent; and
`SUBSTR` never lengthens a value, so every element that is already within 35
goes out byte for byte as it does today. Nothing that works now changes.

### On `AWI2` specifically

`SUBSTR(PI_BENF_BNAME, 1, 35)` and `VAR_REL_TXN_STORE.CUSTOMER_BANK_NAME` are
the same value, because 2198 computes exactly that. Using the record field
would be the smaller change and would keep the message and
`PM_REL_TXN_STORE.NAM_CUST_BANK` visibly in step. `SUBSTR` is used instead so
that all nine elements read the same way and none of them depends on an
assignment four hundred lines earlier - which is the habit that produced this
defect.

## What this does not cover

* **Whether truncating is what the bank wants.** Cutting a beneficiary bank
  name at 35 may make it unrecognisable to the receiving bank. SWIFT allows no
  more in that field, so the alternative is to reject the transaction at the
  channel rather than send a half name. That is BDI's call and it should be put
  to them.
* **What IL does with a long `bdiBenfBName`.** The same question left open on
  NGI-206. One query settles it, against an IL transaction with a long name:
  ```sql
  SELECT ext_ref_no, awi2, beninst2, byodrof2 FROM fccprd.mstm_com_pmt_in
   WHERE ext_ref_no = '<the IL transaction>';
  ```
* **`PK_NGI_CAW_XFINX` has the same defect.** Its line 4075 sends
  `SWIFT_X(PI_BENF_BNAME)` and its 4084 sends `SWIFT_X(PI_BENF_NAME)`, both
  uncut. If that package is live anywhere, it will fail the same way.
