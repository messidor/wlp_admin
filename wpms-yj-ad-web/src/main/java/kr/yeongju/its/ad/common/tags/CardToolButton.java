package kr.yeongju.its.ad.common.tags;

import java.io.IOException;

import javax.servlet.jsp.JspException;
import javax.servlet.jsp.JspWriter;
import javax.servlet.jsp.tagext.BodyTagSupport;

import org.apache.commons.lang3.StringUtils;

import lombok.Setter;

@Setter
public class CardToolButton extends BodyTagSupport {
	private String title;

    @Override
    public int doAfterBody() throws JspException {                
        String body = bodyContent.getString();
        JspWriter out = bodyContent.getEnclosingWriter();
        String result = "";
        
        try {

            if (!StringUtils.isEmpty(body)) {
                result += "       <div class=\"card-header-right\"> \n";
                result += "           <ul class=\"list-unstyled card-option\"> \n";
                result += "               <li><i data-btn=\"btnGridButton\" title=\"" + title + "\" class=\"fa fa fa-wrench open-card-option fa-lg\"></i></li> \n";
            	result += "               " + body + "\n";
                result += "           </ul> \n";
                result += "       </div> \n";
            }
            result += "   </div> \n";
            
    		out.print(result);
        } catch (Exception e) {
        }
        
        return super.doAfterBody();
    }
}
