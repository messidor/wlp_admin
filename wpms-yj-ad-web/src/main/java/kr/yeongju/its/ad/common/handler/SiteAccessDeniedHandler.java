package kr.yeongju.its.ad.common.handler;

import java.io.IOException;

import javax.annotation.Resource;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.web.access.AccessDeniedHandler;

import egovframework.rte.fdl.property.EgovPropertyService;
import kr.yeongju.its.ad.common.config.ApiPathRequestMatcher;
import lombok.extern.slf4j.Slf4j;

@Slf4j
public class SiteAccessDeniedHandler implements AccessDeniedHandler {

	@Resource(name="propertyService")
    protected EgovPropertyService propertyService;
    
    private final ApiPathRequestMatcher apiPathRequestMatcher;

    public SiteAccessDeniedHandler() {
        apiPathRequestMatcher = new ApiPathRequestMatcher();
    }

    @Override
    public void handle(HttpServletRequest request,
                       HttpServletResponse response,
                       AccessDeniedException accessDeniedException) throws IOException, ServletException {	
    	
        String redirectDomain = propertyService.getString("domain");

        if (apiPathRequestMatcher.matches(request)) {
        	if (/*UserUtils.isLogin()*/ true) {
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.getWriter().write("{\"msg\":\"해당 권한이 없습니다.\"}");
            } else {
                // login 필요
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.getWriter().write("{\"msg\":\"로그인이 필요합니다.\"}");
            }
        } else {
            if (/*UserUtils.isLogin()*/ true) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "AccessDenied");
            } else if(request.getRequestURI().contains("logout.do")) {
                response.sendRedirect(redirectDomain + "/index.do");
            } else {
                // login 필요
                response.sendRedirect(redirectDomain + "/login.do");
            }
        }
    }
}
