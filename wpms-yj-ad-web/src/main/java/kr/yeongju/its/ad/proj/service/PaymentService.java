package kr.yeongju.its.ad.proj.service;

import kr.yeongju.its.ad.common.dto.CommonMap;
import kr.yeongju.its.ad.common.dto.ResultInfo;

public interface PaymentService {
	public ResultInfo updateSuccessData(CommonMap param) throws Exception;
	
	public int updateCancelData(CommonMap param) throws Exception;

	public int updateSuccessRepay(CommonMap param) throws Exception;
	
	public int updateSuccessOutstanding(CommonMap param) throws Exception;
	
	public int updateCancelRepay(CommonMap param) throws Exception;
	
	public int unpaidPayment(CommonMap param) throws Exception;
	
	public int elecReductionUpdate(CommonMap param) throws Exception;
	
	public int elecReductionCancel(CommonMap param) throws Exception;
	
	public int unpaidCreate(CommonMap param) throws Exception;
}
