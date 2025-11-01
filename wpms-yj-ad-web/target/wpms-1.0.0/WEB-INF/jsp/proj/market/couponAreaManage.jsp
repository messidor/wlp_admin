<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="form" uri="http://ad.its.yeongju.kr/jsp/jstl/form" %>
<%@ taglib prefix="card" uri="http://ad.its.yeongju.kr/jsp/jstl/card" %>
<%@ taglib prefix="func" uri="http://ad.its.yeongju.kr/jsp/jstl/func" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%@ include file="../../core/include/head.jsp" %>
<%@ include file="../../core/include/header.jsp" %>

<script type="text/javascript">

	var _originData;

	// 컬럼 옵션
	var columnDefs = [
		/*
			[*_field, *_headerName, _align, _width],
			[*_editable, _inputType[(select, check, radio, text("")), _data, _valueName, _textName], _required, _maskType(""(string), "number"), _maxLength("10.5", "5")],
			_hide, _rowDrag, _lockColumn, _addClass

			setColumn_New(
				[ (*필드명), (*헤더명), (정렬), (너비) ],
				[ (*편집여부), (입력종류(배열) [ (종류문자열), (데이터), (value컬럼명), (text컬럼명) ]), (필수여부), (마스크종류), (최대길이) ],
				(숨김여부),
				(row 드래그 여부),
				(고정 여부),
				(추가 클래스명)
			)

			(종류문자열) : "select", "check", "text"
			(최대길이) : 문자열로 입력할 것
		*/
		setColumn(["no", "번호", "center", 50], [false, ["index", "asc"]]),
		setColumn(["appCouponAreaCode", "appCouponAreaCode", "center", 60],[],true),
		setColumn(["couponMemberId", "couponMemberId", "center", 60],[],true),
		setColumn(["confirmYn", "confirmYn", "center", 60],[],true),
		setColumn(["pGovCode", "pGovCode", "center", 60],[],true),
		setColumn(["parkingNo", "parkingNo", "center", 60],[],true),
		setColumn(["regDt", "신청일시", "center", 120]),
		setColumn(["pGovName", "관리기관", "center", 150]),
		setColumn(["parkingName", "주차장명", "left", 150]),
		setColumn(["areaName", "장소명", "left", 120]),
		setColumn(["couponMemberName", "주차권관리자", "center", 100]),
		setColumn(["memberPhone", "휴대폰번호", "center", 100]),
		setColumn(["address", "주소", "left", 180]),
		setColumn(["confirmYn", "처리여부", "center", 100], [false, ["select", ${func:codeToJSON(pageContext, 'CONFIRM_YN')}, "value", "text"], false, "", "20"], false, false, false, ""),
		setColumn(["delYn", "삭제여부", "center", 100], [false, ["select", ${func:codeToJSON(pageContext, 'DEL_YN')}, "value", "text"], false, "", "20"], false, false, false, ""),
		setColumn(["confirmName", "승인자", "center", 100]),
		setColumn(["confirmDt", "승인일시", "center", 120]),
	];

	// setColumnMask(컬럼옵션변수, 컬럼명, 타입, 추가옵션)
	setColumnMask(columnDefs, "memberPhone", "phone");
	setColumnMask(columnDefs, "regDt", "datetime");
	setColumnMask(columnDefs, "confirmDt", "datetime");

	// 그리드 옵션
	// 컬럼정의 / 화면에 그리드 맞추기 / 행추가 func
	var _gridHelper = new initGrid(columnDefs, true);
	var gridOptions = _gridHelper.setGridOption();
	
	// 그리드 클릭 이벤트 추가
	_gridHelper.addRowDblClickEvent(gridRowClickEvent);
	
	// 그리드 클릭 이벤트 내용
	function gridRowClickEvent(event) {
		if(event.data.confirmYn == "Y"){
			OpenPopupSingle("/market/couponAreaManagePopup.do?appCouponAreaCode="+ event.data.appCouponAreaCode + "&confirmYn=" + event.data.confirmYn + "&pGovCode=" + event.data.pGovCode + "&parkingNo=" + event.data.parkingNo + "&couponMemberId=" + event.data.couponMemberId, 500, 905, "_PopCouponAreaManagePopup");	
		}else if(event.data.confirmYn == "N"){
			OpenPopupSingle("/market/couponAreaManagePopup.do?appCouponAreaCode="+ event.data.appCouponAreaCode + "&confirmYn=" + event.data.confirmYn + "&pGovCode=" + event.data.pGovCode + "&parkingNo=" + event.data.parkingNo + "&couponMemberId=" + event.data.couponMemberId, 500, 885, "_PopCouponAreaManagePopup");
		}else if(event.data.confirmYn == "C"){
			OpenPopupSingle("/market/couponAreaManagePopup.do?appCouponAreaCode="+ event.data.appCouponAreaCode + "&confirmYn=" + event.data.confirmYn + "&pGovCode=" + event.data.pGovCode + "&parkingNo=" + event.data.parkingNo + "&couponMemberId=" + event.data.couponMemberId, 500, 1015, "_PopCouponAreaManagePopup");
		}
	}

	function loadTableData() {
		
		var kApplyDate = $("#kApplyDate").val();
		var kApplyDateArr = kApplyDate.split(" - ");
		
		var startDt = kApplyDateArr[0];
		var endDt = kApplyDateArr[1];
		
		var frm = $("#frmMain");
	    //---- 그리드 조회 시 필수요소 start
	    frm.addParam("result", $("#myGrid"));       // 그리드 태그
	    frm.addParam("grid", "gridOptions");        // 그리드 옵션
	    frm.addParam("baseData", "_originData");    // 그리드 원본 데이터 저장 변수
	    //---- 그리드 조회 시 필수요소 end
	    frm.addParam("func", "IQ");
	    frm.addParam("enc_col", "kMemberName");
	    frm.addParam("startDt", startDt);
		frm.addParam("endDt", endDt);
		frm.addParam("query_id", "market.couponAreaManage.select_applyList");
	    frm.addParam("dataType", "json");           // 그리드 불러오는 타입 (기본 json)
		frm.request();
	}

	function handleIQ(data, textStatus, jqXHR) {
		gridOptions.api.sizeColumnsToFit();
		
		if(data.length > 0){}
	}
	
	function viewGubn(){
		if($("#kConfirmYn").val() == "N" || $("#kConfirmYn").val() == "C"){
			$("#kApplyDate").parent().parent().hide();
		}else{
			$("#kApplyDate").parent().parent().show();
		}
	}

	function loadComboData() {
		var frm = $("#frmMain");
		frm.addParam("func", "IQCombo");
		frm.addParam("kParkingGovCode", $("#kParkingGovCode").val());
		frm.addParam("apiVerGubn", "2");
		frm.addParam("queryId", "select.select_parkingInfo2");
		frm.addParam("afterAction", false);
		frm.request();
	}

	function handleIQCombo(data, textStatus, jqXHR) {
		$("#kParkingNo option[value!='']").remove();
		$.each(data, function(k, v) {
			$("#kParkingNo").append("<option value='" + v.value + "'>" + v.text + "</option>");
		});
		loadTableData();
	}
	
	$(function() {
		// lookup the container we want the Grid to use
	    var eGridDiv = document.querySelector('#myGrid');

	    // create the grid passing in the div to use together with the columns & data we want to use
	    new agGrid.Grid(eGridDiv, gridOptions);

	    $("#kApplyDate").initDateOnly("year", -1, "year", 0);

	 	// frmMain 자동조회
	    // $("#frmMain").autoSearch(loadTableData);

	 	// 조회
	    $("#btnSearch").click(function(){
	        loadTableData();
	    });

		$("#kParkingGovCode").change(function() {
			loadComboData();
		});

		$("#kParkingNo, #kAreaName, #kConfirmYn, #kApplyDate, #kMemberName").change(function() {
			loadTableData();
		});
		
		$("#kConfirmYn").change(function(){
	 		viewGubn();
	 	});

		loadComboData();
	    
	    viewGubn();
	});

</script>

<div class="page-body" style="font-size: 0.9em;">
	<div class="row">
		<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12"
			id="search_all_wrapper">
			<card:open title="검색조건" />
			<card:button>
				<form:button type="Search" id="btnSearch" />
				<form:button type="Excel" id="btnExcel" />
				<form:button type="New" id="btnNew" />
			</card:button>
			<card:content />
			<div class="search-area col-lg-12">
				<form id="frmMain" name="frmMain" method="post" onsubmit="return false" class="form-material form-inline">
					<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12">
						<form:select id="kConfirmYn" caption="처리여부" all="true" allLabel="전체" queryId="#CONFIRM_YN" value="N"/>
						<c:choose>
							<c:when test="${fn:contains(user_role_id, 'MANAGE') || fn:contains(user_role_id, 'AD')}">
								<form:select id="kParkingGovCode" caption="관리기관" all="true" allLabel="전체" queryId="select.select_parkingGovInfo"/>
								<form:select id="kParkingNo" caption="주차장" all="true" allLabel="전체" queryId="select.select_parkingInfo"/>
							</c:when>
							<c:otherwise>
								<form:select id="kParkingGovCode" caption="관리기관" all="false" allLabel="전체" queryId="select.select_parkingGovInfo"/>
								<form:select id="kParkingNo" caption="주차장" all="true" allLabel="전체" queryId="select.select_parkingInfo"/>
							</c:otherwise>
						</c:choose>
						
						<form:input id="kAreaName" caption="장소명" addAttr="maxlength='20'" />
						<form:input id="kMemberName" caption="주차권관리자명" addAttr="maxlength='110'" />
						<form:input id="kApplyDate" caption="신청일자" addAttr="maxlength='100'" />
					</div>
				</form>
			</div>
			<card:close />
		</div>
		<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12">
			<card:open title="할인권 장소 신청 목록" />
			<card:toolButton title="">
			</card:toolButton>
			<card:content />
			<form:grid id="myGrid" />
			<card:close />
		</div>
	</div>
</div>
<%@ include file="../../core/include/footer.jsp"%>