package kr.yeongju.its.ad.proj.restcontroller;

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
import kr.yeongju.its.ad.proj.service.PaymentService;

@RestController
@RequestMapping(value = "/payment")
public class PaymentController {
	@Resource(name = "commonService")
	private CommonService commonService;

	@Resource(name = "paymentService")
	private PaymentService paymentService;
	
	// 승인
	@RequestMapping(value = "/updateSuccessData.do", method = RequestMethod.POST)
	public ResultInfo updateSuccessData(HttpServletRequest request) throws Exception {
		String msg = "";
		int result = 1;
		CommonMap data = new CommonMap();
		ResultInfo res = null;
		
		try {
			res = paymentService.updateSuccessData(MapUtils.parseRequest(request, false, request.getParameter("enc_col")));
			result = res.getCount();
			msg = res.getMessage();
			
//			if(success_cnt < 1){
//				if(success_cnt == -1) {
//					result = 0;
//					msg = "해당 주차장에 없는 감면 정보입니다.감면 정보를 등록해 주세요.";
//				}else if(success_cnt == -3) {
//					result = 0;
//					msg = "Mid는 필수입니다.";
//				}else if(success_cnt == -4) {
//					result = 0;
//					msg = "결제정보에 빈값이 존재합니다.";
//				}else {
//					result = 0;
//					msg = "오류가 발생하였습니다.";
//				}
//			}else {
//				msg = "정상적으로 처리되었습니다.";
//			}
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
	
	// 거절
	@RequestMapping(value = "/updateCancelData.do", method = RequestMethod.POST)
	public ResultInfo updateCancelData(HttpServletRequest request) throws Exception {
		String msg = "";
		int result = 1;
		CommonMap data = new CommonMap();

		try {
			int success_cnt = paymentService.updateCancelData(MapUtils.parseRequest(request, false, request.getParameter("enc_col")));

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
	
	// 재결제요청 승인
	@RequestMapping(value = "/updateSuccessRepay.do", method = RequestMethod.POST)
	public ResultInfo updateSuccessRepay(HttpServletRequest request) throws Exception {
		String msg = "";
		int result = 1;
		CommonMap data = new CommonMap();

		try {
			int success_cnt = paymentService.updateSuccessRepay(MapUtils.parseRequest(request, false, request.getParameter("enc_col")));

			if(success_cnt < 1){
				if(success_cnt == -1) {
					result = 0;
					msg = "해당 주차장에 없는 감면 정보입니다.감면 정보를 등록해 주세요.";
				}else if(success_cnt == -3) {
					result = 0;
					msg = "Mid는 필수입니다.";
				}else if(success_cnt == -4) {
					result = 0;
					msg = "결제정보에 빈값이 존재합니다.";
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
	
	// 재결제요청 승인
		@RequestMapping(value = "/updateSuccessOutstanding.do", method = RequestMethod.POST)
		public ResultInfo updateSuccessOutstanding(HttpServletRequest request) throws Exception {
			String msg = "";
			int result = 1;
			CommonMap data = new CommonMap();

			try {
				int success_cnt = paymentService.updateSuccessOutstanding(MapUtils.parseRequest(request, false, request.getParameter("enc_col")));

				if(success_cnt < 1){
					if(success_cnt == -1) {
						result = 0;
						msg = "해당 주차장에 없는 감면 정보입니다.감면 정보를 등록해 주세요.";
					}else if(success_cnt == -3) {
						result = 0;
						msg = "Mid는 필수입니다.";
					}else if(success_cnt == -4) {
						result = 0;
						msg = "결제정보에 빈값이 존재합니다.";
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
	
	// 재결제요청 거절
	@RequestMapping(value = "/updateCancelRepay.do", method = RequestMethod.POST)
	public ResultInfo updateCancelRepay(HttpServletRequest request) throws Exception {
		String msg = "";
		int result = 1;
		CommonMap data = new CommonMap();

		try {
			int success_cnt = paymentService.updateCancelRepay(MapUtils.parseRequest(request, false, request.getParameter("enc_col")));

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
	
	// 미납결제 납부처리
	@RequestMapping(value = "/unpaidPayment.do", method = RequestMethod.POST)
	public ResultInfo unpaidPayment(HttpServletRequest request) throws Exception {
		String msg = "";
		int result = 1;
		CommonMap data = new CommonMap();

		try {
			int success_cnt = paymentService.unpaidPayment(MapUtils.parseRequest(request, false, request.getParameter("enc_col")));

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
	
	// 전기차 충전 할인 내역 승인/거절
	@RequestMapping(value = "/elecReductionUpdate.do", method = RequestMethod.POST)
	public ResultInfo elecReductionUpdate(HttpServletRequest request) throws Exception {
		String msg = "";
		int result = 1;
		CommonMap data = new CommonMap();

		try {
			result = paymentService.elecReductionUpdate(MapUtils.parseRequest(request));

			if(result < 1){
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
	
	// 전기차 충전 할인 내역 취소
	@RequestMapping(value = "/elecReductionCancel.do", method = RequestMethod.POST)
	public ResultInfo elecReductionCancel(HttpServletRequest request) throws Exception {
		String msg = "";
		int result = 1;
		CommonMap data = new CommonMap();

		try {
			result = paymentService.elecReductionCancel(MapUtils.parseRequest(request));

			if(result < 1){
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
	
	// 미납 생성
	@RequestMapping(value = "/unpaidCreate.do", method = RequestMethod.POST)
	public ResultInfo unpaidCreate(HttpServletRequest request) throws Exception {
		String msg = "";
		int result = 1;
		CommonMap data = new CommonMap();

		try {
			int success_cnt = paymentService.unpaidCreate(MapUtils.parseRequest(request, false, request.getParameter("enc_col")));

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
}
