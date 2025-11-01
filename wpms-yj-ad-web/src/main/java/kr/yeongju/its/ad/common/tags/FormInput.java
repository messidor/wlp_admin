package kr.yeongju.its.ad.common.tags;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.http.HttpSession;
import javax.servlet.jsp.JspContext;
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
public class FormInput extends SimpleTagSupport {
	private String type = "text";
	private String id = "";
	private String caption = "";
	private String size = "2";
	private String value = "";
	private String className = "default";
	private String addClassName = "";
	private String addAttr = "";
	private int colNum = 0;
	private String queryId = "";
	private boolean all = false;
	private String allLabel = "";
	private String code = "";
	
	
	@Override
	public void doTag() throws JspException, IOException {
        ApplicationContext context = ApplicationContextProvider.getApplicationContext();
        PageContext pageContext = (PageContext) getJspContext();
        JspWriter out = pageContext.getOut();
        String result = "";

        if ("hidden".equals(type)) {
            result += "            <input type=\"hidden\" name=\"" + id + "\" id=\"" + id + "\" value=\"" + value + "\" > \n";
        } else if ("checkbox".equals(type) || "radio".equals(type)) {
            List<CommonMap> list = new ArrayList<CommonMap>();
            HttpSession session = pageContext.getSession();
            if (StringUtils.isEmpty(allLabel)) allLabel = "L00118";

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
            } catch (Exception e) { }
        	String style = "";
        	
        	if (colNum > 0) style = " style=\"width:calc(100% / " + colNum + "); padding-right:0px;\"";

            result += "            <div class=\"col-xl-" + size + " col-lg-" + size + " col-md-12 col-sm-12 col-12\"> \n";
            result += "                <div class=\"form-group form-" + className  + " form-static-label\"> \n";
            result += "                    <div class=\"form-control fill\"> \n";

            if (all) {
            	result += "                        <label class=\"search-cond\"" + style + "><input type=\"" + type + "\" id=\"" + id + "_checkall\" name=\"" + id + "\" value=\"\" data-checkbox=\"" + id + "_checkall\" />&nbsp;" + allLabel + "</label> \n";	
            }
            
            for(int i=0; i<list.size(); i++) {
            	CommonMap item = list.get(i);
            	String addData = "";
            	            	
            	if (item.has("dataVal1")) addData += " data-val1='" + item.getString("dataVal1") + "'";
            	if (item.has("dataVal2")) addData += " data-val2='" + item.getString("dataVal2") + "'";
            	if (item.has("dataVal3")) addData += " data-val3='" + item.getString("dataVal3") + "'";
            	if (item.has("dataVal4")) addData += " data-val4='" + item.getString("dataVal4") + "'";
            	if (item.has("dataVal5")) addData += " data-val5='" + item.getString("dataVal5") + "'";
            	if (all && "checkbox".equals(type)) addData += "data-checkbox=\"" + id + "_item\"";
            	
            	result += "                        <label class=\"search-cond\"" + style + "><input type=\"" + type + "\" id=\"" + (id + i) + "\" name=\"" + id + "\" value=\"" + item.getString("value") + "\" " + addData + (value.equals(item.getString("value")) ? " checked='checked'" : "") +" />&nbsp;" + item.getString("text") + "</label> \n";	
            }
            
            result += "                    </div> \n";
            result += "                    <label class=\"float-label select-label\">" + caption + "</label> \n";
            result += "                </div> \n";
            result += "            </div> \n";
        } else if ("autocomplete".equals(type)) {
            result += "            <div class=\"col-xl-" + size + " col-lg-" + size + " col-md-12 col-sm-12 col-12\"> \n";
            result += "                <div class=\"form-group form-" + className  + ("danger".equals(className) ? " form-static-label" : "") + "\"> \n";
            result += "                    <input type=\"text\" name=\"" + id + "\" id=\"" + id + "\" value=\"" + value + "\" autocomplete=\"off\" class=\"form-control basicAutoComplete " + (StringUtils.isEmpty(value) ? "" : "fill") + " " + addClassName + " \" " + addAttr + " data-code=\"" + code + "\" data-query-id=\"" + queryId + "\" > \n";
            result += "                    <input type=\"hidden\" name=\"" + code + "\" id=\"" + code + "\"  > \n";
            result += "                    <span class=\"form-bar\"></span><label class=\"float-label\">" + caption + "</label> \n";
            result += "                </div> \n";
            result += "            </div> \n";
        } else {
            result += "            <div class=\"col-xl-" + size + " col-lg-" + size + " col-md-12 col-sm-12 col-12\"> \n";
            result += "                <div class=\"form-group form-" + className  + ("danger".equals(className) ? " form-static-label" : "") + "\"> \n";
            result += "                    <input type=\"text\" name=\"" + id + "\" id=\"" + id + "\" value=\"" + value + "\" class=\"form-control " + (StringUtils.isEmpty(value) ? "" : "fill") + " " + addClassName + " \" " + addAttr + "> \n";
            result += "                    <span class=\"form-bar\"></span><label class=\"float-label\">" + caption + "</label> \n";
            result += "                </div> \n";
            result += "            </div> \n";
        }
        
		out.print(result);
	}
	


}
