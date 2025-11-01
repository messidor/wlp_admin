<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="form" uri="http://ad.its.yeongju.kr/jsp/jstl/form" %>
<%@ taglib prefix="card" uri="http://ad.its.yeongju.kr/jsp/jstl/card" %>
<%@ taglib prefix="func" uri="http://ad.its.yeongju.kr/jsp/jstl/func" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%@ include file="../../core/include/head.jsp" %>
<%@ include file="../../core/include/header.jsp" %>

<script type="text/javascript">

	var _originData;
	
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
		setColumn(["boardId", "게시글ID", "center"], [], true),
		setColumn(["num", "번호", "center", 50], [false, ["index", "asc"]]),
		setColumn(["qGubn", "구분", "center", 50]),
		setColumn(["boardTitle", "제목", "left", 300]),
		setColumn(["parkingName", "주차장명", "left", 150]),
		setColumn(["carNo", "차량번호", "center", 80]),
		setColumn(["inoutDt", "입출차일시", "center", 200]),
		setColumn(["parkingPrice", "주차요금", "right", 100]),
		setColumn(["commentYnName", "답글여부", "center", 80]),
		setColumn(["regName", "작성자", "center", 80]),
		setColumn(["regDt", "작성일시", "center", 100]),
	];
	
	setColumnMask(columnDefs, "regDt", "datetime");
	
	// 그리드 옵션
	// 컬럼정의 / 화면에 그리드 맞추기 / 행추가 func
	var _gridHelper = new initGrid(columnDefs, true);
	var gridOptions = _gridHelper.setGridOption();
	
	
    _gridHelper.addRowDblClickEvent(function(event) {			
		OpenPopupSingle("/board/corporationInquiryPopup.do?boardId="+event.data.boardId, 920, 955, "_CIPop");
	});
	
	function loadTableData() {
		
		var kSearchDate = $("#kSearchDate").val();
		var kSearchArr = kSearchDate.split(" - ");
		
		var startDt = kSearchArr[0];
		var endDt = kSearchArr[1];
		
		var frm = $("#frmMain");
	    //---- 그리드 조회 시 필수요소 start
	    frm.addParam("result", $("#myGrid"));       // 그리드 태그
	    frm.addParam("grid", "gridOptions");        // 그리드 옵션
	    frm.addParam("baseData", "_originData");    // 그리드 원본 데이터 저장 변수
	    //---- 그리드 조회 시 필수요소 end
	    frm.addParam("func", "IQ");
	    frm.addParam("startDt", startDt);
		frm.addParam("endDt", endDt);
		frm.addParam("query_id", "board.corporationInquiry.Select_List");
		frm.addParam("enc_col", "kRegId");
	    frm.addParam("dataType", "json");           // 그리드 불러오는 타입 (기본 json)
		frm.request();
	}
	
	
	function handleIQ(data, textStatus, jqXHR) {}
	
	$(function() {
		// lookup the container we want the Grid to use
	    var eGridDiv = document.querySelector('#myGrid');
	
	    // create the grid passing in the div to use together with the columns & data we want to use
	    new agGrid.Grid(eGridDiv, gridOptions);
	    
	    $("#kSearchDate").initDateOnly("years", -1, "days", 0);
	    
	 	// frmMain 자동조회
	    $("#frmMain").autoSearch(loadTableData);
	    
	 	// 조회
	    $("#btnSearch").click(function(){
	        loadTableData();
	    });
	 	
	    loadTableData();
	
	});

</script>

<div class="page-body" style="font-size: 0.9em;">
	<div class="row">
		<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12"
			id="search_all_wrapper">
			<card:open title="검색조건" />
			<card:button>
				<form:button type="Search" id="btnSearch" />
			</card:button>
			<card:content />
			<div class="search-area col-lg-12">
				<form id="frmMain" name="frmMain" method="post" onsubmit="return false" class="form-material form-inline">
					<c:choose>  
						<c:when test="${fn:contains(user_role_id, 'MANAGE') || fn:contains(user_role_id, 'AD')}"> 
							<form:select id="kParkingGovCode" caption="관리기관" all="true" allLabel="전체" queryId="select.select_parkingGovInfo"/>
						</c:when> 
						<c:otherwise> 
							<form:select id="kParkingGovCode" caption="관리기관" all="false" allLabel="전체" queryId="select.select_parkingGovInfo"/>
						</c:otherwise>
					</c:choose>
					<form:input id="kSearchDate" caption="작성일자" addAttr="maxlength='20'" />
					<form:input id="kTitle" caption="제목" addAttr="maxlength='20'" />
					<form:input id="kRegId" caption="작성자" addAttr="maxlength='20'" />
					<form:select id="kGubn" caption="답글여부" all="true" allLabel="전체" queryId="#COMMENT_GUBN" />
				</form>
			</div>
			<card:close />
		</div>
		<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12">
			<card:open title="공단별 문의" />
			<card:toolButton title="">
			</card:toolButton>
			<card:content />
			<form:grid id="myGrid" />
			<card:close />
		</div>
	</div>
</div>
<%@ include file="../../core/include/footer.jsp"%>