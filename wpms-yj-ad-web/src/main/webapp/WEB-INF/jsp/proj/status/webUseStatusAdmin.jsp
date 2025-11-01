<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="form" uri="http://ad.its.yeongju.kr/jsp/jstl/form"%>
<%@ taglib prefix="card" uri="http://ad.its.yeongju.kr/jsp/jstl/card"%>
<%@ taglib prefix="func" uri="http://ad.its.yeongju.kr/jsp/jstl/func"%>
<%@ taglib prefix="label" uri="http://ad.its.yeongju.kr/jsp/jstl/label"%>

<%@ include file="../../core/include/head.jsp"%>
<%@ include file="../../core/include/header.jsp"%>

<script type="text/javascript">
	//데이터 복원 시 사용할 원본 데이터 변수
	var _originData, _originData2, _originData3;
	
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
		setColumn(["no", "번호", "center", 60], [false, ["index", "asc"]]),
		setColumn(["loginDt", "일자", "center", 100]),
		setColumn(["logCnt", "접속횟수", "right", 100])
	];
	setColumnMask(columnDefs, "loginDt", "date");
	
	var columnDefs2 = [
		setColumn(["memberId", "memberId", "center", 70], [], true),
		setColumn(["no", "번호", "center", 60], [false, ["index", "asc"]]),
		setColumn(["memberName", "사용자명", "center", 100]),
		setColumn(["memberLogCnt", "접속횟수", "right", 70])
	  
	];
	 
	var columnDefs3 = [
		setColumn(["no", "번호", "center", 60], [false, ["index", "asc"]]),
		setColumn(["loginDt", "접속일시", "center", 100]),
		setColumn(["ipAddr", "IP주소", "center", 100]),
		setColumn(["browserName", "Browser", "left", 100])
	];
	setColumnMask(columnDefs3, "loginDt", "datetime");
	
	var _gridHelper = new initGrid(columnDefs, true);
	var gridOptions = _gridHelper.setGridOption();
	
	var _gridHelper2 = new initGrid(columnDefs2, true);
	var gridOptions2 = _gridHelper2.setGridOption();
	
	var _gridHelper3 = new initGrid(columnDefs3, true);
	var gridOptions3 = _gridHelper3.setGridOption();
	
	_gridHelper.addRowClickEvent(gridRowClickEvent);
	_gridHelper2.addRowClickEvent(gridRowClickEvent2);
		
	function loadTableData() {
		var frm = $("#frmMain");
		//---- 그리드 조회 시 필수요소 start
		frm.addParam("result", $("#myGrid"));	   // 그리드 태그
		frm.addParam("grid", "gridOptions");		// 그리드 옵션
		frm.addParam("baseData", "_originData");	// 그리드 원본 데이터 저장 변수
		//---- 그리드 조회 시 필수요소 end
		frm.addParam("func", "IQ");
		frm.addInput("query_id", "status.webUseStatusAdmin.select_loginDate");
		frm.addParam("dataType", "json");		   // 그리드 불러오는 타입 (기본 json)
		frm.addParam("startDate", moment(replaceDate($("#kEntryDate").val())[0]).format('YYYY-MM-DD'));
		frm.addParam("endDate", moment(replaceDate($("#kEntryDate").val())[1]).format('YYYY-MM-DD'));
		frm.request();
	}

	function handleIQ(data, textStatus, jqXHR) {}
	
	function loadTableData2() {
		const data = _gridHelper.getSelectedData();
		const frm = $("#frmMain");
		
		//---- 그리드 조회 시 필수요소 start
		frm.addParam("result", $("#myGrid2"));	   // 그리드 태그
		frm.addParam("grid", "gridOptions2");		// 그리드 옵션
		frm.addParam("baseData", "_originData2");	// 그리드 원본 데이터 저장 변수 
		//---- 그리드 조회 시 필수요소 end
		frm.addParam("func", "IQ2");
		frm.addInput("query_id", "status.webUseStatusAdmin.select_loginUser");
		frm.addParam("dataType", "json");		   // 그리드 불러오는 타입 (기본 json)
		
		frm.addParam("hLoginDt", data.loginDt);
		
		frm.request();
	}

	function handleIQ2(data, textStatus, jqXHR) {
		gridOptions2.api.sizeColumnsToFit();
	}
	
	function loadTableData3() {
		const data = _gridHelper2.getSelectedData();
		const frm = $("#frmMain");
		
		//---- 그리드 조회 시 필수요소 start
		frm.addParam("result", $("#myGrid3"));	   // 그리드 태그
		frm.addParam("grid", "gridOptions3");		// 그리드 옵션
		frm.addParam("baseData", "_originData3");	// 그리드 원본 데이터 저장 변수 
		//---- 그리드 조회 시 필수요소 end
		frm.addParam("func", "IQ3");
		frm.addInput("query_id", "status.webUseStatusAdmin.select_loginBrowser");
		frm.addParam("dataType", "json");		   // 그리드 불러오는 타입 (기본 json)
		
		frm.addParam("hLoginDt", data.loginDate);
		frm.addParam("hMemberId", data.memberId);
		frm.addParam("enc_col", "hMemberId");
		
		frm.request();
	}

	function handleIQ3(data, textStatus, jqXHR) {
		gridOptions3.api.sizeColumnsToFit();
	}
	
	// 접속 일자 클릭 이벤트 발생시 수행할 함수
	function gridRowClickEvent(event) {
    	$("#hLoginDt").val(event.data.loginDt);
		loadTableData2();
	}
	
	// 사용자별 횟수 클릭 이벤트 발생시 수행할 함수
	function gridRowClickEvent2(event) {
    	$("#hLoginDt").val(event.data.loginDate);
    	$("#hMemberId").val(event.data.memberId);
		loadTableData3();
	}
	
	function downExcelData() {
		var frm = $("#frmHidden");
		
		frm.addInput("func", "IQ_Excel");
		frm.addInput("startDate", moment(replaceDate($("#kEntryDate").val())[0]).format('YYYY-MM-DD'));
		frm.addInput("endDate", moment(replaceDate($("#kEntryDate").val())[1]).format('YYYY-MM-DD'));
		frm.addInput("query_id", "status.webUseStatusAdmin.select_loginListExcel");
		frm.addInput("type", "webUseStatusAdmin");
		frm.setAction("<c:url value='/common_excel.do'/>");
		frm.removeAttr("onsubmit");
		frm.submit();
		frm.setAction("<c:url value='/common_select.do'/>");
	}

	function handleIQ_Excel(data, textStatus, jqXHR) {}

	$(function() {
		// lookup the container we want the Grid to use
		var eGridDiv = document.querySelector('#myGrid');
		var eGridDiv2 = document.querySelector('#myGrid2');
		var eGridDiv3 = document.querySelector('#myGrid3');

		// create the grid passing in the div to use together with the columns & data we want to use
		new agGrid.Grid(eGridDiv, gridOptions);
		new agGrid.Grid(eGridDiv2, gridOptions2);
		new agGrid.Grid(eGridDiv3, gridOptions3);

		_gridHelper3.clearData(eGridDiv3);
		_gridHelper2.clearData(eGridDiv2);
		
		// 조회
		$("#btnSearch").click(function() {
			_gridHelper3.clearData(eGridDiv3);
			_gridHelper2.clearData(eGridDiv2);
			loadTableData();
		});
		
		//일자
		$("#kEntryDate").initDateOnly("month", -1, "month", 0);
		
		$("#kEntryDate").on("change", function(e){
			_gridHelper3.clearData(eGridDiv3);
			_gridHelper2.clearData(eGridDiv2);
			loadTableData();
		});
		
		// 다운로드
		$("#btnExcel").click(function(){
			downExcelData();
		});
		
		loadTableData();
	});
</script>


<div class="page-body" style="font-size: 0.9em;">
	<div class="row">
		<div class="col-12" id="search_all_wrapper">
			<card:open title="검색 조건" />
				<card:button>
					<form:button type="Search" id="btnSearch" />
					<form:button type="Excel" id="btnExcel" />
				</card:button>
				<card:content />
				<div class="search-area col-lg-12" >
					<form id="frmMain" name="frmMain" method="post" onsubmit="return false" class="form-material form-inline">
						<form:input type="hidden" id="hLoginDt" />
						<form:input type="hidden" id="hMemberId" />
						<form:input id="kEntryDate" caption="접속일자" addAttr="maxlength='100'" />
					</form>
					<form id="frmHidden" name="frmHidden" method="post" onsubmit="return false" class="form-material form-inline" style="display: none;">
					</form>
				</div>
			<card:close />
		</div> 
		<div class="col-xl-3 col-lg-3 col-md-3 col-sm-12 col-12">
			<card:open title="접속일자" />
				<card:toolButton title="">
				</card:toolButton>
				<card:content />
				<form:grid id="myGrid" />
			<card:close />
		</div>
		<div class="col-xl-3 col-lg-3 col-md-3 col-sm-12 col-12">
			<card:open title="사용자별 횟수" />
				<card:toolButton title="">
				</card:toolButton> 
				<card:content />
				<form:grid id="myGrid2"/>
			<card:close />
		</div>
		<div class="col-xl-6 col-lg-6 col-md-6 col-sm-12 col-12">
			<card:open title="접속 일시" />
				<card:toolButton title="">
				</card:toolButton> 
				<card:content />
				<form:grid id="myGrid3"/>
			<card:close />
		</div>
	</div>
</div>

<%@ include file="../../core/include/footer.jsp"%>
