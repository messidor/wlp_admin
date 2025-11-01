package kr.yeongju.its.ad.common.util;

import java.util.regex.Pattern;

import javax.servlet.http.HttpServletRequest;

public final class DeviceUtils {
	
	public static String getBrowser(HttpServletRequest request) {
		String header = request.getHeader("User-Agent");
		
	  	if (header != null) {
	        if (Pattern.matches("/MSIE*/", header)) {
	            return "4";
	        } else if (Pattern.matches("/Trident*/", header) && Pattern.matches("/rv:11.0*/", header) && Pattern.matches("/Gecko*/", header)) {
	            return "4";
	        } else if (Pattern.matches("/Edge\\/*/", header)) {
	            return "6";
	        } else if (Pattern.matches("/(Mozilla)*/", header)) {
	            return "3";

	        } else if (Pattern.matches("/(Chrome)*/", header)) {
	            return "1";
	        } else if (Pattern.matches("/(Safari)*/", header)) {
	            return "2";
	        } else if (Pattern.matches("/(Nav|Gold|X11|Mozilla|Nav|Netscape)*/", header)) {
	            return "3";
	        } else if (Pattern.matches("/Opera*/", header)) {
	            return "5";
	        }
	  	}
	  	
	  	return "";
	}
}
