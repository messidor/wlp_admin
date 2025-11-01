package kr.yeongju.its.ad.proj.restcontroller;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartHttpServletRequest;

import kr.yeongju.its.ad.common.dto.CommonMap;
import kr.yeongju.its.ad.common.dto.ResultInfo;
import kr.yeongju.its.ad.common.exception.NotFoundException;
import kr.yeongju.its.ad.common.util.MapUtils;
import kr.yeongju.its.ad.core.service.CommonService;
import kr.yeongju.its.ad.proj.service.BoardService;

@RestController
@RequestMapping(value = "/board")
public class BoardController {

	@Resource(name = "commonService")
	private CommonService commonService;
	
	@Resource(name = "boardService")
	private BoardService boardService;
	
	@RequestMapping(value = "/updateNotice.do", method = RequestMethod.POST)
	public ResponseEntity<ResultInfo> updateNotice(HttpSession session, HttpServletRequest request) throws Exception {
		ResultInfo result = null;
		
		try {
			result = boardService.updateNotice(session, request);
		} catch(NotFoundException e) {
			e.printStackTrace();
			throw e;
		} catch (Exception e) {
			e.printStackTrace();
			throw e;
		}

		return ResponseEntity.ok(result);
	}
	
	@RequestMapping(value = "/insertNotice.do", method = RequestMethod.POST)
	public ResponseEntity<ResultInfo> insertNotice(HttpSession session, HttpServletRequest request) throws Exception {
		ResultInfo result = null;
		try {
			result = boardService.insertNotice(session, request);
		} catch(NotFoundException e) {
			e.printStackTrace();
			throw e;
		} catch (Exception e) {
			e.printStackTrace();
			throw e;
		}

		return ResponseEntity.ok(ResultInfo.of(result.getMessage(), result.getCount(), result.getData()));
	}
	
	@RequestMapping(value = "/deleteNotice.do", method = RequestMethod.POST)
    public ResponseEntity<ResultInfo> deleteNotice(HttpSession session, HttpServletRequest request) throws Exception {
        ResultInfo result = null;
        try {
            result = boardService.deleteNotice(session, request);
        } catch(NotFoundException e) {
            e.printStackTrace();
            throw e;
        } catch (Exception e) {
            e.printStackTrace();
            throw e;
        }

        return ResponseEntity.ok(ResultInfo.of(result.getMessage(), result.getCount(), result.getData()));
    }
	
	@RequestMapping(value = "/updateInquiry.do", method = RequestMethod.POST)
	public ResultInfo updateInquiry(HttpServletRequest request) throws Exception {
		String msg = "";
		int result = 1;
		CommonMap data = new CommonMap();
		
		try {
			int success_cnt = boardService.updateInquiry(MapUtils.parseRequest(request, false, request.getParameter("enc_col")));

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
	
	@RequestMapping(value = "/deleteFile.do", method = RequestMethod.POST)
    public ResponseEntity<ResultInfo> deleteFile(HttpSession session, HttpServletRequest request) throws Exception {
        ResultInfo result = null;
        try {
            result = boardService.deleteFile(session, request);
        } catch(NotFoundException e) {
            e.printStackTrace();
            throw e;
        } catch (Exception e) {
            e.printStackTrace();
            throw e;
        }

        return ResponseEntity.ok(ResultInfo.of(result.getMessage(), result.getCount(), result.getData()));
    }
    
    @RequestMapping(value = "/selectInquiry.do", method = RequestMethod.POST)
    public ResponseEntity<ResultInfo> selectInquiry(HttpSession session, HttpServletRequest request) throws Exception {
        ResultInfo result = null;
        try {
            result = boardService.selectInquiry(session, request);
        } catch(NotFoundException e) {
            e.printStackTrace();
            throw e;
        } catch (Exception e) {
            e.printStackTrace();
            throw e;
        }
        
        return ResponseEntity.ok(ResultInfo.of(result.getMessage(), result.getCount(), result.getData()));
    }
    
    @RequestMapping(value = "/selectNotice.do", method = RequestMethod.POST)
    public ResponseEntity<ResultInfo> selectNotice(HttpSession session, HttpServletRequest request) throws Exception {
        ResultInfo result = null;
        try {
            result = boardService.selectNotice(session, request);
        } catch(NotFoundException e) {
            e.printStackTrace();
            throw e;
        } catch (Exception e) {
            e.printStackTrace();
            throw e;
        }
        
        return ResponseEntity.ok(ResultInfo.of(result.getMessage(), result.getCount(), result.getData()));
    }
    
    @RequestMapping(value = "/selectCorporationInquiry.do", method = RequestMethod.POST)
    public ResponseEntity<ResultInfo> selectCorporationInquiry(HttpSession session, HttpServletRequest request) throws Exception {
        ResultInfo result = null;
        try {
            result = boardService.selectCorporationInquiry(session, request);
        } catch(NotFoundException e) {
            e.printStackTrace();
            throw e;
        } catch (Exception e) {
            e.printStackTrace();
            throw e;
        }
        
        return ResponseEntity.ok(ResultInfo.of(result.getMessage(), result.getCount(), result.getData()));
    }
    
	@RequestMapping(value = "/updateCorporationInquiry.do", method = RequestMethod.POST)
	public ResultInfo updateCorporationInquiry(HttpServletRequest request) throws Exception {
		String msg = "";
		int result = 1;
		CommonMap data = new CommonMap();
		
		try {
			int success_cnt = boardService.updateCorporationInquiry(MapUtils.parseRequest(request, false, request.getParameter("enc_col")));

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
}
