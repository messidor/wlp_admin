package kr.yeongju.its.ad.common.util;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.json.simple.parser.ParseException;
import kr.yeongju.its.ad.common.dto.CommonMap;

public class CallApiUtil {
    
    /**
     * 특정 URL을 POST 방식으로 호출하여 결과를 문자열 형태로 받음
     * @param pUrl URL
     * @param params 파라미터(키/값 형태)
     * @return 호출 결과
     */
    public static String post(String pUrl, CommonMap params) {
        String result = "";
        
        try {
            if(!CommonUtil.urlCheck(pUrl.trim())) {
                System.out.println("-----=====***** CallApiUtil.post AD : API URL is empty. *****=====-----");
                return CallApiUtil.makeErrorJSON("-910", "API URL이 잘못되었거나 비어 있습니다.");
            }
            
            System.out.println("-----=====***** CallApiUtil.post AD call Start. URL: [" + pUrl + "] *****=====-----");
            URL url = new URL(pUrl);
            
            StringBuilder postData = new StringBuilder();
            
            for(Object key : params.keyList()) {
                if(postData.length() > 0) {
                    postData.append("&");
                }
                
                postData.append(URLEncoder.encode(key.toString(), "UTF-8"));
                postData.append("=");
                postData.append(URLEncoder.encode(params.getString(key.toString()), "UTF-8"));
            }

            System.out.println("-----=====***** CallApiUtil.post AD Parameters URL: [" + pUrl + "] *****=====-----");
            System.out.println("Stringify Parameters: [" + postData.toString() + "]");
            
            // 길이를 재기 위함
            byte[] postDataBytes = postData.toString().getBytes("UTF-8");
            
            HttpURLConnection conn = (HttpURLConnection)url.openConnection();
            conn.setConnectTimeout(5000);
            conn.setReadTimeout(10000);
            conn.setRequestMethod("POST");
            conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
            conn.setRequestProperty("Content-Length", String.valueOf(postDataBytes.length));
            conn.setDoOutput(true);
            
            System.out.println("-----=====***** CallApiUtil.post AD call activated. URL: [" + pUrl + "] *****=====-----");
            conn.getOutputStream().write(postDataBytes); // POST 호출
            
            BufferedReader in = new BufferedReader(new InputStreamReader(conn.getInputStream(), "UTF-8"));
            String inputLine;
            while((inputLine = in.readLine()) != null) {
                result += inputLine;
            }
            System.out.println("-----=====***** CallApiUtil.post AD call finished. URL: [" + pUrl + "] *****=====-----");
            System.out.println("Call Result String: [" + result + "]");
            
            in.close();
        } catch(Throwable e) {
            System.out.println("-----=====***** CallApiUtil.post AD Exception occured. URL: [" + pUrl + "] *****=====-----");
            result = CallApiUtil.makeErrorJSON("-2000", e.getMessage());
            e.printStackTrace();
        }
        return result;
    }
    
    /**
     * 특정 URL을 GET 방식으로 호출하여 결과를 리턴받음
     * @param pUrl URL
     * @param params 파라미터(키/값 형태)
     * @return 호출 결과
     */
    public static String get(String pUrl, CommonMap params, boolean isParameter) {
        
        String result = "";

        try {
            if(!CommonUtil.urlCheck(pUrl.trim())) {
                System.out.println("-----=====***** CallApiUtil.get AD : API URL is empty. *****=====-----");
                return CallApiUtil.makeErrorJSON("-910", "API URL이 잘못되었거나 비어 있습니다.");
            }
            
            URL url;
            
            if(isParameter) {
            
                StringBuilder getParams = new StringBuilder();
                
                for(Object key : params.keyList()) {
                    if(getParams.length() > 0) {
                        getParams.append("&");
                    }
                    
                    getParams.append(URLEncoder.encode(key.toString(), "UTF-8"));
                    getParams.append("=");
                    getParams.append(URLEncoder.encode(params.getString(key.toString()), "UTF-8"));
                }
                
                url = new URL(pUrl + "?" + getParams.toString());
                
                System.out.println("-----=====***** CallApiUtil.get AD Parameters URL: [" + pUrl + "] *****=====-----");
                System.out.println("URL With Stringify Parameters: [" + pUrl + "?" + getParams.toString() + "]");
            } else {
                url = new URL(pUrl);
                System.out.println("-----=====***** CallApiUtil.get US Parameters URL: [" + pUrl + "] *****=====-----");
                System.out.println("URL With Stringify Parameters: [" + pUrl + "] (Querystring or no parameters)");
            }
            
            HttpURLConnection conn = (HttpURLConnection)url.openConnection();
            conn.setConnectTimeout(5000);
            conn.setReadTimeout(10000);
            conn.setRequestMethod("GET");
            conn.setRequestProperty("Content-Type", "application/json");
            
            System.out.println("-----=====***** CallApiUtil.get AD call activated. URL: [" + pUrl + "] *****=====-----");
            
            BufferedReader in = new BufferedReader(new InputStreamReader(conn.getInputStream(), "UTF-8"));
            String inputLine;
            while((inputLine = in.readLine()) != null) {
                result += inputLine;
            }
            System.out.println("-----=====***** CallApiUtil.get AD call finished. URL: [" + pUrl + "] *****=====-----");
            System.out.println("Call Result String: [" + result + "]");
            
            in.close();
        } catch(Exception e) {
            System.out.println("-----=====***** CallApiUtil.post AD Exception occured. URL: [" + pUrl + "] *****=====-----");
            result = CallApiUtil.makeErrorJSON("-2000", e.getMessage());
            e.printStackTrace();
        }
        
        return result;
    }
    
    // 특정 오류 코드와 문자열로 오류 JSON 을 만들어서 리턴
    private static String makeErrorJSON(String errorCode, String errorString) {
        StringBuilder errStr = new StringBuilder();
        
        errStr.append("{ ");
        errStr.append("    \"success\" : false, ");
        errStr.append("    \"error\" : {, ");
        errStr.append("        \"ERROR_CODE\" : \"" + errorCode + "\", ");
        errStr.append("        \"ERROR_STRING\" : \"" + errorString + "\", ");
        errStr.append("    }, ");
        errStr.append("}");
        
        return errStr.toString();
    }
    
    // JSON 파싱 함수
    public static CommonMap parseJSON(String toParseJson) {
        
        /**
         * 결과
         * 
         * 1) resultCode : 1 이외에 모두 오류
         * 2) resultMsg : resultCode가 1이 아닌 경우 메시지가 들어감
         * 
         * 
         * 오류 코드 (한맥)
         * 
         * 1) 400 오류
         * -3        : 지원하지 않는 서비스입니다.
         * -101      : 필수 파라미터가 없습니다.
         * -102      : 이미 등록된 데이터입니다.
         * -103      : 데이터 크기가 너무 큽니다.
         * -104      : 데이터 값이 잘못되었습니다.
         * -105      : 데이터 유형이 잘못되었습니다.
         * -99999    : 정의되지 않은 예외입니다.
         * 
         * 2) 405 오류
         * -4        : 지원하지 않는 메서드입니다.
         * 
         * 3) 스마트 주차 시스템용 코드
         * -900001   : 주차장 정보가 올바르지 않습니다.
         * -900002   : 유효하지 않은 서비스키입니다.
         * -900003   : 필수정보가 올바르지 않습니다.
         * -900004   : 입차정보가 존재하지 않습니다.
         * -900005   : 올바르지 않은 감면정보입니다.
         * 
         * 4) 모듈 자체 리턴값
         * -900      : API 에서 처리 성공 코드가 아닌 다른 코드를 리턴한 경우
         * -1000     : json 배열을 받았으나, success 항목이 없는 경우
         * -1100     : 문자열을 json 배열로 파싱하는데 실패한 경우
         * -2000     : 기타 오류
         */
        
        CommonMap result = new CommonMap();
        
        result.put("resultCode", "");
        result.put("resultMsg", "");
        
        JSONParser parser = new JSONParser();
        
        try {
            JSONObject res = null;
            
            try {
                
                // 받은 값이 빈값인 경우 수신 데이터가 없다는 오류 추가
                if("".equals(toParseJson.trim())) {
                    result.put("resultCode", "-1101");
                    result.put("resultMsg", "서버 오류가 발생하였습니다.");
                    result.put("errMsg", "수신 데이터가 없습니다.");
                    result.put("isSuccess", "");
                    System.out.println("--- ParseException occured(-1101). Original String: (" + toParseJson + ")");
                    return result;
                }

                res = (JSONObject) parser.parse(toParseJson);
                
                if(res.containsKey("success")) {
                    boolean isSuccess = (boolean) res.get("success");
                    
                    if(isSuccess) {
                        result.put("isSuccess", "true");
                        
                        JSONObject resultDoc = (JSONObject) res.get("result");
                        long rtnCode;
                        
                        if(res.containsKey("RTN_CODE")) {
                            // result 키값이 있으면 받아옴
                            rtnCode = (long) resultDoc.get("RTN_CODE");
                        } else {
                            // 없으면 정상 처리. (애초에 success = true 이기 때문)
                            rtnCode = 1;
                        }
                        
                        if(rtnCode == 1) {
                            // 정상처리 된 경우
                            result.put("resultCode", "1");
                            result.put("resultMsg", "");
                            result.put("errMsg", "");
                            System.out.println("--- (AD) API Result returns OK.");
                        } else {
                            // API 에서 반환한 결과 확인 시 처리되지 않은 경우
                            result.put("resultCode", "-900");
                            result.put("resultMsg", "처리에 실패하였습니다.");
                            result.put("errMsg", "RTN_CODE 가 1이 아닙니다.(" + rtnCode + ")");
                            System.out.println("--- (AD) API Result is OK. But return code is not 1. Original String: (" + toParseJson + ")");
                        }
                    } else {
                        result.put("isSuccess", "false");
                        // success : false 일 경우
                        JSONObject errorObj = (JSONObject) res.get("error");
                        result.put("resultCode", (String)errorObj.get("ERROR_CODE"));
                        result.put("resultMsg", "오류가 발생하였습니다.");
                        result.put("errMsg", (String)errorObj.get("ERROR_STRING"));
                        System.out.println("--- (AD) API Result returns error. Original String: (" + toParseJson + ")");
                    }
                } else {
                    // json 배열이기는 하나, success 항목이 없는 경우
                    result.put("resultCode", "-1000");
                    result.put("resultMsg", "서버 오류가 발생하였습니다.");
                    result.put("errMsg", "success 항목이 없습니다.");
                    result.put("isSuccess", "");
                    System.out.println("--- (AD) key \"success\" does not exists(-1000). Original String: (" + toParseJson + ")");
                }
            } catch(ParseException pe) {
                // json 배열이 아니라서 변환 오류가 발생한 경우
                result.put("resultCode", "-1100");
                result.put("resultMsg", "서버 오류가 발생하였습니다.");
                result.put("errMsg", "JSON 배열이 아닙니다.");
                result.put("isSuccess", "");
                System.out.println("--- (AD) ParseException occured(-1100). Original String: (" + toParseJson + ")");
                pe.printStackTrace();
            }
        } catch(Throwable e) {
            // 기타 오류 발생
            result.put("resultCode", "-2000");
            result.put("resultMsg", "서버 오류가 발생하였습니다.");
            result.put("errMsg", "알 수 없는 오류가 발생하였습니다.");
            result.put("isSuccess", "");
            System.out.println("--- (AD) Exception occured(-2000). Original String: (" + toParseJson + ")");
            e.printStackTrace();
        }
        
        return result;
    }
    
    // JSON 파싱 함수 (배열이 아닌 JSON 결과가 있다면 파싱 처리)
    public static CommonMap parseJSONDoc(String toParseJson) {
        
        /**
         * 결과
         * 
         * 1) resultCode : 1 이외에 모두 오류
         * 2) resultMsg : resultCode가 1이 아닌 경우 메시지가 들어감
         * 
         * 
         * 오류 코드 (한맥)
         * 
         * 1) 400 오류
         * -3        : 지원하지 않는 서비스입니다.
         * -101      : 필수 파라미터가 없습니다.
         * -102      : 이미 등록된 데이터입니다.
         * -103      : 데이터 크기가 너무 큽니다.
         * -104      : 데이터 값이 잘못되었습니다.
         * -105      : 데이터 유형이 잘못되었습니다.
         * -99999    : 정의되지 않은 예외입니다.
         * 
         * 2) 405 오류
         * -4        : 지원하지 않는 메서드입니다.
         * 
         * 3) 스마트 주차 시스템용 코드
         * -900001   : 주차장 정보가 올바르지 않습니다.
         * -900002   : 유효하지 않은 서비스키입니다.
         * -900003   : 필수정보가 올바르지 않습니다.
         * -900004   : 입차정보가 존재하지 않습니다.
         * -900005   : 올바르지 않은 감면정보입니다.
         * 
         * 4) 모듈 자체 리턴값
         * -900      : API 에서 처리 성공 코드가 아닌 다른 코드를 리턴한 경우
         * -1000     : json 배열을 받았으나, success 항목이 없는 경우
         * -1100     : 문자열을 json 배열로 파싱하는데 실패한 경우
         * -2000     : 기타 오류
         */
        
        CommonMap result = new CommonMap();
        
        result.put("resultCode", "");
        result.put("resultMsg", "");
        
        JSONParser parser = new JSONParser();
        
        try {
            JSONObject res = null;
            
            try {
                
                // 받은 값이 빈값인 경우 수신 데이터가 없다는 오류 추가
                if("".equals(toParseJson.trim())) {
                    result.put("resultCode", "-1101");
                    result.put("resultMsg", "서버 오류가 발생하였습니다.");
                    result.put("errMsg", "수신 데이터가 없습니다.");
                    result.put("isSuccess", "");
                    System.out.println("--- ParseException occured(-1101). Original String: (" + toParseJson + ")");
                    return result;
                }

                res = (JSONObject) parser.parse(toParseJson);
                
                if(res.containsKey("success")) {
                    boolean isSuccess = (boolean) res.get("success");
                    
                    if(isSuccess) {
                        result.put("isSuccess", "true");
                        
                        JSONObject resultDoc = (JSONObject) res.get("result");
                        long rtnCode;
                        
                        if(res.containsKey("RTN_CODE")) {
                            // result 키값이 있으면 받아옴
                            rtnCode = (long) resultDoc.get("RTN_CODE");
                        } else {
                            // 없으면 정상 처리. (애초에 success = true 이기 때문)
                            rtnCode = 1;
                        }
                        
                        if(rtnCode == 1) {
                            // 정상처리 된 경우
                            
                            // 나머지 값들 찾아서 추가
                            for(Object key : resultDoc.keySet()) {
                                result.put(key.toString(), resultDoc.get(key.toString()));
                            }
                            
                            // 기본 결과 코드, 메시지, 오류 메시지 추가
                            result.put("resultCode", "1");
                            result.put("resultMsg", "");
                            result.put("errMsg", "");
                            
                            System.out.println("--- (AD) API Result returns OK.");
                        } else {
                            // API 에서 반환한 결과 확인 시 처리되지 않은 경우
                            result.put("resultCode", "-900");
                            result.put("resultMsg", "처리에 실패하였습니다.");
                            result.put("errMsg", "RTN_CODE 가 1이 아닙니다.(" + rtnCode + ")");
                            System.out.println("--- (AD) API Result is OK. But return code is not 1. Original String: (" + toParseJson + ")");
                        }
                    } else {
                        result.put("isSuccess", "false");
                        // success : false 일 경우
                        JSONObject errorObj = (JSONObject) res.get("error");
                        result.put("resultCode", (String)errorObj.get("ERROR_CODE"));
                        result.put("resultMsg", "오류가 발생하였습니다.");
                        result.put("errMsg", (String)errorObj.get("ERROR_STRING"));
                        System.out.println("--- (AD) API Result returns error. Original String: (" + toParseJson + ")");
                    }
                } else {
                    // json 배열이기는 하나, success 항목이 없는 경우
                    result.put("resultCode", "-1000");
                    result.put("resultMsg", "서버 오류가 발생하였습니다.");
                    result.put("errMsg", "success 항목이 없습니다.");
                    result.put("isSuccess", "");
                    System.out.println("--- (AD) key \"success\" does not exists(-1000). Original String: (" + toParseJson + ")");
                }
            } catch(ParseException pe) {
                // json 배열이 아니라서 변환 오류가 발생한 경우
                result.put("resultCode", "-1100");
                result.put("resultMsg", "서버 오류가 발생하였습니다.");
                result.put("errMsg", "JSON 배열이 아닙니다.");
                result.put("isSuccess", "");
                System.out.println("--- (AD) ParseException occured(-1100). Original String: (" + toParseJson + ")");
                pe.printStackTrace();
            }
        } catch(Throwable e) {
            // 기타 오류 발생
            result.put("resultCode", "-2000");
            result.put("resultMsg", "서버 오류가 발생하였습니다.");
            result.put("errMsg", "알 수 없는 오류가 발생하였습니다.");
            result.put("isSuccess", "");
            System.out.println("--- (AD) Exception occured(-2000). Original String: (" + toParseJson + ")");
            e.printStackTrace();
        }
        
        return result;
    }
}