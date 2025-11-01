package kr.yeongju.its.ad.proj.service;

import java.util.ArrayList;
import java.util.List;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.servlet.tags.ParamAware;

import kr.yeongju.its.ad.common.dto.CommonMap;
import kr.yeongju.its.ad.common.util.EncUtil;
import kr.yeongju.its.ad.core.service.CommonService;

@Service("sysService")
public class SysServiceImpl implements SysService {

	@Resource(name = "commonService")
	private CommonService commonService;

	/*SMS 카카오 알림톡 전송*/
	@Transactional
	public int smsCertificationReqeust(CommonMap param) throws Exception {

		return 1;
	}

	/*감면 정보 관리*/
	@Transactional
	public int reductionManage(CommonMap param) throws Exception {
		List<CommonMap> list = param.getList("list");
		EncUtil enc = new EncUtil();
    	int result = 0;
    	String userIdEnc = enc.encrypt(param.getString("userId"));
    	
		for(int i=0; i < list.size(); i++) {
			CommonMap item = list.get(i);
			result = 0;
			
	        // 사용자 ID 암호화 하여 파라미터에 추가
	        item.put("userIdEnc", userIdEnc, false);

			item.put("grdReductionRate", "".equals(item.getString("grdReductionRate")) ? 0 : item.getString("grdReductionRate"));
			item.put("grdFreeHour", "".equals(item.getString("grdFreeHour")) ? 0 : item.getString("grdFreeHour"));
			
			if(item.getString("grdStateCol").equals("C")) {
			    // 추가된 데이터는 추가 처리
				item.put("queryId", "sys.reductionManage.insert_reduction");
				result = commonService.insert(item);
				if(result < 1) return 0;
			}else if(item.getString("grdStateCol").equals("U")) {
				// 데이터 수정시 use_yn (grdUseYn 여부에 따라 처리가 다르게 되어야 함
				
			    // 사용 여부가 Y가 아닌 경우 모든 주차장에 대해 해당 감면정보를 삭제
			    // Y인 경우에는 업데이트만 처리
				if(!"Y".equals(item.getString("grdUseYn"))) {
                    item.put("queryId", "sys.reductionManage.delete_reduction");
                    result = commonService.delete(item);
				}
				
				item.put("queryId", "sys.reductionManage.update_reduction");
				result = commonService.update(item);
				if(result < 1) return 0;
			}
		}

		return 1;
	}
	
	/*자주하는질문 관리*/
	@Transactional
	public int faqM(CommonMap param) throws Exception {
		List<CommonMap> list = param.getList("list");
    	int result = 0;
    	
    	if("C".equals(param.getString("gubn"))) {
    		param.put("queryId", "sys.faq.select_order");
    		CommonMap maxOrder = commonService.selectOne(param);
    		
    		param.put("faqOrder", maxOrder.getInt("faqOrder"));
    		param.put("queryId", "sys.faq.insert_faqM");
    		result = commonService.insert(param);
    	}else if("U".equals(param.getString("gubn"))) {
    		param.put("queryId", "sys.faq.update_faqM");
    		result = commonService.update(param);
    	}else {
    		param.put("queryId", "sys.faq.delete_faqM");
    		result = commonService.delete(param);
    		
    		param.put("queryId", "sys.faq.delete_connect_faqM");
    		commonService.delete(param);
    	}
		
		
		return result;
	}
	
	
	/*자주하는질문 관리*/
	@Transactional
	public int faq(CommonMap param) throws Exception {
		List<CommonMap> list = param.getList("list");
    	int result = 0;
    	
    	if("".equals(param.getString("qCode"))) {
			
    		param.put("queryId", "sys.faq.select_faq_new_key");
    		CommonMap newKey = commonService.selectOne(param);    		
    		param.put("faqNewKey", newKey.getString("faqNewKey"));

    		param.put("queryId", "sys.faq.select_faq_order");
    		CommonMap maxOrder = commonService.selectOne(param);
    		param.put("faqOrder", maxOrder.getInt("faqOrder"));
        	
        	param.put("queryId", "sys.faq.insert_faqQ");
    		result = commonService.insert(param);	
    		
    		param.put("queryId", "sys.faq.insert_faqR");
    		result = commonService.insert(param);
    	}else {
			
    		param.put("queryId", "sys.faq.select_u_faq_order");
    		CommonMap maxOrder = commonService.selectOne(param);
    		param.put("faqOrder", maxOrder.getInt("faqOrder"));
    		
    		param.put("queryId", "sys.faq.update_faqQ");
    		result = commonService.update(param);	
    		
    		param.put("queryId", "sys.faq.update_faqR");
    		result = commonService.update(param);
    	}
    	
		return result;
	}
	
	/*자주하는질문 관리*/
	@Transactional
	public int deleteFaq(CommonMap param) throws Exception {
		List<CommonMap> list = param.getList("list");
    	int result = 0;
    		
		param.put("queryId", "sys.faq.delete_faqQ");
		result = commonService.delete(param);	
		
		param.put("queryId", "sys.faq.delete_faqR");
		result = commonService.delete(param);
		
		return result;
	}
	
	/*자주하는질문 순서 변경*/
	@Transactional
	public int updateOrder(CommonMap param) throws Exception {
		List<CommonMap> list = param.getList("list");
    	int result = 0;
    	for(int i=0; i < list.size(); i++) {
			CommonMap item = list.get(i);
			item.put("queryId", "sys.faq.update_faqOrder");
			result = commonService.update(item);
    	}
	
		return result;
	}
	
	/*자주하는질문 카테고리 순서 변경*/
	@Transactional
	public int updateCategoryOrder(CommonMap param) throws Exception {
		List<CommonMap> list = param.getList("list");
    	int result = 0;
    	for(int i=0; i < list.size(); i++) {
			CommonMap item = list.get(i);
			item.put("queryId", "sys.faqOrderPopup.update_faqOrder");
			result = commonService.update(item);
    	}
	
		return result;
	}
	
	/* 옵션관리-전기자동차 신청 관리 */
	@Transactional
	public int optionManage(CommonMap param) throws Exception {
    	int result = 0;
    	param.put("queryId", "sys.optionManage.update_option");
		result = commonService.update(param);
    	
		return result;
	}
	
	/* 옵션관리-API 호출 여부 */
	@Transactional
	public int optionApiManage(CommonMap param) throws Exception {
    	int result = 0;
    	param.put("queryId", "sys.optionManage.update_option2");
		result = commonService.update(param);
    	
		return result;
	}
	

    /* API 미수신 알림 설정 변경 */
    public int optionManageParking(CommonMap param) throws Exception {
        List<CommonMap> list = param.getList("list");
        int result = 0;
        EncUtil enc = new EncUtil();

        for(int i=0; i < list.size(); i++) {
            CommonMap item = list.get(i);
            result = 0;

            if(item.getString("grdStateCol").equals("U")) {
                item.put("userIdEnc", enc.encrypt(item.getString("userId")), false);
                item.put("queryId", "sys.optionManage.update_ApiSmsRecvStatus");
                result = commonService.update(item);
                if(result < 1) return 0;
            }
        }

        return 1;
    }
    
    /* API 미수신 알림 메시지 변경*/
    public int optionManageMsg(CommonMap param) throws Exception {
        int result = 0;
        
        EncUtil enc = new EncUtil();
        param.put("userIdEnc", enc.encrypt(param.getString("userId")), false);
        param.put("queryId", "sys.optionManage.update_ApiSmsMessage");
        result = commonService.update(param);
        
        return result;
    }
    
    /* API 미수신 알림 수신자 목록 */
    public int optionManageReceiver(CommonMap param) throws Exception {
        int result = 0;
        EncUtil enc = new EncUtil();
        List<CommonMap> list = param.getList("list");
        
        for(int i = 0; i < list.size(); i++) {
            CommonMap row = list.get(i);
            CommonMap data = new CommonMap();
            
            data.put("userId", enc.encrypt(param.getString("userId")), false);
            data.put("grdHRecvPhone", enc.encrypt(row.getString("grdHRecvPhone")), false);
            data.put("grdRecvPhone", enc.encrypt(row.getString("grdRecvPhone")), false);
            data.put("grdRecvName", enc.encrypt(row.getString("grdRecvName")), false);
            data.put("grdUseYn", row.getString("grdUseYn"));
            
            if("C".equals(row.getString("grdStateCol"))) {
                data.put("queryId", "sys.optionManage.insert_ApiSmsReceiveUserInfo");
                result += commonService.insert(data);
            } else if("U".equals(row.getString("grdStateCol"))) {
                data.put("queryId", "sys.optionManage.update_ApiSmsReceiveUserInfo");
                result += commonService.update(data);
            } else if("D".equals(row.getString("grdStateCol"))) {
                data.put("queryId", "sys.optionManage.delete_ApiSmsReceiveUserInfo");
                result += commonService.delete(data);
            } else {
                continue;
            }
        }
        
        return result;
    }
}
