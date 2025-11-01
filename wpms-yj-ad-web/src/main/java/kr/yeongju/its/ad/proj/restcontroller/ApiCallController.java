package kr.yeongju.its.ad.proj.restcontroller;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import org.springframework.context.ApplicationContext;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

import egovframework.rte.fdl.property.EgovPropertyService;
import kr.yeongju.its.ad.common.config.ApplicationContextProvider;
import kr.yeongju.its.ad.common.dto.CommonMap;
import kr.yeongju.its.ad.common.dto.ResultInfo;
import kr.yeongju.its.ad.core.service.CommonService;
import kr.yeongju.its.ad.proj.controller.AutopayApiCallRunnable;
import kr.yeongju.its.ad.common.util.CommonUtil;
import kr.yeongju.its.ad.common.util.EncUtil;
import kr.yeongju.its.ad.common.util.MapUtils;


@RestController
@RequestMapping(value = "/apiCall")
public class ApiCallController {
    
    @Resource(name = "commonService")
    private CommonService commonService;
    
    @Resource(name="propertyService")
    protected EgovPropertyService propertyService;
    
    public ApiCallController(CommonService cmnSvc) {
        commonService = cmnSvc;
    }
    
    public void callParkingApi(CommonMap methodParam) throws Exception {
        
        /**
         * 파라미터
         * 
         * memberId : 회원 ID
         * walletFreeYn : 자동결제 ON(Y)인지 OFF(N)인지
         */
        
        CommonMap param = new CommonMap();
        EncUtil enc = new EncUtil();
        
        SimpleDateFormat cardExpDateFormatter = new SimpleDateFormat("yyMM");
        
        // 자동결제+회원정보변경 API 최대 반복 횟수
        int maxAutopayRepCnt = 0;

        // 자동결제 API 호출시 최종적으로 적용된 값
        String memberId = "";
        
        // API에 전달해야 하는 목록
        String parkingAreaCode = "";
        String serviceKey      = "";
        String carNumber       = "";
        String orgWalletFreeYn = "";    // 기존 자동결제 여부
        String walletFreeYn    = "";    // 변경하려는 자동결제 여부
        String enterDt         = "";
        String reduceCode      = "";
        String reduceNm        = "";
        String reduceRate      = "";
        
        try {
            ApplicationContext context = ApplicationContextProvider.getApplicationContext();
            EgovPropertyService propertyService = context.getBean(EgovPropertyService.class);
            
            memberId = methodParam.getString("memberId");
            
            // 해당 사용자의 차량이 입차되어 있는지를 확인한다
            param.put("queryId", "api.apiCall.select_ParkingCarInList");
            param.put("memberIdEnc", enc.encrypt(memberId), false);
            param.put("memberId", enc.encrypt(memberId), false);
            List<CommonMap> parkingList = commonService.select(param);
            
            // 주차장에 주차된 차량이 없으면 API 전송할 이유가 없기 때문에 종료
            if(parkingList.size() < 1) {
                System.out.println("--- callParkingApi ::: No car is parking in the parking lot.");
                return;
            }
            
            // API 버전 체크
            if(!("2".equals(parkingList.get(0).getString("apiVerGubn")) || "3".equals(parkingList.get(0).getString("apiVerGubn")))) {
                System.out.println("--- callParkingApi ::: Use API Version 2. Current: 1");
                return;
            }
            
            // 호출 여부 체크
            if(!"Y".equals(parkingList.get(0).getString("callApiYn"))) {
                System.out.println("--- callParkingApi ::: CALL_API_YN is not Y.");
                return;
            }

            // 기존 자동결제 상태를 저장하고, 파라미터로 받아 온 새로운 자동결제 상태가 없으면 기존 상태를 저장
            orgWalletFreeYn = parkingList.get(0).getString("currentAutoPayGubn");
            walletFreeYn = orgWalletFreeYn;

            // 자동결제 여부가 N이면 진행하지 않도록 처리
            if(orgWalletFreeYn.equals("N")){
                System.out.println("--- callParkingApi ::: Current AUTO_PAY_GUBN is N. No need to call member API.");
                return;
            }
            
            maxAutopayRepCnt = CommonUtil.toInt(parkingList.get(0).getString("autoApiTryCnt"));
            
            maxAutopayRepCnt = maxAutopayRepCnt < 1 ? 1 : maxAutopayRepCnt;
            // 카드 정보 조회
            param.put("queryId", "api.apiCall.select_cardList");
            List<CommonMap> cardList = commonService.select(param);
            
            // 등록된 카드 정보가 없으면 API 호출 필요 없음
            if(cardList.size() < 1) {
                System.out.println("--- callParkingApi AD (API gubn: ) ::: No card information found.");
                return;
            }
            
            boolean isValidCard = false;

            // 카드 유효일자 확인 작업
            for(int i = 0; i < cardList.size(); i++) {
                CommonMap cardRow = cardList.get(i);
                
                int creditExpDate = CommonUtil.toInt(cardRow.getString("creditExpDate"));
                int todayDate = CommonUtil.toInt(cardExpDateFormatter.format(new Date()));
                
                if(creditExpDate >= todayDate) {
                    isValidCard = true;
                    break;
                }
            }
            
            // 유효기간이 지난 카드만 있는 경우
            if(!isValidCard) {
                System.out.println("--- callParkingApi AD :: no card(exp date checked).");
                return;
            }
            
            System.out.println("--- callParkingApi AD ::: Loop Start - List Size=" + parkingList.size());
            
            // 주차된 차량별로 루프 시작
            for(int i = 0; i < parkingList.size(); i++) {
                CommonMap parkingRow = parkingList.get(i);
                
                // URL 형식이 맞지 않으면... (빈 값이거나 공백이 들어간 경우에도 형식에 맞지 않는다고 판단함)
                if(!CommonUtil.urlCheck(parkingRow.getString("apiUrl"))) {
                    // WAS 로그 남기기
                    System.out.println("--- callParkingApi AD (i = " + i + ") ::: Invalid API URL");
                    System.out.println("--- callParkingApi AD (i = " + i + ") ::: parkingNo = [" + parkingRow.getString("parkingNo") + "]");
                    System.out.println("--- callParkingApi AD (i = " + i + ") ::: historyCode = [" + parkingRow.getString("historyCode") + "]");
                    System.out.println("--- callParkingApi AD (i = " + i + ") ::: carNo = [" + parkingRow.getString("carNo") + "]");
                    System.out.println("--- callParkingApi AD (i = " + i + ") ::: memberIdEnc = [" + param.getString("memberIdEnc") + "]");
                    continue;
                }
                
                if("Y".equals(parkingRow.getString("isApi1"))) {
                    // 입차 API 2.0을 통해 입차한 차량만 가능하도록 처리 (차량 번호 때문에 루프 도중에 처리해야 함)
                    // 추후에 모든 차량이 API 2.0을 통해 입/출차를 진행하면 이 부분을 삭제하면 됨
                    // API 1.0을 통해 입차하였다면 WAS 로그를 남기고 다음 차량으로 계속 진행
                    System.out.println("--- callParkingApi AD (i = " + i + ") ::: The car is entered with API 1.0. Cannot run API. ");
                    System.out.println("--- callParkingApi AD (i = " + i + ") ::: parkingNo = [" + parkingRow.getString("parkingNo") + "]");
                    System.out.println("--- callParkingApi AD (i = " + i + ") ::: historyCode = [" + parkingRow.getString("historyCode") + "]");
                    System.out.println("--- callParkingApi AD (i = " + i + ") ::: carNo = [" + parkingRow.getString("carNo") + "]");
                    System.out.println("--- callParkingApi AD (i = " + i + ") ::: memberIdEnc = [" + param.getString("memberIdEnc") + "]");
                    continue;
                }
                
                System.out.println("--- callParkingApi ::: Start to run Parking API(i = " + i + "). ");
                
                param.put("historyCode", parkingRow.getString("historyCode"));

            
                param.put("parkingNo", parkingRow.getString("parkingNo"));
                param.put("carNo", parkingRow.getString("carNo"));
                
                    param.put("queryId", "api.apiCall.select_memberAllReductionRateList");
                List<CommonMap> reductionList = commonService.select(param);
                
                if(reductionList.size() < 0) {
                    // 감면 내역이 없을 수 없지만 만일을 대비해서 처리(기본 감면이라도 있음)
                    System.out.println("--- callParkingApi AD :: No reduction information found.");
                    continue;
                }
                
                CommonMap reductionRow = reductionList.get(0);
                reduceCode = reductionRow.getString("reductionCode");
                reduceNm   = reductionRow.getString("reductionName");
                reduceRate = reductionRow.getString("reductionRate");
                
                parkingAreaCode = parkingRow.getString("parkingAreaCode");
                serviceKey      = parkingRow.getString("pServiceKey");
                carNumber       = parkingRow.getString("carNo");
                enterDt         = parkingRow.getString("pEntDt");

                // 자동결제 API / T_CAR_STATUS.AUTO_PAY_GUBN 값 업데이트 처리
                // carNo, memberIdEnc 는 위에 있음

                // T_CAR_STATUS.PAY_YN 값 업데이트 처리 추가
                // (회원 여부, 자동결제 설정 여부, 사용 가능한 카드 등록 여부를 확인해야 함)
                // (1) 회원 여부 - 회원인 경우에만 이 메서드를 호출하므로 회원인 것으로 간주함
                // (2) 자동결제 설정 여부 - walletFreeYn 값을 사용
                // (3) 사용 가능한 카드 등록 여부 - 위에서 사용 가능한 카드가 없으면 return 처리 되기 때문에 이 시점에서는 카드가 있는 것으로 간주함
                // 즉, 현 시점에서 PAY_YN 값은 파라미터로 받은 walletFreeYn(설정하는 자동결제 여부) 을 업데이트 처리하면 됨
                
                // 최종적으로 AUTO_PAY_GUBN 값과 PAY_YN 값을 파라미터로 받은 walletFreeYn 변수값으로 업데이트 처리하면 최종적으로 완료됨
                param.put("queryId", "api.apiCall.update_NewMemberCarStatusAutoPayGubn");
                param.put("walletFreeYn", walletFreeYn);
                
                commonService.update(param);
                
                
                // 회원가입 API
                // T_PARKING_CAR_HISTORY, T_CAR_STATUS 테이블에 저장되는 아이디를 unknown 에서 사용자 아이디로 변경
                
                // T_CAR_STATUS 에서 자신의 아이디와 차량 번호로 검색했을 때 INOUT_STATUS 가 NULL 인 경우
                // 입차 후 회원가입한 것으로 간주하여 T_PARKING_CAR_HISTORY, T_CAR_STATUS 테이블에 업데이트를 쳐 준다.
                param.put("queryId", "api.apiCall.select_checkIsFirstEnter");
                List<CommonMap> checkList = commonService.select(param);
                
                if(checkList.size() > 0) {
                    // T_PARKING_CAR_HISTORY
                    param.put("queryId", "api.apiCall.update_NewMemberParkingCarHistory");
                    commonService.update(param);
                    // T_CAR_STATUS (비회원으로 등록된 입차중인 정보를 회원 정보에 업데이트 처리)
                    // 이 시점에서는 같은 차량번호로 비회원 데이터와 회원 데이터가 공존하고 있음
                    param.put("queryId", "api.apiCall.update_CopyCarStatusFromUnknownInfo");
                    commonService.update(param);
                }
                
                // 가장 순위가 높은 감면코드, 이름, 비율을 T_CAR_STATUS 테이블에 업데이트
                param.put("reductionCode", reduceCode);
                param.put("reductionName", reduceNm);
                param.put("reductionRate", reduceRate);
                param.put("queryId", "api.apiCall.update_CarStatusReduction");
                
                commonService.update(param);
                
                
                CommonMap apiParam = new CommonMap();
                
                apiParam.put("memberIdEnc", enc.encrypt(memberId), false);
                apiParam.put("parkingAreaCode", parkingAreaCode);
                apiParam.put("serviceKey", serviceKey);
                apiParam.put("carNumber", carNumber);
                apiParam.put("walletFreeYN", walletFreeYn);
                apiParam.put("isTest", propertyService.getBoolean("debugMode"));

                apiParam.put("enterDt", enterDt);
                apiParam.put("reduceCode", reduceCode);
                apiParam.put("reduceNm", reduceNm);
                apiParam.put("reduceRate", reduceRate);

                if(propertyService.getBoolean("debugMode")) {
                	apiParam.put("apiUrl", propertyService.getString("autoPayApiUrl"));
                }
                
                Thread t = new Thread(new AutopayApiCallRunnable(apiParam, parkingRow.getString("apiUrl"), maxAutopayRepCnt, commonService, "1"));
                t.start();
               
            }
        } catch(Exception e) {
            e.printStackTrace();
        }
    }
    
    /**
     * (Crontab 에서 호출하는 용도) 모든 사용가능한 주차장의 주차면수를 받아오도록 하는 컨트롤러
     * @param request
     * @return
     */
    @RequestMapping(value = "/allParkingCount", method = RequestMethod.GET)
    public ResultInfo callParkingCountUrl(HttpServletRequest request) {
        String message = "";
        int count = 1;
        CommonMap data = new CommonMap();
        
        // 특정 파라미터가 없거나 값이 일치하지 않으면 처리되지 않도록 하기 위함(GET 방식이므로 URL에 붙여서 호출)
        // 특수 파라미터의 키
        final String requiredParamName = "runParkingCountApi";
        // 특수 파라미터의 값
        final String requiredParamValue = "walletfree";
        
        // 메서드 호출 일시
        Date callDt = new Date();
        // 날짜 Formatter
        SimpleDateFormat dateTimeFormatter = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS000");
        // 날짜 항목에 값이 없을 때 들어갈 데이터
        String initDate = "1980-01-01 00:00:00.000000";
        
        try {
            CommonMap param = MapUtils.parseRequest(request);
            if(param.getString(requiredParamName).isEmpty()) {
                // 특정 파라미터를 받아야 실행하도록 처리
                // 없으면 실행하지 않도록 함
                System.out.println("/apiCall/allParkingCount : Required parameter is invalid or empty.");
                count = -1000;
                message = "Required parameter is invalid or empty";
                parkingCntCallHistory("", "CRONTAB", "", dateTimeFormatter.format(callDt), "N", initDate, String.valueOf(count), "", "", "필수 파라미터값이 없거나 비어 있습니다.", initDate);
                return ResultInfo.of(message, count, data);
            }
            
            if(!requiredParamValue.equals(param.getString(requiredParamName))) {
                // 특정 파라미터의 값이 일치해야 실행하도록 처리
                // 일치하지 않으면 실행하지 않도록 함
                System.out.println("/apiCall/allParkingCount : Required parameter is invalid or empty.");
                count = -1100;
                message = "Required parameter is invalid or empty";
                parkingCntCallHistory("", "CRONTAB", "", dateTimeFormatter.format(callDt), "N", initDate, String.valueOf(count), "", "", "필수 파라미터값이 없거나 비어 있습니다.", initDate);
                return ResultInfo.of(message, count, data);
            }
            
            // CRONTAB 실행 여부 체크
            param.put("queryId", "api.apiCall.select_CheckCrontabRunnable");
            List<CommonMap> runList = commonService.select(param);
            if(runList.size() < 1) {
                // 없으면 실행 불가
                System.out.println("/apiCall/allParkingCount : CRONTAB option is not available.");
                count = -1300;
                message = "CRONTAB option is not available.";
                parkingCntCallHistory("", "CRONTAB", "", dateTimeFormatter.format(callDt), "N", initDate, String.valueOf(count), "", "", "스케줄러 사용여부 옵션이 없습니다.", initDate);
                return ResultInfo.of(message, count, data);
            }
            
            if(!"Y".equalsIgnoreCase(runList.get(0).getString("parkcntCrontabUseYn"))) {
                // 실행 여부가 Y가 아닌 경우 실행하지 않음
                System.out.println("/apiCall/allParkingCount : CRONTAB option is off.");
                count = -1400;
                message = "CRONTAB option is not available.";
                parkingCntCallHistory("", "CRONTAB", "", dateTimeFormatter.format(callDt), "N", initDate, String.valueOf(count), "", "", "스케줄러 사용이 중지되어 있습니다.", initDate);
                return ResultInfo.of(message, count, data);
            }
            
            // 주차장 목록 Select
            param.put("queryId", "api.apiCall.select_UsableParkingLotList");
            List<CommonMap> parkingList = commonService.select(param);
            
            if(parkingList.size() > 0) {
                // 주차장별로 주차면수 api 호출
                for(CommonMap row : parkingList) {
                    callParkingCount(row.getString("parkingNo"), "CRONTAB", dateTimeFormatter.format(callDt));
                }
            } else {
                // 주차장 목록이 없다면 오류 처리
                System.out.println("/apiCall/allParkingCount : No usable parking list found.");
                count = -1500;
                message = "No usable parking list found.";
                parkingCntCallHistory("", "CRONTAB", "", dateTimeFormatter.format(callDt), "N", initDate, String.valueOf(count), "", "", "사용 가능한 주차장이 없습니다.", initDate);
                return ResultInfo.of(message, count, data);
            }
        } catch(Exception e) {
            parkingCntCallHistory("", "CRONTAB", "", dateTimeFormatter.format(callDt), "N", initDate, "", "", "", "서버오류 발생 : " + e.getMessage(), initDate);
            e.printStackTrace();
        }
        
        return ResultInfo.of(message, count, data);
    }
    
    /**
     * 주차면수 업데이트를 위한 메서드 (스레드 호출용)
     * @param parkingNo 주차장코드
     * @param callFrom 입차(API_IN:입차, API_OUT:출차, CRONTAB:크론탭, MANUAL:수동 수정)
     * @param stdDt 기준일시 (입차: 입차일시, 출차: 출차일시, 크론탭/수동: 호출 시점의 일시)
     */
    public void callParkingCount(String parkingNo, String callFrom, String stdDt) {
        
        CommonMap param = new CommonMap();
        // 날짜 항목에 값이 없을 때 들어갈 데이터
        String initDate = "1980-01-01 00:00:00.000000";
        // API 호출 url
        String apiUrl = "";
        
        try {
            ApplicationContext context = ApplicationContextProvider.getApplicationContext();
            EgovPropertyService propertyService = context.getBean(EgovPropertyService.class);
            
            // 1. 파라미터 확인 (param.getString("parkingNo"))
            //    - 문제시 로그에 추가
            // 2. 현재 시간이 마지막 업데이트 이전 시간이면 처리하지 않음
            // 3. 주차면수 API 호출 (로그 추가는 여기에 포함됨)
            
            // 1. 파라미터 확인
            if(parkingNo.isEmpty()) {
                System.out.println("--- callParkingCount AD ::: Parking No(Parameter) is not found.");
                // 파라미터 없는 경우 주차면수 API 로그 추가 후 종료
                parkingCntCallHistory(parkingNo, callFrom, "", stdDt, "N", initDate, "-2000", "", "", "주차장 코드가 비어있음", initDate);
                return;
            }
            
            // 주차장 코드가 유효한 값인지를 확인
            // 추가로 옵션값도 같이 select 처리
            param.put("parkingNo", parkingNo);
            param.put("callFrom", callFrom);
            param.put("queryId", "api.apiCall.select_ParkingCountApiHistoryOption");
            List<CommonMap> optionList = commonService.select(param);
            
            // 옵션값이 없거나 주차장 정보가 없다면 오류 처리..
            if(optionList.size() < 1) {
                System.out.println("--- callParkingCount AD ::: Invalid or unused Parking No(" + parkingNo + ").");
                parkingCntCallHistory(parkingNo, callFrom, "", stdDt, "N", initDate, "-2100", "", "", "잘못되거나 미사용 중인 주차장(" + parkingNo + ").", initDate);
                return;
            }
            
            // 주차면수 옵션 비활성화된 경우 처리하지 않음
            if(!"Y".equalsIgnoreCase(optionList.get(0).getString("isContinue"))) {
                System.out.println("--- callParkingCount AD ::: Parking Count API Call option is disabled(callFrom: " + callFrom + ")");
                parkingCntCallHistory(parkingNo, callFrom, "", stdDt, "N", initDate, "-2110", "", "", "주차면수 API 옵션이 비활성화 되어 있습니다(callFrom: " + callFrom + ", matchCodeId: " + optionList.get(0).getString("matchCodeId") + ", matchType: " + optionList.get(0).getString("matchType") + ").", initDate);
                return;
            }
            
            // APi 2.0 을 사용하는 주차장에 적용해야 함
            if(!("2".equals(optionList.get(0).getString("apiVerGubn")) || "3".equals(optionList.get(0).getString("apiVerGubn")))) {
                System.out.println("--- callParkingCount AD ::: The parking does not alled to run API 2.0 (callFrom: " + callFrom + " / parkingNo: " + parkingNo + ")");
                parkingCntCallHistory(parkingNo, callFrom, "", stdDt, "N", initDate, "-2120", "", "", "주차면수 API는 API 2.0을 사용하는 주차장에서만 처리 가능합니다(callFrom: " + callFrom + ", matchCodeId: " + optionList.get(0).getString("matchCodeId") + ", matchType: " + optionList.get(0).getString("matchType") + ").", initDate);
                return;
            }
            
            // URL이 비어있거나 http://, https:// 로 시작하지 않으면 처리 불가
            if("".equals(optionList.get(0).getString("parkcntApiUrl")) || !(optionList.get(0).getString("parkcntApiUrl").startsWith("http://") || !optionList.get(0).getString("parkcntApiUrl").startsWith("https://"))) {
                System.out.println("--- callParkingCount AD ::: The url is empty (callFrom: " + callFrom + " / parkingNo: " + parkingNo + ")");
                parkingCntCallHistory(parkingNo, callFrom, "", stdDt, "N", initDate, "-2130", "", "", "주차면수 API URL(" + optionList.get(0).getString("parkcntApiUrl") + ")이 비어 있거나 형식에 맞지 않습니다.(callFrom: " + callFrom + ", matchCodeId: " + optionList.get(0).getString("matchCodeId") + ", matchType: " + optionList.get(0).getString("matchType") + ").", initDate);
                return;
            }
            
            // 2. 현재 시간이 마지막 업데이트 이전 시간이면 처리하지 않음
            // 결과 수신 일시가 현재 시간보다 이후이면 지금 현재 요청이 과거의 요청이므로 업데이트 하지 않음
            param.put("stdDt", stdDt);
            param.put("queryId", "api.apiCall.select_ParkingCountApiHistoryTimeCheck");
            List<CommonMap> checkDateList = commonService.select(param);
            
            if(checkDateList.size() < 0) {
                // 데이터가 없으면 오류 처리 (미사용 주차장이나 해당 주차장 코드가 없으면 처리 불가)
                parkingCntCallHistory(parkingNo, callFrom, "", stdDt, "N", initDate, "-2200", "", "", "주차장 정보를 찾을 수 없거나 미사용 처리된 주차장입니다(" + parkingNo + ").", initDate);
                return;
            }
            
            if(!"Y".equals(checkDateList.get(0).getString("canBeUpdated"))) {
                // 주차면수 업데이트가 필요하지 않으면 중단
                parkingCntCallHistory(parkingNo, callFrom, "", stdDt, "N", initDate, "-2210", "", "", "주차면수 업데이트가 필요 없음", initDate);
                return;
            }
            
            // 3. 주차면수 api 호출
            
            // 옵션 값 추가
            CommonMap optionRow = optionList.get(0);
            int maxParkingCountTryCnt = optionRow.getInt("parkcntApiTryCnt");
            
            // API 호출 URL 끝에 "/" 가 있다면 제거 처리
            apiUrl = optionRow.getString("parkcntApiUrl");
            apiUrl = apiUrl.lastIndexOf("/") == apiUrl.length() - 1 ? apiUrl.substring(0, apiUrl.length() - 1) : apiUrl;
            
            // API 호출용 파라미터 세팅
            CommonMap apiParam = new CommonMap();
            apiParam.put("parkingNo", param.getString("parkingNo")); // 주차장 번호
            apiParam.put("callUrl", apiUrl); // 호출 url (/parking/space/{주차장번호})
            apiParam.put("callFrom", callFrom); // 어디서 호출했는지 저장하는 값 (API_IN, API_OUT, CRONTAB, MANUAL)
            apiParam.put("stdDt", stdDt); // 이 메서드를 호출한 일시
            apiParam.put("isTest", propertyService.getBoolean("debugMode"));
            
            // 실제 호출하는 스레드 시작
            Thread t = new Thread(new AutopayApiCallRunnable(apiParam, apiUrl, maxParkingCountTryCnt, commonService, "4"));
            t.start();
            
        } catch(Exception e) {
            // API URL은 있는 경우에만 넣고, 세팅되어 있지 않다면 안되어 있는 대로 넣음
            parkingCntCallHistory(parkingNo, callFrom, apiUrl, stdDt, "N", initDate, "-9999", "", "", "서버오류 발생 : " + e.getMessage(), initDate);
            e.printStackTrace();
        }
    }
    

    /**
     * 주차면수 api 히스토리 추가 (실패 히스토리)
     * @param parkingNo 주차장코드
     * @param callFrom 호출 위치
     * @param callUrl 호출 url
     * @param stdDt 기준 일시
     * @param isUpdated 업데이트 여부
     * @param apiRequestDt api 호출 칠시
     * @param resultCode 수신결과 코드
     * @param resultMsg 수신결과 메시지
     * @param resultJson 수신결과 전체
     * @param errMsg 오류 메시지
     * @param apiRecvDt 결과 수신 일시
     */
    private void parkingCntCallHistory(
            String parkingNo, String callFrom, String callUrl, String stdDt, String isUpdated
          , String apiRequestDt, String resultCode, String resultMsg, String resultJson, String errMsg
          , String apiRecvDt
    ) {
        try {
            
            CommonMap param = new CommonMap();
            param.put("queryId", "api.apiCall.insert_ParkingCountApiHistory");
            param.put("parkcntApiCode", "PAC" + CommonUtil.fnMakeRandomNum(6)); // Parking count Api Code (주차면수 API 히스토리 코드, 키값)
            
            param.put("parkingNo", parkingNo);
            param.put("callFrom", callFrom);
            param.put("callUrl", callUrl);
            param.put("stdDt", stdDt);
            param.put("isUpdated", isUpdated);
            param.put("apiRequestDt", apiRequestDt);
            param.put("resultCode", resultCode);
            param.put("resultMsg", resultMsg);
            param.put("resultJson", resultJson);
            param.put("errMsg", errMsg);
            param.put("apiRecvDt", apiRecvDt);
            
            commonService.insert(param);
        } catch(Exception e) {
            e.printStackTrace();
        }
    }
}