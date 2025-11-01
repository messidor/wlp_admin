<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="form" uri="http://ad.its.yeongju.kr/jsp/jstl/form" %>
<%@ taglib prefix="card" uri="http://ad.its.yeongju.kr/jsp/jstl/card" %>
<%@ taglib prefix="func" uri="http://ad.its.yeongju.kr/jsp/jstl/func" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%@ include file="../../core/include/head.jsp" %>
<%@ include file="../../core/include/header.jsp" %>

<link rel="stylesheet" href="<c:url value='/common/css/sumoselect/sumoselect-custom.css'/>" />
<script type="text/javascript" src="<c:url value='/common/js/sumoselect/jquery.sumoselect.js'/>"></script>
<script type="text/javascript">

	var _originData;
	var pStartDate = "";
	var pFinishDate = "";
	var dateChangeGubn = false;

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
		setColumn(["elecApplyCode", "elecApplyCode"], [], true),
		setColumn(["memberId", "memberId"], [], true),
		setColumn(["cancelGubn", "cancelGubn"], [], true),
		setColumn(["applyDt", "신청일시", "center", 120]),
		setColumn(["parkingName", "주차장", "left", 200]),
		setColumn(["carNo", "차량번호", "center", 100]),
		setColumn(["electDate", "충전일시", "center", 120]),
		setColumn(["cancelGubnName", "취소구분", "center", 80]),
		setColumn(["cancelName", "취소자", "center", 80]),
		setColumn(["cancelDt", "취소일시", "center", 120]),
		setColumn(["popDetail", "상세보기", "center", 80], [grdPopDetail, ["button", null, "link", "상세보기", ""]]),
		setColumn(["popCancel", "취소", "center", 80], [grdPopCancel, ["button", null, "link", "text", ""]]),
		
	];

	// setColumnMask(컬럼옵션변수, 컬럼명, 타입, 추가옵션)
	setColumnMask(columnDefs, "applyDt", "datetime");
	setColumnMask(columnDefs, "electDate", "datetime");
	setColumnMask(columnDefs, "cancelDt", "datetime");

	// 그리드 옵션
	// 컬럼정의 / 화면에 그리드 맞추기 / 행추가 func
	var _gridHelper = new initGrid(columnDefs, true);
	var gridOptions = _gridHelper.setGridOption();
	
// 	_gridHelper.addRowDblClickEvent(gridRowClickEvent);
	
	// 그리드 클릭 이벤트 내용
// 	function gridRowClickEvent(event) {
//  		OpenPopupSingle("/pay/cancelElecReductionPopup.do?elecApplyCode="+ event.data.elecApplyCode + "&memberId=" + event.data.memberId + "&carNo=" + event.data.carNo, 950, 690, "_PopElec");	
// 	} 

	function grdPopCancel(e, data) {
		if(data.popCancel != null){
			OpenPopupSingle("/pay/cancelElecReductionPopup.do?elecApplyCode="+ data.elecApplyCode + "&memberId=" + data.memberId + "&carNo=" + data.carNo + "&type=C", 950, 660, "_PopElec1");	
		}
	}
	
	function grdPopDetail(e, data) {
		OpenPopupSingle("/pay/cancelElecReductionPopup.do?elecApplyCode="+ data.elecApplyCode + "&memberId=" + data.memberId + "&carNo=" + data.carNo + "&type=D" + "&cancelGubn=" + data.cancelGubn, 950, 660, "_PopElec2");	
	}

	
	function loadTableData() {
		var frm = $("#frmMain");
	    //---- 그리드 조회 시 필수요소 start
	    frm.addParam("result", $("#myGrid"));       // 그리드 태그
	    frm.addParam("grid", "gridOptions");        // 그리드 옵션
	    frm.addParam("baseData", "_originData");    // 그리드 원본 데이터 저장 변수
	    //---- 그리드 조회 시 필수요소 end
	    frm.addParam("func", "IQ");
		frm.addParam("query_id", "pay.cancelElecReduction.Select_List");
	    frm.addParam("dataType", "json");           // 그리드 불러오는 타입 (기본 json)
		frm.addParam("startDate", moment(replaceDate($("#kSearchDate").val())[0]).format('YYYY-MM-DD'));
		frm.addParam("endDate", moment(replaceDate($("#kSearchDate").val())[1]).format('YYYY-MM-DD'));
		frm.request();
	}

	function handleIQ(data, textStatus, jqXHR) {
		if(data.length > 0){}
	}

	function loadComboData() {
		var frm = $("#frmMain");
		frm.addParam("func", "IQCombo");
		frm.addParam("kParkingGovCode", $("#kParkingGovCode").val());
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
		
	  	//일자
		$("#kSearchDate").initDateOnly("month", -1, "month", 0);
	  
	 	// frmMain 자동조회
	    // $("#frmMain").autoSearch(loadTableData);

	 	// 조회
	    $("#btnSearch").click(function(){
	        loadTableData();
	    });

		$("#kParkingGovCode").change(function() {
			loadComboData();
		});

		$("#kSearchDate, #kParkingNo, #kCarNumber, #kConfirmGubn, #kCancelGubn").change(function() {
			loadTableData();
		});

		
	    var kSearchDate = $("#kSearchDate").val();
		// 초기 날짜 세팅
		pStartDate = moment(replaceDate($("#kSearchDate").val())[0]).format('YYYY-MM-DD');
		pFinishDate = moment(replaceDate($("#kSearchDate").val())[1]).format('YYYY-MM-DD');


		// 데이터 불러오기
        loadComboData();
	});

</script>

<div class="page-body" style="font-size: 0.9em;">
	<div class="row">
		<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12"
			id="search_all_wrapper">
			<card:open title="검색조건" />
			<card:button>
				<form:button type="Search" id="btnSearch" />
			</card:button>
			<card:headerContent />
			<div class="search-area col-lg-12">
				<form id="frmMain" name="frmMain" method="post" onsubmit="return false" class="form-material form-inline">
					<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12">
						<form:input id="kSearchDate" caption="신청일시" addAttr="maxlength='100'" />
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
						<form:input id="kCarNumber" caption="차량번호" addAttr="maxlength='20'" />
						<form:select id="kCancelGubn" caption="취소구분" all="true" allLabel="전체" queryId="#CANCEL_GUBN" value="N"/>
					</div>
				</form>
			</div>
			<card:close />
		</div>
		<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12">
			<card:open title="전기차 충전 할인 내역" />
			<card:toolButton title="">
			</card:toolButton>
			<card:content />
			<form:grid id="myGrid" />
			<card:close />
		</div>
	</div>
</div>
<%@ include file="../../core/include/footer.jsp"%>