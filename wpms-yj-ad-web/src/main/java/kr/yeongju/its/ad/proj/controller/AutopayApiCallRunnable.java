package kr.yeongju.its.ad.proj.controller;

import java.text.SimpleDateFormat;
import java.util.Date;

import javax.annotation.Resource;

import egovframework.rte.fdl.property.EgovPropertyService;
import kr.yeongju.its.ad.common.dto.CommonMap;
import kr.yeongju.its.ad.common.util.CallApiUtil;
import kr.yeongju.its.ad.common.util.CommonUtil;
import kr.yeongju.its.ad.core.service.CommonService;

public class AutopayApiCallRunnable implements Runnable {
	
    private CommonMap mParam;
    private String mApiUrl = "";
    private int mMaxCnt = 0;
    private CommonService commonService;
    private String mApiGubn = "";
    
    private int mRepCnt = 0;
    
    /**
     * 자동결제 변경 & 회원정보변경 API 호출
     */
    private final String API_GUBN_AUTOPAY = "1";
    /**
     * 주차면수 API 호출
     */
    private final String API_GUBN_PARK_CNT = "4";

    public AutopayApiCallRunnable(CommonMap pParam, String pApiUrl, int pMaxCnt, CommonService pCmnSvc, String pApiGubn) {
        mParam = pParam;
        mApiUrl = pApiUrl;
        mMaxCnt = pMaxCnt;
        commonService = pCmnSvc;
        mApiGubn = pApiGubn;
    }
    
    @Override
    public void run() {       
        if(API_GUBN_PARK_CNT.equals(mApiGubn)) {
            // 주차면수 API 호출
            while(mRepCnt < mMaxCnt) {
                System.out.println("----- AutopayApiCallRunnable AD(" + mApiGubn + ") [" + mRepCnt + " / " + mMaxCnt + "]");
                if("1".equals(parkingCountApiCall(mParam, mApiUrl))) {
                    break;
                } else {
                    ++mRepCnt;
                }
            }
        }else{
            // 자동결제 & 회원정보변경 API 호출
            while(mRepCnt < mMaxCnt) {
                System.out.println("----- AutopayApiCallRunnable AD(" + mApiGubn + ") [" + mRepCnt + " / " + mMaxCnt + "]");
                if("1".equals(autopayApiCall(mParam, mApiUrl))) {
                    break;
                } else {
                    ++mRepCnt;
                }
            }
        }
    }
    
    public String autopayApiCall(CommonMap apiParam, String apiUrl) {
        boolean isTest = apiParam.getBoolean("isTest");

        SimpleDateFormat dateTimeFormatter = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS000");
        SimpleDateFormat dateFormatter = new SimpleDateFormat("yyyyMMdd");
        String memberUrl = "/register";
        // 발생일자
        Date occurDt = new Date();
        
        if(!isTest) {
            memberUrl = apiUrl + "/automatic/payment";
        } else {
             memberUrl = apiParam.getString("apiUrl");
        }
        
        // 회원가입 API 호출
        String resultJson = CallApiUtil.post(memberUrl, apiParam);
        // JSON Parsing
        CommonMap apiResult = CallApiUtil.parseJSON(resultJson);

        apiResult.put("enterDt", apiParam.getString("enterDt"));
        apiResult.put("reduceCode", apiParam.getString("reduceCode"));
        apiResult.put("reduceNm", apiParam.getString("reduceNm"));
        apiResult.put("reduceRate", apiParam.getString("reduceRate"));
        apiResult.put("parkingAreaCode", apiParam.getString("parkingAreaCode"));
        apiResult.put("serviceKey", apiParam.getString("serviceKey"));
        apiResult.put("carNumber", apiParam.getString("carNumber"));
        apiResult.put("walletFreeYN", apiParam.getString("walletFreeYN"));
        apiResult.put("resultJson", resultJson);
        apiResult.put("apiRecvDt", dateTimeFormatter.format(new Date()));
        apiResult.put("apiCallDt", dateTimeFormatter.format(occurDt));
        apiResult.put("occurDt", dateFormatter.format(occurDt));
        apiResult.put("memberIdEnc", apiParam.getString("memberIdEnc"), false);
        // apiResult 에 원래 있는 값
        // resultCode, resultMsg, errMsg, isSuccess
        
        autopayApiCallHistory(apiResult);
        
        return apiResult.getString("resultCode");
    }
    
    // 주차면수 API 호출
    public String parkingCountApiCall(CommonMap apiParam, String apiUrl) {
        
        // boolean isTest = apiParam.getBoolean("isTest");

        SimpleDateFormat dateTimeFormatter = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS000");
        String parkCntApiUrl = "";
        
        parkCntApiUrl = apiUrl + "/parking/space/" + apiParam.getString("parkingNo");
        
        // API 요청(실제 요청 직전) 일시
        Date apiRequestDt = new Date();
        
        // 주차면수 API 호출
        // PARKING_NO 는 파라미터에 포함
        String resultJson = CallApiUtil.get(parkCntApiUrl, apiParam, false);
        Date recvDt = new Date();
        // JSON Parsing
        CommonMap apiResult = CallApiUtil.parseJSONDoc(resultJson);
        
        apiResult.put("callUrl", parkCntApiUrl); // 호출 URL
        apiResult.put("resultJson", resultJson); // 결과 JSON 전체
        apiResult.put("apiRecvDt", dateTimeFormatter.format(recvDt)); // 결과 수신 일시
        apiResult.put("apiRequestDt", dateTimeFormatter.format(apiRequestDt)); // 실제 api 요청 일시
        
        // parkingNo 는 파라미터로 받아옴
        apiParam.put("totalParkingCount", apiResult.getString("totalParkingCount"));
        apiParam.put("nowParkingCount", apiResult.getString("nowParkingCount"));
        updateParkingCount(apiParam);
        
        apiResult.put("parkingNo", apiParam.getString("parkingNo"));
        apiResult.put("callFrom", apiParam.getString("callFrom"));
        apiResult.put("stdDt", apiParam.getString("stdDt"));
        apiResult.put("isUpdated", "Y");
        parkingCntCallHistory(apiResult);
        
        return apiResult.getString("resultCode");
    }
    
    // 자동결제 변경 & 회원정보변경 API 히스토리 추가
    public void autopayApiCallHistory(CommonMap param) {
        try {
            param.put("queryId", "api.apiCall.insert_AutoPayApiHistory");
            param.put("regApiCode", "RAC" + CommonUtil.fnMakeRandomNum(6)); // Register Api Code (회원가입 API 코드, 키값)
            
            if(!param.has("carNumber")) { param.put("carNumber", "-"); }
            if(!param.has("walletFreeYn")) { param.put("walletFreeYn", "-"); }
            if(!param.has("serviceKey")) { param.put("serviceKey", "-"); }
            if(!param.has("parkingAreaCode")) { param.put("parkingAreaCode", "-"); }
            if(!param.has("enterDt")) { param.put("enterDt", "-"); }
            if(!param.has("reduceCode")) { param.put("reduceCode", "-"); }
            if(!param.has("reduceNm")) { param.put("reduceNm", "-"); }
            if(!param.has("reduceRate")) { param.put("reduceRate", "-"); }
            if(!param.has("resultCode")) { param.put("resultCode", "-"); }
            if(!param.has("resultMsg")) { param.put("resultMsg", "-"); }
            if(!param.has("apiCallDt")) { param.put("apiCallDt", "-"); }
            if(!param.has("resultJson")) { param.put("resultJson", "-"); }
            if(!param.has("occurDt")) { param.put("occurDt", "-"); }
            if(!param.has("errMsg")) { param.put("errMsg", "-"); }
            if(!param.has("memberIdEnc")) { param.put("memberIdEnc", "-"); }
            if(!param.has("apiRecvDt")) { param.put("apiRecvDt", "-"); }
            
            commonService.insert(param);
        } catch(Exception e) {
            e.printStackTrace();
        }
    }

    // 주차면수 API 히스토리 추가
    public void parkingCntCallHistory(CommonMap param) {
        try {
            // 날짜 항목에 값이 없을 때 들어갈 데이터
            String initDate = "1980-01-01 00:00:00.000000";
            
            param.put("queryId", "api.apiCall.insert_ParkingCountApiHistory");
            param.put("parkcntApiCode", "PAC" + CommonUtil.fnMakeRandomNum(6)); // Parking count Api Code (주차면수 API 히스토리 코드, 키값)
            
            if(!param.has("parkingNo")) { param.put("parkingNo", ""); }
            if(!param.has("callFrom")) { param.put("callFrom", ""); }
            if(!param.has("callUrl")) { param.put("callUrl", ""); }
            if(!param.has("stdDt")) { param.put("stdDt", initDate); }
            if(!param.has("isUpdated")) { param.put("isUpdated", ""); }
            if(!param.has("apiRequestDt")) { param.put("apiRequestDt", initDate); }
            if(!param.has("resultCode")) { param.put("resultCode", ""); }
            if(!param.has("resultMsg")) { param.put("resultMsg", ""); }
            if(!param.has("resultJson")) { param.put("resultJson", ""); }
            if(!param.has("errMsg")) { param.put("errMsg", ""); }
            if(!param.has("apiRecvDt")) { param.put("apiRecvDt", initDate); }
            
            commonService.insert(param);
        } catch(Exception e) {
            e.printStackTrace();
        }
    }
    
    // 주차면수 업데이트
    public void updateParkingCount(CommonMap param) {
        try {
            param.put("queryId", "api.apiCall.update_ParkingCountOnly");
            param.put("lastParkcntModDt", param.getString("stdDt"));
            // parkingNo, totalParkingCount, nowParkingCount 는 받아와야 함
            
            commonService.update(param);
        } catch(Exception e) {
            e.printStackTrace();
        }
    }
}