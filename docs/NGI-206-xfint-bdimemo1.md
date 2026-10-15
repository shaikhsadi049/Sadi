# NGI XFINT — maximum length of `bdiMemo1` (NGI-206)

Defect **NGI-206**, raised by Bank Danamon (PT Bank Danamon Indonesia, Tbk) on
15 October 2026. Service: **NGI XFINT**.

## What was reported

NGI applies a maximum length of 35 characters to `bdiMemo1`. A transaction
whose `bdiMemo1` is longer than 35 characters fails STP. The same transaction
posted through **IL** reaches STP with a `bdiMemo1` longer than 35 characters,
so the two paths do not behave the same way and the bank asks for the NGI limit
to be corrected.

## The XFINT sources are not in this repository

This repository holds the MF_CIFINQ work only: the `FCRNGIMFCifInq` service,
the `ap_ngi_ext_mf_cif_inq` function and the MF_CIFINQ documents. Nothing in it
mentions `bdiMemo1`, and no XFINT project is attached to this workspace. The
change itself therefore cannot be made from here yet. What is needed:

| Artefact | Why |
|---|---|
| The NGI XFINT service project | holds the request payload bean the limit is declared on |
| The DB function XFINT calls (`ap_ngi_ext_*`) | second place a length can be enforced |
| The IL mapping for `bdiMemo1` | tells us what IL actually does above 35 characters |
| The XFINT ITRD / field mapping sheet | the agreed maximum length for these fields |

## Where a 35 character limit comes from in an NGI service

Taken from how the sibling service in this repository is built; the same
skeleton is used across these NGI services, so the cap on `bdiMemo1` is in one
of these places. In likelihood order:

| # | Place | Symptom | How to confirm |
|---|-------|---------|----------------|
| 1 | `@Size(max = 35)` on the XFINT request bean field | HTTP 400 validation error, the request never reaches the DB function, so nothing is posted and the transaction cannot STP | `grep -n "bdiMemo" -A3 -B3` over `payload/request/` |
| 2 | `@Pattern` on the same field with a bounded quantifier, e.g. `^.{0,35}$` | same as 1 | same grep |
| 3 | A sized local variable or a `%TYPE` anchored to a 35 wide column inside the DB function | `ORA-06502: character string buffer too small`, raised after the call is made | `ALL_SOURCE` for the function, and `ALL_ARGUMENTS` for its parameters |
| 4 | The FCR target column the memo is written to | `ORA-06502` or `ORA-12899`, or a silently truncated value | `ALL_TAB_COLUMNS.DATA_LENGTH` on that column |
| 5 | `bdiMemo1` taking part in the txn key / signature string | key mismatch rather than a length message | the `getTxnBodyKey()` equivalent on the XFINT request bean |

Case 1 is the house pattern and by far the most likely. In `FCRNGIMFCifInq`,
every request field carries its own `@Size(max = n, message = "...")`, the
controller takes the body as `@Valid @RequestBody`, and the header bean
validates itself in `createAndValidate()` and throws
`ConstraintViolationException`. A violation is turned into an error response
before any database work is done, which matches "fails STP" exactly: the
transaction is rejected at the edge, not part way through.

Cases 3 and 4 are worth ruling out rather than assumed away. The parameters of
these functions are bound as `Types.VARCHAR` with no length, and declared
unsized (`VARCHAR2`, `char`) in the function signature, so the limit will not be
at the binding itself — but a local variable in the function body, or the FCR
column at the end of it, can still be 35 wide.

## The question to settle before the cap is lifted

**35 is also a common narrative width in FCR**, and it is the SWIFT field 70
line length, so the limit may well be a real downstream constraint rather than
an arbitrary NGI validation. "IL can STP successfully" tells us that IL does not
*reject* the transaction. It does not tell us that the whole memo was *stored*.
Three things IL may be doing, each leading to a different fix:

| What IL does above 35 | The correct NGI fix |
|---|---|
| Passes the full value to a wider column | raise the NGI `@Size` to that column's width |
| Truncates silently at 35 | NGI should truncate too, not accept — parity is truncation, and lifting the validation would make NGI write a value IL never wrote |
| Spills the remainder into `bdiMemo2` / `bdiMemo3` | NGI needs the same spill logic, not a wider single field |

So the first thing to establish is what landed in FCR for an IL transaction
whose `bdiMemo1` was longer than 35 characters — the stored value and its
`LENGTH()`, against what the channel sent. Until that is known, widening the
NGI validation is a guess, and the wrong guess replaces a clean 400 with an
`ORA-06502` part way through posting, or with silent data truncation, which is
worse than the defect being reported.

## Checks to run once the XFINT project is attached

Locate the limit:

```bash
grep -rn "bdiMemo" --include=*.java .
grep -rn "max = 35\|max=35\|{0,35}\|,35}" --include=*.java .
```

Then the database side, substituting the XFINT function and the memo column:

```sql
-- parameter declarations of the function XFINT calls
SELECT argument_name, data_type, data_length, in_out
  FROM all_arguments
 WHERE owner = 'FCR24' AND object_name = UPPER('&xfint_function')
 ORDER BY position;

-- any sized declaration inside the function body
SELECT line, text FROM all_source
 WHERE owner = 'FCR24' AND name = UPPER('&xfint_function')
   AND REGEXP_LIKE(text, 'VARCHAR2\s*\(\s*35|CHAR\s*\(\s*35', 'i')
 ORDER BY line;

-- the width of the column the memo is written to
SELECT table_name, column_name, data_type, data_length
  FROM all_tab_columns
 WHERE owner = 'FCR24' AND table_name = UPPER('&memo_table')
   AND column_name = UPPER('&memo_column');

-- what IL actually stored: anything longer than 35 means IL does not truncate
SELECT LENGTH(&memo_column) AS len, COUNT(*)
  FROM FCR24.&memo_table
 GROUP BY LENGTH(&memo_column)
 ORDER BY len DESC;
```

The failing UAT transaction should also be pulled from the service log. These
services log the request body at INFO on entry, so the payload that was sent and
the validation message that rejected it will both be in the log, which settles
cases 1 and 2 against case 3 without any guessing.

## What to ask the bank

1. From Jira NGI-206: the failing request payload and the exact error NGI
   returned, plus the `svcRqId` or trace id, so the request can be found in the
   UAT log.
2. The XFINT ITRD or field mapping sheet for `bdiMemo1` to `bdiMemo3`, with the
   agreed maximum length of each.
3. One IL transaction reference whose `bdiMemo1` was longer than 35 characters,
   so what IL stored can be compared with what the channel sent.
4. The expected behaviour when the memo exceeds the agreed length: reject the
   transaction, truncate the memo, or carry the remainder into `bdiMemo2`.

Items 2 and 3 are the ones that decide the fix. Item 1 only confirms which of
the five places above holds the limit.
