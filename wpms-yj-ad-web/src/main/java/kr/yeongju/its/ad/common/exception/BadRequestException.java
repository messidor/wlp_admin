package kr.yeongju.its.ad.common.exception;

import egovframework.rte.fdl.cmmn.exception.BaseRuntimeException;
import lombok.Getter;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

@ResponseStatus(code = HttpStatus.BAD_REQUEST)
public class BadRequestException extends BaseRuntimeException {

    final private String field;
    final private String errorCode;

    public BadRequestException(String field, String errorCode, String defaultMessage) {
        super(defaultMessage);
        this.field = field;
        this.errorCode = errorCode;
    }

	public String getField() {
		return field;
	}

	public String getErrorCode() {
		return errorCode;
	}
}
