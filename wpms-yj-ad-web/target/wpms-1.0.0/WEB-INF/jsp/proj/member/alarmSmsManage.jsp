<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="form" uri="http://ad.its.yeongju.kr/jsp/jstl/form" %>
<%@ taglib prefix="card" uri="http://ad.its.yeongju.kr/jsp/jstl/card" %>
<%@ taglib prefix="func" uri="http://ad.its.yeongju.kr/jsp/jstl/func" %>

<%@ include file="../../core/include/head.jsp"%>
<%@ include file="../../core/include/header.jsp"%>

<script type="text/javascript">
	// 데이터 복원 시 사용할 원본 데이터 변수
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
			setColumn(["smsCode", "smsCode", "center", 90],[],true),
			setColumn(["resultDt", "resultDt", "center", 90],[],true),
			setColumn(["msgType", "msgType", "center", 90],[],true),
			setColumn(["memberId", "memberIdID", "center", 90],[],true),
			setColumn(["sendResult", "sendResult", "center", 90],[],true),
			setColumn(["no", "번호", "center", 60], [false, ["index", "desc"]]),
			setColumn(["regDt", "전송일시", "center", 120]),
			setColumn(["sendResultName", "전송결과", "center", 80]),
			setColumn(["sendPhone", "발신번호", "center", 100]),
			setColumn(["recvName", "수신자", "center", 180]),
			setColumn(["recvPhone", "수신번호", "center", 100]),
			setColumn(["msgTypeName", "전송구분", "center", 80]),
			setColumn(["msgContents", "메시지", "left", 700])
	];

	setColumnMask(columnDefs, "regDt", "datetime");
	setColumnMask(columnDefs, "recvPhone", "phone");
	setColumnMask(columnDefs, "sendPhone", "phone");

    var _gridHelper = new initGrid(columnDefs, true);
    var gridOptions = _gridHelper.setGridOption();
    gridOptions.pagination = true;
    
    _gridHelper.addRowDblClickEvent(function(event) {
   		OpenPopupSingle("/member/alarmSmsManagePopup.do?smsCode=" + event.data.smsCode, 1000, 605, "_Pop");
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
		frm.addParam("query_id", "member.alarmSmsManage.select_smsList");
		frm.addParam("dataType", "json"); // 그리드 불러오는 타입 (기본 json)
		frm.addParam("enc_col", "kRecvName");
		frm.addParam("startDate", replaceDate($("#kSendDate").val())[0]);
		frm.addParam("endDate", replaceDate($("#kSendDate").val())[1]); 
		frm.request();
	}

	function handleIQ(data, textStatus, jqXHR) {}

	$(function() {

		//일자
		$("#kSendDate").initDateOnly("days", 0, "days", 0);

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
                <form:button type="Send" id="btnSend" />
			</card:button>
			<card:content />
			<div class="search-area col-lg-12">
				<form id="frmMain" name="frmMain" method="post" onsubmit="return false" class="form-material form-inline">
					<form:input id="kSendDate" caption="전송일자" addAttr="maxlength='100'" />
					<form:input id="kRecvName" caption="수신자" addAttr="maxlength='20'" />
					<form:input id="kMsgContents" caption="메시지"/>
					<form:select id="kSmsType" caption="전송구분" all="true" allLabel="전체" queryId="#msg_type" />
					<form:select id="kSendResult" caption="SMS전송결과구분" all="true" allLabel="전체" queryId="#send_result" />
				</form>
			</div>
			<card:close />
		</div>
		<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12">
			<card:open title="알림톡/SMS 전송 목록" />
			<card:toolButton title="">
			</card:toolButton>
			<card:content />
			<form:grid id="myGrid" />
			<card:close />
		</div>
	</div>
</div>

<%@ include file="../../core/include/footer.jsp"%>
