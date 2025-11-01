package kr.yeongju.its.ad.proj.restcontroller;


import java.util.ArrayList;
import java.util.List;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartHttpServletRequest;

import kr.yeongju.its.ad.common.dto.CommonMap;
import kr.yeongju.its.ad.common.dto.ResultInfo;
import kr.yeongju.its.ad.common.exception.NotFoundException;
import kr.yeongju.its.ad.common.util.MapUtils;
import kr.yeongju.its.ad.core.service.CommonService;
import kr.yeongju.its.ad.proj.service.ParkService;


@RestController
@RequestMapping(value = "/park")
public class ParkController {

	@Resource(name = "commonService")
	private CommonService commonService;

	@Resource(name = "parkService")
	private ParkService parkService;

	/**
	 * 회사 관리 리스트에서 승인
	 * @throws Exception
	 */
	@RequestMapping(value = "/parkCompInsert.do", method = RequestMethod.POST)
	public ResultInfo parkCompInsert(HttpServletRequest request) throws Exception {
		String msg = "";
		int result = 1;
		CommonMap data = new CommonMap();

		try {
			int success_cnt = parkService.parkCompInsert(MapUtils.parseRequest(request, false, request.getParameter("enc_col")));

			if(success_cnt < 1){
				if(success_cnt == -1) {
					result = 0;
					msg = "연계된 주차장이 존재하여 미사용 처리 할 수 없습니다.";
				}else {
					result = 0;
					msg = "삭제된 회사를 삭제할 수 없습니다.";
				}
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
	 * 회사 관리 리스트에서 삭제
	 * @throws Exception
	 */
	@RequestMapping(value = "/parkCompUpdate.do", method = RequestMethod.POST)
	public ResultInfo parkCompUpdate(HttpServletRequest request) throws Exception {
		String msg = "";
		int result = 1;
		CommonMap data = new CommonMap();

		try {
			int success_cnt = parkService.parkCompUpdate(MapUtils.parseRequest(request, false, request.getParameter("enc_col")));

			if(success_cnt < 1){
				if(success_cnt == -1) {
					result = 0;
					msg = "연계된 주차장이 존재하여 삭제 처리 할 수 없습니다.";
				}else {
					result = 0;
					msg = "삭제된 회사를 삭제할 수 없습니다.";
				}
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
	 * 회사 관리 리스트에서 승인
	 * @throws Exception
	 */
	@RequestMapping(value = "/parkingServiceInfo.do", method = RequestMethod.POST)
	public ResultInfo parkingServiceInfo(HttpServletRequest request) throws Exception {
		String msg = "";
		int result = 1;
		CommonMap data = new CommonMap();

		try {
			int success_cnt = parkService.parkingServiceInfo(MapUtils.parseRequest(request, false, request.getParameter("enc_col")));

			if(success_cnt < 1){
				result = 0;
				msg = "오류가 발생하였습니다.";
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
	 * 주차장 관리
	 * @throws Exception
	 */
	@RequestMapping(value = "/parkInsert.do", method = RequestMethod.POST)
	public ResultInfo parkInsert(HttpServletRequest request) throws Exception {
		String msg = "";
		int result = 1;
		CommonMap data = new CommonMap();

		try {
			int success_cnt = parkService.parkInsert(MapUtils.parseRequest(request, false, request.getParameter("enc_col")));

			if(success_cnt == -1){
				result = 0;
				msg = "다른 주차장 areCode가 존재합니다. 확인해 주세요.";
			}else if(success_cnt < 1){
				result = 0;
				msg = "오류가 발생하였습니다.";
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
	 * 회사 관리 리스트에서 삭제
	 * @throws Exception
	 */
	@RequestMapping(value = "/parkDelete.do", method = RequestMethod.POST)
	public ResultInfo parkDelete(HttpServletRequest request) throws Exception {
		String msg = "";
		int result = 1;
		CommonMap data = new CommonMap();

		try {
			int success_cnt = parkService.parkDelete(MapUtils.parseRequest(request, false, request.getParameter("enc_col")));

			if(success_cnt == -1){
				result = 0;
				msg = "다른 주차장 areCode가 존재합니다. 확인해 주세요.";
			}else if(success_cnt < 1){
				result = 0;
				msg = "오류가 발생하였습니다.";
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

	@RequestMapping(value = "/parkingGovServiceInfo.do", method = RequestMethod.POST)
	public ResultInfo parkingGovServiceInfo(HttpServletRequest request) throws Exception {
		String msg = "";
		int result = 1;
		CommonMap data = new CommonMap();

		try {
			int success_cnt = parkService.parkingGovServiceInfo(MapUtils.parseRequest(request, false, request.getParameter("enc_col")));

			if(success_cnt < 1){
				result = 0;
				msg = "오류가 발생하였습니다.";
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

	@RequestMapping(value = "/parkGovInsert.do", method = RequestMethod.POST)
	public ResultInfo parkGovInsert(HttpServletRequest request) throws Exception {
		String msg = "";
		int result = 1;
		CommonMap data = new CommonMap();

		try {
			int success_cnt = parkService.parkGovInsert(MapUtils.parseRequest(request, false, request.getParameter("enc_col")));

			if(success_cnt < 1){
				if(success_cnt == -1) {
					result = 0;
					msg = "연계된 주차장이 존재하여 미사용 처리 할 수 없습니다.";
				}else if(success_cnt == -2) {
					result = 0;
					msg = "이미 처리된 기관이 존재합니다.";
				}else {
					result = 0;
					msg = "오류가 발생하였습니다.";
				}
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

	@RequestMapping(value = "/parkGovUpdate.do", method = RequestMethod.POST)
	public ResultInfo parkGovUpdate(HttpServletRequest request) throws Exception {
		String msg = "";
		int result = 1;
		CommonMap data = new CommonMap();

		try {
			int success_cnt = parkService.parkGovUpdate(MapUtils.parseRequest(request, false, request.getParameter("enc_col")));

			if(success_cnt < 1){
				if(success_cnt == -1) {
					result = 0;
					msg = "연계된 주차장이 존재하여 미사용 처리 할 수 없습니다.";
				}else {
					result = 0;
					msg = "삭제된 기관을 삭제할 수 없습니다.";
				}
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

    // 주차장별 감면 관리
	@RequestMapping(value = "/parkReduction.do", method = RequestMethod.POST)
	public ResultInfo parkReduction(HttpServletRequest request) throws Exception {
		String msg = "";
		int result = 1;
		CommonMap data = new CommonMap();

		try {
			int success_cnt = parkService.parkReduction(MapUtils.parseRequest(request, false, request.getParameter("enc_col")));

			if(success_cnt < 1){
				result = 0;
				msg = "삭제된 기관을 삭제할 수 없습니다.";
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
	 * 주차장 관리 현재면수 수정
	 * @throws Exception
	 */
	@RequestMapping(value = "/parkSpotInsert.do", method = RequestMethod.POST)
	public ResultInfo parkSpotInsert(HttpServletRequest request) throws Exception {
		String msg = "";
		int result = 1;
		CommonMap data = new CommonMap();

		try {
			int success_cnt = parkService.parkSpotInsert(MapUtils.parseRequest(request, false, request.getParameter("enc_col")));

			if(success_cnt < 1){
				result = 0;
				msg = "오류가 발생하였습니다.";
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
	 * 일반 주차장 관리
	 */
	@RequestMapping(value = "/generalPakingSave.do", method = RequestMethod.POST)
	public ResultInfo generalPakingSave(HttpServletRequest request) throws Exception {
		String msg = "";
		int result = 1;
		CommonMap data = new CommonMap();

		try {
			int success_cnt = parkService.generalPakingSave(MapUtils.parseRequest(request, false, request.getParameter("enc_col")));

			if(success_cnt == -1){
				result = 0;
				msg = "중복된 주차장 ID가 존재합니다.";
			}else if(success_cnt < 1){
				result = 0;
				msg = "오류가 발생하였습니다.";
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
	 * 일반 주차장 삭제
	 */
	@RequestMapping(value = "/generalPakingDelete.do", method = RequestMethod.POST)
	public ResultInfo generalPakingDelete(HttpServletRequest request) throws Exception {
		String msg = "";
		int result = 1;
		CommonMap data = new CommonMap();

		try {
			int success_cnt = parkService.generalPakingDelete(MapUtils.parseRequest(request, false, request.getParameter("enc_col")));

			if(success_cnt < 1){
				result = 0;
				msg = "오류가 발생하였습니다.";
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
     * 엑셀 업로드 시 한 줄의 데이터를 체크하는 용도
     * @param request
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/parkingRowDataCheck.do", method = RequestMethod.POST)
    public ResultInfo parkingRowDataCheck(HttpServletRequest request) throws Exception {
        String message = "";
        int count = 1;
        CommonMap data = new CommonMap();
        
        try {
            data = parkService.parkingRowDataCheck(MapUtils.parseRequest(request));
            message = "처리되었습니다.";
        } catch (Exception e) {
            count = 0;
            message = String.format("%s (%s)", "오류가 발생하였습니다.", e.getMessage());
            e.printStackTrace();
            throw e;
        }
        
        return ResultInfo.of(message, count, data);
    }
    
	/**
     * 일반 주차장 관리 엑셀 업로드
     * @throws Exception 
     */
    @RequestMapping(value = "/parkingMassRegisterSave.do", method = RequestMethod.POST)
    public ResultInfo parkingMassRegisterSave(HttpServletRequest request) throws Exception {
        String msg = "";
        int success = 1;
        CommonMap data = new CommonMap();
        
        try {
            data = parkService.parkingMassRegisterSave(MapUtils.parseRequest(request));
            msg = "처리되었습니다.";
        } catch (Exception e) {
            success = 0;
            msg = String.format("%s (%s)", "오류가 발생하였습니다.", e.getMessage());

            e.printStackTrace();
            throw e;
        }
        return ResultInfo.of(msg, success, data);
    }
    
    /**
     * 일반 주차장 대량 업로드 (엑셀 파일 분할 업로드)
     * @param session
     * @param request
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/parkingExcelUpload.do", method = RequestMethod.POST)
    public ResultInfo parkingExcelUpload(HttpSession session, HttpServletRequest request) throws Exception {
        String msg = "";
        int success = 1;
        CommonMap data = new CommonMap();
        ResultInfo res = ResultInfo.of(msg, success, data);;
        
        try {
            res = parkService.generalParkExcelUpload(session, request);
            msg = "처리되었습니다.";
            return res;
        } catch (Exception e) {
            success = 0;
            msg = String.format("%s (%s)", "오류가 발생하였습니다.", e.getMessage());

            e.printStackTrace();
            throw e;
        }
    }
    
    /**
     * 일반 주차장 데이터 처리
     * @throws Exception 
     */
    @RequestMapping(value = "/generalParkingMassRegister.do", method = RequestMethod.POST)
    public ResultInfo generalParkingMassRegister(HttpServletRequest request) throws Exception {
        List<CommonMap> resultList = new ArrayList<CommonMap>();
        CommonMap data = new CommonMap();
        int count = 1;
        String message = "";

        try {

            resultList = parkService.parkingMassRegister(request, MapUtils.parseRequest(request));
            data.put("resultList", resultList);
            
        } catch(NotFoundException e) {

            e.printStackTrace();
            throw e;
        } catch (Exception e) {

            e.printStackTrace();
            throw e;
        }
        
//        if(resultList.get(0).has("xlsChkMsg")) {
//            model.addAttribute("xlsChkMsg", resultList.get(0).getString("xlsChkMsg"));
//            resultList.remove(0);
//        } else {
//            model.addAttribute("xlsChkMsg", "");
//        }
//        
//        model.addAttribute("xlsResultList", resultList);
        return ResultInfo.of(message, count, data);
    }
}
