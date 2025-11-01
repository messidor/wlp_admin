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

			$("#pCompName").val(data[0].pCompName);
			$("#pCompTel").val(data[0].pCompTel);
			$("#pCompPost").val(data[0].pCompPost);
			$("#pCompAddr").val(data[0].pCompAddr);
			$("#pCompAddr2").val(data[0].pCompAddr2);
			$("#pManager").val(data[0].pManager);
			$("#pManagerPhone").val(data[0].pManagerPhone);
			$("#pManagerEmail").val(data[0].pManagerEmail);
			$("#mid").val(data[0].mid);
			$("#sspMallId").val(data[0].sspMallId);
			$("#mKey").val(data[0].mKey);
			$("#useYn").val(data[0].useYn);
			$("#pServiceKey").val(data[0].pServiceKey);
			$("#regId").val(data[0].regId);
			$("#regDt").val(data[0].regDt);
			$("#modId").val(data[0].modId);
			$("#modDt").val(data[0].modDt);

			$("#pCompTel").focus();
			$("#pManagerPhone").focus();
			$('#pManagerPhone').blur();

			// 발급하였으면 발급 버튼 사라지도록 처리
			if (data[0].pServiceKeyYn == "Y") {
				$("#issuanceSpan").css("display", "none");
			}
		}
	}

	function saveData() {
		var frm = $("#frmMain");
		frm.serializeArrayCustom();
		frm.addParam("func", "IS");
		frm.addParam("dataType", "json");
		frm.addParam("hCompCode", $("#hCompCode").val());
		frm.addParam("enc_col",
				"userId, pManager, pManagerPhone, pManagerEmail");
		frm.setAction("<c:url value='/park/parkCompInsert.do' />");
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
				opener.loadTableData();
			}
			window.close();
		}
	}

	// 저장 제약조건
	function validation() {

		var postRule = /^(\d{3}-?\d{3}|\d{3}-?\d{2})$/u;

		if ($("#pCompName").val() == "") {
			alert("회사명을 입력해 주세요.");
			$("#pCompName").focus();
			return;
		}

		if ($("#pCompPost").val() == "") {
			alert("우편번호를 입력해 주세요.");
			$("#pCompPost").focus();
			return;
		}

		if (!postRule.test($("#pCompPost").val())) {
			alert("우편번호가 올바르지 않습니다.");
			$("#pCompPost").focus();
			return;
		}

		if ($("#pCompAddr").val() == "") {
			alert("주소를 입력해 주세요.");
			$("#pCompAddr").focus();
			return;
		}

		if ($("#pManager").val() == "") {
			alert("담당자를 입력해 주세요.");
			$("#pManager").focus();
			return;
		}

		if ($("#pManagerPhone").val() == "") {
			alert("담당자연락처를 입력해 주세요.");
			$("#pManagerPhone").focus();
			return;
		}

		if (confirm("주차장 회사 정보를 저장하시겠습니까?")) {
			saveData();
		}
	}

	function saveData2() {
		var frm = $("#frmMain");
		frm.serializeArrayCustom();
		frm.addParam("func", "IS3");
		frm.addParam("dataType", "json");
		frm.addParam("enc_col", "userId");
		frm.setAction("<c:url value='/park/parkingServiceInfo.do' />");
		frm.request();
	}

	function handleIS3(data, textStatus, jqXHR) {
		if (data.count > 0) {
			loadTableData();
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

		// 우편번호 선택
		$("#btnPostcodeAdd")
				.click(
						function() {
							daum.postcode
									.load(function() {
										new daum.Postcode(
												{
													oncomplete : function(data) {
														// 팝업에서 검색결과 항목을 클릭했을때 실행할 코드를 작성하는 부분.

														// 각 주소의 노출 규칙에 따라 주소를 조합한다.
														// 내려오는 변수가 값이 없을땐 공백('')값을 가지므로, 이를 참고하여 분기한다.
														var addr = ''; // 주소 변수
														//var extraAddr = ''; // 조합형 주소 변수

														fullAddr = data.roadAddress == "" ? data.autoRoadAddress
																: data.roadAddress;

														if (data.userSelectedType === 'R') {
															//법정동명이 있을 경우 추가한다.
															if (data.bname !== '') {
																addr += data.bname;
															}
															// 건물명이 있을 경우 추가한다.
															if (data.buildingName !== '') {
																addr += (addr !== '' ? ', '
																		+ data.buildingName
																		: data.buildingName);
															}
															// 조합형주소의 유무에 따라 양쪽에 괄호를 추가하여 최종 주소를 만든다.
															fullAddr += (addr !== '' ? ' ('
																	+ addr
																	+ ')'
																	: '');
														}

														// 우편번호와 주소 정보를 해당 필드에 넣는다.
														document
																.getElementById("pCompPost").value = data.zonecode;
														document
																.getElementById("pCompAddr").value = fullAddr;

														// 커서를 상세주소 필드로 이동한다.
														document
																.getElementById(
																		"pCompAddr2")
																.focus();
													}
												}).open();
									});
						});

		// serviceKey 발급
		$("#btnIssuance").click(function() {
			saveData2();
		});

		<c:if test="${not empty param.pCompCode}">
		loadTableData();
		</c:if>

		$("#pCompTel").inputMasking("phone");
		$("#pManagerPhone").inputMasking("phone");

	});
</script>
<div class="page-body" style="font-size: 0.9em;">
	<div class="row">
		<div class="col-12" id="search_all_wrapper">
			<div class="col-12">
				<card:open title="주차장 회사 정보" />
				<card:button>
				</card:button>
				<card:content />
				<form id="frmMain" name="frmMain" method="post"
					onsubmit="return false" class="form-horizontal">
					<form:input id="hCompCode" type="hidden" value="${param.pCompCode}" />
					<label:input id="pCompName" caption="회사명" size="6"
						className="danger" addAttr="maxlength='50'" />
					<label:input id="pCompTel" caption="전화번호" size="6"
						addAttr="maxlength='10'" />
					<div
						class="form-group col-xl-6 col-lg-6 col-md-6 col-sm-6 col-6 no-margin no-padding has-danger">
						<label
							class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right">우편번호</label>
						<div
							class="col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached">
							<div class="input-group">
								<span class="input-group-addon"><i
									class="fas fa-pencil-alt" data-icon="fas fa-eye"></i></span> <input
									name="pCompPost" id="pCompPost" class="form-control"
									type="text" value=""> <span class="input-group-btn">
									<button id="btnPostcodeAdd" type="button" name="btnPostcodeAdd"
										class="btn btn-sm btn-primary">주소검색</button>
								</span>
							</div>
						</div>
					</div>
					<label:input id="pManagerEmail" caption="이메일" size="6"
						addAttr="maxlength='25'" />
					<label:input id="pCompAddr" caption="주소" size="6"
						className="danger" />
					<label:select id="useYn" caption="사용여부" size="6" queryId="#use_yn"
						all="false" allLabel="" addAttr="style='height:35px;'" />
					<label:input id="pCompAddr2" caption="상세주소" size="6"
						addAttr="maxlength='50'" />
					<label:input id="modId" caption="수정자" size="6" state="readonly" />
					<label:input id="pManager" caption="담당자" size="6"
						className="danger" addAttr="maxlength='25'" />
					<label:input id="modDt" caption="수정일시" size="6" state="readonly" />
					<label:input id="pManagerPhone" caption="담당자연락처" className="danger"
						size="6" addAttr="maxlength='12'" />
					<c:if test="${not empty param.pCompCode}">
						<div
							class="form-group col-xl-6 col-lg-6 col-md-6 col-sm-6 col-6 no-margin no-padding">
							<label
								class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right">serviceKey</label>
							<div
								class="col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached">
								<div class="input-group">
									<span class="input-group-addon"><i class="fas fa-eye"
										data-icon="fas fa-eye"></i></span> <input name="pServiceKey"
										id="pServiceKey" class="form-control" type="text" value=""
										readonly="readonly"> <span class="input-group-btn"
										id="issuanceSpan">
										<button id="btnIssuance" type="button" name="btnIssuance"
											class="btn btn-sm btn-primary">발급</button>
									</span>
								</div>
							</div>
						</div>
					</c:if>
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
