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
	
	var imageUriData = "";
	
	var downloadCode = "";


	function loadTableData() {
		
		var frm = $("#frmMain");
		frm.addParam("func", "IQ");
		frm.addParam("query_id", "pay.repaymentManage.Select_PopupList");
		frm.addParam("enc_col", "kMemberId");
	    frm.addParam("dataType", "json");           // 그리드 불러오는 타입 (기본 json)
		frm.request();
	}
	
	function handleIQ(data, textStatus, jqXHR) {
		if(data.length > 0) {
			
			$("#frmMain").formSet(data);
			
			if(data[0].repayStatus != "A"){
				$("#reqReason").attr("readonly", true);
				$("#reqReason").siblings("span").children("i").removeClass();
				$("#reqReason").siblings("span").children("i").addClass("fas fa-eye");
				$("#reqReason").siblings("span").children("i").data("icon", "fas fa-eye");
				$("#reqReason").css("background-color", "#EEEEEE");
				$("#newPay").attr("readonly", true);
				$("#newPay").siblings("span").children("i").removeClass();
				$("#newPay").siblings("span").children("i").addClass("fas fa-eye");
				$("#newPay").siblings("span").children("i").data("icon", "fas fa-eye");
				// 승인
				if(data[0].repayStatus == "B"){
					$("#reqReason").parent("div").parent("div").parent("div").css("display", "none");
					$("#newPay").val(data[0].parkingPrice);
				}
				// 거절
				if(data[0].repayStatus == "C"){
					$("#newPay").parent("div").parent("div").parent("div").css("display", "none");	
				}
			}else{
				$("#newPay").inputMasking("number");
				$("#newPay").blur();
			}
			
			if(data[0].fileName !== null && data[0].delYn == "N") {
			    if(data[0].mimeType.indexOf("image/") > -1) {
				    var frm = $("#frmMain");
				    frm.addParam("func", "IQ2_Img");
			        frm.setAction("<c:url value='/upload/getImgDataUri.do' />");
			        frm.addParam("fileRelKey", data[0].fileRelKey);
			        frm.addParam("fileKey", data[0].fileKey);
			        frm.addParam("fileName", data[0].fileName);
			        frm.addParam("dataType", "json");
			        frm.request();
			    } else {
			        var frm = $("#frmMain");
                    frm.addParam("func", "IQ2_DNC");
                    frm.setAction("<c:url value='/upload/getEncFileData.do' />");
                    frm.addParam("fileRelKey", data[0].fileRelKey);
                    frm.addParam("fileKey", data[0].fileKey);
                    frm.addParam("fileName", data[0].fileName);
                    frm.addParam("dataType", "json");
                    frm.request();
			    }
			}
		}
		$(".card-block").eq(1).css("height", $(".card-block").eq(0).innerHeight());
	
	}
	
	// IQ2에 대한 이미지
	function handleIQ2_Img(data, textStatus, jqXHR) {
	    if(data.data.imgDataUri && data.data.imgDataUri.length > 0) {
	        $("#image img").attr("src", data.data.imgDataUri);
	    }
	    $(".card-block").eq(1).css("height", $(".card-block").eq(0).innerHeight());
	}
	
	// IQ2 DNC
    function handleIQ2_DNC(data, textStatus, jqXHR) {
        if(data.data.encData && data.data.encData.length > 0) {
            downloadCode = data.data.encData;
            $("#btnzoomIn span").removeClass("fa fa-search-plus").addClass("far fa-download");
            $("#btnzoomIn").html("").append("<span class=\"fa fa-download\"></span>&nbsp;첨부파일 다운로드");
            
            $("#image")[0].onclick = "";
            $("#image img").attr("src", "<c:url value='/images/no_preview.jpg'/>");
        }
        $(".card-block").eq(1).css("height", $(".card-block").eq(0).innerHeight());
    }
	 
	function saveData() {
		var newPay = $("#newPay").val().replaceAll(",", "");
		
		var frm = $("#frmMain");
		frm.serializeArrayCustom();
		frm.addParam("func", "IS");
		frm.addParam("enc_col", "userId, kMemberId");
		frm.addParam("newPay", newPay);
		frm.addParam("repayType", "U");
		frm.setAction("<c:url value='/payment/updateSuccessRepay.do' />");
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
		var frm = $("#frmMain");
		frm.serializeArrayCustom();
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
		if($("#newPay").val() == ''){
			alert("새로운 요금을 입력해 주세요.");
			$("#newPay").focus();
    		return false;
    	}
		
        return true;
    }
    
	//이미지 팝업창 생성
	function openPopup(imageSrc){
		OpenPopupSingle("/sys/imagePopup.do", 1800, 990, "imagePopup");
  	  
	}
	
	function zoomInImage() {
	    if(downloadCode.length > 0) {
            startDownload(downloadCode, "W");
        } else {
            imageUriData = $("#image img").attr("src");
            openPopup($("#image img").attr("src"));
        }
	}
	
	function zoomInApproveImage() {
	    if(downloadCode.length > 0) {
            startDownload(downloadCode, "W");
        } else {
            imageUriData = $("#approveImage img").attr("src");
            openPopup($("#approveImage img").attr('src'));
        }
	}
    
	$(function(){
		
		// 앞뒤공백없애기
		$("textarea.form-control").on("blur",function(){
        	$(this).val($.trim($(this).val()));
	    })
	    
	    // 크게 보기
		$("#btnzoomIn").click(function() {
		    zoomInImage();
		});
		
		// 크게 보기
		$("#btnApproveZoomIn").click(function() {
		    zoomInApproveImage();
		});
		
		
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
		
		
		
		loadTableData();
		
		$("#image img").css("height",$("#image img").width());
	});

</script>

<div class="page-body" style="font-size: 0.9em;">
	<div class="row">
		<div class="col-12" id="search_all_wrapper">
			<div class="col-xl-6 col-lg-6 col-md-6 col-sm-6 col-6">
				<card:open title="재결제 요청" />
				<card:button>
				</card:button>
				<card:content />
				<form id="frmMain" name="frmMain" method="post" onsubmit="return false" class="form-horizontal">
					<form:input id="kChargeNo" type="hidden" value="${param.chargeNo}" />
					<form:input id="kPayCode" type="hidden" value="${param.payCode}" />
					<form:input id="kPaySeq" type="hidden" value="${param.paySeq}" />
					<form:input id="kApplyCode" type="hidden" value="${param.applyCode}" />
					<form:input id="kMemberId" type="hidden" value="${param.memberId}" />
					<form:input id="payCode" type="hidden" />
					<form:input id="hPrice" type="hidden" />
					<form:input id="paySeq" type="hidden" />
					<form:input id="tId" type="hidden" />
					
					<div class="form-group col-xl-12 col-lg-12 col-md-12 col-sm-12 no-margin no-padding ">
		                <label class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right" style="width: 150px !important;">요청일시</label>
		                <div class="col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached" style="max-width: calc(100% - 150px);">
		                    <div class="input-group">
		                        <span class="input-group-addon"><i class="fas fa fa-eye" data-icon="fas fa fa-eye"></i></span>
		                        <input name="applyDt" id="applyDt" class="form-control text-left fill" type="text" value="" readonly="readonly">
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
					<div class="form-group col-xl-12 col-lg-12 col-md-12 col-sm-12 no-margin no-padding ">
		                <label class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right" style="width: 150px !important;">차량번호</label>
		                <div class="col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached" style="max-width: calc(100% - 150px);">
		                    <div class="input-group">
		                        <span class="input-group-addon"><i class="fas fa fa-eye" data-icon="fas fa fa-eye"></i></span>
		                        <input name="carNo" id="carNo" class="form-control text-left fill" type="text" value="" readonly="readonly">
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
		                <label class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right" style="width: 150px !important;">주차장명</label>
		                <div class="col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached" style="max-width: calc(100% - 150px);">
		                    <div class="input-group">
		                        <span class="input-group-addon"><i class="fas fa fa-eye" data-icon="fas fa fa-eye"></i></span>
		                        <input name="parkingName" id="parkingName" class="form-control text-left fill" type="text" value="" readonly="readonly">
		                    </div>
		                </div>
		            </div>
		            <div class="form-group col-xl-12 col-lg-12 col-md-12 col-sm-12 no-margin no-padding ">
		                <label class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right" style="width: 150px !important;">주차요금 (전체)</label>
		                <div class="col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached" style="max-width: calc(100% - 150px);">
		                    <div class="input-group">
		                        <span class="input-group-addon"><i class="fas fa fa-eye" data-icon="fas fa fa-eye"></i></span>
		                        <input name="totalParkingFee" id="totalParkingFee" class="form-control text-right fill" type="text" value="" readonly="readonly">
		                    </div>
		                </div>
		            </div>
		            <div class="form-group col-xl-12 col-lg-12 col-md-12 col-sm-12 no-margin no-padding ">
		                <label class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right" style="width: 150px !important;">할인요금</label>
		                <div class="col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached" style="max-width: calc(100% - 150px);">
		                    <div class="input-group">
		                        <span class="input-group-addon"><i class="fas fa fa-eye" data-icon="fas fa fa-eye"></i></span>
		                        <input name="discountFee" id="discountFee" class="form-control text-right fill" type="text" value="" readonly="readonly">
		                    </div>
		                </div>
		            </div>
		             <div class="form-group col-xl-12 col-lg-12 col-md-12 col-sm-12 no-margin no-padding ">
		                <label class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right" style="width: 150px !important;">사전결제요금</label>
		                <div class="col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached" style="max-width: calc(100% - 150px);">
		                    <div class="input-group">
		                        <span class="input-group-addon"><i class="fas fa fa-eye" data-icon="fas fa fa-eye"></i></span>
		                        <input name="prePayFee" id="prePayFee" class="form-control text-right fill" type="text" value="" readonly="readonly">
		                    </div>
		                </div>
		            </div>
					<div class="form-group col-xl-12 col-lg-12 col-md-12 col-sm-12 no-margin no-padding "> 
		                <label class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right" style="width: 150px !important;">기주차요금</label> 
		                <div class="col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached" style="max-width: calc(100% - 150px);"> 
		                    <div class="input-group"> 
		                        <span class="input-group-addon"><i class="fas fa fa-eye" data-icon="fas fa fa-eye"></i></span> 
		                        <input name="payPrice" id="payPrice" class="form-control text-right fill" type="text" value="" readonly="readonly"> 
		                    </div> 
		                </div> 
		            </div>
		            <div class="form-group col-xl-12 col-lg-12 col-md-12 col-sm-12 no-margin no-padding" id="cancel_dt"> 
		                <label class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right" style="width: 150px !important;" id="cancel_dt_text">재결제사유</label> 
		                <div class="col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached" style="max-width: calc(100% - 150px);"> 
		                    <div class="input-group"> 
		                        <span class="input-group-addon"><i class="fas fa-eye" data-icon="fas fa-eye"></i></span> 
		                        <input name="cancelReason" id="cancelReason" class="form-control fill" type="text" value="" readonly="readonly"> 
		                    </div> 
		                </div> 
		            </div>
		            <div class="form-group col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12 no-margin no-padding "> 
		                <label class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right" style="width: 150px !important;">새로운 요금</label> 
		                <div class="col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached" style="max-width: calc(100% - 150px);"> 
		                    <div class="input-group"> 
		                        <span class="input-group-addon"><i class="fas fa-pencil-alt" data-icon="fas fa-pencil-alt"></i></span> 
		                        <input name="newPay" id="newPay" class="form-control text-right fill" type="text" value="" oninput="this.value = this.value.replace(/[^0-9.]/g, '').replace(/(\..*)\./g, '$1');"> 
		                    </div> 
		                </div> 
		            </div>
					<div class="form-group col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12 no-margin no-padding "> 
		                <label class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right" style="width: 150px !important;">거절사유</label> 
		                <div class="col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached" style="max-width: calc(100% - 150px);"> 
		                    <div class="input-group"> 
		                        <span class="input-group-addon"><i class="fas fa-pencil-alt" data-icon="fas fa-pencil-alt"></i></span> 
		                        <textarea name="reqReason" id="reqReason" class="form-control " rows="4"></textarea> 
		                    </div> 
		                </div> 
		            </div>
				</form>
				<card:close />
			</div>
			
			<div class="col-xl-6 col-lg-6 col-md-6 col-sm-6 col-6">
				<div class="card">
				    <div class="card-header">
				        <h5 id="applyFileName">파일 정보</h5>
					</div>
					<div class="card-block table-border-style" id="fileDiv">
						<div onClick="zoomInImage()" id="image" style='cursor:pointer'>
							<img src="<c:url value='/images/no_img.jpg'/>" alt="empty.png" style="width:100%; height:450px; margin-bottom: 15px; border: 1px solid #eee; border-radius: 22px;">
						</div>
						<a href="<c:url value='/images/no_img.jpg'/>" id="iframe" data-fancybox="" data-small-btn="true" style="display:none;" data-options='{"type" : "iframe", "iframe" : {"preload" : false, "css" : {"width" : "450px","height" : "450px"}}}'></a>
						<div class="text-right">
							<button type="button" id="btnzoomIn" class="btn btn-sm waves-effect waves-light btn-info btn-outline-info default text-right">
							    <span class="fa fa-search-plus"></span>
							    &nbsp;크게보기
							</button>
						</div>
					</div>
				</div>
			</div>
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