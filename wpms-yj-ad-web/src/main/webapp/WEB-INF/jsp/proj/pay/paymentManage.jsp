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
		setColumn(["chargeNo", "chargeNo", "center"], [], true),
		setColumn(["memberId", "memberId", "center"], [], true),
		setColumn(["regDt", "결제일시", "center", 110]),
		setColumn(["carNo", "차량번호", "center", 80]),
		setColumn(["memberName", "이름", "center", 80]),
        setColumn(["pGovName", "관리기관", "left", 150]),
		setColumn(["parkingName", "주차장명", "left", 130]),
		setColumn(["paymentGubnName", "결제구분", "center", 80]),
		setColumn(["totalParkingFee", "주차요금 (전체)", "right", 100]),
		setColumn(["discountFee", "할인요금", "right", 100]),
		setColumn(["prePayFee", "사전결제요금", "right", 100]),
		setColumn(["parkingPrice", "주차요금", "right", 80]),
		setColumn(["payGubnName", "결제상태", "center", 80]),
		setColumn(["confirmName", "처리자", "center", 80]),
		setColumn(["payCancelGubn", "결제취소", "center", 80], [grdPayCancelGubn, ["button", null, "link", "text", ""]]),
		setColumn(["payReGubn", "재결제", "center", 80], [grdPayReGubn, ["button", null, "link", "text", ""]])
	];

	// setColumnMask(컬럼옵션변수, 컬럼명, 타입, 추가옵션)
	setColumnMask(columnDefs, "regDt", "datetime");

	// 그리드 옵션
	// 컬럼정의 / 화면에 그리드 맞추기 / 행추가 func
	var _gridHelper = new initGrid(columnDefs, true);
	var gridOptions = _gridHelper.setGridOption();

	function grdPayCancelGubn(e, data) {
		if(data.payCancelGubn != null){
			var strChargeNo = data.chargeNo.split(",")[0];
			OpenPopupSingle("/pay/paymentManageCancelPopup.do?chargeNo="+strChargeNo+"&memberId="+data.memberId, 500, 735, "_Pop14");			
		}
	}
	
	function grdPayReGubn(e, data) {
		if(data.payReGubn != null){
			if(data.chargeNo.split(",").length > 1){
				var strChargeNo = "";
				for(var i=0; i<data.chargeNo.split(",").length; i++){
					var chargeItem = data.chargeNo.split(",");
					
					if(i > 0){
						strChargeNo += ",'" + chargeItem[i] + "'"; 	
					}else{
						strChargeNo += "'" + chargeItem[i] + "'";
					}
				}
				OpenPopupSingle("/pay/paymentManageOutstandingPopup.do?chargeNo="+strChargeNo+"&memberId="+data.memberId, 1100, 790, "_Pop14");
			}else{
				OpenPopupSingle("/pay/paymentManageRePayPopup.do?chargeNo="+data.chargeNo+"&memberId="+data.memberId, 500, 785, "_Pop15");
			}
		}
	}

	function loadTableData() {
		var frm = $("#frmMain");
	    //---- 그리드 조회 시 필수요소 start
	    frm.addParam("result", $("#myGrid"));       // 그리드 태그
	    frm.addParam("grid", "gridOptions");        // 그리드 옵션
	    frm.addParam("baseData", "_originData");    // 그리드 원본 데이터 저장 변수
	    //---- 그리드 조회 시 필수요소 end
	    frm.addParam("func", "IQ");
	    frm.addParam("enc_col", "kMemberName");
		frm.addParam("query_id", "pay.paymentManage.Select_List");
	    frm.addParam("dataType", "json");           // 그리드 불러오는 타입 (기본 json)

		frm.addParam("startDate", moment(replaceDate($("#kEntryDate").val())[0]).format('YYYY-MM-DD'));
		frm.addParam("endDate", moment(replaceDate($("#kEntryDate").val())[1]).format('YYYY-MM-DD'));
		
		// 멀티 셀렉트 값을 가져와서 서버에 전송하는 방법
		frm.addParam("kStatus", $("#kStatus")[0].sumo.getListTypeValue());

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
		// 멀티 셀렉트 값을 가져와서 서버에 전송하는 방법
		frm.addInput("kStatus", $("#kStatus")[0].sumo.getListTypeValue());
		
		frm.addInput("func", "IQ_Excel");
	    frm.addInput("enc_col", "kMemberName");
		frm.addInput("startDate", moment(replaceDate($("#kEntryDate").val())[0]).format('YYYY-MM-DD'));
		frm.addInput("endDate", moment(replaceDate($("#kEntryDate").val())[1]).format('YYYY-MM-DD'));
		frm.addInput("query_id", "pay.paymentManage.Select_List");
		frm.addInput("type", "paymentManage");
		frm.setAction("<c:url value='/common_excel.do'/>");
		frm.removeAttr("onsubmit");
		frm.submit();
		frm.setAction("<c:url value='/common_select.do'/>");
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

		$("#kParkingNo,#kCarNumber,#kMemberName,#kPaymentGubn,#kStatus").change(function() {
			loadTableData();
		});
	
		// 입차일자 변경시
		$("input[name='kEntryDate']").on('apply.daterangepicker', function(ev, picker) {
			dateValidation(ev, picker);
		});
		
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
		
		// common/js/etcs/common.js 파일 참조, Select box를 멀티 체크박스 형태로 변경
		// 첫번째 파라미터 : 실행시 선택되어 있어야 하는 값들을 배열로 처리. 없으면 빈 배열만 넣으면 됨
		// 두번째 파라미터 : sumoselect 플러그인의 옵션. 변경할게 없으면 빈 JSON 배열({}) 만 넣으면 됨
		// 세번째 파라미터 : sumoselect 플러그인에서 제공하는 이벤트. 없으면 빈 JSON 배열만 넣으면 됨
		$("#kStatus").setMultiSelect(["PG001", "PG002", "PG004"], {
		    min: 1,
		    csvDispCount: 3
		}, {
	        "closed" : function(e, sumo) {
	            loadTableData();
	        }
		});

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
				<form:button type="New" id="btnNew" />
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
						<form:input id="kCarNumber" caption="차량번호" addAttr="maxlength='20'" />
						<form:input id="kMemberName" caption="이름" addAttr="maxlength='20'" size="1" />
						<form:select id="kPaymentGubn" caption="결제구분" all="true" allLabel="전체" queryId="#PAYMENT_GUBN" size="1" />
						<form:select id="kStatus" caption="결제상태" all="false" queryId="#PAY_GUBN" size="2" />
					</div>			
				</form>
			</div>
			<card:close />
		</div>
		<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12">
			<card:open title="요금 결제 목록" />
			<card:toolButton title="">
			</card:toolButton>
			<card:content />
			<form:grid id="myGrid" />
			<card:close />
		</div>
	</div>
</div>
<%@ include file="../../core/include/footer.jsp"%>