# NGI FC_MF_CIFINQ — Update the source for passport fields

Reference: *ITRD NGI Service - MF_CIFINQ_Passport v.1.0*, raised by Bank Danamon
(PT Bank Danamon Indonesia, Tbk) on 16 September 2026.
Service: `FCRNGIMFCifInq`.

## Background

`icType`, `passportNo` and `passportExpiryDate` were taken straight from the
`ap_ngi_ext_mf_cif_inq` inquiry cursor, `icType` from the `flg_replicate`
column. DBank PRO consumes the passport number and the passport expiry date for
SID opening and reported the values as invalid, so the bank asked for the data
source of these three response fields to be changed.

## Field mapping

The source of each response field, as agreed in the ITRD "Logic" sheet:

| # | Response field (`cifInfo`) | Type | Source |
|---|----------------------------|------|--------|
| 1 | `icType` | Text | `UDF_CUST_LOG_DETAILS.FIELD_VALUE` where `COD_FIELD_TAG = 'TXT_696'` |
| 2 | `passportNo` | Text | `CI_CUSTMAST.COD_CUST_NATL_ID`, only when `icType = 'PAS'`, otherwise `NULL` |
| 3 | `passportExpiryDate` | Date (`YYYYMMDD`) | `UDF_CUST_LOG_DETAILS.FIELD_VALUE` where `COD_FIELD_TAG = 'TXT_762'`, only when `icType = 'PAS'`, otherwise `NULL` |

`icType` is always populated. Sample values are `PAS` (passport), `KTP`
(Indonesian national ID card) and `SIU`. `passportNo` and `passportExpiryDate`
are populated for passport holders only; for every other identity card type
both fields are returned as `NULL`.

Sample response values from the ITRD: `icType = PAS`,
`passportNo = AB1234567Z`, `passportExpiryDate = 20490815`.

## Implementation

* `MFCIFInqResWrapper` no longer maps the three fields from the inquiry cursor,
  so the service has a single source for each of them. `flgReplicate` keeps
  being mapped, it is a separate response field.
* `QueryExecutorCustomerInquiry` gained two reads:
  `getUdfFieldValueByCustId(customerId, fieldTag)` for a customer UDF field
  value, and `getNationalIdByCustomerId(customerId)` for
  `CI_CUSTMAST.COD_CUST_NATL_ID`. Both bind their arguments as parameters and
  return `null` when no row matches.
* `CustomerMFInqCIFServiceImpl.populatePassportDetails(..)` applies the ITRD
  logic to every record of the inquiry result, right after the procedure call,
  so the multiple CIF response (`typeId` `91` and `99`, or more than one record)
  is sourced the same way as the single CIF response. A record that carries no
  customer number is logged and skipped, and the remaining records are still
  sourced.
* The `icType = 'PAS'` comparison is case insensitive and ignores the padding
  that Oracle `CHAR` columns add. A UDF field that is absent or blank is
  treated as no value, so it is returned as `NULL` rather than as an empty
  string.
* `passportExpiryDate` is held as free text in `UDF_CUST_LOG_DETAILS`, so the
  value is normalised to the `YYYYMMDD` format the consumer expects.
  `yyyyMMdd`, `dd/MM/yyyy`, `dd-MM-yyyy`, `dd.MM.yyyy`, `dd-MMM-yyyy`,
  `yyyy-MM-dd` and `yyyy/MM/dd` are recognised. A value in any other format is
  logged as a warning and returned exactly as it is stored, so that an
  unexpected capture format is visible in the logs instead of being silently
  dropped from the response.

## Notes for review

* **`COD_TASK` is not part of the ITRD condition.** A customer can hold the same
  field tag under more than one maintenance task, and the ITRD gives only
  `COD_FIELD_TAG`. The read therefore matches the ITRD (field tag, customer,
  active status) but orders the rows so that the customer maintenance task
  `CIM09` wins when several tasks hold the tag, which keeps the result
  deterministic. Please confirm with BDI which task captures `TXT_696` and
  `TXT_762`; if it is always one task, the read can be narrowed to it.
* **Query cost on the multiple CIF paths.** Sourcing costs one query per
  customer, plus two more for a passport holder. That is negligible for a single
  CIF inquiry, but `typeId` `91` and `99` can return many records. Worth a look
  during SIT if those paths return large result sets.
* **A failed read fails the inquiry.** "No row" is not an error, it yields
  `NULL`. A real database error propagates and the inquiry returns an error
  response, as the rest of this service already does, rather than returning a
  silently empty passport for a passport holder.
* The project depends on the internal `com.oracle.fcr.ngi.il:FCRNGIILMigration`
  artifact, which is not published publicly, so `mvn compile` cannot be run
  outside the Oracle/Midas build environment. The changed sources were syntax
  checked with `javac`, and the new logic (the `icType` condition, the multiple
  CIF loop, trimming and the date normalisation) was exercised with a standalone
  harness over the ITRD samples before the change was committed.
