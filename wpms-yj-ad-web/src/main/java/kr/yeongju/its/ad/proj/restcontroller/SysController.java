package kr.yeongju.its.ad.proj.restcontroller;

import java.io.Console;
import java.util.ArrayList;
import java.util.List;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

import kr.yeongju.its.ad.common.dto.CommonMap;
import kr.yeongju.its.ad.common.dto.ResultInfo;
import kr.yeongju.its.ad.common.exception.NotFoundException;
import kr.yeongju.its.ad.common.util.EncUtil;
import kr.yeongju.its.ad.common.util.KeyGenUtil;
import kr.yeongju.its.ad.common.util.MapUtils;
import kr.yeongju.its.ad.core.service.CommonService;
import kr.yeongju.its.ad.proj.service.SysService;

@RestController
@RequestMapping(value = "/sys")
public class SysController {

	@Resource(name = "commonService")
	private CommonService commonService;
	
	@Resource(name = "sysService")
	private SysService sysService;
	
	/**
     * 메뉴 관리
     * @throws Exception 
     */
	@RequestMapping(value = "/menu.do", method = RequestMethod.POST)
    public ResultInfo insertMenu(HttpServletRequest request) throws Exception {
    	String msg = "";
    	int result = 0;
    	CommonMap data = new CommonMap();

    	try {
    		CommonMap param = MapUtils.parseRequest(request, false, request.getParameter("enc_col")); 
    		List<CommonMap> list = param.getList("list");
    		
    		int success = 0;
    		int total = 0;
    		
    		param.put("queryId", "sys.menu.update_parentMenuId");
    		total++;
    		success += commonService.update(param);
    		
			for(int i=0; i<list.size(); i++) {
    			CommonMap map = list.get(i);
    			map.put("queryId", "sys.menu.update_eachMenuOrder");
    			map.put("index", i);
    			success += commonService.update(map);
    		}
			
			param.put("queryId", "sys.menu.update_menuOrder");
			total++;
			success += commonService.update(param);
    		
    		if (total <= success && total > 0) {
    			msg = "정상적으로 처리되었습니다.";
        		result = 1;
    		} else if (total <= 0) {
    			msg = "정상적으로 처리되지 않았습니다.";
    		} else {
    			msg ="정상적으로 처리되지 않았습니다.";
    		}
    		
    	} catch (NotFoundException e) {
    		msg = e.getMessage();
    		result = 0;
    	} catch (Exception e) {
    		result = 0;
    		msg = String.format("%s (%s)", "오류가 발생하였습니다.", e.getMessage());
    		
    		e.printStackTrace();
    	} catch (Throwable ex) {
    		msg = ex.getMessage();
    		result = 0;
    	}

        return ResultInfo.of(msg, result, data);
    }
	
	/**
     * 메뉴별 버튼 정의
     * @throws Exception 
     */
	@RequestMapping(value = "/menuBtn.do", method = RequestMethod.POST)
    public ResultInfo menuBtn(HttpServletRequest request) throws Exception {
    	String msg = "";
    	int result = 0;
    	CommonMap data = new CommonMap();

    	try {
    		CommonMap param = MapUtils.parseRequest(request, false, request.getParameter("enc_col")); 
    		List<CommonMap> list = param.getList("list");
        	EncUtil enc = new EncUtil();
    		
    		int success = 0;
    		int total = 0;    	
    		
    		for(int idx=0; idx < list.size(); idx++) {
    			CommonMap item = list.get(idx);
    			String stateCol = item.getString("grdStateCol");
				item.put("userId", enc.encrypt(param.getString("userId")), false);		
    			item.put("queryId", "data");
    			item.put("nameSpace", "sys.menuBtn.");
    			
    			total++;
    			if (item.isEmpty("grdStateCol")) {
    				success++;
    			} else {
        			try {
        				switch (stateCol) {
        					case "U" :        				
        						if ("Y".equals(item.getString("grdIncludeValue"))) {
                                    success += commonService.gridInsert(item);
                               } else {
                                    commonService.gridDelete(item);
                                    success++;
                               }
        						break;
        					default :;
        				}
        			} catch (Exception e) {
        	    		result = 0;
        	    		msg = String.format("%s (%s)", "오류가 발생하였습니다.", e.getMessage());
        	    		
        	    		e.printStackTrace();
        	    	}
    			}
    		}
    		
    		if (total <= success && total > 0) {
    			msg = "정상적으로 처리되었습니다.";
        		result = 1;
    		} else if (total > success && total > 0) {
    			msg = String.format("%s (%d / %d)", "정상적으로 처리되지 않았습니다.", total - success, total);
    		} else if (total <= 0) {
    			msg = "정상적으로 처리되지 않았습니다.";
    		} else {
    			msg = "정상적으로 처리되지 않았습니다.";
    		}
    		
    	} catch (NotFoundException e) {
    		msg = e.getMessage();
    		result = 0;
    	} catch (Exception e) {
    		result = 0;
    		msg = String.format("%s (%s)", "오류가 발생하였습니다.", e.getMessage());
    		
    		e.printStackTrace();
    	}

        return ResultInfo.of(msg, result, data);
    }
	
    /**
     * 부서 관련
     * @throws Exception 
     */
	@RequestMapping(value = "/dept.do", method = RequestMethod.POST)
    public ResultInfo insert(HttpServletRequest request) throws Exception {
    	String msg = "";
    	int result = 0;
    	CommonMap data = new CommonMap();

    	try {
    		CommonMap param = MapUtils.parseRequest(request, false, request.getParameter("enc_col")); 
    		List<CommonMap> list = param.getList("list");
    		
    		int success = 0;
    		int total = 0;    		
    		
    		for(int idx=0; idx<list.size(); idx++) {
    			CommonMap item = list.get(idx);
    			String stateCol = item.getString("grdStateCol");
    			
    			item.put("queryId", "dept");
    			item.put("nameSpace", "sys.dept.");
    			total++;
    			if (stateCol.trim().isEmpty()) {
    				success++;
    			} else {
    				if ("C".equals(stateCol)) {
	    				CommonMap keyMap = commonService.selectOne(new CommonMap("queryId", "sys.dept.select_newKey"));
	    				item.put("grdDeptId", keyMap.getString("grdDeptId"));
    				}
        			
        			try {
        				switch (stateCol) {
        					case "C" :
        						success += commonService.gridInsert(item);
        						break;
        					case "U" :
        						if (!"Y".equals(item.getString("grdUseYn"))) {
        			    			item.put("runOnce", true);
        						}
        						
        						success += commonService.gridUpdate(item);
        						break;
        					case "D" :
        						success += commonService.gridDelete(item);
        						break;
        					default :;
        				}
        			} catch (Exception e) {
        	    		result = 0;
        	    		msg = String.format("%s (%s)", "오류가 발생하였습니다.", e.getMessage());
        	    		
        	    		e.printStackTrace();
        	    	}
    				
    			}
    		}
    		
    		for(int i=0; i<list.size(); i++) {
    			CommonMap map = list.get(i);
    			map.put("queryId", "sys.dept.update_order");
    			map.put("index", i);
    			commonService.update(map);
    		}
    		
    		if ((total <= success && total > 0) || (param.has("queryOrder") && total < 1)) {
    			msg = "정상적으로 처리되었습니다.";
        		result = 1;
    		} else if (total > success && total > 0) {
    			msg = String.format("%s (%d / %d)", "정상적으로 처리되지 않았습니다.", total - success, total);
    		} else if (total <= 0) {
    			msg = "정상적으로 처리되지 않았습니다.";
    		} else {
    			msg = "정상적으로 처리되지 않았습니다.";
    		}
    		
    	} catch(NotFoundException e) {
    		msg = e.getMessage();
    		result = 0;
    	} catch (Exception e) {
    		result = 0;
    		msg = String.format("%s (%s)", "오류가 발생하였습니다.", e.getMessage());
    		
    		e.printStackTrace();
    	}

        return ResultInfo.of(msg, result, data);
    }
	
	/**
     * 그룹권한 코드 관리
     * @throws Exception 
     */
	@RequestMapping(value = "/role.do", method = RequestMethod.POST)
    public ResultInfo insertRole(HttpServletRequest request) throws Exception {
    	String msg = "";
    	int result = 0;
    	CommonMap data = new CommonMap();

    	try {
    		CommonMap param = MapUtils.parseRequest(request, false, request.getParameter("enc_col")); 
    		List<CommonMap> list = param.getList("list");
    		
    		int success = 0;
    		int total = 0;    	
    		
    		for(int idx=0; idx < list.size(); idx++) {
    			CommonMap item = list.get(idx);
    			List<CommonMap> rs = new ArrayList<CommonMap>();
    			String stateCol = item.getString("grdStateCol");
    			
    			item.put("queryId", "sys.role.select_duplicate");
    			
    			if("C".equals(stateCol)) {    				
    				rs = commonService.select(item);
    				
        			if(Integer.parseInt(rs.get(0).get("cnt").toString()) > 0) {
        				throw new Throwable("중복된 데이터가 존재합니다.(그룹코드 : " + item.getString("grdRoleId") + ")");
        			}
    			}
    		}
    		
    		for(int idx=0; idx < list.size(); idx++) {
    			CommonMap item = list.get(idx);
    			String stateCol = item.getString("grdStateCol");
    			
    			item.put("queryId", "role");
    			item.put("nameSpace", "sys.role.");
    			
    			total++;
    			if (item.isEmpty("grdStateCol")) {
    				success++;
    			} else {
        			
        			try {
        				switch (stateCol) {
        					case "C" :
        						success += commonService.gridInsert(item);
        						break;
        					case "U" :        						
        						success += commonService.gridUpdate(item);
        						break;
        					case "D" :
        						success += commonService.gridDelete(item);
        						break;
        					default :;
        				}
        			} catch (Exception e) {
        	    		result = 0;
        	    		msg = String.format("%s (%s)", "오류가 발생하였습니다.", e.getMessage());
        	    		
        	    		e.printStackTrace();
        	    	}
    				
    			}
    		}
    		
    		if (total <= success && total > 0) {
    			msg = "정상적으로 처리되었습니다.";
        		result = 1;
    		} else if (total > success && total > 0) {
    			msg = String.format("%s (%d / %d)", "정상적으로 처리되지 않았습니다.", total - success, total);
    		} else if (total <= 0) {
    			msg = "정상적으로 처리되지 않았습니다.";
    		} else {
    			msg = "정상적으로 처리되지 않았습니다.";
    		}
    		
    	} catch (NotFoundException e) {
    		msg = e.getMessage();
    		result = 0;
    	} catch (Exception e) {
    		result = 0;
    		msg = String.format("%s (%s)", "오류가 발생하였습니다.", e.getMessage());
    		
    		e.printStackTrace();
    	} catch (Throwable ex) {
    		msg = ex.getMessage();
    		result = 0;
    	}

        return ResultInfo.of(msg, result, data);
    }
	
	/**
     * 그룹권한 코드 관리
     * @throws Exception 
     */
	@RequestMapping(value = "/clientUser.do", method = RequestMethod.POST)
    public ResultInfo insertClientUser(HttpServletRequest request) throws Exception {
    	String msg = "";
    	int result = 0;
    	CommonMap data = new CommonMap();
    	EncUtil enc = new EncUtil();

    	try {
    		CommonMap param = MapUtils.parseRequest(request, false, request.getParameter("enc_col"), request.getParameter("sha_col"));  
    		List<CommonMap> list = param.getList("list");
    		
    		int success = 0;
    		int total = 0;
    		
    		for(int idx=0; idx < list.size(); idx++) {
    			CommonMap item = list.get(idx);
    			CommonMap p = list.get(idx);
    			String stateCol = item.getString("grdStateCol");
    			String password = item.getString("grdUserPw");
    			if("".equals(password)) {
    				p.put("grdUserPw", enc.get("1"), false);
    			}
    			
    			total++;
    			if (item.isEmpty("grdStateCol")) {
    				success++;
    			} else {
        			
        			try {
        				switch (stateCol) {
        					case "C" :
        						p.put("queryId", "sys.clientUser.insert_user");
        						success += commonService.insert(p);
        						
        						break;
        					case "U" :        	
        						p.put("queryId", "sys.clientUser.update_user");
        						success += commonService.update(p);
        						break;
        					case "D" :
        						p.put("queryId", "sys.clientUser.delete_user");
        						success += commonService.delete(p);
        						p.put("queryId", "sys.clientUser.delete_user_role");
        						commonService.delete(p);
        						
        						break;
        					default :;
        				}
        			} catch (Exception e) {
        	    		result = 0;
        	    		msg = String.format("%s (%s)", "오류가 발생하였습니다.", e.getMessage());
        	    		
        	    		e.printStackTrace();
        	    	}
    				
    			}
    		}
    		
    		if (total <= success && total > 0) {
    			msg = "정상적으로 처리되었습니다.";
        		result = 1;
    		} else if (total > success && total > 0) {
    			msg = String.format("%s (%d / %d)", "정상적으로 처리되지 않았습니다.", total - success, total);
    		} else if (total <= 0) {
    			msg = "정상적으로 처리되지 않았습니다.";
    		} else {
    			msg = "정상적으로 처리되지 않았습니다.";
    		}
    		
    	} catch (NotFoundException e) {
    		msg = e.getMessage();
    		result = 0;
    	} catch (Exception e) {
    		result = 0;
    		msg = String.format("%s (%s)", "오류가 발생하였습니다.", e.getMessage());
    		
    		e.printStackTrace();
    	} catch (Throwable ex) {
    		msg = ex.getMessage();
    		result = 0;
    	}

        return ResultInfo.of(msg, result, data);
    }
	
	/**
	 * SMS 카카오 알림톡
	 * @throws Exception 
	 */
	@RequestMapping(value = "/smsCertificationReqeust.do", method = RequestMethod.POST)
	public ResultInfo smsCertificationReqeust(HttpServletRequest request) throws Exception {
		String msg = "";
		int result = 1;
		CommonMap data = new CommonMap();
		
		try {
			int success_cnt = sysService.smsCertificationReqeust(MapUtils.parseRequest(request));
			
			if(success_cnt < 1){
				result = 0;
				msg = "승인된 회원을 승인 할 수 없습니다.";
			}else {
				msg = "정상적으로 처리되었습니다.";
			}
		} catch(NotFoundException e) {
			msg = e.getMessage();
			result = 0;
			
			e.printStackTrace();
			throw e;
		} catch (Exception e) {
			result = 0;
			msg = String.format("%s (%s)", "오류가 발생하였습니다.", e.getMessage());

			e.printStackTrace();
			throw e;
		}

		return ResultInfo.of(msg, result, data);
	}
	
	/**
	 * 감면 정보 관리
	 * @throws Exception 
	 */
	@RequestMapping(value = "/reductionManage.do", method = RequestMethod.POST)
	public ResultInfo reductionManage(HttpServletRequest request) throws Exception {
		String msg = "";
		int result = 1;
		CommonMap data = new CommonMap();
		
		try {
			int success_cnt = sysService.reductionManage(MapUtils.parseRequest(request));
			
			if(success_cnt < 1){
				result = 0;
				msg = "정상적으로 처리되지 않았습니다.";
			}else {
				msg = "정상적으로 처리되었습니다.";
			}
		} catch(NotFoundException e) {
			msg = e.getMessage();
			result = 0;
			
			e.printStackTrace();
			throw e;
		} catch (Exception e) {
			result = 0;
			msg = String.format("%s (%s)", "오류가 발생하였습니다.", e.getMessage());

			e.printStackTrace();
			throw e;
		}

		return ResultInfo.of(msg, result, data);
	}
	
	
	/**
	 * 감면 정보 관리
	 * @throws Exception 
	 */
	@RequestMapping(value = "/faqM.do", method = RequestMethod.POST)
	public ResultInfo faqM(HttpServletRequest request) throws Exception {
		String msg = "";
		int result = 1;
		CommonMap data = new CommonMap();
		
		try {
			int success_cnt = sysService.faqM(MapUtils.parseRequest(request));
			
			if(success_cnt < 1){
				result = 0;
				msg = "정상적으로 처리되지 않았습니다.";
			}else {
				msg = "정상적으로 처리되었습니다.";
			}
		} catch(NotFoundException e) {
			msg = e.getMessage();
			result = 0;
			
			e.printStackTrace();
			throw e;
		} catch (Exception e) {
			result = 0;
			msg = String.format("%s (%s)", "오류가 발생하였습니다.", e.getMessage());

			e.printStackTrace();
			throw e;
		}

		return ResultInfo.of(msg, result, data);
	}
	
	/**
	 * 감면 정보 관리
	 * @throws Exception 
	 */
	@RequestMapping(value = "/faq.do", method = RequestMethod.POST)
	public ResultInfo faq(HttpServletRequest request) throws Exception {
		String msg = "";
		int result = 1;
		CommonMap data = new CommonMap();
		
		try {
			int success_cnt = sysService.faq(MapUtils.parseRequest(request));
			
			if(success_cnt < 1){
				result = 0;
				msg = "정상적으로 처리되지 않았습니다.";
			}else {
				msg = "정상적으로 처리되었습니다.";
			}
		} catch(NotFoundException e) {
			msg = e.getMessage();
			result = 0;
			
			e.printStackTrace();
			throw e;
		} catch (Exception e) {
			result = 0;
			msg = String.format("%s (%s)", "오류가 발생하였습니다.", e.getMessage());

			e.printStackTrace();
			throw e;
		}

		return ResultInfo.of(msg, result, data);
	}
	
	/**
	 * 감면 정보 삭제
	 * @throws Exception 
	 */
	@RequestMapping(value = "/deleteFaq.do", method = RequestMethod.POST)
	public ResultInfo deleteFaq(HttpServletRequest request) throws Exception {
		String msg = "";
		int result = 1;
		CommonMap data = new CommonMap();
		
		try {
			int success_cnt = sysService.deleteFaq(MapUtils.parseRequest(request));
			
			if(success_cnt < 1){
				result = 0;
				msg = "정상적으로 처리되지 않았습니다.";
			}else {
				msg = "정상적으로 처리되었습니다.";
			}
		} catch(NotFoundException e) {
			msg = e.getMessage();
			result = 0;
			
			e.printStackTrace();
			throw e;
		} catch (Exception e) {
			result = 0;
			msg = String.format("%s (%s)", "오류가 발생하였습니다.", e.getMessage());

			e.printStackTrace();
			throw e;
		}

		return ResultInfo.of(msg, result, data);
	}
	
	/**
	 * 자주하는질문 리스트 순번 변경
	 * @throws Exception 
	 */
	@RequestMapping(value = "/updateOrder.do", method = RequestMethod.POST)
	public ResultInfo updateOrder(HttpServletRequest request) throws Exception {
		String msg = "";
		int result = 1;
		CommonMap data = new CommonMap();
		
		try {
			int success_cnt = sysService.updateOrder(MapUtils.parseRequest(request));
			
			if(success_cnt < 1){
				result = 0;
				msg = "정상적으로 처리되지 않았습니다.";
			}else {
				msg = "정상적으로 처리되었습니다.";
			}
		} catch(NotFoundException e) {
			msg = e.getMessage();
			result = 0;
			
			e.printStackTrace();
			throw e;
		} catch (Exception e) {
			result = 0;
			msg = String.format("%s (%s)", "오류가 발생하였습니다.", e.getMessage());

			e.printStackTrace();
			throw e;
		}

		return ResultInfo.of(msg, result, data);
	}
	
	/**
	 * 자주하는질문 리스트 카테고리 순번 변경
	 * @throws Exception 
	 */
	@RequestMapping(value = "/updateCategoryOrder.do", method = RequestMethod.POST)
	public ResultInfo updateCategoryOrder(HttpServletRequest request) throws Exception {
		String msg = "";
		int result = 1;
		CommonMap data = new CommonMap();
		
		try {
			int success_cnt = sysService.updateCategoryOrder(MapUtils.parseRequest(request));
			
			if(success_cnt < 1){
				result = 0;
				msg = "정상적으로 처리되지 않았습니다.";
			}else {
				msg = "정상적으로 처리되었습니다.";
			}
		} catch(NotFoundException e) {
			msg = e.getMessage();
			result = 0;
			
			e.printStackTrace();
			throw e;
		} catch (Exception e) {
			result = 0;
			msg = String.format("%s (%s)", "오류가 발생하였습니다.", e.getMessage());

			e.printStackTrace();
			throw e;
		}

		return ResultInfo.of(msg, result, data);
	}
	
	/* 옵션관리-전기자동차 신청 관리 */
	@RequestMapping(value = "/optionManage.do", method = RequestMethod.POST)
	public ResultInfo optionManage(HttpServletRequest request) throws Exception {
		String msg = "";
		int result = 1;
		CommonMap data = new CommonMap();
		
		try {
			int success_cnt = sysService.optionManage(MapUtils.parseRequest(request));
			
			if(success_cnt < 1){
				result = 0;
				msg = "정상적으로 처리되지 않았습니다.";
			}else {
				msg = "정상적으로 처리되었습니다.";
			}
		} catch(NotFoundException e) {
			msg = e.getMessage();
			result = 0;
			
			e.printStackTrace();
			throw e;
		} catch (Exception e) {
			result = 0;
			msg = String.format("%s (%s)", "오류가 발생하였습니다.", e.getMessage());

			e.printStackTrace();
			throw e;
		}

		return ResultInfo.of(msg, result, data);
	}
	
	/* 옵션관리-API 호출 여부 */
	@RequestMapping(value = "/optionApiManage.do", method = RequestMethod.POST)
	public ResultInfo optionApiManage(HttpServletRequest request) throws Exception {
		String msg = "";
		int result = 1;
		CommonMap data = new CommonMap();
		
		try {
			int success_cnt = sysService.optionApiManage(MapUtils.parseRequest(request));
			
			if(success_cnt < 1){
				result = 0;
				msg = "정상적으로 처리되지 않았습니다.";
			}else {
				msg = "정상적으로 처리되었습니다.";
			}
		} catch(NotFoundException e) {
			msg = e.getMessage();
			result = 0;
			
			e.printStackTrace();
			throw e;
		} catch (Exception e) {
			result = 0;
			msg = String.format("%s (%s)", "오류가 발생하였습니다.", e.getMessage());

			e.printStackTrace();
			throw e;
		}

		return ResultInfo.of(msg, result, data);
	}
	
    /**
     * 옵션관리 (미수신 알림 설정 그리드)
     * @throws Exception 
     */
    @RequestMapping(value = "/optionManageParking.do", method = RequestMethod.POST)
    public ResultInfo optionManageParking(HttpServletRequest request) throws Exception {
        String msg = "";
        int result = 1;
        CommonMap data = new CommonMap();
        
        try {
            int success_cnt = sysService.optionManageParking(MapUtils.parseRequest(request));
            
            if(success_cnt < 1){
                result = 0;
                msg = "정상적으로 처리되지 않았습니다.";
            }else {
                msg = "정상적으로 처리되었습니다.";
            }
        } catch(NotFoundException e) {
            msg = e.getMessage();
            result = 0;
            
            e.printStackTrace();
            throw e;
        } catch (Exception e) {
            result = 0;
            msg = String.format("%s (%s)", "오류가 발생하였습니다.", e.getMessage());

            e.printStackTrace();
            throw e;
        }

        return ResultInfo.of(msg, result, data);
    }
    
    /**
     * 옵션관리 (미수신 알림 메시지)
     * @throws Exception 
     */
    @RequestMapping(value = "/optionManageMsg.do", method = RequestMethod.POST)
    public ResultInfo optionManageMsg(HttpServletRequest request) throws Exception {
        String msg = "";
        int result = 1;
        CommonMap data = new CommonMap();
        
        try {
            int success_cnt = sysService.optionManageMsg(MapUtils.parseRequest(request));
            
            if(success_cnt < 1){
                result = 0;
                msg = "정상적으로 처리되지 않았습니다.";
            }else {
                msg = "정상적으로 처리되었습니다.";
            }
        } catch(NotFoundException e) {
            msg = e.getMessage();
            result = 0;
            
            e.printStackTrace();
            throw e;
        } catch (Exception e) {
            result = 0;
            msg = String.format("%s (%s)", "오류가 발생하였습니다.", e.getMessage());

            e.printStackTrace();
            throw e;
        }

        return ResultInfo.of(msg, result, data);
    }
    
    /**
     * 옵션관리 (미수신 알림 수신자 목록)
     * @throws Exception 
     */
    @RequestMapping(value = "/optionManageReceiver.do", method = RequestMethod.POST)
    public ResultInfo optionManageReceiver(HttpServletRequest request) throws Exception {
        String msg = "";
        int result = 1;
        CommonMap data = new CommonMap();
        
        try {
            int success_cnt = sysService.optionManageReceiver(MapUtils.parseRequest(request));
            
            if(success_cnt > 0){
                msg = "정상적으로 처리되었습니다.";
            }else {
                result = 0;
                msg = "정상적으로 처리되지 않았습니다.";
            }
        } catch(NotFoundException e) {
            msg = e.getMessage();
            result = 0;
            
            e.printStackTrace();
            throw e;
        } catch (Exception e) {
            result = 0;
            msg = String.format("%s (%s)", "오류가 발생하였습니다.", e.getMessage());

            e.printStackTrace();
            throw e;
        }

        return ResultInfo.of(msg, result, data);
    }
    
    /**
     * API관리
     * @throws Exception 
     */
	@RequestMapping(value = "/apiManage.do", method = RequestMethod.POST)
    public ResultInfo apiManage(HttpServletRequest request) throws Exception {
    	String msg = "";
    	int result = 0;
    	CommonMap data = new CommonMap();
    	EncUtil enc = new EncUtil();

    	try {
    		CommonMap param = MapUtils.parseRequest(request, false, request.getParameter("enc_col"), request.getParameter("sha_col"));  
    		List<CommonMap> list = param.getList("list");
    		
    		int success = 0;
    		int total = 0;
    		
    		for(int idx=0; idx < list.size(); idx++) {
    			CommonMap item = list.get(idx);
    			CommonMap p = list.get(idx);
    			String stateCol = item.getString("grdStateCol");
    			
    			total++;
    			if (item.isEmpty("grdStateCol")) {
    				success++;
    			} else {
        			
        			try {
        				switch (stateCol) {
        					case "C" :
        						// 서비스키 발급
        						KeyGenUtil kgu = new KeyGenUtil(); // 생성자
        						String sk = kgu.getServiceKey(); // 서비스 키
        						
        						p.put("serviceKey",sk);
        						p.put("userId", enc.encrypt(param.getString("userId")), false);
        						
        						p.put("queryId", "sys.apiManage.insert_api");
        						success += commonService.insert(p);
        						
        						break;
        					case "U" :        	
        						p.put("userId", enc.encrypt(param.getString("userId")), false);
        						p.put("queryId", "sys.apiManage.update_api");
        						success += commonService.update(p);
        						break;
        					case "D" :
        						p.put("userId", enc.encrypt(param.getString("userId")), false);
        						p.put("queryId", "sys.apiManage.delete_api");
        						success += commonService.delete(p);
        						
        						break;
        					default :;
        				}
        			} catch (Exception e) {
        	    		result = 0;
        	    		msg = String.format("%s (%s)", "오류가 발생하였습니다.", e.getMessage());
        	    		
        	    		e.printStackTrace();
        	    	}
    				
    			}
    		}
    		
    		if (total <= success && total > 0) {
    			msg = "정상적으로 처리되었습니다.";
        		result = 1;
    		} else if (total > success && total > 0) {
    			msg = String.format("%s (%d / %d)", "정상적으로 처리되지 않았습니다.", total - success, total);
    		} else if (total <= 0) {
    			msg = "정상적으로 처리되지 않았습니다.";
    		} else {
    			msg = "정상적으로 처리되지 않았습니다.";
    		}
    		
    	} catch (NotFoundException e) {
    		msg = e.getMessage();
    		result = 0;
    	} catch (Exception e) {
    		result = 0;
    		msg = String.format("%s (%s)", "오류가 발생하였습니다.", e.getMessage());
    		
    		e.printStackTrace();
    	} catch (Throwable ex) {
    		msg = ex.getMessage();
    		result = 0;
    	}

        return ResultInfo.of(msg, result, data);
    }
}
