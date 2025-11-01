<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="form" uri="http://ad.its.yeongju.kr/jsp/jstl/form" %>
<%@ taglib prefix="card" uri="http://ad.its.yeongju.kr/jsp/jstl/card" %>
<%@ taglib prefix="func" uri="http://ad.its.yeongju.kr/jsp/jstl/func" %>

<%@ include file="../../core/include/head.jsp"%>
<%@ include file="../../core/include/header.jsp"%>


<script type="text/javascript">	
	var treeObj;
	
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
	    setColumn(["parentMenuId", "H_부모메뉴코드", "left", 120],[],true),
	    setColumn(["menuId", "H_메뉴코드", "left", 100],[],true),
	    setColumn(["menuName", "메뉴명", "left", 120]),
	    setColumn(["menuUrl", "URL", "left", 120]),
	    setColumn(["modId", "수정자", "left", 90]),
	    setColumn(["modDt", "수정일시", "left", 130])
	];
	
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
	    setColumn(["includeValue", "포함여부", "center", 90], [true, ["check"], false, "", "20"], false, false, false, ""),
	    setColumn(["includeValueOrg", "H_포함여부_원래값", "left", 100],[],true),
	    setColumn(["hasChild", "H_하위메뉴_여부", "left", 100],[],true),
	    setColumn(["parent_code_id", "H_부모버튼코드_공통", "left", 100],[],true),
	    setColumn(["btnIdParent", "H_부모버튼코드", "left", 100],[],true),
	    setColumn(["menuId", "H_메뉴코드", "left", 100],[],true),
	    setColumn(["btnId", "버튼ID", "left", 140]),
	    setColumn(["btnName", "버튼명", "left", 150]),
	    setColumn(["modId", "수정자", "center", 100]),
	    setColumn(["modDt", "수정일시", "center", 130])
	];
	
	// 그리드 옵션
	var _gridHelper = new initGrid(columnDefs, true);
	var gridOptions = _gridHelper.setGridOption();
	
	var _gridHelper2 = new initGrid(columnDefs2, true);
	var gridOptions2 = _gridHelper2.setGridOption();
	
	// 그리드 클릭 이벤트 추가
	_gridHelper.addRowClickEvent(grid1RowClickEvent);
	
	// 그리드 클릭 이벤트 내용
	function grid1RowClickEvent(event){
	    $("#hMenuId2").val(event.data.menuId);
	    $("#hHasChild").val(event.data.hasChild);
	    loadTableData3();
	}
	
	function loadTableData() {
		var frm = $("#frmMain");
		frm.addParam("func", "IQ");
	    frm.addParam("query_id", "sys.menu.select_tree");
	    frm.addParam("enc_col", "userId");
	    frm.addParam("dataType", "json");
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
	    //---- 그리드 조회 시 필수요소 end
		frm.addParam("func", "IQ2");
	    frm.addParam("query_id", "sys.menuBtn.select_menuList");
	    frm.addParam("enc_col", "userId");
	    frm.addParam("dataType", "json");           // 그리드 불러오는 타입 (기본 json)
		frm.request();
	}
	
	function handleIQ2(data, textStatus, jqXHR) {
		_gridHelper2.clearData();
	}
	
	function loadTableData3(isMsg) {
		if (isMsg === undefined) isMsg = true;
	    var frm = $("#frmMain");
	    //---- 그리드 조회 시 필수요소 start
	    frm.addParam("result", $("#myGrid2"));       // 그리드 태그
	    frm.addParam("grid", "gridOptions2");        // 그리드 옵션
	    //---- 그리드 조회 시 필수요소 end
		frm.addParam("func", "IQ3");
	    frm.addParam("query_id", "sys.menuBtn.select_btnList");
	    frm.addParam("enc_col", "userId");
	    frm.addParam("dataType", "json");           // 그리드 불러오는 타입 (기본 json)
		if (isMsg === false) {
			frm.addParam("afterAction", false);
		}
		frm.request();
	}
	
	function handleIQ3(data, textStatus, jqXHR) {}
	
	function saveData() {
		var frm = $("#frmMain");
	    frm.addParam("func", "IS");
	    frm.addParam("dataType", "json");
	    frm.addParam("menuId", $("#hMenuId2").val());
	    frm.addParam("grid", "gridOptions2");
	    frm.setAction("<c:url value='/sys/menuBtn.do' />");
		frm.request();
	}
	
	// count > 0 : 정상 처리
	function handleIS(data, textStatus, jqXHR) {
	    loadTableData3(false);
	}
	
	// 트리 클릭 이벤트
	function treeClickEvent(event, data) {
	    _gridHelper2.clearData();
	    $("#hMenuId").val(data.node.key);
	    $("#hMenuId2").val("");
	    $("#hHasChild").val("");
	    loadTableData2();
	}
	
	$(function() {
	    // 트리 선언 (클릭한 id 값을 표시할 jQuery ID, 클릭 이벤트 함수)
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
	    var eGridDiv2 = document.querySelector('#myGrid2');
	
	    // 그리드 옵션 초기화
	    var gridObj1 = new agGrid.Grid(eGridDiv, gridOptions);
	    var gridObj2 = new agGrid.Grid(eGridDiv2, gridOptions2);
	
	    // 그리드 툴 버튼 바로 표시
	    $("i.open-card-option").trigger("click");
	
	    // 조회
	    $("#btnSearch").click(function(){
	        _gridHelper.clearData();    // 그리드 데이터 모두 클리어
	        _gridHelper2.clearData();
	        $("#hMenuId").val("");
	        $("#hMenuId2").val("");
	        $("#hHasChild").val("");
	        loadTableData();
	    });
	
	    // frmMain 자동조회
	    $("#frmMain").autoSearch(loadTableData2);
	
	    // 저장
	    $("#btnSave").click(function() {
	        if($("#hMenuId").val() == "") {
	            notifyDanger("상위 메뉴를 선택해 주시기 바랍니다.");
	            return;
	        }
	
	        if($("#hMenuId2").val() == "") {
	            notifyDanger("권한 변경을 할 메뉴를 선택해 주시기 바랍니다.");
	            return;
	        }
	
	        if(confirm("해당 데이터를 저장하시겠습니까?")) {
	            saveData();
	        }
	    });
	
	    loadTableData();
	    loadTableData2();
	    loadTableData3();
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
                    	<form:input id="hMenuId" caption="hMenuId" type="hidden" />
                    	<form:input id="hMenuId2" caption="hMenuId2" type="hidden" />
<%--                     	<form:input id="kMenuName" caption="메뉴명" addAttr="maxlength='25'" />                    	 --%>
                    </form>
				</div>
			<card:close />
		</div>
		<div class="col-xl-3 col-lg-3 col-md-3 col-sm-3 col-3">
			<card:open title="메뉴 목록" />
				<card:toolButton title="">
				</card:toolButton>
				<card:content />
				<form:grid id="treeDiv" height="100%"/>
			<card:close />
		</div>
		<div class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4">
			<card:open title="메뉴 목록" />
				<card:toolButton title="">
				</card:toolButton>
				<card:content />
				<form:grid id="myGrid" />
			<card:close />
		</div>
		<div class="col-xl-5 col-lg-5 col-md-5 col-sm-5 col-5">
			<card:open title="버튼 목록" />
				<card:toolButton title="">
				</card:toolButton>
				<card:content />
				<form:grid id="myGrid2" />
			<card:close />
		</div>
	</div>
</div>

<%@ include file="../../core/include/footer.jsp"%>
