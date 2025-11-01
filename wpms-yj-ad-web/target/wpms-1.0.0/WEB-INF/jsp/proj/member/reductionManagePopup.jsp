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

	function grdMemberReduction(e, data) {

		if(data.fileName === undefined){
			alert("첨부파일이 존재하지 않습니다.");
			return;
		}

		$("#image").attr("href",userUrl+data.fileName);
		$("#iframe").attr("href",userUrl+data.fileName);

		if(data.fileExt == "pdf"){
			$("#imgView").attr("src","/images/no_img.jpg");
			$("#iframe").trigger("click");
		}else{
			$("#imgView").attr("src",userUrl+data.fileName);
		}
	}

	function loadTableDetail() {
		var frm = $("#frmMain");

		frm.addParam("func", "IQ");
		frm.addParam("query_id", "member.reductionManage.Select_MemberReduction");
		frm.addParam("hMemberId", $("#hMemberId").val());
		frm.addParam("enc_col", "hMemberId");
		frm.addParam("dataType", "json");		   // 그리드 불러오는 타입 (기본 json)
		frm.request();
	}


	function handleIQ(data, textStatus, jqXHR) {
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

/* 			if(data[0].confirmYn != 'N'){
				$("#kRejectReason").attr("readonly", true);
				if(data[0].confirmYn == 'C'){
					$("#kRedExpDate").attr("readonly", true);
				}else{
					$("#kRedExpDate").initDateOnly();	
				}
				$("#kRejectReason").siblings("span").children("i").removeClass();
				$("#kRejectReason").siblings("span").children("i").addClass("fas fa-eye");
				$("#kRejectReason").siblings("span").children("i").data("icon", "fas fa-eye");
				$("#kRejectReason").css("background-color", "#EEEEEE");
				$("#kRedExpDate").css("text-align", "center");
				if(data[0].confirmYn == 'Y'){
					$("#kRejectReason").parent("div").parent("div").parent("div").css("display", "none");
				}
			}else {
				$("#kRedExpDate").initDateOnly("year", 1);
			} */
/* 			$("#kRedExpDate").data("daterangepicker").setStartDate(moment().format(data[0].redExpDate));
            $("#kRedExpDate").data("daterangepicker").setEndDate(moment().format(data[0].redExpDate)); */

// 			if(data[0].fileName === undefined){
// 				$("#image").attr("href","/walletfree-admin/images/no_img.jpg");
// 				$("#imgView").attr("src","/walletfree-admin/images/no_img.jpg");
// 			}else{

// 				if(data.fileExt == "pdf"){
// 					$("#imgView").attr("src","/walletfree-admin/images/no_img.jpg");
// 					$("#iframe").trigger("click");
// 				}else{
// 					$("#image").attr("href",userUrl+data[0].fileName);
// 					$("#iframe").attr("href",userUrl+data[0].fileName);
// 					$("#imgView").attr("src",userUrl+data[0].fileName);
// 				}
// 			}
		    
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
	
	// IQ에 대한 이미지
    function handleIQ_Img(data, textStatus, jqXHR) {
        if(data.data.imgDataUri && data.data.imgDataUri.length > 0) {
            $("#imgView").attr("src", data.data.imgDataUri);
        }
    }
	
    // IQ DNC
    function handleIQ_DNC(data, textStatus, jqXHR) {
        if(data.data.encData && data.data.encData.length > 0) {
            downloadCode = data.data.encData;
            $("#btnzoomIn span").removeClass("fa fa-search-plus").addClass("far fa-download");
            $("#btnzoomIn").html("").append("<span class=\"fa fa-download\"></span>&nbsp;첨부파일 다운로드");
            
            $("#imgView").parent().parent()[0].onclick = "";
            $("#imgView").attr("src", "<c:url value='/images/no_preview.jpg'/>");
        }
    }

	function saveData(type) {
		// 기존 로직 변경하지 않기위해 아래와같이 처리
		// 승인 / 거절 타입
		var grd_type = [type];
		var grd_reduction_code = [$("#hReductionCode").val()];
		var grd_reduction_name = [$("#kReductionName").val()];
		var grd_reduction_gubn = [$("#hReductionGubn").val()];
		var grd_red_exp_date = [$("#kRedExpDate").val().replaceAll("-", "")];
		var grd_file_rel_key = [$("#hFileRelKey").val()];
		var grd_reject_reason = [$("#kRejectReason").val()];

	    var frm = $("#frmMain");
	    frm.addParam("func", "IS");
	    frm.addParam("dataType", "json");

	    frm.addParam("grd_type",grd_type);
	    frm.addParam("grd_reduction_code",grd_reduction_code);
	    frm.addParam("grd_reduction_name",grd_reduction_name);
	    frm.addParam("grd_reduction_gubn",grd_reduction_gubn);
	    frm.addParam("grd_red_exp_date",grd_red_exp_date);
	    frm.addParam("grd_file_rel_key",grd_file_rel_key);
	    frm.addParam("grd_reject_reason",grd_reject_reason);

		frm.addParam("hMemberId", $("#hMemberId").val());
		frm.addParam("kMemberName", $("#kMemberName").val());
		frm.addParam("kReductionRate", reductionRate);

	    frm.addParam("enc_col", "hMemberId, kMemberName, userId");

	    frm.addParam("hApplyCode",$("#hApplyCode").val());
	    frm.setAction("<c:url value='/reduction/popupUpdate.do' />");
		frm.request();
	}

	function handleIS(data, textStatus, jqXHR) {
		if(data.count > 0){
    		window.close();
    		opener.loadTableData();
    	}
	}

	// 제약조건
    function validation(type){
		var text = "";

		// 거절 버튼 클릭 시
		if(type == "Refusal"){

			if($("#kRejectReason").val() == ""){
				alert("감면 신청 건의 거절사유를 입력해주세요.");
				$("#kRejectReason").focus();
				return false;
			}
			text = "감면 신청 건을 거절하시겠습니까?"
		}else{
			if("${param.confirmYn}" == "Y"){
				text = "감면유효기간을 저장하시겠습니까?";
			}else{
				text = "감면 신청 건을 승인하시겠습니까?";	
			}
		}

		if(confirm(text)){
			saveData(type);
		}
    }
	//이미지 팝업창 생성
	function openPopup(imageSrc){
		OpenPopupSingle("/sys/imagePopup.do", 1800, 990, "imagePopup");
//      var imageWin = new Image();
//      imageWin = window.open("", "", "width=1350px, height=1000px,scrollbars = yes");
//      imageWin.document.write("<html><body style='margin:0 auto;'>");
//      imageWin.document.write("<div style='height:100%'>");
//      imageWin.document.write("<img src='"
//      		+ imageSrc
//      		+ "' border=0 ");
//      imageWin.document.write("</div>");
//      imageWin.document.write("</body><html>");
//      imageWin.document.title = "imagePopup";

	}
	
	function zoomInImage() {
	    if(downloadCode.length > 0) {
	        startDownload(downloadCode, "W");
	    } else {
            imageUriData = $("#imgView").attr("src");
            openPopup($("#imgView").attr("src"));
	    }
    }

	$(function(){

		// 앞뒤공백없애기
		$("#kRejectReason").on("blur",function(){
        	$(this).val($.trim($(this).val()));
		});

		// 크게 보기
		$("#btnzoomIn").click(function() {
		    zoomInImage();
		});

		// 승인
		$("#btnApproval").click(function() {
			if($("#kRedExpDate").val() <= moment().format('YYYY-MM-DD')){
				alert("감면유효기간은 금일을 제외한 이후 일자로 선택해 주세요.");
				return false
			}else{
				validation("Approval");
			}
		});

		// 거절
		$("#btnRefusal").click(function() {
			validation("Refusal");
		});

		// 닫기
		$("#btnClose").click(function() {
			window.close();
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
	<div class="row padding-left-10 padding-right-10">
		<div class="bottom-btn-area">
			<div class="col-xl-6 col-lg-6 col-md-6 col-sm-12 col-12"></div>
			<div class="col-xl-6 col-lg-6 col-md-6 col-sm-12 col-12 text-right">
				<%-- <c:if test="${param.confirmYn eq 'Y' && param.delYn eq 'N' }">
					<form:button type="Approval" id="btnApproval" caption="저장"/>
				</c:if> --%>
				<c:if test="${param.confirmYn eq 'N' && param.delYn eq 'N' }">
					<form:button type="Approval" id="btnApproval" />
					<form:button type="Refusal" id="btnRefusal" />
				</c:if>
				<form:button type="Close" id="btnClose" />
			</div>
			<label:clear />
		</div>
	</div>
</div>