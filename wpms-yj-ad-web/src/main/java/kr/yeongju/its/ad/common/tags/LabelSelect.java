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
public class LabelSelect extends SimpleTagSupport {
	private String id = "";
	private String caption = "";
	private String size = "6";
	private String queryId = "";
	private String value = "";
	private String className = "default";
	private String addClassName = "";
	private String addAttr = "";
	private boolean all = false;
	private String allLabel = "";
	private String emptyLabel = "";
	private String icon = "fas fa-bars";
	private String state = "";
	private String stateIcon = "fas fa-eye";
	
	
	@Override
	public void doTag() throws JspException, IOException {
        ApplicationContext context = ApplicationContextProvider.getApplicationContext();
        PageContext pageContext = (PageContext) getJspContext();
        HttpSession session = pageContext.getSession();
        JspWriter out = pageContext.getOut();
        String result = "";
        List<CommonMap> list = new ArrayList<CommonMap>();

        if (StringUtils.isEmpty(allLabel)) allLabel = "전체";
        if (StringUtils.isEmpty(emptyLabel)) emptyLabel = "조회된 데이터가 없습니다.";
        if ("readonly".equals(state)) {
        	icon = StringUtils.isEmpty(stateIcon) ? "" : stateIcon;
        	addAttr += " readonly='readonly' ";
        } else if ("disabled".equals(state)) {
        	icon = StringUtils.isEmpty(stateIcon) ? "" : stateIcon;
        	addAttr += " disabled='disabled' ";        	
        }
        if (StringUtils.isEmpty(className) || "default".equals(className)) className = "";
        else className = "has-" + className;
        
        if (!StringUtils.isEmpty(queryId)) {
	        try {
	            CommonService service = context.getBean(CommonService.class);
	            CommonMap param = MapUtils.parseSession(session);
	            if (queryId.startsWith("#")) {
	                param.put("queryId", "common.select_commCode");
	                param.put("parentCodeId", queryId.substring(1).toUpperCase());
	                
	                list = service.select(param);
	            } else {
	                param.put("queryId", queryId);
	                
	                list = service.select(param);
	            }
	        } catch (Exception e) {
	        }
        }
        
        result += "            <div class=\"form-group col-xl-" + size + " col-lg-" + size + " col-md-12 col-sm-12 no-margin no-padding " + className + "\"> \n";
        result += "                <label class=\"col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right\">" + caption + "</label> \n";
        result += "                <div class=\"col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached\"> \n";
        result += "                    <div class=\"input-group\"> \n";
        
        if (!"none".equals(icon)) {
        	result += "                        <span class=\"input-group-addon\"><i class=\"" + icon + "\" data-icon=\"" + icon + "\"></i></span> \n";
        }
        
        result += "                        <select name=\"" + id + "\" id=\"" + id + "\" class=\"form-control selectpicker " + addClassName + "\" " + addAttr + "> \n";

        if (all) {
        	result += "                        <option value=''>" + allLabel + "</option> \n";	
        }
        
        for(int i=0; i<list.size(); i++) {
        	CommonMap item = list.get(i);
        	String addData = "";
        	
        	if (item.has("dataVal1")) addData += " data-val1='" + item.getString("dataVal1") + "'";
        	if (item.has("dataVal2")) addData += " data-val2='" + item.getString("dataVal2") + "'";
        	if (item.has("dataVal3")) addData += " data-val3='" + item.getString("dataVal3") + "'";
        	if (item.has("dataVal4")) addData += " data-val4='" + item.getString("dataVal4") + "'";
        	if (item.has("dataVal5")) addData += " data-val5='" + item.getString("dataVal5") + "'";
        	
        	result += "                        <option value=\"" + item.getString("value") + "\" " + (value.equals(item.getString("value")) ? "selected='selected'" : "") + " " + addData + ">" + item.getString("text") + "</option> \n";	
        }
                
        result += "                        </select> \n";
        result += "                    </div> \n";
        result += "                </div> \n";
        result += "            </div> \n";
        
		out.print(result);
	}
}
