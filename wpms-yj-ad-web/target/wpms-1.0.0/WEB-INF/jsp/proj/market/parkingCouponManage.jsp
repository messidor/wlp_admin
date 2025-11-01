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
    
	function createNewRowData() {
        var newData = {
       		state_col: "C",
       		couponCode: "",
       		parkingNo: $("#hParkingNo").val(),
       		couponUseGubn: "",
       		couponName: "",
       		discount: "",
       		couponPrice: 0,
       		useYn: "Y",
       		regName: "",
       		regDt: ""
        };
        return newData;
    }
	
	// 컬럼 옵션
	var columnDefs = [
			setColumn(["no", "번호", "center", 50], [false, ["index", "asc"]]),
			setColumn(["parkingNo", "parkingNo"], [], true),
			setColumn(["pGovName", "기관", "left", 160]),
			setColumn(["gugunName", "구역(시/군/구)", "center", 100]),
			setColumn(["parkingName", "주차장명", "left", 150]),
	];

	// 컬럼 옵션
	var columnDefs2 = [
			setGubunColumn(60),
			setColumn(["couponCode", "couponCode", 80], [], true),
			setColumn(["parkingNo", "parkingNo", 100], [], true),
			setColumn(["couponUseGubn", "할인권구분", "center", 100], [true, ["select", ${func:codeToJSON(pageContext, 'COUPON_USE_GUBN')}, "value", "text"], true, "", "20"], false, false, false, ""),
			setColumn(["couponName", "할인권명", "left", 180], [true, [], true, "", "20"]), 
			setColumn(["discountGubn", "적용구분", "center", 100],[true, ["select", ${func:codeToJSON(pageContext, 'DISCOUNT_GUBN')}, "value", "text"], true, "", "", checkInputValue]),
			setColumn(["discount", "시간/금액", "right", 100],[true, "text", true, "string", "0", checkInputValue]),
			setColumn(["couponPrice", "판매금액", "right", 80], [true, [], false, "", "11"]), 
			setColumn(["useYn", "사용여부", "center", 80], [true, ["select", ${func:codeToJSON(pageContext, 'USE_YN')}, "value", "text"], false, "", "20"], false, false, false, ""),
            setColumn(["modName", "수정자", "center", 100]),
		    setColumn(["modDt", "수정일시", "center", 140]),
	];
	setColumnMask(columnDefs2, "discount", "number");
	setColumnMask(columnDefs2, "couponPrice", "number");
	setColumnMask(columnDefs2, "modDt", "datetime");


    var _gridHelper = new initGrid(columnDefs, true);
    var gridOptions = _gridHelper.setGridOption();

    var _gridHelper2 = new initGrid(columnDefs2, true, createNewRowData);
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
		frm.addParam("query_id", "market.parkingCouponManage.select_parkingList");
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
		frm.addParam("query_id", "market.parkingCouponManage.select_parkingCouponList");
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
		frm.setAction("<c:url value='/market/parkingCouponSave.do' />");
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
	
	// 적용구분 - 시간/금액 연계
	function checkInputValue(params) {
	    let discountValue = parseInt(params[0].__gridOption.row["discount"], 10);
	    discountValue = isNaN(discountValue) ? 0 : discountValue;
	    
	    if(!findDiscountValue(params[0].__gridOption.row["discountGubn"], discountValue)) {
	        // 할인 구분에 맞는 공통코드값이 없으면 0으로 세팅 처리
	        _gridHelper2.setGridData(params[0].__gridOption.rowNode.rowIndex, "discount", "0", false);
	        alert("※ 시간/금액 입력 가능 범위 (숫자만 입력 가능)\n- 시간 입력가능 범위 : 30분 단위\n- 금액 입력가능 범위 : 100원 단위");
	    }
	}

	// 할인 구분에 따라 30분 배수인지 100원 배수인지 확인
	function findDiscountValue(discountGubn, discountValue) {
	    if(discountGubn == "M" && discountValue % 30 > 0){
	    	return false;
	    } else if(discountGubn == "P" && discountValue % 100 > 0) {
	    	return false;
	    }
	    
	    return true;
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
		
     	// 그리드 행 추가
        $("body").on("click", "#toolInsert",function(){
        	if($("#hParkingNo").val() == ""){
        		alert("주차장을 선택해주세요");
        		return;
        	}
        	_gridHelper2.onAddRow();
        });

        // 그리드 행 삭제
        $("body").on("click", "#toolDelete",function(){
        	if($("#hParkingNo").val() == ""){
        		alert("주차장을 선택해주세요");
        		return;
        	}
        	_gridHelper2.onRemoveSelected();
        });

        // 그리드 행 복원
        $("body").on("click", "#toolUndo",function(){
        	if($("#hParkingNo").val() == ""){
        		alert("주차장을 선택해주세요");
        		return;
        	}
            _gridHelper2.onUndoSelected();
        });

		// 조회
		$("#btnSearch").click(function() {
			loadTableData();
		});

		$("#btnSave").click(function(){
			if($("#hParkingNo").val() == ""){
        		alert("주차장을 선택해주세요");
        		return;
        	}
			
	    	var list = _gridHelper2.getAllGridData();
	    	
	    	for(var i=0; i<list.length; i++){
	    		
	    		// 할인권구분 입력 체크
	    		if(list[i].couponUseGubn == "" || list[i].couponUseGubn == undefined) {
	    			alert("할인권구분을 선택해주세요.");
    				return;
	    		}
	    		
	    		// 할인권명 입력 체크
	    		if(list[i].couponName.trim() == "") {
	    			alert("할인권명을 입력해주세요.");
    				return;
	    		}
	    		
	    		// 적용구분 입력 체크
	    		if(list[i].discountGubn == "" || list[i].discountGubn == undefined) {
	    			alert("적용구분을 선택해주세요.");
    				return;
	    		}
	    		// 판매금액은 0원 가능
	    		
	    		// 시간/금액 입력 체크
	    		if(list[i].discount == "" || list[i].discount, 10 == undefined) {
	    			alert("시간/금액을 입력해주세요.");
    				return;
	    		}
	    		
	    		if(parseInt(list[i].discount, 10) < 1) {
	    			alert("시간/금액을 입력해주세요.");
    				return;
    				
	    		}
	    	}
	    	
		    if(confirm("저장하시겠습니까?")) {
		        saveData();
		    }
		});

		$("#kParkingGovCode").change(function() {
			loadComboData();
		});

		$("#kParkingNo").change(function() {
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
			<card:open title="주차장별 할인권 목록" />
			<card:toolButton title="L00087">
					<form:button type="RowAdd" id="toolInsert" wrap="li" />
					<form:button type="RowDel" id="toolDelete" wrap="li" />
					<form:button type="RowUndo" id="toolUndo" wrap="li" />
				</card:toolButton>
			<card:content />
			<form:grid id="myGrid2" />
			<card:close />
		</div>
	</div>
</div>

<%@ include file="../../core/include/footer.jsp"%>
