package com.oracle.fcr.ngi.customer.inq.exception.payload.response;

import com.oracle.fcr.ngi.payload.response.Response;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.io.Serializable;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class CustomerProfileInquiryCifinqResponse implements Response, Serializable {

	private static final long serialVersionUID = 1252283855499376366L;

	private String responseCode;
	private String responseMessage;
	private CifRec cifRec;

	@Override
	public String toString() {
		return "CustomerProfileInquiryCifinqResponse{" +
				"responseCode='" + responseCode + '\'' +
				", responseMessage='" + responseMessage + '\'' +
				", cifRec=" + cifRec +
				'}';
	}
}
