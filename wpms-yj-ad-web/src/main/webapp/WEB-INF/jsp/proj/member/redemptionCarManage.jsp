<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="form" uri="http://ad.its.yeongju.kr/jsp/jstl/form" %>
<%@ taglib prefix="card" uri="http://ad.its.yeongju.kr/jsp/jstl/card" %>
<%@ taglib prefix="func" uri="http://ad.its.yeongju.kr/jsp/jstl/func" %>

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
        setColumn(["checkValue", "선택", "center", 50], [true, ["check"], false, "", "20"], false, false, false, ""),
        setColumn(["confirmGubn", "confirmGubn", "center", 60],[],true),
        setColumn(["applyCode", "applyCode", "center", 60],[],true),
        setColumn(["memberId", "memberId", "center", 60],[],true),
		setColumn(["memberName", "이름", "center", 70]),
		setColumn(["memberBirth", "생년월일", "center", 70]),
		setColumn(["carNo", "차량번호", "center", 70]),
		setColumn(["reductionCnt", "감면 신청 내용", "center", 150]),
		setColumn(["applyDt", "신청 일시", "center", 120]),
		setColumn(["confirmYn", "처리 여부", "center", 70]),
		setColumn(["confirmId", "처리자", "center", 90]),
		setColumn(["confirmDt", "처리 일시", "center", 120])
	]; 
	
	// setColumnMask(컬럼옵션변수, 컬럼명, 타입, 추가옵션)
	setColumnMask(columnDefs, "applyDt", "datetime");
	setColumnMask(columnDefs, "confirmDt", "datetime");
	
	// 그리드 옵션
	// 컬럼정의 / 화면에 그리드 맞추기 / 행추가 func
	var _gridHelper = new initGrid(columnDefs, true);
	var gridOptions = _gridHelper.setGridOption();
	
	// 그리드 클릭 이벤트 추가
	_gridHelper.addRowDblClickEvent(gridRowClickEvent);
	
	// 그리드 클릭 이벤트 내용
	function gridRowClickEvent(event) {
 		OpenPopupSingle("/member/redemptionCarManagePopup.do?apply_code="+ event.data.applyCode + "&member_id=" + event.data.memberId + "&confirm_gubn=" + event.data.confirmGubn, 1600, 920, "_Pop");	
	} 
	
	function loadTableData() {
		
		var kSearchDate = $("#kSearchDate").val();
		var kSearchArr = kSearchDate.split(" - ");
		
		var startDt = kSearchArr[0];
		var endDt = kSearchArr[1];
		
		var frm = $("#frmMain");
	    //---- 그리드 조회 시 필수요소 start
	    frm.addParam("result", $("#myGrid"));       // 그리드 태그
	    frm.addParam("grid", "gridOptions");        // 그리드 옵션
	    frm.addParam("baseData", "_originData");    // 그리드 원본 데이터 저장 변수
	    //---- 그리드 조회 시 필수요소 end
		frm.addParam("func", "IQ");
	    frm.addParam("startDt", startDt);
		frm.addParam("endDt", endDt);
		frm.addParam("gubn","CAR");
		frm.addParam("query_id", "member.redemptionManage.Select_List");
	    frm.addParam("dataType", "json");           // 그리드 불러오는 타입 (기본 json)
		frm.request();
	}
	
	function handleIQ(data, textStatus, jqXHR) {}
	
	function saveData() {
		var frm = $("#frmMain");
		frm.addParam("func", "IS");
	    frm.addParam("grid", "gridOptions.check");
	    frm.setAction("<c:url value='/redemption/redemptionUpdate.do' />");
		frm.addParam("dataType", "json");
		frm.request();
	}
	
	function handleIS(data, textStatus, jqXHR) {
		loadTableData();
	}
	
	function validation(){
		for(var i=0; i<_gridHelper.getAllGridData().length; i++){
			if(_gridHelper.getAllGridData()[i].checkValue == "Y" &&_gridHelper.getAllGridData()[i].confirmGubn == "Y"){
				alert("승인된 감면신청은 재 승인 할 수 없습니다.");
				return;
			}
		}
		
		saveData();
	}
	 
	$(function() {
		// lookup the container we want the Grid to use
	    var eGridDiv = document.querySelector('#myGrid');
	
	    // create the grid passing in the div to use together with the columns & data we want to use
	    new agGrid.Grid(eGridDiv, gridOptions);
	    
        $("#kSearchDate").initDateOnly("months", -1, "days", 0);
        
	 	// frmMain 자동조회
	    $("#frmMain").autoSearch(loadTableData);
	    
	 	// 조회
	    $("#btnSearch").click(function(){
	        loadTableData();
	    });
	 	 
	 	// 승인
	    $("#btnApproval").click(function(){
	    	validation();
	    });
	 	
	    loadTableData();
	
	});

</script>

<div class="page-body" style="font-size: 0.9em;">
	<div class="row">
		<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12"
			id="search_all_wrapper">
			<card:open title="검색조건" />
			<card:button>
				<form:button type="Search" id="btnSearch" />
				<form:button type="Approval" id="btnApproval" />
			</card:button>
			<card:content />
			<div class="search-area col-lg-12">
				<form id="frmMain" name="frmMain" method="post" onsubmit="return false" class="form-material form-inline">
					<form:input id="kSearchDate" caption="신청일시" addAttr="maxlength='20'" />
					<form:input id="kSearchName" caption="이름" addAttr="maxlength='20'" />
					<form:input id="kSearchCarNo" caption="차량번호" addAttr="maxlength='20'" />
					<form:select id="kConfirmYn" caption="처리여부" all="true" allLabel="전체" queryId="#CONFIRM_YN"  />
				</form>
			</div>
			<card:close />
		</div>
		<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12">
			<card:open title="감면 신청/승인 회원 목록" />
			<card:toolButton title="">
			</card:toolButton>
			<card:content />
			<form:grid id="myGrid" />
			<card:close />
		</div>
	</div>
</div>
<%@ include file="../../core/include/footer.jsp"%>