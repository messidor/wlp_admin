package kr.yeongju.its.ad.common.util;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.MalformedURLException;
import java.net.URISyntaxException;
import java.net.URL;
import java.security.SecureRandom;
import java.sql.Date;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;


public final class CommonUtil {
	private static final String IS_MOBILE = "MOBILE";
	private static final String IS_PC = "PC";
    
    /**
     * 윈도우 운영체제
     */
    public static final int OS_WINDOWS = 50001;
    /**
     * UNIX (linux, unix, IBM aix) 운영체제
     */
    public static final int OS_UNIX = 50002;
    /**
     * MAC 운영체제
     */
    public static final int OS_MAC = 50003;
    /**
     * Solaris 운영체제
     */
    public static final int OS_SOLARIS = 50003;
    /**
     * OS 종류 알 수 없음
     */
    public static final int OS_UNKNOWN = -50000;
	
	/**
     * @static 그리드 전체 페이지 구하기
     * @param int totalCnt 전체 개수
     * @param int viewCnt 한 화면에 보여질 개수
     *
     * @return int
     */
    public static int getTotalPage(int totalCnt) {
        int viewCnt = 10;
        return totalCnt % viewCnt == 0 ? (totalCnt / viewCnt) : (totalCnt / viewCnt) + 1;
    }

    /**
     * @static 그리드 쿼리 조회용 시작 인덱스
     * @param int $p_NowPage 전체 개수
     * @param int $p_ViewCnt 한 화면에 보여질 개수
     *
     * @return int
     */
    public static int getStartIdx(int nowPage) {
        int viewCnt = 10;
        return ((nowPage - 1) * viewCnt) + 1;
    }

    /**
     * @static 그리드 쿼리 조회용 종료 인덱스
     * @param int $p_NowPage 전체 개수
     * @param int $p_ViewCnt 한 화면에 보여질 개수
     *
     * @return int
     */
    public static int getEndIdx(int nowPage) {
        int viewCnt = 10;
        return nowPage * viewCnt;
    }
    
    /**
     * @static 랜덤함수생성함수
     * @param int size 랜덤함수길이
     *
     * @return  String
     */
    public static String randomNumber(int size) {
		
		char[] charSet = new char[] {
                '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
                'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
                'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
                '!', '@', '#', '$', '%', '^', '&' };

        StringBuffer sb = new StringBuffer();
        SecureRandom sr = new SecureRandom();
        sr.setSeed(System.currentTimeMillis());

        int idx = 0;
        int len = charSet.length;
        for (int i=0; i<size; i++) {
            // idx = (int) (len * Math.random());
            idx = sr.nextInt(len);    // 강력한 난수를 발생시키기 위해 SecureRandom을 사용한다.
            sb.append(charSet[idx]);
        }
        
        return sb.toString();
    }
    
    /**
     * @static 랜덤 숫자+영문자 생성 함수(randomNumber에서 특수문자만 제외)
     * @param int size 결과 문자열 길이
     * @return  String
     */
    public static String randomString(int size) {
        
        char[] charSet = new char[] {
                '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
                'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
                'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'};

        StringBuffer sb = new StringBuffer();
        SecureRandom sr = new SecureRandom();
        sr.setSeed(System.currentTimeMillis());

        int idx = 0;
        int len = charSet.length;
        for (int i=0; i<size; i++) {
            // idx = (int) (len * Math.random());
            idx = sr.nextInt(len);    // 강력한 난수를 발생시키기 위해 SecureRandom을 사용한다.
            sb.append(charSet[idx]);
        }
        
        return sb.toString();
    }
    
    
    /**
     * @static IP 알아오는 함수
     * @param HttpServletRequest request
     *
     * @return  String
     */
    public static String getClientIP(HttpServletRequest request) {
        String ip = request.getHeader("X-Forwarded-For");

        if (ip == null) {
            ip = request.getHeader("Proxy-Client-IP");
        }
        if (ip == null) {
            ip = request.getHeader("WL-Proxy-Client-IP");
        }
        if (ip == null) {
            ip = request.getHeader("HTTP_CLIENT_IP");
        }
        if (ip == null) {
            ip = request.getHeader("HTTP_X_FORWARDED_FOR");
        }
        if (ip == null) {
            ip = request.getRemoteAddr();
        }
        
        //System.out.println("> Result : IP Address : "+ip);

        return ip;
    }
    
    /**
     * @static 모바일/웹 함수
     * @param HttpServletRequest request
     *
     * @return  String
     */
    public static String isDevice(HttpServletRequest req) {
        String userAgent = req.getHeader("User-Agent").toUpperCase();
    		
        if(userAgent.indexOf(IS_MOBILE) > -1) {
             return IS_MOBILE;
        } else {
            return IS_PC;
        }
    }
    
    /**
     * @static 모바일/웹 함수
     * @param HttpServletRequest request
     *
     * @return boolean 모바일 여부
     */
    public static boolean isMobile(HttpServletRequest req) {
        String userAgent = req.getHeader("User-Agent").toUpperCase();
        return (userAgent.indexOf(IS_MOBILE) > -1) ? true : false;
    }
    
    /**
     * @static 브라우저 종류 함수
     * @param HttpServletRequest request
     *
     * @return  String
     */
    public static String getClientBrowser(HttpServletRequest request) {
    	String agent = request.getHeader("USER-AGENT");
  	  
        String browser = "";
        
        if (agent.indexOf("Trident/7.0") > -1) {
          browser = "ie11";
        } else if (agent.indexOf("MSIE 10") > -1) {
        	browser = "ie10";
        } else if (agent.indexOf("MSIE 9") > -1) {
        	browser = "ie9";
        } else if (agent.indexOf("MSIE 8") > -1) {
        	browser = "ie8";
        } else if (agent.indexOf("Chrome/") > -1) {
        	browser = "Chrome";
        } else if (agent.indexOf("Chrome/") == -1 && agent.indexOf("Safari/") >= -1) {
        	browser = "Safari";
        } else if (agent.indexOf("Firefox/") >= -1) {
        	browser = "Firefox";
        } else {
        	browser ="Other";
        }
        
        return browser;
	}
    
    /**
     * 왼쪽 padding 함수 (LPAD)
     * @param origStr 원래 문자열
     * @param length 전체 길이
     * @param fillStr 채울 문자열
     * @return
     */
    public static String lpad(String origStr, int length, String fillStr) {
        return CommonUtil.pad(origStr, "L", length, fillStr);
    }
    
    /**
     * 오른쪽 padding 함수 (RPAD)
     * @param origStr 원래 문자열
     * @param length 전체 길이
     * @param fillStr 채울 문자열
     * @return
     */
    public static String rpad(String origStr, int length, String fillStr) {
        return CommonUtil.pad(origStr, "R", length, fillStr);
    }
    
    /**
     * 특정 문자를 반복하여 붙이는 함수
     * @param str 반복할 문자열
     * @param length 반복할 횟수
     * @return
     */
    public static String concatRepeat(String str, int length) {
        StringBuilder sb = new StringBuilder();
        
        for(int i = 0; i < length; i++) {
            sb.append(str);
        }
        
        return sb.toString();
    }
    
    /**
     * 왼쪽 혹은 오른쪽 padding 함수
     * @param origStr 원래 문자열 
     * @param direction "L"=왼쪽, "R"=오른쪽 padding
     * @param length 전체 길이
     * @param fillStr 채울 문자열
     * @return
     */
    public static String pad(String origStr, String direction, int length, String fillStr) {
        
        String result = "";
        direction = direction.toUpperCase();
        
        if(!"L".equals(direction) && !"R".equals(direction)) {
            return origStr;
        }
        
        if(origStr == null) {
            System.out.println(direction + "PAD :: original string is null");
            return "";
        }
        
        if("".equals(origStr)) {
            System.out.println(direction + "PAD :: original string is empty");
            return origStr;
        }
        
        if(length < 1) {
            System.out.println(direction + "PAD :: length should be larger than original string length.");
            return origStr;
        }
        
        if(origStr.length() >= length) {
            System.out.println(direction + "PAD :: original string length is greater or equal than length.");
            return origStr;
        }
        
        if(fillStr == null) {
            System.out.println(direction + "PAD :: fill string is null");
            return origStr;
        }
        
        if("".equals(fillStr)) {
            System.out.println(direction + "PAD :: fill string is empty");
            return origStr;
        }
        
        result = CommonUtil.concatRepeat(fillStr, length - origStr.length());
        
        if("L".equals(direction)) {
            result += origStr;
            
        } else if("R".equals(direction)) {
            result = origStr + result;
        }
        
        return result;
    }
    
    /**
     * 길이만큼의 숫자로 이루어진 랜덤 문자열을 생성
     * @param length 랜덤 문자열을 만들 길이
     * @return 만들어진 문자열
     */
    public static String fnMakeRandomNumOnly(int length) {
        String result = "";

        for(int i = 0; i < length; i++) {
            result += String.valueOf((int)(Math.random() * 10));
        }

        return result;
    }

    /**
     * yyyyMMddHHmissSSS + 랜덤숫자 3자리 형태의 문자열을 생성
     * @return
     */
    public static String fnMakeRandomNum() {
        return CommonUtil.fnMakeRandomNum(3);
    }

    /**
     * yyyyMMddHHmissSSS + 랜덤숫자 형태의 문자열을 생성
     * @param length 랜덤 부분의 길이
     * @return yyyyMMddHHmissSSS + 랜덤숫자 형태의 문자열
     */
    public static String fnMakeRandomNum(int length) {
        String result = "";

        for(int i = 0; i < length; i++) {
            result += String.valueOf((int)(Math.random() * 10));
        }

        return CommonUtil.fnMakeKey("") + result;
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
    
    /**
     * 휴대폰 번호 표시 방식 변경
     * @param pn 휴대폰 번호 (숫자만으로 이루어진 문자열)
     * @return 번호에 따른 dash("-")가 붙은 전화번호 문자열
     */
    public static String phoneNumber(String pn) {
        return CommonUtil.phoneNumber(pn, 1);
    }
    
    /**
     * 휴대폰 번호 표시 방식 변경
     * @param pn 휴대폰 번호 (숫자만으로 이루어진 문자열)
     * @param type 0:중간번호 마스킹("*" 마스킹), 나머지는 마스킹하지 않음
     * @return 번호에 따른 dash("-")가 붙은 전화번호 문자열
     */
    public static String phoneNumber(String pn, int type) {
        
        String retNum = pn;
        
        if(pn.length() == 11) {
            retNum = pn.replaceAll("(\\d{3})(\\d{4})(\\d{4})", (type == 0 ? "$1-****-$3" : "$1-$2-$3"));
        } else if(pn.length() == 8) {
            retNum = pn.replaceAll("(\\d{4})(\\d{4})", "$1-$2");
        } else {
            if(pn.startsWith("02")) {
                retNum = pn.replaceAll("(\\d{2})(\\d{4})(\\d{4})", (type == 0 ? "$1-****-$3" : "$1-$2-$3"));
            } else if(pn.length() == 9) {
                retNum = pn.replaceAll("(\\d{2})(\\d{3,4})(\\d{4})", (type == 0 ? "$1-****-$3" : "$1-$2-$3"));
            } else {
                retNum = pn.replaceAll("(\\d{3})(\\d{3})(\\d{4})", (type == 0 ? "$1-****-$3" : "$1-$2-$3"));
            }
        }
        
        return retNum;
    }

    /**
     * HTML 특수문자를 원래 문자로 replace 해 주는 함수
     * (<code>textarea</code> 안에 값을 세팅할 때에는 특수문자 치환 필요 없음)
     * @param orig
     * @return
     */
    public static String htmlSpecalCharsRestore(String orig) {
        String res = orig;
        res = res.replace("&gt;", ">");
        res = res.replace("&lt;", "<");
        return res;
    }

    /**
     * HTML 문자열을 태그로 인식하지 못하게 문자를 replace 해 주는 함수
     * @param orig
     * @return
     */
    public static String htmlSpecalChars(String orig) {
        String res = orig;
        res = res.replace(">", "&gt;");
        res = res.replace("<", "&lt;");
        return res;
    }
    
    /**
     * 문자열을 정수로 변경, 오류 발생시 0으로 리턴
     * @param str 변경할 문자열
     * @return 변경된 정수
     */
    public static int toInt(String str) {
        int result = 0;
        
        try {
            result = Integer.parseInt(str, 10);
        } catch(Exception e) {
            result = 0;
        }
        
        return result;
    }
    
    /**
     * 문자열을 실수(Double)로 변경, 오류 발생시 0으로 리턴
     * @param str 변경할 문자열
     * @return 변경된 실수(Double)
     */
    public static double toDouble(String str) {
        double result = 0;
        
        try {
            result = Double.parseDouble(str);
        } catch(Exception e) {
            result = 0;
        }
        
        return result;
    }
    
    /**
     * 문자열로 된 두 날짜(날짜2 - 날짜1)의 초단위 시간 차이 계산
     * @param pDate1 날짜1 (yyyy-MM-dd HH:mm:ss)
     * @param pDate2 날짜2 (yyyy-MM-dd HH:mm:ss)
     * @return 두 날짜의 차이 시간 (날짜1이 크면 마이너스값이 리턴됨)
     */
    public static int getDiffTimeSec(String pDate1, String pDate2) {
        return getDiffTime(pDate1, pDate2, "s");
    }
    
    /**
     * 문자열로 된 두 날짜(날짜2 - 날짜1)의 분단위 시간 차이 계산
     * @param pDate1 날짜1 (yyyy-MM-dd HH:mm:ss)
     * @param pDate2 날짜2 (yyyy-MM-dd HH:mm:ss)
     * @return 두 날짜의 차이 시간 (날짜1이 크면 마이너스값이 리턴됨)
     */
    public static int getDiffTimeMin(String pDate1, String pDate2) {
        return getDiffTime(pDate1, pDate2, "m");
    }
    
    /**
     * 문자열로 된 두 날짜(날짜2 - 날짜1)의 시간 차이 계산 (시간단위, 분단위, 초단위만)
     * @param pDate1 날짜1 (yyyy-MM-dd HH:mm:ss)
     * @param pDate2 날짜2 (yyyy-MM-dd HH:mm:ss)
     * @param pUnit 단위 (h:시간, m:분, s:초)
     * @return 두 날짜의 차이 시간 (날짜1이 크면 마이너스값이 리턴됨)
     */
    public static int getDiffTime(String pDate1, String pDate2, String pUnit) {
        try {
            SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        
            java.util.Date d1 = formatter.parse(pDate1);
            java.util.Date d2 = formatter.parse(pDate2);
            
            long timeMill1 = d1.getTime();
            long timeMill2 = d2.getTime();
            
            long diff = timeMill2 - timeMill1;
            
            if("h".equals(pUnit.toLowerCase())) {
                return (int)(diff / (1000 * 60 * 60));
            } else if("m".equals(pUnit.toLowerCase())) {
                return (int)(diff / (1000 * 60));
            } else if("s".equals(pUnit.toLowerCase())) {
                return (int)(diff / 1000);
            } else {
                return 0;
            }
        } catch(Exception e) {
            return 0;
        }
    }

    
    /**
     * OS 체크
     * @return OS_WINDOWS, OS_MAC, OS_UNIX(Linux, UNIX, IBM AIX), OS_SOLARIS, OS_UNKNOWN(판단 불가) 중 하나
     */
    public static int osCheck() {
        String osString = System.getProperty("os.name").toLowerCase();
        
        if(osString.indexOf("win") > -1) {
            return OS_WINDOWS;
        } else if(osString.indexOf("mac") > -1) {
            return OS_MAC;
        } else if(osString.indexOf("nix") > -1 || osString.indexOf("nux") > -1 || osString.indexOf("aix") > -1) {
            return OS_UNIX;
        } else if(osString.indexOf("sunos") > -1) {
            return OS_SOLARIS;
        } else {
            return OS_UNKNOWN;
        }
    }
    
    public static boolean urlCheck(String url) {
        try {
            new URL(url).toURI();
            return true;
        } catch(URISyntaxException e1) {
            return false;
        } catch(MalformedURLException e2) {
            return false;
        } catch(Exception ex) {
            return false;
        }
    }
    
    public static String execCommand(String cmdName, String[] cmdParam) {
        String result = "";
        String s = "";
        try {
            Process process = Runtime.getRuntime().exec(cmdName, cmdParam);
            BufferedReader br = new BufferedReader(new InputStreamReader(process.getInputStream()));
            while((s = br.readLine()) != null) {
                result += s;
            }
            process.waitFor();
            process.destroy();
        } catch(Exception e) {
            result = "";
            e.printStackTrace();
        }
        return result;
    }
}
