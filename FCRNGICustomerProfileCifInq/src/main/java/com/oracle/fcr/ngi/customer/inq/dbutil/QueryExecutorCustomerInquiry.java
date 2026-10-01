package com.oracle.fcr.ngi.customer.inq.dbutil;
import com.oracle.fcr.ngi.il.model.CasaMiniInfo;
import java.util.Collections;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
public class QueryExecutorCustomerInquiry {
    public static final String GET_CH_CUST_ID_BY_ACCT_NO = "select COD_CUST as customerId, COD_ACCT_STAT as accountStatus" +
            " from vwe_ch_acct_mast where LPAD(TRIM(cod_acct_no), 20, 0) = LPAD('%s', 20, 0) and flg_mnt_status = 'A' and rownum < 2";

    public static final String GET_LN_CUST_ID_BY_ACCT_NO = "select COD_CUST_ID as customerId, COD_ACCT_STAT as accountStatus" +
            " from ln_acct_mast where LPAD(TRIM(cod_acct_no), 20, 0) = LPAD('%s', 20, 0) and flg_mnt_status = 'A' and rownum < 2";

    public static final String GET_TD_CUST_ID_BY_ACCT_NO = "select COD_CUST as customerId, COD_ACCT_STAT as accountStatus" +
            " from vwe_td_acct_mast where LPAD(TRIM(cod_acct_no), 20, 0) = LPAD('%s', 20, 0) and flg_mnt_status = 'A' and rownum < 2";

    public static final String GET_UDF_FIELD_VALUE_BY_CUST_ID = "select field_value" +
            " from udf_cust_log_details" +
            " where cod_field_tag = '%s'" +
            " and cod_cust_id = '%s'" +
            " and cod_task = '%s'" +
            " and flg_mnt_status ='A' and rownum < 2";

    public static final String GET_NATIONAL_ID_BY_CUSTOMER_ID = "select cod_cust_natl_id" +
            " from ci_custmast where cod_cust_id = ? and rownum < 2";

    public static final String GET_ATM_CARD_BY_CUSTOMER_ID = "select cod_Card_no from" +
            " ( select cod_Card_no , rank() over (ORDER BY dat_issue asc , dat_last_mnt asc ) last_issued" +
            " from cm_custcard_mast where cod_Cust_id = ? and flg_card_status = '2'  and flg_mnt_status = 'A' )" +
            " where last_issued  = 1   and rownum < 2";


    @Autowired
    private JdbcTemplate mainJdbcTemplate;
    private static final Logger logger = LoggerFactory.getLogger(QueryExecutorCustomerInquiry.class);
    public String getUdfFieldValueByCustId(String customerId, String fieldTag, String mntCustomer){
        String sql = String.format(GET_UDF_FIELD_VALUE_BY_CUST_ID, fieldTag, customerId, mntCustomer);
        try {
            logger.info("Sql getUdfFieldValueByCustId {}", sql);
            return mainJdbcTemplate.queryForObject(sql, String.class);
        } catch (EmptyResultDataAccessException e) {
            return null;
        }
    }
    public String getNationalIdByCustomerId(long customerId){
        try {
            logger.info("Sql getNationalIdByCustomerId {}", GET_NATIONAL_ID_BY_CUSTOMER_ID);
            return mainJdbcTemplate.queryForObject(GET_NATIONAL_ID_BY_CUSTOMER_ID, String.class, customerId);
        } catch (EmptyResultDataAccessException e) {
            return null;
        }
    }
    public String getAtmCardNoByCustomerId(long customerId){
        try {
            return mainJdbcTemplate.queryForObject(GET_ATM_CARD_BY_CUSTOMER_ID, String.class, customerId);
        } catch (EmptyResultDataAccessException e) {
            return null;
        }
    }
    public List<CasaMiniInfo> getCHCustIdByAcct(String accountNo){
        try {
            String query = String.format(GET_CH_CUST_ID_BY_ACCT_NO, accountNo);
            return mainJdbcTemplate.query(query, new BeanPropertyRowMapper<>(CasaMiniInfo.class));
        } catch (EmptyResultDataAccessException e) {
            return Collections.emptyList();
        }
    }
    public List<CasaMiniInfo> getLNCustIdByAcct(String accountNo){
        try {
            String query = String.format(GET_LN_CUST_ID_BY_ACCT_NO, accountNo);
            return mainJdbcTemplate.query(query, new BeanPropertyRowMapper<>(CasaMiniInfo.class));
        } catch (EmptyResultDataAccessException e) {
            return Collections.emptyList();
        }
    }
    public List<CasaMiniInfo> getTDCustIdByAcct(String accountNo){
        try {
            String query = String.format(GET_TD_CUST_ID_BY_ACCT_NO, accountNo);
            return mainJdbcTemplate.query(query, new BeanPropertyRowMapper<>(CasaMiniInfo.class));
        } catch (EmptyResultDataAccessException e) {
            return Collections.emptyList();
        }
    }

}
