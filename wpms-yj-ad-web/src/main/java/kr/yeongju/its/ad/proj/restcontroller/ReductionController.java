package kr.yeongju.its.ad.proj.restcontroller;

import java.awt.Stroke;
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
import kr.yeongju.its.ad.proj.service.ReductionService;


@RestController
@RequestMapping(value = "/reduction")
public class ReductionController {

	@Resource(name = "commonService")
	private CommonService commonService;
	
	@Resource(name = "reductionService")
	private ReductionService reductionService;


	@RequestMapping(value = "/reductionUpdate.do", method = RequestMethod.POST)
	public ResultInfo reductionUpdate(HttpServletRequest request) throws Exception {
		String msg = "";
		int result = 1;
		CommonMap data = new CommonMap();
		
		try {
			int success_cnt = reductionService.reductionUpdate(MapUtils.parseRequest(request));
			
			if(success_cnt < 1){
				result = 0;
				msg = "승인된 내역을 승인 할 수 없습니다.";
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
	
	@RequestMapping(value = "/popupUpdate.do", method = RequestMethod.POST)
	public ResultInfo popupUpdate(HttpServletRequest request) throws Exception {
		
		String msg = "";
		int result = 1;
		CommonMap data = new CommonMap(); 		
		try {
			result = reductionService.popupUpdate(MapUtils.parseRequest(request, false, request.getParameter("enc_col")));
			
			if(result == -2) {
				msg = "이미 거절 된 신청 건입니다.";
				result = 0;
			}else if(result == -3){
				msg = "이미 승인 된 신청 건입니다.";
				result = 0;
			}else if(result < 1){
				result = 0;
				msg = "승인된 내역을 승인 할 수 없습니다.";
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
