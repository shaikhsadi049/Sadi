package com.oracle.fcr.ngi.customer.inq.dbutil;

import com.oracle.fcr.ngi.dbutil.Function;
import com.oracle.fcr.ngi.exception.NGISQLException;
import com.oracle.fcr.ngi.model.CustomError;
import com.oracle.fcr.ngi.util.GlobalConstant;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.SqlOutParameter;
import org.springframework.jdbc.core.SqlParameter;
import org.springframework.stereotype.Component;

import javax.sql.DataSource;
import java.math.BigDecimal;
import java.sql.Types;
import java.util.Collections;
import java.util.Map;

@Component
public class ProcedureExecutorCustomerInq {
	public static final String FUNC_AP_LN_GET_UNBILLED_PENALTY = "AP_LN_GET_UNBILLED_PENALTY";
	@Autowired
//	@Qualifier("mainDataSource")
	private DataSource mainDataSource;

	@Autowired
	@Qualifier("mainJdbcTemplate")
	private JdbcTemplate mainJdbcTemplate;

	private static final Logger LOGGER = LoggerFactory.getLogger(ProcedureExecutorCustomerInq.class);

	public BigDecimal getUnbilledPenalty(String accountNo) throws NGISQLException {

		LOGGER.info("\n\n ----------------------------Start procedure call: {} ------------------------------\n\n",
				FUNC_AP_LN_GET_UNBILLED_PENALTY);
		BigDecimal varRatPenaltyInt = BigDecimal.valueOf(0);
		Function procedure = new Function(mainJdbcTemplate, FUNC_AP_LN_GET_UNBILLED_PENALTY);

		procedure.setParameters(getAplnGetUnbilledPenaltyFuncParam());
		LOGGER.info("Compiling procedure: {}", FUNC_AP_LN_GET_UNBILLED_PENALTY);
		procedure.compile();
		LOGGER.info("Executing procedure: {}", FUNC_AP_LN_GET_UNBILLED_PENALTY);

		LOGGER.info("Procedure({}) parameter's values: {}", FUNC_AP_LN_GET_UNBILLED_PENALTY, accountNo);
		Map<String, Object> outValues = null;
		try {
			outValues = procedure.execute(accountNo);
		} catch (Exception ex) {
			LOGGER.error("Error Track is:::-------", ex);
			CustomError error = new CustomError(GlobalConstant.SOMETHING_WRONG_ERROR_CODE, ex.getCause().getMessage(),
					GlobalConstant.SOMETHING_WRONG_ERROR_MESSAGE);
			throw new NGISQLException(Collections.singletonList(error));
		}

		LOGGER.info("\n\n ----------------------------End procedure call: {} ------------------------------\n\n",
				FUNC_AP_LN_GET_UNBILLED_PENALTY);
		if (!outValues.get("VAR_l_RET_VAL").equals(0)) {
			return varRatPenaltyInt;
		}
		Float ratPenaltyInt = ((Double) outValues.get("var_po_rat_penalty_int")).floatValue();
		varRatPenaltyInt = new BigDecimal(ratPenaltyInt.doubleValue());
		return varRatPenaltyInt;
	}

	private SqlParameter[] getAplnGetUnbilledPenaltyFuncParam() {
		LOGGER.info("Preparing procedure parameters: {}", FUNC_AP_LN_GET_UNBILLED_PENALTY);

		SqlParameter acctNo = new SqlParameter("pi_cod_acct_no", Types.VARCHAR);
		SqlParameter panelty = new SqlOutParameter("var_po_rat_penalty_int", Types.DOUBLE);
		SqlOutParameter returnValue = new SqlOutParameter("VAR_l_RET_VAL", Types.INTEGER);

		SqlParameter[] parameters = { returnValue, acctNo, panelty};
		LOGGER.info("Procedure parameters prepared: {}", FUNC_AP_LN_GET_UNBILLED_PENALTY);
		return parameters;
	}

}
