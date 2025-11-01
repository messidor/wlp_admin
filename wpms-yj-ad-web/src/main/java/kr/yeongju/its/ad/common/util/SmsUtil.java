package kr.yeongju.its.ad.common.util;

import java.io.UnsupportedEncodingException;
import java.util.List;
import javax.annotation.Resource;

import org.springframework.context.ApplicationContext;

import egovframework.rte.fdl.property.EgovPropertyService;
import kr.yeongju.its.ad.common.config.ApplicationContextProvider;
import kr.yeongju.its.ad.common.dto.CommonMap;
import kr.yeongju.its.ad.core.service.CommonService; 

public class SmsUtil {
    //private CommonService commonService;
    //ApplicationContext context;
    
    ApplicationContext context;
    EgovPropertyService propertyService;
    
    private String smsUserId;
    
    private String callBackNumber = "";
    
    private String sendMessage = "";
    
    /**
     * SMS 전송을 위한 초기화 진행
     * @param callBackNumber 회신번호 설정
     */
    public SmsUtil(String callBackNumber) {
        this.context = ApplicationContextProvider.getApplicationContext();
        this.propertyService = this.context.getBean(EgovPropertyService.class);
        this.smsUserId = propertyService.getString("smsId");
        this.callBackNumber = callBackNumber;
    }
    
    /**
     * 회신번호 설정하기
     * @param callBackNumber 설정할 회신번호
     */
    public void setCallBackNumber(String callBackNumber) {
        this.callBackNumber = callBackNumber;
    }
    
    /**
     * 회신번호 가져오기
     * @return 저장되어 있는 회신번호
     */
    public String getCallBackNumber() {
        return this.callBackNumber;
    }
    
    public String getSendMessage() {
        return this.sendMessage;
    }
    
    /**
     * Character Set 을 UTF-8로 지정하여 byte를 구함
     * @param str byte를 구할 문자열
     * @return byte 수 (UnsupportedEncodingException 발생시 -10, 기타 Exception 발생시 -1)
     */
    private int getByteLength(String str) {
        return this.getByteLength(str, "UTF-8");
    }
    
    /**
     * Character Set 을 지정하여 byte를 구함
     * @param str byte를 구할 문자열
     * @param charset Character Set 이름 (ex: UTF-8, EUC-KR 등)
     * @return byte 수 (UnsupportedEncodingException 발생시 -10, 기타 Exception 발생시 -1)
     */
    private int getByteLength(String str, String charset) {
        
        // 빈 문자열이면 0을 리턴
        if(str.trim().equals("")) {
            return 0;
        }
        
        try {
            return str.getBytes(charset).length;
        } catch(UnsupportedEncodingException uee) {
            uee.printStackTrace();
            return -10;
        } catch(Exception e) {
            e.printStackTrace();
            return -1;
        }
    }
    
    // 템플릿 코드와 변수명/변수값을 받아 메시지를 완성하는 함수
    private String createMessage(String tplCode, List<CommonMap> msgParam, boolean doSms) {
        String result = "";
        
        CommonMap dbParam = new CommonMap();
        //select_MessageInfo
        ApplicationContext context = ApplicationContextProvider.getApplicationContext();
        CommonService commonService = context.getBean(CommonService.class);
        
        try {
            dbParam.put("queryId", "sms.smsUtil.select_Template");
            dbParam.put("tplCode", tplCode);
            
            // 템플릿 코드에 해당하는 템플릿을 가져온다.
            CommonMap singleRow = commonService.selectOne(dbParam);
            
            String smsTpl = singleRow.getString("smsTpl");
            String mmsTpl = singleRow.getString("mmsTpl");
            
            boolean isOver90Byte = false;
            
            if(doSms) {
                // SMS replace 처리해 본다. 90byte가 넘으면 MMS 템플릿을 사용하여 처리한다.
                result = smsTpl;
                
                for(CommonMap val : msgParam) {
                    result = result.replace("#{" + val.getString("key") + "}", val.getString("value"));
                }
                
                // 만약 SMS로 처리했는데 90바이트가 넘으면 MMS 처리할 수 있도록 함
                if(this.getByteLength(result) > 90) {
                    isOver90Byte = true;
                }
            }
            
            if(isOver90Byte || !doSms) {
                // MMS 처리
                // replace 처리한 SMS가 90바이트가 넘으면 MMS로 메시지를 구성한다.
                result = mmsTpl;
                
                for(CommonMap val : msgParam) {
                    result = result.replace("#{" + val.getString("key") + "}", val.getString("value"));
                }
                
                System.out.println("SmsUtil.createMessage :: Created Multimedia Message(MMS).");
                System.out.println(result);
            } else {
                // MMS 처리하지 않은 경우
                System.out.println("SmsUtil.createMessage :: Created Short Message(SMS).");
                System.out.println(result);
            }
            
            return result;
        } catch(Exception e) {
            System.out.println("SmsUtil.createMessage :: Exception occured.");
            System.out.println(e.toString());
            return ""; // 오류시 빈 문자열로. sendMsg 함수에서 오류 처리함
        }
    }
    
    /**
     * SMS(MMS)를 전송한다. 90바이트가 넘으면 자동으로 MMS로 바꿔서 전송한다.
     * @param singleParam 보낼 메시지의 제목("msgTitle"), 템플릿 코드("tplCode")
     * @param destList "cp"(휴대폰번호, 숫자만), "name"(이름) 으로 이루어진 CommonMap의 리스트 (메시지 수신할 사람 목록, 최대 100명)
     * @param msgParam 템플릿에 사용할 변수와 그 값("key"(변수명), "value"(변수값) 로 이루어진 CommonMap의 리스트)
     * @param doSms true=SMS, false=MMS. SMS의 경우 길이를 초과하면 자동으로 MMS로 전환됨
     * @return code(결과코드, 1이면 정상), description(결과에 대한 설명), msgId(전송요청 성공시 생성된 메시지 ID), msgType(전송한 메시지 타입(SMS, MMS)) 으로 이루어진 CommonMap
     */
    private CommonMap doSendTpl(CommonMap singleParam, List<CommonMap> destList, List<CommonMap> msgParam, boolean doSms) {
        CommonMap result = new CommonMap();
        
        String tplCode = singleParam.getString("tplCode");
        
        // 메시지 구성
        String sendMessage = this.createMessage(tplCode, msgParam, doSms);
        this.sendMessage = sendMessage;
        singleParam.put("sendMessage", sendMessage);
        
        // true 이면 SMS, false 이면 MMS
        // 메시지가 90바이트가 넘으면 무조건 MMS(false)
        // 그렇지 않으면 파라미터로 받은 대로 처리(강제로 MMS를 보내는 경우도 있을 수 있으니 파라미터 받은대로 처리)
        boolean isSms = this.getByteLength(sendMessage) > 90 ? false : doSms;
        
        // 실제 전송
        result = this.doSend(singleParam, destList, isSms);
        
        return result;
    }
    
    /**
     * SMS를 전송한다. 90바이트가 넘으면 자동으로 MMS로 바꿔서 전송한다.
     * @param singleParam 보낼 메시지의 제목("msgTitle"), 템플릿 코드("tplCode")
     * @param destList "cp"(휴대폰번호, 숫자만), "name"(이름) 으로 이루어진 CommonMap의 리스트 (메시지 수신할 사람 목록, 최대 100명)
     * @param msgParam 템플릿에 사용할 변수와 그 값("key"(변수명), "value"(변수값) 로 이루어진 CommonMap의 리스트)
     * @return code(결과코드, 1이면 정상), description(결과에 대한 설명), msgId(전송요청 성공시 생성된 메시지 ID), msgType(전송한 메시지 타입(SMS, MMS)) 으로 이루어진 CommonMap
     */
    public CommonMap doSendTplSms(CommonMap singleParam, List<CommonMap> destList, List<CommonMap> msgParam) {
        return this.doSendTpl(singleParam, destList, msgParam, true);
    }
    
    /**
     * 내용의 길이와 상관없이 MMS를 전송한다.
     * @param singleParam 보낼 메시지의 제목("msgTitle"), 템플릿 코드("tplCode")
     * @param destList "cp"(휴대폰번호, 숫자만), "name"(이름) 으로 이루어진 CommonMap의 리스트 (메시지 수신할 사람 목록, 최대 100명)
     * @param msgParam 템플릿에 사용할 변수와 그 값("key"(변수명), "value"(변수값) 로 이루어진 CommonMap의 리스트)
     * @return code(결과코드, 1이면 정상), description(결과에 대한 설명), msgId(전송요청 성공시 생성된 메시지 ID), msgType(전송한 메시지 타입(SMS, MMS)) 으로 이루어진 CommonMap
     */
    public CommonMap doSendTplMms(CommonMap singleParam, List<CommonMap> destList, List<CommonMap> msgParam) {
        return this.doSendTpl(singleParam, destList, msgParam, false);
    }
    
    /**
     * SMS(MMS)를 담당하는 테이블에 데이터를 넣는다. 내용이 90byte를 초과하면 자동으로 MMS에 넣게 된다.
     * @param msgTitle 메시지 제목
     * @param sendMessage 보낼 메시지 내용
     * @param destList "cp"(휴대폰번호, 숫자만), "name"(이름) 으로 이루어진 CommonMap의 리스트 (메시지 수신할 사람 목록, 최대 100명)
     * @param isSMS true=SMS, false=MMS. SMS의 경우 길이를 초과하면 자동으로 MMS로 전환됨
     * @return code(결과코드, 1이면 정상), description(결과에 대한 설명), msgId(전송요청 성공시 생성된 메시지 ID), msgType(전송한 메시지 타입(SMS, MMS)) 으로 이루어진 CommonMap
     */
    private CommonMap doSend(CommonMap pInfo, List<CommonMap> destList, boolean isSMS) {
        
        String msgTitle = pInfo.getString("msgTitle");
        String sendMessage = pInfo.getString("sendMessage");
        String smsCode = pInfo.getString("smsCode");
        
        CommonMap result = new CommonMap();
        this.sendMessage = sendMessage;
        ApplicationContext context = ApplicationContextProvider.getApplicationContext();
        CommonService commonService = context.getBean(CommonService.class);
        
        try {
            CommonMap param = new CommonMap();
            
            // 필수값 체크 (영진모빌스 ID)
            if("".equals(this.smsUserId)) {
                System.out.println("SmsUtil.doSend :: smsUserId is empty. Use \"new SmsUtil(String, callBackNumber)\".");
                result.put("code", "-100");
                result.put("description", "smsUserId is empty. use \"new SmsUtil(String, callBackNumber)\".");
                return result;
            }
            
            // 필수값 체크 (회신번호)
            if("".equals(this.callBackNumber)) {
                System.out.println("SmsUtil.doSend :: callBackNumber is empty. Use \"new SmsUtil(String, callBackNumber)\".");
                result.put("code", "-101");
                result.put("description", "smsUserId is empty. use \"new SmsUtil(String, callBackNumber)\".");
                return result;
            }
            
            // 제목 확인
            if("".equals(msgTitle.trim())) {
                System.out.println("SmsUtil.doSend :: msgTitle is empty.");
                result.put("code", "-110");
                result.put("description", "msgTitle is empty. Check the part of calling doSend(msgTitle, sendMessage, destList).");
                return result;
            }
            
            // 보낼 메시지 확인
            if("".equals(sendMessage.trim())) {
                System.out.println("SmsUtil.doSend :: sendMessage is empty.");
                result.put("code", "-120");
                result.put("description", "sendMessage is empty. Check the part of calling doSend(msgTitle, sendMessage, destList).");
                return result;
            }
            
            // 수신자 목록 확인 (null 체크)
            if(destList == null) {
                System.out.println("SmsUtil.doSend :: destList is null.");
                result.put("code", "-130");
                result.put("description", "destList is null. Check the part of calling doSend(msgTitle, sendMessage, destList).");
                return result;
            }
            
            // 수신자 목록 확인 (개수 체크)
            if(destList.size() < 1) {
                System.out.println("SmsUtil.doSend :: destList has no elements(size=0).");
                result.put("code", "-131");
                result.put("description", "destList has no elements(size=0). Check the part of calling doSend(msgTitle, sendMessage, destList).");
                return result;
            }
            
            // 수신자 목록 확인 (내용 체크 : "cp", "name" 속성의 여부와 빈값/null 체크)
            for(CommonMap info : destList) {
                if(!info.containsKey("cp")) {
                    System.out.println("SmsUtil.doSend :: Some of elements in destList has no key(\"cp\").");
                    result.put("code", "-132");
                    result.put("description", "Some of elements in destList has no key(\"cp\"). Check destList has all keys(cp, name).");
                    return result;
                }
                if(!info.containsKey("name")) {
                    System.out.println("SmsUtil.doSend :: Some of elements in destList has no key(\"name\").");
                    result.put("code", "-134");
                    result.put("description", "Some of elements in destList has no key(\"name\"). Check destList has all keys(cp, name).");
                    return result;
                }
                
                String cp = info.getString("cp");
                String name = info.getString("name");
                
                if(cp == null || "".equals(cp)) {
                    System.out.println("SmsUtil.doSend :: Some of elements(key: cp) is null or empty.");
                    result.put("code", "-133");
                    result.put("description", "Some of elements(key: cp) is null or empty. Check values in destList are empty or null.");
                    return result;
                }
                
                if(name == null || "".equals(name)) {
                    System.out.println("SmsUtil.doSend :: Some of elements(key: name) is null or empty.");
                    result.put("code", "-135");
                    result.put("description", "Some of elements(key: name) is null or empty. Check values in destList are empty or null.");
                    return result;
                }
            }
            
            // 90 byte 초과시 MMS로 전환하기 위한 확인 (true=SMS, false=MMS)
            //isSMS = this.getByteLength(sendMessage) <= 90 ? true : false;
            
            // MSGID 새로 받아옴
            String queryId = isSMS ? "sms.smsUtil.select_SmsNextValue" : "sms.smsUtil.select_MmsNextValue";
            param.put("queryId", queryId);
            
            // Sequence 기능의 NextVal을 사용하여 사용할 MSGID 값을 미리 만든다.
            List<CommonMap> msgIdList = commonService.select(param);
            
            String msgId = "";
            
            if(msgIdList.size() > 0) {
                msgId = msgIdList.get(0).getString("nextval");
            } else {
                System.out.println("SmsUtil.doSend :: Sequence.NEXTVAL does not returned any rows.");
                result.put("code", "-210");
                result.put("description", (isSMS ? "SDK_SMS_SEQ" : "SDK_MMS_SEQ") + " does not returned any rows.");
                return result;
            }
            
            param.clear();
            
            // SMS와 MMS의 테이블이 다르기 때문에 쿼리를 나누어 놓음
            queryId = isSMS ? "sms.smsUtil.insert_ShortMessagingService" : "sms.smsUtil.insert_MultimediaMessagingService";
            
            // 메시지 받을 사람 세팅 "홍길동^01012341234|김나미^01000001111|..."
            String destInfo = "";
            for(int i = 0; i < destList.size(); i++) {
                destInfo += (i > 0 ? "|" : "") + destList.get(i).getString("name") + "^" + destList.get(i).getString("cp");
            }
            
            // 파라미터 세팅
            param.put("smsCode", smsCode);
            param.put("userId", this.smsUserId);
            param.put("msgId", msgId);
            param.put("subject", msgTitle);
            param.put("callback", this.callBackNumber);
            param.put("destCount", destList.size());
            param.put("destInfo", destInfo);
            param.put("sendMsg", sendMessage);
            // 쿼리명 세팅
            param.put("queryId", queryId);

            int cnt = commonService.insert(param);
            
            if(cnt > 0) {
                result.put("code", "1");
                result.put("msgId", msgId);
                result.put("msgType", (isSMS ? "SMS" : "MMS"));
                result.put("description", "Succeed to insert data.");
            } else {
                System.out.println("SmsUtil.doSend :: Failed to insert DB(returned rowcount is 0).");
                result.put("code", "-200");
                result.put("description", "Failed to insert data to Table.");
            }
            
            return result;
        } catch(Exception e) {
            System.out.println("SmsUtil.doSend :: Exception occured.");
            result.put("code", "-300");
            result.put("description", e.getMessage());
            e.printStackTrace();
            
            return result;
        }
    }

    /**
     * 템플릿을 사용하지 않고 SMS를 보낸다. 90byte가 넘으면 MMS로 전송한다.
     * @param msgTitle 메시지 제목
     * @param sendMessage 보낼 메시지 내용
     * @param destList "cp"(휴대폰번호, 숫자만), "name"(이름) 으로 이루어진 CommonMap의 리스트 (메시지 수신할 사람 목록, 최대 100명)
     * @return code(결과코드, 1이면 정상), description(결과에 대한 설명), msgId(전송요청 성공시 생성된 메시지 ID), msgType(전송한 메시지 타입(SMS, MMS)) 으로 이루어진 CommonMap
     */
    public CommonMap doSendSms(CommonMap info, List<CommonMap> destList) {
        boolean isSmsMSg = this.getByteLength(info.getString("sendMessage")) <= 90;
        return this.doSend(info, destList, isSmsMSg);
    }
    
    /**
     * 템플릿을 사용하지 않고 MMS를 보낸다. 길이에 상관없이 MMS로 전송된다.
     * @param msgTitle 메시지 제목
     * @param sendMessage 보낼 메시지 내용
     * @param destList "cp"(휴대폰번호, 숫자만), "name"(이름) 으로 이루어진 CommonMap의 리스트 (메시지 수신할 사람 목록, 최대 100명)
     * @return code(결과코드, 1이면 정상), description(결과에 대한 설명), msgId(전송요청 성공시 생성된 메시지 ID), msgType(전송한 메시지 타입(SMS, MMS)) 으로 이루어진 CommonMap
     */
    public CommonMap doSendMms(CommonMap info, List<CommonMap> destList) {
        return this.doSend(info, destList, false);
    }
}
