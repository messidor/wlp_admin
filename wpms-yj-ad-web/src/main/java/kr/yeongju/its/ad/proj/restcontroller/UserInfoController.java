package kr.yeongju.its.ad.proj.restcontroller;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

import kr.yeongju.its.ad.common.dto.CommonMap;
import kr.yeongju.its.ad.common.dto.ResultInfo;
import kr.yeongju.its.ad.common.exception.NotFoundException;
import kr.yeongju.its.ad.common.util.MapUtils;
import kr.yeongju.its.ad.core.service.CommonService;
import kr.yeongju.its.ad.proj.service.UserService;


@RestController
@RequestMapping(value = "/user")
public class UserInfoController {

	@Resource(name = "commonService")
	private CommonService commonService;

	@Resource(name = "userService")
	private UserService userService;

	/**
	 * 정보 수정
	 * @throws Exception
	 */
	@RequestMapping(value = "/userUpdate.do", method = RequestMethod.POST)
	public ResultInfo userUpdate(HttpServletRequest request) throws Exception {
		String msg = "";
		int result = 1;
		CommonMap data = new CommonMap();

		try {
			int success_cnt = userService.userUpdate(MapUtils.parseRequest(request));

			if(success_cnt < 1){
				result = 0;
				msg = "비밀번호가 일치하지 않습니다.";
			}else {
				msg = "정상적으로 변경되었습니다.";
			}
		} catch(NotFoundException e) {
			msg = e.getMessage();
			result = 0;

			e.printStackTrace();
			throw e;
		} catch (Exception e) {
			result = 0;
			msg = String.format("%s (%s)", "오류가 발생하였습니다.", e.getMessage());

			e.printStackTrace();
			throw e;
		}

		return ResultInfo.of(msg, result, data);
	}
}
