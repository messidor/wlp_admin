<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="form" uri="http://ad.its.yeongju.kr/jsp/jstl/form"%>
<%@ taglib prefix="card" uri="http://ad.its.yeongju.kr/jsp/jstl/card"%>
<%@ taglib prefix="func" uri="http://ad.its.yeongju.kr/jsp/jstl/func"%>
<%@ taglib prefix="label" uri="http://ad.its.yeongju.kr/jsp/jstl/label" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%@ include file="../../core/include/head.jsp"%>
<%@ include file="../../core/include/header.jsp"%>

<script type="text/javascript">
	// 데이터 복원 시 사용할 원본 데이터 변수
	var _originData, _originData2;
	
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
	
	var min = [
		{value : "", text : "0분"},
		/* {value : "10", text : "10분"},
		{value : "20", text : "20분"},
		{value : "30", text : "30분"},
		{value : "40", text : "40분"},
		{value : "50", text : "50분"}, */
		{value : "60", text : "60분"},
		/* {value : "70", text : "70분"},
		{value : "80", text : "80분"},
		{value : "90", text : "90분"},
		{value : "100", text : "100분"},
		{value : "110", text : "110분"}, */
		{value : "120", text : "120분"},
	]

	// 컬럼 옵션
	var columnDefs = [
			setColumn(["no", "번호", "center", 50], [false, ["index", "asc"]]),
			setColumn(["parkingNo", "parkingNo", "left", 110], [],true),
			setColumn(["parkingName", "주차장명", "left", 150]),
			setColumn(["parkingGugun", "구역(시/군/구)", "center", 110], [false, ["select", ${func:codeToJSON(pageContext, 'RESION')}, "value", "text"], false, "", "20"], false, false, false, ""),	
	];

	// 컬럼 옵션
	var columnDefs2 = [
		
			setGubunColumn(40, false),
			setColumn(["includeValue", "포함여부", "center", 60], [true, ["check"], false, "", "20"]),
			setColumn(["reductionCode", "reductionCode", "left", 110], [],true),
			setColumn(["reductionName", "감면명", "left", 120]),
			/* setColumn(["reductionRate", "감면비율", "center", 50]), */
			setColumn(["reductionRate", "감면비율", "center", 60], [true, ["select", rating, "value", "text"], false, "", "20", includeChk], false, false, false, ""),
			/* setColumn(["reductionOpt","감면비고","center",50]), */
			setColumn(["freeHour", "무료시간", "center", 60], [true, ["select", min, "value", "text"], false, "", "20", includeChk], false, false, false, ""),
			setColumn(["addrChkYn", "주소확인여부", "center", 90], [true, ["select", ${func:codeToJSON(pageContext, 'USE_YN')}, "value", "text"], false, "", "20", includeChk], false, false, false, ""),
			setColumn(["applyCarKind", "감면적용차량종류", "center", 110], [true, ["select", ${func:codeToJSON(pageContext, 'APPLY_CAR_KIND')}, "value", "text"], false, "", "20"], false, false, false, ""),
	        setColumn(["applyRidingCnt", "승차정원확인여부", "center", 110], [true, ["select", ${func:codeToJSON(pageContext, 'APPLY_RIDING_CNT')}, "value", "text"], false, "", "20"], false, false, false, ""),
            setColumn(["regId", "등록자", "center", 90]),
		    setColumn(["regDt", "등록일시", "center", 100]),
	];

	setColumnMask(columnDefs2, "regDt", "datetime");

	function includeChk(_obj) {
        const index = _obj[0].__selecetedRowIndex;
        const row = _obj[0].getGridRowData(index);
        const api = _obj[0].__gridOption.api; 
        
//         if(row["includeValue"] == "N"){
//         	_gridHelper2.setGridData(index, "includeValue", "Y");
//         }
        _gridHelper2.setGridData(index, "state_col", "U");
    }

    var _gridHelper = new initGrid(columnDefs, true);
    var gridOptions = _gridHelper.setGridOption();

    var _gridHelper2 = new initGrid(columnDefs2, true);
    var gridOptions2 = _gridHelper2.setGridOption();

    _gridHelper.addRowClickEvent(gridRowClickEvent);

    function gridRowClickEvent(event) {
		$("#hParkingNo").val(event.data.parkingNo);

		loadTableData2();
	}

	function loadTableData() {

		var frm = $("#frmMain");
		frm.serializeArrayCustom();
		//---- 그리드 조회 시 필수요소 start
		frm.addParam("result", $("#myGrid")); // 그리드 태그
		frm.addParam("grid", "gridOptions"); // 그리드 옵션
		frm.addParam("baseData", "_originData"); // 그리드 원본 데이터 저장 변수
		//---- 그리드 조회 시 필수요소 end
		frm.addParam("func", "IQ");
		frm.addParam("query_id", "park.parkingReductionManage.select_parkingList");
		frm.addParam("dataType", "json"); // 그리드 불러오는 타입 (기본 json)

		frm.request();
	}

	function handleIQ(data, textStatus, jqXHR) {
		$("#hParkingNo").val("");
		_gridHelper2.clearData();
	}

	function loadTableData2(isMsg) {
		if (isMsg === undefined) isMsg = true;
		var frm = $("#frmMain");
		frm.serializeArrayCustom();
		//---- 그리드 조회 시 필수요소 start
		frm.addParam("result", $("#myGrid2")); // 그리드 태그
		frm.addParam("grid", "gridOptions2"); // 그리드 옵션
		frm.addParam("baseData", "_originData2"); // 그리드 원본 데이터 저장 변수
		//---- 그리드 조회 시 필수요소 end
		frm.addParam("func", "IQ2");
		frm.addParam("query_id", "park.parkingReductionManage.select_parkingReductionList");
		frm.addParam("dataType", "json"); // 그리드 불러오는 타입 (기본 json)
		if (isMsg === false) {
			frm.addParam("afterAction", false);
		}
		frm.request();
	}

	function handleIQ2(data, textStatus, jqXHR) {
		gridOptions2.api.sizeColumnsToFit();
	}

	function saveData() {
		var frm = $("#frmMain");
		frm.serializeArrayCustom();
		frm.addParam("func", "IS");
		frm.addParam("grid", "gridOptions2"); // 그리드 옵션
		frm.addParam("enc_col", "userId");
		frm.setAction("<c:url value='/park/parkReduction.do' />");
		frm.addParam("dataType", "json");
		frm.request();
	}

	function handleIS(data, textStatus, jqXHR) {
		if(data.count > 0){
			loadTableData2();
		}
	}

	function loadComboData() {
		var frm = $("#frmMain");
		frm.addParam("func", "IQCombo");
		frm.addParam("kParkingGovCode", $("#kParkingGovCode").val());
		frm.addParam("queryId", "select.select_parkingInfo2");
		frm.addParam("afterAction", false);
		frm.request();
	}
	
	function handleIQCombo(data, textStatus, jqXHR) {
		$("#kParkingNo option[value!='']").remove();
		$.each(data, function(k, v) {
			$("#kParkingNo").append("<option value='" + v.value + "'>" + v.text + "</option>");			
		});
		loadTableData();
	}

	$(function() {

		// lookup the container we want the Grid to use
		var eGridDiv = document.querySelector('#myGrid');
		var eGridDiv2 = document.querySelector('#myGrid2');

		// create the grid passing in the div to use together with the columns & data we want to use
		new agGrid.Grid(eGridDiv, gridOptions);
		new agGrid.Grid(eGridDiv2, gridOptions2);
		
		_gridHelper2.clearData(eGridDiv2);

		// frmMain 자동조회
		// $("#frmMain").autoSearch(loadTableData);

		// 조회
		$("#btnSearch").click(function() {
			loadTableData();
		});

		$("#btnSave").click(function(){
			// 주차장을 선택했는지 확인
			if($("#hParkingNo").val() == ""){
				alert("주차장 목록을 선택하세요.");
				return;
			}
			
			// 변경된 행 체크
			var list = _gridHelper2.getAllGridData();
			var bool = false;
			for(var i=0; i<list.length; i++){
				if(list[i].state_col == "U") {
					bool = true;
					break;
				}
			}
			
			if(bool) {
				if(confirm("저장하시겠습니까?")) {
			        saveData();
			    }
			} else {
				alert("변경된 행이 없습니다.");
			}
		});

		$("#kParkingGovCode").change(function() {
			loadComboData();
		});

		$("#kParkingNo,#kLocalGubn").change(function() {
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
                <form:button type="Save" id="btnSave" />
			</card:button>
			<card:content />
			<div class="search-area col-lg-12">
				<form id="frmMain" name="frmMain" method="post" onsubmit="return false" class="form-material form-inline">
					<form:input id="hParkingNo" caption="hParkingNo" type="hidden" />
					<c:choose>  
						<c:when test="${fn:contains(user_role_id, 'MANAGE') || fn:contains(user_role_id, 'AD')}"> 
							<form:select id="kParkingGovCode" caption="관리기관" all="true" allLabel="전체" queryId="select.select_parkingGovInfo"/>
							<form:select id="kParkingNo" caption="주차장" all="true" allLabel="전체" queryId="select.select_parkingInfo"/>
						</c:when> 
						<c:otherwise> 
							<form:select id="kParkingGovCode" caption="관리기관" all="false" allLabel="전체" queryId="select.select_parkingGovInfo"/>
							<form:select id="kParkingNo" caption="주차장" all="true" allLabel="전체" queryId="select.select_parkingInfo"/>
						</c:otherwise>
					</c:choose>
					<form:select id="kLocalGubn" caption="구역(시/군/구)" all="true" allLabel="전체" queryId="#RESION" />
				</form>
			</div>
			<card:close />
		</div>
		<div class="col-xl-4 col-lg-4 col-md-4 col-sm-12 col-12">
			<card:open title="주차장 목록" />
			<card:toolButton title="">
			</card:toolButton>
			<card:content />
			<form:grid id="myGrid" />
			<card:close />
		</div>
		<div class="col-xl-8 col-lg-8 col-md-8 col-sm-12 col-12">
			<card:open title="감면 목록" />
			<card:toolButton title="">
			</card:toolButton>
			<card:content />
			<form:grid id="myGrid2" />
			<card:close />
		</div>
	</div>
</div>

<%@ include file="../../core/include/footer.jsp"%>
