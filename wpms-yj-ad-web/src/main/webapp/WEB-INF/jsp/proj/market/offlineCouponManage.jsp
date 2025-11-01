<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="form" uri="http://ad.its.yeongju.kr/jsp/jstl/form"%>
<%@ taglib prefix="card" uri="http://ad.its.yeongju.kr/jsp/jstl/card"%>
<%@ taglib prefix="func" uri="http://ad.its.yeongju.kr/jsp/jstl/func"%>
<%@ taglib prefix="label" uri="http://ad.its.yeongju.kr/jsp/jstl/label" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%@ include file="../../core/include/head.jsp"%>
<%@ include file="../../core/include/header.jsp"%>

<script type="text/javascript">
	// 데이터 복원 시 사용할 원본 데이터 변수
	var _originData;
	
	// 컬럼 옵션
	var columnDefs = [
			setColumn(["no", "번호", "center", 50], [false, ["index", "asc"]]),
			
			setColumn(["offCouponCode", "발급코드", "center", 100]),
			<c:if test="${fn:contains(user_role_id, 'MANAGE') || fn:contains(user_role_id, 'AD')}"> 
				setColumn(["pGovName", "관리기관", "left", 150]),
			</c:if>
			setColumn(["offCouponName", "할인권명", "left", 150]),
			setColumn(["offCouponFormat", "할인권포맷", "left", 200]),
			setColumn(["couponUseGubnName", "할인권구분", "center", 80]),
			setColumn(["discountGubnName", "적용구분", "center", 80]),
			setColumn(["discount", "시간/금액", "right", 80]),
			setColumn(["qty", "수량", "right", 80]),
			setColumn(["print", "인쇄", "center", 50], [grdPrint, ["button", null, "link", "인쇄", ""]]),
			setColumn(["regName", "등록자", "center", 80]),
			setColumn(["regDt", "등록일시", "center", 100]),
	];
	setColumnMask(columnDefs, "discount", "number");
	setColumnMask(columnDefs, "qty", "number");
	setColumnMask(columnDefs, "regDt", "datetime");

	var _gridHelper = new initGrid(columnDefs, true);
	var gridOptions = _gridHelper.setGridOption();

	function grdPrint(e, data) {
		// 모달
		$("#hOfflineCouponCode").val(data.offCouponCode);
		loadDetailData();
		$("#modalEdit").modal('show');		
	}
	
	function loadTableData() {
		var frm = $("#frmMain");
		frm.serializeArrayCustom();
		//---- 그리드 조회 시 필수요소 start
		frm.addParam("result", $("#myGrid")); // 그리드 태그
		frm.addParam("grid", "gridOptions"); // 그리드 옵션
		frm.addParam("baseData", "_originData"); // 그리드 원본 데이터 저장 변수
		//---- 그리드 조회 시 필수요소 end
		frm.addParam("func", "IQ");
		frm.addParam("query_id", "market.offlineCouponManage.select_couponList");
		frm.addParam("dataType", "json"); // 그리드 불러오는 타입 (기본 json)
		frm.request();
	}

	function handleIQ(data, textStatus, jqXHR) {
		gridOptions.api.sizeColumnsToFit();
	}
	
	function loadDetailData() {
		var frm = $("#frmModal");
		frm.addParam("func", "IQ2");
		frm.addParam("query_id", "market.offlineCouponManage.select_couponDetail");
		frm.addParam("dataType", "json"); // 그리드 불러오는 타입 (기본 json)
		frm.request();
	}

	function handleIQ2(data, textStatus, jqXHR) {
		if (data.length > 0) {
			$("#pGovName").val(data[0].pGovName);
			$("#pOffCouponName").val(data[0].offCouponName);
			$("#pPrintQty").val(data[0].qty);
			$("#pQty").data("inputMasking").setValue("");
		}
	}

	// 모달 적용
	function saveData() {
		var frm = $("#frmModal");
		frm.serializeArrayCustom();
		frm.addParam("func", "IS");
		frm.addParam("enc_col", "userId");
		frm.setAction("<c:url value='/market/offlineCouponDetail.do' />");
		frm.addParam("dataType", "json");
		frm.request();
	}

	function handleIS(data, textStatus, jqXHR){
		if (data.count > 0) {
			loadTableData();
			$("#modalEdit").modal('hide');
			// 인쇄팝업
			OpenPopupSingle("/market/offlineCouponPrintPopup.do?printCode=" + data.data.printCode, 840, 1000, "_offlineCouponPrintPop");
			
		}else if(data.count == -100){
			alert(data.message);
		}else{
			notifyDanger(data.message);
		}
	}

	$(function() {
		$("#pQty").inputMasking("number");
		
		// lookup the container we want the Grid to use
		var eGridDiv = document.querySelector('#myGrid');

		// create the grid passing in the div to use together with the columns & data we want to use
		new agGrid.Grid(eGridDiv, gridOptions);

		// frmMain 자동조회
		$("#frmMain").autoSearch(loadTableData);

		// 조회
		$("#btnSearch").click(function() {
			loadTableData();
		});

		$("#btnRegister").click(function() {
			OpenPopupSingle("/market/offlineCouponManagePopup.do", 700, 707, "_offlineCouponPop");
		});
		
		// 모달 닫기
		$("#btnModalClose").click(function(){
			$("#hOfflineCouponCode").val("");
			$("#modalEdit").modal('hide');
		});
		
		// 모달 인쇄
		$("#btnPrint").click(function(){
			if($("#pQty").val() == "" || $("#pQty").val() == "0"){
				alert("수량을 입력해 주세요.");
				return;
			}
			if(confirm("인쇄를 진행하시겠습니까?\n\n※입력하신 수량만큼 할인권을 발행하고 인쇄 팝업이 호출됩니다.\n이미 발행된 할인권의 경우 재인쇄가 불가능합니다.")){
				saveData();
			}
		});
		

		loadTableData();
		
	});
</script>


<div class="page-body" style="font-size: 0.9em;">
	<div class="row">
		<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12"
			id="search_all_wrapper">
			<card:open title="검색 조건" />
			<card:button>
				<form:button type="Search" id="btnSearch" />
				<form:button type="Register" id="btnRegister" />
			</card:button>
			<card:content />
			<div class="search-area col-lg-12">
				<form id="frmMain" name="frmMain" method="post" onsubmit="return false" class="form-material form-inline">
					<form:input id="hCouponMemberId" caption="hCouponMemberId" type="hidden" />
					<c:choose>  
						<c:when test="${fn:contains(user_role_id, 'MANAGE') || fn:contains(user_role_id, 'AD')}"> 
							<form:select id="kParkingGovCode" caption="관리기관" all="true" allLabel="전체" queryId="select.select_parkingGovInfo"/>
						</c:when> 
						<c:otherwise> 
							<form:select id="kParkingGovCode" caption="관리기관" all="false" allLabel="전체" queryId="select.select_parkingGovInfo"/>
						</c:otherwise>
					</c:choose>
					<form:input id="kCouponName" caption="할인권명" addAttr="maxlength='50'" />
					<form:select id="kCouponUseGubn" caption="할인권구분" all="true" allLabel="전체" queryId="#COUPON_USE_GUBN"/>
					<form:select id="kDiscountGubn" caption="적용구분" all="true" allLabel="전체" queryId="#DISCOUNT_GUBN"/>
				</form>
			</div>
			<card:close />
		</div>
		<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12">
			<card:open title="실물 할인권 목록" />
			<card:toolButton title="">
			</card:toolButton>
			<card:content />
			<form:grid id="myGrid" />
			<card:close />
		</div>
	</div>
</div>


<%@ include file="../../core/include/footer.jsp"%>

<!-- 인쇄 모달 -->
<div class="modal fade" id="modalEdit" tabindex="-1" role="dialog" aria-labelledby="modalEdit" style="position: fixed;"
	data-backdrop="static" data-keyboard="false">
	<div class="modal-dialog" role="document" style="max-width: 500px;">
		<div class="modal-content">
			<div class="modal-header">
				<h5 class="modal-title">실물 할인권 인쇄</h5>
			</div>
			<div class="modal-body">
				<div class="row">
					<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12">
						<card:content />
						<form id="frmModal" name="frmModal" method="post" onsubmit="return false" class="form-horizontal" >
							<form:input id="hOfflineCouponCode" type="hidden"/>
							<c:if test="${fn:contains(user_role_id, 'MANAGE') || fn:contains(user_role_id, 'AD')}"> 
							<label:input id="pGovName" caption="관리기관" size="12" state="readonly"/>
							</c:if>
							<label:input id="pOffCouponName" caption="할인권명" size="12" state="readonly"/>
							<label:input id="pPrintQty" caption="발권수량" size="12" state="readonly" addAttr="style='text-align: right;'"/>
							<label:input id="pQty" caption="수량" size="12" addAttr="maxlength='6'; style='text-align: right;'"/>
							<label:clear />
						</form>
						<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12 text-right">
	                        <form:button type="inspectionStatement" id="btnPrint" />
							<form:button type="Close" id="btnModalClose" />
	                    </div>
						<card:close />
					</div>
				</div>
			</div>
		</div>
	</div>
</div>
