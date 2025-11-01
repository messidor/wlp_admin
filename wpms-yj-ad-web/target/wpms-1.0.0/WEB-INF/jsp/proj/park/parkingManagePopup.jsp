<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="form" uri="http://ad.its.yeongju.kr/jsp/jstl/form"%>
<%@ taglib prefix="card" uri="http://ad.its.yeongju.kr/jsp/jstl/card"%>
<%@ taglib prefix="func" uri="http://ad.its.yeongju.kr/jsp/jstl/func"%>
<%@ taglib prefix="label" uri="http://ad.its.yeongju.kr/jsp/jstl/label" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%@ include file="../../core/include/head.jsp"%>
<%@ include file="../../core/include/headerPopup.jsp" %>

<link rel="stylesheet" href="<c:url value='/common/css/sumoselect/sumoselect-custom.css'/>" />
<script type="text/javascript" src="<c:url value='/common/js/sumoselect/jquery.sumoselect.js'/>"></script>
<style>
.card .card-block {
	padding-bottom: 0px;
}
.popup-content {
    padding: 10px 0px;
}
.bottom-btn-area {
    margin-bottom: 0px;
}
</style>

<script type="text/javascript">
	var dong = "";
	var govCode = "";
	function loadTableData() {
	    var frm = $("#frmMain");
	    frm.addParam("func", "IQ");
	    frm.addParam("query_id", "park.parkingManagePopup.select_park");
	    frm.addParam("dataType", "json");           // 그리드 불러오는 타입 (기본 json)
	    frm.request();
	}

	function handleIQ(data, textStatus, jqXHR) {
	    if(data.length > 0){

	        $("#parkingName").val(data[0].parkingName);
	        $("#parkingPost").val(data[0].parkingPost);
	        $("#parkingAddr").val(data[0].parkingAddr);
	        $("#parkingAddr2").val(data[0].parkingAddr2);
	        $("#gugun").val(data[0].gugun);
	        dong = data[0].dong;
	        govCode = data[0].pGovAccountCode;
	        if(data[0].parkingTel === undefined || data[0].parkingTel == ""){
	        	$("#parkingTel").val(data[0].pGovTel);
	        }else{
	        	$("#parkingTel").val(data[0].parkingTel);
	        }
	        $("#minuteStd").val(data[0].minuteStd.toString());
	        $("#minutePrice").val(data[0].minutePrice.toString());
	        $("#dayPrice").val(data[0].dayPrice.toString());
	        $("#parkingSpot").val(data[0].parkingSpot.toString());
	        $("#detailInfo").val(data[0].detailInfo);
	        $("#parkingSpotNow").val(data[0].parkingSpotNow.toString());
	        $("#useYn").val(data[0].useYn);
	        $("#hUseGubn").val(data[0].hUseGubn);
	        $("#priceChgGubn").val(data[0].priceChgGubn);
	        $("#pCompCode").val(data[0].pCompCode);
	        $("#pGovCode").val(data[0].pGovCode);
	        $("#apiVerGubn").val(data[0].apiVerGubn);
	        $("#color").val(data[0].color);
	        $("#fontColor").val(data[0].fontColor);
	        $("#regId").val(data[0].regId);
	        $("#regDt").val(data[0].regDt);
	        $("#modId").val(data[0].modId);
	        $("#modDt").val(data[0].modDt);
	        $("#detailPrice").val(data[0].parkingPriceDetail);
	        
	        $("#freeMin").val(data[0].freeMin);
	        $("#turningMin").val(data[0].turningMin);
	        $("#nStdPrice").val(data[0].nStdPrice);
	        $("#hStdPrice").val(data[0].hStdPrice);
	        $("#n10mPrice").val(data[0].n10mPrice);
	        $("#h10mPrice").val(data[0].h10mPrice);
	        $("#n20mPrice").val(data[0].n20mPrice);
	        $("#h20mPrice").val(data[0].h20mPrice);
	        $("#nDayPrice").val(data[0].nDayPrice);
	        $("#hDayPrice").val(data[0].hDayPrice);
	        $("#nStTimeH").val(data[0].nStTimeH);
	        $("#nStTimeM").val(data[0].nStTimeM);
	        $("#nFnTimeH").val(data[0].nFnTimeH);
	        $("#nFnTimeM").val(data[0].nFnTimeM);
	        $("#hStTimeH").val(data[0].hStTimeH);
	        $("#hStTimeM").val(data[0].hStTimeM);
	        $("#hFnTimeH").val(data[0].hFnTimeH);
	        $("#hFnTimeM").val(data[0].hFnTimeM);
	        
	        $("#spPeriodYn").val(data[0].spPeriodYn);
	        spDisable();
	        
	        $("#spStDate").val(data[0].spStDate);
	        $("#spFnDate").val(data[0].spFnDate);
	        $("#spNStTimeH").val(data[0].spNStTimeH);
	        $("#spNStTimeM").val(data[0].spNStTimeM);
	        $("#spNFnTimeH").val(data[0].spNFnTimeH);
	        $("#spNFnTimeM").val(data[0].spNFnTimeM);
	        $("#spHStTimeH").val(data[0].spHStTimeH);
	        $("#spHStTimeM").val(data[0].spHStTimeM);
	        $("#spHFnTimeH").val(data[0].spHFnTimeH);
	        $("#spHFnTimeM").val(data[0].spHFnTimeM);
	        $("#apiUrl").val(data[0].apiUrl);
	        $("#mapMarkGubn").val(data[0].mapMarkGubn);
	        $("#parkingLatitude").val(data[0].parkingLatitude);
	        $("#parkingLongitude").val(data[0].parkingLongitude);
	        
	        if(data[0].apiVerGubn == "1"){
	        	$("#apiUrl").parent("div").parent("div").parent("div").removeClass("has-danger")	
	        }else{
	        	$("#apiUrl").parent("div").parent("div").parent("div").addClass("has-danger")
	        }
	        
	        $("#freeMin, #turningMin, #nStdPrice, #hStdPrice, #n10mPrice, #h10mPrice, #n20mPrice, #h20mPrice, #nDayPrice, #hDayPrice").focus();
	        
	        
	        if(data[0].parkingAreaCode !== undefined){
	        	$("#parkingAreaCode").prev().children().removeClass("fas fa-pencil-alt");
	        	$("#parkingAreaCode").prev().children().addClass("fas fa-eye");
	        	$("#parkingAreaCode").prop("readonly",true);
	        	$("#parkingAreaCode").val(data[0].parkingAreaCode);
	        }else{
	        	$("#parkingAreaCode").prev().children().removeClass("fas fa-eye");
	        	$("#parkingAreaCode").prev().children().addClass("fas fa-pencil-alt");
	        	$("#parkingAreaCode").prop("readonly",false);
	        }
	        $("#parkingSpotNow").prev().children().removeClass("fas fa-pencil-alt");
        	$("#parkingSpotNow").prev().children().addClass("fas fa-eye");
        	$("#parkingSpotNow").prop("readonly",true);
        	
	        $("#minutePrice").focus();
	        $("#dayPrice").focus();
	        $("#parkingSpot").focus();
	        $("#parkingSpotNow").focus();
	        $("#parkingTel").focus();
	        $('#parkingTel').blur();
	        
	       
        	
	     	// 발급하였으면 발급 버튼 사라지도록 처리
	        if(data[0].parkingAreaCodeYn == "Y"){
	        	$("#issuanceSpan").css("display", "none");
	        }

	        loadComboData();
	        govBankData(); 
	        
	        // 저장된 휴무일 선택되어있도록 처리
	        let weekDays = [];
	        for(let i = 0; i < data.length; i++){
	        	weekDays.push(data[i].weekDay);
	        }
	        $("#weekday").setMultiSelect(weekDays, {}, {});
	        
	    }
	}

	function saveData() {
	    // 시간이 24인 경우 분단위는 0으로 강제 변경하여 저장 처리
	    if($("#nStTimeH").val() == "24") { $("#nStTimeM").val("00"); }
		if($("#nFnTimeH").val() == "24") { $("#nFnTimeM").val("00"); }
		if($("#hStTimeH").val() == "24") { $("#hStTimeM").val("00"); }
		if($("#hFnTimeH").val() == "24") { $("#hFnTimeM").val("00"); }
		if($("#spNStTimeH").val() == "24") { $("#spNStTimeM").val("00"); }
		if($("#spNFnTimeH").val() == "24") { $("#spNFnTimeM").val("00"); }
		if($("#spHStTimeH").val() == "24") { $("#spHStTimeM").val("00"); }
		if($("#spHFnTimeH").val() == "24") { $("#spHFnTimeM").val("00"); }
	    
	    var frm = $("#frmMain");
	    frm.serializeArrayCustom();
	    frm.addParam("func", "IS");
	    frm.addParam("dataType", "json");
	    frm.addParam("enc_col", "userId");
	    
	    // param으로 안넘어가는 값 넣어줌
	    frm.addParam("minuteStd", $("#minuteStd").val());
	    frm.addParam("minutePrice", $("#minutePrice").val());
	    frm.addParam("dayPrice", $("#dayPrice").val());
	    frm.addParam("freeMin", $("#freeMin").val());
	    frm.addParam("turningMin", $("#turningMin").val());
	    
	    frm.addParam("nStdPrice", $("#nStdPrice").val());
	    frm.addParam("n10mPrice", $("#n10mPrice").val());
	    frm.addParam("n20mPrice", $("#n20mPrice").val());
	    frm.addParam("nDayPrice", $("#nDayPrice").val());
	    
	    frm.addParam("hStdPrice", $("#hStdPrice").val());
	    frm.addParam("h10mPrice", $("#h10mPrice").val());
	    frm.addParam("h20mPrice", $("#h20mPrice").val());
	    frm.addParam("hDayPrice", $("#hDayPrice").val());
	    
	    frm.addParam("nStTimeH", $("#nStTimeH").val());
	    frm.addParam("nStTimeM", $("#nStTimeM").val());
	    frm.addParam("nFnTimeH", $("#nFnTimeH").val());
	    frm.addParam("nFnTimeM", $("#nFnTimeM").val());
	    frm.addParam("hStTimeH", $("#hStTimeH").val());
	    frm.addParam("hStTimeM", $("#hStTimeM").val());
	    frm.addParam("hFnTimeH", $("#hFnTimeH").val());
	    frm.addParam("hFnTimeM", $("#hFnTimeM").val());
	    
	    frm.addParam("spPeriodYn", $("#spPeriodYn").val());
	    frm.addParam("spStDate", $("#spStDate").val());
	    frm.addParam("spFnDate", $("#spFnDate").val());
	    frm.addParam("spNStTimeH", $("#spNStTimeH").val());
	    frm.addParam("spNStTimeM", $("#spNStTimeM").val());
	    frm.addParam("spNFnTimeH", $("#spNFnTimeH").val());
	    frm.addParam("spNFnTimeM", $("#spNFnTimeM").val());
	    frm.addParam("spHStTimeH", $("#spHStTimeH").val());
	    frm.addParam("spHStTimeM", $("#spHStTimeM").val());
	    frm.addParam("spHFnTimeH", $("#spHFnTimeH").val());
	    frm.addParam("spHFnTimeM", $("#spHFnTimeM").val());


	    frm.setAction("<c:url value='/park/parkInsert.do' />");
	 	// 멀티 셀렉트 값을 리스트로 전송
		frm.addParam("weekday", $("#weekday").val());
	    frm.request();
	}

	function handleIS(data, textStatus, jqXHR){
		if(data.count> 0) {
			if (opener && typeof opener.loadTableData === "function") {
				opener.loadTableData();
			}
		 	window.close();
		}
	}

	function deleteData() {
	    var frm = $("#frmMain");
	    frm.serializeArrayCustom();
	    frm.addParam("func", "IS2");
	    frm.addParam("dataType", "json");
	    frm.addParam("enc_col", "userId");
	    frm.setAction("<c:url value='/park/parkDelete.do' />");
	    frm.request();
	}

	function handleIS2(data, textStatus, jqXHR){
		if(data.count> 0) {
			if (opener && typeof opener.loadTableData === "function") {
				opener.loadTableData();
			}
		 	window.close();
		}
	}
	
	// 일자, 시간 비교 함수
	function dateTimeComparison(start, end){
		let x = parseInt(start, 10);
		let y = parseInt(end, 10);
		
		if(x==0 && y==0){
			return true;
		} else if(x>=y){
			return false;
		} else {
			return true;
		}
	}

	// 저장 제약조건
	function validation(){

		var postRule = /^(\d{3}-?\d{3}|\d{3}-?\d{2})$/u;
		///(\d{3}-\d{3}|\d{5})/;

		// 주차장 정보
	    if($("#parkingName").val() == ""){
	        alert("주차장명을 입력해 주세요.");
	        $("#parkingName").focus();
	        return;
	    }
	    
	    if($("#parkingAreaCode").val() == ""){
	    	alert("areaCode을 입력해 주세요.");
	        $("#parkingAreaCode").focus();
	        return;
	    }

	    if($("#parkingPost").val() != "" && !postRule.test($("#parkingPost").val())){
	    	alert("우편번호가 올바르지 않습니다.");
	        $("#parkingPost").focus();
	        return;
		}

	    if($("#parkingAddr").val() == ""){
	    	alert("주소를 입력해 주세요.");
	        $("#parkingAddr").focus();
	        return;
	    }


	    if($("#gugun").val() == ""){
	    	alert("구역(시/군/구)를 입력해 주세요.");
	        $("#gugun").focus();
	        return;
	    }

	    if($("#dong").val() == ""){
	    	alert("구역(읍/면/동)을 입력해 주세요.");
	        $("#dong").focus();
	        return;
	    }
	    
	    if($("#apiVerGubn").val() == ""){
	    	alert("API버전을 입력해 주세요.");
	        $("#apiVerGubn").focus();
	        return;
	    }
		
	    if($("#pCompCode").val() == ""){
	    	alert("관리회사를 입력해 주세요.");
	        $("#pCompCode").focus();
	        return;
	    }
	    
	    if($("#pGovCode").val() == ""){
	    	alert("관리기관을 입력해 주세요.");
	        $("#pGovCode").focus();
	        return;
	    }
	    
	    var regType1 = /^[A-Za-z0-9]*$/;
	    var str1 = $("#color").val().substring(0, 1);
	    var str2 = $("#color").val().substring(1, 6);
	    
	    if($("#color").val().length != 7){
	    	alert("색상이 올바르게 입력되지 않았습니다.");
	        $("#color").focus();
	        return;
	    }

	    if(str1 != "#"){
	    	alert("색상이 올바르게 입력되지 않았습니다.");
	        $("#color").focus();
	        return;
	    }

	    if (!regType1.test(str2)){
	    	alert("색상이 올바르게 입력되지 않았습니다.");
	        $("#color").focus();
	        return;
	    }
	    
	    if($("#pGovAccountCode").val() == ""){
	    	alert("통장을 입력해 주세요.");
	        $("#pGovAccountCode").focus();
	        return;
	    }
	    
	    if($("#parkingSpotNow").val() == ""){
	    	alert("현재 주차면수를 입력해 주세요.");
	        $("#parkingSpotNow").focus();
	        return;
	    }
	    
	    if($("#parkingSpot").val() == ""){
	    	alert("주차면수를 입력해 주세요.");
	        $("#parkingSpot").focus();
	        return;
	    }
	    
	    if($("#hUseGubn").val() == ""){
	    	alert("주말운영구분을 입력해 주세요.");
	        $("#hUseGubn").focus();
	        return;
	    }
	    
	    if($("#apiVerGubn").val() == "2" || $("#apiVerGubn").val() == "3"){
	    	if($("#apiUrl").val() == ""){
	    		alert("주차장 API URL을 입력해 주세요.");
		        $("#apiUrl").focus();
		        return;
	    	}
	    }
	    
	    if($("#mapMarkGubn").val() == ""){
	    	alert("지도표시구분을 입력해 주세요.");
	        $("#mapMarkGubn").focus();
	        return;
	    }
	    
// 	    var fontstr1 = $("#fontColor").val().substring(0, 1);
// 	    var fontstr2 = $("#fontColor").val().substring(1, 6);
	    
// 	    if($("#fontColor").val().length != 7){
// 	    	alert("폰트색상이 올바르게 입력되지 않았습니다.");
// 	        $("#fontColor").focus();
// 	        return;
// 	    }

// 	    if(fontstr1 != "#"){
// 	    	alert("폰트색상이 올바르게 입력되지 않았습니다.");
// 	        $("#fontColor").focus();
// 	        return;
// 	    }

// 	    if (!regType1.test(fontstr2)){
// 	    	alert("폰트색상이 올바르게 입력되지 않았습니다.");
// 	        $("#fontColor").focus();
// 	        return;
// 	    }
	    
	    // 운영 시간
	    if($("#nStTimeH").val() == ""){
	    	alert("운영시작시간(평일)을 입력해 주세요.");
	        $("#nStTimeH").focus();
	        return;
	    }
	    
	    if($("#nStTimeM").val() == ""){
	    	alert("운영시작시간(평일)을 입력해 주세요.");
	        $("#nStTimeM").focus();
	        return;
	    }
	    
	    if($("#nFnTimeH").val() == ""){
	    	alert("운영종료시간(평일)을 입력해 주세요.");
	        $("#nFnTimeH").focus();
	        return;
	    }
	    
	    if($("#nFnTimeM").val() == ""){
	    	alert("운영종료시간(평일)을 입력해 주세요.");
	        $("#nFnTimeM").focus();
	        return;
	    }
	    
	    if(!dateTimeComparison($("#nStTimeH").val()+$("#nStTimeM").val(), $("#nFnTimeH").val()+$("#nFnTimeM").val())){
	    	alert("운영시작시간(평일)이 운영종료시간(평일)보다 크거나 같을 수 없습니다.");
	    	return;
	    }
	    // 특정기간 운영 시간
	    if($("#spPeriodYn").val() == "Y"){
	    	
	    	if($("#spStDate").val() == ""){
		    	alert("시작 일자를 입력해 주세요.");
		        $("#spStDate").focus();
		        return;
		    }
	    	
	    	if($("#spFnDate").val() == ""){
		    	alert("종료 일자를 입력해 주세요.");
		        $("#spFnDate").focus();
		        return;
		    }
	    	
	    	if(!dateTimeComparison($("#spStDate").val().replaceAll("-", ""), $("#spFnDate").val().replaceAll("-", ""))){
		    	alert("시작 일자가 종료 일자보다 크거나 같을 수 없습니다.");
		    	return;
		    }
		    
		    if($("#spNStTimeH").val() == ""){
		    	alert("특정기간 운영시작시간(평일)을 입력해 주세요.");
		        $("#spNStTimeH").focus();
		        return;
		    }
		    
		    if($("#spNStTimeM").val() == ""){
		    	alert("특정기간 운영시작시간(평일)을 입력해 주세요.");
		        $("#spNStTimeM").focus();
		        return;
		    }
		    
		    if($("#spNFnTimeH").val() == ""){
		    	alert("특정기간 운영종료시간(평일)을 입력해 주세요.");
		        $("#spNFnTimeH").focus();
		        return;
		    }
		    
		    if($("#spNFnTimeM").val() == ""){
		    	alert("특정기간 운영종료시간(평일)을 입력해 주세요.");
		        $("#spNFnTimeM").focus();
		        return;
		    }
		    
		    if(!dateTimeComparison($("#spNStTimeH").val()+$("#spNStTimeM").val(), $("#spNFnTimeH").val()+$("#spNFnTimeM").val())){
		    	alert("특정기간 운영시작시간(평일)이 특정기간 운영종료시간(평일)보다 크거나 같을 수 없습니다.");
		    	return;
		    }
		    
		}
	    
	    // 요금 정보(기본)
	    if($("#minuteStd").val() == ""){
	    	alert("요금 기준(분)을 입력해 주세요.");
	        $("#minuteStd").focus();
	        return;
	    }
	    
	    if($("#minutePrice").val() == ""){
	    	alert("기준 요금을 입력해 주세요.");
	        $("#minutePrice").focus();
	        return;
	    }

	    if($("#dayPrice").val() == ""){
	    	alert("1일요금을 입력해 주세요.");
	        $("#dayPrice").focus();
	        return;
	    }
	    
	    if($("#turningMin").val() == ""){
	    	alert("회차시간(분)을 입력해 주세요.");
	        $("#turningMin").focus();
	        return;
	    }

		if($("#freeMin").val() == ""){
	    	alert("무료시간(분)을 입력해 주세요.");
	        $("#freeMin").focus();
	        return;
	    }

		// 요금 정보(평일)
		if($("#nStdPrice").val() == ""){
	    	alert("기본요금(평일)을 입력해 주세요.");
	        $("#nStdPrice").focus();
	        return;
	    }

		if($("#n10mPrice").val() == ""){
	    	alert("10분당요금(평일)을 입력해 주세요.");
	        $("#n10mPrice").focus();
	        return;
	    }

		if($("#n20mPrice").val() == ""){
	    	alert("20분당요금(평일)을 입력해 주세요.");
	        $("#n20mPrice").focus();
	        return;
	    }
		if($("#nDayPrice").val() == ""){
	    	alert("1일요금(평일)을 입력해 주세요.");
	        $("#nDayPrice").focus();
	        return;
	    }
		
		// 주말운영구분 = 사용
		if($("#hUseGubn").val() == "Y"){
			if($("#hStTimeH").val() == ""){
				alert("운영시작시간(주말)을 입력해 주세요.");
				$("#hStTimeH").focus();
				return;
			}
			
			if($("#hStTimeM").val() == ""){
				alert("운영시작시간(주말)을 입력해 주세요.");
				$("#hStTimeM").focus();
				return;
			}
			
			if($("#hFnTimeH").val() == ""){
				alert("운영종료시간(주말)을 입력해 주세요.");
				$("#hFnTimeH").focus();
				return;
			}
			
			if($("#hFnTimeM").val() == ""){
				alert("운영종료시간(주말)을 입력해 주세요.");
				$("#hFnTimeM").focus();
				return;
			}
			
			if(!dateTimeComparison($("#hStTimeH").val()+$("#hStTimeM").val(), $("#hFnTimeH").val()+$("#hFnTimeM").val())){
				alert("운영시작시간(주말)이 운영종료시간(주말)보다 크거나 같을 수 없습니다.");
				return;
			}

			if($("#spPeriodYn").val() == "Y") {
			    if($("#spHStTimeH").val() == ""){
			    	alert("특정기간 운영시작시간(주말)을 입력해 주세요.");
			        $("#spHStTimeH").focus();
			        return;
			    }
			    
			    if($("#spHStTimeM").val() == ""){
			    	alert("특정기간 운영시작시간(주말)을 입력해 주세요.");
			        $("#spHStTimeM").focus();
			        return;
			    }
			    
			    if($("#spHFnTimeH").val() == ""){
			    	alert("특정기간 운영종료시간(주말)을 입력해 주세요.");
			        $("#spHFnTimeH").focus();
			        return;
			    }
			    
			    if($("#spHFnTimeM").val() == ""){
			    	alert("특정기간 운영종료시간(주말)을 입력해 주세요.");
			        $("#spHFnTimeM").focus();
			        return;
			    }
			    
			    if(!dateTimeComparison($("#spHStTimeH").val()+$("#spHStTimeM").val(), $("#spHFnTimeH").val()+$("#spHFnTimeM").val())){
			    	alert("특정기간 운영시작시간(주말)이 특정기간 운영종료시간(주말)보다 크거나 같을 수 없습니다.");
			    	return;
			    }
			}
		    
			if($("#hStdPrice").val() == ""){
		    	alert("기본요금(주말)을 입력해 주세요.");
		        $("#hStdPrice").focus();
		        return;
		    }
			if($("#h10mPrice").val() == ""){
		    	alert("10분당요금(주말)을 입력해 주세요.");
		        $("#h10mPrice").focus();
		        return;
		    }
			if($("#h20mPrice").val() == ""){
		    	alert("20분당요금(주말)을 입력해 주세요.");
		        $("#h20mPrice").focus();
		        return;
		    }
			if($("#hDayPrice").val() == ""){
		    	alert("1일요금(주말)을 입력해 주세요.");
		        $("#hDayPrice").focus();
		        return;
		    }

	    }
	    
	    if(confirm("주차장 정보를 저장하시겠습니까?")){
	    	saveData();
	    }
	}

	function loadComboData() {
		var frm = $("#frmMain");
		frm.addParam("func", "IQCombo");
		frm.addParam("gugun", $("#gugun").val());
		frm.addParam("queryId", "park.parkingManagePopup.select_dongList");
		frm.addParam("afterAction", false);
		frm.request();
	}

	function handleIQCombo(data, textStatus, jqXHR) {
		$("#dong option[value!='']").remove();
		
		$.each(data, function(k, v) {
			$("#dong").append("<option value='" + v.value + "'>" + v.text + "</option>");
		});

		if(dong != ""){
			$("#dong").val(dong);
			dong = "";
		}
	}
	
	function govBankData() {
		var frm = $("#frmMain");
		frm.addParam("func", "IQBank");
		frm.addParam("pGovCode", $("#pGovCode").val());
		frm.addParam("queryId", "park.parkingManagePopup.select_bankList");
		frm.addParam("afterAction", false);
		frm.request();
	}

	function handleIQBank(data, textStatus, jqXHR) {
		$("#pGovAccountCode option[value!='']").remove();

		$.each(data, function(k, v) {
			var pGovAccountName = v.pGovAccountName === undefined ? "" : '[' + v.pGovAccountName + '] ';
			var pGovAccountNumber = v.pGovAccountNumber === undefined ? "" : v.pGovAccountNumber;
			var pGovBankName = v.pGovBankName === undefined ? "" : ' (' + v.pGovBankName + ')';
			
			$("#pGovAccountCode").append("<option value='" + v.value + "'>" + pGovAccountName + pGovAccountNumber + pGovBankName + "</option>");
		});

		if(govCode != ""){
			$("#pGovAccountCode").val(govCode);
			govCode = "";
		}
	}

	// 영어 숫자 포맷
	function IsAlphaNumeric(ee) {
	   var inputChar = String.fromCharCode(event.keyCode);
	   var ret = "";
	   if (inputChar == "" && inputChar == null) {
	      ret = ee;
	   } else {
	      if (inputChar.search(/[a-z0-9]+$/gi) >= 0) { ret = ee; } else { ret = ee.replace(/[^a-z0-9]+$/gi,''); }
	   }
	   return ret;
	}
	
	
	// 특정기간 요소 처리
	function spDisable() {
		var id = "#spStDate, #spFnDate, #spNStTimeH, #spNFnTimeH, #spHStTimeH, #spHFnTimeH, #spNStTimeM, #spNFnTimeM, #spHStTimeM, #spHFnTimeM";
		var dangerId = "#spStDate, #spFnDate, #spNStTimeH, #spNFnTimeH, #spNStTimeM, #spNFnTimeM";
		var noDangerId = "#spHStTimeH, #spHStTimeM, #spHFnTimeH, #spHFnTimeM";
		var inputID = "#spStDate, #spFnDate";
		
		if($("#spPeriodYn").val() == "N"){
			// 미사용
        	$(id).attr("disabled", true);
			$(id).siblings("span").children("i").removeClass();
			$(id).siblings("span").children("i").addClass("fas fa-eye");
			$(id).css("background-color", "#EEEEEE");
			$(id).parent().parent().parent().removeClass("has-danger");
			
        } else {
        	// 사용
        	$(id).attr("disabled", false);
        	$(id).siblings("span").children("i").removeClass();
			$(id).siblings("span").children("i").addClass("fas fa-bars");
			$(inputID).siblings("span").children("i").addClass("fas fa-pencil-alt");
			$(id).css("background-color", "#FFFFFF");
			$(dangerId).parent().parent().parent().addClass("has-danger");
        }
	}

	$(function() {
		$("#spStDate").initDateOnly("m", 0);
		$("#spFnDate").initDateOnly("m", 1);
		
        // 시간, 분 select 생성
        var html = "";
        for(var i=0; i<25; i++){
        	if(i<10){
        		html += "<option value='" + "0"+i + "'>" + i + "</option>";
        	} else {
        		html += "<option value='" + i + "'>" + i + "</option>";
        	}
        }
        $("#nStTimeH, #nFnTimeH, #hStTimeH, #hFnTimeH, #spNStTimeH, #spNFnTimeH, #spHStTimeH, #spHFnTimeH").append(html);
        
        html = "";
        for(var i=0; i<12; i++){
        	if(i<2){
        		html += "<option value='" + "0"+i*5 + "'>" + i*5 + "</option>";
        	} else {
        		html += "<option value='" + i*5 + "'>" + i*5 + "</option>";
        	}
        }
        $("#nStTimeM, #nFnTimeM, #hStTimeM, #hFnTimeM, #spNStTimeM, #spNFnTimeM, #spHStTimeM, #spHFnTimeM").append(html);
        
	    // 등록
	    $("#btnSave").on("click", function(){
	        validation();
	    });

	    // 삭제
	    $("#btnDelete").on("click", function(){

	        if(confirm("정말 삭제하시겠습니까?")){
	        	deleteData();
	        }
	    });

	    // 닫기
	    $("#btnClose").on("click", function(){
			self.close();
	    });

	    // areaCode 포맷
	    $(document).on('keydown', '#parkingAreaCode', function() {
	    	 var formatString = IsAlphaNumeric($("#parkingAreaCode").val());

	    	 $("#parkingAreaCode").val(formatString);
	    });
	    $(document).on('keypress', '#parkingAreaCode', function() {
	    	var formatString = IsAlphaNumeric($("#parkingAreaCode").val());

	    	 $("#parkingAreaCode").val(formatString);
	    });
	    $(document).on('keyup', '#parkingAreaCode', function() {
	    	var formatString = IsAlphaNumeric($("#parkingAreaCode").val());

	    	 $("#parkingAreaCode").val(formatString);
	    });

	    // 우편번호 선택
	    $("#btnPostcodeAdd").click(function(){
	        daum.postcode.load(function(){
	            new daum.Postcode({
	                oncomplete: function(data) {
	                    // 팝업에서 검색결과 항목을 클릭했을때 실행할 코드를 작성하는 부분.

	                    // 각 주소의 노출 규칙에 따라 주소를 조합한다.
	                    // 내려오는 변수가 값이 없을땐 공백('')값을 가지므로, 이를 참고하여 분기한다.
	                    var addr = ''; // 주소 변수
	                    //var extraAddr = ''; // 조합형 주소 변수

	                    fullAddr = data.roadAddress == "" ? data.autoRoadAddress : data.roadAddress;

	                    if(data.userSelectedType === 'R') {
	                        //법정동명이 있을 경우 추가한다.
	                        if(data.bname !== '') {
	                            addr += data.bname;
	                        }
	                        // 건물명이 있을 경우 추가한다.
	                        if(data.buildingName !== '') {
	                            addr += (addr !== '' ? ', ' + data.buildingName : data.buildingName);
	                        }
	                        // 조합형주소의 유무에 따라 양쪽에 괄호를 추가하여 최종 주소를 만든다.
	                        fullAddr += (addr !== '' ? ' ('+ addr +')' : '');
	                    }

	                    // 우편번호와 주소 정보를 해당 필드에 넣는다.
	                    document.getElementById("parkingPost").value = data.zonecode;
	                    document.getElementById("parkingAddr").value = fullAddr;

	                    // 커서를 상세주소 필드로 이동한다.
	                    document.getElementById("parkingAddr2").focus();
	                }
	            }).open();
	        });
	    });

	    // 구군 연계콤보
		$("#gugun").on("change", function() {
			if($(this).data("current") && !confirm("구역(시/군/구)가 변경되면 구역(읍/면/동)이 초기화됩니다. 계속 진행하시겠습니까?")) {
				$(this).val($(this).data("current"));
				return false;
			}

			if ($(this).val() ) {
				/* changeLoadingImageStatus(false); */
				loadComboData();
			}

			$(this).data("current", $(this).val());
		});
	    
		// 관리기관-통장번호 연계콤보
		$("#pGovCode,#pCompCode").on("change", function() {
			if ($(this).val() ) {
				govBankData();
			}
		});
		
		$("#spPeriodYn").change(function() {
			spDisable();
			
			if($("#spStDate").val() == ""){
				$("#spStDate").initDateOnly("m", 0);
			}
			if($("#spFnDate").val() == ""){
				$("#spFnDate").initDateOnly("m", 1);
			}
		});

		<c:if test="${not empty param.parkingNo}">
			loadTableData();
		</c:if>
		
		<c:if test="${empty param.parkingNo}">
			$("#parkingSpotNow").prev().children().removeClass("fas fa-pencil-alt");
	    	$("#parkingSpotNow").prev().children().addClass("fas fa-eye");
	    	$("#parkingSpotNow").prop("readonly",true);
	    	$("#parkingSpotNow").val(0);
		</c:if>
		
		$("#detailInfo").height(73);
		$("#parkingPost").inputMasking("zip");
		$("#minutePrice").inputMasking("number");
		$("#dayPrice").inputMasking("number");
		$("#parkingSpot").inputMasking("number");
		$("#parkingSpotNow").inputMasking("number");
		$("#parkingTel").inputMasking("phone");
        $("#freeMin").inputMasking("number");
        $("#turningMin").inputMasking("number");
        $("#nStdPrice").inputMasking("number");
        $("#hStdPrice").inputMasking("number");
        $("#n10mPrice").inputMasking("number");
        $("#h10mPrice").inputMasking("number");
        $("#n20mPrice").inputMasking("number");
        $("#h20mPrice").inputMasking("number");
        $("#nDayPrice").inputMasking("number");
        $("#hDayPrice").inputMasking("number");
        $("#parkingLatitude").inputMasking("number", {decimal: 13});
        $("#parkingLongitude").inputMasking("number", {decimal: 13});

		/* $("#minutePrice").focus();
		$("#minutePrice").blur(); */
		
		// 앞뒤 공백 제거
        $("textarea.form-control").on("blur",function(){
        	$(this).val($.trim($(this).val()));
        })
        
        // common/js/etcs/common.js 파일 참조, Select box를 멀티 체크박스 형태로 변경
		// 첫번째 파라미터 : 실행시 선택되어 있어야 하는 값들을 배열로 처리. 없으면 빈 배열만 넣으면 됨
		// 두번째 파라미터 : sumoselect 플러그인의 옵션. 변경할게 없으면 빈 JSON 배열({}) 만 넣으면 됨
		// 세번째 파라미터 : sumoselect 플러그인에서 제공하는 이벤트. 없으면 빈 JSON 배열만 넣으면 됨
		$("#weekday").setMultiSelect([], {}, {});
		
		// css 맞추기 위해 하드코딩
		$("#weekday").parent().height("33px");
		$("#weekday").height("0px");
		$("#weekday").css("padding", "0");
		$("#weekday").height("0px");
		$(".CaptionCont").height("27px");
		$(".CaptionCont").css("top", "-2px");
		$(".CaptionCont").children("span").css("position", "absolute");
		$(".CaptionCont").children("span").css("top", "0px");
		// 하단 카드 높이 조절
		let cardHeight = $(".col-3").eq(1).children(".card").height();
        $(".col-3").children(".card").height(cardHeight);
        
        $("#apiVerGubn").on("change", function(){
        	if($(this).val() == "1"){
        		$("#apiUrl").parent("div").parent("div").parent("div").removeClass("has-danger")
        	}else{
        		$("#apiUrl").parent("div").parent("div").parent("div").addClass("has-danger")	
        	}
        	
        });
        
        spDisable();
	});
</script>
<div class="page-body" style="font-size: 0.9em;">
	<div class="row">
		<div class="col-12" id="search_all_wrapper">
		<form id="frmMain" name="frmMain" method="post" onsubmit="return false" class="form-horizontal">
			<div class="col-12 top_card">
				<card:open title="주차장 정보" />
				<card:button>
				</card:button>
				<card:content />

					<form:input id="hParkingNo" type="hidden" value="${param.parkingNo}"/>


					<div class="col-6" style="max-width: 40%">
						<label:input id="parkingName" caption="주차장명" size="6" className="danger" addAttr="maxlength='25'"/>
						<label:input id="parkingTel" caption="SMS 발송번호" size="6" addAttr="maxlength='11' placeholder='기관정보번호와 동일' "/>

						<div class="form-group col-6 no-margin no-padding">
							<label class="col-4 control-label text-right">우편번호</label>
							<div class="col-8 inputGroupContainer label-attached">
								<div class="input-group">
									<span class="input-group-addon"><i class="fas fa-pencil-alt" data-icon="fas fa-eye"></i></span>
									<input name="parkingPost" id="parkingPost" class="form-control" type="text" value="">
									<span class="input-group-btn">
										<button id="btnPostcodeAdd" type="button" name="btnPostcodeAdd" class="btn btn-sm btn-primary">주소검색</button>
									</span>
								</div>
							</div>
						</div>
						<label:input id="parkingAreaCode" caption="areaCode" size="6" className="danger" addAttr="maxlength='25'"/>
						<label:input id="parkingAddr" caption="주소" size="6" className="danger"/>
						<label:input id="parkingAddr2" caption="상세주소" size="6" addAttr="maxlength='50'"/>
						<label:input id="parkingLatitude" caption="위도" size="6" />
						<label:input id="parkingLongitude" caption="경도" size="6" />
						<label:textarea id="detailInfo" caption="상세정보" size="6" rows="3" addAttr="style='margin-bottom:0px; height: 90px;'"/>
						<label:textarea id="detailPrice" caption="상세금액" size="6" rows="3" addAttr="style='margin-bottom:0px; height: 90px;'"/>
					</div>
					<div class="col-6" style="max-width: 40%">
						<label:select id="gugun" caption="구역(시/군/구)" size="6" className="danger" queryId="#RESION" all="true" allLabel="선택" />
						<label:select id="dong"  caption="구역(읍/면/동)" size="6" className="danger" queryId="" all="true" allLabel="선택" />
						<label:select id="pCompCode" caption="관리회사" size="6" className="danger" queryId="park.parkingManagePopup.select_parkCompList" all="true" allLabel="선택" addAttr="style='height:33px;'"/>
						<c:choose>
							<c:when test="${fn:contains(user_role_id, 'MANAGE') || fn:contains(user_role_id, 'AD')}">
								<label:select id="pGovCode" caption="관리기관" className="danger" size="6" queryId="select.select_parkingGovInfo" all="true" allLabel="선택"/>
							</c:when>
							<c:otherwise>
								<label:select id="pGovCode" caption="관리기관" className="danger" size="6" queryId="select.select_parkingGovInfo" all="false" allLabel="선택"/>
							</c:otherwise>
						</c:choose>
						<label:select id="pGovAccountCode" caption="통장" className="danger" size="12" queryId="select.select_parkingGovInfo" all="false" allLabel="선택"/>
			            <label:input id="parkingSpotNow" caption="현재 주차면수" size="6" className="danger" addAttr="style='text-align:right;' maxlength='11'"/>
			            <label:input id="parkingSpot" caption="주차면수" size="6" className="danger" addAttr="style='text-align:right;' maxlength='11'"/>
						
						<label:select id="priceChgGubn" caption="요금청구구분" size="6" queryId="#PRICE_CHG_GUBN" all="false" allLabel="" />
						
						<label:select id="hUseGubn" caption="주말운영구분" size="6" className="danger" queryId="#use_yn" all="false" value="N"/>
						<label:input id="apiUrl" caption="주차장 API URL" size="6" className="danger"/>
						<label:select id="mapMarkGubn" caption="지도표시구분" size="6" className="danger" queryId="#map_mark_gubn" all="true" allLabel="선택" />
					</div>
					<div class="col-6" style="max-width: 20%">
						<label:select id="apiVerGubn" caption="API버전" size="12" className="danger" queryId="#API_VER_GUBN" all="false" value="2" />
						<label:input id="color" caption="색상(#RGB)" size="12" className="danger" addAttr="placeholder='#6B24EE' maxlength='7'"/>
						<label:input id="fontColor" caption="폰트색상(#RGB)" size="12" addAttr="placeholder='#FFFFFF' maxlength='7'"/>
						<label:select id="useYn" caption="사용여부" size="12" queryId="#use_yn" all="false" allLabel="" />
						<label:input id="modId" caption="수정자" size="12" state="readonly"/>
						<label:input id="modDt" caption="수정일시" size="12" state="readonly"/>
						
					</div>
				<card:close />
			</div>
			<div class="col-12">
                <div class="col-3" style="max-width: 20%">
                    <card:open title="운영 시간" />
                    <card:button>
                    </card:button>
                    <card:content />
                    	<label:select id="weekday" caption="휴무일" all="false" queryId="#WEEKDAY" size="12" className="danger" />
                        <div class="form-group col-xl-12 col-lg-12 col-md-12 col-sm-12 no-margin no-padding has-danger"> 
                            <label class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right">운영시작시간(평일)</label> 
                            <div class="col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached"> 
                                <div class="input-group"> 
                                    <span class="input-group-addon"><i class="fas fa-bars" data-icon="fas fa-bars"></i></span>
                                    <select name="nStTimeH" id="nStTimeH" class="form-control selectpicker col-6"> 
                                        <option value="">선택</option> 
                                    </select>
                                    <select name="nStTimeM" id="nStTimeM" class="form-control selectpicker col-6"> 
                                        <option value="">선택</option> 
                                    </select> 
                                </div> 
                            </div> 
                        </div>
                        <div class="form-group col-xl-12 col-lg-12 col-md-12 col-sm-12 no-margin no-padding has-danger"> 
                            <label class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right">운영종료시간(평일)</label> 
                            <div class="col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached"> 
                                <div class="input-group">
                                    <span class="input-group-addon"><i class="fas fa-bars" data-icon="fas fa-bars"></i></span>
                                    <select name="nFnTimeH" id="nFnTimeH" class="form-control selectpicker col-6"> 
                                        <option value="">선택</option> 
                                    </select>
                                    <select name="nFnTimeM" id="nFnTimeM" class="form-control selectpicker col-6"> 
                                        <option value="">선택</option> 
                                    </select> 
                                </div> 
                            </div> 
                        </div>
                        <div class="form-group col-xl-12 col-lg-12 col-md-12 col-sm-12 no-margin no-padding"> 
                            <label class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right">운영시작시간(주말)</label> 
                            <div class="col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached"> 
                                <div class="input-group">
                                    <span class="input-group-addon"><i class="fas fa-bars" data-icon="fas fa-bars"></i></span>
                                    <select name="hStTimeH" id="hStTimeH" class="form-control selectpicker col-6"> 
                                        <option value="">선택</option> 
                                    </select>
                                    <select name="hStTimeM" id="hStTimeM" class="form-control selectpicker col-6"> 
                                        <option value="">선택</option> 
                                    </select> 
                                </div> 
                            </div> 
                        </div>
                        <div class="form-group col-xl-12 col-lg-12 col-md-12 col-sm-12 no-margin no-padding"> 
                            <label class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right">운영종료시간(주말)</label> 
                            <div class="col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached"> 
                                <div class="input-group"> 
                                    <span class="input-group-addon"><i class="fas fa-bars" data-icon="fas fa-bars"></i></span>
                                    <select name="hFnTimeH" id="hFnTimeH" class="form-control selectpicker col-6"> 
                                        <option value="">선택</option> 
                                    </select>
                                    <select name="hFnTimeM" id="hFnTimeM" class="form-control selectpicker col-6"> 
                                        <option value="">선택</option> 
                                    </select> 
                                </div> 
                            </div> 
                        </div>
                    
                    <card:close/>
                </div>
                
				<div class="col-3" style="max-width: 20%">
                    <card:open title="특정기간 운영 시간" />
                    <card:button>
                    </card:button>
                    <card:content />
                    	<label:select id="spPeriodYn" caption="사용 유무" all="false" queryId="#use_yn" size="12" className="danger" value="N"/>
                    	<label:input id="spStDate" caption="시작 일자" size="12" className="danger"/>
                    	<label:input id="spFnDate" caption="종료 일자" size="12" className="danger"/>
                        <div class="form-group col-xl-12 col-lg-12 col-md-12 col-sm-12 no-margin no-padding has-danger"> 
                            <label class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right">운영시작시간(평일)</label> 
                            <div class="col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached"> 
                                <div class="input-group"> 
                                    <span class="input-group-addon"><i class="fas fa-bars" data-icon="fas fa-bars"></i></span>
                                    <select name="spNStTimeH" id="spNStTimeH" class="form-control selectpicker col-6"> 
                                        <option value="">선택</option> 
                                    </select>
                                    <select name="spNStTimeM" id="spNStTimeM" class="form-control selectpicker col-6"> 
                                        <option value="">선택</option> 
                                    </select> 
                                </div> 
                            </div> 
                        </div>
                        <div class="form-group col-xl-12 col-lg-12 col-md-12 col-sm-12 no-margin no-padding has-danger"> 
                            <label class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right">운영종료시간(평일)</label> 
                            <div class="col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached"> 
                                <div class="input-group">
                                    <span class="input-group-addon"><i class="fas fa-bars" data-icon="fas fa-bars"></i></span>
                                    <select name="spNFnTimeH" id="spNFnTimeH" class="form-control selectpicker col-6"> 
                                        <option value="">선택</option> 
                                    </select>
                                    <select name="spNFnTimeM" id="spNFnTimeM" class="form-control selectpicker col-6"> 
                                        <option value="">선택</option> 
                                    </select> 
                                </div> 
                            </div> 
                        </div>
                        <div class="form-group col-xl-12 col-lg-12 col-md-12 col-sm-12 no-margin no-padding"> 
                            <label class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right">운영시작시간(주말)</label> 
                            <div class="col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached"> 
                                <div class="input-group">
                                    <span class="input-group-addon"><i class="fas fa-bars" data-icon="fas fa-bars"></i></span>
                                    <select name="spHStTimeH" id="spHStTimeH" class="form-control selectpicker col-6"> 
                                        <option value="">선택</option> 
                                    </select>
                                    <select name="spHStTimeM" id="spHStTimeM" class="form-control selectpicker col-6"> 
                                        <option value="">선택</option> 
                                    </select> 
                                </div> 
                            </div> 
                        </div>
                        <div class="form-group col-xl-12 col-lg-12 col-md-12 col-sm-12 no-margin no-padding"> 
                            <label class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right">운영종료시간(주말)</label> 
                            <div class="col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached"> 
                                <div class="input-group"> 
                                    <span class="input-group-addon"><i class="fas fa-bars" data-icon="fas fa-bars"></i></span>
                                    <select name="spHFnTimeH" id="spHFnTimeH" class="form-control selectpicker col-6"> 
                                        <option value="">선택</option> 
                                    </select>
                                    <select name="spHFnTimeM" id="spHFnTimeM" class="form-control selectpicker col-6"> 
                                        <option value="">선택</option> 
                                    </select> 
                                </div> 
                            </div> 
                        </div>
                    
                    <card:close/>
                </div>
				
				<div class="col-3" style="max-width: 20%">
					<card:open title="요금 정보(기본)" />
					<card:button>
					</card:button>
					<card:content />
                        <div class="form-group col-xl-12 col-lg-12 col-md-12 col-sm-12 no-margin no-padding has-danger"> 
                            <label class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right">요금 기준(분)</label> 
                            <div class="col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached"> 
                                <div class="input-group"> 
                                    <span class="input-group-addon"><i class="fas fa-bars" data-icon="fas fa-bars"></i></span>
                                    <select name="minuteStd" id="minuteStd" class="form-control selectpicker col-12"> 
                                        <option value="">선택</option>
                                        <option value="30">30</option>
                                        <option value="60">60</option> 
                                    </select>
                                </div> 
                            </div> 
                        </div>
					<%-- <label:input id="minuteStd" caption="요금 기준(분)" size="12" className="danger" addAttr="style='text-align:right;' maxlength='11'"/> --%>
					<label:input id="minutePrice" caption="기준 요금" size="12" className="danger" addAttr="style='text-align:right;' maxlength='11'"/>
					<label:input id="dayPrice" caption="1일요금" size="12" className="danger" addAttr="style='text-align:right;' maxlength='11'"/>
					<label:input id="turningMin" caption="회차시간(분)" size="12" className="danger" addAttr="style='text-align:right;' maxlength='11'"/>
					<label:input id="freeMin" caption="무료시간(분)" size="12" className="danger" addAttr="style='text-align:right;' maxlength='11'"/>
					<card:close/>
				</div>
				<div class="col-3" style="max-width: 20%">
					<card:open title="요금 정보(평일)" />
					<card:button>
					</card:button>
					<card:content />
					<label:input id="nStdPrice" caption="기본요금(평일)" size="12" className="danger" addAttr="style='text-align:right;' maxlength='11'"/>
					<label:input id="n10mPrice" caption="10분당요금(평일)" size="12" className="danger" addAttr="style='text-align:right;' maxlength='11'"/>
					<label:input id="n20mPrice" caption="20분당요금(평일)" size="12" className="danger" addAttr="style='text-align:right;' maxlength='11'"/>
					<label:input id="nDayPrice" caption="1일요금(평일)" size="12" className="danger" addAttr="style='text-align:right;' maxlength='11'"/>
					<card:close/>
				</div>
				<div class="col-3" style="max-width: 20%">
					<card:open title="요금 정보(주말)" />
					<card:button>
					</card:button>
					<card:content />
					<label:input id="hStdPrice" caption="기본요금(주말)" size="12" addAttr="style='text-align:right;' maxlength='11'"/>
					<label:input id="h10mPrice" caption="10분당요금(주말)" size="12" addAttr="style='text-align:right;' maxlength='11'"/>
					<label:input id="h20mPrice" caption="20분당요금(주말)" size="12" addAttr="style='text-align:right;' maxlength='11'"/>
					<label:input id="hDayPrice" caption="1일요금(주말)" size="12" addAttr="style='text-align:right;' maxlength='11'"/>
					<card:close/>
				</div>
			</div>
			</form>
		</div>
	</div>
	<div class="row padding-left-10 padding-right-10">
		<div class="bottom-btn-area">
			<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12 text-right">
				<form:button type="Save" id="btnSave" />
				<form:button type="Close" id="btnClose" />
			</div>
			<label:clear />
		</div>
	</div>
</div>


<%@ include file="../../core/include/footer.jsp"%>
