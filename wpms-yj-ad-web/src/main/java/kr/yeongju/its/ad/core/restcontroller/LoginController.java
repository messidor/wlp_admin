package kr.yeongju.its.ad.core.restcontroller;

import java.util.ArrayList;
import java.util.List;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.apache.commons.lang3.StringUtils;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

import kr.yeongju.its.ad.common.dto.CommonMap;
import kr.yeongju.its.ad.common.dto.ResultInfo;
import kr.yeongju.its.ad.common.util.CommonUtil;
import kr.yeongju.its.ad.common.util.EncUtil;
import kr.yeongju.its.ad.common.util.MapUtils;
import kr.yeongju.its.ad.core.service.LoginService;
import kr.yeongju.its.ad.core.service.CommonService;

@RestController
@RequestMapping("/api")
public class LoginController {

	@Resource(name = "loginService")
	private LoginService loginService;
	    
	@Resource(name = "commonService")
	private CommonService commonService;

    /**
     * 로그인 화면
     * @throws Exception 
     */
	@RequestMapping(value = "/login.do", method = RequestMethod.POST)
    public ResultInfo login(HttpServletRequest request,
    						HttpSession session) {
    	String msg = "";
    	int result = 0;
    	CommonMap data = new CommonMap();
    	EncUtil enc = new EncUtil();
    	String mobileYn = "N";
    	
    	try {
    		CommonMap param = MapUtils.parseRequest(request); 
    		param.put("id", enc.encrypt(param.getString("id")), false);
    		param.put("pw", enc.get(param.getString("pw")), false);
    		CommonMap loginData = loginService.login(param);
    		
        	if (loginData == null || loginData.size() == 0) {
        		msg = "로그인 정보가 없거나 비밀번호가 잘못되었습니다.";
        	} else {
        		CommonMap first = loginData.getMap(0);
        		
        		if(!"Y".equals(first.getString("useYn"))) {
            		msg = "퇴사 처리된 사용자입니다.";
                } else if(!"Y".equals(first.getString("roleCheck"))) {
                	msg = "권한이 없는 사용자입니다. 관리자에게 문의해 주시기 바랍니다.";
                } else {
                    result = 1;
                    
                    param.put("memberId", enc.encrypt(first.getString("userId")), false);
                    param.put("requestIp", CommonUtil.getClientIP(request));
                    param.put("browserName", CommonUtil.getClientBrowser(request));
                    param.put("requestUri", "/login.do");
                    
                    if("IS_MOBILE".equals(CommonUtil.isDevice(request))) {
                    	mobileYn = "Y";
                    }
                    
                    param.put("mobileYn", mobileYn);
                    param.put("queryId", "common.login.Insert_userLog");
                    
                    loginService.insert(param);
                    session.setAttribute("user_id", first.getString("userId"));
                    session.setAttribute("user_name", first.getString("userName"));
                    session.setAttribute("user_token", "");
                    session.setAttribute("user_comp_name", first.getString("compName"));
                    session.setAttribute("user_dept_code", first.getString("deptId"));
                    session.setAttribute("user_dept_name", first.getString("deptName"));
                    session.setAttribute("user_phone", first.getString("userPhone"));
                    if("admin".equals(first.getString("userId")) || "wadmin".equals(first.getString("userId"))) {
                    	session.setAttribute("role_name", "");
                    }else {
                    	session.setAttribute("role_name", first.getString("roleName"));                    	
                    }

                    // 직급 코드/이름
                    session.setAttribute("user_pos_gubn", first.getString("posGubn"));
                    session.setAttribute("user_pos_gubn_name", first.getString("posGubnName"));

                    // 언어팩
                    session.setAttribute("user_lang_pack", first.getString("langPack"));
                    
                    List<String> roleIdAry = new ArrayList<String>();
                    List<String> roleNameAry = new ArrayList<String>();
                    List<String> roleGubnAry = new ArrayList<String>();
                    List<String> roleGubnNameAry = new ArrayList<String>();
                    
                    for (int i=0; i<loginData.size(); i++) {
                    	CommonMap d = loginData.getMap(i);
                    	
                    	roleIdAry.add(d.getString("roleId"));
                    	roleNameAry.add(d.getString("roleName"));
                    	roleGubnAry.add(d.getString("roleGubn"));
                    	roleGubnNameAry.add(d.getString("roleGubnName"));
                    }
                    
                    session.setAttribute("user_role_id", StringUtils.join(roleIdAry, ","));
                    session.setAttribute("user_role_name", StringUtils.join(roleNameAry, ","));
                    session.setAttribute("user_role_id_ary", roleIdAry);
                    session.setAttribute("user_role_name_ary", roleNameAry);
                    
                    session.setAttribute("user_role_gubn_ary", roleGubnAry);
                    session.setAttribute("user_role_gubn_name_ary", roleGubnNameAry);
                    session.setAttribute("user_parking_gov", first.getString("pGovCode"));
                    
                    param = MapUtils.parseRequest(request); 
                }
        	}
    	} catch (Exception e) {
    		result = 0;
    		msg = "처리 중 오류가 발생했습니다.";
    		
    		e.printStackTrace();
    	} finally {
    		//model.addAttribute("msg", msg);
    		//model.addAttribute("error", error);
    	}
    	
        return ResultInfo.of(msg, result, data);
    }

    /**
     * 로그아웃
     */
    @RequestMapping(value = "/logout.do", method = RequestMethod.POST)
    public ResultInfo logout(HttpSession session) throws Exception {
    	
    	session.setAttribute("user_id", null);
        session.setAttribute("user_name", null);
        session.setAttribute("user_token", null);
        session.setAttribute("user_comp_name", null);
        session.setAttribute("user_dept_code", null);
        session.setAttribute("user_dept_name", null);
        session.setAttribute("user_phone", null);
        session.setAttribute("user_pos_gubn", null);
        session.setAttribute("user_pos_gubn_name", null);
        session.setAttribute("user_lang_pack", null);
        session.setAttribute("user_role_id", null);
        session.setAttribute("user_role_name", null);
        session.setAttribute("user_role_id_ary", null);
        session.setAttribute("user_role_name_ary", null);        
        session.setAttribute("user_role_gubn_ary", null);
        session.setAttribute("user_role_gubn_name_ary", null);
        session.setAttribute("user_parking_gov", null);
        
    	session.invalidate();
        
        return ResultInfo.of("", 1, new CommonMap());
    }

}
