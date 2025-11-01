package kr.yeongju.its.ad.core.controller;

import java.util.ArrayList;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import egovframework.rte.fdl.property.EgovPropertyService;
import kr.yeongju.its.ad.common.dto.CommonMap;
import kr.yeongju.its.ad.common.dto.ResultInfo;
import kr.yeongju.its.ad.common.util.MapUtils;
import kr.yeongju.its.ad.core.restcontroller.UploadController;
import kr.yeongju.its.ad.core.service.CommonService;

@Controller
@RequestMapping("/_tst")
public class TestController {
    
    @Resource(name = "commonService")
    private final CommonService commonService;

    @Resource(name="propertyService")
    protected EgovPropertyService propertyService;

    @Autowired(required = true)
    public TestController(CommonService commonService) {
        this.commonService = commonService;
    }
    
    /**
     * chunkCustomUploadEncrypt
     */
    @RequestMapping(value = "/chunkCustomUploadEncrypt.do", method = RequestMethod.POST)
    public ResponseEntity<ResultInfo> chunkCustomUploadEncryptPost(HttpSession session, Model model,
            HttpServletRequest request, HttpServletResponse response) {

        // 업로드 컨트롤러
        UploadController uc = new UploadController(commonService);

        // Chunk upload 및 마무리
        ResultInfo res = uc.uploadChunkEncrypt(session, request);
        
        if (uc.isChunkComplete(request)) {
            // 실제 로직 추가
        }

        return ResponseEntity.ok(ResultInfo.of(res.getMessage(), res.getCount(), res.getData()));
    }
    
    @RequestMapping(value = "/{route1}.do", method = {RequestMethod.POST, RequestMethod.GET})
    public String chunk3Post(@PathVariable("route1") String route1, HttpSession session, Model model, HttpServletRequest request, HttpServletResponse response) {
        
        CommonMap param = MapUtils.parseSession(session);

        // JSP에서 "param" 이라는 이름으로 CommomMap을 사용할 수 있게 함
        model.addAttribute("param", param);
        model.addAttribute("properties", propertyService.getString("domain"));
        
        if("img_show_ex".equals(route1)) {
            UploadController uc = new UploadController(commonService);
            //FR2200001613 FF2200001627
//            String dataUri = uc.getDecryptedImageDataUri("FR2200000238", "FF2200000238", request);
            String dataUri = uc.getDecryptedImageDataUri("FR2300001623", "FF2300001637", request);
            
            model.addAttribute("imageUri", dataUri);
        } else if("call_api_test".equals(route1)) {
            model.addAttribute("cmnSvc", commonService);
            return "/_key/call_api_test";
        }

        return String.format("/_key/%s", route1);
    }

    /**
     * chunkCustomUploadEncrypt
     */
    @RequestMapping(value = "/chunkCustomUploadEncryptMulti.do", method = RequestMethod.POST)
    public ResponseEntity<ResultInfo> chunkCustomUploadEncryptMultiPost(HttpSession session, Model model,
            HttpServletRequest request, HttpServletResponse response) {

        // 업로드 컨트롤러
        UploadController uc = new UploadController(commonService);

        // Chunk upload 및 마무리
        ResultInfo res = uc.uploadChunkEncryptMulti(session, request);
        
        if (uc.isChunkCompleteMulti(request)) {
            // 실제 로직 추가
            ArrayList<String> finalFileKey = (ArrayList<String>)res.getData().get("finalFileKey");
        }

        return ResponseEntity.ok(ResultInfo.of(res.getMessage(), res.getCount(), res.getData()));
    }
}