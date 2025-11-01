package kr.yeongju.its.ad.proj.service;

import javax.servlet.http.HttpServletRequest;

import kr.yeongju.its.ad.common.dto.CommonMap;

public interface MemberService {
	public int memberUpdate(CommonMap param) throws Exception;	
	
	public int memberCofirmUpdate(CommonMap param) throws Exception;
	
	public int memberPasswordUpdate(CommonMap param) throws Exception;
	
	public int applyCarUpdate(HttpServletRequest request) throws Exception;
	
	public CommonMap memberFullManage(CommonMap param) throws Exception;
	
	public int msgSendManage(HttpServletRequest request) throws Exception;
	
	public int memberCarDel(CommonMap param) throws Exception;
	
	public int memberReductionDel(HttpServletRequest request) throws Exception;
	
	public int memberSaveData(CommonMap param) throws Exception;
}
