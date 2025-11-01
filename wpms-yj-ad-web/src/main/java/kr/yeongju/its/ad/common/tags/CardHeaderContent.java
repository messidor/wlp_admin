package kr.yeongju.its.ad.common.tags;

import java.io.IOException;

import javax.servlet.jsp.JspContext;
import javax.servlet.jsp.JspException;
import javax.servlet.jsp.JspWriter;
import javax.servlet.jsp.tagext.SimpleTagSupport;

import lombok.Setter;

@Setter
public class CardHeaderContent extends SimpleTagSupport {

	@Override
	public void doTag() throws JspException, IOException {
        JspContext context = getJspContext();
        JspWriter out = context.getOut();
        String result = "";

        result += "    <div class=\"card-block table-border-style\" style=\"overflow:visible\"> \n";
        
		out.print(result);
	}
}
