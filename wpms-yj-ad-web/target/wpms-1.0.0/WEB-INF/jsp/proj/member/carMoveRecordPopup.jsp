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
	var imageUriData = "";
	var downCode1 = "", downCode2 = "";
	
	function loadTableDetail() {
		var frm = $("#frmMain");
		
		frm.addParam("func", "IQ");
		frm.addParam("query_id", "member.carMoveRecord.select_carInfo");
		frm.addParam("enc_col", "hMemberId");
		frm.addParam("dataType", "json"); // 그리드 불러오는 타입 (기본 json)
		frm.request();
	}

	function handleIQ(data, textStatus, jqXHR) {
		if(data.length > 0){
			$("#kMemberName").val(data[0].memberName);
			$("#kCarNo").val(data[0].carNo);
			$("#kCarAlias").val(data[0].carAlias);
			$("#kFrightCarYn").val(data[0].frightCarYn);

// 			if(data[0].fileName === undefined){
// 				$("#image").attr("href","/walletfree-admin/images/no_img.jpg");
// 				$("#image").children().attr("src","/walletfree-admin/images/no_img.jpg");
// 			}else{
				
// 				if(data.fileExt == "pdf"){
// 					$("#image").children().attr("src","/walletfree-admin/images/no_img.jpg");
// 					$("#iframe").trigger("click");
// 				}else{
// 					$("#iframe").attr("href",userUrl+data[0].fileName);	
// 					$("#image").children().attr("src",userUrl+data[0].fileName);
// 				}	
// 			}

            if(data[0].fileName !== undefined && data[0].delYn == "N") {
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
            }else{
            	$("#image img").attr("src", "<c:url value='/images/img_delete.jpg'/>");
                $("#image")[0].onclick = "";
                
                $("#iframe").remove();
                
                $("#btnIframe").html("");
                $("#btnIframe").attr("style", "height: 34px;");
            }
		}
	}
	
	// IQ에 대한 이미지
    function handleIQ_Img(data, textStatus, jqXHR) {
        if(data.data.imgDataUri && data.data.imgDataUri.length > 0) {
            $("#image img").attr("src", data.data.imgDataUri);
        }
    }
	
    // IQ DNC
    function handleIQ_DNC(data, textStatus, jqXHR) {
        if(data.data.encData && data.data.encData.length > 0) {
            downCode1 = data.data.encData;
        }
    }
	
	function loadTableDetail2() {
		var frm = $("#frmMain");
		
		frm.addParam("func", "IQ2");
		frm.addParam("query_id", "member.carMoveRecord.select_approvalCarInfo");
		frm.addParam("dataType", "json"); // 그리드 불러오는 타입 (기본 json)
		frm.request();
	}

	function handleIQ2(data, textStatus, jqXHR) {
		if(data.length > 0){
			
			$("#approveMemberName").val(data[0].memberName);
			$("#approveCarNo").val(data[0].carNo);
			$("#approveCarAlias").val(data[0].carAlias);
			$("#approveMemberId").val(data[0].memberId);
			$("#approveFrightCarYn").val(data[0].frightCarYn);
			
// 			if(data[0].fileName === undefined){
// 				$("#approveImage").attr("href","/walletfree-admin/images/no_img.jpg");
// 				$("#approveImage").children().attr("src","/walletfree-admin/images/no_img.jpg");
// 			}else{
				
// 				if(data.fileExt == "pdf"){
// 					$("#approveImage").children().attr("src","/walletfree-admin/images/no_img.jpg");
// 					$("#approveIframe").trigger("click");
// 				}else{
// 					$("#approveImage").children().attr("src",userUrl+data[0].fileName);
// 				}	
// 			}

            if(data[0].fileName !== undefined) {
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
            }else{
            	$("#approveImage img").attr("src", "<c:url value='/images/img_delete.jpg'/>");
                $("#approveImage")[0].onclick = "";
                
                $("#approveIframe").remove();
                
                $("#btnApproveIframe").html("");
                $("#btnApproveIframe").attr("style", "height: 34px;");
            }
		}
	}
	
	// IQ2에 대한 이미지
    function handleIQ2_Img(data, textStatus, jqXHR) {
        if(data.data.imgDataUri && data.data.imgDataUri.length > 0) {
            $("#approveImage img").attr("src", data.data.imgDataUri);
        }
    }
	
    // IQ2 DNC
    function handleIQ2_DNC(data, textStatus, jqXHR) {
        if(data.data.encData && data.data.encData.length > 0) {
            downCode2 = data.data.encData;
        }
    }
	
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
	    if(downCode1.length > 0) {
	        startDownload(downCode1, "W");
	    } else {
	        imageUriData = $("#image img").attr("src");
	        openPopup($("#image img").attr("src"));
	    }
    }
    
    function zoomInApproveImage() {
        if(downCode2.length > 0) {
            startDownload(downCode2, "W");
        } else {
	        imageUriData = $("#approveImage img").attr("src");
	        openPopup($("#approveImage img").attr('src'));
        }
    }
	
	$(function() {
		// 크게 보기
		$("#btnzoomIn").click(function() {
		    zoomInImage();
		});
		
		// 크게 보기
		$("#btnApproveZoomIn").click(function() {
		    zoomInApproveImage();
		});
		
		// 닫기
		$("#btnClose").click(function() {
			window.close();
		});

		$(window).trigger("resize");
		loadTableDetail();
		loadTableDetail2();

		$(".ag-body-horizontal-scroll").remove();

	});
</script>

<div class="page-body" style="font-size: 0.9em;">
	<div class="row">
		<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12 arrow_wrap" id="mainContent">
			<div class="col-xl-6 col-lg-6 col-md-6 col-sm-12 col-12">
				<card:open title="기존 정보" />
				<card:button>
				</card:button>
				<card:content />
				<form id="frmMain2" name="frmMain2" method="post" onsubmit="return false" class="form-horizontal" >
		            <form:input id="approveMemberId" type="hidden"/>
					<label:input id="approveMemberName" caption="이름" size="12" state="readonly"/>
		            <label:input id="approveCarAlias" caption="차량별칭" size="12" state="readonly"/>
		            <label:input id="approveCarNo" caption="차량번호" size="12" state="readonly"/>
		            <label:input id="approveFrightCarYn" caption="대형차량 여부" size="12" state="readonly" addAttr="style='text-align:center;'"/>
				</form>
				<card:close />
			</div>
			<p class="adm_arrow" id="admArrow"><i class="fas fa-arrow-right" data-icon="fas fa-eye"></i></p>
			<div class="col-xl-6 col-lg-6 col-md-6 col-sm-12 col-12">
				<card:open title="이관 정보" />
				<card:button>
				</card:button>
				<card:content />
				<form id="frmMain" name="frmMain" method="post" onsubmit="return false" class="form-horizontal" >
					<form:input id="hMemberId" type="hidden" value="${param.memberId}" />
					<form:input id="hApplyCode" type="hidden" value="${param.applyCode}" />
					<form:input id="carNo" type="hidden" value="${param.carNo}" />
					<form:input id="hSeq" type="hidden" value="${param.hSeq}" />
					<label:input id="kMemberName" caption="이름" size="12" state="readonly"/>
		            <label:input id="kCarAlias" caption="차량별칭" size="12" state="readonly"/>
		            <label:input id="kCarNo" caption="차량번호" size="12" state="readonly"/>
		            <label:input id="kFrightCarYn" caption="대형차량 여부" size="12" state="readonly" addAttr="style='text-align:center;'"/>
				</form>
				<card:close />
			</div>
		</div>
		<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12" id="mainContent2">
			<div class="col-xl-6 col-lg-6 col-md-6 col-sm-12 col-12">
				<div class="card">
				    <div class="card-header">
				        <h5>기존 파일 정보</h5>
					</div>
					<div class="card-block table-border-style" id="approveFileDiv">
						<a onClick="zoomInApproveImage()" id="approveImage" style='cursor:pointer'>
							<img src="<c:url value='/images/no_img.jpg'/>" alt="empty.png" style="height:235px; width:100%; margin-bottom: 15px; border: 1px solid #eee; border-radius: 22px;">
						</a>
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
				        <h5 id="applyFileName">이관 파일 정보</h5>
					</div>
					<div class="card-block table-border-style" id="fileDiv">
						<a onClick="zoomInImage()" id="image" style='cursor:pointer'>
							<img src="<c:url value='/images/no_img.jpg'/>" alt="empty.png" style="height:235px; width:100%; margin-bottom: 15px; border: 1px solid #eee; border-radius: 22px;">
						</a>
						<a href="<c:url value='/images/no_img.jpg'/>" id="iframe" data-fancybox="" data-small-btn="true" style="display:none;" data-options='{"type" : "iframe", "iframe" : {"preload" : false, "css" : {"width" : "450px","height" : "450px"}}}'></a>
						<div class="text-right" id="btnIframe">
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
				<form:button type="Close" id="btnClose" />
			</div>
			<label:clear />
		</div>
	</div>
</div>


<%@ include file="../../core/include/footerPopup.jsp" %>
