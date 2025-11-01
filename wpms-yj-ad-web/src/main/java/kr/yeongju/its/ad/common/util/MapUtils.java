package kr.yeongju.its.ad.common.util;

import java.util.ArrayList;
import java.util.Enumeration;
import java.util.Iterator;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import egovframework.rte.psl.dataaccess.util.CamelUtil;
import kr.yeongju.its.ad.common.dto.CommonMap;

public final class MapUtils {
    
    public static CommonMap parseRequest(HttpServletRequest request, boolean isCheckDecrypt, String encryptColumns, String shaEncColumns) {
        
        encryptColumns = encryptColumns == null ? "" : encryptColumns; // NULL 체크
        shaEncColumns = shaEncColumns == null ? "" : shaEncColumns; // NULL 체크
        
        // 암호화 처리를 진행할 지의 여부
        boolean isEncrypt = false;
        
        // 암호화( 할 데이터가 있다면 복호화 로직을 처리하지 않도록 함
        if(!"".equals(encryptColumns.trim())) {
            isCheckDecrypt = false;
            isEncrypt = true;
        }
        
        // 암호화 할 데이터가 있다면 복호화 로직을 처리하지 않도록 함
        if(!"".equals(shaEncColumns.trim())) {
            isCheckDecrypt = false;
            isEncrypt = true;
        }
        
        EncUtil enc = new EncUtil(); // 암호화 모듈
        String changeValue = "";
        
        CommonMap result = new CommonMap();
        String func = request.getParameter("func") == null ? "" : request.getParameter("func");
        
        Enumeration<String> e = request.getParameterNames();
        List<CommonMap> list = new ArrayList<CommonMap>();

        String _name = "_token,func,queryId,queryOrder,queryKey,keyCol,result,grid,baseData,dataType,objId,reqAction,enc_col,sha_col,";
        String[] checkbox = request.getParameterValues("checkbox");
        
        // req parser
        while (e.hasMoreElements()) {
            String name = (String) e.nextElement();
            String[] values = request.getParameterValues(name);
            
            if (values != null) {
                // header.
                if (values.length == 1 && !name.startsWith("grd_") && !name.endsWith("[]")) {
                    changeValue = values[0];
                    if(isCheckDecrypt) {
                        changeValue = enc.isCrypted(values[0]) ? enc.decrypt(values[0]) : changeValue;
                    }
                    if(isEncrypt && changeValue.trim().length() > 0) {
                        changeValue = encryptColumns.indexOf(name) > -1 ? enc.encrypt(changeValue) : changeValue;
                        changeValue = shaEncColumns.indexOf(name) > -1 ? enc.get(changeValue) : changeValue;
                    }
                    
                    result.put(name, changeValue, false);
                } else {
                    // select에서는 배열로 넘긴 파라메터값을 ArrayList로 처리(ibatis에서 iterator로 처리하기 위해서)
                    if ((func.startsWith("IQ") || func.startsWith("EX") || func.startsWith("PR")) && checkbox != null) {
                        ArrayList<String> alist = new ArrayList<String>();

                        for (int i=0; i < checkbox.length; i++) {
                            int chkNum = Integer.parseInt(checkbox[i]);
                            if (!name.equals("checkbox")) {
                                if(values[chkNum] != null && !values[chkNum].equals("")) {
                                    changeValue = values[chkNum];
                                    if(isCheckDecrypt) {
                                        changeValue = enc.isCrypted(values[chkNum]) ? enc.decrypt(values[chkNum]) : changeValue;
                                    }
                                    if(isEncrypt && changeValue.trim().length() > 0) {
                                        changeValue = encryptColumns.indexOf(name) > -1 ? enc.encrypt(changeValue) : changeValue;
                                        changeValue = shaEncColumns.indexOf(name) > -1 ? enc.get(changeValue) : changeValue;
                                    }
                                    alist.add(changeValue);
                                }
                            }
                            //  if(values[i] != null && !values[i].equals("")) alist.add(values[i]);
                        }
                        
                        result.put(name, alist, false);
                    } else {
                        // list
                        for (int i=0;i<values.length;i++){
                            if (list.size() <= i || list.get(i) == null){
                                CommonMap t_map = new CommonMap("index", i);
                                
                                list.add(t_map);
                            }
                            
                            changeValue = values[i];
                            if(isCheckDecrypt) {
                                changeValue = enc.isCrypted(values[i]) ? enc.decrypt(values[i]) : changeValue;
                            }
                            if(isEncrypt && changeValue.trim().length() > 0) {
                                changeValue = encryptColumns.indexOf(name) > -1 ? enc.encrypt(changeValue) : changeValue;
                                changeValue = shaEncColumns.indexOf(name) > -1 ? enc.get(changeValue) : changeValue;
                            }
                            
                            list.get(i).put(reverse2CamelCase(name).replace("[]", ""), changeValue, false);
                        }
                    }
                }
            }           
        }

        //세션 추가
        HttpSession session = request.getSession();
        Enumeration<String> attrNames = session.getAttributeNames();
          
        while(attrNames.hasMoreElements()){
            String attrName = attrNames.nextElement();
            Object attrValue = session.getAttribute(attrName);
            
            if(attrValue instanceof String) {
                
                changeValue = (String)attrValue;
                
                if(isCheckDecrypt) {
                    changeValue = enc.isCrypted(changeValue) ? enc.decrypt(changeValue) : changeValue;
                }
                if(isEncrypt && changeValue.trim().length() > 0) {
                    String camelCaseKey = CamelUtil.convert2CamelCase(attrName);
                    changeValue = encryptColumns.indexOf(camelCaseKey) > -1 ? enc.encrypt(changeValue) : changeValue;
                    changeValue = shaEncColumns.indexOf(camelCaseKey) > -1 ? enc.get(changeValue) : changeValue;
                }
                
                result.put(attrName, changeValue, false);
            } else {
                result.put(attrName, attrValue, false);
            }
        }

        
        // header parser --> list copy
        if (list.size() > 0) {
            Iterator iter = result.keySet().iterator();
            
            while(iter.hasNext()){
                String keyname = (String)iter.next();
                if(_name.indexOf(keyname+",")>-1) continue;
                
                for(int i=0; i<list.size(); i++){
                    list.get(i).put(keyname, result.get(keyname), false);
                }
            }
            
            result.put("list", list, false);
        } else {
            
        }
        
        
        return result;
    }
    
    public static CommonMap parseRequest(HttpServletRequest request, boolean isCheckDecrypt, String encryptColumns) {
        return MapUtils.parseRequest(request, isCheckDecrypt, encryptColumns, "");
    }
    
    public static CommonMap parseRequest(HttpServletRequest request, String encryptColumns) {
        // 문자열의 형태로 암호화 할 값의 키를 콤마로 구분하여 넣으면
        // 해당 키의 값을 암호화하여 넣어주도록 함
        return MapUtils.parseRequest(request, false, encryptColumns);
    }

	public static CommonMap parseRequest(HttpServletRequest request) {
	    // 복호화가 가능하면 복호화를 진행하도록 한다.
	    return MapUtils.parseRequest(request, true, "");
//		CommonMap result = new CommonMap();
//		String func = request.getParameter("func") == null ? "" : request.getParameter("func");
//		
//		Enumeration<String> e = request.getParameterNames();
//		List<CommonMap> list = new ArrayList<CommonMap>();
//
//		String _name = "_token,func,queryId,queryOrder,queryKey,keyCol,result,grid,baseData,dataType,objId,reqAction,";
//		String[] checkbox = request.getParameterValues("checkbox");
//		
//		// req parser
//		while (e.hasMoreElements()) {
//			String name = (String) e.nextElement();
//			String[] values = request.getParameterValues(name);
//			
//			if (values != null) {
//				// header.
//				if (values.length == 1 && !name.startsWith("grd_") && !name.endsWith("[]")) {
//					result.put(name, values[0]);
//				} else {
//					// select에서는 배열로 넘긴 파라메터값을 ArrayList로 처리(ibatis에서 iterator로 처리하기 위해서)
//					if ((func.startsWith("IQ") || func.startsWith("EX") || func.startsWith("PR")) && checkbox != null) {
//						ArrayList<String> alist = new ArrayList<String>();
//
//						for (int i=0; i < checkbox.length; i++) {
//							int chkNum = Integer.parseInt(checkbox[i]);
//							if (!name.equals("checkbox")) {
//								if(values[chkNum] != null && !values[chkNum].equals("")) alist.add(values[chkNum]);
//							}
//							//	if(values[i] != null && !values[i].equals("")) alist.add(values[i]);
//						}
//					    
//						result.put(name, alist);
//					} else {
//						// list
//						for (int i=0;i<values.length;i++){
//							if (list.size() <= i || list.get(i) == null){
//								CommonMap t_map = new CommonMap("index", i);
//								
//								list.add(t_map);
//							}
//							
//							list.get(i).put(reverse2CamelCase(name).replace("[]", ""), values[i]);
//						}
//					}
//				}
//			}			
//		}
//
//		//세션 추가
//		HttpSession session = request.getSession();
//		Enumeration<String> attrNames = session.getAttributeNames();                
//	      
//	    while(attrNames.hasMoreElements()){
//	    	String attrName = attrNames.nextElement();
//            Object attrValue = session.getAttribute(attrName);
//            result.put(attrName, attrValue);
//	    }
//
//		
//		// header parser --> list copy
//		if (list.size() > 0) {
//			Iterator iter = result.keySet().iterator();
//			
//			while(iter.hasNext()){
//				String keyname = (String)iter.next();
//				if(_name.indexOf(keyname+",")>-1) continue;
//				
//				for(int i=0; i<list.size(); i++){
//					list.get(i).put(keyname, result.get(keyname));
//				}
//			}
//			
//			result.put("list", list);
//		} else {
//			
//		}
//		
//		
//		return result;
	}
	
	public static CommonMap parseSession(HttpSession session) {
		CommonMap result = new CommonMap();
		Enumeration<String> attrNames = session.getAttributeNames();                
	      
	    while(attrNames.hasMoreElements()){
	    	String attrName = attrNames.nextElement();
            Object attrValue = session.getAttribute(attrName);
            result.put(attrName, attrValue);
	    }
		
	    return result;
	}
	
	public static CommonMap parseList(List<CommonMap> list) {
		CommonMap result = new CommonMap();
		
		if (list == null) return result;
		for (int i=0; i<list.size(); i++) {
			result.put(i, "" + i, list.get(i));
		}
		
		return result; 
	}
	
	public static String reverse2CamelCase(String camel) {
		String regex = "([a-z])([A-Z]+)"; 
		String replacement = "$1_$2"; 
		
		return camel.replaceAll(regex, replacement).toLowerCase();
	}
}
