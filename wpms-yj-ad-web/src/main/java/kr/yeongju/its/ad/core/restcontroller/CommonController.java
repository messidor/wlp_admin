package kr.yeongju.its.ad.core.restcontroller;

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
import kr.yeongju.its.ad.common.util.MapUtils;
import kr.yeongju.its.ad.core.service.CommonService;

@RestController
public class CommonController {

	@Resource(name = "commonService")
	private CommonService commonService;
    

    /**
     * 공통 select
     * @throws Exception 
     */
	@RequestMapping(value = "/common_select.do", method = RequestMethod.POST)
    public List<CommonMap> select(HttpServletRequest request) throws Exception {
		List<CommonMap> result = new ArrayList<CommonMap>();
    	
    	try {
    		CommonMap param = MapUtils.parseRequest(request, false, request.getParameter("enc_col"), request.getParameter("sha_col"));
    		
    		result = commonService.select(param);
    	} catch (Exception e) {
    		e.printStackTrace();
    	} finally {
    	}
    	
        return result;
    }
	
    /**
     * 공통 select
     * @throws Exception 
     */
	@RequestMapping(value = "/common_autocomplete.do", method = RequestMethod.POST)
    public CommonMap autocomplete(HttpServletRequest request) throws Exception {
		CommonMap result = new CommonMap();
    	
    	try {
    		CommonMap param = MapUtils.parseRequest(request);
    		
    		result.put("data", commonService.select(param));
    		result.put("q", param.get("q"));
    	} catch (Exception e) {
    		e.printStackTrace();
    	} finally {
    	}

        return result;
    }

    /**
     * 공통 insert, update, delete
     * @throws Exception 
     */
	@RequestMapping(value = "/common_insert.do", method = RequestMethod.POST)
    public ResultInfo insert(HttpServletRequest request) throws Exception {
    	String msg = "";
    	int result = 0;
    	CommonMap data = new CommonMap();
    	
    	try {
    		CommonMap param = MapUtils.parseRequest(request, false, request.getParameter("enc_col"), request.getParameter("sha_col"));
    		List<CommonMap> list = param.getList("list");
    		boolean isGrid = false;
    		
    		int success = 0;
    		int total = 0;  
    		
    		if (list.size() == 0) {
    			total = 1;
    			
    			if (param.getString("func").startsWith("IS") && param.has("queryKey")) {
    				CommonMap keyParam = MapUtils.parseRequest(request);
    				keyParam.put("queryId", param.getString("queryKey"));
    				
    				CommonMap keyMap = commonService.selectOne(keyParam);
    				
    				if (!keyMap.has(param.getString("keyCol"))) {
    					throw new NotFoundException("keyCol을 찾을 수 없습니다.");
    				} else {
    					param.put(param.getString("keyCol"), keyMap.getString(param.getString("keyCol")));
    				}
    			}
    			
    			if (param.getString("func").startsWith("IS")) {
    				success = commonService.insert(param);
    			} else if (param.getString("func").startsWith("UP")) {
    				success = commonService.update(param);
    			} else if (param.getString("func").startsWith("DL")) {
    				success = commonService.delete(param);
    			}
    		} else {
        		String queryId = param.getString("queryId").substring(param.getString("queryId").lastIndexOf(".") + 1);
        		String nameSpace = param.getString("queryId").replace(queryId, "");
        		String mdNewKey = "";
        		
        		if (queryId.startsWith("grid_")) {
        			isGrid = true;
        			queryId = queryId.substring(5);
        		}		
        		
        		if (param.has("queryMst") && param.getString("func").startsWith("MD")) {
        			total = 1;

        			if (param.has("queryKeyMst")) {
        				param.put("queryId", param.getString("queryKeyMst"));
        				mdNewKey = commonService.selectOne(param).getString(param.getString("keyColMst"));
        				
        				param.put(param.getString("keyColMst"), mdNewKey);
        			}

        			param.put("queryId", param.getString("queryMst"));
					success += commonService.insert(param);	
        		}
        		
        		for(int idx=0; idx<list.size(); idx++) {
        			CommonMap item = list.get(idx);
        			String stateCol = item.getString("grdStateCol");

        			item.put(param.getString("keyColMst"), mdNewKey);
        			item.put("queryId", queryId);
        			item.put("nameSpace", nameSpace);
        			
        			total++;
        			if (item.isEmpty("grdStateCol")) {
        				success++;
        			} else {
            			
            			/*
            			 * TODO: updateCheck, insertCheck, deleteCheck 관련 체크사항에 대한 로직 구현
            			 */
            			
            			if ("C".equals(stateCol) && param.has("queryKey")) {
            				CommonMap keyParam = MapUtils.parseRequest(request);
            				keyParam.put("queryId", param.getString("queryKey"));
            				
            				CommonMap keyMap = commonService.selectOne(keyParam);
            				
            				if (!keyMap.has(param.getString("keyCol"))) {
            					throw new NotFoundException("keyCol을 찾을 수 없습니다.");
            				} else {
                				item.put(param.getString("keyCol"), keyMap.getString(param.getString("keyCol")));
            				}
            			}

            			if ("C".equals(stateCol) && param.has("queryKey2")) {
            				CommonMap keyParam = MapUtils.parseRequest(request);
            				keyParam.put("queryId", param.getString("queryKey2"));
            				
            				CommonMap keyMap = commonService.selectOne(keyParam);
            				
            				if (!keyMap.has(param.getString("keyCol2"))) {
            					throw new NotFoundException("keyCol2을 찾을 수 없습니다.");
            				} else {
                				item.put(param.getString("keyCol2"), keyMap.getString(param.getString("keyCol2")));
            				}
            			}
            			
            			try {
            				switch (stateCol) {
            					case "C" :
            						success += isGrid ? commonService.gridInsert(item) : commonService.insert(item);
            						break;
            					case "U" :
                                    if (item.has("grdIncludeValue")) {
                                       if ("Y".equals(item.getString("grdIncludeValue"))) {
                                            success += isGrid ? commonService.gridInsert(item) : commonService.insert(item);
                                       } else {
                                            success += isGrid ? commonService.gridDelete(item) : commonService.delete(item);
                                       }
                                    } else {
                                        success += isGrid ? commonService.gridUpdate(item) : commonService.update(item);                                 
                                    }
                                    
            						break;
            					case "D" :
            						success += isGrid ? commonService.gridDelete(item) : commonService.delete(item);
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
    		}
    		
    		if (param.has("queryOrder")) {
        		for(int i=0; i<list.size(); i++) {
        			CommonMap map = list.get(i);
        			map.put("queryId", param.getString("queryOrder"));
        			map.put("index", i);
        			commonService.update(map);
        		}
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
     * 공통코드 to JSON
     * @throws Exception 
     */
	@RequestMapping(value = "/comcode.do", method = RequestMethod.POST)
    public ResultInfo comcode(HttpServletRequest request) throws Exception {
    	String msg = "";
    	int result = 0;
    	CommonMap data = new CommonMap();
    	try {
    		CommonMap param = MapUtils.parseRequest(request); 
    		List<CommonMap> loginData = commonService.select("Select_CompList", param);
    		
    	} catch (Exception e) {
    		result = 0;
    		msg = "오류가 발생하였습니다.";
    		
    		e.printStackTrace();
    	} finally {
    	}
    	
        return ResultInfo.of(msg, result, data);
    }
}
