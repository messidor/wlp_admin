package kr.yeongju.its.ad.proj.service;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import kr.yeongju.its.ad.common.dto.CommonMap;
import kr.yeongju.its.ad.common.dto.ResultInfo;

public interface BoardService {
	public ResultInfo updateNotice(HttpSession session, HttpServletRequest request) throws Exception;	
	public ResultInfo insertNotice(HttpSession session, HttpServletRequest request) throws Exception;
	public ResultInfo deleteNotice(HttpSession session, HttpServletRequest request) throws Exception;
	public int updateInquiry(CommonMap param) throws Exception;
	public ResultInfo deleteFile(HttpSession session, HttpServletRequest request) throws Exception;
	public ResultInfo selectInquiry(HttpSession session, HttpServletRequest request) throws Exception;
	public ResultInfo selectNotice(HttpSession session, HttpServletRequest request) throws Exception;
	public ResultInfo selectCorporationInquiry(HttpSession session, HttpServletRequest request) throws Exception;
	public int updateCorporationInquiry(CommonMap param) throws Exception;
}
