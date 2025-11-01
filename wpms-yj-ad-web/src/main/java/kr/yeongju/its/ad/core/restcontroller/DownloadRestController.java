package kr.yeongju.its.ad.core.restcontroller;

import java.io.File;
import java.util.List;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;
import egovframework.rte.fdl.property.EgovPropertyService;
import kr.yeongju.its.ad.common.dto.CommonMap;
import kr.yeongju.its.ad.common.dto.ResultInfo;
import kr.yeongju.its.ad.common.util.EncUtil;
import kr.yeongju.its.ad.core.service.CommonService;

@RestController
@RequestMapping(value = "/down")
public class DownloadRestController {

	@Resource(name = "commonService")
	private CommonService commonService;
	
	@Resource(name = "propertyService")
    private EgovPropertyService propertyService;

	@Autowired(required = true)
    public DownloadRestController(CommonService commonService) {
        this.commonService = commonService;
    }
	
	// 파일을 확인하고 정상적으로 다운로드 받을 수 있으면 URL을 생성하고, 아니면 오류 메시지를 리턴함
    @RequestMapping(value = "/makeUrl.do", method = {RequestMethod.POST, RequestMethod.GET})
    public ResultInfo receiveDownloadUrl(HttpSession session, Model model, HttpServletRequest request, HttpServletResponse response) {
        
        String rootAd = propertyService != null ? propertyService.getString("rootAd") : "wpms-yj-ad-web";
        String rootUs = propertyService != null ? propertyService.getString("rootUs") : "wpms-yj-us-web";
        
        CommonMap result = new CommonMap();
        CommonMap dbParam = new CommonMap();
        File origFile = null;
        EncUtil enc = new EncUtil();
        
        String fileData = "";
        String fileRelKey = "";
        String fileKey = "";
        
        result.put("url", "");
        result.put("errMsg", "");
        
        try {
            
            fileData = request.getParameter("data");
            
            if(fileData == null) {
                return ResultInfo.of("파일 다운로드에 필요한 값이 없습니다.", -2000, result);
            }
            if("".equals(fileData)) {
                return ResultInfo.of("파일 다운로드에 필요한 값이 비어 있습니다.", -2100, result);
            }
            
            fileData = enc.decrypt(fileData);
            String[] splitted = fileData.split("\\|"); // "|" 문자로 split 시도
            
            if(splitted.length != 2) {
                return ResultInfo.of("파일 다운로드에 필요한 값이 잘못되었습니다.", -2200, result);
            }
            
            fileRelKey = splitted[0];
            fileKey = splitted[1];
            
            // 로그인 여부 확인
            if(session.getAttribute("user_id") == null) {
                return ResultInfo.of("로그인이 필요합니다.", -1000, result);
            }
            
            // 현재 도메인을 받아옴
            String domain = propertyService.getString("domain");
            
            // 파일 키 또는 릴레이션 키가 NULL일 경우
            if(fileRelKey == null || fileKey == null) {
                return ResultInfo.of("파일 다운로드에 필요한 값이 없습니다.", -2000, result);
            }
            // 파일 키 또는 릴레이션 키가 빈값일 경우
            if("".equals(fileRelKey) || "".equals(fileKey)) {
                return ResultInfo.of("파일 다운로드에 필요한 값이 비어 있습니다.", -2100, result);
            }
            
            // 파일 확인 필요
            dbParam.put("queryId", "common.file.Select_FileInformation");
            dbParam.put("fileKey", fileKey);
            dbParam.put("fileRelKey", fileRelKey);
            List<CommonMap> fileResult = commonService.select(dbParam);
            
            if(fileResult.size() > 0) {
                CommonMap fileInfo = fileResult.get(0);
                // 웹 루트
                String rootPath = request.getSession().getServletContext().getRealPath("/");
                
                // 관리자/사용자 파일 경로를 모두 만든다.
                String pathUs = rootPath + "../" + rootUs + fileInfo.getString("filePath") + fileInfo.getString("storedFileName");
                String pathAd = rootPath + "../" + rootAd + fileInfo.getString("filePath") + fileInfo.getString("storedFileName");
                
                // 확인용 파일 객체 생성
                File fileUs = new File(pathUs);
                File fileAd = new File(pathAd);
                
                // 둘 중 하나라도 있으면 파일 객체를 생성하고, 아니면 null 처리
                if(fileUs.exists()) {
                    origFile = new File(pathUs);
                } else if(fileAd.exists()) {
                    origFile = new File(pathAd);
                } else {
                    origFile = null;
                }
                
                fileUs = null;
                fileAd = null;
                
                if(origFile != null) {
                    String encValue = java.net.URLEncoder.encode(enc.encrypt(fileRelKey + "|" + fileKey), "UTF-8");
                    result.put("url", domain + "/download/file?data=" + encValue);
                    return ResultInfo.of("정상적으로 처리되었습니다.", 1, result);
                } else {
                    return ResultInfo.of("해당 파일이 없습니다.", -3000, result);
                }
            } else {
                return ResultInfo.of("파일 정보가 없습니다.", -3100, result);
            }
            
        } catch(Throwable e) {
            
            // Exception 발생시
            result.put("errMsg", e.toString());
            return ResultInfo.of("파일 다운로드 URL 생성 도중 오류가 발생하였습니다.", -4000, result);
            
        }
    }
}
