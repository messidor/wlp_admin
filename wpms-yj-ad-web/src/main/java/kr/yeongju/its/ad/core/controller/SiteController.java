package kr.yeongju.its.ad.core.controller;

import java.util.ArrayList;
import java.util.List;

import javax.annotation.Resource;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

import com.fasterxml.jackson.databind.ObjectMapper;

import egovframework.rte.fdl.property.EgovPropertyService;
import kr.yeongju.its.ad.common.dto.CommonMap;
import kr.yeongju.its.ad.common.util.AuthUtils;
import kr.yeongju.its.ad.common.util.MapUtils;
import kr.yeongju.its.ad.core.service.CommonService;


@Controller
public class SiteController {

	@Resource(name = "commonService")
	private final CommonService commonService;
	
	@Resource(name="propertyService")
    protected EgovPropertyService propertyService;

	
    @Autowired(required = true)
    public SiteController(CommonService commonService) {
        this.commonService = commonService;
    }
	
    /**
     * home 화면
     */
    @RequestMapping(value = "/index.do", method = RequestMethod.GET)
    public String index(HttpSession session,
						Model model) {
    	menu(session, model, "/index.do");
    	
        return "/core/index";
    }
    
    /**
     * 정보수정 화면
     */
    @RequestMapping(value = "/userInfo.do", method = RequestMethod.GET)
    public String userInfo(HttpSession session,
						Model model) {
    	menu(session, model, "/userInfo.do");
    	
        return "/core/userInfo";
    }
    
    /**
     * 403
     */
    @RequestMapping(value = "/403.do", method = RequestMethod.GET)
    public String forbidden(HttpSession session,
							Model model) {
    	
        return "/core/static/403";
    }

    /**
     * 404
     */
    @RequestMapping(value = "/404.do", method = RequestMethod.GET)
    public String notFound(HttpSession session,
						   Model model) {
        
        return "/core/static/404";
    }

    /**
     * 500
     */
    @RequestMapping(value = "/500.do", method = RequestMethod.GET)
    public String error(HttpSession session,
						Model model) {
        
        return "/core/static/500";
    }
    

    /**
     * route
     */    
    @RequestMapping(value = "/{route1}/{route2}.do", method = RequestMethod.GET)
    public String route(@PathVariable("route1") String route1,
			    		@PathVariable("route2") String route2,
                        HttpSession session,
						Model model) {
    	
        String redirectDomain = propertyService.getString("domain");
        String url = String.format("/%s/%s.do", route1, route2);
        CommonMap param = MapUtils.parseSession(session);
        List<CommonMap> authList = AuthUtils.getList(param, url);
        if (authList.size() > 0) {
        	session.setAttribute("user_menu_auth", authList);
        } else {
            String menuUrl = "";
            
            if (!StringUtils.isEmpty(menuUrl)) {
                authList = AuthUtils.getList(param, menuUrl);

                if (authList.size() > 0) {
                	session.setAttribute("user_menu_auth", authList);
                } else {
                    // return "redirect:" + redirectDomain + "/";
                    return "redirect:/403.do";
                }
            } else {
                // return "redirect:" + redirectDomain + "/";
                return "redirect:/403.do";
            }
        }
        String userUrl = propertyService.getString("userUrl");
        String apiUrl = propertyService.getString("apiUrl");
        model.addAttribute("userUrl", userUrl);
        model.addAttribute("apiUrl", apiUrl);
        menu(session, model, url);
        return String.format("/proj/%s/%s", route1, route2);
    }

    /**
     * 출력부분
     */
    @RequestMapping(value = "/print/{route1}/{route2}.do", method = RequestMethod.GET)
    private String print(@PathVariable("route1") String route1,
			    		 @PathVariable("route2") String route2,
			    		 HttpServletRequest request,
			             HttpSession session,
			             Model model) {

        String redirectDomain = propertyService.getString("domain");
        String url = String.format("/print/%s/%s.do", route1, route2);
		CommonMap param = MapUtils.parseRequest(request);
        List<CommonMap> authList = AuthUtils.getList(param, url);
        
        if (authList.size() > 0) {
        	session.setAttribute("user_menu_auth", authList);
        } else {
            String menuUrl = "";
            
            if (!StringUtils.isEmpty(menuUrl)) {
                authList = AuthUtils.getList(param, menuUrl);

                if (authList.size() > 0) {
                	session.setAttribute("user_menu_auth", authList);
                } else {
                	return "redirect:" + redirectDomain + "/";
                }
            } else {
            	return "redirect:" + redirectDomain + "/";
            }
        }
        
        if (param.has("deliNo")) {
        	CommonMap item = null;
        	List<CommonMap> list = null;
        	
        	try {
        		if(param.has("printGubn")){
        			param.put("WhCode", param.getString("hWhCode"));
        			param.put("queryId", "sales.shipmentByOrderPopup.select_ByOrderPrintItem");
            		item = commonService.selectOne(param);
            		param.put("queryId", "sales.shipmentByOrderPopup.select_ByOrderPrintList");
            		list = commonService.select(param);
        		}else{
        			param.put("queryId", "sales.shipment.select_shipmentPrint");
            		item = commonService.selectOne(param);
            		param.put("queryId", "sales.shipment.select_shipmentGridPrint");
            		list = commonService.select(param);
        		}
        	} catch(Exception e) {
        		e.printStackTrace();
        	}
			model.addAttribute("item", item);
			model.addAttribute("list", list);
        }
        
        if (param.has("purchaseNo")) {
        	CommonMap item = null;
        	List<CommonMap> list = null;
        	
        	try {
        		param.put("kPurchaseNo", param.getString("purchaseNo"));
        		param.put("queryId", "mtrl.purchasePopup.select_print_client_info");
        		item = commonService.selectOne(param);
        		param.put("queryId", "mtrl.purchasePopup.select_list2");
        		list = commonService.select(param);
        	} catch(Exception e) {
        		e.printStackTrace();
        	}
			model.addAttribute("item", item);
			model.addAttribute("list", list);
        }
        
        if (param.has("pInspectNo")) {
        	List<CommonMap> list = null;
        	
        	try {
        		param.put("queryId", "qc.completionInspectPopup.select_list2");
        		list = commonService.select(param);
        	} catch(Exception e) {
        		e.printStackTrace();
        	}
			model.addAttribute("list", list);
        }
        
        if (param.has("lotNo")) {
        	List<CommonMap> list = null;
        	
        	try {
        		param.put("queryId", "qc.completionInspectPopup.select_shipmentExcel");
        		list = commonService.select(param);
        	} catch(Exception e) {
        		e.printStackTrace();
        	}
			model.addAttribute("list", list);
        }
        
        return String.format("/proj/%s/%s", route1, route2);
    }
    
    private void menu(HttpSession session,
    				  Model model,
    				  String url) {

        CommonMap param = MapUtils.parseSession(session);
        List<CommonMap> menuList = new ArrayList<CommonMap>();
        List<CommonMap> topMenuList = new ArrayList<CommonMap>();
        
        try {
	        param.put("queryId", "common.select_menu");
	        menuList = commonService.select(param);
	        boolean isFound = false;

	        for (int i=0; i<menuList.size(); i++) { 
	        	CommonMap menu = menuList.get(i);
	        	
	        	if (menu.getInt("menuDepth") == 1) {
	        		if (!isFound) {
	        			model.addAttribute("topMenuId", menu.getString("menuId"));
	        		}
	        		topMenuList.add(menu);
	        	}
	        	if (isFound) continue;
	        	if (url.equals(menu.getString("menuUrl")) && menu.has("menuUrl")) {
        			model.addAttribute("menuName", menu.getString("menuName"));
        			model.addAttribute("menuStr", menu.getString("menuNameStr"));
        			model.addAttribute("menuId", menu.getString("menuId"));
        			model.addAttribute("parentMenuId", menu.getString("parentMenuId"));
        			isFound = true;
	        	}
	        }
        	if (!isFound) {
    			model.addAttribute("menuName", "");
    			model.addAttribute("topMenuId", 0);
        	}
        	
			model.addAttribute("menuList", menuList);
			model.addAttribute("topMenuList", topMenuList);
        } catch (Exception e) {
        }
    }
    
    /**
     * route
     */
    @RequestMapping(value = "/pop/{route1}/{route2}.do", method = RequestMethod.GET)
    public String popRoute(@PathVariable("route1") String route1,
    		            @PathVariable("route2") String route2,
                        HttpSession session,
						Model model) {

		model.addAttribute("menu_group", route1);

        return String.format("/proj/pop/%s/%s", route1, route2);
    }
    
    /**
     * _key
     */
    @RequestMapping(value = "/_key/{route1}.do", method = RequestMethod.GET)
    public String keyRoute(@PathVariable("route1") String route1,
                        HttpSession session,
                        Model model) {

        CommonMap param = MapUtils.parseSession(session);
        model.addAttribute("param", param);

        return String.format("/_key/%s", route1);
    }
}