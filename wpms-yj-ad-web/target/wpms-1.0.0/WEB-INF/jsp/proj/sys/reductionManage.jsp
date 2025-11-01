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

	var rating = [
		{value : "", text : "0%"},
		{value : "10", text : "10%"},
		{value : "20", text : "20%"},
		{value : "30", text : "30%"},
		{value : "40", text : "40%"},
		{value : "50", text : "50%"},
		{value : "60", text : "60%"},
		{value : "70", text : "70%"},
		{value : "80", text : "80%"},
		{value : "90", text : "90%"},
		{value : "100", text : "100%"}
	]

    // 새로운 행 기본값 세팅
    function createNewRowData() {
        var newData = {
			state_col: "C",
			reductionCode: "",
			reductionGubn: "A",
			reductionName: "",
			useYn: "Y",
			reductionRate : "",
			reductionOpt : "",
			reductionOrder : "",
			freeHour : "0",
			addrChkYn : "N",
        };
        return newData;
    }

    // 컬럼 옵션
    var columnDefs = [
		setGubunColumn(),   // 그리드 에디터 사용시(Create,Update,Delete)
		
		setColumn(["reductionCode", "감면코드", "center", 80],[false, [], true, "", ""]),
		setColumn(["reductionGubn", "감면구분", "center", 100], [true, ["select", ${func:codeToJSON(pageContext, 'REDUCTION_GUBN')}, "value", "text"], true, "", "20"], false, false, false, ""),
		setColumn(["reductionName", "감면정보", "center", 140],[true, [], true, "", "20"]),
		setColumn(["reductionRate", "감면비율", "center", 90], [true, ["select", rating, "value", "text"], false, "", "20"], false, false, false, ""),
		setColumn(["reductionOpt", "비고", "left", 200],[true, [], false, "", "20"]),
		setColumn(["reductionOrder", "우선순위", "center", 90],[true, [], true, "", "10"]),
		setColumn(["freeHour", "무료시간", "center", 80], [true, ["select", ${func:codeToJSON(pageContext, 'DISCOUNT_M')}, "value", "text"], false, "", "20"], false, false, false, ""),
		setColumn(["addrChkYn", "주소확인여부", "center", 100], [true, ["select", ${func:codeToJSON(pageContext, 'USE_YN')}, "value", "text"], false, "", "20"], false, false, false, ""),
		setColumn(["useYn", "사용여부", "center", 100], [true, ["select", ${func:codeToJSON(pageContext, 'USE_YN')}, "value", "text"], false, "", "20"], false, false, false, ""),
		setColumn(["applyCarKind", "감면적용차량종류", "center", 130], [true, ["select", ${func:codeToJSON(pageContext, 'APPLY_CAR_KIND')}, "value", "text"], false, "", "20"], false, false, false, ""),
		setColumn(["applyRidingCnt", "승차정원확인여부", "center", 130], [true, ["select", ${func:codeToJSON(pageContext, 'APPLY_RIDING_CNT')}, "value", "text"], false, "", "20"], false, false, false, ""),
        setColumn(["userName", "수정자", "center", 120]),
        setColumn(["modDt", "수정일시", "center", 160]),
    ];
    
    setColumnMask(columnDefs, "reductionOrder", "number", {maxLength : 9});
    setColumnMask(columnDefs, "modDt", "datetime");

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
        frm.addParam("query_id", "sys.reductionManage.select_list");
        frm.addParam("dataType", "json");           // 그리드 불러오는 타입 (기본 json)
		frm.request();
    }

    function handleIQ(data, textStatus, jqXHR) {}
	
    function saveData() {
	    var frm = $("#frmMain");
	    frm.addParam("func", "IS");
	    frm.addParam("dataType", "json");
	    frm.addParam("grid", "gridOptions");
	    frm.setAction("<c:url value='/sys/reductionManage.do' />");
	    
		frm.request();
	}
	
	function handleIS(data, textStatus, jqXHR){
	    //notifyInfo("정상적으로 저장되었습니다.");
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
                    	<form:input id="kSearchName" caption="감면명" addAttr="maxlength='10'" />
                    </form>
				</div>
			<card:close />
        </div> 
        <div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12">
			<card:open title="감면 정보 리스트" />
				<card:toolButton title="L00087">
					<form:button type="RowAdd" id="tool_insert" wrap="li" />
					<form:button type="RowUndo" id="tool_undo" wrap="li" />
				</card:toolButton>
				<card:content />
				<form:grid id="myGrid" />
			<card:close />
        </div>
	</div>
</div>

<%@ include file="../../core/include/footer.jsp"%>
