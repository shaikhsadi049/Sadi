# MF_CIFINQ passport fields — database side

ITRD NGI Service - MF_CIFINQ_Passport v.1.0.

One script, one object: `ap_ngi_ext_mf_cif_inq.sql` replaces the function.
Nothing else is created or dropped.

## Why the data was invalid

The function sourced the two passport fields from `ci_custdetl`, `passportNo`
from `REF_CUST_PSPT` and `passportExpiryDate` from `DAT_PSPT_EXPIRY`, and it
returned **no `icType` column at all**, which is why the service was reading
`icType` off `flg_replicate`, a replication flag unrelated to an identity card
type. The bank maintains the identity document type and its expiry date as
customer UDFs, so the ITRD asks for those to be the source.

## What changed

Three columns, in all six `var_pi_id_type` branches (`99`, `00`, `30`, `50`,
`90`, `91`). Every other column is untouched.

| Column | Was | Now |
|---|---|---|
| `icType` | *not returned* | `UDF_CUST_LOG_DETAILS.FIELD_VALUE`, `TXT_696` |
| `passportNo` | `ci_custdetl.REF_CUST_PSPT` | `ci_custmast.COD_CUST_NATL_ID`, only when `icType = 'PAS'` |
| `passportExpiryDate` | `ci_custdetl.DAT_PSPT_EXPIRY` | `UDF_CUST_LOG_DETAILS.FIELD_VALUE`, `TXT_762`, only when `icType = 'PAS'` |

`TXT_762` is free text. The schema holds it as `YYYYMMDD`, as `DDMMYYYY` and as
`DD/MM/YYYY`, so it is rearranged to `YYYYMMDD` with `SUBSTR` once a
`REGEXP_LIKE` has confirmed the shape. No `TO_DATE` is used, so no value can
raise and no value can be read under the wrong format. A value that is not a
date, such as `SEUMUR HDP`, returns `NULL`.

## Deploy

```sql
@ap_ngi_ext_mf_cif_inq.sql

SELECT object_name, status FROM all_objects
 WHERE owner = 'FCR24' AND object_name = 'AP_NGI_EXT_MF_CIF_INQ';
```

Then the jar.

## Java side

One line, in `MFCIFInqResWrapper`:

```java
res.setIcType((String) map.get("ICTYPE"));   // was map.get("flg_replicate")
```

`passportNo` and `passportExpiryDate` keep their existing mappings, the column
names did not change. `QueryExecutorCustomerInquiry` and
`CustomerMFInqCIFServiceImpl` stay as they were.

The row map is case insensitive, which is why the existing code mixes
`map.get("flg_replicate")` with `map.get("PASSPORTNO")`. `ICTYPE` is spelled in
upper case because that is the label Oracle reports for an unquoted alias, so
the lookup holds either way.

## Open point for BDI

`COD_CUST_NATL_ID` on the one `PAS` customer in the schema, `14508534`, holds
`5876567876545678`, sixteen digits, the shape of a NIK, where the ITRD's sample
is `AB1234567Z`. It is the only `PAS` record available, so the mapping has not
been exercised against a realistic passport number. Worth confirming against
production before SIT sign off.

`docs/mf_cifinq_passport_verify.sql` holds the queries this was checked with.
