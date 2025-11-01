package kr.yeongju.its.ad.proj.service;

import java.text.DecimalFormat;
import java.util.HashMap;
import java.util.List;
import java.util.logging.Logger;

import javax.annotation.Resource;

import org.json.simple.JSONObject;
import org.springframework.jdbc.datasource.DataSourceTransactionManager;
import org.springframework.stereotype.Service;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.TransactionDefinition;
import org.springframework.transaction.TransactionStatus;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.DefaultTransactionDefinition;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.tags.ParamAware;

import egovframework.rte.fdl.property.EgovPropertyService;
import kr.yeongju.its.ad.common.dto.CommonMap;
import kr.yeongju.its.ad.common.dto.ResultInfo;
import kr.yeongju.its.ad.common.exception.NotFoundException;
import kr.yeongju.its.ad.common.util.CommonUtil;
import kr.yeongju.its.ad.common.util.EncUtil;
import kr.yeongju.its.ad.common.util.FunctionUtils;
import kr.yeongju.its.ad.common.util.MsgUtil;
import kr.yeongju.its.ad.common.util.SmartroPayUtil;
import kr.yeongju.its.ad.core.service.CommonService;

@Service("paymentService")
public class PaymentServiceImpl implements PaymentService {

	@Resource(name = "commonService")
	private CommonService commonService;

	@Resource(name="propertyService")
    protected EgovPropertyService propertyService;

	@Resource(name="transactionManager")
    PlatformTransactionManager transactionManager;
	// 승인
	@Transactional
	public ResultInfo updateSuccessData(CommonMap param) throws Exception {

		Logger logger = Logger.getLogger("mylogger");
    	DefaultTransactionDefinition txDefinition = new DefaultTransactionDefinition();
    	txDefinition.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRED);
 		TransactionStatus txStatus = transactionManager.getTransaction(txDefinition);

		String url = propertyService.getString("payCancelApiUrl");       // 테스트
		//String url = "https://approval.smartropay.co.kr/payment/approval/cancel.do";     // 운영
		boolean isTest = propertyService.getBoolean("payTest");		 // 테스트 여부

		JSONObject body = new JSONObject();
		JSONObject paramData = new JSONObject();
		EncUtil enc = new EncUtil();
		DecimalFormat df = new DecimalFormat("###,###");
		String payGubnStr = "";

		param.put("queryId", "pay.paymentManage.Select_payInfo");
		CommonMap payInfo = commonService.selectOne(param);

		// t_parking_pay_cancel max_seq
		param.put("queryId", "pay.paymentManage.select_maxSeq");
		CommonMap item = commonService.selectOne(param);

		// t_parking_pay max_seq
		param.put("queryId", "pay.paymentManage.select_pay_maxSeq");
		CommonMap item2 = commonService.selectOne(param);

		param.put("paySeq", Integer.parseInt(item.get("paySeq").toString()));
		param.put("prevSeq", Integer.parseInt(item2.get("paySeq").toString()));

		try {
			if(payInfo == null) {
				// 결제정보 없음
				System.out.println("Mid는 필수입니다.");
//			    return -3;
			    return ResultInfo.of("Mid는 필수입니다.", -3, null);
			}

			if("".equals(payInfo.getString("onceMid")) || "".equals(payInfo.getString("onceMidPw")) || "".equals(payInfo.getString("billingMid"))) {
				// 결제정보에 빈값이 존재합니다.
				System.out.println("결제정보에 빈값이 존재합니다.");
//			    return -4;
			    return ResultInfo.of("결제정보에 빈값이 존재합니다.", -4, null);
			}

			//MID (일회용 결제를 취소하려면 일반용 MID를, 빌링 결제를 취소하려면 빌링용 MID를 사용해야 함)
			String Mid = payInfo.getString("billingMid");
			param.put("queryId", "pay.paymentManage.Select_PayCode");
			CommonMap member_id = commonService.selectOne(param);
			String biliiMallid = member_id.getString("memberId");

			//가맹점 키(상점키)
			String MerchantKey = payInfo.getString("merchantKey");            // 발급받은 테스트 상점키 설정(Real 전환 시 운영 상점키 설정)
			String CancelPwd = payInfo.getString("onceMidPw"); // 가맹점 관리자에서 설정한 취소 비밀번호

			String Tid = param.getString("tId").toString(); //"t_2301101m01012301281347442061";            // 취소 요청할 Tid 입력***
			String CancelAmt = param.getString("hPrice").toString();  // 취소할 거래금액

			if(Tid == null || "".equals(Tid)) {
			    // 이 이후로는 실행하지 않으며, php의 exit 구문과 같은 역할을 한다고 함
				System.out.println("TID(Tid)는 필수입니다.");
//			    return -1;
			    return ResultInfo.of("TID(Tid)는 필수입니다.", -1, null);
			}
			if(CancelAmt == null || "".equals(CancelAmt)) {
			    // 이 이후로는 실행하지 않으며, php의 exit 구문과 같은 역할을 한다고 함
				System.out.println("취소 금액(CancelAmt)은 필수입니다.");
//			    return -2;
			    return ResultInfo.of("취소 금액(CancelAmt)은 필수입니다.", -2, null);
			}

			param.put("queryId", "pay.paymentManage.Select_PayGubn");
			CommonMap payGubn = commonService.selectOne(param);

			//부가세를 Java로 계산하여 세팅해 줌
			//결제금액을 숫자로 변환
			int amt = Integer.parseInt(CancelAmt, 10);
			//부가세 계산하여 Hashmap으로 리턴해 줌
			//비과세 금액은 0으로 계산했지만, 필요한 경우에 0 대신 다른 금액을 넣으면 계산하여 처리함
			//(totalAmt=총 결제금액, taxFreeAmt=비과세금액, vat=VAT금액, tax=과세금액)
			HashMap<String, Integer> moneyData = SmartroPayUtil.calVat(amt, 0);

			String CancelSeq = "1";     // 취소차수(기본값: 1, 부분취소 시마다 차수가 1씩 늘어남. 첫번째 부분취소=1, 두번째 부분취소=2, ...)
			String PartialCancelCode = "0";     // 0: 전체취소, 1: 부분취소
			//검증값 SHA256 암호화(Tid + MerchantKey + CancelAmt + PartialCancelCode)
			String HashData = SmartroPayUtil.encodeSHA256Base64(Tid + MerchantKey + CancelAmt + PartialCancelCode);

			//취소 요청 파라미터 셋팅
			paramData.put("SERVICE_MODE", "CL1");
			paramData.put("Tid", Tid);
			paramData.put("Mid", Mid);
			paramData.put("CancelAmt", CancelAmt);
			paramData.put("CancelPwd", CancelPwd);
			paramData.put("CancelMsg", param.getString("cancelReason").toString()); // 취소 메시지
			paramData.put("CancelSeq", CancelSeq);
			paramData.put("PartialCancelCode", PartialCancelCode);

			//과세, 비과세, 부가세 셋팅(부가세 직접 계산 가맹점의 경우 각 값을 계산하여 설정해야 합니다.)
			paramData.put("CancelTaxAmt", String.valueOf(moneyData.get("tax")));
			paramData.put("CancelTaxFreeAmt", String.valueOf(moneyData.get("taxFreeAmt")));
			paramData.put("CancelVatAmt", String.valueOf(moneyData.get("vat")));

			//서브몰 사용 가맹점의 경우, DivideInfo 파라미터를 가맹점에 맞게 설정해 주세요. (일반연동 참고)
			paramData.put("DivideInfo", "");

			//HASH 설정 (필수)
			paramData.put("HashData", HashData);


			//json 데이터 AES256 암호화
			try {
			    // AES_Encode 암호화 함수 - 기타연동 메뉴 참조
			    body.put("EncData", SmartroPayUtil.AES_Encode(paramData.toString(), MerchantKey.substring(0,32)));
			    body.put("Mid", Mid);
			} catch(Exception e){
			    e.printStackTrace();
			}

			HashMap<String, Object> result = new HashMap<String, Object>();

			if(isTest) {
				result.put("ResultCode", "2001");
			} else {
				result = SmartroPayUtil.callApi(body, url);
			}

			if(!"2001".equals(result.get("ResultCode"))){
				transactionManager.rollback(txStatus);
				// 결제 취소 에러.
				System.out.println(result.get("ResultMsg"));
//				return 0;
				return ResultInfo.of((String) result.get("ResultMsg"), 0, null);
			}

			if("U".equals(param.getString("cancelType"))) {
				payGubnStr = payGubn.getString("payGubn");				
			}else {
				payGubnStr = "PG002";
			}

			if("PG002".equals(payGubnStr)) {
				// 취소 요청
				param.put("payGubn", "PG003");

				param.put("queryId", "pay.paymentManage.Insert_SuccessData");
				int cnt = commonService.update(param);

				param.put("queryId", "pay.paymentManage.Update_SuccessData2");
				cnt += commonService.update(param);

				int parkingChargeCnt = 0;
				if(cnt > 0) {
					param.put("queryId", "pay.paymentManage.Update_Success_ParkingCharge");
					parkingChargeCnt = commonService.update(param);
				}else {
					transactionManager.rollback(txStatus);
					// 결제정보에 빈값이 존재합니다.
					System.out.println("Error_SuccessData");
//					return 0;
					return ResultInfo.of("Error_SuccessData", 0, null);
				}

				if(parkingChargeCnt > 0) {
					transactionManager.commit(txStatus);

					param.put("memberId", param.getString("kMemberId"), false);
					param.put("queryId", "select.select_memberInfo");
					CommonMap memberInfo = commonService.selectOne(param);

					param.put("queryId", "pay.paymentManage.select_cardInfo");
					CommonMap cardInfo = commonService.selectOne(param);	

					param.put("queryId", "pay.paymentManage.select_Gov_Tel");
					CommonMap govTel = commonService.selectOne(param);

					// 알림 메서드
					MsgUtil msg = new MsgUtil();
					CommonMap sendParam = new CommonMap();
					sendParam.put("recvId", item.getString("kMemberId"));
					sendParam.put("recvName", memberInfo.getString("memberName"));
					sendParam.put("recvPhone", memberInfo.getString("memberPhone"));
					sendParam.put("sendPhone", govTel.getString("pGovTel"));
					sendParam.put("tplCode", "T00009");

					sendParam.put("memberName", memberInfo.getString("memberName"));
					sendParam.put("creditNo", cardInfo.getString("creditNo") + "-" + cardInfo.getString("creditNo2") + "-" + cardInfo.getString("creditNo3") + "-" + cardInfo.getString("creditNo4"));
					sendParam.put("creditAlias", cardInfo.getString("creditAlias"));
					sendParam.put("cancelFee", df.format(amt));

					if("Y".equals(memberInfo.getString("kakaoYn"))) {
						msg.doSend(sendParam, "K");
					} else {
						msg.doSend(sendParam, "S");
					}

				}else {
					transactionManager.rollback(txStatus);
					// 결제정보에 빈값이 존재합니다.
					System.out.println("Error_Success_ParkingCharge");
//					return 0;
					return ResultInfo.of("Error_Success_ParkingCharge", 0, null);
				}

			}else {
				// 감면 재결재 취소
				param.put("payGubn", "PG005");

				param.put("queryId", "pay.paymentManage.Select_Pay_Seq");
				CommonMap paySeq = commonService.selectOne(param);
				param.put("paySeq", paySeq.getString("paySeq"));
				param.put("prevSeq", Integer.parseInt(paySeq.getString("paySeq")) -1);

				param.put("queryId", "pay.paymentManage.Select_Reduction_Code");
				CommonMap reductionCode = commonService.selectOne(param);

				if(reductionCode == null) {
//					return -1;
					return ResultInfo.of("해당 주차장에 없는 감면 정보입니다.감면 정보를 등록해 주세요.", -1, null);
				}

				int redutionPrice = (int) (Integer.parseInt(CancelAmt) * (reductionCode.getInt("reductionRate")/(float)100));
				int calPrice = Integer.parseInt(CancelAmt) - redutionPrice;

				param.put("reductionPrice", String.valueOf(redutionPrice));
				param.put("calPrice", String.valueOf(calPrice));
				param.put("queryId", "pay.paymentManage.Update_Parking_Charge");
				int parkingCharge = commonService.update(param);

				int parkingPayCnt = 0;
				if(parkingCharge > 0) {
					param.put("queryId", "pay.paymentManage.Select_Pay_Card");
					CommonMap payCardInfo = commonService.selectOne(param);
					param.put("creditNo", payCardInfo.getString("creditNo"));
					param.put("creditNo2", payCardInfo.getString("creditNo2"));
					param.put("creditNo3", payCardInfo.getString("creditNo3"));
					param.put("creditNo4", payCardInfo.getString("creditNo4"));
					param.put("creditExpDate", payCardInfo.getString("creditExpDate"));
					param.put("memberId", payCardInfo.getString("memberId"), false);

					param.put("queryId", "pay.paymentManage.Select_BillTokenKey");
					CommonMap billTokenKey = commonService.selectOne(param);

					param.put("queryId", "pay.paymentManage.Select_MemberInfo");
					CommonMap memberInfo = commonService.selectOne(param);

					HashMap<String, Object> payResult = new HashMap<String, Object>();

					if(isTest) {
						payResult.put("ResultCode", "3001");
						payResult.put("AppCardName", payCardInfo.getString("creditAlias"));
					} else {
						payResult = this.billPay(MerchantKey, billTokenKey.getString("billtokenkey"), String.valueOf(calPrice), biliiMallid, memberInfo.getString("memberName"), memberInfo.getString("memberPhone"), memberInfo.getString("memberEmail"), "영주시 공영주차장", payInfo.getString("billingMid"));
					}

					if(!"3001".equals(payResult.get("ResultCode"))) {
						transactionManager.rollback(txStatus);
						// 결제정보에 빈값이 존재합니다.
						System.out.println(payResult.get("ResultMsg"));
//						return 0;
						return ResultInfo.of((String) payResult.get("ResultMsg"), 0, null);
					}else {
						param.put("creditAlias",payResult.get("AppCardName").toString());
                        param.put("paymentGubn", member_id.get("paymentGubn"));
						param.put("queryId", "pay.paymentManage.Insert_Parking_Pay");
						parkingPayCnt =commonService.insert(param);
					}
				}

				if(parkingPayCnt > 0) {
					transactionManager.commit(txStatus);
				}else {
					transactionManager.rollback(txStatus);
					// 결제정보에 빈값이 존재합니다.
					System.out.println("Error_Success_Parking_Pay");
//					return 0;
					return ResultInfo.of("Error_Success_Parking_Pay", 0, null);
				}
			}

		} catch (Exception e) {
			transactionManager.rollback(txStatus);
        	logger.warning("==오류 발생==");
        	logger.warning(e.getMessage());
        	return ResultInfo.of("오류가 발생하였습니다.", 0, null);
    	}

//		return 1;
		return ResultInfo.of("정상적으로 처리되었습니다.", 1, null);
	}

	// 거절
	@Transactional
	public int updateCancelData(CommonMap param) throws Exception {
		DecimalFormat df = new DecimalFormat("###,###");

		// t_parking_pay max_seq
		param.put("queryId", "pay.paymentManage.select_maxSeq");
		CommonMap item = commonService.selectOne(param);

		// t_parking_pay max_seq
		param.put("queryId", "pay.paymentManage.select_pay_maxSeq");
		CommonMap item2 = commonService.selectOne(param);

		param.put("paySeq", Integer.parseInt(item.get("paySeq").toString()));
		param.put("prevSeq", Integer.parseInt(item2.get("paySeq").toString()));

		param.put("queryId", "pay.paymentManage.Update_CancelData2");
		commonService.update(param);

		param.put("queryId", "pay.paymentManage.Update_Cancel_ParkingCharge");
		commonService.update(param);

		param.put("memberId", param.getString("kMemberId"), false);
 		param.put("queryId", "select.select_memberInfo");
 		CommonMap memberInfo = commonService.selectOne(param);

		param.put("queryId", "pay.paymentManage.select_cardInfo");
		CommonMap cardInfo = commonService.selectOne(param);

		param.put("queryId", "pay.paymentManage.select_Gov_Tel");
		CommonMap govTel = commonService.selectOne(param);
		
		// 알림 메서드
		MsgUtil msg = new MsgUtil();
		CommonMap sendParam = new CommonMap();
		sendParam.put("recvId", item.getString("kMemberId"));
		sendParam.put("recvName", memberInfo.getString("memberName"));
		sendParam.put("recvPhone", memberInfo.getString("memberPhone"));
		sendParam.put("sendPhone", govTel.getString("pGovTel"));
 		sendParam.put("tplCode", "T00027");
		
		sendParam.put("memberName", memberInfo.getString("memberName"));
		sendParam.put("creditNo", cardInfo.getString("creditNo") + "-" + cardInfo.getString("creditNo2") + "-" + cardInfo.getString("creditNo3") + "-" + cardInfo.getString("creditNo4"));
		sendParam.put("creditAlias", cardInfo.getString("creditAlias"));
		sendParam.put("cancelFee",df.format(Integer.parseInt(param.getString("payPrice").replaceAll("[^0-9]", ""))));
		sendParam.put("reason",param.getString("reqReason").toString() );
 		
 		if("Y".equals(memberInfo.getString("kakaoYn"))) {
 			msg.doSend(sendParam, "K");
 		} else {
 			msg.doSend(sendParam, "S");
 		}

		return 1;
	}

	// 결재
    // BillTokenKey : BillTokenKey
    // Amount : 가격
    // MallUserId : 가맹점 UseId(test_login_userid_20)
    // BuyerName : Member_name
    // BuyerTel : Member_Tel
    // BuyerEmail : 회원 email (현재 DB에 없음_2023.02.02)
    // GoodsName : 상품정보
    public HashMap<String, Object> billPay(String p_merchantKey, String p_encBillTokenKey, String p_Amount, String p_MallUserId, String BuyerName, String BuyerTel, String BuyerEmail, String GoodsName, String BillMid) throws Exception{

    	// 테스트용 요청 URL
    	String url = propertyService.getString("billPayApiUrl");      // 테스트
    	//// 운영용 요청 URL
    	//String url = "https://approval.smartropay.co.kr/payment/approval/ssbbill.do";    // 운영

    	JSONObject body = new JSONObject();
    	JSONObject paramData = new JSONObject();

    	//발급받은 테스트 상점키 설정(Real 전환 시 운영 상점키 설정)
    	String merchantKey = p_merchantKey;
    	//MID (빌링용 MID를 사용해야 함)
    	String Mid = BillMid;
    	// 현재 일시
    	String EdiDate = SmartroPayUtil.getyyyyMMddHHmmss();
    	// 주문번호
    	String Moid = "YEONGJUWPMS_" + EdiDate;
    	// 빌링키 발급을 통해 생성된 키 (암호화 된 키) - DB에서 불러올 것
    	String encBillTokenKey = p_encBillTokenKey;
    	//결제 금액
    	String Amount = p_Amount == null ? "0" : p_Amount;
    	// 로그인 ID
    	String MallUserId = p_MallUserId;

    	HashMap<String, Object> errorMap = new HashMap<>();//new에서 타입 파라미터 생략가능

    	if(encBillTokenKey == null || "".equals(encBillTokenKey)) {
    	    // 이 이후로는 실행하지 않으며, php의 exit 구문과 같은 역할을 한다고 함
    		System.out.println("암호화 빌링키(BillTokenKey)는 필수입니다.");
    		errorMap.put("resultmsg","암호화 빌링키(BillTokenKey)는 필수입니다."); //값 추가
    	    return errorMap;
    	}
    	if(Amount == null || "".equals(Amount)) {
    	    // 이 이후로는 실행하지 않으며, php의 exit 구문과 같은 역할을 한다고 함
    		System.out.println("결제 금액(Amount)은 필수입니다.");
    		errorMap.put("resultmsg","결제 금액(Amount)은 필수입니다."); //값 추가
    	    return errorMap;
    	}
    	if(MallUserId == null || "".equals(MallUserId)) {
    	    // 이 이후로는 실행하지 않으며, php의 exit 구문과 같은 역할을 한다고 함
    		System.out.println("사용자 ID(MallUserId)는 필수입니다.");
    		errorMap.put("resultmsg","사용자 ID(MallUserId)는 필수입니다."); //값 추가
    	    return errorMap;
    	}


    	// 빌링키 발급을 통해 생성된 키 (복호화)
    	String BillTokenKey = SmartroPayUtil.AESDecode(encBillTokenKey, merchantKey.substring(0, 32));
    	// 결제 금액
    	int amount = Integer.parseInt(Amount, 10);
    	// VAT 계산
    	HashMap<String, Integer> moneyData = SmartroPayUtil.calVat(amount);

    	// VAT 제외 금액 (결제금액 / 1.1)
    	int taxAmount = moneyData.get("tax");
    	// VAT 금액
    	int vatAmount = moneyData.get("vat");

    	//검증값 SHA256 암호화(빌링키 + Mid + 결제금액)
    	String VerifyValue = SmartroPayUtil.encodeSHA256Base64(BillTokenKey + Mid + Amount);

    	// 서버 IP
    	String mallIp = "127.0.0.1";
    	// 사용자 IP
    	String userIp = "127.0.0.1";

    	//요청 파라미터 (각 값들은 가맹점 환경에 맞추어 설정해 주세요.)
    	paramData.put("UserIp" , mallIp);
    	paramData.put("MallIp" , userIp);
    	paramData.put("Mid" ,Mid);
    	paramData.put("BillTokenKey" ,BillTokenKey);
    	paramData.put("Moid" ,Moid);
    	paramData.put("EdiDate" ,EdiDate);
    	paramData.put("BuyerName" , BuyerName); // 구매자명
    	paramData.put("BuyerTel" ,BuyerTel); // 구매자 연락처 ("-" 제외)
    	paramData.put("BuyerEmail" ,BuyerEmail); // 구매자 이메일
    	paramData.put("CardQuota" ,"00"); // 할부 개월 (일시불="00")
    	paramData.put("CardPoint" ,"0"); // 카드의 포인트 사용 여부(0=미사용)
    	paramData.put("GoodsCnt" ,"1"); // 상품 개수 (인터넷 결제는 1로 고정)
    	paramData.put("GoodsName" ,GoodsName); // 상품명 (화면에 표시됨)
    	paramData.put("Amt" , Amount); // 결제되는 금액
    	paramData.put("SvcAmt" , "0"); // 문서에 어떤 값인지 명시 안됨...
    	paramData.put("VatAmt" , String.valueOf(vatAmount)); // VAT 금액
    	paramData.put("TaxAmt" , String.valueOf(taxAmount)); // VAT 제외 금액
    	paramData.put("TaxFreeAmt" , "0"); // 비과세
    	paramData.put("MallUserId" ,MallUserId); // 로그인 사용자 ID
    	paramData.put("VerifyValue", VerifyValue); // 위/변조 검증 키

    	//json 데이터 AES256 암호화
    	try {
    	    body.put("EncData", SmartroPayUtil.AES_Encode(paramData.toString(), merchantKey.substring(0,32)));
    	    body.put("Mid", Mid);
    	} catch(Exception e){
    	    e.printStackTrace();
    	}

    	// 전송 후 결과 수신
    	// kr.co.wnpsoft.common.util 패키지의 SmartroPayUtil 참조
    	// 데이터를 통해 바로 결제를 요청함 (별도의 사용자 입력 필요 없음)
    	HashMap<String, Object> result = SmartroPayUtil.callApi(body, url);

		return result;
    }

    // 재결제 요청 승인
 	@Transactional
 	public int updateSuccessRepay(CommonMap param) throws Exception {

 		Logger logger = Logger.getLogger("mylogger");
     	DefaultTransactionDefinition txDefinition = new DefaultTransactionDefinition();
     	txDefinition.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRED);
  		TransactionStatus txStatus = transactionManager.getTransaction(txDefinition);

 		String url = propertyService.getString("payCancelApiUrl");       // 테스트
		boolean isTest = propertyService.getBoolean("payTest");		 // 테스트 여부
 		//String url = "https://approval.smartropay.co.kr/payment/approval/cancel.do";     // 운영

 		JSONObject body = new JSONObject();
 		JSONObject paramData = new JSONObject();
 		EncUtil enc = new EncUtil();
		DecimalFormat df = new DecimalFormat("###,###");
		String payGubnStr = "";

 		param.put("queryId", "pay.repaymentManage.Select_payInfo");
 		CommonMap payInfo = commonService.selectOne(param);
 		
 		// t_parking_pay_cancel max_seq
		param.put("queryId", "pay.repaymentManage.select_maxSeq");
		CommonMap item = commonService.selectOne(param);

		// t_parking_pay max_seq
		param.put("queryId", "pay.paymentManage.select_pay_maxSeq");
		CommonMap item2 = commonService.selectOne(param);

		param.put("paySeq", Integer.parseInt(item.get("paySeq").toString()));
		param.put("prevSeq", Integer.parseInt(item2.get("paySeq").toString()));
 			
 		try {
 			if(payInfo == null) {
 				// 결제정보 없음
 				System.out.println("Mid는 필수입니다.");
 			    return -3;
 			}

 			if("".equals(payInfo.getString("onceMid")) || "".equals(payInfo.getString("onceMidPw")) || "".equals(payInfo.getString("billingMid"))) {
 				// 결제정보에 빈값이 존재합니다.
 				System.out.println("결제정보에 빈값이 존재합니다.");
 			    return -4;
 			}

 			//MID (일회용 결제를 취소하려면 일반용 MID를, 빌링 결제를 취소하려면 빌링용 MID를 사용해야 함)
 			String Mid = payInfo.getString("billingMid");

 			//가맹점 키(상점키)
 			String MerchantKey = payInfo.getString("merchantKey");            // 발급받은 테스트 상점키 설정(Real 전환 시 운영 상점키 설정)
 			String CancelPwd = payInfo.getString("onceMidPw"); // 가맹점 관리자에서 설정한 취소 비밀번호

 			String Tid = param.getString("tId").toString(); //"t_2301101m01012301281347442061";            // 취소 요청할 Tid 입력***
 			String CancelAmt = param.getString("hPrice").toString();  // 취소할 거래금액

 			if(Tid == null || "".equals(Tid)) {
 			    // 이 이후로는 실행하지 않으며, php의 exit 구문과 같은 역할을 한다고 함
 				System.out.println("TID(Tid)는 필수입니다.");
 			    return -1;
 			}
 			if(CancelAmt == null || "".equals(CancelAmt)) {
 			    // 이 이후로는 실행하지 않으며, php의 exit 구문과 같은 역할을 한다고 함
 				System.out.println("취소 금액(CancelAmt)은 필수입니다.");
 			    return -2;
 			}

 			param.put("queryId", "pay.repaymentManage.Select_PayGubn");
 			CommonMap payGubn = commonService.selectOne(param);

// 			//부가세를 Java로 계산하여 세팅해 줌
// 			//결제금액을 숫자로 변환
 			int amt = Integer.parseInt(CancelAmt, 10);
 			//부가세 계산하여 Hashmap으로 리턴해 줌
 			//비과세 금액은 0으로 계산했지만, 필요한 경우에 0 대신 다른 금액을 넣으면 계산하여 처리함
 			//(totalAmt=총 결제금액, taxFreeAmt=비과세금액, vat=VAT금액, tax=과세금액)
 			HashMap<String, Integer> moneyData = SmartroPayUtil.calVat(amt, 0);

 			String CancelSeq = "1";     // 취소차수(기본값: 1, 부분취소 시마다 차수가 1씩 늘어남. 첫번째 부분취소=1, 두번째 부분취소=2, ...)
 			String PartialCancelCode = "0";     // 0: 전체취소, 1: 부분취소
 			//검증값 SHA256 암호화(Tid + MerchantKey + CancelAmt + PartialCancelCode)
 			String HashData = SmartroPayUtil.encodeSHA256Base64(Tid + MerchantKey + CancelAmt + PartialCancelCode);

 			//취소 요청 파라미터 셋팅
 			paramData.put("SERVICE_MODE", "CL1");
 			paramData.put("Tid", Tid);
 			paramData.put("Mid", Mid);
 			paramData.put("CancelAmt", CancelAmt);
 			paramData.put("CancelPwd", CancelPwd);
 			paramData.put("CancelMsg", param.getString("cancelReason").toString()); // 취소 메시지
 			paramData.put("CancelSeq", CancelSeq);
 			paramData.put("PartialCancelCode", PartialCancelCode);

 			//과세, 비과세, 부가세 셋팅(부가세 직접 계산 가맹점의 경우 각 값을 계산하여 설정해야 합니다.)
 			paramData.put("CancelTaxAmt", String.valueOf(moneyData.get("tax")));
 			paramData.put("CancelTaxFreeAmt", String.valueOf(moneyData.get("taxFreeAmt")));
 			paramData.put("CancelVatAmt", String.valueOf(moneyData.get("vat")));

 			//서브몰 사용 가맹점의 경우, DivideInfo 파라미터를 가맹점에 맞게 설정해 주세요. (일반연동 참고)
 			paramData.put("DivideInfo", "");

 			//HASH 설정 (필수)
 			paramData.put("HashData", HashData);


 			//json 데이터 AES256 암호화
 			try {
 			    // AES_Encode 암호화 함수 - 기타연동 메뉴 참조
 			    body.put("EncData", SmartroPayUtil.AES_Encode(paramData.toString(), MerchantKey.substring(0,32)));
 			    body.put("Mid", Mid);
 			} catch(Exception e){
 			    e.printStackTrace();
 			}

 			HashMap<String, Object> result = new HashMap<String, Object>();
 			
 			if(isTest) {
 			   result.put("ResultCode", "2001");
 			} else {
 			   result = SmartroPayUtil.callApi(body, url);
 			}

 			if(!"2001".equals(result.get("ResultCode"))){
 				transactionManager.rollback(txStatus);
 				// 결제 취소 에러.
 				System.out.println(result.get("ResultMsg"));
 				return 0;
 			}
 			
 			if("U".equals(param.getString("repayType"))) {
				payGubnStr = payGubn.getString("payGubn");				
			}else {
				payGubnStr = "PG004";
			}

 			if("PG004".equals(payGubnStr)) {
 				// 재결제 요청
 				param.put("payGubn", "PG005");

 				param.put("queryId", "pay.repaymentManage.Insert_SuccessData");
 				int cnt = commonService.update(param);

 				param.put("queryId", "pay.repaymentManage.Update_SuccessData2");
 				cnt += commonService.update(param);


 				int parkingChargeCnt = 0;
 				if(cnt > 0) {
 					String newChargeNo = FunctionUtils.fnMakeKey("CH");
                    param.put("chargeNo", newChargeNo);

 					param.put("queryId", "pay.repaymentManage.Update_Success_ParkingCharge");
 					parkingChargeCnt = commonService.update(param);

 	 				param.put("queryId", "pay.repaymentManage.Insert_newPayCharge");
 	 				commonService.insert(param);
					
					// 미납건 발생 업데이트
					param.put("queryId", "pay.repaymentManage.Update_MemberUnpaid");
					commonService.update(param);
				}else {
 					transactionManager.rollback(txStatus);
 					// 결제정보에 빈값이 존재합니다.
 					System.out.println("Error_SuccessData");
 					return 0;
 				}

 				if(parkingChargeCnt > 0) {
 					transactionManager.commit(txStatus);

 					param.put("memberId", param.getString("kMemberId"), false);
 					param.put("queryId", "select.select_memberInfo");
 					CommonMap memberInfo = commonService.selectOne(param);
 					
 					param.put("queryId", "pay.paymentManage.select_cardInfo");
					CommonMap cardInfo = commonService.selectOne(param);

					param.put("queryId", "pay.paymentManage.select_Gov_Tel");
					CommonMap govTel = commonService.selectOne(param);

					// 알림 메서드
					MsgUtil msg = new MsgUtil();
					CommonMap sendParam = new CommonMap();
					sendParam.put("recvId", item.getString("kMemberId"));
					sendParam.put("recvName", memberInfo.getString("memberName"));
					sendParam.put("recvPhone", memberInfo.getString("memberPhone"));
					sendParam.put("memberName", memberInfo.getString("memberName"));
					sendParam.put("sendPhone", govTel.getString("pGovTel"));
					sendParam.put("cancelCreditNo", cardInfo.getString("creditNo") + "-" + cardInfo.getString("creditNo2") + "-" + cardInfo.getString("creditNo3") + "-" + cardInfo.getString("creditNo4"));
					sendParam.put("cancelCreditAlias", cardInfo.getString("creditAlias"));
					sendParam.put("cancelFee", df.format(amt));
					sendParam.put("parkingFee", df.format(Integer.parseInt(param.getString("newPay").replaceAll("[^0-9]", ""))));
 					sendParam.put("tplCode", "T00028");

 					if("Y".equals(memberInfo.getString("kakaoYn"))) {
 						msg.doSend(sendParam, "K");
 					} else {
 						msg.doSend(sendParam, "S");
 					}

 				}else {
 					transactionManager.rollback(txStatus);
 					// 결제정보에 빈값이 존재합니다.
 					System.out.println("Error_Success_ParkingCharge");
 					return 0;
 				}

 			}

 		} catch (Exception e) {
 			transactionManager.rollback(txStatus);
         	logger.warning("==오류 발생==");
         	logger.warning(e.getMessage());
     	}

 		return 1;
 	}
 	
    // 재결제 요청 승인(미납결제)
  	@Transactional
  	public int updateSuccessOutstanding(CommonMap param) throws Exception {

  		Logger logger = Logger.getLogger("mylogger");
      	DefaultTransactionDefinition txDefinition = new DefaultTransactionDefinition();
      	txDefinition.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRED);
   		TransactionStatus txStatus = transactionManager.getTransaction(txDefinition);

  		String url = propertyService.getString("payCancelApiUrl");       // 테스트
  		//String url = "https://approval.smartropay.co.kr/payment/approval/cancel.do";     // 운영
        boolean isTest = propertyService.getBoolean("payTest");        // 테스트 여부

  		JSONObject body = new JSONObject();
  		JSONObject paramData = new JSONObject();
  		EncUtil enc = new EncUtil();
 		DecimalFormat df = new DecimalFormat("###,###");
 		String payGubnStr = "";
 		HashMap<String, Object> result = null;
 		
  		param.put("queryId", "pay.repaymentManage.Select_payInfo2");
  		CommonMap payInfo = commonService.selectOne(param);
  		
  		// t_parking_pay_cancel max_seq
 		param.put("queryId", "pay.repaymentManage.select_maxSeq");
 		CommonMap item = commonService.selectOne(param);

 		// t_parking_pay max_seq
 		param.put("queryId", "pay.paymentManage.select_pay_maxSeq");
 		CommonMap item2 = commonService.selectOne(param);

 		param.put("paySeq", Integer.parseInt(item.get("paySeq").toString()));
 		param.put("prevSeq", Integer.parseInt(item2.get("paySeq").toString()));
  			
  		try {
  			if(payInfo == null) {
  				// 결제정보 없음
  				System.out.println("Mid는 필수입니다.");
  			    return -3;
  			}

  			if("".equals(payInfo.getString("onceMid")) || "".equals(payInfo.getString("onceMidPw")) || "".equals(payInfo.getString("billingMid"))) {
  				// 결제정보에 빈값이 존재합니다.
  				System.out.println("결제정보에 빈값이 존재합니다.");
  			    return -4;
  			}
			List<CommonMap> list = param.getList("list");
		
  			int sumPrice = 0;
  			int sumNewpay = 0;
  			
  			for(int idx=0; idx < list.size(); idx++) {
  				CommonMap grdItem = list.get(idx);
  				
  				sumPrice += grdItem.getInt("grdParkingPrice");
  				sumNewpay += grdItem.getInt("grdNewParkingPrice");
  				
  			}
  			
  			param.put("newPay", Integer.toString(sumNewpay));
  			param.put("hPrice", sumPrice);
  			//MID (일회용 결제를 취소하려면 일반용 MID를, 빌링 결제를 취소하려면 빌링용 MID를 사용해야 함)
  			String Mid = payInfo.getString("billingMid");

  			//가맹점 키(상점키)
  			String MerchantKey = payInfo.getString("merchantKey");            // 발급받은 테스트 상점키 설정(Real 전환 시 운영 상점키 설정)
  			String CancelPwd = payInfo.getString("onceMidPw"); // 가맹점 관리자에서 설정한 취소 비밀번호

  			String Tid = param.getString("tId").toString(); //"t_2301101m01012301281347442061";            // 취소 요청할 Tid 입력***
  			String CancelAmt = param.getString("hPrice").toString();  // 취소할 거래금액

  			if(Tid == null || "".equals(Tid)) {
  			    // 이 이후로는 실행하지 않으며, php의 exit 구문과 같은 역할을 한다고 함
  				System.out.println("TID(Tid)는 필수입니다.");
  			    return -1;
  			}
  			if(CancelAmt == null || "".equals(CancelAmt)) {
  			    // 이 이후로는 실행하지 않으며, php의 exit 구문과 같은 역할을 한다고 함
  				System.out.println("취소 금액(CancelAmt)은 필수입니다.");
  			    return -2;
  			}
  			
  			param.put("queryId", "pay.repaymentManage.Select_PayGubn");
  			CommonMap payGubn = commonService.selectOne(param);
  			
  			//부가세를 Java로 계산하여 세팅해 줌
  			//결제금액을 숫자로 변환
  			int amt = Integer.parseInt(CancelAmt, 10);
  			//부가세 계산하여 Hashmap으로 리턴해 줌
  			//비과세 금액은 0으로 계산했지만, 필요한 경우에 0 대신 다른 금액을 넣으면 계산하여 처리함
  			//(totalAmt=총 결제금액, taxFreeAmt=비과세금액, vat=VAT금액, tax=과세금액)
  			HashMap<String, Integer> moneyData = SmartroPayUtil.calVat(amt, 0);

  			String CancelSeq = "1";     // 취소차수(기본값: 1, 부분취소 시마다 차수가 1씩 늘어남. 첫번째 부분취소=1, 두번째 부분취소=2, ...)
  			String PartialCancelCode = "0";     // 0: 전체취소, 1: 부분취소
  			//검증값 SHA256 암호화(Tid + MerchantKey + CancelAmt + PartialCancelCode)
  			String HashData = SmartroPayUtil.encodeSHA256Base64(Tid + MerchantKey + CancelAmt + PartialCancelCode);

  			//취소 요청 파라미터 셋팅
  			paramData.put("SERVICE_MODE", "CL1");
  			paramData.put("Tid", Tid);
  			paramData.put("Mid", Mid);
  			paramData.put("CancelAmt", CancelAmt);
  			paramData.put("CancelPwd", CancelPwd);
  			paramData.put("CancelMsg", param.getString("cancelReason").toString()); // 취소 메시지
  			paramData.put("CancelSeq", CancelSeq);
  			paramData.put("PartialCancelCode", PartialCancelCode);

  			//과세, 비과세, 부가세 셋팅(부가세 직접 계산 가맹점의 경우 각 값을 계산하여 설정해야 합니다.)
  			paramData.put("CancelTaxAmt", String.valueOf(moneyData.get("tax")));
  			paramData.put("CancelTaxFreeAmt", String.valueOf(moneyData.get("taxFreeAmt")));
  			paramData.put("CancelVatAmt", String.valueOf(moneyData.get("vat")));

  			//서브몰 사용 가맹점의 경우, DivideInfo 파라미터를 가맹점에 맞게 설정해 주세요. (일반연동 참고)
  			paramData.put("DivideInfo", "");

  			//HASH 설정 (필수)
  			paramData.put("HashData", HashData);


  			//json 데이터 AES256 암호화
  			try {
  			    // AES_Encode 암호화 함수 - 기타연동 메뉴 참조
  			    body.put("EncData", SmartroPayUtil.AES_Encode(paramData.toString(), MerchantKey.substring(0,32)));
  			    body.put("Mid", Mid);
  			} catch(Exception e){
  			    e.printStackTrace();
  			}

  			if(isTest) {
			    result = new HashMap<String, Object>();
			    result.put("ResultCode", "2001");
  			} else {
			    result = SmartroPayUtil.callApi(body, url);
  			}
  			

  			if(!"2001".equals(result.get("ResultCode"))){
  				transactionManager.rollback(txStatus);
  				// 결제 취소 에러.
  				System.out.println(result.get("ResultMsg"));
  				return 0;
  			}
  			
  			if("U".equals(param.getString("repayType"))) {
 				payGubnStr = payGubn.getString("payGubn");				
 			}else {
 				payGubnStr = "PG004";
 			}

  			if("PG004".equals(payGubnStr)) {
  				// 재결제 요청
  				param.put("payGubn", "PG005");

  				param.put("queryId", "pay.repaymentManage.Insert_SuccessData");
  				int cnt = commonService.update(param);

  				param.put("queryId", "pay.repaymentManage.Update_SuccessData2");
  				cnt += commonService.update(param);


  				int parkingChargeCnt = 0;
  				String govChargeNo = "";
  				if(cnt > 0) {  					
  					
  					for(int idx=0; idx < list.size(); idx++) {
  		  				CommonMap grdItem = list.get(idx);
  		  				
  		  				if(idx == 0) {
  		  					govChargeNo = grdItem.getString("grdChargeNo");
  		  				}
  		  				
			  			String newChargeNo = FunctionUtils.fnMakeKey("CH");
			  			grdItem.put("chargeNo", newChargeNo);
			  			grdItem.put("payGubn", "PG005");
			  			
			  			grdItem.put("queryId", "pay.repaymentManage.Update_Success_ParkingCharge_out");
	  					parkingChargeCnt = commonService.update(grdItem);
	  					
  		  				grdItem.put("queryId", "pay.repaymentManage.Insert_newPayCharge_out");
	  	 				commonService.insert(grdItem);
  					}
 					
 					// 미납건 발생 업데이트
 					param.put("queryId", "pay.repaymentManage.Update_MemberUnpaid");
 					commonService.update(param);
 				}else {
  					transactionManager.rollback(txStatus);
  					// 결제정보에 빈값이 존재합니다.
  					System.out.println("Error_SuccessData");
  					return 0;
  				}

  				if(parkingChargeCnt > 0) {
  					transactionManager.commit(txStatus);

  					param.put("memberId", param.getString("kMemberId"), false);
  					param.put("queryId", "select.select_memberInfo");
  					CommonMap memberInfo = commonService.selectOne(param);
  					
  					param.put("queryId", "pay.paymentManage.select_cardInfo");
 					CommonMap cardInfo = commonService.selectOne(param);
 					
 					param.put("govChargeNo", govChargeNo);
 					param.put("queryId", "pay.paymentManage.select_Gov_Tel_Out");
 					CommonMap govTel = commonService.selectOne(param);

 					// 알림 메서드
 					MsgUtil msg = new MsgUtil();
 					CommonMap sendParam = new CommonMap();
 					sendParam.put("recvId", item.getString("kMemberId"));
 					sendParam.put("recvName", memberInfo.getString("memberName"));
 					sendParam.put("recvPhone", memberInfo.getString("memberPhone"));
 					sendParam.put("memberName", memberInfo.getString("memberName"));
 					sendParam.put("sendPhone", govTel.getString("pGovTel"));
 					sendParam.put("cancelCreditNo", cardInfo.getString("creditNo") + "-" + cardInfo.getString("creditNo2") + "-" + cardInfo.getString("creditNo3") + "-" + cardInfo.getString("creditNo4"));
 					sendParam.put("cancelCreditAlias", cardInfo.getString("creditAlias"));
 					sendParam.put("cancelFee", df.format(amt));
 					sendParam.put("parkingFee", df.format(Integer.parseInt(param.getString("newPay").replaceAll("[^0-9]", ""))));
  					sendParam.put("tplCode", "T00028");

  					if("Y".equals(memberInfo.getString("kakaoYn"))) {
  						msg.doSend(sendParam, "K");
  					} else {
  						msg.doSend(sendParam, "S");
  					}

  				}else {
  					transactionManager.rollback(txStatus);
  					// 결제정보에 빈값이 존재합니다.
  					System.out.println("Error_Success_ParkingCharge");
  					return 0;
  				}

  			}

  		} catch (Exception e) {
  			transactionManager.rollback(txStatus);
          	logger.warning("==오류 발생==");
          	logger.warning(e.getMessage());
      	}

  		return 1;
  	}
  	
 	// 거절
 	@Transactional
 	public int updateCancelRepay(CommonMap param) throws Exception {
		DecimalFormat df = new DecimalFormat("###,###");

 		// t_parking_pay max_seq
		param.put("queryId", "pay.repaymentManage.select_maxSeq");
		CommonMap item = commonService.selectOne(param);

		// t_parking_pay max_seq
		param.put("queryId", "pay.repaymentManage.select_pay_maxSeq");
		CommonMap item2 = commonService.selectOne(param);

		param.put("paySeq", Integer.parseInt(item.get("paySeq").toString()));
		param.put("prevSeq", Integer.parseInt(item2.get("paySeq").toString()));
 			
 		param.put("queryId", "pay.repaymentManage.Update_CancelData2");
 		commonService.update(param);

 		param.put("queryId", "pay.repaymentManage.Update_Cancel_ParkingCharge");
 		commonService.update(param);

		param.put("memberId", param.getString("kMemberId"), false);
 		param.put("queryId", "select.select_memberInfo");
 		CommonMap memberInfo = commonService.selectOne(param);

		param.put("queryId", "pay.paymentManage.select_cardInfo");
		CommonMap cardInfo = commonService.selectOne(param);
		
		String[] splitChargeNo = param.getString("kChargeNo").split(",");
		if(splitChargeNo.length > 0) {
			param.put("kChargeNo", splitChargeNo[0].replaceAll("'",""));
		}
		param.put("queryId", "pay.paymentManage.select_Gov_Tel");
		CommonMap govTel = commonService.selectOne(param);
			
		// 알림 메서드
		MsgUtil msg = new MsgUtil();
		CommonMap sendParam = new CommonMap();
		sendParam.put("recvId", item.getString("kMemberId"));
		sendParam.put("recvName", memberInfo.getString("memberName"));
		sendParam.put("recvPhone", memberInfo.getString("memberPhone"));	
		sendParam.put("sendPhone", govTel.getString("pGovTel"));
 		sendParam.put("tplCode", "T00029");
		
		sendParam.put("memberName", memberInfo.getString("memberName"));
		sendParam.put("creditNo", cardInfo.getString("creditNo") + "-" + cardInfo.getString("creditNo2") + "-" + cardInfo.getString("creditNo3") + "-" + cardInfo.getString("creditNo4"));
		sendParam.put("creditAlias", cardInfo.getString("creditAlias"));
		sendParam.put("dispFee",df.format(Integer.parseInt(param.getString("payPrice").replaceAll("[^0-9]", ""))));
		sendParam.put("reason",param.getString("reqReason").toString() );
 		
 		if("Y".equals(memberInfo.getString("kakaoYn"))) {
 			msg.doSend(sendParam, "K");
 		} else {
 			msg.doSend(sendParam, "S");
 		}

 		return 1;
 	}

 	// 미납결제 납부처리
  	@Transactional
  	public int unpaidPayment(CommonMap param) throws Exception {
 		DecimalFormat df = new DecimalFormat("###,###");

 		int successCnt = 0;

		param.put("payCode", CommonUtil.fnMakeKey("PAY"));
		param.put("queryId", "pay.unpaidCarManage.Update_ParkingCharge");
		successCnt += commonService.update(param);

		param.put("queryId", "pay.unpaidCarManage.Insert_ParkingPay");
		successCnt += commonService.insert(param);

		param.put("queryId", "pay.unpaidCarManage.Select_MemberUnpaid");
		CommonMap paidResult = commonService.selectOne(param);
		
		if(paidResult.getInt("paidCnt") < 1) {	
			param.put("queryId", "pay.unpaidCarManage.Update_MemberUnpaid");
			successCnt += commonService.update(param);
		}
		
  		return 1;
  	}
  	
  	// 전기차 충전 할인 내역 승인/거절
   	@Transactional
   	public int elecReductionUpdate(CommonMap param) throws Exception {
  		int successCnt = 0;
  		EncUtil enc = new EncUtil();

  		try {
  			String type = param.getString("type");
  			String confirmGubn = "";
  			// type 으로 승인/거절 로직 분리
  			
  			if(type.equals("Approval")) {		// 1. 승인
  				confirmGubn = "Y";
  				
  			} else if(type.equals("Refusal")) {	// 2. 거절
  				confirmGubn = "C";
  			}
  			
  			param.put("confirmGubn", confirmGubn);
  			param.put("memberId", enc.encrypt(param.getString("hMemberId")), false);
  			param.put("userId", enc.encrypt(param.getString("userId")), false);
  			param.put("queryId", "pay.elecReduction.update_elecReduction");
			successCnt += commonService.update(param);
  			
  		} catch(NotFoundException e) {
			successCnt = 0;
			e.printStackTrace();
		} catch (Exception e) {
			successCnt = 0;
			e.printStackTrace();
		}
   		return successCnt;
   	}
  	
 	// 전기차 충전 할인 내역 취소
  	@Transactional
  	public int elecReductionCancel(CommonMap param) throws Exception {

 		int successCnt = 0;
 		EncUtil enc = new EncUtil();
 		
 		param.put("memberId", enc.encrypt(param.getString("hMemberId")), false);
 		param.put("userId", enc.encrypt(param.getString("userId")), false);
		param.put("queryId", "pay.cancelElecReduction.Update_elecReductionCancel");
		successCnt += commonService.update(param);

  		return successCnt;
  	}
  	
 	// 미납 생성
  	@Transactional
  	public int unpaidCreate(CommonMap param) throws Exception {

 		int successCnt = 0;
 		EncUtil enc = new EncUtil();

		param.put("newChargeNo", CommonUtil.fnMakeKey("CH"));
		param.put("memberId", enc.encrypt(param.getString("memberId")), false);
		param.put("userId", enc.encrypt(param.getString("userId")), false);
		param.put("queryId", "pay.unpaidCarManage.Insert_unpaidCreate");
		successCnt += commonService.insert(param);
		
  		return successCnt;
  	}
}
