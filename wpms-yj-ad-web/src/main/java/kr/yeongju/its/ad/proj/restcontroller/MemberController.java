package kr.yeongju.its.ad.proj.restcontroller;

import java.util.List;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;

import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

import kr.yeongju.its.ad.common.dto.CommonMap;
import kr.yeongju.its.ad.common.dto.ResultInfo;
import kr.yeongju.its.ad.common.exception.NotFoundException;
import kr.yeongju.its.ad.common.util.MapUtils;
import kr.yeongju.its.ad.core.service.CommonService;
import kr.yeongju.its.ad.proj.service.MemberService;


@RestController
@RequestMapping(value = "/member")
public class MemberController {

	@Resource(name = "commonService")
	private CommonService commonService;

	@Resource(name = "memberService")
	private MemberService memberService;

	/**
	 * 회사 관리 리스트에서 승인
	 * @throws Exception
	 */
	@RequestMapping(value = "/memberUpdate.do", method = RequestMethod.POST)
	public ResultInfo memberUpdate(HttpServletRequest request) throws Exception {
		String msg = "";
		int result = 1;
		CommonMap data = new CommonMap();

		try {
			int success_cnt = memberService.memberUpdate(MapUtils.parseRequest(request));

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
	 * 회사 관리 팝업에서 승인
	 * @throws Exception
	 */
	@RequestMapping(value = "/memberCofirmUpdate.do", method = RequestMethod.POST)
	public ResultInfo memberCofirmUpdate(HttpServletRequest request) throws Exception {
		String msg = "";
		int result = 1;
		CommonMap data = new CommonMap();

		try {
			int success_cnt = memberService.memberCofirmUpdate(MapUtils.parseRequest(request));

			if(success_cnt < 1){
				if(success_cnt == 0) {
					result = 0;
					msg = "감면 유효기간을 입력해 주세요.";
				}else if(success_cnt == -1){
					result = 0;
					msg = "거절 사유를 입력해 주세요.";
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
	 * 회원 관리 팝업에서 패스워드 변경
	 * @throws Exception
	 */
	@RequestMapping(value = "/memberPasswordUpdate.do", method = RequestMethod.POST)
	public ResultInfo memberPasswordUpdate(HttpServletRequest request) throws Exception {
		String msg = "";
		int result = 1;
		CommonMap data = new CommonMap();

		try {
			int success_cnt = memberService.memberPasswordUpdate(MapUtils.parseRequest(request));

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
	 * 회원 관리 팝업에서 차량 삭제
	 * @throws Exception
	 */
	@RequestMapping(value = "/memberCarDel.do", method = RequestMethod.POST)
	public ResultInfo memberCarDel(HttpServletRequest request) throws Exception {
		String msg = "";
		int result = 0;
		CommonMap data = new CommonMap();

		try {
			int success_cnt = memberService.memberCarDel(MapUtils.parseRequest(request));

            if(success_cnt > 0) {
                msg = "정상적으로 처리되었습니다.";
                result = 1;
            } else if(success_cnt == -1000) {
                // 20240710 :: 입차 상태인 차량은 삭제 불가능하도록 처리
                msg = "해당 차량은 현재 주차장 입차 상태입니다. 출차 후 삭제가 가능합니다.";
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
	
	/**
	 * 회원 관리 팝업에서 인적감면 삭제
	 * @throws Exception
	 */
	@RequestMapping(value = "/memberReductionDel.do", method = RequestMethod.POST)
	public ResultInfo memberReductionDel(HttpServletRequest request) throws Exception {
		String msg = "";
		int result = 1;
		CommonMap data = new CommonMap();

		try {
			int success_cnt = memberService.memberReductionDel(request);

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
	 * 회원 관리 팝업에서 저장
	 * @throws Exception
	 */
	@RequestMapping(value = "/memberSaveData.do", method = RequestMethod.POST)
	public ResultInfo memberSaveData(HttpServletRequest request) throws Exception {
		String msg = "";
		int result = 1;
		CommonMap data = new CommonMap();

		try {
			int success_cnt = memberService.memberSaveData(MapUtils.parseRequest(request));

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
	 * 차량 신청 관리 팝업에서 승인 & 거절
	 * @throws Exception
	 */
	@RequestMapping(value = "/applyCarUpdate.do", method = RequestMethod.POST)
	public ResultInfo applyCarUpdate(HttpServletRequest request) throws Exception {
		String msg = "";
		int result = 1;
		CommonMap data = new CommonMap();

		try {
			int success_cnt = memberService.applyCarUpdate(request);

			if(success_cnt < 1){
				if(success_cnt == -1) {
					result = 0;
					msg = "이미 승인된 차량이 존재합니다.";
				} else if(success_cnt == -2) {
					result = 0;
					msg = "이미 처리된 차량이 존재합니다.";
				} else {
					result = 0;
					msg = "정상적으로 처리되지 않았습니다.";
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
	 * 전체관리 팝업
	 * @throws Exception
	 */
	@RequestMapping(value = "/memberFullManage.do", method = RequestMethod.POST)
	public ResultInfo memberFullManage(Model model, HttpServletRequest request) throws Exception {
		String msg = "";
		int result = 1;
		CommonMap data = new CommonMap();
		
		try {
			msg = "정상적으로 처리되었습니다.";
			
			data = memberService.memberFullManage(MapUtils.parseRequest(request, false, request.getParameter("enc_col")));
		}catch(Exception e){
			result = 0;
			msg = String.format("%s (%s)", "오류가 발생하였습니다.", e.getMessage());

			e.printStackTrace();
			throw e;
		}

		return ResultInfo.of(msg, result, data);
	}
	
	/**
	 * SMS 발송 관리
	 * @throws Exception
	 */
	@RequestMapping(value = "/msgSendManage.do", method = RequestMethod.POST)
	public ResultInfo msgSendManage(HttpServletRequest request) throws Exception {
		String msg = "";
		int result = 1;
		CommonMap data = new CommonMap();

		try {
			int success_cnt = memberService.msgSendManage(request);

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
}
