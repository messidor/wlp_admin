package kr.yeongju.its.ad.common.tags;

import java.io.IOException;
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
import kr.yeongju.its.ad.common.util.EncUtil;
import kr.yeongju.its.ad.common.util.MapUtils;
import kr.yeongju.its.ad.core.service.CommonService;
import lombok.Setter;

@Setter
public class FormButton extends SimpleTagSupport {
	private String type = "";
	private String id = "";
	private String caption = "";
	private String className = "default";
	private String attr = "";
	private String wrap = "";
	
	
	@Override
	public void doTag() throws JspException, IOException {
        ApplicationContext context = ApplicationContextProvider.getApplicationContext();
        PageContext pageContext = (PageContext) getJspContext();
        HttpSession session = pageContext.getSession();
        JspWriter out = getJspContext().getOut();
        String result = "";
        
        EncUtil enc = new EncUtil();
        
        try {
        	if (session.getAttribute("user_menu_auth") == null) {
        		out.print(result);
        		return;
        	}
        	
        	List<CommonMap> authList = (List<CommonMap>) session.getAttribute("user_menu_auth");
        	boolean hasBtn = false;
        	for (int i=0; i<authList.size(); i++) {
        		if (type.equals(authList.get(i).getString("btnId"))) hasBtn = true;
        	}
        	if (!hasBtn) {
        		out.print(result);
        		return;
        	}        	
        	
            CommonService service = context.getBean(CommonService.class);
            CommonMap param = MapUtils.parseSession(session);
            
            param.put("userId", enc.encrypt(param.getString("userId")), false);
            param.put("queryId", "common.select_Button");
            param.put("btnId", type);
            
            CommonMap button = service.selectOne(param);
            
            if (!button.has("btnId")) {
        		out.print(result);
        		return;            	
            }
            
            String defClass = button.getString("btnClass");
            String icon = button.getString("btnIcon");
            String dispType = button.getString("btnDispType");
            caption = StringUtils.isEmpty(caption) ? button.getString("btnCaption") : caption;
            
            if ("B".equals(dispType)) {
                result += "<button type=\"button\" id=\"" + id + "\" class=\"" + defClass + " " + className + "\" " + attr + "> \n";
                result += "    <span class=\"" + icon + "\"></span> \n";
                result += "    &nbsp;" + caption + " \n";
                result += "</button> \n";        	
            } else if ("R".equals(dispType)) {
            	result += StringUtils.isEmpty(wrap) ? "" : String.format("<%s>", wrap);
            	if (StringUtils.isEmpty(icon)) {
                    result += "<button type=\"button\" style=\"font-size: 11px; \" class=\"btn btn-mini border-0 " + icon + " " + defClass + "\" id=\"" + id + "\" name=\"" + id + "\" '.$p_Attr.'>" + caption + "</button> \n";
            	} else {
                    result += "<i data-btn=\"btnGridButton\" style=\"cursor:pointer;\" title=\"" + caption + "\" class=\"" + icon + " " + defClass + " " + className + "\" id=\"" + id + "\" name=\"" + id + "\" " + attr + "></i> \n";            		
            	}
            	result += StringUtils.isEmpty(wrap) ? "" : String.format("</%s>", wrap);
            } else {
            	result += "<pre>type 이 잘못되었습니다.</pre>";
            }
        } catch (Exception e) {
        }
        
		out.print(result);
	}
}
