package kr.yeongju.its.ad.common.util;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.UnsupportedEncodingException;
import java.net.URL;

import javax.net.ssl.HttpsURLConnection;
import javax.net.ssl.SSLContext;
import javax.net.ssl.TrustManager;
import java.security.KeyManagementException;
import java.security.NoSuchAlgorithmException;
import java.security.cert.X509Certificate;
import java.util.ArrayList;
import java.util.Base64;
import java.util.LinkedHashSet;
import java.util.List;

import javax.net.ssl.X509TrustManager;

import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.json.simple.parser.ParseException;
import org.springframework.context.ApplicationContext;
import egovframework.rte.fdl.property.EgovPropertyService;
import kr.yeongju.its.ad.common.config.ApplicationContextProvider;
import kr.yeongju.its.ad.common.dto.CommonMap;
import kr.yeongju.its.ad.core.service.CommonService; 

public class KakaoUtil {
    
    ApplicationContext context;
    EgovPropertyService propertyService;
    
    private boolean isTest = false;
    
    // 운영서버
    private final String BASE_URL_OP = "https://api.bizppurio.com";
    // 검수(개발)
    private final String BASE_URL_TEST = "https://dev-api.bizppurio.com";
    
    private String baseUrl = "";
    
    private String bizId = "";
    private String bizPw = "";
    private String profileKey = "";
    private String authToken = "";
    private String authType = "";
    
    // 최종적으로 보낼 JSON 메시지
    private String sendMsg = "";
    // 변수가 대체된 메시지 내용
    private String sendMsgContents = "";
    // SMS에 사용할 제목 (실패시 보내기 위함)
    private String sendTitle = "";
    // 수신자 이름
    private String recvName = "";
    // 수신 휴대폰 번호
    private String recvPhone = "";
    // 회신(발신) 번호
    private String sendPhone = "";
    // 메시지 코드
    private String msgCode = ""; // 현 TPL_CODE
    // 템플릿 코드
    private String templateCode = "";
    // replace 처리할 변수명과 값
    private List<CommonMap> replaceParamList = new ArrayList<CommonMap>();
    
    private String smsCode = "";

    /**
     * 초기화 진행 (운영 모드로 진행)
     */
    public KakaoUtil() {
        this(false);
    }
    
    /**
     * 초기화 진행 (운영/테스트 모드 선택)
     * @param isTestMode true=테스트모드(실제 전송은 안되고 결과는 정상으로 들어옴), false=운영모드
     */
    public KakaoUtil(boolean isTestMode) {
        
        this.context = ApplicationContextProvider.getApplicationContext();
        this.propertyService = this.context.getBean(EgovPropertyService.class);
        
        this.bizId = this.propertyService.getString("kakaoId");
        this.bizPw = this.propertyService.getString("kakaoPw");
        this.profileKey = this.propertyService.getString("profileKey");
        
        this.isTest = isTestMode;
        this.baseUrl = this.isTest ? BASE_URL_TEST : BASE_URL_OP;
        
        CommonMap authResult = new CommonMap();
        
        try {
            authResult = this.requestAuth();
        
            if(authResult != null) {
                System.out.println("---------- Authorization Result ----------");
                System.out.println("code :: " + authResult.getString("code"));
                System.out.println("desc :: " + authResult.getString("description"));
            } else {
                System.out.println("---------- Authorization Result ----------");
                System.out.println("Authorization request is failed!");
            }
        } catch(Exception e) {
            e.printStackTrace();
        }
    }
    
    /**
     * 전송할 JSON 배열 확인
     * @return
     */
    public String getSendMsg() {
        return this.sendMsg;
    }
    
    /**
     * 전송할 메시지(JSON 아님) 확인
     * @return
     */
    public String getSendMsgContents() {
        return this.sendMsgContents;
    }
    
    /**
     * 전송할 제목 확인
     * @return
     */
    public String getSendTitle() {
        return this.sendTitle;
    }
    
    /**
     * 수신자명 확인
     * @return
     */
    public String getRecvName() {
        return this.recvName;
    }
    
    /**
     * 수신번호 확인
     * @return
     */
    public String getRecvPhone() {
        return this.recvPhone;
    }
    
    /**
     * 회신번호 확인
     * @return
     */
    public String getSendPhone() {
        return this.sendPhone;
    }
    
    /**
     * 메시지 코드 확인(TPL_CODE)
     * @return
     */
    public String getMsgCode() {
        return this.msgCode;
    }
    
    /**
     * 알림톡 템플릿 코드 확인
     * @return
     */
    public String getTemplateCode() {
        return this.templateCode;
    }
    
    /**
     * Authorization Token 이 발급 되어 있는지 확인
     * @return 발급 여부 (true/false)
     */
    public boolean isAuthToken() {
        return (this.authToken.trim().length() > 0 ? true : false);
    }
    
    /**
     * API를 실제로 요청하는 메서드
     * @param requestUrl 요청할 URL
     * @param requestContents 요청 내용
     * @param checkAuth 인증 문자열 확인할지의 여부(false=미확인, true=확인)
     * @return
     */
    private String requestCommon(String requestUrl, String requestContents, boolean checkAuth) {
        if(checkAuth) {
            if("".equals(this.authToken)) {
                // 오류 처리
                System.out.println("KakaoUtil.requestCommon :: run requestAuth before request (No authorization token added).");
                return "";
            }
        }
        
        String input = null;
        StringBuffer result = new StringBuffer();
        URL url = null;
        OutputStream os = null;
        BufferedReader in = null;
        HttpsURLConnection connection = null;
        
        try {
            
            // 테스트 서버에 접속하는 경우, 인증서를 무시할 수 있도록 한다. 운영에 접속할 때는 필요 없음
            if(isTest) {
                /** SSL 인증서 무시 : 비즈뿌리오 API 운영을 접속하는 경우 해당 코드 필요 없음 **/
                TrustManager[] trustAllCerts = new TrustManager[] {new X509TrustManager() {
                   public X509Certificate[] getAcceptedIssuers() { return null; }
                   public void checkClientTrusted(X509Certificate[] chain, String authType) { }
                   public void checkServerTrusted(X509Certificate[] chain, String authType) { } } };
    
                SSLContext sc = SSLContext.getInstance("SSL");
                sc.init(null, trustAllCerts, new java.security.SecureRandom());
                HttpsURLConnection.setDefaultSSLSocketFactory(sc.getSocketFactory());
            }

            url = new URL(this.baseUrl + requestUrl);

            /** Connection 설정 **/
            connection = (HttpsURLConnection) url.openConnection();
            connection.setRequestMethod("POST");
            connection.addRequestProperty("Content-Type", "application/json;charset=utf-8");
            connection.addRequestProperty("Authorization", this.authType + " " + this.authToken);
            connection.setDoInput(true);
            connection.setDoOutput(true);
            connection.setUseCaches(false);
            connection.setConnectTimeout(15000);

            /** Request **/
            os = connection.getOutputStream();
            os.write(requestContents.getBytes());
            os.flush();
            
            /** Response **/
            in = new BufferedReader(new InputStreamReader(connection.getInputStream(), "UTF-8"));
            while ((input = in.readLine()) != null) {
                result.append(input);
            }

            connection.disconnect();
            String resStr = result.toString();
            System.out.println("KakaoUtil.requestCommon(private) :: Response String : " + resStr);
            return resStr;
        } catch (IOException e) {
            //e.printStackTrace();
            // 400 bad request
            // 오류 메시지를 json 형태로 돌려주는데 이걸 확인해서 파싱하여 리턴
            if(connection != null) {
                BufferedReader err = null;
                StringBuffer errRes = new StringBuffer();
                String tmp = "";
                try {
                    err = new BufferedReader(new InputStreamReader(connection.getErrorStream(), "UTF-8"));
                    while ((tmp = err.readLine()) != null) {
                        errRes.append(tmp);
                    }
                    System.out.println("KakaoUtil.requestCommon(private) :: error response string = [" + errRes.toString() + "]");
                    connection.disconnect();
                    return errRes.toString();
                } catch (UnsupportedEncodingException ex) {
                    System.out.println("KakaoUtil.requestCommon(private) :: Cannot recognize Encoding on processing error message :: " + ex.toString());
                    return "";
                } catch (IOException ex) {
                    System.out.println("KakaoUtil.requestCommon(private) :: IOException occured on processing error message :: " + ex.toString());
                    return "";
                } catch (Exception ex) {
                    System.out.println("KakaoUtil.requestCommon(private) :: Exception occured on processing error message :: " + ex.toString());
                    return "";
                }
            } else {
                // 원래 IOException
                System.out.println("KakaoUtil.requestCommon(private) :: Unknown IOException :: " + e.toString());
                return "";
            }
            
        } catch (KeyManagementException e) {
            System.out.println("KakaoUtil.requestCommon(private) :: KeyManagementException occured :: " + e.toString());
            return "";
        } catch (NoSuchAlgorithmException e) {
            System.out.println("KakaoUtil.requestCommon(private) :: NoSuchAlgorithmException occured :: " + e.toString());
            return "";
        } catch (Exception e) {
            System.out.println("KakaoUtil.requestCommon(private) :: Exception occured :: " + e.toString());
            return "";
        }
    }
    
    /**
     * API를 실제로 요청하는 메서드 (인증 문자열 여부 확인)
     * @param requestUrl 요청할 URL
     * @param requestContents 요청 내용
     * @return
     */
    private String requestCommon(String requestUrl, String requestContents) {
        return this.requestCommon(requestUrl, requestContents, true);
    }
    
    
    /**
     * 인증 코드 요청 (24시간동안 유효, 토큰이 받아지지 않았다면 다시 실행하여 받을 것. isAuthToken 메서드로 확인 가능)
     */
    public CommonMap requestAuth() {
        
        CommonMap resultMap = new CommonMap();
        
        String input = null;
        StringBuffer result = new StringBuffer();
        URL url = null;
        OutputStream os = null;
        BufferedReader in = null;
        HttpsURLConnection connection = null;
        
        try {
            
            // 테스트 서버에 접속하는 경우, 인증서를 무시할 수 있도록 한다. 운영에 접속할 때는 필요 없음
            if(isTest) {
                /** SSL 인증서 무시 : 비즈뿌리오 API 운영을 접속하는 경우 해당 코드 필요 없음 **/
                TrustManager[] trustAllCerts = new TrustManager[] {new X509TrustManager() {
                   public X509Certificate[] getAcceptedIssuers() { return null; }
                   public void checkClientTrusted(X509Certificate[] chain, String authType) { }
                   public void checkServerTrusted(X509Certificate[] chain, String authType) { } } };
    
                SSLContext sc = SSLContext.getInstance("SSL");
                sc.init(null, trustAllCerts, new java.security.SecureRandom());
                HttpsURLConnection.setDefaultSSLSocketFactory(sc.getSocketFactory());
            }

            url = new URL(this.baseUrl + "/v1/token");
            
            String authStr = new String(Base64.getEncoder().encode((this.bizId + ":" + this.bizPw).getBytes()));

            /** Connection 설정 **/
            connection = (HttpsURLConnection) url.openConnection();
            connection.setRequestMethod("POST");
            connection.addRequestProperty("Content-Type", "application/json;charset=utf-8");
            connection.addRequestProperty("Authorization", "Basic " + authStr);
            connection.setDoInput(true);
            connection.setDoOutput(true);
            connection.setUseCaches(false);
            connection.setConnectTimeout(15000);

            byte[] sendData = ("{ \"account\" : \"" + this.bizId + "\" }").getBytes();
            
            /** Request **/
            os = connection.getOutputStream();
            os.write(sendData); // 내용 없이 보내야 하므로 빈 byte 배열을 보낸다.
            os.flush();

            /** Response **/
            in = new BufferedReader(new InputStreamReader(connection.getInputStream(), "UTF-8"));
            while ((input = in.readLine()) != null) {
                result.append(input);
            }

            connection.disconnect();
            String resStr = result.toString();
            System.out.println("Response String : " + resStr);
            
            if("".equals(resStr)) {
                System.out.println("Response String is empty. No auth token is received.");
                
                resultMap.put("code", "9000");
                resultMap.put("description", "response is empty");
                
            } else {
                // JSON Object로 변경하여 값을 읽어온다.
                JSONParser parser = new JSONParser();
                JSONObject resObj = (JSONObject)parser.parse(resStr);
                
                if(resObj.containsKey("accesstoken")) {
                    this.authToken = (String) resObj.get("accesstoken");
                    this.authType = (String) resObj.get("type");
                    
                    System.out.println("Token : " + this.authToken);
                    System.out.println("Type : " + this.authType);
                    
                    resultMap.put("code", "1000");
                    resultMap.put("description", "received token successfully.");
                } else {
                    resultMap.put("code", (String) resObj.get("code"));
                    resultMap.put("description", (String) resObj.get("description"));
                }
            }
            
            return resultMap;
        } catch (IOException e) {
            //e.printStackTrace();
            // 400 bad request
            // 오류 메시지를 json 형태로 돌려주는데 이걸 확인해서 파싱하여 리턴
            if(connection != null) {
                BufferedReader err = null;
                StringBuffer errRes = new StringBuffer();
                String tmp = "";
                try {
                    if(connection.getErrorStream() != null) {
                        err = new BufferedReader(new InputStreamReader(connection.getErrorStream(), "UTF-8"));
                        while ((tmp = err.readLine()) != null) {
                            errRes.append(tmp);
                        }
                        System.out.println("KakaoUtil.requestAuth :: error response string = [" + errRes.toString() + "]");
                        connection.disconnect();
                        
                        JSONParser parser = new JSONParser();
                        JSONObject resObj = (JSONObject)parser.parse(errRes.toString());
                        
                        resultMap.put("code", String.valueOf((long)resObj.get("code")));
                        resultMap.put("description", (String)resObj.get("description"));
                        
                        return resultMap;
                    } else {
                        System.out.println("KakaoUtil.requestAuth :: There is no stream data in connection object.");
                    }
                } catch (UnsupportedEncodingException ex) {
                    System.out.println("KakaoUtil.requestAuth :: UnsupportedEncodingException occured on processing error message");
                    System.out.println(ex.toString());
                } catch (IOException ex) {
                    System.out.println("KakaoUtil.requestAuth :: IOException occured on processing error message");
                    System.out.println(ex.toString());
                } catch (Exception ex) {
                    System.out.println("KakaoUtil.requestAuth :: Exception occured on processing error message");
                    System.out.println(ex.toString());
                }
            } else {
                // 원래 IOException
                System.out.println("KakaoUtil.requestAuth :: Unknown error message or I/O error");
                System.out.println(e.toString());
            }
        } catch (NoSuchAlgorithmException e) {
            System.out.println("KakaoUtil.requestAuth :: Unknown algorithm");
            System.out.println(e.toString());
        } catch (Exception e) {
            System.out.println("KakaoUtil.requestAuth :: Exception occured");
            System.out.println(e.toString());
        }
        
        return null;
    }
    
    /**
     * 실제 보내는 요청을 하는 메서드
     * @param reqContents 요청하는 문자열
     * @return
     */
    private CommonMap requestSendMsg(String recvName, String msgCode) {
        
        CommonMap resultMap = new CommonMap();
        
        ApplicationContext context = ApplicationContextProvider.getApplicationContext();
        CommonService commonService = context.getBean(CommonService.class);
        
        try {
            
            String resStr = this.requestCommon("/v3/message", this.sendMsg);
            
            if(resStr == null) {
                System.out.println("KakaoUtil.requestSendMSg :: received unexpected error from server.");
                return null;
            }
            
            if("".equals(resStr)) {
                System.out.println("KakaoUtil.requestSendMSg :: no response from server.");
                return null;
            } else {
                // JSON Object로 변경하여 값을 읽어온다.
                JSONParser parser = new JSONParser();
                JSONObject resObj = (JSONObject)parser.parse(resStr);
                
                // 결과 중 refkey, messagekey를 변수에 넣는다.
                String refKey = (String)resObj.get("refkey");
                String cMsgId = (String)resObj.get("messagekey");
                
                resultMap.clear();
                resultMap.put("code", String.valueOf((long)resObj.get("code")));
                resultMap.put("description", (String)resObj.get("description"));
                resultMap.put("refkey", refKey);
                resultMap.put("messagekey", cMsgId);
                
                // 변수명과 처리할 내용을 문자열로 담는다.
                // 변수명^내용|변수명^내용|... 형태로 담는다.
                
                String varList = "";
                
                for(CommonMap item : this.replaceParamList) {
                    varList += item.getString("key") + "^" + item.getString("value") + "|";
                }
                
                // 마지막에 붙은 "|" 문자를 제거한다(문자열 길이가 0보다 크면..)
                varList = this.replaceParamList.size() > 0 ? varList.substring(0, varList.length() - 1) : varList;
                
                CommonMap dbParam = new CommonMap();
                refKey = this.smsCode;
                
                dbParam.put("cMsgId", cMsgId);
                dbParam.put("smsCode", refKey);
                dbParam.put("msgCode", msgCode);
                dbParam.put("toName", recvName);
                dbParam.put("reSms", "N");
                dbParam.put("varList", varList);
                dbParam.put("title", this.sendTitle);
                dbParam.put("sendPhone", this.sendPhone);
                dbParam.put("msgContents", this.sendMsgContents);
                
                dbParam.put("queryId", "at.receiveAlimTalkResult.insert_AlimTalkSendData");
                
                commonService.insert(dbParam);
                
                return resultMap;
            }
        } catch (ParseException ex) {
            System.out.println("KakaoUtil.requestSendMSg :: Cannot parse json array.");
            ex.printStackTrace();
        } catch (Exception e) {
            System.out.println("KakaoUtil.requestSendMSg :: Exception occured.");
            e.printStackTrace();
        }
        
        return null;
    }
    
    /**
     * 알림톡을 보내는 메서드
     * @return 결과(code=1000이 정상이며, API가 정상적으로 요청됨을 의미함(실제 발송 결과는 BIZ_AT_RESULT 테이블의 RESULT컬럼값 참조)
     */
    public CommonMap doSend() {
        
        CommonMap result = new CommonMap();

        try {
            result = this.requestSendMsg(this.recvName, this.msgCode);
            return result;
        } catch (Exception e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
            result.put("code", "-200");
            result.put("description", "KakaoUtil.doSend() :: exception occured.\nException Message :: " + e.getMessage());
        }
        
        return result;
    }

    /**
     * 필요한 내용을 받아 알림톡으로 전송할 메시지를 만드는 메서드
     * @param info 제목(msgTitle), 수신자명(recvName), 수신번호(recvPhone), 회신번호(sendPhone), 메시지코드(msgCode)를 갖는 CommonMap
     * @param paramList 변수 목록. 각각의 CommonMap에는 key, value라는 이름으로 변수명(key에)과 값(value에)을 넣는다.
     * @return 실제 전송하는 메시지
     */
    public String createSendMessage(CommonMap info, List<CommonMap> paramList) {
        
        CommonMap dbParam = new CommonMap();
        
        ApplicationContext context = ApplicationContextProvider.getApplicationContext();
        CommonService commonService = context.getBean(CommonService.class);
        
        String retMessage = "";
        
        if(!info.containsKey("msgTitle")) {
            System.out.println("KakaoUtil.createSendMessage :: CommonMap info does not have the key - msgTitle.");
            return null;
        }
        
        if(!info.containsKey("recvName")) {
            System.out.println("KakaoUtil.createSendMessage :: CommonMap info does not have the key - recvName.");
            return null;
        }
        
        if(!info.containsKey("recvPhone")) {
            System.out.println("KakaoUtil.createSendMessage :: CommonMap info does not have the key - recvPhone.");
            return null;
        }
        
        if(!info.containsKey("sendPhone")) {
            System.out.println("KakaoUtil.createSendMessage :: CommonMap info does not have the key - sendPhone.");
            return null;
        }
        
        if(!info.containsKey("msgCode")) {
            System.out.println("KakaoUtil.createSendMessage :: CommonMap info does not have the key - msgCode.");
            return null;
        }
        
        // 필요한 값 세팅
        String msgTitle = info.getString("msgTitle");
        String recvName = info.getString("recvName");
        String recvPhone = info.getString("recvPhone");
        String sendPhone = info.getString("sendPhone");
        String msgCode = info.getString("msgCode");
        String smsCode = info.getString("smsCode");
        
        // 템플릿 코드
        String templateCode = "";
        // 변수가 포함되어 있는 메시지(아직 replace 처리하지 않음)
        String originalMessage = "";
        
        try {
            
            // DB에서 MSG_CODE에 해당하는 템플릿 코드와 변수가 포함된 알림톡 메시지를 불러온다.
            // T_SYS_COMCODE.CODE_NAME3(템플릿 코드), CODE_NAME5(템플릿 코드)
            
            dbParam.put("queryId", "at.receiveAlimTalkResult.select_MessageInfo");
            dbParam.put("msgCode", msgCode);
            CommonMap dbResult = commonService.selectOne(dbParam);
            
            templateCode = dbResult.getString("templateCode");
            originalMessage = dbResult.getString("kakaoMsg");
            
            retMessage = originalMessage;
            
            // paramList에 들어있는 key를 value로 replace 처리할 것
            
            for(CommonMap val : paramList) {
                retMessage = retMessage.replace("#{" + val.getString("key") + "}", val.getString("value"));
            }
            
            retMessage = retMessage.replace("\r", "");
            retMessage = retMessage.replace("\n", "\\n");
            
            // 내부 변수들을 이에 맞게 변경할 것   
            
            // 변수가 대체(replace)된 전송할 메시지
            this.sendMsgContents = retMessage;
            // SMS에 사용할 제목 (실패시 보내기 위함)
            this.sendTitle = msgTitle;
            // 수신자 이름
            this.recvName = recvName;
            // 수신 휴대폰 번호
            this.recvPhone = recvPhone;
            // 회신(발신) 번호
            this.sendPhone = sendPhone;
            // 메시지 코드
            this.msgCode = msgCode;
            // 템플릿 코드
            this.templateCode = templateCode;
            // SMS Code(ref_key 에 사용할 예정)
            this.smsCode = smsCode;
            // 전송할 JSON 문자열
            this.sendMsg = this.makeKakaoMsgSimple(); // 전역변수 세팅
            // 변수명과 내용
            this.replaceParamList = paramList;
            
        } catch(Exception e) {
            System.out.println("KakaoUtil.createSendMessage :: Exception occured.");
            e.printStackTrace();
            retMessage = null;
        }
        
        return retMessage;
    }
    
    /**
     * 알림톡 메시지에 변수가 어떤게 있는지를 찾아서 중복제거하고 변수가 등장하는 순서대로 콤마(,)로 구분하여 String으로 반환
     * @param chkStr
     * @return
     */
    public String extractVariableList(String chkStr) {
        String result = "";
        
        List<String> resObj = new ArrayList<String>();
        LinkedHashSet<String> tempObj = new LinkedHashSet<String>();
        
        if(chkStr == null) {
            System.out.println("KakaoUtil.extractVariableList :: Input string is null.");
            return null;
        }
        
        if("".equals(chkStr.trim())) {
            System.out.println("KakaoUtil.extractVariableList :: Input string is empty.");
            return null;
        }
        
        if(chkStr.indexOf("#{") < 0) {
            System.out.println("KakaoUtil.extractVariableList :: Input string has no variables start with \"#{\".");
            return null;
        }
        
        String[] splitString = chkStr.split("\\#\\{"); // 특수문자를 넣기 위해 "\\" 를 추가
        
        for(int i = 1; i < splitString.length; i++) {
            if(splitString[i].indexOf("}") > -1) {
                resObj.add(splitString[i].substring(0, splitString[i].indexOf("}")));
            }
        }
        
        tempObj = new LinkedHashSet<String>(resObj);
        
        resObj.clear();
        resObj.addAll(tempObj);
        
        result = String.join(",", resObj);
        
        return result;
    }
    
    /**
     * 알림톡 메시지를 보내기 위한 JSON 문자열 생성
     */
    private String makeKakaoMsg() {
        
        try {
            
            String templateCode = "", refKey = "", fromNo = "", toNo = "", msgStr = "";
            
            templateCode = this.templateCode;
            fromNo = this.sendPhone;
            toNo = this.recvPhone;
            msgStr = this.sendMsgContents;
            
            if("".equals(templateCode)) { System.out.println("KakaoUtil.makeKakaoMsg :: templateCode is empty. "); return null; }
            if("".equals(fromNo)) { System.out.println("KakaoUtil.makeKakaoMsg :: fromNo is empty. "); return null; }
            if("".equals(toNo)) { System.out.println("KakaoUtil.makeKakaoMsg :: toNo is empty. "); return null; }
            if("".equals(msgStr)) { System.out.println("KakaoUtil.makeKakaoMsg :: msgStr is empty. "); return null; }
            
            // enable DB connection
            ApplicationContext context = ApplicationContextProvider.getApplicationContext();
            CommonService commonService = context.getBean(CommonService.class);
            
            CommonMap dbParam = new CommonMap();
            
            // REF_KEY 생성           
            dbParam.put("queryId", "at.receiveAlimTalkResult.select_GetRefKey");
            CommonMap refKeyResult = commonService.selectOne(dbParam);
            refKey = refKeyResult.getString("refkey");
            
            StringBuilder sendMsg = new StringBuilder();
            
            sendMsg.append("{\n");
            sendMsg.append("    \"account\" : \"" + this.bizId + "\",\n"); // 비즈뿌리오 계정
            sendMsg.append("    \"type\" : \"at\",\n");   // at 고정 (알림톡을 의미)
            sendMsg.append("    \"from\" : \"" + fromNo + "\",\n");     // 발신 전화번호
            sendMsg.append("    \"to\" : \"" + toNo + "\",\n");       // 수신 전화번호
            sendMsg.append("    \"refkey\" : \"" + refKey + "\",\n"); // 스마트 주차 시스템 자체 키
            sendMsg.append("    \"content\" : {\n");
            sendMsg.append("        \"at\" : {\n");
            sendMsg.append("            \"senderkey\" : \"" + this.profileKey + "\",\n"); // 발신 프로필 키
            sendMsg.append("            \"templatecode\" : \"" + templateCode + "\",\n"); // 템플릿 코드
            //sendMsg.append("            \"title\" : \"" + titleStr + "\",\n"); // 강조할 메시지
            sendMsg.append("            \"message\" : \"" + msgStr + "\",\n");  // 나머지 메시지
            // 이 버튼 부분은 템플릿에 따라 삭제될 수 있음. 아래의 버튼 설정은 템플릿에 있기 때문에 어쩔 수 없이 넣음.
            sendMsg.append("            \"button\" : [\n"); // 버튼 설정 (버튼은 배열로..)
            sendMsg.append("                {\n");
            sendMsg.append("                    \"name\" : \"서비스 4시간 중지\",\n"); // 버튼명 (표시 이름)
            sendMsg.append("                    \"type\": \"WL\",\n"); // 종류 WL=웹링크
            sendMsg.append("                    \"url_pc\": \"https://its.yeongju.kr/pis/stop.do\",\n"); // PC용 링크
            sendMsg.append("                    \"url_mobile\": \"https://its.yeongju.kr/pis/stop.do\"\n"); // 모바일용 링크
            sendMsg.append("                },\n");
            sendMsg.append("                {\n");
            sendMsg.append("                    \"name\" : \"서비스 재설정\",\n");
            sendMsg.append("                    \"type\": \"WL\",\n");
            sendMsg.append("                    \"url_pc\": \"http://its.yeongju.kr/pis/stop.do\",\n");
            sendMsg.append("                    \"url_mobile\": \"http://its.yeongju.kr/pis/stop.do\"\n");
            sendMsg.append("                }\n");
            sendMsg.append("            ]\n");
            // 이 버튼 부분은 템플릿에 따라 삭제될 수 있음 end //
            sendMsg.append("        }\n");
            sendMsg.append("    }\n");
            sendMsg.append("}\n");
            
            System.out.println("KakaoUtil.makeKakaoMsg :: ***** JSON Message to send *****");
            System.out.println(sendMsg.toString());
            
            return sendMsg.toString();
        } catch(Exception e) {
            System.out.println("KakaoUtil.makeKakaoMsg :: " + e.getMessage());
            return "";
        }
    }
    
    private String makeKakaoMsgSimple() {
        
        try {
            
            String templateCode = "", refKey = "", fromNo = "", toNo = "", msgStr = "";
            
            templateCode = this.templateCode;
            fromNo = this.sendPhone;
            toNo = this.recvPhone;
            msgStr = this.sendMsgContents;
            
            if("".equals(templateCode)) { System.out.println("KakaoUtil.makeKakaoMsg :: templateCode is empty. "); return null; }
            if("".equals(fromNo)) { System.out.println("KakaoUtil.makeKakaoMsg :: fromNo is empty. "); return null; }
            if("".equals(toNo)) { System.out.println("KakaoUtil.makeKakaoMsg :: toNo is empty. "); return null; }
            if("".equals(msgStr)) { System.out.println("KakaoUtil.makeKakaoMsg :: msgStr is empty. "); return null; }
            
            // enable DB connection
            ApplicationContext context = ApplicationContextProvider.getApplicationContext();
            CommonService commonService = context.getBean(CommonService.class);
            
            CommonMap dbParam = new CommonMap();
            
            // REF_KEY 생성           
//            dbParam.put("queryId", "at.receiveAlimTalkResult.select_GetRefKey");
//            CommonMap refKeyResult = commonService.selectOne(dbParam);
            refKey = this.smsCode;
            
            StringBuilder sendMsg = new StringBuilder();
            
            sendMsg.append("{\n");
            sendMsg.append("    \"account\" : \"" + this.bizId + "\",\n"); // 비즈뿌리오 계정
            sendMsg.append("    \"type\" : \"at\",\n");   // at 고정 (알림톡을 의미)
            sendMsg.append("    \"from\" : \"" + fromNo + "\",\n");     // 발신 전화번호
            sendMsg.append("    \"to\" : \"" + toNo + "\",\n");       // 수신 전화번호
            sendMsg.append("    \"refkey\" : \"" + refKey + "\",\n"); // 영주시 스마트 주차 시스템 자체 키
            sendMsg.append("    \"content\" : {\n");
            sendMsg.append("        \"at\" : {\n");
            sendMsg.append("            \"senderkey\" : \"" + this.profileKey + "\",\n"); // 발신 프로필 키
            sendMsg.append("            \"templatecode\" : \"" + templateCode + "\",\n"); // 템플릿 코드
            sendMsg.append("            \"message\" : \"" + msgStr + "\"\n");  // 나머지 메시지
            sendMsg.append("        }\n");
            sendMsg.append("    }\n");
            sendMsg.append("}\n");
            
            System.out.println("KakaoUtil.makeKakaoMsgSimple :: ***** JSON Message to send *****");
            System.out.println(sendMsg.toString());
            
            return sendMsg.toString();
        } catch(Exception e) {
            System.out.println("KakaoUtil.makeKakaoMsgSimple :: " + e.getMessage());
            return "";
        }
    }
}
