<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="form" uri="http://ad.its.yeongju.kr/jsp/jstl/form"%>
<%@ taglib prefix="card" uri="http://ad.its.yeongju.kr/jsp/jstl/card"%>
<%@ taglib prefix="func" uri="http://ad.its.yeongju.kr/jsp/jstl/func"%>
<%@ taglib prefix="label" uri="http://ad.its.yeongju.kr/jsp/jstl/label"%>

<%@ include file="../../core/include/head.jsp"%>
<%@ include file="../../core/include/headerPopup.jsp"%>

<script type="text/javascript">

	var userUrl = "${userUrl}";

	function loadTableData() {

		var frm = $("#frmMain");
		frm.addParam("func", "IQ");
		frm.addParam("query_id", "pay.paymentManage.Select_RePayPopupList");
		frm.addParam("enc_col", "kMemberId");
	    frm.addParam("dataType", "json");           // 그리드 불러오는 타입 (기본 json)
		frm.request();
	}

	function handleIQ(data, textStatus, jqXHR) {
		if(data.length > 0) {
			$("#frmMain").formSet(data);
			$("#rePayPrice").inputMasking("number");
			$("#rePayPrice").blur();
		}
	}

	function saveData() {
		var newPay = $("#rePayPrice").val().replaceAll(",", "");
		
		var frm = $("#frmMain");
		frm.serializeArrayCustom();
		frm.addParam("func", "IS");
		frm.addParam("enc_col", "userId, kMemberId");
		frm.addParam("newPay", newPay);
		frm.addParam("repayType", "M");
		frm.setAction("<c:url value='/payment/updateSuccessRepay.do' />");
		frm.addParam("dataType", "json");
		frm.request();
	}

	function handleIS(data, textStatus, jqXHR) {
		if(data.count > 0){
			self.close();
			opener.loadTableData();
		}
	}

	$(function(){
		
		$("#btnApproval").click(function() {
			if($("#rePayPrice").val() == '') {
				alert("새로운 요금을 입력해주세요.");
				$("#rePayPrice").focus();
				return false;
			}else if($("#rePayPrice").val() == '0'){
				alert("0원 이상의 요금을 입력해주세요.");
				$("#rePayPrice").focus();
				return false;
			}
			
			if(confirm("재결제하시겠습니까?")){
				saveData();
			}
		});

		$("#btnClose").click(function() {
			self.close();
		});

		loadTableData();
	});
	
</script>

<div class="page-body" style="font-size: 0.9em;">
	<div class="row">
		<div class="col-12" id="search_all_wrapper">
			<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12">
				<card:open title="재결제" />
				<card:button>
				</card:button>
				<card:content />
				<form id="frmMain" name="frmMain" method="post" onsubmit="return false" class="form-horizontal">
					<form:input id="kChargeNo" type="hidden" value="${param.chargeNo}" />
					<form:input id="kMemberId" type="hidden" value="${param.memberId}" />
					<form:input id="payCode" type="hidden" />
					<form:input id="hPrice" type="hidden" />
					<form:input id="paySeq" type="hidden" />
					<form:input id="tId" type="hidden" />
					
					<div class="form-group col-xl-12 col-lg-12 col-md-12 col-sm-12 no-margin no-padding ">
		                <label class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right" style="width: 150px !important;">결제일시</label>
		                <div class="col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached" style="max-width: calc(100% - 150px);">
		                    <div class="input-group">
		                        <span class="input-group-addon"><i class="fas fa fa-eye" data-icon="fas fa fa-eye"></i></span>
		                        <input name="payDt" id="payDt" class="form-control text-left fill" type="text" value="" readonly="readonly">
		                    </div>
		                </div>
		            </div>
		            <div class="form-group col-xl-12 col-lg-12 col-md-12 col-sm-12 no-margin no-padding ">
		                <label class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right" style="width: 150px !important;">입차일시</label>
		                <div class="col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached" style="max-width: calc(100% - 150px);">
		                    <div class="input-group">
		                        <span class="input-group-addon"><i class="fas fa fa-eye" data-icon="fas fa fa-eye"></i></span>
		                        <input name="pEntDt" id="pEntDt" class="form-control text-left fill" type="text" value="" readonly="readonly">
		                    </div>
		                </div>
		            </div>
					<div class="form-group col-xl-12 col-lg-12 col-md-12 col-sm-12 no-margin no-padding ">
		                <label class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right" style="width: 150px !important;">출차일시</label>
		                <div class="col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached" style="max-width: calc(100% - 150px);">
		                    <div class="input-group">
		                        <span class="input-group-addon"><i class="fas fa fa-eye" data-icon="fas fa fa-eye"></i></span>
		                        <input name="pOutDt" id="pOutDt" class="form-control text-left fill" type="text" value="" readonly="readonly">
		                    </div>
		                </div>
		            </div>
					<div class="form-group col-xl-12 col-lg-12 col-md-12 col-sm-12 no-margin no-padding ">
		                <label class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right" style="width: 150px !important;">차량번호</label>
		                <div class="col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached" style="max-width: calc(100% - 150px);">
		                    <div class="input-group">
		                        <span class="input-group-addon"><i class="fas fa fa-eye" data-icon="fas fa fa-eye"></i></span>
		                        <input name="carNo" id="carNo" class="form-control text-left fill" type="text" value="" readonly="readonly">
		                    </div>
		                </div>
		            </div>
					<div class="form-group col-xl-12 col-lg-12 col-md-12 col-sm-12 no-margin no-padding ">
		                <label class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right" style="width: 150px !important;">이름</label>
		                <div class="col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached" style="max-width: calc(100% - 150px);">
		                    <div class="input-group">
		                        <span class="input-group-addon"><i class="fas fa fa-eye" data-icon="fas fa fa-eye"></i></span>
		                        <input name="memberName" id="memberName" class="form-control text-left fill" type="text" value="" readonly="readonly">
		                    </div>
		                </div>
		            </div>
					<div class="form-group col-xl-12 col-lg-12 col-md-12 col-sm-12 no-margin no-padding ">
		                <label class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right" style="width: 150px !important;">주차장명</label>
		                <div class="col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached" style="max-width: calc(100% - 150px);">
		                    <div class="input-group">
		                        <span class="input-group-addon"><i class="fas fa fa-eye" data-icon="fas fa fa-eye"></i></span>
		                        <input name="parkingName" id="parkingName" class="form-control text-left fill" type="text" value="" readonly="readonly">
		                    </div>
		                </div>
		            </div>
		            <div class="form-group col-xl-12 col-lg-12 col-md-12 col-sm-12 no-margin no-padding ">
		                <label class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right" style="width: 150px !important;">주차요금 (전체)</label>
		                <div class="col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached" style="max-width: calc(100% - 150px);">
		                    <div class="input-group">
		                        <span class="input-group-addon"><i class="fas fa fa-eye" data-icon="fas fa fa-eye"></i></span>
		                        <input name="totalParkingFee" id="totalParkingFee" class="form-control text-right fill" type="text" value="" readonly="readonly">
		                    </div>
		                </div>
		            </div>
		            <div class="form-group col-xl-12 col-lg-12 col-md-12 col-sm-12 no-margin no-padding ">
		                <label class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right" style="width: 150px !important;">할인요금</label>
		                <div class="col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached" style="max-width: calc(100% - 150px);">
		                    <div class="input-group">
		                        <span class="input-group-addon"><i class="fas fa fa-eye" data-icon="fas fa fa-eye"></i></span>
		                        <input name="discountFee" id="discountFee" class="form-control text-right fill" type="text" value="" readonly="readonly">
		                    </div>
		                </div>
		            </div>
		             <div class="form-group col-xl-12 col-lg-12 col-md-12 col-sm-12 no-margin no-padding ">
		                <label class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right" style="width: 150px !important;">사전결제요금</label>
		                <div class="col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached" style="max-width: calc(100% - 150px);">
		                    <div class="input-group">
		                        <span class="input-group-addon"><i class="fas fa fa-eye" data-icon="fas fa fa-eye"></i></span>
		                        <input name="prePayFee" id="prePayFee" class="form-control text-right fill" type="text" value="" readonly="readonly">
		                    </div>
		                </div>
		            </div>
					<div class="form-group col-xl-12 col-lg-12 col-md-12 col-sm-12 no-margin no-padding ">
		                <label class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right" style="width: 150px !important;">주차요금</label>
		                <div class="col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached" style="max-width: calc(100% - 150px);">
		                    <div class="input-group">
		                        <span class="input-group-addon"><i class="fas fa fa-eye" data-icon="fas fa fa-eye"></i></span>
		                        <input name="payPrice" id="payPrice" class="form-control text-right fill" type="text" value="" readonly="readonly">
		                    </div>
		                </div>
		            </div>
		            <div class="form-group col-xl-12 col-lg-12 col-md-12 col-sm-12 no-margin no-padding ">
		                <label class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right" style="width: 150px !important;">새로운 요금</label>
		                <div class="col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached" style="max-width: calc(100% - 150px);">
		                    <div class="input-group">
		                        <span class="input-group-addon"><i class="fas fa fa-pencil" data-icon="fas fa fa-pencil"></i></span>
		                        <input name="rePayPrice" id="rePayPrice" class="form-control text-right fill" type="text" value="" oninput="this.value = this.value.replace(/[^0-9.]/g, '').replace(/(\..*)\./g, '$1');">
		                    </div>
		                </div>
		            </div>
				</form>
				<card:close />
			</div>
		</div>
	</div>
	<div class="row padding-left-10 padding-right-10">
		<div class="bottom-btn-area">
			<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12 text-right">
				<button type="button" id="btnApproval" class="btn btn-sm waves-effect waves-light btn-danger btn-outline-danger default">
				    <span class="icofont icofont-close"></span>
				    &nbsp;재결제
				</button>
				<form:button type="Close" id="btnClose" />
			</div>
			<label:clear />
		</div>
	</div>
</div>