# NGI-206 — the three UAT requests, 14 October 2026

Pulled from `defect_log_xfint_uat_bdiMemo1_Length.xlsx`, one file per sheet,
ready to re-fire.

| File | Channel | `bdiMemo1` | `ref_txn_no` | `svcRqId` | FCC `ext_ref_no` | Outcome |
|---|---|---|---|---|---|---|
| `NGI-206_ngi_request_60char.json` | NGI (REST) | 60 | 182092026101423293500025460742 | 20250806LLSWIFTLINUX77 | 7101262870000116 | **no FCC message** |
| `NGI-206_il_request_60char.xml` | IL (PCM XML) | 60 | 182092026101423375300025460743 | 26101401061930799981 | 7101262870000117 | ok |
| `NGI-206_ngi_request_35char.json` | NGI (REST) | 35 | 182092026101423521400025460744 | 20250806LLSWIFTLINUX78 | 7101262870000118 | ok |

All three carry the same memo, cut to a different length:

```
60: 2012/SIN5030348(1163.68)SIN5035358(23558.48)SIN5035351(1328)
35: 2012/SIN5030348(1163.68)SIN5035358(
```

The 35 character one is the control: identical in every other field, and it
reached FCC. That is what rules the memo's length out as the cause and leaves
the single `PAYDET1` element as the only difference.

## What the FCC message holds now, and after the fix

Only the `PAYDET` elements change. Everything else in `SWIFT_REQ_MESSAGE` is
byte for byte the same.

Today, for the 60 character run - 60 characters in a single 35 character line:

```xml
<PAYDET1>2012/SIN5030348(1163.68)SIN5035358(23558.48)SIN5035351(1328)</PAYDET1><PAYDET2/><PAYDET3/><PAYDET4/><PAYDET5/>
```

After the fix:

```xml
<PAYDET1>2012/SIN5030348(1163.68)SIN5035358(</PAYDET1><PAYDET2>23558.48)SIN5035351(1328)</PAYDET2><PAYDET3></PAYDET3><PAYDET4></PAYDET4><PAYDET5/>
```

`PAYDET1` then carries exactly the 35 characters the control run sent, which
FCC already accepted on `7101262870000118`.

And the 35 character run is unaffected by the fix - its memo fits `PAYDET1`,
so `PAYDET2` to `PAYDET4` come back `NULL` from `SUBSTR` and go out empty, as
they do today.

## Re-firing

Resend the 60 character request with a **new** `svcRqId`. The duplicate check
reads `channel_txn_xref` by `REF_USR_NO`, so reusing
`20250806LLSWIFTLINUX77` will be rejected as a duplicate rather than posting.

`lldInfo` carries trailing spaces that matter - the value is
`USA0YA012` followed by spaces to column 57, then `LUX SIMODIS 1`. Copy the
line whole rather than retyping it.

Then run `docs/NGI-206-verify.sql`.
