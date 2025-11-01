<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="form" uri="http://ad.its.yeongju.kr/jsp/jstl/form"%>
<%@ taglib prefix="card" uri="http://ad.its.yeongju.kr/jsp/jstl/card"%>
<%@ taglib prefix="func" uri="http://ad.its.yeongju.kr/jsp/jstl/func"%>
<%@ taglib prefix="label" uri="http://ad.its.yeongju.kr/jsp/jstl/label"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%@ include file="../../core/include/head.jsp"%>
<%@ include file="../../core/include/headerPopup.jsp"%>

<script type="text/javascript">

	function saveData() {
		var frm = $("#frmMain");
		frm.serializeArrayCustom();
		frm.addParam("func", "IS");
		frm.addParam("enc_col", "userId");
		frm.setAction("<c:url value='/market/offlineCouponSave.do' />");
		frm.addParam("dataType", "json");
		frm.addParam("afterAction", false);
		frm.request();
	}

	function handleIS(data, textStatus, jqXHR){
		if (data.count > 0) {
			if (opener && typeof opener.loadTableData === "function") {
				opener.loadTableData();
			}
			window.close();
		}else if(data.count == -100){
			alert(data.message);
		}else{
			notifyDanger(data.message);
		}
	}
	
	// 적용구분 - 시간/금액 연계
	function checkInputValue() {
		const discountGubn = $("#pDiscountGubn").val();
		const discountValue = parseInt($("#pDiscount").val().replaceAll(",", ""), 10);
		let bool = false;
		
		// 할인 구분에 따라 30분 배수인지 100원 배수인지 확인
		if(discountGubn == "M" && discountValue % 30 > 0){
			bool = true;
	    } else if(discountGubn == "P" && discountValue % 100 > 0) {
	    	bool = true;
	    }
		
	    if(bool) {
	        // 할인 구분에 맞는 공통코드값이 없으면 0으로 세팅 처리
	        $("#pDiscount").val("0");
	        alert("※ 시간/금액 입력 가능 범위 (숫자만 입력 가능)\n- 시간 입력가능 범위 : 30분 단위\n- 금액 입력가능 범위 : 100원 단위");
	    }
	}
	
	$(function(){
		$("#btnClose").click(function() {
			self.close();
		});
		
		$("#btnSave").click(function() {
			if($("#pGovCode").val() == ""){
				alert("관리기관을 선택해 주세요.");
				return;
			} else if($("#pCouponName").val().trim() == ""){
				alert("할인궘명을 입력해 주세요.");
				return;
			} else if($("#pCouponFormat").val().trim() == ""){
				alert("할인궘포맷을 입력해 주세요.");
				return;
			} else if($("#pCouponUseGubn").val().trim() == ""){
				alert("할인권구분을 선택해 주세요.");
				return;
			} else if($("#pDiscountGubn").val().trim() == ""){
				alert("적용구분을 선택해 주세요.");
				return;
			} else if($("#pDiscount").val() == "" || $("#pDiscount").val() == "0"){
				alert("시간/금액을 입력해 주세요.");
				return;
			} 
			if(confirm("저장하시겠습니까?")){
				saveData();
			}
		});
		
		$("#pDiscount").change(function() {
			if($("#pDiscountGubn").val() == ""){
				alert("적용구분을 선택해 주세요.");
				$(this).val(0);
			}
		});
		
		$("#pDiscount, #pDiscountGubn").change(function() {
			checkInputValue();
		});

		$("#pDiscount").inputMasking("number");
		
	});
</script>

<div class="page-body" style="font-size: 0.9em;">
	<div class="row">
		<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12">
			<card:open title="실물권 등록" />
			<card:button>
			</card:button>
			<card:content />
			<div class="format_guide">
				<h6>[할인권 포맷 작성 안내]</h6>
				<div class="format-item">
					<div>
						<strong>{CP_GUBN}</strong> = 할인권구분 (D1,D2)<br>
					    <strong>{DC_GUBN}</strong> = 적용구분 (P,M)<br>
					</div>
					<div>
		 				<strong>{RN}</strong> = 랜덤난수 (문자+숫자 랜덤 6자리)<br>
						<strong>{CP_VALUE}</strong> = 시간/금액<br>
					</div>
				</div>
				<div class="format_example">
				  	<span>항목의 순서나 구분자(:, -, _ 등)를 자유롭게 조합하세요.</span><br>
	 				 예시 :
				  	<strong>{CP_GUBN}:{CP_VALUE}-{RN}-{DC_GUBN}, {CP_GUBN}-{CP_VALUE}-{DC_GUBN}-{RN}</strong>
			  	</div>
			  	<div class="format_danger">
			  		<strong>※ 같은 기관 내에서 동일한 포맷은 중복 등록할 수 없습니다.</strong>
			  	</div>
			</div>
			<form id="frmMain" name="frmMain" method="post" onsubmit="return false" class="form-horizontal" >
				<c:choose>
					<c:when test="${fn:contains(user_role_id, 'MANAGE') || fn:contains(user_role_id, 'AD')}">
						<label:select id="pGovCode" caption="관리기관" className="danger" queryId="select.select_parkingGovInfo" all="true" allLabel="선택"/>
					</c:when>
					<c:otherwise>
						<label:select id="pGovCode" caption="관리기관" className="danger" queryId="select.select_parkingGovInfo" all="false" allLabel="선택"/>
					</c:otherwise>
				</c:choose>
				<label:input id="pCouponName" caption="할인권명" className="danger" size="12" addAttr="maxlength='50';"/>
				<label:input id="pCouponFormat" caption="할인권포맷" className="danger" size="12" addAttr="maxlength='500';"/>
				<label:select id="pCouponUseGubn" caption="할인권구분" className="danger" all="true" allLabel="선택" queryId="#COUPON_USE_GUBN"/>
				<label:select id="pDiscountGubn" caption="적용구분" className="danger" all="true" allLabel="선택" queryId="#DISCOUNT_GUBN"/>
				<label:input id="pDiscount" caption="시간/금액" className="danger" size="12" addAttr="style='text-align:right;' maxlength='6'"/>					
				<label:clear />
			</form>
			<card:close />
		</div>
	</div>
	<div class="row">
		<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12 text-right">
			<div class="bottom-btn-area">
				<form:button type="Save" id="btnSave" />
				<form:button type="Close" id="btnClose" />
			<label:clear />
			</div>
		</div>
	</div>
</div>