package kr.yeongju.its.ad.common.config;

import org.springframework.security.web.util.matcher.AntPathRequestMatcher;
import org.springframework.security.web.util.matcher.OrRequestMatcher;
import org.springframework.security.web.util.matcher.RequestMatcher;
import org.springframework.stereotype.Component;

import javax.servlet.http.HttpServletRequest;

@Component
public class ApiPathRequestMatcher implements RequestMatcher {
    private OrRequestMatcher apiPathMatcher = new OrRequestMatcher(
        new AntPathRequestMatcher("/api/**"),
        new AntPathRequestMatcher("/ajax/**"));

    @Override
    public boolean matches(HttpServletRequest request) {
        return apiPathMatcher.matches(request);
    }
}