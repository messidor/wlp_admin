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
            btnId: "",
            btnDispType: "R",
            btnCaption: "",
            btnClass: "",
            btnIcon: "",
            iconLoc: "L",
            useYn: "Y",
            modId: "",
            modDt: "",
            checkValue: ""
        };
        return newData;
    }

    // 컬럼 조건에 따른 에디팅 여부
    function codeEditFunc(_params) {
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
        setGubunColumn(100, false),
        setColumn(["btnId", "버튼 고유키", "left", 150], [codeEditFunc, [], true, "", "20"]),
        setColumn(["btnDispType", "버튼종류", "center", 150], [true, ["select", ${func:codeToJSON(pageContext, 'BTN_DISP_TYPE')}, "value", "text"], false, "", ""]),
        setColumn(["btnCaption", "기본문구", "left", 150], [true, [], false, "", "20"], false, false, false, ""),
        setColumn(["btnClass", "기본클래스", "left", 350], [true, [], false, "", "300"], false, false, false, ""),
        setColumn(["btnIcon", "아이콘클래스", "left", 200], [true, [], false, "", "300"], false, false, false, ""),
        setColumn(["iconLoc", "위치", "center", 100], [true, ["select", ${func:codeToJSON(pageContext, 'BTN_ICON_LOC')}, "value", "text"], false, "", ""]),
        setColumn(["useYn", "사용여부", "center", 100], [true, ["select", ${func:codeToJSON(pageContext, 'USE_YN')}, "value", "text"], false, "", ""]),     
        setColumn(["modId", "수정자", "center", 100], [false], false, false, false, ""),
        setColumn(["modDt", "수정일시", "center", 200], [false], false, false, false, ""),
        setColumn(["checkValue", "check_value", "left", 100], [false], true, false, false, "")
    ];

    // 그리드 옵션
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
        frm.addParam("query_id", "sys.btn.select_list");
        frm.addParam("enc_col", "userId");
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
        frm.addParam("query_id", "sys.btn.grid_btn");
        frm.addParam("query_order", "sys.btn.update_btn_order");
        frm.addParam("enc_col", "userId");
        frm.addParam("dataType", "json");
        //frm.addParam("reqFunc", noValueReqField); // 그리드 입력의 경우, 필수 필드를 입력하지 않았을 때 처리하는 추가 기능 (함수 지정)
        frm.addParam("grid", "gridOptions");        // gridOptions.all : 모든 데이터, gridOptions.check : 체크된 데이터, gridOptions.nocheck : 체크 안된 데이터
		frm.request();
    }

    function handleIS(data, textStatus, jqXHR){
        if(data.count > 0) {
            loadTableData(false);
        }
    }

    $(function() {

        // lookup the container we want the Grid to use
        var eGridDiv = document.querySelector('#myGrid');

        // create the grid passing in the div to use together with the columns & data we want to use
        new agGrid.Grid(eGridDiv, gridOptions);

        // 그리드 툴 버튼 바로 표시
        $("i.open-card-option").trigger("click");

        // frmMain 자동조회
        $("#frmMain").autoSearch(loadTableData);
        
        // 조회
        $("#btnSearch").click(function(){
            loadTableData();
        });

        // 저장
        $("#btnSave").click(function(){
            if(confirm("저장하시겠습니까")) {
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
                    	<form:select id="kSearchGubn" caption="검색 구분" all="true" allLabel="전체" queryId="#btn_search_gubn"  />
                    	<form:input id="kSearchName" caption="검색어" addAttr="maxlength='20'" />
                    </form>
				</div>
			<card:close />
        </div>		
		<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12">
			<card:open title="버튼 리스트" />
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

<%@ include file="../../core/include/footer.jsp" %>
