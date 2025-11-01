<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="form" uri="http://ad.its.yeongju.kr/jsp/jstl/form"%>
<%@ taglib prefix="card" uri="http://ad.its.yeongju.kr/jsp/jstl/card"%>
<%@ taglib prefix="func" uri="http://ad.its.yeongju.kr/jsp/jstl/func"%>
<%@ taglib prefix="label" uri="http://ad.its.yeongju.kr/jsp/jstl/label"%>

<%@ include file="../../core/include/head.jsp"%>
<%@ include file="../../core/include/headerPopup.jsp"%>

<script type="text/javascript">
	
	function loadTableData() {
		var frm = $("#frmMain");
		frm.addParam("func", "IQ");
		frm.addParam("query_id", "market.couponRefundManage.Select_PopupList");
		frm.addParam("enc_col", "hCouponMemberId");
	    frm.addParam("dataType", "json");           // 그리드 불러오는 타입 (기본 json)
		frm.request();
	}
	
	function handleIQ(data, textStatus, jqXHR) {
		if(data.length > 0) {
			$("#frmMain").formSet(data);
			
			if(data[0].confirmYn == "N"){
				// 요청 상태
				$("#confirmName, #confirmDt").parent().parent().parent().hide();
			} else {
				$("#btnApproval, #btnRefusal").hide();
				
				if(data[0].confirmYn == "Y") {			// 승인 상태
					$(".card .card-header h5").eq(0).text("환불 상세 (승인완료)");
					$("#confirmName, #confirmDt").parent().parent().parent().show();
					$("#rejectReason").parent().parent().parent().hide();
					
				} else if(data[0].confirmYn == "C") {	// 거절 상태
					$(".card .card-header h5").eq(0).text("환불 상세 (거절)");
					$("#confirmName, #confirmDt").parent().parent().parent().show();
					id = "#rejectReason";
					$(id).prop("readonly",true);
					$(id).siblings("span").children("i").removeClass();
					$(id).siblings("span").children("i").addClass("fas fa-eye");
					$(id).css("background-color", "#EEEEEE");
				}	
			}
			$(".card").eq(1).height($(".card").eq(0).height());
		}
	
	}

	function saveData() {
		var frm = $("#frmMain");
		frm.serializeArrayCustom();
		frm.addParam("func", "IS");
		frm.addParam("enc_col", "userId, hCouponMemberId");
		frm.addParam("repayType", "U");
		frm.setAction("<c:url value='/market/couponRefundConfirm.do' />");
		frm.addParam("dataType", "json");
		frm.request();
	}
	
	function handleIS(data, textStatus, jqXHR) {
		if(data.count > 0){
			self.close();
			opener.loadTableData();	
		}
		
	}
	
	function saveData2() {
		var frm = $("#frmMain");
		frm.serializeArrayCustom();
		frm.addParam("func", "IS2");
		frm.addParam("enc_col", "userId, hCouponMemberId");
		frm.setAction("<c:url value='/market/couponRefundReject.do' />");
		frm.addParam("dataType", "json");
		frm.request();
	}
	
	function handleIS2(data, textStatus, jqXHR) {
		if(data.count > 0){
			self.close();
			opener.loadTableData();
		}
	}

    
	$(function(){
		$("#memberPhone").inputMasking("phone");
		$("#refundReason").css("background-color", "#EEEEEE");
		
		$("#btnApproval").click(function() {
			if(confirm("환불 신청 건을 승인하시겠습니까?")){
				saveData();	
			}	
		});

		$("#btnRefusal").click(function() {
			if($("#rejectReason").val() == '') {
				alert("환불 신청 건의 거절사유를 입력해주세요.");
				$("#reqReason").focus();
				return false;
			}else{
				if(confirm("환불 신청 건을 거절하시겠습니까?")){
					saveData2();
				}
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
		<form id="frmMain" name="frmMain" method="post" onsubmit="return false" class="form-horizontal">
			<form:input id="hPublishCode" type="hidden" value="${param.publishCode}" />
			<form:input id="hCouponCode" type="hidden" value="${param.couponCode}" />
			<form:input id="hParkingNo" type="hidden" value="${param.parkingNo}" />
			<form:input id="hCouponAreaCode" type="hidden" value="${param.couponAreaCode}" />
			<form:input id="hCouponMemberId" type="hidden" value="${param.couponMemberId}" />
			<form:input id="hAppRefundCode" type="hidden" value="${param.appRefundCode}" />
			
			<div class="col-xl-6 col-lg-6 col-md-6 col-sm-6 col-6">
				<card:open title="환불 신청 상세"/>
				<card:button>
				</card:button>
				<card:content />
					<label:input id="refundRegDt" caption="환불요청일시" state="readonly" addAttr="style='text-align: center;'" size="12"/>
					<label:input id="purchaseRegDt" caption="결제일시" state="readonly" addAttr="style='text-align: center;'" size="12"/>
					<label:input id="couponMemberName" caption="주차권관리자" state="readonly" addAttr="style='text-align: center;'" size="12"/>
					<label:input id="memberPhone" caption="휴대폰번호" state="readonly" addAttr="style='text-align: center;'" size="12"/>
					<label:input id="confirmYnName" caption="환불여부" state="readonly" addAttr="style='text-align: center;'" size="12"/>
					<label:textarea id="refundReason" caption="환불사유" rows="3" state="readonly" size="12"/>
					<label:textarea id="rejectReason" caption="거절사유" rows="3" size="12"/>
					<label:input id="confirmName" caption="승인자" state="readonly" size="12"/>
					<label:input id="confirmDt" caption="승인일시" state="readonly" size="12"/>
				<card:close />
			</div>
			<div class="col-xl-6 col-lg-6 col-md-6 col-sm-6 col-6">
				<card:open title="환불 할인권 정보"/>
				<card:button>
				</card:button>
				<card:content />
					<label:input id="pGovName" caption="관리기관" state="readonly" size="12"/>
					<label:input id="parkingName" caption="주차장명" state="readonly" size="12"/>
					<label:input id="areaName" caption="장소" state="readonly" size="12"/>
					<label:input id="couponName" caption="할인권명" state="readonly" size="12"/>
					<label:input id="couponGubnName" caption="할인권구분" state="readonly" addAttr="style='text-align: center;'" size="12"/>
					<label:input id="couponQty" caption="수량" state="readonly" addAttr="style='text-align: right;'" size="12"/>
					<label:input id="purchasePrice" caption="금액" state="readonly" addAttr="style='text-align: right;'" size="12"/>
				<card:close />
			</div>
			</form>
		</div>
	</div>
	<div class="row padding-left-10 padding-right-10">
		<div class="bottom-btn-area">
			<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12 text-right">
				<form:button type="Approval" id="btnApproval" />
				<form:button type="Refusal" id="btnRefusal" />
				<form:button type="Close" id="btnClose" />
			</div>
			<label:clear />
		</div>
	</div>
</div>