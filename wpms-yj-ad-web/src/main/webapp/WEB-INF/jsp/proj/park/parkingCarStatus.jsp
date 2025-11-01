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
			setColumn(["no", "번호", "center", 50], [false, ["index", "asc"]]),
			setColumn(["parkingName", "주차장명", "left", 130 ]),
			setColumn(["address", "주소", "left", 330 ]),
			setColumn(["parkingSpotNow", "현재면수", "center", 80 ]),
			setColumn(["parkingSpot", "전체면수", "center", 80 ])
	];

	setColumnMask(columnDefs, "parkingSpotNow", "number");
	setColumnMask(columnDefs, "parkingSpot", "number");
	
    var _gridHelper = new initGrid(columnDefs, true);
    var gridOptions = _gridHelper.setGridOption();
    _gridHelper.addRowClickEvent(gridRowClickEvent);

	function gridRowClickEvent(event) {
		$("#hParkingNo").val(event.data.parkingNo);
		loadTableData2();
	}

	// 컬럼 옵션
	var columnDefs2 = [
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
			setColumn(["carNo", "차량번호", "center", 120 ]),
			setColumn(["memberName", "이름", "center", 110 ]),
			setColumn(["pEntDt", "입차일시", "center", 150 ]),
			setColumn(["pOutDt", "출차일시", "center", 150 ]),
			setColumn(["parkingStatus", "주차상태", "center", 70 ]),

	];

	setColumnMask(columnDefs2, "pEntDt", "datetime");
	setColumnMask(columnDefs2, "pOutDt", "datetime");

    var _gridHelper2 = new initGrid(columnDefs2, true);
    var gridOptions2 = _gridHelper2.setGridOption();

	function loadTableData() {
		var frm = $("#frmMain");
		frm.serializeArrayCustom();
		//---- 그리드 조회 시 필수요소 start
		frm.addParam("result", $("#myGrid")); // 그리드 태그
		frm.addParam("grid", "gridOptions"); // 그리드 옵션
		frm.addParam("baseData", "_originData"); // 그리드 원본 데이터 저장 변수
		//---- 그리드 조회 시 필수요소 end
		frm.addParam("func", "IQ");
		frm.addParam("queryId", "park.parkingCarStatus.select_parkList");
		frm.addParam("dataType", "json"); // 그리드 불러오는 타입 (기본 json)
		frm.request();
	}

	function handleIQ(data, textStatus, jqXHR) {
		_gridHelper2.clearData();
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

	function loadTableData2() {
		var frm = $("#frmMain");
		//---- 그리드 조회 시 필수요소 start
		frm.addParam("result", $("#myGrid2"));	   // 그리드 태그
		frm.addParam("grid", "gridOptions2");		// 그리드 옵션
		frm.addParam("baseData", "_originData2");	// 그리드 원본 데이터 저장 변수
		//---- 그리드 조회 시 필수요소 end
		frm.addParam("func", "IQ2");
		frm.addParam("queryId", "park.parkingCarStatus.select_parkStatusList");
		frm.addParam("dataType", "json");		   // 그리드 불러오는 타입 (기본 json)
		frm.addParam("kEntryDate", $("#kEntryDate").val());
		frm.request();
	}

	function handleIQ2(data, textStatus, jqXHR) {
		gridOptions2.api.sizeColumnsToFit();
	}

	function downExcelData() {
		var frm = $("#frmMain");
		
		frm.addInput("func", "IQ_Excel");
		frm.addInput("query_id", "park.parkingCarStatus.select_parkStatusExcel");
		frm.addInput("type", "parkingCarStatus");
		frm.setAction("<c:url value='/common_excel.do'/>");
		frm.removeAttr("onsubmit");
		frm.submit();
		frm.attr("action", "<c:url value='/common_select.do' />");
        frm.attr("onsubmit", "return false");
        $("#frmMain > input[name='query_id']").remove();
	}
	
	function handleIQ_Excel(data, textStatus, jqXHR) {}
	
	$(function() {
		//일자
		$("#kEntryDate").initDateOnly("month", 0);

		// lookup the container we want the Grid to use
		var eGridDiv = document.querySelector('#myGrid');
		var eGridDiv2 = document.querySelector('#myGrid2');

		// create the grid passing in the div to use together with the columns & data we want to use
		new agGrid.Grid(eGridDiv, gridOptions);
		new agGrid.Grid(eGridDiv2, gridOptions2);
		
		_gridHelper2.clearData(eGridDiv2);
		
		// frmMain 자동조회
		// $("#frmMain").autoSearch(loadTableData);

		// 입차일자 변경시
		$("#kEntryDate").change(function(){
			loadTableData2();
		});

		// 주차상태 변경시
		$("#kSearchGubn").change(function(){
			loadTableData2();
		});
		
		// 조회조건 변경 시
		$("#kMemberYn").change(function(){
			loadTableData2();
		});

		// 조회
		$("#btnSearch").click(function() {
			loadTableData();
		});

		$("#kParkingGovCode").change(function() {
			loadComboData();
		});

		$("#kParkingNo").change(function() {
			loadTableData();
		});

	 	// 다운로드
		$("#btnExcel").click(function(){
			if($("#hParkingNo").val() == ""){
				alert("주차장 정보 목록에서 주차장을 선택해주세요");
				return false;
			}else{
				if(_gridHelper2.getAllGridData().length < 1) {
					alert("조회된 데이터가 없습니다.");
					return false;
				}
				downExcelData();				
			}
		});

		loadComboData();
		
	});
</script>


<div class="page-body" style="font-size: 0.9em;">
	<div class="row">
		<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12" id="search_all_wrapper">
			<card:open title="검색 조건" />
			<card:button>
				<form:button type="Search" id="btnSearch" />
				<form:button type="Excel" id="btnExcel" />
			</card:button>
			<card:content />
			<div class="search-area col-lg-12">
				<form id="frmMain" name="frmMain" method="post" onsubmit="return false" class="form-material form-inline">
					<form:input type="hidden" caption="hParkingNo" id="hParkingNo"/>
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
					<form:input id="kEntryDate" caption="입차일자" addAttr="maxlength='100'" />
					<form:select id="kSearchGubn" caption="주차상태" all="true" allLabel="전체" queryId="#parking_status" />
					<form:select id="kMemberYn" caption="회원여부" all="true" allLabel="전체" queryId="#MEMBER_YN"/>
				</form>
			</div>
			<card:close />
		</div>
		<div class="col-xl-6 col-lg-6 col-md-6 col-sm-12 col-12">
			<card:open title="주차장 정보 목록" />
			<card:toolButton title="">
			</card:toolButton>
			<card:content />
			<form:grid id="myGrid" />
			<card:close />
		</div>
		<div class="col-xl-6 col-lg-6 col-md-6 col-sm-12 col-12">
			<card:open title="주차장별 주차 현황" />
			<card:toolButton title="">
			</card:toolButton>
			<card:content />
			<form:grid id="myGrid2" />
			<card:close />
		</div>
	</div>
</div>

<%@ include file="../../core/include/footer.jsp"%>
