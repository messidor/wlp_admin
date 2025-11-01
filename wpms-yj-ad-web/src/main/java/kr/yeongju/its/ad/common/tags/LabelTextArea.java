package kr.yeongju.its.ad.common.tags;

import java.io.IOException;

import javax.servlet.jsp.JspContext;
import javax.servlet.jsp.JspException;
import javax.servlet.jsp.JspWriter;
import javax.servlet.jsp.tagext.SimpleTagSupport;

import org.apache.commons.lang3.StringUtils;

import lombok.Setter;

@Setter
public class LabelTextArea extends SimpleTagSupport {
	private String id = "";
	private String caption = "";
	private String size = "12";
	private String value = "";
	private String className = "default";
	private String addClassName = "";
	private String addAttr = "";
	private String rows = "3";
	private String icon = "fas fa-pencil-alt";
	private String state = "";
	private String stateIcon = "fas fa-eye";
	
	
	@Override
	public void doTag() throws JspException, IOException {
        JspContext context = getJspContext();
        JspWriter out = context.getOut();
        String result = "";
        
        if ("readonly".equals(state)) {
        	icon = StringUtils.isEmpty(stateIcon) ? "" : stateIcon;
        	addAttr += " readonly='readonly' ";
        } else if ("disabled".equals(state)) {
        	icon = StringUtils.isEmpty(stateIcon) ? "" : stateIcon;
        	addAttr += " disabled='disabled' ";        	
        }
        if (StringUtils.isEmpty(className) || "default".equals(className)) className = "";
        else className = "has-" + className;
        
        result += "            <div class=\"form-group col-xl-" + size + " col-lg-" + size + " col-md-" + size + " col-sm-12 col-12 no-margin no-padding " + className + "\"> \n";
        result += "                <label class=\"col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right\">" + caption + "</label> \n";
        result += "                <div class=\"col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached\"> \n";
        result += "                    <div class=\"input-group\"> \n";
        
        if (!"none".equals(icon)) {
            result += "                        <span class=\"input-group-addon\"><i class=\"" + icon + "\" data-icon=\"" + icon + "\"></i></span> \n";
        }
        
        result += "                        <textarea name=\"" + id + "\" id=\"" + id + "\" class=\"form-control " + addClassName + "\" rows=\"" + rows + "\" " + addAttr + ">" + value + "</textarea> \n";
        result += "                    </div> \n";
        result += "                </div> \n";
        result += "            </div> \n";
        
		out.print(result);
	}
}
