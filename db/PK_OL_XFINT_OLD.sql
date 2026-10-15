CREATE OR REPLACE PACKAGE PK_OL_XFINT AS
  /******************************************************************************
     NAME:       PK_OL_XFINT
     PURPOSE:

     REVISIONS:
     Ver        Date        Author             Description
     ---------  ----------  ---------------    ------------------------------------
     1.0        31/07/2023   Ahmed Nafisul Bari      1. Created this package.
  ******************************************************************************/

  SUBTYPE T_STRING_LIST IS DBMS_SQL.VARCHAR2A;

  --records-----------------------------------------------------------------------

  TYPE BENIF_LLD_DETAILS_REC IS RECORD(
    LLD_RESIDENT    VARCHAR2(10),
    LLD_COUNTRY     VARCHAR2(10),
    LLD_CATEGORY    VARCHAR2(10),
    LLD_IDENTITY    VARCHAR2(10),
    LLD_AFFILIATE   CHAR(1),
    LLD_PURPOSE     VARCHAR2(10),
    LLD_DESCRIPTION VARCHAR2(60));

  TYPE CURRENCY_AMOUNT_REC IS RECORD(
    MONETARY_VALUE NUMBER,
    CURRENCY_CODE  VARCHAR2(5),
    CURRENCY_RATE  NUMBER);

  TYPE TXN_VALUE_REC IS RECORD(
    ACCT_CCY_CONV_RATE NUMBER,
    TXN_CCY_CONV_RATE  NUMBER,
    AMOUNT_ACY         CURRENCY_AMOUNT_REC,
    AMOUNT_TCY         CURRENCY_AMOUNT_REC,
    AMOUNT_LCY         CURRENCY_AMOUNT_REC);

  TYPE PAYMENT_TXN_LOG_REC IS RECORD(
    BANK_CODE                  NUMBER,
    BRANCH_CODE                NUMBER,
    TRANSACTION_DATE           DATE,
    BATCH_NO                   NUMBER,
    SYSTEM_TRAIL_AUDIT_NUMBER  NUMBER,
    SEQUENCE_NUMBER            NUMBER,
    PAYMENT_TRANSACTION_CODE   VARCHAR2(20),
    BEN_CUST_TYP               VARCHAR2(20),
    BEN_RES_STATUS             VARCHAR2(20),
    TRANSACTION_MNEMONIC       VARCHAR2(10),
    POSTING_DATE               DATE,
    ACCOUNT_NO                 VARCHAR2(16),
    CUSTOMER_ID                VARCHAR2(16),
    TRANSACTION_CURRENCY_CODE  NUMBER,
    NETWORK_ID                 VARCHAR2(50),
    NETWORK_REFERENCE_NO       VARCHAR2(50),
    TRANSACTION_REFERENCE_NO   VARCHAR2(50),
    USER_REFERENCE_NO          VARCHAR2(50),
    DISPATCH_DATE              DATE,
    ACTIVATION_DATE            DATE,
    COUNTER_PARTY_VALUE_DATE   DATE,
    EXPIRY_DATE                DATE,
    PAYMENT_DIRECTION          VARCHAR2(10),
    COUNTER_PARTY_ID           VARCHAR2(50),
    COUNTER_PARTY_ACCOUNT_NO   VARCHAR2(50),
    TRANSACTION_DESC           VARCHAR2(200),
    TOTAL_AMOUNT               NUMBER,
    FINANCIAL_INSTITUITION_ID  VARCHAR2(20),
    VALUE_DATE                 DATE,
    TRANSACTION_VALUE          TXN_VALUE_REC,
    SUPERVISOR                 VARCHAR2(20),
    FINANCIAL_INST_BANK_CODE   VARCHAR2(20),
    FINANCIAL_INST_BRANCH_CODE VARCHAR2(10),
    CORRESP_AGENT_CODE         VARCHAR2(20),
    USER_ID                    VARCHAR2(20),
    BIN_NO                     VARCHAR2(20),
    CREDIT_CARD_NO             VARCHAR2(20),
    TRANSACTION_CURR_CONV_RATE NUMBER);

  TYPE COUNTER_PARTY_DETAIL_REC IS RECORD(
    BANK_NAME                VARCHAR2(200),
    COUNTER_PARTY_NAME       VARCHAR2(200),
    BRANCH                   VARCHAR2(200),
    COUNTER_PARTY_ACCOUNT_ID VARCHAR2(50),
    ADDRESS                  VARCHAR2(200),
    --SWIFT_MT
    ADDRESS_LINE_1 VARCHAR2(200),
    ADDRESS_LINE_2 VARCHAR2(200),
    ADDRESS_LINE_3 VARCHAR2(200),
    CUSTOMER_CLASS VARCHAR2(20));

  TYPE REL_TXN_STORE_REC IS RECORD(
    REFERENCE_NUMBER             VARCHAR2(50),
    ORIGINATING_BANK             VARCHAR2(5),
    ORIGINATING_BRANCH           VARCHAR2(5),
    PAYMENT_TRANSACTION_CODE     VARCHAR2(50),
    PAYMENT_PACKAGE_ID           VARCHAR2(20),
    TRANSACTION_MNEMONIC         VARCHAR2(10),
    INITIATION_BRANCH            VARCHAR2(5),
    RECEIVER_ACCOUNT_NO          VARCHAR2(16),
    ACCOUNT_TITLE                VARCHAR2(100),
    FROM_ACCOUNT_IBAN_NO         VARCHAR2(50),
    TRANSMISSION_DATE_TIME       NUMBER,
    ORIGINAL_REMIT_NO            VARCHAR2(50),
    ORIGINAL_PROCESS_CODE        VARCHAR2(20),
    NARRATIVE                    VARCHAR2(200),
    ORIGINALNETWORK_REFERENCE_NO VARCHAR2(50),
    CLEARING_TYPE                VARCHAR2(10),
    FROM_ZONE_ID                 VARCHAR2(10),
    FROM_CIRCLE_ID               VARCHAR2(10),
    TO_ZONE_ID                   VARCHAR2(10),
    TO_CIRCLE_ID                 VARCHAR2(10),
    CLEARING_CODE                VARCHAR2(10),
    IS_INTERNALLY_CLEARED        VARCHAR2(10),
    MESSAGE_REFERENCE_NO         VARCHAR2(40),
    DETAILS                      COUNTER_PARTY_DETAIL_REC,
    COUNTER_PARTY_IBAN_NO        VARCHAR2(40),
    COUNTER_PARTY_ROUTING_CODE   VARCHAR2(10),
    REMITTER_NAME                VARCHAR2(100),
    REMITTER_PHONE               VARCHAR2(50),
    REMITTER_NATL_ID             VARCHAR2(50),
    INSTRUMENT_NUMBER            VARCHAR2(30),
    INSTRUMENT_TYPE              VARCHAR2(10),
    INSTRUMENT_DATE              DATE,
    OVERRIDE_CODE                VARCHAR2(20),
    ERROR_CODE                   VARCHAR2(20),
    ERROR_TEXT                   VARCHAR2(200),
    TELEGRAM_NO                  VARCHAR2(20),
    REASON_CODE                  VARCHAR2(20),
    TXN_RTGS_CODE                VARCHAR2(20),
    SETTLEMENT_CCY_CODE          VARCHAR2(10),
    INITIATOR_RES_STATUS_CODE    VARCHAR2(10),
    PM_CHARGES_FEE_CODE          VARCHAR2(10),
    CORRESP_AGENT_NAME           VARCHAR2(100),
    CORRESP_AGENT_BANK_NAME      VARCHAR2(200),
    CORRESP_AGENT_BRANCH_NAME    VARCHAR2(200),
    BENEFICIARY_NAME             VARCHAR2(200),
    FCC_PRODUCT_CODE             VARCHAR2(10),
    REMITTER_CATEGORY            VARCHAR2(20),
    RECEIVER_BIC_CODE            VARCHAR2(20),
    RECEIVER_CATEGORY            VARCHAR2(20),
    AFFILIATION_CODE             VARCHAR2(20),
    PURPOSE_CODE                 VARCHAR2(10),
    COUNTERPARTY_COUNTRY_CODE    VARCHAR2(10),
    CUSTOMER_COUNTRY_CODE        VARCHAR2(10),
    SENDER_TO_RECEIVER_INFO1     VARCHAR2(200),
    SENDER_TO_RECEIVER_INFO2     VARCHAR2(200),
    SENDER_TO_RECEIVER_INFO3     VARCHAR2(200),
    SENDER_TO_RECEIVER_INFO4     VARCHAR2(200),
    SENDER_TO_RECEIVER_INFO5     VARCHAR2(200),
    SENDER_TO_RECEIVER_INFO6     VARCHAR2(200),
    CUSTOMER_ADDRESS1            VARCHAR2(200),
    CUSTOMER_ADDRESS2            VARCHAR2(200),
    CUSTOMER_ADDRESS3            VARCHAR2(200),
    CUSTOMER_COUNTRY             VARCHAR2(200),
    CORRESPONDENT_AGENT_ADDRESS1 VARCHAR2(200),
    CORRESPONDENT_AGENT_ADDRESS2 VARCHAR2(200),
    CUSTOMER_BANK_NAME           VARCHAR2(200),
    CUSTOMER_BANK_ADDRESS1       VARCHAR2(200),
    CUSTOMER_BANK_ADDRESS2       VARCHAR2(200),
    CUSTOMER_BANK_ADDRESS3       VARCHAR2(200),
    CUSTOMER_BANK_ADDRESS4       VARCHAR2(200),
    COUNTERPARTY_BANK_ADDRESS    VARCHAR2(200),
    CUSTOMER_TO_RECEIVER_INFO1   VARCHAR2(200),
    CUSTOMER_TO_RECEIVER_INFO2   VARCHAR2(200),
    CUSTOMER_TO_RECEIVER_INFO3   VARCHAR2(200),
    CUSTOMER_TO_RECEIVER_INFO4   VARCHAR2(200),
    SENDER_BIC_CODE              VARCHAR2(20),
    SWIFT_REFERENCE_NUMBER       VARCHAR2(40),
    NOSTRO_ACCOUNT_NUMBER        VARCHAR2(40),
    BI_CODE                      VARCHAR2(20),
    VOSTRO_ACCOUNT_NUMBER        VARCHAR2(40),
    CUSTOMER_BRANCH_NAME         VARCHAR2(100),
    CUSTOMER_RTGS_CODE           VARCHAR2(20),
    COUNTERPARTY_RTGS_CODE       VARCHAR2(20),
    RELATED_TRN_CODE             VARCHAR2(20),
    BOR_NO                       VARCHAR2(20),
    SWIFT_REFERENCE_NO           VARCHAR2(40),
    SEQUENCE_NUMBER              VARCHAR2(40));

  TYPE BASIC_INSTRUMENT_DTL_REC IS RECORD(
    CHEQUE_DATE           DATE,
    CHEQUE_LITERAL        VARCHAR2(20),
    CLEARING_TYPE         NUMBER,
    DRAWER_ACCOUNT_NUMBER VARCHAR2(20),
    INSTRUMENT_NUMBER     VARCHAR2(20),
    IS_COMISSION_CHARGED  BOOLEAN,
    RULE_RETURN_VALUE     VARCHAR2(200),
    ROUTING_NUMBER        NUMBER);

  TYPE RULE_EVALUATION_HIST_REC IS RECORD(
    RULE_REFERENCE_NUMBER NUMBER,
    RULEID                VARCHAR2(40),
    ORIGINAL_AMOUNT       NUMBER,
    NEW_AMOUNT            NUMBER,
    REASON                VARCHAR2(200),
    RETURN_VALUE_DESC     VARCHAR2(200),
    RULE_RETURN_VALUE     VARCHAR2(200),
    CONDITION_NUMBER      NUMBER);

  TYPE SERVICE_CHARGE_REC IS RECORD(
    TXN_REF_NUMBER          VARCHAR2(40),
    RULE_REF_NUMBER         NUMBER,
    INCOME_LEDGER_CODE      VARCHAR2(20),
    DEBIT_ACCT_ID           VARCHAR2(20),
    AMT_IN_LOCAL_CCY        CURRENCY_AMOUNT_REC,
    AMT_IN_TXN_CCY          CURRENCY_AMOUNT_REC,
    AMT_IN_ACCT_CCY         CURRENCY_AMOUNT_REC,
    AMT_IN_SC_CCY           CURRENCY_AMOUNT_REC,
    CODE                    NUMBER,
    NAME                    VARCHAR2(200),
    SC_CCY_OPTION           VARCHAR2(20),
    DEBIT_ACCT_BRN_CODE     NUMBER,
    RULES                   RULE_EVALUATION_HIST_REC,
    CUMULATIVE_DEBIT_FLAG   VARCHAR2(10),
    ADDL_SC_CODE            NUMBER,
    ADDL_SC_CCY             NUMBER,
    PARENT_SC_AMT_IN_ACY    NUMBER,
    PARENT_SC_AMT_IN_TCY    NUMBER,
    PARENT_SC_AMT_IN_LCY    NUMBER,
    ADDL_SC_AMT_IN_ACY      NUMBER,
    ADDL_SC_AMT_IN_TCY      NUMBER,
    ADDL_SC_AMT_IN_LCY      NUMBER,
    ADDL_INCOME_LEDGER_CODE NUMBER,
    IS_FLG_AMORT            VARCHAR2(10),
    SC_NATURE               VARCHAR2(20));

  TYPE OUTGOING_PAYMENT_REC IS RECORD(
    SERVICE_CHARGE_DETAILS SERVICE_CHARGE_REC,
    INSTRUMENT_DETAILS     BASIC_INSTRUMENT_DTL_REC,
    TRANSACTION_TYPE       NUMBER);

  TYPE PAYMENT_MAPPING_REC IS RECORD(
    REL_TXN_STORE       REL_TXN_STORE_REC,
    PAYMENT_TXN_LOG     PAYMENT_TXN_LOG_REC,
    OUTGOING_PAYMENT    OUTGOING_PAYMENT_REC,
    DESIGNATED_BRN_CODE VARCHAR2(20),
    LOB_CODE            VARCHAR2(20));

  TYPE FCC_CODE_GENERATION_REC IS RECORD(
    BANK_SWIFT_CODE              VARCHAR(50),
    INT_INS_OR_BEN_CORR_BIC_CODE VARCHAR(50),
    CCY_CODE                     VARCHAR(50),
    CHARGE_BEARER                VARCHAR(50),
    TRANSACTION_TYPE             VARCHAR(50),
    TRANSACTION_DATE             DATE,
    TRANSACTION_TIME             VARCHAR(200),
    TRANSACTION_AMOUNT           NUMBER);

  --procedures----------------------------------------------------------------

  FUNCTION AP_OL_XFINT_S_WRAPPER(PI_CHANNEL_ID         IN VARCHAR2,
                                 PI_SVC_CODE           IN VARCHAR2,
                                 PI_SVC_RQ_ID          IN VARCHAR2,
                                 PI_TRACE_ID           IN VARCHAR2,
                                 PI_USER_ID            IN VARCHAR2,
                                 PI_TXN_DATE           IN VARCHAR2,
                                 PI_ACCT_ID            IN VARCHAR2,
                                 PI_ACCT_TYPE          IN VARCHAR2,
                                 PI_ACCT_CUR           IN VARCHAR2,
                                 PI_XFER_AMT_FRM       IN NUMBER,
                                 PI_XFER_AMT_FRM_LCE   IN NUMBER,
                                 PI_XFER_AMT_TO        IN NUMBER,
                                 PI_XFER_AMT_TO_LCE    IN NUMBER,
                                 PI_XFER_CUR_CODE      IN VARCHAR2,
                                 PI_XRATE_AMT          IN NUMBER,
                                 PI_STDRATE_AMT        IN NUMBER,
                                 PI_XREFF_NUMBER       IN VARCHAR2,
                                 PI_BENF_ACCT          IN VARCHAR2,
                                 PI_BENF_NAME          IN VARCHAR2,
                                 PI_BENF_PHONE         IN VARCHAR2,
                                 PI_BENF_EMAIL         IN VARCHAR2,
                                 PI_BENF_ADDRESS       IN VARCHAR2,
                                 PI_BENF_ID            IN VARCHAR2,
                                 PI_BENF_BNAME         IN VARCHAR2,
                                 PI_BENF_BADDRESS      IN VARCHAR2,
                                 PI_BENF_BCOUNTRY      IN VARCHAR2,
                                 PI_BANK_CORESPONDENT1 IN VARCHAR2,
                                 PI_BANK_CORESPONDENT2 IN VARCHAR2,
                                 PI_XFER_COST_CTR      IN VARCHAR2,
                                 PI_MEMO1              IN VARCHAR2,
                                 PI_MEMO2              IN VARCHAR2,
                                 PI_XFEE_AMT           IN NUMBER,
                                 PI_XFEE_AMT_LCE       IN NUMBER,
                                 PI_XFEE_CODE          IN VARCHAR2,
                                 PI_LLD_INFO           IN VARCHAR2,
								 PI_CUST_INDUCED_FLG   IN VARCHAR2,
                                 PO_REF_NO             OUT VARCHAR2,
                                 PO_RESPONSE_CODE      OUT VARCHAR2,
                                 PO_RESPONSE_MESSAGE   OUT VARCHAR2)
    RETURN NUMBER;

  FUNCTION POPULATE_CCY_AMOUNT(PI_ISO_CODE            IN VARCHAR2,
                               PI_AMOUNT              IN NUMBER,
                               PI_CONV_RATE           IN NUMBER,
                               PO_CURRENCY_AMOUNT_REC OUT CURRENCY_AMOUNT_REC)
    RETURN NUMBER;

  FUNCTION GET_CURRENCY_CODE(PI_CURRENCY_SHORT_NAME IN VARCHAR2)
    RETURN NUMBER;

  FUNCTION AP_READ_DATA(VAR_PI_SVC_RQ_ID        IN VARCHAR2,
                        VAR_PI_USER_ID          IN VARCHAR2,
                        VAR_PI_DAT_PROCESS      IN DATE,
                        VAR_PI_COD_TXN_MNEMONIC IN NUMBER,
                        -----FROM ACCOUNT DETAILS----
                        VAR_PI_COD_ACC_NO_FRM     IN VARCHAR2,
                        VAR_PI_COD_ACC_CCY_FRM    IN NUMBER,
                        VAR_PO_COD_CC_BRN_F       OUT NUMBER,
                        VAR_PO_COD_PROD_F         OUT NUMBER,
                        VAR_PO_ACCT_CUR_F         OUT NUMBER,
                        VAR_PO_USN_F              OUT NUMBER,
                        VAR_PO_FLG_PSBOOK_F       OUT VARCHAR2,
                        VAR_PO_BAL_LST_PSBK_F     OUT NUMBER,
                        VAR_PO_COD_CUST_F         OUT NUMBER,
                        VAR_PO_CTR_PSBK_LINE_NO_F OUT NUMBER,
                        VAR_PO_USER_ROW           IN OUT SM_USER_PROFILE%ROWTYPE,
                        ---------------KEY VALUES---------
                        VAR_PO_REF_TXN_NO       OUT VARCHAR2,
                        VAR_PO_STAN_NO          OUT NUMBER,
                        VAR_PO_RESPONSE_CODE    IN OUT VARCHAR2,
                        VAR_PO_RESPONSE_MESSAGE IN OUT VARCHAR2)
    RETURN NUMBER;

  FUNCTION AP_VAL_ACCOUNT(VAR_PI_COD_ACC_NO_FRM     IN VARCHAR2,
                          VAR_PI_COD_ACC_CCY_FRM    IN NUMBER,
                          VAR_PO_COD_CC_BRN_F       OUT NUMBER,
                          VAR_PO_COD_PROD_F         OUT NUMBER,
                          VAR_PO_ACCT_CUR_F         OUT NUMBER,
                          VAR_PO_USN_F              OUT NUMBER,
                          VAR_PO_FLG_PSBOOK_F       OUT VARCHAR2,
                          VAR_PO_BAL_LST_PSBK_F     OUT NUMBER,
                          VAR_PO_CTR_PSBK_LINE_NO_F OUT NUMBER,
                          VAR_PO_COD_CUST_F         OUT VARCHAR2,
                          VAR_PO_RESPONSE_CODE      IN OUT NUMBER,
                          VAR_PO_RESPONSE_MESSAGE   IN OUT VARCHAR2)
    RETURN NUMBER;

  FUNCTION AP_SAVE_PAYMENT_LOG(VAR_PI_REL_TXN_STORE        IN REL_TXN_STORE_REC,
                               VAR_PI_PAYMENT_TXN_LOG      IN PAYMENT_TXN_LOG_REC,
                               VAR_L_NTWK_ACCT_STAT        IN NUMBER,
                               VAR_PI_COUNTER_PARTY_DETAIL IN COUNTER_PARTY_DETAIL_REC,
                               VAR_PI_COD_MSG_TYP          IN NUMBER,
                               VAR_PI_CHANNEL_ID           IN VARCHAR2,
                               VAR_PI_SUB_SEQ_NO           IN NUMBER,
                               VAR_PI_TOT_SUBSEQ_NO        IN NUMBER DEFAULT 7,
                               VAR_PI_DAT_TXN              IN NUMBER,
                               VAR_PI_COD_USER_ID          IN SM_USER_PROFILE.COD_USER_ID%TYPE,
                               VAR_PI_STAN_NO              IN NUMBER,
                               VAR_PI_TXN_CCY              IN NUMBER,
                               VAR_PI_AMT_TXN_TCY          IN NUMBER,
                               VAR_PI_RAT_CONV_TCLCY       IN NUMBER,
                               VAR_PI_AMT_TXN_LCY          IN NUMBER,
                               VAR_PI_AMT_TXN_ACY          IN NUMBER,
                               VAR_PI_RAT_CONV_ACLCY       IN NUMBER,
                               VAR_PI_COD_NETWORK_ID       IN VARCHAR2,
                               VAR_PI_NAM_CUST_BRN         IN NUMBER,
                               VAR_PI_REF_TXN_NO           IN VARCHAR2,
                               VAR_PI_REF_USR_NO           IN VARCHAR2,
                               PO_RESPONSE_CODE            OUT VARCHAR2,
                               PO_RESPONSE_MESSAGE         OUT VARCHAR2)
    RETURN NUMBER;

  FUNCTION GENERATE_FCC_CODE_AND_NOSTRO(IN_FCC_CODE_GENERATION_REC IN FCC_CODE_GENERATION_REC,
                                        OUT_FCC_PRODUCT_CODE       OUT VARCHAR2,
                                        PO_RESPONSE_CODE           OUT VARCHAR2,
                                        PO_RESPONSE_MESSAGE        OUT VARCHAR2)
    RETURN NUMBER;

  FUNCTION AP_OL_CALL_CH_WDR(VAR_PI_CHANNEL_ID              IN VARCHAR2,
                             VAR_PI_SVC_CODE                IN VARCHAR2,
                             VAR_PI_DAT_TXN                 IN NUMBER,
                             VAR_PI_COD_ORG_BRN             IN NUMBER,
                             VAR_PI_REF_SUBSEQ_NO           IN NUMBER,
                             VAR_PI_MSG_TYPE                IN NUMBER,
                             VAR_PI_REF_TXN_NO              IN VARCHAR2,
                             VAR_PI_SVC_RQ_ID               IN VARCHAR2,
                             VAR_PI_COD_USER_ID             IN VARCHAR2,
                             VAR_PI_COD_USERNO              IN NUMBER,
                             VAR_PI_STAN_NO                 IN NUMBER,
                             VAR_PI_COD_PROC                IN NUMBER,
                             VAR_PI_COD_ACCT_NO_F           IN VARCHAR2,
                             VAR_PI_COD_CC_BRN_F            IN NUMBER,
                             VAR_PI_ACCT_CUR_F              IN VARCHAR2,
                             VAR_PI_XFER_CUR                IN VARCHAR2,
                             VAR_PI_COD_PROD_F              IN NUMBER,
                             VAR_PI_BAL_LST_PSBK_F          IN NUMBER,
                             VAR_PI_CTR_PSBK_LINE_NO_F      IN NUMBER,
                             VAR_PI_TXN_CUR                 IN VARCHAR2,
                             VAR_PI_COD_ACCT_NO_T           IN VARCHAR2,
                             VAR_PI_AMT_TXN_LCY             IN NUMBER,
                             VAR_PI_AMT_TXN_TCY             IN NUMBER,
                             VAR_PI_AMT_TXN_ACY             IN NUMBER,
                             VAR_PI_AMT_TXN_OTHER_ACY       IN NUMBER,
                             VAR_PI_TXN_CCY_CONV_RATE       IN NUMBER,
                             VAR_PI_ACCT_CCY_CONV_RATE      IN NUMBER,
                             VAR_PI_COD_TXN_MNEMONIC        IN VARCHAR2,
                             VAR_PI_COD_TXN                 IN VARCHAR2,
                             VAR_PI_NARRATIVE               IN VARCHAR2,
                             VAR_PI_COD_TASK_LITERAL_DERIVE IN VARCHAR2,
                             VAR_PI_COD_ORG_MSG_TYP         IN NUMBER,
                             VAR_PI_REF_ORG_STAN            IN NUMBER,
                             VAR_PI_REF_ORG_SUBSEQ_NO       IN NUMBER,
                             VAR_PI_DAT_ORG_TXN             IN NUMBER,
                             VAR_PI_CTR_YR_ORG_TXN          IN NUMBER,
                             VAR_PI_DAT_ORG_POST            IN NUMBER,
                             VAR_PI_CTR_YR_ORG_POST         IN NUMBER,
                             VAR_PO_COD_EXT                 IN OUT VARCHAR2,
                             VAR_PO_COD_REPLY               IN OUT NUMBER,
                             VAR_PO_USN                     IN OUT NUMBER,
                             VAR_PO_RESPONSE_CODE           OUT VARCHAR2,
                             VAR_PO_RESPONSE_MESSAGE        OUT VARCHAR2)
    RETURN NUMBER;

  FUNCTION AP_OL_CALL_GL_TXNS(VAR_PI_DAT_TXN                 IN NUMBER,
                              VAR_PI_COD_ORG_BRN             IN NUMBER,
                              VAR_PI_COD_CC_BRN              IN NUMBER,
                              VAR_PI_REF_SUBSEQ_NO           IN NUMBER,
                              VAR_PI_REF_TXN_NO              IN VARCHAR2,
                              VAR_PI_SVC_RQ_ID               IN VARCHAR2,
                              VAR_PI_COD_USER_ID             IN VARCHAR2,
                              VAR_PI_COD_USERNO              IN NUMBER,
                              VAR_PI_STAN_NO                 IN NUMBER,
                              VAR_PI_COD_ACCT_NO             IN VARCHAR2,
                              VAR_PI_COD_ACCT_NO_DUM_GL      IN VARCHAR2,
                              VAR_PI_TXN_CUR                 IN NUMBER,
                              VAR_PI_ACCT_CUR                IN NUMBER,
                              VAR_PI_COD_PROD                IN NUMBER,
                              VAR_PI_COD_PROC                IN NUMBER,
                              VAR_PI_AMT_TXN_LCY             IN NUMBER,
                              VAR_PI_AMT_TXN_TCY             IN NUMBER,
                              VAR_PI_AMT_TXN_ACY             IN NUMBER,
                              VAR_PI_TXN_CCY_CONV_RATE       IN NUMBER,
                              VAR_PI_ACCT_CCY_CONV_RATE      IN NUMBER,
                              VAR_PI_FLG_OVERRIDE_DUM        IN NUMBER,
                              VAR_PI_COD_TXN_MNEMONIC        IN NUMBER,
                              VAR_PI_TXNDESC1                IN VARCHAR2,
                              VAR_PI_TXNDESC2                IN VARCHAR2,
                              VAR_PI_COD_TASK_LITERAL_DERIVE IN VARCHAR2,
                              VAR_PI_FLG_DRCR                IN VARCHAR2,
                              VAR_PI_COD_ORG_MSG_TYP         IN NUMBER,
                              VAR_PI_REF_ORG_STAN            IN NUMBER,
                              VAR_PI_REF_ORG_SUBSEQ_NO       IN NUMBER,
                              VAR_PI_DAT_ORG_TXN             IN NUMBER,
                              VAR_PI_CTR_YR_ORG_TXN          IN NUMBER,
                              VAR_PI_DAT_ORG_POST            IN NUMBER,
                              VAR_PI_CTR_YR_ORG_POST         IN NUMBER,
                              VAR_PO_COD_EXT                 IN OUT VARCHAR2,
                              VAR_PO_COD_REPLY               IN OUT NUMBER,
                              VAR_PO_USN                     IN OUT NUMBER,
                              VAR_PI_XFEE_AMT                IN NUMBER,
                              VAR_PO_RESPONSE_CODE           OUT VARCHAR2,
                              VAR_PO_RESPONSE_MESSAGE        OUT VARCHAR2)
    RETURN NUMBER;

  FUNCTION AP_OL_CALL_PROCESS_SC(VAR_PI_CHANNEL_ID         IN VARCHAR2,
                                 VAR_PI_SVC_CODE           IN VARCHAR2,
                                 VAR_PI_DAT_TXN            IN NUMBER,
                                 VAR_PI_COD_ORG_BRN        IN NUMBER,
                                 VAR_PI_REF_SUBSEQ_NO      IN NUMBER,
                                 VAR_PI_SVC_RQ_ID          IN VARCHAR2,
                                 VAR_PI_TXN_CCY            IN NUMBER,
                                 VAR_PI_AMT_TXN_LCY        IN NUMBER,
                                 VAR_PI_AMT_TXN_TCY        IN NUMBER,
                                 VAR_PI_AMT_TXN_ACY        IN NUMBER,
                                 VAR_PI_TXN_CCY_CONV_RATE  IN NUMBER,
                                 VAR_PI_ACCT_CCY_CONV_RATE IN NUMBER,
                                 VAR_PI_COD_SC             IN NUMBER,
                                 VAR_PI_COD_TXN_MNEMONIC   IN VARCHAR2,
                                 VAR_PI_COD_TXN            IN VARCHAR2,
                                 VAR_PI_COD_USER_ID        IN VARCHAR2,
                                 VAR_PI_COD_USERNO         IN NUMBER,
                                 VAR_PI_STAN_NO            IN NUMBER,
                                 VAR_PI_REF_TXN_NO         IN VARCHAR2,
                                 ---FROM ACCOUNT DETAILS---
                                 VAR_PI_ACCT_ID_F    IN VARCHAR2,
                                 VAR_PI_COD_CC_BRN_F IN NUMBER,
                                 VAR_PI_ACCT_CUR_F   IN VARCHAR2,
                                 VAR_PI_COD_PROD_F   IN VARCHAR2,
                                 VAR_PO_COD_EXT      IN OUT VARCHAR2,
                                 VAR_PO_COD_REPLY    IN OUT NUMBER,
                                 VAR_PO_USN_F        IN OUT VARCHAR2,
                                 VAR_PI_XREF_NUMBER  IN VARCHAR2,
                                 --  the fee leg carries the transaction narrative
                                 VAR_PI_NARRATIVE        IN VARCHAR2 DEFAULT NULL,
                                 VAR_PO_RESPONSE_CODE    OUT VARCHAR2,
                                 VAR_PO_RESPONSE_MESSAGE OUT VARCHAR2)
    RETURN NUMBER;

  FUNCTION AP_OL_PREPARE_TXN_VAL_COMMON(VAR_PI_COD_TXN_MNEMONIC   IN VARCHAR2,
                                        VAR_PI_MONETARY_VALUE     IN NUMBER, --amount
                                        VAR_PI_COD_ACCT_CCY       IN NUMBER, --amount.getCurrency
                                        VAR_PI_COD_OTHER_ACCT_CCY IN NUMBER,
                                        VAR_PI_COD_LCY            IN NUMBER,
                                        VAR_PI_DAT_PROCESS        IN DATE,
                                        VAR_PO_TXN_RATE           IN OUT NUMBER,
                                        VAR_PI_ACCT_RATE          IN NUMBER DEFAULT 0,
                                        VAR_PI_IS_TXN_CCY_BASED   IN BOOLEAN,
                                        VAR_PO_COD_TXN_CCY        OUT NUMBER,
                                        VAR_PO_ACCT_CCY_CONV_RATE IN OUT NUMBER,
                                        VAR_PO_TXN_CCY_CONV_RATE  IN OUT NUMBER,
                                        VAR_PO_CTR_CCY_ROUND_TO   OUT NUMBER,
                                        VAR_PO_AMT_TXN_LCY        OUT NUMBER,
                                        VAR_PO_AMT_TXN_TCY        OUT NUMBER,
                                        VAR_PO_AMT_TXN_ACY        OUT NUMBER,
                                        VAR_PO_ACCT_TO_RATE       OUT NUMBER,
                                        VAR_PO_RESPONSE_CODE      OUT VARCHAR2,
                                        VAR_PO_RESPONSE_MESSAGE   OUT VARCHAR2)
    RETURN NUMBER;

  --  Returns the first extended-response code that NGI_OVERRIDE_SCORES does not let
  --  this service override, with its BA_ERR_DEFS description.
  FUNCTION AP_OL_CHECK_EXT_RESP_NGI(PI_INPUT_STR        IN VARCHAR2,
                                    PI_OVERWRITE_STR    IN VARCHAR2,
                                    PO_RESPONSE_CODE    OUT VARCHAR2,
                                    PO_RESPONSE_MESSAGE OUT VARCHAR2)
    RETURN NUMBER;

  --  Rates travel as 32-bit floats in IL, so a rate is reduced to the shortest
  --  decimal that round-trips through one.
  FUNCTION F_IL_RATE(PI_RATE IN NUMBER) RETURN NUMBER;

END PK_OL_XFINT;






















CREATE OR REPLACE PACKAGE BODY PK_OL_XFINT AS
  /******************************************************************************
     NAME:       PK_OL_XFINT  (IL-parity revision of PK_OL_XFINT)
     PURPOSE:
  
     REVISIONS:
     Ver        Date        Author             Description
     ---------  ----------  ---------------    ------------------------------------
     1.0        31/07/2023   Ahmed Nafisul Bari      1. Created this package body.
     1.1        04/04/2024   Koushik Chandra Sarker  2. implement payment log.
     2.0        21/08/2026   Shaikh Sadi             3. NGI-194 performance pass.
  ******************************************************************************/

  -- ================================================================================
  --  NGI-194 performance caches.
  --
  --  Everything cached here is REFERENCE data that cannot change while one payment is
  --  being posted, so serving a repeat lookup from the cache returns exactly the value
  --  the query would have returned.  Nothing transaction-specific is ever cached.
  --
  --  G_TXN_* caches are cleared at the top of every AP_OL_XFINT_S_WRAPPER call, so no
  --  value ever survives into the next transaction on a pooled session.
  --  G_SEQ_VERIFIED is deliberately session-lived - see the note at its use.
  --  All of this lives in the package BODY only; the specification is untouched.
  -- ================================================================================
  TYPE G_CCY_CACHE_REC IS RECORD(
    NAM_CCY_SHORT VARCHAR2(100),
    FOUND         NUMBER);
  TYPE G_CCY_CACHE_TAB IS TABLE OF G_CCY_CACHE_REC INDEX BY VARCHAR2(40);
  TYPE G_FLAG_TAB IS TABLE OF NUMBER INDEX BY VARCHAR2(200);

  G_TXN_CCY_CACHE       G_CCY_CACHE_TAB;
  G_TXN_BANK_LCY_SHORT  VARCHAR2(100);
  G_TXN_BANK_LCY_LOADED NUMBER := 0;
  G_TXN_NETWORK_BRANCH  NUMBER;
  G_TXN_NETWORK_LOADED  NUMBER := 0;
  G_SEQ_VERIFIED        G_FLAG_TAB;

  PROCEDURE AP_OL_RESET_TXN_CACHE IS
  BEGIN
    G_TXN_CCY_CACHE.DELETE;
    G_TXN_BANK_LCY_SHORT  := NULL;
    G_TXN_BANK_LCY_LOADED := 0;
    G_TXN_NETWORK_BRANCH  := NULL;
    G_TXN_NETWORK_LOADED  := 0;
  END AP_OL_RESET_TXN_CACHE;

  FUNCTION AP_OL_GET_CCY_SHORT(PI_COD_CCY IN NUMBER) RETURN VARCHAR2 IS
    VAR_L_KEY VARCHAR2(40) := TO_CHAR(PI_COD_CCY);
    VAR_L_REC G_CCY_CACHE_REC;
  BEGIN
    IF G_TXN_CCY_CACHE.EXISTS(VAR_L_KEY) THEN
      IF G_TXN_CCY_CACHE(VAR_L_KEY).FOUND = 0 THEN
        RAISE NO_DATA_FOUND;
      END IF;
    
      RETURN G_TXN_CCY_CACHE(VAR_L_KEY) .NAM_CCY_SHORT;
    END IF;
  
    BEGIN
      SELECT NAM_CCY_SHORT
        INTO VAR_L_REC.NAM_CCY_SHORT
        FROM vwe_ba_ccy_code
       WHERE COD_CCY = PI_COD_CCY
         AND FLG_MNT_STATUS = 'A';
    
      VAR_L_REC.FOUND := 1;
      G_TXN_CCY_CACHE(VAR_L_KEY) := VAR_L_REC;
      RETURN VAR_L_REC.NAM_CCY_SHORT;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        VAR_L_REC.NAM_CCY_SHORT := NULL;
        VAR_L_REC.FOUND := 0;
        G_TXN_CCY_CACHE(VAR_L_KEY) := VAR_L_REC;
        RAISE;
    END;
  END AP_OL_GET_CCY_SHORT;

  FUNCTION AP_OL_XFINT_S_MAIN(PI_CHANNEL_ID         IN VARCHAR2,
                              PI_SVC_CODE           IN VARCHAR2,
                              PI_SVC_RQ_ID          IN VARCHAR2,
                              PI_TRACE_ID           IN VARCHAR2,
                              PI_USER_ID            IN VARCHAR2,
                              PI_TXN_DATE           IN VARCHAR2,
                              PI_ACCT_ID            IN VARCHAR2,
                              PI_ACCT_TYPE          IN VARCHAR2,
                              PI_ACCT_CUR           IN VARCHAR2,
                              PI_XFER_AMT_FRM       IN NUMBER,
                              PI_XFER_AMT_FRM_LCE   IN NUMBER,
                              PI_XFER_AMT_TO        IN NUMBER,
                              PI_XFER_AMT_TO_LCE    IN NUMBER,
                              PI_XFER_CUR_CODE      IN VARCHAR2,
                              PI_XRATE_AMT          IN NUMBER,
                              PI_STDRATE_AMT        IN NUMBER,
                              PI_XREFF_NUMBER       IN VARCHAR2, --dealer ref number
                              PI_BENF_ACCT          IN VARCHAR2,
                              PI_BENF_NAME          IN VARCHAR2,
                              PI_BENF_PHONE         IN VARCHAR2,
                              PI_BENF_EMAIL         IN VARCHAR2,
                              PI_BENF_ADDRESS       IN VARCHAR2,
                              PI_BENF_ID            IN VARCHAR2,
                              PI_BENF_BNAME         IN VARCHAR2,
                              PI_BENF_BADDRESS      IN VARCHAR2,
                              PI_BENF_BCOUNTRY      IN VARCHAR2,
                              PI_BANK_CORESPONDENT1 IN VARCHAR2,
                              PI_BANK_CORESPONDENT2 IN VARCHAR2,
                              PI_XFER_COST_CTR      IN VARCHAR2,
                              PI_MEMO1              IN VARCHAR2,
                              PI_MEMO2              IN VARCHAR2,
                              PI_XFEE_AMT           IN NUMBER,
                              PI_XFEE_AMT_LCE       IN NUMBER,
                              PI_XFEE_CODE          IN VARCHAR2,
                              PI_LLD_INFO           IN VARCHAR2,
							  PI_CUST_INDUCED_FLG   IN VARCHAR2,
                              PO_REF_NO             OUT VARCHAR2,
                              PO_RESPONSE_CODE      OUT VARCHAR2,
                              PO_RESPONSE_MESSAGE   OUT VARCHAR2)
    RETURN NUMBER IS
    APPLICATION_ERROR EXCEPTION;
  
    --  PI_CHANNEL_ID is the raw ChannelId. Only the PCM clause looks at it; the
    --  duplicate check, the cross-references and the payment log use the context channel.
    VAR_L_IL_CHANNEL CONSTANT VARCHAR2(10) := 'CAW';
  
    VAR_PI_CUSTOMER_VALUE_DATE DATE := TO_DATE(PI_TXN_DATE,
                                               'YYYYMMDDHH24MISS');
  
    VAR_G_PAYMENT_DIRECTION  VARCHAR2(3) := 'OUT';
    VAR_G_COD_BANK           NUMBER := 11;
    VAR_G_MNEM_CASA_GL_FLOW  VARCHAR(5) := 2043;
    VAR_G_MNEM_OUTG_PAY_FLOW VARCHAR(5) := 2030;
    VAR_G_NORMAL_TRANSACTION NUMBER := 0;
  
    VAR_L_RETURN_VALUE NUMBER;
  
    --VALIDATION VARIABLES
    VAR_COUNT_XFER_COST_CTR NUMBER;
  
    --checkForDuplicateRequest variables
    VAR_CHECK_FOR_DUP_REF     NUMBER;
    VAR_CHECK_FOR_DUP_EXT_REF channel_txn_xref.REF_USR_NO%TYPE := PI_SVC_RQ_ID;
    --  matched on the context channel, not the request one
    VAR_CHECK_FOR_DUP_CHANNEL channel_txn_xref.org_chnl_id%TYPE := 'CAW';
  
    VAR_TXN_DATE VARCHAR2(14);
  
    VAR_DATE_PROCESS          BA_BANK_MAST.Dat_Process%TYPE;
    VAR_BANK_LOC_CUR_SRT_NAME BA_BANK_MAST.COD_LCY%TYPE;
  
    --amountInFromAccountCurrency
    VAR_AMT_IN_FROM_ACCT_CURR     CURRENCY_AMOUNT_REC;
    VAR_RET_AMT_IN_FROM_ACCT_CURR NUMBER;
    --amountInLocalCurrency
    VAR_AMT_IN_LOCAL_CURR     CURRENCY_AMOUNT_REC;
    VAR_RET_AMT_IN_LOCAL_CURR NUMBER;
    --amountInTransferCurrency
    VAR_AMT_IN_XFER_CURR     CURRENCY_AMOUNT_REC;
    VAR_RET_AMT_IN_XFER_CURR NUMBER;
  
    VAR_TXN_VALUE TXN_VALUE_REC;
  
    VAR_TRANSACTION_CCY NUMBER;
    VAR_XFER_CCY_SHORT  vwe_ba_ccy_code.NAM_CCY_SHORT%TYPE;
    --  NGI-194: account currency short name, resolved once instead of by an
    --  in-line sub-select inside the CHANNEL_TXN_XREF insert
    VAR_ACCT_CCY_SHORT vwe_ba_ccy_code.NAM_CCY_SHORT%TYPE;
    VAR_ACCOUNT_CCY    NUMBER;
    VAR_I_ACCOUNT_CCY  NUMBER;
    VAR_LOCAL_CCY      NUMBER;
  
    VAR_BUY_RATE      NUMBER;
    VAR_SELL_RATE     NUMBER;
    VAR_MID_RATE      NUMBER;
    VAR_EXCHANGE_RATE NUMBER := PI_XRATE_AMT;
    VAR_STDRATE_AMT   NUMBER := PI_STDRATE_AMT;
  
    VAR_ACCT_CCY_CONV_RATE NUMBER;
  
    VAR_FROM_RATE NUMBER := 1;
    VAR_TO_RATE   NUMBER := 1;
  
    VAR_PAYMENT_TXN_LOG  PAYMENT_TXN_LOG_REC;
    VAR_L_NTWK_ACCT_STAT NUMBER(3) := 0;
  
    --transalateNetworkMessage
    VAR_NETWORK_ID     pm_network_msg_translator.COD_NETWORK_ID%TYPE;
    VAR_TRANSACTION_ID pm_network_msg_translator.COD_PAYMENT_TXN%TYPE;
  
    VAR_COUNTER_PARTY_DETAIL    COUNTER_PARTY_DETAIL_REC;
    VAR_REL_TXN_STORE           REL_TXN_STORE_REC;
    VAR_BASIC_INSTRUMENT_DTL    BASIC_INSTRUMENT_DTL_REC;
    VAR_OUTGOING_PAYMENT        OUTGOING_PAYMENT_REC;
    VAR_PAYMENT_MAPPING         PAYMENT_MAPPING_REC;
    VAR_SERVICE_CHARGE          SERVICE_CHARGE_REC;
    VAR_BENIF_LLD_DETAILS_REC   BENIF_LLD_DETAILS_REC;
    VAR_FCC_CODE_GENERATION_REC FCC_CODE_GENERATION_REC;
  
    VAR_SERVICE_CHARGE_GL_SC_INC vwe_ba_sc_code.COD_GL_SC_INCOME%TYPE;
    VAR_SC_CODE                  ba_site.MACRO_VALUE%TYPE;
    VAR_MACRO_SIMODIS_DCC        ba_site.MACRO_VALUE%TYPE;
  
    VAR_OUT_FCC_PRODUCT_CODE VARCHAR(255);
    --populateRelationalTransactionStore
    VAL_ACCOUNT_NUMBER NUMBER;
    VAR_ACCOUNT_TYPE   vwe_cs_ho_acct_module_xref.COD_MODULE%TYPE;
    VAR_ACCOUNT_TITLE  vwe_ch_acct_mast.COD_ACCT_TITLE%TYPE;
    VAR_CUSTOMER_ID    vwe_ch_acct_mast.COD_CUST%TYPE;
    VAR_L_FLG_MEMO_F   vwe_ch_acct_mast.FLG_MEMO%TYPE;
  
    VAR_COUNTER_PARTY_BANK    pm_counterparty_mast.NAM_CTPARTY_BANK%TYPE;
    VAR_COUNTER_PARTY_BRANCH  pm_counterparty_mast.NAM_CTPARTY_BRANCH%TYPE;
    VAR_COUNTER_PARTY_ACCT_NO pm_counterparty_mast.COD_CTPARTY_ACCT%TYPE;
  
    --setLLDDetails
    VAR_CUSTOMER_NATIONALITY vwe_ci_custmast.TXT_CUST_NATNLTY%TYPE;
    VAR_UDF_FIELD_VALUE      UDF_CUST_LOG_DETAILS.field_value%TYPE;
    VAR_REMITTER_CATEGORY    ext_caw_swift_lld_map.cod_Category%TYPE;
  
    VAR_L_NARRATIVE VARCHAR(255);
  
    --processOutgoingAccountPayment
    VAR_L_PM_TXN_DEFN_ROW      pm_txn_defn%ROWTYPE;
    VAR_CASA_PAYMENT_PACKAGE   pm_global_params.cod_casa_pymt_pkg_id%TYPE;
    VAR_COUNT_ALLOWED_TXN      NUMBER;
    VAR_INTERMEDIARY_LEDGER_ID pm_txn_defn.cod_inter_gl_acct%TYPE;
    VAR_MNEMONIC_MISCE_CUST_D  NUMBER := 1008;
  
    --AP_READ_DATA
    VAR_ARD_PO_COD_CC_BRN_F       NUMBER;
    VAR_ARD_PO_COD_PROD_F         NUMBER;
    VAR_ARD_PO_ACCT_CUR_F         NUMBER;
    VAR_ARD_PO_USN_F              NUMBER;
    VAR_ARD_PO_FLG_PSBOOK_F       VARCHAR2(255);
    VAR_ARD_PO_BAL_LST_PSBK_F     NUMBER;
    VAR_ARD_PO_COD_CUST_F         NUMBER;
    VAR_ARD_PO_CTR_PSBK_LINE_NO_F NUMBER;
    VAR_ARD_PO_USER_ROW           SM_USER_PROFILE%ROWTYPE;
    VAR_ARD_PO_REF_TXN_NO         VARCHAR2(255);
    VAR_ARD_PO_STAN_NO            NUMBER;
    --AP_OL_CALC_DAT_LOG
    VAR_CDL_PO_DAT_LOG DATE;
    --AP_CM_AM_EXCHANGE
    VAR_EXR_MLT_UNIT_RAT_QUOT_SRC  NUMBER;
    VAR_EXR_MLT_UNIT_RAT_QUOT_DEST NUMBER;
    VAR_EXR_FLG_CCY_CONV_SRC       NUMBER;
    VAR_EXR_FLG_CCY_CONV_DEST      NUMBER;
    VAR_EXR_CTR_CCY_ROUND_TO_LCY   NUMBER;
    VAR_EXR_CTR_CCY_ROUND_TO_DEST  NUMBER;
    VAR_EXR_RAT_SRC                NUMBER;
    VAR_EXR_RAT_DEST               NUMBER;
    VAR_EXR_RAT_BASE_SRC           NUMBER;
    VAR_EXR_RAT_BASE_DEST          NUMBER;
    VAR_EXR_RAT_SRC_SPREAD         NUMBER;
    VAR_EXR_RAT_DEST_SPREAD        NUMBER;
    VAR_EXR_COD_CCY_SPREAD_SRC     CHAR;
    VAR_EXR_COD_CCY_SPREAD_DEST    CHAR;
  
    VAR_EXR_OUT_AMT_LCY      NUMBER;
    VAR_EXR_OUT_AMT_DEST     NUMBER;
    VAR_EXR_OUT_RAT_SRC_LCY  NUMBER;
    VAR_EXR_OUT_RAT_LCY_DEST NUMBER;
  
    --prepare txn value
    VAR_L_COD_LCY NUMBER := PK_BA_CCY.GET_COD_LCY(PI_XFER_COST_CTR);
  
    PO_PTV_TXN_RATE           NUMBER := 0;
    PI_PTV_ACCT_RATE          NUMBER := 0;
    PO_PTV_ACCT_CCY_CONV_RATE NUMBER := 1;
    PO_PTV_TXN_CCY_CONV_RATE  NUMBER;
    PO_PTV_CTR_CCY_ROUND_TO   NUMBER;
    PO_PTV_AMT_TXN_LCY        NUMBER;
    PO_PTV_AMT_TXN_TCY        NUMBER;
    PO_PTV_AMT_TXN_ACY        NUMBER;
    VAR_PO_ACCT_TO_RATE       NUMBER;
    VAR_PTV_COD_TXN_CCY       NUMBER; --  holds the OUT value so VAR_TRANSACTION_CCY survives the call
    PO_PTV_RESPONSE_CODE      VARCHAR2(255);
    PO_PTV_RESPONSE_MESSAGE   VARCHAR2(255);
  
    --FIND TASK LITERAL NARRATIVE
    VAR_TASK_LITERAL_DERIVED VARCHAR2(255);
    VAR_TXT_NARRATIVE        VARCHAR2(255);
  
    --Call WDR
    VAR_AMT_TXN_ACY        NUMBER;
    VAR_WDR_PO_COD_EXT     VARCHAR2(255);
    VAR_WDR_PO_COD_REPLY   NUMBER;
    VAR_WDR_REF_SUBSEQ_NO  NUMBER := 0; -- First call = 0
    VAR_WDR_PO_USN         NUMBER;
    VAR_TXN_DESC_NARRATIVE VARCHAR(750);
  
    --Call GL_TXNS
    VAR_GL_ACCOUNT       VARCHAR(14);
    VAR_SPL_GL_ACCOUNT   VARCHAR(14);
    VAR_SPL_GL_3_ACCOUNT VARCHAR(14);
    VAR_COD_SPL_BRN      NUMBER := 9429;
    VAR_L_IS_SPECIAL     NUMBER := 0; -- 1 = EFFECTIVE special (2030); PCM clause can force standard
    VAR_L_SWIFT_OK       NUMBER := 1; -- BR-19/BR-20 swiftErrorCode equivalent ('0' = ok)
    --  reason the FCC push failed; goes back in the response message
    VAR_L_SWIFT_FAIL_REASON VARCHAR2(300);
    VAR_NET_PARKING_GL      VARCHAR2(50);
    VAR_PI_AMT_TXN_LCY_IN   NUMBER;
    VAR_DAT_TXN             NUMBER;
    VAR_GLTXN_PO_USN        NUMBER;
  
    -- PROCESS SC
    SC_TXN_CCY_CONV_RATE  NUMBER;
    SC_ACCT_CCY_CONV_RATE NUMBER;
    VAR_SC_PO_COD_EXT     VARCHAR2(255);
  
    --network ref no
    VAR_L_REF_NETWORK_NO VARCHAR2(255);
    VAR_L_SEQ            VARCHAR2(255);
    VAR_L_NET_QUERY      VARCHAR2(255);
    VAR_PO_SEQ_CURR      VARCHAR2(255);
  
    -- CUSTORMER DETAILS
    VAR_L_CUSTOMER_FNAME    VWE_CI_CUSTMAST.COD_CUST_PHONETIC%TYPE;
    VAR_L_CUSTOMER_PHONE_NO VWE_CI_CUSTMAST_PHONE.PHONE%TYPE;
    VAR_L_COD_NATIONAL_ID   VWE_CI_CUSTMAST.COD_CUST_NATL_ID%TYPE;
    VAR_L_HOME_BRN_COD      VWE_CI_CUSTMAST.COD_CC_HOMEBRN%TYPE;
  
    VAR_L_DAT_PROCESS BA_BANK_MAST.DAT_PROCESS%TYPE := PK_BA_GLOBAL.DAT_PROCESS;
  
    --processOutgoingSWIFTMessage
    VAR_NETWORK_BRANCH      NUMBER;
    VAR_SWIFT_LOB           NUMBER;
    VAR_DAT_STR_YYMMDD      VARCHAR(20);
    VAR_API_SWIFT_NTWRK_REF VARCHAR(20);
    VAR_SEQ_SWIFT_NTWRK_REF VARCHAR(20);
  
    SWIFT_REQ_MESSAGE     VARCHAR2(32767);
    SWIFT_RES_MESSAGE     VARCHAR2(32767);
    SWIFT_RES_XML_MESSAGE XMLTYPE;
  
    SWIFT_WARN_CODE VARCHAR(200);
  
    -- ==========================================
    -- NEW VARIABLES FOR WDR and GL OPTIMIZATION
    VAR_FINAL_ORG_BRN   NUMBER;
    VAR_FINAL_GL_ACCT   VARCHAR2(50);
    VAR_FINAL_GL_3_ACCT VARCHAR2(50);
    VAR_FINAL_GLTXN_USN NUMBER;
    VAR_FINAL_ACCT_NO   VARCHAR2(50);
  
    -- For WDR Parameters
    VAR_WDR_AMT_TXN_LCY    NUMBER;
    VAR_WDR_AMT_TXN_ACY    NUMBER;
    VAR_WDR_TXN_CONV_RATE  NUMBER;
    VAR_WDR_ACCT_CONV_RATE NUMBER;
  
    -- For GL Parameters
    VAR_GL1_AMT_TXN_LCY    NUMBER;
    VAR_GL1_TXN_CONV_RATE  NUMBER;
    VAR_GL1_ACCT_CONV_RATE NUMBER;
  
    VAR_GL_AMT_TXN_LCY    NUMBER;
    VAR_GL_TXN_CONV_RATE  NUMBER;
    VAR_GL_ACCT_CONV_RATE NUMBER;
  
    VAR_SC_AMT_TXN_LCY NUMBER;
  BEGIN
    --  NGI-194: start every call with an empty per-transaction cache so nothing can
    --  leak between two payments that share a pooled session.
    AP_OL_RESET_TXN_CACHE;
  
    --processDate
    BEGIN
      SELECT DAT_PROCESS, COD_LCY
        INTO VAR_DATE_PROCESS, VAR_BANK_LOC_CUR_SRT_NAME
        FROM BA_BANK_MAST
       WHERE COD_BANK = VAR_G_COD_BANK
         AND FLG_MNT_STATUS = 'A';
    EXCEPTION
      WHEN OTHERS THEN
        PO_RESPONSE_CODE    := '1001';
        PO_RESPONSE_MESSAGE := 'Failed to fetch bank DAT_PROCESS, COD_LCY';
        RETURN 1;
    END;
  
    VAR_TXN_DATE := TO_CHAR(VAR_DATE_PROCESS, 'YYYYMMDDHH24MISS');
  
    --Checking Duplicate User Reference--
    BEGIN
      VAR_L_RETURN_VALUE := AP_VAL_DUP_SVC_REQ(PI_TRACE_ID,
                                               VAR_L_IL_CHANNEL,
                                               PI_SVC_CODE,
                                               PI_SVC_RQ_ID,
                                               VAR_TXN_DATE,
                                               PO_RESPONSE_CODE,
                                               PO_RESPONSE_MESSAGE);
    
      IF VAR_L_RETURN_VALUE <> 0 THEN
        RETURN VAR_L_RETURN_VALUE;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        PO_RESPONSE_CODE    := '1210';
        PO_RESPONSE_MESSAGE := 'Database Error: AP_VAL_DUP_SVC_REQ';
        RETURN VAR_L_RETURN_VALUE;
    END;
  
    --PI_ACCT_TYPE validation
    BEGIN
      IF PI_ACCT_TYPE NOT IN ('00', '20', '26', '30', '40', '50') THEN
        PO_RESPONSE_CODE    := '200211';
        PO_RESPONSE_MESSAGE := 'Missing Data Map Entry';
        RETURN 1;
      END IF;
    END;
  
    --PI_XFER_COST_CTR validation
    BEGIN
      SELECT COUNT(*)
        INTO VAR_COUNT_XFER_COST_CTR
        FROM BA_CC_BRN_MAST
       WHERE COD_CC_BRN = PI_XFER_COST_CTR
         AND FLG_MNT_STATUS = 'A';
    
      IF VAR_COUNT_XFER_COST_CTR = 0 THEN
        PO_RESPONSE_CODE    := '33';
        PO_RESPONSE_MESSAGE := 'Invalid branch code';
        RETURN 1;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        PO_RESPONSE_CODE    := '33';
        PO_RESPONSE_MESSAGE := 'Invalid branch code';
        RETURN 1;
    END;
  
    --PI_XREFF_NUMBER validation
    IF LENGTH(PI_XREFF_NUMBER) > 40 THEN
      PO_RESPONSE_CODE    := 'NACSDAS000';
      PO_RESPONSE_MESSAGE := 'bdiXReffNumber too large';
      RETURN 1;
    END IF;
  
    --PI_BENF_ID validation
    IF TRIM(PI_BENF_ID) IS NULL OR LENGTH(PI_BENF_ID) > 11 THEN
      PO_RESPONSE_CODE    := 'NACSDAS000';
      PO_RESPONSE_MESSAGE := 'Invalid bdiBenfID';
      RETURN 1;
    END IF;
  
    --checkForDuplicateRequest
    -- ============================================================================
    --  NGI-194: DISABLED ON PURPOSE.
    --
    --  CHANNEL_TXN_XREF holds ~506 M rows / ~124 GB and its optimizer statistics are
    --  badly stale, so this single lookup dominated the response time and was the
    --  main reason the channel timed out while the payment still committed.
    --
    --  Nothing is lost: AP_VAL_DUP_SVC_REQ above already rejects a repeated
    --  svcRqId, so a retry after a timeout still cannot post the payment twice.
    --  IL keeps its own equivalent check (CommonHelper.checkForDuplicateRequest);
    --  re-enable the block below if the bank ever wants that second guard back and
    --  the table's statistics have been refreshed.
    --
    --  BEGIN
    --      SELECT COUNT (*)
    --        INTO VAR_CHECK_FOR_DUP_REF
    --        FROM channel_txn_xref
    --       WHERE     REF_USR_NO = VAR_CHECK_FOR_DUP_EXT_REF
    --             AND ORG_CHNL_ID = VAR_CHECK_FOR_DUP_CHANNEL
    --             AND DAT_TXN >= TRUNC (SYSDATE)
    --             AND DAT_TXN < TRUNC (SYSDATE) + 1
    --             AND ROWNUM = 1;
    --  EXCEPTION
    --      WHEN OTHERS
    --      THEN
    --          --  IL downgrades a failure of this check to a warning and carries on
    --          VAR_CHECK_FOR_DUP_REF := 0;
    --  END;
    -- ============================================================================
    VAR_CHECK_FOR_DUP_REF := 0;
  
    VAR_PAYMENT_TXN_LOG.PAYMENT_DIRECTION        := VAR_G_PAYMENT_DIRECTION;
    VAR_PAYMENT_TXN_LOG.ACCOUNT_NO               := PI_ACCT_ID;
    VAR_PAYMENT_TXN_LOG.COUNTER_PARTY_ACCOUNT_NO := PI_BENF_ACCT;
    VAR_PAYMENT_TXN_LOG.USER_ID                  := PI_USER_ID;
  
    BEGIN
      IF VAR_CHECK_FOR_DUP_REF > 0 THEN
        PO_RESPONSE_CODE    := '1001';
        PO_RESPONSE_MESSAGE := 'Duplicate User Referance Number: ' ||
                               VAR_CHECK_FOR_DUP_EXT_REF;
        RETURN 1;
      END IF;
    
      --amountInFromAccountCurrency
      VAR_RET_AMT_IN_FROM_ACCT_CURR := POPULATE_CCY_AMOUNT(PI_ACCT_CUR,
                                                           PI_XFER_AMT_FRM,
                                                           0,
                                                           VAR_AMT_IN_FROM_ACCT_CURR);
    
      --amountInLocalCurrency
      --  local amount comes from BDIXferAmtFrmLCE, not from FRM
      VAR_RET_AMT_IN_LOCAL_CURR := POPULATE_CCY_AMOUNT('000',
                                                       PI_XFER_AMT_FRM_LCE,
                                                       0,
                                                       VAR_AMT_IN_LOCAL_CURR);
    
      --amountInTransferCurrency
      VAR_RET_AMT_IN_XFER_CURR := POPULATE_CCY_AMOUNT(PI_XFER_CUR_CODE,
                                                      PI_XFER_AMT_TO,
                                                      0,
                                                      VAR_AMT_IN_XFER_CURR);
    
      VAR_LOCAL_CCY := VAR_BANK_LOC_CUR_SRT_NAME;
    
      --  the codes handed to the OLTP procedures are ISO numeric, so convert the request
      --  value directly instead of going through the currency lookup
      VAR_TRANSACTION_CCY := CASE WHEN TRIM(PI_XFER_CUR_CODE) IN ('000', '888') THEN VAR_LOCAL_CCY ELSE TO_NUMBER(TRIM(PI_XFER_CUR_CODE)) END;
      VAR_I_ACCOUNT_CCY   := CASE WHEN TRIM(PI_ACCT_CUR) IN ('000', '888') THEN VAR_LOCAL_CCY ELSE TO_NUMBER(TRIM(PI_ACCT_CUR)) END;
    
      --  transfer currency short name for the FCUBS envelope and the FCC engine
      BEGIN
        --  NGI-194: served from the per-transaction currency cache
        VAR_XFER_CCY_SHORT := AP_OL_GET_CCY_SHORT(VAR_TRANSACTION_CCY);
      EXCEPTION
        WHEN OTHERS THEN
          VAR_XFER_CCY_SHORT := VAR_AMT_IN_XFER_CURR.CURRENCY_CODE;
      END;
    
      --  account currency short name.  The insert used to carry an in-line
      --  MAX (NAM_CCY_SHORT) sub-select, which yields NULL when no active row
      --  exists rather than raising - so the miss is swallowed here too.
      BEGIN
        VAR_ACCT_CCY_SHORT := AP_OL_GET_CCY_SHORT(VAR_ACCOUNT_CCY);
      EXCEPTION
        WHEN OTHERS THEN
          VAR_ACCT_CCY_SHORT := NULL;
      END;
    
      IF TRIM(PI_XREFF_NUMBER) IS NOT NULL THEN
        --  exact match on '*PCM1'; plain 'PCM1' and '*RIB1' stay special
        IF TRIM(PI_CHANNEL_ID) = '*PCM1' AND NVL(PI_XRATE_AMT, 0) <> 0 THEN
          VAR_L_IS_SPECIAL := 0; -- PCM standard treatment (UAT case-2: 2043 @ branch 9429, push YES)
        ELSE
          VAR_L_IS_SPECIAL := 1; -- true special rate (2030, waits screen 2032)
        END IF;
      END IF;
    
      --  the network account status only applies where the four network legs are booked
      IF VAR_L_IS_SPECIAL = 0 THEN
        VAR_L_NTWK_ACCT_STAT := 2;
      END IF;
    
      --validate if account number contains only digits
      BEGIN
        SELECT LENGTH(TRIM(TRANSLATE(VAR_PAYMENT_TXN_LOG.ACCOUNT_NO,
                                     '0123456789',
                                     ' '))) AS VAL_ACCOUNT_NUMBER
          INTO VAL_ACCOUNT_NUMBER
          FROM DUAL;
      
        IF VAL_ACCOUNT_NUMBER > 0 THEN
          PO_RESPONSE_CODE    := '2928';
          PO_RESPONSE_MESSAGE := 'Invalid account number';
          RETURN 1;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          PO_RESPONSE_CODE    := '2928';
          PO_RESPONSE_MESSAGE := 'Invalid account number';
          RETURN 1;
      END;
    
      BEGIN
        -- ================================================================
        --  NGI-194 - THE hot spot.  Measured on UAT with EXPLAIN PLAN:
        --
        --    WHERE TRIM (COD_ACCT_NO) = ...   cost 152,000
        --        -> THREE full scans of CS_HO_CUSTACCTXREF (16.5 M rows,
        --           181,642 blocks each) because the function on the column
        --           makes every index on it unusable.
        --           3 x 181,642 = ~545,000 blocks, which is what the session
        --           counters showed for one payment (442,761 physical reads).
        --
        --    WHERE COD_ACCT_NO = ...          cost 18
        --        -> INDEX RANGE SCAN on CS_HO_CUSTACCTXREF_IDX2.
        --
        --  Both forms return the identical row ('CH' for the test account).
        --
        --  COD_ACCT_NO is CHAR(16).  Comparing a CHAR column with a VARCHAR2
        --  PL/SQL variable uses NON-padded semantics, so the value has to be
        --  padded to 16 explicitly or nothing matches - the same CHAR/VARCHAR2
        --  rule we already hit on REF_TXN_NO.  RPAD sits on the VALUE, not on
        --  the column, so the index stays usable.
        -- ================================================================
        SELECT COD_MODULE
          INTO VAR_ACCOUNT_TYPE
          FROM vwe_cs_ho_acct_module_xref
         WHERE COD_ACCT_NO =
               RPAD(TRIM(VAR_PAYMENT_TXN_LOG.ACCOUNT_NO), 16, ' ');
      EXCEPTION
        WHEN OTHERS THEN
          PO_RESPONSE_CODE    := 'PM0029';
          PO_RESPONSE_MESSAGE := 'Account type not found';
          RETURN 1;
      END;
    
      IF VAR_ACCOUNT_TYPE = 'CH' THEN
        BEGIN
          SELECT COD_ACCT_TITLE, COD_CUST, COD_CCY, FLG_MEMO
            INTO VAR_ACCOUNT_TITLE,
                 VAR_CUSTOMER_ID,
                 VAR_ACCOUNT_CCY,
                 VAR_L_FLG_MEMO_F
            FROM vwe_ch_acct_mast
           WHERE TRIM(COD_ACCT_NO) = VAR_PAYMENT_TXN_LOG.ACCOUNT_NO;
        EXCEPTION
          WHEN OTHERS THEN
            PO_RESPONSE_CODE    := '2928';
            PO_RESPONSE_MESSAGE := 'Invalid account no';
            RETURN 1;
        END;
      END IF;
    
      /* high memo
      */
      IF NVL(VAR_L_FLG_MEMO_F, 'N') <> 'N' THEN
        DECLARE
          VAR_L_TXT_MEMO          VARCHAR2(3000);
          VAR_L_FLG_CUST_MEMO_SEV VARCHAR2(1);
          VAR_L_FLG_ACCT_MEMO_SEV VARCHAR2(1);
        BEGIN
          VAR_L_RETURN_VALUE := AP_BA_GET_MEMO(VAR_PI_FLG_CUST_ACCT_MEMO => VAR_L_FLG_MEMO_F,
                                               VAR_PI_COD_CUST_ID        => VAR_CUSTOMER_ID,
                                               VAR_PI_COD_ACCT_NO        => RPAD(TO_CHAR(PI_ACCT_ID),
                                                                                 16,
                                                                                 ' '),
                                               VAR_PO_TXT_MEMO           => VAR_L_TXT_MEMO,
                                               VAR_PO_FLG_CUST_MEMO_SEV  => VAR_L_FLG_CUST_MEMO_SEV,
                                               VAR_PO_FLG_ACCT_MEMO_SEV  => VAR_L_FLG_ACCT_MEMO_SEV);
        
          IF VAR_L_FLG_CUST_MEMO_SEV = 'H' OR VAR_L_FLG_ACCT_MEMO_SEV = 'H' THEN
            PO_RESPONSE_CODE    := '11';
            PO_RESPONSE_MESSAGE := 'There is a memo present on the Debit account';
            RETURN 1;
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            PO_RESPONSE_CODE    := '11';
            PO_RESPONSE_MESSAGE := 'Unable to check memo severity level';
            RETURN 1;
        END;
      END IF;
    
      VAR_PAYMENT_TXN_LOG.BANK_CODE   := VAR_G_COD_BANK;
      VAR_PAYMENT_TXN_LOG.BRANCH_CODE := TO_NUMBER(PI_XFER_COST_CTR);
      VAR_REL_TXN_STORE.ACCOUNT_TITLE := VAR_ACCOUNT_TITLE;
      VAR_PAYMENT_TXN_LOG.CUSTOMER_ID := VAR_CUSTOMER_ID;
    
      IF (TRIM(PI_XREFF_NUMBER) IS NULL) AND
         (VAR_TRANSACTION_CCY <> VAR_LOCAL_CCY) THEN
        --transferBuyExchangeRates
        BEGIN
          SELECT (rat_ccy_mid - rat_xfer_buy_sprd) AS buy_rate,
                 (rat_ccy_mid + rat_xfer_sell_sprd) AS sell_rate,
                 rat_ccy_mid AS mid_rate
            INTO VAR_BUY_RATE, VAR_SELL_RATE, VAR_MID_RATE
            FROM (SELECT rat_ccy_mid,
                         rat_xfer_buy_sprd,
                         rat_xfer_sell_sprd,
                         RANK() OVER(ORDER BY dat_tim_rate_eff DESC) latest
                    FROM ba_ccy_rate
                   WHERE cod_ccy = VAR_TRANSACTION_CCY
                     AND FLG_MNT_STATUS = 'A')
           WHERE latest = 1;
        EXCEPTION
          WHEN OTHERS THEN
            PO_RESPONSE_CODE    := 'ONL_BDI_002';
            PO_RESPONSE_MESSAGE := 'No rates found';
            RETURN 1;
        END;
      
        IF VAR_LOCAL_CCY <> VAR_I_ACCOUNT_CCY THEN
          IF (VAR_TRANSACTION_CCY = VAR_I_ACCOUNT_CCY) AND
             (VAR_TRANSACTION_CCY <> VAR_LOCAL_CCY) THEN
            VAR_EXCHANGE_RATE := VAR_MID_RATE;
          ELSE
            IF VAR_TRANSACTION_CCY <> VAR_I_ACCOUNT_CCY AND
               VAR_LOCAL_CCY <> VAR_I_ACCOUNT_CCY AND
               VAR_LOCAL_CCY <> VAR_TRANSACTION_CCY THEN
              IF VAR_EXCHANGE_RATE <> VAR_SELL_RATE THEN
                PO_RESPONSE_CODE    := 'ONL_BDI_004';
                PO_RESPONSE_MESSAGE := 'Invalid foreign exhange rate';
                RETURN 1;
              END IF;
            ELSE
              IF NOT (VAR_EXCHANGE_RATE >= VAR_BUY_RATE AND
                  VAR_EXCHANGE_RATE <= VAR_MID_RATE) THEN
                PO_RESPONSE_CODE    := 'ONL_BDI_004';
                PO_RESPONSE_MESSAGE := 'Invalid foreign exhange rate';
                RETURN 1;
              END IF;
            END IF;
          END IF;
        END IF;
      ELSE
        VAR_EXCHANGE_RATE := 1;
      END IF;
    
      --  a zero rate from the channel is replaced by the board buy rate
      IF NVL(VAR_EXCHANGE_RATE, 0) = 0 THEN
        VAR_EXCHANGE_RATE := VAR_BUY_RATE;
      END IF;
    
      VAR_TXN_VALUE.AMOUNT_LCY := VAR_AMT_IN_LOCAL_CURR;
      VAR_TXN_VALUE.AMOUNT_ACY := VAR_AMT_IN_FROM_ACCT_CURR;
    
      --  BR-4: the account rate uses the loaded account's currency, not the channel field
      IF VAR_ACCOUNT_CCY <> VAR_LOCAL_CCY THEN
        VAR_FROM_RATE := F_IL_RATE(PI_XFER_AMT_FRM_LCE / PI_XFER_AMT_FRM);
      END IF;
    
      VAR_TXN_VALUE.TXN_CCY_CONV_RATE               := VAR_MID_RATE;
      VAR_TXN_VALUE.AMOUNT_TCY                      := VAR_AMT_IN_XFER_CURR;
      VAR_PAYMENT_TXN_LOG.TRANSACTION_CURRENCY_CODE := VAR_TRANSACTION_CCY;
    
      --  the posted rate keys on the dealer reference; the mnemonic keys on the effective
      --  rate type, which the PCM clause can flip
      IF TRIM(PI_XREFF_NUMBER) IS NULL THEN
        VAR_TXN_VALUE.TXN_CCY_CONV_RATE := F_IL_RATE(VAR_EXCHANGE_RATE);
      ELSE
        IF VAR_TRANSACTION_CCY <> VAR_LOCAL_CCY THEN
          VAR_TO_RATE := F_IL_RATE(PI_XFER_AMT_FRM_LCE / PI_XFER_AMT_TO);
        END IF;
      
        VAR_TXN_VALUE.TXN_CCY_CONV_RATE := F_IL_RATE(VAR_TO_RATE);
      END IF;
    
      -- (b) mnemonic by effective rate type (PCM clause aware)
      IF VAR_L_IS_SPECIAL = 0 THEN
        VAR_PAYMENT_TXN_LOG.TRANSACTION_MNEMONIC := VAR_G_MNEM_CASA_GL_FLOW;
      ELSE
        VAR_PAYMENT_TXN_LOG.TRANSACTION_MNEMONIC := VAR_G_MNEM_OUTG_PAY_FLOW;
      END IF;
    
      VAR_PAYMENT_TXN_LOG.TRANSACTION_VALUE := VAR_TXN_VALUE;
    
      --transalateNetworkMessage
      BEGIN
        SELECT COD_NETWORK_ID, COD_PAYMENT_TXN
          INTO VAR_NETWORK_ID, VAR_TRANSACTION_ID
          FROM pm_network_msg_translator
        --  keyed by the context channel
         WHERE cod_msg_type_id = 'CAW'
           AND cod_msg_extd_type_id = 'SWIFT'
           AND FLG_MNT_STATUS = 'A';
      EXCEPTION
        WHEN OTHERS THEN
          PO_RESPONSE_CODE    := 'GEF_BDI_005';
          PO_RESPONSE_MESSAGE := 'Invalid Channel';
          RETURN 1;
      END;
    
      VAR_PAYMENT_TXN_LOG.PAYMENT_TRANSACTION_CODE := VAR_TRANSACTION_ID;
      VAR_REL_TXN_STORE.PAYMENT_TRANSACTION_CODE   := VAR_TRANSACTION_ID;
      VAR_PAYMENT_TXN_LOG.NETWORK_ID               := VAR_NETWORK_ID;
    
      VAR_OUTGOING_PAYMENT.INSTRUMENT_DETAILS := VAR_BASIC_INSTRUMENT_DTL;
      VAR_OUTGOING_PAYMENT.TRANSACTION_TYPE   := VAR_G_NORMAL_TRANSACTION;
    
      VAR_PAYMENT_MAPPING.PAYMENT_TXN_LOG  := VAR_PAYMENT_TXN_LOG;
      VAR_PAYMENT_MAPPING.REL_TXN_STORE    := VAR_REL_TXN_STORE;
      VAR_PAYMENT_MAPPING.OUTGOING_PAYMENT := VAR_OUTGOING_PAYMENT;
    
      --populateRelationalTransactionStore
      BEGIN
        SELECT COD_CTPARTY_ACCT,
               NAM_CTPARTY_BANK,
               NAM_CTPARTY_BRANCH,
               COD_FIN_INST_ID,
               cod_ctparty_acct
          INTO VAR_COUNTER_PARTY_ACCT_NO,
               VAR_COUNTER_PARTY_BANK,
               VAR_COUNTER_PARTY_BRANCH,
               VAR_REL_TXN_STORE.COUNTER_PARTY_ROUTING_CODE,
               VAR_REL_TXN_STORE.COUNTER_PARTY_IBAN_NO
          FROM pm_counterparty_mast
         WHERE cod_ctparty_id = PI_BENF_ACCT
           AND FLG_MNT_STATUS = 'A';
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;
        WHEN OTHERS THEN
          PO_REF_NO           := VAR_CHECK_FOR_DUP_EXT_REF;
          PO_RESPONSE_CODE    := 'PM019';
          PO_RESPONSE_MESSAGE := 'PM Counterparty master error';
          RETURN 1;
      END;
    
      --  NGI-197: IL puts no length limit on the memo, and the SIMODIS block
      --  further down slices PI_MEMO1 into four 35-character fields (1-35, 36-70,
      --  71-105, 106-140), so a 140-character memo is expected here.  This field
      --  is VARCHAR2(50), so the value is cut to the same 35 characters the
      --  SIMODIS path uses for it - without this, a long memo raises ORA-06502
      --  before the SIMODIS block is ever reached.
      VAR_REL_TXN_STORE.ORIGINAL_REMIT_NO := SUBSTR(PI_MEMO1, 1, 35);
    
      --  BR-13: slash and mnemonic follow the effective rate type
      IF VAR_L_IS_SPECIAL = 0 THEN
        VAR_REL_TXN_STORE.RECEIVER_ACCOUNT_NO  := '/' || PI_ACCT_ID;
        VAR_REL_TXN_STORE.TRANSACTION_MNEMONIC := '2043';
      ELSE
        VAR_REL_TXN_STORE.RECEIVER_ACCOUNT_NO  := PI_ACCT_ID;
        VAR_REL_TXN_STORE.TRANSACTION_MNEMONIC := '2030';
      END IF;
    
      VAR_COUNTER_PARTY_DETAIL.COUNTER_PARTY_ACCOUNT_ID := PI_BENF_ACCT; --updating reltxnstore after fcc call
      VAR_COUNTER_PARTY_DETAIL.COUNTER_PARTY_NAME       := PI_BENF_NAME;
    
      --  BR-10: address splits at 35 characters, anything past 70 is dropped
      IF PI_BENF_ADDRESS IS NOT NULL THEN
        VAR_COUNTER_PARTY_DETAIL.ADDRESS_LINE_1 := SUBSTR(PI_BENF_ADDRESS,
                                                          1,
                                                          35);
      
        IF LENGTH(PI_BENF_ADDRESS) > 35 THEN
          VAR_COUNTER_PARTY_DETAIL.ADDRESS_LINE_2 := SUBSTR(PI_BENF_ADDRESS,
                                                            36,
                                                            35);
        END IF;
      END IF;
    
      VAR_REL_TXN_STORE.DETAILS := VAR_COUNTER_PARTY_DETAIL;
    
      IF PI_XFEE_CODE = '0' THEN
        VAR_REL_TXN_STORE.PM_CHARGES_FEE_CODE := 'OUR';
      ELSIF PI_XFEE_CODE = '1' THEN
        VAR_REL_TXN_STORE.PM_CHARGES_FEE_CODE := 'BEN';
      ELSIF PI_XFEE_CODE = '2' THEN
        VAR_REL_TXN_STORE.PM_CHARGES_FEE_CODE := 'SHA';
      END IF;
    
      --C@W FCC Code Generation Start
      VAR_FCC_CODE_GENERATION_REC.BANK_SWIFT_CODE := PI_BENF_ID;
      --  correspondent or intermediary BIC replaces the beneficiary bank BIC here
      VAR_FCC_CODE_GENERATION_REC.INT_INS_OR_BEN_CORR_BIC_CODE := PI_BANK_CORESPONDENT1;
      --  the FCC engine expects the currency short name
      VAR_FCC_CODE_GENERATION_REC.CCY_CODE         := VAR_XFER_CCY_SHORT;
      VAR_FCC_CODE_GENERATION_REC.CHARGE_BEARER    := VAR_REL_TXN_STORE.PM_CHARGES_FEE_CODE;
      VAR_FCC_CODE_GENERATION_REC.TRANSACTION_TYPE := 'CAW';
      VAR_FCC_CODE_GENERATION_REC.TRANSACTION_DATE := TRUNC(SYSDATE);
      VAR_FCC_CODE_GENERATION_REC.TRANSACTION_TIME := TO_CHAR(SYSDATE,
                                                              'HH24:MI:SS');
      --  transaction amount, not the currency code (BR-8 throughput log)
      VAR_FCC_CODE_GENERATION_REC.TRANSACTION_AMOUNT := PI_XFER_AMT_TO;
    
      VAR_REL_TXN_STORE.RECEIVER_BIC_CODE := PI_BENF_ID;
    
      --generateFCCCodeAndNostro
      BEGIN
        VAR_L_RETURN_VALUE := GENERATE_FCC_CODE_AND_NOSTRO(VAR_FCC_CODE_GENERATION_REC,
                                                           VAR_OUT_FCC_PRODUCT_CODE,
                                                           PO_RESPONSE_CODE,
                                                           PO_RESPONSE_MESSAGE);
      
        IF VAR_L_RETURN_VALUE <> 0 THEN
          RETURN 1;
        END IF;
      
        VAR_REL_TXN_STORE.FCC_PRODUCT_CODE := VAR_OUT_FCC_PRODUCT_CODE;
      EXCEPTION
        WHEN OTHERS THEN
          RETURN 1;
      END;
    
      --fetchDecoySCForExternalFeeForSwift
      BEGIN
        SELECT MACRO_VALUE
          INTO VAR_SC_CODE
          FROM ba_site
         WHERE MACRO_NAME = 'BDI_CAW_OP_SWIFT_FEE_SC_CODE'
           AND FLG_MNT_STATUS = 'A';
      EXCEPTION
        WHEN OTHERS THEN
          PO_RESPONSE_CODE    := '4457';
          PO_RESPONSE_MESSAGE := 'Failed to fetch MACRO_VALUE from ba_site';
          RETURN 1;
      END;
    
      BEGIN
        SELECT COD_GL_SC_INCOME
          INTO VAR_SERVICE_CHARGE_GL_SC_INC
          FROM vwe_ba_sc_code
         WHERE FLG_MNT_STATUS = 'A'
           AND COD_CCY = VAR_LOCAL_CCY
           AND COD_SC = VAR_SC_CODE;
      EXCEPTION
        WHEN OTHERS THEN
          PO_RESPONSE_CODE    := '4457';
          PO_RESPONSE_MESSAGE := 'Failed to fetch COD_GL_SC_INCOME from vwe_ba_sc_code';
          RETURN 1;
      END;
    
      VAR_SERVICE_CHARGE.AMT_IN_LOCAL_CCY   := VAR_AMT_IN_LOCAL_CURR;
      VAR_SERVICE_CHARGE.AMT_IN_ACCT_CCY    := VAR_AMT_IN_FROM_ACCT_CURR;
      VAR_SERVICE_CHARGE.AMT_IN_TXN_CCY     := VAR_AMT_IN_LOCAL_CURR;
      VAR_SERVICE_CHARGE.AMT_IN_SC_CCY      := VAR_AMT_IN_LOCAL_CURR;
      VAR_SERVICE_CHARGE.SC_CCY_OPTION      := 'L';
      VAR_SERVICE_CHARGE.CODE               := VAR_SC_CODE;
      VAR_SERVICE_CHARGE.DEBIT_ACCT_ID      := PI_ACCT_ID;
      VAR_SERVICE_CHARGE.INCOME_LEDGER_CODE := VAR_SERVICE_CHARGE_GL_SC_INC;
    
      VAR_OUTGOING_PAYMENT.SERVICE_CHARGE_DETAILS := VAR_SERVICE_CHARGE;
    
      --setLLDDetails
      BEGIN
        VAR_BENIF_LLD_DETAILS_REC.LLD_RESIDENT  := SUBSTR(PI_LLD_INFO, 1, 2);
        VAR_BENIF_LLD_DETAILS_REC.LLD_CATEGORY  := SUBSTR(PI_LLD_INFO, 3, 2);
        VAR_BENIF_LLD_DETAILS_REC.LLD_AFFILIATE := SUBSTR(PI_LLD_INFO, 5, 1);
        VAR_BENIF_LLD_DETAILS_REC.LLD_IDENTITY  := SUBSTR(PI_LLD_INFO, 6, 2);
        VAR_BENIF_LLD_DETAILS_REC.LLD_PURPOSE   := TRIM(SUBSTR(PI_LLD_INFO,
                                                               8,
                                                               3));
        --  NGI-190: IL accepts an LLDInfo of 69 characters, so the description is
        --  everything from position 11 on - up to 59 characters.  IL does not trim
        --  it, so neither do we.
        VAR_BENIF_LLD_DETAILS_REC.LLD_DESCRIPTION := SUBSTR(PI_LLD_INFO, 11); -- Take the rest of the string as description
      EXCEPTION
        WHEN OTHERS THEN
          PO_RESPONSE_CODE    := '400000';
          PO_RESPONSE_MESSAGE := 'Invalid PI_LLD_INFO';
          RETURN 1;
      END;
    
      --  NGI-191: the beneficiary bank country ('United States', 'US', a full name -
      --  whatever the channel sends) is NOT stored in this record field.  The field was
      --  write-only dead code: nothing downstream ever read it, and forcing a country
      --  name into its VARCHAR2(10) declaration raised ORA-06502, which the LLD block's
      --  WHEN OTHERS caught and mis-reported as 'Invalid PI_LLD_INFO'.  The country
      --  reaches the database directly through PI_BENF_BCOUNTRY - the beneficiary bank
      --  address lines below and the CHANNEL_SWIFT_PAYMENT_XREF.LLD_COUNTRY insert - so
      --  removing the assignment loses nothing and matches IL, which never length-limits
      --  the country.
      VAR_REL_TXN_STORE.RECEIVER_CATEGORY := VAR_BENIF_LLD_DETAILS_REC.LLD_CATEGORY;
      VAR_REL_TXN_STORE.AFFILIATION_CODE  := VAR_BENIF_LLD_DETAILS_REC.LLD_AFFILIATE;
    
      --  a blank or failed purpose falls back to 2000
      VAR_REL_TXN_STORE.PURPOSE_CODE := '2' || LPAD(NVL(TRIM(VAR_BENIF_LLD_DETAILS_REC.LLD_PURPOSE),
                                                        '000'),
                                                    3,
                                                    '0');
    
      IF VAR_BENIF_LLD_DETAILS_REC.LLD_RESIDENT IS NOT NULL THEN
        IF TRIM(VAR_BENIF_LLD_DETAILS_REC.LLD_RESIDENT) IS NULL THEN
          VAR_REL_TXN_STORE.COUNTERPARTY_COUNTRY_CODE := 'ID';
        ELSE
          VAR_REL_TXN_STORE.COUNTERPARTY_COUNTRY_CODE := VAR_BENIF_LLD_DETAILS_REC.LLD_RESIDENT;
        END IF;
      ELSE
        VAR_REL_TXN_STORE.COUNTERPARTY_COUNTRY_CODE := 'ID';
      END IF;
    
      BEGIN
        SELECT TXT_CUST_NATNLTY,
               NAM_CUST_SHRT,
               COD_CUST_PHONETIC,
               COD_CUST_NATL_ID,
               COD_CC_HOMEBRN
          INTO VAR_CUSTOMER_NATIONALITY,
               VAR_REL_TXN_STORE.BENEFICIARY_NAME,
               VAR_L_CUSTOMER_FNAME,
               VAR_L_COD_NATIONAL_ID,
               VAR_L_HOME_BRN_COD
          FROM vwe_ci_custmast
         WHERE COD_CUST_ID = VAR_CUSTOMER_ID
           AND FLG_MNT_STATUS = 'A';
      EXCEPTION
        WHEN OTHERS THEN
          PO_RESPONSE_CODE    := '3431';
          PO_RESPONSE_MESSAGE := 'Invalid customer id';
          RETURN 1;
      END;
    
      BEGIN
        SELECT A.LINE1   AS C_LINE1,
               A.LINE2   AS C_LINE2,
               A.LINE3   AS C_LINE3,
               A.COUNTRY AS COUNTRY
          INTO VAR_REL_TXN_STORE.CUSTOMER_ADDRESS1,
               VAR_REL_TXN_STORE.CUSTOMER_ADDRESS2,
               VAR_REL_TXN_STORE.CUSTOMER_ADDRESS3,
               VAR_REL_TXN_STORE.CUSTOMER_COUNTRY
          FROM VWE_CI_CUSTMAST_ADD A
         WHERE COD_CUST_ID = VAR_CUSTOMER_ID
           AND FLG_MNT_STATUS = 'A'
           AND ADDR_TYPE = 'CURRENT';
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;
        WHEN OTHERS THEN
          PO_RESPONSE_CODE    := '3431';
          PO_RESPONSE_MESSAGE := 'Invalid customer id';
          RETURN 1;
      END;
    
      BEGIN
        SELECT PHONE
          INTO VAR_L_CUSTOMER_PHONE_NO
          FROM vwe_ci_custmast_phone
         WHERE COD_CUST_ID = VAR_CUSTOMER_ID
           AND FLG_MNT_STATUS = 'A'
           AND ROWNUM = 1;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    
      BEGIN
        SELECT field_value
          INTO VAR_UDF_FIELD_VALUE
          FROM UDF_CUST_LOG_DETAILS
         WHERE cod_field_tag = 'TXT_725'
              --  ###[PERF-UDF | measured 12-Sep-2026]###
              --  cod_cust_id is VARCHAR2; VAR_CUSTOMER_ID is NUMBER.
              --  Oracle resolves that mismatch by converting the
              --  COLUMN, so the predicate silently became
              --  TO_NUMBER(cod_cust_id) = :v and the index on
              --  UDF_CUST_LOG_DETAILS could not be used - every row
              --  carrying TXT_725 was converted and filtered one by
              --  one.  Measured on the sibling XFINX service, same
              --  table, same customer, same returned value:
              --      cod_cust_id = <NUMBER>         29,810 ms
              --      cod_cust_id = TO_CHAR(<NUMBER>)    50 ms
              --  Stored ids are plain unpadded digits, so no row that
              --  matched before can stop matching.  Result unchanged.
           AND cod_cust_id = TO_CHAR(VAR_CUSTOMER_ID)
           AND flg_mnt_status = 'A';
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;
        WHEN OTHERS THEN
          PO_RESPONSE_CODE    := 'BDI_UDF_FIELD_VALUE';
          PO_RESPONSE_MESSAGE := 'Invalid BDI UDF field value';
          RETURN 1;
      END;
    
      BEGIN
        SELECT lld_value
          INTO VAR_REMITTER_CATEGORY
          FROM ext_caw_swift_lld_map
         WHERE cod_Category = VAR_UDF_FIELD_VALUE;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          VAR_REMITTER_CATEGORY := 'N1';
        WHEN OTHERS THEN
          PO_RESPONSE_CODE    := '1001';
          PO_RESPONSE_MESSAGE := 'Failed to select cod_Category from ext_caw_swift_lld_map';
          RETURN 1;
      END;
    
      VAR_REL_TXN_STORE.CUSTOMER_COUNTRY_CODE := VAR_CUSTOMER_NATIONALITY;
      VAR_REL_TXN_STORE.REMITTER_CATEGORY     := VAR_REMITTER_CATEGORY;
    
      --  BR-17: narrative = memo1 + memo2, trimmed and cut to 40 characters
      VAR_L_NARRATIVE := SUBSTR(TRIM(TRIM(PI_MEMO1) || TRIM(PI_MEMO2)),
                                1,
                                40);
    
      IF VAR_L_NARRATIVE IS NOT NULL THEN
        VAR_REL_TXN_STORE.NARRATIVE := VAR_L_NARRATIVE;
      END IF;
    
      --processOutgoingAccountPayment
      BEGIN
        SELECT *
          INTO VAR_L_PM_TXN_DEFN_ROW
          FROM pm_txn_defn
         WHERE cod_payment_txn =
               VAR_PAYMENT_TXN_LOG.PAYMENT_TRANSACTION_CODE
           AND flg_mnt_status = 'A';
      EXCEPTION
        WHEN OTHERS THEN
          PO_RESPONSE_CODE    := '1001';
          PO_RESPONSE_MESSAGE := 'Failed to select from pm_txn_defn';
          RETURN 1;
      END;
    
      BEGIN
        SELECT cod_casa_pymt_pkg_id
          INTO VAR_CASA_PAYMENT_PACKAGE
          FROM pm_global_params
         WHERE COD_BANK = VAR_G_COD_BANK
           AND FLG_MNT_STATUS = 'A';
      
        VAR_REL_TXN_STORE.PAYMENT_PACKAGE_ID := VAR_CASA_PAYMENT_PACKAGE;
      EXCEPTION
        WHEN OTHERS THEN
          PO_RESPONSE_CODE    := 'PM0016';
          PO_RESPONSE_MESSAGE := 'No account payment package available';
          RETURN 1;
      END;
    
      --STEP 2
      --validatePaymentPackage
      BEGIN
        SELECT COUNT(*)
          INTO VAR_COUNT_ALLOWED_TXN
          FROM pm_pkg_allwd_txns A
         WHERE A.COD_PKG_ID = VAR_CASA_PAYMENT_PACKAGE
           AND A.COD_PAYMENT_TXN =
               VAR_PAYMENT_TXN_LOG.PAYMENT_TRANSACTION_CODE
           AND A.flg_mnt_status = 'A';
      
        IF VAR_COUNT_ALLOWED_TXN = 0 THEN
          PO_RESPONSE_CODE    := 'PM0013';
          PO_RESPONSE_MESSAGE := 'MID_EPM_TXN_NOT_ALLOWED';
          RETURN 1;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          PO_RESPONSE_CODE    := 'PM0013';
          PO_RESPONSE_MESSAGE := 'MID_EPM_TXN_NOT_ALLOWED';
          RETURN 1;
      END;
    
      --transferFundsFromAccountWithServiceCharge
      VAR_INTERMEDIARY_LEDGER_ID := VAR_L_PM_TXN_DEFN_ROW.cod_inter_gl_acct;
    
      --callMiscellaneousDebitCommonWithAcctRate
    
      -----Read and Validate Data----
      BEGIN
        VAR_L_RETURN_VALUE := AP_READ_DATA(PI_SVC_RQ_ID,
                                           PI_USER_ID,
                                           VAR_DATE_PROCESS,
                                           VAR_MNEMONIC_MISCE_CUST_D,
                                           PI_ACCT_ID,
                                           PI_ACCT_CUR,
                                           VAR_ARD_PO_COD_CC_BRN_F,
                                           VAR_ARD_PO_COD_PROD_F,
                                           VAR_ARD_PO_ACCT_CUR_F,
                                           VAR_ARD_PO_USN_F,
                                           VAR_ARD_PO_FLG_PSBOOK_F,
                                           VAR_ARD_PO_BAL_LST_PSBK_F,
                                           VAR_ARD_PO_COD_CUST_F,
                                           VAR_ARD_PO_CTR_PSBK_LINE_NO_F,
                                           VAR_ARD_PO_USER_ROW,
                                           VAR_ARD_PO_REF_TXN_NO,
                                           VAR_ARD_PO_STAN_NO,
                                           PO_RESPONSE_CODE,
                                           PO_RESPONSE_MESSAGE);
      
        IF VAR_L_RETURN_VALUE <> 0 THEN
          RETURN 1;
        END IF;
      
        VAR_REL_TXN_STORE.REFERENCE_NUMBER := VAR_ARD_PO_REF_TXN_NO;
      EXCEPTION
        WHEN OTHERS THEN
          PO_RESPONSE_CODE    := '1001';
          PO_RESPONSE_MESSAGE := 'Error executing AP_READ_DATA';
          RETURN 1;
      END;
    
      --AP_OL_CALC_DAT_LOG
      BEGIN
        VAR_L_RETURN_VALUE := AP_OL_CALC_DAT_LOG(VAR_DATE_PROCESS,
                                                 VAR_CDL_PO_DAT_LOG);
      
        IF VAR_L_RETURN_VALUE <> 0 THEN
          PO_RESPONSE_CODE    := '1001';
          PO_RESPONSE_MESSAGE := 'Error executing AP_OL_CALC_DAT_LOG';
          RETURN 1;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          PO_RESPONSE_CODE    := '1001';
          PO_RESPONSE_MESSAGE := 'Error executing AP_OL_CALC_DAT_LOG';
          RETURN 1;
      END;
    
      --FIND TASK LITERAL NARRATIVE
      BEGIN
        SELECT COD_TASK_LITERAL_DERIVED, TXT_NARRATIVE
          INTO VAR_TASK_LITERAL_DERIVED, VAR_TXT_NARRATIVE
          FROM vwe_ba_txn_chnl_xref_attr
         WHERE cod_task_derived = TO_CHAR(VAR_MNEMONIC_MISCE_CUST_D)
              --  keyed by the context channel
           AND cod_chnl_id = 'CAW'
           AND cod_service = VAR_L_PM_TXN_DEFN_ROW.COD_PAYMENT_TYPE
           AND cod_composite_task = 'CIM09' --hard coded
           AND COD_DRCR = 'D'; --hard coded
      EXCEPTION
        WHEN OTHERS THEN
          PO_RESPONSE_CODE    := 'PM0016';
          PO_RESPONSE_MESSAGE := 'Failed to select from vwe_ba_txn_chnl_xref_attr';
          RETURN 1;
      END;
    
      --AP_OL_PREPARE_TXN_VAL
      BEGIN
        VAR_L_RETURN_VALUE := AP_OL_PREPARE_TXN_VAL_COMMON(VAR_MNEMONIC_MISCE_CUST_D,
                                                           PI_XFER_AMT_FRM,
                                                           VAR_ARD_PO_ACCT_CUR_F,
                                                           VAR_TRANSACTION_CCY,
                                                           VAR_L_COD_LCY,
                                                           VAR_DATE_PROCESS,
                                                           PO_PTV_TXN_RATE,
                                                           PI_PTV_ACCT_RATE,
                                                           TRUE,
                                                           --  tenth argument is OUT, so it needs its own variable - passing
                                                           --  VAR_TRANSACTION_CCY here let the call overwrite the transfer currency
                                                           VAR_PTV_COD_TXN_CCY,
                                                           PO_PTV_ACCT_CCY_CONV_RATE,
                                                           PO_PTV_TXN_CCY_CONV_RATE,
                                                           PO_PTV_CTR_CCY_ROUND_TO,
                                                           PO_PTV_AMT_TXN_LCY,
                                                           PO_PTV_AMT_TXN_TCY,
                                                           PO_PTV_AMT_TXN_ACY,
                                                           VAR_PO_ACCT_TO_RATE,
                                                           PO_PTV_RESPONSE_CODE,
                                                           PO_PTV_RESPONSE_MESSAGE);
      
        IF VAR_L_RETURN_VALUE <> 0 THEN
          RETURN VAR_L_RETURN_VALUE;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          RETURN 1;
      END;
    
      BEGIN
        VAR_L_RETURN_VALUE := AP_CM_AM_EXCHANGE(PI_XFER_AMT_FRM,
                                                VAR_ACCOUNT_CCY,
                                                VAR_TRANSACTION_CCY,
                                                VAR_MNEMONIC_MISCE_CUST_D,
                                                VAR_LOCAL_CCY,
                                                SYSDATE,
                                                VAR_EXR_MLT_UNIT_RAT_QUOT_SRC,
                                                VAR_EXR_MLT_UNIT_RAT_QUOT_DEST,
                                                VAR_EXR_FLG_CCY_CONV_SRC,
                                                VAR_EXR_FLG_CCY_CONV_DEST,
                                                VAR_EXR_CTR_CCY_ROUND_TO_LCY,
                                                VAR_EXR_CTR_CCY_ROUND_TO_DEST,
                                                VAR_EXR_RAT_SRC,
                                                VAR_EXR_RAT_DEST,
                                                VAR_EXR_RAT_BASE_SRC,
                                                VAR_EXR_RAT_BASE_DEST,
                                                VAR_EXR_RAT_SRC_SPREAD,
                                                VAR_EXR_RAT_DEST_SPREAD,
                                                VAR_EXR_COD_CCY_SPREAD_SRC,
                                                VAR_EXR_COD_CCY_SPREAD_DEST,
                                                VAR_EXR_OUT_AMT_LCY,
                                                VAR_EXR_OUT_AMT_DEST,
                                                VAR_EXR_OUT_RAT_SRC_LCY,
                                                VAR_EXR_OUT_RAT_LCY_DEST);
      
        IF VAR_L_RETURN_VALUE <> 0 THEN
          PO_RESPONSE_CODE    := '1001';
          PO_RESPONSE_MESSAGE := 'Error executing AP_CM_AM_EXCHANGE';
          RETURN 1;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          PO_RESPONSE_CODE    := '1001';
          PO_RESPONSE_MESSAGE := 'Error executing AP_CM_AM_EXCHANGE';
          RETURN 1;
      END;
    
      --AP_SM_CHECK_USER_ACCESS
      BEGIN
        VAR_L_RETURN_VALUE := AP_SM_CHECK_USER_ACCESS(PI_COD_USER_ID => PI_USER_ID,
                                                      PI_CIF_ID      => PI_ACCT_ID,
                                                      PI_SEARCH_TYPE => 'ACCT',
                                                      PI_COD_TASK    => 'CIM09');
      
        IF VAR_L_RETURN_VALUE <> 0 THEN
          PO_RESPONSE_CODE    := '1001';
          PO_RESPONSE_MESSAGE := 'Exception occured while executing the Procedure AP_SM_CHECK_USER_ACCESS';
          RETURN 1;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          PO_RESPONSE_CODE    := '1001';
          PO_RESPONSE_MESSAGE := 'Exception occured while executing the Procedure AP_SM_CHECK_USER_ACCESS';
          RETURN 1;
      END;
    
      BEGIN
        VAR_L_RETURN_VALUE := AP_SM_CHECK_USER_ACCESS(PI_COD_USER_ID => PI_USER_ID,
                                                      PI_CIF_ID      => VAR_CUSTOMER_ID,
                                                      PI_SEARCH_TYPE => 'CUST',
                                                      PI_COD_TASK    => 'CIM09');
      
        IF VAR_L_RETURN_VALUE <> 0 THEN
          PO_RESPONSE_CODE    := '1001';
          PO_RESPONSE_MESSAGE := 'Exception occured while executing the Procedure AP_SM_CHECK_USER_ACCESS';
          RETURN 1;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          PO_RESPONSE_CODE    := '1001';
          PO_RESPONSE_MESSAGE := 'Exception occured while executing the Procedure AP_SM_CHECK_USER_ACCESS';
          RETURN 1;
      END;
    
      --Fetching dat_txn
      BEGIN
        --  NGI-194: the value is built purely from SYSDATE - the BA_BANK_MAST row
        --  was never read - so DUAL produces the identical string without touching
        --  the table.  (BA_BANK_MAST is already read, with COD_BANK, further up.)
        SELECT LPAD(DATEPART('MM', SYSDATE), 2, '0') ||
               LPAD(DATEPART('DD', SYSDATE), 2, '0') ||
               LPAD(DATEPART('HH', SYSDATE), 2, '0') ||
               LPAD(DATEPART('MI', SYSDATE), 2, '0') ||
               LPAD(DATEPART('SS', SYSDATE), 2, '0')
          INTO VAR_DAT_TXN
          FROM DUAL;
      EXCEPTION
        WHEN OTHERS THEN
          PO_RESPONSE_CODE    := '1001';
          PO_RESPONSE_MESSAGE := 'Exception occured while fetching dat_txn';
          RETURN 1;
      END;
    
      VAR_GL_ACCOUNT       := TO_NUMBER(PI_XFER_COST_CTR) ||
                              LPAD(VAR_L_PM_TXN_DEFN_ROW.COD_INTER_GL_ACCT,
                                   10,
                                   '0');
      VAR_SPL_GL_ACCOUNT   := TO_NUMBER(VAR_COD_SPL_BRN) ||
                              LPAD(VAR_L_PM_TXN_DEFN_ROW.COD_INTER_GL_ACCT,
                                   10,
                                   '0');
      VAR_SPL_GL_3_ACCOUNT := TO_NUMBER(VAR_COD_SPL_BRN) ||
                              LPAD(241032, 10, '0');
    
      --  local amount = transfer amount x the posted rate; the channel's own FrmLce
      --  value is not used
      VAR_PI_AMT_TXN_LCY_IN := PI_XFER_AMT_TO *
                               VAR_TXN_VALUE.TXN_CCY_CONV_RATE;
    
      VAR_WDR_PO_USN := VAR_ARD_PO_USN_F;
    
      --  BR-4 / NGI-188.  Two amounts on the same leg that are expressed in the same
      --  currency have to be the same figure.  Every IL row obeys that: wherever
      --  COD_ACC_CCY = COD_TXN_CCY, IL writes AMT_TXN_ACY = AMT_TXN_TCY, and wherever
      --  the account is held in the local currency it writes AMT_TXN_ACY = AMT_TXN_LCY.
      --  Only when all three currencies differ is the account amount derived, and then
      --  it is the local amount divided by the account rate.
      --  The rate is IL's fromRate: left at 1 when the account is in local currency,
      --  otherwise FrmLce / Frm as computed above.  IL passes that rate through
      --  untouched even when the channel's own Frm / FrmLce pair is inconsistent, so
      --  it is never used to reconstruct the amount on the two identity branches.
      VAR_ACCT_CCY_CONV_RATE := VAR_FROM_RATE;
    
      IF VAR_ACCOUNT_CCY = VAR_TRANSACTION_CCY THEN
        --  account held in the transfer currency: the leg's own TCY figure is what
        --  leaves the account, no conversion is involved
        VAR_AMT_TXN_ACY := PI_XFER_AMT_TO;
      ELSIF VAR_ACCOUNT_CCY = VAR_LOCAL_CCY THEN
        --  account held in the local currency: the leg's own LCY figure
        VAR_AMT_TXN_ACY := VAR_PI_AMT_TXN_LCY_IN;
      ELSIF NVL(VAR_ACCT_CCY_CONV_RATE, 0) = 0 THEN
        --  three currencies but no usable account rate; fall back to the channel
        VAR_AMT_TXN_ACY := PI_XFER_AMT_FRM;
      ELSE
        --  three different currencies: derive from the local amount at the account
        --  rate, never read it off the channel's from field
        VAR_AMT_TXN_ACY := VAR_PI_AMT_TXN_LCY_IN / VAR_ACCT_CCY_CONV_RATE;
      END IF;
    
      --  BR-17 narrative on the ledger legs, with the empty-memo fallback
      VAR_TXN_DESC_NARRATIVE := NVL(VAR_L_NARRATIVE,
                                    'Outgoing Payment Initiation');
    
      -- =========================================================
      -- PREPARE VARIABLES FOR WDR and GL_TXNS BASED ON XREFF_NUMBER
      IF PI_XREFF_NUMBER IS NOT NULL THEN
        VAR_FINAL_ORG_BRN   := VAR_COD_SPL_BRN;
        VAR_FINAL_GL_ACCT   := VAR_SPL_GL_ACCOUNT;
        VAR_FINAL_GL_3_ACCT := VAR_SPL_GL_3_ACCOUNT;
      ELSE
        VAR_FINAL_ORG_BRN   := TO_NUMBER(PI_XFER_COST_CTR);
        VAR_FINAL_GL_ACCT   := VAR_GL_ACCOUNT;
        VAR_FINAL_GL_3_ACCT := VAR_GL_ACCOUNT; -- replaced by <networkBrn>||241032 in the network block
      END IF;
    
      VAR_FINAL_GLTXN_USN := 5; -- GL1 VarOUsn = 5 in all five observed UAT runs
      VAR_FINAL_ACCT_NO   := NULL; -- net legs pass no customer account (CodNfwAcct blank)
    
      -- WDR (identical for both rate types - channel-supplied values, IL-parity)
      --  withdrawal leg: local amount rounded to 2, account amount as resolved above
      VAR_WDR_AMT_TXN_LCY    := ROUND(VAR_PI_AMT_TXN_LCY_IN, 2);
      VAR_WDR_AMT_TXN_ACY    := ROUND(VAR_AMT_TXN_ACY, 2);
      VAR_WDR_TXN_CONV_RATE  := VAR_TXN_VALUE.TXN_CCY_CONV_RATE;
      VAR_WDR_ACCT_CONV_RATE := VAR_ACCT_CCY_CONV_RATE;
    
      -- GL 1: parking credit in TXN ccy (UAT-1521/BR-26)
      VAR_GL1_AMT_TXN_LCY    := ROUND(VAR_PI_AMT_TXN_LCY_IN, 2);
      VAR_GL1_TXN_CONV_RATE  := VAR_TXN_VALUE.TXN_CCY_CONV_RATE;
      VAR_GL1_ACCT_CONV_RATE := VAR_ACCT_CCY_CONV_RATE;
    
      -- GL 2..5: std-rate network legs ONLY (transferFundsToNetwork + CR-259 re-book)
      --  net legs use the same local amount, unrounded
      VAR_GL_AMT_TXN_LCY    := VAR_PI_AMT_TXN_LCY_IN;
      VAR_GL_TXN_CONV_RATE  := VAR_TXN_VALUE.TXN_CCY_CONV_RATE;
      VAR_GL_ACCT_CONV_RATE := F_IL_RATE(VAR_PO_ACCT_TO_RATE);
    
      --WDR
      BEGIN
        VAR_L_RETURN_VALUE := AP_OL_CALL_CH_WDR(
                                                
                                                VAR_PI_CHANNEL_ID         => VAR_L_IL_CHANNEL,
                                                VAR_PI_SVC_CODE           => PI_SVC_CODE,
                                                VAR_PI_DAT_TXN            => VAR_DAT_TXN,
                                                VAR_PI_COD_ORG_BRN        => VAR_FINAL_ORG_BRN,
                                                VAR_PI_REF_SUBSEQ_NO      => VAR_WDR_REF_SUBSEQ_NO,
                                                VAR_PI_MSG_TYPE           => 200,
                                                VAR_PI_REF_TXN_NO         => VAR_ARD_PO_REF_TXN_NO,
                                                VAR_PI_SVC_RQ_ID          => PI_SVC_RQ_ID,
                                                VAR_PI_COD_USER_ID        => VAR_ARD_PO_USER_ROW.COD_USER_ID,
                                                VAR_PI_COD_USERNO         => VAR_ARD_PO_USER_ROW.COD_USERNO,
                                                VAR_PI_STAN_NO            => VAR_ARD_PO_STAN_NO,
                                                VAR_PI_COD_PROC           => 11000,
                                                VAR_PI_COD_ACCT_NO_F      => PI_ACCT_ID,
                                                VAR_PI_COD_CC_BRN_F       => VAR_ARD_PO_COD_CC_BRN_F,
                                                VAR_PI_ACCT_CUR_F         => VAR_ACCOUNT_CCY,
                                                VAR_PI_XFER_CUR           => PI_XFER_CUR_CODE,
                                                VAR_PI_COD_PROD_F         => VAR_ARD_PO_COD_PROD_F,
                                                VAR_PI_BAL_LST_PSBK_F     => VAR_ARD_PO_BAL_LST_PSBK_F,
                                                VAR_PI_CTR_PSBK_LINE_NO_F => VAR_ARD_PO_CTR_PSBK_LINE_NO_F,
                                                --  the FCR internal currency code, not the raw ISO value
                                                VAR_PI_TXN_CUR                 => VAR_TRANSACTION_CCY,
                                                VAR_PI_COD_ACCT_NO_T           => VAR_COUNTER_PARTY_DETAIL.COUNTER_PARTY_ACCOUNT_ID,
                                                VAR_PI_AMT_TXN_LCY             => VAR_WDR_AMT_TXN_LCY,
                                                VAR_PI_AMT_TXN_TCY             => PI_XFER_AMT_TO,
                                                VAR_PI_AMT_TXN_ACY             => VAR_WDR_AMT_TXN_ACY,
                                                VAR_PI_AMT_TXN_OTHER_ACY       => VAR_WDR_AMT_TXN_ACY,
                                                VAR_PI_TXN_CCY_CONV_RATE       => VAR_WDR_TXN_CONV_RATE,
                                                VAR_PI_ACCT_CCY_CONV_RATE      => VAR_WDR_ACCT_CONV_RATE,
                                                VAR_PI_COD_TXN_MNEMONIC        => 1008,
                                                VAR_PI_COD_TXN                 => 2031,
                                                VAR_PI_NARRATIVE               => VAR_TXN_DESC_NARRATIVE,
                                                VAR_PI_COD_TASK_LITERAL_DERIVE => VAR_TASK_LITERAL_DERIVED,
                                                VAR_PI_COD_ORG_MSG_TYP         => 0,
                                                VAR_PI_REF_ORG_STAN            => 0,
                                                VAR_PI_REF_ORG_SUBSEQ_NO       => 0,
                                                VAR_PI_DAT_ORG_TXN             => 0,
                                                VAR_PI_CTR_YR_ORG_TXN          => 0,
                                                VAR_PI_DAT_ORG_POST            => 0,
                                                VAR_PI_CTR_YR_ORG_POST         => 0,
                                                VAR_PO_COD_EXT                 => VAR_WDR_PO_COD_EXT,
                                                VAR_PO_COD_REPLY               => VAR_WDR_PO_COD_REPLY,
                                                VAR_PO_USN                     => VAR_WDR_PO_USN,
                                                VAR_PO_RESPONSE_CODE           => PO_RESPONSE_CODE,
                                                VAR_PO_RESPONSE_MESSAGE        => PO_RESPONSE_MESSAGE);
      
        IF VAR_L_RETURN_VALUE <> 0 THEN
          RETURN VAR_L_RETURN_VALUE;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          PO_RESPONSE_CODE    := 1210;
          PO_RESPONSE_MESSAGE := 'Database Error : executing the Function AP_OL_CALL_CH_WDR';
          RETURN 1;
      END;
    
      --WDR END
    
      --GL TXNS goes here 1
      VAR_WDR_REF_SUBSEQ_NO := VAR_WDR_REF_SUBSEQ_NO + 1;
      VAR_GLTXN_PO_USN      := VAR_FINAL_GLTXN_USN;
    
      BEGIN
        VAR_L_RETURN_VALUE := AP_OL_CALL_GL_TXNS(VAR_PI_DAT_TXN            => TO_NUMBER(VAR_DAT_TXN),
                                                 VAR_PI_COD_ORG_BRN        => VAR_FINAL_ORG_BRN,
                                                 VAR_PI_COD_CC_BRN         => VAR_FINAL_ORG_BRN,
                                                 VAR_PI_REF_SUBSEQ_NO      => VAR_WDR_REF_SUBSEQ_NO,
                                                 VAR_PI_REF_TXN_NO         => VAR_ARD_PO_REF_TXN_NO,
                                                 VAR_PI_SVC_RQ_ID          => PI_SVC_RQ_ID,
                                                 VAR_PI_COD_USER_ID        => VAR_ARD_PO_USER_ROW.COD_USER_ID,
                                                 VAR_PI_COD_USERNO         => VAR_ARD_PO_USER_ROW.COD_USERNO,
                                                 VAR_PI_STAN_NO            => VAR_ARD_PO_STAN_NO,
                                                 VAR_PI_COD_ACCT_NO        => PI_ACCT_ID,
                                                 VAR_PI_COD_ACCT_NO_DUM_GL => VAR_FINAL_GL_ACCT,
                                                 --  FCR currency code; the GL account is held in the transfer currency
                                                 VAR_PI_TXN_CUR                 => VAR_TRANSACTION_CCY,
                                                 VAR_PI_ACCT_CUR                => VAR_TRANSACTION_CCY,
                                                 VAR_PI_COD_PROD                => VAR_ARD_PO_COD_PROD_F,
                                                 VAR_PI_COD_PROC                => 216000,
                                                 VAR_PI_AMT_TXN_LCY             => VAR_GL1_AMT_TXN_LCY,
                                                 VAR_PI_AMT_TXN_TCY             => PI_XFER_AMT_TO,
                                                 VAR_PI_AMT_TXN_ACY             => PI_XFER_AMT_TO,
                                                 VAR_PI_TXN_CCY_CONV_RATE       => VAR_GL1_TXN_CONV_RATE,
                                                 VAR_PI_ACCT_CCY_CONV_RATE      => VAR_GL1_ACCT_CONV_RATE,
                                                 VAR_PI_FLG_OVERRIDE_DUM        => 0,
                                                 VAR_PI_COD_TXN_MNEMONIC        => 1008,
                                                 VAR_PI_TXNDESC1                => RPAD(PI_ACCT_ID,
                                                                                        16,
                                                                                        ' ') || ':',
                                                 VAR_PI_TXNDESC2                => VAR_TXN_DESC_NARRATIVE,
                                                 VAR_PI_COD_TASK_LITERAL_DERIVE => VAR_TASK_LITERAL_DERIVED,
                                                 VAR_PI_FLG_DRCR                => 'C',
                                                 VAR_PI_COD_ORG_MSG_TYP         => 0,
                                                 VAR_PI_REF_ORG_STAN            => 0,
                                                 VAR_PI_REF_ORG_SUBSEQ_NO       => 0,
                                                 VAR_PI_DAT_ORG_TXN             => 0,
                                                 VAR_PI_CTR_YR_ORG_TXN          => 0,
                                                 VAR_PI_DAT_ORG_POST            => 0,
                                                 VAR_PI_CTR_YR_ORG_POST         => 0,
                                                 VAR_PO_COD_EXT                 => VAR_WDR_PO_COD_EXT,
                                                 VAR_PO_COD_REPLY               => VAR_WDR_PO_COD_REPLY,
                                                 VAR_PO_USN                     => VAR_GLTXN_PO_USN,
                                                 VAR_PI_XFEE_AMT                => PI_XFEE_AMT,
                                                 VAR_PO_RESPONSE_CODE           => PO_RESPONSE_CODE,
                                                 VAR_PO_RESPONSE_MESSAGE        => PO_RESPONSE_MESSAGE);
      
        IF VAR_L_RETURN_VALUE <> 0 THEN
          RETURN VAR_L_RETURN_VALUE;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          PO_RESPONSE_CODE    := 1210;
          PO_RESPONSE_MESSAGE := 'Database Error : executing the Function AP_OL_CALL_GL_TXNS';
          RETURN 1;
      END;
    
      IF PI_XFEE_AMT > 0 THEN
        --SC_WDR start
        VAR_WDR_REF_SUBSEQ_NO := VAR_WDR_REF_SUBSEQ_NO + 1;
      
        --  BR-15: the fee leg posts in local currency for every rate type
        VAR_SC_AMT_TXN_LCY    := PI_XFEE_AMT_LCE;
        SC_TXN_CCY_CONV_RATE  := 1;
        SC_ACCT_CCY_CONV_RATE := F_IL_RATE(PI_XFEE_AMT_LCE / PI_XFEE_AMT);
      
        BEGIN
          VAR_L_RETURN_VALUE := AP_OL_CALL_PROCESS_SC(VAR_PI_CHANNEL_ID         => VAR_L_IL_CHANNEL,
                                                      VAR_PI_SVC_CODE           => PI_SVC_CODE,
                                                      VAR_PI_DAT_TXN            => TO_NUMBER(VAR_DAT_TXN),
                                                      VAR_PI_COD_ORG_BRN        => VAR_FINAL_ORG_BRN,
                                                      VAR_PI_REF_SUBSEQ_NO      => VAR_WDR_REF_SUBSEQ_NO,
                                                      VAR_PI_SVC_RQ_ID          => PI_SVC_RQ_ID,
                                                      VAR_PI_TXN_CCY            => VAR_LOCAL_CCY,
                                                      VAR_PI_AMT_TXN_LCY        => VAR_SC_AMT_TXN_LCY,
                                                      VAR_PI_AMT_TXN_TCY        => PI_XFEE_AMT_LCE,
                                                      VAR_PI_AMT_TXN_ACY        => PI_XFEE_AMT,
                                                      VAR_PI_TXN_CCY_CONV_RATE  => SC_TXN_CCY_CONV_RATE,
                                                      VAR_PI_ACCT_CCY_CONV_RATE => SC_ACCT_CCY_CONV_RATE,
                                                      VAR_PI_COD_SC             => TO_NUMBER(TRIM(VAR_SC_CODE)),
                                                      VAR_PI_COD_TXN_MNEMONIC   => 1008,
                                                      VAR_PI_COD_TXN            => 2031,
                                                      VAR_PI_COD_USER_ID        => VAR_ARD_PO_USER_ROW.COD_USER_ID,
                                                      VAR_PI_COD_USERNO         => VAR_ARD_PO_USER_ROW.COD_USERNO,
                                                      VAR_PI_STAN_NO            => VAR_ARD_PO_STAN_NO,
                                                      VAR_PI_REF_TXN_NO         => VAR_ARD_PO_REF_TXN_NO,
                                                      VAR_PI_ACCT_ID_F          => PI_ACCT_ID,
                                                      VAR_PI_COD_CC_BRN_F       => VAR_ARD_PO_COD_CC_BRN_F,
                                                      VAR_PI_ACCT_CUR_F         => VAR_ACCOUNT_CCY,
                                                      VAR_PI_COD_PROD_F         => VAR_ARD_PO_COD_PROD_F,
                                                      VAR_PO_COD_EXT            => VAR_SC_PO_COD_EXT,
                                                      VAR_PO_COD_REPLY          => VAR_WDR_PO_COD_REPLY,
                                                      VAR_PO_USN_F              => VAR_ARD_PO_USN_F,
                                                      VAR_PI_XREF_NUMBER        => PI_XREFF_NUMBER,
                                                      --  the fee leg carries this literal description in IL
                                                      VAR_PO_RESPONSE_CODE    => PO_RESPONSE_CODE,
                                                      VAR_PO_RESPONSE_MESSAGE => PO_RESPONSE_MESSAGE);
        
          IF VAR_L_RETURN_VALUE <> 0 THEN
            RETURN VAR_L_RETURN_VALUE;
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            PO_RESPONSE_CODE    := SQLCODE;
            PO_RESPONSE_MESSAGE := 'Exception occured while executing the Function AP_OL_CALL_PROCESS_SC';
            RETURN 1;
        END;
        --SC_WDR END
      END IF;
    
      --generate network reference number: start
      --  <branch> + YY + calendar julian day + 7-digit sequence
      BEGIN
        VAR_L_REF_NETWORK_NO := TO_NUMBER(VAR_FINAL_ORG_BRN) ||
                                TO_CHAR(SYSDATE, 'YY') ||
                                TO_CHAR(SYSDATE, 'DDD');
      
        VAR_L_SEQ := UPPER(TRIM('API_' || TO_NUMBER(VAR_FINAL_ORG_BRN) ||
                                '__NTWRK_REF'));
      
        VAR_L_NET_QUERY := 'SELECT ' || TRIM(VAR_L_SEQ) ||
                           '.NEXTVAL FROM DUAL';
      
        BEGIN
          EXECUTE IMMEDIATE VAR_L_NET_QUERY
            INTO VAR_PO_SEQ_CURR;
        EXCEPTION
          WHEN OTHERS THEN
            BEGIN
              EXECUTE IMMEDIATE 'CREATE SEQUENCE ' || TRIM(VAR_L_SEQ) ||
                                ' START WITH 1 INCREMENT BY 1 NOCACHE';
            
              EXECUTE IMMEDIATE VAR_L_NET_QUERY
                INTO VAR_PO_SEQ_CURR;
            EXCEPTION
              WHEN OTHERS THEN
                PO_RESPONSE_CODE    := 1;
                PO_RESPONSE_MESSAGE := 'Error in populating sequence ' ||
                                       VAR_L_SEQ;
                RETURN 1;
            END;
        END;
      
        VAR_PO_SEQ_CURR := LPAD(VAR_PO_SEQ_CURR, 7, '0');
      
        VAR_L_REF_NETWORK_NO := VAR_L_REF_NETWORK_NO || VAR_PO_SEQ_CURR;
      EXCEPTION
        WHEN OTHERS THEN
          PO_RESPONSE_CODE    := 1;
          PO_RESPONSE_MESSAGE := 'Error in generating network no ';
          RETURN 1;
      END;
    
      -- generate network reference number: end
    
      -- SAVEING PAYMENT LOG:START
      BEGIN
        --  BR-14: 'OTHER' only when a correspondent bank was sent
        IF TRIM(PI_BANK_CORESPONDENT1) IS NOT NULL OR
           TRIM(PI_BANK_CORESPONDENT2) IS NOT NULL THEN
          VAR_PAYMENT_TXN_LOG.CORRESP_AGENT_CODE := 'OTHER';
        END IF;
        VAR_REL_TXN_STORE.INITIATOR_RES_STATUS_CODE := '001';
        --  initiation branch = the transaction branch (9429 on dealer-reference txns)
        VAR_REL_TXN_STORE.INITIATION_BRANCH            := VAR_FINAL_ORG_BRN;
        VAR_REL_TXN_STORE.ORIGINALNETWORK_REFERENCE_NO := VAR_L_REF_NETWORK_NO;
        VAR_PAYMENT_TXN_LOG.NETWORK_REFERENCE_NO       := VAR_L_REF_NETWORK_NO;
        VAR_REL_TXN_STORE.ORIGINATING_BANK             := '11';
        VAR_REL_TXN_STORE.ORIGINATING_BRANCH           := VAR_FINAL_ORG_BRN;
      
        VAR_PAYMENT_TXN_LOG.FINANCIAL_INSTITUITION_ID  := '11' ||
                                                          PI_XFER_COST_CTR;
        VAR_PAYMENT_TXN_LOG.FINANCIAL_INST_BANK_CODE   := '11';
        VAR_PAYMENT_TXN_LOG.FINANCIAL_INST_BRANCH_CODE := PI_XFER_COST_CTR;
      
        --  remitter identification belongs to the special-rate path only
        IF VAR_REL_TXN_STORE.TRANSACTION_MNEMONIC IS NOT NULL AND
           VAR_REL_TXN_STORE.TRANSACTION_MNEMONIC = '2030' THEN
          VAR_REL_TXN_STORE.REMITTER_NAME    := VAR_REL_TXN_STORE.BENEFICIARY_NAME;
          VAR_REL_TXN_STORE.REMITTER_NATL_ID := VAR_L_COD_NATIONAL_ID;
          --  a zero on the customer master is not a phone number
          VAR_REL_TXN_STORE.REMITTER_PHONE := NULLIF(VAR_L_CUSTOMER_PHONE_NO,
                                                     0);
          --  the category is only carried when the remitter is not identified
          VAR_REL_TXN_STORE.REMITTER_CATEGORY := NULL;
        END IF;
      
        VAR_REL_TXN_STORE.CUSTOMER_BRANCH_NAME := VAR_L_HOME_BRN_COD;
        VAR_REL_TXN_STORE.BI_CODE              := PI_BENF_ID;
      
        IF PI_BENF_BNAME IS NOT NULL AND LENGTH(PI_BENF_BNAME) > 35 THEN
          VAR_REL_TXN_STORE.CUSTOMER_BANK_NAME := SUBSTR(PI_BENF_BNAME,
                                                         1,
                                                         35);
        ELSE
          VAR_REL_TXN_STORE.CUSTOMER_BANK_NAME := PI_BENF_BNAME;
        END IF;
      
        --populateBeneficiaryBankAddress: start
        IF PI_BENF_BADDRESS IS NOT NULL THEN
          IF LENGTH(PI_BENF_BADDRESS) <= 35 THEN
            VAR_REL_TXN_STORE.CUSTOMER_BANK_ADDRESS1 := PI_BENF_BADDRESS;
            VAR_REL_TXN_STORE.CUSTOMER_BANK_ADDRESS2 := PI_BENF_BCOUNTRY;
          ELSIF LENGTH(PI_BENF_BADDRESS) <= 70 THEN
            VAR_REL_TXN_STORE.CUSTOMER_BANK_ADDRESS1 := SUBSTR(PI_BENF_BADDRESS,
                                                               1,
                                                               35);
            VAR_REL_TXN_STORE.CUSTOMER_BANK_ADDRESS2 := SUBSTR(PI_BENF_BADDRESS,
                                                               36);
            VAR_REL_TXN_STORE.CUSTOMER_BANK_ADDRESS3 := PI_BENF_BCOUNTRY;
          ELSE
            VAR_REL_TXN_STORE.CUSTOMER_BANK_ADDRESS1 := SUBSTR(PI_BENF_BADDRESS,
                                                               1,
                                                               35);
            VAR_REL_TXN_STORE.CUSTOMER_BANK_ADDRESS2 := SUBSTR(PI_BENF_BADDRESS,
                                                               36,
                                                               35);
            VAR_REL_TXN_STORE.CUSTOMER_BANK_ADDRESS3 := SUBSTR(PI_BENF_BADDRESS,
                                                               71);
          
            IF LENGTH(VAR_REL_TXN_STORE.CUSTOMER_BANK_ADDRESS3) <= 14 THEN
              VAR_REL_TXN_STORE.CUSTOMER_BANK_ADDRESS3 := VAR_REL_TXN_STORE.CUSTOMER_BANK_ADDRESS3 || ',' ||
                                                          PI_BENF_BCOUNTRY;
            ELSE
              VAR_REL_TXN_STORE.CUSTOMER_BANK_ADDRESS3 := SUBSTR(VAR_REL_TXN_STORE.CUSTOMER_BANK_ADDRESS3,
                                                                 1,
                                                                 14) || ',' ||
                                                          PI_BENF_BCOUNTRY;
            END IF;
          END IF;
        ELSE
          VAR_REL_TXN_STORE.CUSTOMER_BANK_ADDRESS1 := PI_BENF_BCOUNTRY;
        END IF;
      
        VAR_REL_TXN_STORE.CUSTOMER_BANK_ADDRESS4 := PI_BENF_PHONE;
      
        --populateBeneficiaryBankAddress: end
      
        -- getMacroSimodisDCC: start
        BEGIN
          SELECT MACRO_VALUE
            INTO VAR_MACRO_SIMODIS_DCC
            FROM ba_site
           WHERE MACRO_NAME = 'ENABLE_SIMODIS_DCC'
             AND FLG_MNT_STATUS = 'A';
        EXCEPTION
          WHEN OTHERS THEN
            PO_RESPONSE_CODE    := '1001';
            PO_RESPONSE_MESSAGE := 'Failed to select from pm_txn_defn';
            RETURN 1;
        END;
      
        -- getMacroSimodisDCC: end
      
        --  SIMODIS memo split: remit no [1-35], name [36-70], national id [71-105], phone [106-]
        DECLARE
          var_l_memo_length NUMBER;
        BEGIN
          IF VAR_MACRO_SIMODIS_DCC = 'Y' AND PI_MEMO1 IS NOT NULL THEN
            var_l_memo_length := LENGTH(PI_MEMO1);
          
            VAR_REL_TXN_STORE.ORIGINAL_REMIT_NO := SUBSTR(PI_MEMO1, 1, 35);
          
            IF var_l_memo_length > 35 THEN
              VAR_REL_TXN_STORE.REMITTER_NAME := SUBSTR(PI_MEMO1, 36, 35);
            END IF;
          
            IF var_l_memo_length > 70 THEN
              VAR_REL_TXN_STORE.REMITTER_NATL_ID := SUBSTR(PI_MEMO1, 71, 35);
            END IF;
          
            IF var_l_memo_length > 105 THEN
              VAR_REL_TXN_STORE.REMITTER_PHONE := SUBSTR(PI_MEMO1, 106, 35);
            END IF;
          END IF;
        END;
      
        IF (PI_BENF_ID IS NULL OR PI_BENF_ID = '') THEN
          VAR_REL_TXN_STORE.RECEIVER_BIC_CODE := 'OTHER';
        ELSE
          VAR_REL_TXN_STORE.RECEIVER_BIC_CODE := PI_BENF_ID;
        END IF;
      
        VAR_REL_TXN_STORE.CORRESPONDENT_AGENT_ADDRESS1 := PI_BANK_CORESPONDENT1;
        VAR_REL_TXN_STORE.CORRESPONDENT_AGENT_ADDRESS2 := PI_BANK_CORESPONDENT2;
      
        VAR_REL_TXN_STORE.TRANSMISSION_DATE_TIME := 0;
        VAR_REL_TXN_STORE.REASON_CODE            := '';
      
        VAR_L_RETURN_VALUE := AP_SAVE_PAYMENT_LOG(VAR_PI_REL_TXN_STORE => VAR_REL_TXN_STORE, VAR_PI_PAYMENT_TXN_LOG => VAR_PAYMENT_TXN_LOG, VAR_L_NTWK_ACCT_STAT => VAR_L_NTWK_ACCT_STAT, VAR_PI_COUNTER_PARTY_DETAIL => VAR_COUNTER_PARTY_DETAIL, VAR_PI_COD_MSG_TYP => 200,
                              --  CHANNEL_ID stays the context channel
                              VAR_PI_CHANNEL_ID => VAR_L_IL_CHANNEL, VAR_PI_SUB_SEQ_NO => 0,
                              --  withdrawal + parking, the fee leg when one is charged, and on the standard
                              --  path the four network legs
                              VAR_PI_TOT_SUBSEQ_NO => 2 + (CASE WHEN NVL(PI_XFEE_AMT, 0) > 0 THEN 1 ELSE 0 END) + (CASE WHEN VAR_L_IS_SPECIAL = 0 THEN 4 ELSE 0 END), VAR_PI_DAT_TXN => VAR_DAT_TXN, VAR_PI_COD_USER_ID => VAR_ARD_PO_USER_ROW.COD_USER_ID, VAR_PI_STAN_NO => VAR_ARD_PO_STAN_NO, VAR_PI_TXN_CCY => VAR_TRANSACTION_CCY, VAR_PI_AMT_TXN_TCY => PI_XFER_AMT_TO, VAR_PI_RAT_CONV_TCLCY => VAR_TXN_VALUE.TXN_CCY_CONV_RATE,
        --  pm_txn_log carries the withdrawal leg's amounts and rates
         VAR_PI_AMT_TXN_LCY => ROUND(VAR_PI_AMT_TXN_LCY_IN, 2), VAR_PI_AMT_TXN_ACY => ROUND(VAR_AMT_TXN_ACY, 2), VAR_PI_RAT_CONV_ACLCY => VAR_ACCT_CCY_CONV_RATE, VAR_PI_COD_NETWORK_ID => VAR_PAYMENT_TXN_LOG.NETWORK_ID,
        --  NAM_CUST_BRN is the customer's home branch, not the account's branch
         VAR_PI_NAM_CUST_BRN => VAR_L_HOME_BRN_COD, VAR_PI_REF_TXN_NO => VAR_ARD_PO_REF_TXN_NO, VAR_PI_REF_USR_NO => PI_SVC_RQ_ID, PO_RESPONSE_CODE => PO_RESPONSE_CODE, PO_RESPONSE_MESSAGE => PO_RESPONSE_MESSAGE);
      
        IF VAR_L_RETURN_VALUE <> 0 THEN
          RETURN VAR_L_RETURN_VALUE;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          PO_RESPONSE_CODE    := 1210;
          PO_RESPONSE_MESSAGE := 'Database Error : executing the Function AP_SAVE_PAYMENT_LOG';
          RETURN 1;
      END;
    
      -- SAVEING PAYMENT LOG:END
    
      --  BR-19: the network GL pairs and the FCUBS push are standard-only; a special
      --  rate stops after debit, parking, fee and log and waits on branch screen 2032
      IF VAR_L_IS_SPECIAL = 0 THEN
        --GL TXNS goes here 2
        VAR_WDR_REF_SUBSEQ_NO := VAR_WDR_REF_SUBSEQ_NO + 1;
        VAR_GLTXN_PO_USN      := 0;
        --  the network legs carry a fixed description:
        --  16 spaces + ':Cash@Work Outgoing Payment Initiation'
        VAR_TXT_NARRATIVE := '                :Cash@Work Outgoing Payment Initiation';
      
        --  network branch and network-side GL accounts. Payable ledger 241032 is still to
        --  be confirmed against IL fetchNetworkLedgerId.
        BEGIN
          --  NGI-194: identical lookup runs twice in this function; fetch once
          IF G_TXN_NETWORK_LOADED = 0 THEN
            SELECT COD_CC_BRN
              INTO G_TXN_NETWORK_BRANCH
              FROM VWE_PM_NETWORK_MAST
             WHERE COD_NETWORK_ID = 'SWIFTO'
               AND FLG_MNT_STATUS = 'A';
          
            G_TXN_NETWORK_LOADED := 1;
          END IF;
        
          VAR_NETWORK_BRANCH := G_TXN_NETWORK_BRANCH;
        EXCEPTION
          WHEN OTHERS THEN
            PO_RESPONSE_CODE    := '100';
            PO_RESPONSE_MESSAGE := 'Failed to select from VWE_PM_NETWORK_MAST';
            RETURN 1;
        END;
      
        VAR_NET_PARKING_GL  := TO_NUMBER(VAR_NETWORK_BRANCH) ||
                               LPAD(VAR_L_PM_TXN_DEFN_ROW.COD_INTER_GL_ACCT,
                                    10,
                                    '0');
        VAR_FINAL_GL_3_ACCT := TO_NUMBER(VAR_NETWORK_BRANCH) ||
                               LPAD(241032, 10, '0');
      
        BEGIN
          VAR_L_RETURN_VALUE := AP_OL_CALL_GL_TXNS(VAR_PI_DAT_TXN => TO_NUMBER(VAR_DAT_TXN),
                                                   --  pair-1 debit: parking GL at the initiation branch, which stays OrgBrn on all
                                                   --  four network legs
                                                   VAR_PI_COD_ORG_BRN   => VAR_FINAL_ORG_BRN,
                                                   VAR_PI_COD_CC_BRN    => VAR_FINAL_ORG_BRN,
                                                   VAR_PI_REF_SUBSEQ_NO => VAR_WDR_REF_SUBSEQ_NO,
                                                   VAR_PI_REF_TXN_NO    => VAR_ARD_PO_REF_TXN_NO,
                                                   --  the network legs carry the FCR reference, not the SvcRqId
                                                   VAR_PI_SVC_RQ_ID   => VAR_ARD_PO_REF_TXN_NO,
                                                   VAR_PI_COD_USER_ID => VAR_ARD_PO_USER_ROW.COD_USER_ID,
                                                   VAR_PI_COD_USERNO  => VAR_ARD_PO_USER_ROW.COD_USERNO,
                                                   VAR_PI_STAN_NO     => VAR_ARD_PO_STAN_NO,
                                                   VAR_PI_COD_ACCT_NO => VAR_FINAL_ACCT_NO,
                                                   --  initiation-branch parking GL
                                                   VAR_PI_COD_ACCT_NO_DUM_GL      => VAR_FINAL_GL_ACCT,
                                                   VAR_PI_TXN_CUR                 => VAR_TRANSACTION_CCY,
                                                   VAR_PI_ACCT_CUR                => VAR_TRANSACTION_CCY,
                                                   VAR_PI_COD_PROD                => 0,
                                                   VAR_PI_COD_PROC                => 16000,
                                                   VAR_PI_AMT_TXN_LCY             => VAR_GL_AMT_TXN_LCY,
                                                   VAR_PI_AMT_TXN_TCY             => PI_XFER_AMT_TO,
                                                   VAR_PI_AMT_TXN_ACY             => PI_XFER_AMT_TO,
                                                   VAR_PI_TXN_CCY_CONV_RATE       => VAR_GL_TXN_CONV_RATE,
                                                   VAR_PI_ACCT_CCY_CONV_RATE      => VAR_GL_ACCT_CONV_RATE,
                                                   VAR_PI_FLG_OVERRIDE_DUM        => 0,
                                                   VAR_PI_COD_TXN_MNEMONIC        => 1005,
                                                   VAR_PI_TXNDESC1                => '',
                                                   VAR_PI_TXNDESC2                => VAR_TXT_NARRATIVE,
                                                   VAR_PI_COD_TASK_LITERAL_DERIVE => VAR_TASK_LITERAL_DERIVED,
                                                   VAR_PI_FLG_DRCR                => 'D',
                                                   VAR_PI_COD_ORG_MSG_TYP         => 0,
                                                   VAR_PI_REF_ORG_STAN            => 0,
                                                   VAR_PI_REF_ORG_SUBSEQ_NO       => 0,
                                                   VAR_PI_DAT_ORG_TXN             => 0,
                                                   VAR_PI_CTR_YR_ORG_TXN          => 0,
                                                   VAR_PI_DAT_ORG_POST            => 0,
                                                   VAR_PI_CTR_YR_ORG_POST         => 0,
                                                   VAR_PO_COD_EXT                 => VAR_WDR_PO_COD_EXT,
                                                   VAR_PO_COD_REPLY               => VAR_WDR_PO_COD_REPLY,
                                                   VAR_PO_USN                     => VAR_GLTXN_PO_USN,
                                                   VAR_PI_XFEE_AMT                => PI_XFEE_AMT,
                                                   VAR_PO_RESPONSE_CODE           => PO_RESPONSE_CODE,
                                                   VAR_PO_RESPONSE_MESSAGE        => PO_RESPONSE_MESSAGE);
        
          IF VAR_L_RETURN_VALUE <> 0 THEN
            RETURN VAR_L_RETURN_VALUE;
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            PO_RESPONSE_CODE    := 1210;
            PO_RESPONSE_MESSAGE := 'Database Error : executing the Function AP_OL_CALL_GL_TXNS';
            RETURN 1;
        END;
      
        --GL TXNS goes here 3
        VAR_WDR_REF_SUBSEQ_NO := VAR_WDR_REF_SUBSEQ_NO + 1;
      
        BEGIN
          VAR_L_RETURN_VALUE := AP_OL_CALL_GL_TXNS(VAR_PI_DAT_TXN => TO_NUMBER(VAR_DAT_TXN),
                                                   --  CcBrn switches to the network branch; OrgBrn stays the initiation branch
                                                   VAR_PI_COD_ORG_BRN   => VAR_FINAL_ORG_BRN,
                                                   VAR_PI_COD_CC_BRN    => VAR_NETWORK_BRANCH,
                                                   VAR_PI_REF_SUBSEQ_NO => VAR_WDR_REF_SUBSEQ_NO,
                                                   VAR_PI_REF_TXN_NO    => VAR_ARD_PO_REF_TXN_NO,
                                                   --  FCR reference on the network legs
                                                   VAR_PI_SVC_RQ_ID               => VAR_ARD_PO_REF_TXN_NO,
                                                   VAR_PI_COD_USER_ID             => VAR_ARD_PO_USER_ROW.COD_USER_ID,
                                                   VAR_PI_COD_USERNO              => VAR_ARD_PO_USER_ROW.COD_USERNO,
                                                   VAR_PI_STAN_NO                 => VAR_ARD_PO_STAN_NO,
                                                   VAR_PI_COD_ACCT_NO             => VAR_FINAL_ACCT_NO,
                                                   VAR_PI_COD_ACCT_NO_DUM_GL      => VAR_FINAL_GL_3_ACCT,
                                                   VAR_PI_TXN_CUR                 => VAR_TRANSACTION_CCY,
                                                   VAR_PI_ACCT_CUR                => VAR_TRANSACTION_CCY,
                                                   VAR_PI_COD_PROD                => 0,
                                                   VAR_PI_COD_PROC                => 216000,
                                                   VAR_PI_AMT_TXN_LCY             => VAR_GL_AMT_TXN_LCY,
                                                   VAR_PI_AMT_TXN_TCY             => PI_XFER_AMT_TO,
                                                   VAR_PI_AMT_TXN_ACY             => PI_XFER_AMT_TO,
                                                   VAR_PI_TXN_CCY_CONV_RATE       => VAR_GL_TXN_CONV_RATE,
                                                   VAR_PI_ACCT_CCY_CONV_RATE      => VAR_GL_ACCT_CONV_RATE,
                                                   VAR_PI_FLG_OVERRIDE_DUM        => 0,
                                                   VAR_PI_COD_TXN_MNEMONIC        => 1005,
                                                   VAR_PI_TXNDESC1                => '',
                                                   VAR_PI_TXNDESC2                => VAR_TXT_NARRATIVE,
                                                   VAR_PI_COD_TASK_LITERAL_DERIVE => VAR_TASK_LITERAL_DERIVED,
                                                   VAR_PI_FLG_DRCR                => 'C',
                                                   VAR_PI_COD_ORG_MSG_TYP         => 0,
                                                   VAR_PI_REF_ORG_STAN            => 0,
                                                   VAR_PI_REF_ORG_SUBSEQ_NO       => 0,
                                                   VAR_PI_DAT_ORG_TXN             => 0,
                                                   VAR_PI_CTR_YR_ORG_TXN          => 0,
                                                   VAR_PI_DAT_ORG_POST            => 0,
                                                   VAR_PI_CTR_YR_ORG_POST         => 0,
                                                   VAR_PO_COD_EXT                 => VAR_WDR_PO_COD_EXT,
                                                   VAR_PO_COD_REPLY               => VAR_WDR_PO_COD_REPLY,
                                                   VAR_PO_USN                     => VAR_GLTXN_PO_USN,
                                                   VAR_PI_XFEE_AMT                => PI_XFEE_AMT,
                                                   VAR_PO_RESPONSE_CODE           => PO_RESPONSE_CODE,
                                                   VAR_PO_RESPONSE_MESSAGE        => PO_RESPONSE_MESSAGE);
        
          IF VAR_L_RETURN_VALUE <> 0 THEN
            RETURN VAR_L_RETURN_VALUE;
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            PO_RESPONSE_CODE    := 1210;
            PO_RESPONSE_MESSAGE := 'Database Error : executing the Function AP_OL_CALL_GL_TXNS';
            RETURN 1;
        END;
      
        --GL TXNS goes here 4
        VAR_WDR_REF_SUBSEQ_NO := VAR_WDR_REF_SUBSEQ_NO + 1;
      
        BEGIN
          VAR_L_RETURN_VALUE := AP_OL_CALL_GL_TXNS(VAR_PI_DAT_TXN       => TO_NUMBER(VAR_DAT_TXN),
                                                   VAR_PI_COD_ORG_BRN   => VAR_FINAL_ORG_BRN,
                                                   VAR_PI_COD_CC_BRN    => VAR_FINAL_ORG_BRN,
                                                   VAR_PI_REF_SUBSEQ_NO => VAR_WDR_REF_SUBSEQ_NO,
                                                   VAR_PI_REF_TXN_NO    => VAR_ARD_PO_REF_TXN_NO,
                                                   --  FCR reference on the network legs
                                                   VAR_PI_SVC_RQ_ID          => VAR_ARD_PO_REF_TXN_NO,
                                                   VAR_PI_COD_USER_ID        => VAR_ARD_PO_USER_ROW.COD_USER_ID,
                                                   VAR_PI_COD_USERNO         => VAR_ARD_PO_USER_ROW.COD_USERNO,
                                                   VAR_PI_STAN_NO            => VAR_ARD_PO_STAN_NO,
                                                   VAR_PI_COD_ACCT_NO        => VAR_FINAL_ACCT_NO,
                                                   VAR_PI_COD_ACCT_NO_DUM_GL => VAR_FINAL_GL_ACCT,
                                                   --  pair-2 debit: parking GL at the initiation branch
                                                   VAR_PI_TXN_CUR                 => VAR_TRANSACTION_CCY,
                                                   VAR_PI_ACCT_CUR                => VAR_TRANSACTION_CCY,
                                                   VAR_PI_COD_PROD                => 0,
                                                   VAR_PI_COD_PROC                => 16000,
                                                   VAR_PI_AMT_TXN_LCY             => VAR_GL_AMT_TXN_LCY,
                                                   VAR_PI_AMT_TXN_TCY             => PI_XFER_AMT_TO,
                                                   VAR_PI_AMT_TXN_ACY             => PI_XFER_AMT_TO,
                                                   VAR_PI_TXN_CCY_CONV_RATE       => VAR_GL_TXN_CONV_RATE,
                                                   VAR_PI_ACCT_CCY_CONV_RATE      => VAR_GL_ACCT_CONV_RATE,
                                                   VAR_PI_FLG_OVERRIDE_DUM        => 0,
                                                   VAR_PI_COD_TXN_MNEMONIC        => 1005,
                                                   VAR_PI_TXNDESC1                => '',
                                                   VAR_PI_TXNDESC2                => VAR_TXT_NARRATIVE,
                                                   VAR_PI_COD_TASK_LITERAL_DERIVE => VAR_TASK_LITERAL_DERIVED,
                                                   VAR_PI_FLG_DRCR                => 'D',
                                                   VAR_PI_COD_ORG_MSG_TYP         => 0,
                                                   VAR_PI_REF_ORG_STAN            => 0,
                                                   VAR_PI_REF_ORG_SUBSEQ_NO       => 0,
                                                   VAR_PI_DAT_ORG_TXN             => 0,
                                                   VAR_PI_CTR_YR_ORG_TXN          => 0,
                                                   VAR_PI_DAT_ORG_POST            => 0,
                                                   VAR_PI_CTR_YR_ORG_POST         => 0,
                                                   VAR_PO_COD_EXT                 => VAR_WDR_PO_COD_EXT,
                                                   VAR_PO_COD_REPLY               => VAR_WDR_PO_COD_REPLY,
                                                   VAR_PO_USN                     => VAR_GLTXN_PO_USN,
                                                   VAR_PI_XFEE_AMT                => PI_XFEE_AMT,
                                                   VAR_PO_RESPONSE_CODE           => PO_RESPONSE_CODE,
                                                   VAR_PO_RESPONSE_MESSAGE        => PO_RESPONSE_MESSAGE);
        
          IF VAR_L_RETURN_VALUE <> 0 THEN
            RETURN VAR_L_RETURN_VALUE;
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            PO_RESPONSE_CODE    := 1210;
            PO_RESPONSE_MESSAGE := 'Database Error : executing the Function AP_OL_CALL_GL_TXNS';
            RETURN 1;
        END;
      
        --GL TXNS goes here 5
        VAR_WDR_REF_SUBSEQ_NO := VAR_WDR_REF_SUBSEQ_NO + 1;
      
        BEGIN
          VAR_L_RETURN_VALUE := AP_OL_CALL_GL_TXNS(VAR_PI_DAT_TXN => TO_NUMBER(VAR_DAT_TXN),
                                                   --  pair-2 (CR-259) re-books parking to parking at the same branch
                                                   VAR_PI_COD_ORG_BRN   => VAR_FINAL_ORG_BRN,
                                                   VAR_PI_COD_CC_BRN    => VAR_FINAL_ORG_BRN,
                                                   VAR_PI_REF_SUBSEQ_NO => VAR_WDR_REF_SUBSEQ_NO,
                                                   VAR_PI_REF_TXN_NO    => VAR_ARD_PO_REF_TXN_NO,
                                                   --  FCR reference on the network legs
                                                   VAR_PI_SVC_RQ_ID   => VAR_ARD_PO_REF_TXN_NO,
                                                   VAR_PI_COD_USER_ID => VAR_ARD_PO_USER_ROW.COD_USER_ID,
                                                   VAR_PI_COD_USERNO  => VAR_ARD_PO_USER_ROW.COD_USERNO,
                                                   VAR_PI_STAN_NO     => VAR_ARD_PO_STAN_NO,
                                                   VAR_PI_COD_ACCT_NO => VAR_FINAL_ACCT_NO,
                                                   --  the same initiation-branch parking GL
                                                   VAR_PI_COD_ACCT_NO_DUM_GL      => VAR_FINAL_GL_ACCT,
                                                   VAR_PI_TXN_CUR                 => VAR_TRANSACTION_CCY,
                                                   VAR_PI_ACCT_CUR                => VAR_TRANSACTION_CCY,
                                                   VAR_PI_COD_PROD                => 0,
                                                   VAR_PI_COD_PROC                => 216000,
                                                   VAR_PI_AMT_TXN_LCY             => VAR_GL_AMT_TXN_LCY,
                                                   VAR_PI_AMT_TXN_TCY             => PI_XFER_AMT_TO,
                                                   VAR_PI_AMT_TXN_ACY             => PI_XFER_AMT_TO,
                                                   VAR_PI_TXN_CCY_CONV_RATE       => VAR_GL_TXN_CONV_RATE,
                                                   VAR_PI_ACCT_CCY_CONV_RATE      => VAR_GL_ACCT_CONV_RATE,
                                                   VAR_PI_FLG_OVERRIDE_DUM        => 0,
                                                   VAR_PI_COD_TXN_MNEMONIC        => 1005,
                                                   VAR_PI_TXNDESC1                => '',
                                                   VAR_PI_TXNDESC2                => VAR_TXT_NARRATIVE,
                                                   VAR_PI_COD_TASK_LITERAL_DERIVE => VAR_TASK_LITERAL_DERIVED,
                                                   VAR_PI_FLG_DRCR                => 'C',
                                                   VAR_PI_COD_ORG_MSG_TYP         => 0,
                                                   VAR_PI_REF_ORG_STAN            => 0,
                                                   VAR_PI_REF_ORG_SUBSEQ_NO       => 0,
                                                   VAR_PI_DAT_ORG_TXN             => 0,
                                                   VAR_PI_CTR_YR_ORG_TXN          => 0,
                                                   VAR_PI_DAT_ORG_POST            => 0,
                                                   VAR_PI_CTR_YR_ORG_POST         => 0,
                                                   VAR_PO_COD_EXT                 => VAR_WDR_PO_COD_EXT,
                                                   VAR_PO_COD_REPLY               => VAR_WDR_PO_COD_REPLY,
                                                   VAR_PO_USN                     => VAR_GLTXN_PO_USN,
                                                   VAR_PI_XFEE_AMT                => PI_XFEE_AMT,
                                                   VAR_PO_RESPONSE_CODE           => PO_RESPONSE_CODE,
                                                   VAR_PO_RESPONSE_MESSAGE        => PO_RESPONSE_MESSAGE);
        
          IF VAR_L_RETURN_VALUE <> 0 THEN
            RETURN VAR_L_RETURN_VALUE;
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            PO_RESPONSE_CODE    := 1210;
            PO_RESPONSE_MESSAGE := 'Database Error : executing the Function AP_OL_CALL_GL_TXNS';
            RETURN 1;
        END;
      
        --processOutgoingSWIFTMessage
        BEGIN
          --  NGI-194: reuse the value already fetched above
          IF G_TXN_NETWORK_LOADED = 0 THEN
            SELECT COD_CC_BRN
              INTO G_TXN_NETWORK_BRANCH
              FROM VWE_PM_NETWORK_MAST
             WHERE COD_NETWORK_ID = 'SWIFTO'
               AND FLG_MNT_STATUS = 'A';
          
            G_TXN_NETWORK_LOADED := 1;
          END IF;
        
          VAR_NETWORK_BRANCH := G_TXN_NETWORK_BRANCH;
        EXCEPTION
          WHEN OTHERS THEN
            PO_RESPONSE_CODE    := '100';
            PO_RESPONSE_MESSAGE := 'Failed to select from VWE_PM_NETWORK_MAST ' ||
                                   substring(SQLERRM, 1, 100);
            RETURN 1;
        END;
      
        VAR_PAYMENT_MAPPING.DESIGNATED_BRN_CODE := VAR_NETWORK_BRANCH;
      
        BEGIN
          SELECT COD_LOB
            INTO VAR_SWIFT_LOB
            FROM BA_LOB_BRN_XREF
           WHERE COD_CC_BRN = VAR_NETWORK_BRANCH
             AND FLG_DEFAULT = 'Y'
             AND FLG_MNT_STATUS = 'A'
             AND ROWNUM < 2;
        EXCEPTION
          WHEN OTHERS THEN
            PO_RESPONSE_CODE    := 'PM0001';
            PO_RESPONSE_MESSAGE := 'No records found for lobCode';
            RETURN 1;
        END;
      
        VAR_PAYMENT_MAPPING.LOB_CODE := VAR_SWIFT_LOB;
        VAR_SEQ_SWIFT_NTWRK_REF      := VAR_PAYMENT_TXN_LOG.NETWORK_REFERENCE_NO;
      
        DECLARE
          VAR_XML_AWI3       VARCHAR2(255);
          VAR_XML_AWI4       VARCHAR2(255);
          VAR_XML_INTERMEDY1 VARCHAR2(20);
        BEGIN
          IF TRIM(PI_BANK_CORESPONDENT1) IS NOT NULL OR
             TRIM(PI_BANK_CORESPONDENT2) IS NOT NULL THEN
            VAR_XML_INTERMEDY1 := 'OTHER'; --VERIFY: no pushed UAT run carried a correspondent
          END IF;
        
          VAR_XML_AWI3 := VAR_REL_TXN_STORE.CUSTOMER_BANK_ADDRESS1;
          VAR_XML_AWI4 := VAR_REL_TXN_STORE.CUSTOMER_BANK_ADDRESS2;
        
          SWIFT_REQ_MESSAGE := '<?xml version="1.0" encoding="UTF-8"?><FCUBS_REQ_ENV><FCUBS_HEADER><SOURCE>FCR</SOURCE><UBSCOMP>FCUBS</UBSCOMP><MSGID/><CORRELID/><USERID>SYSTEM</USERID><BRANCH>922</BRANCH><MODULEID>MS</MODULEID><SERVICE>FCUBSMSService</SERVICE><OPERATION>CreateCPMessage</OPERATION><SOURCE_OPERATION/><SOURCE_USERID/><DESTINATION/><MULTITRIPID/><FUNCTIONID>MSDPMTBR</FUNCTIONID><ACTION>NEW</ACTION><ADDL><PARAM><NAME/><VALUE/></PARAM></ADDL></FCUBS_HEADER><FCUBS_BODY><Com-Pmt-In-Full><XREF>' ||
                               VAR_SEQ_SWIFT_NTWRK_REF ||
                               '</XREF><SRCCODE>FCR</SRCCODE><QUEUE>FCR_PMNT</QUEUE><AMOUNT>' ||
                               PI_XFER_AMT_TO || '</AMOUNT><CCY>'
                              --  envelope <CCY> is the currency short name
                               || VAR_XFER_CCY_SHORT ||
                               '</CCY><STATUS/><ERRREASON/><FCCREF/><CUSTACNO>' ||
                               PI_ACCT_ID ||
                               '</CUSTACNO><CUSTCCY/><CPTYACNO>/' ||
                               PI_ACCT_ID ||
                               '</CPTYACNO><CPTYCCY/><BYODROF1>/' ||
                               PI_ACCT_ID || '</BYODROF1><BYODROF2>' ||
                               VAR_REL_TXN_STORE.BENEFICIARY_NAME ||
                               '</BYODROF2><BYODROF3>' ||
                               VAR_REL_TXN_STORE.CUSTOMER_ADDRESS1 ||
                               '</BYODROF3><BYODROF4>' ||
                               VAR_REL_TXN_STORE.CUSTOMER_ADDRESS2 ||
                               '</BYODROF4><BYODROF5>' ||
                               VAR_REL_TXN_STORE.CUSTOMER_ADDRESS3 ||
                               '</BYODROF5><OURCORR1/><OURCORR2/><OURCORR3/><OURCORR4/><OURCORR5/><RCVRCORR1/><RCVRCORR2/><RCVRCORR3/><RCVRCORR4/><RCVRCORR5/><INTERMEDY1>' ||
                               VAR_XML_INTERMEDY1 ||
                               '</INTERMEDY1><INTERMEDY2/><INTERMEDY3>' ||
                               PI_BANK_CORESPONDENT1 ||
                               '</INTERMEDY3><INTERMEDY4>' ||
                               PI_BANK_CORESPONDENT2 ||
                               '</INTERMEDY4><INTERMEDY5/><AWI1>' ||
                               PI_BENF_ID || '</AWI1><AWI2>' ||
                               PI_BENF_BNAME || '</AWI2><AWI3>' ||
                               VAR_XML_AWI3 || '</AWI3><AWI4>' ||
                               VAR_XML_AWI4 || '</AWI4><AWI5>' ||
                               VAR_REL_TXN_STORE.CUSTOMER_BANK_ADDRESS3 ||
                               '</AWI5><BENINST1>/' ||
                               VAR_REL_TXN_STORE.DETAILS.COUNTER_PARTY_ACCOUNT_ID ||
                               '</BENINST1><BENINST2>' || PI_BENF_NAME ||
                               '</BENINST2><BENINST3>' ||
                               VAR_COUNTER_PARTY_DETAIL.ADDRESS_LINE_1 ||
                               '</BENINST3><BENINST4>' ||
                               VAR_COUNTER_PARTY_DETAIL.ADDRESS_LINE_2 ||
                               '</BENINST4><BENINST5/><PAYDET1>' ||
                               PI_MEMO1 ||
                               '</PAYDET1><PAYDET2/><PAYDET3/><PAYDET4/><PAYDET5/><MSGTYPE>MT103</MSGTYPE><VERNO>1</VERNO><LATVERNO>1</LATVERNO><PRDCODE>' ||
                               VAR_REL_TXN_STORE.FCC_PRODUCT_CODE ||
                               '</PRDCODE><ERRDESC/><MAKERID/><MAKERDTSTAMP/><CHECKERID/><CHECKERDTSTAMP/><MODNO>1</MODNO><AUTHSTAT/><RECSTAT/><ONCEAUTH/><UDFDETAILS><FIELD_NAME>ORGBRNCODE</FIELD_NAME><FIELD_VALUE>' ||
                               VAR_PAYMENT_MAPPING.DESIGNATED_BRN_CODE ||
                               '</FIELD_VALUE></UDFDETAILS><UDFDETAILS><FIELD_NAME>LOB</FIELD_NAME><FIELD_VALUE>' ||
                               VAR_PAYMENT_MAPPING.LOB_CODE ||
                               '</FIELD_VALUE></UDFDETAILS><SNDTORECINF1/><SNDTORECINF2/><SNDTORECINF3/><SNDTORECINF4/><SNDTORECINF5/></Com-Pmt-In-Full></FCUBS_BODY></FCUBS_REQ_ENV>';
        END;
      
        BEGIN
          VAR_L_RETURN_VALUE := AP_PROCESS_OUTGOING_MT(SWIFT_REQ_MESSAGE,
                                                       SWIFT_RES_MESSAGE);
        
          IF VAR_L_RETURN_VALUE <> 0 THEN
            --  BR-18: a failed FCC push is swallowed - the booked legs stay committed and the
            --  channel still gets a success
            VAR_L_SWIFT_OK          := 0;
            VAR_L_SWIFT_FAIL_REASON := 'AP_PROCESS_OUTGOING_MT returned ' ||
                                       VAR_L_RETURN_VALUE;
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            VAR_L_SWIFT_OK          := 0;
            VAR_L_SWIFT_FAIL_REASON := 'AP_PROCESS_OUTGOING_MT raised ' ||
                                       SUBSTR(SQLERRM, 1, 200);
        END;
      
        IF VAR_L_SWIFT_OK = 1 THEN
          BEGIN
            SWIFT_RES_XML_MESSAGE := xmltype(SWIFT_RES_MESSAGE);
          
            SELECT EXTRACTVALUE(SWIFT_RES_XML_MESSAGE,
                                '//FCUBS_BODY/FCUBS_WARNING_RESP/WARNING/WCODE',
                                'xmlns="http://fcubs.iflex.com/service/FCUBSMSService/CreateCPMessage"')
              INTO SWIFT_WARN_CODE
              FROM DUAL;
          EXCEPTION
            WHEN OTHERS THEN
              --  masked, not fatal
              VAR_L_SWIFT_OK          := 0;
              VAR_L_SWIFT_FAIL_REASON := 'FCC reply could not be parsed: ' ||
                                         SUBSTR(SQLERRM, 1, 100) ||
                                         ' | reply=' ||
                                         SUBSTR(SWIFT_RES_MESSAGE, 1, 120);
          END;
        END IF;
      
        IF VAR_L_SWIFT_OK = 1 THEN
          IF TRIM(SWIFT_WARN_CODE) IS NULL OR
             SWIFT_WARN_CODE <> 'ST-SAVE-002' THEN
            --  any warning code other than ST-SAVE-002 counts as a masked failure
            VAR_L_SWIFT_OK          := 0;
            VAR_L_SWIFT_FAIL_REASON := 'FCC warning code was ' ||
                                       NVL(TRIM(SWIFT_WARN_CODE), '<empty>') ||
                                       ', expected ST-SAVE-002';
          END IF;
        END IF;
      
        IF VAR_L_SWIFT_OK = 1 THEN
        
          BEGIN
            UPDATE PM_REL_TXN_STORE
               SET COD_CTPARTY_ACCT = '/' ||
                                      VAR_COUNTER_PARTY_DETAIL.COUNTER_PARTY_ACCOUNT_ID
             WHERE REF_TXN_NO = VAR_ARD_PO_REF_TXN_NO;
          EXCEPTION
            WHEN OTHERS THEN
              PO_RESPONSE_CODE    := 1001;
              PO_RESPONSE_MESSAGE := 'Update failed for PM_REL_TXN_STORE ' ||
                                     substring(SQLERRM, 1, 100);
              RETURN 1;
          END;
        
          BEGIN
            --     UPDATE PM_TXN_LOG
            --        SET TXN_STAT = 1, MSG_STAT = 6
            UPDATE PM_TXN_LOG
               SET TXN_STAT   = 1,
                   MSG_STAT   = 5,
                   REF_USR_NO = VAR_ARD_PO_REF_TXN_NO
             WHERE REF_TXN_NO = VAR_ARD_PO_REF_TXN_NO;
          
            --  the same swap applies to the external transaction cross-reference
            UPDATE XF_OL_ST_EXT_TXN_XREF
               SET REF_USR_NO = VAR_ARD_PO_REF_TXN_NO
             WHERE REF_TXN_NO = VAR_ARD_PO_REF_TXN_NO;
          EXCEPTION
            WHEN OTHERS THEN
              PO_RESPONSE_CODE    := 1001;
              PO_RESPONSE_MESSAGE := 'Update failed for pm_txn_log ' ||
                                     substring(SQLERRM, 1, 100);
              RETURN 1;
          END;
        
        END IF; -- VAR_L_SWIFT_OK = 1 (ACK-only status marks)
      
      END IF; --  end of the standard-only network / SWIFT block
    
      --  channel_txn_xref is written after BR-20, just before the successful return
    
      --  BR-20: stored after the FCC ack on a standard txn, always on a special one
      IF VAR_L_SWIFT_OK = 1 THEN
        BEGIN
          INSERT INTO channel_swift_payment_xref
            (ref_usr_no,
             org_chnl_id,
             fee_processing_type,
             fee_bearer_type,
             lld_resident,
             lld_country,
             lld_category,
             lld_affiliate,
             lld_identity,
             lld_purpose,
             lld_description)
          VALUES
            (PI_SVC_RQ_ID,
             --  the reversal service looks this row up by context channel
             VAR_L_IL_CHANNEL,
             'S', -- S=SPLIT,  C=COMBINE
             VAR_REL_TXN_STORE.PM_CHARGES_FEE_CODE, --BEN, OUR, SHA
             VAR_BENIF_LLD_DETAILS_REC.LLD_RESIDENT,
             PI_BENF_BCOUNTRY,
             VAR_BENIF_LLD_DETAILS_REC.LLD_CATEGORY,
             VAR_BENIF_LLD_DETAILS_REC.LLD_AFFILIATE,
             --  the identity segment is not carried on this row
             NULL,
             TRIM(VAR_BENIF_LLD_DETAILS_REC.LLD_PURPOSE),
             VAR_BENIF_LLD_DETAILS_REC.LLD_DESCRIPTION);
        EXCEPTION
          WHEN OTHERS THEN
            PO_RESPONSE_CODE    := 1210;
            PO_RESPONSE_MESSAGE := 'Insert Failed into channel_swift_payment_xref. ' ||
                                   substring(SQLERRM, 1, 100);
            RETURN 1;
        END;
      END IF; -- VAR_L_SWIFT_OK = 1 (BR-20 gate)
    
      --  TODO (BR-20): IL also keeps both rates, the three amounts, both currency short
      --  names, the dealer reference, the fee and the memos on this row.
    
      --  channel_txn_xref: written on a successful commit and read back by the next
      --  day's duplicate check. A failure here never undoes a posted transaction.
      BEGIN
        INSERT INTO channel_txn_xref
          (REF_TXN_NO,
           REF_USR_NO,
           ORG_CHNL_ID,
           AMT_TXN,
           RAT_CONV_TCLCY,
           COD_TXN_CCY,
           COD_TXN_MNEMONIC,
           COD_FROM_ACCT_NO,
           DAT_POST,
           DAT_TXN,
           RAT_STD_AMT,
           RAT_XFER_AMT,
           AMT_FEE,
           FLG_TXN_REVERSED,
           REF_DLR_NO,
           AMT_FROM_ACCT_CCY,
           AMT_TO_ACCT_CCY,
           AMT_LOCAL_CCY,
           FROM_ACCT_CCY,
           TO_ACCT_CCY,
           COD_ORG_BRN,
           FROM_MEMO_1,
           FROM_MEMO_2,
           TO_MEMO_1,
           TO_MEMO_2)
        VALUES
          (
           --  host reference; this is what a reversal looks for
           VAR_ARD_PO_REF_TXN_NO,
           PI_SVC_RQ_ID,
           --  the duplicate check above reads the same context channel
           VAR_L_IL_CHANNEL,
           --  debit amount
           NVL(PI_XFER_AMT_FRM, 0),
           --  IL keeps this at 0; the rate that matters is RAT_XFER_AMT
           0,
           VAR_TRANSACTION_CCY,
           --  2043 standard, 2030 special
           CASE WHEN VAR_L_IS_SPECIAL = 0 THEN VAR_G_MNEM_CASA_GL_FLOW ELSE
           VAR_G_MNEM_OUTG_PAY_FLOW END,
           PI_ACCT_ID,
           --  bank posting date
           NVL(VAR_DATE_PROCESS, TRUNC(SYSDATE)),
           SYSDATE,
           --  both rates as the channel sent them; BR-21 compares them to tell standard
           --  from special on a reversal
           NVL(F_IL_RATE(NVL(VAR_STDRATE_AMT, 0)), 0),
           NVL(F_IL_RATE(NVL(PI_XRATE_AMT, 0)), 0),
           --  fee exactly as the channel sent it
           NVL(PI_XFEE_AMT, 0),
           'N',
           --  dealer reference, NULL when the channel sent none
           TRIM(PI_XREFF_NUMBER),
           NVL(PI_XFER_AMT_FRM, 0),
           NVL(PI_XFER_AMT_TO, 0),
           NVL(PI_XFER_AMT_FRM_LCE, 0),
           --  account currency
           --  NGI-194: from the per-transaction currency cache
           VAR_ACCT_CCY_SHORT,
           --  transfer currency, resolved earlier
           VAR_XFER_CCY_SHORT,
           --  always the CAW branch, even without a dealer reference
           VAR_COD_SPL_BRN,
           PI_MEMO1,
           PI_MEMO2,
           PI_MEMO1,
           PI_MEMO2);
      EXCEPTION
        WHEN OTHERS THEN
          --  a cross-reference failure must not undo a transaction that has posted
          NULL;
      END;
    
      --end of request return 0 for success
    
      PO_REF_NO := VAR_ARD_PO_REF_TXN_NO;
      --  BR-18: success even when the SWIFT push was masked
      PO_RESPONSE_CODE := '0000000';
    
      IF VAR_L_SWIFT_OK = 0 THEN
        PO_RESPONSE_MESSAGE := 'SUCCESS-BR18: FCC push failed; booked legs committed, pending ops re-push. ' ||
                               VAR_L_SWIFT_FAIL_REASON;
      END IF;
    /*Dormancy CR changes*/
	BEGIN
	  IF PI_CUST_INDUCED_FLG = 'Y' THEN
		  VAR_L_RETURN_VALUE := PK_EXT_CH_ACCT_MAST_UPD.AP_CH_EXT_ACCT_DR_UPD(PI_ACCT_ID,
																			'NGI',
																			PI_TRACE_ID,
																			PI_USER_ID);
			IF VAR_L_RETURN_VALUE <> 0 THEN
				PO_RESPONSE_CODE := SQLCODE;
				PO_RESPONSE_MESSAGE  := 'Execution failed for AP_CH_EXT_ACCT_DR_UPD for '||PI_ACCT_ID;
				ORA_RAISERROR(SQLCODE, 'execute() - Exception occured in AP_CH_EXT_ACCT_DR_UPD for '||PI_ACCT_ID,921);
				RETURN 1;
			END IF;
	  END IF;
	END;
	
	
      RETURN 0;
    EXCEPTION
      WHEN OTHERS THEN
        PO_RESPONSE_CODE    := SQLCODE;
        PO_RESPONSE_MESSAGE := SQLERRM;
        RETURN 1;
    END;
  END AP_OL_XFINT_S_MAIN;

  -- ================================================================================
  --  PUBLIC ENTRY POINT.
  --
  --  Rule: the database performs NO COMMIT, and a failed payment leaves NOTHING behind.
  --
  --  The service calls this procedure with the connection in autocommit mode, so the
  --  whole call is one statement and the driver commits when it returns.  Oracle only
  --  undoes a statement automatically when an exception escapes it - but the logic
  --  below reports failure by RETURNING a non-zero code, not by raising.  Without the
  --  savepoint here, a failure that happened AFTER the withdrawal leg was booked would
  --  return an error to the channel and still leave the posted legs committed.
  --
  --  So: mark a savepoint before any work, and undo back to it whenever the call does
  --  not end in success.  This is a ROLLBACK, never a COMMIT - the caller's own work,
  --  if this is ever invoked inside a larger transaction, is untouched.
  --
  --  The OUT parameters keep their values: a rollback affects data, not PL/SQL
  --  variables, so the channel still receives the exact error code and message.
  -- ================================================================================
  FUNCTION AP_OL_XFINT_S_WRAPPER(PI_CHANNEL_ID         IN VARCHAR2,
                                 PI_SVC_CODE           IN VARCHAR2,
                                 PI_SVC_RQ_ID          IN VARCHAR2,
                                 PI_TRACE_ID           IN VARCHAR2,
                                 PI_USER_ID            IN VARCHAR2,
                                 PI_TXN_DATE           IN VARCHAR2,
                                 PI_ACCT_ID            IN VARCHAR2,
                                 PI_ACCT_TYPE          IN VARCHAR2,
                                 PI_ACCT_CUR           IN VARCHAR2,
                                 PI_XFER_AMT_FRM       IN NUMBER,
                                 PI_XFER_AMT_FRM_LCE   IN NUMBER,
                                 PI_XFER_AMT_TO        IN NUMBER,
                                 PI_XFER_AMT_TO_LCE    IN NUMBER,
                                 PI_XFER_CUR_CODE      IN VARCHAR2,
                                 PI_XRATE_AMT          IN NUMBER,
                                 PI_STDRATE_AMT        IN NUMBER,
                                 PI_XREFF_NUMBER       IN VARCHAR2, --dealer ref number
                                 PI_BENF_ACCT          IN VARCHAR2,
                                 PI_BENF_NAME          IN VARCHAR2,
                                 PI_BENF_PHONE         IN VARCHAR2,
                                 PI_BENF_EMAIL         IN VARCHAR2,
                                 PI_BENF_ADDRESS       IN VARCHAR2,
                                 PI_BENF_ID            IN VARCHAR2,
                                 PI_BENF_BNAME         IN VARCHAR2,
                                 PI_BENF_BADDRESS      IN VARCHAR2,
                                 PI_BENF_BCOUNTRY      IN VARCHAR2,
                                 PI_BANK_CORESPONDENT1 IN VARCHAR2,
                                 PI_BANK_CORESPONDENT2 IN VARCHAR2,
                                 PI_XFER_COST_CTR      IN VARCHAR2,
                                 PI_MEMO1              IN VARCHAR2,
                                 PI_MEMO2              IN VARCHAR2,
                                 PI_XFEE_AMT           IN NUMBER,
                                 PI_XFEE_AMT_LCE       IN NUMBER,
                                 PI_XFEE_CODE          IN VARCHAR2,
                                 PI_LLD_INFO           IN VARCHAR2,	 
								 PI_CUST_INDUCED_FLG   IN VARCHAR2,
                                 PO_REF_NO             OUT VARCHAR2,
                                 PO_RESPONSE_CODE      OUT VARCHAR2,
                                 PO_RESPONSE_MESSAGE   OUT VARCHAR2)
    RETURN NUMBER IS
    VAR_L_RET_VAL NUMBER;
  
    PROCEDURE AP_OL_UNDO_TXN IS
    BEGIN
      ROLLBACK TO SAVEPOINT SP_OL_XFINT_START;
    EXCEPTION
      WHEN OTHERS THEN
        --  ORA-01086 means something under us ended the transaction, so the
        --  savepoint no longer exists.  Nothing can be undone at that point and
        --  the channel must still get its error, so this never re-raises.
        NULL;
    END AP_OL_UNDO_TXN;
  BEGIN
    SAVEPOINT SP_OL_XFINT_START;
  
    VAR_L_RET_VAL := AP_OL_XFINT_S_MAIN(PI_CHANNEL_ID,
                                        PI_SVC_CODE,
                                        PI_SVC_RQ_ID,
                                        PI_TRACE_ID,
                                        PI_USER_ID,
                                        PI_TXN_DATE,
                                        PI_ACCT_ID,
                                        PI_ACCT_TYPE,
                                        PI_ACCT_CUR,
                                        PI_XFER_AMT_FRM,
                                        PI_XFER_AMT_FRM_LCE,
                                        PI_XFER_AMT_TO,
                                        PI_XFER_AMT_TO_LCE,
                                        PI_XFER_CUR_CODE,
                                        PI_XRATE_AMT,
                                        PI_STDRATE_AMT,
                                        PI_XREFF_NUMBER,
                                        PI_BENF_ACCT,
                                        PI_BENF_NAME,
                                        PI_BENF_PHONE,
                                        PI_BENF_EMAIL,
                                        PI_BENF_ADDRESS,
                                        PI_BENF_ID,
                                        PI_BENF_BNAME,
                                        PI_BENF_BADDRESS,
                                        PI_BENF_BCOUNTRY,
                                        PI_BANK_CORESPONDENT1,
                                        PI_BANK_CORESPONDENT2,
                                        PI_XFER_COST_CTR,
                                        PI_MEMO1,
                                        PI_MEMO2,
                                        PI_XFEE_AMT,
                                        PI_XFEE_AMT_LCE,
                                        PI_XFEE_CODE,
                                        PI_LLD_INFO,
										PI_CUST_INDUCED_FLG,
                                        PO_REF_NO,
                                        PO_RESPONSE_CODE,
                                        PO_RESPONSE_MESSAGE);
  
    IF NVL(VAR_L_RET_VAL, 1) <> 0 THEN
      --  failed payment: undo every leg, cross-reference and log row it wrote
      AP_OL_UNDO_TXN;
    END IF;
  
    RETURN VAR_L_RET_VAL;
  EXCEPTION
    WHEN OTHERS THEN
      --  nothing should reach here, the logic traps its own errors, but an
      --  unexpected escape must not leave a half-posted payment behind
      AP_OL_UNDO_TXN;
    
      PO_RESPONSE_CODE    := SQLCODE;
      PO_RESPONSE_MESSAGE := SQLERRM;
      RETURN 1;
  END AP_OL_XFINT_S_WRAPPER;

  --FUNCTION POPULATE_CCY_AMOUNT START

  --  a rate handed to an OLTP procedure is reduced to the shortest decimal that
  --  round-trips through a 32-bit float, the way IL stores it
  FUNCTION F_IL_RATE(PI_RATE IN NUMBER) RETURN NUMBER IS
    VAR_L_BF    BINARY_FLOAT;
    VAR_L_SCALE NUMBER;
    VAR_L_TRY   NUMBER;
  BEGIN
    IF PI_RATE IS NULL OR PI_RATE = 0 THEN
      RETURN PI_RATE;
    END IF;
  
    --  TM9 prints the full expansion of the float, Java prints the shortest form, so
    --  try 7, 8 then 9 significant digits and take the first that converts back
    VAR_L_BF := CAST(PI_RATE AS BINARY_FLOAT);
  
    FOR i IN 7 .. 9 LOOP
      VAR_L_SCALE := i - 1 - FLOOR(LOG(10, ABS(PI_RATE)));
      VAR_L_TRY   := ROUND(PI_RATE, VAR_L_SCALE);
    
      IF CAST(VAR_L_TRY AS BINARY_FLOAT) = VAR_L_BF THEN
        RETURN VAR_L_TRY;
      END IF;
    END LOOP;
  
    RETURN ROUND(PI_RATE, 7);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN ROUND(PI_RATE, 7); -- fallback
  END F_IL_RATE;

  FUNCTION POPULATE_CCY_AMOUNT(PI_ISO_CODE            IN VARCHAR2,
                               PI_AMOUNT              IN NUMBER,
                               PI_CONV_RATE           IN NUMBER,
                               PO_CURRENCY_AMOUNT_REC OUT CURRENCY_AMOUNT_REC)
    RETURN NUMBER IS
    VAR_BANK_LOCAL_CUR_SHORT_NAME vwe_ba_ccy_code.NAM_CCY_SHORT%TYPE;
    VAR_G_COD_BANK                BA_BANK_MAST.COD_LCY%TYPE := 11;
    VAR_ISO_CURRENCY_SHORT_NAME   vwe_ba_ccy_code.NAM_DEC_CCY_SHORT%TYPE;
  BEGIN
    BEGIN
      --  NGI-194: this function is called three times per payment and this lookup
      --  (a view joined to BA_BANK_MAST) is identical on every call, so it is
      --  resolved once per transaction.
      IF G_TXN_BANK_LCY_LOADED = 0 THEN
        SELECT NAM_CCY_SHORT
          INTO G_TXN_BANK_LCY_SHORT
          FROM vwe_ba_ccy_code
         WHERE COD_CCY_ISO =
               (SELECT COD_LCY
                  FROM ba_bank_mast
                 WHERE cod_bank = VAR_G_COD_BANK)
           AND FLG_MNT_STATUS = 'A';
      
        G_TXN_BANK_LCY_LOADED := 1;
      END IF;
    
      VAR_BANK_LOCAL_CUR_SHORT_NAME := G_TXN_BANK_LCY_SHORT;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN 1;
    END;
  
    IF PI_ISO_CODE NOT IN ('000', '888') THEN
      BEGIN
        SELECT NAM_CCY_SHORT
          INTO VAR_ISO_CURRENCY_SHORT_NAME
          FROM vwe_ba_ccy_code
         WHERE COD_CCY_ISO = PI_ISO_CODE
           AND FLG_MNT_STATUS = 'A';
      EXCEPTION
        WHEN OTHERS THEN
          RETURN 1;
      END;
    END IF;
  
    IF PI_ISO_CODE = '000' THEN
      PO_CURRENCY_AMOUNT_REC.CURRENCY_CODE  := VAR_BANK_LOCAL_CUR_SHORT_NAME;
      PO_CURRENCY_AMOUNT_REC.MONETARY_VALUE := PI_AMOUNT;
      PO_CURRENCY_AMOUNT_REC.CURRENCY_RATE  := PI_CONV_RATE;
    ELSIF PI_ISO_CODE = '888' THEN
      PO_CURRENCY_AMOUNT_REC.CURRENCY_CODE  := VAR_BANK_LOCAL_CUR_SHORT_NAME;
      PO_CURRENCY_AMOUNT_REC.MONETARY_VALUE := PI_AMOUNT * 100;
      PO_CURRENCY_AMOUNT_REC.CURRENCY_RATE  := PI_CONV_RATE;
    ELSE
      PO_CURRENCY_AMOUNT_REC.CURRENCY_CODE  := VAR_ISO_CURRENCY_SHORT_NAME;
      PO_CURRENCY_AMOUNT_REC.MONETARY_VALUE := PI_AMOUNT;
      PO_CURRENCY_AMOUNT_REC.CURRENCY_RATE  := PI_CONV_RATE;
    END IF;
  
    RETURN 1;
  END;

  FUNCTION GET_CURRENCY_CODE(PI_CURRENCY_SHORT_NAME IN VARCHAR2)
    RETURN NUMBER IS
    VAR_CURRENCY_CODE NUMBER;
  BEGIN
    BEGIN
      SELECT cod_ccy
        INTO VAR_CURRENCY_CODE
        FROM vwe_ba_ccy_code
       WHERE NAM_CCY_SHORT = PI_CURRENCY_SHORT_NAME
         AND flg_mnt_status = 'A';
    EXCEPTION
      WHEN OTHERS THEN
        RETURN 1;
    END;
  
    RETURN VAR_CURRENCY_CODE;
  END;

  --FUNCTION getCurrencyCode END

  --FUNCTION AP_READ_DATA

  FUNCTION AP_READ_DATA(VAR_PI_SVC_RQ_ID        IN VARCHAR2,
                        VAR_PI_USER_ID          IN VARCHAR2,
                        VAR_PI_DAT_PROCESS      IN DATE,
                        VAR_PI_COD_TXN_MNEMONIC IN NUMBER,
                        -----FROM ACCOUNT DETAILS----
                        VAR_PI_COD_ACC_NO_FRM     IN VARCHAR2,
                        VAR_PI_COD_ACC_CCY_FRM    IN NUMBER,
                        VAR_PO_COD_CC_BRN_F       OUT NUMBER,
                        VAR_PO_COD_PROD_F         OUT NUMBER,
                        VAR_PO_ACCT_CUR_F         OUT NUMBER,
                        VAR_PO_USN_F              OUT NUMBER,
                        VAR_PO_FLG_PSBOOK_F       OUT VARCHAR2,
                        VAR_PO_BAL_LST_PSBK_F     OUT NUMBER,
                        VAR_PO_COD_CUST_F         OUT NUMBER,
                        VAR_PO_CTR_PSBK_LINE_NO_F OUT NUMBER,
                        VAR_PO_USER_ROW           IN OUT SM_USER_PROFILE%ROWTYPE,
                        ---------------KEY VALUES---------
                        VAR_PO_REF_TXN_NO       OUT VARCHAR2,
                        VAR_PO_STAN_NO          OUT NUMBER,
                        VAR_PO_RESPONSE_CODE    IN OUT VARCHAR2,
                        VAR_PO_RESPONSE_MESSAGE IN OUT VARCHAR2)
    RETURN NUMBER IS
    VAR_L_QUERY              VARCHAR2(255);
    VAR_L_STAN_SEQUENCE_NAME VARCHAR2(100);
    VAR_L_COUNT              NUMBER := 0;
    VAR_L_RETURN_VAL         NUMBER := 0;
    NO_ROWS EXCEPTION;
    VAR_L_DAT_PROCESS DATE;
  BEGIN
    BEGIN
      SELECT *
        INTO VAR_PO_USER_ROW
        FROM SM_USER_PROFILE
       WHERE COD_USER_ID = VAR_PI_USER_ID
         AND FLG_MNT_STATUS = 'A';
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        VAR_PO_RESPONSE_CODE    := '2077';
        VAR_PO_RESPONSE_MESSAGE := 'Invalid user id';
        RETURN 1;
      WHEN OTHERS THEN
        VAR_PO_RESPONSE_CODE    := 20;
        VAR_PO_RESPONSE_MESSAGE := 'SELECT FAILED FROM SM_USER_PROFILE FOR,' ||
                                   VAR_PI_USER_ID;
        ORA_RAISERROR(SQLCODE,
                      'SELECT FAILED FROM MAKER SM_USER_PROFILE:' ||
                      VAR_PI_USER_ID,
                      158);
        RETURN 1;
    END;
  
    BEGIN
      VAR_L_RETURN_VAL := AP_VAL_ACCOUNT(VAR_PI_COD_ACC_NO_FRM     => VAR_PI_COD_ACC_NO_FRM,
                                         VAR_PI_COD_ACC_CCY_FRM    => VAR_PI_COD_ACC_CCY_FRM,
                                         var_PO_COD_CC_BRN_F       => VAR_PO_COD_CC_BRN_F,
                                         VAR_PO_COD_PROD_F         => VAR_PO_COD_PROD_F,
                                         VAR_PO_ACCT_CUR_F         => VAR_PO_ACCT_CUR_F,
                                         VAR_PO_USN_F              => VAR_PO_USN_F,
                                         VAR_PO_FLG_PSBOOK_F       => VAR_PO_FLG_PSBOOK_F,
                                         VAR_PO_BAL_LST_PSBK_F     => VAR_PO_BAL_LST_PSBK_F,
                                         VAR_PO_COD_CUST_F         => VAR_PO_COD_CUST_F,
                                         VAR_PO_CTR_PSBK_LINE_NO_F => VAR_PO_CTR_PSBK_LINE_NO_F,
                                         VAR_PO_RESPONSE_CODE      => VAR_PO_RESPONSE_CODE,
                                         VAR_PO_RESPONSE_MESSAGE   => VAR_PO_RESPONSE_MESSAGE);
    EXCEPTION
      WHEN OTHERS THEN
        VAR_PO_RESPONSE_CODE    := SQLCODE;
        VAR_PO_RESPONSE_MESSAGE := 'execute() - Exception occured while executing the Function AP_VAL_ACCOUNT';
        RETURN 1;
    END;
  
    --Get date
    VAR_L_DAT_PROCESS := SYSDATE;
  
    --Get External System Audit Trail Number
    BEGIN
      BEGIN
        VAR_L_STAN_SEQUENCE_NAME := UPPER(TRIM('API_11_' ||
                                               TRIM(VAR_PI_USER_ID) ||
                                               '_STAN_SEQ'));
      
        -- ================================================================
        --  NGI-194.  This existence check used to run a data-dictionary query
        --  (USER_OBJECTS is a heavy view, and this was dynamic SQL) on EVERY
        --  payment.  Under concurrency it also contends on the row cache.
        --
        --  The answer cannot meaningfully change while the session lives - the
        --  sequence is DDL - so it is verified once per sequence name per
        --  session.  USER_SEQUENCES is used instead of USER_OBJECTS: it is a far
        --  lighter view and it is what the following NEXTVAL actually needs.
        -- ================================================================
        IF G_SEQ_VERIFIED.EXISTS(VAR_L_STAN_SEQUENCE_NAME) THEN
          VAR_L_COUNT := G_SEQ_VERIFIED(VAR_L_STAN_SEQUENCE_NAME);
        ELSE
          SELECT COUNT(*)
            INTO VAR_L_COUNT
            FROM USER_SEQUENCES
           WHERE SEQUENCE_NAME = VAR_L_STAN_SEQUENCE_NAME;
        
          --  only a positive result is remembered; a miss is re-checked next
          --  time so a newly created sequence is picked up straight away
          IF VAR_L_COUNT > 0 THEN
            G_SEQ_VERIFIED(VAR_L_STAN_SEQUENCE_NAME) := VAR_L_COUNT;
          END IF;
        END IF;
      
        --  BEHAVIOUR PRESERVED EXACTLY.  The original line here read
        --      IF SQL%ROWCOUNT = 0 THEN RAISE NO_ROWS; END IF;
        --  placed after an EXECUTE IMMEDIATE ... INTO.  A COUNT(*) always
        --  returns exactly one row, so SQL%ROWCOUNT was always 1 and NO_ROWS was
        --  never raised - a missing sequence fell through to the NEXTVAL below
        --  and surfaced as response 29, 'Execution failed for sequence'.
        --  That is left untouched: this optimisation must not change which error
        --  code the bank sees.  VAR_L_COUNT is therefore still not used for
        --  control flow.
        --
        --  NOTE for the record: response 27 'Sequence not found' has always been
        --  unreachable for this reason.  Raise it as a separate finding if the
        --  team wants it corrected - it is a functional change, not a
        --  performance one.
        NULL;
      EXCEPTION
        WHEN NO_ROWS THEN
          VAR_PO_RESPONSE_CODE    := 27;
          VAR_PO_RESPONSE_MESSAGE := 'Sequence not found';
          RETURN 1;
        WHEN OTHERS THEN
          VAR_PO_RESPONSE_CODE    := 28;
          VAR_PO_RESPONSE_MESSAGE := 'Select failed for sequence ' ||
                                     VAR_L_STAN_SEQUENCE_NAME;
          RETURN 1;
      END;
    
      VAR_L_QUERY := 'select ' || TRIM(VAR_L_STAN_SEQUENCE_NAME) ||
                     '.nextval FROM dual';
    
      EXECUTE IMMEDIATE VAR_L_QUERY
        INTO VAR_PO_STAN_NO;
    
      BEGIN
        --  30-character layout:
        --  COD_USERNO || TO_CHAR (SYSDATE, 'YYYYMMDDHH24MISS') || LPAD ('02' || STAN, 11, '0')
        VAR_PO_REF_TXN_NO := VAR_PO_USER_ROW.COD_USERNO ||
                             TO_CHAR(VAR_L_DAT_PROCESS, 'YYYYMMDDHH24MISS') ||
                             LPAD('02' || VAR_PO_STAN_NO, 11, '0');
      EXCEPTION
        WHEN OTHERS THEN
          VAR_PO_RESPONSE_CODE    := 31;
          VAR_PO_RESPONSE_MESSAGE := 'REF TXN NO FORMATION FAIL';
          RETURN 1;
      END;
    EXCEPTION
      WHEN OTHERS THEN
        VAR_PO_RESPONSE_CODE    := 29;
        VAR_PO_RESPONSE_MESSAGE := 'Execution failed for sequence';
        RETURN 1;
    END;
  
    --STAN : System Trail Audit Number
    VAR_PO_STAN_NO := VAR_PO_STAN_NO * 100;
  
    RETURN 0;
  EXCEPTION
    WHEN OTHERS THEN
      VAR_PO_RESPONSE_CODE    := SQLCODE;
      VAR_PO_RESPONSE_MESSAGE := 'execute() - Exception occured while executing the Function AP_READ_DATA, ' ||
                                 substring(SQLERRM, 1, 100);
      RETURN 1;
  END AP_READ_DATA;

  FUNCTION AP_VAL_ACCOUNT(VAR_PI_COD_ACC_NO_FRM     IN VARCHAR2,
                          VAR_PI_COD_ACC_CCY_FRM    IN NUMBER,
                          var_PO_COD_CC_BRN_F       OUT NUMBER,
                          VAR_PO_COD_PROD_F         OUT NUMBER,
                          VAR_PO_ACCT_CUR_F         OUT NUMBER,
                          VAR_PO_USN_F              OUT NUMBER,
                          VAR_PO_FLG_PSBOOK_F       OUT VARCHAR2,
                          VAR_PO_BAL_LST_PSBK_F     OUT NUMBER,
                          VAR_PO_CTR_PSBK_LINE_NO_F OUT NUMBER,
                          VAR_PO_COD_CUST_F         OUT VARCHAR2,
                          VAR_PO_RESPONSE_CODE      IN OUT NUMBER,
                          VAR_PO_RESPONSE_MESSAGE   IN OUT VARCHAR2)
    RETURN NUMBER IS
    VAR_L_RET_CODE    NUMBER := 0;
    VAR_L_RET_COUNT   NUMBER := 0;
    VAR_L_COD_MODULE  VARCHAR2(5);
    VAR_L_FLG_MEMO_F  VARCHAR2(1);
    var_l_cod_cust_id NUMBER;
  BEGIN
    BEGIN
      SELECT COD_MODULE
        INTO VAR_L_COD_MODULE
        FROM vwe_cs_ho_acct_module_xref
       WHERE COD_ACCT_NO = CAST(VAR_PI_COD_ACC_NO_FRM AS CHAR(16));
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        VAR_PO_RESPONSE_CODE    := 6031;
        VAR_PO_RESPONSE_MESSAGE := 'Invalid Module Code, Account No:' ||
                                   VAR_PI_COD_ACC_NO_FRM;
        RETURN 1;
    END;
  
    IF var_l_COD_MODULE = 'CH' THEN
      BEGIN
        SELECT COD_CC_BRN,
               COD_PROD,
               COD_CCY,
               CTR_UPDAT_SRLNO,
               FLG_PSBOOK,
               BAL_LST_PSBK,
               CTR_PSBK_LINE_NO,
               FLG_MEMO,
               COD_CUST
          INTO VAR_PO_COD_CC_BRN_F,
               VAR_PO_COD_PROD_F,
               VAR_PO_ACCT_CUR_F,
               VAR_PO_USN_F,
               VAR_PO_FLG_PSBOOK_F,
               VAR_PO_BAL_LST_PSBK_F,
               VAR_PO_CTR_PSBK_LINE_NO_F,
               VAR_L_FLG_MEMO_F,
               VAR_PO_COD_CUST_F
          FROM VWE_CH_ACCT_MAST
         WHERE COD_ACCT_NO = CAST(VAR_PI_COD_ACC_NO_FRM AS CHAR(16))
           AND FLG_MNT_STATUS = 'A';
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          VAR_PO_RESPONSE_CODE    := 2853;
          VAR_PO_RESPONSE_MESSAGE := 'Account not found for - ' ||
                                     VAR_PI_COD_ACC_NO_FRM;
          RETURN 1;
        WHEN OTHERS THEN
          VAR_PO_RESPONSE_CODE    := SQLCODE;
          VAR_PO_RESPONSE_MESSAGE := 'Select failed for vwe_ch_acct_mast ' ||
                                     SUBSTR(SQLERRM, 1, 100);
          ORA_RAISERROR(SQLCODE,
                        'Select failed for vwe_ch_acct_mast  ' ||
                        VAR_PI_COD_ACC_NO_FRM,
                        270);
          RETURN 1;
      END;
    END IF;
  
    --high memo validation
    IF NVL(VAR_L_FLG_MEMO_F, 'N') <> 'N' THEN
      DECLARE
        VAR_L_TXT_MEMO          VARCHAR2(3000);
        VAR_L_FLG_CUST_MEMO_SEV VARCHAR2(1);
        VAR_L_FLG_ACCT_MEMO_SEV VARCHAR2(1);
      BEGIN
        VAR_L_RET_CODE := AP_BA_GET_MEMO(VAR_PI_FLG_CUST_ACCT_MEMO => VAR_L_FLG_MEMO_F,
                                         VAR_PI_COD_CUST_ID        => VAR_PO_COD_CUST_F,
                                         VAR_PI_COD_ACCT_NO        => RPAD(TO_CHAR(VAR_PI_COD_ACC_NO_FRM),
                                                                           16,
                                                                           ' '),
                                         VAR_PO_TXT_MEMO           => VAR_L_TXT_MEMO,
                                         VAR_PO_FLG_CUST_MEMO_SEV  => VAR_L_FLG_CUST_MEMO_SEV,
                                         VAR_PO_FLG_ACCT_MEMO_SEV  => VAR_L_FLG_ACCT_MEMO_SEV);
      
        IF VAR_L_FLG_CUST_MEMO_SEV = 'H' OR VAR_L_FLG_ACCT_MEMO_SEV = 'H' THEN
          VAR_PO_RESPONSE_CODE    := 11;
          VAR_PO_RESPONSE_MESSAGE := 'There is a memo present on the Debit account';
          RETURN 1;
        ELSIF VAR_L_FLG_ACCT_MEMO_SEV != 'H' THEN
          BEGIN
            SELECT cod_cust
              INTO var_l_cod_cust_id
              FROM ch_acct_cust_xref
             WHERE cod_acct_no =
                   RPAD(TO_CHAR(VAR_PI_COD_ACC_NO_FRM), 16, ' ')
               AND cod_acct_cust_rel IN ('SOW', 'JAF', 'JOF');
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              VAR_PO_RESPONSE_CODE    := 29;
              VAR_PO_RESPONSE_MESSAGE := 'Internal OLTP Error';
              RETURN 1;
            WHEN OTHERS THEN
              VAR_PO_RESPONSE_CODE    := 29;
              VAR_PO_RESPONSE_MESSAGE := 'Internal OLTP Error';
              RETURN 95;
          END;
        ELSE
          NULL;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          VAR_PO_RESPONSE_CODE    := 11;
          VAR_PO_RESPONSE_MESSAGE := 'Unable to chek memo severty level';
          RETURN 1;
      END;
    END IF;
  
    SELECT COUNT(*)
      INTO VAR_L_RET_COUNT
      FROM VWE_BA_CCY_CODE
     WHERE COD_CCY = VAR_PI_COD_ACC_CCY_FRM
       AND FLG_MNT_STATUS = 'A';
  
    IF VAR_L_RET_COUNT = 0 THEN
      VAR_PO_RESPONSE_CODE    := 1248;
      VAR_PO_RESPONSE_MESSAGE := 'Invalid currency code, From Account CCY:' ||
                                 VAR_PI_COD_ACC_CCY_FRM;
      RETURN 1;
    END IF;
  
    RETURN VAR_L_RET_CODE;
  EXCEPTION
    WHEN OTHERS THEN
      VAR_PO_RESPONSE_CODE    := SQLCODE;
      VAR_PO_RESPONSE_MESSAGE := 'execute() - Exception occured while executing the Function AP_VAL_ACCOUNT, ' ||
                                 substring(SQLERRM, 1, 100);
      RETURN 1;
  END AP_VAL_ACCOUNT;

  FUNCTION AP_SAVE_PAYMENT_LOG(VAR_PI_REL_TXN_STORE        IN REL_TXN_STORE_REC,
                               VAR_PI_PAYMENT_TXN_LOG      IN PAYMENT_TXN_LOG_REC,
                               VAR_L_NTWK_ACCT_STAT        IN NUMBER,
                               VAR_PI_COUNTER_PARTY_DETAIL IN COUNTER_PARTY_DETAIL_REC,
                               VAR_PI_COD_MSG_TYP          IN NUMBER,
                               VAR_PI_CHANNEL_ID           IN VARCHAR2,
                               VAR_PI_SUB_SEQ_NO           IN NUMBER,
                               VAR_PI_TOT_SUBSEQ_NO        IN NUMBER DEFAULT 7,
                               VAR_PI_DAT_TXN              IN NUMBER,
                               VAR_PI_COD_USER_ID          IN SM_USER_PROFILE.COD_USER_ID%TYPE,
                               VAR_PI_STAN_NO              IN NUMBER,
                               VAR_PI_TXN_CCY              IN NUMBER,
                               VAR_PI_AMT_TXN_TCY          IN NUMBER,
                               VAR_PI_RAT_CONV_TCLCY       IN NUMBER,
                               VAR_PI_AMT_TXN_LCY          IN NUMBER,
                               VAR_PI_AMT_TXN_ACY          IN NUMBER,
                               VAR_PI_RAT_CONV_ACLCY       IN NUMBER,
                               VAR_PI_COD_NETWORK_ID       IN VARCHAR2,
                               VAR_PI_NAM_CUST_BRN         IN NUMBER,
                               VAR_PI_REF_TXN_NO           IN VARCHAR2,
                               VAR_PI_REF_USR_NO           IN VARCHAR2,
                               PO_RESPONSE_CODE            OUT VARCHAR2,
                               PO_RESPONSE_MESSAGE         OUT VARCHAR2)
    RETURN NUMBER IS
    VAR_L_COD_MSG_TYP    NUMBER := VAR_PI_COD_MSG_TYP;
    VAR_L_CHANNEL_ID     VARCHAR2(40 BYTE) := VAR_PI_CHANNEL_ID;
    VAR_L_COD_CC_BRN     NUMBER := VAR_PI_REL_TXN_STORE.ORIGINATING_BRANCH;
    VAR_L_DAT_TXN        NUMBER := LPAD(DATEPART('MM', SYSDATE), 2, '0') ||
                                   LPAD(DATEPART('DD', SYSDATE), 2, '0') ||
                                   LPAD(DATEPART('HH', SYSDATE), 2, '0') ||
                                   LPAD(DATEPART('MI', SYSDATE), 2, '0') ||
                                   LPAD(DATEPART('SS', SYSDATE), 2, '0');
    VAR_L_CTR_YR_TXN_DUM NUMBER := DATEPART('YY', SYSDATE);
    VAR_L_COD_USERID     SM_USER_PROFILE.COD_USER_ID%TYPE := VAR_PI_COD_USER_ID;
    VAR_L_CTR_BATCH_NO   NUMBER := 2;
    VAR_L_STAN_NO        NUMBER := VAR_PI_STAN_NO;
    VAR_L_REF_SUBSEQ_NO  NUMBER := VAR_PI_SUB_SEQ_NO;
    --  number of ledger subsequences the transaction used
    VAR_L_SUBSEQ_NO          NUMBER := VAR_PI_TOT_SUBSEQ_NO;
    VAR_L_COD_PAYMENT_TXN    VARCHAR2(32 BYTE) := VAR_PI_REL_TXN_STORE.PAYMENT_TRANSACTION_CODE;
    VAR_L_COD_TXN_MNEMONIC   NUMBER(5) := VAR_PI_REL_TXN_STORE.TRANSACTION_MNEMONIC;
    VAR_L_DAT_PROCESS        BA_BANK_MAST.DAT_PROCESS%TYPE := PK_BA_GLOBAL.DAT_PROCESS;
    VAR_L_DAT_POST           DATE := VAR_L_DAT_PROCESS;
    VAR_L_DAT_VALUE          DATE := VAR_L_DAT_PROCESS;
    VAR_L_COD_ACCT_NO        CHAR(16 BYTE) := VAR_PI_PAYMENT_TXN_LOG.ACCOUNT_NO;
    VAR_COD_ACCT_BRN         NUMBER;
    VAR_L_COD_CUST           NUMBER := VAR_PI_PAYMENT_TXN_LOG.CUSTOMER_ID;
    VAR_L_COD_TXN_CCY        NUMBER := VAR_PI_TXN_CCY;
    VAR_L_AMT_TXN_TCY        NUMBER := VAR_PI_AMT_TXN_TCY;
    VAR_L_RAT_CONV_TCLCY     NUMBER := VAR_PI_RAT_CONV_TCLCY;
    VAR_L_AMT_TXN_LCY        NUMBER := VAR_PI_AMT_TXN_LCY;
    VAR_L_AMT_TXN_ACY        NUMBER := VAR_PI_AMT_TXN_ACY;
    VAR_L_RAT_CONV_ACLCY     NUMBER := VAR_PI_RAT_CONV_ACLCY;
    VAR_L_COD_NETWORK_ID     VARCHAR2(32 BYTE) := VAR_PI_COD_NETWORK_ID;
    VAR_L_REF_TXN_NO         VARCHAR2(40 BYTE) := VAR_PI_REF_TXN_NO;
    VAR_L_REF_USR_NO         VARCHAR2(40 BYTE) := VAR_PI_REF_USR_NO;
    VAR_L_DAT_DISPATCH       DATE := VAR_L_DAT_PROCESS;
    VAR_L_DAT_ACTIVATION     DATE := VAR_L_DAT_PROCESS;
    VAR_L_DAT_CTRPARTY_VALUE DATE := VAR_L_DAT_PROCESS;
    VAR_L_PAY_DIR            VARCHAR2(12 BYTE) := '0';
    VAR_L_ACCT_STAT          NUMBER(3) := 3;
    VAR_L_MSG_STAT           NUMBER(3);
    VAR_L_TXN_STAT           NUMBER(3) := 0; --inserting 0, updateing to 1 after fcc call
    VAR_L_COD_REPLY          NUMBER(5) := 0;
    VAR_L_COD_SRL_TXT        VARCHAR2(255 BYTE);
    --  IL leaves this empty; the narrative is kept on PM_REL_TXN_STORE only
    VAR_L_TXT_TXN_DESC            VARCHAR2(360 BYTE) := NULL;
    VAR_L_FLG_NTWKDATE_PROCESSED  VARCHAR2(255) := 'NP';
    VAR_L_FLG_VALUEDATE_PROCESSED VARCHAR2(3 BYTE) := 'NTP';
    VAR_L_DAT_NTWK_VALUE          DATE := VAR_L_DAT_PROCESS;
    VAR_L_FLG_CONTG_PROCESSED     VARCHAR2(3 BYTE) := 'NTP';
    VAR_L_CONTG_ACCT_STAT         NUMBER(3) := 0;
    VAR_L_AMT_TOT_TCY             NUMBER := VAR_L_AMT_TXN_TCY;
    ---------------
    VAR_L_COD_PKG_ID               VARCHAR2(32 BYTE) := VAR_PI_REL_TXN_STORE.PAYMENT_PACKAGE_ID;
    COD_TXN_INIT_BRN               NUMBER := VAR_PI_REL_TXN_STORE.ORIGINATING_BRANCH;
    VAR_L_COD_ORG_BRN              NUMBER := VAR_PI_REL_TXN_STORE.ORIGINATING_BRANCH;
    VAR_L_COD_ACCT_TITLE           VARCHAR2(120 BYTE);
    VAR_L_DAT_TRANSMISSION         NUMBER := 0;
    VAR_L_COD_ORG_PROCESS          NUMBER := 0;
    VAR_L_TXT_NARRATIVE            VARCHAR2(256 BYTE) := VAR_PI_REL_TXN_STORE.NARRATIVE;
    VAR_L_COD_CLG                  NUMBER := 0;
    VAR_L_TYPE_CLG                 NUMBER := 0;
    VAR_L_FLG_INTERNAL_CLG         VARCHAR2(1 BYTE) := 'N';
    VAR_L_COD_FRM_ZONE_ID          VARCHAR2(32 BYTE) := '';
    VAR_L_COD_FRM_CIRCLE_ID        VARCHAR2(32 BYTE) := '';
    VAR_L_TXT_CTPARTY_ADD1         VARCHAR2(150 BYTE);
    VAR_L_COD_STL_CCY              VARCHAR2(10 BYTE) := '001';
    VAR_L_COD_TXN_INITIA_RESI_STAT VARCHAR2(10 BYTE) := '001';
  BEGIN
    BEGIN
      FOR i IN 1 .. 32 LOOP
        VAR_L_COD_SRL_TXT := VAR_L_COD_SRL_TXT ||
                             SUBSTR('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789',
                                    MOD(ABS(DBMS_RANDOM.RANDOM), 62) + 1,
                                    1);
      END LOOP;
    EXCEPTION
      WHEN OTHERS THEN
        PO_RESPONSE_CODE    := 1;
        PO_RESPONSE_MESSAGE := 'Error in generating serial number';
        RETURN 1;
    END;
  
    BEGIN
      INSERT INTO XF_OL_ST_EXT_TXN_XREF
        (REF_TXN_NO,
         COD_MSG_TYP,
         COD_ORG_BRN,
         CTR_BATCH_NO,
         REF_SYS_TR_AUD_NO,
         DAT_LOG,
         DAT_TXN,
         DAT_POST,
         COD_ORG_BANK,
         COD_USER_ID,
         SUB_SEQ_NO,
         REF_USR_NO,
         CHANNEL_ID,
         COD_ENTITY_VPD)
      VALUES
        (VAR_L_REF_TXN_NO,
         VAR_L_COD_MSG_TYP,
         VAR_L_COD_ORG_BRN,
         VAR_L_CTR_BATCH_NO,
         VAR_L_STAN_NO,
         SYSDATE,
         SYSDATE,
         VAR_L_DAT_POST,
         11,
         VAR_L_COD_USERID,
         VAR_L_SUBSEQ_NO,
         --  the channel reference, not the FCR one
         VAR_L_REF_USR_NO,
         VAR_L_CHANNEL_ID,
         11);
    EXCEPTION
      WHEN OTHERS THEN
        PO_RESPONSE_CODE    := 1;
        PO_RESPONSE_MESSAGE := 'INSERTION FAILED (XF_OL_ST_EXT_TXN_XREF)';
        RETURN 1;
    END;
  
    BEGIN
      INSERT INTO VWE_PM_TXN_LOG
        (COD_ORG_BRN,
         COD_ORG_BANK,
         COD_USER_ID,
         DAT_TXN,
         CTR_BATCH_NO,
         REF_SYS_TR_AUD_NO,
         REF_SUBSEQ_NO,
         COD_PAYMENT_TXN,
         COD_TXN_MNEMONIC,
         DAT_POST,
         DAT_VALUE,
         COD_ACCT_NO,
         COD_CUST_ID,
         COD_TXN_CCY,
         AMT_TXN_TCY,
         RAT_CONV_TCLCY,
         AMT_TXN_LCY,
         AMT_TXN_ACY,
         RAT_CONV_ACLCY,
         COD_NETWORK_ID,
         REF_NETWORK_NO,
         REF_TXN_NO,
         REF_USR_NO,
         PAY_DIR,
         ACCT_STAT,
         MSG_STAT,
         TXN_STAT,
         COD_REPLY,
         COD_SRL_TXT,
         FLG_VALUEDATE_PROCESSED,
         TXT_TXN_DESC,
         FLG_NTWKDATE_PROCESSED,
         NTWK_ACCT_STAT,
         CONTG_ACCT_STAT,
         FLG_CONTG_PROCESSED,
         COD_CTPARTY_ACCT,
         COD_CORRESP_AGENT,
         AMT_TOT_TCY)
      VALUES
        (VAR_L_COD_CC_BRN,
         11,
         VAR_L_COD_USERID,
         SYSDATE,
         VAR_L_CTR_BATCH_NO,
         VAR_L_STAN_NO,
         VAR_L_REF_SUBSEQ_NO,
         VAR_L_COD_PAYMENT_TXN,
         VAR_L_COD_TXN_MNEMONIC,
         VAR_L_DAT_POST,
         VAR_L_DAT_VALUE,
         VAR_L_COD_ACCT_NO,
         VAR_L_COD_CUST,
         VAR_L_COD_TXN_CCY,
         VAR_L_AMT_TXN_TCY,
         VAR_L_RAT_CONV_TCLCY,
         VAR_L_AMT_TXN_LCY,
         VAR_L_AMT_TXN_ACY,
         VAR_L_RAT_CONV_ACLCY,
         VAR_PI_PAYMENT_TXN_LOG.NETWORK_ID,
         VAR_PI_PAYMENT_TXN_LOG.NETWORK_REFERENCE_NO,
         VAR_L_REF_TXN_NO,
         --  pm_txn_log keeps the transaction reference here on both rate types
         VAR_L_REF_TXN_NO,
         VAR_L_PAY_DIR,
         VAR_L_ACCT_STAT,
         VAR_L_MSG_STAT,
         VAR_L_TXN_STAT,
         VAR_L_COD_REPLY,
         VAR_L_COD_SRL_TXT,
         VAR_L_FLG_VALUEDATE_PROCESSED,
         VAR_L_TXT_TXN_DESC,
         VAR_L_FLG_NTWKDATE_PROCESSED,
         VAR_L_NTWK_ACCT_STAT,
         VAR_L_CONTG_ACCT_STAT,
         VAR_L_FLG_CONTG_PROCESSED,
         VAR_PI_PAYMENT_TXN_LOG.COUNTER_PARTY_ACCOUNT_NO,
         VAR_PI_PAYMENT_TXN_LOG.CORRESP_AGENT_CODE,
         VAR_L_AMT_TOT_TCY);
    EXCEPTION
      WHEN OTHERS THEN
        PO_RESPONSE_CODE    := 1;
        PO_RESPONSE_MESSAGE := 'INSERTION FAILED (VWE_PM_TXN_LOG) ' ||
                               SQLERRM;
        RETURN 1;
    END;
  
    --INSERT DATA INTO RELATIONALTRANSACTIONSTORE
    BEGIN
      INSERT INTO PM_REL_TXN_STORE
        (REF_TXN_NO,
         COD_ORG_BRN,
         COD_ORG_BANK,
         COD_PAYMENT_TXN,
         COD_PKG_ID,
         COD_TXN_MNEMONIC,
         COD_TXN_INIT_BRN,
         COD_ACCT_TITLE,
         DAT_TRANSMISSION,
         COD_ORG_PROCESS,
         TXT_NARRATIVE,
         ORG_REF_NETWORK_NO,
         COD_CLG,
         TYPE_CLG,
         FLG_INTERNAL_CLG,
         COD_FRM_ZONE_ID,
         COD_FRM_CIRCLE_ID,
         COD_CTPARTY_ACCT,
         NAM_CTPARTY,
         NAM_CTPARTY_BANK,
         NAM_CTPARTY_BRANCH,
         COD_CTPARTY_ROUTING,
         TXT_CTPARTY_ADD1,
         TXT_CTPARTY_ADD2,
         COD_REASON,
         COD_STL_CCY,
         COD_TXN_INITIATOR_RESI_STAT,
         COD_FEE_COLL,
         COD_BI,
         NAM_CUST_SHRT,
         COD_SW_FCC_PRODUCT,
         COD_SW_CATEGORY_REMITTER,
         COD_SW_BIC_RECEIVER,
         TXT_CUSTADR_ADD1,
         TXT_CUSTADR_ADD2,
         TXT_CUSTADR_ADD3,
         TXT_CORRESP_AGENT_ADD1,
         TXT_CORRESP_AGENT_ADD2,
         NAM_CUST_BANK,
         TXT_CUST_BANK_ADD1,
         TXT_CUST_BANK_ADD2,
         TXT_CUST_BANK_ADD3,
         TXT_CUST_BANK_ADD4,
         NAM_REMITTER,
         PHONE_REMITTER,
         REMITTER_NATL_ID,
         COD_ORG_REMIT,
         ORG_REC_COD_ACCT_NO,
         COD_CTPARTY_IBAN,
         COD_SW_CATEGORY_RECEIVER,
         COD_SW_AFFILIATION,
         COD_SW_PURPOSE,
         COD_CTPARTY_COUNTRY,
         COD_CUST_COUNTRY,
         NAM_CUST_BRN,
         REF_SUBSEQ_NO,
         COD_ENTITY_VPD)
      VALUES
        (VAR_PI_REL_TXN_STORE.REFERENCE_NUMBER,
         VAR_L_COD_ORG_BRN,
         11,
         VAR_L_COD_PAYMENT_TXN,
         VAR_L_COD_PKG_ID,
         VAR_L_COD_TXN_MNEMONIC,
         VAR_PI_REL_TXN_STORE.INITIATION_BRANCH,
         VAR_PI_REL_TXN_STORE.ACCOUNT_TITLE,
         VAR_PI_REL_TXN_STORE.TRANSMISSION_DATE_TIME,
         VAR_L_COD_ORG_PROCESS,
         VAR_PI_REL_TXN_STORE.NARRATIVE,
         VAR_PI_REL_TXN_STORE.ORIGINALNETWORK_REFERENCE_NO,
         VAR_L_COD_CLG,
         VAR_L_TYPE_CLG,
         VAR_L_FLG_INTERNAL_CLG,
         VAR_L_COD_FRM_ZONE_ID,
         VAR_L_COD_FRM_CIRCLE_ID,
         VAR_PI_REL_TXN_STORE.DETAILS.COUNTER_PARTY_ACCOUNT_ID,
         VAR_PI_REL_TXN_STORE.DETAILS.COUNTER_PARTY_NAME,
         VAR_PI_REL_TXN_STORE.DETAILS.BANK_NAME,
         VAR_PI_REL_TXN_STORE.DETAILS.BRANCH,
         VAR_PI_REL_TXN_STORE.COUNTER_PARTY_ROUTING_CODE,
         VAR_PI_COUNTER_PARTY_DETAIL.ADDRESS_LINE_1,
         VAR_PI_COUNTER_PARTY_DETAIL.ADDRESS_LINE_2,
         VAR_PI_REL_TXN_STORE.REASON_CODE,
         VAR_PI_REL_TXN_STORE.SETTLEMENT_CCY_CODE,
         VAR_L_COD_TXN_INITIA_RESI_STAT,
         VAR_PI_REL_TXN_STORE.PM_CHARGES_FEE_CODE,
         VAR_PI_REL_TXN_STORE.BI_CODE,
         VAR_PI_REL_TXN_STORE.BENEFICIARY_NAME,
         VAR_PI_REL_TXN_STORE.FCC_PRODUCT_CODE,
         VAR_PI_REL_TXN_STORE.REMITTER_CATEGORY,
         VAR_PI_REL_TXN_STORE.RECEIVER_BIC_CODE,
         VAR_PI_REL_TXN_STORE.CUSTOMER_ADDRESS1,
         VAR_PI_REL_TXN_STORE.CUSTOMER_ADDRESS2,
         VAR_PI_REL_TXN_STORE.CUSTOMER_ADDRESS3,
         VAR_PI_REL_TXN_STORE.CORRESPONDENT_AGENT_ADDRESS1,
         VAR_PI_REL_TXN_STORE.CORRESPONDENT_AGENT_ADDRESS2,
         VAR_PI_REL_TXN_STORE.CUSTOMER_BANK_NAME,
         VAR_PI_REL_TXN_STORE.CUSTOMER_BANK_ADDRESS1,
         VAR_PI_REL_TXN_STORE.CUSTOMER_BANK_ADDRESS2,
         VAR_PI_REL_TXN_STORE.CUSTOMER_BANK_ADDRESS3,
         VAR_PI_REL_TXN_STORE.CUSTOMER_BANK_ADDRESS4,
         VAR_PI_REL_TXN_STORE.REMITTER_NAME,
         VAR_PI_REL_TXN_STORE.REMITTER_PHONE,
         VAR_PI_REL_TXN_STORE.REMITTER_NATL_ID,
         VAR_PI_REL_TXN_STORE.ORIGINAL_REMIT_NO,
         VAR_PI_REL_TXN_STORE.RECEIVER_ACCOUNT_NO,
         VAR_PI_REL_TXN_STORE.COUNTER_PARTY_IBAN_NO,
         VAR_PI_REL_TXN_STORE.RECEIVER_CATEGORY,
         VAR_PI_REL_TXN_STORE.AFFILIATION_CODE,
         TRIM(VAR_PI_REL_TXN_STORE.PURPOSE_CODE),
         VAR_PI_REL_TXN_STORE.COUNTERPARTY_COUNTRY_CODE,
         VAR_PI_REL_TXN_STORE.CUSTOMER_COUNTRY,
         VAR_PI_NAM_CUST_BRN,
         VAR_L_REF_SUBSEQ_NO,
         11);
    EXCEPTION
      WHEN OTHERS THEN
        PO_RESPONSE_CODE    := 1;
        PO_RESPONSE_MESSAGE := 'INSERTION FAILED (PM_REL_TXN_STORE)' ||
                               SQLERRM;
        RETURN 1;
    END;
  
    RETURN 0;
  END AP_SAVE_PAYMENT_LOG;

  FUNCTION GENERATE_FCC_CODE_AND_NOSTRO(IN_FCC_CODE_GENERATION_REC IN FCC_CODE_GENERATION_REC,
                                        OUT_FCC_PRODUCT_CODE       OUT VARCHAR2,
                                        PO_RESPONSE_CODE           OUT VARCHAR2,
                                        PO_RESPONSE_MESSAGE        OUT VARCHAR2)
    RETURN NUMBER IS
    VAR_TRANSACTION_TIME    VARCHAR(50);
    VAR_FCC_PRODUCT_CODE    VARCHAR(255);
    VAR_NOSTRO              VARCHAR(255);
    VAR_MAX_NOT             NUMBER;
    VAR_PRIORITY            NUMBER;
    VAR_POSSIBLE_NOSTRO_STR VARCHAR(2000);
    LST_ERR_MESSAGE         VARCHAR(4000);
    VAR_L_RETURN_VALUE      NUMBER;
  BEGIN
    --  the period of time is the configured window that contains the transaction time.
    --  Both halves of PERIOD_OF_TIME are maintained in 12-hour form, so each is converted
    --  before the comparison.
    BEGIN
      SELECT PERIOD_OF_TIME
        INTO VAR_TRANSACTION_TIME
        FROM (SELECT PERIOD_OF_TIME
                FROM (SELECT DISTINCT PERIOD_OF_TIME
                        FROM PM_SWIFT_NOSTRO_DISTR)
               WHERE IN_FCC_CODE_GENERATION_REC.TRANSACTION_TIME >=
                     TO_CHAR(TO_DATE(TRIM(SUBSTR(PERIOD_OF_TIME,
                                                 1,
                                                 INSTR(PERIOD_OF_TIME, '-') - 1)),
                                     'HH:MI:SS AM'),
                             'HH24:MI:SS')
                 AND IN_FCC_CODE_GENERATION_REC.TRANSACTION_TIME <=
                     TO_CHAR(TO_DATE(TRIM(SUBSTR(PERIOD_OF_TIME,
                                                 INSTR(PERIOD_OF_TIME, '-') + 1)),
                                     'HH:MI:SS AM'),
                             'HH24:MI:SS')
               ORDER BY PERIOD_OF_TIME)
       WHERE ROWNUM = 1;
    EXCEPTION
      WHEN OTHERS THEN
        PO_RESPONSE_CODE    := 'PM0060';
        PO_RESPONSE_MESSAGE := 'Error in generation of FCC Product Code';
        RETURN 1;
    END;
  
    --  the beneficiary bank BIC is tried first, then the correspondent; only when neither
    --  is maintained as a nostro for this window does the distribution logic decide
    BEGIN
      SELECT NOSTRO, FCC_PRODUCT_CODE, MAX_NOT, PRIORITY
        INTO VAR_NOSTRO, VAR_FCC_PRODUCT_CODE, VAR_MAX_NOT, VAR_PRIORITY
        FROM PM_SWIFT_NOSTRO_DISTR
       WHERE NOSTRO = TRIM(IN_FCC_CODE_GENERATION_REC.BANK_SWIFT_CODE)
         AND CCY = IN_FCC_CODE_GENERATION_REC.CCY_CODE
         AND CHARGE_BEARER = IN_FCC_CODE_GENERATION_REC.CHARGE_BEARER
         AND PERIOD_OF_TIME = VAR_TRANSACTION_TIME
         AND ROWNUM = 1;
    EXCEPTION
      WHEN OTHERS THEN
        VAR_NOSTRO := NULL;
    END;
  
    IF VAR_NOSTRO IS NULL AND
       TRIM(IN_FCC_CODE_GENERATION_REC.INT_INS_OR_BEN_CORR_BIC_CODE) IS NOT NULL THEN
      BEGIN
        SELECT NOSTRO, FCC_PRODUCT_CODE, MAX_NOT, PRIORITY
          INTO VAR_NOSTRO, VAR_FCC_PRODUCT_CODE, VAR_MAX_NOT, VAR_PRIORITY
          FROM PM_SWIFT_NOSTRO_DISTR
         WHERE NOSTRO =
               TRIM(IN_FCC_CODE_GENERATION_REC.INT_INS_OR_BEN_CORR_BIC_CODE)
           AND CCY = IN_FCC_CODE_GENERATION_REC.CCY_CODE
           AND CHARGE_BEARER = IN_FCC_CODE_GENERATION_REC.CHARGE_BEARER
           AND PERIOD_OF_TIME = VAR_TRANSACTION_TIME
           AND ROWNUM = 1;
      EXCEPTION
        WHEN OTHERS THEN
          VAR_NOSTRO := NULL;
      END;
    END IF;
  
    --  distribution: a nostro not yet used today comes first, then the lowest CYCLE,
    --  then the lowest CURRENT_NOT, then the lowest PRIORITY
    IF VAR_NOSTRO IS NULL THEN
      BEGIN
        SELECT NOSTRO, FCC_PRODUCT_CODE, MAX_NOT, PRIORITY
          INTO VAR_NOSTRO, VAR_FCC_PRODUCT_CODE, VAR_MAX_NOT, VAR_PRIORITY
          FROM (SELECT D.NOSTRO, D.FCC_PRODUCT_CODE, D.MAX_NOT, D.PRIORITY
                  FROM PM_SWIFT_NOSTRO_DISTR D
                  LEFT JOIN PM_SWIFT_TXN_LOG L ON L.NOSTRO = D.NOSTRO
                                              AND L.CHARGE_BEARER =
                                                  D.CHARGE_BEARER
                                              AND L.CCY = D.CCY
                                              AND L.PERIOD_OF_TIME =
                                                  D.PERIOD_OF_TIME
                                              AND L.TRANSACTION_DATE =
                                                  IN_FCC_CODE_GENERATION_REC.TRANSACTION_DATE
                 WHERE D.FLG_EXCLUDE = 'I'
                   AND D.CCY = IN_FCC_CODE_GENERATION_REC.CCY_CODE
                   AND D.CHARGE_BEARER =
                       IN_FCC_CODE_GENERATION_REC.CHARGE_BEARER
                   AND D.PERIOD_OF_TIME = VAR_TRANSACTION_TIME
                 ORDER BY NVL(L.CYCLE, -1),
                          NVL(L.CURRENT_NOT, -1),
                          D.PRIORITY)
         WHERE ROWNUM = 1;
      EXCEPTION
        WHEN OTHERS THEN
          PO_RESPONSE_CODE    := 'PM0060';
          PO_RESPONSE_MESSAGE := 'Error in generation of FCC Product Code';
          RETURN 1;
      END;
    END IF;
  
    --  the throughput log keys on the bare nostro; a composite value here would never
    --  match an existing counter row and the rotation would stall on one account
    VAR_POSSIBLE_NOSTRO_STR := TRIM(VAR_NOSTRO);
  
    BEGIN
      VAR_L_RETURN_VALUE := AP_PM_LOG_SWIFT_TRANSACTION(VAR_POSSIBLE_NOSTRO_STR,
                                                        IN_FCC_CODE_GENERATION_REC.CHARGE_BEARER,
                                                        IN_FCC_CODE_GENERATION_REC.CCY_CODE,
                                                        IN_FCC_CODE_GENERATION_REC.TRANSACTION_DATE,
                                                        VAR_MAX_NOT,
                                                        VAR_PRIORITY,
                                                        IN_FCC_CODE_GENERATION_REC.TRANSACTION_AMOUNT,
                                                        VAR_TRANSACTION_TIME,
                                                        LST_ERR_MESSAGE);
    EXCEPTION
      WHEN OTHERS THEN
        --  a throughput-log failure never rejects the payment; only the next
        --  nostro selection is affected
        NULL;
    END;
  
    OUT_FCC_PRODUCT_CODE := VAR_FCC_PRODUCT_CODE;
  
    RETURN 0;
  EXCEPTION
    WHEN OTHERS THEN
      PO_RESPONSE_CODE    := 'PM0060';
      PO_RESPONSE_MESSAGE := 'Error in generation of FCC Product Code';
      RETURN 1;
  END GENERATE_FCC_CODE_AND_NOSTRO;

  FUNCTION AP_OL_CALL_CH_WDR(VAR_PI_CHANNEL_ID              IN VARCHAR2,
                             VAR_PI_SVC_CODE                IN VARCHAR2,
                             VAR_PI_DAT_TXN                 IN NUMBER,
                             VAR_PI_COD_ORG_BRN             IN NUMBER,
                             VAR_PI_REF_SUBSEQ_NO           IN NUMBER,
                             VAR_PI_MSG_TYPE                IN NUMBER,
                             VAR_PI_REF_TXN_NO              IN VARCHAR2,
                             VAR_PI_SVC_RQ_ID               IN VARCHAR2,
                             VAR_PI_COD_USER_ID             IN VARCHAR2,
                             VAR_PI_COD_USERNO              IN NUMBER,
                             VAR_PI_STAN_NO                 IN NUMBER,
                             VAR_PI_COD_PROC                IN NUMBER,
                             VAR_PI_COD_ACCT_NO_F           IN VARCHAR2,
                             VAR_PI_COD_CC_BRN_F            IN NUMBER,
                             VAR_PI_ACCT_CUR_F              IN VARCHAR2,
                             VAR_PI_XFER_CUR                IN VARCHAR2, --NAF
                             VAR_PI_COD_PROD_F              IN NUMBER,
                             VAR_PI_BAL_LST_PSBK_F          IN NUMBER,
                             VAR_PI_CTR_PSBK_LINE_NO_F      IN NUMBER,
                             VAR_PI_TXN_CUR                 IN VARCHAR2,
                             VAR_PI_COD_ACCT_NO_T           IN VARCHAR2,
                             VAR_PI_AMT_TXN_LCY             IN NUMBER,
                             VAR_PI_AMT_TXN_TCY             IN NUMBER,
                             VAR_PI_AMT_TXN_ACY             IN NUMBER,
                             VAR_PI_AMT_TXN_OTHER_ACY       IN NUMBER,
                             VAR_PI_TXN_CCY_CONV_RATE       IN NUMBER,
                             VAR_PI_ACCT_CCY_CONV_RATE      IN NUMBER,
                             VAR_PI_COD_TXN_MNEMONIC        IN VARCHAR2,
                             VAR_PI_COD_TXN                 IN VARCHAR2,
                             VAR_PI_NARRATIVE               IN VARCHAR2,
                             VAR_PI_COD_TASK_LITERAL_DERIVE IN VARCHAR2,
                             VAR_PI_COD_ORG_MSG_TYP         IN NUMBER,
                             VAR_PI_REF_ORG_STAN            IN NUMBER,
                             VAR_PI_REF_ORG_SUBSEQ_NO       IN NUMBER,
                             VAR_PI_DAT_ORG_TXN             IN NUMBER,
                             VAR_PI_CTR_YR_ORG_TXN          IN NUMBER,
                             VAR_PI_DAT_ORG_POST            IN NUMBER,
                             VAR_PI_CTR_YR_ORG_POST         IN NUMBER,
                             VAR_PO_COD_EXT                 IN OUT VARCHAR2,
                             VAR_PO_COD_REPLY               IN OUT NUMBER,
                             VAR_PO_USN                     IN OUT NUMBER,
                             VAR_PO_RESPONSE_CODE           OUT VARCHAR2,
                             VAR_PO_RESPONSE_MESSAGE        OUT VARCHAR2)
    RETURN NUMBER IS
    VAR_L_RETURN_VAL           NUMBER := 1;
    VAR_L_COD_ACCT_NO_F        VARCHAR2(16) := RPAD(VAR_PI_COD_ACCT_NO_F,
                                                    16,
                                                    ' ');
    VAR_L_COD_ACCT_NO_T        VARCHAR2(16) := RPAD(VAR_PI_COD_ACCT_NO_T,
                                                    16,
                                                    ' ');
    VAR_L_DAT_PROCESS          BA_BANK_MAST.DAT_PROCESS%TYPE := PK_BA_GLOBAL.DAT_PROCESS;
    VAR_L_DAT_TXN              NUMBER := SUBSTR(VAR_PI_DAT_TXN, 5, 10);
    VAR_L_BATCH_NO             NUMBER(10) := 2; --SEQ_BATCH_NO_NGI.NEXTVAL;
    VAR_L_DAT_LOCALTIM         NUMBER := TO_CHAR(SYSDATE, 'HH24MISS');
    VAR_L_DAT_LOCAL            NUMBER := TO_CHAR(SYSDATE, 'MMDD');
    VAR_L_CTR_YR_LOCAL         NUMBER := TO_CHAR(SYSDATE, 'YYYY');
    VAR_L_DAT_POST_DUM         NUMBER := LPAD(DATEPART('MM',
                                                       VAR_L_DAT_PROCESS),
                                              2,
                                              '0') ||
                                         LPAD(DATEPART('DD',
                                                       VAR_L_DAT_PROCESS),
                                              2,
                                              '0');
    VAR_L_CTR_YR_POST_DUM      NUMBER := TO_CHAR(VAR_L_DAT_PROCESS, 'YYYY');
    VAR_L_DAT_VALUE_DUM        NUMBER := TO_CHAR(VAR_L_DAT_PROCESS, 'MMDD');
    VAR_L_CTR_YR_VALUE_DUM     NUMBER := TO_CHAR(VAR_L_DAT_PROCESS, 'YYYY');
    VAR_L_STL_PROC_CODE        NUMBER := 4; -- K: 4   NAF
    VAR_L_TXT_MEMO             VARCHAR2(250);
    var_L_nam_cust_shrt        VARCHAR2(250);
    var_L_amt_avail            NUMBER;
    var_L_amt_hld              NUMBER;
    var_L_amt_unclr            NUMBER;
    var_L_amt_auth_dr          NUMBER;
    var_L_amt_excp             NUMBER;
    var_L_amt_excp_typ         NUMBER := 0; --NAF: was not declared
    var_L_amt_to_pay           NUMBER;
    var_L_amt_penalty          NUMBER;
    var_L_amt_outstanding      NUMBER;
    var_L_amt_instal_arrears   NUMBER;
    var_L_amt_arrears_charges  NUMBER;
    var_L_amt_penalty_interest NUMBER;
    var_L_acct_oper_usn        NUMBER := 0; --K: WAS NOT DECLARE
    VAR_L_COD_DEP_NO           NUMBER := 0; --K: WAS NOT DECLARE
    VAR_L_PAYOUT_TO_DEP_NO     VARCHAR2(16) := '0'; --K: WAS NOT DECLARE
    VAR_L_PAYOUT_ACCT_NO       VARCHAR2(16);
    VAR_L_REDEM_TO_DEP_NO      NUMBER := 0; -- K: WAS NOT DECLARE
    VAR_L_REDEM_ACCT_NO        VARCHAR2(16);
    VAR_L_TXT_INDEMNITY        VARCHAR2(16);
    --  AP_OL_CH_WDR waives a condition only when the flag is on and the code is already
    --  in VAR_O_COD_EXT, where each code must sit as exactly three characters
    VAR_L_FLG_OVERRIDE_DUM NUMBER := 1;
  
    -----------
    SUBTYPE T_STRING_LIST IS DBMS_SQL.VARCHAR2A;
  
    VAR_L_ADDED_WORDS            t_string_list;
    VAR_L_ORG_WORDS              t_string_list;
    VAR_L_EXT_STRING             t_string_list;
    VAR_L_COD_REPLY              NUMBER := 0;
    VAR_L_REPLY_CODE             NUMBER := 0;
    VAR_L_ORIGINAL_MEMO          VARCHAR2(250) := NULL;
    VAR_L_ORIGINAL_RESPONSE_CODE NUMBER := NULL;
    VAR_L_ORG_EXTENDED_RESP      VARCHAR2(20) := NULL;
    VAR_L_EXT_RESPONSE           VARCHAR2(20) := NULL;
    VAR_L_PADDED_EXT_RESP        VARCHAR2(10);
    VAR_L_ORG_COD_REPLY          NUMBER;
    VAR_L_CUR_COD_REPLY          NUMBER;
    VAR_L_VAILD_REPEAT_RESP_FLG  BOOLEAN;
    VAR_L_CUR_EXT_RESP           VARCHAR2(20) := NULL;
    VAR_L_ADDED_RESPONSE         VARCHAR2(20) := NULL;
    VAR_L_REPEAT                 BOOLEAN := TRUE;
    VAR_L_RESULT                 NUMBER := 0;
    VAR_L_COUNTER                NUMBER := 0;
    VAR_L_RET_CODE_CHK_EXT_RESP  NUMBER := 1;
    VAR_O_ACCT_OPER_USN          NUMBER := 0; --NAF
    VAR_L_COD_EXT                VARCHAR(100) := '0 ,';
    VAR_O_COD_EXT_OVERWRITE      VARCHAR2(100) := NULL;
  BEGIN
    --  codes this service may override; no row means none
    BEGIN
      SELECT RTRIM(OVERRIDEN_CODES)
        INTO VAR_L_COD_EXT
        FROM NGI_OVERRIDE_SCORES
       WHERE NGI_SERVICE = VAR_PI_SVC_CODE
         AND NAM_FUNCTION = 'AP_OL_CH_WDR'
         AND FLG_MNT_STATUS = 'A';
    EXCEPTION
      WHEN OTHERS THEN
        VAR_L_COD_EXT := NULL;
    END;
  
    --  the call returns its extended response in the same variable, so keep the list
    VAR_O_COD_EXT_OVERWRITE := VAR_L_COD_EXT;
  
    BEGIN
      VAR_L_RETURN_VAL := AP_OL_CH_WDR(VAR_DAT_LOG                    => VAR_L_DAT_PROCESS,
                                       VAR_DAT_TXN                    => VAR_PI_DAT_TXN,
                                       VAR_CTR_YR_TXN_DUM             => TO_CHAR(SYSDATE,
                                                                                 'YYYY'),
                                       VAR_COD_ORG_BRN                => VAR_PI_COD_ORG_BRN,
                                       VAR_COD_USERNO                 => VAR_PI_COD_USERNO,
                                       VAR_COD_AUTHNO_DUM             => 0,
                                       VAR_CTR_BATCH_NO               => VAR_L_BATCH_NO,
                                       VAR_REF_SYS_TR_AUD_NO_DUM      => VAR_PI_STAN_NO,
                                       VAR_REF_SUBSEQ_NO              => VAR_PI_REF_SUBSEQ_NO,
                                       VAR_COD_MSG_TYP                => VAR_PI_MSG_TYPE,
                                       VAR_COD_ACCT_NO_DUM            => VAR_L_COD_ACCT_NO_F,
                                       VAR_COD_TXN_CCY_DUM            => VAR_PI_TXN_CUR,
                                       VAR_COD_ACC_CCY_DUM            => VAR_PI_ACCT_CUR_F,
                                       VAR_COD_OTHER_ACC_CCY_DUM      => VAR_PI_ACCT_CUR_F,
                                       VAR_COD_PROC_DUM               => VAR_PI_COD_PROC,
                                       VAR_AMT_TXN_LCY_DUM            => VAR_PI_AMT_TXN_LCY,
                                       VAR_AMT_TXN_TCY_DUM            => VAR_PI_AMT_TXN_TCY,
                                       VAR_AMT_TXN_ACY_DUM            => VAR_PI_AMT_TXN_ACY,
                                       VAR_AMT_TXN_OTHER_ACY_DUM      => VAR_PI_AMT_TXN_ACY,
                                       VAR_RAT_CONV_TCLCY_DUM         => VAR_PI_TXN_CCY_CONV_RATE,
                                       VAR_RAT_CONV_ACLCY_DUM         => VAR_PI_ACCT_CCY_CONV_RATE,
                                       VAR_RAT_CONV_OTHER_ACLCY_DUM   => 0,
                                       VAR_FLG_TCY_CONV               => 0,
                                       VAR_FLG_ACY_CONV               => 0,
                                       VAR_DAT_LOCALTIM               => VAR_L_DAT_LOCALTIM,
                                       VAR_DAT_LOCAL                  => VAR_L_DAT_LOCAL,
                                       VAR_CTR_YR_LOCAL               => VAR_L_CTR_YR_LOCAL,
                                       VAR_DAT_POST_DUM               => VAR_L_DAT_POST_DUM,
                                       VAR_CTR_YR_POST_DUM            => VAR_L_CTR_YR_POST_DUM,
                                       VAR_DAT_VALUE_DUM              => VAR_L_DAT_VALUE_DUM,
                                       VAR_CTR_YR_VALUE_DUM           => VAR_L_CTR_YR_VALUE_DUM,
                                       VAR_FLG_OVERRIDE_DUM           => VAR_L_FLG_OVERRIDE_DUM,
                                       VAR_REF_DOC_NO_DUM             => NULL,
                                       VAR_COD_FND_ACCT_NO            => VAR_L_COD_ACCT_NO_F,
                                       VAR_COD_SOURCE_LO_DUM          => 1,
                                       VAR_COD_DEST_LO_DUM            => 0,
                                       VAR_REF_INSTR_TYP_DUM          => NULL,
                                       VAR_REF_FUND_TYP_DUM           => 1,
                                       VAR_COD_ROUTING_NO_DUM         => 0,
                                       VAR_COD_INSTR_ACCT_NO_DUM      => NULL,
                                       VAR_REF_INSTR_NO_STR_DUM       => NULL,
                                       VAR_REF_INSTR_NO_END           => NULL,
                                       VAR_COD_INSTR_ISSUER_DUM       => 0,
                                       VAR_NO_OF_INSTRS_DUM           => 0,
                                       VAR_COD_BANK_CORRESP_INSTR_DUM => 0,
                                       VAR_COD_DRAWEE_BANK_INSTR_DUM  => NULL,
                                       VAR_COD_FLOAT_INSTR_DUM        => '000',
                                       VAR_COD_END_POINT_DUM          => 0,
                                       VAR_COD_CLG_BRN_DUM            => 0,
                                       VAR_NAM_BENEF                  => NULL,
                                       VAR_TXT_BENEF_ADDR1            => NULL,
                                       VAR_TXT_BENEF_ADDR2            => NULL,
                                       VAR_TXT_BENEF_ADDR3            => NULL,
                                       VAR_COD_CUST_NATL_ID           => NULL,
                                       VAR_TXN_COD                    => 0,
                                       VAR_COD_ACCT_BENEF             => NULL,
                                       VAR_FLG_ROUTE                  => NULL,
                                       VAR_FLG_BENEF_ID               => NULL,
                                       VAR_NAM_ORDER_CUST             => NULL,
                                       VAR_COD_OPT_CHARGES            => NULL,
                                       VAR_TYP_ADVICE                 => 0,
                                       VAR_TXT_ACCT_DIRECT_INSTRS1    => NULL,
                                       VAR_TXT_ACCT_DIRECT_INSTRS2    => NULL,
                                       VAR_TXT_ACCT_DIRECT_INSTRS3    => NULL,
                                       VAR_TXT_ACCT_DIRECT_INSTRS4    => NULL,
                                       VAR_NAM_AGENT_NEAR_BRN         => NULL,
                                       VAR_NAM_BANK                   => NULL,
                                       VAR_TXT_BANK_ADD1              => NULL,
                                       VAR_TXT_BANK_ADD2              => NULL,
                                       VAR_TXT_BANK_ADD3              => NULL,
                                       VAR_AMT_REPL_TCY_DUM           => 0.0,
                                       VAR_AMT_REPL_LCY_DUM           => 0.0,
                                       VAR_AMT_REPL_ACY_DUM           => 0.0,
                                       VAR_AMT_TXN_FROM_ACY_DUM       => NULL,
                                       VAR_AMT_TXN_TO_ACY_DUM         => NULL,
                                       VAR_DAT_INSTR_DUM              => VAR_L_DAT_POST_DUM,
                                       VAR_CTR_YR_INSTR_DUM           => VAR_L_CTR_YR_POST_DUM,
                                       VAR_COD_CCY_INSTR_DUM          => VAR_PI_XFER_CUR,
                                       VAR_AMT_INSTR_DUM              => 0,
                                       VAR_DAT_INSTR_VALUE_DUM        => VAR_L_DAT_POST_DUM,
                                       VAR_CTR_YR_INSTR_VALUE_DUM     => VAR_L_CTR_YR_POST_DUM,
                                       VAR_DAT_DEL_INSTR              => VAR_L_DAT_POST_DUM,
                                       VAR_CTR_YR_DEL_INSTR           => VAR_L_CTR_YR_POST_DUM,
                                       VAR_COD_TXN_MNEMONIC_DUM       => VAR_PI_COD_TXN_MNEMONIC,
                                       VAR_COD_ORG_MSG_TYP_DUM        => VAR_PI_COD_ORG_MSG_TYP,
                                       VAR_REF_ORG_STAN_DUM           => VAR_PI_REF_ORG_STAN,
                                       VAR_REF_ORG_SUBSEQ_NO_DUM      => VAR_PI_REF_ORG_SUBSEQ_NO,
                                       VAR_DAT_ORG_TXN_DUM            => VAR_PI_DAT_ORG_TXN,
                                       VAR_CTR_YR_ORG_TXN_DUM         => VAR_PI_CTR_YR_ORG_TXN,
                                       VAR_DAT_ORG_POST_DUM           => VAR_PI_DAT_ORG_POST,
                                       VAR_CTR_YR_ORG_POST_DUM        => VAR_PI_CTR_YR_ORG_POST,
                                       VAR_COD_USER_ACCESS_DUM        => 90,
                                       VAR_COD_FROM_ACCT_NO_DUM       => NULL,
                                       VAR_COD_TO_ACCT_NO_DUM         => NULL,
                                       VAR_FLG_PSBK_BAL               => 'N',
                                       VAR_BAL_PASSBOOK               => VAR_PI_BAL_LST_PSBK_F,
                                       VAR_LINE_NO_PSBK               => VAR_PI_CTR_PSBK_LINE_NO_F,
                                       VAR_FLG_SC_OPTION_DUM          => NULL,
                                       VAR_TXT_TXNDESC_DUM            => VAR_PI_NARRATIVE,
                                       VAR_COD_TXN_LITERAL_DUM        => VAR_PI_COD_TASK_LITERAL_DERIVE,
                                       VAR_COD_CUST1                  => 0,
                                       VAR_COD_CUST2                  => 0,
                                       VAR_COD_CUST3                  => 0,
                                       VAR_COD_CUST4                  => 0,
                                       VAR_COD_CUST5                  => 0,
                                       VAR_COD_CUST6                  => 0,
                                       VAR_COD_CC_BRN_DUM             => VAR_PI_COD_CC_BRN_F,
                                       VAR_COD_PROD_DUM               => VAR_PI_COD_PROD_F, -- 422,
                                       VAR_COD_FROM_CC_BRN_DUM        => 0,
                                       VAR_COD_TO_CC_BRN_DUM          => 0,
                                       VAR_COD_NFW_ACCT               => VAR_L_COD_ACCT_NO_F,
                                       VAR_COD_NFW_BRN                => VAR_PI_COD_CC_BRN_F,
                                       VAR_BAL_PRINCIPAL_REN          => NULL,
                                       VAR_BAL_POSTMAT_INT_REN        => NULL,
                                       VAR_TAX_WITHHELD_REN           => 0,
                                       VAR_CTR_RENEW_TERM_REN         => 0,
                                       VAR_RAT_RENEWAL_REN            => 0.0,
                                       VAR_RAT_TAX_REN                => 0,
                                       VAR_RAT_INT_EXP_REN            => 0.0,
                                       VAR_DAT_MAT_YYYY_REN           => VAR_L_CTR_YR_POST_DUM,
                                       VAR_DAT_MAT_MMDD_REN           => VAR_L_DAT_POST_DUM,
                                       VAR_COD_INT_INDX_REN           => 0,
                                       VAR_RAT_INT_REN                => 0.0,
                                       VAR_RAT_INT_VAR_REN            => 0.0,
                                       VAR_FLG_MODE_RED_DUM           => 0,
                                       VAR_FLG_REVERSE_INT_RED        => NULL,
                                       VAR_FLG_CLOSE_DEP_RED          => NULL,
                                       VAR_BAL_PRINCIPAL_RED          => NULL,
                                       VAR_AMT_REDEEM_RED             => NULL,
                                       VAR_AMT_PMI_RED_DUM            => NULL,
                                       VAR_AMT_PENALTY_RED            => NULL,
                                       VAR_AMT_INT_DEDUCT_RED         => NULL,
                                       VAR_AMT_TDS_ACY_RED            => NULL,
                                       VAR_AMT_SERV_CHG_RED           => NULL,
                                       VAR_AMT_NET_PROC_RED           => NULL,
                                       VAR_COD_ACCT_STAT_RED          => 0,
                                       VAR_RAT_CONV_EXPENSE_RED       => 0.0,
                                       VAR_RAT_CONV_ACCRUAL_RED       => 0.0,
                                       VAR_RAT_TDS_ACLCY_RED          => 0,
                                       VAR_RAT_CONV_REG_DEP_RED       => 0.0,
                                       VAR_RAT_CONV_SC_RED            => 0,
                                       VAR_P_RSV_PRV_BUF_2            => NULL,
                                       VAR_P_AMT_PMI                  => NULL,
                                       VAR_P_AMT_PEN_INT              => NULL,
                                       VAR_P_COD_PROD                 => VAR_PI_COD_PROD_F, -- 422,
                                       PI_COD_LCY                     => 0,
                                       VAR_P_STL_COD_PROCESS_DUM      => VAR_L_STL_PROC_CODE,
                                       VAR_P_FLG_DRCR                 => 'D',
                                       VAR_P_COD_USER_ID              => VAR_PI_COD_USER_ID,
                                       VAR_P_COD_AUTH_ID              => NULL,
                                       VAR_COD_ACCT_MAINT_MODE_DUM    => NULL,
                                       VAR_MAKER_ID                   => VAR_PI_COD_USER_ID,
                                       VAR_CHECKER_ID                 => NULL,
                                       VAR_COD_MODULE                 => 'CH',
                                       VAR_TXT_ACCT_OPER_INSTRS1      => NULL,
                                       VAR_TXT_ACCT_OPER_INSTRS2      => NULL,
                                       VAR_REF_TXN_NO                 => VAR_PI_REF_TXN_NO,
                                       VAR_REF_USR_NO                 => VAR_PI_SVC_RQ_ID,
                                       VAR_CONSUMER_NO_DUM            => NULL,
                                       VAR_REF_NO1_DUM                => NULL,
                                       VAR_REF_NO2_DUM                => NULL,
                                       VAR_DAT_BILL_DUM               => 0,
                                       VAR_CTR_YR_BILL_DUM            => 0,
                                       VAR_O_COD_REPLY                => VAR_PO_COD_REPLY,
                                       VAR_O_COD_EXT                  => VAR_L_COD_EXT,
                                       VAR_O_TXT_MEMO                 => VAR_L_TXT_MEMO,
                                       VAR_O_NAM_CUST_SHRT            => VAR_L_NAM_CUST_SHRT,
                                       VAR_O_AMT_AVAIL                => VAR_L_AMT_AVAIL,
                                       VAR_O_AMT_HLD                  => VAR_L_AMT_HLD,
                                       VAR_O_AMT_UNCLR                => VAR_L_AMT_UNCLR,
                                       VAR_O_AMT_AUTH_DR              => VAR_L_AMT_AUTH_DR,
                                       VAR_O_AMT_EXCP                 => VAR_L_AMT_EXCP,
                                       VAR_O_AMT_EXCP_TYP             => VAR_L_AMT_EXCP_TYP,
                                       VAR_O_USN                      => VAR_PO_USN,
                                       VAR_AMT_TO_PAY                 => VAR_L_AMT_TO_PAY,
                                       VAR_AMT_PENALTY                => VAR_L_AMT_PENALTY,
                                       VAR_AMT_OUTSTANDING            => VAR_L_AMT_OUTSTANDING,
                                       VAR_AMT_INSTAL_ARREARS         => VAR_L_AMT_INSTAL_ARREARS,
                                       VAR_AMT_ARREARS_CHARGES        => VAR_L_AMT_ARREARS_CHARGES,
                                       VAR_AMT_PENALTY_INTEREST       => VAR_L_AMT_PENALTY_INTEREST,
                                       VAR_O_ACCT_OPER_USN            => VAR_O_ACCT_OPER_USN,
                                       VAR_P_CARD_DATA                => NULL,
                                       VAR_P_COD_SC                   => NULL,
                                       VAR_P_FLG_BASE_RATE            => NULL,
                                       VAR_P_DEP_TERM                 => 0,
                                       VAR_RAT_INT_PROD               => 0.0,
                                       VAR_INT_PAY_FRQ                => NULL,
                                       VAR_INT_COMP_FRQ               => NULL,
                                       VAR_DAT_MATURITY               => NULL,
                                       VAR_DAT_START                  => NULL,
                                       VAR_COD_INT_INDX               => 0,
                                       VAR_RAT_INT                    => 0.0,
                                       VAR_RAT_INT_VAR                => 0.0,
                                       VAR_COD_DEP_NO                 => VAR_L_COD_DEP_NO,
                                       VAR_RENEW_PMI_INT              => 0,
                                       VAR_RENEW_PMI_PRIN             => 0,
                                       VAR_RENEW_COMP_FREQ            => 0,
                                       VAR_RENEW_PAY_FREQ             => 0,
                                       VAR_RENEW_FLG_BASE_RATE        => NULL,
                                       VAR_RENEW_DEP_NO               => 0,
                                       VAR_REDEM_UNCOLL_PRIN          => 0,
                                       VAR_REDEM_UNCOLL_INT           => 0,
                                       VAR_REDEM_DEP_NO               => 0,
                                       VAR_PAYOUT_AMT                 => NULL,
                                       VAR_PAYOUT_DEP_NO              => 0,
                                       VAR_AMT_TXN_ACY_SC             => NULL,
                                       VAR_AMT_TXN_LCY_SC             => NULL,
                                       VAR_AMT_TXN_TCY_SC             => NULL,
                                       VAR_COD_TXN_MNEMONIC_SC        => 0,
                                       VAR_AMT_SC_ACY_ORG             => NULL,
                                       VAR_PAYOUT_BASE_RATE           => NULL,
                                       VAR_PAYOUT_DEP_TERM            => 0,
                                       VAR_PAYOUT_INT_PAY_FREQ        => NULL,
                                       VAR_PAYOUT_INT_COMP_FREQ       => NULL,
                                       VAR_PAYOUT_VAL_DATE            => NULL,
                                       VAR_PAYOUT_START_DATE          => NULL,
                                       VAR_PAYOUT_PROD_CODE           => 0,
                                       VAR_PAYOUT_TO_DEP_NO           => VAR_L_PAYOUT_TO_DEP_NO,
                                       VAR_PAYOUT_ACCT_NO             => VAR_L_PAYOUT_ACCT_NO,
                                       VAR_REDEM_BASE_RATE            => NULL,
                                       VAR_REDEM_DEP_TERM             => 0,
                                       VAR_REDEM_INT_PAY_FREQ         => NULL,
                                       VAR_REDEM_INT_COMP_FREQ        => NULL,
                                       VAR_REDEM_VAL_DATE             => NULL,
                                       VAR_REDEM_START_DATE           => NULL,
                                       VAR_REDEM_PROD_CODE            => 0,
                                       VAR_REDEM_TO_DEP_NO            => VAR_L_REDEM_TO_DEP_NO,
                                       VAR_REDEM_ACCT_NO              => VAR_L_REDEM_ACCT_NO,
                                       VAR_TXT_INDEMNITY              => VAR_L_TXT_INDEMNITY,
                                       VAR_COD_LCY_SRC                => 0,
                                       VAR_COD_LCY_DEST               => 0,
                                       VAR_AMT_TXN_LCY_SRC            => NULL, --K: 0
                                       VAR_AMT_TXN_LCY_DEST           => NULL, --K: 0
                                       VAR_CTR_SUBSIDY_TERM           => 0,
                                       FLG_RD_PAYMENT_MODE            => 0);
    
      VAR_PO_COD_EXT := VAR_L_COD_EXT;
    
      --  anything the host reported that is not on the list becomes the response
      VAR_L_RET_CODE_CHK_EXT_RESP := AP_OL_CHECK_EXT_RESP_NGI(PI_INPUT_STR        => VAR_L_COD_EXT,
                                                              PI_OVERWRITE_STR    => VAR_O_COD_EXT_OVERWRITE,
                                                              PO_RESPONSE_CODE    => VAR_PO_RESPONSE_CODE,
                                                              PO_RESPONSE_MESSAGE => VAR_PO_RESPONSE_MESSAGE);
    
      IF VAR_PO_RESPONSE_CODE IS NOT NULL THEN
        RETURN 1;
      END IF;
    
      IF VAR_L_RETURN_VAL <> 0 THEN
        --  refused without an extended code: hand back the host's own reply code
        VAR_PO_RESPONSE_CODE := LPAD(NVL(VAR_PO_COD_REPLY, 2440), 7, '0');
        RETURN 1;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        VAR_PO_RESPONSE_CODE    := 1210;
        VAR_PO_RESPONSE_MESSAGE := 'Exception occured while executing the Function AP_OL_CH_WDR';
        RETURN 1;
    END;
  
    RETURN 0;
  END AP_OL_CALL_CH_WDR;

  FUNCTION AP_OL_CALL_GL_TXNS(VAR_PI_DAT_TXN                 IN NUMBER,
                              VAR_PI_COD_ORG_BRN             IN NUMBER,
                              VAR_PI_COD_CC_BRN              IN NUMBER,
                              VAR_PI_REF_SUBSEQ_NO           IN NUMBER,
                              VAR_PI_REF_TXN_NO              IN VARCHAR2,
                              VAR_PI_SVC_RQ_ID               IN VARCHAR2,
                              VAR_PI_COD_USER_ID             IN VARCHAR2,
                              VAR_PI_COD_USERNO              IN NUMBER,
                              VAR_PI_STAN_NO                 IN NUMBER,
                              VAR_PI_COD_ACCT_NO             IN VARCHAR2,
                              VAR_PI_COD_ACCT_NO_DUM_GL      IN VARCHAR2,
                              VAR_PI_TXN_CUR                 IN NUMBER,
                              VAR_PI_ACCT_CUR                IN NUMBER,
                              VAR_PI_COD_PROD                IN NUMBER,
                              VAR_PI_COD_PROC                IN NUMBER,
                              VAR_PI_AMT_TXN_LCY             IN NUMBER,
                              VAR_PI_AMT_TXN_TCY             IN NUMBER,
                              VAR_PI_AMT_TXN_ACY             IN NUMBER,
                              VAR_PI_TXN_CCY_CONV_RATE       IN NUMBER,
                              VAR_PI_ACCT_CCY_CONV_RATE      IN NUMBER,
                              VAR_PI_FLG_OVERRIDE_DUM        IN NUMBER,
                              VAR_PI_COD_TXN_MNEMONIC        IN NUMBER,
                              VAR_PI_TXNDESC1                IN VARCHAR2,
                              VAR_PI_TXNDESC2                IN VARCHAR2,
                              VAR_PI_COD_TASK_LITERAL_DERIVE IN VARCHAR2,
                              VAR_PI_FLG_DRCR                IN VARCHAR2,
                              VAR_PI_COD_ORG_MSG_TYP         IN NUMBER,
                              VAR_PI_REF_ORG_STAN            IN NUMBER,
                              VAR_PI_REF_ORG_SUBSEQ_NO       IN NUMBER,
                              VAR_PI_DAT_ORG_TXN             IN NUMBER,
                              VAR_PI_CTR_YR_ORG_TXN          IN NUMBER,
                              VAR_PI_DAT_ORG_POST            IN NUMBER,
                              VAR_PI_CTR_YR_ORG_POST         IN NUMBER,
                              VAR_PO_COD_EXT                 IN OUT VARCHAR2,
                              VAR_PO_COD_REPLY               IN OUT NUMBER,
                              VAR_PO_USN                     IN OUT NUMBER,
                              VAR_PI_XFEE_AMT                IN NUMBER,
                              VAR_PO_RESPONSE_CODE           OUT VARCHAR2,
                              VAR_PO_RESPONSE_MESSAGE        OUT VARCHAR2)
    RETURN NUMBER IS
    VAR_L_RETURN_VAL   NUMBER := 1;
    VAR_L_COD_ACCT_NO  VARCHAR2(16) := RPAD(VAR_PI_COD_ACCT_NO, 16, ' ');
    VAR_L_DAT_PROCESS  BA_BANK_MAST.DAT_PROCESS%TYPE := PK_BA_GLOBAL.DAT_PROCESS;
    VAR_L_DAT_TXN      VARCHAR2(14) := SUBSTR(VAR_PI_DAT_TXN, 5, 10);
    VAR_L_BATCH_NO     NUMBER(10) := 2; --SEQ_BATCH_NO_NGI.NEXTVAL;
    VAR_L_MSG_TYPE     NUMBER;
    VAR_L_DAT_LOCALTIM NUMBER := TO_CHAR(SYSDATE, 'HH24MISS');
    VAR_L_DAT_LOCAL    NUMBER := TO_CHAR(SYSDATE, 'MMDD');
    VAR_L_CTR_YR_LOCAL NUMBER := TO_CHAR(SYSDATE, 'YYYY');
    VAR_L_DAT_POST_DUM NUMBER := LPAD(DATEPART('MM', VAR_L_DAT_PROCESS),
                                      2,
                                      '0') ||
                                 LPAD(DATEPART('DD', VAR_L_DAT_PROCESS),
                                      2,
                                      '0');
  
    VAR_L_CTR_YR_POST_DUM      NUMBER := TO_CHAR(VAR_L_DAT_PROCESS, 'YYYY');
    VAR_L_DAT_VALUE_DUM        NUMBER := TO_CHAR(VAR_L_DAT_PROCESS, 'MMDD');
    VAR_L_CTR_YR_VALUE_DUM     NUMBER := TO_CHAR(VAR_L_DAT_PROCESS, 'YYYY');
    VAR_L_STL_PROC_CODE        NUMBER := 18;
    VAR_L_TXT_MEMO             VARCHAR2(250);
    var_L_nam_cust_shrt        VARCHAR2(250);
    var_L_amt_avail            NUMBER;
    var_L_amt_hld              NUMBER;
    var_L_amt_unclr            NUMBER;
    var_L_amt_auth_dr          NUMBER;
    var_L_amt_excp             NUMBER;
    var_L_amt_excp_typ         NUMBER := 0;
    var_L_amt_to_pay           NUMBER;
    var_L_amt_penalty          NUMBER;
    var_L_amt_outstanding      NUMBER;
    var_L_amt_instal_arrears   NUMBER;
    var_L_amt_arrears_charges  NUMBER;
    var_L_amt_penalty_interest NUMBER;
    var_L_acct_oper_usn        NUMBER := 0; --NAF ASSIGN 0
    VAR_L_COD_DEP_NO           NUMBER := 0;
    VAR_L_PAYOUT_TO_DEP_NO     VARCHAR2(16) := 0; -- NAF
    VAR_L_PAYOUT_ACCT_NO       VARCHAR2(16) := NULL; -- NAF
  
    VAR_L_REDEM_TO_DEP_NO VARCHAR2(16) := 0;
    VAR_L_REDEM_ACCT_NO   VARCHAR2(16);
    VAR_L_TXT_INDEMNITY   VARCHAR2(16);
  
    -- naf
    VAR_L_EXT_STRING t_string_list;
  BEGIN
    IF VAR_PI_COD_ORG_MSG_TYP = 200 THEN
      VAR_L_MSG_TYPE := 400;
    ELSE
      VAR_L_MSG_TYPE := 200;
    END IF;
  
    --  settlement process 20 marks a true inter-branch leg, not a fixed subsequence
    IF VAR_PI_COD_TXN_MNEMONIC = 1005 AND
       NVL(VAR_PI_COD_CC_BRN, 0) <> NVL(VAR_PI_COD_ORG_BRN, 0) THEN
      VAR_L_STL_PROC_CODE := 20;
    END IF;
  
    BEGIN
      VAR_L_RETURN_VAL := AP_OL_GL_TXNS(var_dat_log                    => VAR_L_DAT_PROCESS,
                                        var_dat_txn                    => VAR_PI_DAT_TXN,
                                        var_ctr_yr_txn_dum             => TO_CHAR(SYSDATE,
                                                                                  'YYYY'),
                                        var_cod_org_brn                => VAR_PI_COD_ORG_BRN,
                                        var_cod_userno                 => VAR_PI_COD_USERNO,
                                        var_cod_authno_dum             => 0,
                                        var_ctr_batch_no               => VAR_L_BATCH_NO,
                                        var_ref_sys_tr_aud_no_dum      => VAR_PI_STAN_NO,
                                        var_ref_subseq_no              => VAR_PI_REF_SUBSEQ_NO,
                                        var_cod_msg_typ                => VAR_L_MSG_TYPE,
                                        var_cod_acct_no_dum            => VAR_PI_COD_ACCT_NO_DUM_GL,
                                        var_cod_txn_ccy_dum            => VAR_PI_TXN_CUR,
                                        var_cod_acc_ccy_dum            => VAR_PI_ACCT_CUR,
                                        var_cod_other_acc_ccy_dum      => VAR_PI_ACCT_CUR,
                                        var_cod_proc_dum               => VAR_PI_COD_PROC,
                                        var_amt_txn_lcy_dum            => ROUND(VAR_PI_AMT_TXN_LCY,
                                                                                2),
                                        var_amt_txn_tcy_dum            => VAR_PI_AMT_TXN_TCY,
                                        var_amt_txn_acy_dum            => VAR_PI_AMT_TXN_TCY,
                                        var_amt_txn_other_acy_dum      => VAR_PI_AMT_TXN_TCY,
                                        var_rat_conv_tclcy_dum         => VAR_PI_TXN_CCY_CONV_RATE,
                                        var_rat_conv_aclcy_dum         => VAR_PI_ACCT_CCY_CONV_RATE,
                                        var_rat_conv_other_aclcy_dum   => 0,
                                        var_flg_tcy_conv               => 0,
                                        var_flg_acy_conv               => 0,
                                        var_dat_localtim               => VAR_L_DAT_LOCALTIM,
                                        var_dat_local                  => VAR_L_DAT_LOCAL,
                                        var_ctr_yr_local               => VAR_L_CTR_YR_LOCAL,
                                        var_dat_post_dum               => VAR_L_DAT_POST_DUM,
                                        var_ctr_yr_post_dum            => VAR_L_CTR_YR_POST_DUM,
                                        var_dat_value_dum              => VAR_L_DAT_VALUE_DUM,
                                        var_ctr_yr_value_dum           => VAR_L_CTR_YR_VALUE_DUM,
                                        var_flg_override_dum           => VAR_PI_FLG_OVERRIDE_DUM,
                                        var_ref_doc_no_dum             => NULL,
                                        var_cod_fnd_acct_no            => VAR_PI_COD_ACCT_NO_DUM_GL,
                                        var_cod_source_lo_dum          => 1,
                                        var_cod_dest_lo_dum            => 0,
                                        var_ref_instr_typ_dum          => NULL,
                                        var_ref_fund_typ_dum           => 1,
                                        var_cod_routing_no_dum         => 0,
                                        var_cod_instr_acct_no_dum      => NULL,
                                        var_ref_instr_no_str_dum       => NULL,
                                        var_ref_instr_no_end           => NULL,
                                        var_cod_instr_issuer_dum       => 0,
                                        var_no_of_instrs_dum           => 0,
                                        var_cod_bank_corresp_instr_dum => 0,
                                        var_cod_drawee_bank_instr_dum  => NULL,
                                        var_cod_float_instr_dum        => '000',
                                        var_cod_end_point_dum          => 0,
                                        var_cod_clg_brn_dum            => 0,
                                        var_nam_benef                  => NULL,
                                        var_txt_benef_addr1            => NULL,
                                        var_txt_benef_addr2            => NULL,
                                        var_txt_benef_addr3            => NULL,
                                        var_cod_cust_natl_id           => NULL,
                                        var_txn_cod                    => 0,
                                        var_cod_acct_benef             => NULL,
                                        var_flg_route                  => NULL,
                                        var_flg_benef_id               => NULL,
                                        var_nam_order_cust             => NULL,
                                        var_cod_opt_charges            => NULL,
                                        var_typ_advice                 => 0,
                                        var_txt_acct_direct_instrs1    => NULL,
                                        var_txt_acct_direct_instrs2    => NULL,
                                        var_txt_acct_direct_instrs3    => NULL,
                                        var_txt_acct_direct_instrs4    => NULL,
                                        var_nam_agent_near_brn         => NULL,
                                        var_nam_bank                   => NULL,
                                        var_txt_bank_add1              => NULL,
                                        var_txt_bank_add2              => NULL,
                                        var_txt_bank_add3              => NULL,
                                        var_amt_repl_tcy_dum           => 0.0,
                                        var_amt_repl_lcy_dum           => 0.0,
                                        var_amt_repl_acy_dum           => 0.0,
                                        var_amt_txn_from_acy_dum       => NULL,
                                        var_amt_txn_to_acy_dum         => NULL,
                                        var_dat_instr_dum              => VAR_L_DAT_POST_DUM,
                                        var_ctr_yr_instr_dum           => VAR_L_CTR_YR_POST_DUM,
                                        var_cod_ccy_instr_dum          => VAR_PI_ACCT_CUR,
                                        var_amt_instr_dum              => 0,
                                        var_dat_instr_value_dum        => VAR_L_DAT_POST_DUM,
                                        var_ctr_yr_instr_value_dum     => VAR_L_CTR_YR_POST_DUM,
                                        var_dat_del_instr              => VAR_L_DAT_POST_DUM,
                                        var_ctr_yr_del_instr           => VAR_L_CTR_YR_POST_DUM,
                                        var_cod_txn_mnemonic_dum       => VAR_PI_COD_TXN_MNEMONIC,
                                        var_cod_org_msg_typ_dum        => VAR_PI_COD_ORG_MSG_TYP,
                                        var_ref_org_stan_dum           => VAR_PI_REF_ORG_STAN,
                                        var_ref_org_subseq_no_dum      => VAR_PI_REF_ORG_SUBSEQ_NO,
                                        var_dat_org_txn_dum            => VAR_PI_DAT_ORG_TXN,
                                        var_ctr_yr_org_txn_dum         => VAR_PI_CTR_YR_ORG_TXN,
                                        var_dat_org_post_dum           => VAR_PI_DAT_ORG_POST,
                                        var_ctr_yr_org_post_dum        => VAR_PI_CTR_YR_ORG_POST,
                                        var_cod_user_access_dum        => 90,
                                        var_cod_from_acct_no_dum       => VAR_PI_COD_ACCT_NO_DUM_GL,
                                        var_cod_to_acct_no_dum         => NULL,
                                        var_flg_psbk_bal               => 'N',
                                        var_bal_passbook               => NULL,
                                        var_line_no_psbk               => 0,
                                        var_flg_sc_option_dum          => NULL,
                                        var_txt_txndesc_dum            => VAR_PI_TXNDESC1 ||
                                                                          VAR_PI_TXNDESC2,
                                        var_cod_txn_literal_dum        => VAR_PI_COD_TASK_LITERAL_DERIVE,
                                        var_cod_cust1                  => 0,
                                        var_cod_cust2                  => 0,
                                        var_cod_cust3                  => 0,
                                        var_cod_cust4                  => 0,
                                        var_cod_cust5                  => 0,
                                        var_cod_cust6                  => 0,
                                        var_cod_cc_brn_dum             => VAR_PI_COD_CC_BRN,
                                        var_cod_prod_dum               => VAR_PI_COD_PROD,
                                        var_cod_from_cc_brn_dum        => 0,
                                        var_cod_to_cc_brn_dum          => 0,
                                        var_cod_nfw_acct               => VAR_L_COD_ACCT_NO,
                                        var_cod_nfw_brn                => VAR_PI_COD_ORG_BRN,
                                        var_bal_principal_ren          => NULL,
                                        var_bal_postmat_int_ren        => NULL,
                                        var_tax_withheld_ren           => 0,
                                        var_ctr_renew_term_ren         => 0,
                                        var_rat_renewal_ren            => 0.0,
                                        var_rat_tax_ren                => 0,
                                        var_rat_int_exp_ren            => 0.0,
                                        var_dat_mat_yyyy_ren           => VAR_L_CTR_YR_POST_DUM,
                                        var_dat_mat_mmdd_ren           => VAR_L_DAT_POST_DUM,
                                        var_cod_int_indx_ren           => 0,
                                        var_rat_int_ren                => 0.0,
                                        var_rat_int_var_ren            => 0.0,
                                        var_flg_mode_red_dum           => 0,
                                        var_flg_reverse_int_red        => NULL,
                                        var_flg_close_dep_red          => NULL,
                                        var_bal_principal_red          => NULL,
                                        var_amt_redeem_red             => NULL,
                                        var_amt_pmi_red_dum            => NULL,
                                        var_amt_penalty_red            => NULL,
                                        var_amt_int_deduct_red         => NULL,
                                        var_amt_tds_acy_red            => NULL,
                                        var_amt_serv_chg_red           => NULL,
                                        var_amt_net_proc_red           => NULL,
                                        var_cod_acct_stat_red          => 0,
                                        var_rat_conv_expense_red       => 0.0,
                                        var_rat_conv_accrual_red       => 0.0,
                                        var_rat_tds_aclcy_red          => 0,
                                        var_rat_conv_reg_dep_red       => 0.0,
                                        var_rat_conv_sc_red            => 0,
                                        var_p_rsv_prv_buf_2            => NULL,
                                        var_p_amt_pmi                  => NULL,
                                        var_p_amt_pen_int              => NULL,
                                        var_p_cod_prod                 => VAR_PI_COD_PROD,
                                        pi_cod_lcy                     => 0,
                                        var_p_stl_cod_process_dum      => VAR_L_STL_PROC_CODE,
                                        var_p_flg_drcr                 => VAR_PI_FLG_DRCR,
                                        var_p_cod_user_id              => VAR_PI_COD_USER_ID,
                                        var_p_cod_auth_id              => NULL,
                                        var_cod_acct_maint_mode_dum    => NULL,
                                        var_maker_id                   => VAR_PI_COD_USER_ID,
                                        var_checker_id                 => NULL,
                                        var_cod_module                 => NULL,
                                        var_txt_acct_oper_instrs1      => NULL,
                                        var_txt_acct_oper_instrs2      => NULL,
                                        var_ref_txn_no                 => VAR_PI_REF_TXN_NO,
                                        var_ref_usr_no                 => VAR_PI_SVC_RQ_ID,
                                        var_consumer_no_dum            => NULL,
                                        var_ref_no1_dum                => NULL,
                                        var_ref_no2_dum                => NULL,
                                        var_dat_bill_dum               => 0,
                                        var_ctr_yr_bill_dum            => 0,
                                        var_o_cod_reply                => VAR_PO_COD_REPLY,
                                        var_o_cod_ext                  => VAR_PO_COD_EXT,
                                        var_o_txt_memo                 => VAR_L_TXT_MEMO,
                                        var_o_nam_cust_shrt            => VAR_L_NAM_CUST_SHRT,
                                        var_o_amt_avail                => VAR_L_AMT_AVAIL,
                                        var_o_amt_hld                  => VAR_L_AMT_HLD,
                                        var_o_amt_unclr                => VAR_L_AMT_UNCLR,
                                        var_o_amt_auth_dr              => VAR_L_AMT_AUTH_DR,
                                        var_o_amt_excp                 => VAR_L_AMT_EXCP,
                                        var_o_amt_excp_typ             => VAR_L_AMT_EXCP_TYP,
                                        var_o_usn                      => VAR_PO_USN,
                                        var_amt_to_pay                 => VAR_L_AMT_TO_PAY,
                                        var_amt_penalty                => VAR_L_AMT_PENALTY,
                                        var_amt_outstanding            => VAR_L_AMT_OUTSTANDING,
                                        var_amt_instal_arrears         => VAR_L_AMT_INSTAL_ARREARS,
                                        var_amt_arrears_charges        => VAR_L_AMT_ARREARS_CHARGES,
                                        var_amt_penalty_interest       => VAR_L_AMT_PENALTY_INTEREST,
                                        var_o_acct_oper_usn            => VAR_L_ACCT_OPER_USN,
                                        var_p_card_data                => NULL,
                                        var_p_cod_sc                   => NULL,
                                        var_p_flg_base_rate            => NULL,
                                        var_p_dep_term                 => 0,
                                        var_rat_int_prod               => 0.0,
                                        var_int_pay_frq                => NULL,
                                        var_int_comp_frq               => NULL,
                                        var_dat_maturity               => NULL,
                                        var_dat_start                  => NULL,
                                        var_cod_int_indx               => 0,
                                        var_rat_int                    => 0.0,
                                        var_rat_int_var                => 0.0,
                                        var_cod_dep_no                 => VAR_L_COD_DEP_NO,
                                        var_renew_pmi_int              => 0,
                                        var_renew_pmi_prin             => 0,
                                        var_renew_comp_freq            => 0,
                                        var_renew_pay_freq             => 0,
                                        var_renew_flg_base_rate        => NULL,
                                        var_renew_dep_no               => 0,
                                        var_redem_uncoll_prin          => 0,
                                        var_redem_uncoll_int           => 0,
                                        var_redem_dep_no               => 0,
                                        var_payout_amt                 => NULL,
                                        var_payout_dep_no              => 0,
                                        var_amt_txn_acy_sc             => NULL,
                                        var_amt_txn_lcy_sc             => NULL,
                                        var_amt_txn_tcy_sc             => NULL,
                                        var_cod_txn_mnemonic_sc        => 0,
                                        var_amt_sc_acy_org             => NULL,
                                        var_payout_base_rate           => NULL,
                                        var_payout_dep_term            => 0,
                                        var_payout_int_pay_freq        => NULL,
                                        var_payout_int_comp_freq       => NULL,
                                        var_payout_val_date            => NULL,
                                        var_payout_start_date          => NULL,
                                        var_payout_prod_code           => 0,
                                        var_payout_to_dep_no           => VAR_L_PAYOUT_TO_DEP_NO,
                                        var_payout_acct_no             => VAR_L_PAYOUT_ACCT_NO,
                                        var_redem_base_rate            => NULL,
                                        var_redem_dep_term             => 0,
                                        var_redem_int_pay_freq         => NULL,
                                        var_redem_int_comp_freq        => NULL,
                                        var_redem_val_date             => NULL,
                                        var_redem_start_date           => NULL,
                                        var_redem_prod_code            => 0,
                                        var_redem_to_dep_no            => VAR_L_REDEM_TO_DEP_NO,
                                        var_redem_acct_no              => VAR_L_REDEM_ACCT_NO,
                                        var_txt_indemnity              => VAR_L_TXT_INDEMNITY,
                                        var_cod_lcy_src                => 0,
                                        var_cod_lcy_dest               => 0,
                                        var_amt_txn_lcy_src            => NULL,
                                        var_amt_txn_lcy_dest           => NULL,
                                        var_ctr_subsidy_term           => 0,
                                        flg_rd_payment_mode            => 0);
    
      IF VAR_L_RETURN_VAL <> 0 THEN
        --  the host's own reply code
        VAR_PO_RESPONSE_CODE    := LPAD(NVL(VAR_PO_COD_REPLY, 1210), 7, '0');
        VAR_PO_RESPONSE_MESSAGE := 'Database Error: AP_OL_GL_TXNS';
        RETURN VAR_L_RETURN_VAL;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        VAR_PO_RESPONSE_CODE    := 1210;
        VAR_PO_RESPONSE_MESSAGE := 'Exception occured while executing the Function AP_OL_GL_TXNS';
        RETURN 1;
    END;
  
    RETURN 0;
  END AP_OL_CALL_GL_TXNS;

  FUNCTION AP_OL_CALL_PROCESS_SC(VAR_PI_CHANNEL_ID         IN VARCHAR2,
                                 VAR_PI_SVC_CODE           IN VARCHAR2,
                                 VAR_PI_DAT_TXN            IN NUMBER,
                                 VAR_PI_COD_ORG_BRN        IN NUMBER,
                                 VAR_PI_REF_SUBSEQ_NO      IN NUMBER,
                                 VAR_PI_SVC_RQ_ID          IN VARCHAR2,
                                 VAR_PI_TXN_CCY            IN NUMBER,
                                 VAR_PI_AMT_TXN_LCY        IN NUMBER,
                                 VAR_PI_AMT_TXN_TCY        IN NUMBER,
                                 VAR_PI_AMT_TXN_ACY        IN NUMBER,
                                 VAR_PI_TXN_CCY_CONV_RATE  IN NUMBER,
                                 VAR_PI_ACCT_CCY_CONV_RATE IN NUMBER,
                                 VAR_PI_COD_SC             IN NUMBER,
                                 VAR_PI_COD_TXN_MNEMONIC   IN VARCHAR2,
                                 VAR_PI_COD_TXN            IN VARCHAR2,
                                 VAR_PI_COD_USER_ID        IN VARCHAR2,
                                 VAR_PI_COD_USERNO         IN NUMBER,
                                 VAR_PI_STAN_NO            IN NUMBER,
                                 VAR_PI_REF_TXN_NO         IN VARCHAR2,
                                 ---FROM ACCOUNT DETAILS---
                                 VAR_PI_ACCT_ID_F    IN VARCHAR2,
                                 VAR_PI_COD_CC_BRN_F IN NUMBER,
                                 VAR_PI_ACCT_CUR_F   IN VARCHAR2,
                                 VAR_PI_COD_PROD_F   IN VARCHAR2,
                                 VAR_PO_COD_EXT      IN OUT VARCHAR2,
                                 VAR_PO_COD_REPLY    IN OUT NUMBER,
                                 VAR_PO_USN_F        IN OUT VARCHAR2,
                                 VAR_PI_XREF_NUMBER  IN VARCHAR2,
                                 --  fee leg narration = the transaction narrative
                                 VAR_PI_NARRATIVE        IN VARCHAR2 DEFAULT NULL,
                                 VAR_PO_RESPONSE_CODE    OUT VARCHAR2,
                                 VAR_PO_RESPONSE_MESSAGE OUT VARCHAR2)
    RETURN NUMBER IS
    VAR_L_RETURN_VAL  NUMBER := 1;
    VAR_L_COD_EXT     VARCHAR2(20);
    VAR_L_COD_REPLY   NUMBER := 0;
    VAR_L_ACCT_ID_F   VARCHAR2(16) := RPAD(VAR_PI_ACCT_ID_F, 16, ' ');
    VAR_L_DAT_PROCESS BA_BANK_MAST.DAT_PROCESS%TYPE := PK_BA_GLOBAL.DAT_PROCESS;
    VAR_L_DAT_TXN     NUMBER := TO_CHAR(SYSDATE, 'MMDDHH24MISS');
  
    VAR_L_CTR_YR_TXN_DUM NUMBER := TO_CHAR(SYSDATE, 'YYYY');
    VAR_L_BATCH_NO       NUMBER(10) := 2; --SEQ_BATCH_NO_NGI.NEXTVAL;
    VAR_L_MSG_TYPE       NUMBER := 200;
    VAR_L_DAT_LOCALTIM   VARCHAR2(6) := TO_CHAR(SYSDATE, 'HH24MISS');
    VAR_L_DAT_LOCAL      VARCHAR2(4) := TO_CHAR(SYSDATE, 'MMDD');
    VAR_L_CTR_YR_LOCAL   NUMBER := TO_CHAR(SYSDATE, 'YYYY');
    VAR_L_DAT_POST_DUM   VARCHAR2(4) := LPAD(DATEPART('MM',
                                                      VAR_L_DAT_PROCESS),
                                             2,
                                             '0') || LPAD(DATEPART('DD',
                                                                   VAR_L_DAT_PROCESS),
                                                          2,
                                                          '0');
  
    VAR_L_CTR_YR_POST_DUM      NUMBER := TO_CHAR(VAR_L_DAT_PROCESS, 'YYYY');
    VAR_L_DAT_VALUE_DUM        NUMBER := TO_CHAR(VAR_L_DAT_PROCESS, 'MMDD');
    VAR_L_CTR_YR_VALUE_DUM     NUMBER := TO_CHAR(VAR_L_DAT_PROCESS, 'YYYY');
    VAR_L_STL_PROC_CODE        NUMBER := 4;
    VAR_L_TXT_MEMO             VARCHAR2(250);
    var_L_nam_cust_shrt        VARCHAR2(250);
    var_L_amt_avail            NUMBER := 0;
    var_L_amt_hld              NUMBER := 0;
    var_L_amt_unclr            NUMBER := 0;
    var_L_amt_auth_dr          NUMBER := 0;
    var_L_amt_excp             NUMBER := 0;
    var_L_amt_excp_typ         NUMBER := 0;
    var_L_amt_to_pay           NUMBER := 0;
    var_L_amt_penalty          NUMBER := 0;
    var_L_amt_outstanding      NUMBER := 0;
    var_L_amt_instal_arrears   NUMBER := 0;
    var_L_amt_arrears_charges  NUMBER := 0;
    var_L_amt_penalty_interest NUMBER := 0;
    var_L_acct_oper_usn        NUMBER := 0;
    VAR_L_COD_DEP_NO           NUMBER := 0;
    VAR_L_PAYOUT_TO_DEP_NO     VARCHAR2(16) := 0;
    VAR_L_REDEM_TO_DEP_NO      NUMBER := 0;
    VAR_L_REDEM_ACCT_NO        VARCHAR2(16);
    VAR_L_TXT_INDEMNITY        VARCHAR2(16);
    VAR_L_FLG_OVERRIDE_DUM     NUMBER := 1;
    VAR_L_PAYOUT_ACCT_NO       VARCHAR2(16);
  
    -----------
    SUBTYPE T_STRING_LIST IS DBMS_SQL.VARCHAR2A;
  
    VAR_L_ADDED_WORDS            t_string_list;
    VAR_L_ORG_WORDS              t_string_list;
    VAR_L_EXT_STRING             t_string_list;
    VAR_L_REPLY_CODE             NUMBER := 0;
    VAR_L_ORIGINAL_MEMO          VARCHAR2(250) := NULL;
    VAR_L_ORIGINAL_RESPONSE_CODE NUMBER := NULL;
    VAR_L_ORG_EXTENDED_RESP      VARCHAR2(20) := NULL;
    VAR_L_EXT_RESPONSE           VARCHAR2(20) := NULL;
    VAR_L_PADDED_EXT_RESP        VARCHAR2(10);
    VAR_L_ORG_COD_REPLY          NUMBER;
    VAR_L_CUR_COD_REPLY          NUMBER;
    VAR_L_VAILD_REPEAT_RESP_FLG  BOOLEAN;
    VAR_L_CUR_EXT_RESP           VARCHAR2(20) := NULL;
    VAR_L_ADDED_RESPONSE         VARCHAR2(20) := NULL;
    VAR_L_REPEAT                 BOOLEAN := TRUE;
    VAR_L_RESULT                 NUMBER := 0;
    VAR_L_COUNTER                NUMBER := 0;
    VAR_L_RET_CODE_CHK_EXT_RESP  NUMBER := 1;
    VAR_O_COD_EXT_OVERWRITE      VARCHAR2(100) := NULL;
  BEGIN
    --  codes this service may override; no row means none
    BEGIN
      SELECT RTRIM(OVERRIDEN_CODES)
        INTO VAR_PO_COD_EXT
        FROM NGI_OVERRIDE_SCORES
       WHERE NGI_SERVICE = VAR_PI_SVC_CODE
         AND NAM_FUNCTION = 'AP_OL_SC_WDR'
         AND FLG_MNT_STATUS = 'A';
    EXCEPTION
      WHEN OTHERS THEN
        VAR_PO_COD_EXT := NULL;
    END;
  
    --  the call returns its extended response in the same variable, so keep the list
    VAR_O_COD_EXT_OVERWRITE := VAR_PO_COD_EXT;
  
    BEGIN
      VAR_L_RETURN_VAL := AP_OL_SC_WDR(VAR_DAT_LOG => VAR_L_DAT_PROCESS,
                                       --  one DAT_TXN per transaction: reuse the wrapper's timestamp
                                       VAR_DAT_TXN                    => VAR_PI_DAT_TXN,
                                       VAR_CTR_YR_TXN_DUM             => VAR_L_CTR_YR_TXN_DUM,
                                       VAR_COD_ORG_BRN                => VAR_PI_COD_ORG_BRN,
                                       VAR_COD_USERNO                 => VAR_PI_COD_USERNO,
                                       VAR_COD_AUTHNO_DUM             => 0,
                                       VAR_CTR_BATCH_NO               => VAR_L_BATCH_NO,
                                       VAR_REF_SYS_TR_AUD_NO_DUM      => VAR_PI_STAN_NO,
                                       VAR_REF_SUBSEQ_NO              => VAR_PI_REF_SUBSEQ_NO,
                                       VAR_COD_MSG_TYP                => VAR_L_MSG_TYPE,
                                       VAR_COD_ACCT_NO_DUM            => VAR_L_ACCT_ID_F,
                                       VAR_COD_TXN_CCY_DUM            => VAR_PI_TXN_CCY,
                                       VAR_COD_ACC_CCY_DUM            => VAR_PI_ACCT_CUR_F,
                                       VAR_COD_OTHER_ACC_CCY_DUM      => VAR_PI_ACCT_CUR_F,
                                       VAR_COD_PROC_DUM               => 101000,
                                       VAR_AMT_TXN_LCY_DUM            => VAR_PI_AMT_TXN_TCY,
                                       VAR_AMT_TXN_TCY_DUM            => VAR_PI_AMT_TXN_TCY,
                                       VAR_AMT_TXN_ACY_DUM            => VAR_PI_AMT_TXN_ACY,
                                       VAR_AMT_TXN_OTHER_ACY_DUM      => VAR_PI_AMT_TXN_ACY,
                                       VAR_RAT_CONV_TCLCY_DUM         => VAR_PI_TXN_CCY_CONV_RATE,
                                       VAR_RAT_CONV_ACLCY_DUM         => VAR_PI_ACCT_CCY_CONV_RATE,
                                       VAR_RAT_CONV_OTHER_ACLCY_DUM   => 0,
                                       VAR_FLG_TCY_CONV               => 0,
                                       VAR_FLG_ACY_CONV               => 0,
                                       VAR_DAT_LOCALTIM               => VAR_L_DAT_LOCALTIM,
                                       VAR_DAT_LOCAL                  => VAR_L_DAT_LOCAL,
                                       VAR_CTR_YR_LOCAL               => VAR_L_CTR_YR_LOCAL,
                                       VAR_DAT_POST_DUM               => VAR_L_DAT_POST_DUM,
                                       VAR_CTR_YR_POST_DUM            => VAR_L_CTR_YR_POST_DUM,
                                       VAR_DAT_VALUE_DUM              => VAR_L_DAT_VALUE_DUM,
                                       VAR_CTR_YR_VALUE_DUM           => VAR_L_CTR_YR_VALUE_DUM,
                                       VAR_FLG_OVERRIDE_DUM           => VAR_L_FLG_OVERRIDE_DUM,
                                       VAR_REF_DOC_NO_DUM             => VAR_PI_REF_TXN_NO,
                                       VAR_COD_FND_ACCT_NO            => VAR_L_ACCT_ID_F,
                                       VAR_COD_SOURCE_LO_DUM          => 1,
                                       VAR_COD_DEST_LO_DUM            => 0,
                                       VAR_REF_INSTR_TYP_DUM          => NULL,
                                       VAR_REF_FUND_TYP_DUM           => NULL,
                                       VAR_COD_ROUTING_NO_DUM         => 0,
                                       VAR_COD_INSTR_ACCT_NO_DUM      => NULL,
                                       VAR_REF_INSTR_NO_STR_DUM       => NULL,
                                       VAR_REF_INSTR_NO_END           => NULL,
                                       VAR_COD_INSTR_ISSUER_DUM       => 0,
                                       VAR_NO_OF_INSTRS_DUM           => 0,
                                       VAR_COD_BANK_CORRESP_INSTR_DUM => 0,
                                       VAR_COD_DRAWEE_BANK_INSTR_DUM  => NULL,
                                       VAR_COD_FLOAT_INSTR_DUM        => NULL,
                                       VAR_COD_END_POINT_DUM          => 0,
                                       VAR_COD_CLG_BRN_DUM            => 0,
                                       VAR_NAM_BENEF                  => NULL,
                                       VAR_TXT_BENEF_ADDR1            => NULL,
                                       VAR_TXT_BENEF_ADDR2            => NULL,
                                       VAR_TXT_BENEF_ADDR3            => NULL,
                                       VAR_COD_CUST_NATL_ID           => NULL,
                                       VAR_TXN_COD                    => 0,
                                       VAR_COD_ACCT_BENEF             => NULL,
                                       VAR_FLG_ROUTE                  => NULL,
                                       VAR_FLG_BENEF_ID               => NULL,
                                       VAR_NAM_ORDER_CUST             => NULL,
                                       VAR_COD_OPT_CHARGES            => NULL,
                                       VAR_TYP_ADVICE                 => 0,
                                       VAR_TXT_ACCT_DIRECT_INSTRS1    => NULL,
                                       VAR_TXT_ACCT_DIRECT_INSTRS2    => NULL,
                                       VAR_TXT_ACCT_DIRECT_INSTRS3    => NULL,
                                       VAR_TXT_ACCT_DIRECT_INSTRS4    => NULL,
                                       VAR_NAM_AGENT_NEAR_BRN         => NULL,
                                       VAR_NAM_BANK                   => NULL,
                                       VAR_TXT_BANK_ADD1              => NULL,
                                       VAR_TXT_BANK_ADD2              => NULL,
                                       VAR_TXT_BANK_ADD3              => NULL,
                                       VAR_AMT_REPL_TCY_DUM           => VAR_PI_AMT_TXN_TCY,
                                       VAR_AMT_REPL_LCY_DUM           => VAR_PI_AMT_TXN_LCY,
                                       VAR_AMT_REPL_ACY_DUM           => VAR_PI_AMT_TXN_ACY,
                                       VAR_AMT_TXN_FROM_ACY_DUM       => 0,
                                       VAR_AMT_TXN_TO_ACY_DUM         => 0,
                                       VAR_DAT_INSTR_DUM              => VAR_L_DAT_POST_DUM,
                                       VAR_CTR_YR_INSTR_DUM           => VAR_L_CTR_YR_POST_DUM,
                                       VAR_COD_CCY_INSTR_DUM          => VAR_PI_ACCT_CUR_F,
                                       --  the instructed amount is the fee in local currency
                                       VAR_AMT_INSTR_DUM          => VAR_PI_AMT_TXN_LCY,
                                       VAR_DAT_INSTR_VALUE_DUM    => VAR_L_DAT_POST_DUM,
                                       VAR_CTR_YR_INSTR_VALUE_DUM => VAR_L_CTR_YR_POST_DUM,
                                       VAR_DAT_DEL_INSTR          => VAR_L_DAT_POST_DUM,
                                       VAR_CTR_YR_DEL_INSTR       => VAR_L_CTR_YR_POST_DUM,
                                       VAR_COD_TXN_MNEMONIC_DUM   => VAR_PI_COD_TXN_MNEMONIC,
                                       VAR_COD_ORG_MSG_TYP_DUM    => 0,
                                       VAR_REF_ORG_STAN_DUM       => 0,
                                       VAR_REF_ORG_SUBSEQ_NO_DUM  => 0,
                                       VAR_DAT_ORG_TXN_DUM        => 0,
                                       VAR_CTR_YR_ORG_TXN_DUM     => 0,
                                       VAR_DAT_ORG_POST_DUM       => 0,
                                       VAR_CTR_YR_ORG_POST_DUM    => 0,
                                       VAR_COD_USER_ACCESS_DUM    => 90,
                                       VAR_COD_FROM_ACCT_NO_DUM   => NULL,
                                       VAR_COD_TO_ACCT_NO_DUM     => NULL,
                                       VAR_FLG_PSBK_BAL           => NULL,
                                       VAR_BAL_PASSBOOK           => 0,
                                       VAR_LINE_NO_PSBK           => 0,
                                       VAR_FLG_SC_OPTION_DUM      => NULL,
                                       --  the fee leg carries this literal description in IL
                                       VAR_TXT_TXNDESC_DUM         => 'Outgoing Payment Initiation',
                                       VAR_COD_TXN_LITERAL_DUM     => 'MSD',
                                       VAR_COD_CUST1               => 0,
                                       VAR_COD_CUST2               => 0,
                                       VAR_COD_CUST3               => 0,
                                       VAR_COD_CUST4               => 0,
                                       VAR_COD_CUST5               => 0,
                                       VAR_COD_CUST6               => 0,
                                       VAR_COD_CC_BRN_DUM          => VAR_PI_COD_CC_BRN_F,
                                       VAR_COD_PROD_DUM            => VAR_PI_COD_PROD_F,
                                       VAR_COD_FROM_CC_BRN_DUM     => 0,
                                       VAR_COD_TO_CC_BRN_DUM       => 0,
                                       VAR_COD_NFW_ACCT            => VAR_L_ACCT_ID_F,
                                       VAR_COD_NFW_BRN             => VAR_PI_COD_CC_BRN_F,
                                       VAR_BAL_PRINCIPAL_REN       => 0,
                                       VAR_BAL_POSTMAT_INT_REN     => 0,
                                       VAR_TAX_WITHHELD_REN        => 0,
                                       VAR_CTR_RENEW_TERM_REN      => 0,
                                       VAR_RAT_RENEWAL_REN         => 0.0,
                                       VAR_RAT_TAX_REN             => 0,
                                       VAR_RAT_INT_EXP_REN         => 0.0,
                                       VAR_DAT_MAT_YYYY_REN        => VAR_L_CTR_YR_POST_DUM,
                                       VAR_DAT_MAT_MMDD_REN        => VAR_L_DAT_POST_DUM,
                                       VAR_COD_INT_INDX_REN        => 0,
                                       VAR_RAT_INT_REN             => 0.0,
                                       VAR_RAT_INT_VAR_REN         => 0.0,
                                       VAR_FLG_MODE_RED_DUM        => 0,
                                       VAR_FLG_REVERSE_INT_RED     => NULL,
                                       VAR_FLG_CLOSE_DEP_RED       => NULL,
                                       VAR_BAL_PRINCIPAL_RED       => 0,
                                       VAR_AMT_REDEEM_RED          => 0,
                                       VAR_AMT_PMI_RED_DUM         => 0,
                                       VAR_AMT_PENALTY_RED         => 0,
                                       VAR_AMT_INT_DEDUCT_RED      => 0,
                                       VAR_AMT_TDS_ACY_RED         => 0,
                                       VAR_AMT_SERV_CHG_RED        => 0,
                                       VAR_AMT_NET_PROC_RED        => 0,
                                       VAR_COD_ACCT_STAT_RED       => 0,
                                       VAR_RAT_CONV_EXPENSE_RED    => 0.0,
                                       VAR_RAT_CONV_ACCRUAL_RED    => 0.0,
                                       VAR_RAT_TDS_ACLCY_RED       => 0,
                                       VAR_RAT_CONV_REG_DEP_RED    => 0.0,
                                       VAR_RAT_CONV_SC_RED         => 0,
                                       VAR_P_RSV_PRV_BUF_2         => NULL,
                                       VAR_P_AMT_PMI               => NULL,
                                       VAR_P_AMT_PEN_INT           => NULL,
                                       VAR_P_COD_PROD              => VAR_PI_COD_PROD_F,
                                       PI_COD_LCY                  => 0,
                                       VAR_P_STL_COD_PROCESS_DUM   => VAR_L_STL_PROC_CODE, --4
                                       VAR_P_FLG_DRCR              => 'D',
                                       VAR_P_COD_USER_ID           => VAR_PI_COD_USER_ID,
                                       VAR_P_COD_AUTH_ID           => NULL,
                                       VAR_COD_ACCT_MAINT_MODE_DUM => NULL,
                                       VAR_MAKER_ID                => VAR_PI_COD_USER_ID,
                                       VAR_CHECKER_ID              => NULL,
                                       VAR_COD_MODULE              => 'CH',
                                       VAR_TXT_ACCT_OPER_INSTRS1   => NULL,
                                       VAR_TXT_ACCT_OPER_INSTRS2   => NULL,
                                       VAR_REF_TXN_NO              => VAR_PI_REF_TXN_NO,
                                       VAR_REF_USR_NO              => VAR_PI_SVC_RQ_ID,
                                       VAR_CONSUMER_NO_DUM         => NULL,
                                       VAR_REF_NO1_DUM             => NULL,
                                       VAR_REF_NO2_DUM             => NULL,
                                       VAR_DAT_BILL_DUM            => 0,
                                       VAR_CTR_YR_BILL_DUM         => 0,
                                       VAR_O_COD_REPLY             => VAR_PO_COD_REPLY,
                                       VAR_O_COD_EXT               => VAR_PO_COD_EXT,
                                       VAR_O_TXT_MEMO              => VAR_L_TXT_MEMO,
                                       VAR_O_NAM_CUST_SHRT         => VAR_L_NAM_CUST_SHRT,
                                       VAR_O_AMT_AVAIL             => VAR_L_AMT_AVAIL,
                                       VAR_O_AMT_HLD               => VAR_L_AMT_HLD,
                                       VAR_O_AMT_UNCLR             => VAR_L_AMT_UNCLR,
                                       VAR_O_AMT_AUTH_DR           => VAR_L_AMT_AUTH_DR,
                                       VAR_O_AMT_EXCP              => VAR_L_AMT_EXCP,
                                       VAR_O_AMT_EXCP_TYP          => VAR_L_AMT_EXCP_TYP,
                                       VAR_O_USN                   => VAR_PO_USN_F,
                                       VAR_AMT_TO_PAY              => VAR_L_AMT_TO_PAY,
                                       VAR_AMT_PENALTY             => VAR_L_AMT_PENALTY,
                                       VAR_AMT_OUTSTANDING         => VAR_L_AMT_OUTSTANDING,
                                       VAR_AMT_INSTAL_ARREARS      => VAR_L_AMT_INSTAL_ARREARS,
                                       VAR_AMT_ARREARS_CHARGES     => VAR_L_AMT_ARREARS_CHARGES,
                                       VAR_AMT_PENALTY_INTEREST    => VAR_L_AMT_PENALTY_INTEREST,
                                       VAR_O_ACCT_OPER_USN         => VAR_L_ACCT_OPER_USN,
                                       VAR_P_CARD_DATA             => NULL,
                                       VAR_P_COD_SC                => VAR_PI_COD_SC, --5620
                                       VAR_P_FLG_BASE_RATE         => NULL,
                                       VAR_P_DEP_TERM              => 0,
                                       VAR_RAT_INT_PROD            => 0.0,
                                       VAR_INT_PAY_FRQ             => NULL,
                                       VAR_INT_COMP_FRQ            => NULL,
                                       VAR_DAT_MATURITY            => NULL,
                                       VAR_DAT_START               => NULL,
                                       VAR_COD_INT_INDX            => 0,
                                       VAR_RAT_INT                 => 0.0,
                                       VAR_RAT_INT_VAR             => 0.0,
                                       VAR_COD_DEP_NO              => VAR_L_COD_DEP_NO,
                                       VAR_RENEW_PMI_INT           => 0,
                                       VAR_RENEW_PMI_PRIN          => 0,
                                       VAR_RENEW_COMP_FREQ         => 0,
                                       VAR_RENEW_PAY_FREQ          => 0,
                                       VAR_RENEW_FLG_BASE_RATE     => NULL,
                                       VAR_RENEW_DEP_NO            => 0,
                                       VAR_REDEM_UNCOLL_PRIN       => 0,
                                       VAR_REDEM_UNCOLL_INT        => 0,
                                       VAR_REDEM_DEP_NO            => 0,
                                       VAR_PAYOUT_AMT              => NULL,
                                       VAR_PAYOUT_DEP_NO           => 0,
                                       VAR_AMT_TXN_ACY_SC          => VAR_PI_AMT_TXN_ACY,
                                       VAR_AMT_TXN_LCY_SC          => VAR_PI_AMT_TXN_LCY,
                                       VAR_AMT_TXN_TCY_SC          => VAR_PI_AMT_TXN_TCY,
                                       VAR_COD_TXN_MNEMONIC_SC     => VAR_PI_COD_TXN_MNEMONIC,
                                       VAR_AMT_SC_ACY_ORG          => VAR_PI_AMT_TXN_ACY,
                                       VAR_PAYOUT_BASE_RATE        => NULL,
                                       VAR_PAYOUT_DEP_TERM         => 0,
                                       VAR_PAYOUT_INT_PAY_FREQ     => NULL,
                                       VAR_PAYOUT_INT_COMP_FREQ    => NULL,
                                       VAR_PAYOUT_VAL_DATE         => NULL,
                                       VAR_PAYOUT_START_DATE       => NULL,
                                       VAR_PAYOUT_PROD_CODE        => 0,
                                       VAR_PAYOUT_TO_DEP_NO        => VAR_L_PAYOUT_TO_DEP_NO,
                                       VAR_PAYOUT_ACCT_NO          => VAR_L_PAYOUT_ACCT_NO,
                                       VAR_REDEM_BASE_RATE         => NULL,
                                       VAR_REDEM_DEP_TERM          => 0,
                                       VAR_REDEM_INT_PAY_FREQ      => NULL,
                                       VAR_REDEM_INT_COMP_FREQ     => NULL,
                                       VAR_REDEM_VAL_DATE          => NULL,
                                       VAR_REDEM_START_DATE        => NULL,
                                       VAR_REDEM_PROD_CODE         => 0,
                                       VAR_REDEM_TO_DEP_NO         => VAR_L_REDEM_TO_DEP_NO,
                                       VAR_REDEM_ACCT_NO           => VAR_L_REDEM_ACCT_NO,
                                       VAR_TXT_INDEMNITY           => VAR_L_TXT_INDEMNITY,
                                       VAR_FLG_CUMUL_DR            => NULL,
                                       VAR_COD_SC_ADDNL            => 0,
                                       VAR_COD_SC_ADDNL_CCY        => 0,
                                       VAR_AMT_SC_PARENT_LCYE      => 0,
                                       VAR_AMT_SC_PARENT_TCYE      => 0,
                                       VAR_AMT_SC_PARENT_ACYE      => 0,
                                       VAR_AMT_SC_ADDNL_LCYE       => 0,
                                       VAR_AMT_SC_ADDNL_TCYE       => 0,
                                       VAR_AMT_SC_ADDNL_ACYE       => 0,
                                       VAR_COD_GL_SC_ADDNL_INCOME  => 0);
    
      --  same rule as the withdrawal leg
      VAR_L_RET_CODE_CHK_EXT_RESP := AP_OL_CHECK_EXT_RESP_NGI(PI_INPUT_STR        => VAR_PO_COD_EXT,
                                                              PI_OVERWRITE_STR    => VAR_O_COD_EXT_OVERWRITE,
                                                              PO_RESPONSE_CODE    => VAR_PO_RESPONSE_CODE,
                                                              PO_RESPONSE_MESSAGE => VAR_PO_RESPONSE_MESSAGE);
    
      IF VAR_PO_RESPONSE_CODE IS NOT NULL THEN
        RETURN 1;
      END IF;
    
      IF VAR_L_RETURN_VAL <> 0 THEN
        VAR_PO_RESPONSE_CODE := LPAD(NVL(VAR_PO_COD_REPLY, 1210), 7, '0');
        RETURN VAR_L_RETURN_VAL;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        VAR_PO_RESPONSE_CODE    := 1210;
        VAR_PO_RESPONSE_MESSAGE := 'Exception occured while executing the Function AP_OL_SC_WDR';
        RETURN 1;
    END;
  
    RETURN 0;
  END AP_OL_CALL_PROCESS_SC;

  FUNCTION AP_OL_PREPARE_TXN_VAL_COMMON(VAR_PI_COD_TXN_MNEMONIC   IN VARCHAR2,
                                        VAR_PI_MONETARY_VALUE     IN NUMBER, --amount
                                        VAR_PI_COD_ACCT_CCY       IN NUMBER, --amount.getCurrency
                                        VAR_PI_COD_OTHER_ACCT_CCY IN NUMBER,
                                        VAR_PI_COD_LCY            IN NUMBER,
                                        VAR_PI_DAT_PROCESS        IN DATE,
                                        VAR_PO_TXN_RATE           IN OUT NUMBER,
                                        VAR_PI_ACCT_RATE          IN NUMBER DEFAULT 0,
                                        VAR_PI_IS_TXN_CCY_BASED   IN BOOLEAN,
                                        VAR_PO_COD_TXN_CCY        OUT NUMBER,
                                        VAR_PO_ACCT_CCY_CONV_RATE IN OUT NUMBER,
                                        VAR_PO_TXN_CCY_CONV_RATE  IN OUT NUMBER,
                                        VAR_PO_CTR_CCY_ROUND_TO   OUT NUMBER,
                                        VAR_PO_AMT_TXN_LCY        OUT NUMBER,
                                        VAR_PO_AMT_TXN_TCY        OUT NUMBER,
                                        VAR_PO_AMT_TXN_ACY        OUT NUMBER,
                                        VAR_PO_ACCT_TO_RATE       OUT NUMBER,
                                        VAR_PO_RESPONSE_CODE      OUT VARCHAR2,
                                        VAR_PO_RESPONSE_MESSAGE   OUT VARCHAR2)
    RETURN NUMBER IS
    VAR_L_COD_CCY                NUMBER;
    VAR_L_COD_ACCT_CCY           NUMBER;
    VAR_L_IS_APPROVED_CCY        VARCHAR2(1);
    VAR_L_RETURN_VAL             NUMBER;
    VAR_L_COD_TXN_MNEMONIC       VARCHAR2(10) := VAR_PI_COD_TXN_MNEMONIC;
    VAR_L_RATE_CCY               NUMBER := 0;
    VAR_L_RATE_CCY_SPREAD        NUMBER := 0;
    VAR_L_COD_CCY_SPREAD         VARCHAR2(20) := '';
    VAR_L_MLT_UNIT_RAT_QUOT      NUMBER := 0;
    VAR_L_FLG_CCY_CONV           NUMBER := 0;
    VAR_L_AMT_DEST               NUMBER := 0;
    VAR_L_RAT_SRC_LCY            NUMBER;
    VAR_L_RAT_LCY_DEST           NUMBER;
    VAR_L_CONVERTED_AMT          NUMBER;
    VAR_L_ACCT_RATE              NUMBER(10, 4) := 0;
    var_l_rat_src                NUMBER := 0;
    var_l_mlt_unit_rat_quot_src  NUMBER := 0;
    var_l_flg_ccy_conv_src       NUMBER := 0;
    var_l_mlt_unit_rat_quot_dest NUMBER := 0;
    var_l_flg_ccy_conv_dest      NUMBER := 0;
    var_L_rat_dest               NUMBER;
    var_L_amt_lcy                NUMBER;
  BEGIN
    IF VAR_PI_COD_OTHER_ACCT_CCY <> 0 THEN
      BEGIN
        SELECT COD_CCY, FLG_APPROVED_CCY
          INTO VAR_L_COD_CCY, VAR_L_IS_APPROVED_CCY
          FROM VWE_BA_CCY_CODE
         WHERE COD_CCY = VAR_PI_COD_OTHER_ACCT_CCY
           AND FLG_MNT_STATUS = 'A';
      
        IF UPPER(VAR_L_IS_APPROVED_CCY) <> 'Y' THEN
          VAR_PO_RESPONSE_CODE    := 4142;
          VAR_PO_RESPONSE_MESSAGE := 'Invalid currency code:' ||
                                     VAR_PI_COD_OTHER_ACCT_CCY;
          RETURN 1;
        END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          VAR_PO_RESPONSE_CODE    := 1248;
          VAR_PO_RESPONSE_MESSAGE := 'Invalid currency code:' ||
                                     VAR_PI_COD_OTHER_ACCT_CCY;
          RETURN 1;
      END;
    END IF;
  
    IF VAR_PI_IS_TXN_CCY_BASED THEN
      VAR_L_COD_ACCT_CCY := VAR_L_COD_CCY;
      VAR_PO_COD_TXN_CCY := VAR_PI_COD_ACCT_CCY;
    ELSE
      VAR_L_COD_ACCT_CCY := VAR_PI_COD_ACCT_CCY;
      VAR_PO_COD_TXN_CCY := VAR_L_COD_CCY;
    END IF;
  
    VAR_PO_AMT_TXN_TCY := VAR_PI_MONETARY_VALUE;
    VAR_PO_AMT_TXN_ACY := VAR_PI_MONETARY_VALUE;
    VAR_PO_AMT_TXN_LCY := VAR_PI_MONETARY_VALUE;
  
    IF VAR_L_COD_TXN_MNEMONIC = 0 THEN
      VAR_L_COD_TXN_MNEMONIC := 5003;
    END IF;
  
    IF VAR_L_COD_ACCT_CCY IS NOT NULL AND VAR_PI_ACCT_RATE <= 0 THEN
      BEGIN
        VAR_L_RETURN_VAL := AP_CM_RD_EXCHANGE_RATES(PI_COD_LCY            => VAR_PI_COD_LCY,
                                                    VAR_COD_CCY           => VAR_L_COD_ACCT_CCY,
                                                    VAR_COD_TXN_MNEMONIC  => VAR_L_COD_TXN_MNEMONIC,
                                                    VAR_IP_DT             => VAR_PI_DAT_PROCESS,
                                                    VAR_FLG_SPRD_LCY_DEST => 'L',
                                                    VAR_RATE_CCY          => VAR_L_RATE_CCY,
                                                    VAR_RATE_CCY_SPREAD   => VAR_L_RATE_CCY_SPREAD,
                                                    VAR_COD_CCY_SPREAD    => VAR_L_COD_CCY_SPREAD,
                                                    VAR_MLT_UNIT_RAT_QUOT => VAR_L_MLT_UNIT_RAT_QUOT,
                                                    VAR_FLG_CCY_CONV      => VAR_L_FLG_CCY_CONV,
                                                    VAR_CTR_CCY_ROUND_TO  => VAR_PO_CTR_CCY_ROUND_TO);
      
        VAR_PO_ACCT_TO_RATE := VAR_L_RATE_CCY;
      
        IF VAR_L_RETURN_VAL <> 0 THEN
          VAR_PO_RESPONSE_CODE    := 1210;
          VAR_PO_RESPONSE_MESSAGE := 'Database Error : AP_CM_RD_EXCHANGE_RATES';
          RETURN 1;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          VAR_PO_RESPONSE_CODE    := SQLCODE;
          VAR_PO_RESPONSE_MESSAGE := 'Exception occured while executing the Function AP_CM_RD_EXCHANGE_RATES';
          RETURN 1;
      END;
    
      IF TRIM(VAR_L_COD_CCY_SPREAD) = 'N' THEN
        VAR_L_ACCT_RATE := VAR_L_RATE_CCY;
      ELSIF TRIM(VAR_L_COD_CCY_SPREAD) = 'B' THEN
        VAR_L_ACCT_RATE := VAR_L_RATE_CCY - VAR_L_RATE_CCY_SPREAD;
      ELSIF TRIM(VAR_L_COD_CCY_SPREAD) = 'S' THEN
        VAR_L_ACCT_RATE := VAR_L_RATE_CCY + VAR_L_RATE_CCY_SPREAD;
      END IF;
    END IF;
  
    VAR_PO_ACCT_CCY_CONV_RATE := VAR_L_ACCT_RATE;
  
    IF VAR_PO_TXN_RATE <= 0 THEN
      BEGIN
        ---find Rate For Effective Date
        VAR_L_RATE_CCY          := 0;
        VAR_L_RATE_CCY_SPREAD   := 0;
        VAR_L_COD_CCY_SPREAD    := '';
        VAR_L_MLT_UNIT_RAT_QUOT := 0;
        VAR_L_FLG_CCY_CONV      := 0;
        VAR_PO_CTR_CCY_ROUND_TO := 0;
      
        VAR_L_RETURN_VAL := AP_CM_RD_EXCHANGE_RATES(PI_COD_LCY            => VAR_PI_COD_LCY,
                                                    VAR_COD_CCY           => VAR_PO_COD_TXN_CCY,
                                                    VAR_COD_TXN_MNEMONIC  => VAR_L_COD_TXN_MNEMONIC,
                                                    VAR_IP_DT             => VAR_PI_DAT_PROCESS,
                                                    VAR_FLG_SPRD_LCY_DEST => 'L',
                                                    VAR_RATE_CCY          => VAR_L_RATE_CCY,
                                                    VAR_RATE_CCY_SPREAD   => VAR_L_RATE_CCY_SPREAD,
                                                    VAR_COD_CCY_SPREAD    => VAR_L_COD_CCY_SPREAD,
                                                    VAR_MLT_UNIT_RAT_QUOT => VAR_L_MLT_UNIT_RAT_QUOT,
                                                    VAR_FLG_CCY_CONV      => VAR_L_FLG_CCY_CONV,
                                                    VAR_CTR_CCY_ROUND_TO  => VAR_PO_CTR_CCY_ROUND_TO);
      
        IF VAR_L_RETURN_VAL <> 0 THEN
          VAR_PO_RESPONSE_CODE    := 1210;
          VAR_PO_RESPONSE_MESSAGE := 'Database Error : AP_CM_RD_EXCHANGE_RATES';
          RETURN 1;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          VAR_PO_RESPONSE_CODE    := SQLCODE;
          VAR_PO_RESPONSE_MESSAGE := 'Exception occured while executing the Function AP_CM_RD_EXCHANGE_RATES';
          RETURN 1;
      END;
    
      IF TRIM(VAR_L_COD_CCY_SPREAD) = 'N' THEN
        VAR_PO_TXN_RATE := VAR_L_RATE_CCY;
      ELSIF TRIM(VAR_L_COD_CCY_SPREAD) = 'B' THEN
        VAR_PO_TXN_RATE := VAR_L_RATE_CCY - VAR_L_RATE_CCY_SPREAD;
      ELSIF TRIM(VAR_L_COD_CCY_SPREAD) = 'S' THEN
        VAR_PO_TXN_RATE := VAR_L_RATE_CCY + VAR_L_RATE_CCY_SPREAD;
      END IF;
    END IF;
  
    VAR_PO_TXN_CCY_CONV_RATE := VAR_PO_TXN_RATE;
  
    IF VAR_PI_COD_ACCT_CCY <> VAR_PI_COD_LCY THEN
      IF VAR_PO_TXN_RATE > 0 THEN
        VAR_L_CONVERTED_AMT := ROUND(VAR_PI_MONETARY_VALUE *
                                     VAR_PO_TXN_RATE,
                                     VAR_PO_CTR_CCY_ROUND_TO);
      ELSE
        BEGIN
          VAR_L_RETURN_VAL := AP_CM_AM_EXCHANGE(var_amt_src                => VAR_PI_MONETARY_VALUE,
                                                var_cod_src_ccy            => VAR_PI_COD_ACCT_CCY,
                                                var_cod_dest_ccy           => VAR_L_COD_ACCT_CCY,
                                                var_cod_txn_mnemonic       => VAR_L_COD_TXN_MNEMONIC,
                                                pi_cod_lcy                 => VAR_PI_COD_LCY,
                                                var_ip_dt                  => VAR_PI_DAT_PROCESS,
                                                var_mlt_unit_rat_quot_src  => 0,
                                                var_mlt_unit_rat_quot_dest => 0,
                                                var_flg_ccy_conv_src       => 0,
                                                var_flg_ccy_conv_dest      => 0,
                                                var_ctr_ccy_round_to_lcy   => NULL,
                                                var_ctr_ccy_round_to_dest  => NULL,
                                                var_rat_src                => NULL,
                                                var_rat_dest               => NULL,
                                                var_rat_base_src           => 0,
                                                var_rat_base_dest          => 0,
                                                var_rat_src_spread         => 0,
                                                var_rat_dest_spread        => 0,
                                                var_cod_ccy_spread_src     => NULL,
                                                var_cod_ccy_spread_dest    => NULL,
                                                var_amt_lcy                => var_l_amt_lcy,
                                                var_amt_dest               => var_l_converted_amt,
                                                var_rat_src_lcy            => var_L_rat_src_lcy,
                                                var_rat_lcy_dest           => var_l_rat_lcy_dest);
        
          IF VAR_L_RETURN_VAL <> 0 THEN
            VAR_PO_RESPONSE_CODE    := 1210;
            VAR_PO_RESPONSE_MESSAGE := 'Database Error : AP_CM_AM_EXCHANGE';
            RETURN 1;
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            VAR_PO_RESPONSE_CODE    := SQLCODE;
            VAR_PO_RESPONSE_MESSAGE := 'Exception occured while executing the Function AP_CM_AM_EXCHANGE';
            RETURN 1;
        END;
      END IF;
    
      VAR_PO_AMT_TXN_LCY := VAR_L_CONVERTED_AMT;
    END IF;
  
    IF VAR_PI_IS_TXN_CCY_BASED THEN
      IF VAR_L_COD_ACCT_CCY IS NOT NULL AND
         VAR_L_COD_ACCT_CCY <> VAR_PO_COD_TXN_CCY THEN
        IF VAR_L_COD_ACCT_CCY <> VAR_PI_COD_LCY THEN
          IF VAR_PO_TXN_RATE <> 0 THEN
            VAR_L_RAT_SRC := VAR_PO_TXN_RATE;
          
            SELECT MLT_UNIT_RAT_QUOT, FLG_CCY_CONV
              INTO var_l_mlt_unit_rat_quot_src, var_l_flg_ccy_conv_src
              FROM VWE_BA_CCY_CODE
             WHERE COD_CCY = VAR_PI_COD_ACCT_CCY
               AND FLG_MNT_STATUS = 'A';
          END IF;
        
          IF VAR_L_ACCT_RATE <> 0 THEN
            var_L_rat_dest := VAR_L_ACCT_RATE;
          
            SELECT MLT_UNIT_RAT_QUOT, FLG_CCY_CONV
              INTO var_l_mlt_unit_rat_quot_dest, var_l_flg_ccy_conv_dest
              FROM VWE_BA_CCY_CODE
             WHERE COD_CCY = VAR_L_COD_ACCT_CCY
               AND FLG_MNT_STATUS = 'A';
          END IF;
        
          BEGIN
            VAR_L_RETURN_VAL := AP_CM_AM_EXCHANGE(var_amt_src                => VAR_PI_MONETARY_VALUE,
                                                  var_cod_src_ccy            => VAR_PI_COD_ACCT_CCY,
                                                  var_cod_dest_ccy           => VAR_L_COD_ACCT_CCY,
                                                  var_cod_txn_mnemonic       => VAR_L_COD_TXN_MNEMONIC,
                                                  pi_cod_lcy                 => VAR_PI_COD_LCY,
                                                  var_ip_dt                  => VAR_PI_DAT_PROCESS,
                                                  var_mlt_unit_rat_quot_src  => var_l_mlt_unit_rat_quot_src,
                                                  var_mlt_unit_rat_quot_dest => var_l_mlt_unit_rat_quot_dest,
                                                  var_flg_ccy_conv_src       => var_l_flg_ccy_conv_src,
                                                  var_flg_ccy_conv_dest      => var_l_flg_ccy_conv_dest,
                                                  var_ctr_ccy_round_to_lcy   => NULL,
                                                  var_ctr_ccy_round_to_dest  => NULL,
                                                  var_rat_src                => var_l_rat_src,
                                                  var_rat_dest               => var_L_rat_dest,
                                                  var_rat_base_src           => NULL,
                                                  var_rat_base_dest          => NULL,
                                                  var_rat_src_spread         => NULL,
                                                  var_rat_dest_spread        => NULL,
                                                  var_cod_ccy_spread_src     => NULL,
                                                  var_cod_ccy_spread_dest    => NULL,
                                                  var_amt_lcy                => var_L_amt_lcy,
                                                  var_amt_dest               => var_L_amt_dest,
                                                  var_rat_src_lcy            => var_L_rat_src_lcy,
                                                  var_rat_lcy_dest           => var_L_rat_lcy_dest);
          
            IF VAR_L_RETURN_VAL <> 0 THEN
              VAR_PO_RESPONSE_CODE    := 1210;
              VAR_PO_RESPONSE_MESSAGE := 'Database Error : AP_CM_AM_EXCHANGE';
              RETURN 1;
            END IF;
          EXCEPTION
            WHEN OTHERS THEN
              VAR_PO_RESPONSE_CODE    := SQLCODE;
              VAR_PO_RESPONSE_MESSAGE := 'Exception occured while executing the Function AP_CM_AM_EXCHANGE';
              RETURN 1;
          END;
        
          VAR_PO_AMT_TXN_ACY        := var_L_amt_dest;
          VAR_PO_ACCT_CCY_CONV_RATE := var_L_rat_lcy_dest;
        ELSE
          VAR_PO_AMT_TXN_ACY := VAR_PO_AMT_TXN_LCY;
        END IF;
      END IF;
    ELSE
      IF VAR_PO_COD_TXN_CCY IS NOT NULL AND
         VAR_L_COD_ACCT_CCY <> VAR_PO_COD_TXN_CCY THEN
        IF VAR_PO_COD_TXN_CCY <> VAR_PI_COD_LCY THEN
          BEGIN
            VAR_L_RETURN_VAL := AP_CM_AM_EXCHANGE(var_amt_src                => VAR_PI_MONETARY_VALUE,
                                                  var_cod_src_ccy            => VAR_PI_COD_ACCT_CCY,
                                                  var_cod_dest_ccy           => VAR_PO_COD_TXN_CCY,
                                                  var_cod_txn_mnemonic       => VAR_L_COD_TXN_MNEMONIC,
                                                  pi_cod_lcy                 => VAR_PI_COD_LCY,
                                                  var_ip_dt                  => VAR_PI_DAT_PROCESS,
                                                  var_mlt_unit_rat_quot_src  => 0,
                                                  var_mlt_unit_rat_quot_dest => 0,
                                                  var_flg_ccy_conv_src       => 0,
                                                  var_flg_ccy_conv_dest      => 0,
                                                  var_ctr_ccy_round_to_lcy   => NULL,
                                                  var_ctr_ccy_round_to_dest  => NULL,
                                                  var_rat_src                => NULL,
                                                  var_rat_dest               => NULL,
                                                  var_rat_base_src           => 0,
                                                  var_rat_base_dest          => 0,
                                                  var_rat_src_spread         => 0,
                                                  var_rat_dest_spread        => 0,
                                                  var_cod_ccy_spread_src     => NULL,
                                                  var_cod_ccy_spread_dest    => NULL,
                                                  var_amt_lcy                => var_L_amt_lcy,
                                                  var_amt_dest               => var_L_amt_dest,
                                                  var_rat_src_lcy            => var_L_rat_src_lcy,
                                                  var_rat_lcy_dest           => var_L_rat_lcy_dest);
          
            IF VAR_L_RETURN_VAL <> 0 THEN
              VAR_PO_RESPONSE_CODE    := 1210;
              VAR_PO_RESPONSE_MESSAGE := 'Database Error : AP_CM_AM_EXCHANGE';
              RETURN 1;
            END IF;
          EXCEPTION
            WHEN OTHERS THEN
              VAR_PO_RESPONSE_CODE    := SQLCODE;
              VAR_PO_RESPONSE_MESSAGE := 'Exception occured while executing the Function AP_CM_AM_EXCHANGE';
              RETURN 1;
          END;
        
          VAR_PO_AMT_TXN_TCY       := var_L_amt_dest;
          VAR_PO_TXN_CCY_CONV_RATE := var_L_rat_lcy_dest;
        ELSE
          VAR_PO_AMT_TXN_TCY := VAR_PO_AMT_TXN_LCY;
        END IF;
      END IF;
    END IF;
  
    RETURN 0;
  EXCEPTION
    WHEN OTHERS THEN
      VAR_PO_RESPONSE_CODE    := SQLCODE;
      VAR_PO_RESPONSE_MESSAGE := 'Exception occured while executing the Function AP_OL_PREPARE_TXN_VAL_COMMON';
      RETURN 1;
  END AP_OL_PREPARE_TXN_VAL_COMMON;

  FUNCTION AP_OL_CHECK_EXT_RESP_NGI(PI_INPUT_STR        IN VARCHAR2,
                                    PI_OVERWRITE_STR    IN VARCHAR2,
                                    PO_RESPONSE_CODE    OUT VARCHAR2,
                                    PO_RESPONSE_MESSAGE OUT VARCHAR2)
    RETURN NUMBER IS
    SUBTYPE T_STRING_LIST IS DBMS_SQL.VARCHAR2A;
  
    L_STRING_MATCHES       T_STRING_LIST;
    L_STRING_AVOID_STR     T_STRING_LIST;
    P_MATCH_PATTERN        VARCHAR2(10) := '\d+';
    L_BA_ERR_DEFS_EXT_CODE VARCHAR2(20);
    L_EXT_STRING           VARCHAR2(2000);
    L_FIRST_UNMATCH_FOUND  BOOLEAN := FALSE;
  BEGIN
    BEGIN
      --  codes the host reported
      SELECT REGEXP_SUBSTR(PI_INPUT_STR, P_MATCH_PATTERN, 1, LEVEL) STR BULK COLLECT
        INTO L_STRING_MATCHES
        FROM DUAL
      CONNECT BY LEVEL <= REGEXP_COUNT(PI_INPUT_STR, P_MATCH_PATTERN)
       ORDER BY LEVEL ASC;
    
      --  codes this service may override
      SELECT REGEXP_SUBSTR(PI_OVERWRITE_STR, P_MATCH_PATTERN, 1, LEVEL) STR BULK COLLECT
        INTO L_STRING_AVOID_STR
        FROM DUAL
      CONNECT BY LEVEL <= REGEXP_COUNT(PI_OVERWRITE_STR, P_MATCH_PATTERN)
       ORDER BY LEVEL ASC;
    EXCEPTION
      WHEN OTHERS THEN
        PO_RESPONSE_CODE    := SQLCODE;
        PO_RESPONSE_MESSAGE := SQLERRM(SQLCODE);
    END;
  
    FOR I IN 1 .. L_STRING_MATCHES.COUNT LOOP
      DECLARE
        IS_FOUND BOOLEAN := FALSE;
      BEGIN
        FOR J IN 1 .. L_STRING_AVOID_STR.COUNT LOOP
          IF L_STRING_MATCHES(I) = L_STRING_AVOID_STR(J) THEN
            IS_FOUND := TRUE;
            EXIT;
          END IF;
        END LOOP;
      
        --  only codes that may not be overridden reach the caller
        IF NOT IS_FOUND THEN
          L_BA_ERR_DEFS_EXT_CODE := 'EXT_RSP9' ||
                                    LPAD(L_STRING_MATCHES(I), 3, '0');
        
          --  the first of them becomes the response code
          IF NOT L_FIRST_UNMATCH_FOUND THEN
            PO_RESPONSE_CODE      := L_STRING_MATCHES(I);
            L_FIRST_UNMATCH_FOUND := TRUE;
          END IF;
        
          BEGIN
            -- ====================================================
            --  NGI-194.  Same index-killer as the account lookup,
            --  and this one sits INSIDE the loop above, so it ran
            --  once per error code, twice per payment.
            --
            --  Measured: TRIM (COD_ERR) = ...  -> cost 4,995,
            --  TABLE ACCESS FULL of BA_ERR_DEFS (18,424 blocks)
            --  EVERY time round the loop.
            --
            --  COD_ERR is CHAR(12); the value ('EXT_RSP9nnn') is 11
            --  characters, so it is padded to 12 to keep the CHAR
            --  comparison working, with the padding on the VALUE so
            --  the index on the column stays usable.
            -- ====================================================
            SELECT ERR_DESCRIPTION
              INTO L_EXT_STRING
              FROM BA_ERR_DEFS
             WHERE COD_ERR = RPAD(TRIM(L_BA_ERR_DEFS_EXT_CODE), 12, ' ');
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              PO_RESPONSE_CODE    := '80820';
              PO_RESPONSE_MESSAGE := 'Error definition could not be found - fatal error.';
            WHEN OTHERS THEN
              PO_RESPONSE_CODE    := '80820';
              PO_RESPONSE_MESSAGE := 'Error definition could not be found - fatal error.';
          END;
        
          PO_RESPONSE_MESSAGE := CASE WHEN PO_RESPONSE_MESSAGE IS NULL THEN L_EXT_STRING ELSE PO_RESPONSE_MESSAGE || ';' || L_EXT_STRING END;
        END IF;
      END;
    END LOOP;
  
    RETURN 0;
  EXCEPTION
    WHEN OTHERS THEN
      PO_RESPONSE_CODE    := SQLCODE;
      PO_RESPONSE_MESSAGE := SQLERRM(SQLCODE);
      RETURN 100;
  END AP_OL_CHECK_EXT_RESP_NGI;
END PK_OL_XFINT;

