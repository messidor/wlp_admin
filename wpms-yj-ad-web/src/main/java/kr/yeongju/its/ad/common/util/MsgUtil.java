package kr.yeongju.its.ad.common.util;

import java.util.ArrayList;
import java.util.List;
import org.springframework.context.ApplicationContext;

import kr.yeongju.its.ad.common.config.ApplicationContextProvider;
import kr.yeongju.its.ad.common.dto.CommonMap;
import kr.yeongju.its.ad.core.service.CommonService; 

public class MsgUtil {
    
    private String replaceMessage = "";

    public MsgUtil() {}
    
    public String getMessage() {
        return this.replaceMessage;
    }
    
    public void setMessage(String msg) {
        this.replaceMessage = msg;
    }
    
    /**
     * 템플릿을 사용하지 않는 일반 메시지를 SMS(MMS)로 전송하는 메서드 (카카오는 제외)
     * @param param 수신자명(recvName), 수신번호(recvPhone), 회신번호(sendPhone), 사용자(recvId), 내용(sendMessage), 제목(msgTitle)
     * @return SMS(MMS)전송 결과
     */
    public CommonMap doSendMsg(CommonMap param) {
        
        CommonMap result = new CommonMap();
        CommonMap dbParam = new CommonMap();
        CommonMap info = new CommonMap();
        
        EncUtil enc = new EncUtil();
        
        String recvName = "";
        String recvPhone = "";
        String sendPhone = "";
        String msgTitle = "";
        String sendMessage = "";
        String recvId = "";
        String smsCode = "";
        int byteLength = 0;
        String msgType = "";
        
     // 파라미터 체크
        if(param == null) {
            // NULL 체크
            System.out.println("MsgUtil.doSendMsg :: Parameter is null.");
            result.put("code", "-1000");
            result.put("description", "First parameter is null.");
            return result; 
        } else if(param.size() < 1) {
            // 아무 내용도 없는 파라미터인 경우
            System.out.println("MsgUtil.doSendMsg :: Parameter is empty. There is no key/value pair in the first parameter.");
            result.put("code", "-1001");
            result.put("description", "Parameter is empty. There is no key/value pair in the first parameter.");
            return result;
        } else {
            // 파라미터가 있는 경우 필수 파라미터 체크
            // 수신자명 (recvName)
            // 수신자 전화번호 (recvPhone)
            // 발신번호 - (sendPhone)
            // 템플릿 코드 (tplCode)
            if(!param.containsKey("recvName")) {
                System.out.println("MsgUtil.doSendMsg :: Cannot get recvName. recvName is required.");
                result.put("code", "-1002");
                result.put("description", "Cannot get recvName. recvName is required.");
                return result;
            }
            
            if(!param.containsKey("recvPhone")) {
                System.out.println("MsgUtil.doSendMsg :: Cannot get recvPhone. recvPhone is required.");
                result.put("code", "-1002");
                result.put("description", "Cannot get recvPhone. recvPhone is required.");
                return result;
            }
            
            if(!param.containsKey("sendPhone")) {
                System.out.println("MsgUtil.doSendMsg :: Cannot get sendPhone. sendPhone is required.");
                result.put("code", "-1002");
                result.put("description", "Cannot get sendPhone. sendPhone is required.");
                return result;
            }
            
            if(!param.containsKey("sendMessage")) {
                System.out.println("MsgUtil.doSendMsg :: Cannot get sendMessage. sendMessage is required.");
                result.put("code", "-1002");
                result.put("description", "Cannot get sendMessage. sendMessage is required.");
                return result;
            }
        }
        
        recvName = param.getString("recvName");
        recvPhone = param.getString("recvPhone");
        sendPhone = param.getString("sendPhone");
        recvId = param.getString("recvId");
        msgTitle = param.getString("msgTitle");
        sendMessage = param.getString("sendMessage");
        
        try {
            
            ApplicationContext context = ApplicationContextProvider.getApplicationContext();
            CommonService commonService = context.getBean(CommonService.class);
            
            // SMS 전송
            SmsUtil sms = new SmsUtil(sendPhone);
            // SMS Log 키 생성
            smsCode = CommonUtil.fnMakeKey("SM") + CommonUtil.fnMakeRandomNumOnly(3);
            
            info.put("msgTitle", msgTitle);
            info.put("smsCode", smsCode);
            info.put("sendMessage", sendMessage);
            
            // 수신자 목록(SMS용)
            List<CommonMap> recvList = new ArrayList<CommonMap>();
            CommonMap recvParam = new CommonMap();
            
            recvParam = new CommonMap();
            recvParam.put("cp", recvPhone);
            recvParam.put("name", recvName);
            recvList.add(recvParam);
            
            // SMS(MMS) 전송
            result = sms.doSendSms(info, recvList);
            
            try {
                byteLength = sendMessage.getBytes("UTF-8").length;
            } catch(Exception e) {
                byteLength = -1;
            }
            
            if(byteLength > 90) {
                msgType = "MMS";
            } else if(byteLength > 0) {
                msgType = "SMS";
            } else {
                msgType = "SMS";
            }
            
            // SMS 로그 추가
            // recvName = param.getString("recvName"); // 수신자명 (암호화되어 있음)
            // recvPhone = param.getString("recvPhone"); // 수신자 번호 (암호화되어 있음)
            // sendPhone = param.getString("sendPhone"); // 발신자 번호
            // tplCode = param.getString("tplCode"); // 템플릿 코드
            // recvId // 수신자명/수신자 번호에 해당하는 사용자 ID
            param.put("queryId", "sms.smsUtil.insert_MessageLog");
            param.put("subject", msgTitle);
            param.put("recvName", enc.encrypt(recvName), false);
            param.put("recvPhone", enc.encrypt(recvPhone), false);
            param.put("sendPhone", enc.encrypt(sendPhone), false);
            if(!param.containsKey("recvId")) {
                param.put("recvId", enc.encrypt("unknown"), false);
            } else {
                param.put("recvId", enc.encrypt(recvId), false);
            }
            param.put("smsCode", smsCode); // SMS Code
            param.put("msgContents", sendMessage, false); // 내용이 치환(replace)된 메시지
            param.put("byteLength", byteLength); // byte 길이
            param.put("msgType", msgType); // 메시지 타입 (카카오/SMS/MMS)
            param.put("tplCode", ""); // 템플릿 코드는 없기 때문에 빈 값으로 넣음
            commonService.insert(param);
            
            return result;
        } catch(Throwable e) {
            System.out.println("MsgUtil.doSendMsg :: Exception occured(" + msgType + ").");
            result.put("code", "-2000");
            result.put("description", "Exception occured(" + msgType + ").");
            e.printStackTrace();
            return result;
        }
    }
    
    /**
     * 파라미터에 따라 알림톡 혹은 SMS를 전송
     * @param param 수신자명(recvName), 수신번호(recvPhone), 회신번호(sendPhone), 템플릿코드(tplCode), 사용자ID(recvId), 차량번호(carNo), 카드사(creditAlias), 카드번호(creditNo), 오류내용(errorDesc), 주차장명(parkingName), 감면내용(reductionName)
     * @param sendTool K=알림톡, S=SMS전송
     * @return 알림톡 혹은 SMS전송 결과
     */
    public CommonMap doSend(CommonMap param, String sendTool) {
        
        CommonMap result = new CommonMap();
        CommonMap dbParam = new CommonMap();
        
        String recvName = "";
        String recvPhone = "";
        String sendPhone = "";
        String tplCode = "";
        String msgTitle = "";
        String sendMessage = "";
        String recvId = "";
        String smsCode = "";
        
        EncUtil enc = new EncUtil();
        
        try {
            
            ApplicationContext context = ApplicationContextProvider.getApplicationContext();
            CommonService commonService = context.getBean(CommonService.class);
        
            // 파라미터 체크
            if(param == null) {
                // NULL 체크
                System.out.println("MsgUtil.doSend :: Parameter is null.");
                result.put("code", "-1000");
                result.put("description", "First parameter is null.");
                return result; 
            } else if(param.size() < 1) {
                // 아무 내용도 없는 파라미터인 경우
                System.out.println("MsgUtil.doSend :: Parameter is empty. There is no key/value pair in the first parameter.");
                result.put("code", "-1001");
                result.put("description", "Parameter is empty. There is no key/value pair in the first parameter.");
                return result;
            } else {
                // 파라미터가 있는 경우 필수 파라미터 체크
                // 수신자명 (recvName)
                // 수신자 전화번호 (recvPhone)
                // 발신번호 - (sendPhone)
                // 템플릿 코드 (tplCode)
                if(!param.containsKey("recvName")) {
                    System.out.println("MsgUtil.doSend :: Cannot get recvName. recvName is required.");
                    result.put("code", "-1002");
                    result.put("description", "Cannot get recvName. recvName is required.");
                    return result;
                }
                
                if(!param.containsKey("recvPhone")) {
                    System.out.println("MsgUtil.doSend :: Cannot get recvPhone. recvName is required.");
                    result.put("code", "-1002");
                    result.put("description", "Cannot get recvPhone. recvPhone is required.");
                    return result;
                }
                
                if(!param.containsKey("sendPhone")) {
                    System.out.println("MsgUtil.doSend :: Cannot get sendPhone. recvName is required.");
                    result.put("code", "-1001");
                    result.put("description", "Cannot get sendPhone. sendPhone is required.");
                    return result;
                }
                
                if(!param.containsKey("tplCode")) {
                    System.out.println("MsgUtil.doSend :: Cannot get tplCode. recvName is required.");
                    result.put("code", "-1002");
                    result.put("description", "Cannot get tplCode. tplCode is required.");
                    return result;
                }
            }
            
            if(!"K".equals(sendTool.toUpperCase()) && !"S".equals(sendTool.toUpperCase())) {
                System.out.println("MsgUtil.doSend :: Second parameter must be \"K\" or \"S\" (Case insensitive). ");
                result.put("code", "-1003");
                result.put("description", "Second parameter must be \"K\" or \"S\" (Case insensitive).");
                return result;
            }
            
            recvName = param.getString("recvName");
            recvPhone = param.getString("recvPhone");
            sendPhone = param.getString("sendPhone");
            tplCode = param.getString("tplCode");
            recvId = param.getString("recvId");
            
            // 기본정보
            CommonMap info = new CommonMap();
            // 템플릿 변수/값 리스트
            List<CommonMap> paramList = new ArrayList<CommonMap>();
            CommonMap singleParam = new CommonMap();
            // 수신자 목록(SMS용)
            List<CommonMap> recvList = new ArrayList<CommonMap>();
            CommonMap recvParam = new CommonMap();
            
            // true 면 알림톡, false 면 SMS
            boolean isKakao = "K".equals(sendTool.toUpperCase());
            
            // 템플릿 코드로 제목을 DB에서 받아오도록 함
            // at.receiveAlimTalkResult.select_MessageTitle
            dbParam.put("queryId", "at.receiveAlimTalkResult.select_MessageTitle");
            dbParam.put("tplCode", tplCode);
            CommonMap titleResult = commonService.selectOne(dbParam);
            msgTitle = titleResult.getString("tplName");
            
            // 변수목록 받아오기
            dbParam.put("queryId", "sms.smsUtil.select_MessageParameters");
            List<CommonMap> varResult = commonService.select(dbParam);
            
            // 변수와 파라미터 추가 (한글명-영문명 매칭 테이블 - T_MSG_VAR)
            if(varResult.size() > 0) {
                for(int i = 0; i < varResult.size(); i++) {
                    CommonMap singleRow = varResult.get(i);
                    if(param.containsKey(singleRow.getString("varEn"))) {
                        singleParam = new CommonMap();
                        singleParam.put("key", singleRow.getString("varKo"));
                        singleParam.put("value", param.getString(singleRow.getString("varEn")));
                        paramList.add(singleParam);
                    }
                }
            }
            
            // 변수목록 넣은게 없으면.. 경고 정도만 우선 넣음. 템플릿에 변수가 없을 것을 대비하여...
            if(paramList.size() < 1) {
                System.out.println("MsgUtil.doSend :: No variable name and value pairs... Is it correct?????");
            }
            
            String msgType = "";
            int byteLength = 0;
            
            // 여기에 로그 넣도록 할 것
            // 공통 필수
            // recvName = param.getString("recvName"); // 수신자명 (암호화되어 있음)
            // recvPhone = param.getString("recvPhone"); // 수신자 번호 (암호화되어 있음)
            // sendPhone = param.getString("sendPhone"); // 발신자 번호
            // tplCode = param.getString("tplCode"); // 템플릿 코드
            // recvId // 수신자명/수신자 번호에 해당하는 사용자 ID
            param.put("queryId", "sms.smsUtil.insert_MessageLog");
            param.put("subject", msgTitle);
            param.put("recvName", enc.encrypt(recvName), false);
            param.put("recvPhone", enc.encrypt(recvPhone), false);
            param.put("sendPhone", enc.encrypt(sendPhone), false);
            
            if(!param.containsKey("recvId")) {
                param.put("recvId", enc.encrypt("unknown"), false);
            } else {
                param.put("recvId", enc.encrypt(recvId), false);
            }
            
            if(isKakao) {
                // 카카오 알림톡 전송
                KakaoUtil kakao = new KakaoUtil(false);
                
                smsCode = CommonUtil.fnMakeKey("SM") + CommonUtil.fnMakeRandomNumOnly(3);
                
                info.put("recvName", recvName);
                info.put("recvPhone", recvPhone);
                info.put("sendPhone", sendPhone);
                info.put("msgTitle", msgTitle);
                info.put("msgCode", tplCode);
                info.put("smsCode", smsCode);
                
                sendMessage = kakao.createSendMessage(info, paramList);
                sendMessage = sendMessage.replace("\\n", "\n");
                
                this.replaceMessage = sendMessage;
                
                try {
                    byteLength = sendMessage.getBytes("UTF-8").length;
                } catch(Exception e) {
                    byteLength = -1;
                }
                
                msgType = "KAKAO";
                
                param.put("smsCode", smsCode); // SMS Code
                param.put("msgContents", sendMessage, false); // 내용이 치환(replace)된 메시지
                param.put("byteLength", byteLength); // byte 길이
                param.put("msgType", msgType); // 메시지 타입 (카카오/SMS/MMS)
                commonService.insert(param);
                
                result = kakao.doSend();
            } else {
                // SMS 전송
                SmsUtil sms = new SmsUtil(sendPhone);
                
                smsCode = CommonUtil.fnMakeKey("SM") + CommonUtil.fnMakeRandomNumOnly(3);
                
                info.put("msgTitle", msgTitle);
                info.put("tplCode", tplCode);
                info.put("smsCode", smsCode);
                
                recvParam = new CommonMap();
                recvParam.put("cp", recvPhone);
                recvParam.put("name", recvName);
                recvList.add(recvParam);
                
                result = sms.doSendTplSms(info, recvList, paramList);
                sendMessage = sms.getSendMessage();
                
                this.replaceMessage = sendMessage;
                
                try {
                    byteLength = sendMessage.getBytes("UTF-8").length;
                } catch(Exception e) {
                    byteLength = -1;
                }
                
                if(byteLength > 90) {
                    msgType = "MMS";
                } else if(byteLength > 0) {
                    msgType = "SMS";
                } else {
                    msgType = "SMS";
                }
                
                param.put("smsCode", smsCode); // SMS Code
                param.put("msgContents", sendMessage, false); // 내용이 치환(replace)된 메시지
                param.put("byteLength", byteLength); // byte 길이
                param.put("msgType", msgType); // 메시지 타입 (카카오/SMS/MMS)
                commonService.insert(param);
            }
            
            return result;
        } catch(Exception e) {
            System.out.println("MsgUtil.doSend :: Exception occured when calling (" + sendTool + ").");
            result.put("code", "-2000");
            result.put("description", "Exception occured when calling (" + sendTool + ").");
            e.printStackTrace();
            return result;
        }
    }
}
