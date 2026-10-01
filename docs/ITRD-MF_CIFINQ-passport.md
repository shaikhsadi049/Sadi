# NGI FC_MF_CIFINQ — Update the source for passport fields

Reference: *ITRD NGI Service - MF_CIFINQ_Passport v.1.0*, raised by Bank Danamon
(PT Bank Danamon Indonesia, Tbk) on 16 September 2026.

## Background

The passport number and passport expiry date returned by the `FC_MF_CIFINQ`
service are consumed by DBank PRO for SID opening. The bank reported that the
values being returned were invalid and asked for the data source of those
response fields to be changed.

## Field mapping

The source of each response field, as agreed in the ITRD "Logic" sheet:

| # | Response field (`cifRec`) | Type | Source |
|---|---------------------------|------|--------|
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

* `CifRec` carries the three fields `icType`, `passportNo` and
  `passportExpiryDate`.
* `QueryExecutorCustomerInquiry.getUdfFieldValueByCustId(..)` reads any customer
  UDF field value by field tag. It replaces the single-purpose
  `getMotherNameByCustId(..)`, which read the same table and is now one caller
  of the generic method, so the mother maiden name (`TXT_691`) keeps its
  existing behaviour.
* `QueryExecutorCustomerInquiry.getNationalIdByCustomerId(..)` reads
  `CI_CUSTMAST.COD_CUST_NATL_ID` for the customer.
* `CustomerInquiryCIFINQServiceImpl.populatePassportDetails(..)` applies the
  `icType = 'PAS'` condition. The comparison is case insensitive and ignores the
  padding that Oracle `CHAR` columns add, and a UDF field that is absent or
  blank is treated as no value, so it is returned as `NULL` rather than as an
  empty string.
* `passportExpiryDate` is held as free text in `UDF_CUST_LOG_DETAILS`, so the
  value is normalised to the `YYYYMMDD` format the consumer expects.
  `yyyyMMdd`, `dd/MM/yyyy`, `dd-MM-yyyy`, `dd.MM.yyyy`, `dd-MMM-yyyy`,
  `yyyy-MM-dd` and `yyyy/MM/dd` are recognised. A value in any other format is
  logged as a warning and returned exactly as it is stored, so that an
  unexpected capture format is visible in the logs instead of being silently
  dropped from the response.

## Notes for review

* The ITRD describes `icType`, `passportNo` and `passportExpiryDate` as
  *existing* response fields. They are not present in the
  `FCRNGICustomerProfileCifInq` snapshot this change was made against
  (`Midas-Ngi/FCRNGICustomerProfileCifInq` @ `7053f72`, `main`), so they have
  been added to `CifRec`. If the deployed service already exposes them from a
  branch that is not in that snapshot, only the sourcing logic above needs to be
  carried over and the `CifRec` additions should be dropped as duplicates.
* The UDF reads filter on `COD_TASK = 'CIM09'`, matching how the existing
  mother maiden name UDF read is scoped in this service. The ITRD does not
  mention `COD_TASK`; please confirm that `TXT_696` and `TXT_762` are captured
  under the same task, since `UDF_CUST_LOG_DETAILS` is keyed per task.
* The project depends on the internal `com.oracle.fcr.ngi.il:FCRNGIILMigration`
  artifact, which is not published publicly, so `mvn compile` cannot be run
  outside the Oracle/Midas build environment. The changed sources were syntax
  checked with `javac` and the new logic (the `icType` condition, trimming and
  the date normalisation) was exercised with a standalone harness over the ITRD
  samples before the change was committed.
