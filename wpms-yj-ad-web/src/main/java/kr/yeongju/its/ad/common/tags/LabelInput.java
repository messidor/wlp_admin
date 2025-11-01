package kr.yeongju.its.ad.common.tags;

import java.io.IOException;

import javax.servlet.jsp.JspContext;
import javax.servlet.jsp.JspException;
import javax.servlet.jsp.JspWriter;
import javax.servlet.jsp.tagext.SimpleTagSupport;

import org.apache.commons.lang3.StringUtils;

import lombok.Setter;

@Setter
public class LabelInput extends SimpleTagSupport {
	private String type = "text";
	private String id = "";
	private String caption = "";
	private String size = "4";
	private String value = "";
	private String className = "default";
	private String addClassName = "";
	private String addAttr = "";
	private String icon = "fas fa-pencil-alt";
	private String state = "";
	private String stateIcon = "fas fa-eye";
	private String btnId = "";
	private String btnClass = "";
	private String btnCaption = "";
	private String code = "";
	private String queryId = "";
	
	
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
        
        result += "            <div class=\"form-group col-xl-" + size + " col-lg-" + size + " col-md-12 col-sm-12 no-margin no-padding " + className + "\"> \n";
        result += "                <label class=\"col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right\">" + caption + "</label> \n";
        result += "                <div class=\"col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached\"> \n";
        result += "                    <div class=\"input-group\"> \n";
        
        if (!"none".equals(icon)) {
            result += "                        <span class=\"input-group-addon\"><i class=\"" + icon + "\" data-icon=\"" + icon + "\"></i></span> \n";
        }
        
        if ("autocomplete".equals(type)) {
            result += "                        <input type=\"text\" name=\"" + id + "\" id=\"" + id + "\" value=\"" + value + "\" autocomplete=\"off\" class=\"form-control basicAutoComplete " + addClassName + " \" " + addAttr + " data-code=\"" + code + "\" data-query-id=\"" + queryId + "\" > \n";
            result += "                        <input type=\"hidden\" name=\"" + code + "\" id=\"" + code + "\"  > \n";
        } else {
            result += "                        <input name=\"" + id + "\" id=\"" + id + "\" class=\"form-control " + addClassName + "\" type=\"text\" value=\"" + value + "\" " + addAttr + " /> \n";
        }
        
        if(!StringUtils.isEmpty(btnId)) {
         	result += "					   <span class=\"input-group-btn\"> \n";
        	result += "            			   <button id=\"" + btnId + "\" type=\"button\" name=\"" + btnId + "\" class=\"btn btn-sm btn-" + btnClass + "\">" + btnCaption + "</button> \n";
			result += "        			   </span> \n";
        }
        
        result += "                    </div> \n";
        result += "                </div> \n";
        result += "            </div> \n";
        
		out.print(result);
	}
}
