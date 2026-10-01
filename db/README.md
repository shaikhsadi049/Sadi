# MF_CIFINQ passport fields — database side

ITRD NGI Service - MF_CIFINQ_Passport v.1.0.

## Why the data was invalid

`ap_ngi_ext_mf_cif_inq` sourced the two passport fields from `ci_custdetl`:

* `passportNo` from `REF_CUST_PSPT`
* `passportExpiryDate` from `DAT_PSPT_EXPIRY`

and it returned **no `icType` column at all**, which is why the service was
reading `icType` off `flg_replicate`, a replication flag that has nothing to do
with an identity card type.

The bank maintains the identity document type and its expiry date as customer
UDFs instead, so the ITRD asks for those to be the source.

## Deploy order

1. `01_ap_ngi_fmt_udf_date.sql` — new helper that normalises a free text UDF
   date to `YYYYMMDD`, or returns `NULL` when the value is not a date.
2. `02_ap_ngi_ext_mf_cif_inq.sql` — the function with the three columns
   re-sourced in all six `var_pi_id_type` branches (`99`, `00`, `30`, `50`,
   `90`, `91`). Every other column is untouched.

Then check for invalid objects:

```sql
SELECT object_name, object_type, status
  FROM all_objects
 WHERE owner = 'FCR24'
   AND object_name IN ('AP_NGI_EXT_MF_CIF_INQ', 'AP_NGI_FMT_UDF_DATE');
```

## Java side

With the sourcing in the function, the service needs no sourcing logic of its
own. `MFCIFInqResWrapper` carries the only change: `icType` now comes from the
cursor's new `icType` column rather than from `flg_replicate`.

```java
res.setIcType((String) map.get("ICTYPE"));   // was map.get("flg_replicate")
```

`passportNo` and `passportExpiryDate` keep their existing mappings, since the
column names did not change. `QueryExecutorCustomerInquiry` and
`CustomerMFInqCIFServiceImpl` are back to their original state.

The row map is case insensitive, which is why the existing code mixes
`map.get("flg_replicate")` with `map.get("PASSPORTNO")`. `ICTYPE` is spelled in
upper case because that is the label Oracle reports for an unquoted alias, so
the lookup holds either way.

## Decisions to confirm with BDI

* **A lifetime validity marker returns `NULL`.** 42 of the 55 `TXT_762` rows
  hold `SEUMUR HDP` or `SEUMUR-HDP`, and two more hold `0` and `220326`. The
  helper returns `NULL` for all of them rather than passing text into a field
  the ITRD types as `YYYYMMDD`. If DBank PRO would rather have a sentinel such
  as `99991231`, change the final `RETURN NULL` in
  `01_ap_ngi_fmt_udf_date.sql`. Those rows belong to customers whose `icType`
  is not `PAS` today, so nothing reaches the response either way, but a
  passport holder could be captured the same way later.
* **`COD_CUST_NATL_ID` on the one `PAS` customer does not look like a passport
  number.** Customer `14508534` holds `5876567876545678`, sixteen digits, the
  shape of a NIK, where the ITRD's sample is `AB1234567Z`. It is the only `PAS`
  record in the schema, so the mapping has not been exercised against a
  realistic passport number. Confirm against production before SIT sign off.

## Verification

`docs/mf_cifinq_passport_verify.sql` holds the queries this was checked with.
After deploying, compare the service response for customer `14508534` with:

```sql
SELECT FCR24.ap_ngi_ext_mf_cif_inq('t','c','s','r','20261001','14508534','90',
                                   :code, :msg, :cur) FROM dual;
```
