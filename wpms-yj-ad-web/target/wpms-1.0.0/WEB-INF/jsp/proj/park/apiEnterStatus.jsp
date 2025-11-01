<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="form" uri="http://ad.its.yeongju.kr/jsp/jstl/form"%>
<%@ taglib prefix="card" uri="http://ad.its.yeongju.kr/jsp/jstl/card"%>
<%@ taglib prefix="func" uri="http://ad.its.yeongju.kr/jsp/jstl/func"%>
<%@ taglib prefix="label" uri="http://ad.its.yeongju.kr/jsp/jstl/label" %>

<%@ include file="../../core/include/head.jsp"%>
<%@ include file="../../core/include/header.jsp"%>

<script type="text/javascript">
	// 데이터 복원 시 사용할 원본 데이터 변수
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
 			
	 		setColumn(["number", "번호", "center", 50], [false, ["index", "asc"]]),
			setColumn(["enterApiCode", "enterApiCode", "center", 130], [], true),
			setColumn(["resultGubn", "결과여부", "center", 80]),
			setColumn(["enterDt", "입차일시", "center", 130]),
			setColumn(["receiveDt", "수신일시", "center", 130]),
			setColumn(["mdfcnDt", "처리시작일시", "center", 130]),
			setColumn(["regDt", "등록일시", "center", 130]),
			setColumn(["resultCode", "결과코드", "center", 80]),
			setColumn(["resultMsg", "결과메세지", "left", 130]),
			setColumn(["errMsg", "에러메세지", "left", 130]),
			setColumn(["serviceKey", "인증키", "left", 300]),
			setColumn(["parkingAreaCode", "주차장인증코드", "center", 125]),
			setColumn(["carNumberRecv", "차량번호", "center", 120]),
		    setColumn(["walletFreeYn", "사전등록여부", "center", 100]),
		    setColumn(["reduceCode", "감면코드", "center", 90]),
		    setColumn(["reduceNm", "감면종류", "center", 130]),
		    setColumn(["reduceRate", "감면비율", "center", 90])
	];         
	 
    var _gridHelper = new initGrid(columnDefs, true);
    var gridOptions = _gridHelper.setGridOption();
    gridOptions.pagination = true;

	function loadTableData() {
		var frm = $("#frmMain");
		frm.serializeArrayCustom();
		
		var kSearchDate = $("#regDt").val();
		
		//---- 그리드 조회 시 필수요소 start
		frm.addParam("result", $("#myGrid")); // 그리드 태그
		frm.addParam("grid", "gridOptions"); // 그리드 옵션
		frm.addParam("baseData", "_originData"); // 그리드 원본 데이터 저장 변수
		//---- 그리드 조회 시 필수요소 end
		frm.addParam("func", "IQ");
		frm.addParam("regDt", kSearchDate);
		frm.addParam("query_id", "park.apiEnterStatus.select_List");
		frm.addParam("dataType", "json"); // 그리드 불러오는 타입 (기본 json)
		frm.request();
	}

	function handleIQ(data, textStatus, jqXHR) {}


	$(function() {

		// lookup the container we want the Grid to use
		var eGridDiv = document.querySelector('#myGrid');

		// create the grid passing in the div to use together with the columns & data we want to use
		new agGrid.Grid(eGridDiv, gridOptions);
		
		$("#regDt").initDateSingle("days");
		
		//$("#regDt").initDateOnly("days", 0, "days", 0);
		 
		// frmMain 자동조회
		$("#frmMain").autoSearch(loadTableData);

		// 조회
		$("#btnSearch").click(function() {
			loadTableData();
		});
		
		// 조회
		$("#regDt").change(function() {
			loadTableData();
		});
		
// 		$("#ServiceKey").on("keyup",function(key){
// 	        if(key.keyCode==13) {
// 	            if($("#ServiceKey").val() == ""){
// 	            	loadTableData();
// 	            }
// 	        }
// 	    });
		
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
					<form:input id="regDt" caption="등록일자"/>
					<form:input id="carNumber" caption="차량번호" addAttr="maxlength='10'" />
					<form:select id="kResultGubn" caption="결과여부" all="true" allLabel="전체" queryId="#api_result_gubn" />
					<form:select id="kParkingNo" caption="주차장 인증코드" all="true" allLabel="전체" queryId="park.apiEnterStatus.select_parkInfo"/>
					<form:input id="kServiceKey" caption="인증키"/>
				</form>
			</div>
			<card:close />
		</div>
		<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12">
			<card:open title="입차 API 현황" />
			<card:toolButton title="">
			</card:toolButton>
			<card:content />
			<form:grid id="myGrid" />
			<card:close />
		</div>
	</div>
</div>

<%@ include file="../../core/include/footer.jsp"%>
