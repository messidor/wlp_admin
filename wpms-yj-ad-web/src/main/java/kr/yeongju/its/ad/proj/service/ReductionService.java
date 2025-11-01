package kr.yeongju.its.ad.proj.service;

import javax.servlet.http.HttpServletRequest;

import kr.yeongju.its.ad.common.dto.CommonMap;

public interface ReductionService {

	public int reductionUpdate(CommonMap param) throws Exception;
	
	public int popupUpdate(CommonMap param) throws Exception;
}
