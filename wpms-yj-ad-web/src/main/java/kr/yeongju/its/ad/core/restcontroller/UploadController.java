package kr.yeongju.its.ad.core.restcontroller;

import java.io.File;
import java.io.FileOutputStream;
import java.lang.annotation.Annotation;
import java.lang.reflect.Constructor;
import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.lang.reflect.Parameter;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Base64;
import java.util.Collection;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.apache.tika.Tika;
import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationContext;
import org.springframework.util.FileCopyUtils;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.MultipartHttpServletRequest;
import egovframework.rte.fdl.property.EgovPropertyService;
import egovframework.rte.psl.dataaccess.util.CamelUtil;
import kr.yeongju.its.ad.common.config.ApplicationContextProvider;
import kr.yeongju.its.ad.common.dto.CommonMap;
import kr.yeongju.its.ad.common.dto.ResultInfo;
import kr.yeongju.its.ad.common.util.MapUtils;
import kr.yeongju.its.ad.common.util.SetableHttpServletRequest;
import kr.yeongju.its.ad.core.service.CommonService;
import kr.yeongju.its.ad.common.util.CommonUtil;
import kr.yeongju.its.ad.common.util.EncUtil;

@RestController
@RequestMapping(value = "/upload")
public class UploadController {

	@Resource(name = "commonService")
	private CommonService commonService;
	
	@Resource(name = "propertyService")
    private EgovPropertyService propertyService;
    
	@Autowired(required = true)
    public UploadController(CommonService commonService) {
        this.commonService = commonService;
    }
    
    private String file_Path = "/uploads/";
    
    /**
     * 임시 파일 업로드
     * 엑셀 데이터를 json으로 반환
     * @throws Exception 
     */
    @RequestMapping(value = "/uploadFileDelete.do", method = RequestMethod.POST)
    public ResultInfo uploadFileDelete(HttpServletRequest request) throws Exception {
            String msg = "";
            int result = 1;
            CommonMap data = new CommonMap();
        
        try {
             CommonMap param = MapUtils.parseRequest(request);
            
             param.put("query_id", "common.file.select_file_info");
             List<CommonMap> file_info = commonService.select(param);
             
             if(file_info.size() > 0) {
                 for(int i=0; i<file_info.size(); i++) {
                     CommonMap item = new CommonMap();
                     String full_file_path = request.getSession().getServletContext().getRealPath(file_info.get(i).getString("filePath"));
                     
                     item.put("fileKey", file_info.get(i).getString("fileKey"));
                     
                     item.put("query_id", "common.file.delete_file_info");
                     commonService.delete(item);
                     item.put("query_id", "common.file.delete_file_relation");
                     commonService.delete(item);
                     
                     if (new File(full_file_path+ file_info.get(i).getString("fileName")).exists()) { 
                         File file = new File(full_file_path + file_info.get(i).getString("fileName"));
                         //Path filePath = Paths.get(full_file_path + file_info.get(i).getString("fileName"));
                         //Files.delete(filePath);
                         file.delete(); 
                     } 
                 }           
             }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
        }

        return ResultInfo.of(msg, result, data);
    }
    
    /**
     * 파일삭제
     * @throws Exception 
     */
    @RequestMapping(value = "/userUploadFileDelete.do", method = RequestMethod.POST)
    public ResultInfo userUploadFileDelete(HttpServletRequest request) throws Exception {
        
        String rootUs = propertyService != null ? propertyService.getString("rootUs") : "wpms-us-web";
        
            String msg = "";
            int result = 1;
            CommonMap data = new CommonMap();
        
        try {
             CommonMap param = MapUtils.parseRequest(request);
            
             param.put("query_id", "common.file.select_file_info");
             List<CommonMap> file_info = commonService.select(param);
             
             if(file_info.size() > 0) {
                 for(int i=0; i<file_info.size(); i++) {
                     CommonMap item = new CommonMap();
                     String full_file_path = request.getSession().getServletContext().getRealPath("/") + "../" + rootUs + file_info.get(i).getString("filePath");
                     
                     item.put("fileKey", file_info.get(i).getString("fileKey"));
                     
                     item.put("query_id", "common.file.delete_file_info");
                     commonService.delete(item);
                     item.put("query_id", "common.file.delete_file_relation");
                     commonService.delete(item);
                     
                     if (new File(full_file_path+ file_info.get(i).getString("fileName")).exists()) { 
                         File file = new File(full_file_path + file_info.get(i).getString("fileName"));
                         //Path filePath = Paths.get(full_file_path + file_info.get(i).getString("fileName"));
                         //Files.delete(filePath);
                         file.delete(); 
                     } 
                 }           
             }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
        }

        return ResultInfo.of(msg, result, data);
    }
    
    @RequestMapping(value = "/uploadFileSingleDelete.do", method = RequestMethod.POST)
    public ResultInfo uploadFileDeleteSingle(HttpServletRequest request) throws Exception {
        String msg = "";
        int result = 1;
        CommonMap data = new CommonMap();
        CommonMap param = MapUtils.parseRequest(request);
        
        try {
            param.put("queryId", "common.file.Select_FileInformation");
            
            List<CommonMap> fileList = commonService.select(param);
            if(fileList.size() > 0) {
                String rootDir = request.getSession().getServletContext().getRealPath("/");
                
                if(rootDir.lastIndexOf("\\") == rootDir.length() - 1 || rootDir.lastIndexOf("/") == rootDir.length() - 1) {
                    rootDir = rootDir.substring(0, rootDir.length() - 1);
                }
                
                File delFile = new File(rootDir + fileList.get(0).getString("filePath") + fileList.get(0).getString("storedFileName"));
                
                if(delFile.exists()) {
                    
                    param.put("queryId", "common.file.delete_file_info");
                    commonService.delete(param);
                    
                    param.put("queryId", "common.file.Delete_FileRelationSingle");
                    commonService.delete(param);
                    
                    delFile.delete();
                    msg = "정상적으로 처리하였습니다.";
                    result = 1;
                    data.put("fileRelKey", param.getString("fileRelKey"));
                    data.put("fileKey", param.getString("fileKey"));
                } else {
                    System.out.println("UploadController.uploadFileDeleteSingle ::: No stored file found.");
                    msg = "해당 파일이 존재하지 않습니다.";
                    result = 0;
                    data = new CommonMap();
                }
                
            } else {
                System.out.println("UploadController.uploadFileDeleteSingle ::: No file information found.");
                msg = "해당 파일 정보가 없습니다.";
                result = 0;
                data = new CommonMap();
            }
        } catch(Throwable e) {
            System.out.println("UploadController.uploadFileDeleteSingle Exception occured :: " + e.toString());
            msg = "오류가 발생하여 삭제하지 못했습니다.";
            result = 0;
            data = new CommonMap();
        }
        
        return ResultInfo.of(msg, result, data);
    }
	
	/**
	 * 파일 업로드
	 * 엑셀 데이터를 json으로 반환
	 * @throws Exception 
	 */
	@RequestMapping(value = "/uploadfile.do", method = RequestMethod.POST)
	public ResultInfo uploadfile(MultipartHttpServletRequest request) throws Exception {
	    	String msg = "";
	    	int result = 1;
	    	CommonMap data = new CommonMap();
		
	    	/*
	    	file_rel_key: 
		_token: 
		upload_folder: temp
		uploadName: multiFiles
		fileExt: .xls,.xlsx,.csv
		singleRelation: false
		fn_prefix: 
		fn_suffix: 
		multiFiles[0]: (이진)
		multiple: true
	    	 */
		try {
			CommonMap param = MapUtils.parseRequest(request);
			CommonMap cache = new CommonMap();

			List<MultipartFile> files = null;
			
			/*
			if (param.getBoolean("multiple")) {
				files = request.getFiles(param.getString("uploadName"));
			} else {
				files = new ArrayList<MultipartFile>();
				files.add(request.getFile(param.getString("uploadName")));
			}
			*/
			//files = new ArrayList<MultipartFile>();
			//files.add(request.getFiles("multiFiles"));
			
			files=request.getFiles("multiFiles");
			
			if (files.size() > 0) {
				 String path = file_Path + param.getString("uploadFolder");
				 String full_file_path = request.getSession().getServletContext().getRealPath(path);
				 List<CommonMap> file_list = new ArrayList<CommonMap>();
				 File target = new File(full_file_path);
				 
				 if (!target.exists()) { 
					 target.mkdirs();
					 target.setReadable(true, false);
					 target.setWritable(true, false);
					 target.setExecutable(true, false);
				 }
				 
				 if (param.getString("file_rel_key").isEmpty() && !param.getBoolean("singleRelation")) {
					 param.put("file_rel_key", commonService.selectOne(new CommonMap("queryId", "common.file.select_newRelKey")).getString("newFileRelKey"));
				 }
				 
				 for(int i=0; i<files.size(); i++) {
					 CommonMap f = new CommonMap();
					 MultipartFile file = files.get(i);

					 String file_name = param.getString("fnPrefix") + (new Timestamp(System.nanoTime()).getTime()) + "_" + (i < 10 ? "0" + i : i) + param.getString("fnSuffix");
					 String file_orig_name = file.getOriginalFilename().substring(0, file.getOriginalFilename().lastIndexOf(".") );
					 String file_ext = file.getOriginalFilename().toLowerCase().substring(file.getOriginalFilename().lastIndexOf(".") + 1);
					 File saveFile = new File(full_file_path, file_name + "." + file_ext);
					 
					 try {
						FileCopyUtils.copy(file.getBytes(),saveFile);
						saveFile.setReadable(true, false);
						saveFile.setWritable(true, false);
						saveFile.setExecutable(true, false);
						//file.transferTo(saveFile);
						
						if (param.getBoolean("singleRelation")) {
							param.put("file_rel_key", commonService.selectOne(new CommonMap("queryId", "common.file.select_newRelKey")).getString("newFileRelKey"));
						}
						
						f.put("file_key", commonService.selectOne(new CommonMap("queryId", "common.file.select_newKey")).getString("newFileKey"));
						f.put("file_rel_key", param.get("fileRelKey"));
						f.put("file_size", Files.size(saveFile.toPath()));
						f.put("file_name", file_name);
						f.put("orig_file_name", file_orig_name);
						f.put("file_path", path); 
						f.put("file_ext", file_ext); 
						f.put("mime_type", Files.probeContentType(saveFile.toPath()));

						f.put("queryId", "common.file.insert_tempFileRelation");
						commonService.insert(f);
						
						f.put("queryId", "common.file.insert_tempFile");
						commonService.insert(f);
						
						System.out.println(f);
						file_list.add(f);
					} catch(Exception e) {
						e.printStackTrace();
					}
				 }
				 data.put("list", file_list);
			} 
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
		}

        return ResultInfo.of(msg, result, data);
	}
	
    // chunked data 를 합치는 용도
    public ResultInfo uploadChunk(HttpSession session, HttpServletRequest request) {
        String curIdxStr = request.getParameter("curIdx");
        String totalIdxStr = request.getParameter("totalIdx");
        String totalSizeStr = request.getParameter("totalSize");
        String blockSizeStr = request.getParameter("blockSize");
        String fileContStr = request.getParameter("fileCont");
        String fileName = request.getParameter("fileName");
        String uuid = request.getParameter("uuid");
        String uploadFileExt = request.getParameter("uploadFileExt");
        String maxFileSizeStr = request.getParameter("maxFileSize");
        
        String uploadFolder = request.getParameter("uploadFolder");
        
        CommonMap data = new CommonMap();
        int resultCode = 1;
        String resultString = "success";
        CommonMap param = MapUtils.parseSession(session);
        CommonMap dbParam = new CommonMap();
        CommonMap f = new CommonMap();
        List<CommonMap> dbResult;
        EncUtil enc = new EncUtil();
        StringBuilder contents = new StringBuilder();
        String uploadFilePath = "";
        data.put("newFileRelKey", "");
        
        if(propertyService == null) {
            uploadFilePath = "/uploads/";
        } else {
            uploadFilePath = propertyService.getString("uploadFilePath");
        }
        
        long curIdx = 0;
        long totalIdx = 0;
        long totalSize = 0;
        long blockSize = 0;
        long maxFileSize = 0;
        
        try { curIdx = Long.parseLong(curIdxStr, 10); } catch(NumberFormatException e) { curIdx = 0; }
        try { totalIdx = Long.parseLong(totalIdxStr, 10); } catch(NumberFormatException e) { totalIdx = 0; }
        try { totalSize = Long.parseLong(totalSizeStr, 10); } catch(NumberFormatException e) { totalSize = 0; }
        try { blockSize = Long.parseLong(blockSizeStr, 10); } catch(NumberFormatException e) { blockSize = 0; }
        try { maxFileSize = Long.parseLong(maxFileSizeStr, 10); } catch(NumberFormatException e) { maxFileSize = 0; }
        
        //fileContStr
//        byte[] piece = java.util.Base64.getDecoder().decode(fileContStr);
                
        // 진행 중
        try {
            
//            // 최초 파일을 받은 다음 확장자 검사를 한다.
            String[] extensions = uploadFileExt.split("\\|"); // 또는 "[|]" 도 가능
            String file_ext = fileName.substring(fileName.lastIndexOf(".") + 1).toLowerCase();
            boolean isFound = false;
            for(int i = 0; i < extensions.length; i++) {
                if(extensions[i].toLowerCase().equals(file_ext)) {
                    isFound = true;
                } 
            }
            if(!isFound) {
                resultString = "File extension is not allowed.";
                resultCode = -1500;
                return ResultInfo.of(resultString, resultCode, data);
            }
            
            // 수신된 파일 크기를 비교하여 체크
            if(totalSize > maxFileSize && maxFileSize > 0) {
                resultString = "File size limit is exceed(max " + maxFileSize + " bytes).";
                resultCode = -1510;
                return ResultInfo.of(resultString, resultCode, data);
            }
            
            // DB에 추가
            dbParam.put("queryId", "chunk.chunkFile.insert_newChunkData");
            dbParam.put("uuid", uuid, false);
            dbParam.put("idx", curIdxStr, false);
            dbParam.put("contents", enc.encrypt(fileContStr), false);
            
            int resIns = 0;
            
            if(dbParam.getString("contents").length() > 0) {
                try {
                    resIns = commonService.insert(dbParam);
                } catch(Exception e2) {
                    e2.printStackTrace();
                    resultString = "Failed when insert DB(Exception).";
                    resultCode = -1000;
                }
            } else {
                resIns = 0;
                resultString = "Failed when insert DB(no contents).";
                resultCode = -1010;
                return ResultInfo.of(resultString, resultCode, data);
            }
            
            if(resIns < 1) {
                resultString = "No chunk data is inserted.";
                resultCode = -1000;
            } else {
                if(curIdx == totalIdx - 1) {
                    // 완료
                    // 1. DB에 있는 모든 데이터를 읽는다.
                    // 2. 각 데이터를 Base64 Decode 처리한다.
                    // 3. 각 데이터를 하나의 변수에 담는다. (Stringbuilder)
                    // 4. 해당 데이터로 파일을 하나 생성하여 저장한다.
                    // 5. 해당 폴더로 가서 확인할 것
                    
                    // select_allChunkedData
                    
                    dbParam.clear();
                    dbParam.put("queryId", "chunk.chunkFile.select_allChunkedData");
                    dbParam.put("uuid", uuid);
                    
//                    Thread.sleep(100);
                    dbResult = commonService.select(dbParam);
                    
                    if(dbResult.size() > 0) {
                        for(int i = 0; i < dbResult.size(); i++) {
                            String s = dbResult.get(i).getString("contents");
                            contents.append(s);
                        }
//                        for(CommonMap map : dbResult) {
//                            String s = map.getString("contents");
//                            contents.append(s);
//                        }
                        try {
//                            BufferedImage image;
                            
                            byte[] decoded = java.util.Base64.getDecoder().decode(contents.toString());
//                            ByteArrayInputStream bis = new ByteArrayInputStream(decoded);
//                            image = ImageIO.read(bis);
//                            bis.close();

                            // write the image to a file
                            // uploadFilePath example : "/uploads/"
                            // uploadFolder example : "apply/temp/"
                            String rootDir = request.getSession().getServletContext().getRealPath("/");
                            
                            if(rootDir.lastIndexOf("\\") == rootDir.length() - 1 || rootDir.lastIndexOf("/") == rootDir.length() - 1) {
                                rootDir = rootDir.substring(0, rootDir.length() - 1);
                            }
                            
                            String fullFilePath = rootDir + uploadFilePath + uploadFolder;
                            
                            // 폴더 없으면 만들도록 처리
                            File target = new File(fullFilePath);
                            if (!target.exists()) { 
                                target.mkdirs();
                                target.setReadable(true, false);
                                target.setWritable(true, false);
                                target.setExecutable(true, false);
                            }
                            
                            // 파일명 생성
                            String file_name = 
                                    param.getString("fnPrefix") + 
                                    (param.has("fnPrefix") ? "_" : "") + 
                                    (new Timestamp(System.nanoTime()).getTime()) + 
                                    "F" + CommonUtil.randomString(8) +
                                    (param.has("fnSuffix") ? "_" : "") + 
                                    param.getString("fnSuffix");
                            String file_orig_name = fileName.substring(0, fileName.lastIndexOf("."));
                            file_ext = fileName.substring(fileName.lastIndexOf(".") + 1);
                            
                            // File key, Relation key 생성
                            
                            // 실제 저장할 파일경로 및 파일명
                            File outputfile = new File(fullFilePath + file_name + "." + file_ext);
                            // 이미지 생성후 저장
//                            ImageIO.write(image, (file_ext == "jpeg" ? "jpg" : file_ext), outputfile);
                            
                            try (FileOutputStream fos = new FileOutputStream(fullFilePath + file_name + "." + file_ext)) {
                                fos.write(decoded);
                            } catch(Exception fe) {
                                fe.printStackTrace();
                                resultString = "Failed to write file: " + fe.toString();
                                resultCode = -2000;
                                return ResultInfo.of(resultString, resultCode, data);
                            }
                            
                            // 파일 크기 초과 검사
                            if(Files.size(outputfile.toPath()) > maxFileSize && maxFileSize > 0) {
                                Files.delete(outputfile.toPath());
                                resultString = "File size limit is exceed(max " + maxFileSize + " bytes).";
                                resultCode = -1510;
                                return ResultInfo.of(resultString, resultCode, data);
                            }
                            
                            outputfile.setReadable(true, false);
                            outputfile.setWritable(true, false);
                            outputfile.setExecutable(true, false);
                            
                            f.put("memberId", enc.encrypt(session.getAttribute("user_id").toString()), false);
                            f.put("file_key", commonService.selectOne(new CommonMap("queryId", "common.file.select_newKey")).getString("newFileKey"));
                            f.put("file_rel_key", commonService.selectOne(new CommonMap("queryId", "common.file.select_newRelKey")).getString("newFileRelKey"));
                            f.put("file_size", Files.size(outputfile.toPath()));
                            f.put("file_name", file_name);
                            f.put("orig_file_name", file_orig_name);
                            f.put("file_path", (uploadFilePath + uploadFolder)); 
                            f.put("file_ext", file_ext); 
                            f.put("mime_type", Files.probeContentType(outputfile.toPath()));
                            f.put("memberId", enc.encrypt(param.getString("memberId")), false);
                            f.put("queryId", "common.file.insert_tempFileRelation");
                            commonService.insert(f);
                            
                            f.put("queryId", "common.file.insert_tempFile");
                            commonService.insert(f);
                            
                            resultString = "Upload completed.";
                            resultCode = 1;
                            data.put("newFileRelKey", f.getString("fileRelKey"));
                        } catch(Exception ie) {
                            ie.printStackTrace();
                            
                            resultString = "Failed because of Exception: " + ie.toString();
                            resultCode = -2000;
                        } finally {
                            // DB에 임시로 저장했던 데이터 삭제
                            param.clear();
                            param.put("queryId", "chunk.chunkFile.delete_chunkData");
                            param.put("uuid", uuid);
                            
                            commonService.delete(param);
                        }
                    }
                } else {
                    resultString = "Chunk data has been uploaded successfully.";
                    resultCode = 2;
                }
            }
            
        } catch(Exception e) {
            e.printStackTrace();
            resultString = "Failed to run. Chunk data has not been uploaded:" + e.toString();
            resultCode = -1000;
        }
        
        return ResultInfo.of(resultString, resultCode, data);
    }
    
    public boolean isChunkComplete(HttpServletRequest request) {
        // Chunk 번호 받아오기 (완료 여부 판단용)
        String curIdxStr = request.getParameter("curIdx");
        String totalIdxStr = request.getParameter("totalIdx");
        
        // chunk 번호
        long curIdx = 0, totalIdx = 0;
        
        // 숫자로 변환
        try { curIdx = Long.parseLong(curIdxStr, 10); } catch(NumberFormatException e) { curIdx = 0; }
        try { totalIdx = Long.parseLong(totalIdxStr, 10); } catch(NumberFormatException e) { totalIdx = 0; }
        
        return (curIdx == totalIdx - 1);
    }

    // chunked data를 합치는 용도 (암호화 하여 업로드)
    public ResultInfo uploadChunkEncrypt(HttpSession session, HttpServletRequest request) {
        String curIdxStr = request.getParameter("curIdx");
        String totalIdxStr = request.getParameter("totalIdx");
        String totalSizeStr = request.getParameter("totalSize");
        String blockSizeStr = request.getParameter("blockSize");
        String fileContStr = request.getParameter("fileCont");
        String fileName = request.getParameter("fileName");
        String uuid = request.getParameter("uuid");
        String uploadFileExt = request.getParameter("uploadFileExt");
        String maxFileSizeStr = request.getParameter("maxFileSize");
        String uploadFolder = request.getParameter("uploadFolder");
        CommonMap data = new CommonMap();
        int resultCode = 1;
        String resultString = "success";
        CommonMap param = MapUtils.parseSession(session);
        CommonMap dbParam = new CommonMap();
        CommonMap f = new CommonMap();
        List<CommonMap> dbResult;
        EncUtil enc = new EncUtil();
        StringBuilder contents = new StringBuilder();
        String uploadFilePath = "";
        
        data.put("newFileRelKey", "");
        
        if(propertyService == null) {
            uploadFilePath = "/uploads/";
        } else {
            uploadFilePath = propertyService.getString("uploadFilePath");
        }
        
        long curIdx = 0;
        long totalIdx = 0;
        long totalSize = 0;
        long blockSize = 0;
        long maxFileSize = 0;
        
        try { curIdx = Long.parseLong(curIdxStr, 10); } catch(NumberFormatException e) { curIdx = 0; }
        try { totalIdx = Long.parseLong(totalIdxStr, 10); } catch(NumberFormatException e) { totalIdx = 0; }
        try { totalSize = Long.parseLong(totalSizeStr, 10); } catch(NumberFormatException e) { totalSize = 0; }
        try { blockSize = Long.parseLong(blockSizeStr, 10); } catch(NumberFormatException e) { blockSize = 0; }
        try { maxFileSize = Long.parseLong(maxFileSizeStr, 10); } catch(NumberFormatException e) { maxFileSize = 0; }
        
        //fileContStr
        // byte[] piece = java.util.Base64.getDecoder().decode(fileContStr);
                
        // 진행 중
        try {
            
            // 최초 파일을 받은 다음 확장자 검사를 한다.
            String[] extensions = uploadFileExt.split("\\|"); // 또는 "[|]" 도 가능
            String file_ext = fileName.substring(fileName.lastIndexOf(".") + 1).toLowerCase();
            boolean isFound = false;
            for(int i = 0; i < extensions.length; i++) {
                if(extensions[i].toLowerCase().equals(file_ext)) {
                    isFound = true;
                } 
            }
            if(!isFound) {
                resultString = "File extension is not allowed.";
                resultCode = -1500;
                return ResultInfo.of(resultString, resultCode, data);
            }
            
            // 수신된 파일 크기를 비교하여 체크
            if(totalSize > maxFileSize && maxFileSize > 0) {
                resultString = "File size limit is exceed(max " + maxFileSize + " bytes).";
                resultCode = -1510;
                return ResultInfo.of(resultString, resultCode, data);
            }
            
            // DB에 추가
            dbParam.put("queryId", "chunk.chunkFile.insert_newChunkData");
            dbParam.put("uuid", uuid, false);
            dbParam.put("idx", curIdxStr, false);
            dbParam.put("contents", enc.encrypt(fileContStr), false);
            
            int resIns = 0;
            try {
                resIns = commonService.insert(dbParam);
            } catch(Exception e2) {
                e2.printStackTrace();
                resultString = "Failed when insert DB.";
                resultCode = -1000;
            }
            
            if(resIns < 1) {
                resultString = "No chunk data is inserted.";
                resultCode = -1000;
            } else {
                if(curIdx == totalIdx - 1) {
                    // 완료
                    // 1. DB에 있는 모든 데이터를 읽는다.
                    // 2. 각 데이터를 Base64 Decode 처리한다.
                    // 3. 각 데이터를 하나의 변수에 담는다. (Stringbuilder)
                    // 4. 해당 데이터로 파일을 하나 생성하여 저장한다.
                    // 5. 해당 폴더로 가서 확인할 것
                    
                    // select_allChunkedData
                    
                    dbParam.clear();
                    dbParam.put("queryId", "chunk.chunkFile.select_allChunkedData");
                    dbParam.put("uuid", uuid);
                    
                    // Thread.sleep(100);
                    dbResult = commonService.select(dbParam);
                    
                    if(dbResult.size() > 0) {
                        for(int i = 0; i < dbResult.size(); i++) {
                            String s = dbResult.get(i).getString("contents");
                            contents.append(s);
                        }

                        try {

                            // write the image to a file
                            // uploadFilePath example : "/uploads/"
                            // uploadFolder example : "apply/temp/"
                            String rootDir = request.getSession().getServletContext().getRealPath("/");
                            
                            if(rootDir.lastIndexOf("\\") == rootDir.length() - 1 || rootDir.lastIndexOf("/") == rootDir.length() - 1) {
                                rootDir = rootDir.substring(0, rootDir.length() - 1);
                            }
                            
                            String fullFilePath = rootDir + uploadFilePath + uploadFolder;
                            
                            // 폴더 없으면 만들도록 처리
                            File target = new File(fullFilePath);
                            if (!target.exists()) { 
                                target.mkdirs();
                                target.setReadable(true, false);
                                target.setWritable(true, false);
                                target.setExecutable(true, false);
                            }
                            
                            // 파일명 생성
                            String file_name = 
                                    param.getString("fnPrefix") + 
                                    (param.has("fnPrefix") ? "_" : "") + 
                                    (new Timestamp(System.nanoTime()).getTime()) + 
                                    "F" + CommonUtil.randomString(8) +
                                    (param.has("fnSuffix") ? "_" : "") + 
                                    param.getString("fnSuffix");
                            String file_orig_name = fileName.substring(0, fileName.lastIndexOf("."));
                            file_ext = fileName.substring(fileName.lastIndexOf(".") + 1);
                            
                            // File key, Relation key 생성
                            
                            // 실제 저장할 파일경로 및 파일명
                            File outputfile = new File(fullFilePath + file_name + "." + file_ext);
                            // 이미지 생성후 저장
                            // ImageIO.write(image, (file_ext == "jpeg" ? "jpg" : file_ext), outputfile);
                            
                            try (FileOutputStream fos = new FileOutputStream(fullFilePath + file_name + "." + file_ext)) {
                                // 파일 정보를 암호화 한다 (EncUtil, AES256)
                                byte[] encArray = enc.encByte(contents.toString().getBytes("UTF-8"));
                                // 암호화 한 파일 내용을 파일에 쓴다(write).
                                // 만들어진 파일에 대한 용량 검사는 하지 않는다.
                                // 이유 : 암호화하면 파일 길이가 늘어나기 때문이다.
                                fos.write(encArray);
                            } catch(Throwable fe) {
                                fe.printStackTrace();
                                resultString = "Failed to write file: " + fe.toString();
                                resultCode = -2000;
                                return ResultInfo.of(resultString, resultCode, data);
                            }
                            
                            outputfile.setReadable(true, false);
                            outputfile.setWritable(true, false);
                            outputfile.setExecutable(true, false);
                            
                            f.put("fileKey", commonService.selectOne(new CommonMap("queryId", "common.file.select_newKey")).getString("newFileKey"));
                            f.put("fileRelKey", commonService.selectOne(new CommonMap("queryId", "common.file.select_newRelKey")).getString("newFileRelKey"));
                            f.put("fileSize", Files.size(outputfile.toPath()));
                            f.put("fileName", file_name);
                            f.put("origFileName", file_orig_name);
                            f.put("filePath", (uploadFilePath + uploadFolder)); 
                            f.put("fileExt", file_ext); 
                            f.put("mime_type", Files.probeContentType(outputfile.toPath()));
                            f.put("memberId", enc.encrypt(param.getString("memberId")), false);
                            f.put("queryId", "common.file.insert_tempFileRelation");
                            commonService.insert(f);
                            
                            f.put("queryId", "common.file.insert_tempFile");
                            commonService.insert(f);
                            
                            resultString = "Upload completed.";
                            resultCode = 1;
                            data.put("newFileRelKey", f.getString("fileRelKey"));
                            data.put("newFileKey", f.getString("fileKey"));
                        } catch(Exception ie) {
                            ie.printStackTrace();
                            
                            resultString = "Failed because of Exception: " + ie.toString();
                            resultCode = -2000;
                        } finally {
                            // DB에 임시로 저장했던 데이터 삭제
                            param.clear();
                            param.put("queryId", "chunk.chunkFile.delete_chunkData");
                            param.put("uuid", uuid);
                            
                            commonService.delete(param);
                        }
                    }
                } else {
                    resultString = "Chunk data has been uploaded successfully.";
                    resultCode = 2;
                }
            }
            
        } catch(Exception e) {
            e.printStackTrace();
            resultString = "Failed to run. Chunk data has not been uploaded:" + e.toString();
            resultCode = -1000;
        }
        
        return ResultInfo.of(resultString, resultCode, data);
    }
    
    /**
     * 파일 키와 연계 키를 통해 이미지의 경우 파일을 복호화 하고 이미지 Data URI를 생성하여 리턴하고, 동영상의 경우 해당 경로를 리턴하는 함수
     * @param fileRelKey 파일 연계 키
     * @param fileKey 파일 키
     * @param request request객체
     * @return 파일 Data URI 또는 동영상 위치 (DB에 정보가 없거나, 이미지 파일이 아니거나, 실제 파일이 없거나, 오류가 발생하는 경우 빈값 리턴)
     */
    public String getMediaDecryptedData(String fileRelKey, String fileKey, HttpServletRequest request) {
        
        String rootAd = propertyService != null ? propertyService.getString("rootAd") : "wpms-yj-ad-web";
        String rootUs = propertyService != null ? propertyService.getString("rootUs") : "wpms-yj-us-web";
        
        String result = "";
        CommonMap dbParam = new CommonMap();
        List<CommonMap> fileResult = new java.util.ArrayList<CommonMap>();
        
        try {
            dbParam.put("queryId", "common.file.Select_FileInformation");
            dbParam.put("fileKey", fileKey);
            dbParam.put("fileRelKey", fileRelKey);
            fileResult = commonService.select(dbParam);
            
            if(fileResult.size() > 0) {
                CommonMap fileRow = fileResult.get(0);
                String mimeType = fileRow.getString("mimeType");
                String fileExt = fileRow.getString("fileExt");
                
                mimeType = mimeType.toLowerCase();
                fileExt = fileExt.toLowerCase();
                
                if(mimeType.indexOf("video/") > -1) {
                    // 동영상 파일
                    
                    // 웹 루트
                    String rootPath = request.getSession().getServletContext().getRealPath("/");
                    
                    // 관리자/사용자 파일 경로를 모두 만든다.
                    String pathUs = rootPath + ".." + File.separator + rootUs + fileRow.getString("filePath") + fileRow.getString("storedFileName");
                    String pathAd = rootPath + ".." + File.separator + rootAd + fileRow.getString("filePath") + fileRow.getString("storedFileName");
                    
                    // 확인용 파일 객체 생성
                    File fileUs = new File(pathUs);
                    File fileAd = new File(pathAd);
                    
                    // 둘 중 하나라도 있으면 해당 경로를 사용하고, 아니면 빈값 리턴
                    if(fileUs.exists()) {
                        result = "/walletfree" + fileRow.getString("filePath") + fileRow.getString("storedFileName");
                    } else if(fileAd.exists()) {
                        result = "/walletfree-admin" + fileRow.getString("filePath") + fileRow.getString("storedFileName");;
                    } else {
                        System.out.println("getMediaDecryptedData Error ::: File does not exist.");
                        result = "";
                    }
                } else if(mimeType.indexOf("image/") > -1) {
                    // 이미지 decrypt 처리 후 data uri 전송
                    result = getDecryptedImageDataUri(fileRelKey, fileKey, request);
                } else {
                    // not an image or video file.
                    System.out.println("getMediaDecryptedData Error ::: It is neither an image file or a video file.");
                    result = "";
                }
            } else {
                // no file information found.
                System.out.println("getMediaDecryptedData Error ::: No file information found in database.");
                result = "";
            }
            
        } catch(Throwable e) {
            e.printStackTrace();
            result = "";
        }
        
        return result;
    }

    /**
     * 파일 키와 연계 키를 통해 파일을 복호화 하고 이미지 Data URI를 생성하여 리턴하는 함수
     * @param fileRelKey 파일 연계 키
     * @param fileKey 파일 키
     * @param request request객체
     * @return 파일 Data URI (DB에 정보가 없거나, 이미지 파일이 아니거나, 실제 파일이 없거나, 오류가 발생하는 경우 빈값 리턴)
     */
    public String getDecryptedImageDataUri(String fileRelKey, String fileKey, HttpServletRequest request) {
        
        String rootAd = propertyService != null ? propertyService.getString("rootAd") : "wpms-yj-ad-web";
        String rootUs = propertyService != null ? propertyService.getString("rootUs") : "wpms-yj-ad-web";
        
        CommonMap dbParam = new CommonMap();
        List<CommonMap> fileResult = new java.util.ArrayList<CommonMap>();
        File origFile = null;
        EncUtil enc = new EncUtil();
        
        try {
            dbParam.put("queryId", "common.file.Select_FileInformation");
            dbParam.put("fileKey", fileKey);
            dbParam.put("fileRelKey", fileRelKey);
            fileResult = commonService.select(dbParam);
            
            if(fileResult.size() > 0) {
                CommonMap fileInfo = fileResult.get(0);
                
                if(fileInfo.getString("mimeType").indexOf("image/") > -1) {
                    
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
                        
                        return "data:" + mimeType + ";base64," + new String(decoded);
                    } else {
                        // no actual stored files found.
                        System.out.println("getImageDataURI Error ::: No stored files found.");
                        return "";
                    }
                } else {
                    // not an image file.
                    System.out.println("getImageDataURI Error ::: It is not an image file.");
                    return "";
                }
            } else {
                // no file information found.
                System.out.println("getImageDataURI Error ::: No file information found in database.");
                return "";
            }
        } catch(Throwable e) {
            System.out.println("getImageDataURI Error ::: " + e.toString());
            return "";
        }
    }
    
    // 이미지를 복호화 하거나 비디오 경로를 갖고 옴
    @RequestMapping(value = "/getVideoDataUri.do", method = RequestMethod.POST)
    public ResultInfo getVideoPathPost(HttpServletRequest request) {
        String fileRelKey = request.getParameter("fileRelKey");
        String fileKey = request.getParameter("fileKey");
        String fileName = request.getParameter("fileName");
        String mainImgYn = request.getParameter("mainImgYn");
        EncUtil enc = new EncUtil();
        
        CommonMap data = new CommonMap();
        data.put("imgDataUri", "");
        data.put("fileName", fileName);
        data.put("fileKey", fileKey);
        data.put("mainImgYn", mainImgYn);
        data.put("encData", "");
        
        if(fileRelKey == null || fileKey == null) {
            // null 이면.. 애초에 호출을 잘못한거라 오류를 리턴할 것
            return ResultInfo.of("잘못된 호출입니다.", -1, data);
        } else {
            String encData = enc.encrypt(fileRelKey + "|" + fileKey);
            String res = getMediaDecryptedData(fileRelKey, fileKey, request);
            data.put("encData", encData, false);
            data.put("imgDataUri", res, false);
        }
        
        return ResultInfo.of("", 1, data);
    }
    
    // 특정 이미지를 복호화하여 볼 수 있는 코드로 변환
    // FILE_REL_KEY, FILE_KEY 필요
    @RequestMapping(value = "/getImgDataUri.do", method = RequestMethod.POST)
    public ResultInfo getDecryptedImageDataUriPost(HttpServletRequest request) {
        
        String fileRelKey = request.getParameter("fileRelKey");
        String fileKey = request.getParameter("fileKey");
        String fileName = request.getParameter("fileName");
        String mainImgYn = request.getParameter("mainImgYn");
        
        CommonMap data = new CommonMap();
        data.put("imgDataUri", "");
        data.put("fileName", fileName);
        data.put("fileKey", fileKey);
        data.put("mainImgYn", mainImgYn);
        
        if(fileRelKey == null || fileKey == null) {
            // null 이면.. 애초에 호출을 잘못한거라 오류를 리턴할 것
            return ResultInfo.of("잘못된 호출입니다.", -1, data);
        } else {
            String res = this.getDecryptedImageDataUri(fileRelKey, fileKey, request);
            data.put("imgDataUri", res, false);
        }
        
        return ResultInfo.of("", 1, data);
    }
    
    // 특정 파일의 다운로드 코드를 생성하는 함수
    // FILE_REL_KEY, FILE_KEY 필요
    @RequestMapping(value = "/getEncFileData.do", method = RequestMethod.POST)
    public ResultInfo getEncryptedFileKey(HttpServletRequest request) {
        
        String fileRelKey = request.getParameter("fileRelKey");
        String fileKey = request.getParameter("fileKey");
        String fileName = request.getParameter("fileName");
        String mainImgYn = request.getParameter("mainImgYn");
        CommonMap data = new CommonMap();
        EncUtil enc = new EncUtil();
        
        data.put("fileName", fileName);
        data.put("fileKey", fileKey);
        data.put("mainImgYn", mainImgYn);
        
        if(fileRelKey == null || "".equals(fileRelKey)) {
            // null 이면.. 애초에 호출을 잘못한거라 오류를 리턴할 것
            return ResultInfo.of("잘못된 호출입니다.", -1, data);
        } else {
            data.put("encData", enc.encrypt(fileRelKey + "|" + fileKey), false);
        }
        
        return ResultInfo.of("", 1, data);
    }

    // FILE_REL_KEY 하나로 연결된 모든 파일의 다운로드 코드를 생성해 주는 함수
    @RequestMapping(value = "/getEncFileDataArray.do", method = RequestMethod.POST)
    public ResultInfo getEncryptedFileKeyArray(HttpServletRequest request) {
        
        String fileRelKey = request.getParameter("fileRelKey");
        CommonMap data = new CommonMap();
        CommonMap param = new CommonMap();
        EncUtil enc = new EncUtil();
        String retMsg = "";
        int retCount = 0;

        if(fileRelKey == null || "".equals(fileRelKey)) {
            // null 이면.. 애초에 호출을 잘못한거라 오류를 리턴할 것
            data = new CommonMap();
            retMsg = "잘못된 호출입니다.";
            retCount = -1;
        } else {
            param.put("fileRelKey", fileRelKey);
            param.put("queryId", "common.file.Select_FileListByRefKey");
            List<CommonMap> result = new ArrayList<CommonMap>();

            try {
                result = commonService.select(param);

                if(result.size() > 0) {
                    for(int i = 0; i < result.size(); i++) {
                        data.put("encData", enc.encrypt(result.get(i).getString("fileRelKey") + "|" + result.get(i).getString("fileKey")));
                    }
                    retMsg = "정상적으로 처리되었습니다.";
                    retCount = 1;
                }
            } catch(Throwable e) {
                System.out.println("UploadController.getEncryptedFileKeyArray Exception occured ::: " + e.toString());
                data = new CommonMap();
                retMsg = "오류가 발생하였습니다.";
                retCount = 0;
            }
        }
        
        return ResultInfo.of(retMsg, retCount, data);
    }
    
    private String getMimeTypeByteArray(byte[] data) {
        String result = "";
        
        try {
            Tika tika = new Tika();
            result = tika.detect(data);
        } catch(Exception e) {
            e.printStackTrace();
            result = "";
        }
        return result;
    }

    // chunked multi upload (encrypt)
    public ResultInfo uploadChunkEncryptMulti(HttpSession session, HttpServletRequest request) {
        String curIdxStr = request.getParameter("curIdx");
        String totalIdxStr = request.getParameter("totalIdx");
        String fileContStr = request.getParameter("fileCont");
        String fileName = request.getParameter("fileName");
        String uuid = request.getParameter("uuid");
        String uploadFileExt = "";
        String uploadFolder = request.getParameter("uploadFolder");
        String curFileIdxStr = request.getParameter("curFileIdx");
        String totalFileCountStr = request.getParameter("totalFileCount");
        String recvFileRelKey = request.getParameter("fileRelKey");
        String recvFileKey = request.getParameter("fileKey"); // "," 문자로 합쳐진 FILE_KEY
        String mimeType = "";
        String currentFileExt = "";
        
        uploadFileExt = "bmp|pdf|jpg|jpeg|png|gif|hwp|hwpx|xls|xlsx|doc|docx|mp4|webm|ogg";
        
        CommonMap data = new CommonMap();
        int resultCode = 1;
        String resultString = "success";
        CommonMap param = MapUtils.parseSession(session);
        CommonMap dbParam = new CommonMap();
        CommonMap f = new CommonMap();
        List<CommonMap> dbResult;
        EncUtil enc = new EncUtil();
        StringBuilder contents = new StringBuilder();
        String uploadFilePath = "";
        
        data.put("newFileRelKey", "");
        data.put("newFileKey", "");
        
        if(propertyService == null) {
            uploadFilePath = "/uploads/";
        } else {
            uploadFilePath = propertyService.getString("uploadFilePath");
        }
        
        long curIdx = 0;
        long totalIdx = 0;
        long curFileIdx = 0;
        long totalFileCount = 0;
        
        try { curIdx = Long.parseLong(curIdxStr, 10); } catch(NumberFormatException e) { curIdx = 0; }
        try { totalIdx = Long.parseLong(totalIdxStr, 10); } catch(NumberFormatException e) { totalIdx = 0; }
        try { curFileIdx = Long.parseLong(curFileIdxStr, 10); } catch(NumberFormatException e) { curFileIdx = 0; }
        try { totalFileCount = Long.parseLong(totalFileCountStr, 10); } catch(NumberFormatException e) { totalFileCount = 0; }
        
        // 진행 중
        try {// 무조건 업로드 하면 안되는 확장자
            String[] blackListExtensions = new String[] {
                    "jsp", "jspx", "class"
                  , "asa", "asp", "cdx", "cer", "htr", "aspx"
                  , "dll", "exe", "sh"
                  , "js", "html", "htm", "php", "php3", "php4", "php5"
            };
            String file_ext = fileName.substring(fileName.lastIndexOf(".") + 1).toLowerCase();
            currentFileExt = file_ext;
            boolean isFound = false;
            for(int i = 0; i < blackListExtensions.length; i++) {
                if(blackListExtensions[i].toLowerCase().equals(file_ext)) {
                    isFound = true;
                } 
            }
            if(isFound) {
                System.out.println("uploadChunkEncryptMulti_Exception :: File extension is on the blacklist.");
                resultString = "File extension is not allowed(blacklist).";
                resultCode = -1500;
                return ResultInfo.of(resultString, resultCode, data);
            }
            
            // 최초 파일을 받은 다음 확장자 검사를 한다.
            String[] extensions = uploadFileExt.split("\\|"); // 또는 "[|]" 도 가능
            isFound = false;
            for(int i = 0; i < extensions.length; i++) {
                if(extensions[i].toLowerCase().equals(file_ext)) {
                    isFound = true;
                } 
            }
            if(!isFound) {
                System.out.println("uploadChunkEncryptMulti_Exception :: File extension is not allowed.");
                resultString = "File extension is not allowed.";
                resultCode = -1500;
                return ResultInfo.of(resultString, resultCode, data);
            }
            
//            // 최초 파일을 받은 다음 확장자 검사를 한다.
//            String[] extensions = uploadFileExt.split("\\|"); // 또는 "[|]" 도 가능
//            String file_ext = fileName.substring(fileName.lastIndexOf(".") + 1).toLowerCase();
//            boolean isFound = false;
//            for(int i = 0; i < extensions.length; i++) {
//                if(extensions[i].toLowerCase().equals(file_ext)) {
//                    isFound = true;
//                } 
//            }
//            if(!isFound) {
//                resultString = "File extension is not allowed.";
//                resultCode = -1500;
//                return ResultInfo.of(resultString, resultCode, data);
//            }
            
            // DB에 추가
            dbParam.put("queryId", "chunk.chunkFile.insert_newChunkData");
            dbParam.put("uuid", uuid, false);
            dbParam.put("idx", curIdxStr, false);
            dbParam.put("contents", enc.encrypt(fileContStr), false);
            
            int resIns = 0;
            try {
                resIns = commonService.insert(dbParam);
            } catch(Exception e2) {
                e2.printStackTrace();
                resultString = "Failed when insert DB.";
                resultCode = -1000;
            }
            
            if(resIns < 1) {
                resultString = "No chunk data is inserted.";
                resultCode = -1000;
            } else {
                if(curIdx == totalIdx - 1) {
                    // 완료
                    // 1. DB에 있는 모든 데이터를 읽는다.
                    // 2. 각 데이터를 Base64 Decode 처리한다.
                    // 3. 각 데이터를 하나의 변수에 담는다. (Stringbuilder)
                    // 4. 해당 데이터로 파일을 하나 생성하여 저장한다.
                    // 5. 해당 폴더로 가서 확인할 것
                    
                    dbParam.clear();
                    dbParam.put("queryId", "chunk.chunkFile.select_allChunkedData");
                    dbParam.put("uuid", uuid);
                    
                    dbResult = commonService.select(dbParam);
                    
                    if(dbResult.size() > 0) {
                        for(int i = 0; i < dbResult.size(); i++) {
                            String s = dbResult.get(i).getString("contents");
                            contents.append(s);
                        }
                        
                        byte[] chkByte = contents.toString().getBytes();
                        chkByte = Base64.getDecoder().decode(chkByte);
                        
                        // mime type 확인 및 처리
                        mimeType = getMimeTypeByteArray(chkByte);
                        System.out.println("uploadChunkEncrypt :: Mime-type=" + mimeType + " / Ext: " + currentFileExt);
                        
                        if(    !mimeType.toLowerCase().startsWith("application/pdf")                                                                // pdf
                            && !mimeType.toLowerCase().startsWith("image/")                                                                         // image files
                            && !mimeType.toLowerCase().startsWith("application/msword")                                                             // doc
                            && !mimeType.toLowerCase().startsWith("application/vnd.openxmlformats-officedocument.wordprocessingml.document")        // docx
                            && !mimeType.toLowerCase().startsWith("application/x-tika-msoffice")                                                    // hwp (스트림 사용시 : doc, xls, hwp)
                            && !mimeType.toLowerCase().startsWith("application/x-hwp")                                                              // hwp(~97)
                            && !(mimeType.toLowerCase().startsWith("application/zip") && "hwpx".equals(currentFileExt))                             // hwpx
                            && !mimeType.toLowerCase().startsWith("application/vnd.ms-excel")                                                       // xls
                            && !mimeType.toLowerCase().startsWith("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")              // xlsx
                            && !mimeType.toLowerCase().startsWith("application/x-tika-ooxml")                                                       // 스트림 사용시 : docx, xlsx
                            && !mimeType.toLowerCase().startsWith("video/")                                                                         // 동영상 파일
                        ) {
                            System.out.println("uploadChunkEncrypt_Exception :: File extension is not allowed. :: Mime-type=" + mimeType + " / Ext: " + currentFileExt);
                            resultString = "File extension is not allowed.";
                            resultCode = -1500;
                            return ResultInfo.of(resultString, resultCode, data);
                        }

                        try {

                            // write the image to a file
                            // uploadFilePath example : "/uploads/"
                            // uploadFolder example : "apply/temp/"
                            String rootDir = request.getSession().getServletContext().getRealPath("/");
                            
                            if(rootDir.lastIndexOf("\\") == rootDir.length() - 1 || rootDir.lastIndexOf("/") == rootDir.length() - 1) {
                                rootDir = rootDir.substring(0, rootDir.length() - 1);
                            }
                            
                            String fullFilePath = rootDir + uploadFilePath + uploadFolder;
                            
                            // 폴더 없으면 만들도록 처리
                            File target = new File(fullFilePath);
                            if (!target.exists()) { 
                                target.mkdirs();
                                target.setReadable(true, false);
                                target.setWritable(true, false);
                                target.setExecutable(true, false);
                            }
                            
                            // 파일명 생성
                            String file_name = 
                                    param.getString("fnPrefix") + 
                                    (param.has("fnPrefix") ? "_" : "") + 
                                    (new Timestamp(System.nanoTime()).getTime()) + 
                                    "F" + CommonUtil.randomString(8) +
                                    (param.has("fnSuffix") ? "_" : "") + 
                                    param.getString("fnSuffix");
                            String file_orig_name = fileName.substring(0, fileName.lastIndexOf("."));
                            file_ext = fileName.substring(fileName.lastIndexOf(".") + 1);
                            
                            // File key, Relation key 생성
                            
                            // 실제 저장할 파일경로 및 파일명
                            File outputfile = new File(fullFilePath + file_name + "." + file_ext);
                            
                            try (FileOutputStream fos = new FileOutputStream(fullFilePath + file_name + "." + file_ext)) {
                                if(mimeType.toLowerCase().startsWith("video/")) {
                                    fos.write(chkByte);
                                } else {
                                    // 파일 정보를 암호화 한다 (EncUtil, AES256)
                                    byte[] encArray = enc.encByte(contents.toString().getBytes("UTF-8"));
                                    // 암호화 한 파일 내용을 파일에 쓴다(write).
                                    // 만들어진 파일에 대한 용량 검사는 하지 않는다.
                                    // 이유 : 암호화하면 파일 길이가 늘어나기 때문이다.
                                    fos.write(encArray);
                                }
                            } catch(Throwable fe) {
                                fe.printStackTrace();
                                resultString = "Failed to write file: " + fe.toString();
                                resultCode = -2000;
                                return ResultInfo.of(resultString, resultCode, data);
                            }
                            
                            outputfile.setReadable(true, false);
                            outputfile.setWritable(true, false);
                            outputfile.setExecutable(true, false);

                            String fileRelKey = "";
                            if("".equals(recvFileRelKey)) {
                                fileRelKey = commonService.selectOne(new CommonMap("queryId", "common.file.select_newRelKey")).getString("newFileRelKey");
                            } else {
                                fileRelKey = recvFileRelKey;
                            }
                            String fileKey = commonService.selectOne(new CommonMap("queryId", "common.file.select_newKey")).getString("newFileKey");

                            f.put("fileKey", fileKey);
                            f.put("fileRelKey", fileRelKey);
                            f.put("fileSize", Files.size(outputfile.toPath()));
                            f.put("fileName", file_name);
                            f.put("origFileName", file_orig_name);
                            f.put("filePath", (uploadFilePath + uploadFolder)); 
                            f.put("fileExt", file_ext); 
                            f.put("mime_type", mimeType);
                            f.put("memberId", enc.encrypt(param.getString("memberId")), false);
                            f.put("queryId", "common.file.insert_tempFileRelation");
                            commonService.insert(f);
                            
                            f.put("queryId", "common.file.insert_tempFile");
                            commonService.insert(f);
                            
                            if(curFileIdx >= totalFileCount - 1) {
                                resultString = "All files are uploaded completed.";
                                resultCode = 1;

                                recvFileKey += (recvFileKey.length() > 0 ? "," : "") + fileKey;
                                String[] splitted = recvFileKey.split(",");
                                ArrayList<String> fileKeyList = new ArrayList<String>();

                                for(int i = 0; i < splitted.length; i++) {
                                    fileKeyList.add(splitted[i]);
                                }

                                // 모든 FILE_KEY를 모아서 리스트 형태로 리턴..
                                data.put("finalFileKey", fileKeyList);
                            } else {
                                resultString = "A file has been uploaded(partial completion).";
                                resultCode = 3;
                            }
                            data.put("newFileKey", f.getString("fileKey"));
                            data.put("newFileRelKey", f.getString("fileRelKey"));
                            
                        } catch(Exception ie) {
                            ie.printStackTrace();
                            
                            resultString = "Failed because of Exception: " + ie.toString();
                            resultCode = -2000;
                        } finally {
                            // DB에 임시로 저장했던 데이터 삭제
                            param.clear();
                            param.put("queryId", "chunk.chunkFile.delete_chunkData");
                            param.put("uuid", uuid);
                            
                            commonService.delete(param);
                        }
                    }
                } else {
                    resultString = "Chunk data has been uploaded successfully.";
                    resultCode = 2;
                }
            }
            
        } catch(Exception e) {
            e.printStackTrace();
            resultString = "Failed to run. Chunk data has not been uploaded:" + e.toString();
            resultCode = -1000;
        }
        
        return ResultInfo.of(resultString, resultCode, data);
    }

    public boolean isChunkCompleteMulti(HttpServletRequest request) {
        // Chunk 번호 받아오기 (완료 여부 판단용)
        String curIdxStr = request.getParameter("curIdx");
        String totalIdxStr = request.getParameter("totalIdx");
        String curFileIdxStr = request.getParameter("curFileIdx");
        String totalFileCountStr = request.getParameter("totalFileCount");
        
        // chunk 번호 및 파일 번호
        long curIdx = 0, totalIdx = 0, curFileIdx = 0, totalFileCount = 0;
        
        // 숫자로 변환
        try { curIdx = Long.parseLong(curIdxStr, 10); } catch(NumberFormatException e) { curIdx = 0; }
        try { totalIdx = Long.parseLong(totalIdxStr, 10); } catch(NumberFormatException e) { totalIdx = 0; }
        try { curFileIdx = Long.parseLong(curFileIdxStr, 10); } catch(NumberFormatException e) { curFileIdx = 0; }
        try { totalFileCount = Long.parseLong(totalFileCountStr, 10); } catch(NumberFormatException e) { totalFileCount = 0; }

        return (curIdx >= totalIdx - 1 && curFileIdx >= totalFileCount - 1);
    }

    // 특정 FILE_REF_KEY를 가지고 연결된 모든 파일을 갖고 오도록 하는 함수
    // DB Select 1회 수행
    public List<CommonMap> getFileList(String fileRelKey) {
        CommonMap dbParam = new CommonMap();
        List<CommonMap> result = new ArrayList<CommonMap>();

        try {
            dbParam.put("fileRelKey", fileRelKey);
            dbParam.put("queryId", "common.file.Select_FileListByRefKey");
            result = commonService.select(dbParam);
        } catch(Exception e) {
            System.out.println("UploadController.getFileList Exception occured ::: " + e.toString());
        }

        return result;
    }
    
    // 잘라서 보내준 데이터를 DB에 넣는 과정을 처리
    @RequestMapping(value = "/dataChunkProcess.do", method = RequestMethod.POST)
    public ResultInfo dataChunkProcess(HttpServletRequest request, HttpSession session) throws Exception {
        int count = 1;
        String message = "";
        CommonMap data = new CommonMap();
        EncUtil enc = new EncUtil();
        CommonMap param = MapUtils.parseRequest(request);
        
        HashMap<String, Object> tempVal = new HashMap<String, Object>(); // 임시로 데이터를 담는 용도로 사용
        //CommonMap tempVal = new CommonMap();

        try {
            int requestTotalCount = param.getInt("requestTotalCount");
            int requestFnIdx = param.getInt("requestFnIdx");
            int eachDataCount = param.getInt("eachDataCount");
            int requestCount = param.getInt("requestCount");
            String originUrl = param.getString("originUrl");
            
            // Chunked 데이터 DB에 추가
            param.put("queryId", "chunk.chunkData.insert_singleChunkedData");
            param.put("dataUuid", param.getString("chunkUuid"));
            param.put("dataIdx", param.getString("requestCount"));
            // param.put("requestDataType", ""); // 같은 이름의 파라미터로 넘기기 때문에 따로 추가필요 없음..
            // param.put("originUrl", ""); // 같은 이름의 파라미터로 넘기기 때문에 따로 추가필요 없음..
            param.put("contents", param.getString("requestContents"));
            param.put("userIdEnc", enc.encrypt(param.getString("userId")), false); // REG_ID
            commonService.insert(param);
            
            // 조각난 데이터를 로그로 쌓는 경우 이 부분에 추가
            
            if(requestFnIdx >= requestTotalCount - 1
                    && requestCount > 0 
                    && requestCount - 1 >= Math.floor(requestTotalCount / eachDataCount) + (requestTotalCount % eachDataCount > 0 ? 1 : 0)) 
            {
                // 모든 데이터가 완료된 경우
                
                // DB에 저장한 데이터 읽어옴
                param.put("queryId", "chunk.chunkData.select_allChunkedData");
                param.put("dataUuid", param.getString("chunkUuid"));
                
                List<CommonMap> chunkList = commonService.select(param);
                
                if(chunkList.size() > 0) {
                    // 모든 데이터가 정상적으로 처리되어 조회가 정상적으로 처리된 경우

                    // 1. url 로 클래스와 컨트롤러를 찾는다.
                    CommonMap urlResult = this.getAllRequestUrl(originUrl);
                    
                    if(!"".equals(urlResult.getString("className"))) {
                        String className = urlResult.getString("className");
                        String methodName = urlResult.getString("methodName");
                        String paramListStr = urlResult.getString("params");
                        
                        // 먼저 생성자를 처리해야 한다.
                        Class<?> runClass = Class.forName(className); // 실행할 클래스
                        Object constructor = null; // 실행할 클래스의 인스턴스
                        Method runMethod = null; // 실행할 메서드
                        Object methodResult = null; // 리턴값을 받을 변수
                        
                        // 클래스 생성시 @Autowired 처리 이후의 정보를 갖고오도록 함
                        // (CommonService가 @Autowired 로 인해 자동으로 생성자에 포함되기 때문에 이게 처리된 이후의 정보를 획득해야 함)
                        ApplicationContext context = ApplicationContextProvider.getApplicationContext();
                        constructor = context.getBean(runClass);
                        
                        // 메서드 파라미터 처리 및 실행
                        if("".equals(paramListStr)) {
                            // 메서드 파라미터가 없을수는 없음 (최소 request 객체 1개는 존재함)
                            runMethod = runClass.getMethod(methodName);
                            methodResult = runMethod.invoke(constructor);
                        } else if(paramListStr.indexOf(",") < 0 && (paramListStr.indexOf(".HttpServletRequest") > -1 || paramListStr.indexOf(".MultipartHttpServletRequest") > -1)) {
                            // 메서드 파라미터가 한개이면서 HttpServletRequest 또는 MultipartHttpServletRequest 클래스인 경우
                            runMethod = runClass.getMethod(methodName, Class.forName(paramListStr));
                            
                            // Request 객체 생성
                            SetableHttpServletRequest setableRequest = new SetableHttpServletRequest(request);
                            
                            JSONParser jsonParser = new JSONParser();
                            
                            // DB 데이터를 기반으로 파라미터 추가 (배열은 String[] 객체로, 값은 String 으로 추가)
                            for(int i = 0; i < chunkList.size(); i++) {
                                JSONObject mainObj = (JSONObject) jsonParser.parse(chunkList.get(i).getString("contents"));
                                
                                // 개별 키 별로 루프
                                for(Object key : mainObj.keySet()) {
                                    if("requestContents".equals(key.toString())) {
                                        // DB에 넣는 용도로 사용하는 컬럼은 제외하고 원래 URL로 전송한다.
                                        continue;
                                    }
                                    Object value = mainObj.get(key.toString());
                                    
                                    if(value instanceof JSONArray) {
                                        // 현재 키의 값이 배열인 경우
                                        if(!tempVal.containsKey(key.toString())) {
                                            // 현재 키값이 임시 객체에 없으면 만들어 줌
                                            tempVal.put(key.toString(), new String[] {});
                                        }
                                        // 기존 값을 들고 옴
                                        List<String> tmpList = new ArrayList<String>();
                                        if(tempVal.get(key.toString()) != null) {
                                            tmpList = new ArrayList<String>(Arrays.asList((String[]) tempVal.get(key.toString())));
                                        }
                                        // JSON 배열 읽음
                                        JSONArray subValue = (JSONArray) value;
                                        
                                        for(int j = 0; j < subValue.size(); j++) {
                                            // 기존 배열에 값 추가
                                            tmpList.add(subValue.get(j).toString());
                                        }
                                        
                                        // 임시 객체에 변경된 데이터를 세팅
                                        tempVal.put(key.toString(), tmpList.toArray(new String[tmpList.size()]));
                                    } else {
                                        // 현재 키의 값이 배열이 아닌 경우 String 으로 추가
                                        setableRequest.setParameter(key.toString(), new String[] { value.toString() });
                                    }
                                }
                            }
                            
                            // 임시 배열에 넣은 것을 request 에 추가
                            for(Object key : tempVal.keySet()) {
                                setableRequest.setParameter(key.toString(), tempVal.get(key));
                            }
                            
                            // 전체 데이터를 로그로 쌓는 경우 이 부분에 추가하며, DB에서 읽어온 문자열들을 합쳐서 추가할 것
                            
                            // 메서드 실행
                            if(paramListStr.indexOf(".HttpServletRequest") > -1) {
                                methodResult = runMethod.invoke(constructor, (HttpServletRequest)setableRequest);
                            } else if(paramListStr.indexOf(".MultipartHttpServletRequest") > -1) {
                                methodResult = runMethod.invoke(constructor, (MultipartHttpServletRequest)setableRequest);
                            }
                        } else if(paramListStr.indexOf(",") < 0) {
                            // 메서드 파라미터가 그냥 1개인 경우 (없음 : request 는 무조건 1개 존재함)
                            runMethod = runClass.getMethod(methodName, Class.forName(paramListStr));
                            methodResult = runMethod.invoke(constructor, new Object());
                        }
                        
                        // 메서드 실행 후 결과 처리
                        // ResultInfo 인 경우 값을 받아서 처리
                        // 아닌 경우 정상 처리 세팅
                        if(methodResult instanceof ResultInfo) {
                            return (ResultInfo)methodResult;
                        } else {
                            count = -12000;
                            message = "서버 오류가 발생하였습니다.(-12000)";
                        }
                    } else {
                        count = -11000;
                        message = "서버 오류가 발생하였습니다.(-11000)";
                    }

                    param.put("queryId", "chunk.chunkData.delete_allChunkedData");
                    param.put("dataUuid", param.getString("chunkUuid"));
                    commonService.delete(param);
                    
                } else {
                    count = -10000;
                    message = "서버 오류가 발생하였습니다.(-10000)";
                }
            }
        } catch(Exception e) {
            e.printStackTrace();
            count = -20000;
            message = "서버 오류가 발생하였습니다.(-20000)";
        }
        
        return ResultInfo.of(message, count, data);
    }
    
    public CommonMap getAllRequestUrl(String pUrl) {
        // 결과값
        CommonMap result = new CommonMap();
        boolean isFinish = false;
        try {
            String url = pUrl.substring(pUrl.indexOf("/walletfree-admin") + "/walletfree-admin".length());
            
            // 결과값 세팅
            result.put("className", "");    // 클래스명 (package 이름이 붙어있음)
            result.put("classParams", "");  // 클래스의 생성자를 호출할 때 필요한 클래스 목록 ("," 로 구분)
            result.put("methodName", "");   // 메서드명 (package 이름이 붙어있음)
            result.put("returnType", "");   // 리턴 타입 (package 이름이 붙어있음)
            result.put("params", ""); // "," 로 구분한 문자열을 넣을 예정 (package 이름이 붙어있음)
            
            // Context 객체 획득
            ApplicationContext context = ApplicationContextProvider.getApplicationContext();
            // Context 로부터 RestController Annotation 을 사용하는 컨트롤러 목록을 획득
            Collection<Object> controllers = context.getBeansWithAnnotation(RestController.class).values();
            // 결과를 Array 로 변환
            Object[] res = controllers.toArray();
            
            String classUrl = "";
            String methodUrl = "";
            String compareUrl = ""; // 특정 메서드의 URL (컨트롤러 URL + 메서드 URL 합치는 용도)
            String conParam = ""; // 클래스 생성자의 파라미터
            
            for(int i = 0; i < res.length; i++) {
                classUrl = "";
                methodUrl = "";
                compareUrl = "";
                conParam = "";
                boolean isMatch = false; // 입력받은 URL과 매칭되는지 확인
                String[] cn = res[i].getClass().toGenericString().split(" "); // 클래스 이름 (public class kr.yeongju.... 처럼 나오기 때문에 공백으로 잘라서 마지막 배열의 값을 가져온다.
                
                if(res[i].getClass().getAnnotation(RequestMapping.class) != null) {
                    // 클래스에 RequestMapping Annotation 이 존재하면 해당 클래스에 할당된 value 항목중 첫번째 것을 들고 옴
                    classUrl = res[i].getClass().getAnnotation(RequestMapping.class).value()[0];
                } else {
                    // null 이면 클래스 자체에서 사용하는 RequestMapping 이 없다는 의미이며, 이 경우 기본적으로 "/" 을 사용함
                    classUrl = "/";
                }
                
                // 생성자 목록 획득
                Constructor<?>[] classConstructors = res[i].getClass().getDeclaredConstructors();
                
                if(classConstructors.length > 0) {
                    // 생성자별로 루프
                    for(int j = 0; j < classConstructors.length; j++) {
                        // 생성자의 파라미터 획득
                        Parameter[] conParams = classConstructors[j].getParameters();
                        
                        // 생성자의 파라미터 개수가 1이고 파라미터가 CommonService인 경우 해당 생성자를 사용하도록 처리
                        // CommonService 는 DB 조회를 위해 항상 사용되므로 먼저 확인하여 걸러낼 수 있도록 한다.
                        if(conParams.length == 1 && conParams[0].getType().toGenericString().indexOf(".CommonService") > -1) {
                            conParam = kr.yeongju.its.ad.core.restcontroller.CommonController.class.getCanonicalName();
                            System.out.println("Class : " + cn[cn.length - 1] + " / " + conParam);
                            break;
                        }
                        
                        conParam = "";
                        if(conParams.length > 0) {
                            for(int k = 0; k < conParams.length; k++) {
                                String[] cpn = conParams[k].getType().toGenericString().split(" ");
                                if("".equals(conParam)) {
                                    conParam = cpn[cpn.length - 1];
                                } else {
                                    conParam += "," + cpn[cpn.length - 1];
                                }
                                break;
                            }
                            
                            if(!"".equals(conParam)) {
                                // 찾은 생성자가 있으면 리턴
                                break;
                            }
                        } else {
                            // 해당 생성자에 파라미터가 없음
                            conParam = "";
                        }
                    }
                } else {
                    // 생성자가 없음 - ???
                    conParam = "";
                }
                
                // 클래스명 : cn[cn.length - 1]
                
                // 해당 클래스의 메서드 목록을 배열 형태로 가져온다.
                Method[] method = res[i].getClass().getDeclaredMethods();
                
                for(int j = 0; j < method.length; j++) {
                    methodUrl = "";
                    compareUrl = "";
                    // 메서드의 파라미터 획득
                    Parameter[] params = method[j].getParameters();
                    // 메서드의 이름도 public ResultInfo methodName 처럼 나오므로 공백으로 잘라서 마지막 것만 들고 오도록 처리
                    String[] mn = method[j].getName().split(" ");
                    
                    // 메서드명 : mn[mn.length - 1]
                    // 리턴 타입 : method[j].getGenericReturnType();
                    
                    if(method[j].getAnnotation(RequestMapping.class) != null) {
                        // 메서드에 RequestMapping Annotation 이 존재하면 해당 클래스에 할당된 value 항목중 첫번째 것을 들고 옴
                        String[] rmList = method[j].getAnnotation(RequestMapping.class).value();
                        methodUrl = rmList[0];
                    } else {
                        // RequestMapping Annotation 이 존재하지 않으면 다음 루프로 넘어감
                        continue;
                    }
                    
                    // 클래스 단위에서 붙은 URL과 메서드 단위에서 붙은 URL을 합친다.
                    // 단, 클래스 단위에서 붙은 URL이 "/" 일 경우 붙이지 않는다.
                    compareUrl = ("/".equals(classUrl) ? "" : classUrl) + methodUrl;
                    
                    // 입력받은 URL과 발견하여 합친 URL(compareUrl)이 일치하면 파라미터의 클래스 목록을 가져온다.
                    if(url.equals(compareUrl)) {
                        String paramNames = "";
                        // 메서드의 파라미터를 확인한다.
                        for(int k = 0; k < params.length; k++) {
                            String[] pn = params[k].getType().toGenericString().split(" ");
                            // 파라미터 : pn[pn.length - 1]
                            if("".equals(paramNames)) {
                                paramNames = pn[pn.length - 1];
                            } else {
                                paramNames += "," + pn[pn.length - 1];
                            }
                        }
                        
                        // 결과값 세팅
                        result.put("className", cn[cn.length - 1]);
                        result.put("classParams", conParam);
                        result.put("methodName", mn[mn.length - 1]);
                        result.put("returnType", method[j].getGenericReturnType());
                        result.put("params", paramNames);
                        
                        // 일치하는 것을 찾았으므로 루프 중지
                        isFinish = true;
                        break;
                    }
                    
                    if(isFinish) {
                        break;
                    }
                } // for method.length (Method)
            } // for res.length (Class)
        } catch(Exception e) {
            e.printStackTrace();
        }
        
        return result;
    }
}
