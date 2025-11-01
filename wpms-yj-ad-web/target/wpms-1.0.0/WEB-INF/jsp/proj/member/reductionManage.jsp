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
//         setColumn(["checkValue", "선택", "center", 50], [true, ["check"], false, "", "20"], false, false, false, ""),
		setColumn(["no", "번호", "center", 50], [false, ["index", "asc"]]),
        setColumn(["delYn", "delYn", "center", 60],[],true),
        setColumn(["confirmYn", "confirmYn", "center", 60],[],true),
        setColumn(["applyCode", "applyCode", "center", 60],[],true),
        setColumn(["reductionCode", "reductionCode", "center", 60],[],true),
        setColumn(["applyDt", "신청일시", "center", 120]),
        setColumn(["memberId", "ID", "left", 110]),
		setColumn(["memberName", "이름", "center", 110]),
		setColumn(["reductionName", "감면정보", "center", 130]),
		setColumn(["confirmYnName", "처리여부", "center", 70]),
		setColumn(["delYnName", "삭제여부", "center", 70]),
		setColumn(["redExpDate", "감면유효기간", "center", 70]),
		setColumn(["confirmId", "처리자", "center", 90]),
		setColumn(["confirmDt", "처리일시", "center", 120])
	]; 
	
	// setColumnMask(컬럼옵션변수, 컬럼명, 타입, 추가옵션)
	setColumnMask(columnDefs, "applyDt", "datetime");
	setColumnMask(columnDefs, "confirmDt", "datetime");
	setColumnMask(columnDefs, "redExpDate", "date");
	
	// 그리드 옵션
	// 컬럼정의 / 화면에 그리드 맞추기 / 행추가 func
	var _gridHelper = new initGrid(columnDefs, true);
	var gridOptions = _gridHelper.setGridOption();
	
	// 그리드 클릭 이벤트 추가
	_gridHelper.addRowDblClickEvent(gridRowClickEvent);
	
	// 그리드 클릭 이벤트 내용
	function gridRowClickEvent(event) {
		console.log(event)
		OpenPopupSingle("/member/reductionManagePopup.do?applyCode="+ event.data.applyCode + "&memberId=" + event.data.memberId + "&confirmYn=" + event.data.confirmYn + "&delYn=" + event.data.delYn, 950, 860, "_Pop3");
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
		//frm.addParam("gubn","MEMBER");
		frm.addParam("gubn","kReductionType");
		frm.addParam("enc_col", "kSearchName");
		frm.addParam("query_id", "member.reductionManage.Select_List");
	    frm.addParam("dataType", "json");           // 그리드 불러오는 타입 (기본 json)
		frm.request();
	}
	
	function handleIQ(data, textStatus, jqXHR) {}
	
	function viewGubn(){
		if($("#kConfirmYn").val() == "N" || $("#kConfirmYn").val() == "C"){
			$("#kSearchDate").parent().parent().hide();
		}else{
			$("#kSearchDate").parent().parent().show();
		}
	}
	
	function saveData() {
		var frm = $("#frmMain");
		frm.addParam("func", "IS");
	    frm.addParam("grid", "gridOptions.check");
	    frm.setAction("<c:url value='/reduction/reductionUpdate.do' />");
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
	    
        $("#kSearchDate").initDateOnly("year", -1, "year", 0);
        
	 	// frmMain 자동조회
	    $("#frmMain").autoSearch(loadTableData);
	    
	 	// 조회
	    $("#btnSearch").click(function(){
	        loadTableData();
	    });
	 	
	 	$("#kConfirmYn, #kDelYn").change(function(){
	 		viewGubn();
	 	});
	 	 
	 	// 승인
	    $("#btnApproval").click(function(){
	    	validation();
	    });
	 	
	    loadTableData();
	    
	    viewGubn();
	
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
					<form:select id="kConfirmYn" caption="처리여부" all="true" allLabel="전체" queryId="#CONFIRM_YN" value="N"/>
					<form:select id="kDelYn" caption="삭제여부" all="true" allLabel="전체" queryId="#DEL_YN" value="N"/>
					<form:input id="kSearchName" caption="이름" addAttr="maxlength='20'" />
					<form:select id="kReductionType" caption="감면구분" all="false" queryId="#REDUCTION_GUBN"/>
					<form:select id="kReductionCode" caption="감면정보" all="true" allLabel="전체" queryId="member.reductionManage.select_reductionList"/>
					<form:select id="kAutoConfirmYn" caption="자동승인여부" all="true" allLabel="전체" queryId="#REDUCT_INPUT_GUBN"/>


					<form:input id="kSearchDate" caption="신청일자" addAttr="maxlength='20'" />
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