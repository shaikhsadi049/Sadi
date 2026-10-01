package com.oracle.fcr.ngi.mfcifinq.dbutil;
import com.oracle.fcr.ngi.exception.GlobalException;
import com.oracle.fcr.ngi.il.model.CasaMiniInfo;
import com.oracle.fcr.ngi.il.utils.AccountFactory;

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

    @Autowired
    private JdbcTemplate mainJdbcTemplate;
    private static final Logger logger = LoggerFactory.getLogger(QueryExecutorCustomerInquiry.class);

    /** Customer maintenance task the customer user defined fields are captured under. */
    public static final String MNT_CUSTOMER = "CIM09";
    
    public static final String GET_CUSTID_BY_ATM_CARD="select cod_cust_id from cm_x_custcard_acct_xref WHERE cod_card_no = ? AND flg_mnt_status='A' AND flg_link_unlink='L' AND ROWNUM = 1";

    /**
     * Reads a customer user defined field by its field tag. A customer can hold the same field tag
     * under more than one maintenance task, so the customer maintenance task (CIM09) is preferred
     * and the remaining tasks are ordered by task code to keep the result deterministic.
     */
    public static final String GET_UDF_FIELD_VALUE_BY_CUST_ID = "select field_value from (" +
            " select field_value from udf_cust_log_details" +
            " where cod_field_tag = ?" +
            " and cod_cust_id = ?" +
            " and flg_mnt_status = 'A'" +
            " order by case when cod_task = '" + MNT_CUSTOMER + "' then 0 else 1 end, cod_task" +
            " ) where rownum < 2";

    public static final String GET_NATIONAL_ID_BY_CUSTOMER_ID = "select cod_cust_natl_id" +
            " from ci_custmast where cod_cust_id = ? and rownum < 2";

    public String getCustomerIdByAtmCard(String cardNumber){
        try {
            return mainJdbcTemplate.queryForObject(GET_CUSTID_BY_ATM_CARD, String.class, cardNumber);
        } catch (EmptyResultDataAccessException e) {
            return null;
        }
    }

    public String getUdfFieldValueByCustId(String customerId, String fieldTag){
        try {
            logger.info("Sql getUdfFieldValueByCustId for customer {} and field tag {}", customerId, fieldTag);
            return mainJdbcTemplate.queryForObject(GET_UDF_FIELD_VALUE_BY_CUST_ID, String.class, fieldTag, customerId);
        } catch (EmptyResultDataAccessException e) {
            return null;
        }
    }

    public String getNationalIdByCustomerId(String customerId){
        try {
            logger.info("Sql getNationalIdByCustomerId for customer {}", customerId);
            return mainJdbcTemplate.queryForObject(GET_NATIONAL_ID_BY_CUSTOMER_ID, String.class, customerId);
        } catch (EmptyResultDataAccessException e) {
            return null;
        }
    }
  
    
    
   
}
