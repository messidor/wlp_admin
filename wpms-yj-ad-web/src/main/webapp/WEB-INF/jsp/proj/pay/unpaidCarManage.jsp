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
		setColumn(["payStatus", "payStatus", "center", 80], [], true),
		setColumn(["chargeNo", "chargeNo", "left", 130], [], true),
		setColumn(["memberId", "memberId", "left", 130], [], true), 
		setColumn(["parkingName", "주차장명", "left", 130]),
		setColumn(["carNo", "차량번호", "center", 100]),
		setColumn(["memberName", "이름", "center", 80]),
		setColumn(["memberPhone", "연락처", "center", 100]),
		setColumn(["pEntDt", "입차일시", "center", 110]),
		setColumn(["pOutDt", "출차일시", "center", 110]),
		setColumn(["parkingPrice", "주차요금", "right", 80]),
		setColumn(["confirmName", "처리자", "center", 80]),
		setColumn(["payStatusName", "납부구분", "center", 80], [grdPayButton, ["button", null, "link", "text", ""] ])
	];
	
	// setColumnMask(컬럼옵션변수, 컬럼명, 타입, 추가옵션)
	setColumnMask(columnDefs, "memberPhone", "phone");
	setColumnMask(columnDefs, "pEntDt", "datetime");
	setColumnMask(columnDefs, "pOutDt", "datetime");
	
	// 그리드 옵션
	// 컬럼정의 / 화면에 그리드 맞추기 / 행추가 func
	var _gridHelper = new initGrid(columnDefs, true);
	var gridOptions = _gridHelper.setGridOption();
	
	function grdPayButton(e, data) {
		OpenPopupSingle("/pay/unpaidPaymentPopup.do?chargeNo="+data.chargeNo+"&memberId="+data.memberId+"&payStatus="+data.payStatus, 500, 815, "_Pop20");
	}
	
	function loadTableData() {
		
		var frm = $("#frmMain");
	    //---- 그리드 조회 시 필수요소 start
	    frm.addParam("result", $("#myGrid"));       // 그리드 태그
	    frm.addParam("grid", "gridOptions");        // 그리드 옵션
	    frm.addParam("baseData", "_originData");    // 그리드 원본 데이터 저장 변수
	    //---- 그리드 조회 시 필수요소 end
		frm.addParam("func", "IQ");
		frm.addParam("enc_col", "kMemberName, kMemberPhone");
		frm.addParam("query_id", "pay.unpaidCarManage.Select_List");
	    frm.addParam("dataType", "json");           // 그리드 불러오는 타입 (기본 json)
		frm.request();
	}
	
	function handleIQ(data, textStatus, jqXHR) {}

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
	
	function downExcelData() {
		var frm = $("#frmMain");
		
		frm.addInput("func", "IQ_Excel");
		frm.addInput("enc_col", "kMemberName, kMemberPhone");
		frm.addInput("query_id", "pay.unpaidCarManage.Select_List");
		frm.addInput("type", "unpaidCarManage");
		frm.setAction("<c:url value='/common_excel.do'/>");
		frm.removeAttr("onsubmit");
		frm.submit();
		frm.setAction("<c:url value='/common_select.do'/>");
		frm.attr("onsubmit", "return false");
        $("#frmMain > input[name='query_id']").remove();
	}

	function handleIQ_Excel(data, textStatus, jqXHR) {}
	
	$(function() {
		// lookup the container we want the Grid to use
	    var eGridDiv = document.querySelector('#myGrid');
	
	    // create the grid passing in the div to use together with the columns & data we want to use
	    new agGrid.Grid(eGridDiv, gridOptions);
	    
        
	 	// frmMain 자동조회
	    //$("#frmMain").autoSearch(loadTableData);
	    
	 	// 조회
	    $("#btnSearch").click(function(){
	        loadTableData();
	    });
	 	
	 	// 생성
	    $("#btnCreate").click(function(){
	    	OpenPopupSingle("/pay/unpaidCreatePopup.do", 800, 710, "Unpaid_Pop");
	    });
	 	
	    $("#kParkingGovCode").change(function() {
			loadComboData();
		});

		$("#kParkingNo,#kCarNumber,#kMemberName,#kMemberPhone, #kPayStatus").change(function() {
			loadTableData();
		});
	    
	    loadTableData();
	    
	 	// 다운로드
		$("#btnExcel").click(function(){
			if(_gridHelper.getAllGridData().length < 1) {
				alert("조회된 데이터가 없습니다.");
				return false;
			}
			downExcelData();
		});
	
	});

</script>

<div class="page-body" style="font-size: 0.9em;">
	<div class="row">
		<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12"
			id="search_all_wrapper">
			<card:open title="검색조건" />
			<card:button>
				<form:button type="Search" id="btnSearch" />
				<form:button type="Create" id="btnCreate" />
				<form:button type="Excel" id="btnExcel" />
			</card:button>
			<card:content />
			<div class="search-area col-lg-12"> 
				<form id="frmMain" name="frmMain" method="post" onsubmit="return false" class="form-material form-inline">
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
					<form:input id="kMemberName" caption="이름" addAttr="maxlength='20'" />
					<form:input id="kMemberPhone" caption="연락처" addAttr="maxlength='20'" />
					<form:select id="kPayStatus" caption="납부구분" all="true" allLabel="전체" queryId="#pay_status" value="N"/>
				</form>
			</div>
			<card:close />
		</div>
		<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12">
			<card:open title="미납 결제 목록" />
			<card:toolButton title="">
			</card:toolButton>
			<card:content />
			<form:grid id="myGrid" />
			<card:close />
		</div>
	</div>
</div>

<%@ include file="../../core/include/footer.jsp"%>