package kr.yeongju.its.ad.common.util;

import java.io.UnsupportedEncodingException;
import java.security.GeneralSecurityException;
import java.security.InvalidAlgorithmParameterException;
import java.security.InvalidKeyException;
import java.security.Key;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.UUID;

import javax.crypto.BadPaddingException;
import javax.crypto.Cipher;
import javax.crypto.IllegalBlockSizeException;
import javax.crypto.NoSuchPaddingException;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;
import org.apache.commons.codec.binary.Base64;

public final class KeyGenUtil {
    private String iv;
    private Key keySpec;

    // 16 byte 이상 해야 함
    private final static String key = "Key generation class.";
    
    public final int KEY_TYPE_PARKINGAREA = 10001;
    public final int KEY_TYPE_SERVICE = 10002;

    /**
     * 생성자
     * @throws UnsupportedEncodingException
     */
    public KeyGenUtil() {
        try {
            this.iv = key.substring(0, 16);
            byte[] keyBytes = new byte[16];
            byte[] b = key.getBytes("UTF-8");
            int len = b.length;
            if (len > keyBytes.length) {
                len = keyBytes.length;
            }
            System.arraycopy(b, 0, keyBytes, 0, len);
            SecretKeySpec keySpec = new SecretKeySpec(keyBytes, "AES");
            this.keySpec = keySpec;
        } catch (UnsupportedEncodingException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
            System.out.println("KeyGenUtil :: UnsupportedEncoding (UTF-8)");
        } catch(Exception e) {
            e.printStackTrace();
            System.out.println("KeyGenUtil :: Error when initializing class.");
        }
    }
    
    /**
     * 서비스 키 생성 (회사별)
     * @return
     */
    public String getServiceKey() {
        String rndValue1 = java.util.UUID.randomUUID().toString().replace("-", "");
        String rndValue2 = java.util.UUID.randomUUID().toString().replace("-", "");
        String rndValue = rndValue1.substring(0, 8) + rndValue2.substring(24);
        Date now = new Date();
        String orig = String.format("S%s:%s", now.getTime(), rndValue);
        String result = "";
        
        try {
            result = this.encrypt(orig);
            
            result = result.replace("+", "_");
            result = result.replace("/", "-");
            result = result.replace("=", "");
        } catch(Exception e) {
            e.printStackTrace();
            System.out.println("getServiceKey :: Error on Encryption.");
        }
        
        return result;
    }
    
    public String checkKey(String key) {
        
        String retStr = "";
        
        if(key == null) {
            return "E:INPUT_STRING_NULL";
        }
        
        if("".equals(key.trim())) {
            return "E:INPUT_STRING_EMPTY";
        }
        
        key = key.replace("_", "+");
        key = key.replace("-", "/");
        
        int appendEqualSignCnt = key.length() % 4;
        
        if(appendEqualSignCnt > 0) {
            for(int i = 0; i < appendEqualSignCnt; i++) {
                key += "=";
            }
        }
        
        String decStr = "";
        
        try {
            decStr = this.decrypt(key);
        } catch(Exception e) {
            return "E:DEC_ERROR";
        }
        
        if(decStr.substring(0, 1).equals("S") && decStr.length() == 31) {
            retStr = "S:SERVICE_KEY:" + this.timestampToDate(decStr.substring(1, 14), "yyyyMMddHHmmssSSS");
        } else {
            retStr = "E:INVALID_KEY";
        }
        
        return retStr;
    }
    
    private String timestampToDate(String timestamp, String dateTimeFormat) {
        try {
            long ts = Long.parseLong(timestamp, 10);
            Date dt = new Date(ts);
            SimpleDateFormat sdf = new SimpleDateFormat(dateTimeFormat);
            return sdf.format(dt);
        } catch(NumberFormatException e) {
            System.out.println("Error : Timestamp string(" + timestamp + ") cannot convert to numeric.");
            return "";
        } catch(Exception e) {
            System.out.println("Error : Exception occured.");
            System.out.println(e.toString());
            return "";
        }
    }

    /**
     * 텍스트를 암호화 (AES256)
     * 
     * @param str 암호화할 문자열   
     * @return
     * @throws NoSuchAlgorithmException
     * @throws GeneralSecurityException
     * @throws UnsupportedEncodingException
     */
    private String encrypt(String str) throws NoSuchAlgorithmException, GeneralSecurityException, UnsupportedEncodingException {
        Cipher c = Cipher.getInstance("AES/CBC/PKCS5Padding");
        c.init(Cipher.ENCRYPT_MODE, keySpec, new IvParameterSpec(iv.getBytes()));
        byte[] encrypted = c.doFinal(str.getBytes("UTF-8"));
        String enStr = new String(Base64.encodeBase64(encrypted));
        return enStr;
    }
    
    private String decrypt(String str) throws NoSuchAlgorithmException, NoSuchPaddingException, InvalidAlgorithmParameterException, InvalidKeyException, BadPaddingException, IllegalBlockSizeException, UnsupportedEncodingException {
        Cipher c = Cipher.getInstance("AES/CBC/PKCS5Padding");
        c.init(Cipher.DECRYPT_MODE, keySpec, new IvParameterSpec(iv.getBytes()));
        byte[] decodedBytes = Base64.decodeBase64(str.getBytes());
        byte[] decrypted = c.doFinal(decodedBytes);
        String decStr = new String(decrypted, "UTF-8");
        return decStr;
    }
}
