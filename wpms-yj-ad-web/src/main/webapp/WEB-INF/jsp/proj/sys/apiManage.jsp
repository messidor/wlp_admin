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
			serviceKey: "",
			apiGubn: "A01",
			providedName: "",
			useYn: "Y",
			modId: "",
			modDt: "",
        };
        return newData;
    }

    // 컬럼 옵션
    var columnDefs = [

		setGubunColumn(),   // 그리드 에디터 사용시(Create,Update,Delete)
		setColumn(["orgApiGubn", "orgApiGubn", "center", 60],[],true),
        setColumn(["serviceKey", "서비스키", "left", 250],[false, [], true, "", "10"]),
        setColumn(["apiGubn", "API 구분", "center", 110], [true, ["select", ${func:codeToJSON(pageContext, 'API_GUBN')}, "value", "text"], true, "", "20"], false, false, false, ""),
        setColumn(["providedName", "제공처", "left", 150],[true, [], true, "", "10"]),
        setColumn(["useYn", "사용여부", "center", 110], [true, ["select", ${func:codeToJSON(pageContext, 'USE_YN')}, "value", "text"], true, "", "20"], false, false, false, ""),
        setColumn(["modId", "수정자", "center", 120]),
        setColumn(["modDt", "수정일시", "center", 160]),
    ];
    
    columnDefs = setColumnMask(columnDefs, "modDt", "datetime");

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
        frm.addParam("query_id", "sys.apiManage.select_list");
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
        frm.setAction("<c:url value='/sys/apiManage.do' />");
        frm.addParam("dataType", "json");
        frm.addParam("reqAction", true);            // 그리드 입력의 경우, 필수 필드를 입력하지 않았을 때 처리하는 기본 기능 활성 여부 (기본값 = true)
        
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
                    	<form:select id="kApiGubn" caption="API구분" all="true" allLabel="전체" queryId="#API_GUBN"  />
                    	<form:input id="kProvidedName" caption="제공처" addAttr="maxlength='50'" />
                    	<form:select id="kUseYn" caption="사용여부" all="true" allLabel="전체" queryId="#use_yn" value="Y" />
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
