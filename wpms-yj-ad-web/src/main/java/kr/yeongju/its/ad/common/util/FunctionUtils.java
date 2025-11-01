package kr.yeongju.its.ad.common.util;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.Calendar;

import javax.servlet.jsp.PageContext;

import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.context.ApplicationContext;

import com.fasterxml.jackson.databind.ObjectMapper;

import kr.yeongju.its.ad.common.config.ApplicationContextProvider;
import kr.yeongju.its.ad.common.dto.CommonMap;
import kr.yeongju.its.ad.core.service.CommonService;

public final class FunctionUtils {

	public static String codeToJSON(PageContext pageContext, String id) {
        ApplicationContext context = ApplicationContextProvider.getApplicationContext();
		String result = "{}";
        
        try {
            CommonService service = context.getBean(CommonService.class);
            CommonMap param = MapUtils.parseSession(pageContext.getSession());
			ObjectMapper mapper = new ObjectMapper();
            
            param.put("queryId", "common.select_commCode");
            param.put("parentCodeId", id.toUpperCase());
			
			result = mapper.writeValueAsString(service.select(param));
		} catch (Exception e) {
			System.out.println(e.getMessage());
		}
		
		return result;		
	}
	
	public static String queryToJSON(PageContext pageContext, String queryId) {
        ApplicationContext context = ApplicationContextProvider.getApplicationContext();
		String result = "{}";
        
        try {
			CommonService service = context.getBean(CommonService.class);
            CommonMap param = MapUtils.parseSession(pageContext.getSession());
			ObjectMapper mapper = new ObjectMapper();
            
            param.put("queryId", queryId);
            
			result = mapper.writeValueAsString(service.select(param));
		} catch (Exception e) {
			System.out.println(e.getMessage());
		}
		
		return result;		
	}
	
	public static String langToJSON(PageContext pageContext) {
        ApplicationContext context = ApplicationContextProvider.getApplicationContext();
		String result = "{}";
        
        try {
			ObjectMapper mapper = new ObjectMapper();
			result = result.replaceAll("\\\\n", "\\n");
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		return result;		
	}
	
	public static String formatter(String type, String value) {
		String result = value;
        
        try {
            switch(type) {
                case "phone": // 전화번호
                    if (value.length() > 11) {
                        value = value.substring(0, 11);
                    }

                    if (value.length() == 11) {
                        return value.replaceAll("(\\d{3})(\\d{4})(\\d{4})", "$1-$2-$3");
                    } else if(value.length() == 8) {
                        return value.replaceAll("(\\d{4})(\\d{4})", "$1-$2");
                    } else {
                        if(value.indexOf("02") == 0) {
                            return value.replaceAll("(\\d{2})(\\d{4})(\\d{4})", "$1-$2-$3");
                        } else {
                            return value.replaceAll("(\\d{3})(\\d{3})(\\d{4})", "$1-$2-$3");
                        }
                    }
                case "business": // 사업자 등록번호
                	if (value.length() > 10) {
                        value = value.substring(0, 10);
                    }
                	
                	return value.replaceAll("(\\d{3})(\\d{2})(\\d{5})", "$1-$2-$3");
            }
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		return result;
	}
	
	public static String fnMakeKey(String prefix){
		String result = "";
		String month_str = "";
		String day_str = "";
		String hour_str = "";
		String minute_str = "";
		String second_str = "";
		String milliSecond_str 	= "";
		
		Calendar c = Calendar.getInstance();
		int year = c.get(Calendar.YEAR);
		int month = (c.get(Calendar.MONTH)+1);
		int day = c.get(Calendar.DATE);
		int hour = c.get(Calendar.HOUR_OF_DAY);
		int minute = c.get(Calendar.MINUTE);
		int second = c.get(Calendar.SECOND);
		int milliSecond = c.get(Calendar.MILLISECOND);
		
		if(month<10){	
			month_str="0"+month;			
		}else{	
			month_str=""+month;			
		}
		
		if(day<10){
			day_str="0"+day;
		}else{
			day_str=""+day;				
		}
		
		if(hour<10){
			hour_str="0"+hour;				
		}else{
			hour_str=""+hour;				
		}
		
		if(minute<10){
			minute_str="0"+minute;			
		}else{	
			minute_str=""+minute;		
		}
		
		if(second<10){	
			second_str="0"+second;			
		}else{	
			second_str=""+second;		
		}
		
		if(milliSecond<10){		
			milliSecond_str="00"+milliSecond;					
		}else{	
			if(milliSecond<100){	
				milliSecond_str="0"+milliSecond;			
			}else{	
				milliSecond_str=""+milliSecond;
			}
		}
		
		result = prefix + year + month_str + day_str + hour_str + minute_str + second_str + milliSecond_str;
		
		return result;
	}
}
