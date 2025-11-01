package kr.yeongju.its.ad.common.tags;

import java.io.IOException;
import java.util.ArrayList;
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
import kr.yeongju.its.ad.common.util.MapUtils;
import kr.yeongju.its.ad.core.service.CommonService;
import lombok.Setter;

@Setter
public class LabelTime extends SimpleTagSupport {
	private String id = "";
	private String caption = "";
	private String size = "6";
	private String value = "";
	private String className = "default";
	private String addClassName = "";
	private String addAttr = "";
	private String icon = "fas fa-bars";
	private String state = "";
	private String stateIcon = "fas fa-eye";
	private String suffix = "";
	private int inc = 1;
	private int min = 0;
	private int max = 24;
	
	
	@Override
	public void doTag() throws JspException, IOException {
        PageContext pageContext = (PageContext) getJspContext();
        JspWriter out = pageContext.getOut();
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
                
        result += "            <div class=\"form-group col-xl-" + size + " col-lg-" + size + " col-md-" + size + " col-sm-" + size + " col-" + size + " no-margin no-padding " + className + "\"> \n";
        
        if (!StringUtils.isEmpty(caption)) {
            result += "                <label class=\"time-combo-label control-label text-right\">" + caption + "</label> \n";
            result += "                <div class=\"inputGroupContainer\" style=\"width:calc(100% - 95px);\"> \n";        	
        } else {
        	result += "                <div class=\"inputGroupContainer\" style=\"width:100%;\"> \n";        	
        }
        
        result += "                    <div class=\"input-group\"> \n";
        
        if (!StringUtils.isEmpty(caption) && !"none".equals(icon)) {
        	result += "                        <span class=\"input-group-addon\"><i class=\"" + icon + "\" data-icon=\"" + icon + "\"></i></span> \n";
        }
        
        result += "                        <select name=\"" + id + "\" id=\"" + id + "\" class=\"form-control selectpicker " + addClassName + "\" " + addAttr + "> \n";

    	for (int i=min; i < max; i += inc) {
    		result += "                        <option value='" + StringUtils.leftPad(String.valueOf(i), 2, "0") + "' " + (value.equals(String.valueOf(i)) ? "selected='selected'" : "") + ">" + String.valueOf(i) + suffix + "</option> \n";
    	}
    	                
        result += "                        </select> \n";
        result += "                    </div> \n";
        result += "                </div> \n";
        result += "            </div> \n";
        
		out.print(result);
	}
}
