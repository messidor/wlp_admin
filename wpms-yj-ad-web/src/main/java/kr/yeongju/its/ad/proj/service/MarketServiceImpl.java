package kr.yeongju.its.ad.proj.service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Random;

import javax.annotation.Resource;

import org.json.simple.JSONObject;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import egovframework.rte.fdl.property.EgovPropertyService;
import kr.yeongju.its.ad.common.dto.CommonMap;
import kr.yeongju.its.ad.common.util.CommonUtil;
import kr.yeongju.its.ad.common.util.EncUtil;
import kr.yeongju.its.ad.common.util.MsgUtil;
import kr.yeongju.its.ad.common.util.SmartroPayUtil;
import kr.yeongju.its.ad.core.service.CommonService;

@Service("marketService")
public class MarketServiceImpl implements MarketService {

	@Resource(name = "commonService")
	private CommonService commonService;
	
	@Resource(name="propertyService")
    protected EgovPropertyService propertyService;

	@Transactional
	public int parkingCouponSave(CommonMap param) throws Exception {
		int result = 0;
		
		List<CommonMap> list = param.getList("list");

		for(int idx=0; idx < list.size(); idx++) {
			CommonMap item = list.get(idx);
			String stateCol = item.getString("grdStateCol");
			
			try {
				switch (stateCol) {
					case "C" :
						item.put("queryId", "market.parkingCouponManage.insert_parkingCouponInfo");
						result += commonService.insert(item);
						break;
					case "U" :        	
						item.put("queryId", "market.parkingCouponManage.update_parkingCouponInfo");
						result += commonService.update(item);
						break;
					case "D" :
						item.put("queryId", "market.parkingCouponManage.delete_parkingCouponInfo");
						result += commonService.delete(item);
						break;
					default :;
				}
			} catch (Exception e) {
	    		result = 0;    	    		
	    		e.printStackTrace();
	    	}
				
		}
		
		return result;
	}
	
	// 할인권 환불 승인
	@Transactional
	public int couponRefundConfirm(CommonMap param) throws Exception {
		int result = 0;
		try {
		    boolean isTest = param.getBoolean("isPayTest");       // 테스트 여부
		    String cancelUrl = param.getString("cancelUrl");
		    
		    String cancelResultCode = "";
		    
		    param.put("queryId", "market.couponRefundManage.select_PayCancelInformation");
		    List<CommonMap> payInfoList = commonService.select(param);
		    
		    if(payInfoList.size() < 1) {
		        cancelResultCode = "";
		    } else {
		        CommonMap payInfo = payInfoList.get(0);
	            // TID, MID, 취소 비밀번호, 취소 총 금액 -> DB조회
	            // --> PUBLISH_CODE, COUPON_CODE, PARKING_NO, COUPON_AREA_CODE, COUPON_MEMBER_ID
	            //    (hPublishCode hCouponCode hParkingNo hCouponAreaCode hCouponMemberId 가 조건)
	            
	            // 취소 메시지 (이유) - 파라미터값 (rejectReason)
	            // 과세, 비과세, 부가세 - SmartroPayUtil.calVat 함수 계산결과 필요
	            // SERVICE_MODE(CL1), CancelSeq(1), PartialCancelCode(0), DivideInfo(빈값) -> 고정값
	            // HashData -> 파라미터를 담고 있는 변수
		        
		        String cancelAmt = payInfo.getString("purchasePrice");  // 결제금액
                String tId = payInfo.getString("tId");                  // T_ID
                String merchantKey = payInfo.getString("onceMerchantKey");  // 상점 키
                String mid = payInfo.getString("onceMid");              // MID
                String cancelPwd = payInfo.getString("onceMidPw");      // 취소 비밀번호
		        // DB에서 가져온 결제금액을 숫자형태로 변환함
		        int amt = CommonUtil.toInt(cancelAmt);
		        
		        // 고정값
		        String partialCancelCode = "0";   // 0=전체취소, 1=부분취소
		        String cancelSeq = "1";           // 취소 순서 (1부터)
		        
		        if("0".equals(cancelAmt)) {
		            // 금액이 0원이면 실제 결제 취소를 할 필요가 없음
		            // 결제 결과는 정상으로 간주하고 진행
		            cancelResultCode = "2001";
		        } else {
    	            //부가세 계산하여 Hashmap으로 리턴해 줌
    	            //비과세 금액은 0으로 계산했지만, 필요한 경우에 0 대신 다른 금액을 넣으면 계산하여 처리함
    	            //(totalAmt=총 결제금액, taxFreeAmt=비과세금액, vat=VAT금액, tax=과세금액)
    	            HashMap<String, Integer> moneyData = SmartroPayUtil.calVat(amt, 0);
    	            
    	            // 검증값 SHA256 암호화 (거래ID + 상점키 + 취소금액 + (전체취소(0) / 부분취소(1) 구분)
    	            String HashData = SmartroPayUtil.encodeSHA256Base64(tId + merchantKey + cancelAmt + partialCancelCode);
    	            
    	            JSONObject paramData = new JSONObject(); // 파라미터용 변수
    	            JSONObject body = new JSONObject();      // 전송용 파라미터변수 (파라미터용 변수값이 문자열화되어 이 변수에 추가됨)
    	            
    	            paramData.put("SERVICE_MODE", "CL1");  // 고정값
    	            paramData.put("Tid", tId);
    	            paramData.put("Mid", mid);
    	            paramData.put("CancelAmt", cancelAmt);
    	            paramData.put("CancelPwd", cancelPwd);
    	            paramData.put("CancelMsg", param.getString("rejectReason")); // 취소 메시지
    	            paramData.put("CancelSeq", cancelSeq); // 취소 순서 (부분취소시 사용)
    	            paramData.put("PartialCancelCode", partialCancelCode);
    
    	            //과세, 비과세, 부가세 셋팅(부가세 직접 계산 가맹점의 경우 각 값을 계산하여 설정해야 합니다.)
    	            paramData.put("CancelTaxAmt", String.valueOf(moneyData.get("tax")));
    	            paramData.put("CancelTaxFreeAmt", String.valueOf(moneyData.get("taxFreeAmt")));
    	            paramData.put("CancelVatAmt", String.valueOf(moneyData.get("vat")));
    
    	            // 빈 값 처리
    	            paramData.put("DivideInfo", "");
    
    	            //HASH 설정 (필수)
    	            paramData.put("HashData", HashData);
    	            
    	            //json 데이터 AES256 암호화
    	            try {
    	                // AES_Encode 암호화 함수 - 기타연동 메뉴 참조
    	                body.put("EncData", SmartroPayUtil.AES_Encode(paramData.toString(), merchantKey.substring(0,32)));
    	                body.put("Mid", mid);
    	            } catch(Exception e){
    	                e.printStackTrace();
    	            }
    	            
    	            HashMap<String, Object> payResult = new HashMap<String, Object>();
    	            
    	            System.out.println("Params : " + tId + merchantKey + cancelAmt + partialCancelCode);

    	            if(isTest) {
    	                payResult.put("ResultCode", "2001");
    	                cancelResultCode = "2001";
    	            } else {
    	                payResult = SmartroPayUtil.callApi(body, cancelUrl);
    	                cancelResultCode = payResult.get("ResultCode").toString();
    	            }
		        }
		    }
		    
		    if("2001".equals(cancelResultCode)) {
		    
    			// COUPON_PC_GUBN : 결제구분(P:결제, R:환불요청, C:환불완료)
    			param.put("pcGubn", "C");
    			param.put("queryId", "market.couponRefundManage.update_couponPurchase");
    			result += commonService.update(param);
    			
    			// CONFIRM_YN : 승인여부
    			param.put("confirmYn", "Y");
    			param.put("queryId", "market.couponRefundManage.update_appCouponRefund");
    			result += commonService.update(param);
		    } else {
		        result = 0;
		    }

		} catch (Exception e) {
    		result = 0;
    		e.printStackTrace();
    	}	

		return result;
	}
	
	// 할인권 환불 거절
	@Transactional
	public int couponRefundReject(CommonMap param) throws Exception {
		int result = 0;
		try {
			// COUPON_PC_GUBN : 결제구분(P:결제, R:환불요청, C:환불완료)
			param.put("pcGubn", "P");		// 환불요청을 거절하면 정상 상태로 돌린다.
			param.put("queryId", "market.couponRefundManage.update_couponPurchase");
			result += commonService.update(param);
			
			// CONFIRM_YN : 승인여부
			param.put("confirmYn", "C");
			param.put("queryId", "market.couponRefundManage.update_appCouponRefund");
			result += commonService.update(param);

		} catch (Exception e) {
    		result = 0;    	    		
    		e.printStackTrace();
    	}	

		return result;
	}
	
	@Transactional
	public int CouponManageSave(CommonMap param) throws Exception {
		int result = 0;
		EncUtil enc = new EncUtil();
		try {
			param.put("queryId", "market.couponManage.update_member");
			result += commonService.update(param);
		} catch (Exception e) {
    		result = 0;    	    		
    		e.printStackTrace();
    	}
		return result;
	}
	
	@Transactional
	public int CouponPasswordUpdate(CommonMap param) throws Exception {
		int result = 0;
		EncUtil enc = new EncUtil();
		
		try {
			param.put("kMemberPw", enc.get(param.getString("kMemberPw")), false);
			
			param.put("queryId", "market.couponManage.update_memberPassword");
			
			result += commonService.update(param);
		} catch (Exception e) {
    		result = 0;    	    		
    		e.printStackTrace();
    	}
		return result;
	}
	
	@Transactional
	public int CouponAreaSave(CommonMap param) throws Exception {
		int result = 0;
		EncUtil enc = new EncUtil();
		String gubn = param.getString("gubn");
		
		/*param.put("userId", enc.encrypt(param.getString("userId")), false);*/
		try {
			switch (gubn) {
				case "Y" :
					// 승인
					param.put("confirmYn", gubn);
					param.put("rejectReason", "");
					param.put("queryId", "market.couponAreaManage.update_couponArea");
					commonService.update(param);
					
					param.put("queryId", "market.couponAreaManage.insert_couponArea");
					result += commonService.update(param);
					break;
				case "C" : 
					// 거절
					param.put("confirmYn", gubn);
					param.put("rejectReason", param.getString("kRejectReason"));
					param.put("queryId", "market.couponAreaManage.update_couponArea");
					result += commonService.update(param);
					break;
				default :;
			}
			
			param.put("couponMemberId", param.getString("hCouponMemberId"), false);
			param.put("queryId", "select.select_couponMemberInfo");
			CommonMap memberInfo = commonService.selectOne(param);

			// 알림 메서드(할인권 장소 승인 알림)
			MsgUtil msg = new MsgUtil();
			CommonMap sendParam = new CommonMap();
			sendParam.put("recvId", param.getString("hCouponMemberId"), false);
			sendParam.put("recvName", memberInfo.getString("couponMemberName"));
			sendParam.put("recvPhone", memberInfo.getString("memberPhone"));
			sendParam.put("sendPhone", propertyService.getString("msgSendNumber"));
			sendParam.put("tplCode", "Y".equals(gubn) ? "T00044" : "T00047"); // 승인 / 거절

			sendParam.put("memberName", memberInfo.getString("couponMemberName"));
			sendParam.put("govName", param.getString("pGovName"));
			sendParam.put("parkingName", param.getString("parkingName"));
			sendParam.put("areaName", param.getString("kAreaName"));
			sendParam.put("reason", param.getString("kRejectReason"));

			if("Y".equals(memberInfo.getString("kakaoYn"))) {
				msg.doSend(sendParam, "K");
			} else {
				msg.doSend(sendParam, "S");
			}
		} catch (Exception e) {
    		result = 0;    	    		
    		e.printStackTrace();
    	}
		return result;
	}
	
	@Transactional
	public int offlineCouponSave(CommonMap param) throws Exception {
		int result = 0;
		try {
			// 동일한 기관에 중복된 포맷이 있는지 확인
			param.put("pCouponFormat", param.getString("pCouponFormat").trim());
			param.put("queryId", "market.offlineCouponManage.select_dupFormat");
			CommonMap dupFormat = commonService.selectOne(param);
			if(dupFormat.getInt("cnt") > 0) {
				return -100;
			}
			
			param.put("queryId", "market.offlineCouponManage.insert_offlineCouponMaster");
			result = commonService.insert(param);
			
		} catch (Exception e) {
    		result = 0;    	    		
    		e.printStackTrace();
    	}
		return result;
	}	
	
	@Transactional
	public CommonMap offlineCouponDetail(CommonMap param) throws Exception {
		CommonMap result = new CommonMap();
		
		try {
			param.put("queryId", "market.offlineCouponManage.select_newKey");
    		CommonMap newKey = commonService.selectOne(param);    		
    		param.put("printCode", newKey.getString("newKey"));
			
    		// 실물 할인권 인쇄 Master
			param.put("queryId", "market.offlineCouponManage.insert_couponPrintMaster");
			commonService.insert(param);
			
			// 바코드를 수량만큼 생성해오기 
			int qty = Integer.parseInt(param.getString("pQty"));
			List<String> barcodeList = generateFormatCodeList(param.getString("hOfflineCouponCode"), qty);
			if(barcodeList == null) {
				result.put("count", -100);
				return result;
			}
			
			for(int i = 0; i < qty; i++) {
				// 코드번호
				param.put("barcode", barcodeList.get(i));
				
				param.put("queryId", "market.offlineCouponManage.select_maxSeq");
				CommonMap seqMap = commonService.selectOne(param);
				param.put("seq", seqMap.getString("seq"));
				param.put("queryId", "market.offlineCouponManage.insert_offlineCouponDetail");
				commonService.insert(param);
				
				// 실물 할인권 인쇄 Detail
				param.put("printSeq", i+1);
				param.put("queryId", "market.offlineCouponManage.insert_couponPrintDetail");
				commonService.insert(param);
			}
			
		} catch (Exception e) {
			e.printStackTrace();
    		result.put("count", 0);
			return result;
    	}
		
		result.put("count", 1);
		result.put("printCode", param.getString("printCode"));
		return result;
	}
	
	@Transactional
	public int offlineCouponParkingSave(CommonMap param) throws Exception {
		int result = 0;
		try {
			List<CommonMap> list = param.getList("list");
			
			for(int i=0; i<list.size(); i++) {
				CommonMap item = list.get(i);
				
				if(item.getString("grdIncludeValue").equals("Y")) {
					item.put("queryId", "market.offlineCouponParkingManage.insert_offCouponParking");
	 				result += commonService.insert(item);
				}else {
					item.put("queryId", "market.offlineCouponParkingManage.delete_offCouponParking");
					result += commonService.delete(item);
				}
			}
			
			if(list.size() > result) {
				result = 0;	
			}
			
		} catch (Exception e) {
    		result = 0;    	    		
    		e.printStackTrace();
    	}
		return result;
	}
	
	public List<String> generateFormatCodeList(String offCouponCode, int qty) {
		List<String> barcodeList = new ArrayList<>();
		List<String> error = null;
		CommonMap param = new CommonMap();
		String couponFormat = "";
		String temp = "";
		
		try {
			// 생성하려는 할인권의 포맷을 가져옴
			param.put("offCouponCode", offCouponCode);
			param.put("queryId", "market.offlineCouponManage.select_offCouponFormat");
			CommonMap map = commonService.selectOne(param);
			couponFormat = map.getString("offCouponFormat");
			
			// 컬럼값으로 코드를 생성하기 위해 가져옴
			param.put("queryId", "market.offlineCouponManage.select_couponMasterColumn");
			List<CommonMap> columnList = commonService.select(param);
			
			// 포맷의 코드와 정규식을 가져옴
			param.put("queryId", "market.offlineCouponManage.select_couponFormatElement");
            List<CommonMap> fmElemList = commonService.select(param);
            
            // 정의된 정규식이 없는 경우
            if(fmElemList.size() < 1) return error;
            
            // 수량만큼 코드 생성
            for(int k=0; k<qty; k++) {
        		String newCouponCode = "";
        		temp = couponFormat;	// 포맷코드를 난수로 변환하기 위해 저장

                // 정의된 포맷코드와 생성하려는 할인권의 포맷을 비교
                for(int i=0; i<fmElemList.size(); i++) {
                	CommonMap item = fmElemList.get(i);
                	String fmCode = item.getString("fmCode");
                	String fmRegexp = item.getString("fmRegexp");
                	String fmColumn = item.getString("fmColumn");
                	String formatedCode = "";
                	
                	// 컬럼값으로 코드에 입력해야하는지 확인
                	if(!fmColumn.equals("")) {
                		for(int j=0; j < columnList.size(); j++) {
                			if(columnList.get(j).getString("id").equals(fmColumn)) {
                				// 컬럼값이 정규식에 맞는지 확인
                				if(columnList.get(j).getString("value").matches(fmRegexp)) {
                					formatedCode = columnList.get(j).getString("value");
                					break;
                				}else{
                					// CP_VALUE의 경우 자릿수를 채워야 하기 때문. 다른 형식이 추가되면 개선 필요
                					String length = fmRegexp.replaceAll("[^0-9]","");
                					formatedCode = String.format("%0" + length + "d", Integer.parseInt(columnList.get(j).getString("value")));
                					break;
                				}
                			}
                		}
                	}
                	
                	// RN 이면 8자리 난수 생성
                	if(formatedCode.equals("") && fmCode.equals("RN")) {
                		formatedCode = CommonUtil.randomString(8);
                		formatedCode = formatedCode.toUpperCase();
                		if(formatedCode.equals("")) return error;
                	}
                	
                	temp = temp.replace("{" + fmCode + "}", formatedCode);
                }
                
                // 변환 안된 포맷코드가 있는지 확인 (ex. D2:{CP_VALUE}-P-SW084Y)
                if(temp.contains("{") || temp.contains("}")) {
                	return error;
                }

                newCouponCode = temp;
       
                
                // 중복된 코드가 존재하면 생성수량을 증가시키고 다음 루프를 실행함
                param.put("newCouponCode", newCouponCode);
				param.put("queryId", "market.offlineCouponManage.select_barcodeDupCheck");
				CommonMap barcodeDup = commonService.selectOne(param);
				if(barcodeDup.getInt("cnt") > 0) {
					qty++;
					continue;
				}
				
                barcodeList.add(newCouponCode);
            }

		} catch (Exception e) {
			return error;
    	}
		
		return barcodeList;
	}
}
