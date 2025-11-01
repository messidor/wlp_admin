<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="form" uri="http://ad.its.yeongju.kr/jsp/jstl/form"%>
<%@ taglib prefix="card" uri="http://ad.its.yeongju.kr/jsp/jstl/card"%>
<%@ taglib prefix="func" uri="http://ad.its.yeongju.kr/jsp/jstl/func"%>
<%@ taglib prefix="label" uri="http://ad.its.yeongju.kr/jsp/jstl/label"%>

<%@ include file="../../core/include/head.jsp"%>
<%@ include file="../../core/include/headerPopup.jsp"%>

<script type="text/javascript">
	
	var _originData;

	var userUrl = "${userUrl}";
	
	// 컬럼 조건에 따른 에디팅 여부
    function codeEditFunc(_params){
        if(_params.data.repayStatus === "B" || _params.data.repayStatus === "C"){
            return false;
        }
        else{
            return true;
        }
    }
	
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
		setColumn(["pEntDt", "입차일시", "center", 130]),
		setColumn(["pOutDt", "출차일시", "center", 130]),
		setColumn(["parkingName", "주차장명", "left", 140]),  
		setColumn(["parkingPrice", "기주차요금", "right", 120]),
		setColumn(["newParkingPrice", "새로운요금", "right", 120], [codeEditFunc, [], true, "", "100", checkNewPrice]),
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
		frm.addParam("query_id", "pay.repaymentManage.Select_PopupList2");
		frm.addParam("dataType", "json"); // 그리드 불러오는 타입 (기본 json)
		frm.addParam("afterAction", true);
		frm.request();
	} 

	function handleIQ_OutstandingData(data, textStatus, jqXHR) {
		if("${param.repayStatus}" == "B"){
			$("#myGrid").height(($(".card-block").eq(0).innerHeight()*3)-60);
		}else{
			$("#myGrid").height($(".card-block").eq(0).innerHeight()-40);
		}
		if(data.length > 0) {
            // chargeNo check
            let cnStr = "";
            for(let i = 0; i < data.length; i++) {
                if(cnStr != "") {
                    cnStr += ",";
                }
                cnStr += "'" + data[i].chargeNo + "'";
            }
            $("#kChargeNo").val(cnStr);
		}
	}
	 
	function loadTableData() {
		
		var frm = $("#frmMain");
		frm.addParam("func", "IQ");
		frm.addParam("query_id", "pay.repaymentManage.Select_PopupList2");
		frm.addParam("enc_col", "kMemberId");
	    frm.addParam("dataType", "json");           // 그리드 불러오는 타입 (기본 json)
		frm.request();
	}
	
	function handleIQ(data, textStatus, jqXHR) {
		if(data.length > 0) {
			
			$("#frmMain").formSet(data);
			outstandingData();
			if("${param.repayStatus}" != "A"){
				$("#reqReason").attr("readonly", true);
				$("#reqReason").siblings("span").children("i").removeClass();
				$("#reqReason").siblings("span").children("i").addClass("fas fa-eye");
				$("#reqReason").siblings("span").children("i").data("icon", "fas fa-eye");
				$("#reqReason").css("background-color", "#EEEEEE");
				// 승인
				if(data[0].repayStatus == "B"){
					$(".card-header-right").hide();
					$("#reqReason").parent("div").parent("div").parent("div").css("display", "none");
					gridOptions.columnApi.setColumnVisible("state_col", false);
					//$("#newPay").val(data[0].parkingPrice);
				}
				// 거절
				if(data[0].repayStatus == "C"){
					$(".card-header-right").hide();
					gridOptions.columnApi.setColumnVisible("newParkingPrice", false);
					gridOptions.columnApi.setColumnVisible("state_col", false);
					//$("#newPay").parent("div").parent("div").parent("div").css("display", "none");	
				}
				gridOptions.api.sizeColumnsToFit();
			}else{
				$(".card-header-right").show();
				//$("#newPay").inputMasking("number");
				//$("#newPay").blur();
			}
		}
	}
	 
	function saveData() {
		//var newPay = $("#newPay").val().replaceAll(",", "");
		
		var frm = $("#frmMain");
		frm.serializeArrayCustom();
		frm.addParam("func", "IS");
		frm.addParam("enc_col", "userId, kMemberId");
		//frm.addParam("newPay", newPay);
		
		frm.addParam("repayType", "U");
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
	
	function saveData2() {
		var parkingPrice = 0;
		
		for(var i=0; i<_gridHelper.getAllGridData().length; i++){
			parkingPrice += parseInt(_gridHelper.getAllGridData()[i].parkingPrice);
		}
		
		var frm = $("#frmMain");
		frm.serializeArrayCustom();
		frm.addParam("payPrice",parkingPrice);
		frm.addParam("func", "IS2");
		frm.addParam("enc_col", "userId, kMemberId");
		frm.setAction("<c:url value='/payment/updateCancelRepay.do' />");
		frm.addParam("dataType", "json");
		frm.request();
	}
	
	function handleIS2(data, textStatus, jqXHR) {
		if(data.count > 0){
			self.close();
			opener.loadTableData();
		}
	}
    
    function dataValidationApproval() {
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
		
        return true;
    }
    
	$(function(){
		
		var eGridDiv = document.querySelector('#myGrid');
		new agGrid.Grid(eGridDiv, gridOptions);
		
		// 그리드 툴 버튼 바로 표시
        $("i.open-card-option").trigger("click");
		
		// 앞뒤공백없애기
		$("textarea.form-control").on("blur",function(){
        	$(this).val($.trim($(this).val()));
	    })
		
		$("#btnApproval").click(function() {
			if(dataValidationApproval()) {
				if(confirm("재결제 신청 건을 승인하시겠습니까?")){
					saveData();	
				}	
			}
		});

		$("#btnReject").click(function() {
			if($("#reqReason").val() == '') {
				alert("재결제 신청 건의 거절사유를 입력해주세요.");
				$("#reqReason").focus();
				return false;
			}else{
				if(confirm("재결제 신청 건을 거절하시겠습니까?")){
					saveData2();
				}
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
				<card:open title="재결제 요청" />
				<card:button>
				</card:button>
				<card:content />
				<form id="frmMain" name="frmMain" method="post" onsubmit="return false" class="form-horizontal">
					<form:input id="kChargeNo" type="hidden" value="" />
					<form:input id="kPayCode" type="hidden" value="${param.payCode}" />
					<form:input id="kPaySeq" type="hidden" value="${param.paySeq}" />
					<form:input id="kApplyCode" type="hidden" value="${param.applyCode}" />
					<form:input id="kMemberId" type="hidden" value="${param.memberId}" />
					<form:input id="payCode" type="hidden" />
					<form:input id="hPrice" type="hidden" />
					<form:input id="paySeq" type="hidden" />
					<form:input id="tId" type="hidden" />
					
					<div class="form-group col-xl-6 col-lg-6 col-md-6 col-sm-6 no-margin no-padding ">
		                <label class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right" style="width: 150px !important;">요청일시</label>
		                <div class="col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached" style="max-width: calc(100% - 150px);">
		                    <div class="input-group">
		                        <span class="input-group-addon"><i class="fas fa fa-eye" data-icon="fas fa fa-eye"></i></span>
		                        <input name="applyDt" id="applyDt" class="form-control text-left fill" type="text" value="" readonly="readonly">
		                    </div>
		                </div>
		            </div>
		            <div class="form-group col-xl-6 col-lg-6 col-md-6 col-sm-6 no-margin no-padding ">
		                <label class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right" style="width: 150px !important;">이름</label>
		                <div class="col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached" style="max-width: calc(100% - 150px);">
		                    <div class="input-group">
		                        <span class="input-group-addon"><i class="fas fa fa-eye" data-icon="fas fa fa-eye"></i></span>
		                        <input name="memberName" id="memberName" class="form-control text-left fill" type="text" value="" readonly="readonly">
		                    </div>
		                </div>
		            </div>
					<div class="form-group col-xl-6 col-lg-6 col-md-6 col-sm-6 no-margin no-padding ">
		                <label class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right" style="width: 150px !important;">차량번호</label>
		                <div class="col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached" style="max-width: calc(100% - 150px);">
		                    <div class="input-group">
		                        <span class="input-group-addon"><i class="fas fa fa-eye" data-icon="fas fa fa-eye"></i></span>
		                        <input name="carNo" id="carNo" class="form-control text-left fill" type="text" value="" readonly="readonly">
		                    </div>
		                </div>
		            </div>
					<div class="form-group col-xl-6 col-lg-6 col-md-6 col-sm-6 no-margin no-padding" id="cancel_dt"> 
		                <label class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right" style="width: 150px !important;" id="cancel_dt_text">재결제사유</label> 
		                <div class="col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached" style="max-width: calc(100% - 150px);"> 
		                    <div class="input-group"> 
		                        <span class="input-group-addon"><i class="fas fa-eye" data-icon="fas fa-eye"></i></span> 
		                        <input name="cancelReason" id="cancelReason" class="form-control fill" type="text" value="" readonly="readonly"> 
		                    </div> 
		                </div> 
		            </div>
		            <div class="form-group col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12 no-margin no-padding "> 
		                <label class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right" style="width: 150px !important;">거절사유</label> 
		                <div class="col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached" style="max-width: calc(100% - 150px);"> 
		                    <div class="input-group"> 
		                        <span class="input-group-addon"><i class="fas fa-pencil-alt" data-icon="fas fa-pencil-alt"></i></span> 
		                        <textarea name="reqReason" id="reqReason" class="form-control " rows="5"></textarea> 
		                    </div>  
		                </div> 
		            </div>					
				</form>
				<card:close />
			</div>
		</div>
		<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12">
			<card:open title="재결제 요청 정보" />
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
				<c:if test="${param.repayStatus eq 'A' }">
					<form:button type="Approval" id="btnApproval" />
					<button type="button" id="btnReject" class="btn btn-sm waves-effect waves-light btn-danger btn-outline-danger default"> 
					    <span class="icofont icofont-close"></span> 
					    &nbsp;거절 
					</button>
				</c:if>
				<form:button type="Close" id="btnClose" />
			</div>
			<label:clear />
		</div>
	</div>
</div>