package com.oracle.fcr.ngi.customer.inq.dbutil;

import com.oracle.fcr.ngi.customer.inq.exception.payload.dto.ReturnVOApILFCCCheck;
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
import java.sql.Types;
import java.util.Collections;
import java.util.Map;

@Component
public class ProcedureExecutorFccCheck {
	public static final String FUNC_AP_IL_FCC_CHECK = "AP_IL_FCC_CHECK";
	public static final String RULE_PREFIX = "MWF_RULE_ONL_";
	@Autowired
//	@Qualifier("mainDataSource")
	private DataSource mainDataSource;

	@Autowired
	@Qualifier("mainJdbcTemplate")
	private JdbcTemplate mainJdbcTemplate;

	private static final Logger LOGGER = LoggerFactory.getLogger(ProcedureExecutorFccCheck.class);

	public ReturnVOApILFCCCheck getGetFccCheck(String ruleId, String channelId, String codSearch) throws NGISQLException {

		LOGGER.info("\n\n ----------------------------Start  procedure call: {} ------------------------------\n\n",
				FUNC_AP_IL_FCC_CHECK);
		ruleId = RULE_PREFIX + ruleId;
		ReturnVOApILFCCCheck returnVOApILFCCCheck = new ReturnVOApILFCCCheck();
		Function procedure = new Function(mainJdbcTemplate, FUNC_AP_IL_FCC_CHECK);

		procedure.setParameters(getApIlFccCheckFuncParam());
		LOGGER.info("Compiling procedure: {}", FUNC_AP_IL_FCC_CHECK);
		procedure.compile();
		LOGGER.info("Executing procedure: {}", FUNC_AP_IL_FCC_CHECK);
		String funcParams = "ruleId = " + ruleId + " channelId = " + channelId + " codSearch = " + codSearch;
		LOGGER.info("Procedure({}) parameter's values: {}", FUNC_AP_IL_FCC_CHECK, funcParams);
		Map<String, Object> outValues = null;
		try {
			outValues = procedure.execute(ruleId, channelId, codSearch);
		} catch (Exception ex) {
			LOGGER.error("Error Track is:::-------", ex);
			CustomError error = new CustomError(GlobalConstant.SOMETHING_WRONG_ERROR_CODE, ex.getCause().getMessage(),
					GlobalConstant.SOMETHING_WRONG_ERROR_MESSAGE);
			throw new NGISQLException(Collections.singletonList(error));
		}

		LOGGER.info("\n\n ----------------------------End procedure call: {} ------------------------------\n\n",
				FUNC_AP_IL_FCC_CHECK);
		Integer returnValue  = (Integer) outValues.get("VAR_l_RET_VAL");
		if (returnValue != 0) {
			return returnVOApILFCCCheck;
		}
		String flgReplicate = String.valueOf( outValues.get("var_pio_flg_replicate"));
		String errMsg = String.valueOf( outValues.get("var_pio_err_msg"));
		String params = "flgReplicate = " + flgReplicate + " errMsg = " + errMsg + " returnValue = " + returnValue;
		LOGGER.info("Procedure({}) return values: {}", FUNC_AP_IL_FCC_CHECK, params);
		returnVOApILFCCCheck.setFlgReplicate(flgReplicate);
		returnVOApILFCCCheck.setErrMsg(errMsg);
		returnVOApILFCCCheck.setReturnValue(returnValue);
		return returnVOApILFCCCheck;
	}

	private SqlParameter[] getApIlFccCheckFuncParam() {
		LOGGER.info("Preparing procedure parameters: {}", FUNC_AP_IL_FCC_CHECK);

		SqlParameter ruleId = new SqlParameter("var_pi_rule_name", Types.VARCHAR);
		SqlParameter channelId = new SqlParameter("var_pi_channel", Types.VARCHAR);
		SqlParameter codSearch = new SqlParameter("var_pi_cod_search", Types.VARCHAR);

		SqlParameter flgReplicate = new SqlOutParameter("var_pio_flg_replicate", Types.CHAR);
		SqlParameter errMsg = new SqlOutParameter("var_pio_err_msg", Types.VARCHAR);
		SqlOutParameter returnValue = new SqlOutParameter("VAR_l_RET_VAL", Types.INTEGER);

		SqlParameter[] parameters = { returnValue, ruleId, channelId, codSearch, flgReplicate, errMsg};
		LOGGER.info("Procedure parameters prepared: {}", FUNC_AP_IL_FCC_CHECK);
		return parameters;
	}

}
