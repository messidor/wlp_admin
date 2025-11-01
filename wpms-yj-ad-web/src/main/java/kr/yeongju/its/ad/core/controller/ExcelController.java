package kr.yeongju.its.ad.core.controller;

import java.io.File;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.Iterator;
import java.util.List;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.apache.commons.io.FilenameUtils;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.HorizontalAlignment;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.ss.util.CellRangeAddress;
import org.apache.poi.xssf.streaming.SXSSFSheet;
import org.apache.poi.xssf.streaming.SXSSFWorkbook;
import org.springframework.context.ApplicationContext;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.MultipartHttpServletRequest;

import kr.yeongju.its.ad.common.config.ApplicationContextProvider;
import kr.yeongju.its.ad.common.dto.CommonMap;
import kr.yeongju.its.ad.common.exception.NotFoundException;
import kr.yeongju.its.ad.common.util.CommonUtil;
import kr.yeongju.its.ad.common.util.EncUtil;
import kr.yeongju.its.ad.common.util.ExcelUtils;
import kr.yeongju.its.ad.common.util.MapUtils;
import kr.yeongju.its.ad.core.service.CommonService;

@RestController
public class ExcelController {

	@Resource(name = "commonService")
	private CommonService commonService;
    
    /**
     * 업로드 한 엑셀 파일을 읽어서 그 내용을 List(CommonMap)에 담아서 리턴 (행은 첫번째 제외, 열은 첫번째부터 읽음)
     * @param request 업로드 request 객체 (파일이 있어야 함)
     * @return
     */
    public List<CommonMap> readExcel(MultipartHttpServletRequest request) {
        return readExcel(request, 3, 1);
    }
    

    
    /**
     * 업로드 한 엑셀 파일을 읽어서 그 내용을 List(CommonMap)에 담아서 리턴
     * @param request 업로드 request 객체 (파일이 있어야 함)
     * @param startRowNum 실제로 읽어올 시작 row (0부터)
     * @param startColNum 실제로 읽어올 시작 col (0부터)
     * @return List(CommonMap) col1, col2, ... 로 받을 수 있는 CommonMap이 담긴 List
     */
    public List<CommonMap> readExcel(MultipartHttpServletRequest request, int startRowNum, int startColNum) {
        List<CommonMap> result = new ArrayList<CommonMap>();
        MultipartFile file = request.getFile("multiFiles");
        int MAX_COLS = 16384;
        
        try {
            if(file != null && !file.isEmpty()) {
                String extension = FilenameUtils.getExtension(file.getOriginalFilename());
                
                if (extension.equalsIgnoreCase("xls") || extension.equalsIgnoreCase("xlsx")) {
                    
                    if(extension.equalsIgnoreCase("xls")) {
                        // xls 파일은 최대 256 columns
                        MAX_COLS = 256;
                    } else if(extension.equalsIgnoreCase("xlsx")) {
                        // xlsx 파일은 최대 16384 columns
                        MAX_COLS = 16384;
                    }
                    
                    Workbook workBook = ExcelUtils.getWorkBook(file);
                    Sheet sheet = workBook.getSheetAt(0);
                    Iterator<Row> rows = sheet.iterator();
                    
                    int nRow = 0;
                    int nCol = 0;
                    int nRptCnt = 0; // 엑셀에서 제한하는 컬럼 개수를 넘기지 않기 위함
                    
                    int readRows = 0;
                    int headerColCount = 0; // 가장 첫번째 row의 개수
                    
                    // 0번째가 아닌 1번째가 Excel 상의 1번 Row 이기 때문에 첫 row는 읽어서 넘어가야 함
                    //rows.next();
                    while (rows.hasNext()) {
                        // 첫번째 데이터 이전 (Header) 을 기준으로 몇 개의 열(Column)이 있는지 체크하도록 함 ( 몇 번째 row를 체크해야 하는지 저장 )
                        int chkColumnRowNumber = startRowNum < 1 ? 0 : startRowNum - 1;
                        
                        // 몇 개의 열(Column)이 있는지 체크
                        if(nRow == chkColumnRowNumber) {
                            Row row = rows.next();
                            nCol = 0;
                            while(nRptCnt < MAX_COLS) {
                                if(startColNum > nCol) {
                                    nCol++;
                                    headerColCount++;
                                    continue;
                                }
                                
                                Cell cell = row.getCell(nCol);
                                if(cell == null) {
                                    break;
                                } else {
                                    headerColCount++;
                                    nCol++;
                                }
                            }
                            
                            // startRowNum 에 지정된 row 번호부터 시작하도록 함
                            if(startRowNum > nRow) {
                                nRow++;
                                continue;
                            }
                        } else {
                            if(startRowNum > nRow) {
                                if(rows.hasNext()) {
                                    // startRowNum 에 지정된 row 번호부터 시작하도록 함
                                    rows.next();
                                    nRow++;
                                    continue;
                                } else {
                                    break;
                                }
                            }
                        }
                        
                        if(rows.hasNext()) {
                            Row row = rows.next();
                            CommonMap map = new CommonMap();
                            nCol = 0;
                            nRptCnt = 0;
                            
                            // 앞에서 알아온 컬럼 개수만큼 반복
                            for(int i = 0; i < headerColCount; i++) {
                                if(startColNum > i) {
                                    // 수집하지 않는 컬럼은 넘어가도록 처리
                                    continue;
                                }
                                
                                Cell cell = row.getCell(i);
                                // 컬럼명 (col1, col2, ...)
                                String fieldName = "col" + String.valueOf(i + 1 - startColNum);
                                
                                // 값을 가져올 수 없다면 NULL값으로 처리
                                if(cell == null) {
                                    map.put(fieldName, null);
                                } else {
                                    String cellValue = ExcelUtils.getValue(cell);
                                    
                                    // 값이 비어 있으면 NULL 로 처리, 아니면 원래 값을 넣어줌
                                    if("".equals(cellValue.trim())) {
                                        map.put(fieldName, null);
                                    } else {
                                        map.put(fieldName, cellValue.trim());
                                    }
                                }
                            }
                            
                            result.add(map);
                            nRow++;
                            readRows++;
                        }
                    }
                    
                    if(readRows == 0) {
                        System.out.println("ExcelController.readExcel :: 읽은 행이 없습니다(No rows to read).");
                    }
                }
            } else {
                System.out.println("ExcelController.readExcel :: 파일이 없습니다(No file info in request).");
            }
        } catch(Exception e) {
            System.out.println("ExcelController.readExcel :: 오류가 발생하였습니다(Exception occured). - " + e.getMessage());
            e.printStackTrace();
        }
        return result;
    }
    
    /**
     * 업로드된 엑셀 파일을 읽어서 그 내용을 List(CommonMap)에 담아서 리턴
     * @param fileKey 파일 키 (연계키가 아님)
     * @param startRowNum 실제로 읽어올 시작 row (0부터)
     * @param startColNum 실제로 읽어올 시작 col (0부터)
     * @return List(CommonMap) col1, col2, ... 로 받을 수 있는 CommonMap이 담긴 List
     */
    public List<CommonMap> readExcelFile(String fileKey, int startRowNum, int startColNum, HttpServletRequest request) {
        List<CommonMap> result = new ArrayList<CommonMap>();
        int MAX_COLS = 16384;
        String fullFileInfo = "";
        String fileName = "";
        String filePath = "";
        EncUtil enc = new EncUtil();
        
        try {
            String useDecrypt = request.getAttribute("useDecrypt") != null ? request.getAttribute("useDecrypt").toString() : "N";
            
            CommonMap param = new CommonMap();
            param.put("queryId", "common.file.select_fileInfoByFileKey");
            param.put("fileKey", fileKey);
            
            ApplicationContext context = ApplicationContextProvider.getApplicationContext();
            
            if(commonService == null) {
                commonService = context.getBean(CommonService.class);
            }
            
            List<CommonMap> fileList = commonService.select(param);
            
            if(fileList.size() > 0) {
                CommonMap fileRow = fileList.get(0);
                
                // 서버의 절대경로 확인
                String rootPath = request.getSession().getServletContext().getRealPath("/");
                
                // 끝에 붙은 "/" 나 "\" 제거
                if(rootPath.lastIndexOf("\\") == rootPath.length() - 1 || rootPath.lastIndexOf("/") == rootPath.length() - 1) {
                    rootPath = rootPath.substring(0, rootPath.length() - 1);
                }
                
                String extension = fileRow.getString("fileExt");
                fileName = fileRow.getString("fileName");
                filePath = fileRow.getString("filePath");
                fullFileInfo = fileRow.getString("filePath") + fileRow.getString("fullFileName");
                
                if("Y".equals(useDecrypt)) {
                    // 파일 경로를 받아 해당 파일을 열어서 디코딩 처리함
                    byte[] xlsContents = Files.readAllBytes(Paths.get(rootPath + fullFileInfo));
                    byte[] decContents = enc.decByte(xlsContents);
                    
                    // Base64 디코딩 처리
                    byte[] decBase64 = java.util.Base64.getDecoder().decode(decContents);
                    
                    
                    // 복호화된 파일의 이름을 다르게 함
                    fileName += "_dec";
                    
                    File decXls = new File(rootPath + filePath + fileName + "." + extension);
                    if(decXls.exists()) {
                        decXls.delete();
                    }
                    
                    decXls.createNewFile();
                    decXls.setExecutable(true, false);
                    decXls.setWritable(true, false);
                    decXls.setReadable(true, false);
                    
                    Files.write(Paths.get(rootPath + filePath + fileName + "." + extension), decBase64);
                }
                
                File xlsFile = new File(rootPath + filePath + fileName + "." + extension);
                xlsFile.setExecutable(true, false);
                xlsFile.setWritable(true, false);
                xlsFile.setReadable(true, false);
                
                if (extension.equalsIgnoreCase("xls") || extension.equalsIgnoreCase("xlsx")) {
                    
                    if(extension.equalsIgnoreCase("xls")) {
                        // xls 파일은 최대 256 columns
                        MAX_COLS = 256;
                    } else if(extension.equalsIgnoreCase("xlsx")) {
                        // xlsx 파일은 최대 16384 columns
                        MAX_COLS = 16384;
                    }
                    
                    Workbook workBook = ExcelUtils.getWorkBook(xlsFile.getCanonicalPath());
                    Sheet sheet = workBook.getSheetAt(0);
                    Iterator<Row> rows = sheet.iterator();
                    
                    int nRow = 0;
                    int nCol = 0;
                    int nRptCnt = 0; // 엑셀에서 제한하는 컬럼 개수를 넘기지 않기 위함
                    
                    int readRows = 0;
                    int headerColCount = 0; // 가장 첫번째 row의 개수
                    
                    // 0번째가 아닌 1번째가 Excel 상의 1번 Row 이기 때문에 첫 row는 읽어서 넘어가야 함
                    //rows.next();
                    while (rows.hasNext()) {
                        // 첫번째 데이터 이전 (Header) 을 기준으로 몇 개의 열(Column)이 있는지 체크하도록 함 ( 몇 번째 row를 체크해야 하는지 저장 )
                        int chkColumnRowNumber = startRowNum < 1 ? 0 : startRowNum - 1;
                        
                        // 몇 개의 열(Column)이 있는지 체크
                        if(nRow == chkColumnRowNumber) {
                            Row row = rows.next();
                            nCol = 0;
                            while(nRptCnt < MAX_COLS) {
                                if(startColNum > nCol) {
                                    nCol++;
                                    headerColCount++;
                                    continue;
                                }
                                
                                Cell cell = row.getCell(nCol);
                                if(cell == null) {
                                    break;
                                } else {
                                    headerColCount++;
                                    nCol++;
                                }
                            }
                            
                            // startRowNum 에 지정된 row 번호부터 시작하도록 함
                            if(startRowNum > nRow) {
                                nRow++;
                                continue;
                            }
                        } else {
                            if(startRowNum > nRow) {
                                if(rows.hasNext()) {
                                    // startRowNum 에 지정된 row 번호부터 시작하도록 함
                                    rows.next();
                                    nRow++;
                                    continue;
                                } else {
                                    break;
                                }
                            }
                        }
                        
                        if(rows.hasNext()) {
                            Row row = rows.next();
                            CommonMap map = new CommonMap();
                            nCol = 0;
                            nRptCnt = 0;
                            
                            // 앞에서 알아온 컬럼 개수만큼 반복
                            for(int i = 0; i < headerColCount; i++) {
                                if(startColNum > i) {
                                    // 수집하지 않는 컬럼은 넘어가도록 처리
                                    continue;
                                }
                                
                                Cell cell = row.getCell(i);
                                // 컬럼명 (col1, col2, ...)
                                String fieldName = "col" + String.valueOf(i + 1 - startColNum);
                                
                                // 값을 가져올 수 없다면 NULL값으로 처리
                                if(cell == null) {
                                    map.put(fieldName, null);
                                } else {
                                    String cellValue = ExcelUtils.getValue(cell);
                                    
                                    // 값이 비어 있으면 NULL 로 처리, 아니면 원래 값을 넣어줌
                                    if("".equals(cellValue.trim())) {
                                        map.put(fieldName, null);
                                    } else {
                                        map.put(fieldName, cellValue.trim());
                                    }
                                }
                            }
                            
                            result.add(map);
                            nRow++;
                            readRows++;
                        }
                    }
                    
                    if(readRows == 0) {
                        System.out.println("ExcelController.readExcel :: 읽은 행이 없습니다(No rows to read).");
                    }
                }
                // 복호화 된 파일은 관리가 안되기 때문에 제거를 함
                // 암호화 된 파일은 관리가 되기 때문에 그대로 둠
                if(xlsFile.exists()) {
                    xlsFile.delete();
                }
            } else {
                System.out.println("ExcelController.readExcel :: 파일이 없습니다(No file info in request).");
            }
        } catch(Exception e) {
            System.out.println("ExcelController.readExcel :: 오류가 발생하였습니다(Exception occured). - " + e.getMessage());
            e.printStackTrace();
        }
        return result;
    }
    

    /**
     * 공통 select excel
     * @throws Exception 
     */
	@RequestMapping(value = "/common_excel.do", method = RequestMethod.POST)
    public void excel(HttpServletResponse response, HttpServletRequest request) {
		
		String excelType = "";

		try {

			excelType = request.getParameter("type");
			excelType = excelType == null ? "" : excelType;

			String fileName = "";
			SXSSFWorkbook workbook = new SXSSFWorkbook();
			SXSSFSheet sheet = workbook.createSheet();
			
			CellStyle headerCellStyle = ExcelUtils.headerStyle(workbook);
			CellStyle bodyCellStyle = ExcelUtils.bodyStyle(workbook);
			CellStyle bodyCellStyleRight = ExcelUtils.bodyStyle(workbook, HorizontalAlignment.RIGHT);
			CellStyle bodyCellStyleLeft = ExcelUtils.bodyStyle(workbook, HorizontalAlignment.LEFT);
			
			sheet.trackAllColumnsForAutoSizing();
			
			int rowIndex = 0;
			int colIndex = 0;
			Row row = null;
			Cell cell = null;

			CommonMap param = MapUtils.parseRequest(request, false, request.getParameter("enc_col"));
			List<CommonMap> list = commonService.select(param);
			
			if ("parkingCarStatus".equals(param.getString("type"))) {
				fileName = param.getString("kEntryDate") + "_주차차량현황";
					
				row = sheet.createRow(rowIndex++);
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("번호");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("주차장명");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("주소");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("차량번호");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("이름");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("입차일시");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("출차일시");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("주차상태");
					
				for (CommonMap map : list) {
					Row bodyRow = sheet.createRow(rowIndex++);
					colIndex = 0;
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("num"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleLeft);
					cell.setCellValue(map.getString("parkingName"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleLeft);
					cell.setCellValue(map.getString("address"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("carNo"));

					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("memberName"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("pEntDt"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("pOutDt"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("parkingStatus"));
				}
				for(int k = 0; k < colIndex; k++) {        		
					sheet.autoSizeColumn(k);
					sheet.setColumnWidth(k, (sheet.getColumnWidth(k))+(short)2048);
				}      	
			} else if ("parkingCarStatusByNumber".equals(param.getString("type"))) {
				fileName = param.getString("startDt") + "~" + param.getString("endDt") + "_차량별주차이력";
					
				row = sheet.createRow(rowIndex++);
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("번호");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("관리기관");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("주차장명");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("차량번호");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("이름");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("입차일시");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("출차일시");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("주차요금");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("결제여부");
					
				for (CommonMap map : list) {
					Row bodyRow = sheet.createRow(rowIndex++);
					colIndex = 0;
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("num"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleLeft);
					cell.setCellValue(map.getString("pGovName"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleLeft);
					cell.setCellValue(map.getString("parkingName"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("carNo"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("memberName"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("pEntDt"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("pOutDt"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleRight);
					cell.setCellValue(map.getString("parkingPrice"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("payGubnName"));
				}
				for(int k = 0; k < colIndex; k++) {        		
					sheet.autoSizeColumn(k);
					sheet.setColumnWidth(k, (sheet.getColumnWidth(k))+(short)2048);
				}      	
			} else if ("parkingCarStatusAll".equals(param.getString("type"))) {
				fileName = param.getString("startDt") + "~" + param.getString("endDt") + "_기간별주차차량현황";
					
				row = sheet.createRow(rowIndex++);
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("번호");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("차량번호");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("이름");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("입차일시");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("출차일시");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("주차상태");
					
				for (CommonMap map : list) {
					Row bodyRow = sheet.createRow(rowIndex++);
					colIndex = 0;
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("num"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("carNo"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("memberName"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("pEntDt"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("pOutDt"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("parkingStatus"));
				}
				for(int k = 0; k < colIndex; k++) {        		
					sheet.autoSizeColumn(k);
					sheet.setColumnWidth(k, (sheet.getColumnWidth(k))+(short)2048);
				}      	
			} else if ("paymentManage".equals(param.getString("type"))) {
				fileName = param.getString("startDate") + "~" + param.getString("endDate") + "_요금결제조회";
					
				row = sheet.createRow(rowIndex++);
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("번호");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("결제일시");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("차량번호");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("이름");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("관리기관");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("주차장명");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("결제구분");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("주차요금 (전체)");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("할인요금");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("사전결제요금");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("주차요금");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("결제상태");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("처리자");
					
				for (CommonMap map : list) {
					Row bodyRow = sheet.createRow(rowIndex++);
					colIndex = 0;
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("num"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("regDt"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("carNo"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("memberName"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleLeft);
					cell.setCellValue(map.getString("pGovName"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleLeft);
					cell.setCellValue(map.getString("parkingName"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("paymentGubnName"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleRight);
					cell.setCellValue(map.getString("totalParkingFee"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleRight);
					cell.setCellValue(map.getString("discountFee"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleRight);
					cell.setCellValue(map.getString("prePayFee"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleRight);
					cell.setCellValue(map.getString("parkingPrice"));

					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("payGubnName"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("confirmName"));
				}
				for(int k = 0; k < colIndex; k++) {        		
					sheet.autoSizeColumn(k);
					sheet.setColumnWidth(k, (sheet.getColumnWidth(k))+(short)2048);
				}      	
			} else if ("unpaidCarManage".equals(param.getString("type"))) {
				fileName = "미납차량조회";
					
				row = sheet.createRow(rowIndex++);
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("번호");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("주차장명");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("차량번호");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("이름");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("연락처");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("입차일시");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("출차일시");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("주차요금");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("납부구분");
					
				for (CommonMap map : list) {
					Row bodyRow = sheet.createRow(rowIndex++);
					colIndex = 0;
					String phone = CommonUtil.phoneNumber(map.getString("memberPhone"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("num"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleLeft);
					cell.setCellValue(map.getString("parkingName"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("carNo"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("memberName"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(phone);
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("pEntDt"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("pOutDt"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleRight);
					cell.setCellValue(map.getString("parkingPrice"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("payStatusName"));
				}
				for(int k = 0; k < colIndex; k++) {        		
					sheet.autoSizeColumn(k);
					sheet.setColumnWidth(k, (sheet.getColumnWidth(k))+(short)2048);
				}      	
			} else if ("cancelPaymentManage".equals(param.getString("type"))) {
				fileName = "결제취소관리";
					
				row = sheet.createRow(rowIndex++);
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("번호");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("요청일시");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("결제일시");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("차량번호");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("이름");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("연락처");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("관리기관");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("통장명");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("통장번호");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("주차장명");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("결제구분");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("주차요금");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("취소상태");
					
				for (CommonMap map : list) {
					Row bodyRow = sheet.createRow(rowIndex++);
					colIndex = 0;
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("num"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("regDt"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("payDt"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("carNo"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("memberName"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("memberPhone").replaceAll("(\\d{3})(\\d{3,4})(\\d{4})", "$1-$2-$3"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleLeft);
					cell.setCellValue(map.getString("pGovName"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleLeft);
					cell.setCellValue(map.getString("pGovAccountName"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleLeft);
					cell.setCellValue(map.getString("pGovAccountNumber"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleLeft);
					cell.setCellValue(map.getString("parkingName"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("paymentGubnName"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleRight);
					cell.setCellValue(map.getString("parkingPrice"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("cancelStatusName"));
				}
				for(int k = 0; k < colIndex; k++) {        		
					sheet.autoSizeColumn(k);
					sheet.setColumnWidth(k, (sheet.getColumnWidth(k))+(short)2048);
				}      	
			} else if ("repaymentManage".equals(param.getString("type"))) {
				fileName = "재결제관리";
					
				row = sheet.createRow(rowIndex++);
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("번호");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("요청일시");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("결제일시");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("차량번호");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("이름");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("연락처");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("관리기관");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("통장명");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("통장번호");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("주차장명");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("결제구분");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("주차요금");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("재결제요청상태");
					
				for (CommonMap map : list) {
					Row bodyRow = sheet.createRow(rowIndex++);
					colIndex = 0;
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("num"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("regDt"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("payDt"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("carNo"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("memberName"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("memberPhone").replaceAll("(\\d{3})(\\d{3,4})(\\d{4})", "$1-$2-$3"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleLeft);
					cell.setCellValue(map.getString("pGovName"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleLeft);
					cell.setCellValue(map.getString("pGovAccountName"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleLeft);
					cell.setCellValue(map.getString("pGovAccountNumber"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleLeft);
					cell.setCellValue(map.getString("parkingName"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("paymentGubnName"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleRight);
					cell.setCellValue(map.getString("parkingPrice"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("repayStatusName"));
				}
				for(int k = 0; k < colIndex; k++) {        		
					sheet.autoSizeColumn(k);
					sheet.setColumnWidth(k, (sheet.getColumnWidth(k))+(short)2048);
				}      	
			} else if ("dayPaymentManage".equals(param.getString("type"))) {
				fileName = "일일정산조회_" + param.getString("parkingGoveName") + "_" + param.getString("startDate").replaceAll("-", "");
					
				row = sheet.createRow(rowIndex++);
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("번호");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("처리일시");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("관리기관");

				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("주차장명");

				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("차량번호");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("이름");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("결제상태");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("금액");
					
				
				CommonMap tempMap = null;
				for (CommonMap map : list) {
					Row bodyRow = sheet.createRow(rowIndex++);
					colIndex = 0;
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("num"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("regDt"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleLeft);
					cell.setCellValue(map.getString("pGovName"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleLeft);
					cell.setCellValue(map.getString("parkingName"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("carNo"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("memberName"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("pcGubnName"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleRight);
					cell.setCellValue(map.getString("payPrice"));

					tempMap = map;
				}
				// 합계 추가
				Row bodyRow = sheet.createRow(rowIndex++);
				colIndex = 0;
				
				cell = bodyRow.createCell(colIndex++);
				cell.setCellStyle(bodyCellStyle);
				cell.setCellValue("합계");
				
				cell = bodyRow.createCell(colIndex++);
				cell.setCellStyle(bodyCellStyle);
				cell.setCellValue("");
				
				cell = bodyRow.createCell(colIndex++);
				cell.setCellStyle(bodyCellStyle);
				cell.setCellValue("");
				
				cell = bodyRow.createCell(colIndex++);
				cell.setCellStyle(bodyCellStyle);
				cell.setCellValue("");
				
				cell = bodyRow.createCell(colIndex++);
				cell.setCellStyle(bodyCellStyle);
				cell.setCellValue("");
				
				cell = bodyRow.createCell(colIndex++);
				cell.setCellStyle(bodyCellStyle);
				cell.setCellValue("");
				
				cell = bodyRow.createCell(colIndex++);
				cell.setCellStyle(bodyCellStyle);
				cell.setCellValue("");
				
				sheet.addMergedRegion(new CellRangeAddress(rowIndex-1, rowIndex-1, 0, colIndex-1));
				
				cell = bodyRow.createCell(colIndex++);
				cell.setCellStyle(bodyCellStyleRight);
				cell.setCellValue(tempMap.getString("totalPrice"));
				
				for(int k = 0; k < colIndex; k++) {        		
					sheet.autoSizeColumn(k);
					sheet.setColumnWidth(k, (sheet.getColumnWidth(k))+(short)2048);
				}      	
			} else if ("webUseStatus".equals(param.getString("type"))) {
				fileName = param.getString("startDate") + "~" + param.getString("endDate") + "_웹접속자(유저)통계";
					
				row = sheet.createRow(rowIndex++);
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("번호");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("일자");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("사용자명");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("접속일시");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("IP주소");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("Browser");
					
				for (CommonMap map : list) {
					Row bodyRow = sheet.createRow(rowIndex++);
					colIndex = 0;
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("num"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("logDate"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("memberName"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("loginDt"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("ipAddr"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleLeft);
					cell.setCellValue(map.getString("browserName"));
				}
				for(int k = 0; k < colIndex; k++) {        		
					sheet.autoSizeColumn(k);
					sheet.setColumnWidth(k, (sheet.getColumnWidth(k))+(short)2048);
				}      	
			}  else if ("webUseStatusAdmin".equals(param.getString("type"))) {
				fileName = param.getString("startDate") + "~" + param.getString("endDate") + "_웹접속자(관리자)통계";
					
				row = sheet.createRow(rowIndex++);
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("일자");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("사용자명");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("접속일시");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("IP주소");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("Browser");
					
				for (CommonMap map : list) {
					Row bodyRow = sheet.createRow(rowIndex++);
					colIndex = 0;
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("logDate"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("userName"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("loginDt"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("ipAddr"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleLeft);
					cell.setCellValue(map.getString("browserName"));
				}
				for(int k = 0; k < colIndex; k++) {        		
					sheet.autoSizeColumn(k);
					sheet.setColumnWidth(k, (sheet.getColumnWidth(k))+(short)2048);
				}      	
			} else if ("parkingUseStatus".equals(param.getString("type"))) {
				String useMonth = "".equals(param.getString("kUseMonth")) ? "" : "_" + param.getString("kUseMonth");
				String parkingName = "".equals(param.getString("kParkingNo")) ? "" : "_" + param.getString("parkingName");
				String memberYnName = "".equals(param.getString("kMemberYn")) ? "" : "_" + param.getString("memberYnName");
				
				fileName = param.getString("parkingGovName") 
							+ parkingName
							+ "_" + param.getString("kUseYear")
							+ useMonth
							+ memberYnName
							+ "_주차장이용통계";
				
				row = sheet.createRow(rowIndex++);
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("번호");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("주차장명");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("관리기관");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("관리회사");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("주소");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("연도");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("월");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("차량번호");
				
                cell = row.createCell(colIndex++);
                cell.setCellStyle(headerCellStyle);
                cell.setCellValue("회원여부");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("이용건수");
					
				for (CommonMap map : list) {
					Row bodyRow = sheet.createRow(rowIndex++);
					colIndex = 0;
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("num"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleLeft);
					cell.setCellValue(map.getString("parkingName"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleLeft);
					cell.setCellValue(map.getString("pGovName"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleLeft);
					cell.setCellValue(map.getString("pCompName"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleLeft);
					cell.setCellValue(map.getString("parkingAddr"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("useYear"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("useMonth"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("carNo"));
                    
                    cell = bodyRow.createCell(colIndex++);
                    cell.setCellStyle(bodyCellStyle);
                    cell.setCellValue(map.getString("memberYnName"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleRight);
					cell.setCellValue(map.getString("useCnt"));
				}
				for(int k = 0; k < colIndex; k++) {
					sheet.autoSizeColumn(k);
					sheet.setColumnWidth(k, (sheet.getColumnWidth(k))+(short)2048);
				}      	
			} else if ("govSalesByMonth".equals(param.getString("type"))) {
				fileName = param.getString("kYearDate") + "_월별_기관_매출/정산_집계";
					
				row = sheet.createRow(rowIndex++);
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("기관명");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("1월");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("2월");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("3월");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("4월");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("5월");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("6월");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("7월");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("8월");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("9월");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("10월");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("11월");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("12월");
					
				for (CommonMap map : list) {
					Row bodyRow = sheet.createRow(rowIndex++);
					colIndex = 0;
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleLeft);
					cell.setCellValue(map.getString("pGovName"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleRight);
					cell.setCellValue(map.getString("m1"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleRight);
					cell.setCellValue(map.getString("m2"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleRight);
					cell.setCellValue(map.getString("m3"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleRight);
					cell.setCellValue(map.getString("m4"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleRight);
					cell.setCellValue(map.getString("m5"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleRight);
					cell.setCellValue(map.getString("m6"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleRight);
					cell.setCellValue(map.getString("m7"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleRight);
					cell.setCellValue(map.getString("m8"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleRight);
					cell.setCellValue(map.getString("m9"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleRight);
					cell.setCellValue(map.getString("m10"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleRight);
					cell.setCellValue(map.getString("m11"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleRight);
					cell.setCellValue(map.getString("m12"));
				}
				for(int k = 0; k < colIndex; k++) {        		
					sheet.autoSizeColumn(k);
					sheet.setColumnWidth(k, (sheet.getColumnWidth(k))+(short)2048);
				}      	
			} else if ("govSalesByDate".equals(param.getString("type"))) {
				int endDay = param.getInt("endDay");
				fileName = param.getString("kUseYear") + param.getString("kUseMonth") + "_일자별_기관_매출/정산_집계";
					
				row = sheet.createRow(rowIndex++);
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("기관명");
				
				for(int i=1; i<=endDay; i++) {
					cell = row.createCell(colIndex++);
					cell.setCellStyle(headerCellStyle);
					cell.setCellValue(i+"일");
				}
				
				for (CommonMap map : list) {
					Row bodyRow = sheet.createRow(rowIndex++);
					colIndex = 0;
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleLeft);
					cell.setCellValue(map.getString("pGovName"));
					
					for(int i=1; i<=endDay; i++) {
						cell = bodyRow.createCell(colIndex++);
						cell.setCellStyle(bodyCellStyleRight);
						cell.setCellValue(map.getString("d"+i));
					}
				}
				for(int k = 0; k < colIndex; k++) {        		
					sheet.autoSizeColumn(k);
					sheet.setColumnWidth(k, (sheet.getColumnWidth(k))+(short)2048);
				}      	
			} else if ("govBankSalesByMonth".equals(param.getString("type"))) {
				fileName = param.getString("kYearDate") + "_월별_기관_주차장_매출/정산_집계";
					
				row = sheet.createRow(rowIndex++);
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("기관명");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("주차장명");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("1월");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("2월");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("3월");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("4월");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("5월");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("6월");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("7월");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("8월");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("9월");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("10월");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("11월");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("12월");
					
				for (CommonMap map : list) {
					Row bodyRow = sheet.createRow(rowIndex++);
					colIndex = 0;
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleLeft);
					cell.setCellValue(map.getString("pGovName"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleLeft);
					cell.setCellValue(map.getString("parkingName"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleRight);
					cell.setCellValue(map.getString("m1"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleRight);
					cell.setCellValue(map.getString("m2"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleRight);
					cell.setCellValue(map.getString("m3"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleRight);
					cell.setCellValue(map.getString("m4"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleRight);
					cell.setCellValue(map.getString("m5"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleRight);
					cell.setCellValue(map.getString("m6"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleRight);
					cell.setCellValue(map.getString("m7"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleRight);
					cell.setCellValue(map.getString("m8"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleRight);
					cell.setCellValue(map.getString("m9"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleRight);
					cell.setCellValue(map.getString("m10"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleRight);
					cell.setCellValue(map.getString("m11"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleRight);
					cell.setCellValue(map.getString("m12"));
				}
				for(int k = 0; k < colIndex; k++) {        		
					sheet.autoSizeColumn(k);
					sheet.setColumnWidth(k, (sheet.getColumnWidth(k))+(short)2048);
				}      	
			} else if ("govBankSalesByDate".equals(param.getString("type"))) {
				int endDay = param.getInt("endDay");
				fileName = param.getString("kUseYear") + param.getString("kUseMonth") + "_일자별_기관_주차장_매출/정산_집계";
					
				row = sheet.createRow(rowIndex++);
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("기관명");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("주차장명");
				
				for(int i=1; i<=endDay; i++) {
					cell = row.createCell(colIndex++);
					cell.setCellStyle(headerCellStyle);
					cell.setCellValue(i+"일");
				}
				
				for (CommonMap map : list) {
					Row bodyRow = sheet.createRow(rowIndex++);
					colIndex = 0;
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleLeft);
					cell.setCellValue(map.getString("pGovName"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleLeft);
					cell.setCellValue(map.getString("parkingName"));
					
					for(int i=1; i<=endDay; i++) {
						cell = bodyRow.createCell(colIndex++);
						cell.setCellStyle(bodyCellStyleRight);
						cell.setCellValue(map.getString("d"+i));
					}
				}
				for(int k = 0; k < colIndex; k++) {        		
					sheet.autoSizeColumn(k);
					sheet.setColumnWidth(k, (sheet.getColumnWidth(k))+(short)2048);
				}      	
			} else if ("parkingStatus".equals(param.getString("type"))) {
				int endDay = param.getInt("endDay");
				String memberYnName = "".equals(param.getString("kMemberYn")) ? "" : "_" + param.getString("memberYnName");
				
				fileName = param.getString("parkingGovName") 
							+ "_" + param.getString("kYearDate")
							+ "_" + param.getString("kMonthDate")
							+ memberYnName
							+ "_주차장별현황";
				
				row = sheet.createRow(rowIndex++);
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("번호");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("주차장명");
				
				for(int i=1; i<=endDay; i++) {
					cell = row.createCell(colIndex++);
					cell.setCellStyle(headerCellStyle);
					cell.setCellValue(i+"일");
				}
				
				for (CommonMap map : list) {
					Row bodyRow = sheet.createRow(rowIndex++);
					colIndex = 0;
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("num"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleLeft);
					cell.setCellValue(map.getString("parkingName"));
					
					for(int i=1; i<=endDay; i++) {
						cell = bodyRow.createCell(colIndex++);
						cell.setCellStyle(bodyCellStyleRight);
						cell.setCellValue(map.getString(i+"일"));
					}
				}
				for(int k = 0; k < colIndex; k++) {        		
					sheet.autoSizeColumn(k);
					sheet.setColumnWidth(k, (sheet.getColumnWidth(k))+(short)2048);
				}      	
			} else if ("parkingTimeStatus".equals(param.getString("type"))) {
				String memberYnName = "".equals(param.getString("kMemberYn")) ? "" : "_" + param.getString("memberYnName");
				
				fileName = param.getString("parkingGovName") 
							+ "_" + param.getString("parkingName")
							+ "_" + param.getString("kYearDate")
							+ "_" + param.getString("kMonthDate")
							+ memberYnName
							+ "_시간대별주차장현황";
				
				row = sheet.createRow(rowIndex++);
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("번호");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("주차장명");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("입/출차");
				
				for(int i=1; i<=24; i++) {
					String time = "";
					if(i < 10) {
						time = "0" + i + "시";
					}else {
						time = i + "시";
					}
					cell = row.createCell(colIndex++);
					cell.setCellStyle(headerCellStyle);
					cell.setCellValue(time);
				}
				
				for (CommonMap map : list) {
					Row bodyRow = sheet.createRow(rowIndex++);
					colIndex = 0;
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("num"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleLeft);
					cell.setCellValue(map.getString("parkingName"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("parkingStatus"));
					
					for(int i=1; i<=24; i++) {
						String time = "";
						if(i < 10) {
							time = "0" + i + "시";
						}else {
							time = i + "시";
						}
						cell = bodyRow.createCell(colIndex++);
						cell.setCellStyle(bodyCellStyleRight);
						cell.setCellValue(map.getString(time) + '%');
					}
				}
				for(int k = 0; k < colIndex; k++) {        		
					sheet.autoSizeColumn(k);
					sheet.setColumnWidth(k, (sheet.getColumnWidth(k))+(short)2048);
				}      	
			} else if ("parkingWeekStatus".equals(param.getString("type"))) {
				String[] weekArray = {"일요일","월요일","화요일","수요일","목요일","금요일","토요일"};
				String memberYnName = "".equals(param.getString("kMemberYn")) ? "" : "_" + param.getString("memberYnName");
				
				fileName = param.getString("parkingGovName") 
							+ "_" + param.getString("parkingName")
							+ "_" + param.getString("kYearDate")
							+ "_" + param.getString("kMonthDate")
							+ memberYnName
							+ "_요일별주차장현황";
				
				row = sheet.createRow(rowIndex++);
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("번호");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("주차장명");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("입/출차");
				
				for(int i=0; i<7; i++) {
					cell = row.createCell(colIndex++);
					cell.setCellStyle(headerCellStyle);
					cell.setCellValue(weekArray[i]);
				}
				
				for (CommonMap map : list) {
					Row bodyRow = sheet.createRow(rowIndex++);
					colIndex = 0;
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("num"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleLeft);
					cell.setCellValue(map.getString("parkingName"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("parkingStatus"));
					
					for(int i=0; i<7; i++) {
						cell = bodyRow.createCell(colIndex++);
						cell.setCellStyle(bodyCellStyleRight);
						cell.setCellValue(map.getString(weekArray[i]) + '%');
					}
				}
				for(int k = 0; k < colIndex; k++) {        		
					sheet.autoSizeColumn(k);
					sheet.setColumnWidth(k, (sheet.getColumnWidth(k))+(short)2048);
				}      	
			} else if("UserStatusExcel".equals(param.getString("type"))) {
				
				System.out.println("UserStatusExcel :: Start.");

				workbook.setSheetName(workbook.getSheetIndex(sheet), "회원목록");
				SXSSFSheet sheet2 = workbook.createSheet("회원별 차량정보");
				SXSSFSheet sheet3 = workbook.createSheet("회원별 카드정보");
				SXSSFSheet sheet4 = workbook.createSheet("회원별 감면정보");
				sheet2.trackAllColumnsForAutoSizing();
				sheet3.trackAllColumnsForAutoSizing();
				sheet4.trackAllColumnsForAutoSizing();
				param.put("queryId", "member.memberPopup.select_user_carreduction_excel");
				List<CommonMap> list2 = commonService.select(param);
				param.put("queryId", "member.memberPopup.select_user_credit_excel");
				List<CommonMap> list3 = commonService.select(param);
				param.put("queryId", "member.memberPopup.select_user_reduction_excel");
				List<CommonMap> list4 = commonService.select(param);
				
				List<CommonMap> tempList = new ArrayList<CommonMap>();;
				CommonMap tempMap = new CommonMap();
				
				int rowIndex2 = 0;
				int colIndex2 = 0;
				int rowIndex3 = 0;
				int colIndex3 = 0;
				int rowIndex4 = 0;
				int colIndex4 = 0;
				
				fileName = param.getString("endDate") + "_회원관리";
				
				System.out.println("UserStatusExcel :: (List 1) Start to create sheet and headers");
				
				row = sheet.createRow(rowIndex++);
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("번호");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("아이디");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("이름");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("전화번호");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("이메일");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("회원구분");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("차량등록여부");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("카드등록여부");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("인적감면등록여부");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("가입일시");
				
				System.out.println("UserStatusExcel :: (List 1) Start for statement(data write)");

				for (CommonMap map : list) {
					Row bodyRow = sheet.createRow(rowIndex++);
					colIndex = 0;
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("num"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleLeft);
					cell.setCellValue(map.getString("memberId"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("memberName"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(CommonUtil.phoneNumber(map.getString("memberPhone")));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleLeft);
					cell.setCellValue(map.getString("memberEmail"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("memberGubn"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("carYn"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("creditYn"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("reductionYn"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("confirmDt"));
				}
				System.out.println("UserStatusExcel :: (List 1) Start for statement(fit column size)");
				for(int k = 0; k < colIndex; k++) {        		
					sheet.autoSizeColumn(k);
					sheet.setColumnWidth(k, (sheet.getColumnWidth(k))+(short)2048);
				}
				
				System.out.println("UserStatusExcel :: (List 2) (Started) data to tempMap");

				//2번째 시트
				for (CommonMap map : list2) {
					tempMap = map;
					tempMap.put("mixValue", map.getString("memberName") + map.getString("memberPhone"));
					tempList.add(tempMap);
				}

				System.out.println("UserStatusExcel :: (List 2) data sorting");

				Collections.sort(tempList, new Comparator<CommonMap>() {
					@Override
					public int compare(CommonMap o1, CommonMap o2) {
						// TODO Auto-generated method stub
						return o1.getString("mixValue").compareTo(o2.getString("mixValue"));
					}
				});

				System.out.println("UserStatusExcel :: (List 2) Start to create sheet and headers");
				
				row = sheet2.createRow(rowIndex2++);
				cell = row.createCell(colIndex2++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("아이디");
				
				cell = row.createCell(colIndex2++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("이름");
				
				cell = row.createCell(colIndex2++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("전화번호");
				
				cell = row.createCell(colIndex2++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("이메일");
				
				cell = row.createCell(colIndex2++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("회원구분");
				
				cell = row.createCell(colIndex2++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("차량별칭");
				
				cell = row.createCell(colIndex2++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("차량번호");
				
				cell = row.createCell(colIndex2++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("감면구분");
				
				cell = row.createCell(colIndex2++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("감면율");
				
				cell = row.createCell(colIndex2++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("감면유효기간");

				System.out.println("UserStatusExcel :: (List 2) Start for statement(data write)");
				
				for (CommonMap map : tempList) {
					Row bodyRow = sheet2.createRow(rowIndex2++);
					colIndex2 = 0;

					cell = bodyRow.createCell(colIndex2++);
					cell.setCellStyle(bodyCellStyleLeft);
					cell.setCellValue(map.getString("memberId"));
					
					cell = bodyRow.createCell(colIndex2++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("memberName"));
					
					cell = bodyRow.createCell(colIndex2++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(CommonUtil.phoneNumber(map.getString("memberPhone")));
					
					cell = bodyRow.createCell(colIndex2++);
					cell.setCellStyle(bodyCellStyleLeft);
					cell.setCellValue(map.getString("memberEmail"));
					
					cell = bodyRow.createCell(colIndex2++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("memberGubn"));
					
					cell = bodyRow.createCell(colIndex2++);
					cell.setCellStyle(bodyCellStyleLeft);
					cell.setCellValue(map.getString("carAlias"));
					
					cell = bodyRow.createCell(colIndex2++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("carNo"));
					
					cell = bodyRow.createCell(colIndex2++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("reductionName"));
					
					cell = bodyRow.createCell(colIndex2++);
					cell.setCellStyle(bodyCellStyle);
					if("".equals(map.getString("reductionRate"))) {
						cell.setCellValue(map.getString("reductionRate"));	
					}else {
						cell.setCellValue(map.getString("reductionRate") + "%");
					}
					
					cell = bodyRow.createCell(colIndex2++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("redExpDate"));
				}

				System.out.println("UserStatusExcel :: (List 2) Start for statement(fit column size)");

				for(int k = 0; k < colIndex2; k++) {        		
					sheet2.autoSizeColumn(k);
					sheet2.setColumnWidth(k, (sheet2.getColumnWidth(k))+(short)2048);
				}

				System.out.println("UserStatusExcel :: (List 3) (Started) data to tempMap");
				
				//3번째 시트
				tempList.clear();
				for (CommonMap map : list3) {
					tempMap = map;
					tempMap.put("mixValue", map.getString("memberName") + map.getString("memberPhone"));
					tempList.add(tempMap);
				}

				System.out.println("UserStatusExcel :: (List 3) data sorting");

				Collections.sort(tempList, new Comparator<CommonMap>() {
					@Override
					public int compare(CommonMap o1, CommonMap o2) {
						// TODO Auto-generated method stub
						return o1.getString("mixValue").compareTo(o2.getString("mixValue"));
					}
				});

				System.out.println("UserStatusExcel :: (List 3) Start to create sheet and headers");
				
				row = sheet3.createRow(rowIndex3++);
				
				cell = row.createCell(colIndex3++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("아이디");
				
				cell = row.createCell(colIndex3++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("이름");
				
				cell = row.createCell(colIndex3++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("전화번호");
				
				cell = row.createCell(colIndex3++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("이메일");
				
				cell = row.createCell(colIndex3++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("회원구분");
				
				cell = row.createCell(colIndex3++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("카드사");
				
				cell = row.createCell(colIndex3++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("카드번호");
				
				cell = row.createCell(colIndex3++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("유효기간");
				
				cell = row.createCell(colIndex3++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("대표카드여부");

				System.out.println("UserStatusExcel :: (List 3) Start for statement(data write)");
				
				for (CommonMap map : tempList) {
					Row bodyRow = sheet3.createRow(rowIndex3++);
					colIndex3 = 0;

					cell = bodyRow.createCell(colIndex3++);
					cell.setCellStyle(bodyCellStyleLeft);
					cell.setCellValue(map.getString("memberId"));
					
					cell = bodyRow.createCell(colIndex3++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("memberName"));
					
					cell = bodyRow.createCell(colIndex3++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(CommonUtil.phoneNumber(map.getString("memberPhone")));
					
					cell = bodyRow.createCell(colIndex3++);
					cell.setCellStyle(bodyCellStyleLeft);
					cell.setCellValue(map.getString("memberEmail"));
					
					cell = bodyRow.createCell(colIndex3++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("memberGubn"));
					
					cell = bodyRow.createCell(colIndex3++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("creditComp"));
					
					cell = bodyRow.createCell(colIndex3++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("creditNo") + "-" + map.getString("creditNo2") + "-" + map.getString("creditNo3") + "-" + map.getString("creditNo4"));
					
					cell = bodyRow.createCell(colIndex3++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(
					        map.getString("creditExpDate").length() >= 4 ?
					                (map.getString("creditExpDate").substring(0, 2) + " / " + map.getString("creditExpDate").substring(2, 4)) :
					                ""
					);
					
					cell = bodyRow.createCell(colIndex3++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("repYn"));
					
					
				}

				System.out.println("UserStatusExcel :: (List 3) Start for statement(fit column size)");

				for(int k = 0; k < colIndex3; k++) {        		
					sheet3.autoSizeColumn(k);
					sheet3.setColumnWidth(k, (sheet3.getColumnWidth(k))+(short)2048);
				}

				System.out.println("UserStatusExcel :: (List 4) (Started) data to tempMap");
				
				//4번째 시트
				tempList.clear();
				for (CommonMap map : list4) {
					tempMap = map;
					tempMap.put("mixValue", map.getString("memberName") + map.getString("memberPhone"));
					tempList.add(tempMap);
				}

				System.out.println("UserStatusExcel :: (List 4) data sorting");

				Collections.sort(tempList, new Comparator<CommonMap>() {
					@Override
					public int compare(CommonMap o1, CommonMap o2) {
						// TODO Auto-generated method stub
						return o1.getString("mixValue").compareTo(o2.getString("mixValue"));
					}
				});

				System.out.println("UserStatusExcel :: (List 4) Start to create sheet and headers");
				
				row = sheet4.createRow(rowIndex4++);
				cell = row.createCell(colIndex4++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("아이디");
				
				cell = row.createCell(colIndex4++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("이름");
				
				cell = row.createCell(colIndex4++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("전화번호");
				
				cell = row.createCell(colIndex4++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("이메일");
				
				cell = row.createCell(colIndex4++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("회원구분");
				
				cell = row.createCell(colIndex4++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("감면구분");
				
				cell = row.createCell(colIndex4++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("감면율");
				
				cell = row.createCell(colIndex4++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("감면유효기간");

				System.out.println("UserStatusExcel :: (List 4) Start for statement(data write)");
				
				for (CommonMap map : tempList) {
					Row bodyRow = sheet4.createRow(rowIndex4++);
					colIndex4 = 0;

					cell = bodyRow.createCell(colIndex4++);
					cell.setCellStyle(bodyCellStyleLeft);
					cell.setCellValue(map.getString("memberId"));
					
					cell = bodyRow.createCell(colIndex4++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("memberName"));
					
					cell = bodyRow.createCell(colIndex4++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(CommonUtil.phoneNumber(map.getString("memberPhone")));
					
					cell = bodyRow.createCell(colIndex4++);
					cell.setCellStyle(bodyCellStyleLeft);
					cell.setCellValue(map.getString("memberEmail"));
					
					cell = bodyRow.createCell(colIndex4++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("memberGubn"));
					
					cell = bodyRow.createCell(colIndex4++);
					cell.setCellStyle(bodyCellStyleLeft);
					cell.setCellValue(map.getString("reductionName"));

					cell = bodyRow.createCell(colIndex4++);
					cell.setCellStyle(bodyCellStyle);
					if("".equals(map.getString("reductionRate"))) {
						cell.setCellValue(map.getString("reductionRate"));	
					}else {
						cell.setCellValue(map.getString("reductionRate") + "%");
					}
					
					cell = bodyRow.createCell(colIndex4++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("redExpDate"));
					
				}

				System.out.println("UserStatusExcel :: (List 4) Start for statement(fit column size)");

				for(int k = 0; k < colIndex4; k++) {        		
					sheet4.autoSizeColumn(k);
					sheet4.setColumnWidth(k, (sheet4.getColumnWidth(k))+(short)2048);
				}

				System.out.println("UserStatusExcel :: All list finished. start to download...");
				
			} else if ("payLog".equals(param.getString("type"))) {
				fileName = param.getString("startDate") + "~" + param.getString("endDate") + "_결제로그조회";
					
				row = sheet.createRow(rowIndex++);
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("번호");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("결제요청일시");

				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("스마트로페이 결과 수신 일시");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("결제완료일시");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("ID");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("이름");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("서비스키");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("주차장명");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("차량번호");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("결제구분");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("최종 청구 금액");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("입차일시");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("출차일시");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("감면 코드");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("감면명");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("감면율");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("총 주차 금액(수신)");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("사전정산금액(감면적용)");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("할인금액(감면제외)");		
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("결제요청금액(감면적용)");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("총 유료 주차 시간");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("총 주차 금액(계산)");

				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("할인금액(계산)");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("결제금액(감면적용)");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("스마트로페이 결제 결과");

				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("오류 발생시 문자열");
				
				for (CommonMap map : list) {
					Row bodyRow = sheet.createRow(rowIndex++);
					colIndex = 0;

					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("num"));

					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("regDt"));

					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("payDt"));

					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("modDt"));

					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleLeft);
					cell.setCellValue(map.getString("memberId"));

					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("memberName"));

					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleLeft);
					cell.setCellValue(map.getString("serviceKey"));

					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleLeft);
					cell.setCellValue(map.getString("parkingName"));

					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("carNo"));

					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("payGubnName"));

					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleRight);
					cell.setCellValue(map.getString("fmChargePrice"));

					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("entDt"));

					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("outDt"));

					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("calcReductionCode"));

					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("calcReductionName"));

					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("calcReductionRate"));

					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleRight);
					cell.setCellValue(map.getString("fmTotalParkingFee"));

					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleRight);
					cell.setCellValue(map.getString("fmPrePayFee"));

					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleRight);
					cell.setCellValue(map.getString("fmDiscountFee"));

					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleRight);
					cell.setCellValue(map.getString("fmParkingFee"));

					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("fmParkingMin"));

					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleRight);
					cell.setCellValue(map.getString("fmTotalParkingPrice"));

					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleRight);
					cell.setCellValue(map.getString("fmDiscountPrice"));

					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleRight);
					cell.setCellValue(map.getString("fmParkingPrice"));

					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("payResultCode"));

					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleLeft);
					cell.setCellValue(map.getString("payErrorDetail"));
					
				}
				for(int k = 0; k < colIndex; k++) {        		
					sheet.autoSizeColumn(k);
					sheet.setColumnWidth(k, (sheet.getColumnWidth(k))+(short)2048);
				}      	
			} else if ("couponPurchase".equals(param.getString("type"))) {
				fileName = param.getString("startDate") + "~" + param.getString("endDate") + "_할인권판매내역조회";
					
				row = sheet.createRow(rowIndex++);
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("번호");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("판매일시");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("주차권관리자");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("휴대폰번호");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("관리기관");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("주차장");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("할인권 구분");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("할인권명");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("판매수량");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("판매금액");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("상태");
				for (CommonMap map : list) {
					Row bodyRow = sheet.createRow(rowIndex++);
					colIndex = 0;
					String phone = CommonUtil.phoneNumber(map.getString("memberPhone"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("num"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("regDt"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("couponMemberName"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(phone);
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleLeft);
					cell.setCellValue(map.getString("pGovName"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleLeft);
					cell.setCellValue(map.getString("parkingName"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("couponGubnName"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleLeft);
					cell.setCellValue(map.getString("couponName"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleRight);
					cell.setCellValue(map.getString("couponQtyFmt"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleRight);
					cell.setCellValue(map.getString("purchasePriceFmt"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("pcGubnName"));
					
				}
				for(int k = 0; k < colIndex; k++) {        		
					sheet.autoSizeColumn(k);
					sheet.setColumnWidth(k, (sheet.getColumnWidth(k))+(short)2048);
				}      	
			} else if ("couponUse".equals(param.getString("type"))) {
				fileName = param.getString("startDate") + "~" + param.getString("endDate") + "_주차권할인내역조회";
					
				row = sheet.createRow(rowIndex++);
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("번호");

				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("사용일시");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("관리기관");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("주차장");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("차량번호");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("회원명");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("할인권명");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("사용수량");
				
				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("할인금액");

				cell = row.createCell(colIndex++);
				cell.setCellStyle(headerCellStyle);
				cell.setCellValue("사용구분");

				for (CommonMap map : list) {
					Row bodyRow = sheet.createRow(rowIndex++);
					colIndex = 0;
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("num"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("useDt"));

					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleLeft);
					cell.setCellValue(map.getString("pGovName"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleLeft);
					cell.setCellValue(map.getString("parkingName"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("carNo"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("memberName"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleLeft);
					cell.setCellValue(map.getString("couponName"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyleRight);
					cell.setCellValue(map.getString("useQty"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("discountPrice"));
					
					cell = bodyRow.createCell(colIndex++);
					cell.setCellStyle(bodyCellStyle);
					cell.setCellValue(map.getString("couponUseYnName"));
					
				}
				for(int k = 0; k < colIndex; k++) {        		
					sheet.autoSizeColumn(k);
					sheet.setColumnWidth(k, (sheet.getColumnWidth(k))+(short)2048);
				}      	
			} else {
				throw new NotFoundException("paramater 'type' is null");
			}
			
			ExcelUtils.download(response, workbook, fileName);
		} catch(Exception e) {
			System.out.println("Excel Download error. Type=" + excelType + " ::: " + e.getMessage());
			e.printStackTrace();
		}
    }
}
