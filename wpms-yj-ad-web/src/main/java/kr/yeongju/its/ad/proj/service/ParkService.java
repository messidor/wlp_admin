package kr.yeongju.its.ad.proj.service;

import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.springframework.web.multipart.MultipartHttpServletRequest;

import kr.yeongju.its.ad.common.dto.CommonMap;
import kr.yeongju.its.ad.common.dto.ResultInfo;

public interface ParkService {
	public int parkCompInsert(CommonMap param) throws Exception;
	
	public int parkCompUpdate(CommonMap param) throws Exception;
	
	public int parkingServiceInfo(CommonMap param) throws Exception;
	
	public int parkInsert(CommonMap param) throws Exception;
	
	public int parkDelete(CommonMap param) throws Exception;
	
	public int parkGovInsert(CommonMap param) throws Exception;
	
	public int parkGovUpdate(CommonMap param) throws Exception;
	
	public int parkingGovServiceInfo(CommonMap param) throws Exception;
	
	public int parkReduction(CommonMap param) throws Exception;
	
	public int parkSpotInsert(CommonMap param) throws Exception;
	
	public int generalPakingSave(CommonMap param) throws Exception;
	
	public int generalPakingDelete(CommonMap param) throws Exception;
	
	public List<CommonMap> parkingMassRegister(HttpServletRequest request, CommonMap param) throws Exception;
	
	public CommonMap parkingMassRegisterSave(CommonMap param) throws Exception;
	
	public CommonMap parkingRowDataCheck(CommonMap param) throws Exception;
	
	public ResultInfo generalParkExcelUpload(HttpSession session, HttpServletRequest request) throws Exception;

}
