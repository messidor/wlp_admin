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

	// 컬럼 옵션
	var columnDefs = [
		setColumn(["no", "번호", "center", 50], [false, ["index", "asc"]]),
		<c:if test="${fn:contains(user_role_id, 'MANAGE') || fn:contains(user_role_id, 'AD')}"> 
		setColumn(["pGovName", "관리기관", "left", 140]),
		</c:if>
		setColumn(["offCouponCode", "offCouponCode", "left", 100], [],true),
		setColumn(["offCouponName", "할인권명", "left", 140]),
		setColumn(["couponUseGubnName", "할인권구분", "center", 80]),
		setColumn(["discountGubnName", "적용구분", "center", 80]),
		setColumn(["discount", "시간/금액", "right", 80]),
	];
	setColumnMask(columnDefs, "discount", "number");
	
	// 컬럼 옵션
	var columnDefs2 = [
		setGubunColumn(0,true),
		setColumn(["includeValue", "포함여부", "center", 60], [true, ["check"], false, "", "20"]),
		setColumn(["parkingNo", "parkingNo", "left", 100], [],true),
		setColumn(["gugunName", "구역(시/군/구)", "center", 80]),
		setColumn(["parkingName", "주차장명", "left", 180]),
		setColumn(["regName", "등록자", "center", 80]),
		setColumn(["regDt", "등록일시", "center", 100]),
	];

	setColumnMask(columnDefs2, "regDt", "datetime");

	var _gridHelper = new initGrid(columnDefs, true);
	var gridOptions = _gridHelper.setGridOption();

	var _gridHelper2 = new initGrid(columnDefs2, true);
	var gridOptions2 = _gridHelper2.setGridOption();

	_gridHelper.addRowClickEvent(gridRowClickEvent);

	function gridRowClickEvent(event) {
		$("#hOffCouponCode").val(event.data.offCouponCode);
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
		frm.addParam("query_id", "market.offlineCouponParkingManage.select_offCouponList");
		frm.addParam("dataType", "json"); // 그리드 불러오는 타입 (기본 json)
		frm.request();
	}

	function handleIQ(data, textStatus, jqXHR) {
		$("#hOffCouponCode").val("");
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
		frm.addParam("query_id", "market.offlineCouponParkingManage.select_parkingList");
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
		frm.setAction("<c:url value='/market/offlineCouponParkingSave.do' />");
		frm.addParam("dataType", "json");
		frm.request();
	}

	function handleIS(data, textStatus, jqXHR) {
		if(data.count > 0){
			loadTableData2(false);
		}
	}

	$(function() {

		// lookup the container we want the Grid to use
		var eGridDiv = document.querySelector('#myGrid');
		var eGridDiv2 = document.querySelector('#myGrid2');

		// create the grid passing in the div to use together with the columns & data we want to use
		new agGrid.Grid(eGridDiv, gridOptions);
		new agGrid.Grid(eGridDiv2, gridOptions2);
		
		_gridHelper2.clearData(eGridDiv2);

		// 그리드 툴 버튼 바로 표시
		$("i.open-card-option").trigger("click");

		// 조회
		$("#btnSearch").click(function() {
			loadTableData();
		});

		$("#btnSave").click(function(){
			if($("#hOffCouponCode").val() == ""){
				alert("실물 할인권 목록을 선택하세요.");
				return;
			}
			
			// 변경된 행 체크
			var list = _gridHelper2.getAllGridData();
			
			/*
				전체포함/미포함 시 전체 state_col == "U" 상태로 변경되는 오류 방지하기 위해
				state_col == "U" 이라도, 포함여부가 이전데이터와 같으면 state_col = ""
			*/
			for(var i=0; i<list.length; i++){
				if(list[i].state_col == "U") {
					for(var j=0; j<_originData2.length; j++){
						if(list[i].parkingNo == _originData2[j].parkingNo && list[i].includeValue == _originData2[j].includeValue){
							list[i].state_col = "";
						}
					}
				}
			}
			
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
		
		$("#kParkingGovCode, #kOffCouponName").change(function() {
			loadTableData();
		});

		$("#kLocalGubn").change(function() {
			loadTableData2();
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
					<form:input id="hOffCouponCode" caption="hOffCouponCode" type="hidden" />
					<c:choose>  
						<c:when test="${fn:contains(user_role_id, 'MANAGE') || fn:contains(user_role_id, 'AD')}"> 
							<form:select id="kParkingGovCode" caption="관리기관" all="true" allLabel="전체" queryId="select.select_parkingGovInfo"/>
						</c:when> 
						<c:otherwise> 
							<form:select id="kParkingGovCode" caption="관리기관" all="false" allLabel="전체" queryId="select.select_parkingGovInfo"/>
						</c:otherwise>
					</c:choose>
					<form:input id="kOffCouponName" caption="할인권명" />
					<form:select id="kLocalGubn" caption="구역(시/군/구)" all="true" allLabel="전체" queryId="#RESION" />
				</form>
			</div>
			<card:close />
		</div>
		<div class="col-xl-6 col-lg-6 col-md-6 col-sm-12 col-12">
			<card:open title="실물 할인권 목록" />
			<card:toolButton title="">
			</card:toolButton>
			<card:content />
			<form:grid id="myGrid" />
			<card:close />
		</div>
		<div class="col-xl-6 col-lg-6 col-md-6 col-sm-12 col-12">
			<card:open title="주차장 목록" />
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
