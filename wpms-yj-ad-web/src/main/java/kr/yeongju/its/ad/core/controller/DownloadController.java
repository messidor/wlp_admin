package kr.yeongju.its.ad.core.controller;

import java.io.File;
import java.io.OutputStream;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.Base64;
import java.util.List;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

import egovframework.rte.fdl.property.EgovPropertyService;
import kr.yeongju.its.ad.common.dto.CommonMap;
import kr.yeongju.its.ad.common.util.EncUtil;
import kr.yeongju.its.ad.core.service.CommonService;

@Controller
@RequestMapping("/download")
public class DownloadController {

	@Resource(name = "commonService")
	private CommonService commonService;

    @Resource(name = "propertyService")
    private EgovPropertyService propertyService;

	@Autowired(required = true)
    public DownloadController(CommonService commonService) {
        this.commonService = commonService;
    }

	@RequestMapping(value = "/file", method = RequestMethod.GET)
    public void fileDecryptDownload(HttpServletRequest request, HttpServletResponse response, HttpSession session, Model model) throws Exception {
	    
	    String rootAd = propertyService != null ? propertyService.getString("rootAd") : "wpms-yj-ad-web";
	    String rootUs = propertyService != null ? propertyService.getString("rootUs") : "wpms-yj-us-web";
	    
	    // @PathVariable("fileData") String fileData, 
	    if(session.getAttribute("user_id") == null) {
//	        return "/core/static/404";
	        throw new Exception("Login required.");
	        
	    }
	    
        CommonMap dbParam = new CommonMap();
        List<CommonMap> fileResult = new java.util.ArrayList<CommonMap>();
        File origFile = null;
        EncUtil enc = new EncUtil();
        
        String fileData = request.getParameter("data");
        String fileRelKey = ""; //request.getParameter("fileRelKey");
        String fileKey = ""; //request.getParameter("fileKey");
        
        if(fileData == null) {
//            return "/core/static/404";
            throw new Exception("Param is null");
        }
        
        String fileDecData = enc.decrypt(fileData);
        
        if(fileDecData.indexOf("|") < 0) {
//            return "/core/static/404";
            throw new Exception("Param is empty");
        }
        
        String[] splitted = fileDecData.split("\\|"); // "|" 문자로 split 시도
        
        fileRelKey = splitted[0];
        fileKey = splitted[1];
        
        try {
            dbParam.put("queryId", "common.file.Select_FileInformation");
            dbParam.put("fileKey", fileKey);
            dbParam.put("fileRelKey", fileRelKey);
            fileResult = commonService.select(dbParam);
            
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
                    byte[] encoded = Files.readAllBytes(Paths.get(origFile.getAbsolutePath()));
                    byte[] decoded = enc.decByte(encoded);
                    String mimeType = Files.probeContentType(origFile.toPath());
                    byte[] origFileContents = Base64.getDecoder().decode(decoded);
                    String origFileName = fileInfo.getString("origFileName");
                    int fileLength = origFileContents.length;
                    
                    // Header 변경
                    response.setHeader("Content-Disposition", "attachment; filename=\"" + java.net.URLEncoder.encode(origFileName, "UTF-8") + "\";");
                    response.setHeader("Content-Transfer-Encoding", "binary");
                    response.setHeader("Content-Type", mimeType);
                    response.setHeader("Content-Length", "" + fileLength);
                    response.setHeader("Pragma", "no-cache;");
                    response.setHeader("Expires", "-1;");
                    
                    // Stream 을 통해 byte 배열을 넣어준다.
                    try(OutputStream outStream = response.getOutputStream()) {
                        outStream.write(origFileContents, 0, origFileContents.length);
                    } catch(Throwable ex) {
                        System.out.println("Downloading Error(write to stream error) ::: " + ex.toString());
//                        model.addAttribute("errMsg", "Downloading Error(write to stream error) ::: " + ex.toString());
                        throw new Exception("Downloading Error(write to stream error) ::: " + ex.toString());
                    }
                } else {
                    // no actual stored files found.
                    System.out.println("Downloading Error ::: No stored files found.");
//                    model.addAttribute("errMsg", "Downloading Error ::: No stored files found.");
                    throw new Exception("Downloading Error ::: No stored files found.");
                }
            } else {
                // no file information found.
                System.out.println("Downloading Error ::: No file information found in database.");
//                model.addAttribute("errMsg", "Downloading Error ::: No file information found in database.");
                throw new Exception("Downloading Error ::: No file information found in database.");
            }
        } catch(Throwable e) {
            System.out.println("Downloading Error(other exception occured) ::: " + e.toString());
//            model.addAttribute("errMsg", "Downloading Error(other exception occured) ::: " + e.toString());
            throw e;
        }
        
//        return "/core/static/download";
    }
}
