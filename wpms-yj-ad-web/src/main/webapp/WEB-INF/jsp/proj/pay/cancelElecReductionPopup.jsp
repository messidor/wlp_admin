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

	function loadTableDetail() {
		var frm = $("#frmMain");
		frm.addParam("func", "IQ");
		frm.addParam("query_id", "pay.cancelElecReduction.Select_PopupList");
		frm.addParam("hMemberId", $("#hMemberId").val());
		frm.addParam("enc_col", "hMemberId");
		frm.addParam("dataType", "json");		   // 그리드 불러오는 타입 (기본 json)
		frm.request();
	}


	function handleIQ(data, textStatus, jqXHR) {
		if(data.length > 0){
			// 취소상태 -> 취소사유 readonly, 취소버튼 숨김
// 			if(data[0].cancelGubn == "D") {
// 				$("#btnCancel").hide();
// 				$("#cancelReason").attr("readonly", true);
// 				$("#cancelReason").siblings("span").children("i").removeClass();
// 				$("#cancelReason").siblings("span").children("i").addClass("fas fa-eye");
// 				$("#cancelReason").css("background-color", "#EEEEEE");
// 			} else {
// 				$("#cancelReason").val("");
// 			}
			
			$("#frmMain").formSet(data);
			$("#hFileRelKey").val(data[0].fileRelKey)
			
		    if(data[0].fileName !== null) {
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

	function saveData() {
		var frm = $("#frmMain");
		
		frm.addParam("cancelReason", $("#cancelReason").val());
		frm.addParam("hElecApplyCode", $("#hElecApplyCode").val());
		frm.addParam("hCarNo", $("#hCarNo").val());
		frm.addParam("hMemberId", $("#hMemberId").val());
		
		frm.addParam("func", "IS");
		frm.setAction("<c:url value='/payment/elecReductionCancel.do' />");
		frm.addParam("dataType", "json");
		frm.request();
	}

	function handleIS(data, textStatus, jqXHR) {
		if(data.count> 0) {
			if (opener && typeof opener.loadTableData === "function") {
				opener.loadTableData();
			}
		 	window.close();
		}
	}
	
	$(function(){
		// 취소
		$("#btnCancel").click(function() {
			if(confirm("취소하시겠습니까?")){
				saveData();
			}
		});

		// 크게 보기
		$("#btnzoomIn").click(function() {
		    zoomInImage();
		});

		// 닫기
		$("#btnClose").click(function() {
			window.close();
		});
		

		//최초 갭 : 205
		$(window).on("resize", function() {
			$(".card-block").eq(0).css("height", $("#fileDiv").innerHeight());
			$(".card-block").eq(1).css("height", $(".card-block").eq(0).innerHeight());
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
				<card:open title="전기차 충전 할인 내역 상세" />
				<card:button>
				</card:button>
				<card:content />
				<form id="frmMain" name="frmMain" method="post" onsubmit="return false" class="form-horizontal" >
					<form:input id="hElecApplyCode" type="hidden" value="${param.elecApplyCode}" />
					<form:input id="hMemberId" type="hidden" value="${param.memberId}" />
					<form:input id="hCarNo" type="hidden" value="${param.carNo}" />
					<form:input id="hFileRelKey" type="hidden" />
					
					<label:input id="carNo" caption="차량번호" size="12" state="readonly"/>
		            <label:input id="applyDt" caption="신청일시" size="12" state="readonly"/>
<%-- 		            <label:input id="parkingName" caption="주차장" size="12" state="readonly"/> --%>
		            <label:input id="electDate" caption="충전일시" size="12" state="readonly"/>
		            <label:input id="cancelGubnName" caption="취소구분" size="12" state="readonly" addAttr="style='text-align:center;'"/>
		            <c:choose>
		            	<c:when test="${param.type eq 'D'}">
		            		 <c:if test="${param.cancelGubn eq 'Y'}">
				            	<label:input id="cancelName" caption="취소자" size="12" state="readonly"/>
				            	<label:input id="cancelDt" caption="취소일시" size="12" state="readonly"/>
				            	<label:textarea id="cancelReason" caption="취소사유" rows="4" size="12" state="readonly" addAttr="style='background-color : #EEEEEE'"/>
							</c:if>
		            	</c:when>
		            	<c:when test="${param.type eq 'C'}">
		            		<label:textarea id="cancelReason" caption="취소사유" rows="4" size="12" />
		            	</c:when>
		            </c:choose>
				</form>
				<card:close />
			</div>
			<div class="col-xl-6 col-lg-6 col-md-6 col-sm-12 col-12">
				<div class="card">
				    <div class="card-header">
				        <h5>첨부 파일</h5>
					</div>
					<div class="card-block table-border-style" id="fileDiv">
						<div onClick="zoomInImage()" id="image">
							<div style="width: 400px; height: 400px;">
								<img src="<c:url value='/images/no_img.jpg'/>" id="imgView" style="height:100%; width:100%; object-fit: contain; border: 1px solid #eee; border-radius: 15px; background-color: #f1f1f1;">
							</div>
						</div>
						<a href="<c:url value='/images/no_img.jpg'/>" id="iframe" data-fancybox="" data-small-btn="true" style="display:none;" data-options='{"type" : "iframe", "iframe" : {"preload" : false, "css" : {"width" : "450px","height" : "450px"}}}'></a>
						<div class="text-right" style="margin-top: 20px;">
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
			<div class="col-xl-6 col-lg-6 col-md-6 col-sm-12 col-12"></div>
			<div class="col-xl-6 col-lg-6 col-md-6 col-sm-12 col-12 text-right">
				<c:if test="${param.type eq 'C'}">
					<form:button type="Cancel" id="btnCancel" />
				</c:if>
				
				<form:button type="Close" id="btnClose" />
			</div>
			<label:clear />
		</div>
	</div>
</div>