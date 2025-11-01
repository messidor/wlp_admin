package kr.yeongju.its.ad.common.util;

import java.io.BufferedOutputStream;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.net.MalformedURLException;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.security.InvalidAlgorithmParameterException;
import java.security.InvalidKeyException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.security.spec.AlgorithmParameterSpec;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;

import javax.crypto.BadPaddingException;
import javax.crypto.Cipher;
import javax.crypto.IllegalBlockSizeException;
import javax.crypto.NoSuchPaddingException;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;
import javax.net.ssl.HttpsURLConnection;
import javax.net.ssl.SSLContext;

import org.apache.commons.codec.binary.Base64;
import org.json.simple.JSONObject;

import com.fasterxml.jackson.databind.ObjectMapper;

// 스마트로 페이 결제를 사용하기 위해 필요한 Java 함수 모음
// 암호화/복호화 함수, 빌링결제 함수, 날짜 문자열 생성 함수 등이 있음
public final class SmartroPayUtil {
    
    /**
     * 문자열을 BASE64 인코딩하여 결과를 리턴
     * @param toEncode 인코딩 할 문자열
     * @return 인코딩 된 문자열
     */
    public static final String encBase64(String toEncode) {
        if(toEncode == null || "".equals(toEncode.trim())) {
            System.out.println("encBase64: Input string is null or empty.");
            return "";
        } else {
            return new String(Base64.encodeBase64(toEncode.getBytes(StandardCharsets.UTF_8)));
        }
    }
    
    /**
     * 문자열을 BASE64로 디코딩하여 결과를 리턴
     * @param toDecode 디코딩 할 BASE64 문자열
     * @return 디코딩 된 문자열
     */
    public static final String decBase64(String toDecode) {
        if(toDecode == null || "".equals(toDecode.trim())) {
            System.out.println("decBase64: Input string is null or empty.");
            return "";
        } else if(!Base64.isBase64(toDecode)) {
            System.out.println("decBase64: Input string is not BASE64 string.");
            return "";
        } else {
            return new String(Base64.decodeBase64(toDecode));
        }
    }

	/* SHA256 암호화 */
	public static final String encodeSHA256Base64(String strPW) {
	    String passACL = null;
	    MessageDigest md = null;
	    
	    if(strPW == null) {
	        System.out.println("String is null.");
	        return "";
	    }

	    try {
	        md = MessageDigest.getInstance("SHA-256");
	    } catch (Exception e) {
	        e.printStackTrace();
	    }

	    md.update(strPW.getBytes());
	    byte[] raw = md.digest();
	    byte[] encodedBytes = Base64.encodeBase64(raw);
	    passACL = new String(encodedBytes);

	    return passACL;
	}

	/* 현재일자 - 년,월,일,시,분,초 - EdiDate에 사용 */
	public static final String getyyyyMMddHHmmss() {
	    SimpleDateFormat yyyyMMddHHmmss = new SimpleDateFormat("yyyyMMddHHmmss");
	    return yyyyMMddHHmmss.format(new Date());
	}

	/* 현재일자 - 년,월,일,시,분 - 캐시방지에 사용 */
	public static final String getyyyyMMddHHmm() {
	    SimpleDateFormat yyyyMMddHHmm = new SimpleDateFormat("yyyyMMddHHmm");
	    return yyyyMMddHHmm.format(new Date());
	}
	
	private static byte[] ivBytes = { 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 };
	
	/* 복호화 함수 - ivBytes static 필드를 사용 */
	public static String AESDecode(String str, String key) throws Exception {
	    //byte[] textBytes =  Base64.decodeBase64(str.getBytes());
	    String result = "";
	    System.out.println(" str: [" + str + "]");
	    
	    if(str == null) {
	        System.out.println("Input string is null.");
	        return result;
	    }
	    
	    byte[] textBytes = Base64.decodeBase64(str);
	    AlgorithmParameterSpec ivSpec = new IvParameterSpec(ivBytes);
	    SecretKeySpec newKey = new SecretKeySpec(key.getBytes("UTF-8"), "AES");
	    Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");
	    cipher.init(Cipher.DECRYPT_MODE, newKey, ivSpec);
	    result = new String(cipher.doFinal(textBytes), "UTF-8");
	    return result;
	}

	/* 암호화 함수 - ivBytes static 필드를 사용 */
	public static String AES_Encode(String str, String key) throws java.io.UnsupportedEncodingException, NoSuchAlgorithmException, NoSuchPaddingException, InvalidKeyException, InvalidAlgorithmParameterException, IllegalBlockSizeException, BadPaddingException {
	    
	    if(str == null) {
            System.out.println("String is null.");
            return "";
        }
	    
        byte[] textBytes = str.getBytes("UTF-8");
        AlgorithmParameterSpec ivSpec = new IvParameterSpec(ivBytes);
        SecretKeySpec newKey = new SecretKeySpec(key.getBytes("UTF-8"), "AES");
        Cipher cipher = null;
        cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");
        cipher.init(Cipher.ENCRYPT_MODE, newKey, ivSpec);
        return Base64.encodeBase64String(cipher.doFinal(textBytes));
	}

	/* 복호화 함수 - ivBytes static 필드 대신 파라미터로 받아서 사용 */
	public static String AES_Decode(String str, String key, byte[] ivBytes) throws java.io.UnsupportedEncodingException, NoSuchAlgorithmException, NoSuchPaddingException, InvalidKeyException, InvalidAlgorithmParameterException, IllegalBlockSizeException, BadPaddingException {
	    
	    if(str == null) {
            System.out.println("String is null.");
            return "";
        }
	    
        byte[] textBytes =  Base64.decodeBase64(str.getBytes());
        AlgorithmParameterSpec ivSpec = new IvParameterSpec(ivBytes);
        SecretKeySpec newKey = new SecretKeySpec(key.getBytes("UTF-8"), "AES");
        Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");
        cipher.init(Cipher.DECRYPT_MODE, newKey, ivSpec);
        return new String(cipher.doFinal(textBytes), "UTF-8");
	}

	/* 복호화 함수(파라미터 다름) - ivBytes static 필드를 사용 */
    public static String AES_Decode(String str, String key) throws java.io.UnsupportedEncodingException, NoSuchAlgorithmException, NoSuchPaddingException, InvalidKeyException, InvalidAlgorithmParameterException,    IllegalBlockSizeException, BadPaddingException {
        return AES_Decode(str, key, ivBytes); 
    }
    
    /* 자동 결제 및 일회성 결제 취소를 요청하여 결과를 리턴하는 함수 */
	public static HashMap<String, Object> callApi(JSONObject json, String callUrl) {

	    StringBuilder responseBody = null;
	    HashMap<String, Object> result = new HashMap<>();

	    // http urlCall 승인 요청 및 TrAuthKey 유효성 검증
	    int connectTimeout = 1000;
	    int readTimeout = 10000; // 가맹점에 맞게 TimeOut 조절

	    URL url = null;
	    HttpsURLConnection connection = null;

	    try {
	        SSLContext sslCtx = SSLContext.getInstance("TLSv1.2");
	        sslCtx.init(null, null, new SecureRandom());

	        url = new URL(callUrl);
	        System.out.println(" url " + url.toString());
	        connection = (HttpsURLConnection)url.openConnection();
	        connection.setSSLSocketFactory(sslCtx.getSocketFactory());

	        connection.addRequestProperty("Content-Type", "application/json");
	        connection.addRequestProperty("Accept", "application/json");
	        connection.setDoOutput(true);
	        connection.setDoInput(true);
	        connection.setConnectTimeout(connectTimeout);
	        connection.setReadTimeout(readTimeout);

	        OutputStreamWriter osw = new OutputStreamWriter(new BufferedOutputStream(connection.getOutputStream()) , "utf-8" );
	        char[] bytes = json.toString().toCharArray();
	        osw.write(bytes,0,bytes.length);
	        osw.flush();
	        osw.close();

	        BufferedReader br = new BufferedReader(new InputStreamReader(connection.getInputStream(), "utf-8"));
	        String line = null;
	        responseBody =  new StringBuilder();
	        while ((line = br.readLine()) != null) {
	            System.out.println(" response " +  line);
	            responseBody.append(line);
	        }
	        br.close();

	        // 결제결과
	        result = new ObjectMapper().readValue(responseBody.toString(), HashMap.class);

	    } catch (MalformedURLException e) {
	        // TODO Auto-generated catch block
	        e.printStackTrace();
	    } catch (IOException e) {
	        // TODO Auto-generated catch block
	        e.printStackTrace();
	    } catch (Exception e) {
	        e.printStackTrace();
	    }
	    return result;
	}

	/* 1회용 결제를 요청하여 결과를 리턴하는 함수 */
	public static HashMap<String, Object> callApiSingle(String TrAuthKey, String Tid, String callUrl) {

	    StringBuilder responseBody = null;
	    HashMap<String, Object> result = new HashMap<>();

	    // http urlCall 승인 요청 및 TrAuthKey 유효성 검증
	    int connectTimeout = 1000;
	    int readTimeout = 10000; // 가맹점에 맞게 TimeOut 조절

	    URL url = null;
	    HttpsURLConnection connection = null;

	    try {
	        SSLContext sslCtx = SSLContext.getInstance("TLSv1.2");
	        sslCtx.init(null, null, new SecureRandom());

	        url = new URL(callUrl);
	        System.out.println(" url " + url.toString());
	        connection = (HttpsURLConnection)url.openConnection();
	        connection.setSSLSocketFactory(sslCtx.getSocketFactory());

	        connection.addRequestProperty("Content-Type", "application/json");
	        connection.addRequestProperty("Accept", "application/json");
	        connection.setDoOutput(true);
	        connection.setDoInput(true);
	        connection.setConnectTimeout(connectTimeout);
	        connection.setReadTimeout(readTimeout);

	        OutputStreamWriter osw = new OutputStreamWriter(new BufferedOutputStream(connection.getOutputStream()) , "utf-8" );

	        JSONObject body = new JSONObject();
	        body.put("Tid" ,Tid);
	        body.put("TrAuthKey" ,TrAuthKey);

	        char[] bytes = body.toString().toCharArray();
	        osw.write(bytes,0,bytes.length);
	        osw.flush();
	        osw.close();

	        BufferedReader br = new BufferedReader(new InputStreamReader(connection.getInputStream(), "utf-8"));
	        String line = null;
	        responseBody =  new StringBuilder();
	        while ((line = br.readLine()) != null) {
	            System.out.println(" response " +  line);
	            responseBody.append(line);
	        }
	        br.close();

	        // 결제결과
	        result = new ObjectMapper().readValue(responseBody.toString(), HashMap.class);

	    } catch (MalformedURLException e) {
	        // TODO Auto-generated catch block
	        e.printStackTrace();
	    } catch (IOException e) {
	        // TODO Auto-generated catch block
	        e.printStackTrace();
	    } catch (Exception e) {
	        e.printStackTrace();
	    }
	    return result;
	}
	
	/**
	 * 전체 금액과 비과세 금액을 넣어서 VAT 금액과 과세 금액을 계산해 주는 함수 (VAT계산시 소수점 절삭)
	 * (https://manual.smartropay.co.kr/module.do?level=#tax) 참조
	 * @param totalAmt 총 결제 금액(비과세, 과세, VAT 포함 금액)
	 * @param taxFreeAmt 비과세 금액
	 * @return HashMap<String, Integer> 형태 (totalAmt=총 결제금액, taxFreeAmt=비과세금액, vat=VAT금액, tax=과세금액)
	 */
	public static HashMap<String, Integer> calVat(int totalAmt, int taxFreeAmt) {
	    HashMap<String, Integer> result = new HashMap<String, Integer>();
	    
	    // 결제 금액 = 비과세 + 과세 + VAT
	    // 과세와 VAT계산시 결제 금액에서 비과세를 먼저 빼 준후에 진행해야 함
	    
	    // 과세 계산 (소수점 있음)
	    double tempTaxAmt = (double)(totalAmt - taxFreeAmt) / 1.1;
	    // 전체 금액에서 과세를 뺀 후 소수점을 절삭하여 VAT를 계산
	    int vatAmt = (int)Math.floor((double)totalAmt - tempTaxAmt - (double)taxFreeAmt);
	    // 소수점을 절삭한 VAT 제외 나머지 금액은 과세 금액으로 계산
	    int taxAmt = totalAmt - vatAmt - taxFreeAmt;
	    
	    result.put("totalAmt", totalAmt);
	    result.put("taxFreeAmt", taxFreeAmt);
	    result.put("vat", vatAmt);
	    result.put("tax", taxAmt);
	    
	    return result;
	}
	
	/**
	 * 비과세 없이 계산
	 * @param totalAmt totalAmt 총 결제 금액(비과세, 과세, VAT 포함 금액)
	 * @return HashMap<String, Integer> 형태 (totalAmt=총 결제금액, taxFreeAmt=비과세금액, vat=VAT금액, tax=과세금액)
	 */
	public static HashMap<String, Integer> calVat(int totalAmt) {
	    return SmartroPayUtil.calVat(totalAmt, 0);
	}
}
