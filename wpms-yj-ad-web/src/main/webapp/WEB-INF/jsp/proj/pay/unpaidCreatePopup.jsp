<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="form" uri="http://ad.its.yeongju.kr/jsp/jstl/form"%>
<%@ taglib prefix="card" uri="http://ad.its.yeongju.kr/jsp/jstl/card"%>
<%@ taglib prefix="func" uri="http://ad.its.yeongju.kr/jsp/jstl/func"%>
<%@ taglib prefix="label" uri="http://ad.its.yeongju.kr/jsp/jstl/label"%>

<%@ include file="../../core/include/head.jsp"%>
<%@ include file="../../core/include/headerPopup.jsp"%>

<script type="text/javascript">

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
	setColumn(["chargeNo", "chargeNo"], [], true),
	setColumn(["memberId", "memberId"], [], true), 
	setColumn(["memberName", "memberName"], [], true), 
	setColumn(["pGovName", "pGovName"], [], true),
	setColumn(["parkingNo", "parkingNo"], [], true),
	
	setColumn(["select", "선택", "center", 80], [grdSelect, ["button", null, "button", "선택", ""] ]),
	setColumn(["parkingName", "주차장명", "left", 130]),
	setColumn(["carNo", "차량번호", "center", 100]),
	setColumn(["pEntDt", "입차일시", "center", 130]),
	setColumn(["pOutDt", "출차일시", "center", 130]),
	setColumn(["parkingPrice", "주차요금", "right", 80]),
	]
	
	// setColumnMask(컬럼옵션변수, 컬럼명, 타입, 추가옵션)
	setColumnMask(columnDefs, "pEntDt", "datetime");
	setColumnMask(columnDefs, "pOutDt", "datetime");
	
	// 그리드 옵션
	// 컬럼정의 / 화면에 그리드 맞추기 / 행추가 func
	var _gridHelper = new initGrid(columnDefs, true);
	var gridOptions = _gridHelper.setGridOption();
	
	function grdSelect(e, data) {
		$("#carNo").val(data.carNo);
		$("#memberName").val(data.memberName);
		$("#pGovName").val(data.pGovName);
		$("#parkingName").val(data.parkingName);
		$("#pEntDt").val(data.pEntDt);
		$("#pOutDt").val(data.pOutDt);
		$("#chargeNo").val(data.pOutDt);
		$("#memberId").val(data.memberId);
		$("#parkingNo").val(data.parkingNo);
		$("#chargeNo").val(data.chargeNo);
		
		$("#modalEdit").modal('hide');
	}

	function saveData() {
		var frm = $("#frmMain");
		frm.serializeArrayCustom();
		frm.addParam("func", "IS");
		frm.addParam("cancelType", "U");
		frm.setAction("<c:url value='/payment/unpaidCreate.do' />");
		frm.addParam("dataType", "json");
		frm.request();
	}

	function handleIS(data, textStatus, jqXHR) {
		if(data.count > 0){
			self.close();
			opener.loadTableData();
		}
	}
	
	function carSearch() {
		$("#kCarNumber").val("");
		$("#modalEdit").modal('show');
		_gridHelper.clearData();
		
	}
	
	function loadTableData() {
		if($("#kCarNumber").val() == ""){
			_gridHelper.clearData();
			alert("차량번호를 입력해주세요.");
			return;
		}
		var frm = $("#frmModal");
	    //---- 그리드 조회 시 필수요소 start
	    frm.addParam("result", $("#myGrid"));       // 그리드 태그
	    frm.addParam("grid", "gridOptions");        // 그리드 옵션
	    frm.addParam("baseData", "_originData");    // 그리드 원본 데이터 저장 변수
	    //---- 그리드 조회 시 필수요소 end
		frm.addParam("func", "IQ");
		frm.addParam("query_id", "pay.unpaidCarManage.Select_carModalList");
	    frm.addParam("dataType", "json");           // 그리드 불러오는 타입 (기본 json)
		frm.request();
	}
	
	function handleIQ(data, textStatus, jqXHR) {}
	

	$(function(){
		var eGridDiv = document.querySelector('#myGrid');
	    new agGrid.Grid(eGridDiv, gridOptions);
	    
		$("#payPrice").inputMasking("number");
		
		// 앞뒤공백없애기
		$("textarea.form-control").on("blur",function(){
        	$(this).val($.trim($(this).val()));
	    })

		$("#btnCreate").click(function() {
			if($("#carNo").val() == ""){
				alert("주차장 이용내역을 선택해주세요.");
				return false;
			}else if($("#payPrice").val() == ""){
				alert("주차요금을 입력해주세요.");
				$("#payPrice").focus()
				return false;
			}else if($("#payPrice").val() == "0"){
				alert("0원 이상의 요금을 입력해주세요.");
				$("#payPrice").focus()
				return false;
			}else if($("#createRemark").val() == ""){
				alert("사유를 입력해주세요.");
				$("#payPrice").focus()
				return false;
			}
			
			if(confirm("미납 결제 내역을 생성하시겠습니까?")){
				saveData();
			}
		});
	
		$("#btnClose").click(function() {
			self.close();
		});

		$("#btnModalClose").click(function() {
			$("#modalEdit").modal('hide');
		});
		
		$("#btnModalSearch").click(function() {
			loadTableData();
		});
		
		
		$("#kCarNumber").on("keyup",function(key){
			if(key.keyCode==13) {
			    loadTableData();
			}     
		});
	});
	


</script>

<div class="page-body" style="font-size: 0.9em;">
	<div class="row">
		<div class="col-12" id="search_all_wrapper">
			<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12">
				<card:open title="미납 결제" />
				<card:button>
				</card:button>
				<card:content />
				<form id="frmMain" name="frmMain" method="post" onsubmit="return false" class="form-horizontal">
					<form:input id="chargeNo" type="hidden" />
					<form:input id="memberId" type="hidden" />
					<form:input id="parkingNo" type="hidden" />

					<div class="form-group col-xl-12 col-lg-12 col-md-12 col-sm-12 no-margin no-padding ">
		                <label class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right" style="width: 150px !important;">차량번호</label>
		                <div class="col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached" style="max-width: calc(100% - 150px);">
		                    <div class="input-group">
                                <span class="input-group-addon"><i class="fas fa fa-eye" data-icon="fas fa fa-eye"></i></span>
                                <input name="carNo" id="carNo" class="form-control text-left fill" type="text" value="" maxlength="20" readonly="readonly">
                                <span class="input-group-btn">
									<button type="button" onClick="carSearch()" class="btn btn-sm btn-primary" data-gubn="activation">검색</button>
								</span>
                            </div>
                        </div>
                    </div>
                    
					<div class="form-group col-xl-12 col-lg-12 col-md-12 col-sm-12 no-margin no-padding ">
		                <label class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right" style="width: 150px !important;">이름</label>
		                <div class="col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached" style="max-width: calc(100% - 150px);">
		                    <div class="input-group">
		                        <span class="input-group-addon"><i class="fas fa fa-eye" data-icon="fas fa fa-eye"></i></span>
		                        <input name="memberName" id="memberName" class="form-control text-left fill" type="text" value="" readonly="readonly">
		                    </div>
		                </div>
		            </div>
					<div class="form-group col-xl-12 col-lg-12 col-md-12 col-sm-12 no-margin no-padding ">
		                <label class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right" style="width: 150px !important;">관리기관</label>
		                <div class="col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached" style="max-width: calc(100% - 150px);">
		                    <div class="input-group">
		                        <span class="input-group-addon"><i class="fas fa fa-eye" data-icon="fas fa fa-eye"></i></span>
		                        <input name="pGovName" id="pGovName" class="form-control text-left fill" type="text" value="" readonly="readonly">
		                    </div>
		                </div>
		            </div>
					<div class="form-group col-xl-12 col-lg-12 col-md-12 col-sm-12 no-margin no-padding ">
		                <label class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right" style="width: 150px !important;">주차장</label>
		                <div class="col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached" style="max-width: calc(100% - 150px);">
		                    <div class="input-group">
		                        <span class="input-group-addon"><i class="fas fa fa-eye" data-icon="fas fa fa-eye"></i></span>
		                        <input name="parkingName" id="parkingName" class="form-control text-left fill" type="text" value="" readonly="readonly">
		                    </div>
		                </div>
		            </div>
					<div class="form-group col-xl-12 col-lg-12 col-md-12 col-sm-12 no-margin no-padding ">
		                <label class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right" style="width: 150px !important;">입차일시</label>
		                <div class="col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached" style="max-width: calc(100% - 150px);">
		                    <div class="input-group">
		                        <span class="input-group-addon"><i class="fas fa fa-eye" data-icon="fas fa fa-eye"></i></span>
		                        <input name="pEntDt" id="pEntDt" class="form-control text-left fill" type="text" value="" readonly="readonly">
		                    </div>
		                </div>
		            </div>
					<div class="form-group col-xl-12 col-lg-12 col-md-12 col-sm-12 no-margin no-padding ">
		                <label class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right" style="width: 150px !important;">출차일시</label>
		                <div class="col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached" style="max-width: calc(100% - 150px);">
		                    <div class="input-group">
		                        <span class="input-group-addon"><i class="fas fa fa-eye" data-icon="fas fa fa-eye"></i></span>
		                        <input name="pOutDt" id="pOutDt" class="form-control text-left fill" type="text" value="" readonly="readonly">
		                    </div>
		                </div>
		            </div>
		            
		            
					<div class="form-group col-xl-12 col-lg-12 col-md-12 col-sm-12 no-margin no-padding has-danger">
		                <label class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right" style="width: 150px !important;">주차요금</label>
		                <div class="col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached" style="max-width: calc(100% - 150px);">
		                    <div class="input-group">
		                        <span class="input-group-addon"><i class="fas fa-pencil-alt" data-icon="fas fa-pencil-alt"></i></span>
		                        <input name="payPrice" id="payPrice" class="form-control text-right fill" type="text" value="" maxlength="11" >
		                    </div>
		                </div>
		            </div>
		            <div class="form-group col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12 no-margin no-padding has-danger">
		                <label class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right" style="width: 150px !important;">사유</label>
		                <div class="col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached" style="max-width: calc(100% - 150px);">
		                    <div class="input-group">
		                        <span class="input-group-addon"><i class="fas fa-pencil-alt" data-icon="fas fa-pencil-alt"></i></span>
		                        <textarea name="createRemark" id="createRemark" class="form-control" rows="5" maxlength="2000"></textarea>
		                    </div>
		                </div>
		            </div>
				</form>
				<card:close />
			</div>
		</div>
	</div>
	<div class="row padding-left-10 padding-right-10">
		<div class="bottom-btn-area">
			<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12 text-right">
				<c:if test="${param.payStatus == 'N' }">
					<button type="button" id="btnSave" class="btn btn-sm waves-effect waves-light btn-success btn-outline-success">
					    <span class="icofont icofont-check"></span>
					    &nbsp;납부
					</button>
				</c:if>
				<form:button type="Create" id="btnCreate" />
				<form:button type="Close" id="btnClose" />
			</div>
			<label:clear />
		</div>
	</div>
</div>


<!-- 차량검색 모달 -->
<div class="modal fade" id="modalEdit" tabindex="-1" role="dialog" aria-labelledby="modalEdit" style="position: fixed;"
	data-backdrop="static" data-keyboard="false">
	<div class="modal-dialog" role="document" style="max-width: 750px;">
		<div class="modal-content">
			<div class="modal-header">
				<h5 class="modal-title">차량 검색</h5>
			</div>
			<div class="modal-body">
				<div class="row">
					<div class="col-12 text-right">
						<card:button>
							<form:button type="Search" id="btnModalSearch" />
						</card:button>
						<div class="search-area col-6"> 
							<form id="frmModal" name="frmModal" method="post" onsubmit="return false" class="form-material form-inline">
								<form:input id="kCarNumber" caption="차량번호" addAttr="maxlength='20'"/>
							</form>
						</div>
					</div>
					
					<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12">
						<card:open title="주차장 이용 내역" />
						<card:button>
						</card:button>
						<card:content />
						<form:grid id="myGrid" height="300px" />
						<card:close />
					</div>
					
					<div class="col-12 text-right">
						<form:button type="Close" id="btnModalClose" />
					</div>
						
				</div>
			</div>
		</div>
	</div>
</div>