package com.oracle.fcr.ngi.mfcifinq.dbutil;

import java.sql.Types;
import java.time.LocalDateTime;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.SqlOutParameter;
import org.springframework.jdbc.core.SqlParameter;
import org.springframework.jdbc.core.simple.SimpleJdbcCall;
import org.springframework.stereotype.Component;

import com.oracle.fcr.ngi.dbutil.Function;
import com.oracle.fcr.ngi.exception.NGISQLException;
import com.oracle.fcr.ngi.mfcifinq.payload.request.CustomerInqMFCIFInqWrapperReq;
import com.oracle.fcr.ngi.mfcifinq.payload.response.MFCifInqResponse;
import com.oracle.fcr.ngi.mfcifinq.payload.response.MFCifInqAcctDet;
import com.oracle.fcr.ngi.model.CustomError;
import com.oracle.fcr.ngi.util.GlobalConstant;

import lombok.RequiredArgsConstructor;

@Component
@RequiredArgsConstructor(onConstructor_ = {@Autowired} )
public class ProcedureExecutorMFAcctCIFInq {
	 public static final String FUNC_AP_NGI_EXT_MF_CIF_ACCT_INQ = "ap_ngi_ext_mf_cif_acctinq";
	    
	    private final JdbcTemplate mainJdbcTemplate;
	   // private final ChannelHelper channelHelper;
	    
		private static final Logger LOGGER = LoggerFactory.getLogger(ProcedureExecutorMFCIFInq.class);

		public MFCifInqResponse getMFCifSumAcctData(CustomerInqMFCIFInqWrapperReq req,String acctId,String acctType,MFCifInqResponse res) throws NGISQLException {

			LOGGER.info("\n\n ----------------------------Start procedure call: {} ------------------------------\n\n",
					FUNC_AP_NGI_EXT_MF_CIF_ACCT_INQ);
			Function procedure = new Function(mainJdbcTemplate, FUNC_AP_NGI_EXT_MF_CIF_ACCT_INQ);
	        procedure.setParameters(getApNgiExtMfCIFAcctFuncParam());
	        procedure.compile();

			
			
	        Map<String, Object> inParams = new HashMap<>();
	        inParams.put("VAR_PI_ID", acctId);
	        inParams.put("VAR_PI_ID_TYPE", acctType);
	        
	        
	        
	                  
			LOGGER.info("Procedure({}) parameter's values: {}", FUNC_AP_NGI_EXT_MF_CIF_ACCT_INQ, req.toString());
			Map<String, Object> outValues = null;
			try {
				System.out.println("Start time"+LocalDateTime.now());
				//outValues = jdbcCall.execute(inParams);
				outValues=procedure.execute(inParams);
				System.out.println("End Time"+LocalDateTime.now());
			} catch (Exception ex) {
				LOGGER.error("Error Track is:::-------", ex);
				CustomError error = new CustomError(GlobalConstant.SOMETHING_WRONG_ERROR_CODE, ex.getCause().getMessage(),
						GlobalConstant.SOMETHING_WRONG_ERROR_MESSAGE);
				throw new NGISQLException(Collections.singletonList(error));
			}

			LOGGER.info("\n\n ----------------------------End procedure call: {} ------------------------------\n\n",
					FUNC_AP_NGI_EXT_MF_CIF_ACCT_INQ);

	        if (!outValues.get("v_result").equals(0)) {
	            CustomError error = new CustomError(
	            		String.valueOf(outValues.get("var_po_response_code")),
	            		 String.valueOf(outValues.get("var_po_response_msg")),   
	                    org.springframework.http.HttpStatus.INTERNAL_SERVER_ERROR.getReasonPhrase()
	            );
	            	throw new NGISQLException(Collections.singletonList(error));
	        }
			
			MFCifInqResponse response=MFCIFInqAcctResWrapper.mapToWrappeCifInqAcctRes(outValues, res);
			 //List<MFCifInqResponse> result = (List<MFCifInqResponse>) outValues.get("var_po_inq_result");
			// List<AcctRec> result = (HashMap<AcctRec>) outValues.get("cursname");
			 
			
			// MFCifInqResponse response= new MFCifInqResponse();
			response.setAcctId(req.getAcctId());
			response.setTypeId(req.getTypeId());
			 response.setResponseCode(GlobalConstant.SUCCESS_CODE);
			 response.setResponseMessage(GlobalConstant.SUCCESS_MESSAGE);
			 
			 //response.setAcctSummRs(acctSumm);
			return response;
		}
		private SqlParameter[] getApNgiExtMfCIFAcctFuncParam() {
			LOGGER.info("Preparing procedure parameters: {}", FUNC_AP_NGI_EXT_MF_CIF_ACCT_INQ);
	        
	       
	        SqlParameter acctId = new SqlParameter("VAR_PI_ID", Types.VARCHAR);
	        
	        SqlParameter acctType = new SqlParameter("VAR_PI_ID_TYPE", Types.VARCHAR);
	        SqlOutParameter acctInqCur = new SqlOutParameter("VAR_O_INQ_RESULT", Types.REF_CURSOR);
	        SqlOutParameter resCode = new SqlOutParameter("var_po_response_code", Types.VARCHAR);
	        SqlOutParameter resMsg = new SqlOutParameter("var_po_response_msg", Types.VARCHAR);
	        //SqlOutParameter joinholderCur = new SqlOutParameter("var_o_join_holder", Types.REF_CURSOR);
	        SqlOutParameter returnValue = new SqlOutParameter("v_result", Types.INTEGER);

	        SqlParameter[] parameters = {
	        		returnValue,acctId,acctType,resCode,resMsg,acctInqCur
	        };
	       /* SqlParameter[] parameters = {
	                returnValue,cifId,acctType,maxrecIn,nextRecIn,matchedRecIn,channelIdOut,svcCodeout,
	                svcrqIdout,maxRecOut,nextRecOut,matchedRecOut,statusCode,fccAvail,email,verCode,branchCode,cursName,responseCode, responseMessage};*/
			LOGGER.info("Procedure parameters prepared: {}", FUNC_AP_NGI_EXT_MF_CIF_ACCT_INQ);
			return parameters;
		}
}
