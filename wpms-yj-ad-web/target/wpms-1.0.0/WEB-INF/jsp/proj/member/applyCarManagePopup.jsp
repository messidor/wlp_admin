<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="form" uri="http://ad.its.yeongju.kr/jsp/jstl/form" %>
<%@ taglib prefix="card" uri="http://ad.its.yeongju.kr/jsp/jstl/card" %>
<%@ taglib prefix="func" uri="http://ad.its.yeongju.kr/jsp/jstl/func" %>
<%@ taglib prefix="label" uri="http://ad.its.yeongju.kr/jsp/jstl/label" %>

<%@ include file="../../core/include/head.jsp" %>
<%@ include file="../../core/include/headerPopup.jsp" %>


<style type="text/css">
div.z-idx-item2 {
	margin-left: calc(50vw - 350px);
	margin-top: calc(30vh);
}
</style>

<script type="text/javascript">
	var userUrl = "${userUrl}";
	var overLap = "N";
	
	var imageUriData = "";
	
	var downloadCode = "";
	
	function loadTableDetail() {
		var frm = $("#frmMain");
		
		frm.addParam("carNo", "${param.carNo}");
		frm.addParam("func", "IQ");
		frm.addParam("query_id", "member.applyCarManage.select_applyCarInfo");
		frm.addParam("enc_col", "hMemberId");
		frm.addParam("dataType", "json"); // 그리드 불러오는 타입 (기본 json)
		frm.addParam("afterAction", false);
		frm.request();
	}
	
	function handleIQ(data, textStatus, jqXHR) {
		if(data[0].cnt > 0){
			overLap = "Y";
		}
		
		view_gubn();
		
		loadTableDetail2();
		loadTableDetail3();
	}
	
	function loadTableDetail2() {
		var frm = $("#frmMain");
		
		frm.addParam("func", "IQ2");
		frm.addParam("query_id", "member.applyCarManage.select_carInfo");
		frm.addParam("enc_col", "hMemberId");
		frm.addParam("dataType", "json"); // 그리드 불러오는 타입 (기본 json)
		frm.request();
	}

	function handleIQ2(data, textStatus, jqXHR) {
		console.log(data);
		if(data.length > 0){
			$("#kMemberId").val(data[0].memberId);
			$("#kMemberName").val(data[0].memberName);
			$("#kCarNo").val(data[0].carNo);
			$("#kCarAlias").val(data[0].carAlias);
			$("#kFrightCarYn").val(data[0].frightCarYn);
			//수동감면시 팝업 데이터 추가
			$("#KCarManualApplyYn").val(data[0].carManualApplyYn);
			$("#kCarCc").val(data[0].carCc);
			$("#KCarLength").val(data[0].carLength);
			$("#KridingCnt").val(data[0].ridingCnt);
			$("#KCarType").val(data[0].carType);
			$("#KlowPltGubn").val(data[0].lowPltGubn);



			if(data[0].confirmGubn != 'N'){
				if(overLap == "Y"){
					if(data[0].confirmGubn == 'C'){
						$("#kRejectReason").val(data[0].rejectReason);
						$("#kRejectReason").attr("readonly", true);
						$("#kRejectReason").siblings("span").children("i").removeClass();
						$("#kRejectReason").siblings("span").children("i").addClass("fas fa-eye");
						$("#kRejectReason").siblings("span").children("i").data("icon", "fas fa-eye");
						$("#kRejectReason").css("background-color", "#EEEEEE");
					}else{
						$("#changeRejectReason").val(data[0].rejectReason);
						$("#changeRejectReason").attr("readonly", true);
						$("#changeRejectReason").siblings("span").children("i").removeClass();
						$("#changeRejectReason").siblings("span").children("i").addClass("fas fa-eye");
						$("#changeRejectReason").siblings("span").children("i").data("icon", "fas fa-eye");
						$("#changeRejectReason").css("background-color", "#EEEEEE");	
					}				
				}else{
					$("#kRejectReason").val(data[0].rejectReason);
					$("#kRejectReason").attr("readonly", true);
					$("#kRejectReason").siblings("span").children("i").removeClass();
					$("#kRejectReason").siblings("span").children("i").addClass("fas fa-eye");
					$("#kRejectReason").siblings("span").children("i").data("icon", "fas fa-eye");
					$("#kRejectReason").css("background-color", "#EEEEEE");
				}
				if(data[0].confirmGubn == 'Y'){
					$("#kRejectReason").parent("div").parent("div").parent("div").css("display", "none");
				}
			}

// 			if(data[0].fileName === undefined){
// 				$("#image").attr("href","/walletfree-admin/images/no_img.jpg");
// 				$("#image").children().attr("src","/walletfree-admin/images/no_img.jpg");
// 			}else{
				
// 				if(data.fileExt == "pdf"){
// 					$("#image").children().attr("src","/walletfree-admin/images/no_img.jpg");
// 					$("#iframe").trigger("click");
// 				}else{
// 					$("#image").attr("href",userUrl+data[0].fileName);
// 					$("#iframe").attr("href",userUrl+data[0].fileName);	
// 					$("#image").children().attr("src",userUrl+data[0].fileName);
// 				}	
// 			}
			
			if(data[0].fileName !== undefined && data[0].delYn == "N") {
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
	}
	
	// IQ2에 대한 이미지
	function handleIQ2_Img(data, textStatus, jqXHR) {
	    if(data.data.imgDataUri && data.data.imgDataUri.length > 0) {
	        $("#image img").attr("src", data.data.imgDataUri);
	    }
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
    }
	
	function loadTableDetail3() {
		var frm = $("#frmMain");
		
		frm.addParam("func", "IQ3");
		frm.addParam("query_id", "member.applyCarManage.select_approvalCarInfo");
		frm.addParam("car_no", "${param.carNo}");
		frm.addParam("hSeq", "${param.hSeq}");
		frm.addParam("dataType", "json"); // 그리드 불러오는 타입 (기본 json)
		frm.request();
	}

	function handleIQ3(data, textStatus, jqXHR) {
		if(data.length > 0){
			$("#approveMemberName").val(data[0].memberName);
			$("#approveCarNo").val(data[0].carNo);
			$("#approveCarAlias").val(data[0].carAlias);
			$("#approveMemberId").val(data[0].memberId);
			$("#approveMemberInputId").val(data[0].memberId);
			$("#approveFrightCarYn").val(data[0].frightCarYn);
// 			if(data[0].fileName === undefined){
// 				$("#approveImage").attr("href","/walletfree-admin/images/no_img.jpg");
// 				$("#approveImage").children().attr("src","/walletfree-admin/images/no_img.jpg");
// 			}else{
				
// 				if(data.fileExt == "pdf"){
// 					$("#approveImage").children().attr("src","/walletfree-admin/images/no_img.jpg");
// 					$("#approveIframe").trigger("click");
// 				}else{
// 					$("#approveImage").attr("href",userUrl+data[0].fileName);
// 					$("#approveIframe").attr("href",userUrl+data[0].fileName);	
// 					$("#approveImage").children().attr("src",userUrl+data[0].fileName);
// 				}	
// 			}

		    if(data[0].fileName !== undefined) {
		    	$("#approveFileRelKey").val(data[0].fileRelKey);
                if(data[0].mimeType.indexOf("image/") > -1) {
                    var frm = $("#frmMain");
                    frm.addParam("func", "IQ3_Img");
                    frm.setAction("<c:url value='/upload/getImgDataUri.do' />");
                    frm.addParam("fileRelKey", data[0].fileRelKey);
                    frm.addParam("fileKey", data[0].fileKey);
                    frm.addParam("fileName", data[0].fileName);
                    frm.addParam("dataType", "json");
                    frm.request();
                } else {
                    var frm = $("#frmMain");
                    frm.addParam("func", "IQ3_DNC");
                    frm.setAction("<c:url value='/upload/getEncFileData.do' />");
                    frm.addParam("fileRelKey", data[0].fileRelKey);
                    frm.addParam("fileKey", data[0].fileKey);
                    frm.addParam("fileName", data[0].fileName);
                    frm.addParam("dataType", "json");
                    frm.request();
                }
            }else{
            	$("#approveImage img").attr("src", "<c:url value='/images/img_delete.jpg'/>");
                $("#approveImage")[0].onclick = "";
                
                $("#approveIframe").remove();
                
                $("#btnApproveIframe").html("");
                $("#btnApproveIframe").attr("style", "height: 34px;");
            }
		}
	}
	
	// IQ3에 대한 이미지
    function handleIQ3_Img(data, textStatus, jqXHR) {
        if(data.data.imgDataUri && data.data.imgDataUri.length > 0) {
            $("#approveImage img").attr("src", data.data.imgDataUri);
        }
    }
	
    // IQ3 DNC
    function handleIQ3_DNC(data, textStatus, jqXHR) {
        if(data.data.encData && data.data.encData.length > 0) {
            downloadCode = data.data.encData;
            $("#btnApproveZoomIn span").removeClass("fa fa-search-plus").addClass("far fa-download");
            $("#btnApproveZoomIn").html("").append("<span class=\"fa fa-download\"></span>&nbsp;첨부파일 다운로드");
            
            $("#approveImage")[0].onclick = "";
            $("#approveImage img").attr("src", "<c:url value='/images/no_preview.jpg'/>");
        }
    }
	
	function saveData(type) {
		// 기존 로직 변경하지 않기위해 아래와같이 처리
		// 승인 / 거절 타입
		var grd_type = [type];
		var grd_reject_reason = "";
		if(overLap == "Y"){
			grd_reject_reason = [$("#changeRejectReason").val()];
		}else{
			grd_reject_reason = [$("#kRejectReason").val()];			
		}
		var grd_car_no = [$("#kCarNo").val()];
		var grd_over_lap = [overLap];

	    var frm = $("#frmMain");
	    frm.addParam("func", "IS");
	    frm.addParam("dataType", "json");

	    frm.addParam("grd_type", grd_type);
	    frm.addParam("grd_reject_reason", grd_reject_reason);
	    frm.addParam("grd_car_no", grd_car_no);
	    frm.addParam("grd_over_lap", grd_over_lap);
	    frm.addParam("hMemberId", $("#hMemberId").val());
	    frm.addParam("kMemberName", $("#kMemberName").val());
	    frm.addParam("approveMemberId", $("#approveMemberId").val());
	    frm.addParam("fileRelKey", $("#approveFileRelKey").val());
	    
		frm.addParam("enc_col", "hMemberId, kMemberName, userId, approveMemberId");

	    frm.addParam("hApplyCode",$("#hApplyCode").val());
	    frm.addParam("hSmsGubn",$("#hSmsGubn").val());
	    frm.setAction("<c:url value='/member/applyCarUpdate.do' />");
		frm.request();
	}

    function handleIS(data, textStatus, jqXHR){
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
			if(overLap == "Y"){
				if($("#changeRejectReason").val() == ""){
					alert("차량 신청 건의 거절사유를 입력해주세요.");
					$("#changeRejectReason").focus();
					return false;
				}
			}else{
				if($("#kRejectReason").val() == ""){
					alert("차량 신청 건의 거절사유를 입력해주세요.");
					$("#kRejectReason").focus();
					return false;
				}				
			}
			text = "차량 신청 건을 거절하시겠습니까?"
		}else{
			text = "차량 신청 건을 승인하시겠습니까?";
		}

		if(confirm(text)){
			saveData(type);
		}
    }
	
	function view_gubn(){
		if("${param.confirmGubn}" == "C" && "${param.confirmCnt}" > 0){
			$("#mainContent").children().eq(0).hide();
			$("#mainContent2").children().eq(0).hide();
			$("#rejectContent").hide();
			$("#kRejectReason").parent().parent().parent().show();
			
			$("#admArrow").hide();
			$("#admImgArrow").hide();
			
			$("#mainContent").removeClass("col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12");
			$("#mainContent2").removeClass("col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12");
			$("#mainContent").addClass("col-xl-6 col-lg-6 col-md-6 col-sm-12 col-12");
			$("#mainContent2").addClass("col-xl-6 col-lg-6 col-md-6 col-sm-12 col-12");

			$("#mainContent").children().eq(2).removeClass("col-xl-6 col-lg-6 col-md-6 col-sm-12 col-12");
			$("#mainContent2").children().eq(2).removeClass("col-xl-6 col-lg-6 col-md-6 col-sm-12 col-12");
			$("#mainContent").children().eq(2).addClass("col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12");
			$("#mainContent2").children().eq(2).addClass("col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12");
			
			$("#image").css("height", "400px");
			$("#image img").css("height", "390px");
			$("#fileDiv").css("height", "495px");
			//최초 갭 : 205
			//$(window).on("resize", function() {
				$(".card-block").eq(0).css("height", $("#fileDiv").innerHeight());
				$(".card-block").eq(1).css("height", $("#fileDiv").innerHeight());
			//});
		}else if("${param.confirmGubn}" == "N" && "${param.confirmCnt}" > 0){
			$("#mainContent").children().eq(0).show();
			$("#mainContent2").children().eq(0).show();
			$("#rejectContent").show();
			$("#kRejectReason").parent().parent().parent().hide();
			$("#approveImage").css("height", "235px");
			$("#image").css("height", "235px");
			$("#approveImage img").css("height", "225px");
			$("#image img").css("height", "225px");
		}else{
			if(overLap == "Y" && "${param.confirmCnt}" > 0){
				if("${param.hSeq}" > 0){
					$("#mainContent").children().eq(0).show();
					$("#mainContent2").children().eq(0).show();
					$("#rejectContent").show();
					$("#kRejectReason").parent().parent().parent().hide();
					$("#approveImage").css("height", "235px");
					$("#image").css("height", "235px");
					$("#approveImage img").css("height", "225px");
					$("#image img").css("height", "225px");	
				}else{
					$("#mainContent").children().eq(0).hide();
					$("#mainContent2").children().eq(0).hide();
					$("#rejectContent").hide();
					$("#kRejectReason").parent().parent().parent().show();
					$("#admArrow").hide();
					$("#admImgArrow").hide();
					
					$("#mainContent").removeClass("col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12");
					$("#mainContent2").removeClass("col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12");
					$("#mainContent").addClass("col-xl-6 col-lg-6 col-md-6 col-sm-12 col-12");
					$("#mainContent2").addClass("col-xl-6 col-lg-6 col-md-6 col-sm-12 col-12");

					$("#mainContent").children().eq(2).removeClass("col-xl-6 col-lg-6 col-md-6 col-sm-12 col-12");
					$("#mainContent2").children().eq(2).removeClass("col-xl-6 col-lg-6 col-md-6 col-sm-12 col-12");
					$("#mainContent").children().eq(2).addClass("col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12");
					$("#mainContent2").children().eq(2).addClass("col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12");
					
					$("#image").css("height", "400px");
					$("#image img").css("height", "390px");
					$("#fileDiv").css("height", "495px");
					//최초 갭 : 205
					//$(window).on("resize", function() {
						$(".card-block").eq(0).css("height", $("#fileDiv").innerHeight());
						$(".card-block").eq(1).css("height", $("#fileDiv").innerHeight());
					//});
				}
				
			}else{
				$("#mainContent").children().eq(0).hide();
				$("#mainContent2").children().eq(0).hide();
				$("#rejectContent").hide();
				$("#kRejectReason").parent().parent().parent().show();
				$("#admArrow").hide();
				$("#admImgArrow").hide();
				
				$("#mainContent").removeClass("col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12");
				$("#mainContent2").removeClass("col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12");
				$("#mainContent").addClass("col-xl-6 col-lg-6 col-md-6 col-sm-12 col-12");
				$("#mainContent2").addClass("col-xl-6 col-lg-6 col-md-6 col-sm-12 col-12");

				$("#mainContent").children().eq(2).removeClass("col-xl-6 col-lg-6 col-md-6 col-sm-12 col-12");
				$("#mainContent2").children().eq(2).removeClass("col-xl-6 col-lg-6 col-md-6 col-sm-12 col-12");
				$("#mainContent").children().eq(2).addClass("col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12");
				$("#mainContent2").children().eq(2).addClass("col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12");
				
				$("#image").css("height", "400px");
				$("#image img").css("height", "390px");
				$("#fileDiv").css("height", "495px");
				//최초 갭 : 205
				//$(window).on("resize", function() {
					$(".card-block").eq(0).css("height", $("#fileDiv").innerHeight());
					$(".card-block").eq(1).css("height", $("#fileDiv").innerHeight());
				//});
			}	
		}
	}
	
	//이미지 팝업창 생성
	function openPopup(imageSrc){
		OpenPopupSingle("/sys/imagePopup.do", 1800, 990, "imagePopup");
//         var imageWin = new Image();
//         imageWin = window.open("", "", "width=1350px, height=1000px,scrollbars = yes"); 
//         imageWin.document.write("<html><body style='margin:0 auto;'>"); 
//         imageWin.document.write("<div style='height:100%'>"); 
//         imageWin.document.write("<img src='" 
//         		+ imageSrc 
//         		+ "' border=0 "); 
//         imageWin.document.write("</div>");
//         imageWin.document.write("</body><html>"); 
//         imageWin.document.title = "imagePopup"; 
  	  
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
	
	$(function() {
		
		// 앞뒤공백없애기
		$("textarea.form-control").on("blur",function(){
        	$(this).val($.trim($(this).val()));
		});
		

		// 크게 보기
		$("#btnzoomIn").click(function() {
		    zoomInImage();
		});
		
		// 크게 보기
		$("#btnApproveZoomIn").click(function() {
		    zoomInApproveImage();
		});
		
		// 승인
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

		$(window).trigger("resize");
		loadTableDetail();

		$(".ag-body-horizontal-scroll").remove();

	});
</script>

<div class="page-body" style="font-size: 0.9em;">
	<div class="row">
		<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12 arrow_wrap" id="mainContent">
			<div class="col-xl-6 col-lg-6 col-md-6 col-sm-12 col-12">
				<card:open title="기 등록 차량 정보" />
				<card:button>
				</card:button>
				<card:content />
				<form id="frmMain2" name="frmMain2" method="post" onsubmit="return false" class="form-horizontal" >
					<form:input id="approveFileRelKey" type="hidden" />
		            <form:input id="approveMemberId" type="hidden"/>
		            <label:input id="approveMemberInputId" caption="ID" size="12" state="readonly"/>
					<label:input id="approveMemberName" caption="이름" size="12" state="readonly"/>
		            <label:input id="approveCarAlias" caption="차량별칭" size="12" state="readonly"/>
		            <label:input id="approveCarNo" caption="차량번호" size="12" state="readonly"/>
		            <label:input id="approveFrightCarYn" caption="대형차량 여부" size="12" state="readonly" addAttr="style='text-align:center;'" />
				</form>
				<card:close />
			</div>
			<p class="adm_arrow" id="admArrow"><i class="fas fa-arrow-right" data-icon="fas fa-eye"></i></p>
			<div class="col-xl-6 col-lg-6 col-md-6 col-sm-12 col-12">
				<card:open title="신청 정보" />
				<card:button>
				</card:button>
				<card:content />
				<form id="frmMain" name="frmMain" method="post" onsubmit="return false" class="form-horizontal" >
					<!-- 현재 로직 중 framMian에서 eq(?)번째 show hide 하는 부분이 있기 때문에 제거하거나 추가할 경우 로직 수정 필요합니다. -->
					<form:input id="hMemberId" type="hidden" value="${param.memberId}" />
					<form:input id="hApplyCode" type="hidden" value="${param.applyCode}" />
					<form:input id="hSmsGubn" type="hidden" value="${param.hSmsGubn}" />
					<label:input id="kMemberId" caption="ID" size="12" state="readonly"/>
					<label:input id="kMemberName" caption="이름" size="12" state="readonly"/>
		            <label:input id="kCarAlias" caption="차량별칭" size="12" state="readonly"/>
		            <label:input id="kCarNo" caption="차량번호" size="12" state="readonly"/>
		            <label:input id="kFrightCarYn" caption="대형차량 여부" size="12" state="readonly" addAttr="style='text-align:center;'"/>
					<c:if test="${param.carManualApplyYn eq 'Y'}">
						<label:input id="KCarManualApplyYn" caption="수동등록 여부" size="12" state="readonly"/>
						<label:input id="kCarCc" caption="배기량(CC)" size="12" state="readonly"/>
						<label:input id="KCarLength" caption="차량 길이(mm)" size="12" state="readonly"/>
						<label:input id="KridingCnt" caption="승차 정원" size="12" state="readonly"/>
						<label:input id="KCarType" caption="차량 종류" size="12" state="readonly"/>
						<label:input id="KlowPltGubn" caption="차량구분" size="12" state="readonly"/>
					</c:if>

					<label:textarea id="kRejectReason" caption="거절사유" size="12" rows="3"/>
				</form>
				<card:close />
			</div>
		</div>
		<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12" id="rejectContent">
			<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12">
				<card:open title="거절 사유" />
				<card:button>
				</card:button>
				<card:content />
				<form id="frmMain3" name="frmMain3" method="post" onsubmit="return false" class="form-horizontal" >
					<div class="form-group col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12 no-margin no-padding "> 
	                    <div class="input-group"> 
	                        <span class="input-group-addon"><i class="fas fa-pencil-alt" data-icon="fas fa-pencil-alt"></i></span> 
	                        <textarea name="changeRejectReason" id="changeRejectReason" class="form-control " rows="2"></textarea> 
	                    </div> 
		            </div>
				</form>
				<card:close />
			</div>
		</div>
		<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12" id="mainContent2">
			<div class="col-xl-6 col-lg-6 col-md-6 col-sm-12 col-12">
				<div class="card">
				    <div class="card-header">
				        <h5>기 등록 차량 파일 정보</h5>
					</div>
					<div class="card-block table-border-style" id="approveFileDiv">
						<div onClick="zoomInApproveImage()" id="approveImage" style="cursor:poiter">
							<img src="<c:url value='/images/no_img.jpg'/>" alt="empty.png" style="height:235px; width:100%; margin-bottom: 15px; border: 1px solid #eee; border-radius: 22px;">
						</div>
						<a href="<c:url value='/images/no_img.jpg'/>" id="approveIframe" data-fancybox="" data-small-btn="true" style="display:none;" data-options='{"type" : "iframe", "iframe" : {"preload" : false, "css" : {"width" : "450px","height" : "450px"}}}'></a>
						<div class="text-right" id="btnApproveIframe">
							<button type="button" id="btnApproveZoomIn" class="btn btn-sm waves-effect waves-light btn-info btn-outline-info default text-right">
							    <span class="fa fa-search-plus"></span>
							    &nbsp;크게보기
							</button>
						</div>
					</div>
				</div>
			</div>
			<p class="adm_arrow" id="admImgArrow"><i class="fas fa-arrow-right" data-icon="fas fa-eye"></i></p>
			<div class="col-xl-6 col-lg-6 col-md-6 col-sm-12 col-12">
				<div class="card">
				    <div class="card-header">
				        <h5 id="applyFileName">파일 정보</h5>
					</div>
					<div class="card-block table-border-style" id="fileDiv">
						<c:choose>
							<c:when test="${param.delYn eq 'Y' }">
								<div onClick="return false;" id="image" style='cursor:pointer'>
									<img src="<c:url value='/images/img_delete.jpg'/>" alt="empty.png" style="height:235px; width:100%; margin-bottom: 15px; border: 1px solid #eee; border-radius: 22px;">
								</div>
								<div style="height: 34px;"></div>
							</c:when>
							<c:otherwise>
								<div onClick="zoomInImage()" id="image" style='cursor:pointer'>
									<img src="<c:url value='/images/no_img.jpg'/>" alt="empty.png" style="height:235px; width:100%; margin-bottom: 15px; border: 1px solid #eee; border-radius: 22px;">
								</div>
								<a href="<c:url value='/images/no_img.jpg'/>" id="iframe" data-fancybox="" data-small-btn="true" style="display:none;" data-options='{"type" : "iframe", "iframe" : {"preload" : false, "css" : {"width" : "450px","height" : "450px"}}}'></a>
								<div class="text-right">
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
			<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12 text-right">
				<c:if test="${param.confirmGubn eq 'N' && param.delYn eq 'N'}">
					<form:button type="Approval" id="btnApproval" />
					<form:button type="Refusal" id="btnRefusal" />
				</c:if>
				<form:button type="Close" id="btnClose" />
			</div>
			<label:clear />
		</div>
	</div>
</div>


<%@ include file="../../core/include/footerPopup.jsp" %>
