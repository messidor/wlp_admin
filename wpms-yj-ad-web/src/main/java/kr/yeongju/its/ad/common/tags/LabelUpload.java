package kr.yeongju.its.ad.common.tags;

import java.io.IOException;

import javax.servlet.jsp.JspContext;
import javax.servlet.jsp.JspException;
import javax.servlet.jsp.JspWriter;
import javax.servlet.jsp.tagext.SimpleTagSupport;

import org.apache.commons.lang3.StringUtils;

import lombok.Setter;

@Setter
public class LabelUpload extends SimpleTagSupport {
	private String id = "";
	private String caption = "";
	private String size = "6";
	private String height = "100px";
	private String placeholder = "";
	
	
	@Override
	public void doTag() throws JspException, IOException {
        JspContext context = getJspContext();
        JspWriter out = context.getOut();
        String result = "";
        
        result += "            <div class=\"form-group col-xl-" + size + " col-lg-" + size + " col-md-" + size + " col-sm-12 col-12 no-margin no-padding\"> \n";
        result += "                <label class=\"col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right\">" + caption + "</label> \n";
        result += "                <div id=\"" + id + "\" class=\"col-xl-8 col-lg-8 col-md-8 col-sm-12 col-12 dropzone-file-upload control-file-upload\" style=\"height: " + height + "\"> \n";
        result += "                    " + placeholder + " \n"; 
        result += "                </div> \n";
        result += "            </div> \n";
        
		out.print(result);
	}
}
