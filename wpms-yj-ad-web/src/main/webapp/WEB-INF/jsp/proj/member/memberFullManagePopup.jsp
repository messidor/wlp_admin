<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="form" uri="http://ad.its.yeongju.kr/jsp/jstl/form" %>
<%@ taglib prefix="card" uri="http://ad.its.yeongju.kr/jsp/jstl/card" %>
<%@ taglib prefix="func" uri="http://ad.its.yeongju.kr/jsp/jstl/func" %>
<%@ taglib prefix="label" uri="http://ad.its.yeongju.kr/jsp/jstl/label" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%@ include file="../../core/include/head.jsp" %>
<%@ include file="../../core/include/headerPopup.jsp" %>


<link rel="stylesheet" type="text/css" href="../common/css/etc/import.css">

<style type="text/css">
div.z-idx-item2 {
	margin-left: calc(50vw - 350px);
	margin-top: calc(30vh);
}
body {background-color: #fff;}
#wrap {position: relative; min-width: 1800px;}
.top_car_search {display: flex; align-items: center; position:relative; padding: 20px; border-bottom: 15px solid #f8f8f8;}
.top_car_time {position: absolute; top: 80px; right: 20px; width: 330px;}
.top_car_time span {font-size: 30px; font-weight: 600; color: #121212;}
.top_car_search .car_left {margin-right: 40px;}


.top_car_search .car_left strong {display: block; margin-bottom:20px; font-size: 20px; color: #121212; font-weight: 600;}
.top_car_search .car_left input {width:272px; height:55px; padding:0 20px; margin-right:10px; font-size:16px; border: 1px solid #ddd;}
.top_car_search .car_left select {width:272px; height:55px; padding:0 20px; margin-right:10px; font-size:16px; border: 1px solid #ddd; cursor: pointer;}
.top_car_search .car_left .cont {display: flex;}
.top_car_search .car_left .cont .top_search_btn a {display:inline-block; width:100px; height:55px; text-align:center; line-height:55px; border:1px solid #ddd; font-size: 18px;}
.top_car_search .car_left .cont .top_search_btn a.check {background-color: #009ead; border:1px solid #009ead; color: #fff; font-weight: 600;}

.top_car_search .car_detail {display: flex; width: 25%; height: 55px; margin-top: 40px; line-height: 55px; border: 1px solid #ddd;}
.top_car_search .car_detail > div {display:flex; width: 100%; padding: 0 20px;}
.top_car_search .car_detail > div:first-child {border-right: 1px solid #ddd;}
.top_car_search .car_detail strong {margin-right: 20px; font-size: 18px;}
.top_car_search .car_detail p {font-size: 16px; color: #999;}

.board_search .center_cont {display:flex; justify-content: space-between; padding: 20px;}
.board_search .center_cont > div {width: 60%; margin-right: 30px;}
.board_search .center_cont > div:last-child {margin-right: 0;}
.board_search .center_cont > div.box_w100 {width: 100%;}
.board_search .car_cont01 {border-bottom: 15px solid #f8f8f8;}
.board_search .center_cont strong {display:block; margin-bottom:15px; font-size: 20px; color: #121212; font-weight: 600;}

.car_cont_box {border: 1px solid #ddd;}
.car_cont_box .box_top {display:flex; justify-content: space-between; font-size:16px; background-color: #f8f8f8;}
.car_cont_box .box_top p {width: 100%; padding:25px 5px; text-align: center; font-weight: 600;}
.car_cont_box .box_cont {display:flex; justify-content: space-between; font-size:15px; min-height: 71px;}
.car_cont_box .box_cont p {width: 100%; padding:25px 5px; text-align: center; color: #555;}
.car_cont_box .box_cont p.name {width:70%;}

.payment_list .box_top p {width: 30%;}
.payment_list .box_top p.name {width: 70%;}
.car_cont_box .payment_cont p {width: 30%;}
.car_cont_box .payment_cont p.name {width: 70%;}

.board_search .car_cont02 .first_cont {width: 36.6%;}
.payment_list .box_top p.date {width:50%;}
.car_cont_box .payment_cont p.date {width:50%;}
</style>

<script type="text/javascript">
	// 로딩 이미지 표시 여부
	//setLoadImage(false);

	var memberId = "${param.memberId}";
	var confirmYn = "${param.confirmYn}";
	var userUrl = "${userUrl}";

	function loadTableData() {
		var frm = $("#frmMain");
        frm.addParam("kCarNumber", $("#kCarNumber").val());
        frm.addParam("kParkingGovCode", $("#kParkingGovCode").val());
        frm.addParam("func", "IQ");
        frm.setAction("<c:url value='/member/memberFullManage.do' />");
        frm.addParam("dataType", "json");
        frm.addParam("afterAction", true);

        frm.request();
	}

	function handleIQ(data, textStatus, jqXHR) {
		var phone = "";
		
		if(data.data.memberCar.length > 0){
			phone = data.data.memberCar[0].memberPhone;
			$("#kMemberName").text(data.data.memberCar[0].memberName);
			$("#kMemberPhone").text(phone.replace(/^(\d{2,3})(\d{3,4})(\d{4})$/, `$1-$2-$3`));
		}else{
			$("#kMemberName").text("");
			$("#kMemberPhone").text("");
		}
		
		var parkingInOutList = "";
		var reductionInfo = "";
		var paymentList = "";
		var nonpaymentlist = "";
		var cancelRePaymentList = "";
		
		var boolArr = [false, false, false, false, false];
		
		$(".car_cont_box").eq(0).children().not(":eq(0)").remove();
		$(".car_cont_box").eq(1).children().not(":eq(0)").remove();
		$(".car_cont_box").eq(2).children().not(":eq(0)").remove();
		$(".car_cont_box").eq(3).children().not(":eq(0)").remove();
		$(".car_cont_box").eq(4).children().not(":eq(0)").remove();
		
		// 입출차 내역
		if(data.data.parkingInOutList.length > 0){
			for(var i=0; i<data.data.parkingInOutList.length; i++){
				parkingInOutList += "<div class='box_cont'>";
				parkingInOutList +=    "<p>" + data.data.parkingInOutList[i].parkingName + "</p>";
				parkingInOutList +=    "<p>" + data.data.parkingInOutList[i].pEntDt + "</p>";
				parkingInOutList +=    "<p>" + data.data.parkingInOutList[i].pOutDt + "</p>";
				parkingInOutList += "</div>";
			}
			if(data.data.parkingInOutList.length < 3){
				for(var i=0; i<3-data.data.parkingInOutList.length; i++){
					parkingInOutList += "<div class='box_cont'>";
					parkingInOutList +=    "<p></p>";
					parkingInOutList +=    "<p></p>";
					parkingInOutList +=    "<p></p>";
					parkingInOutList += "</div>";
				}
			}
			
			boolArr[0] = true;
			
		}else{
			parkingInOutList += "<div class='box_cont'>";
			parkingInOutList +=    "<p>조회된 데이터가 없습니다.</p>";
			parkingInOutList += "</div>";
			
			boolArr[0] = false;
		}
		
		// 감면 정보
		if(data.data.reductionInfo.length > 0){
			for(var i=0; i<data.data.reductionInfo.length; i++){
				if(i == 0){
					reductionInfo += "<div class='box_cont'>";
					reductionInfo +=    "<p style='background-color:yellow;'>" + data.data.reductionInfo[i].reductionName + "</p>";
					reductionInfo +=    "<p style='background-color:yellow;'>" + data.data.reductionInfo[i].reductionRate + "</p>";
					reductionInfo +=    "<p style='background-color:yellow;'>" + data.data.reductionInfo[i].redExpDate + "</p>";
					reductionInfo += "</div>";
				}else{
					reductionInfo += "<div class='box_cont'>";
					reductionInfo +=    "<p>" + data.data.reductionInfo[i].reductionName + "</p>";
					reductionInfo +=    "<p>" + data.data.reductionInfo[i].reductionRate + "</p>";
					reductionInfo +=    "<p>" + data.data.reductionInfo[i].redExpDate + "</p>";
					reductionInfo += "</div>";
				}
				
			}
			if(data.data.reductionInfo.length < 3){
				for(var i=0; i<3-data.data.reductionInfo.length; i++){
					reductionInfo += "<div class='box_cont'>";
					reductionInfo +=    "<p></p>";
					reductionInfo +=    "<p></p>";
					reductionInfo +=    "<p></p>";
					reductionInfo += "</div>";
				}
			}
			
			boolArr[3] = true;
			
		}else{
			reductionInfo += "<div class='box_cont'>";
			reductionInfo +=    "<p>조회된 데이터가 없습니다.</p>";
			reductionInfo += "</div>";

			boolArr[3] = false;
	        
		}
		
		// 결제 내역
		if(data.data.paymentList.length > 0){
			for(var i=0; i<data.data.paymentList.length; i++){
				paymentList += "<div class='box_cont payment_cont'>";
				paymentList +=    "<p class='date'>" + data.data.paymentList[i].regDt + "</p>";
				paymentList +=    "<p class='name'>" + data.data.paymentList[i].pGovName + "</p>";
				paymentList +=    "<p>" + data.data.paymentList[i].parkingName + "</p>";
				paymentList +=    "<p>" + data.data.paymentList[i].paymentGubnName + "</p>";
				paymentList +=    "<p>" + data.data.paymentList[i].parkingPrice + "</p>";
				paymentList += "</div>";
			}
			
			if(data.data.paymentList.length < 3){
				for(var i=0; i<3-data.data.paymentList.length; i++){
					paymentList += "<div class='box_cont payment_cont'>";
					paymentList +=    "<p></p>";
					paymentList +=    "<p class='name'></p>";
					paymentList +=    "<p></p>";
					paymentList +=    "<p></p>";
					paymentList +=    "<p></p>";
					paymentList += "</div>";
				}
			}
			
			boolArr[1] = true;
			
		}else{
			paymentList += "<div class='box_cont'>";
			paymentList +=    "<p>조회된 데이터가 없습니다.</p>";
			paymentList += "</div>";
			
			boolArr[1] = false;
	        
		}
		
		// 미납내역
		if(data.data.nonpaymentlist.length > 0){
			for(var i=0; i<data.data.nonpaymentlist.length; i++){
				nonpaymentlist += "<div class='box_cont'>";
				nonpaymentlist +=    "<p>" + data.data.nonpaymentlist[i].regDt + "</p>";
				nonpaymentlist +=    "<p>" + data.data.nonpaymentlist[i].parkingName + "</p>";
				nonpaymentlist +=    "<p>" + data.data.nonpaymentlist[i].parkingPrice + "</p>";
				nonpaymentlist += "</div>";
			}
			if(data.data.nonpaymentlist.length < 3){
				for(var i=0; i<3-data.data.nonpaymentlist.length; i++){
					nonpaymentlist += "<div class='box_cont'>";
					nonpaymentlist +=    "<p></p>";
					nonpaymentlist +=    "<p></p>";
					nonpaymentlist +=    "<p></p>";
					nonpaymentlist += "</div>";
				}
			}
			
			boolArr[2] = true;
			
		}else{
			nonpaymentlist += "<div class='box_cont'>";
			nonpaymentlist +=    "<p>조회된 데이터가 없습니다.</p>";
			nonpaymentlist += "</div>";
			
			boolArr[2] = false;
	        
		}
		
		// 결제취소/재결제 내역
		if(data.data.cancelRePaymentList.length > 0){
			
			for(var i=0; i<data.data.cancelRePaymentList.length; i++){
				
				var rejectReason = "";
				
				if(data.data.cancelRePaymentList[i].rejectReason == null){
					rejectReason = "";
				}else{
					rejectReason = data.data.cancelRePaymentList[i].rejectReason;
				}
				
				if(data.data.cancelRePaymentList[i].payGubn == "PG002"){
					cancelRePaymentList += "<div class='box_cont payment_cont'>";
					cancelRePaymentList +=    "<p class='date' style='color:red;'>" + data.data.cancelRePaymentList[i].regDt + "</p>";
					cancelRePaymentList +=    "<p  style='color:red;'>" + data.data.cancelRePaymentList[i].parkingName + "</p>";
					cancelRePaymentList +=    "<p class='name' style='color:red;'>" + data.data.cancelRePaymentList[i].pGovName + "</p>";
					cancelRePaymentList +=    "<p style='color:red;'>" + data.data.cancelRePaymentList[i].paymentGubnName + "</p>";
					cancelRePaymentList +=    "<p style='color:red;'>" + data.data.cancelRePaymentList[i].parkingPrice + "</p>";
					cancelRePaymentList +=    "<p style='color:red;'>" + data.data.cancelRePaymentList[i].nParkingPrice + "</p>";
					cancelRePaymentList +=    "<p style='color:red;'>" + data.data.cancelRePaymentList[i].payGubnName + "</p>";
					cancelRePaymentList +=    "<p style='color:red;'>" + rejectReason + "</p>";
					cancelRePaymentList += "</div>";
				}else if(data.data.cancelRePaymentList[i].payGubn == "PG004"){
					cancelRePaymentList += "<div class='box_cont payment_cont'>";
					cancelRePaymentList +=    "<p class='date' style='color:orange;'>" + data.data.cancelRePaymentList[i].regDt + "</p>";
					cancelRePaymentList +=    "<p style='color:orange;'>" + data.data.cancelRePaymentList[i].parkingName + "</p>";
					cancelRePaymentList +=    "<p class='name' style='color:orange;'>" + data.data.cancelRePaymentList[i].pGovName + "</p>";
					cancelRePaymentList +=    "<p style='color:orange;'>" + data.data.cancelRePaymentList[i].paymentGubnName + "</p>";
					cancelRePaymentList +=    "<p style='color:orange;'>" + data.data.cancelRePaymentList[i].parkingPrice + "</p>";
					cancelRePaymentList +=    "<p style='color:orange;'>" + data.data.cancelRePaymentList[i].nParkingPrice + "</p>";
					cancelRePaymentList +=    "<p style='color:orange;'>" + data.data.cancelRePaymentList[i].payGubnName + "</p>";
					cancelRePaymentList +=    "<p style='color:orange;'>" + rejectReason + "</p>";
					cancelRePaymentList += "</div>";
				}else{
					cancelRePaymentList += "<div class='box_cont payment_cont'>";
					cancelRePaymentList +=    "<p class='date'>" + data.data.cancelRePaymentList[i].regDt + "</p>";
					cancelRePaymentList +=    "<p>" + data.data.cancelRePaymentList[i].parkingName + "</p>";
					cancelRePaymentList +=    "<p class='name'>" + data.data.cancelRePaymentList[i].pGovName + "</p>";
					cancelRePaymentList +=    "<p>" + data.data.cancelRePaymentList[i].paymentGubnName + "</p>";
					cancelRePaymentList +=    "<p>" + data.data.cancelRePaymentList[i].parkingPrice + "</p>";
					cancelRePaymentList +=    "<p>" + data.data.cancelRePaymentList[i].nParkingPrice + "</p>";
					cancelRePaymentList +=    "<p>" + data.data.cancelRePaymentList[i].payGubnName + "</p>";
					cancelRePaymentList +=    "<p>" + rejectReason + "</p>";
					cancelRePaymentList += "</div>";
				}
				
				boolArr[4] = true;
				
			}
			
			if(data.data.cancelRePaymentList.length < 3){
				for(var i=0; i<3-data.data.cancelRePaymentList.length; i++){
					cancelRePaymentList += "<div class='box_cont payment_cont'>";
					cancelRePaymentList +=    "<p class='date'></p>";
					cancelRePaymentList +=    "<p></p>";
					cancelRePaymentList +=    "<p class='name'></p>";
					cancelRePaymentList +=    "<p></p>";
					cancelRePaymentList +=    "<p></p>";
					cancelRePaymentList +=    "<p></p>";
					cancelRePaymentList +=    "<p></p>";
					cancelRePaymentList +=    "<p></p>";
					cancelRePaymentList += "</div>";
				}
			}
		}else{
			cancelRePaymentList += "<div class='box_cont'>";
			cancelRePaymentList +=    "<p>조회된 데이터가 없습니다.</p>";
			cancelRePaymentList += "</div>";
			
			boolArr[4] = false;
	        
		}
		
		$(".car_cont_box").eq(0).append(parkingInOutList);
		$(".car_cont_box").eq(1).append(paymentList);
		$(".car_cont_box").eq(2).append(nonpaymentlist);
		$(".car_cont_box").eq(3).append(reductionInfo);
		$(".car_cont_box").eq(4).append(cancelRePaymentList);
		
		if(boolArr[0] === true){
			$(".car_cont_box").eq(0).children(".box_cont").css("min-height", "71px");
		}else if(boolArr[0] === false){
			$(".car_cont_box").eq(0).children(".box_cont").css("min-height", "213px");
		}
		if(boolArr[1] === true){
			$(".car_cont_box").eq(1).children(".box_cont").css("min-height", "71px");
		}else if(boolArr[1] === false){
			$(".car_cont_box").eq(1).children(".box_cont").css("min-height", "213px");
		}
		
		if(boolArr[2] === true){
			$(".car_cont_box").eq(2).children(".box_cont").css("min-height", "71px");
		}else if(boolArr[2] === false){
			$(".car_cont_box").eq(2).children(".box_cont").css("min-height", "213px");
		}
		
		if(boolArr[3] === true){
			$(".car_cont_box").eq(3).children(".box_cont").css("min-height", "71px");
		}else if(boolArr[3] === false){
			$(".car_cont_box").eq(3).children(".box_cont").css("min-height", "213px");
		}
		
		if(boolArr[4] === true){
			$(".car_cont_box").eq(4).children(".box_cont").css("min-height", "71px");
		}else if(boolArr[4] === false){
			$(".car_cont_box").eq(4).children(".box_cont").css("min-height", "213px");
		}
	}
	
	function btnSearch(){
		if(validation()){
			loadTableData();
		}
	}
	
	function btnClear(){
		$(".car_cont_box").eq(0).children().not(":eq(0)").remove();
		$(".car_cont_box").eq(1).children().not(":eq(0)").remove();
		$(".car_cont_box").eq(2).children().not(":eq(0)").remove();
		$(".car_cont_box").eq(3).children().not(":eq(0)").remove();
		$(".car_cont_box").eq(4).children().not(":eq(0)").remove();
		
		var clearHtml = "";
		var paymentHtml = "";
		
		clearHtml += "<div class='box_cont'>";
		clearHtml +=    "<p>조회된 데이터가 없습니다.</p>";
		clearHtml += "</div>";
		
		paymentHtml += "<div class='box_cont'>";
		paymentHtml +=    "<p>조회된 데이터가 없습니다.</p>";
		paymentHtml += "</div>";
		
		$(".car_cont_box").eq(0).append(clearHtml);
		$(".car_cont_box").eq(1).append(paymentHtml);
		$(".car_cont_box").eq(2).append(clearHtml);
		$(".car_cont_box").eq(3).append(clearHtml);
		$(".car_cont_box").eq(4).append(clearHtml);
		$("#kCarNumber").val("");
		$("#kMemberName").text("");
		$("#kMemberPhone").text("");
		$("#hMemberId").val("");
		$("#kParkingGovCode").find("option:eq(0)").prop("selected", true);
        $(".box_cont").css("min-height", "213px");
	}

	function getTime(){
        const time = new Date();
        const year = time.getFullYear();
        const month = ('0' + (time.getMonth() + 1)).slice(-2);
        const day = ('0' + time.getDate()).slice(-2);

        const hour = time.getHours();
        const minutes = time.getMinutes();
        const seconds = time.getSeconds();

        var html = "";
        var hour2 = "";
        var minutes2 = "";
        var seconds2 = ""; 
        
        if(hour < 10){
        	hour2 = "0" + hour;
        }else{
        	hour2 = hour;
        }
        
        if(minutes < 10){
        	minutes2 = "0" + minutes;
        }else{
        	minutes2 = minutes;
        }
        
        if(seconds < 10){
        	seconds2 = "0" + seconds;
        }else{
        	seconds2 = seconds;
        }
        
        
        $("#clock").text(year + "-" + month + "-" + day + " " + hour2 + ":" + minutes2 + ":" + seconds2);
    }

    function init(){
        setInterval(getTime, 1000);
    }

    function validation(){
    	if($("#kCarNumber").val() == ""){
    		notifyDanger("차량번호를 입력해주세요.");	
    		return false;
    	}
    	return true;
    }

    $(function() {
        clock = document.querySelector('#clock');
        
        $(".box_cont").css("min-height", "213px");
        
        $("#kCarNumber").keyup(function(event) {
            if (event.which === 13) {
            	if(validation()){
            		loadTableData();	
            	}
            }
        });
        
        $("#kParkingGovCode").change(function(){
        	loadTableData();
        });
        
        getTime();
        init();
    });
</script>

<div id="wrap">
    <!-- container -->
    <div class="board_search">
        <div class="top_car_search">
            <div class="top_car_time">
                <span id="clock"></span>
            </div>
            <div class="car_left">
                <strong>차량 검색</strong>
                <div class="cont">
					<form id="frmMain" name="frmMain" method="post" onsubmit="return false" class="form-material form-inline">	
	                    <input type="text" placeholder="차량 검색" id="kCarNumber" name="kCarNumber">
	                    <select name="kParkingGovCode" id="kParkingGovCode">
	                    	<c:choose>  
								<c:when test="${fn:contains(user_role_id, 'MANAGE') || fn:contains(user_role_id, 'AD')}"> 
	                    			<form:option queryId="select.select_parkingGovInfo" allLabel="전체" all="true" />
								</c:when> 
								<c:otherwise>
									<form:option queryId="select.select_parkingGovInfo" allLabel="전체" all="false" />
								</c:otherwise>
							</c:choose>
	                    </select>
	                </form>
                    <div class="top_search_btn">
                    	<a href="javascript:void(0);" onclick="btnSearch();" class="check">조회</a>
                        <a href="javascript:void(0);" onclick="btnClear();">초기화</a>
                    </div>
                </div>
            </div>
            <div class="car_detail">
                <div>
                    <strong>이름</strong>
                    <p id="kMemberName"></p>
                </div>
                <div>
                    <strong>연락처</strong>
                    <p id="kMemberPhone"></p>
                </div>
            </div>
        </div>
        <div class="car_cont01 center_cont">
            <div>
                <strong>입출차 내역 (최근 3건)</strong>
                <div class="car_cont_box">
                    <div class="box_top">
                        <p>주차장명</p>
                        <p>입차일시</p>
                        <p>출차일시</p>
                    </div>
                    <div class="box_cont">
                        <p>조회된 데이터가 없습니다.</p>
                    </div>
                </div>
            </div>
            <div class="box_w100">
                <strong>결제 내역 (최근 3건)</strong>
                <div class="car_cont_box payment_list">
                    <div class="box_top">
                        <p class="date">결제일시</p>
                        <p class='name'>관리기관명</p>
                        <p>주차장명</p>
                        <p>결제구분</p>
                        <p>주차요금</p>
                        <!-- <p>결제상태</p> -->
                    </div>
                    <div class="box_cont">
                        <p>조회된 데이터가 없습니다.</p>
                    </div>
                </div>
            </div>
            <div>
                <strong>미납 내역 (최근 3건)</strong>
                <div class="car_cont_box">
                    <div class="box_top">
                        <p>미납일시</p>
                        <p>주차장명</p>
                        <p>미납요금</p>
                    </div>
                    <div class="box_cont">
                        <p>조회된 데이터가 없습니다.</p>
                    </div>
                </div>
            </div>
        </div>
        <div class="car_cont02 center_cont">
            <div class="first_cont">
                <strong>감면 정보 (최대 3건)</strong>
                <div class="car_cont_box">
                    <div class="box_top">
                        <p>구분</p>
                        <p>감면율</p>
                        <p>유효기간</p>
                    </div>
                    <div class="box_cont">
                        <p>조회된 데이터가 없습니다.</p>
                    </div>
                </div>
            </div>
            <div class="box_w100">
                <strong>결제취소/재결제 신청내역 (최근 3건)</strong>
                <div class="car_cont_box payment_list">
                    <div class="box_top">
                        <p class="date">신청일시</p>
                        <p>주차장명</p>
                        <p class="name">관리기관</p>
                        <p>결제구분</p>
                        <p>주차요금</p>
                        <p>재결제요금</p>
                        <p>신청상태</p>
                        <p>거절사유</p>
                    </div>
                    <div class="box_cont">
                        <p>조회된 데이터가 없습니다.</p>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<%-- <div class="page-body" style="font-size: 0.9em;">
	<div class="row">
		<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12" id="search_all_wrapper">
			<card:open title="차량 검색" />
			<card:button>
				<form:button type="Search" id="btnSearch" />
                <form:button type="Clear" id="btnClear" />
			</card:button>
			<card:content />
			<div class="search-area col-lg-4">
				<form id="frmMain" name="frmMain" method="post" onsubmit="return false" class="form-material form-inline">
					<form:input id="hMemberId2" type="hidden" value="" />
					<form:input id="kCarNumber2" caption="차량번호" addAttr="maxlength='20'" size="6"/>
					<form:select id="kParkingGovCode2" caption="관리기관" all="true" allLabel="전체" queryId="select.select_parkingGovInfo" size="6"/>
				</form>
			</div>
			<div class="form-group col-xl-2 col-lg-2 col-md-2 col-sm-2 no-margin no-padding ">
                <label class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right">이름</label>
                <div class="col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached">
                    <div class="input-group">
                        <span class="input-group-addon"><i class="fas fa-eye" data-icon="fas fa-pencil-alt"></i></span>
                        <input name="kMemberName" id="kMemberName" class="form-control" type="text" value="" readonly="readonly">
                    </div>
                </div>
            </div>
            <div class="form-group col-xl-2 col-lg-2 col-md-2 col-sm-2 no-margin no-padding ">
                <label class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right">연락처</label>
                <div class="col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached">
                    <div class="input-group">
                        <span class="input-group-addon"><i class="fas fa-eye" data-icon="fas fa-pencil-alt"></i></span>
                        <input name="kMemberPhone" id="kMemberPhone" class="form-control" type="text" value="" readonly="readonly">
                    </div>
                </div>
            </div>
			<card:close />
		</div>
		
        <div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12" style="padding: 0;">
			<div class="col-3">
				<card:open title="입출차 내역" />
	            <card:button>
	            </card:button>
	            <card:content />
	            <form:grid id="myGrid"/>
	            <card:close />
			</div>
			<div class="col-6">
     			<card:open title="결제 내역" />
                <card:button>
                </card:button>
                <card:content />
     			<form:grid id="myGrid3"/>
     			<card:close />
            </div>
			<div class="col-3">
				<card:open title="미납 내역" />
	            <card:button>
	            </card:button>
	            <card:content />
	            <form:grid id="myGrid4"/>
	            <card:close />
			</div>
        </div>
        <div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12" style="padding: 0;">
			<div class="col-3">
				<card:open title="감면 정보" />
	            <card:button>
	            </card:button>
	            <card:content />
	            <form:grid id="myGrid2"/>
	            <card:close />
			</div>
			<div class="col-9">
     			<card:open title="결제취소/재결제 신청내역" />
                <card:button>
                </card:button>
                <card:content />
     			<form:grid id="myGrid5"/>
     			<card:close />
            </div>
        </div>
	</div>
</div> --%>


<%@ include file="../../core/include/footerPopup.jsp" %>
