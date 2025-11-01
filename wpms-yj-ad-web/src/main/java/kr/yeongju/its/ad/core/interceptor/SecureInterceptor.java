package kr.yeongju.its.ad.core.interceptor;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.handler.HandlerInterceptorAdapter;

import lombok.Setter;

@Setter
public class SecureInterceptor extends HandlerInterceptorAdapter {
    
    @Override
    public boolean preHandle(HttpServletRequest request, 
                             HttpServletResponse response, 
                             Object handler) throws Exception {
        // Proxy 서버에서 헤더에 추가하는 값으로 추정됨
        // Reverse Proxy 서버를 사용 중
        String xForwardProto = request.getHeader("X-Forwarded-Proto");

        if(xForwardProto != null) {
            if(!"https".equals(xForwardProto.toLowerCase())) {
                String requestUrl = ((HttpServletRequest)request).getRequestURL().toString();
                if(!requestUrl.startsWith("https://")) {
                    requestUrl = requestUrl.substring("http://".length());
                    // querystring
                    String queryString = request.getQueryString();
                    // total url
                    String redirectUrl = "https://" + requestUrl + (queryString == null ? "" : "?" + queryString);
                    response.sendRedirect(redirectUrl);
                    return false;
                }
            }
        }
           
        return true;
    }
    
    @Override
    public void postHandle(HttpServletRequest request,
                           HttpServletResponse response,
                           Object handler,
                           ModelAndView modelAndView) throws Exception {

    }
}
