package kr.yeongju.its.ad.common.util;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Base64;
import java.util.regex.Pattern;

import javax.crypto.Cipher;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;

import kr.yeongju.its.ad.common.dto.CommonMap;

public class EncUtil {
    
    // SHA256
    private final String SHA_ALGORITHM = "SHA-256";
    
    // AES256
    private final String AES_ALGORITHM = "AES/CBC/PKCS5Padding";
    private final String AES_IV = "walletfreesystem"; // 암호화 시작에 필요한 문자열 (공개되도 상관없음)
    //private final String AES_STR = "Walletfree system in parking-lot"; // 32 bytes (키 - 비공개)
    private final String AES_STR = "PpQOkygJpMwWb16lKW4ifI3V7b3wWWPN"; // 32 bytes (키 - 비공개)

    public EncUtil() {}
    
    /**
     * 단방향 암호화
     * @param fromStr 암호화 할 문자열
     * @return 암호화 된 문자열
     */
    public String get(String fromStr) {
        
        fromStr = fromStr == null ? "" : fromStr;
        
        if("".equals(fromStr.trim())) {
            return "";
        }
        
        StringBuffer sb = new StringBuffer();
        
        try {
        
            MessageDigest md = MessageDigest.getInstance(this.SHA_ALGORITHM);
            md.update(fromStr.getBytes());
            byte[] msgStr = md.digest();
            
            for(int i = 0; i < msgStr.length; i++) {
                byte tmp = msgStr[i];
                String tmpEncTxt = Integer.toString((tmp & 0xff) + 0x100, 16).substring(1);
                sb.append(tmpEncTxt);
            }
            
        } catch(NoSuchAlgorithmException e) {
            System.err.println("EncUtil.get :: Algorithm(" + this.SHA_ALGORITHM + ") does not exists. (" + e.getMessage() + ")");
            sb.delete(0, sb.length());
        } catch(Exception e) {
            System.err.println("EncUtil.get :: Exception occured. (" + e.getMessage() + ")");
            sb.delete(0, sb.length());
        }
        
        return sb.toString();
    }
    
    /**
     * 양방향 암호화 (오류 발생시 빈 문자열 리턴)
     * @param fromStr 암호화 할 문자열
     * @return 암호화 된 문자열
     */
    public String encrypt(String fromStr) {
        
        fromStr = fromStr == null ? "" : fromStr;
        
        if("".equals(fromStr.trim())) {
            return "";
        }
        
        try {
            Cipher cipher = Cipher.getInstance(this.AES_ALGORITHM);
            SecretKeySpec keySpec = new SecretKeySpec(this.AES_STR.getBytes(), "AES");
            IvParameterSpec ivParamSpec = new IvParameterSpec(this.AES_IV.getBytes());
            cipher.init(Cipher.ENCRYPT_MODE, keySpec, ivParamSpec);
            byte[] encrypted = cipher.doFinal(fromStr.getBytes("UTF-8"));
            return Base64.getEncoder().encodeToString(encrypted);
        } catch(Exception e) {
            System.out.println("EncUtil.encrypt() :: Exception occured. Return will be empty string.\n" + e.getMessage());
            return "";
        }
    }
    
    /**
     * 암호화가 된 문자열을 복호화 (오류 발생시 빈 문자열 리턴)
     * @param fromStr 암호화 된 문자열
     * @return 복호화 된 문자열
     */
    public String decrypt(String fromStr) {
        
        fromStr = fromStr == null ? "" : fromStr;
        
        if("".equals(fromStr.trim())) {
            return "";
        }
        
        try {
            Cipher cipher = Cipher.getInstance(this.AES_ALGORITHM);
            SecretKeySpec keySpec = new SecretKeySpec(this.AES_STR.getBytes(), "AES");
            IvParameterSpec ivParamSpec = new IvParameterSpec(this.AES_IV.getBytes());
            cipher.init(Cipher.DECRYPT_MODE, keySpec, ivParamSpec);
    
            byte[] decodedBytes = Base64.getDecoder().decode(fromStr);
            byte[] decrypted = cipher.doFinal(decodedBytes);
            return new String(decrypted, "UTF-8");
        } catch(Exception e) {
            System.out.println("EncUtil.encrypt() :: Exception occured. Return will be empty string.\n" + e.getMessage());
            return "";
        }
    }
    
    /**
     * 암호화 (오류 발생시 길이가 1인 빈 byte 배열 리턴)
     * @param fromArray 암호화 할 byte 배열
     * @return 암호화 된 byte 배열
     */
    public byte[] encByte(byte[] fromArray) {
        if(fromArray == null) {
            return new byte[1];
        }
        
        try {
            Cipher cipher = Cipher.getInstance(this.AES_ALGORITHM);
            SecretKeySpec keySpec = new SecretKeySpec(this.AES_STR.getBytes(), "AES");
            IvParameterSpec ivParamSpec = new IvParameterSpec(this.AES_IV.getBytes());
            cipher.init(Cipher.ENCRYPT_MODE, keySpec, ivParamSpec);
            
            byte[] encrypted = cipher.doFinal(fromArray);
            return Base64.getEncoder().encode(encrypted);
        } catch(Exception e) {
            System.out.println("EncUtil.encrypt() :: Exception occured. Return will be empty string.\n" + e.getMessage());
            return new byte[1];
        }
    }
    
    /**
     * 암호화가 된 byte 배열을 복호화 (오류 발생시 길이가 1인 빈 byte 배열 리턴)
     * @param fromStr 암호화 된 byte 배열
     * @return 복호화 된 byte 배열
     */
    public byte[] decByte(byte[] fromArray) {
        if(fromArray == null) {
            return new byte[1];
        }
        
        try {
            Cipher cipher = Cipher.getInstance(this.AES_ALGORITHM);
            SecretKeySpec keySpec = new SecretKeySpec(this.AES_STR.getBytes(), "AES");
            IvParameterSpec ivParamSpec = new IvParameterSpec(this.AES_IV.getBytes());
            cipher.init(Cipher.DECRYPT_MODE, keySpec, ivParamSpec);
    
            byte[] decodedBytes = Base64.getDecoder().decode(fromArray);
            byte[] decrypted = cipher.doFinal(decodedBytes);
            return decrypted;
        } catch(Exception e) {
            System.out.println("EncUtil.encrypt() :: Exception occured. Return will be empty string.\n" + e.getMessage());
            return new byte[1];
        }
    }
    
    /**
     * 문자열이 암호화 되어 있는지 확인
     * @param fromStr 확인할 문자열
     * @return true=암호화된 문자열, false=일반 문자열
     */
    public boolean isCrypted(String fromStr) {
        
        fromStr = fromStr == null ? "" : fromStr;
        
        if("".equals(fromStr.trim())) {
            return false;
        }
        
        try {
            Cipher cipher = Cipher.getInstance(this.AES_ALGORITHM);
            SecretKeySpec keySpec = new SecretKeySpec(this.AES_STR.getBytes(), "AES");
            IvParameterSpec ivParamSpec = new IvParameterSpec(this.AES_IV.getBytes());
            cipher.init(Cipher.DECRYPT_MODE, keySpec, ivParamSpec);
    
            byte[] decodedBytes = Base64.getDecoder().decode(fromStr);
            byte[] decrypted = cipher.doFinal(decodedBytes);
            
            final String userReadable = "`~-=_+!@#$%^&*()[]{};':\",./<>?\\| \t\r\n1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
            String decStr = new String(decrypted, "UTF-8");
            String korPattern = "^[ㄱ-힣]*$"; 
            
            for(int i = 0; i < decStr.length(); i++) {
                String singleChar = String.valueOf(decStr.charAt(i));
                
                // 한글인 경우 타이핑 가능하므로 다음 문자를 체크
                if(Pattern.compile(korPattern).matcher(singleChar).find()) {
                    continue;
                }
                
                // 다른 읽을 수 있는 문자에 포함이 안된 경우에는 최종적으로 복호화에 실패했다고 보면 됨
                if(userReadable.indexOf(singleChar) < 0) {
                    return false;
                }
            }
            
            return true;
        } catch(Exception e) {
            return false;
        }
    }
    
    public CommonMap encMap(CommonMap param) {
        
        if(param == null) {
            System.err.println("encMap received NULL value.");
            return new CommonMap();
        }
        
        if(!param.containsKey("enc_col")) {
            return param;
        }
        
        String colList = param.getString("enc_col");
        String[] encList = colList.split(",");
        
        for(int i = 0; i < encList.length; i++) {
            if(param.containsKey(encList[i])) {
                param.put(encList[i], this.encrypt(param.getString(encList[i])), false);
            }
        }
        
        return param;
    }
}
