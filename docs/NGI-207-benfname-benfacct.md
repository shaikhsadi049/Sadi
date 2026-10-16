# `bdiBenfName` and `bdiBenfAcct` — two different causes

Reported 16 October: `bdiBenfName` over 35 fails STP (field max 70), and
`bdiBenfAcct` over 49 fails STP (field max 50). They look alike. They are not.

## 1. `bdiBenfName` — already covered

`PI_BENF_NAME` goes to `<BENINST2>` at line 2671, raw and uncut, exactly as
`bdiBenfBName` went to `AWI2`. The script sent yesterday already fixes it:

```sql
'</BENINST1><BENINST2>' || SWIFT_X(SUBSTR(PI_BENF_NAME, 1, 35)) ||
```

It was one of the nine in that pass. Nothing further is needed — it just has not
been deployed yet.

## 2. `bdiBenfAcct` — a different defect, and not in the XML

The arithmetic in the report gives it away. "Max 50, fails above 49" means 49
works and 50 does not, which is a 50 character limit on **one more character
than the account itself**.

That character is a slash, at lines 2739-2742:

```sql
UPDATE PM_REL_TXN_STORE
   SET COD_CTPARTY_ACCT = '/' ||
                          VAR_COUNTER_PARTY_DETAIL.COUNTER_PARTY_ACCOUNT_ID
 WHERE REF_TXN_NO = VAR_ARD_PO_REF_TXN_NO;
EXCEPTION
  WHEN OTHERS THEN
    PO_RESPONSE_CODE    := 1001;
    PO_RESPONSE_MESSAGE := 'Update failed for PM_REL_TXN_STORE ' || substring(SQLERRM, 1, 100);
    RETURN 1;
```

* `COUNTER_PARTY_ACCOUNT_ID` is `VARCHAR2(50)` (line 81), so the account itself
  fits at 50.
* `AP_SAVE_PAYMENT_LOG` inserts it into `COD_CTPARTY_ACCT` **without** the
  slash (line 3802), so the insert is fine at 50.
* This UPDATE, which runs after FCC accepts the message, writes `'/'` plus the
  account. At 49 that is 50 characters and fits. At 50 it is 51 and does not.

So `PM_REL_TXN_STORE.COD_CTPARTY_ACCT` is almost certainly `VARCHAR2(50)`, the
UPDATE raises `ORA-12899`, the handler returns 1, and the wrapper rolls the
whole transaction back.

### This is checkable without any guessing

The failing transaction's own response carries the proof. `PO_RESPONSE_MESSAGE`
will read:

```
Update failed for PM_REL_TXN_STORE ORA-12899: value too large for column ...
```

And the column width settles it:

```sql
SELECT data_length FROM all_tab_columns
 WHERE table_name = 'PM_REL_TXN_STORE' AND column_name = 'COD_CTPARTY_ACCT';
```

If that returns 50, the diagnosis is confirmed.

### Note this one fails loudly

Unlike the memo defect, this path returns 1 and rolls back, so the channel does
get an error. Nothing is left posted.

### The fix is not truncation

Cutting an account number to make room for a slash would corrupt it, and a
payment would go to the wrong place or nowhere. The slash is not optional
either: XFINX's comment on the same field records that FCC's validation
re-derives the account by prefixing a slash itself and compares it against the
XML, which is why the slash is applied after the send rather than before.

So if the bank genuinely sends 50 character accounts, the column has to hold 51:

```sql
ALTER TABLE PM_REL_TXN_STORE MODIFY COD_CTPARTY_ACCT VARCHAR2(60);
```

That is DDL on a live table and belongs to the DBA and the bank, not to a
package deployment. Worth asking first how long `bdiBenfAcct` really gets - if
the real maximum is 34, as MT103 field 59 line 1 allows, then no change is
needed at all and the 50 in the mapping sheet is simply wider than reality.

## Summary for the reply

| Field | Cause | Status |
|---|---|---|
| `bdiBenfName` | `BENINST2` sent raw, same as `AWI2` | fixed in the script already sent, needs deploying |
| `bdiBenfAcct` | `'/' ‖ account` overflows `COD_CTPARTY_ACCT` at line 2740 | not a package fix - column width, needs the bank's real maximum first |
