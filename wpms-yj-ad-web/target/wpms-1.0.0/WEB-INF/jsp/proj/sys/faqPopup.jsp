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
		frm.addParam("query_id", "sys.faq.select_faq_detail");
		frm.addParam("dataType", "json"); // 그리드 불러오는 타입 (기본 json)
		frm.request();
	}

	function handleIQ(data, textStatus, jqXHR) {
		if (data.length > 0) {

			$("#menuName").val($("#faqCode").val());
			$("#faqContent").val(data[0].faqContent);
			$("#rFaqContent").val(data[0].rFaqContent);

		}
	}

	function saveData() {
		var frm = $("#frmMain");
		frm.serializeArrayCustom();
		if($("#faqCode").val() == ""){
			frm.addParam("faqCode", $("#menuName").val());
		}else{
			frm.addParam("faqCode", $("#faqCode").val());
		}
		frm.addParam("func", "IS");
		frm.addParam("dataType", "json");
		frm.setAction("<c:url value='/sys/faq.do' />");
		frm.request();
	}

	function handleIS(data, textStatus, jqXHR) {
		if (data.count > 0) {
			if (opener && typeof opener.loadTableData === "function") {
				opener.loadTableData();
			}
			window.close();
		}
	}

	function deleteData() {
		var frm = $("#frmMain");
		frm.serializeArrayCustom();
		frm.addParam("func", "IS");
		frm.addParam("dataType", "json");
		frm.setAction("<c:url value='/sys/deleteFaq.do' />");
		frm.request();
	}

	function handleIS2(data, textStatus, jqXHR) {
		if (data.count > 0) {
			if (opener && typeof opener.loadTableData === "function") {
				opener.loadTableData();
			}
			window.close();
		}
	}

	// 저장 제약조건
	function validation() {
	
		if($("#menuName").val() == ""){
			alert("메뉴명을 선택해주십시오.");
			return;
		}
		
		if($("#faqContent").val() == ""){
			alert("질문을 입력해주십시오.");
			return;
		}
		
		if($("#rFaqContent").val() == ""){
			alert("답변을 입력해주십시오.");
			return;
		}

		if (confirm("질문 및 답변을 저장하시겠습니까?")) {
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
			if (confirm("정말 삭제하시겠습니까?")) {
				deleteData();
			}
		});

		// 닫기
		$("#btnClose").on("click", function() {
			self.close();
		});
		
		$("#menuName").parent().append("<span class='input-group-btn'><button id='btnMenuAdd' type='button' name='btnMenuAdd' class='btn btn-sm btn-primary'>추가</button></span>");
		
		$("#btnMenuAdd").on("click", function() {
	    	OpenPopupSingle("/sys/faqMPopup.do", 535, 410, "_Pop_Menu");
	    });
		
		loadTableData();
		
	});
</script>
<div class="page-body" style="font-size: 0.9em;">
	<div class="row">
		<div class="col-12" id="search_all_wrapper">
			<div class="col-12">
				<card:open title="질문/답변 정보" />
				<card:button>
				</card:button>
				<card:content />
				<form id="frmMain" name="frmMain" method="post"	onsubmit="return false" class="form-horizontal">
					<form:input id="faqCode" type="hidden" value="${param.faqCode}"/>
					<form:input id="qCode" type="hidden" value="${param.qCode}"/>
					<label:select id="menuName" caption="카테고리명" size="12" queryId="sys.faq.select_faq_list" all="true" allLabel="선택" addAttr="style='height:35px;'" />
					<label:input id="faqContent" caption="질문" size="12" addAttr="maxlength='200'"/>
					<label:textarea id="rFaqContent" caption="답변" size="12" rows="20" addAttr="maxlength='2000'"/>  
				</form>
				<card:close />
			</div>
		</div>
	</div>
	<div class="row padding-left-10 padding-right-10">
		<div class="bottom-btn-area">
			<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12 text-right">
				<form:button type="Save" id="btnSave" />
				<c:if test="${not empty param.faqCode}">
					<form:button type="Delete" id="btnDelete" />
				</c:if>
				<form:button type="Close" id="btnClose" />
			</div>
			<label:clear />
		</div>
	</div>
</div>


<%@ include file="../../core/include/footer.jsp"%>
