package kr.yeongju.its.ad.core.service;

import javax.annotation.Resource;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import kr.yeongju.its.ad.common.dto.CommonMap;
import kr.yeongju.its.ad.common.util.MapUtils;
import kr.yeongju.its.ad.core.mapper.LoginMapper;

@Service("loginService")
public class LoginService {

	@Autowired
	@Resource(name = "loginMapper")
	private LoginMapper loginMapper;

	public CommonMap login(CommonMap map) throws Exception {
		return MapUtils.parseList(loginMapper.login(map));
	}
	
	public int insert(CommonMap map) throws Exception {
		return loginMapper.Insert_userLog(map);
	}
}
