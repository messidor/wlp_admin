<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="form" uri="http://ad.its.yeongju.kr/jsp/jstl/form"%>
<%@ taglib prefix="card" uri="http://ad.its.yeongju.kr/jsp/jstl/card"%>
<%@ taglib prefix="func" uri="http://ad.its.yeongju.kr/jsp/jstl/func"%>
<%@ taglib prefix="label" uri="http://ad.its.yeongju.kr/jsp/jstl/label" %>

<%@ include file="../../core/include/head.jsp"%>
<%@ include file="../../core/include/headerPopup.jsp" %>

<script type="text/javascript">
	//데이터 복원 시 사용할 원본 데이터 변수
	var _originData;
	
	// 새로운 행 기본값 세팅
	function createNewRowData() {
	    var newData = {
	        state_col: "C",
	        faqCode: "",
	        faqOrder: "",
	        faqContent: ""
	    };
	    return newData;
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
	    setColumn(["faqOrder", "번호", "center", 40],[true]),
	    setColumn(["faqContent", "카테고리명", "center", 100]),
	];
	
	setColumnMask(columnDefs, "faqOrder", "number", {maxLength : 9});
	
	var _gridHelper = new initGrid(columnDefs, true, createNewRowData);
	var gridOptions = _gridHelper.setGridOption();
	
	function loadTableData(isMsg) {
	    var frm = $("#frmMain");
	    //---- 그리드 조회 시 필수요소 start
	    frm.addParam("result", $("#myGrid"));       // 그리드 태그
	    frm.addParam("grid", "gridOptions");        // 그리드 옵션
	    frm.addParam("baseData", "_originData");    // 그리드 원본 데이터 저장 변수
	    //---- 그리드 조회 시 필수요소 end
		frm.addParam("func", "IQ");
	    frm.addParam("query_id", "sys.faqOrderPopup.select_list");
	    frm.addParam("dataType", "json");           // 그리드 불러오는 타입 (기본 json)
	    if(isMsg === false){
	    	frm.addParam("afterAction", false);	
	    }
		frm.request();
	}
	
	function handleIQ(data, textStatus, jqXHR){}
	
	function saveData() {
		var frm = $("#frmMain");
		frm.serializeArrayCustom();
		frm.addParam("func", "IS");
		frm.addParam("grid", "gridOptions");
		frm.addParam("dataType", "json");
		frm.setAction("<c:url value='/sys/updateCategoryOrder.do' />");
		
		frm.request();
	}
	
	function handleIS(data, textStatus, jqXHR) {
		loadTableData(false);
	}
	
	$(function() {
		
		var eGridDiv = document.querySelector('#myGrid');
		new agGrid.Grid(eGridDiv, gridOptions);
		
		// frmMain 자동조회
	    $("#frmMain").autoSearch(loadTableData);
		
	    // 등록
	    $("#btnSave").on("click", function(){
	    	if(confirm("저장하시겠습니까?")){
	    		saveData();	
	    	}
	    });

	    // 닫기
	    $("#btnClose").on("click", function(){
			self.close();
	    });

	    loadTableData();
        
	});
</script>
<div class="page-body" style="font-size: 0.9em;">
	<div class="row">
		<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12">
            <form id="frmMain" name="frmMain" method="post" onsubmit="return false" class="form-material form-inline">                    	
            	                  	
            </form>
			<card:open title="카테고리 리스트" />
				<card:toolButton title="">
				</card:toolButton>
				<card:content />
				<form:grid id="myGrid" style="height:300px;"/>
			<card:close />
		</div>
	</div>
	<div class="row padding-left-5 padding-right-5">
		<div class="bottom-btn-area">
			<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12 text-right">
				<form:button type="Save" id="btnSave" />
				<form:button type="Close" id="btnClose" />
			</div>
			<label:clear />
		</div>
	</div>
</div>


<%@ include file="../../core/include/footer.jsp"%>
