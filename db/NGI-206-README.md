# NGI-206 — PK_OL_XFINT, the memo to FCC

| File | Use |
|---|---|
| `PK_OL_XFINT_NGI-206.sql` | the change, deploy this |
| `PK_OL_XFINT_OLD.sql` | the package as it stood before, for rollback |

Built from the 5574 line package. Two fixes, both inside
`AP_OL_XFINT_S_MAIN`'s XML block, plus one new body function.

## What changed

1. **`SWIFT_X`** added to the body before `AP_OL_RESET_TXN_CACHE`. Reduces free
   text to the SWIFT "X" character set, so `&` and `<` can no longer break the
   FCC request as XML. Matches IL, which cleans the message text only.
2. **The memo is split over `PAYDET1`-`PAYDET4`**, 35 characters each. It used
   to go into `PAYDET1` alone, which is one line of MT103 field 70 and so
   accepts 35, while `PAYDET2`-`PAYDET5` went out empty.
3. **Thirteen free-text elements are now wrapped in `SWIFT_X`.** Ten match what
   XFINX wraps. The other three - `INTERMEDY3`, `INTERMEDY4`, `AWI5`,
   `BENINST4` - are elements XFINX leaves empty, so the IL log proves nothing
   about them; they are wrapped here because they are free text reaching the
   same XML. Drop the four `SWIFT_X(..)` calls on lines 2697, 2699, 2705 and
   2712 to keep strictly to the IL-evidenced ten.

Nothing outside the XML block changed. `ORIGINAL_REMIT_NO` still takes
`SUBSTR(PI_MEMO1, 1, 35)` and everything `AP_SAVE_PAYMENT_LOG` writes is
untouched, which is what keeps the stored value equal to IL's.

The package **specification is unchanged** - `SWIFT_X` is body-only - so only
the body is recompiled.

## Deploy

Both scripts now carry what SQL*Plus needs to run them: `SET DEFINE OFF` at the
top, a `/` after the specification and after the body, and `SHOW ERRORS` after
each. The source dump they were built from had none of that, which is what made
the first attempt leave the package **invalid** - without the `/` after
`END PK_OL_XFINT;` on the specification, SQL*Plus never submits it and reads the
body as a continuation of the same statement.

```sql
@PK_OL_XFINT_NGI-206.sql
```

`SHOW ERRORS` prints anything that failed to compile, twice - once for the
specification, once for the body. Both must print `No errors.`

If your tool ignores `SHOW ERRORS`, check it directly:

```sql
SELECT object_name, object_type, status FROM all_objects
 WHERE object_name = 'PK_OL_XFINT';

SELECT line, position, text FROM all_errors
 WHERE name = 'PK_OL_XFINT' ORDER BY sequence;
```

`PACKAGE` and `PACKAGE BODY` must both read `VALID`, and the second query must
return no rows. A `PLS-00905: object PK_OL_XFINT is invalid` at runtime means
one of them did not compile - read `all_errors` before anything else.

In SQL*Plus, if the run stops partway with a blank-line error, add
`SET SQLBLANKLINES ON` at the top: the package body has blank lines inside its
blocks, and older SQL*Plus settings treat one as the end of a statement.

Only the body changed, so deploying just the body is enough if you prefer -
the specification is byte for byte what is already there.

## Verify

Post a transaction with a 60 character `bdiMemo1`, then:

```sql
SELECT TXN_STAT, MSG_STAT FROM PM_TXN_LOG WHERE REF_TXN_NO = :ref;            -- 1 and 5
SELECT COUNT(*) FROM channel_swift_payment_xref WHERE ref_usr_no = :svcRqId;  -- 1
```

Neither held those values on the failing transaction. In the FCC message,
`PAYDET1` should carry the first 35 characters and `PAYDET2` the remaining 25.

Then a memo containing `&`: it reaches FCC with the `&` as a space, while
`PM_REL_TXN_STORE` keeps the original.

## Rollback

```sql
@PK_OL_XFINT_OLD.sql
```

Nothing else to undo.
