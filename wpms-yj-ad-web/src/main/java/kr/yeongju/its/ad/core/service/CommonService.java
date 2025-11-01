package kr.yeongju.its.ad.core.service;

import java.util.List;

import kr.yeongju.its.ad.common.dto.CommonMap;

public interface CommonService {

	public List<CommonMap> select(String queryId, CommonMap param) throws Exception;
	
	public List<CommonMap> select(CommonMap param) throws Exception;
	
	public CommonMap selectOne(CommonMap param) throws Exception;
	
	public int insert(CommonMap param) throws Exception;
	
	public int update(CommonMap param) throws Exception;
	
	public int delete(CommonMap param) throws Exception;
	
	public int gridInsert(CommonMap param) throws Exception;
	
	public int gridUpdate(CommonMap param) throws Exception;
	
	public int gridDelete(CommonMap param) throws Exception;
}
