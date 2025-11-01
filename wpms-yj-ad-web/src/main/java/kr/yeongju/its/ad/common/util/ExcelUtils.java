package kr.yeongju.its.ad.common.util;

import java.awt.Color;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.OutputStream;
import java.net.URLEncoder;
import java.text.SimpleDateFormat;
import java.util.Date;

import javax.servlet.http.HttpServletResponse;

import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.ss.usermodel.BorderStyle;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.CellType;
import org.apache.poi.ss.usermodel.DataFormatter;
import org.apache.poi.ss.usermodel.DateUtil;
import org.apache.poi.ss.usermodel.FillPatternType;
import org.apache.poi.ss.usermodel.HorizontalAlignment;
import org.apache.poi.ss.usermodel.VerticalAlignment;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.ss.usermodel.WorkbookFactory;
import org.apache.poi.ss.util.CellReference;
import org.apache.poi.xssf.streaming.SXSSFWorkbook;
import org.apache.poi.xssf.usermodel.DefaultIndexedColorMap;
import org.apache.poi.xssf.usermodel.XSSFCellStyle;
import org.apache.poi.xssf.usermodel.XSSFColor;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.web.multipart.MultipartFile;

public final class ExcelUtils {
    /**
     * 
     * 엑셀파일을 읽어서 Workbook 객체에 리턴한다.
     * XLS와 XLSX 확장자를 비교한다.
     * 
     * @param filePath
     * @return
     * 
     */
    public static Workbook getWorkBook(String filePath) {
        
        /*
         * FileInputStream은 파일의 경로에 있는 파일을
         * 읽어서 Byte로 가져온다.
         * 
         * 파일이 존재하지 않는다면은
         * RuntimeException이 발생된다.
         */
        FileInputStream fis = null;
        try {
            fis = new FileInputStream(filePath);
        } catch (FileNotFoundException e) {
            throw new RuntimeException(e.getMessage(), e);
        }
        
        Workbook wb = null;
        
        /*
         * 파일의 확장자를 체크해서 .XLS 라면 HSSFWorkbook에
         * .XLSX라면 XSSFWorkbook에 각각 초기화 한다.
         */
        if(filePath.toUpperCase().endsWith(".XLS")) {
            try {
                wb = new HSSFWorkbook(fis);
            } catch (IOException e) {
                throw new RuntimeException(e.getMessage(), e);
            }
        } else if(filePath.toUpperCase().endsWith(".XLSX")) {
            try {
                wb = new XSSFWorkbook(fis);
            } catch (IOException e) {
                throw new RuntimeException(e.getMessage(), e);
            }
        }
        
        try {
            fis.close();
        } catch(Exception e) {
            e.printStackTrace();
        }
        
        return wb;   
    }
    
    public static Workbook getWorkBook(MultipartFile file) {
        Workbook workbook = null;
        
        try {
            workbook = WorkbookFactory.create(file.getInputStream());
        } catch (Exception e) {
            throw new IllegalArgumentException();
        }
        return workbook;
    }
    
    /**
     * Cell에 해당하는 Column Name을 가젼온다(A,B,C..)
     * 만약 Cell이 Null이라면 int cellIndex의 값으로
     * Column Name을 가져온다.
     * @param cell
     * @param cellIndex
     * @return
     */
    public static String getName(Cell cell, int cellIndex) {
        int cellNum = 0;
        if(cell != null) {
            cellNum = cell.getColumnIndex();
        }
        else {
            cellNum = cellIndex;
        }
        
        return CellReference.convertNumToColString(cellNum);
    }
    
    public static String getValue(Cell cell) {
        String value = "";
        
        if(cell == null) {
            value = "";
        } else {
            if( cell.getCellType() == CellType.FORMULA ) {
                value = cell.getCellFormula();
            } else if( cell.getCellType() == CellType.NUMERIC ) {
    			if(DateUtil.isCellDateFormatted(cell)) {
    				Date date = cell.getDateCellValue();
    				value = new SimpleDateFormat("yyyy-MM-dd").format(date);
    			} else {
    				DataFormatter formatter = new DataFormatter();

    				//value = String.valueOf(cell.getNumericCellValue());
    				value = formatter.formatCellValue(cell);
    			}
            } else if( cell.getCellType() == CellType.STRING ) {
                value = cell.getStringCellValue();
            } else if( cell.getCellType() == CellType.BOOLEAN ) {
                value = cell.getBooleanCellValue() + "";
            } else if( cell.getCellType() == CellType.ERROR ) {
                value = cell.getErrorCellValue() + "";
            } else if( cell.getCellType() == CellType.BLANK ) { 
                value = "";
            } else {
                value = cell.getStringCellValue();
            }
        }
        
        return value;
    }

    public static void download(HttpServletResponse response, SXSSFWorkbook workbook, String fileName) throws Exception {    	    	
		response.setContentType("Application/Msexcel");
		response.setHeader("Content-Disposition", "ATTachment; Filename=" + URLEncoder.encode(fileName, "UTF-8") + ".xls");
		
		OutputStream fileOut = response.getOutputStream();
		workbook.write(fileOut);
		fileOut.close();
		
		response.getOutputStream().flush();
		response.getOutputStream().close();
		
		workbook.close();
		workbook.dispose();
    }
 
    public static CellStyle headerStyle(SXSSFWorkbook workbook) {
    	CellStyle style = workbook.createCellStyle();
    	cellStyle(style, new Color(231, 234, 236));
    	
    	return style;
    }
 
    public static CellStyle bodyStyle(SXSSFWorkbook workbook) {
    	return bodyStyle(workbook, HorizontalAlignment.CENTER);
    }
    
    public static CellStyle bodyStyle(SXSSFWorkbook workbook, HorizontalAlignment align) {
    	CellStyle style = workbook.createCellStyle();
    	cellStyle(style, new Color(255, 255, 255), align);
    	
    	return style;
    }
    
    private static void cellStyle(CellStyle cellStyle, Color color) {
    	cellStyle(cellStyle, color, HorizontalAlignment.CENTER);
	}
    
    private static void cellStyle(CellStyle cellStyle, Color color, HorizontalAlignment align) {
		XSSFCellStyle xssfCellStyle = (XSSFCellStyle) cellStyle;
		xssfCellStyle.setFillForegroundColor(new XSSFColor(color, new DefaultIndexedColorMap()));
		cellStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
		cellStyle.setAlignment(align);
		cellStyle.setVerticalAlignment(VerticalAlignment.CENTER);
		cellStyle.setBorderLeft(BorderStyle.THIN);
		cellStyle.setBorderTop(BorderStyle.THIN);
		cellStyle.setBorderRight(BorderStyle.THIN);
		cellStyle.setBorderBottom(BorderStyle.THIN);
	}
}
