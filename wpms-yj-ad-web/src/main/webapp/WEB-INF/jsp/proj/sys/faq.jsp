<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="form" uri="http://ad.its.yeongju.kr/jsp/jstl/form" %>
<%@ taglib prefix="card" uri="http://ad.its.yeongju.kr/jsp/jstl/card" %>
<%@ taglib prefix="func" uri="http://ad.its.yeongju.kr/jsp/jstl/func" %>

<%@ include file="../../core/include/head.jsp"%>
<%@ include file="../../core/include/header.jsp"%>


<script type="text/javascript">
	//데이터 복원 시 사용할 원본 데이터 변수
	var _originData;
	
	// 새로운 행 기본값 세팅
	function createNewRowData() {
	    var newData = {
	        state_col: "C",
	        roleId: "",
	        roleName: "",
	        roleGubn: "N",
	        useYn: "Y",
	        modId: "",
	        modDt: "",
	        checkValue: ""
	    };
	    return newData;
	}
	
	// 컬럼 조건에 따른 에디팅 여부
	function codeEditFunc(_params){
	    if(_params.data.checkValue === 'Y'){
	        return false;
	    }
	    else{
	        return true;
	    }
	}
	
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
	    setColumn(["faqCode", "faqCode", "center", 100],[],true),
	    setColumn(["qCode", "qCode", "center", 100],[],true),
	    setColumn(["faqOrder", "번호", "center", 60], [true]),
	    setColumn(["faqContent", "카테고리명", "center", 100]),
	    setColumn(["qFaqContent", "질문", "left", 300]),
	    setColumn(["rFaqContent", "답변", "left", 500]),
	    setColumn(["btnDetail", "상세보기", "center", 80], [grdDetail, ["button", null, "link", "text", ""]]),
	];
	
	setColumnMask(columnDefs, "faqOrder", "number", {maxLength : 9});

	var _gridHelper = new initGrid(columnDefs, true, createNewRowData);
	var gridOptions = _gridHelper.setGridOption();

	function grdDetail(e, data) {
		if(data.faqCode != null){
			OpenPopupSingle("/sys/faqPopup.do?faqCode=" + data.faqCode + "&qCode=" + data.qCode, 950, 760, "_Pop_New");			
		}
	}
	
	function loadTableData(isMsg) {
	    var frm = $("#frmMain");
	    //---- 그리드 조회 시 필수요소 start
	    frm.addParam("result", $("#myGrid"));       // 그리드 태그
	    frm.addParam("grid", "gridOptions");        // 그리드 옵션
	    frm.addParam("baseData", "_originData");    // 그리드 원본 데이터 저장 변수
	    //---- 그리드 조회 시 필수요소 end
		frm.addParam("func", "IQ");
	    frm.addParam("query_id", "sys.faq.select_list");
	    frm.addParam("dataType", "json");           // 그리드 불러오는 타입 (기본 json)
	    if(isMsg === false){
	    	frm.addParam("afterAction", false);	
	    }
		frm.request();
	    
	    
	}
	
	function handleIQ(data, textStatus, jqXHR){
	    //notifySuccess("조회가 완료되었습니다.");
	}
	
	function saveData() {
		var frm = $("#frmMain");
		frm.serializeArrayCustom();
		frm.addParam("func", "IS");
		frm.addParam("grid", "gridOptions");
		frm.addParam("dataType", "json");
		frm.setAction("<c:url value='/sys/updateOrder.do' />");
		
		frm.request();
	}
	
	function handleIS(data, textStatus, jqXHR) {
		loadTableData(false);
	}
	
	$(function() {
	
	    // lookup the container we want the Grid to use
	    var eGridDiv = document.querySelector('#myGrid');
	
	    // create the grid passing in the div to use together with the columns & data we want to use
	    new agGrid.Grid(eGridDiv, gridOptions);	
	
	    // frmMain 자동조회
	    $("#frmMain").autoSearch(loadTableData);
	    
	    // 조회
	    $("#btnSearch").click(function(){
	        loadTableData();
	    });
	     
	    // 저장
	    $("#btnSave").click(function(){
	    	if(confirm("저장하시겠습니까?")){
	    		saveData();	
	    	}
	    });
	    
	 	// 등록
	    $("#btnRegister").click(function(){
	    	OpenPopupSingle("/sys/faqPopup.do", 950, 760, "_Pop_New2");
	    });
	 	
	 	// 카테고리 순서 변경
	 	$("#btnCategoryOrder").click(function(){
	 		OpenPopupSingle("/sys/faqOrderPopup.do", 600, 510, "_Pop_New3");
	 	});
	     
	    loadTableData();
	});
</script>

<div class="page-body" style="font-size: 0.9em;">
	<div class="row">
		<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12" id="search_all_wrapper">
			<card:open title="검색조건" />
				<card:button>
					<form:button type="Search" id="btnSearch" />
					<form:button type="Save" id="btnSave" />
					<form:button type="CategoryOrder" id="btnCategoryOrder" />
					<form:button type="Register" id="btnRegister" />
				</card:button>
				<card:content />
                <div class="search-area col-lg-12" >
                    <form id="frmMain" name="frmMain" method="post" onsubmit="return false" class="form-material form-inline">                    	
                    	<form:select id="kFaqCode" caption="카테고리명" all="true" allLabel="전체" queryId="sys.faq.select_faq_list"/>                  	
                    </form>
				</div>
			<card:close />
		</div>
		<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12">
			<card:open title="자주하는질문 리스트" />
				<card:content />
				<form:grid id="myGrid" />
			<card:close />
		</div>
	</div>
</div>

<%@ include file="../../core/include/footer.jsp"%>
