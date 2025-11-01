<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="form" uri="http://ad.its.yeongju.kr/jsp/jstl/form"%>
<%@ taglib prefix="card" uri="http://ad.its.yeongju.kr/jsp/jstl/card"%>
<%@ taglib prefix="func" uri="http://ad.its.yeongju.kr/jsp/jstl/func"%>
<%@ taglib prefix="label" uri="http://ad.its.yeongju.kr/jsp/jstl/label" %>

<%@ include file="../../core/include/head.jsp"%>
<%@ include file="../../core/include/header.jsp"%>

<style type="text/css">

.col-3 .card-block {
    align-content: center;
}

.col-3 .card-block p {
    font-size: 15px;
}

</style>

<script type="text/javascript">
	// 데이터 복원 시 사용할 원본 데이터 변수
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
	 		setColumn(["number", "번호", "center", 50], [false, ["index", "asc"]]),
	 		setColumn(["parkingNo", "parkingNo", "center", 110],[],true),
	 		setColumn(["parkingAreaCode", "주차장인증코드", "center", 110]),
	 		setColumn(["pGovName", "관리기관", "center", 190]),
	 		setColumn(["pCompName", "관리회사", "center", 100]),
	 		setColumn(["enterStatus", "입차 API 상태", "center", 100]),
	 		setColumn(["outStatus", "출차 API 상태", "center", 100]),
	 		setColumn(["enterResultCode", "입차API 결과", "center", 100]),
	 		setColumn(["enterReceiveDt", "입차API 수신일시", "center", 125]),
	 		setColumn(["enterCarNo", "차량번호", "center", 100]),
	 		setColumn(["outResultCode", "출차API 결과", "center", 100]),
	 		setColumn(["outReceiveDt", "출차API 수신일시", "center", 125]),
	 		setColumn(["outCarNo", "차량번호", "center", 100]),
	];
	
	setColumnMask(columnDefs, "enterReceiveDt", "datetime");
	setColumnMask(columnDefs, "outReceiveDt", "datetime");
	
	for(var x=0; x<4; x++){
    	columnDefs[x].pinned = "left";
    }
           
    var _gridHelper = new initGrid(columnDefs, true);
    var gridOptions = _gridHelper.setGridOption();
    _gridHelper.addRowClickEvent(gridRowClickEvent);
    
	function gridRowClickEvent(event) {
    	$("#hParkingNo").val(event.data.parkingNo);
		loadTableData2();
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
		frm.addParam("query_id", "park.apiStatus.select_List");
		frm.addParam("dataType", "json"); // 그리드 불러오는 타입 (기본 json)
		frm.request();
	}

	function handleIQ(data, textStatus, jqXHR) {
		$("#enterReceiveDt, #enterTimeDiff, #outReceiveDt, #outTimeDiff").text("");
		$(".col-3 .card-block").height($(".col-9 .card-block").height()/2 - 50);
	}
	
	
	function loadTableData2() {
		var frm = $("#frmMain");
		frm.addParam("func", "IQ2");
		frm.addParam("query_id", "park.apiStatus.select_lastReceive");
		frm.addParam("dataType", "json"); // 그리드 불러오는 타입 (기본 json)
		frm.request();
	}

	function handleIQ2(data, textStatus, jqXHR) {
		if(data.length > 0){
			$("#enterReceiveDt").text(data[0].enterReceiveDt);
			$("#enterTimeDiff").text(data[0].enterTimeDiff);
			$("#outReceiveDt").text(data[0].outReceiveDt);
			$("#outTimeDiff").text(data[0].outTimeDiff);
			
		} else {
			$("#enterReceiveDt, #enterTimeDiff, #outReceiveDt, #outTimeDiff").text("");
		}
	}


	$(function() {

		// lookup the container we want the Grid to use
		var eGridDiv = document.querySelector('#myGrid');

		// create the grid passing in the div to use together with the columns & data we want to use
		new agGrid.Grid(eGridDiv, gridOptions);

		// 조회
		$("#btnSearch").click(function() {
			loadTableData();
		});
		
		// 조회
		$("#kParkingNo").change(function() {
			loadTableData();
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
					<form:select id="kParkingNo" caption="주차장 인증코드" all="true" allLabel="전체" queryId="park.apiStatus.select_parkInfo"/>
					<form:input id="hParkingNo" type="hidden"/>
				</form>
			</div>
			<card:close />
		</div> 
		<div class="col-xl-9 col-lg-9 col-md-9 col-sm-9 col-9">
			<card:open title="API 상태 현황" />
			<card:toolButton title="">
			</card:toolButton>
			<card:content />
			<form:grid id="myGrid" />
			<card:close />
		</div>
		<div class="col-xl-3 col-lg-3 col-md-3 col-sm-3 col-3">
		
			<card:open title="입차 API" />
			<card:toolButton title="">
			</card:toolButton>
			<card:content />
				<p>마지막 수신일시 : <span id="enterReceiveDt"></span></p>
				<p>미수신 시간&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; : <span id="enterTimeDiff"></span></p>
			<card:close />
			
			<card:open title="출차 API" />
			<card:toolButton title="">
			</card:toolButton>
			<card:content />
				<p>마지막 수신일시 : <span id="outReceiveDt"></span></p>
				<p>미수신 시간&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; : <span id="outTimeDiff"></span></p>
			<card:close />
		</div>
		
	</div>
</div>

<%@ include file="../../core/include/footer.jsp"%>
