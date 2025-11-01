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
	
	var imageUriData = "";
	
	var downloadCode = "";

	var parkingNoStr = "";

	function loadTableData() {
		
		var frm = $("#frmMain");
		frm.addParam("func", "IQ");
		frm.addParam("query_id", "market.couponAreaManage.select_applyDetail");
		frm.addParam("hAppCouponAreaCode", $("#hAppCouponAreaCode").val());
	    frm.addParam("dataType", "json");           // 그리드 불러오는 타입 (기본 json)
		frm.request();
	}
	
	function handleIQ(data, textStatus, jqXHR) {
		if(data.length > 0) {
			$("#kApplyDate").val(data[0].regDt);
			$("#pGovName").val(data[0].pGovName);
			$("#hPGovCode").val(data[0].pGovCode);
			$("#pParkingNo").val(data[0].parkingNo);
			$("#hParkingNo").val(data[0].parkingNo);
			$("#kAreaName").val(data[0].areaName);
			$("#kCouponMemberName").val(data[0].couponMemberName);
			$("#kMemberPhone").val(data[0].memberPhone);
			
			$("#kZipCode").val(data[0].zipCode);
			$("#kAddrCode1").val(data[0].address1);
			$("#kAddrCode2").val(data[0].address2);
			$("#kRejectReason").val(data[0].rejectReason);
			$("#kConfirmName").val(data[0].confirmName);
			$("#kConfirmDt").val(data[0].confirmDt);
			$("#confirmYnName").val(data[0].confirmYnName);
			$("#delYnName").val(data[0].delYnName);
			
			$('#kMemberPhone').blur();
			$('#kMemberPhone').attr("readonly", "true");
			$("#kMemberPhone").siblings("span").children("i").removeClass();
			$("#kMemberPhone").siblings("span").children("i").addClass("fas fa-eye");
			$("#kMemberPhone").siblings("span").children("i").data("icon", "fas fa-eye");
			
			if(data[0].confirmYn == "Y"){ // 승인
				var html = "<input name='pParkingNo' id='pParkingNo' class='form-control fill' type='text' value='' readonly='readonly'>";

				$(".input-group").each(function() {
				    var selectElement = $(this).find("#pParkingNo");
				    if (selectElement.length > 0) {
				        selectElement.remove();
				        $(this).append(html);
				    }
				});
				$("#pParkingNo").val(data[0].parkingName);
				$("#kRejectReason").parent("div").parent("div").parent("div").css("display", "none");
				
				$("#pParkingNo").siblings("span").children("i").removeClass();
				$("#pParkingNo").siblings("span").children("i").addClass("fas fa-eye");
				$("#pParkingNo").siblings("span").children("i").data("icon", "fas fa-eye");
				$("#pParkingNo").parent("div").parent("div").parent("div").removeClass("has-danger");
				
			} else if(data[0].confirmYn == "N"){ // 미승인
				loadParkingData();
			
			} else if(data[0].confirmYn == "C"){ // 거절
				var html = "<input name='pParkingNo' id='pParkingNo' class='form-control fill' type='text' value='' readonly='readonly'>";

				$(".input-group").each(function() {
				    var selectElement = $(this).find("#pParkingNo");
				    if (selectElement.length > 0) {
				        selectElement.remove();
				        $(this).append(html);
				    }
				});
				
				$("#pParkingNo").val(data[0].parkingName);
				$("#pParkingNo").siblings("span").children("i").removeClass();
				$("#pParkingNo").siblings("span").children("i").addClass("fas fa-eye");
				$("#pParkingNo").siblings("span").children("i").data("icon", "fas fa-eye");
				$("#pParkingNo").parent("div").parent("div").parent("div").removeClass("has-danger");
				
				$("#kRejectReason").attr("readonly", true);
				$("#kRejectReason").siblings("span").children("i").removeClass();
				$("#kRejectReason").siblings("span").children("i").addClass("fas fa-eye");
				$("#kRejectReason").siblings("span").children("i").data("icon", "fas fa-eye");
				$("#kRejectReason").css("background-color", "#EEEEEE");
			}
		}
		/* $(".card-block").eq(1).css("height", $(".card-block").eq(0).innerHeight()); */
	
	}
	
	function loadComboData() {
		var frm = $("#frmMain");
		frm.addParam("func", "IQCombo");
		frm.addParam("kParkingGovCode", $("#hPGovCode").val());
		frm.addParam("queryId", "select.select_parkingInfo3");
		frm.addParam("afterAction", false);
		frm.request();
	}
	
	function handleIQCombo(data, textStatus, jqXHR) {
		$("#pParkingNo option").remove();
		
		if(data.length > 0){
			$("#pParkingNo").parent().parent().show();
			$.each(data, function(k, v) {
				if (parkingNoStr.indexOf(v.value) != -1) {
				  
				} else {
					$("#pParkingNo").append("<option value='" + v.value + "'>" + v.text + "</option>");  
				}
			});
			$("#pParkingNo").val($("#hParkingNo").val());
		}else{
			$("#pParkingNo").parent().parent().show();
		}
	}
	
	function loadParkingData() {
		var frm = $("#frmMain");
		frm.addParam("func", "IQParking");
		frm.addParam("enc_col", "hCouponMemberId");
		frm.addParam("query_id", "market.couponAreaManage.select_parkingList");
		
		frm.addParam("afterAction", false);
		frm.request();
	}
	
	function handleIQParking(data, textStatus, jqXHR) {
		if(data.length > 0){
			parkingNoStr = data[0].parkingNo;
			loadComboData();
		}
	}
	
	
	
	function saveData(gubn) {
		
		var frm = $("#frmMain");
		frm.serializeArrayCustom();
		frm.addParam("func", "IS");
		frm.addParam("enc_col", "userId, hCouponMemberId");
		frm.addParam("gubn", gubn);
		frm.addParam("parkingName", $("#pParkingNo :selected").text());
		frm.addParam("hAppCouponAreaCode", $("#hAppCouponAreaCode").val());
		
		frm.setAction("<c:url value='/market/CouponAreaSave.do' />");
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
		
		// 앞뒤공백없애기
		$("textarea.form-control").on("blur",function(){
        	$(this).val($.trim($(this).val()));
	    })
		
		$("#btnApproval").click(function() {
			if(confirm("할인권 장소 신청 건을 승인하시겠습니까?")){
				saveData("Y");	
			}
		});

		$("#btnReject").click(function() {
			if($("#kRejectReason").val() == '') {
				alert("할인권 장소 신청 건의 거절사유를 입력해주세요.");
				$("#kRejectReason").focus();
				return false;
			}else{
				if(confirm("할인권 장소 신청 건을 거절하시겠습니까?")){
					saveData("C");
				}
			}
		});
		
		$("#btnClose").click(function() {				
			self.close();
		});
		
		$("#kMemberPhone").inputMasking("phone");
		
		loadTableData();
	});

</script>

<div class="page-body" style="font-size: 0.9em;">
	<div class="row">
		<div class="col-12" id="search_all_wrapper">
			<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12">
				<card:open title="할인권 장소 신청 상세" />
				<card:button>
				</card:button>
				<card:content />
				<form id="frmMain" name="frmMain" method="post" onsubmit="return false" class="form-horizontal">
					<form:input id="hAppCouponAreaCode" type="hidden" value="${param.appCouponAreaCode}" />
					<form:input id="hCouponMemberId" type="hidden" value="${param.couponMemberId}" />
					<form:input id="hParkingNo" type="hidden"/>
					<form:input id="hPGovCode" type="hidden"/>  
					
					<label:input id="kApplyDate" caption="신청일시" size="12" state="readonly" addAttr="style='text-align:center;'"/>
					<label:input id="pGovName" caption="관리기관" size="12" state="readonly"/>
					<%-- <label:select id="pGovCode" caption="관리기관" size="12" queryId="select.select_parkingGovInfo" all="false" allLabel="선택" state="readonly"/> --%>
					<label:select id="pParkingNo" caption="주차장명" className="danger" size="12" queryId="select.select_parkingInfo3" all="false" allLabel="선택"/>
					<label:input id="kAreaName" caption="장소" size="12" state="readonly"/>
					<label:input id="kCouponMemberName" caption="주차권관리자" size="12" state="readonly" addAttr="style='text-align:center;'"/>
					<label:input id="kMemberPhone" caption="휴대폰번호" size="12" state="" addAttr="style='text-align:center;'"/>
					<label:input id="kZipCode" caption="우편번호" size="12" state="readonly"/>
					<label:input id="kAddrCode1" caption="주소" size="12" state="readonly"/>
					<label:input id="kAddrCode2" caption="상세주소" size="12" state="readonly"/>
					<label:input id="confirmYnName" caption="처리여부" size="12" state="readonly" addAttr="style='text-align:center;'"/>
					<label:input id="delYnName" caption="삭제여부" size="12" state="readonly" addAttr="style='text-align:center;'"/>
					<c:if test="${param.confirmYn eq 'N' or  param.confirmYn eq 'C'}">
						<label:textarea id="kRejectReason" caption="거절사유" size="12" rows="2"/>
					</c:if>
					<c:if test="${param.confirmYn eq 'Y' or param.confirmYn eq 'C' }">
						<label:input id="kConfirmName" caption="승인자" size="12" state="readonly"/>
						<label:input id="kConfirmDt" caption="승인일시" size="12" state="readonly" addAttr="style='text-align:center;'"/>
					</c:if>
				</form>
				<card:close />
			</div>
		</div>
	</div>
	<div class="row padding-left-10 padding-right-10">
		<div class="bottom-btn-area">
			<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12 text-right">
				<c:if test="${param.confirmYn eq 'N' }">
					<form:button type="Approval" id="btnApproval" />
					<button type="button" id="btnReject" class="btn btn-sm waves-effect waves-light btn-danger btn-outline-danger default"> 
					    <span class="icofont icofont-close"></span> 
					    &nbsp;거절 
					</button>
				</c:if>
				<form:button type="Close" id="btnClose" />
			</div>
			<label:clear />
		</div>
	</div>
</div>