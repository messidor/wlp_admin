package kr.yeongju.its.ad.core.service;

import java.util.List;

import javax.annotation.Resource;

import org.apache.commons.lang3.StringUtils;
import org.apache.ibatis.mapping.MappedStatement;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import kr.yeongju.its.ad.common.dto.CommonMap;
import kr.yeongju.its.ad.common.exception.NotFoundException;
import kr.yeongju.its.ad.core.repository.CommonRepository;

@Service("commonService")
public class CommonServiceImpl implements CommonService {

	@Resource(name = "commonRepository")
	private CommonRepository commonRepository;
	
    private final String NAMESPACE = "kr.yeongju.its.ad.core.mapper.";
    private final String QUERYID_NOT_FOUND = "queryId가 존재하지 않습니다!";
    private final int MAX_QUERY_COUNT = 10;

	public List<CommonMap> select(String queryId, CommonMap param) throws Exception {
		if (StringUtils.isEmpty(queryId)) throw new NotFoundException(QUERYID_NOT_FOUND);
		return commonRepository.selectList(NAMESPACE + queryId, param);
	}

	public List<CommonMap> select(CommonMap param) throws Exception {
		if (StringUtils.isEmpty(param.getString("queryId"))) throw new NotFoundException(QUERYID_NOT_FOUND);				
		return commonRepository.selectList(NAMESPACE + param.getString("queryId"), param);
	}
	
	public CommonMap selectOne(CommonMap param) throws Exception {
		if (StringUtils.isEmpty(param.getString("queryId"))) throw new NotFoundException(QUERYID_NOT_FOUND);
		return commonRepository.selectOne(NAMESPACE + param.getString("queryId"), param);
	}
	
	public int insert(CommonMap param) throws Exception {
		if (StringUtils.isEmpty(param.getString("queryId"))) throw new NotFoundException(QUERYID_NOT_FOUND);
		return insert("", param);
	}
	
	public int update(CommonMap param) throws Exception {
		if (StringUtils.isEmpty(param.getString("queryId"))) throw new NotFoundException(QUERYID_NOT_FOUND);
		return update("", param);
	}
	
	public int delete(CommonMap param) throws Exception {
		if (StringUtils.isEmpty(param.getString("queryId"))) throw new NotFoundException(QUERYID_NOT_FOUND);
		return delete("", param);
	}
	
	public int gridInsert(CommonMap param) throws Exception {
		return insert(param.getString("nameSpace") + "insert_", param);
	}
	
	public int gridUpdate(CommonMap param) throws Exception {
		return update(param.getString("nameSpace") + "update_", param);
	}
	
	public int gridDelete(CommonMap param) throws Exception {
		return delete(param.getString("nameSpace") + "delete_", param);
	}

	
	private int insert(String prefix, CommonMap param) throws Exception {
        int result = 0;

        try {
            for (int i=1; i<=MAX_QUERY_COUNT; i++) {
                String queryId = NAMESPACE + prefix + param.getString("queryId") + (i==1?"":i);
                
                MappedStatement ms = null;
                try {
                    ms = commonRepository.getSqlSession().getConfiguration().getMappedStatement(queryId);
                } catch(Exception e2) {
                    // 쿼리 아이디가 존재하지 않으면 실행하지 않고 break 처리
                    // QUERY_ID2, QUERY_ID3, ... 실행하는 것을 방지하기 위함
                    // 첫번째 쿼리가 없어서 오류나는 경우에는 stackTrace 를 실행하도록 처리
                    if(i == 1) {
                        throw new Exception(QUERYID_NOT_FOUND);
                    }
                    break;
                }
                
                if (ms != null) { //comp_insert, comp_insert2...10
                    int rows = commonRepository.insert(queryId, param);
                    result += i==1?rows:0;
                }
                
                if (param.getBoolean("runOnce")) break;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return result;
    }
    
    private int update(String prefix, CommonMap param) throws Exception {
        int result = 0;

        try {
            for (int i=1; i<=MAX_QUERY_COUNT; i++) {
                String queryId = NAMESPACE + prefix + param.getString("queryId") + (i==1?"":i);
                
                MappedStatement ms = null;
                try {
                    ms = commonRepository.getSqlSession().getConfiguration().getMappedStatement(queryId);
                } catch(Exception e2) {
                    // 쿼리 아이디가 존재하지 않으면 실행하지 않고 break 처리
                    // QUERY_ID2, QUERY_ID3, ... 실행하는 것을 방지하기 위함
                    // 첫번째 쿼리가 없어서 오류나는 경우에는 stackTrace 를 실행하도록 처리
                    if(i == 1) {
                        throw new Exception(QUERYID_NOT_FOUND);
                    }
                    break;
                }
                
                if (ms != null) { //comp_insert, comp_insert2...10
                    int rows = commonRepository.update(queryId, param);
                    result += i==1?rows:0;
                }
                
                if (param.getBoolean("runOnce")) break;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return result;
    }
    
    private int delete(String prefix, CommonMap param) throws Exception {
        int result = 0;

        try {
            for (int i=1; i<=MAX_QUERY_COUNT; i++) {
                String queryId = NAMESPACE + prefix + param.getString("queryId") + (i == 1 ? "" : i);
                
                MappedStatement ms = null;
                try {
                    ms = commonRepository.getSqlSession().getConfiguration().getMappedStatement(queryId);
                } catch(Exception e2) {
                    // 쿼리 아이디가 존재하지 않으면 실행하지 않고 break 처리
                    // QUERY_ID2, QUERY_ID3, ... 실행하는 것을 방지하기 위함
                    // 첫번째 쿼리가 없어서 오류나는 경우에는 stackTrace 를 실행하도록 처리
                    if(i == 1) {
                        throw new Exception(QUERYID_NOT_FOUND);
                    }
                    break;
                }
                
                if (ms != null) { //comp_insert, comp_insert2...10
                    int rows = commonRepository.delete(queryId, param);
                    result += i==1?rows:0;
                }
                
                if (param.getBoolean("runOnce")) break;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return result;
    }
}
