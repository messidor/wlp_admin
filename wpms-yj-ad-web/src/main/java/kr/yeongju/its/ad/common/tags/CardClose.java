package kr.yeongju.its.ad.common.tags;

import java.io.IOException;

import javax.servlet.jsp.JspContext;
import javax.servlet.jsp.JspException;
import javax.servlet.jsp.JspWriter;
import javax.servlet.jsp.tagext.SimpleTagSupport;

import lombok.Setter;

@Setter
public class CardClose extends SimpleTagSupport {
	@Override
	public void doTag() throws JspException, IOException {
        JspContext context = getJspContext();
        JspWriter out = context.getOut();
        String result = "";

        result += "    </div> \n";
        result += "</div> \n";
        
		out.print(result);
	}
}
