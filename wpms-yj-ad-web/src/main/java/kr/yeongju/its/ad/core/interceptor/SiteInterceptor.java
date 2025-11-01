package kr.yeongju.its.ad.core.interceptor;

import java.util.List;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.lang3.StringUtils;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.ModelAndViewDefiningException;
import org.springframework.web.servlet.handler.HandlerInterceptorAdapter;

import egovframework.rte.fdl.property.EgovPropertyService;
import kr.yeongju.its.ad.common.dto.CommonMap;
import kr.yeongju.its.ad.common.util.AuthUtils;
import kr.yeongju.its.ad.common.util.DeviceUtils;
import kr.yeongju.its.ad.core.service.CommonService;
import lombok.Setter;

@Setter
public class SiteInterceptor extends HandlerInterceptorAdapter {

	@Resource(name = "commonService")
	private CommonService commonService;
	
	@Resource(name="propertyService")
    protected EgovPropertyService propertyService;
	
	private String attributeName;	
	private String redirectUrl;

	
    @Override
    public boolean preHandle(HttpServletRequest request, 
    						 HttpServletResponse response, 
    						 Object handler) throws Exception {
		if ((this.attributeName == null) || (this.redirectUrl == null)) {
			return true;
		}
		
        String redirectDomain = propertyService.getString("domain");
		Object sessionAttribute = request.getSession().getAttribute(this.attributeName);
	    
	    if (sessionAttribute == null && !request.getServletPath().startsWith("/pop/")) {
		    ModelAndView modelAndView = new ModelAndView("redirect:" + redirectDomain + this.redirectUrl);
		    
	    	throw new ModelAndViewDefiningException(modelAndView);
	    }
        
    	return true;
    }
    
    @Override
    public void postHandle(HttpServletRequest request,
                           HttpServletResponse response,
                           Object handler,
                           ModelAndView modelAndView) throws Exception {

        if (modelAndView == null || modelAndView.getViewName().startsWith("redirect:")) return;
                
        //modelAndView.addObject("loginUser", UserUtils.getLoginUser());
        modelAndView.addObject("current_request_uri", request.getRequestURI());
        modelAndView.addObject("browser", DeviceUtils.getBrowser(request));
    }
    
    public void setAttributeName(String name) {
        this.attributeName=name;

    }
    public void setRedirectUrl(String url) {
        this.redirectUrl=url;

    }   
    public String getAttributeName() {
        return this.attributeName;

    }   
    public String getRedirectUrl() {
        return this.redirectUrl;

    } 
}
