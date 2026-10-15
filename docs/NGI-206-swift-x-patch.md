# `SWIFT_X` for `PK_OL_XFINT` — clean the message text

Approved by Oracle on 15 October alongside the `PAYDET` split, with one
condition: **it must behave the way IL behaves.**

Line numbers are for the 5574 line file.

## IL's behaviour is documented, not assumed

The `XFINX` package carries the evidence in the comment above its own
`SWIFT_X` (lines 683-707). It was derived from IL logs:

* The customer on all three test cases is stored as ``WILLIAM AGUS`SE``.
* The backtick survives everywhere in the IL log - it appears 16 times, so the
  logger is not stripping it.
* But inside IL's own FCC message it is a **space**:
  `<BYODROF2>WILLIAM AGUS SE</BYODROF2>` and
  `<PAYDET1>Internet Trf dari WILLIAM AGUS SE</PAYDET1>`.
* Meanwhile `<BYODROF4>001/012</BYODROF4>` keeps its slash.

Two conclusions follow, and both matter:

1. **IL does not clean only `&` and `<`.** A backtick is neither, and IL still
   replaces it. IL reduces the text to the SWIFT "X" character set: anything
   outside `A-Z a-z 0-9` and `/ - ? : ( ) . , ' +` and space becomes a space.
2. **IL cleans the message text only.** The stored columns keep the original,
   which is why `PM_REL_TXN_STORE` still shows the backtick on both sides.

So the change belongs in the XML block and nowhere else. `ORIGINAL_REMIT_NO`
(line 1343) and everything `AP_SAVE_PAYMENT_LOG` writes stay exactly as they
are.

## 1. Add the function — before line 581

Immediately above `PROCEDURE AP_OL_RESET_TXN_CACHE`:

```sql
  -- ================================================================================
  --  SWIFT_X - reduce free text to the SWIFT "X" character set.
  --
  --  Anything outside  A-Z a-z 0-9  and  / - ? : ( ) . , ' +  and space becomes a
  --  space.  Two reasons: SWIFT will not carry other characters, and '&' and '<'
  --  break the FCC request as XML before SWIFT ever sees it.
  --
  --  Matches IL, which cleans the message text and only the message text - the
  --  stored columns keep the original value.
  -- ================================================================================
  FUNCTION SWIFT_X(P_TEXT IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN REGEXP_REPLACE(P_TEXT, q'{[^A-Za-z0-9/?:().,'+ -]}', ' ');
  END SWIFT_X;

```

It is a body-only function used from `AP_OL_XFINT_S_MAIN` further down, so it
must appear before that function and **the package specification does not
change**. Only the body is recompiled.

The replacement is one character for one character, so no value gets longer or
shorter. `Maju & Jaya` goes out as `Maju   Jaya`, same length.

## 2. Wrap the free-text elements in the XML

Ten elements, the same ten `XFINX` wraps:

| Line | Was | Now | Element |
|---|---|---|---|
| 2650 | `VAR_REL_TXN_STORE.BENEFICIARY_NAME` | `SWIFT_X(VAR_REL_TXN_STORE.BENEFICIARY_NAME)` | `BYODROF2` |
| 2652 | `VAR_REL_TXN_STORE.CUSTOMER_ADDRESS1` | `SWIFT_X(VAR_REL_TXN_STORE.CUSTOMER_ADDRESS1)` | `BYODROF3` |
| 2654 | `VAR_REL_TXN_STORE.CUSTOMER_ADDRESS2` | `SWIFT_X(VAR_REL_TXN_STORE.CUSTOMER_ADDRESS2)` | `BYODROF4` |
| 2656 | `VAR_REL_TXN_STORE.CUSTOMER_ADDRESS3` | `SWIFT_X(VAR_REL_TXN_STORE.CUSTOMER_ADDRESS3)` | `BYODROF5` |
| 2665 | `PI_BENF_BNAME` | `SWIFT_X(PI_BENF_BNAME)` | `AWI2` |
| 2666 | `VAR_XML_AWI3` | `SWIFT_X(VAR_XML_AWI3)` | `AWI3` |
| 2667 | `VAR_XML_AWI4` | `SWIFT_X(VAR_XML_AWI4)` | `AWI4` |
| 2671 | `PI_BENF_NAME` | `SWIFT_X(PI_BENF_NAME)` | `BENINST2` |
| 2673 | `VAR_COUNTER_PARTY_DETAIL.ADDRESS_LINE_1` | `SWIFT_X(VAR_COUNTER_PARTY_DETAIL.ADDRESS_LINE_1)` | `BENINST3` |
| 2677 | `PI_MEMO1` | see below | `PAYDET1` |

With the `PAYDET` split applied, line 2677 and the three new lines become:

```sql
                               SWIFT_X(VAR_XML_PAYDET1) ||
                               '</PAYDET1><PAYDET2>' ||
                               SWIFT_X(VAR_XML_PAYDET2) ||
                               '</PAYDET2><PAYDET3>' ||
                               SWIFT_X(VAR_XML_PAYDET3) ||
                               '</PAYDET3><PAYDET4>' ||
                               SWIFT_X(VAR_XML_PAYDET4) ||
```

Order does not matter between `SUBSTR` and `SWIFT_X` - the replacement does not
change length - but wrapping the sliced variable keeps it reading like the rest
of the block.

## 3. Three elements `XFINX` has no reading for

`PK_OL_XFINT` sends three free-text elements that `XFINX` leaves empty, so the
IL log says nothing about them:

| Line | Field | Element |
|---|---|---|
| 2660, 2662 | `PI_BANK_CORESPONDENT1`, `PI_BANK_CORESPONDENT2` | `INTERMEDY3`, `INTERMEDY4` |
| 2668 | `VAR_REL_TXN_STORE.CUSTOMER_BANK_ADDRESS3` | `AWI5` |
| 2675 | `VAR_COUNTER_PARTY_DETAIL.ADDRESS_LINE_2` | `BENINST4` |

Recommend wrapping these too. They are free text reaching the same XML, so an
unwrapped one leaves the same hole open - a beneficiary address line 2
containing `&` would break the request exactly as the memo does. Wrapping can
only turn a character SWIFT will not carry into a space, so it cannot make a
message worse. Flagged separately because it goes past what the IL log proves.

## What is deliberately left alone

Codes, references, numbers and account identifiers are not touched, matching
`XFINX`: `PI_ACCT_ID`, `VAR_SEQ_SWIFT_NTWRK_REF`, `PI_XFER_AMT_TO`,
`VAR_XFER_CCY_SHORT`, `PI_BENF_ID` (BIC), `COUNTER_PARTY_ACCOUNT_ID`,
`FCC_PRODUCT_CODE`, `DESIGNATED_BRN_CODE`, `LOB_CODE`. `BYODROF4` carrying
`001/012` is the proof that a slash must survive, which is why `/` is inside the
allowed set.

## Test

| Memo in | Goes to FCC as |
|---|---|
| `Bayar ke PT Maju & Jaya` | `Bayar ke PT Maju   Jaya` |
| `Trf <urgent> ke vendor` | `Trf  urgent  ke vendor` |
| ``WILLIAM AGUS`SE`` | `WILLIAM AGUS SE` |
| `Gaji 001/012 Okt.` | unchanged - `/` and `.` are allowed |
| `Transfer gaji bulan Oktober` | unchanged |

And `PM_REL_TXN_STORE` keeps the original in every one of those cases.
