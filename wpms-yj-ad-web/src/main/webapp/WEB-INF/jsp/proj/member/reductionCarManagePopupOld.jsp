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
	var reductionRate = "";
	var imageUriData = "";
	var downloadCode = "";

	var confirm_gubn = "${param.confirm_gubn}";
	confirm_gubn = confirm_gubn == "Y" ? true : false;


	var _gridHelper = new initGrid(columnDefs, true);
	var gridOptions = _gridHelper.setGridOption();

	function grdCarReduction(e, data) {

		gridOptions.api.forEachNode(function (node) {
			node.setSelected(false);
		});

		if(data.fileName === undefined){
			alert("첨부파일이 존재하지 않습니다.");
			return;
		}

		$("#image").attr("href",userUrl+data.fileName);
		$("#iframe").attr("href",userUrl+data.fileName);

		if(data.fileExt == "pdf"){
			$("#image").children().attr("src","/images/no_img.jpg");
			$("#iframe").trigger("click");
		}else{
			$("#image").children().attr("src",userUrl+data.fileName);
		}
	}

	function loadTableDetail() {
		var frm = $("#frmMain");

		frm.addParam("func", "IQ");
		frm.addParam("query_id", "member.reductionManage.Select_CarReduction");
		frm.addParam("hMemberId", $("#hMemberId").val());
		frm.addParam("enc_col", "hMemberId");
		frm.addParam("dataType", "json");		   // 그리드 불러오는 타입 (기본 json)
		frm.request();
	}

	function handleIQ(data, textStatus, jqXHR) {
		console.log(data)
		if(data.length > 0){
			// 자동승인일 때 이미지 처리
			if(data[0].inputGubn == "A"){
				$("#imgView").attr("src", "/walletfree-admin/assets/images/auto_img.jpg");
			}
			reductionRate = data[0].reductionRate;
			$("#kMemberId").val(data[0].memberId);
			$("#kMemberName").val(data[0].memberName);
			$("#kAddrCode1").val(data[0].addrCode1);
			$("#kAddrCode2").val(data[0].addrCode2);
			$("#kGugun").val(data[0].gugun);
			$("#hReductionCode").val(data[0].reductionCode);
			$("#kReductionName").val(data[0].reductionName);
			$("#kReductionRate").val(data[0].reductionRate + "%");
			$("#hFileRelKey").val(data[0].fileRelKey);
			$("#kRejectReason").val(data[0].rejectReason);
			$("#kRedExpDate").val(data[0].redExpDate);
			$("#kConfirmYnName").val(data[0].confirmYnName);

			// 미승인/삭제, 승인/삭제, 거절/삭제 모두 readonly로 처리
			if('${param.delYn}' == 'Y'){
				$("#kRejectReason").attr("readonly", true);
				$("#kRedExpDate").attr("readonly", true);

				$("#kRejectReason").siblings("span").children("i").removeClass();
				$("#kRejectReason").siblings("span").children("i").addClass("fas fa-eye");
				$("#kRejectReason").siblings("span").children("i").data("icon", "fas fa-eye");
				$("#kRejectReason").css("background-color", "#EEEEEE");
				$("#kRedExpDate").css("text-align", "center");

				if(data[0].confirmYn == 'Y'){
					$("#kRejectReason").parent("div").parent("div").parent("div").css("display", "none");
				}
				// 승인시 날짜 변경 불가능하도록 처리
			}else if("${param.confirmYn}" == "Y"){
				$("#kRedExpDate").attr("readonly", true);
				$("#kRedExpDate").css("text-align", "center");
			}else {
//				$("#kRedExpDate").initDateOnly("year", 1);
				$("#kRedExpDate").css("text-align", "center");
			}

			// 승인여부에 따라 거절사유, 유효기간 처리
			if('${param.confirmYn}' == 'Y'){
				$("#kRejectReason").parent().parent().parent().hide();
// 				$("#kRedExpDate").initDateOnly("year", 1);
// 				$("#kRedExpDate").data("daterangepicker").setStartDate(moment().format(data[0].redExpDate));
// 	            $("#kRedExpDate").data("daterangepicker").setEndDate(moment().format(data[0].redExpDate));

			} else if('${param.confirmYn}' == 'C'){
				$("#kRejectReason").attr("readonly", true);
				$("#kRedExpDate").attr("readonly", true);
				$("#kRejectReason, #kRedExpDate").siblings("span").children("i").removeClass();
				$("#kRejectReason, #kRedExpDate").siblings("span").children("i").addClass("fas fa-eye");
				$("#kRejectReason, #kRedExpDate").siblings("span").children("i").data("icon", "fas fa-eye");
				$("#kRejectReason, #kRedExpDate").css("background-color", "#EEEEEE");

			} else if('${param.confirmYn}' == 'N'){
				if('${param.delYn}' == 'N'){
					$("#kRedExpDate").initDateOnly("year", 1);
				}
				$("#kRedExpDate").data("daterangepicker").setStartDate(moment().format(data[0].redExpDate));
				$("#kRedExpDate").data("daterangepicker").setEndDate(moment().format(data[0].redExpDate));
			}


			if(data[0].fileName !== undefined) {
				if(data[0].mimeType.indexOf("image/") > -1) {
					var frm = $("#frmMain");
					frm.addParam("func", "IQ_Img");
					frm.setAction("<c:url value='/upload/getImgDataUri.do' />");
					frm.addParam("fileRelKey", data[0].fileRelKey);
					frm.addParam("fileKey", data[0].fileKey);
					frm.addParam("fileName", data[0].fileName);
					frm.addParam("dataType", "json");
					frm.request();
				} else {
					var frm = $("#frmMain");
					frm.addParam("func", "IQ_DNC");
					frm.setAction("<c:url value='/upload/getEncFileData.do' />");
					frm.addParam("fileRelKey", data[0].fileRelKey);
					frm.addParam("fileKey", data[0].fileKey);
					frm.addParam("fileName", data[0].fileName);
					frm.addParam("dataType", "json");
					frm.request();
				}
			}
		}
	}

	function saveData() {

		// 승인할 그리드2 데이터
		var grd_check_value = [];
		var grd_reduction_code = [];
		var grd_red_exp_date = [];
		var grd_car_no = [];
		var grd_file_rel_key = [];
		var grd_reject_reason = [];

		for(var i=0; i<_gridHelper.getAllGridData().length; i++){
			grd_check_value.push(_gridHelper.getAllGridData()[i].checkValue);
			grd_reduction_code.push(_gridHelper.getAllGridData()[i].reductionCode);
			grd_red_exp_date.push(_gridHelper.getAllGridData()[i].redExpDate);
			grd_car_no.push(_gridHelper.getAllGridData()[i].carNo);
			grd_file_rel_key.push(_gridHelper.getAllGridData()[i].fileRelKey);
			grd_reject_reason.push(_gridHelper.getAllGridData()[i].rejectReason);
		}


		var frm = $("#frmMain");
		frm.addParam("func", "IS");
		frm.addParam("dataType", "json");

		frm.addParam("grd2_check_value",grd_check_value);
		frm.addParam("grd2_reduction_code",grd_reduction_code);
		frm.addParam("grd2_red_exp_date",'99991231');
		frm.addParam("grd2_car_no",grd_car_no);
		frm.addParam("grd2_file_rel_key",grd_file_rel_key);
		frm.addParam("grd2_reject_reason",grd_reject_reason);
		frm.addParam("processGubn","car");

		frm.addParam("hApplyCode",$("#hApplyCode").val());
		frm.addParam("hMemberId",$("#hMemberId").val());
		frm.setAction("<c:url value='/reduction/popupUpdate.do' />");
		frm.request();
	}

	function handleIS(data, textStatus, jqXHR) {
		if(data.count > 0){
			window.close();
			opener.loadTableData();
		}
	}

	function dataValidation() {
		var grid_data = _gridHelper.getAllGridData();

		for(var i=0; i<grid_data.length; i++){
			if(grid_data[i].checkValue == "N" && grid_data[i].rejectReason == ""){
				notifyDanger("차량 감면 거절사유를 입력해 주세요.");
				return;
			}else{

				if(grid_data[i].checkValue == "N" && grid_data[i].rejectReason === undefined){
					notifyDanger("차량 감면 거절사유를 입력해 주세요.");
					return;
				}

			}
		}

		saveData();
	}

	function checkValidDate(value) {
		var result = true;
		try {
			var date = value.split("-");
			var y = parseInt(date[0], 10),
					m = parseInt(date[1], 10),
					d = parseInt(date[2], 10);

			var dateRegex = /^(?=\d)(?:(?:31(?!.(?:0?[2469]|11))|(?:30|29)(?!.0?2)|29(?=.0?2.(?:(?:(?:1[6-9]|[2-9]\d)?(?:0[48]|[2468][048]|[13579][26])|(?:(?:16|[2468][048]|[3579][26])00)))(?:\x20|$))|(?:2[0-8]|1\d|0?[1-9]))([-.\/])(?:1[012]|0?[1-9])\1(?:1[6-9]|[2-9]\d)?\d\d(?:(?=\x20\d)\x20|$))?(((0?[1-9]|1[012])(:[0-5]\d){0,2}(\x20[AP]M))|([01]\d|2[0-3])(:[0-5]\d){1,2})?$/;
			result = dateRegex.test(d+'-'+m+'-'+y);
		} catch (err) {
			result = false;
		}
		return result;
	}

	function checkDate(_obj) {
		const index = _obj[0].__selecetedRowIndex;
		const row = _obj[0].getGridRowData(index);
		const api = _obj[0].__gridOption.api;
		const gridHelper = _obj[0];

		if(row.redExpDate !== undefined && row.redExpDate != ""){
			var reg_date = moment(row.redExpDate).format("YYYY-MM-DD");
			if(row.rejectReason == "" || row.rejectReason === undefined){
				if(checkValidDate(reg_date)){
					gridHelper.setGridData(index, "checkValue", "Y");
					gridHelper.setGridData(index, "redExpDate", reg_date);
				}else{
					alert("감면유효기간 날짜 형식을 확인해 주세요.(ex.2023-01-01)");
					gridHelper.setGridData(index, "checkValue", "N");
					gridHelper.setGridData(index, "redExpDate", "");
					return;
				}
			}else{
				gridHelper.setGridData(index, "rejectReason", "");
			}
		}
	}

	function reject(_obj) {
		const index = _obj[0].__selecetedRowIndex;
		const row = _obj[0].getGridRowData(index);
		const api = _obj[0].__gridOption.api;
		const gridHelper = _obj[0];

		if(row.redExpDate != ""  && row.rejectReason !== undefined){
			gridHelper.setGridData(index, "checkValue", "N");
		}
	}

	function checking(_obj) {
		const index = _obj[0].__selecetedRowIndex;
		const row = _obj[0].getGridRowData(index);
		const api = _obj[0].__gridOption.api;
		const gridHelper = _obj[0];

		if(row.checkValue == "Y"){
			gridHelper.setGridData(index, "rejectReason", "");
		}
	}

	$(function(){

		var eGridDiv = document.querySelector('#myGrid');
		new agGrid.Grid(eGridDiv, gridOptions);

		$("#btnApproval").click(function() {
			validation("Approval");
		});

		// 거절
		$("#btnRefusal").click(function() {
			validation("Refusal");
		});

		// 닫기
		$("#btnClose").click(function() {
			window.close();
		});



		// 앞뒤공백없애기
		$("#kRejectReason").on("blur",function(){
			$(this).val($.trim($(this).val()));
		});

		// 크게 보기
		$("#btnzoomIn").click(function() {
			zoomInImage();
		});


		//최초 갭 : 205
		$(window).on("resize", function() {
			$(".card-block").eq(0).css("height", $("#fileDiv").innerHeight());
			$(".card-block").eq(1).css("height", $("#fileDiv").innerHeight());
		});

		$(window).trigger("resize");
		loadTableDetail();

		$(".ag-body-horizontal-scroll").remove();
	});

</script>


<div class="page-body" style="font-size: 0.9em;">
	<div class="row">
		<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12">
			<div class="col-xl-6 col-lg-6 col-md-6 col-sm-12 col-12">
				<card:open title="신청 정보" />
				<card:button>
				</card:button>
				<card:content />
				<form id="frmMain" name="frmMain" method="post" onsubmit="return false" class="form-horizontal" >
					<form:input id="hMemberId" type="hidden" value="${param.memberId}" />
					<form:input id="hApplyCode" type="hidden" value="${param.applyCode}" />
					<form:input id="hReductionCode" type="hidden" value="${param.reductionCode}"/>
					<form:input id="hReductionGubn" type="hidden" value="${param.reductionGubn}"/>
					<form:input id="hFileRelKey" type="hidden" />
					<label:input id="kMemberId" caption="ID" size="20" state="readonly"/>
					<label:input id="kMemberName" caption="이름" size="12" state="readonly"/>
					<label:input id="kAddrCode1" caption="주소" size="12" state="readonly"/>
					<label:input id="kAddrCode2" caption="상세주소" size="12" state="readonly"/>
					<label:input id="kGugun" caption="구역(시/군/구)" size="12" state="readonly"/>
					<label:input id="kReductionName" caption="감면정보" size="12" state="readonly"/>
					<label:input id="kReductionRate" caption="감면율" size="12" state="readonly"/>
					<label:input id="kRedExpDate" caption="감면유효기간" size="12" icon="far fa-calendar-alt" />
					<label:input id="kConfirmYnName" caption="처리여부" size="12" state="readonly" addAttr="style='text-align:center;'"/>
					<label:textarea id="kRejectReason" caption="거절사유" size="12" rows="5" />
				</form>
				<card:close />
			</div>
			<div class="col-xl-6 col-lg-6 col-md-6 col-sm-12 col-12">
				<div class="card">
					<div class="card-header">
						<h5>파일 정보</h5>
					</div>
					<div class="card-block table-border-style" id="fileDiv">
						<c:choose>
							<c:when test="${param.delYn eq 'Y' }">
								<div onClick="return false;" id="image">
									<div style="width: 400px; height: 600px;">
										<img src="<c:url value='/images/img_delete.jpg'/>" id="imgView" style="height:100%; width:100%; object-fit: contain; border: 1px solid #eee; border-radius: 15px; background-color: #f1f1f1;">
									</div>
								</div>
								<div style="height: 34px; margin-top: 20px;"></div>
							</c:when>
							<c:otherwise>
								<div onClick="zoomInImage()" id="image">
									<div style="width: 400px; height: 600px;">
										<img src="<c:url value='/images/no_img.jpg'/>" id="imgView" style="height:100%; width:100%; object-fit: contain; border: 1px solid #eee; border-radius: 15px; background-color: #f1f1f1;">
									</div>
								</div>
								<a href="<c:url value='/images/no_img.jpg'/>" id="iframe" data-fancybox="" data-small-btn="true" style="display:none;" data-options='{"type" : "iframe", "iframe" : {"preload" : false, "css" : {"width" : "450px","height" : "600px"}}}'></a>
								<div class="text-right" style="margin-top: 20px;">
									<button type="button" id="btnzoomIn" class="btn btn-sm waves-effect waves-light btn-info btn-outline-info default text-right">
										<span class="fa fa-search-plus"></span>
										&nbsp;크게보기
									</button>
								</div>
							</c:otherwise>
						</c:choose>
					</div>
				</div>
			</div>
		</div>
	</div>

	<div class="row padding-left-5 padding-right-5">
		<div class="bottom-btn-area">
			<div class="col-xl-6 col-lg-6 col-md-6 col-sm-12 col-12"></div>
			<div class="col-xl-6 col-lg-6 col-md-6 col-sm-12 col-12 text-right">
				<form:button type="Approval" id="btnApproval" />
				<form:button type="Close" id="btnClose" />
			</div>
			<label:clear />
		</div>
	</div>
</div>