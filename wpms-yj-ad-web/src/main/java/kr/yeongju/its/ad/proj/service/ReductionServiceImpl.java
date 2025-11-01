package kr.yeongju.its.ad.proj.service;

import java.util.List;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import egovframework.rte.fdl.property.EgovPropertyService;
import kr.yeongju.its.ad.common.dto.CommonMap;
import kr.yeongju.its.ad.common.exception.NotFoundException;
import kr.yeongju.its.ad.common.util.EncUtil;
import kr.yeongju.its.ad.common.util.MsgUtil;
import kr.yeongju.its.ad.core.service.CommonService;
import kr.yeongju.its.ad.proj.restcontroller.ApiCallController;

@Service("reductionService")
public class ReductionServiceImpl implements ReductionService {

	@Resource(name = "commonService")
	private CommonService commonService;
	
	@Resource(name="propertyService")
    protected EgovPropertyService propertyService;
	
	// 메인리스트 승인
	@Transactional
	public int reductionUpdate(CommonMap param) throws Exception {
		
		CommonMap p = new CommonMap();
		List<CommonMap> list = param.getList("list");
		
		for(int i=0; i<list.size(); i++) {
			CommonMap item = list.get(i);
			
			item.put("queryId", "member.reductionManage.update_apply_car_reduction");
			commonService.update(item);
			
//			item.put("queryId", "member.redemptionManage.update_apply_member_reduction");
//			commonService.update(item);
			
//			item.put("queryId", "member.redemptionManage.insert_member_reduction");
//			commonService.insert(item);
			
			item.put("queryId", "member.reductionManage.insert_car_reduction");
			commonService.insert(item);
			
			item.put("queryId", "member.reductionManage.insert_car_reduction_history");
			commonService.insert(item);
			
//			item.put("queryId", "member.redemptionManage.insert_member_reduction_history");
//			commonService.insert(item);
		}
		
		return 1;
			
	}

	/*감면 승인, 거절*/
	@Transactional
	public int popupUpdate(CommonMap param) throws Exception {
		int result = 1;
		try {
			String processGubn = param.getString("processGubn");
			List<CommonMap> list = param.getList("list");
			
			EncUtil enc = new EncUtil();
			
			for(int idx=0; idx < list.size(); idx++) {
				CommonMap item = list.get(idx);
				CommonMap param2 = new CommonMap();
				
				// 1. t_apply_member_reduction에 승인자, 승인일시, 승인 구분 입력
				String grdType = item.getString("grdType"); // 승인 / 거절 타입
				String grdReductionCode = item.getString("grdReductionCode"); // 감면코드
				String grdReductionGubn = item.getString("grdReductionGubn"); // 감면구분
				String grdRedExpDate = item.getString("grdRedExpDate").replaceAll("-",""); // 감면유효기간
				String grdFileRelKey = item.getString("grdFileRelKey"); // 파일 주소
				String grdRejectReason = item.getString("grdRejectReason"); // 거절사유
				
				String hMemberId = item.getString("hMemberId"); // 회원 아이디
				String hApplyCode = item.getString("hApplyCode"); // 감면신청번호
				
				String userId = item.getString("userId"); // 관리자아이디

				// 3. t_apply_master에 승인자, 승인일시, 승인구분 입력
				
				param2.put("grdReductionCode", grdReductionCode);
				param2.put("grdRedExpDate", grdRedExpDate, false);
				param2.put("grdFileRelKey", grdFileRelKey);
				param2.put("grdRejectReason", grdRejectReason);
				
				param2.put("hMemberId", hMemberId, false);
				param2.put("hApplyCode", hApplyCode);
				param2.put("userId", userId, false);

				// 2. t_apply_car_reduction에 승인자, 승인일시, 승인 구분 입력
				// 4. 승인된 데이터 t_member_reduction에 insert-update
				// 5. 승인된 데이터 t_history_member_reduction에 insert
				
				CommonMap seq = null;
				CommonMap confirmYn = null;

				param2.put("queryId", "member.reductionManage.select_historySeq");
				seq = commonService.selectOne(param2);
				
				param2.put("queryId", "member.reductionManage.select_applyReductionYn");
				confirmYn = commonService.selectOne(param2);
			
				 
				// 이미 승인된 데이터인지 확인
				if("N".equals(confirmYn.getString("confirmYn"))) {
					// 승인
					if(grdType.equals("Approval")) {
						param2.put("redConfirmGubn", "Y");
						param2.put("grdRejectReason", "");
						param2.put("hSeq", seq.getInt("hSeq"));
						
						param2.put("queryId", "member.reductionManage.Update_Apply_MemberReduction");
						commonService.update(param2);
						param2.put("queryId", "member.reductionManage.Insert_MemberReduction");
						commonService.insert(param2);
						param2.put("queryId", "member.reductionManage.Insert_MemberHistory");
						result = commonService.insert(param2);
					
						param2.put("memberId", param2.getString("hMemberId"), false);
						param2.put("queryId", "select.select_memberInfo");
						CommonMap memberInfo = commonService.selectOne(param2);
						
						// 알림 메서드
						MsgUtil msg = new MsgUtil();
						CommonMap sendParam = new CommonMap();
						sendParam.put("recvId", item.getString("hMemberId"));
						sendParam.put("recvName", memberInfo.getString("memberName"));
						sendParam.put("recvPhone", memberInfo.getString("memberPhone"));
						sendParam.put("memberName", memberInfo.getString("memberName"));
						sendParam.put("sendPhone", propertyService.getString("msgSendNumber"));
						sendParam.put("tplCode", "T00008");
						sendParam.put("reductionName", item.getString("grdReductionName"));
						sendParam.put("reductionRate", item.getString("kReductionRate"));
						
						if("Y".equals(memberInfo.getString("kakaoYn"))) {	
							msg.doSend(sendParam, "K");
						} else {
							msg.doSend(sendParam, "S");
						}
						
		            	ApiCallController acc = new ApiCallController(commonService);
		                
		        		CommonMap apiParam = new CommonMap();
		        		
		        		apiParam.put("memberId", item.getString("hMemberId"));
		        		
		                acc.callParkingApi(apiParam); // 실제 호출하는 부분 (리턴없음)
		                
						// 거절
					}else{
						param2.put("redConfirmGubn", "C");
						param2.put("hSeq", seq.getInt("hSeq"));
						
						param2.put("queryId", "member.reductionManage.Update_MemberRefuseReduction");
						result = commonService.update(param2);
					

						param2.put("memberId", param2.getString("hMemberId"), false);
						param2.put("queryId", "select.select_memberInfo");
						CommonMap memberInfo = commonService.selectOne(param2);

						// 알림 메서드
						MsgUtil msg = new MsgUtil();
						CommonMap sendParam = new CommonMap();
						sendParam.put("recvId", item.getString("hMemberId"));
						sendParam.put("recvName", memberInfo.getString("memberName"));
						sendParam.put("recvPhone", memberInfo.getString("memberPhone"));
						sendParam.put("sendPhone", propertyService.getString("msgSendNumber"));
						sendParam.put("tplCode", "T00026");
						
						sendParam.put("memberName", memberInfo.getString("memberName"));
						sendParam.put("reductionName", item.getString("grdReductionName"));
						sendParam.put("reductionRate", item.getString("kReductionRate"));
						sendParam.put("reason", item.getString("grdRejectReason"));
						
						if("Y".equals(memberInfo.getString("kakaoYn"))) {	
							msg.doSend(sendParam, "K");
						} else {
							msg.doSend(sendParam, "S");
						}
							}
						}else if("C".equals(confirmYn.getString("confirmYn"))){
							result = -2;
						}else if("Y".equals(confirmYn.getString("confirmYn"))) {
							param2.put("redConfirmGubn", "Y");
							param2.put("grdRejectReason", "");
							param2.put("hSeq", seq.getInt("hSeq"));
						
							param2.put("queryId", "member.reductionManage.Update_Apply_MemberReduction");
							result = commonService.update(param2);
							
							param2.put("queryId", "member.reductionManage.Update_RedExpDate");
							commonService.update(param2);
						}
			}
		} catch(NotFoundException e) {
			result = 0;
			e.printStackTrace();
			throw e;
		} catch (Exception e) {
			result = 0;
			e.printStackTrace();
			throw e;
		}
		
		return result;
	}
}
