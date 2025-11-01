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
		setColumn(["payLogCode", "payLogCode", "center"], [], true),
		
		setColumn(["regDt", "결제요청일시", "center", 130]),
		setColumn(["payDt", "스마트로페이 결과 수신 일시", "center", 180]),
		setColumn(["modDt", "결제완료일시", "center", 130]),
		setColumn(["memberId", "ID", "left", 100]),
		setColumn(["memberName", "이름", "center", 80]),
		setColumn(["serviceKey", "서비스키", "left", 300]),
		setColumn(["parkingName", "주차장명", "left", 150]),
		setColumn(["carNo", "차량번호", "center", 100]),
		setColumn(["payGubnName", "결제구분", "center", 100]),
		setColumn(["entDt", "입차일시", "center", 130]),
		setColumn(["outDt", "출차일시", "center", 130]),
		setColumn(["calcReductionCode", "감면 코드", "center", 80]),
		setColumn(["calcReductionName", "감면명", "center", 110]),
		setColumn(["calcReductionRate", "감면율", "center", 80]),
		setColumn(["totalParkingFee", "총 주차 금액(수신)", "right", 150]),
		setColumn(["prePayFee", "사전정산금액(감면적용)", "right", 160]),
		setColumn(["discountFee", "할인금액(감면제외)", "right", 150]),
		setColumn(["parkingFee", "결제요청금액(감면적용)", "right", 160]),
		setColumn(["parkingMin", "총 유료 주차 시간", "right", 140]),
		setColumn(["totalParkingPrice", "총 주차 금액(계산)", "right", 130]),
		setColumn(["discountPrice", "할인금액(계산)", "right", 130]),
		setColumn(["parkingPrice", "결제금액(감면적용)", "right", 140]),
        setColumn(["chargePrice", "최종 청구 금액", "right", 110]),
		setColumn(["payResultCode", "스마트로페이 결제 결과", "center", 160]),
		setColumn(["payErrorDetail", "오류 발생시 문자열", "left", 180]),
		
	];

	// setColumnMask(컬럼옵션변수, 컬럼명, 타입, 추가옵션)
	setColumnMask(columnDefs, "totalParkingFee", "number");
	setColumnMask(columnDefs, "prePayFee", "number");
	setColumnMask(columnDefs, "discountFee", "number");
	setColumnMask(columnDefs, "parkingFee", "number");
	setColumnMask(columnDefs, "parkingMin", "number");
	setColumnMask(columnDefs, "totalParkingPrice", "number");
	setColumnMask(columnDefs, "discountPrice", "number");
	setColumnMask(columnDefs, "parkingPrice", "number");
	setColumnMask(columnDefs, "chargePrice", "number");
	setColumnMask(columnDefs, "entDt", "datetime");
	setColumnMask(columnDefs, "outDt", "datetime");
	setColumnMask(columnDefs, "payDt", "datetime");
	setColumnMask(columnDefs, "regDt", "datetime");
	setColumnMask(columnDefs, "modDt", "datetime");

	// 그리드 옵션
	// 컬럼정의 / 화면에 그리드 맞추기 / 행추가 func
	var _gridHelper = new initGrid(columnDefs, true);
	var gridOptions = _gridHelper.setGridOption();

	function loadTableData() {
		var frm = $("#frmMain");
	    //---- 그리드 조회 시 필수요소 start
	    frm.addParam("result", $("#myGrid"));       // 그리드 태그
	    frm.addParam("grid", "gridOptions");        // 그리드 옵션
	    frm.addParam("baseData", "_originData");    // 그리드 원본 데이터 저장 변수
	    //---- 그리드 조회 시 필수요소 end
	    frm.addParam("func", "IQ");
		frm.addParam("query_id", "pay.payLog.Select_List");
	    frm.addParam("dataType", "json");           // 그리드 불러오는 타입 (기본 json)

		frm.addParam("startDate", moment(replaceDate($("#kEntryDate").val())[0]).format('YYYY-MM-DD'));
		frm.addParam("endDate", moment(replaceDate($("#kEntryDate").val())[1]).format('YYYY-MM-DD'));
		
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

	// 결제 일자 클릭 이벤트 발생시 수행할 함수
	function gridRowClickEvent(event) {

		loadTableData();
	}
	
	function dateValidation(ev, picker){
		var startDate = new Date(picker.startDate.format('YYYY'), picker.startDate.format('MM'), picker.startDate.format('DD'));
	    var endDate = new Date(picker.endDate.format('YYYY'), picker.endDate.format('MM'), picker.endDate.format('DD'));
	    var year = moment(picker.endDate.format('YYYY-MM-DD')).subtract(1,'month').format('YYYY');
	    var month = moment(picker.endDate.format('YYYY-MM-DD')).subtract(1,'month').format('MM');
	    var day = moment(picker.endDate.format('YYYY-MM-DD')).subtract(1,'month').format('DD');
	    var calEndDate = new Date(year,month,day); 
	    
	    var diffDate = startDate - calEndDate;
	    var cDay = 24 * 60 * 60 * 1000;// 시 * 분 * 초 * 밀리세컨
	    var cMonth = cDay * 30;// 월 만듬
	    
	    if(parseInt(diffDate/cDay) < 0){
	    	dateChangeGubn = true;
	    	
	    	$("input[name='kEntryDate']").data("daterangepicker").setStartDate(moment().format(pStartDate));
            $("input[name='kEntryDate']").data("daterangepicker").setEndDate(moment().format(pFinishDate));
            
	    	alert("결제일자는 1개월까지 조회할 수 있습니다.");
	    	return;
	    }else{
	    	pStartDate = moment(replaceDate($("#kEntryDate").val())[0]).format('YYYY-MM-DD');
			pFinishDate = moment(replaceDate($("#kEntryDate").val())[1]).format('YYYY-MM-DD');
	    }
	    
	    loadTableData();
	}
	
	function downExcelData() {
		var frm = $("#frmMain");
		frm.addInput("func", "IQ_Excel");
		frm.addInput("startDate", moment(replaceDate($("#kEntryDate").val())[0]).format('YYYY-MM-DD'));
		frm.addInput("endDate", moment(replaceDate($("#kEntryDate").val())[1]).format('YYYY-MM-DD'));
		frm.addInput("query_id", "pay.payLog.Select_List");
		frm.addInput("type", "payLog");
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
		// lookup the container we want the Grid to use
	    var eGridDiv = document.querySelector('#myGrid');

	    // create the grid passing in the div to use together with the columns & data we want to use
	    new agGrid.Grid(eGridDiv, gridOptions);
		
	  	//일자
		$("#kEntryDate").initDateOnly("month", -1, "month", 0);
	  
	 	// frmMain 자동조회
	    // $("#frmMain").autoSearch(loadTableData);

	 	// 조회
	    $("#btnSearch").click(function(){
	        loadTableData();
	    });

		$("#kParkingGovCode").change(function() {
			loadComboData();
		});

		$("#kEntryDate, #kParkingNo, #kCarNo, #kPaymentGubn").change(function() {
			loadTableData();
		});
	
		// 입차일자 변경시
// 		$("input[name='kEntryDate']").on('apply.daterangepicker', function(ev, picker) {
// 			dateValidation(ev, picker);
// 		});
		
// 		$("#kEntryDate").on("change", function(e){
// 			loadTableData();
// 		});
	    
	 	// 다운로드
		$("#btnExcel").click(function(){
			if(_gridHelper.getAllGridData().length < 1) {
				alert("조회된 데이터가 없습니다.");
				return false;
			}
			downExcelData();
		});
		
	    var kSearchDate = $("#kEntryDate").val();
		// 초기 날짜 세팅
		pStartDate = moment(replaceDate($("#kEntryDate").val())[0]).format('YYYY-MM-DD');
		pFinishDate = moment(replaceDate($("#kEntryDate").val())[1]).format('YYYY-MM-DD');


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
				<form:button type="Excel" id="btnExcel" />
			</card:button>
			<card:headerContent />
			<div class="search-area col-lg-12">
				<form id="frmMain" name="frmMain" method="post" onsubmit="return false" class="form-material form-inline">
					<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12">
						<form:input id="kEntryDate" caption="결제일자" addAttr="maxlength='100'" />
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
						<form:input id="kCarNo" caption="차량번호" addAttr="maxlength='20'" />
						<form:select id="kPaymentGubn" caption="결제구분" all="true" allLabel="전체" queryId="#PAYMENT_GUBN" size="1" />
					</div>			
				</form>
			</div>
			<card:close />
		</div>
		<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12">
			<card:open title="결제 로그 조회" />
			<card:toolButton title="">
			</card:toolButton>
			<card:content />
			<form:grid id="myGrid" />
			<card:close />
		</div>
	</div>
</div>
<%@ include file="../../core/include/footer.jsp"%>