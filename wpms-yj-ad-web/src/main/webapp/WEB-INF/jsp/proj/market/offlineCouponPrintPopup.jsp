<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="form" uri="http://ad.its.yeongju.kr/jsp/jstl/form"%>
<%@ taglib prefix="card" uri="http://ad.its.yeongju.kr/jsp/jstl/card"%>
<%@ taglib prefix="func" uri="http://ad.its.yeongju.kr/jsp/jstl/func"%>
<%@ taglib prefix="label" uri="http://ad.its.yeongju.kr/jsp/jstl/label"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%@ include file="../../core/include/head.jsp"%>
<%@ include file="../../core/include/headerPopup.jsp"%>

<style>
.print-area {
	width: 100%;
}

.print-page {
	width: 210mm;
	display: flex;
	flex-wrap: wrap;
	background: white;
	box-sizing: border-box;
	margin: 0 auto;
}
.print-page:not(:last-of-type) {
	margin-bottom: 10px;
}

.coupon_box {
	position: relative;
	width: 52.5mm;
	height: 92.5mm;
	box-sizing: border-box;
	padding: 0;
	margin: 0;
	text-align: center;
}

img {
	height: 25mm;
}

.text1{
	font-size: 29px;
	font-weight: 700;
	color: #000;
	padding-top: 5mm;
}

.text2{
	font-size: 20px;
	font-weight: 600;
	color: #000;
}
.text3{
	font-size: 14px;
	font-weight: 500;
	color: #000;
	position: absolute;
	bottom: 70px;
	justify-self: anchor-center;
}
.text4{
	font-size: 16px;
	font-weight: 500;
	color: #ff0000;
	position: absolute;
	bottom: 30px;
	justify-self: anchor-center;
}
.text5{
	font-size: 14px;
	font-weight: 500;
	color: #000;
	position: absolute;
	bottom: 0;
	justify-self: anchor-center;
}

@page {
	size: A4;
	margin:11mm; /* 테두리 없이 화면에 채우려면 0으로 수정 */
}

/* 인쇄 전용 */
@media print {
	html, body {
		margin: 0 !important;
		padding: 0 !important;
		background: white;
	}
	 
	.page-body{
		display: none;
	}
	
	.popup-content{
		padding: 0;
	}

	.print-page {
		width: 100%;
		margin-bottom: 0;
		page-break-after: always;
	}
	.coupon_box {
		width: 25%;
	}
}
</style>

<script type="text/javascript">

	function loadTableData() {
		var frm = $("#frmMain");
		frm.addParam("func", "IQ");
		frm.addParam("query_id", "market.offlineCouponManage.select_offCouponDetail");
		frm.addParam("dataType", "json");
		frm.request();
	}

	function handleIQ(data, textStatus, jqXHR) {
		let html = "";
		
		for (let i = 0; i < data.length; i++) {
			if (i % 16 == 0) {
				if (i != 0) html += '</div>'; // 이전 페이지 닫기
				html += '<div class="print-page">';
			}

			// 행
			let row = parseInt(i / 4);
			// 열
			let col = i % 4;

			// 모든 셀
			let borderStyle = "border-bottom: 1px solid #000;border-right: 1px solid #000;";
			// 맨 위
			if (row % 4 == 0) borderStyle += "border-top: 1px solid #000;";
			// 맨 왼쪽
			if (col == 0) borderStyle += "border-left: 1px solid #000;";
			
			html += `<div class="coupon_box" style="`+borderStyle+`">
						<p class="text1">`+data[i].title+`</p>
						<p class="text2">`+data[i].offCouponName+`</p>
						<img id="qr_img`+i+`"/>
						<p class="text3">(본권은 1회만 사용가능합니다.)</p>
						<p class="text4">구매 후 환불 불가</p>
						<p class="text5">`+data[i].pGovName+`</p>
					</div>`;
		}
		
		html += '</div>'; // 마지막 페이지 닫기
		
		$(".print-area").append(html);
		
		for (let i = 0; i < data.length; i++) {
			generateQR("qr_img" + i, data[i].couponCode);
		}
	}
	
	function generateQR(qrImageId, qrText) {
		const qrImage = $("#"+qrImageId);
		
		if (qrText.length > 0) {
			qrImage.attr("src", "https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=" + qrText);
		}
	}
	
	$(function(){
		$("#btnClose").click(function() {
			self.close();
		});
		
		$("#btnPrint").click(function(){
			window.print();
		});
		
		loadTableData();
	});
</script>

<form id="frmMain" name="frmMain" method="post" onsubmit="return false" class="form-horizontal" >
	<form:input id="hPrintCode" type="hidden" value="${param.printCode}"/>
</form>

<div class="page-body" style="font-size: 0.9em;">
	<div class="row padding-left-5 padding-right-5">
		<div class="bottom-btn-area">
			<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12 text-right">
				<form:button type="inspectionStatement" id="btnPrint" />
				<form:button type="Close" id="btnClose" />
			</div>
			<label:clear />
		</div>
	</div>
</div>
<div class="print-area">
</div>