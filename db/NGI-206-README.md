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

```sql
@PK_OL_XFINT_NGI-206.sql

SELECT object_name, object_type, status FROM all_objects
 WHERE object_name = 'PK_OL_XFINT';
```

Both the spec and the body must come back `VALID`. No jar change, no DB object
created or dropped.

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
