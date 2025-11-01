package kr.yeongju.its.ad.common.util;

import java.util.ArrayList;
import java.util.List;

import org.springframework.context.ApplicationContext;

import kr.yeongju.its.ad.common.config.ApplicationContextProvider;
import kr.yeongju.its.ad.common.dto.CommonMap;
import kr.yeongju.its.ad.core.service.CommonService;

public final class AuthUtils {

	public static List<CommonMap> getList(CommonMap param, String url) {
        ApplicationContext context = ApplicationContextProvider.getApplicationContext();
		List<CommonMap> result = new ArrayList<CommonMap>();
		EncUtil enc = new EncUtil();
		
        try {
            CommonService service = context.getBean(CommonService.class);
            param.put("userId", enc.encrypt(param.getString("userId")), false);
            param.put("queryId", "common.select_checkHasAuth");
            param.put("url", url);
            
            List<CommonMap> btnList = service.select(param);
            for(int i=0; i<btnList.size(); i++) {
            	CommonMap button = btnList.get(i);
            	
            	if ("Search".equals(button.getString("btnId"))) {
            		return btnList;
            	}
            }
            
		} catch (Exception e) {
			System.out.println(e.getMessage());
		}
		
		return result;		
	}
	
	public static String getPopupUrl(CommonMap param, String url) {
        ApplicationContext context = ApplicationContextProvider.getApplicationContext();
		String result = "";
        
        try {
            CommonService service = context.getBean(CommonService.class);
            
            param.put("queryId", "common.select_popupUrl");
            param.put("url", url);
            
            List<CommonMap> menuList = service.select(param);
            if (menuList.size() > 0) {
            	return menuList.get(0).getString("menuUrl");
            }
            
		} catch (Exception e) {
			System.out.println(e.getMessage());
		}
		
		return result;		
	}
}
