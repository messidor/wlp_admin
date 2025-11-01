<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="form" uri="http://ad.its.yeongju.kr/jsp/jstl/form" %>
<%@ taglib prefix="card" uri="http://ad.its.yeongju.kr/jsp/jstl/card" %>
<%@ taglib prefix="func" uri="http://ad.its.yeongju.kr/jsp/jstl/func" %>

<%@ include file="../../core/include/head.jsp" %>
<%@ include file="../../core/include/header.jsp" %>


<script type="text/javascript">

    // 데이터 복원 시 사용할 원본 데이터 변수
    var _originData;

    // 새로운 행 기본값 세팅
    function createNewRowData() {
        var newData = {
			state_col: "C",
			userId: "",
			userPw: "",
			deptId: "",
			userName: "",
			posGubn: "A",
			userPhone : "",
			userEmail : "",
			recvYn: "Y",
			useYn: "Y",
			modId: "",
			modDt: "",
			checkValue: ""
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
		setGubunColumn(),   // 그리드 에디터 사용시(Create,Update,Delete)
        setColumn(["userId", "사용자ID", "left", 150], [(_params) => { return _params.data.checkValue === 'Y' ? false : true }, [], true, "", "20"]),
        setColumn(["userPw", "비밀번호", "left", 170],[true, [], false, "", "40"],false),
        setColumn(["userName", "사용자명", "left", 130],[true, [], true, "", "10"]),
        setColumn(["userEmail", "이메일", "left", 250],[true, ["email"], false, "", "100"]),
        setColumn(["userPhone", "연락처", "center", 140],[true, [], true, "", "11"]),
        setColumn(["deptId", "부서", "center", 100], [true, ["select", ${func:queryToJSON(pageContext, 'sys.dept.select_deptComboData')}, "value", "text"], false, "", "20"], false, false, false, ""),
        setColumn(["posGubn", "직급", "center", 100], [true, ["select", ${func:codeToJSON(pageContext, 'POS_GUBN')}, "value", "text"], false, "", "20"], false, false, false, ""),
        setColumn(["recvYn", "수신여부", "center", 100], [true, ["select", ${func:codeToJSON(pageContext, 'USE_YN')}, "value", "text"], true, "", "20"], false, false, false, ""),
        setColumn(["useYn", "사용여부", "center", 100], [true, ["select", ${func:codeToJSON(pageContext, 'USE_YN')}, "value", "text"], false, "", "20"], false, false, false, ""),
        setColumn(["modId", "수정자", "center", 100]),
        setColumn(["modDt", "수정일시", "center", 160]),
    ];
    
    columnDefs = setColumnMask(columnDefs, "userPhone", "phone");

    // 컬럼정의 / 화면에 그리드 맞추기 / 행추가 func
    var _gridHelper = new initGrid(columnDefs, true, createNewRowData);
    var gridOptions = _gridHelper.setGridOption();

	function loadTableData(isMsg) {
		if (isMsg === undefined) isMsg = true;
    	var frm = $("#frmMain");
        //---- 그리드 조회 시 필수요소 start
        frm.addParam("result", $("#myGrid"));       // 그리드 태그
        frm.addParam("grid", "gridOptions");        // 그리드 옵션
        frm.addParam("baseData", "_originData");    // 그리드 원본 데이터 저장 변수
        //---- 그리드 조회 시 필수요소 end
		frm.addParam("func", "IQ");
        frm.addParam("enc_col", "kSearchName");
        frm.addParam("query_id", "sys.user.select_list");
        frm.addParam("dataType", "json");           // 그리드 불러오는 타입 (기본 json)
        if (isMsg === false) {
    		frm.addParam("afterAction", false);
    	}
		frm.request();
    }

    function handleIQ(data, textStatus, jqXHR) {}

    function saveData() {
		var frm = $("#frmMain");
		frm.addParam("func", "IS");
		frm.addParam("grid", "gridOptions");        // 그리드 옵션
        frm.addParam("query_id", "sys.user.grid_user");
        frm.addParam("dataType", "json");
        frm.addParam("reqAction", true);            // 그리드 입력의 경우, 필수 필드를 입력하지 않았을 때 처리하는 기본 기능 활성 여부 (기본값 = true)
        frm.addParam("emptyPw", "1");
        frm.addParam("enc_col", "grd_userId[], grd_userName[], grd_userEmail[], grd_userPhone[], userId");
        frm.addParam("sha_col", "grd_userPw[], emptyPw");
        
        frm.addParam("grid", "gridOptions"); // 저장할 그리드의 그리드옵션 변수명    	
		frm.request();
    }

    function handleIS(data, textStatus, jqXHR){
        loadTableData(false);
    }

    $(function() {

        // lookup the container we want the Grid to use
        var eGridDiv = document.querySelector('#myGrid');

        // create the grid passing in the div to use together with the columns & data we want to use
        new agGrid.Grid(eGridDiv, gridOptions);

        loadTableData();

        // frmMain 자동조회
        $("#frmMain").autoSearch(loadTableData);

        // 조회
        $("#btnSearch").click(function(){
            loadTableData();
        });

        // 저장
        $("#btnSave").click(function(){
            if(confirm("저장하시겠습니까?")) {
                saveData();
            }
        });
        
     	// 그리드 버튼 표시
        $("i.open-card-option").trigger("click");

        // 그리드 행 추가
        $("body").on("click", "#tool_insert",function(){
            _gridHelper.onAddRow();
        });

        // 그리드 행 삭제
        $("body").on("click", "#tool_delete",function(){
            _gridHelper.onRemoveSelected();
        });

        // 그리드 행 복원
        $("body").on("click", "#tool_undo",function(){
            _gridHelper.onUndoSelected();
        });

    });
</script>


<div class="page-body" style="font-size: 0.9em;">
	<div class="row">
		<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12" id="search_all_wrapper">
			<card:open title="검색 조건" />
				<card:button>
					<form:button type="Search" id="btnSearch" />
					<form:button type="Save" id="btnSave" />
				</card:button>
				<card:content />
                <div class="search-area col-lg-12" >
                    <form id="frmMain" name="frmMain" method="post" onsubmit="return false" class="form-material form-inline">
                    	<form:select id="kUserGubn" caption="검색구분" all="true" allLabel="전체" queryId="#USER_SEARCH_GUBN"  />
                    	<form:input id="kSearchName" caption="검색어" addAttr="maxlength='50'" />
                    </form>
				</div>
			<card:close />
        </div> 
        <div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12">
			<card:open title="사용자 리스트" />
				<card:toolButton title="L00087">
					<form:button type="RowAdd" id="tool_insert" wrap="li" />
					<form:button type="RowDel" id="tool_delete" wrap="li" />
					<form:button type="RowUndo" id="tool_undo" wrap="li" />
				</card:toolButton>
				<card:content />
				<form:grid id="myGrid" />
			<card:close />
        </div>
	</div>
</div>

<%@ include file="../../core/include/footer.jsp"%>
