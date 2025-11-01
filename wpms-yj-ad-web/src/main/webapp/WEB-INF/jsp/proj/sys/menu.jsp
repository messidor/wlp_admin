<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="form" uri="http://ad.its.yeongju.kr/jsp/jstl/form" %>
<%@ taglib prefix="card" uri="http://ad.its.yeongju.kr/jsp/jstl/card" %>
<%@ taglib prefix="func" uri="http://ad.its.yeongju.kr/jsp/jstl/func" %>

<%@ include file="../../core/include/head.jsp"%>
<%@ include file="../../core/include/header.jsp"%>


<script type="text/javascript">

	var _ogringData;
	var treeCount = 0;
	
	var treeObj;

    // 새로운 행 기본값 세팅
    function createNewRowData() {
        var newData = {
       		state_col: "C",
            parentMenuId: $("#hMenuId").val(),
            menuId: "",
            menuName: "",
            menuUrl: "",
            menuIcon: "",
            codeType: "C",
            useYn: "Y",
            modId: "",
            modDt: "",            
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
                (추가 클래스명)g 
            )

            (종류문자열) : "select", "check", "text"
            (최대길이) : 문자열로 입력할 것
        */
        // setColumn => field / headerName /  align / width / editable  / rowDrag       / hide
        // setColumn => DB명  / 헤더명      /  정렬  / 넓이  / 편집여부   / 행 드래깅 여부 / 숨김여부
        // setTagColumn => DB명 / 헤더명 / 정렬 / 너비 / 편집여부 / 콤보데이터(JSON) / type(select, dateonly, datetime, timeonly, check, radio) / JSON배열에서 가지고올 값 데이터 / JSON배열에서 가지고올 텍스트 데이터
        setGubunColumn(),   // 그리드 에디터 사용시(Create,Update,Delete)
        setColumn(["parentMenuId", "H_부모메뉴코드", "left", 100],[],true),
        setColumn(["menuId", "H_메뉴코드", "left", 100],[],true),
        setColumn(["menuName", "메뉴명", "left", 200],[true, [], true, "", "25"]),        
        setColumn(["menuUrl", "URL", "left", 200],[true, [], false, "", "50"]),
        setColumn(["menuIcon", "아이콘 클래스", "left", 160],[true]),
        setColumn(["codeType", "코드타입", "center", 100], [true, ["select", ${func:codeToJSON(pageContext, 'MENU_GUBN')}, "value", "text"]]),
        setColumn(["useYn", "사용여부", "center", 100], [true, ["select", ${func:codeToJSON(pageContext, 'USE_YN')}, "value", "text"], false, "", ""]),
        setColumn(["modId", "수정자", "center", 100]),
        setColumn(["modDt", "수정일시", "center", 200])
    ];

    // 그리드 옵션
    var _gridHelper = new initGrid(columnDefs, false, createNewRowData);
    var gridOptions = _gridHelper.setGridOption();

	function loadTableData(isMsg) {
		if (isMsg === undefined) isMsg = true;
		var frm = $("#frmMain");
		frm.addParam("func", "IQ");
        frm.addParam("query_id", "sys.menu.select_tree");
        frm.addParam("dataType", "json");
    	if (isMsg === false) {
    		frm.addParam("afterAction", false);
    	}
		frm.request();
    }

    function handleIQ(data, textStatus, jqXHR) {
        treeObj.refresh(data);
    }

	function loadTableData2(isMsg) {
		if (isMsg === undefined) isMsg = true;
        var frm = $("#frmMain");
        //---- 그리드 조회 시 필수요소 start
        frm.addParam("result", $("#myGrid"));       // 그리드 태그
        frm.addParam("grid", "gridOptions");        // 그리드 옵션
        frm.addParam("baseData", "_ogringData");    // 그리드 원본 데이터 저장 변수
        //---- 그리드 조회 시 필수요소 end
		frm.addParam("func", "IQ2");
        frm.addParam("query_id", "sys.menu.select_list");
        frm.addParam("dataType", "json");           // 그리드 불러오는 타입 (기본 json)
    	if (isMsg === false) {
    		frm.addParam("afterAction", false);
    	}
		frm.request();
    }

    function handleIQ2(data, textStatus, jqXHR){
        treeCount++;
    }

    function saveData() {
		var frm = $("#frmMain");
        frm.serializeArrayCustom();
        frm.addParam("func", "IS");
        frm.addParam("max_idx",(_gridHelper.getAllGridData().length+1));
        frm.addParam("query_id", "sys.menu.grid_data");
        frm.addParam("query_key", "sys.menu.select_newKey");   // 키값 자동 생성 쿼리
        //frm.addParam("query_order", "sys.menu.update_eachMenuOrder");   // 키값 자동 생성 쿼리
        frm.addParam("key_col", "newMenuId");      // 키값 컬럼명(그리드인 경우에 grd_ 를 붙여야 함)
        frm.addParam("dataType", "json");
        frm.addParam("enc_col", "userId");
        frm.addParam("grid", "gridOptions"); // 저장할 그리드의 그리드옵션 변수명
		frm.request();
    }

    function handleIS(data, textStatus, jqXHR){
        if(data.count> 0) {
        	updateMenuOrder();
        }
    }
    
    function updateMenuOrder() {
        var frm = $("#frmMain");
		frm.addParam("func", "UP");
        frm.addParam("query_id", "sys.menu.update_menuOrder");
        frm.addParam("enc_col", "userId");
        frm.addParam("dataType", "json");           // 그리드 불러오는 타입 (기본 json)
        frm.addParam("afterAction", false);
		frm.request();
    }

    function handleUP(data, textStatus, jqXHR){
        $("#hMenuId").val("");
        loadTableData(false);
        loadTableData2(false);
    }

    // 트리 클릭 이벤트
    function treeClickEvent(event, data) {
        $("#hMenuId").val(data.node.key);
        loadTableData2();
    }

    function dndFinishEvent(node, data) {
        if(confirm("메뉴를 이동시키시겠습니까?")) {
            data.otherNode.moveTo(node, data.hitMode);  // 화면상으로 우선 옮김
            var currNode = treeObj.getAllChildNode(data.otherNode.key); // 옮긴 후의 노드 정보를 다시 불러옴

            // 1. 옮긴 노드가 4를 초과하면 불가
            // 2. 옮긴 노드의 모든 하위 노드 중 4를 초과하는 노드가 있으면 불가

            var chk1 = currNode.getLevel() > 4;
            var chk2 = !checkChildNodeLevel(currNode, 4, currNode.getLevel());

            if(chk1 || chk2) {
                notifyDanger("메뉴 단수가 3을 초과하기 때문에 옮길 수 없습니다.")
                if(treeObj.dndBeforeCurrentNodeIndex < 2) {
                    currNode.moveTo(treeObj.getAllChildNode(treeObj.dndBeforeParentNodeId), "firstChild");
                } else {
                    currNode.moveTo(treeObj.getAllChildNode(treeObj.dndBeforeParentNodeId).children[treeObj.dndBeforeCurrentNodeIndex - 2], "after");
                }
            } else {
                saveDndData(currNode.parent.key, currNode.key);
            }
        }
    }

    // 하위 노드들 중 최고 레벨이 초과하는 경우 false, 아니면 true 리턴 (재귀함수 사용)
    function checkChildNodeLevel(p_Node, p_MaxLevel, p_StartLevel) {
        if(p_Node.children != null) {
            for(var i = 0; i < p_Node.children.length; i++) {
                if(p_StartLevel + 1 > p_MaxLevel) {
                    return false;
                }
                if(!checkChildNodeLevel(p_Node.children[i], p_MaxLevel, p_StartLevel + 1)) {
                    return false;
                }
            }
        }

        return true;
    }

    // 옮긴 후의 부모코드로 저장 처리하는 함수
    function saveDndData(p_ParentNodeId, p_ChangeNodeId) {
        var parentNode = treeObj.getAllChildNode(p_ParentNodeId);
        var menu_id = [];

        if(parentNode.children != null) {
            for(var i = 0; i < parentNode.children.length; i++) {
                menu_id.push(parentNode.children[i].key);
            }
        }

        var frm = $("#frmMain");
        frm.addParam("grd_menu_id[]", menu_id);           // 순서 정렬을 위한 메뉴 아이디들
        frm.addParam("menu_id", p_ChangeNodeId);            // 부모 메뉴가 바뀌는 메뉴 아이디
        frm.addParam("parent_menu_id", p_ParentNodeId);     // 드랍된 위치의 부모 아이디
        frm.addParam("func", "IS2");
        frm.addParam("enc_col", "userId");
		frm.setAction("<c:url value='/sys/menu.do' />");
        frm.addParam("dataType", "json");
		frm.request();
    }

    function handleIS2(data, textStatus, jqXHR){
        if(data.count> 0) {
            $("#hMenuId").val("");
            loadTableData();
            loadTableData2();
        }
    }

    $(function() {
        // 트리 선언
        treeObj = $("#treeDiv").initTree({
            "icon" : true,
            "expand" : true,
            "clickEvent" : treeClickEvent,
            "dnd" : true,
            "dndFinishEvent" : dndFinishEvent,
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
            $("#hMenuId").val("");
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
            //tree를 한번도 클릭하지 않았을시
            if(treeCount > 1){
                _gridHelper.onAddRow();
            }else{
                notifyDanger("메뉴를 선택해 주세요.");
            }
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
                    	<form:input id="hMenuId" caption="hMenuId" type="hidden" />
<%--                     	<form:input id="kMenuName" caption="메뉴명" addAttr="maxlength='25'" /> --%>
<%--                     	<form:select id="kUseYn" caption="사용여부" all="true" allLabel="전체" queryId="#use_yn"  /> --%>
                    </form>
				</div>
			<card:close />
		</div>
		<div class="col-xl-3 col-lg-3 col-md-3 col-sm-12 col-12">
			<card:open title="메뉴 리스트" />
				<card:toolButton title="">
				</card:toolButton>
				<card:content />
				<form:grid id="treeDiv" height="100%"/>
			<card:close />	
		</div>
		<div class="col-xl-9 col-lg-9 col-md-9 col-sm-12 col-12">
			<card:open title="상세 메뉴 리스트" />
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
