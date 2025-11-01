package kr.yeongju.its.ad.common.util;

import java.util.Collections;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletRequestWrapper;

public class SetableHttpServletRequest extends HttpServletRequestWrapper {
    
    private HashMap<String, Object> params;
    
    public SetableHttpServletRequest(HttpServletRequest request) {
        super(request);
        this.params = new HashMap<String, Object>(request.getParameterMap());
    }
    
    public String getParameter(String name) {
        String result = null;
        String[] paramArray = getParameterValues(name);
        if(paramArray != null && paramArray.length > 0) {
            result = paramArray[0];
        }
        
        return result;
    }
    
    @SuppressWarnings({ "unchecked", "rawtypes" })
    public Map getParameterMap() {
        return Collections.unmodifiableMap(params);
    }
    
    @SuppressWarnings({ "unchecked", "rawtypes" })
    public Enumeration getParameterNames() {
        return Collections.enumeration(params.keySet());
    }
    
    public String[] getParameterValues(String name) {
        String[] result = null;
        String[] temp = (String[]) params.get(name);
        
        if(temp != null) {
            result = new String[temp.length];
            System.arraycopy(temp, 0, result, 0, temp.length);
        }
        return result;
    }
    
    public void setParameter(String name, Object value) {
        params.put(name, value);
    }
}