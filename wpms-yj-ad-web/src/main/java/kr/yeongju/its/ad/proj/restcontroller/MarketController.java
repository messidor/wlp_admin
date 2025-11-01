package kr.yeongju.its.ad.proj.restcontroller;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

import egovframework.rte.fdl.property.EgovPropertyService;
import kr.yeongju.its.ad.common.dto.CommonMap;
import kr.yeongju.its.ad.common.dto.ResultInfo;
import kr.yeongju.its.ad.common.exception.NotFoundException;
import kr.yeongju.its.ad.common.util.MapUtils;
import kr.yeongju.its.ad.core.service.CommonService;
import kr.yeongju.its.ad.proj.service.MarketService;


@RestController
@RequestMapping(value = "/market")
public class MarketController {

	@Resource(name = "commonService")
	private CommonService commonService;

	@Resource(name = "marketService")
	private MarketService marketService;

    @Resource(name = "propertyService")
    private EgovPropertyService propertyService;

	
	// 주차장 별 할인권 관리 저장
	@RequestMapping(value = "/parkingCouponSave.do", method = RequestMethod.POST)
	public ResultInfo parkingCouponSave(HttpServletRequest request) throws Exception {
		String msg = "";
		int result = 1;
		CommonMap data = new CommonMap();

		try {
			int success_cnt = marketService.parkingCouponSave(MapUtils.parseRequest(request, false, request.getParameter("enc_col")));

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
	
	// 할인권 환불 승인
	@RequestMapping(value = "/couponRefundConfirm.do", method = RequestMethod.POST)
	public ResultInfo couponRefundConfirm(HttpServletRequest request) throws Exception {
		String msg = "";
		int result = 1;
		CommonMap data = new CommonMap();

		try {
		    CommonMap requestParam = MapUtils.parseRequest(request, false, request.getParameter("enc_col"));
		    requestParam.put("isPayTest", propertyService.getBoolean("payTest"));
		    requestParam.put("cancelUrl",  propertyService.getString("payCancelApiUrl"));
		    
			int success_cnt = marketService.couponRefundConfirm(requestParam);

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
	
	// 할인권 환불 거절
	@RequestMapping(value = "/couponRefundReject.do", method = RequestMethod.POST)
	public ResultInfo couponRefundReject(HttpServletRequest request) throws Exception {
		String msg = "";
		int result = 1;
		CommonMap data = new CommonMap();

		try {
			int success_cnt = marketService.couponRefundReject(MapUtils.parseRequest(request, false, request.getParameter("enc_col")));

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
	
	// 주차권관리자 관리(정보)
	@RequestMapping(value = "/CouponManageSave.do", method = RequestMethod.POST)
	public ResultInfo CouponManageSave(HttpServletRequest request) throws Exception {
		String msg = "";
		int result = 1;
		CommonMap data = new CommonMap();

		try {
			int success_cnt = marketService.CouponManageSave(MapUtils.parseRequest(request, false, request.getParameter("enc_col")));

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
	
	// 주차권관리자 관리(비밀번호)
	@RequestMapping(value = "/CouponPasswordUpdate.do", method = RequestMethod.POST)
	public ResultInfo CouponPasswordUpdate(HttpServletRequest request) throws Exception {
		String msg = "";
		int result = 1;
		CommonMap data = new CommonMap();

		try {
			int success_cnt = marketService.CouponPasswordUpdate(MapUtils.parseRequest(request, false, request.getParameter("enc_col")));

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
	
	// 할인권 장소 승인 관리 - 승인 / 거절
	@RequestMapping(value = "/CouponAreaSave.do", method = RequestMethod.POST)
	public ResultInfo CouponAreaSave(HttpServletRequest request) throws Exception {
		String msg = "";
		int result = 1;
		CommonMap data = new CommonMap();

		try {
			int success_cnt = marketService.CouponAreaSave(MapUtils.parseRequest(request, false, request.getParameter("enc_col")));

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
	
	// 실물 할인권 관리
	@RequestMapping(value = "/offlineCouponSave.do", method = RequestMethod.POST)
	public ResultInfo offlineCouponSave(HttpServletRequest request) throws Exception {
		String msg = "";
		int result = 0;
		CommonMap data = new CommonMap();

		try {
			result = marketService.offlineCouponSave(MapUtils.parseRequest(request, false, request.getParameter("enc_col")));

			if(result > 0) {
				msg = "정상적으로 처리되었습니다.";
			} else if(result == -100) {
				msg = "이미 등록된 할인권포맷입니다.";
			} else {
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
	
	// 실물 할인권 인쇄
	@RequestMapping(value = "/offlineCouponDetail.do", method = RequestMethod.POST)
	public ResultInfo offlineCouponDetail(HttpServletRequest request) throws Exception {
		String msg = "";
		int result = 1;
		CommonMap data = new CommonMap();

		try {
			data = marketService.offlineCouponDetail(MapUtils.parseRequest(request, false, request.getParameter("enc_col")));

			result = data.getInt("count");
			if(result > 0) {
				msg = "정상적으로 처리되었습니다.";
			} else if(result == -100){
				msg = "할인권 포맷 오류로 인해 생성할 수 없습니다.";
			} else {
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
	
	// 실물 할인권 별 주차장 관리
	@RequestMapping(value = "/offlineCouponParkingSave.do", method = RequestMethod.POST)
	public ResultInfo offlineCouponParkingSave(HttpServletRequest request) throws Exception {
		String msg = "";
		int result = 1;
		CommonMap data = new CommonMap();

		try {
			int success_cnt = marketService.offlineCouponParkingSave(MapUtils.parseRequest(request, false, request.getParameter("enc_col")));

			if(success_cnt > 0) {
				msg = "정상적으로 처리되었습니다.";
			} else {
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

}
