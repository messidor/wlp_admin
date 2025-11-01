package kr.yeongju.its.ad.proj.service;

import javax.servlet.http.HttpServletRequest;

import kr.yeongju.its.ad.common.dto.CommonMap;

public interface SysService {
	public int smsCertificationReqeust(CommonMap param) throws Exception;
	
	public int reductionManage(CommonMap param) throws Exception;
	
	public int faqM(CommonMap param) throws Exception;
	
	public int faq(CommonMap param) throws Exception;
	
	public int deleteFaq(CommonMap param) throws Exception;
	
	public int updateOrder(CommonMap param) throws Exception;
	
	public int updateCategoryOrder(CommonMap param) throws Exception;
	
	public int optionManage(CommonMap param) throws Exception;
	
	public int optionApiManage(CommonMap param) throws Exception;
	
	public int optionManageParking(CommonMap param) throws Exception;
	
	public int optionManageMsg(CommonMap param) throws Exception;
	
	public int optionManageReceiver(CommonMap param) throws Exception;
}
