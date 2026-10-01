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
    
    public static final String GET_CUSTID_BY_ATM_CARD="select cod_cust_id from cm_x_custcard_acct_xref WHERE cod_card_no = ? AND flg_mnt_status='A' AND flg_link_unlink='L' AND ROWNUM = 1";
  
    public String getCustomerIdByAtmCard(String cardNumber){
        try {
            return mainJdbcTemplate.queryForObject(GET_CUSTID_BY_ATM_CARD, String.class, cardNumber);
        } catch (EmptyResultDataAccessException e) {
            return null;
        }
    }
  
    
    
   
}
