<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="form" uri="http://ad.its.yeongju.kr/jsp/jstl/form" %>
<%@ taglib prefix="card" uri="http://ad.its.yeongju.kr/jsp/jstl/card" %>
<%@ taglib prefix="func" uri="http://ad.its.yeongju.kr/jsp/jstl/func" %>

<%@ include file="../../core/include/head.jsp"%>
<%@ include file="../../core/include/header.jsp"%>


<script type="text/javascript">
	var columnDefs = [ 
			setColumn([ "roleId", "그룹코드", "left", 120 ]),
			setColumn([ "roleName", "그룹명", "left", 150 ]),
			setColumn([ "roleGubn", "그룹구분", "center", 100 ]) ];

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
			setGubunColumn(100, true),
			setColumn([ "includeValue", "포함여부", "center", 90 ], [ true,[ "check" ], false, "", "20" ], false, false, false, ""),
			setColumn([ "userId", "사용자 ID", "left", 120 ]),
			setColumn([ "userName", "사용자명", "left", 150 ]),
			setColumn([ "userEmail", "이메일", "left", 150 ]),
			setColumn([ "userPhone", "연락처", "left", 120 ]),
			setColumn([ "modId", "수정자", "center", 100 ]),
			setColumn([ "modDt", "수정일시", "center", 150 ]) ];

    columnDefs2 = setColumnMask(columnDefs2, "userPhone", "phone");

	// 그리드 옵션
	var _gridHelper = new initGrid(columnDefs, true);
	var gridOptions = _gridHelper.setGridOption();

	var _gridHelper2 = new initGrid(columnDefs2, true);
	var gridOptions2 = _gridHelper2.setGridOption();

	// 그리드 클릭 이벤트 추가
	_gridHelper.addRowClickEvent(gridRowClickEvent);

	// 그리드 클릭 이벤트 발생시 수행할 함수
	function gridRowClickEvent(event) {
		$("#hRoleId").val(event.data.roleId);
		loadTableData2();
	}

	function loadTableData(isMsg) {
		if (isMsg === undefined) isMsg = true;
		var frm = $("#frmMain");
		//---- 그리드 조회 시 필수요소 start
		frm.addParam("result", $("#myGrid")); // 그리드 태그
		frm.addParam("grid", "gridOptions"); // 그리드 옵션
		//---- 그리드 조회 시 필수요소 end
		frm.addParam("func", "IQ");
		frm.addParam("query_id", "sys.groupUser.select_groupList");
		frm.addParam("dataType", "json"); // 그리드 불러오는 타입 (기본 json)
		if (isMsg === false) {
			frm.addParam("afterAction", false);
		}
		frm.request();
	}

	function handleIQ(data, textStatus, jqXHR) {
		$("#hRoleId").val("");
		_gridHelper2.clearData();
	}

	function loadTableData2() {
		var frm = $("#frmMain");
		//---- 그리드 조회 시 필수요소 start
		frm.addParam("result", $("#myGrid2")); // 그리드 태그
		frm.addParam("grid", "gridOptions2"); // 그리드 옵션
		frm.addParam("baseData", "_origData2"); // 그리드 원본 데이터 저장 변수
		//---- 그리드 조회 시 필수요소 end
		frm.addParam("func", "IQ2");
		frm.addParam("query_id", "sys.groupUser.select_userList");
		frm.addParam("dataType", "json"); // 그리드 불러오는 타입 (기본 json)
		frm.addParam("afterAction", true);
		frm.request();
	}

	function handleIQ2(data, textStatus, jqXHR) {
	}

	function saveData() {
		var frm = $("#frmMain");
		frm.addParam("func", "IS");
		frm.addParam("dataType", "json");
		frm.addParam("hRoleId", $("#hRoleId").val());
		frm.addParam("query_id", "sys.groupUser.grid_data");
		frm.addParam("enc_col", "grd_userId[], userId")
		frm.addParam("grid", "gridOptions2"); // 저장할 그리드의 그리드옵션 변수명
		frm.request();
	}

	function handleIS(data, textStatus, jqXHR) {
		_gridHelper2.clearData();
		$("#hRoleId").val("");
		loadTableData(false);
		//loadTableData3();
	}

	$(function() {
		// 그리드 선언
		var eGridDiv = document.querySelector('#myGrid');
		var eGridDiv2 = document.querySelector('#myGrid2');

		// 그리드 옵션 초기화
		var gridObj1 = new agGrid.Grid(eGridDiv, gridOptions);
		var gridObj2 = new agGrid.Grid(eGridDiv2, gridOptions2);

		// 그리드 툴 버튼 바로 표시
		$("i.open-card-option").trigger("click");

		// 조회
		$("#btnSearch").click(function() {
			_gridHelper2.clearData();
			$("#hRoleId").val("");
			loadTableData();
		});

		// frmMain 자동조회
		$("#frmMain").autoSearch(loadTableData);

		// 저장
		$("#btnSave").click(function() {
			if ($("#hRoleId").val() == "") {
				notifyDanger("그룹을 선택해 주세요.");
				return;
			}
			if (confirm("저장하시겠습니까?")) {
				saveData();
			}
		});

		// 전체 포함
		$("#btnIncludeAll").click(function() {
			// 전체 체크 상태 변경 (컬럼명, 포함 여부(true:포함, false:미포함))
			_gridHelper2.changeCheckState("includeValue", true);
		});

		// 전체 미포함
		$("#btnExcludeAll").click(function() {
			// 전체 체크 상태 변경 (컬럼명, 포함 여부(true:포함, false:미포함))
			_gridHelper2.changeCheckState("includeValue", false);
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
                    	<form:input id="hRoleId" caption="hRoleId" type="hidden" />
                    	<form:select id="kRoleGubn" caption="그룹구분" all="true" allLabel="전체" queryId="#role_gubn" />
                    	<form:select id="kSearchGubn" caption="검색 구분" all="true" allLabel="전체" queryId="#role_search_gubn" />
                    	<form:input id="kSearchName" caption="검색어" addAttr="maxlength='20'" />
                    </form>
				</div>
			<card:close />
		</div>
		<div class="col-xl-4 col-lg-4 col-md-4 col-sm-12 col-12">
			<card:open title="그룹 리스트" />
				<card:toolButton title="">
				</card:toolButton>
				<card:content />
				<form:grid id="myGrid" />
			<card:close />
		</div>
		<div class="col-xl-8 col-lg-8 col-md-8 col-sm-12 col-12">
			<card:open title="사용자 리스트" />
				<card:toolButton title="">
					<form:button type="IncludeAll" id="btnIncludeAll" wrap="li" />
					<form:button type="ExcludeAll" id="btnExcludeAll" wrap="li" />
				</card:toolButton>
				<card:content />
				<form:grid id="myGrid2" />
			<card:close />
		</div>
	</div>
</div>

<%@ include file="../../core/include/footer.jsp"%>
