package kr.yeongju.its.ad.proj.service;

import kr.yeongju.its.ad.common.dto.CommonMap;

public interface MarketService {
	public int parkingCouponSave(CommonMap param) throws Exception;
	
	public int couponRefundConfirm(CommonMap param) throws Exception;
	
	public int couponRefundReject(CommonMap param) throws Exception;
	
	public int CouponManageSave(CommonMap param) throws Exception;
	
	public int CouponPasswordUpdate(CommonMap param) throws Exception;
	
	public int CouponAreaSave(CommonMap param) throws Exception;
	
	public int offlineCouponSave(CommonMap param) throws Exception;
	
	public CommonMap offlineCouponDetail(CommonMap param) throws Exception;
	
	public int offlineCouponParkingSave(CommonMap param) throws Exception;
}
