package kr.yeongju.its.ad.proj.service;

import java.util.ArrayList;
import java.util.List;
import java.util.regex.Pattern;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartHttpServletRequest;

import kr.yeongju.its.ad.common.dto.CommonMap;
import kr.yeongju.its.ad.common.dto.ResultInfo;
import kr.yeongju.its.ad.common.util.EncUtil;
import kr.yeongju.its.ad.common.util.KeyGenUtil;
import kr.yeongju.its.ad.common.util.MapUtils;
import kr.yeongju.its.ad.core.controller.ExcelController;
import kr.yeongju.its.ad.core.restcontroller.UploadController;
import kr.yeongju.its.ad.core.service.CommonService;

@Service("parkService")
public class ParkServiceImpl implements ParkService {

	@Resource(name = "commonService")
	private CommonService commonService;
	
	/*주차장 회사 정보 저장*/
	@Transactional
	public int parkCompInsert(CommonMap param) throws Exception {
		int result = 0;
		
		if("".equals(param.getString("hCompCode"))) {
			// 주차장 회사 정보 입력
			param.put("queryId", "park.parkingCompManagePopup.insert_parkingCompInfo");
			result = commonService.insert(param);			
		}else {
			// param.put("queryId", "park.parkingCompManagePopup.select_useYn");
			// CommonMap useYn = commonService.selectOne(param);
			
			// String popUseYn = param.getString("useYn");
			// String selectUseYn = useYn.getString("USE_YN");
			
			if(param.getString("useYn").equals("N")) {
				
				// 해당 주차장 회사에 사용하는 주차장이 존재할때
				param.put("queryId", "park.parkingCompManagePopup.select_use_comp");
				CommonMap useCnt = commonService.selectOne(param);
				
				if(Integer.parseInt(useCnt.getString("useCnt")) > 0) {
					return -1;
				}
			}
			
			// 주차장 회사 정보 수정
			param.put("queryId", "park.parkingCompManagePopup.update_parkingCompInfo");
			result = commonService.update(param);
			result = 1;
		}
		
		return result;
	}
	
	/*주차장 회사 정보 삭제*/
	@Transactional
	public int parkCompUpdate(CommonMap param) throws Exception {
		int result = 0;
		
		// 해당 주차장 회사에 사용하는 주차장이 존재할때
		param.put("queryId", "park.parkingCompManagePopup.select_use_comp");
		CommonMap useCnt = commonService.selectOne(param);
			
		if(Integer.parseInt(useCnt.getString("useCnt")) > 0) {
			return -1;
		}else{
			// 주차장 관리 테이블에 주차장회사코드 제거
			param.put("queryId", "park.parkingCompManagePopup.update_parkingInfo");
			result = commonService.update(param);
			
			// 주차장 회사 관리 삭제
			param.put("queryId", "park.parkingCompManagePopup.delete_parkingCompInfo");
			result = commonService.delete(param);
			result = 1;
		}
		
		return result;
	}
	
	/*서비스키 발급*/
	@Transactional
	public int parkingServiceInfo(CommonMap param) throws Exception {
		
		KeyGenUtil kgu = new KeyGenUtil(); // 생성자
		String sk = kgu.getServiceKey(); // 서비스 키
		
		param.put("pServiceKey",sk);
		// 서비스키 발급
		param.put("queryId", "park.parkingCompManagePopup.update_parkingServiceInfo");
		commonService.update(param);
		
		return 1;
	}
	
	/*기관 저장 및 수정*/
	@Transactional
	public int parkGovInsert(CommonMap param) throws Exception {
		int result = 0;
		
		List<CommonMap> list = param.getList("list");
		
		// 이미 사용중인 통장일 경우
		for(int idx=0; idx < list.size(); idx++) {
			CommonMap item = list.get(idx);
			CommonMap p = list.get(idx);
			String stateCol = item.getString("grdStateCol");
			
			try {
				switch (stateCol) {
				case "D" :
					p.put("queryId", "park.parkingGovManagePopup.select_govBankInfo");
					CommonMap cnt = commonService.selectOne(p);
					
					if(Integer.parseInt(cnt.getString("accountCnt")) > 0){
						return -2;
					}
					
					break;
					default :;
				}
			} catch (Exception e) {
	    		result = 0;    	    		
	    		e.printStackTrace();
	    	}
			
		}
		
		// 주차장 기관 코드 생성
		param.put("queryId", "park.parkingGovManagePopup.select_new_gov_key");
		CommonMap newGovCode = commonService.selectOne(param);
		
		if("".equals(param.getString("hGovCode"))) {
			// 주차장 기관 정보 입력
			param.put("newGovCode", newGovCode.getString("newParkingGovCode"));
			param.put("queryId", "park.parkingGovManagePopup.insert_list");
			result = commonService.insert(param);			
		}else {
			
			// 사용 -> 미사용으로 변경 확인
			param.put("queryId", "park.parkingGovManagePopup.select_useYnGov");
			CommonMap useYn = commonService.selectOne(param);
			
			if(param.getString("useYn").equals("N") && useYn.getString("useYn").equals("Y")) {
			// 해당 주차장 회사에 사용하는 주차장이 존재할때
			param.put("queryId", "park.parkingGovManagePopup.select_useGov");
			CommonMap useCnt = commonService.selectOne(param);
			
			if(Integer.parseInt(useCnt.getString("useCnt")) > 0) {
				//주차장이 있으면 
				return -1;
			}
			
			//셀렉트를 변경했는데 데이터베이스가 이미 변경되어서 같아지는 경우
			if(param.getString("useYnUupdate").equals("T")) {
				if(param.getString("useYn").equals("Y") && useYn.getString("useYn").equals("Y")) {
					return -2;
				}
					
				if(param.getString("useYn").equals("N") && useYn.getString("useYn").equals("N")) {
					return -2;
				}
			}
			}
			
			// 주차장 기관 정보 수정
			param.put("queryId", "park.parkingGovManagePopup.update_list");
			result = commonService.update(param);
		}
		
		int total = 0;
		
		for(int idx=0; idx < list.size(); idx++) {
			CommonMap item = list.get(idx);
			CommonMap p = list.get(idx);
			String stateCol = item.getString("grdStateCol");
			
			if (item.isEmpty("grdStateCol")) {
				
			} else {
    			
    			try {
    				switch (stateCol) {
    					case "C" :
    						if("".equals(param.getString("hGovCode"))) {
    							p.put("newGovCode", newGovCode.getString("newParkingGovCode"));
    						}else {
    							p.put("newGovCode", param.getString("hGovCode"));
    						}
    						
    						p.put("queryId", "park.parkingGovManagePopup.insert_govBankInfo");
    						commonService.insert(p);
    						
    						break;
    					case "U" :        	
    						p.put("queryId", "park.parkingGovManagePopup.update_govBankInfo");
    						commonService.update(p);
    						break;
    					case "D" :
    						p.put("queryId", "park.parkingGovManagePopup.delete_govBankInfo");
    						commonService.update(p);
    						
    						break;
    					default :;
    				}
    			} catch (Exception e) {
    	    		result = 0;    	    		
    	    		e.printStackTrace();
    	    	}
				
			}
		}
		
		return result;
	}
	
	/*기관 삭제*/
	@Transactional
	public int parkGovUpdate(CommonMap param) throws Exception {
		int result = 0;
		
		// 해당 주차장 회사에 사용하는 주차장이 존재할때
		param.put("queryId", "park.parkingGovManagePopup.select_useGov");
		CommonMap useCnt = commonService.selectOne(param);
			
		if(Integer.parseInt(useCnt.getString("useCnt")) > 0) {
			return -1;
		}else{
			// 주차장 관리 테이블에 주차장회사코드 제거
			param.put("queryId", "park.parkingGovManagePopup.update_parkingInfo");
			result = commonService.update(param);
			
			// 주차장 회사 관리 삭제
			param.put("queryId", "park.parkingGovManagePopup.delete_list");
			result = commonService.delete(param);
			
			// 은행 정보 삭제
			param.put("queryId", "park.parkingGovManagePopup.delete_allGovBankInfo");
			result = commonService.delete(param);
		}
		
		return result;
	}
	
	/*서비스키 발급*/
	@Transactional
	public int parkingGovServiceInfo(CommonMap param) throws Exception {
		
		KeyGenUtil kgu = new KeyGenUtil(); // 생성자
		String sk = kgu.getServiceKey(); // 서비스 키
		
		param.put("pServiceKey",sk);
		// 서비스키 발급
		param.put("queryId", "park.parkingGovManagePopup.update_parkingServiceInfo");
		commonService.update(param);
		
		return 1;
	}

	/*주차장 정보 저장*/
	@Transactional
	public int parkInsert(CommonMap param) throws Exception {
		int result = 0;
			
		param.put("queryId", "park.parkingManagePopup.select_parkingAreaCode");
		CommonMap parkingOverap = commonService.selectOne(param);
		
		List<CommonMap> list = param.getList("list");
		
		// 휴무일 배열에 저장
		String[] weekdayList = new String[list.size()];
		for(int i=0; i<list.size(); i++) {
			weekdayList[i] = list.get(i).getString("weekday");
		}
		
		if("".equals(param.getString("hParkingNo"))) {
			if(Integer.parseInt(parkingOverap.getString("pakingCnt")) > 0) {
			   return -1;	
			}
			
			param.put("queryId", "park.parkingManagePopup.select_parkingNo");
			CommonMap newParkingNo = commonService.selectOne(param);
			
			param.put("newParkingNo", newParkingNo.getString("newParkingNo"));
			param.put("queryId", "park.parkingManagePopup.insert_parkingInfo");
			result = commonService.insert(param);
			
			// 감면코드 강제입력
			param.put("queryId", "park.parkingManagePopup.insert_parkingReduction");
			result = commonService.insert(param);
			
			// 휴무일 insert
			for(int i=0; i<weekdayList.length; i++) {
				param.put("parkingNo", newParkingNo.getString("newParkingNo"));
				param.put("weekDay", weekdayList[i]);
				param.put("queryId", "park.parkingManagePopup.insert_weekday");
				result = commonService.insert(param);
			}
			
		}else {
			param.put("parkingNo", param.getString("hParkingNo"));
			param.put("queryId", "park.parkingManagePopup.update_parkingInfo");
			result = commonService.update(param);
			
			// 휴무일 기존데이터 delete
			param.put("parkingNo", param.getString("hParkingNo"));
			param.put("queryId", "park.parkingManagePopup.delete_weekday");
			commonService.delete(param);
			
			// 휴무일 insert
			for(int i=0; i<weekdayList.length; i++) {
				param.put("weekDay", weekdayList[i]);
				param.put("queryId", "park.parkingManagePopup.insert_weekday");
				result = commonService.insert(param);
			}
		}
		
		return result;
	}
	
	/*주차장 정보 삭제*/
	@Transactional
	public int parkDelete(CommonMap param) throws Exception {
		
		param.put("queryId", "park.parkingManagePopup.delete_parkingInfo");
		commonService.delete(param);
		
		// 감면코드 삭제
		param.put("queryId", "park.parkingManagePopup.delete_parkingReduction");
		commonService.delete(param);
		
		return 1;
	}
	
	/*주차장별 감면 관리*/
	@Transactional
	public int parkReduction(CommonMap param) throws Exception {
			
		List<CommonMap> list = param.getList("list");
		
		for(int i=0; i<list.size(); i++) {
			CommonMap item = list.get(i);

			if(item.getString("grdStateCol").equals("U") && item.getString("grdIncludeValue").equals("Y")) {
				/*UPDATE 추가됌으로 삭제하고 입력하는 것으로 변경*/
				item.put("queryId", "park.parkingReductionManage.delete_parkingReduction");
				commonService.delete(item);
				
				item.put("grdReductionRate", "".equals(item.getString("grdReductionRate")) ? 0 : item.getString("grdReductionRate"));
				item.put("grdFreeHour", "".equals(item.getString("grdFreeHour")) ? 0 : item.getString("grdFreeHour"));

 				item.put("queryId", "park.parkingReductionManage.insert_parkingReduction");
				commonService.insert(item);
			}else if(item.getString("grdIncludeValue").equals("N")) {
				item.put("queryId", "park.parkingReductionManage.delete_parkingReduction");
				commonService.delete(item);
			}
		}
		
		return 1;
	}
	
	/*주차장 관리 현재면수 수정*/
	@Transactional
	public int parkSpotInsert(CommonMap param) throws Exception {
		
		param.put("queryId", "park.parkingSpotPopup.update_parkingSpotInfo");
		commonService.update(param);
		
		return 1;
	}
	
	/* 일반 주차장 정보 저장 */
	@Transactional
	public int generalPakingSave(CommonMap param) throws Exception {
		int result = 0;
		try {
			if("".equals(param.getString("hGeneralParkingNo"))) {
				// parkingId 중복검사
				param.put("queryId", "park.genaralParkingManagePopup.select_parkingId");
				CommonMap parkingOverap = commonService.selectOne(param);
				
				if(Integer.parseInt(parkingOverap.getString("cnt")) > 0) {
				return -1;	
				}

				// T_GENERAL_PARKING_INFO 입력
				param.put("queryId", "park.genaralParkingManagePopup.insert_generalParkingInfo");
				result = commonService.insert(param);

			} else {
				// T_GENERAL_PARKING_INFO 수정
				param.put("queryId", "park.genaralParkingManagePopup.update_generalParkingInfo");
				result = commonService.update(param);
			}

		} catch (Exception e) {
			return 0;
		}
		return result;
	}


	/* 일반 주차장 정보 삭제 */
	@Transactional
	public int generalPakingDelete(CommonMap param) throws Exception {
		int result = 0;
		try {
			param.put("queryId", "park.genaralParkingManagePopup.delete_generalParkingInfo");
			result = commonService.delete(param);

		} catch (Exception e) {
			return 0;
		}
		return result;
	}
	
	
	 // 주차장 대량 등록
    @Transactional
    public List<CommonMap> parkingMassRegister(HttpServletRequest request, CommonMap param) throws Exception {
        
        // fileKey, fileRelKey 를 통해 파일 위치를 찾고 해당 파일을 읽어야 함
        String fileKey = request.getParameter("fileKey").toString();
        
        // 암호화를 풀도록 처리
        request.setAttribute("useDecrypt", "Y");

        final int START_ROWNUM = 7;
        int result = 1;
        ExcelController ec = new ExcelController();
        // 두번째 줄, 첫번째 칸(A열)부터 시작하도록 변경
        List<CommonMap> xlsList = ec.readExcelFile(fileKey, START_ROWNUM - 6, 0, request);
        List<CommonMap> retList = new ArrayList<CommonMap>();
        
        // 오류 발생시 메시지 담는 용도
        List<CommonMap> errList = new ArrayList<CommonMap>();
        CommonMap errRow = new CommonMap();
        
        if(xlsList.size() < 5) {
            // 양식 문제 발생
            errRow.put("xlsChkMsg", "업로드 양식이 맞지 않습니다.");
            errList.add(errRow);
            return errList;
        }
        
        // 양식 검사
        // 1. 1행에 데이터가 있어야 2, 4행을 읽을 수 있음
        // 2. 2행, 4행을 검사하여 특정 문자열이 있어야 함
        if(!"주차장 등록".equals(xlsList.get(0).getString("col1")) || !"*주차장 ID".equals(xlsList.get(2).getString("col1"))) {
            // 양식 문제 발생
            errRow.put("xlsChkMsg", "업로드 양식이 맞지 않습니다.");
            errList.add(errRow);
            return errList;
        }
        
        // 엑셀을 다시 읽도록 처리
        // 1행부터 읽으면 column 개수가 맞지 않는 경우가 발생함
        xlsList = ec.readExcelFile(fileKey, START_ROWNUM, 0, request);
        
        if(xlsList.size() < 1) {
            // 데이터 없음
            errRow.put("xlsChkMsg", "업로드 할 데이터가 없습니다.");
            errList.add(errRow);
            return errList;
        }

        CommonMap params = MapUtils.parseRequest(request);
        
        for(int i = 0; i < xlsList.size(); i++) {
            CommonMap row = xlsList.get(i);

            // 엔터키 방지
            row.put("col1", row.getString("col1").replaceAll("\n", ""));
	        row.put("col2", row.getString("col2").replaceAll("\n", ""));
	        row.put("col3", row.getString("col3").replaceAll("\n", ""));
	        row.put("col4", row.getString("col4").replaceAll("\n", ""));
	        row.put("col5", row.getString("col5").replaceAll("\n", ""));
	        row.put("col6", row.getString("col6").replaceAll("\n", ""));
	        row.put("col7", row.getString("col7").replaceAll("\n", ""));
	        row.put("col8", row.getString("col8").replaceAll("\n", ""));
	        row.put("col9", row.getString("col9").replaceAll("\n", ""));
	        row.put("col10", row.getString("col10").replaceAll("\n", ""));
	        row.put("col11", row.getString("col11").replaceAll("\n", ""));
	        row.put("col12", row.getString("col12").replaceAll("\n", ""));
            row.put("col13", row.getString("col13").replaceAll("\n", ""));
            row.put("col14", row.getString("col14").replaceAll("\n", ""));
            row.put("col15", row.getString("col15").replaceAll("\n", ""));
            row.put("col16", row.getString("col16").replaceAll("\n", ""));
            row.put("col17", row.getString("col17").replaceAll("\n", ""));
            row.put("col18", row.getString("col18").replaceAll("\n", ""));
            row.put("col19", row.getString("col19").replaceAll("\n", ""));
            row.put("col20", row.getString("col20").replaceAll("\n", ""));
	        row.put("col21", row.getString("col21").replaceAll("\n", "\\\\n"));

            CommonMap checkResult = new CommonMap();
            String errorReason = ""; // 오류 발생시 내용
            CommonMap newData = new CommonMap();

            // ExcelController.readExcel 에서 6번 행부터 읽으므로 i 값에 5 (START_ROWNUM) + 1 (0부터 시작하므로 보정치 추가)을 더함
            newData.put("rowNumber", (i + START_ROWNUM + 1));
        
            // 오류 여부 저장하는 항목 (T: 있음, 이외: 없음)
            newData.put("hasError", "F");

            newData.put("parkingId", row.getString("col1"));
            newData.put("parkingName", row.getString("col2"));
            newData.put("gugunName", row.getString("col3"));
            newData.put("dongName", row.getString("col4"));
            newData.put("pGovName", row.getString("col5"));
            newData.put("parkingPost", row.getString("col6"));
            newData.put("parkingAddr", row.getString("col7"));
            newData.put("parkingAddr2", row.getString("col8"));
            newData.put("parkingRoadAddr", row.getString("col9"));
            newData.put("parkingRoadAddr2", row.getString("col10"));
            newData.put("parkingLatitude", row.getString("col11"));
            newData.put("parkingLongitude", row.getString("col12"));
            newData.put("parkingGrade", row.getString("col13"));
            newData.put("parkingTel", row.getString("col14"));
            newData.put("parkingSpot", row.getString("col15"));
            newData.put("dpParkingSpot", row.getString("col16"));
            newData.put("stdPrice", row.getString("col17"));
            newData.put("tenMPrice", row.getString("col18"));
            newData.put("useYnName", row.getString("col19"));
            newData.put("mapMarkGubnName", row.getString("col20"));
            newData.put("manageInfo", row.getString("col21"));
            
            // 그리드 상태(state_col) 기본값
            newData.put("stateCol", "");
            
            // 오류 메시지 관련 기본값
            newData.put("errorReason", "");
            newData.put("hasError", "");
            
            
            try {
                row.put("userId", params.getString("userId"));

                // 필수값, 사전 Validation 확인
                {
                    // 주차장 ID
                    if("".equals(row.getString("col1"))) {
                        errorReason = newData.getString("errorReason");
                        errorReason += (errorReason.length() > 0 ? " / " : "") + "[주차장 ID] 입력 필요";
                        newData.put("errorReason", errorReason);
                        newData.put("hasError", "T");
                        newData.put("stateCol", "");
                    } else {
                    	// 주차장 ID 조건 : 5자리 영문+숫자
                        String idReg = "^[a-zA-Z0-9]{5}$";
                        Pattern idPattern = Pattern.compile(idReg);
                        if(!idPattern.matcher(row.getString("col1")).matches()) {
                            errorReason = newData.getString("errorReason");
                            errorReason += (errorReason.length() > 0 ? " / " : "") + "[주차장 ID] 영문,숫자 5자리 입력";
                            newData.put("errorReason", errorReason);
                            newData.put("hasError", "T");
                            newData.put("stateCol", "");
                        }
                        
                        // 주차장 ID 중복검사
                        row.put("parkingId", row.getString("col1"));
                        row.put("queryId", "park.generalParkingUploadPopup.select_parkingId");
        				CommonMap parkingOverap = commonService.selectOne(row);
        				
        				if(Integer.parseInt(parkingOverap.getString("cnt")) > 0) {
        					errorReason = newData.getString("errorReason");
                            errorReason += (errorReason.length() > 0 ? " / " : "") + "[주차장 ID] 중복 ID 존재";
                            newData.put("errorReason", errorReason);
                            newData.put("hasError", "T");
                            newData.put("stateCol", "");
        				}
                    }

                    // 주차장명
                    if("".equals(row.getString("col2"))) {
                        errorReason = newData.getString("errorReason");
                        errorReason += (errorReason.length() > 0 ? " / " : "") + "[주차장명] 입력 필요";
                        newData.put("errorReason", errorReason);
                        newData.put("hasError", "T");
                        newData.put("stateCol", "");
                    }

                    // 구역(시/군/구)
                    if("".equals(row.getString("col3"))) {
                        errorReason = newData.getString("errorReason");
                        errorReason += (errorReason.length() > 0 ? " / " : "") + "[구역(시/군/구)] 입력 필요";
                        newData.put("errorReason", errorReason);
                        newData.put("hasError", "T");
                        newData.put("stateCol", "");
                    }

                    // 구역(읍/면/동)
                    if("".equals(row.getString("col4"))) {
                        errorReason = newData.getString("errorReason");
                        errorReason += (errorReason.length() > 0 ? " / " : "") + "[구역(읍/면/동)] 입력 필요";
                        newData.put("errorReason", errorReason);
                        newData.put("hasError", "T");
                        newData.put("stateCol", "");
                    }

                    // 관리기관
                    if("".equals(row.getString("col5"))) {
                        errorReason = newData.getString("errorReason");
                        errorReason += (errorReason.length() > 0 ? " / " : "") + "[관리기관] 입력 필요";
                        newData.put("errorReason", errorReason);
                        newData.put("hasError", "T");
                        newData.put("stateCol", "");
                    }

                    // 우편번호
                    if(!"".equals(row.getString("col6"))) {
                    	// 우편번호 조건
                        String postCodePattern = "^(\\d{3}-?\\d{3}|\\d{3}-?\\d{2})$";
                        Pattern postPattern = Pattern.compile(postCodePattern);
                        if(!postPattern.matcher(row.getString("col6")).matches()) {
                            errorReason = newData.getString("errorReason");
                            errorReason += (errorReason.length() > 0 ? " / " : "") + "[우편번호] 형식 오류";
                            newData.put("errorReason", errorReason);
                            newData.put("hasError", "T");
                            newData.put("stateCol", "");
                        }
                    }

                    // 지번주소
                    if("".equals(row.getString("col7"))) {
                        errorReason = newData.getString("errorReason");
                        errorReason += (errorReason.length() > 0 ? " / " : "") + "[지번주소] 입력 필요";
                        newData.put("errorReason", errorReason);
                        newData.put("hasError", "T");
                        newData.put("stateCol", "");
                    } else {
                    	// 지번주소 조건 : 50자리
                        if(row.getString("col7").length() > 50) {
                            errorReason = newData.getString("errorReason");
                            errorReason += (errorReason.length() > 0 ? " / " : "") + "[지번주소] 50자리 이하 입력";
                            newData.put("errorReason", errorReason);
                            newData.put("hasError", "T");
                            newData.put("stateCol", "");
                        }
                    }
                    
                    // 지번상세주소 조건 : 50자리
                    if(row.getString("col8").length() > 50) {
                        errorReason = newData.getString("errorReason");
                        errorReason += (errorReason.length() > 0 ? " / " : "") + "[지번상세주소] 50자리 이하 입력";
                        newData.put("errorReason", errorReason);
                        newData.put("hasError", "T");
                        newData.put("stateCol", "");
                    }
                    
                    // 도로명주소
                    if("".equals(row.getString("col9"))) {
                        errorReason = newData.getString("errorReason");
                        errorReason += (errorReason.length() > 0 ? " / " : "") + "[도로명주소] 입력 필요";
                        newData.put("errorReason", errorReason);
                        newData.put("hasError", "T");
                        newData.put("stateCol", "");
                    } else {
                    	// 도로명상세주소 조건 : 50자리
                        if(row.getString("col10").length() > 50) {
                            errorReason = newData.getString("errorReason");
                            errorReason += (errorReason.length() > 0 ? " / " : "") + "[도로명상세주소] 50자리 이하 입력";
                            newData.put("errorReason", errorReason);
                            newData.put("hasError", "T");
                            newData.put("stateCol", "");
                        }
                    }
                    
                    // 위도
                    if(!row.getString("col11").equals("") && !(row.getDouble("col11") >= 35 && row.getDouble("col11") < 36)) {
                        errorReason = newData.getString("errorReason");
                        errorReason += (errorReason.length() > 0 ? " / " : "") + "[위도] 올바르지 않음";
                        newData.put("errorReason", errorReason);
                        newData.put("hasError", "T");
                        newData.put("stateCol", "");
                    }
                    
                    // 경도
                    if(!row.getString("col12").equals("") && !(row.getDouble("col12") >= 129 && row.getDouble("col12") < 130)) {
                        errorReason = newData.getString("errorReason");
                        errorReason += (errorReason.length() > 0 ? " / " : "") + "[경도] 올바르지 않음";
                        newData.put("errorReason", errorReason);
                        newData.put("hasError", "T");
                        newData.put("stateCol", "");
                    }

                    // 급지
                    if("".equals(row.getString("col13"))) {
                        errorReason = newData.getString("errorReason");
                        errorReason += (errorReason.length() > 0 ? " / " : "") + "[급지] 입력 필요";
                        newData.put("errorReason", errorReason);
                        newData.put("hasError", "T");
                        newData.put("stateCol", "");
                    } else {
                    	// 급지 조건 : 숫자
                        String gradeReg = "^[1-5]{1}$";
                        Pattern gradePattern = Pattern.compile(gradeReg);
                        if(!gradePattern.matcher(row.getString("col13")).matches()) {
                            errorReason = newData.getString("errorReason");
                            errorReason += (errorReason.length() > 0 ? " / " : "") + "[급지] 1~5 입력";
                            newData.put("errorReason", errorReason);
                            newData.put("hasError", "T");
                            newData.put("stateCol", "");
                        }
                    }
                    
                    
                    // 전화번호
                    if("".equals(row.getString("col14"))) {
                        errorReason = newData.getString("errorReason");
                        errorReason += (errorReason.length() > 0 ? " / " : "") + "[전화번호] 입력 필요";
                        newData.put("errorReason", errorReason);
                        newData.put("hasError", "T");
                        newData.put("stateCol", "");
                    } else {
                    	// 전화번호 조건
                        String phoneReg = "^(02.{0}|01.{1}|[0-9]{3,4})([0-9]{3,4})([0-9]{4})";
                        Pattern phonePattern = Pattern.compile(phoneReg);
                        if(!phonePattern.matcher(row.getString("col14").replaceAll("-", "")).matches()) {
                            errorReason = newData.getString("errorReason");
                            errorReason += (errorReason.length() > 0 ? " / " : "") + "[전화번호] 형식 오류";
                            newData.put("errorReason", errorReason);
                            newData.put("hasError", "T");
                            newData.put("stateCol", "");
                        }
                    }
                    
                    // 11자리 이하 숫자 정규식
                    String intReg = "^[0-9]{0,11}$";
                    Pattern intPattern = Pattern.compile(intReg);
                    
                    // 일반주차면수 조건 : 11자리 이하 숫자
                    if(!"".equals(row.getString("col15")) && !intPattern.matcher(row.getString("col15")).matches()) {
                        errorReason = newData.getString("errorReason");
                        errorReason += (errorReason.length() > 0 ? " / " : "") + "[일반주차면수] 11자리 이하 숫자 입력";
                        newData.put("errorReason", errorReason);
                        newData.put("hasError", "T");
                        newData.put("stateCol", "");
                    }
                    
                    // 장애인주차면수 조건 : 11자리 이하 숫자
                    if(!"".equals(row.getString("col16")) && !intPattern.matcher(row.getString("col16")).matches()) {
                        errorReason = newData.getString("errorReason");
                        errorReason += (errorReason.length() > 0 ? " / " : "") + "[장애인주차면수] 11자리 이하 숫자 입력";
                        newData.put("errorReason", errorReason);
                        newData.put("hasError", "T");
                        newData.put("stateCol", "");
                    }
                    
                    // 기본요금(평일) 조건 : 11자리 이하 숫자
                    if(!"".equals(row.getString("col17")) && !intPattern.matcher(row.getString("col17")).matches()) {
                        errorReason = newData.getString("errorReason");
                        errorReason += (errorReason.length() > 0 ? " / " : "") + "[기본요금(평일)] 11자리 이하 숫자 입력";
                        newData.put("errorReason", errorReason);
                        newData.put("hasError", "T");
                        newData.put("stateCol", "");
                    }
                    
                    // 10분당요금(평일) 조건 : 11자리 이하 숫자
                    if(!"".equals(row.getString("col18")) && !intPattern.matcher(row.getString("col18")).matches()) {
                        errorReason = newData.getString("errorReason");
                        errorReason += (errorReason.length() > 0 ? " / " : "") + "[분당요금(평일)] 11자리 이하 숫자 입력";
                        newData.put("errorReason", errorReason);
                        newData.put("hasError", "T");
                        newData.put("stateCol", "");
                    }
                    

                    // 사용여부
                    if("".equals(row.getString("col19"))) {
                        errorReason = newData.getString("errorReason");
                        errorReason += (errorReason.length() > 0 ? " / " : "") + "[사용여부] 입력 필요";
                        newData.put("errorReason", errorReason);
                        newData.put("hasError", "T");
                        newData.put("stateCol", "");
                    }
                    
                    // 지도표시구분
                    if("".equals(row.getString("col20"))) {
                        errorReason = newData.getString("errorReason");
                        errorReason += (errorReason.length() > 0 ? " / " : "") + "[지도표시구분] 입력 필요";
                        newData.put("errorReason", errorReason);
                        newData.put("hasError", "T");
                        newData.put("stateCol", "");
                    }
                    
                    // 비고 (500자까지 잘라서 업로드)
                    if(row.getString("col21").length() > 500) {
                        row.put("col21", row.getString("col21").substring(0, 499));
                    }
                }
                
                

                // gugunName -> 코드 변환
                row.put("parentCodeId", "RESION");
	    	    row.put("codeName", row.getString("col3"));
                row.put("queryId", "park.generalParkingUploadPopup.select_ExcelUploadGetCommonCode");
                checkResult = new CommonMap();
                checkResult = getCodeName(row, "codeId", "[구역(시/군/구)]", "");

                if(checkResult.getInt("result") == 1) {
                    newData.put("gugun", checkResult.getString("data"));
                } else {
                	errorReason = newData.getString("errorReason");
                    errorReason += (errorReason.length() > 0 ? " / " : "") + checkResult.getString("errorMessage");
                    newData.put("errorReason", errorReason);
                    newData.put("hasError", "T");
                    newData.put("stateCol", "");
                }

                // dongName -> 코드변환
                row.put("parentCodeId", newData.getString("gugun"));
	    	    row.put("codeName", row.getString("col4"));
                row.put("queryId", "park.generalParkingUploadPopup.select_ExcelUploadGetCommonCode");
                checkResult = new CommonMap();
                checkResult = getCodeName(row, "codeId", "[구역(읍/면/동)]", "");

                if(checkResult.getInt("result") == 1) {
                    newData.put("dong", checkResult.getString("data"));
                } else {
                	errorReason = newData.getString("errorReason");
                    errorReason += (errorReason.length() > 0 ? " / " : "") + checkResult.getString("errorMessage");
                    newData.put("errorReason", errorReason);
                    newData.put("hasError", "T");
                    newData.put("stateCol", "");
                }

                // pGovName -> 코드변환
                row.put("pGovName", row.getString("col5"));
                row.put("queryId", "park.generalParkingUploadPopup.select_ExcelUploadGetPGovCode");
                checkResult = new CommonMap();
                checkResult = getCodeName(row, "pGovCode", "[관리기관]", "");
                
                 if(checkResult.getInt("result") == 1) {
                    newData.put("pGovCode", checkResult.getString("data"));
                } else {
                	errorReason = newData.getString("errorReason");
                    errorReason += (errorReason.length() > 0 ? " / " : "") + checkResult.getString("errorMessage");
                    newData.put("errorReason", errorReason);
                    newData.put("hasError", "T");
                    newData.put("stateCol", "");
                }

                // useYnName -> 코드변환
                row.put("parentCodeId", "USE_YN");
	    	    row.put("codeName", row.getString("col19"));
                row.put("queryId", "park.generalParkingUploadPopup.select_ExcelUploadGetCommonCode");
                checkResult = new CommonMap();
                checkResult = getCodeName(row, "codeId", "[사용여부]", "");

                if(checkResult.getInt("result") == 1) {
                    newData.put("useYn", checkResult.getString("data"));
                } else {
                	errorReason = newData.getString("errorReason");
                    errorReason += (errorReason.length() > 0 ? " / " : "") + checkResult.getString("errorMessage");
                    newData.put("errorReason", errorReason);
                    newData.put("hasError", "T");
                    newData.put("stateCol", "");
                }
                
                // mapMarkGubnName -> 코드변환
                row.put("parentCodeId", "MAP_MARK_GUBN");
	    	    row.put("codeName", row.getString("col20"));
                row.put("queryId", "park.generalParkingUploadPopup.select_ExcelUploadGetCommonCode");
                checkResult = new CommonMap();
                checkResult = getCodeName(row, "codeId", "[지도표시구분]", "");

                if(checkResult.getInt("result") == 1) {
                    newData.put("mapMarkGubn", checkResult.getString("data"));
                } else {
                	errorReason = newData.getString("errorReason");
                    errorReason += (errorReason.length() > 0 ? " / " : "") + checkResult.getString("errorMessage");
                    newData.put("errorReason", errorReason);
                    newData.put("hasError", "T");
                    newData.put("stateCol", "");
                }

            } catch(Exception e) {
                e.printStackTrace();
                errorReason = newData.getString("errorReason");
                errorReason += (errorReason.length() > 0 ? " / " : "") + "서버 오류 발생";
                newData.put("errorReason", errorReason);
                newData.put("hasError", "T");
                newData.put("stateCol", "");
            }

            retList.add(newData);
        }

        return retList;
    }

    @Transactional
    public CommonMap parkingMassRegisterSave(CommonMap param) throws Exception {
    	EncUtil enc = new EncUtil();
        CommonMap result = new CommonMap();
        List<CommonMap> gridData = param.getList("list");
        int qry_rst = 0;

        int cnt_ok = 0;
        int cnt_er = 0; // 지금 처리 도중 발생하는 오류 개수
        int cnt_old_er = 0; // 기존 오류 개수

        int total_count = gridData.size();

        for(int i = 0; i < gridData.size(); i++) {
            CommonMap row = gridData.get(i);

            if("Y".equals(row.getString("grdIsReCheck"))) {
            	
            	CommonMap chkRes = parkingRowDataCheck(row);
                // insert 쿼리
            	row.put("userId", enc.encrypt(row.getString("userId")), false);
            	row.put("grdParkingTel", row.getString("grdParkingTel").replaceAll("-", ""));
                row.put("queryId", "park.generalParkingUploadPopup.insert_ExcelUpload");
                row.put("runOnce", "true");
                qry_rst = commonService.insert(row);

                if(qry_rst > 0) {
                    cnt_ok++;
                } else {
                    cnt_er++;
                }

            } else {
                // 재확인 항목이 오류인 경우를 그대로 올리면 업로드 하지 않고 오류 처리
                cnt_old_er++;
            }
        }

        result.put("totalCount", total_count);      // 전체 데이터 개수
        result.put("okCount", cnt_ok);              // 정상 처리 개수
        result.put("newErrCnt", cnt_er);            // 현재 메서드에서 처리에 실패한 개수
        result.put("oldErrCnt", cnt_old_er);        // 엑셀 업로드 시 오류로 판단한 개수

        return result;
    }

    // 한 줄의 데이터가 맞는지를 확인하는 메서드
    @Transactional
    public CommonMap parkingRowDataCheck(CommonMap param) throws Exception {
        // .result = "T" / "F" (정상 / 비정상)
        // .errorMessage = "" (오류 메시지 모음)
        CommonMap result = new CommonMap();
        
        // 초기값
        result.put("result", "T");
        result.put("errorMessage", "");
        result.put("changeIdx", param.getString("changeIdx")); // 변경한 index 를 handle 함수에서 사용하기 위함
        
        if(param.has("rowData")) {
            // JSON 형태 String 을 객체로 변환
            JSONParser parser = new JSONParser();
            String rowDataStr = param.getString("rowData");
            JSONObject rowData = (JSONObject) parser.parse(rowDataStr);
            
            // rowData 를 param 에 추가
            for(Object objs : rowData.keySet()) {
                String key = (String) objs;
                
                if(key.startsWith("grd")) {
                    key = key.substring(3);
                    
                    char key1char = key.charAt(0);
                    key1char += 32;
                    
                    key = key1char + key.substring(1);
                }
                
                param.put(key, String.valueOf(rowData.get(objs) == null ? "" : rowData.get(objs)));
            }
        }
        
        if(param.has("grdParkingId")) {
            CommonMap tmpMap = new CommonMap();
            
            for(Object objs : param.keySet()) {
                String key = (String) objs;
                String convKey = key;
                
                if(key.startsWith("grd")) {
                    convKey = convKey.substring(3);
                    
                    char key1char = convKey.charAt(0);
                    key1char += 32;
                    
                    convKey = key1char + convKey.substring(1);
                }
                
                tmpMap.put(convKey, param.getString(key));
            }
            
            for(Object objs : tmpMap.keySet()) {
                String key = (String) objs;
                param.put(key, tmpMap.getString(key));
            }
        }
        
        // 기타 변수
        String errorMessage = "";
        List<CommonMap> checkList = new ArrayList<CommonMap>();
        
        // 헤더 ID별 이름 매칭
        CommonMap headerName = new CommonMap();
        headerName.put("hasError", "[성공여부]");
        headerName.put("errorReason", "[실패 사유]");
        headerName.put("parkingId", "[주차장 ID]");
        headerName.put("parkingName", "[주차장명]");
        headerName.put("gugun", "[구역(시/군/구)]");
        headerName.put("dong", "[구역(읍/면/동)]");
        headerName.put("pGovCode", "[관리기관]");
        headerName.put("parkingPost", "[우편번호]");
        headerName.put("parkingAddr", "[지번주소]");
        headerName.put("parkingAddr2", "[지번상세주소]");
        headerName.put("parkingRoadAddr", "[도로명주소]");
        headerName.put("parkingRoadAddr2", "[도로명상세주소]");
        headerName.put("parkingLatitude", "[위도]");
        headerName.put("parkingLongitude", "[경도]");
        headerName.put("parkingGrade", "[급지]");
        headerName.put("parkingTel", "[전화번호]");
        headerName.put("parkingSpot", "[일반주차면수]");
        headerName.put("dpParkingSpot", "[장애인주차면수]");
        headerName.put("stdPrice", "[기본요금(평일)]");
        headerName.put("tenMPrice", "[10분당요금(평일)]");
        headerName.put("useYn", "[사용여부]");
        headerName.put("mapMarkGubn", "[지도표시구분]");
        headerName.put("manageInfo", "[운영정보]");
        
        // 빈값 체크
        for(Object obj : headerName.keyList()) {
            String key = obj.toString();
            String value = "";
            
            // 검사할 필요 없는 항목 제외
            if(
                    "hasError".equals(key) ||
                    "errorReason".equals(key) ||
                    "parkingPost".equals(key) ||
                    "parkingAddr2".equals(key) ||
                    "parkingRoadAddr2".equals(key) ||
                    "parkingLatitude".equals(key) ||
                    "parkingLongitude".equals(key) ||
                    "parkingSpot".equals(key) ||
                    "dpParkingSpot".equals(key) ||
                    "stdPrice".equals(key) ||
                    "tenMPrice".equals(key) ||
                    "manageInfo".equals(key)
            ) {
                continue;
            }
            
            value = param.getString(key);
            
            // 빈값 체크
            if(value == null || "".equals(value.trim())) {
                errorMessage = result.getString("errorMessage");
                errorMessage += (errorMessage.length() > 0 ? " / " : "") + headerName.getString(key) + " 입력 필요";
                result.put("result", "F");
                result.put("errorMessage", errorMessage);
            }
        }
        
        // 주차장 ID 공백 체크 (전/후행)
        if(!"Y".equals(param.getString("parkingId"))) {
            if(param.getString("parkingId").trim() != param.getString("parkingId")) {
                errorMessage = result.getString("errorMessage");
                errorMessage += (errorMessage.length() > 0 ? " / " : "") + headerName.getString("parkingId") + " 전/후 공백 제거 요망";
                result.put("result", "F");
                result.put("errorMessage", errorMessage);
            }
        }
        
        // 주차장 ID 공백 체크 (중간)
        if(!"Y".equals(param.getString("parkingId"))) {
            if(param.getString("parkingId").indexOf(" ") > -1) {
                errorMessage = result.getString("errorMessage");
                errorMessage += (errorMessage.length() > 0 ? " / " : "") + headerName.getString("parkingId") + " 중간 공백 제거 요망";
                result.put("result", "F");
                result.put("errorMessage", errorMessage);
            }
        }
        
        // 주차장 ID 조건 : 5자리 영문+숫자
        String idReg = "^[a-zA-Z0-9]{5}$";
        Pattern idPattern = Pattern.compile(idReg);
        if(!idPattern.matcher(param.getString("parkingId")).matches()) {
            errorMessage = result.getString("errorMessage");
            errorMessage += (errorMessage.length() > 0 ? " / " : "") + "[주차장 ID] 영문,숫자 5자리 입력";
            result.put("result", "F");
            result.put("errorMessage", errorMessage);
        }
        
        // 주차장 ID 중복검사
        param.put("queryId", "park.generalParkingUploadPopup.select_parkingId");
		CommonMap parkingOverap = commonService.selectOne(param);
		
		if(Integer.parseInt(parkingOverap.getString("cnt")) > 0) {         
			errorMessage = result.getString("errorMessage");
            errorMessage += (errorMessage.length() > 0 ? " / " : "") + "[주차장 ID] 중복 ID 존재";
            result.put("result", "F");
            result.put("errorMessage", errorMessage);
		}
		
		// 우편번호 조건
        String postCodePattern = "^(\\d{3}-?\\d{3}|\\d{3}-?\\d{2})$";
        Pattern postPattern = Pattern.compile(postCodePattern);
        if(!"".equals(param.getString("parkingPost"))) {
            if(!postPattern.matcher(param.getString("parkingPost")).matches()) {
            	errorMessage = result.getString("errorMessage");
                errorMessage += (errorMessage.length() > 0 ? " / " : "") + "[우편번호] 형식 오류";
                result.put("result", "F");
                result.put("errorMessage", errorMessage);
            }
        }
		
		// 전화번호 조건
        String phoneReg = "^(02.{0}|01.{1}|[0-9]{3,4})([0-9]{3,4})([0-9]{4})";
        Pattern phonePattern = Pattern.compile(phoneReg);
        if(!phonePattern.matcher(param.getString("parkingTel").replaceAll("-", "")).matches()) {
        	errorMessage = result.getString("errorMessage");
            errorMessage += (errorMessage.length() > 0 ? " / " : "") + "[전화번호] 형식 오류";
            result.put("result", "F");
            result.put("errorMessage", errorMessage);
        }
		
		// 급지 조건 : 1~5 중 하나
		String gradeReg = "^[1-5]{1}$";
        Pattern gradePattern = Pattern.compile(gradeReg);
        if(!gradePattern.matcher(param.getString("parkingGrade")).matches()) {
        	errorMessage = result.getString("errorMessage");
            errorMessage += (errorMessage.length() > 0 ? " / " : "") + "[급지] 1~5 입력";
            result.put("result", "F");
            result.put("errorMessage", errorMessage);
        } 
        
        // 위도
        if(!param.getString("parkingLatitude").equals("") && !(param.getDouble("parkingLatitude") >= 35 && param.getDouble("parkingLatitude") < 36)) {           
            errorMessage = result.getString("errorMessage");
            errorMessage += (errorMessage.length() > 0 ? " / " : "") + "[위도] 올바르지 않음";
            result.put("result", "F");
            result.put("errorMessage", errorMessage);
        }
        
        // 경도
        if(!param.getString("parkingLongitude").equals("") && !(param.getDouble("parkingLongitude") >= 129 && param.getDouble("parkingLongitude") < 130)) {           
            errorMessage = result.getString("errorMessage");
            errorMessage += (errorMessage.length() > 0 ? " / " : "") + "[경도] 올바르지 않음";
            result.put("result", "F");
            result.put("errorMessage", errorMessage);
        }

        return result;
    }


    private CommonMap getCodeName(CommonMap param, String resultColumnName, String errMsgPrefix, String errMsgSuffix) {
        CommonMap result = new CommonMap();

        result.put("result", 1);
        result.put("data", "");
        result.put("errorMessage", "");

        // 결과(result)
        //     1 : 성공
        // -1000 : 조회된 데이터 없음
        // -2000 : 2개 이상 조회됨
        // -3000 : Exception 발생

        try {
            List<CommonMap> checkList = commonService.select(param);

            if(checkList.size() == 1) {
                result.put("result", 1);
                result.put("data", checkList.get(0).getString(resultColumnName));
                result.put("errorMessage", "");
            } else if(checkList.size() > 1) {
                result.put("result", -2000);
                result.put("data", "");
                result.put("errorMessage", errMsgPrefix + " 2개 이상 중복 " + errMsgSuffix);
            } else {
                result.put("result", -1000);
                result.put("data", "");
                result.put("errorMessage", errMsgPrefix + " 조회 결과 없음 " + errMsgSuffix);
            }

        } catch(Exception e) {
            e.printStackTrace();
            result.put("result", -3000);
            result.put("errorMessage", errMsgPrefix + " 조회 도중 오류 발생 " + errMsgSuffix);
        }

        return result;
    }
    
    /* 일반 주차장 엑셀 파일 업로드 */
    @Transactional
    public ResultInfo generalParkExcelUpload(HttpSession session, HttpServletRequest request) throws Exception {
        UploadController uc = new UploadController(commonService);
        CommonMap param = MapUtils.parseRequest(request, false, request.getParameter("enc_col"));
        ResultInfo result = null;
        
        // 파일 업로드가 없는 경우에 리턴해야 하는 경우
        String msg = "";
        String str = "";
        int count = 0;
        CommonMap data = new CommonMap();
        
        // 파일 업로드가 있는 경우 해당 파라미터가 항상 포함되어 있다.
        String fileCont = request.getParameter("fileCont");
        boolean isFileUploaded = fileCont == null ? false : true;
        
        if(isFileUploaded) {
            result = uc.uploadChunkEncryptMulti(session, request);
        }
        
        if(uc.isChunkCompleteMulti(request) || !isFileUploaded) {
            // 파일 업로드 완료시 파일키를 리턴하여 해당 키를 통해 파일을 열어서 엑셀을 읽을 수 있도록 한다.
            // 기본적으로 uploadChunkEncryptMulti 함수에서 리턴해주는 값을 통해 진행할 것
            // newFileKey, newFileRelKey 로 확인할 것
        }
        
        return result;
    }
}
