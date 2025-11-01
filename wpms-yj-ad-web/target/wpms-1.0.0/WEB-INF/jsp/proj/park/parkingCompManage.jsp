<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="form" uri="http://ad.its.yeongju.kr/jsp/jstl/form"%>
<%@ taglib prefix="card" uri="http://ad.its.yeongju.kr/jsp/jstl/card"%>
<%@ taglib prefix="func" uri="http://ad.its.yeongju.kr/jsp/jstl/func"%>
<%@ taglib prefix="label" uri="http://ad.its.yeongju.kr/jsp/jstl/label" %>

<%@ include file="../../core/include/head.jsp"%>
<%@ include file="../../core/include/header.jsp"%>

<script type="text/javascript">
	// 데이터 복원 시 사용할 원본 데이터 변수
	var _originData, _originData2;

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

			setColumn(["no", "번호", "center", 60], [false, ["index", "asc"]]),
			setColumn(["pCompName", "회사명", "left", 110]),
			setColumn(["pCompTel", "전화번호", "center", 90]),
			setColumn(["address", "주소", "left", 300]),
			setColumn(["pManager", "담당자", "CENTER", 80]),
			setColumn(["pManagerPhone", "담당자연락처", "center", 90]),
			setColumn(["useYnName", "사용여부", "center", 70]),
            setColumn(["modId", "수정자", "center", 60]),
		    setColumn(["modDt", "수정일시", "center", 100]),
	];

	setColumnMask(columnDefs, "pCompTel", "phone");
	setColumnMask(columnDefs, "pManagerPhone", "phone");
	setColumnMask(columnDefs, "modDt", "datetime");

    var _gridHelper = new initGrid(columnDefs, true);
    var gridOptions = _gridHelper.setGridOption();

	_gridHelper.addRowDblClickEvent(function(event) {
   		OpenPopupSingle("/park/parkingCompManagePopup.do?pCompCode=" + event.data.pCompCode, 1200, 520, "_Pop4");
	});

	function loadTableData() {
		var frm = $("#frmMain");
		frm.serializeArrayCustom();
		//---- 그리드 조회 시 필수요소 start
		frm.addParam("result", $("#myGrid")); // 그리드 태그
		frm.addParam("grid", "gridOptions"); // 그리드 옵션
		frm.addParam("baseData", "_originData"); // 그리드 원본 데이터 저장 변수
		//---- 그리드 조회 시 필수요소 end
		frm.addParam("func", "IQ");
		frm.addParam("enc_col", "kSearchManager");
		frm.addParam("query_id", "park.parkingCompManage.select_compList");
		frm.addParam("dataType", "json"); // 그리드 불러오는 타입 (기본 json)
		frm.request();
	}

	function handleIQ(data, textStatus, jqXHR) {
		if($("#kUseYn").val() == ""){
			gridOptions.columnApi.setColumnVisible('useYnName', true);
		}else{
			gridOptions.columnApi.setColumnVisible('useYnName', false);
		}
		gridOptions.api.sizeColumnsToFit();

	}
	
	$(function() {

		// lookup the container we want the Grid to use
		var eGridDiv = document.querySelector('#myGrid');

		// create the grid passing in the div to use together with the columns & data we want to use
		new agGrid.Grid(eGridDiv, gridOptions);

		// frmMain 자동조회
		$("#frmMain").autoSearch(loadTableData);

		// 조회
		$("#btnSearch").click(function() {
			loadTableData();
		});

		// 등록
		$("#btnRegister").click(function() {
			OpenPopupSingle("/park/parkingCompManagePopup.do", 1200, 520, "_Pop");
		});
		

		loadTableData();
	});
</script>


<div class="page-body" style="font-size: 0.9em;">
	<div class="row">
		<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12"
			id="search_all_wrapper">
			<card:open title="검색 조건" />
			<card:button>
				<form:button type="Search" id="btnSearch" />
                <form:button type="Register" id="btnRegister" />
			</card:button>
			<card:content />
			<div class="search-area col-lg-12">
				<form id="frmMain" name="frmMain" method="post" onsubmit="return false" class="form-material form-inline">
					<form:input id="kSearchName" caption="회사명"/>
					<form:input id="kSearchManager" caption="담당자"/>
					<form:select id="kUseYn" caption="사용여부" all="true" allLabel="전체" queryId="#use_yn" value="Y" />
				</form>
			</div>
			<card:close />
		</div>
		<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12">
			<card:open title="주차장 회사 목록" />
			<card:toolButton title="">
			</card:toolButton>
			<card:content />
			<form:grid id="myGrid" />
			<card:close />
		</div>
	</div>
</div>

<%@ include file="../../core/include/footer.jsp"%>
