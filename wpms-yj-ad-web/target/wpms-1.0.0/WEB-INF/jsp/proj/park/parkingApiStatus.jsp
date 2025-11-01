<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="form" uri="http://ad.its.yeongju.kr/jsp/jstl/form"%>
<%@ taglib prefix="card" uri="http://ad.its.yeongju.kr/jsp/jstl/card"%>
<%@ taglib prefix="func" uri="http://ad.its.yeongju.kr/jsp/jstl/func"%>
<%@ taglib prefix="label" uri="http://ad.its.yeongju.kr/jsp/jstl/label" %>

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
	 		setColumn(["number", "번호", "center", 50], [false, ["index", "asc"]]),
			setColumn(["resultGubn", "결과여부", "center", 80]),
			setColumn(["mdfcnDt", "요청일시", "center", 130]),
			setColumn(["receiveDt", "수신일시", "center", 130]),
			setColumn(["regDt", "등록일시", "center", 130]),
			setColumn(["resultCode", "결과코드", "center", 80]),
			setColumn(["resultMsg", "결과메세지", "left", 130]),
			setColumn(["providedName", "요청처", "left", 120]),
			setColumn(["serviceKey", "인증키", "left", 300]),
			setColumn(["apiCode", "호출코드", "center", 80]),
			setColumn(["parkingNo", "주차장코드", "center", 120]),
	];    
           
    var _gridHelper = new initGrid(columnDefs, true);
    var gridOptions = _gridHelper.setGridOption();

	function loadTableData() {
		var frm = $("#frmMain");
		frm.serializeArrayCustom();
		
		//---- 그리드 조회 시 필수요소 start
		frm.addParam("result", $("#myGrid")); // 그리드 태그
		frm.addParam("grid", "gridOptions"); // 그리드 옵션
		frm.addParam("baseData", "_originData"); // 그리드 원본 데이터 저장 변수
		//---- 그리드 조회 시 필수요소 end
		frm.addParam("func", "IQ");
		frm.addParam("kRegDt", $("#kRegDt").val());
		frm.addParam("query_id", "park.parkingApiStatus.select_List");
		frm.addParam("dataType", "json"); // 그리드 불러오는 타입 (기본 json)
		
		frm.addParam("startDate", moment(replaceDate($("#kRegDt").val())[0]).format('YYYYMMDD'));
		frm.addParam("endDate", moment(replaceDate($("#kRegDt").val())[1]).format('YYYYMMDD'));
		
		frm.request();
	}

	function handleIQ(data, textStatus, jqXHR) {}


	$(function() {

		// lookup the container we want the Grid to use
		var eGridDiv = document.querySelector('#myGrid');

		// create the grid passing in the div to use together with the columns & data we want to use
		new agGrid.Grid(eGridDiv, gridOptions);
		
		$("#kRegDt").initDateOnly("month", -1, "month", 0);
		
		// frmMain 자동조회
		$("#frmMain").autoSearch(loadTableData);

		// 조회
		$("#btnSearch").click(function() {
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
					<form:input id="kRegDt" caption="등록일자"/>
					<form:select id="kResultGubn" caption="결과여부" all="true" allLabel="전체" queryId="#api_result_gubn" />
					<form:input id="kProvidedName" caption="요청처" addAttr="maxlength='20';"/>
				</form>
			</div>
			<card:close />
		</div> 
		<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12">
			<card:open title="주차장 정보 제공 API 현황" />
			<card:toolButton title="">
			</card:toolButton>
			<card:content />
			<form:grid id="myGrid" />
			<card:close />
		</div>
	</div>
</div>

<%@ include file="../../core/include/footer.jsp"%>
