<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="form" uri="http://ad.its.yeongju.kr/jsp/jstl/form"%>
<%@ taglib prefix="card" uri="http://ad.its.yeongju.kr/jsp/jstl/card"%>
<%@ taglib prefix="func" uri="http://ad.its.yeongju.kr/jsp/jstl/func"%>
<%@ taglib prefix="label" uri="http://ad.its.yeongju.kr/jsp/jstl/label" %>

<%@ include file="../../core/include/head.jsp"%>
<%@ include file="../../core/include/headerPopup.jsp" %>

<script type="text/javascript">
	var dong = "";
	var govCode = "";
	function loadTableData() {
	    var frm = $("#frmMain");
	    frm.addParam("func", "IQ");
	    frm.addParam("query_id", "park.parkingSpotPopup.select_park");
	    frm.addParam("dataType", "json");           // 그리드 불러오는 타입 (기본 json)
	    frm.request();
	}

	function handleIQ(data, textStatus, jqXHR) {
	    if(data.length > 0){
        	$("#parkingSpot").val(data[0].parkingSpot);
	        $("#parkingSpotNow").val(data[0].parkingSpotNow);
        	
	        $("#parkingSpot").focus();
	        $("#parkingSpotNow").focus();
	        $('#parkingSpotNow').blur();
        	
        	$("#parkingSpot").prev().children().removeClass("fas fa-pencil-alt");
        	$("#parkingSpot").prev().children().addClass("fas fa-eye");
        	$("#parkingSpot").prop("readonly",true);
	    }
	}

	function saveData() {
	    var frm = $("#frmMain");
	    frm.serializeArrayCustom();
	    frm.addParam("func", "IS");
	    frm.addParam("dataType", "json");
	    frm.addParam("enc_col", "userId");
	    frm.setAction("<c:url value='/park/parkSpotInsert.do' />");
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

	// 저장 제약조건
	function validation(){

	    if($("#parkingSpotNow").val() == ""){
	    	alert("현재 주차면수를 입력해 주세요.");
	        $("#parkingSpotNow").focus();
	        return;
	    }

	    if(confirm("주차장 정보를 저장하시겠습니까?")){
	    	saveData();
	    }
	}

	$(function() {
	    // 등록
	    $("#btnSave").on("click", function(){
	        validation();
	    });

	    // 닫기
	    $("#btnClose").on("click", function(){
			self.close();
	    });

	    $("#parkingSpot").inputMasking("number");
	    $("#parkingSpotNow").inputMasking("number");
	    
		loadTableData();

	});
</script>
<div class="page-body" style="font-size: 0.9em;">
	<div class="row">
		<div class="col-12" id="search_all_wrapper">
			<div class="col-12">
				<card:open title="주차장 정보" />
				<card:button>
				</card:button>
				<card:content />
				<form id="frmMain" name="frmMain" method="post" onsubmit="return false" class="form-horizontal">
					<form:input id="hParkingNo" type="hidden" value="${param.parkingNo}"/>
					<label:input id="parkingSpot" caption="주차면수" size="6" className="danger" addAttr="style='text-align:right;' maxlength='11'"/>
					<label:input id="parkingSpotNow" caption="현재 주차면수" size="6" className="danger" addAttr="style='text-align:right;' maxlength='11'"/>
				</form>
				<card:close />
			</div>
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
