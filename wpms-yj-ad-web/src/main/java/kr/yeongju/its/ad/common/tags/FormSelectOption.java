package kr.yeongju.its.ad.common.tags;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.http.HttpSession;
import javax.servlet.jsp.JspException;
import javax.servlet.jsp.JspWriter;
import javax.servlet.jsp.PageContext;
import javax.servlet.jsp.tagext.SimpleTagSupport;

import org.apache.commons.lang3.StringUtils;
import org.springframework.context.ApplicationContext;

import kr.yeongju.its.ad.common.config.ApplicationContextProvider;
import kr.yeongju.its.ad.common.dto.CommonMap;
import kr.yeongju.its.ad.common.util.MapUtils;
import kr.yeongju.its.ad.core.service.CommonService;
import lombok.Setter;

@Setter
public class FormSelectOption extends SimpleTagSupport {
	private String queryId = "";
	private String value = "";
	private boolean all = false;
	private String allLabel = "";
	
	
	@Override
	public void doTag() throws JspException, IOException {
        ApplicationContext context = ApplicationContextProvider.getApplicationContext();
        PageContext pageContext = (PageContext) getJspContext();
        HttpSession session = pageContext.getSession();
        JspWriter out = pageContext.getOut();
        String result = "";
        List<CommonMap> list = new ArrayList<CommonMap>();
        
		try {

	        if (StringUtils.isEmpty(allLabel)) allLabel = "전체";
	        
	        if (!StringUtils.isEmpty(queryId)) {
		        try {
		            CommonService service = context.getBean(CommonService.class);
		            CommonMap param = MapUtils.parseSession(session);
		            if (queryId.startsWith("#")) {
		                param.put("queryId", "common.select_commCode");
		                param.put("parentCodeId", queryId.substring(1).toUpperCase());
		                
		                list = service.select(param);
		            } else {
		                param.put("queryId", queryId);
		                
		                list = service.select(param);
		            }
		        } catch (Exception e) {
		        }
	        }

	        if (all) {
	        	result += "<option value=''>" + allLabel + "</option> \n";	
	        }
	        
	        for(int i=0; i<list.size(); i++) {
	        	CommonMap item = list.get(i);
	        	String addData = "";
	        	
	        	
	        	result += "<option value=\"" + item.getString("value") + "\" " + (value.equals(item.getString("value")) ? "selected='selected'" : "") + " " + addData + " >" + item.getString("text") + "</option> \n";	
	        }
	        
			out.print(result);
		} catch(Exception e) {
	        if (all) {
	        	result += "<option value=''>" + allLabel + "</option> \n";	
	        }

			out.print(result);
		}
	}
}
