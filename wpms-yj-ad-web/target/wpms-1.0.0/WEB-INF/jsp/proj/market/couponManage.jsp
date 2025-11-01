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
	var _originData;
	
	// 컬럼 옵션
	var columnDefs = [
			setColumn(["no", "번호", "center", 50], [false, ["index", "asc"]]),
			setColumn(["pGovName", "기관", "left", 260]),
			setColumn(["parkingName", "주차장명", "left", 240]),
			setColumn(["couponMemberId", "ID", "left", 100]),
			setColumn(["couponMemberName", "주차권관리자", "center", 100]),
			setColumn(["memberPhone", "휴대폰번호", "center", 100]),
			setColumn(["memberEmail", "이메일", "left", 120]),
			setColumn(["address", "주소", "left", 250]),
			setColumn(["useYn", "사용여부", "center", 70], [false, ["select", ${func:codeToJSON(pageContext, 'USE_YN')}, "value", "text"], false, "", "20"], false, false, false, ""),
			setColumn(["regDt", "가입일시", "center", 120]),
	];
	
	setColumnMask(columnDefs, "memberPhone", "phone");
	setColumnMask(columnDefs, "regDt", "datetime");

    var _gridHelper = new initGrid(columnDefs, true);
    var gridOptions = _gridHelper.setGridOption();

	// 그리드 클릭 이벤트 추가
	_gridHelper.addRowDblClickEvent(gridRowClickEvent);
	
	// 그리드 클릭 이벤트 내용
	function gridRowClickEvent(event) {
		OpenPopupSingle("/market/couponManagePopup.do?couponMemberId=" + event.data.couponMemberId, 1200, 640, "_PopCouponManagePopup");
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
		frm.addParam("enc_col", "kMemberName , kMemberPhone");
		frm.addParam("query_id", "market.couponManage.select_couponMemberList");
		frm.addParam("dataType", "json"); // 그리드 불러오는 타입 (기본 json)
		frm.request();
	}

	function handleIQ(data, textStatus, jqXHR) {
		gridOptions.api.sizeColumnsToFit();
	}

	function loadComboData() {
		var frm = $("#frmMain");
		frm.addParam("func", "IQCombo");
		frm.addParam("kParkingGovCode", $("#kParkingGovCode").val());
		frm.addParam("apiVerGubn", "2");
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
	
    function validation(){
    	var gridAllData = _gridHelper.getAllGridData();
		var bool = false;
		
    	for(var i=0; i<gridAllData.length; i++){
    		if(gridAllData[i]["state_col"] == "U"){
    			bool = true;		
    		}
    	}
    	
    	return bool;
    }

	$(function() {

		// lookup the container we want the Grid to use
		var eGridDiv = document.querySelector('#myGrid');

		// create the grid passing in the div to use together with the columns & data we want to use
		new agGrid.Grid(eGridDiv, gridOptions);

		// frmMain 자동조회
		// $("#frmMain").autoSearch(loadTableData);

		// 조회
		$("#btnSearch").click(function() {
			loadTableData();
		});

		$("#kParkingGovCode").change(function() {
			loadComboData();
		});

		$("#kParkingNo, #kMemberName, #kMemberPhone, #kUseYn").change(function() {
			loadTableData();
		});
		
		loadComboData();
	});
</script>


<div class="page-body" style="font-size: 0.9em;">
	<div class="row">
		<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12"
			id="search_all_wrapper">
			<card:open title="검색 조건" />
			<card:button>
				<form:button type="Search" id="btnSearch" />
			</card:button>
			<card:content />
			<div class="search-area col-lg-12">
				<form id="frmMain" name="frmMain" method="post" onsubmit="return false" class="form-material form-inline">
					<form:input id="hCouponMemberId" caption="hCouponMemberId" type="hidden" />
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
					<form:input id="kMemberName" caption="주차권관리자" addAttr="maxlength='110'" />
					<form:input id="kMemberPhone" caption="휴대폰번호" addAttr="maxlength='110'" />
					<form:select id="kUseYn" caption="사용여부" all="true" allLabel="전체" queryId="#use_yn" value="Y" />
				</form>
			</div>
			<card:close />
		</div>
		<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12">
			<card:open title="주차권관리자 목록" />
			<card:toolButton title="">
			</card:toolButton>
			<card:content />
			<form:grid id="myGrid" />
			<card:close />
		</div>
	</div>
</div>

<%@ include file="../../core/include/footer.jsp"%>
