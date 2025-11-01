<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="form" uri="http://ad.its.yeongju.kr/jsp/jstl/form" %>
<%@ taglib prefix="card" uri="http://ad.its.yeongju.kr/jsp/jstl/card" %>
<%@ taglib prefix="func" uri="http://ad.its.yeongju.kr/jsp/jstl/func" %>

<%@ include file="../../core/include/head.jsp" %>
<%@ include file="../../core/include/header.jsp" %>


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
	    setColumn(["roleId", "그룹코드", "left", 100]),
	    setColumn(["roleName", "그룹명", "left", 120]),
	    setColumn(["roleGubn", "그룹구분", "center", 100])
	];
	
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
	    setColumn(["parentMenuId", "hParentMenuId", "left", 120],[],true),
	    setColumn(["menuId", "hMenuId", "left", 100],[],true),
	    setColumn(["menuName", "메뉴명", "left", 160]),
	    setColumn(["menuUrl", "URL", "left", 150]),
	    setColumn(["useYn", "사용여부", "left", 100]),
	];
	
	// 컬럼 옵션
	var columnDefs3 = [
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
	    setColumn(["menuId", "hMenuId", "left", 100],[],true),
	    setColumn(["btnId", "버튼 ID", "left", 120]),
	    setColumn(["btnName", "버튼명", "left", 100]),
	];
	
	// 그리드 옵션
	var _gridHelper = new initGrid(columnDefs, true);
	var gridOptions = _gridHelper.setGridOption();
	
	var _gridHelper2 = new initGrid(columnDefs2, false);
	var gridOptions2 = _gridHelper2.setGridOption();
	
	var _gridHelper3 = new initGrid(columnDefs3, true);
	var gridOptions3 = _gridHelper3.setGridOption();
	
	// 그리드 클릭 이벤트 추가
	_gridHelper.addRowClickEvent(grid1RowClickEvent);
	_gridHelper2.addRowClickEvent(grid2RowClickEvent);
	
	// 그리드 클릭 이벤트 내용
	function grid1RowClickEvent(event){
	    $("#hRoleId").val(event.data.roleId);
	    loadTableData4();	
	}
	
	// 그리드 클릭 이벤트 내용
	function grid2RowClickEvent(event){
	    $("#hMenuId2").val(event.data.menuId);
	
	    loadTableData4();
	}
	
	function loadTableData() {
	    var frm = $("#frmMain");
	    //---- 그리드 조회 시 필수요소 start
	    frm.addParam("result", $("#myGrid"));       // 그리드 태그
	    frm.addParam("grid", "gridOptions");        // 그리드 옵션
	    //---- 그리드 조회 시 필수요소 end
		frm.addParam("func", "IQ");
	    frm.addParam("query_id", "sys.groupMenu.select_groupList");
	    frm.addParam("enc_col", "userId");
	    frm.addParam("dataType", "json");           // 그리드 불러오는 타입 (기본 json)
		frm.request();
	}
	
	function handleIQ(data, textStatus, jqXHR) {
	    loadTableData2();
	}
	
	function loadTableData2() {
		var frm = $("#frmMain");
		frm.addParam("func", "IQ2");
	    frm.addParam("query_id", "sys.groupMenu.select_groupMenuTree");
	    frm.addParam("enc_col", "userId");
	    frm.addParam("dataType", "json");
		frm.request();
	}
	
	function handleIQ2(data, textStatus, jqXHR){
	    treeObj.refresh(data);
	}
	
	function loadTableData3() {
	    var frm = $("#frmMain");
	    //---- 그리드 조회 시 필수요소 start
	    frm.addParam("result", $("#myGrid2"));       // 그리드 태그
	    frm.addParam("grid", "gridOptions2");        // 그리드 옵션
	    //---- 그리드 조회 시 필수요소 end
		frm.addParam("func", "IQ3");
	    frm.addParam("query_id", "sys.groupMenu.select_groupMenuList");
	    frm.addParam("enc_col", "userId");
	    frm.addParam("dataType", "json");           // 그리드 불러오는 타입 (기본 json)
		frm.request();
	}
	
	function handleIQ3(data, textStatus, jqXHR) {
	    loadTableData4();
	}
	
	function loadTableData4() {
	    var frm = $("#frmMain");
	    //---- 그리드 조회 시 필수요소 start
	    frm.addParam("result", $("#myGrid3"));       // 그리드 태그
	    frm.addParam("grid", "gridOptions3");        // 그리드 옵션
	    //---- 그리드 조회 시 필수요소 end
		frm.addParam("func", "IQ4");
	    frm.addParam("query_id", "sys.groupMenu.select_groupButtonList");
	    frm.addParam("dataType", "json");           // 그리드 불러오는 타입 (기본 json)
		frm.request();
	}
	
	function handleIQ4(data, textStatus, jqXHR){
	}
	
	function saveData() {
	    var frm = $("#frmMain");
        frm.serializeArrayCustom();
		frm.addParam("func", "IS");
	    frm.addParam("query_id", "sys.groupMenu.grid_data");
	    frm.addParam("dataType", "json");
	    frm.addParam("enc_col", "userId");
	    frm.addParam("grid", "gridOptions3"); // 저장할 그리드의 그리드옵션 변수명
		frm.request();
	}
	
	// http response code == 200 : OK, NO 처리 후 처리되는 공통 핸들러
	function handleIS(data, textStatus, jqXHR) {
	    // handleOK, handleNO 수행 후 실행됨
	    loadTableData4();
	}
	
	function onTreeClick(event, data) {
	    $("#hMenuId2").val("");
	    $("#hMenuId").val(data.node.key);
	
	    if($("#hRoleId").val() != "" && $("#hParentMenuId").val() != ""){
	        loadTableData3();
	    }
	}
	
	// 검색조건으로 검색하기 위해 선처리 해야 할 부분들
	function autoSearchCheck() {
	    _gridHelper2.clearData();    // 그리드 데이터 모두 클리어
	    _gridHelper3.clearData();
	    $("#hMenuId").val("");
	    $("#hMenuId2").val("");
	    loadTableData();
	}
	
	$(function() {
	
	    treeObj = $("#treeDiv").initTree({
	        "icon" : true,
	        "expand" : true,
	        "clickEvent" : onTreeClick,
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
	    var eGridDiv3 = document.querySelector('#myGrid3');
	
	    // 그리드 옵션 초기화
	    var gridObj = new agGrid.Grid(eGridDiv, gridOptions);
	    var gridObj2 = new agGrid.Grid(eGridDiv2, gridOptions2);
	    var gridObj3 = new agGrid.Grid(eGridDiv3, gridOptions3);
	
	    // 그리드 툴 버튼 바로 표시
	    $("i.open-card-option").trigger("click");
	
	    // 조회
	    $("#btnSearch").click(function(){
	        _gridHelper2.clearData();    // 그리드 데이터 모두 클리어
	        _gridHelper3.clearData();
	        $("#hRoleId").val("");
	        $("#hMenuId").val("");
	        $("#hMenuId2").val("");
	
	        loadTableData();
	        loadTableData3();
	        loadTableData4();
	    });
	
	    // frmMain 자동조회
	    $("#frmMain").autoSearch(autoSearchCheck);
	
	    // 저장
	    $("#btnSave").click(function() {
	        if($("#hRoleId").val() == "") {
	            notifyDanger("그룹을 선택해 주세요.");
	            return;
	        }
	        if($("#hMenuId").val() == "") {
	            notifyDanger("메뉴를 선택해 주세요.");
	            return;
	        }
	        if($("#hMenuId2").val() == "") {
	            notifyDanger("상위 메뉴를 선택해 주세요.");
	            return;
	        }
	        if(confirm("저장하시겠습니까?")) {
	            saveData();
	        }
	    });
	
	    // 전체 포함
	    $("#btnIncludeAll").click(function() {
	        // 전체 체크 상태 변경 (컬럼명, 포함 여부(true:포함, false:미포함))
	        _gridHelper3.changeCheckState("includeValue", true);
	    });
	
	    // 전체 미포함
	    $("#btnExcludeAll").click(function() {
	        // 전체 체크 상태 변경 (컬럼명, 포함 여부(true:포함, false:미포함))
	        _gridHelper3.changeCheckState("includeValue", false);
	    });
	
	    loadTableData();
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
                    	<form:input id="hRoleId" caption="hRoleId" type="hidden" />
                    	<form:input id="hMenuId" caption="hMenuId" type="hidden" />
                    	<form:input id="hMenuId2" caption="hMenuId2" type="hidden" />
                    	<form:select id="kRoleGubn" caption="그룹구분" all="true" allLabel="전체" queryId="#role_gubn" />
                    	<form:select id="kSearchGubn" caption="검색 구분" all="true" allLabel="전체" queryId="#role_search_gubn" />
                    	<form:input id="kSearchName" caption="검색어" addAttr="maxlength='20'" />
                    </form>
				</div>
			<card:close />
		</div>
		<div class="col-xl-3 col-lg-3 col-md-3 col-sm-12 col-12">
			<card:open title="그룹 리스트" />
				<card:toolButton title="">
				</card:toolButton>
				<card:content />
				<form:grid id="myGrid" />
			<card:close />
		</div>
		<div class="col-xl-3 col-lg-3 col-md-3 col-sm-12 col-12">
			<card:open title="메뉴 리스트" />
				<card:toolButton title="">
				</card:toolButton>
				<card:content />
				<form:grid id="treeDiv" height="100%" />
			<card:close />
		</div>
		<div class="col-xl-3 col-lg-3 col-md-3 col-sm-12 col-12">
			<card:open title="상세 메뉴 리스트" />
				<card:toolButton title="">
				</card:toolButton>
				<card:content />
				<form:grid id="myGrid2" />
			<card:close />
		</div>
		<div class="col-xl-3 col-lg-3 col-md-3 col-sm-12 col-12">
			<card:open title="버튼 리스트" />
				<card:toolButton title="">
				</card:toolButton>
				<card:content />
				<form:grid id="myGrid3" />
			<card:close />
		</div>
	</div>
</div>

<%@ include file="../../core/include/footer.jsp" %>
