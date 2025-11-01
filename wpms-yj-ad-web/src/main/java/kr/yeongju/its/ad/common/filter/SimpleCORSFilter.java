package kr.yeongju.its.ad.common.filter;

import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

import javax.servlet.*;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@Component
@Order(Ordered.HIGHEST_PRECEDENCE)
public class SimpleCORSFilter implements Filter {
    @Override
    public void init(FilterConfig fc) throws ServletException {
    }

    @Override
    public void doFilter(ServletRequest req, ServletResponse resp,
                         FilterChain chain) throws IOException, ServletException {
        HttpServletResponse response = (HttpServletResponse) resp;
        HttpServletRequest request = (HttpServletRequest) req;
        response.setHeader("Access-Control-Allow-Origin", "*");
        //response.setHeader("Access-Control-Allow-Methods", "POST, GET, OPTIONS, DELETE, PUT");
        response.setHeader("Access-Control-Max-Age", "360000");
        response.setHeader("Access-Control-Allow-Headers", "x-requested-with, authorization, Content-Type, Authorization, credential, X-XSRF-TOKEN, x-auth-token");
        
        if ("OPTIONS".equalsIgnoreCase(request.getMethod())) {
            response.setStatus(HttpServletResponse.SC_OK);
        } else {
            // JSESSIONID를 받음
            String jSessionId = request.getRequestedSessionId() == null ? "" : request.getRequestedSessionId();
            
            // JSESSIONID가 있으면
            if(!"".equals(jSessionId)) {          
                // 쿠키 설정을 진행 (크롬 80패치에 대응하기 위한 코드)
                response.setHeader("Set-Cookie", "JSESSIONID=" + jSessionId + ";path=/walletfree-admin;SameSite=None;Secure;HttpOnly");
            }
            chain.doFilter(req, resp);
        }
    }

    @Override
    public void destroy() {
    }
}
