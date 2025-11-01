<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="form" uri="http://ad.its.yeongju.kr/jsp/jstl/form" %>
<%@ taglib prefix="card" uri="http://ad.its.yeongju.kr/jsp/jstl/card" %>
<%@ taglib prefix="func" uri="http://ad.its.yeongju.kr/jsp/jstl/func" %>
<%@ taglib prefix="label" uri="http://ad.its.yeongju.kr/jsp/jstl/label" %>

<%@ include file="../../core/include/head.jsp"%>
<%@ include file="../../core/include/headerPopup.jsp" %>

<script type="text/javascript">
	function loadTableData() {
	    var frm = $("#frmMain");
	    frm.addParam("func", "IQ");
	    frm.addParam("smsCode", $("#hSmsCode").val());
	    frm.addParam("query_id", "sys.smsManagePopup.select_smsDetail");
	    frm.addParam("dataType", "json");
	    frm.request();
	}

	function handleIQ(data, textStatus, jqXHR) {
	    if(data.length > 0){
	    	$("#msgTypeName").val(data[0].msgTypeName);
	    	$("#regDt").val(data[0].regDt);
	    	$("#sendResultName").val(data[0].sendResultName);
	    	$("#recvName").val(data[0].recvName);
	    	$("#recvPhone").val(data[0].recvPhone);
	    	$("#sendPhone").val(data[0].sendPhone);
	    	$("#msgTypeName").val(data[0].msgTypeName);
	    	$("#msgContents").val(data[0].msgContents);
	    	
	    	$('#recvPhone').blur();
	        $('#recvPhone').attr("readonly", "true");
	        $('#sendPhone').blur();
	        $('#sendPhone').attr("readonly", "true");
	        
	        $("#msgContents").attr("readonly", true);
			$("#msgContents").siblings("span").children("i").removeClass();
			$("#msgContents").siblings("span").children("i").addClass("fas fa-eye");
			$("#msgContents").siblings("span").children("i").data("icon", "fas fa-eye");
			$("#msgContents").css("background-color", "#EEEEEE");
	    }
	}
	
	$(function() {
	    // 닫기
	    $("#btnClose").on("click", function(){
            self.close();
	    });
		
	    loadTableData();
	    
	    $("#recvPhone").inputMasking("phone");
	    $("#sendPhone").inputMasking("phone");
	});
</script>
<div class="page-body" style="font-size: 0.9em;">
	<div class="row">
		<div class="col-12" id="search_all_wrapper">
			<card:open title="알림톡/SMS 전송내역" />
			<card:button>
			</card:button>
			<card:content />
			<form id="frmMain" name="frmMain" method="post" onsubmit="return false" class="form-horizontal">
				<form:input id="hSmsCode" type="hidden" value="${param.smsCode}"/>
				<label:input id="regDt" caption="전송일시" size="6" state="readonly"/>
				<label:input id="sendResultName" caption="전송결과" size="6" state="readonly"/>
				<label:input id="recvName" caption="수신자" size="6" state="readonly"/>
				<label:input id="recvPhone" caption="수신번호" size="6"/>
				<label:input id="sendPhone" caption="발신번호" size="6"/>
                <label:input id="msgTypeName" caption="전송구분" size="6" state="readonly"/>
				<label:textarea id="msgContents" caption="메시지" size="12" rows="10" state="readonly"/>
			</form>
			<card:close />
		</div>
	</div>
	<div class="row padding-left-5 padding-right-5">
		<div class="bottom-btn-area">
			<div class="col-xl-6 col-lg-6 col-md-6 col-sm-12 col-12">
			</div>
			<div class="col-xl-6 col-lg-6 col-md-6 col-sm-12 col-12 text-right">
				<form:button type="Close" id="btnClose" />
			</div>
			<label:clear />
		</div>
	</div>
</div>


<%@ include file="../../core/include/footer.jsp"%>
