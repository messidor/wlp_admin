package kr.yeongju.its.ad.core.controller;

import javax.servlet.http.HttpSession;

import javax.annotation.Resource;
import egovframework.rte.fdl.property.EgovPropertyService;
import org.apache.commons.lang3.StringUtils;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

@Controller
public class UserController {
    
    @Resource(name="propertyService")
    protected EgovPropertyService propertyService;
    
    /**
     * 로그인 화면
     */
    @RequestMapping(value = "/login.do", method = RequestMethod.GET)
    public String login(HttpSession session,
		     			Model model) {

        String redirectDomain = propertyService.getString("domain");
    	String userId = session.getAttribute("user_id") == null ? "" : (String) session.getAttribute("user_id");
    	
    	if (!StringUtils.isEmpty(userId)) {
            return "redirect:" + redirectDomain + "/index.do";
    	}
    	
        return "/core/login";
    }

    /**
     * 로그아웃
     */
    @RequestMapping(value = "/logout.do", method = RequestMethod.GET)
    public String logout(HttpSession session,
    				     Model model) {
    	
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

        String redirectDomain = propertyService.getString("domain");
        return "redirect:" + redirectDomain + "/login.do";
    }

}
