package kr.yeongju.its.ad.proj.service;

import java.util.ArrayList;
import java.util.List;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.ws.rs.NotFoundException;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import egovframework.rte.fdl.property.EgovPropertyService;
import kr.yeongju.its.ad.common.dto.CommonMap;
import kr.yeongju.its.ad.common.util.EncUtil;
import kr.yeongju.its.ad.common.util.MapUtils;
import kr.yeongju.its.ad.common.util.MsgUtil;
import kr.yeongju.its.ad.core.restcontroller.UploadController;
import kr.yeongju.its.ad.core.service.CommonService;
import kr.yeongju.its.ad.proj.restcontroller.ApiCallController;

@Service("memberService")
public class MemberServiceImpl implements MemberService {

	@Resource(name = "commonService")
	private CommonService commonService;
	
	@Resource(name = "propertyService")
	private EgovPropertyService propertyService;
	
	/*승인*/
	@Transactional
	public int memberUpdate(CommonMap param) throws Exception {
		CommonMap p = new CommonMap();
		List<CommonMap> list = param.getList("list");
		
		for(int i=0; i<list.size(); i++) {
			CommonMap item = list.get(i);
			
			//p = new CommonMap();
			item.put("queryId", "member.applyMember.update_member_confirm");
			commonService.update(item);
			
			item.put("queryId", "member.applyMember.update_apply_master_confirm");
			commonService.update(item);
			
			item.put("queryId", "member.applyMember.update_apply_car_reduction");
			commonService.update(item);
			
			item.put("queryId", "member.applyMember.update_apply_member_reduction");
			commonService.update(item);
			
			item.put("queryId", "member.applyMember.update_member_reduction");
			commonService.insert(item);
			
			item.put("queryId", "member.applyMember.insert_car_reduction");
			commonService.insert(item);
			
			item.put("queryId", "member.applyMember.insert_member_reduction");
			commonService.insert(item);
			
			item.put("queryId", "member.applyMember.insert_car_reduction_history");
			commonService.insert(item);
			
			item.put("queryId", "member.applyMember.insert_member_reduction_history");
			commonService.insert(item);
			
		}
		return 1;
		
	}
	
	/*승인*/
	@Transactional
	public int memberCofirmUpdate(CommonMap param) throws Exception {
		List<CommonMap> list = param.getList("list");
		System.out.println(list.size());
		
		param.put("queryId", "member.applymemberPopup.update_member_confirm");
		commonService.update(param);
		
		param.put("queryId", "member.applymemberPopup.update_apply_master_confirm");
		commonService.update(param);
		
		for(int i=0; i<list.size(); i++) {
			CommonMap item = list.get(i);
		
			item.put("redExpDate3", item.getString("grd3RedExpDate").replaceAll("-",""));
			item.put("redExpDate4", item.getString("grd4RedExpDate").replaceAll("-",""));
			
			if("Y".equals(item.getString("grdCheckValue"))) {
				item.put("queryId", "member.applymemberPopup.update_apply_car");
				commonService.update(item);
				
				item.put("queryId", "member.applymemberPopup.insert_car_apply");
				commonService.insert(item);
				
			}else {
				item.put("queryId", "member.applymemberPopup.update_apply_non_car");
				commonService.update(item);
			}
			
			if("Y".equals(item.getString("grd4CheckValue"))) {
				item.put("queryId", "member.applymemberPopup.update_apply_car_reduction");
				commonService.update(item);
				
				item.put("queryId", "member.applymemberPopup.insert_car_reduction");
				commonService.insert(item);
			}else {
				item.put("queryId", "member.applymemberPopup.update_apply_non_car_reduction");
				commonService.update(item);
			}
			
			if("Y".equals(item.getString("grd3CheckValue"))) {
				item.put("queryId", "member.applymemberPopup.update_apply_member_reduction");
				commonService.insert(item);	
				
				item.put("queryId", "member.applymemberPopup.insert_member_reduction");
				commonService.insert(item);		
			} else {
				item.put("queryId", "member.applymemberPopup.update_apply_non_member_reduction");
				commonService.insert(item);	
			}
			

//			item.put("queryId", "member.applymemberPopup.update_member_reduction");
//			commonService.insert(item);
//			
			
			item.put("queryId", "member.applymemberPopup.insert_member_reduction_history");
			commonService.insert(item);
			
			item.put("queryId", "member.applymemberPopup.insert_car_reduction_history");
			commonService.insert(item);
			
		}
		
		return 1;
		
	}
	
	/*비밀번호 변경*/
	@Transactional
	public int memberPasswordUpdate(CommonMap param) throws Exception {
		EncUtil enc = new EncUtil();
		
		param.put("kMemberId", enc.encrypt(param.getString("kMemberId")), false);
		param.put("kMemberPw", enc.get(param.getString("kMemberPw")), false);
		
		param.put("queryId", "member.memberPopup.update_memberPassword");
		commonService.update(param);
		
		return 1;
	}
	
	/*회원 관리 팝업에서 차량 삭제*/
	@Transactional
	public int memberCarDel(CommonMap param) throws Exception {
		EncUtil enc = new EncUtil();
		
		try {
			CommonMap item = new CommonMap();
			CommonMap item2 = new CommonMap();
			CommonMap item3 = new CommonMap();
			CommonMap item4 = new CommonMap();
			
			int result = 0;

			item.put("hMemberId", enc.encrypt(param.getString("hMemberId")), false);
			item.put("userId", enc.encrypt(param.getString("userId")), false);
			item.put("grdCarNo", param.getString("grdCarNo"));
			item.put("grdCarAlias", param.getString("grdCarAlias"));
			item.put("grdReductionCode", param.getString("grdReductionCode"));
			item.put("grdRedExpDate", param.getString("grdRedExpDate"));
			item.put("delComment", param.getString("delComment"));

			// 20240710 :: 입차 상태인 차량은 삭제 불가능하도록 처리
			// 해당 차량이 입차중인지 확인
			// 입차중이면 입차중인 차량이라는 코드 만들어서 리턴
			item.put("queryId", "member.memberPopup.select_CheckParkingCar");
			List<CommonMap> checkParkingCarList = commonService.select(item);
			
			if(checkParkingCarList.size() > 0) {
			    // 입차중인 차량으로 확인됨
			    return -1000;
			}
			
			item.put("queryId", "member.memberPopup.select_carReduction");
			List<CommonMap> carRed = commonService.select(item);

			CommonMap newSeq = commonService.selectOne(new CommonMap("queryId", "member.memberPopup.select_hSeqCarInfo"));
			int hSeq = 1;
			if(newSeq != null) {
				hSeq = newSeq.getInt("hSeq");
			}
			item.put("hSeq", hSeq);
			item.put("queryId", "member.memberPopup.insert_carInfoHistory");
			commonService.insert(item);

			
			for(int i=0; i<carRed.size(); i++) {
				item3 = carRed.get(i);
					
				item.put("redExpDate", item3.getString("redExpDate"));
				item.put("fileRelKey", item3.getString("fileRelKey"));
				item.put("confirmYnParent", item3.getString("confirmYnParent"));
				item.put("confirmYn", item3.getString("confirmYn"));
				item.put("confirmId", enc.encrypt(item3.getString("confirmId")), false);
				item.put("confirmDt", item3.getString("confirmDt"));
				item.put("regId", enc.encrypt(item3.getString("regId")), false);
				item.put("regDt", item3.getString("regDt"));
				item.put("modId", enc.encrypt(item3.getString("modId")), false);
				item.put("modDt", item3.getString("modDt"));
				item.put("delYnParent", item3.getString("delYnParent"));
				
				CommonMap newSeq2 = commonService.selectOne(new CommonMap("queryId", "member.memberPopup.select_hSeqCarReduction"));
				int hSeq2 = 1;
				if(newSeq2 != null) {
					hSeq2 = newSeq2.getInt("hSeq");
				}
				
				item.put("hSeq", hSeq2);
				item.put("queryId", "member.memberPopup.insert_carReductionHistory");
				commonService.insert(item);
			}

			item.put("queryId", "member.memberPopup.delete_carReductionDel");
			commonService.delete(item);
			
			item.put("queryId", "member.memberPopup.delete_carInfo");
			result = commonService.delete(item);

			
			if(result > 0) {
				item4.put("memberId", enc.encrypt(param.getString("hMemberId")), false);
				item4.put("queryId", "select.select_memberInfo");
		 		CommonMap memberInfo = commonService.selectOne(item4);

				// 알림 메서드
				MsgUtil msg = new MsgUtil();
				CommonMap sendParam = new CommonMap();
				sendParam.put("recvId", enc.encrypt(param.getString("hMemberId")), false);
				sendParam.put("recvName", memberInfo.getString("memberName"));
				sendParam.put("recvPhone", memberInfo.getString("memberPhone"));
				sendParam.put("sendPhone", propertyService.getString("msgSendNumber"));
		 		sendParam.put("tplCode", "T00040");
		 		
				// 회원 이름, 차량 번호, 삭제 사유				
		 		sendParam.put("memberName", memberInfo.getString("memberName"));
		 		sendParam.put("carNo", param.getString("grdCarNo"));
				sendParam.put("reason",param.getString("delComment").toString() );
		 		
		 		if("Y".equals(memberInfo.getString("kakaoYn"))) {
		 			msg.doSend(sendParam, "K");
		 		} else {
		 			msg.doSend(sendParam, "S");
		 		}
		 		
				return 1;
			}else {
				return 0;
			}
			
		}catch (Exception e) {
			return 0;
		}
	}
	
	/*회원 관리 팝업에서 인적감면 삭제*/
	@Transactional
	public int memberReductionDel(HttpServletRequest request) throws Exception {
		EncUtil enc = new EncUtil();
		CommonMap param = MapUtils.parseRequest(request, false, request.getParameter("enc_col"));

		try {
			CommonMap item = new CommonMap();
			CommonMap item2 = new CommonMap();
			CommonMap item3 = new CommonMap();
			
			int result = 0;
			

			item.put("hMemberId", param.getString("hMemberId"), false);
			item.put("userId", param.getString("userId"), false);
			item.put("grdReductionCode", param.getString("grdReductionCode"));
			item.put("grdRedExpDate", param.getString("grdRedExpDate").replace("-", ""));
			item.put("delComment", param.getString("delComment"));
			
			item.put("queryId", "member.memberPopup.select_memberReduction");
			List<CommonMap> memberRed = commonService.select(item);
			
			for(int i=0; i<memberRed.size(); i++) {
				List<CommonMap> list = null;
				CommonMap hSeq = null;
				item2 = memberRed.get(i);
				item2.put("hMemberId", item.getString("hMemberId"), false);
				
				item2.put("queryId", "member.memberPopup.select_fileKey");
				
				list = commonService.select(item2);
					
				if(list.get(0) != null) {
					item2.put("fileRelKey", list.get(0).get("fileRelKey"));
					item2.put("fileKey", list.get(0).get("fileKey"));
				}else {
					item2.put("fileRelKey", null);
					item2.put("fileKey", null);
				}	
				
				// 현재 seq값
				item2.put("queryId", "member.memberPopup.select_hSeqMemberReduction");
				hSeq = commonService.selectOne(item2);
				
				if(hSeq == null) {
					item2.put("hSeq", 1);
				}else {
					item2.put("hSeq", hSeq.getInt("hSeq")+1);
				}
				
				item.put("hSeq", item2.getString("hSeq"));
				item.put("fileRelKey", item2.getString("fileRelKey"));
				item.put("regId", enc.encrypt(item2.getString("regId")), false);
				item.put("regDt", item2.getString("regDt"));
				item.put("modId", enc.encrypt(item2.getString("modId")), false);
				item.put("modDt", item2.getString("modDt"));
				item.put("confirmYnParent", item2.getString("confirmYnParent"));
				item.put("confirmYn", item2.getString("confirmYn"));
				item.put("confirmId", enc.encrypt(item2.getString("confirmId")), false);
				item.put("confirmDt", item2.getString("confirmDt"));
				
				item.put("queryId", "member.memberPopup.delete_enrollmentFile");
				commonService.delete(item);
				
				item.put("queryId", "member.memberPopup.insert_memberReductionHistory");
				commonService.insert(item);
			}
			
			item.put("queryId", "member.memberPopup.delete_memberReduction");
			result = commonService.delete(item);
			
			if(result > 0) {
				item3.put("memberId", param.getString("hMemberId"), false);
				item3.put("queryId", "select.select_memberInfo");
		 		CommonMap memberInfo = commonService.selectOne(item3);

				// 알림 메서드
				MsgUtil msg = new MsgUtil();
				CommonMap sendParam = new CommonMap();
				sendParam.put("recvId", enc.encrypt(param.getString("hMemberId")), false);
				sendParam.put("recvName", memberInfo.getString("memberName"));
				sendParam.put("recvPhone", memberInfo.getString("memberPhone"));
				sendParam.put("sendPhone", propertyService.getString("msgSendNumber"));
		 		sendParam.put("tplCode", "T00041");
		 		
				// 회원 이름, 감면정보, 삭제 사유				
		 		sendParam.put("memberName", memberInfo.getString("memberName"));
		 		sendParam.put("reductionName", param.getString("grdReductionName"));
				sendParam.put("reason",param.getString("delComment").toString() );
		 		
		 		if("Y".equals(memberInfo.getString("kakaoYn"))) {
		 			msg.doSend(sendParam, "K");
		 		} else {
		 			msg.doSend(sendParam, "S");
		 		}
                
                // 회원가입 API 오류가 발생해도 리턴은 정상적으로 되어야 하므로 try / catch를 이용함
                // 20240710 :: 회원가입 API 전송 부분 추가
                try {
                    ApiCallController acc = new ApiCallController(commonService);
                    
                    CommonMap apiParam = new CommonMap();
                    
                    apiParam.put("memberId", param.getString("hMemberId"));
                    
                    acc.callParkingApi(apiParam); // 실제 호출하는 부분 (리턴없음)
                } catch(Exception e) {
                    System.out.println("MemberServiceImpl.memberReductionDel :: ApiCallController error.");
                    e.printStackTrace();
                }
                
				return 1;
			}else {
				return 0;
			}

		}catch (Exception e) {
			return 0;
		}
	}

	/*차량 승인 & 거절*/
	@Transactional
	public int applyCarUpdate(HttpServletRequest request) throws Exception {
		UploadController uc = new UploadController(commonService);
		CommonMap param = MapUtils.parseRequest(request, false, request.getParameter("enc_col"));
		List<CommonMap> list = param.getList("list");
		EncUtil enc = new EncUtil();
		
		// 승인받은 사용자 ID를 저장
		List<String> approveMember = new ArrayList<String>();
		
		for(int i=0; i<list.size(); i++) {
			CommonMap item = list.get(i);
			
			// 승인
			if(item.getString("grdType").equals("Approval")) {
				item.put("queryId", "member.applyCarManage.select_car_info");
				CommonMap carOverlapCnt = commonService.selectOne(item);
				
				// 기존 처리 여부
				item.put("confirmGubn", "Y");
				item.put("delYn", "N");
				item.put("queryId", "member.applyCarManage.select_reg_gubn");
				CommonMap regGubn = commonService.selectOne(item);
				
				if(Integer.parseInt(regGubn.getString("regCnt")) > 0){
					return -2;
				}
				
				// 기존 처리 여부
				item.put("confirmGubn", "C");
				item.put("delYn", "N");
				item.put("queryId", "member.applyCarManage.select_reg_gubn");
				regGubn = commonService.selectOne(item);
				
				if(Integer.parseInt(regGubn.getString("regCnt")) > 0){
					return -2;
				}
				
				if(Integer.parseInt(carOverlapCnt.getString("carOverlapCnt")) > 0){
					// 기존 차량 삭제 로직
					// 현재 seq값
					item.put("queryId", "member.applyCarManage.select_hSeq");
					CommonMap hSeq = commonService.selectOne(item);
					
					if(hSeq == null) {
						item.put("hSeq", 1);
					}else {
						item.put("hSeq", hSeq.getInt("hSeq")+1);
					}
					
					// 차량 관리 이력 insert
					item.put("queryId", "member.applyCarManage.insert_carInfoHistory");
					commonService.delete(item);
					
					// 기존 차량 삭제
					item.put("queryId", "member.applyCarManage.delete_car");
					commonService.delete(item);
					
					// 차량감면관리 이력 insert
					item.put("queryId", "member.applyCarManage.insert_reductionHistory");
					commonService.delete(item);
					
					// 차량감면 삭제
					item.put("queryId", "member.applyCarManage.delete_carReduction");
					commonService.delete(item);
					
					item.put("queryId", "member.applyCarManage.select_prevApplyCode");
					CommonMap prev_apply_code = commonService.selectOne(item); 
					
					if(!prev_apply_code.isEmpty()) {
						uc.userUploadFileDelete(request);
					}
					
					item.put("prevApplyCode", prev_apply_code.getString("prevApplyCode"));
					item.put("queryId", "member.applyCarManage.delete_applyMemberCar");
					commonService.update(item);
					
					// 차량 상태 삭제
					item.put("queryId", "member.applyCarManage.delete_carStatus");
					commonService.delete(item);
					
					// 등록 로직
					item.put("queryId", "member.applyCarManage.update_applyCar");
					commonService.update(item);
					
					item.put("queryId", "member.applyCarManage.insert_carInfo");
					commonService.insert(item);
					
					item.put("queryId", "member.applyCarManage.insert_carStatus");
					commonService.insert(item);
					
					// APPLY_CAR_REDUCTION CONFIRM_GUBN = 'Y' 변경
					item.put("queryId", "member.applyCarManage.update_apply_reduction");
					commonService.update(item);
					
					// CAR_REDUCTION SELECT INSERT
					item.put("queryId", "member.applyCarManage.insert_reduction");
					commonService.insert(item);

					//차량이관 후 알림톡보내줌
					param.put("memberId", param.getString("approveMemberId"), false);
					param.put("queryId", "select.select_memberInfo");
					CommonMap memberInfo = commonService.selectOne(param);

					// 알림 메서드
					MsgUtil msg = new MsgUtil();
					CommonMap sendParam = new CommonMap();
					sendParam.put("recvId", item.getString("approveMemberId"));
					sendParam.put("recvName", memberInfo.getString("memberName"));
					sendParam.put("recvPhone", memberInfo.getString("memberPhone"));
					sendParam.put("sendPhone", propertyService.getString("msgSendNumber"));
					sendParam.put("tplCode", "T00030");
					
					sendParam.put("memberName",memberInfo.getString("memberName"));
					sendParam.put("carNo", item.getString("grdCarNo"));
					
					if("Y".equals(memberInfo.getString("kakaoYn"))) {
						msg.doSend(sendParam, "K");
					} else {
						msg.doSend(sendParam, "S");
					}

				}else {
					item.put("queryId", "member.applyCarManage.update_applyCar");
					commonService.update(item);
					
					item.put("queryId", "member.applyCarManage.insert_carInfo");
					commonService.insert(item);
					
					item.put("queryId", "member.applyCarManage.insert_carStatus");
					commonService.insert(item);
					
					// APPLY_CAR_REDUCTION CONFIRM_GUBN = 'Y' 변경
					item.put("queryId", "member.applyCarManage.update_apply_reduction");
					commonService.update(item);
					
					// CAR_REDUCTION SELECT INSERT
					item.put("queryId", "member.applyCarManage.insert_reduction");
					commonService.insert(item);
				}
				
				item.put("memberId", item.getString("hMemberId"), false);
				item.put("queryId", "select.select_memberInfo");
				CommonMap memberInfo = commonService.selectOne(item);
				
				item.put("kCarNum", item.getString("grdCarNo"));
				item.put("queryId", "member.member.select_carRegDt");
				CommonMap regDt = commonService.selectOne(item);
				
				// 알림 메서드
				MsgUtil msg = new MsgUtil();
				CommonMap sendParam = new CommonMap();
				sendParam.put("recvId", item.getString("hMemberId"));
				sendParam.put("recvName", memberInfo.getString("memberName"));
				sendParam.put("recvPhone", memberInfo.getString("memberPhone"));
				sendParam.put("sendPhone", propertyService.getString("msgSendNumber"));
				sendParam.put("tplCode", "T00006");
				sendParam.put("memberName", memberInfo.getString("memberName"));
				sendParam.put("applyDt", regDt.getString("modDt"));
				sendParam.put("carNo", item.getString("grdCarNo"));
				
				if("Y".equals(memberInfo.getString("kakaoYn"))) {	
					msg.doSend(sendParam, "K");
				} else {
					msg.doSend(sendParam, "S");
				}
				
				String nowMemberId = enc.decrypt(item.getString("hMemberId"));
				boolean isDuplicate = false;
				// id 추가 전 중복 여부 확인
				for(int dup = 0; dup < approveMember.size(); dup++) {
				    if(approveMember.get(dup).equals(nowMemberId)) {
				        isDuplicate = true;
				        break;
				    }
				}
				if(!isDuplicate) {
				    // 승인된 사용자의 id 를 추가
				    approveMember.add(nowMemberId);
				}
				
            	ApiCallController acc = new ApiCallController(commonService);
                
        		CommonMap apiParam = new CommonMap();
        		
        		apiParam.put("memberId", item.getString("hMemberId"));
        		
                acc.callParkingApi(apiParam); // 실제 호출하는 부분 (리턴없음)
				
			// 거절
			}else {
				
				// 기존 처리 여부
				item.put("confirmGubn", "Y");
				item.put("delYn", "N");
				item.put("queryId", "member.applyCarManage.select_reg_gubn");
				CommonMap regGubn = commonService.selectOne(item);
				
				if(Integer.parseInt(regGubn.getString("regCnt")) > 0){
					return -2;
				}
				
				// 기존 처리 여부
				item.put("confirmGubn", "C");
				item.put("delYn", "N");
				item.put("queryId", "member.applyCarManage.select_reg_gubn");
				regGubn = commonService.selectOne(item);
				
				if(Integer.parseInt(regGubn.getString("regCnt")) > 0){
					return -2;
				}
				
				item.put("queryId", "member.applyCarManage.update_NonApplyCar");
				commonService.update(item);
				
//				item.put("queryId", "member.applyCarManage.select_prevApplyCode");
//				CommonMap prev_apply_code = commonService.selectOne(item); 
				
//				if(prev_apply_code != null) {
//					item.put("queryId", "member.applyCarManage.delete_car_reduction");
//					commonService.delete(item);
//				}
				
				item.put("memberId", item.getString("hMemberId"), false);
				item.put("queryId", "select.select_memberInfo");
				CommonMap memberInfo = commonService.selectOne(item);
			
				item.put("queryId", "member.applyCarManage.select_NonApplyCar");
				CommonMap modDt = commonService.selectOne(item);

				// 알림 메서드
				MsgUtil msg = new MsgUtil();
				CommonMap sendParam = new CommonMap();
				sendParam.put("recvId", item.getString("hMemberId"));
				sendParam.put("recvName", memberInfo.getString("memberName"));
				sendParam.put("recvPhone", memberInfo.getString("memberPhone"));
				sendParam.put("sendPhone", propertyService.getString("msgSendNumber"));
				sendParam.put("tplCode", "T00025");
				
				sendParam.put("memberName", memberInfo.getString("memberName"));
				sendParam.put("applyDt", modDt.getString("confirmDt"));
				sendParam.put("carNo", item.getString("grdCarNo"));
				sendParam.put("reason", item.getString("grdRejectReason"));
				
				if("Y".equals(memberInfo.getString("kakaoYn"))) {	
					msg.doSend(sendParam, "K");
				} else {
					msg.doSend(sendParam, "S");
				}
			}
		}
		
        return 1;
    }

	/*전체 관리*/
	@Transactional
	public CommonMap memberFullManage(CommonMap param) throws Exception {
		CommonMap result = new CommonMap();
		EncUtil enc = new EncUtil();
		String memberId = "";

		if(!"".equals(param.getString("kCarNumber"))) {
			
			// 차량번호
			param.put("queryId", "member.memberFullManagePopup.select_memberCar");
			CommonMap memberInfo = commonService.selectOne(param);
			
			if(memberInfo != null) {
				memberId = enc.encrypt(memberInfo.getString("memberId"));
						
			}else {
				memberId = "아이디";
			}
			
		}else {
			// 없는 데이터를 검색하도록 하게 하여 팝업의 데이터를 클리어시키위함
			param.put("kCarNumber", "차량번호");
			memberId = "아이디";
		}
		
		param.put("queryId", "member.memberFullManagePopup.select_memberCar");
		param.put("hMemberId", memberId, false);
		result.put("memberCar", commonService.select(param));
		
		// 입출차 내역
		param.put("queryId", "member.memberFullManagePopup.select_parkingInOutList");
		result.put("parkingInOutList", commonService.select(param));
		
		// 감면 정보
		param.put("queryId", "member.memberFullManagePopup.select_reductionInfo");
		result.put("reductionInfo", commonService.select(param));
		
		// 결제 내역
		param.put("queryId", "member.memberFullManagePopup.select_paymentList");
		result.put("paymentList", commonService.select(param));
		
		// 미납 내역
		param.put("queryId", "member.memberFullManagePopup.select_NonPaymentList");
		result.put("NonPaymentList", commonService.select(param));
		
		// 결제취소/재결제 내역
		param.put("queryId", "member.memberFullManagePopup.select_cancelRePaymentList");
		result.put("cancelRePaymentList", commonService.select(param));
		
		return result;
	}
	
	/*SMS 발송*/
	@Transactional
	public int msgSendManage(HttpServletRequest request) throws Exception {

		CommonMap param = MapUtils.parseRequest(request, false, request.getParameter("enc_col"));

		MsgUtil msg = new MsgUtil();
		CommonMap sendParam = new CommonMap();
		
		// 알림 메서드
		sendParam = new CommonMap();
		sendParam.put("recvId", param.getString("memberId"));
		sendParam.put("recvName", param.getString("memberName"));
		sendParam.put("recvPhone", param.getString("memberPhone"));
		sendParam.put("msgTitle", param.getString("hMsgTitle"));
		sendParam.put("sendPhone", propertyService.getString("msgSendNumber"));
		sendParam.put("sendMessage", param.getString("hContent"));			
		msg.doSendMsg(sendParam);
		
//		String[] memberName = param.getString("kMemberName").split(",");
//		String[] memberPhone = param.getString("kMemberPhone").split(",");
//		String[] memberId = param.getString("kMemberId").split(",");
//		
//		for(int i=0; i<memberName.length; i++) {
//			// 알림 메서드
//			MsgUtil msg = new MsgUtil();
//			CommonMap sendParam = new CommonMap();
//			sendParam.put("recvId", memberId[i]);
//			sendParam.put("recvName", memberName[i]);
//			sendParam.put("recvPhone", memberPhone[i]);
//			sendParam.put("msgTitle", param.getString("msgTitle"));
//			sendParam.put("sendPhone", propertyService.getString("msgSendNumber"));
//			sendParam.put("sendMessage", param.getString("content"));
//			
//			msg.doSendMsg(sendParam);
//		}
		
		return 1;
	}
	
	/* 회원관리 저장 */
	@Transactional
	public int memberSaveData(CommonMap param) throws Exception {
        int result = 0;

        try {
        	EncUtil enc = new EncUtil();
    		
    		param.put("memberId", enc.encrypt(param.getString("kMemberId")), false);
    		
        	// 1. 회원정보 - 주소
        	// 구군 코드 검색
        	param.put("queryId", "member.memberPopup.select_gugunCode");
			List<CommonMap> gugunList = commonService.select(param);
			if(gugunList.size() > 0) {
				param.put("gugunCode", gugunList.get(0).getString("codeId"));
			}
			
        	param.put("queryId", "member.memberPopup.update_memberAddr");
            result += commonService.update(param);
        	
        	
        	// 2. 회원감면정보   	
            List<CommonMap> list = param.getList("list");

            for(int i = 0; i < list.size(); i++) {
                CommonMap item = list.get(i);
                // grdStateCol 안먹힘
                if(item.getString("grdStateCol").equals("U")) {
                	item.put("memberId", enc.encrypt(param.getString("kMemberId")), false);
                	item.put("queryId", "member.memberPopup.update_memberReduction");
                    result += commonService.update(item);

                    // 회원가입 API 오류가 발생해도 리턴은 정상적으로 되어야 하므로 try / catch를 이용함
                    // 20240710 :: 회원가입 API 전송 부분 추가
                    try {
                        ApiCallController acc = new ApiCallController(commonService);
                        
                        CommonMap apiParam = new CommonMap();
                        
                        apiParam.put("memberId", param.getString("kMemberId"));
                        
                        acc.callParkingApi(apiParam); // 실제 호출하는 부분 (리턴없음)
                    } catch(Exception e) {
                        System.out.println("MemberServiceImpl.memberSaveData :: ApiCallController error.");
                        e.printStackTrace();
                    }
                    
                }
            }


        } catch (NotFoundException e) {
            e.printStackTrace();
        }

        return result;
	}

}
