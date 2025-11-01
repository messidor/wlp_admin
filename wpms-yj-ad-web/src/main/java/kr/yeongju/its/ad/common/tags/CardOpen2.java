package kr.yeongju.its.ad.common.tags;

import java.io.IOException;

import javax.servlet.jsp.JspContext;
import javax.servlet.jsp.JspException;
import javax.servlet.jsp.JspWriter;
import javax.servlet.jsp.tagext.SimpleTagSupport;

import lombok.Setter;

@Setter
public class CardOpen2 extends SimpleTagSupport {
	private String title;

	@Override
	public void doTag() throws JspException, IOException {
        JspContext context = getJspContext();
        JspWriter out = context.getOut();
        String result = "";

        result += "<div class=\"card main_card\"> \n";
        result += "    <div class=\"card-header\"> \n";
        result += "        <h5>" + title + "</h5> \n";
        
		out.print(result);
	}
}
