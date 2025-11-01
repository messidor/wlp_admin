<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="form" uri="http://ad.its.yeongju.kr/jsp/jstl/form"%>
<%@ taglib prefix="card" uri="http://ad.its.yeongju.kr/jsp/jstl/card"%>
<%@ taglib prefix="func" uri="http://ad.its.yeongju.kr/jsp/jstl/func"%>
<%@ taglib prefix="label" uri="http://ad.its.yeongju.kr/jsp/jstl/label"%>

<%@ include file="../../core/include/head.jsp"%>
<%@ include file="../../core/include/headerPopup.jsp"%>

<script type="text/javascript">

	var userUrl = "${userUrl}";
	
	/* select_failCodeList */
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
		setGubunColumn(),
		setColumn(["chargeNo", "chargeNo", "center"], [], true),
		setColumn(["repayStatus", "repayStatus", "center"], [], true),
		setColumn(["pEntDt", "입차일시", "center", 160]),
		setColumn(["pOutDt", "출차일시", "center", 160]),
		setColumn(["parkingName", "주차장명", "left", 200]),  
		setColumn(["parkingPrice", "기주차요금", "right", 80]),
		setColumn(["newParkingPrice", "새로운요금", "right", 80], [true, [], true, "", "100", checkNewPrice]),
	];  
	     
	// 그리드 옵션
	// 컬럼정의 / 화면에 그리드 맞추기 / 행추가 func
	var _gridHelper = new initGrid(columnDefs, true);
	var gridOptions = _gridHelper.setGridOption();
	 
	setColumnMask(columnDefs, "parkingPrice", "number");
	setColumnMask(columnDefs, "newParkingPrice", "number");
	 
	function checkNewPrice(_obj) {
        const index = _obj[0].__selecetedRowIndex;
        const row = _obj[0].getGridRowData(index);
        const api = _obj[0].__gridOption.api; 
        
        if(parseInt(row["parkingPrice"]) < parseInt(row["newParkingPrice"])){

            api.setFocusedCell(index, "newParkingPrice");
            _gridHelper.setGridData(index, "newParkingPrice", parseInt(row["parkingPrice"]));
            _gridHelper.setGridData(index, "state_col", "");
            alert("새로운요금이 기주차요금을 초과하였습니다"); 
            return false;
        }

    }
	
	function outstandingData() {

		var frm = $("#frmMain");
		//---- 그리드 조회 시 필수요소 start
		frm.addParam("result", $("#myGrid")); // 그리드 태그
		frm.addParam("grid", "gridOptions"); // 그리드 옵션
		frm.addParam("baseData", "_originData"); // 그리드 원본 데이터 저장 변수
		//---- 그리드 조회 시 필수요소 end
		frm.addParam("func", "IQ_OutstandingData");
		frm.addParam("query_id", "pay.paymentManage.Select_RePayPopupList2");
		frm.addParam("dataType", "json"); // 그리드 불러오는 타입 (기본 json)
		frm.addParam("afterAction", true);
		frm.request();
	} 

	function handleIQ_OutstandingData(data, textStatus, jqXHR) {
		$("#myGrid").height(($(".card-block").eq(0).innerHeight()-40)*2+10);		
	}
	
	function loadTableData() {

		var frm = $("#frmMain");
		frm.addParam("func", "IQ");
		frm.addParam("query_id", "pay.paymentManage.Select_RePayPopupList2");
		frm.addParam("enc_col", "kMemberId");
	    frm.addParam("dataType", "json");           // 그리드 불러오는 타입 (기본 json)
		frm.request();
	}

	function handleIQ(data, textStatus, jqXHR) {
		if(data.length > 0) {
			$("#frmMain").formSet(data);
			outstandingData();
		}
	}

	function saveData() {
		//var newPay = $("#rePayPrice").val().replaceAll(",", "");
		
		var frm = $("#frmMain");
		frm.serializeArrayCustom();
		frm.addParam("func", "IS");
		frm.addParam("enc_col", "userId, kMemberId");
		//frm.addParam("newPay", newPay);
		frm.addParam("repayType", "M");
		frm.addParam("grid", "gridOptions.all"); // 저장할 그리드의 그리드옵션 변수명	
		frm.setAction("<c:url value='/payment/updateSuccessOutstanding.do' />");
		frm.addParam("dataType", "json");
		frm.request();
	}

	function handleIS(data, textStatus, jqXHR) {
		if(data.count > 0){
			self.close();
			opener.loadTableData();
		}
	}

	$(function(){
		
		var eGridDiv = document.querySelector('#myGrid');
		new agGrid.Grid(eGridDiv, gridOptions);
	 	
		// 그리드 툴 버튼 바로 표시
        $("i.open-card-option").trigger("click");
		
		$("#btnApproval").click(function() {
			
			var gridData = _gridHelper.getAllGridData();
	    	
	    	for(var i=0; i<gridData.length; i++){
	    		if(_gridHelper.getAllGridData()[i].newParkingPrice == "" || _gridHelper.getAllGridData()[i].newParkingPrice === null || _gridHelper.getAllGridData()[i].newParkingPrice === 0){
	    			alert("새로운 요금을 입력해 주세요.");
	    			gridOptions.api.setFocusedCell(i, "newParkingPrice");
	    			gridOptions.api.startEditingCell({
	                    rowIndex: i,
	                    colKey: "newParkingPrice"
	                });
	    			return;
	    		}
	    	}
	    	
			if(confirm("재결제하시겠습니까?")){
				saveData();
			}
		});

		$("#btnClose").click(function() {
			self.close();
		});
	
		// 그리드 행 복원
        $("body").on("click", "#toolUndo",function(){
            _gridHelper.onUndoSelected();
        });
		
		loadTableData();
	});
	
</script>

<div class="page-body" style="font-size: 0.9em;">
	<div class="row">
		<div class="col-12" id="search_all_wrapper">
			<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12">
				<card:open title="재결제" />
				<card:button>
				</card:button>
				<card:content />
				<form id="frmMain" name="frmMain" method="post" onsubmit="return false" class="form-horizontal">
					<form:input id="kChargeNo" type="hidden" value="${param.chargeNo}" />
					<form:input id="kMemberId" type="hidden" value="${param.memberId}" />
					<form:input id="payCode" type="hidden" />
					<form:input id="hPrice" type="hidden" />
					<form:input id="paySeq" type="hidden" />
					<form:input id="tId" type="hidden" />
					
					<div class="form-group col-xl-6 col-lg-6 col-md-6 col-sm-12 no-margin no-padding ">
		                <label class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right" style="width: 150px !important;">결제일시</label>
		                <div class="col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached" style="max-width: calc(100% - 150px);">
		                    <div class="input-group">
		                        <span class="input-group-addon"><i class="fas fa fa-eye" data-icon="fas fa fa-eye"></i></span>
		                        <input name="payDt" id="payDt" class="form-control text-left fill" type="text" value="" readonly="readonly">
		                    </div>
		                </div>
		            </div>
		            <div class="form-group  col-xl-6 col-lg-6 col-md-6 col-sm-12 no-margin no-padding ">
		                <label class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right" style="width: 150px !important;">입차일시</label>
		                <div class="col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached" style="max-width: calc(100% - 150px);">
		                    <div class="input-group">
		                        <span class="input-group-addon"><i class="fas fa fa-eye" data-icon="fas fa fa-eye"></i></span>
		                        <input name="pEntDt" id="pEntDt" class="form-control text-left fill" type="text" value="" readonly="readonly">
		                    </div>
		                </div>
		            </div>
					<div class="form-group  col-xl-6 col-lg-6 col-md-6 col-sm-12 no-margin no-padding ">
		                <label class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right" style="width: 150px !important;">출차일시</label>
		                <div class="col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached" style="max-width: calc(100% - 150px);">
		                    <div class="input-group">
		                        <span class="input-group-addon"><i class="fas fa fa-eye" data-icon="fas fa fa-eye"></i></span>
		                        <input name="pOutDt" id="pOutDt" class="form-control text-left fill" type="text" value="" readonly="readonly">
		                    </div>
		                </div>
		            </div>
					<div class="form-group  col-xl-6 col-lg-6 col-md-6 col-sm-12 no-margin no-padding ">
		                <label class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right" style="width: 150px !important;">차량번호</label>
		                <div class="col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached" style="max-width: calc(100% - 150px);">
		                    <div class="input-group">
		                        <span class="input-group-addon"><i class="fas fa fa-eye" data-icon="fas fa fa-eye"></i></span>
		                        <input name="carNo" id="carNo" class="form-control text-left fill" type="text" value="" readonly="readonly">
		                    </div>
		                </div>
		            </div>
					<div class="form-group  col-xl-6 col-lg-6 col-md-6 col-sm-12 no-margin no-padding ">
		                <label class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right" style="width: 150px !important;">이름</label>
		                <div class="col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached" style="max-width: calc(100% - 150px);">
		                    <div class="input-group">
		                        <span class="input-group-addon"><i class="fas fa fa-eye" data-icon="fas fa fa-eye"></i></span>
		                        <input name="memberName" id="memberName" class="form-control text-left fill" type="text" value="" readonly="readonly">
		                    </div>
		                </div>
		            </div>
					<div class="form-group  col-xl-6 col-lg-6 col-md-6 col-sm-12 no-margin no-padding ">
		                <label class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right" style="width: 150px !important;">주차장명</label>
		                <div class="col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached" style="max-width: calc(100% - 150px);">
		                    <div class="input-group">
		                        <span class="input-group-addon"><i class="fas fa fa-eye" data-icon="fas fa fa-eye"></i></span>
		                        <input name="parkingName" id="parkingName" class="form-control text-left fill" type="text" value="" readonly="readonly">
		                    </div>
		                </div>
		            </div> 
				</form>
				<card:close />
			</div>
		</div>
		<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12">
			<card:open title="재결재 요청 정보" />
				<card:toolButton title="">
					<form:button type="RowUndo" id="toolUndo" wrap="li" />
				</card:toolButton>
				<card:content />
				<form:grid id="myGrid"/>
			<card:close />
		</div>
	</div>
	<div class="row padding-left-10 padding-right-10">
		<div class="bottom-btn-area">
			<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12 text-right">
				<button type="button" id="btnApproval" class="btn btn-sm waves-effect waves-light btn-danger btn-outline-danger default">
				    <span class="icofont icofont-close"></span>
				    &nbsp;재결제
				</button>
				<form:button type="Close" id="btnClose" />
			</div>
			<label:clear />
		</div>
	</div>
</div>