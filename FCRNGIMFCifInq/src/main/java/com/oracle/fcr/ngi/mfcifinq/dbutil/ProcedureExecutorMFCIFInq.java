package com.oracle.fcr.ngi.mfcifinq.dbutil;
import java.sql.Types;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.SqlOutParameter;
import org.springframework.jdbc.core.SqlParameter;
import org.springframework.stereotype.Component;

import com.oracle.fcr.ngi.dbutil.Function;
import com.oracle.fcr.ngi.dbutil.Procedure;
import com.oracle.fcr.ngi.exception.NGISQLException;
import com.oracle.fcr.ngi.mfcifinq.payload.request.CustomerInqMFCIFInqWrapperReq;
import com.oracle.fcr.ngi.mfcifinq.payload.response.MFCifInfoRes;
import com.oracle.fcr.ngi.mfcifinq.payload.response.MFCifInqResponse;
import com.oracle.fcr.ngi.model.CustomError;
import com.oracle.fcr.ngi.util.GlobalConstant;
import lombok.RequiredArgsConstructor;

@Component
@RequiredArgsConstructor(onConstructor_ = {@Autowired} )
public class ProcedureExecutorMFCIFInq {
    // Write your logic


	 public static final String FUNC_AP_NGI_EXT_MF_CIF_INQ = "ap_ngi_ext_mf_cif_inq";
	    
	    private final JdbcTemplate mainJdbcTemplate;
	   // private final ChannelHelper channelHelper;
	    
		private static final Logger LOGGER = LoggerFactory.getLogger(ProcedureExecutorMFCIFInq.class);

		public List<MFCifInfoRes> getMFCifsumData(CustomerInqMFCIFInqWrapperReq req,String acctId,String acctType) throws NGISQLException {

			LOGGER.info("\n\n ----------------------------Start procedure call: {} ------------------------------\n\n",
					FUNC_AP_NGI_EXT_MF_CIF_INQ);
			Function procedure = new Function(mainJdbcTemplate, FUNC_AP_NGI_EXT_MF_CIF_INQ);
	        procedure.setParameters(getApNgiExtMfCIFINQFuncParam());
	        procedure.compile();

			
	        Map<String, Object> inParams = new HashMap<>();
	        inParams.put("var_pi_trace_id", req.getTraceId());
	        inParams.put("var_pi_channel_id", req.getChannelId());
	        inParams.put("var_pi_serv_code", req.getSvcCode());
	        inParams.put("var_pi_svc_rq_id", req.getSvcRequestId());
	        inParams.put("var_pi_dat_txn", req.getTxnDate());
	        inParams.put("var_pi_id", acctId);
	        inParams.put("var_pi_id_type", acctType);
	        
	                  
			LOGGER.info("Procedure({}) parameter's values: {}", FUNC_AP_NGI_EXT_MF_CIF_INQ, req.toString());
			Map<String, Object> outValues = null;
			try {
				System.out.println("ap_ngi_ext_mf_cif_inq Start time"+LocalDateTime.now());
			//	outValues = jdbcCall.execute(inParams);
				outValues=procedure.execute(inParams);
				System.out.println("ap_ngi_ext_mf_cif_inq End Time"+LocalDateTime.now());
			} catch (Exception ex) {
				LOGGER.error("Error Track is:::-------", ex);
				CustomError error = new CustomError(GlobalConstant.SOMETHING_WRONG_ERROR_CODE, ex.getCause().getMessage(),
						GlobalConstant.SOMETHING_WRONG_ERROR_MESSAGE);
				throw new NGISQLException(Collections.singletonList(error));
			}

			LOGGER.info("\n\n ----------------------------End procedure call: {} ------------------------------\n\n",
					FUNC_AP_NGI_EXT_MF_CIF_INQ);

	        if (!outValues.get("v_result").equals(0)) {
	            CustomError error = new CustomError(
	            		String.valueOf(outValues.get("var_po_response_code")),
	            		 String.valueOf(outValues.get("var_po_response_msg")),   
	                    org.springframework.http.HttpStatus.INTERNAL_SERVER_ERROR.getReasonPhrase()
	            );
	            	throw new NGISQLException(Collections.singletonList(error));
	        }
			
			List<MFCifInfoRes> res=MFCIFInqResWrapper.mapToWrapperCIFInqRes(outValues,req.getAcctId(),req.getTypeId());
			 //List<MFCifInqResponse> result = (List<MFCifInqResponse>) outValues.get("var_po_inq_result");
			// List<AcctRec> result = (HashMap<AcctRec>) outValues.get("cursname");
			 
			
			 
			 
			 //response.setAcctSummRs(acctSumm);
			return res;
		}
		private SqlParameter[] getApNgiExtMfCIFINQFuncParam() {
			LOGGER.info("Preparing procedure parameters: {}", FUNC_AP_NGI_EXT_MF_CIF_INQ);
			
			SqlParameter traceId = new SqlParameter("var_pi_trace_id", Types.VARCHAR);
	        SqlParameter channelId = new SqlParameter("var_pi_channel_id", Types.VARCHAR);
			SqlParameter serviceCode = new SqlParameter("var_pi_serv_code", Types.VARCHAR);
	        SqlParameter servReqId = new SqlParameter("var_pi_svc_rq_id", Types.VARCHAR);
	        SqlParameter datTxn = new SqlParameter("var_pi_dat_txn", Types.VARCHAR);
	        SqlParameter acctId = new SqlParameter("var_pi_id", Types.VARCHAR);
	        SqlParameter acctType = new SqlParameter("var_pi_id_type", Types.VARCHAR);
	        SqlOutParameter responseMsg = new SqlOutParameter("var_po_response_msg", Types.VARCHAR);
	        SqlOutParameter responseCode = new SqlOutParameter("var_po_response_code", Types.VARCHAR);
	        SqlOutParameter cursName = new SqlOutParameter("var_po_inq_result", Types.REF_CURSOR);
	        
	        SqlOutParameter returnValue = new SqlOutParameter("v_result", Types.INTEGER);

	        SqlParameter[] parameters = {
	        		returnValue,traceId,channelId,serviceCode,servReqId,datTxn,acctId,acctType,responseCode,responseMsg,cursName
	        };
	       /* SqlParameter[] parameters = {
	                returnValue,cifId,acctType,maxrecIn,nextRecIn,matchedRecIn,channelIdOut,svcCodeout,
	                svcrqIdout,maxRecOut,nextRecOut,matchedRecOut,statusCode,fccAvail,email,verCode,branchCode,cursName,responseCode, responseMessage};*/
			LOGGER.info("Procedure parameters prepared: {}", FUNC_AP_NGI_EXT_MF_CIF_INQ);
			return parameters;
		}
}
