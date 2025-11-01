package kr.yeongju.its.ad.common.tags;

import java.io.IOException;

import javax.servlet.jsp.JspContext;
import javax.servlet.jsp.JspException;
import javax.servlet.jsp.JspWriter;
import javax.servlet.jsp.tagext.BodyTagSupport;

import org.apache.commons.lang3.StringUtils;

import lombok.Setter;

@Setter
public class CardButton extends BodyTagSupport {
	    
    @Override
    public int doAfterBody() throws JspException {                
        String body = bodyContent.getString();
        JspWriter out = bodyContent.getEnclosingWriter();
        String result = "";
        
        try {
            if (!StringUtils.isEmpty(body.trim())) {
                result += "<div class=\"card-header-right\"> \n";
            	result += "    " + body + "\n";
                result += "</div> \n";
            }
            
            result += "</div> \n";

    		out.print(result);
        } catch (Exception e) {
        }
        
        return super.doAfterBody();
    }
}
