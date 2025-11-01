package kr.yeongju.its.ad.proj.service;

import java.util.List;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import kr.yeongju.its.ad.common.dto.CommonMap;
import kr.yeongju.its.ad.common.util.EncUtil;
import kr.yeongju.its.ad.common.util.MapUtils;
import kr.yeongju.its.ad.common.util.MsgUtil;
import kr.yeongju.its.ad.core.service.CommonService;

@Service("userService")
public class UserServiceImpl implements UserService {

	@Resource(name = "commonService")
	private CommonService commonService;
	
	/*승인*/
	@Transactional
	public int userUpdate(CommonMap param) throws Exception {
		
		EncUtil enc = new EncUtil();
		
		param.put("userInfoPw", enc.get(param.getString("userInfoPw")), false);
		param.put("newPassword1", enc.get(param.getString("newPassword1")), false);
		param.put("userInfoId", enc.encrypt(param.getString("userInfoId")), false);
		param.put("userInfoName", enc.encrypt(param.getString("userInfoName")), false);
		param.put("userInfoEmail", enc.encrypt(param.getString("userInfoEmail")), false);
		param.put("userInfoPhone", enc.encrypt(param.getString("userInfoPhone")), false);
		param.put("recvYn", param.getString("recvYn"));
		
		param.put("queryId", "index.user.select_userPasswordCheck");
		CommonMap rs = commonService.selectOne(param);
		
		// 비밀번호 정보가 일치하면
		if(Integer.parseInt(rs.getString("passwordCheck")) > 0){
			param.put("queryId", "index.user.update_userInfo");
			commonService.update(param);
			return 1;
		}
		return 0;
	}
}
