<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="form" uri="http://ad.its.yeongju.kr/jsp/jstl/form"%>
<%@ taglib prefix="card" uri="http://ad.its.yeongju.kr/jsp/jstl/card"%>
<%@ taglib prefix="func" uri="http://ad.its.yeongju.kr/jsp/jstl/func"%>
<%@ taglib prefix="label" uri="http://ad.its.yeongju.kr/jsp/jstl/label"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%@ include file="../../core/include/head.jsp"%>
<%@ include file="../../core/include/header.jsp"%>

<script type="text/javascript">
	//데이터 복원 시 사용할 원본 데이터 변수
	var _originData, _originData2;
	
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
		setColumn(["parkingNo", "parkingNo", "center", 100], [], true),
		setColumn(["no", "번호", "center", 40], [false, ["index", "asc"]]),
		setColumn(["parkingName", "주차장명", "left", 100]),
		setColumn(["pGovName", "관리기관", "left", 100]),
		setColumn(["pCompName", "관리회사", "left", 100]),
		setColumn(["parkingAddr", "주소", "left", 160])
	];

	var columnDefs2 = [
		setColumn(["no", "번호", "center", 50], [false, ["index", "asc"]]),
		setColumn(["payYear", "연도", "center", 100]),
		setColumn(["payMonth", "월", "center", 100]),
		setColumn(["payCnt", "이용건수", "right", 100]),
		setColumn(["payPrice", "금액", "right", 100])

	];

	var _gridHelper = new initGrid(columnDefs, true);
	var gridOptions = _gridHelper.setGridOption();

	var _gridHelper2 = new initGrid(columnDefs2, true);
	var gridOptions2 = _gridHelper2.setGridOption();

	_gridHelper.addRowClickEvent(gridRowClickEvent);

	function loadTableData() {
		var frm = $("#frmMain");
		//---- 그리드 조회 시 필수요소 start
		frm.addParam("result", $("#myGrid"));	   // 그리드 태그
		frm.addParam("grid", "gridOptions");		// 그리드 옵션
		frm.addParam("baseData", "_originData");	// 그리드 원본 데이터 저장 변수
		//---- 그리드 조회 시 필수요소 end
		frm.addParam("func", "IQ");
		frm.addParam("kParkingCompCode", $("#kParkingCompCode").val()); 
		frm.addParam("query_id", "status.salesStatus.select_parkingInfo");
		frm.addParam("dataType", "json");		   // 그리드 불러오는 타입 (기본 json)
		frm.request();
	}

	function handleIQ(data, textStatus, jqXHR) {
		_gridHelper2.clearData();
	}

	function loadTableData2() {
		const data = _gridHelper.getSelectedData();
		const frm = $("#frmMain");

		//---- 그리드 조회 시 필수요소 start
		frm.addParam("result", $("#myGrid2"));	   // 그리드 태그
		frm.addParam("grid", "gridOptions2");		// 그리드 옵션
		frm.addParam("baseData", "_originData2");	// 그리드 원본 데이터 저장 변수
		//---- 그리드 조회 시 필수요소 end
		frm.addParam("func", "IQ2");
		frm.addParam("query_id", "stast.salesStatus.select_salesInfo");
		frm.addParam("dataType", "json");		   // 그리드 불러오는 타입 (기본 json)

		frm.addParam("hParkingNo", data.parkingNo);

		frm.request();
	}

	function handleIQ2(data, textStatus, jqXHR) {}

	// 접속 일자 클릭 이벤트 발생시 수행할 함수
	function gridRowClickEvent(event) {
    	$("#hParkingNo").val(event.data.parkingNo);
		loadTableData2();
	}
	
	function loadComboData() {
		var frm = $("#frmMain");
		frm.addParam("func", "IQCombo");
		frm.addParam("kParkingGovCode", $("#kParkingGovCode").val());
		frm.addParam("kParkingCompCode", $("#kParkingCompCode").val());
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
		var eGridDiv2 = document.querySelector('#myGrid2');

		// create the grid passing in the div to use together with the columns & data we want to use
		new agGrid.Grid(eGridDiv, gridOptions);
		new agGrid.Grid(eGridDiv2, gridOptions2);

		// 조회
		$("#btnSearch").click(function() {
			loadTableData();
		});

		//년도
		$("#kUseYear").initDateSingle("year");
		
		$("#kParkingGovCode, #kParkingCompCode").change(function() {
			loadComboData();
		});

		$("#kParkingNo,#kUseYear,#kUseMonth, #kCarNumber").change(function() {
			loadTableData();
		});
		
		loadComboData();
		loadTableData();
		loadTableData2();
	});
</script>


<div class="page-body" style="font-size: 0.9em;">
	<div class="row">
		<div class="col-12" id="search_all_wrapper">
			<card:open title="검색 조건" />
				<card:button>
					<form:button type="Search" id="btnSearch" />
				</card:button>
				<card:content />
				<div class="search-area col-lg-12" >
					<form id="frmMain" name="frmMain" method="post" onsubmit="return false" class="form-material form-inline">
						<form:input type="hidden" id="hParkingNo" />
						<c:choose>  
							<c:when test="${fn:contains(user_role_id, 'MANAGE') || fn:contains(user_role_id, 'AD')}"> 
								<form:select id="kParkingGovCode" caption="관리기관" all="true" allLabel="전체" queryId="select.select_parkingGovInfo"/>
								<form:select id="kParkingCompCode" caption="관리회사" all="true" allLabel="전체" queryId="select.select_parkingCompInfo"/>
								<form:select id="kParkingNo" caption="주차장" all="true" allLabel="전체" queryId="select.select_parkingInfo"/>
							</c:when> 
							<c:otherwise> 
								<form:select id="kParkingGovCode" caption="관리기관" all="false" allLabel="전체" queryId="select.select_parkingGovInfo"/>
								<form:select id="kParkingCompCode" caption="관리회사" all="false" allLabel="전체" queryId="select.select_parkingCompInfo"/>
								<form:select id="kParkingNo" caption="주차장" all="true" allLabel="전체" queryId="select.select_parkingInfo"/>
							</c:otherwise>
						</c:choose>
						<form:input id="kUseYear" caption="연도" />
						<form:select id="kUseMonth" caption="월" all="true" allLabel="전체" queryId="#month"  />
					</form>
				</div>
			<card:close />
		</div>
		<div class="col-xl-8 col-lg-8 col-md-8 col-sm-12 col-12">
			<card:open title="주차장 정보 목록" />
				<card:toolButton title="">
				</card:toolButton>
				<card:content />
				<form:grid id="myGrid" />
			<card:close />
		</div>
		<div class="col-xl-4 col-lg-4 col-md-4 col-sm-12 col-12">
			<card:open title="매출 정보" />
				<card:toolButton title="">
				</card:toolButton>
				<card:content />
				<form:grid id="myGrid2"/>
			<card:close />
		</div>
	</div>
</div>

<%@ include file="../../core/include/footer.jsp"%>
