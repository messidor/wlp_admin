package kr.yeongju.its.ad.core.mapper;

import java.util.List;

import egovframework.rte.psl.dataaccess.mapper.Mapper;
import kr.yeongju.its.ad.common.dto.CommonMap;

@Mapper("loginMapper")
public interface LoginMapper {

	/**
	 * 로그인
	 * @param map - 조회할 정보가 담긴 CommonMap
	 * @return 사용자 정보
	 * @exception Exception
	 */
	List<CommonMap> login(CommonMap map) throws Exception;

	int Insert_userLog(CommonMap map) throws Exception;

}
