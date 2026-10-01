package com.oracle.fcr.ngi.mfcifinq.payload.response;

import com.oracle.fcr.ngi.payload.response.Response;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.io.Serializable;
import java.util.List;

@Getter
@Setter
@NoArgsConstructor
public class MFCifInqResponse implements Response, Serializable {

	private static final long serialVersionUID = 7984978975120510419L;

	private String responseCode;
	private String responseMessage;
	private String typeId;
	private String acctId;
	private List<MFCifInfoRes> cifInfo;
	
	
	
	
	
	@Override
	public String toString() {
		return "TestResponse [ responseMessage=" + responseMessage + ", responseCode="
				+ responseCode + "]";
	}

}
