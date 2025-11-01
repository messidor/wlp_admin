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
			setColumn(["pGovName", "관리기관", "left", 150]),
			setColumn(["parkingName", "주차장명", "left", 150]),
			setColumn(["carNo", "차량번호", "center", 100]),
			setColumn(["memberName", "이름", "center", 100]),
			setColumn(["pEntDt", "입차일시", "center", 150]),
			setColumn(["pOutDt", "출차일시", "center", 150]),
			setColumn(["parkingPrice", "주차요금", "right", 100]),
			setColumn(["payGubnName", "결제여부", "center", 100]),

	];

	setColumnMask(columnDefs, "pEntDt", "datetime");
	setColumnMask(columnDefs, "pOutDt", "datetime");

    var _gridHelper = new initGrid(columnDefs, true);
    var gridOptions = _gridHelper.setGridOption();

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
		
		if(data.length > 0){
			$("#kParkingNo").parent().parent().show();
			$.each(data, function(k, v) {
				$("#kParkingNo").append("<option value='" + v.value + "'>" + v.text + "</option>");			
			});
		}else{
			$("#kParkingNo").parent().parent().show();
		}
		
		loadTableData();
	}

	function loadTableData() {
		var kSearchDate = $("#kEntryDate").val();
		var kSearchArr = kSearchDate.split(" - ");
		
		var startDt = kSearchArr[0];
		var endDt = kSearchArr[1];
		
		var frm = $("#frmMain");
		//---- 그리드 조회 시 필수요소 start
		frm.addParam("result", $("#myGrid"));	   // 그리드 태그
		frm.addParam("grid", "gridOptions");		// 그리드 옵션
		frm.addParam("baseData", "_originData");	// 그리드 원본 데이터 저장 변수
		//---- 그리드 조회 시 필수요소 end
		frm.addParam("func", "IQ");
		frm.addParam("startDt", startDt);
		frm.addParam("endDt", endDt);
		frm.addParam("kParkingGovCode", $("#kParkingGovCode").val());
		frm.addParam("kParkingNo", $("#kParkingNo").val());
		frm.addParam("query_id", "park.parkingCarStatusByNumber.select_parkStatusAllList");
		frm.addParam("dataType", "json");		   // 그리드 불러오는 타입 (기본 json)
		frm.request();
	}

	function handleIQ(data, textStatus, jqXHR) { 
	}    
	
// 	function dateValidation(ev, picker){
// 		var startDate = new Date(picker.startDate.format('YYYY'), picker.startDate.format('MM'), picker.startDate.format('DD'));
// 	    var endDate = new Date(picker.endDate.format('YYYY'), picker.endDate.format('MM'), picker.endDate.format('DD'));
// 	    var year = moment(picker.endDate.format('YYYY-MM-DD')).subtract(6,'months').format('YYYY');
// 	    var month = moment(picker.endDate.format('YYYY-MM-DD')).subtract(6,'months').format('MM');
// 	    var day = moment(picker.endDate.format('YYYY-MM-DD')).subtract(6,'months').format('DD');
// 	    var calEndDate = new Date(year,month,day); 
	    
// 	    var diffDate = startDate - calEndDate;
// 	    var cDay = 24 * 60 * 60 * 1000;// 시 * 분 * 초 * 밀리세컨
// 	    var cMonth = cDay * 30;// 월 만듬
	    
// 	    if(parseInt(diffDate/cDay) < 0){
// 	    	dateChangeGubn = true;
	    	
// 	    	$("input[name='kEntryDate']").data("daterangepicker").setStartDate(moment().format(pStartDate));
//             $("input[name='kEntryDate']").data("daterangepicker").setEndDate(moment().format(pFinishDate));
            
// 	    	alert("등록일자는 최대 6개월까지 조회할 수 있습니다.");
// 	    	return;
// 	    }else{
// 	    	pStartDate = moment(replaceDate($("#kEntryDate").val())[0]).format('YYYY-MM-DD');
// 			pFinishDate = moment(replaceDate($("#kEntryDate").val())[1]).format('YYYY-MM-DD');
// 	    }
	    
// 	    loadTableData();
// 	}
	
	function downExcelData() {
		var kSearchDate = $("#kEntryDate").val();
		var kSearchArr = kSearchDate.split(" - ");
		
		var startDt = kSearchArr[0];
		var endDt = kSearchArr[1];
		var frm = $("#frmMain");
		
		frm.addInput("func", "IQ_Excel");
		frm.addInput("startDt", startDt);
		frm.addInput("endDt", endDt);
		frm.addInput("query_id", "park.parkingCarStatusByNumber.select_parkStatusAllList");
		frm.addInput("type", "parkingCarStatusByNumber");
		frm.setAction("<c:url value='/common_excel.do'/>");
		frm.removeAttr("onsubmit");
		frm.submit();
		frm.setAction("<c:url value='/common_select.do'/>");
		frm.attr("onsubmit", "return false");
        $("#frmMain > input[name='query_id']").remove();
        $("#frmMain > input[name='startDt']").remove();
        $("#frmMain > input[name='endDt']").remove();
	}

	function handleIQ_Excel(data, textStatus, jqXHR) {}
	
	$(function() {
		//일자
		$("#kEntryDate").initDateOnly("m",-3,"m",0);

		// lookup the container we want the Grid to use
		var eGridDiv = document.querySelector('#myGrid');

		// create the grid passing in the div to use together with the columns & data we want to use
		new agGrid.Grid(eGridDiv, gridOptions);

		// frmMain 자동조회
		$("#frmMain").autoSearch(loadTableData);

		// 입차일자 변경시
// 		$("input[name='kEntryDate']").on('apply.daterangepicker', function(ev, picker) {
// 			dateValidation(ev, picker);
// 		});

		// 조회
		$("#btnSearch").click(function() {
			loadTableData();
		});

		// 다운로드
		$("#btnExcel").click(function(){
			if(_gridHelper.getAllGridData().length < 1) {
				alert("조회된 데이터가 없습니다.");
				return false;
			}
			downExcelData();
		});
		
		loadTableData();
		
// 		var kSearchDate = $("#kEntryDate").val();
// 		// 초기 날짜 세팅
// 		pStartDate = moment(replaceDate($("#kEntryDate").val())[0]).format('YYYY-MM-DD');
// 		pFinishDate = moment(replaceDate($("#kEntryDate").val())[1]).format('YYYY-MM-DD');
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
					<c:choose>  
						<c:when test="${fn:contains(user_role_id, 'MANAGE') || fn:contains(user_role_id, 'AD')}">
							<form:select id="kParkingGovCode" caption="관리기관" all="true" allLabel="전체" queryId="select.select_parkingGovInfo"/>
						</c:when> 
						<c:otherwise> 
							<form:select id="kParkingGovCode" caption="관리기관" all="false" allLabel="전체" queryId="select.select_parkingGovInfo"/>
						</c:otherwise>
					</c:choose>
					<form:input id="kCarNo" caption="차량번호" addAttr="maxlength='20'" />
					<form:input id="kEntryDate" caption="입차일자" addAttr="maxlength='100'" />
				</form>
			</div>
			<card:close />
		</div>
		<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12">
			<card:open title="차량별 주차 현황" />
			<card:toolButton title="">
			</card:toolButton>
			<card:content />
			<form:grid id="myGrid" />
			<card:close />
		</div>
	</div>
</div>

<%@ include file="../../core/include/footer.jsp"%>
