<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="form" uri="http://ad.its.yeongju.kr/jsp/jstl/form"%>
<%@ taglib prefix="card" uri="http://ad.its.yeongju.kr/jsp/jstl/card"%>
<%@ taglib prefix="func" uri="http://ad.its.yeongju.kr/jsp/jstl/func"%>
<%@ taglib prefix="label" uri="http://ad.its.yeongju.kr/jsp/jstl/label"%>

<%@ include file="../../core/include/head.jsp"%>
<%@ include file="../../core/include/headerPopup.jsp"%>

<script type="text/javascript">
	var dong = "";
	function loadTableData() {
		var frm = $("#frmMain");
		frm.addParam("func", "IQ");
		frm.addParam("query_id", "park.parkingCompManagePopup.select_comp");
		frm.addParam("dataType", "json"); // 그리드 불러오는 타입 (기본 json)
		frm.request();
	}

	function handleIQ(data, textStatus, jqXHR) {
		if (data.length > 0) {
		}
	}
	
	function createCombo() {
		var frm = $("#frmMain");
		frm.addParam("func", "IQ_CreateCombo");
		frm.addParam("query_id", "sys.faq.select_faq_list");
		frm.addParam("dataType", "json"); // 그리드 불러오는 타입 (기본 json)
		frm.request();
	}

	function handleIQ_CreateCombo(data, textStatus, jqXHR) {
		if (data.length > 0) {
			var comboHtml = "";
			$(opener.opener.document).find("#kFaqCode").children().not(":eq(0)").remove();
			$(opener.document).find("#menuName").children().not(":eq(0)").remove();
			for(var i=0; i<data.length; i++){
				comboHtml += "<option value='" + data[i].value + "'>" + data[i].text + "</option>";
			}
			$(opener.opener.document).find("#kFaqCode").append(comboHtml);
			$(opener.document).find("#menuName").append(comboHtml);
		}
		window.close();
	}
	
	function loadComboData() {
		var frm = $("#frmMain");
		frm.addParam("func", "IQCombo");
		frm.addParam("queryId", "sys.faq.select_faq_list");
		frm.addParam("dataType", "json");
		frm.request();
	}
	
	function handleIQCombo(data, textStatus, jqXHR) {
		$("#menuName option[value!='']").remove();
		$.each(data, function(k, v) {
			$("#menuName").append("<option value='" + v.value + "'>" + v.text + "</option>");			
		});
	}
	
	function saveData() {
		var frm = $("#frmMain");
		frm.serializeArrayCustom();
		frm.addParam("func", "IS");
		frm.addParam("dataType", "json");
		frm.setAction("<c:url value='/sys/faqM.do' />");
		frm.request();
	}

	function handleIS(data, textStatus, jqXHR) {
		if (data.count > 0) {
			if (opener && typeof opener.loadTableData === "function") {
				opener.opener.loadTableData();
			}
			createCombo();
		}
	}

	function deleteData() {
		var frm = $("#frmMain");
		frm.serializeArrayCustom();
		frm.addParam("func", "IS2");
		frm.addParam("dataType", "json");
		frm.addParam("hCompCode", $("#hCompCode").val());
		frm.addParam("enc_col", "userId");
		frm.setAction("<c:url value='/park/parkCompUpdate.do' />");
		frm.request();
	}

	function handleIS2(data, textStatus, jqXHR) {
		if (data.count > 0) {
			if (opener && typeof opener.loadTableData === "function") {
				opener.opener.loadTableData();
			}
			createCombo();
		}
	}

	// 저장 제약조건
	function validation() {

		if($("#gubn").val() != "C" && $("#menuName").val() == ""){
			alert("카테고리명을 선택해주십시오.");
			return;
		}
		
		if($("#gubn").val() != "D" && $("#faqContent").val().trim() == ""){
			alert("추가/수정 카테고리명을 입력해주십시오.");
			return;
		}
		
		var text = "";
		var plus_text = "";
		for(var i=0; i<$("#gubn").children().length; i++){
			if($("#gubn").val() == $("#gubn").children().eq(i).val()){
				if($("#gubn").val() == "C"){
					text = "저장";
				}else{
					text = $("#gubn").children().eq(i).text();
				}
				
				if($("#gubn").val() == "D"){
					plus_text = "※ 하위에 있는 질문및답변도 삭제됩니다. 그래도 ";
				}
			} 
		}

		if (confirm(plus_text + "메뉴명을 " + text + "하시겠습니까?")) {
			saveData();
		}
	}

	$(function() {
		// 등록
		$("#btnSave").on("click", function() {
			validation();
		});

		// 삭제
		$("#btnDelete").on("click", function() {
			if (confirm("삭제시 주차장 정보 관리에 등록되어있는 해당 회사가 삭제 됩니다.\n정말 삭제하시겠습니까?")) {
				deleteData();
			}
		});

		// 닫기
		$("#btnClose").on("click", function() {
			self.close();
		});
		
		
		// 닫기
		$("#gubn").on("change", function() {
			if($("#gubn").val() == "C"){
				$("#menuName").parent().parent().parent().hide();
				$("#faqContent").parent().parent().parent().show();
			}else if($("#gubn").val() == "U"){
				$("#menuName").parent().parent().parent().show();
				$("#faqContent").parent().parent().parent().show();
			}else{
				$("#menuName").parent().parent().parent().show();
				$("#faqContent").parent().parent().parent().hide();
			}
		});
		
		loadComboData();
		$("#menuName").parent().parent().parent().hide();
		$(".card-block").css("height","245px");
	});
</script>
<div class="page-body" style="font-size: 0.9em;">
	<div class="row">
		<div class="col-12" id="search_all_wrapper">
			<div class="col-12">
				<card:open title="카테고리 정보" />
				<card:button>
				</card:button>
				<card:content />
				<form id="frmMain" name="frmMain" method="post"	onsubmit="return false" class="form-horizontal">
					<div class="form-group col-xl-12 col-lg-12 col-md-12 col-sm-12 no-margin no-padding "> 
		                <label class="col-xl-5 col-lg-5 col-md-5 col-sm-5 col-5 control-label text-right" style="width: 120px !important;">구분</label> 
		                <div class="col-xl-7 col-lg-7 col-md-7 col-sm-7 col-7 inputGroupContainer label-attached" style="max-width: calc(100% - 120px);"> 
		                    <div class="input-group"> 
		                        <span class="input-group-addon"><i class="fas fa-bars" data-icon="fas fa-bars"></i></span> 
		                        <select name="gubn" id="gubn" class="form-control selectpicker  fill" style="height:35px;"> 
			                        <option value="C">신규</option> 
			                        <option value="U">수정</option>
			                        <option value="D">삭제</option>
			                     </select>
		                    </div> 
		                </div> 
		            </div>
		            <div class="form-group col-xl-12 col-lg-12 col-md-12 col-sm-12 no-margin no-padding "> 
		                <label class="col-xl-5 col-lg-5 col-md-5 col-sm-5 col-5 control-label text-right" style="width: 120px !important;">카테고리명</label> 
		                <div class="col-xl-7 col-lg-7 col-md-7 col-sm-7 col-7 inputGroupContainer label-attached" style="max-width: calc(100% - 120px);"> 
		                    <div class="input-group"> 
		                        <span class="input-group-addon"><i class="fas fa-bars" data-icon="fas fa-bars"></i></span> 
		                        <select name="menuName" id="menuName" class="form-control selectpicker " style='height:35px;'> 
		                        	<option value=''>선택</option>
		                        </select> 
		                    </div> 
		                </div> 
		            </div>
					<div class="form-group col-xl-12 col-lg-12 col-md-12 col-sm-12 no-margin no-padding "> 
		                <label class="col-xl-5 col-lg-5 col-md-5 col-sm-5 col-5 control-label text-right" style="width: 120px !important;">추가/수정 카테고리명</label> 
		                <div class="col-xl-7 col-lg-7 col-md-7 col-sm-7 col-7 inputGroupContainer label-attached" style="max-width: calc(100% - 120px);"> 
		                    <div class="input-group"> 
		                        <span class="input-group-addon"><i class="fas fa-pencil-alt" data-icon="fas fa-pencil-alt"></i></span> 
		                        <input name="faqContent" id="faqContent" class="form-control " type="text" value=""  /> 
		                    </div> 
		                </div> 
		            </div> 
				</form>
				<card:close />
			</div>
		</div>
	</div>
	<div class="row padding-left-10 padding-right-10">
		<div class="bottom-btn-area">
			<div
				class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12 text-right">
				<c:if test="${empty param.pCompCode}">
					<form:button type="Save" id="btnSave" />
				</c:if>
				<c:if test="${not empty param.pCompCode}">
					<form:button type="Save" id="btnSave" />
				</c:if>
				<form:button type="Close" id="btnClose" />
			</div>
			<label:clear />
		</div>
	</div>
</div>


<%@ include file="../../core/include/footer.jsp"%>
