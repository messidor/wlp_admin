package kr.yeongju.its.ad.proj.service;

import java.util.List;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import egovframework.rte.fdl.property.EgovPropertyService;
import kr.yeongju.its.ad.common.dto.CommonMap;
import kr.yeongju.its.ad.common.dto.ResultInfo;
import kr.yeongju.its.ad.common.util.CommonUtil;
import kr.yeongju.its.ad.common.util.MapUtils;
import kr.yeongju.its.ad.common.util.MsgUtil;
import kr.yeongju.its.ad.core.restcontroller.UploadController;
import kr.yeongju.its.ad.core.service.CommonService;

@Service("boardService")
public class BoardServiceImpl implements BoardService{
	
	@Resource(name = "commonService")
	private CommonService commonService;
	
	@Resource(name="propertyService")
    protected EgovPropertyService propertyService;
	
	@Transactional
	public ResultInfo updateNotice(HttpSession session, HttpServletRequest request) throws Exception {
				
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
            if(!isFileUploaded) {
                // 파일이 없거나 있다고 해도 업로드되지 않으면 FILE_REL_KEY는 화면에서 받아온 값을 그대로 넣어줌
                param.put("realFileRelKey", request.getParameter("fileRelKey"));
            } else {
                // FILE_REL_KEY 추가
                param.put("realFileRelKey", result.getData().getString("newFileRelKey"));
            }
            
            param.put("queryId", "board.announcement.Update_PopupData");
            
            // 제목과 내용을 꺼내온다.
            String boardTitle = param.getString("boardTitle");
            String boardContent = param.getString("boardContent");
            // 꺼내온 후 replace 처리
            boardTitle = CommonUtil.htmlSpecalChars(boardTitle);
            boardContent = CommonUtil.htmlSpecalChars(boardContent);
            // 다시 param 에 넣음
            param.put("boardTitle", boardTitle);
            param.put("boardContent", boardContent);
            
            // 파라미터 안넘어오는 오류로 직접 입력함
    		if(param.getString("popNoticeStartDate").isEmpty()) {
    			param.put("popNoticeStartDate", "");
    		}
    		if(param.getString("popNoticeEndDate").isEmpty()) {
    			param.put("popNoticeEndDate", "");
    		}
    		
    		if(param.getInt("mainFileKey") > 0) {
    			String fileKey = "";
    			if(result.getData().getString("finalFileKey").contains(",")) {
    				str = result.getData().getString("finalFileKey").substring(1, result.getData().getString("finalFileKey").length() - 1).replace(" ", "");

            		String[] fileKeyArr = str.split(",");
            		
            		fileKey = fileKeyArr[param.getInt("mainFileKey")-1];
    			}else {
    				str = result.getData().getString("finalFileKey").substring(1, result.getData().getString("finalFileKey").length() - 1).replace(" ", "");
    				
    				fileKey = str;
    			}
        		param.put("mainFileKey", fileKey);
    		}
            
            int updateCnt = commonService.update(param);
            
            if(result == null) {
                if(updateCnt > 0) {
                    msg = "정상적으로 처리되었습니다.";
                    count = 1;
                } else {
                    msg = "";
                    count = 0;
                }
                
                result = ResultInfo.of(msg, count, data);
            }
        }
		
		return result; 
	}
	
	@Transactional
	public ResultInfo insertNotice(HttpSession session, HttpServletRequest request) throws Exception {
				
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
		    // 로직 진행
		    
		    if(!isFileUploaded) {
		        // 파일 없을 경우 FILE_REL_KEY는 빈 값으로 처리
		        param.put("realFileRelKey", "");
		    } else {
		        // 파일 있으면 FILE_REL_KEY 추가
		        param.put("realFileRelKey", result.getData().getString("newFileRelKey"));
		    }
		    
		    // 제목과 내용을 꺼내온다.
            String boardTitle = param.getString("boardTitle");
            String boardContent = param.getString("boardContent");
            // 꺼내온 후 replace 처리
            boardTitle = CommonUtil.htmlSpecalChars(boardTitle);
            boardContent = CommonUtil.htmlSpecalChars(boardContent);
            // 다시 param 에 넣음
            param.put("boardTitle", boardTitle);
            param.put("boardContent", boardContent);
            
            // 파라미터 안넘어오는 오류로 직접 입력함
    		if(param.getString("popNoticeStartDate").isEmpty()) {
    			param.put("popNoticeStartDate", "");
    		}
    		if(param.getString("popNoticeEndDate").isEmpty()) {
    			param.put("popNoticeEndDate", "");
    		}
    		
    		/*if(param.getInt("mainImgIndex") > 0) {
        		str = result.getData().getString("finalFileKey").substring(1, result.getData().getString("finalFileKey").length() - 1).replace(" ", "");

        		String[] fileKeyArr = str.split(",");

        		param.put("mainFileKey", fileKeyArr[param.getInt("mainImgIndex")-1]);
    		}else{
    			param.put("mainFileKey", "");
    		}*/
    		
    		if(param.getInt("mainImgIndex") > 0) {
    			String fileKey = "";
    			if(result.getData().getString("finalFileKey").contains(",")) {
    				str = result.getData().getString("finalFileKey").substring(1, result.getData().getString("finalFileKey").length() - 1).replace(" ", "");

            		String[] fileKeyArr = str.split(",");
            		
            		fileKey = fileKeyArr[param.getInt("mainImgIndex")-1];
    			}else {
    				str = result.getData().getString("finalFileKey").substring(1, result.getData().getString("finalFileKey").length() - 1).replace(" ", "");
    				
    				fileKey = str;
    			}
        		param.put("mainFileKey", fileKey);
    		}else{
    			param.put("mainFileKey", "");
    		}


    		param.put("queryId", "board.announcement.Insert_PopupData");
    		int insertCnt = commonService.insert(param);

    		if(result == null) {
    		    if(insertCnt > 0) {
    		        msg = "정상적으로 처리되었습니다.";
    		        count = 1;
    		    } else {
    		        msg = "";
    		        count = 0;
    		    }

    		    result = ResultInfo.of(msg, count, data);
    		}
		}
		
		return result; 
	}
	
	@Transactional
    public ResultInfo deleteNotice(HttpSession session, HttpServletRequest request) throws Exception {
	    
	    UploadController uc = new UploadController(commonService);
        CommonMap param = MapUtils.parseRequest(request, false, request.getParameter("enc_col"));
        ResultInfo result = null;
        
        int deleteCnt = commonService.insert(param);
        
        if(deleteCnt > 0) {
            result = uc.uploadFileDelete(request);
        } else {
            result = ResultInfo.of("삭제하지 못하였습니다.", 0, new CommonMap());
        }
        
        // 파일 업로드가 없는 경우에 리턴해야 하는 경우
        String msg = "";
        int count = 0;
        CommonMap data = new CommonMap();
	    
	    return result;
	}
	
	@Transactional
	public int updateInquiry(CommonMap param) throws Exception {
	    
	    // 관리자의 댓글을 꺼내온다.
        String boardComment = param.getString("boardComment");
        // 꺼내온 후 replace 처리
        boardComment = CommonUtil.htmlSpecalChars(boardComment);
        // 다시 param 에 넣음
        param.put("boardComment", boardComment);
        
        param.put("queryId", "board.inquiry.Update_PopupData");
        int updateCnt = commonService.update(param);
        
        param.put("queryId", "board.inquiry.Select_boardMember");
        CommonMap memberInfo = commonService.selectOne(param);
        
        // 알림 메서드
		MsgUtil msg = new MsgUtil();
		CommonMap sendParam = new CommonMap();
		sendParam.put("recvId", param.getString("hMemberId"));
		sendParam.put("recvName", memberInfo.getString("memberName"));
		sendParam.put("recvPhone", memberInfo.getString("memberPhone"));
		sendParam.put("sendPhone", propertyService.getString("msgSendNumber"));
		sendParam.put("tplCode", "T00036");
		sendParam.put("memberName", memberInfo.getString("memberName"));
		
		if("Y".equals(memberInfo.getString("kakaoYn"))) {	
			msg.doSend(sendParam, "K");
		} else {
			msg.doSend(sendParam, "S");
		}
		
		return updateCnt; 
	}
	
	@Transactional
    public ResultInfo deleteFile(HttpSession session, HttpServletRequest request) throws Exception {
	    
	    UploadController uc = new UploadController(commonService);
        CommonMap param = MapUtils.parseRequest(request, false, request.getParameter("enc_col"));
        ResultInfo result = null;
        int deleteCnt = 0;
        
        result = uc.uploadFileDeleteSingle(request);

        param.put("queryId", "board.announcement.Select_FileList");
        CommonMap fileCnt = commonService.selectOne(param);
        
        if(fileCnt.getInt("cnt") < 1) {
            param.put("hBoardId", request.getParameter("hBoardId"));
            param.put("queryId", "board.announcement.Update_fileKeyDelete");
            deleteCnt = commonService.update(param);
        } 
        
        // 파일 업로드가 없는 경우에 리턴해야 하는 경우
        String msg = "";
        int count = 0;
        CommonMap data = new CommonMap();
	    
	    return result;
	}
	
    @Transactional
    public ResultInfo selectInquiry(HttpSession session, HttpServletRequest request) throws Exception {
        String message = "";
        int count = 1;
        CommonMap data = new CommonMap();
        CommonMap param = MapUtils.parseRequest(request);
        
        param.put("queryId", "board.inquiry.Select_PopupList");
        List<CommonMap> noticeList = commonService.select(param);
        
        if(noticeList.size() > 0) {
            for(int i = 0; i < noticeList.size(); i++) {
                CommonMap row = noticeList.get(i);
                
                // 제목, 내용, 관리자 댓글을 불러온다.
                String boardTitle = row.getString("boardTitle");
                String boardContent = row.getString("boardContent");
                String boardComment = row.getString("boardComment");
                
                // &gt; &lt; 를 원래 문자로 돌려준다.
                // textarea 안에 들어가기 때문에 클릭도 안되고 태그가 깨지는 일도 없다.
                // DB 값은 &gt; &lt; 의 형태로 저장되어 있음
                boardTitle = CommonUtil.htmlSpecalCharsRestore(boardTitle);
                boardContent = CommonUtil.htmlSpecalCharsRestore(boardContent);
                boardComment = CommonUtil.htmlSpecalCharsRestore(boardComment);
                
                // 다시 CommonMap 에 넣어준다.
                row.put("boardTitle", boardTitle);
                row.put("boardContent", boardContent);
                row.put("boardComment", boardComment);
                
                // 리스트에 값을 다시 넣어준다.
                noticeList.set(i, row);
            }
        }
        
        data.put("list", noticeList);
        
        return ResultInfo.of(message, count, data);
    }
    
    @Transactional
    public ResultInfo selectNotice(HttpSession session, HttpServletRequest request) throws Exception {
        String message = "";
        int count = 1;
        CommonMap data = new CommonMap();
        CommonMap param = MapUtils.parseRequest(request);
        
        param.put("queryId", "board.announcement.Select_PopupList");
        List<CommonMap> noticeList = commonService.select(param);
        
        if(noticeList.size() > 0) {
            for(int i = 0; i < noticeList.size(); i++) {
                CommonMap row = noticeList.get(i);
                
                // 제목, 내용, 관리자 댓글을 불러온다.
                String boardTitle = row.getString("boardTitle");
                String boardContent = row.getString("boardContent");
                
                // &gt; &lt; 를 원래 문자로 돌려준다.
                // textarea 안에 들어가기 때문에 클릭도 안되고 태그가 깨지는 일도 없다.
                // DB 값은 &gt; &lt; 의 형태로 저장되어 있음
                boardTitle = CommonUtil.htmlSpecalCharsRestore(boardTitle);
                boardContent = CommonUtil.htmlSpecalCharsRestore(boardContent);
                
                // 다시 CommonMap 에 넣어준다.
                row.put("boardTitle", boardTitle);
                row.put("boardContent", boardContent);
                
                // 리스트에 값을 다시 넣어준다.
                noticeList.set(i, row);
            }
        }
        
        data.put("list", noticeList);
        
        return ResultInfo.of(message, count, data);
    }
    
    @Transactional
    public ResultInfo selectCorporationInquiry(HttpSession session, HttpServletRequest request) throws Exception {
        String message = "";
        int count = 1;
        CommonMap data = new CommonMap();
        CommonMap param = MapUtils.parseRequest(request);
        
        param.put("queryId", "board.corporationInquiry.Select_PopupList");
        List<CommonMap> noticeList = commonService.select(param);
        
        if(noticeList.size() > 0) {
            for(int i = 0; i < noticeList.size(); i++) {
                CommonMap row = noticeList.get(i);
                
                // 제목, 내용, 관리자 댓글을 불러온다.
                String boardTitle = row.getString("boardTitle");
                String boardContent = row.getString("boardContent");
                String boardComment = row.getString("boardComment");
                
                // &gt; &lt; 를 원래 문자로 돌려준다.
                // textarea 안에 들어가기 때문에 클릭도 안되고 태그가 깨지는 일도 없다.
                // DB 값은 &gt; &lt; 의 형태로 저장되어 있음
                boardTitle = CommonUtil.htmlSpecalCharsRestore(boardTitle);
                boardContent = CommonUtil.htmlSpecalCharsRestore(boardContent);
                boardComment = CommonUtil.htmlSpecalCharsRestore(boardComment);
                
                // 다시 CommonMap 에 넣어준다.
                row.put("boardTitle", boardTitle);
                row.put("boardContent", boardContent);
                row.put("boardComment", boardComment);
                
                // 리스트에 값을 다시 넣어준다.
                noticeList.set(i, row);
            }
        }
        
        data.put("list", noticeList);
        
        return ResultInfo.of(message, count, data);
    }
    
	@Transactional
	public int updateCorporationInquiry(CommonMap param) throws Exception {
	    
	    // 관리자의 댓글을 꺼내온다.
        String boardComment = param.getString("boardComment");
        // 꺼내온 후 replace 처리
        boardComment = CommonUtil.htmlSpecalChars(boardComment);
        // 다시 param 에 넣음
        param.put("boardComment", boardComment);
        
        param.put("queryId", "board.corporationInquiry.Update_PopupData");
        int updateCnt = commonService.update(param);
        
        param.put("queryId", "board.corporationInquiry.Select_boardMember");
        CommonMap memberInfo = commonService.selectOne(param);
        
        // 알림 메서드
		MsgUtil msg = new MsgUtil();
		CommonMap sendParam = new CommonMap();
		sendParam.put("recvId", param.getString("hMemberId"));
		sendParam.put("recvName", memberInfo.getString("memberName"));
		sendParam.put("recvPhone", memberInfo.getString("memberPhone"));
		// 공단 전화번호로 발신
		sendParam.put("sendPhone", param.getString("hPGovTel"));
		sendParam.put("tplCode", "T00036");
		sendParam.put("memberName", memberInfo.getString("memberName"));
		
		if("Y".equals(memberInfo.getString("kakaoYn"))) {	
			msg.doSend(sendParam, "K");
		} else {
			msg.doSend(sendParam, "S");
		}
		
		return updateCnt; 
	}
}
