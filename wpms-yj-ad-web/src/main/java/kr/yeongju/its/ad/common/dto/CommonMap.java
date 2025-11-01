package kr.yeongju.its.ad.common.dto;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;

import org.apache.commons.collections.map.ListOrderedMap;
import org.apache.commons.lang3.StringUtils;

import com.fasterxml.jackson.databind.ObjectMapper;

import egovframework.rte.psl.dataaccess.util.CamelUtil;

public final class CommonMap extends ListOrderedMap {
    private static final long serialVersionUID = -5612938228459808005L;
    private static final String ignoreName = "state_col,enc_col,";

    public CommonMap() {}
    
    public CommonMap(String key, Object value) {
        this.put(key, value);
    }
    
    public CommonMap(String key, Object value, boolean isCheckEncrypt) {
        this.put(key, value, isCheckEncrypt);
    }
    
    public String getString(String name, String def) {
        Object obj = get(name);
        
        if (obj == null) {
            return "";
        } else {
            if(obj instanceof String[]) {
                return ((String[]) obj)[0];
            } else {
                return obj.toString();
            }
        }
    }
    
    public String getString(String name) {
        return getString(name, "");
    }
    
    public boolean has(String name) {
        return get(name) != null;
    }

    public boolean isEmpty(String name) {
        return StringUtils.isEmpty(getString(name, ""));
    }
    
    public CommonMap getMap(String name) {
        Object obj = get(name);

        try {
            if (obj == null) {
                return new CommonMap();
            } else if (obj instanceof LinkedHashMap) {
                return CommonMap.parse((LinkedHashMap<String, Object>) obj);
            } else {
                return (CommonMap) obj;
            }
        } catch (Exception e) {
            return new CommonMap();
        }
    }
    
    public CommonMap getMap(int idx) {
        Object obj = getValue(idx);

        try {
            if (obj == null) {
                return new CommonMap();
            } else if (obj instanceof LinkedHashMap) {
                return CommonMap.parse((LinkedHashMap<String, Object>) obj);
            } else {
                return (CommonMap) obj;
            }
        } catch (Exception e) {
            return new CommonMap();
        }
    }
    
    public List<CommonMap> getList(int idx) {
        Object obj = getValue(idx);

        try {
            if (obj == null) {
                return new ArrayList<CommonMap>();
            } else {
                return (List<CommonMap>) obj;
            }
        } catch (Exception e) {
            return new ArrayList<CommonMap>();
        }
    }
    
    public List<CommonMap> getList(String name) {
        Object obj = get(name);

        try {
            if (obj == null) {
                return new ArrayList<CommonMap>();
            } else {
                if (((List) obj).size() > 0 && ((List) obj).get(0) instanceof LinkedHashMap) {
                    List<CommonMap> result = new ArrayList<CommonMap>();
                    List<LinkedHashMap<String, Object>> temp = (List<LinkedHashMap<String, Object>>) obj;
                    
                    for(int i=0; i<temp.size(); i++) {
                        result.add(CommonMap.parse(temp.get(i)));
                    }
                    
                    return result;
                } else {
                    return (List<CommonMap>) obj;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            return new ArrayList<CommonMap>();
        }
    }
    
    public boolean getBoolean(String name) {
        Object obj = get(name);

        try {
            if (obj instanceof Boolean) {
                return (boolean) obj;
            } else if (obj instanceof String) {
                return Boolean.parseBoolean(obj.toString());
            } else {
                return false;
            }
        } catch (Exception e) {
            return false;
        }
    }
    
    public int getInt(String name, int def) {
        Object obj = get(name);
        
        try {
            if (obj instanceof Integer) {
                return (int) obj;
            } else if (obj instanceof String || obj instanceof Long) {
                return Integer.parseInt(obj.toString());
            } else if (obj instanceof BigDecimal) {
                return ((BigDecimal) obj).intValue();
            } else {
                return def;
            }
        } catch (Exception e) {
            return def;
        }
    }
    
    public int getInt(String name) {
        return getInt(name, 0);
    }
    
    public double getDouble(String name, double def) {
        Object obj = get(name);
        
        try {
            if (obj instanceof Integer) {
                return (double) obj;
            } else if (obj instanceof String) {
                return Double.parseDouble(obj.toString());
            } else if (obj instanceof BigDecimal) {
                return ((BigDecimal) obj).doubleValue();
            } else {
                return def;
            }
        } catch (Exception e) {
            return def;
        }
    }
    
    public double getDouble(String name) {
        return getDouble(name, 0);
    }
    
    /**
     * CommonMap의 Key에 값을 할당한다. 복호화할 문자열을 확인하여 복호화를 진행한다.
     * @param key 키 이름
     * @param value 할당할 값
     * @return
     */
    @Override
    public Object put(Object key, Object value) {
//      if (key instanceof String) {
//          String k = ((String) key).toLowerCase();
//          
//          Object finalValue = value;
//          
//          // value가 문자열인 경우
//          // 복호화 시도
//          // 시도 실패시 빈 값을 리턴하므로, 빈값일 경우 일반 문자열이다. 그러면 일반 문자열을 넣는다.
//          // 시도가 성공하면 성공한 값을 할당하여 리턴하도록 한다.
//          if(value instanceof String) {
//              kr.yeongju.its.ad.common.util.EncUtil enc = new kr.yeongju.its.ad.common.util.EncUtil();
//              finalValue = enc.isCrypted((String)value) ? enc.decrypt((String)value) : value;
//          }
//          
//          if (ignoreName.indexOf(k + ",") > -1) {
//              return super.put(k, finalValue);
//          } else {
//              return super.put(CamelUtil.convert2CamelCase((String) key), finalValue);    
//          }
//      } else {
//          return super.put(key, value);
//      }
        
        return this.put(key, value, true);
    }
    
    /**
     * CommonMap의 Key에 값을 할당한다.
     * @param key 키 이름
     * @param value 할당할 값
     * @param isCheckEncrypt 암호화 체크 여부(true=체크 후 복호화, false=그냥 넣음)
     * @return
     */
    public Object put(Object key, Object value, boolean isCheckEncrypt) {
        if (key instanceof String) {
            String k = ((String) key).toLowerCase();
            
            Object finalValue = value;
            
            if(isCheckEncrypt) {
                // value가 문자열인 경우
                // 복호화 시도
                // 시도 실패시 빈 값을 리턴하므로, 빈값일 경우 일반 문자열이다. 그러면 일반 문자열을 넣는다.
                // 시도가 성공하면 성공한 값을 할당하여 리턴하도록 한다.
                if(value instanceof String) {
                    kr.yeongju.its.ad.common.util.EncUtil enc = new kr.yeongju.its.ad.common.util.EncUtil();
                    finalValue = enc.isCrypted((String)value) ? enc.decrypt((String)value) : value;
                }
            }
            
            if (ignoreName.indexOf(k + ",") > -1) {
                return super.put(k, finalValue);
            } else {
                return super.put(CamelUtil.convert2CamelCase((String) key), finalValue);
            }
        } else {
            return super.put(key, value);
        }
    }

    public static CommonMap parse(LinkedHashMap<String, Object> map) {
        CommonMap result = new CommonMap();
        
        try {
            Iterator<String> keyData = map.keySet().iterator();
            while (keyData.hasNext()) {
                String key = keyData.next();
                result.put(key, map.get(key));
            }
        } catch (Exception e) {
            return new CommonMap();
        }
        
        return result;
    }
    
    public static CommonMap parseJSON(String json) {
        CommonMap result = new CommonMap();
        
        try {
            ObjectMapper mapper = new ObjectMapper();
            result = mapper.readValue(json, CommonMap.class);
        } catch (Exception e) {
            return new CommonMap();
        }
        
        return result;
    }
    
    public CommonMap clone() {
        return this.clone(false);
    }
    
    public CommonMap clone(boolean isCheckDecrypt) {
        CommonMap result = new CommonMap();
        
        for(Object key : this.keyList()) {
            result.put(key, this.getString((String)key), isCheckDecrypt);
        }
        
        return result;
    }
}
 