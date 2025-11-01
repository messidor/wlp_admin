package kr.yeongju.its.ad.common.tags;

import java.io.IOException;

import javax.servlet.jsp.JspContext;
import javax.servlet.jsp.JspException;
import javax.servlet.jsp.JspWriter;
import javax.servlet.jsp.tagext.SimpleTagSupport;

import org.apache.commons.lang3.StringUtils;

import lombok.Setter;

@Setter
public class FormGrid extends SimpleTagSupport {
	private String id = "";
	private String height = "";
	private String style = "";
	
	
	@Override
	public void doTag() throws JspException, IOException {
        JspContext context = getJspContext();
        JspWriter out = context.getOut();
        String result = "";

        if (StringUtils.isEmpty(height.replace("%", "").replace("px", ""))) {
            result += "        <div id=\"" + id + "\" class=\"ag-theme-balham\" style=\"" + style + "\"></div> \n";
        } else {
            result += "        <div id=\"" + id + "\" class=\"ag-theme-balham\" style=\"" + style + "\" data-height=\"" + height + "\"></div> \n";
        }
        
		out.print(result);
	}
}
