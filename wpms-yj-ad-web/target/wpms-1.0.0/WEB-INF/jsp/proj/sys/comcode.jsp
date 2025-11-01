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
	
	var treeObj;
	
	// 새로운 행 기본값 세팅
	function createNewRowData() {
	    var newData = {
	        state_col: "C",
	        parentCodeId: $("#hTreeCode").val(),
	        codeId: "",
	        codeName1: "",
	        codeName2: "",
	        codeName3: "",
	        codeName4: "",
	        codeName5: "",
	        codeComment: "",
	        lang_code: "",
	        codeType: "C",
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
	    setGubunColumn(),   // 그리드 에디터 사용시(Create,Update,Delete)
	    setColumn(["parentCodeId", "H_부모코드", "left", 100],[],true),
	    setColumn(["codeId", "자식코드", "left", 200], [codeEditFunc, [], true, "", "20"], false, true),
	    setColumn(["codeName1", "코드명1", "left", 200],[true]),
	    setColumn(["codeName2", "코드명2", "left", 200],[true]),
	    setColumn(["codeName3", "코드명3", "left", 200],[true]),
	    setColumn(["codeName4", "코드명4", "left", 200],[true]),
	    setColumn(["codeName5", "코드명5", "left", 200],[true]),
	    setColumn(["codeComment", "설명", "left", 200],[true]),	    
	    setColumn(["codeType", "코드타입", "center", 100], [true, ["select", ${func:codeToJSON(pageContext, 'CODE_TYPE')}, "value", "text"]]),
	    setColumn(["useYn", "사용여부", "center", 100], [true, ["select", ${func:codeToJSON(pageContext, 'USE_YN')}, "value", "text"]]),
	    setColumn(["modId", "수정자", "center", 100]),
	    setColumn(["modDt", "수정일시", "center", 200]),
	    setColumn(["checkValue", "checkValue", "left", 100],[],true)
	];
	
	// 그리드 옵션
	var _gridHelper = new initGrid(columnDefs, false, createNewRowData);
	var gridOptions = _gridHelper.setGridOption();
	
	function loadTableData(isMsg) {
		if (isMsg === undefined) isMsg = true;
		var frm = $("#frmMain");
		frm.addParam("func", "IQ");
	    frm.addParam("query_id", "sys.comcode.select_tree");
	    frm.addParam("dataType", "json");
		if (isMsg === false) {
			frm.addParam("afterAction", false);
		}
		frm.request();
	}
	
	function handleIQ(data, textStatus, jqXHR){
	    treeObj.refresh(data);
	}
	
	function loadTableData2() {
	    var frm = $("#frmMain");
	    //---- 그리드 조회 시 필수요소 start
	    frm.addParam("result", $("#myGrid"));       // 그리드 태그
	    frm.addParam("grid", "gridOptions");        // 그리드 옵션
	    frm.addParam("baseData", "_originData");    // 그리드 원본 데이터 저장 변수
	    //---- 그리드 조회 시 필수요소 end
		frm.addParam("func", "IQ2");
	    frm.addParam("query_id", "sys.comcode.select_list");
	    frm.addParam("dataType", "json");           // 그리드 불러오는 타입 (기본 json)
		frm.request();
	}
	
	function handleIQ2(data, textStatus, jqXHR){
	}
	
	function saveData() {
		var frm = $("#frmMain");
		frm.addParam("func", "IS");
	    frm.addParam("query_id", "sys.comcode.grid_comcode");
	    frm.addParam("query_order", "sys.comcode.update_comcode_order");
	    frm.addParam("dataType", "json");
	    frm.addParam("enc_col", "userId");
	    frm.addParam("grid", "gridOptions.all"); // 저장할 그리드의 그리드옵션 변수명
		frm.request();
	}
	
	function handleIS(data, textStatus, jqXHR){
	    _gridHelper.clearData();
	    $("#hTreeCode").val("");
	    loadTableData(false);
	    //loadTableData2();
	}
	
	// 트리 클릭 이벤트
	function treeClickEvent(event, data) {
	    $("#hTreeCode").val(data.node.key);
	    loadTableData2();
	}
	
	$(function() {
	    // 트리 선언
	    treeObj = $("#treeDiv").initTree({
	        "icon" : true,
	        "expand" : true,
	        "clickEvent" : treeClickEvent,
	        "dnd" : false,
	        "convert" : {
	            "key" : "id",
	            "title" : "text",
	            "folder" : "codeType"
	        }
	    });
	
	    // 그리드 선언
	    var eGridDiv = document.querySelector('#myGrid');
	
	    // 그리드 옵션 초기화
	    new agGrid.Grid(eGridDiv, gridOptions);
	
	    // 그리드 툴 버튼 바로 표시
	    $("i.open-card-option").trigger("click");
	
	    // 조회
	    $("#btnSearch").click(function(){
	        _gridHelper.clearData();
	        $("#hTreeCode").val("");
	        loadTableData();
	    });
	
	    // frmMain 자동조회
	    $("#frmMain").autoSearch(loadTableData2);
	
	    // 저장
	    $("#btnSave").click(function(){
	        if(confirm("저장하시겠습니까?")) {
	            saveData();
	        }
	    });
	
	    // 그리드 행 추가
	    $("body").on("click", "#toolInsert",function(){
	        _gridHelper.onAddRow();
	    });
	
	    // 그리드 행 삭제
	    $("body").on("click", "#toolDelete",function(){
	        _gridHelper.onRemoveSelected();
	    });
	
	    // 그리드 행 복원
	    $("body").on("click", "#toolUndo",function(){
	        _gridHelper.onUndoSelected();
	    });
	
	    loadTableData();
	    loadTableData2();
	});
</script>

<div class="page-body" style="font-size: 0.9em;">
	<div class="row">		
		<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12" id="search_all_wrapper">
			<card:open title="검색조건" />
				<card:button>
					<form:button type="Search" id="btnSearch" />
					<form:button type="Save" id="btnSave" />
				</card:button>
				<card:content />
                <div class="search-area col-lg-12" >
                    <form id="frmMain" name="frmMain" method="post" onsubmit="return false" class="form-material form-inline">                    
                    	<form:input id="hTreeCode" caption="hTreeCode" type="hidden" />
                    	<form:input id="kCodeName" caption="코드명" addAttr="maxlength='20'" />
                    	<form:select id="kUseYn" caption="사용여부" all="true" allLabel="전체" queryId="#use_yn"  />
                    </form>
				</div>
			<card:close />
        </div>
		<div class="col-xl-3 col-lg-3 col-md-3 col-sm-3 col-3">
			<card:open title="코드 목록" />
				<card:toolButton title="">
				</card:toolButton>
				<card:content />
				<form:grid id="treeDiv" height="100%"/>
			<card:close />
		</div>
		<div class="col-xl-9 col-lg-9 col-md-9 col-sm-9 col-9">
			<card:open title="코드 리스트" />
				<card:toolButton title="">
					<form:button type="RowAdd" id="toolInsert" wrap="li" />
					<form:button type="RowDel" id="toolDelete" wrap="li" />
					<form:button type="RowUndo" id="toolUndo" wrap="li" />
				</card:toolButton>
				<card:content />
				<form:grid id="myGrid" />
			<card:close />
        </div>
	</div>
</div>
<%@ include file="../../core/include/footer.jsp"%>
