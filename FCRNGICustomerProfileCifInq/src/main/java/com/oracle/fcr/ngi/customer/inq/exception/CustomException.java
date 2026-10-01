package com.oracle.fcr.ngi.customer.inq.exception;


import com.oracle.fcr.ngi.exception.NGIBaseException;
import com.oracle.fcr.ngi.model.CustomError;

import java.util.List;

public class CustomException extends NGIBaseException {

	private static final long serialVersionUID = 619665828707923005L;

	public CustomException() {
		super();
	}

	public CustomException(List<CustomError> error) {
		super(error);
	}

	public CustomException(String message, Throwable cause, boolean enableSuppression, boolean writableStackTrace) {
		super(message, cause, enableSuppression, writableStackTrace);
	}

	public CustomException(String message, Throwable cause) {
		super(message, cause);
	}

	public CustomException(String message) {
		super(message);
	}

	public CustomException(Throwable cause) {
		super(cause);
	}
}