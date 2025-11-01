<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="form" uri="http://ad.its.yeongju.kr/jsp/jstl/form" %>
<%@ taglib prefix="card" uri="http://ad.its.yeongju.kr/jsp/jstl/card" %>
<%@ taglib prefix="func" uri="http://ad.its.yeongju.kr/jsp/jstl/func" %>

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
		setColumn(["num", "번호", "center", 100], [false, ["index", "asc"]]),
		setColumn(["boardTitle", "제목", "left", 450]),
		setColumn(["popNotice", "팝업공지화면", "center", 140]),
		setColumn(["contentViewYn", "공지내용표시여부", "center", 140]),
		setColumn(["popNoticeOrder", "팝업공지순서", "center", 140]),
		setColumn(["popNoticeDate", "팝업공지기간", "center", 140]),
		setColumn(["userName", "작성자", "center", 140]),
		setColumn(["regDt", "작성일시", "center", 140])
	];
	  
	// 그리드 옵션
	// 컬럼정의 / 화면에 그리드 맞추기 / 행추가 func
	var _gridHelper = new initGrid(columnDefs, true);
	var gridOptions = _gridHelper.setGridOption();
	
	
    _gridHelper.addRowDblClickEvent(function(event) {			
		OpenPopupSingle("/board/announcementPopup.do?boardId="+event.data.boardId, 720, 960, "_Pop");
	});
	
	function loadTableData() {
		
		var frm = $("#frmMain");
	    //---- 그리드 조회 시 필수요소 start
	    frm.addParam("result", $("#myGrid"));       // 그리드 태그
	    frm.addParam("grid", "gridOptions");        // 그리드 옵션
	    frm.addParam("baseData", "_originData");    // 그리드 원본 데이터 저장 변수
	    //---- 그리드 조회 시 필수요소 end
	    frm.addParam("func", "IQ");

		frm.addParam("query_id", "board.announcement.Select_List");
	    frm.addParam("dataType", "json");           // 그리드 불러오는 타입 (기본 json)
		frm.request();
	}
	
	function handleIQ(data, textStatus, jqXHR) {}
	
	$(function() {
		// lookup the container we want the Grid to use
	    var eGridDiv = document.querySelector('#myGrid');
	
	    // create the grid passing in the div to use together with the columns & data we want to use
	    new agGrid.Grid(eGridDiv, gridOptions);
	    
	 	// frmMain 자동조회
	    $("#frmMain").autoSearch(loadTableData);
	    
	 	// 조회
	    $("#btnSearch").click(function(){
	        loadTableData();
	    });
	 	
	    $("#btnRegister").click(function(){
	    	OpenPopupSingle("/board/announcementPopup.do", 620, 960, "_Pop");
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
				<form:button type="Register" id="btnRegister" />
			</card:button>
			<card:content />
			<div class="search-area col-lg-12">
				<form id="frmMain" name="frmMain" method="post" onsubmit="return false" class="form-material form-inline">
					<form:input id="kTitle" caption="제목" addAttr="maxlength='20'" />
					<form:select id="kPopNotice" queryId="#POP_NOTICE" caption="팝업공지화면" all="true" allLabel="전체"/>
				</form>
			</div>
			<card:close />
		</div>
		<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12">
			<card:open title="공지사항" />
			<card:toolButton title="">
			</card:toolButton>
			<card:content />
			<form:grid id="myGrid" />
			<card:close />
		</div>
	</div>
</div>
<%@ include file="../../core/include/footer.jsp"%>