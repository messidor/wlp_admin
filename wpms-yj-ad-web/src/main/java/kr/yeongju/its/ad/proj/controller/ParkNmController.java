package kr.yeongju.its.ad.proj.controller;


import java.util.ArrayList;
import java.util.List;

import javax.annotation.Resource;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.multipart.MultipartHttpServletRequest;

import kr.yeongju.its.ad.common.dto.CommonMap;
import kr.yeongju.its.ad.common.exception.NotFoundException;
import kr.yeongju.its.ad.common.util.MapUtils;
import kr.yeongju.its.ad.core.service.CommonService;
import kr.yeongju.its.ad.proj.service.ParkService;

@Controller
@RequestMapping(value = "/park")
public class ParkNmController {

	@Resource(name = "commonService")
	private CommonService commonService;
	
	@Resource(name = "parkService")
	private ParkService parkService;
	
	/**
     * 학생 대량 등록을 위한 엑셀 업로드
     * @throws Exception 
     */
    @RequestMapping(value = "/parkingMassRegister.do", method = RequestMethod.POST)
    public String parkingMassRegister(MultipartHttpServletRequest request, Model model) throws Exception {
        List<CommonMap> resultList = new ArrayList<CommonMap>();

        try {

            resultList = parkService.parkingMassRegister(request, MapUtils.parseRequest(request));

            
        } catch(NotFoundException e) {

            e.printStackTrace();
            throw e;
        } catch (Exception e) {

            e.printStackTrace();
            throw e;
        }
        
        if(resultList.get(0).has("xlsChkMsg")) {
            model.addAttribute("xlsChkMsg", resultList.get(0).getString("xlsChkMsg"));
            resultList.remove(0);
        } else {
            model.addAttribute("xlsChkMsg", "");
        }
        
        model.addAttribute("xlsResultList", resultList);
        return "/proj/park/generalParkingUploadPopup";
    }
}
