<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="form" uri="http://ad.its.yeongju.kr/jsp/jstl/form"%>
<%@ taglib prefix="card" uri="http://ad.its.yeongju.kr/jsp/jstl/card"%>
<%@ taglib prefix="func" uri="http://ad.its.yeongju.kr/jsp/jstl/func"%>
<%@ taglib prefix="label" uri="http://ad.its.yeongju.kr/jsp/jstl/label" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%@ include file="../../core/include/head.jsp"%>
<%@ include file="../../core/include/headerPopup.jsp" %>

<script type="text/javascript">

	var dong = "";
	var idChk = false;
	
	function loadTableData() {
	    var frm = $("#frmMain");
	    frm.addParam("func", "IQ");
	    frm.addParam("query_id", "park.genaralParkingManagePopup.select_detail");
	    frm.addParam("dataType", "json");           // 그리드 불러오는 타입 (기본 json)
	    frm.request();
	}

	function handleIQ(data, textStatus, jqXHR) {
	    idChk = true;
	    
	    if(data.length > 0){
// 	    	$("#frmMain").formSet(data); -> 오류로 인해 각각 값을 넣어주어야 함
	        dong = data[0].dong;
	        
	        $("#parkingId").val(data[0].parkingId);

	        // 최초 입력 후 수정되지 않게 하기 위함
	        if(data[0].parkingId !== undefined){
	        	$("#parkingId").prev().children().removeClass("fas fa-pencil-alt");
	        	$("#parkingId").prev().children().addClass("fas fa-eye");
	        	$("#parkingId").prop("readonly",true);
	        	
	        }else{
	        	$("#parkingId").prev().children().removeClass("fas fa-eye");
	        	$("#parkingId").prev().children().addClass("fas fa-pencil-alt");
	        	$("#parkingId").prop("readonly",false);
	        }
	        
	        $("#parkingName").val(data[0].parkingName);
	        $("#parkingPost").val(data[0].parkingPost);
	        $("#parkingAddr").val(data[0].parkingAddr);
	        $("#parkingAddr2").val(data[0].parkingAddr2);
	        $("#parkingRoadAddr").val(data[0].parkingRoadAddr);
	        $("#parkingRoadAddr2").val(data[0].parkingRoadAddr2);
	        $("#gugun").val(data[0].gugun);
	        $("#parkingLatitude").val(data[0].parkingLatitude);
	        $("#parkingLongitude").val(data[0].parkingLongitude);
	        $("#parkingGrade").val(data[0].parkingGrade);
	        $("#parkingTel").val(data[0].parkingTel);
	        $("#parkingSpot").val(data[0].parkingSpot);
	        $("#dpParkingSpot").val(data[0].dpParkingSpot);
	        $("#stdPrice").val(data[0].stdPrice);
	        $("#tenMPrice").val(data[0].tenMPrice);
	        $("#manageInfo").val(data[0].manageInfo);
	        $("#pGovCode").val(data[0].pGovCode);
	        $("#useYn").val(data[0].useYn);
	        $("#mapMarkGubn").val(data[0].mapMarkGubn);
	        
	        // inputMasking 적용
	        $("#parkingSpot").focus();
	        $("#dpParkingSpot").focus();
	        $("#stdPrice").focus();
	        $("#tenMPrice").focus();
	        $("#parkingTel").focus();
	        $("#parkingSpot").blur();
	        $("#dpParkingSpot").blur();
	        $("#stdPrice").blur();
	        $("#tenMPrice").blur();
	        $("#parkingTel").blur();

	        // 구-동 SELECT
	        loadComboData();
	    }
	}

	function saveData() {
	    var frm = $("#frmMain");
	    frm.serializeArrayCustom();
	    frm.addParam("func", "IS");
	    frm.addParam("tenMPrice", $("#tenMPrice").val());
	    frm.addParam("dataType", "json");
	    frm.addParam("enc_col", "userId");
	    frm.setAction("<c:url value='/park/generalPakingSave.do' />");
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
	    frm.setAction("<c:url value='/park/generalPakingDelete.do' />");
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

	// 저장 제약조건
	function validation(){

		var postRule = /^(\d{3}-?\d{3}|\d{3}-?\d{2})$/u;
		///(\d{3}-\d{3}|\d{5})/;

		// 주차장 정보
		if($("#parkingId").val() == ""){
	    	alert("주차장 ID를 입력해 주세요.");
	        $("#parkingId").focus();
	        return;
	    }
		
		if(!idChk) {
			alert("주차장 ID 중복 확인을 진행해 주세요.");
	        return;
		}
		
	    if($("#parkingName").val() == ""){
	        alert("주차장명을 입력해 주세요.");
	        $("#parkingName").focus();
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

	    if($("#pGovCode").val() == ""){
	    	alert("관리기관을 입력해 주세요.");
	        $("#pGovCode").focus();
	        return;
	    }

	    if($("#parkingPost").val() != "" && !postRule.test($("#parkingPost").val())){
	    	alert("우편번호가 올바르지 않습니다.");
	        $("#parkingPost").focus();
	        return;
		}

	    if($("#parkingAddr").val() == ""){
	    	alert("지번주소를 입력해 주세요.");
	        $("#parkingAddr").focus();
	        return;
	    }
	    
	    if($("#parkingRoadAddr").val() == ""){
	    	alert("도로명주소를 입력해 주세요.");
	        $("#parkingRoadAddr").focus();
	        return;
	    }

	    
	    if($("#parkingGrade").val() == ""){
	    	alert("급지를 입력해 주세요.");
	        $("#parkingGrade").focus();
	        return;
	    }

	    if($("#parkingTel").val() == ""){
	    	alert("전화번호를 입력해 주세요.");
	        $("#parkingTel").focus();
	        return;
	    }
	    
	    if($("#useYn").val() == ""){
	    	alert("사용여부를 입력해 주세요.");
	        $("#useYn").focus();
	        return;
	    }
	    
	    if($("#mapMarkGubn").val() == ""){
	    	alert("지도표시구분을 입력해 주세요.");
	        $("#mapMarkGubn").focus();
	        return;
	    }

	    if(confirm("주차장 정보를 저장하시겠습니까?")){
	    	saveData();
	    }
	}

	function loadComboData() {
		var frm = $("#frmMain");
		frm.addParam("func", "IQCombo");
		frm.addParam("gugun", $("#gugun").val());
		frm.addParam("queryId", "park.genaralParkingManagePopup.select_dongList");
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
	
	function parkingIdSelect() {
	    var frm = $("#frmMain");
	    frm.addParam("func", "IQ_PIS");
	    frm.addParam("query_id", "park.genaralParkingManagePopup.select_parkingOverlapName");
	    frm.addParam("dataType", "json");           // 그리드 불러오는 타입 (기본 json)
	    frm.request();
	}

	function handleIQ_PIS(data, textStatus, jqXHR) {
	    if(data.length > 0){
	    	idChk = false;
	    	alert("중복된 주차장 ID가 존재합니다.\n\n***현재 등록된 주차장 ID 정보***\n주차장 ID : " + data[0].parkingId + "\n관리기관 : " + data[0].pGovName + "\n주차장명 : " + data[0].parkingName);
	    } else {
	    	idChk = true;
	    	alert("사용 가능한 주차장 ID 입니다.");
	    	// 입력칸 readonly 처리
	    	$("#parkingId").prev().children().removeClass("fas fa-pencil-alt");
        	$("#parkingId").prev().children().addClass("fas fa-eye");
        	$("#parkingId").prop("readonly",true);
        	$("#btnParkingIdChk").hide();
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
	


	$(function() {
       
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

	    // parkingId 포맷
	    $(document).on('keydown', '#parkingId', function() {
	    	 var formatString = IsAlphaNumeric($("#parkingId").val());

	    	 $("#parkingId").val(formatString);
	    });
	    $(document).on('keypress', '#parkingId', function() {
	    	var formatString = IsAlphaNumeric($("#parkingId").val());

	    	 $("#parkingId").val(formatString);
	    });
	    $(document).on('keyup', '#parkingId', function() {
	    	var formatString = IsAlphaNumeric($("#parkingId").val());

	    	 $("#parkingId").val(formatString);
	    });
	    
	    // 주차장 ID 중복확인
	    $("#btnParkingIdChk").click(function(){
	    	
	    	if($("#parkingId").val() == ""){
	    		alert("주차장 ID를 입력해 주세요.");
		        $("#parkingId").focus();
		        return;
		        
	    	} else {

	    		parkingIdSelect();
	    	}
	    	
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

	                    // 도로명 주소
	                    roadAddr = data.roadAddress == "" ? data.autoRoadAddress : data.roadAddress;
	                    // 지번 주소
	                    jibunAddr = data.jibunAddress == "" ? data.autoJibunAddress : data.jibunAddress;

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
	                        roadAddr += (addr !== '' ? ' ('+ addr +')' : '');
	                        jibunAddr += (addr !== '' ? ' ('+ addr +')' : '');
	                    }

	                    // 우편번호와 주소 정보를 해당 필드에 넣는다.
	                    $("#parkingPost").val(data.zonecode);
	                    $("#parkingRoadAddr").val(roadAddr);
	                    $("#parkingAddr").val(jibunAddr);

	                    // 커서를 상세주소 필드로 이동한다.
	                    $("#parkingAddr2").focus();
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
				loadComboData();
			}

			$(this).data("current", $(this).val());
		});

		<c:if test="${not empty param.generalParkingNo}">
			loadTableData();
		</c:if>
		
		

		$("#parkingPost").inputMasking("zip");
		$("#parkingSpot").inputMasking("number");
		$("#dpParkingSpot").inputMasking("number");
		$("#stdPrice").inputMasking("number");
		$("#tenMPrice").inputMasking("number");
		$("#parkingTel").inputMasking("phone");
        $("#parkingLatitude").inputMasking("number", {decimal: 13});
        $("#parkingLongitude").inputMasking("number", {decimal: 13});

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

					<form:input id="hGeneralParkingNo" type="hidden" value="${param.generalParkingNo}"/>

					<div class="col-12">
<%-- 						<label:input id="parkingId" caption="주차장 ID" size="6" className="danger" addAttr="maxlength='5'; placeholder='주차장 ID 5자리를 입력해주세요. ex)00001'"/> --%>
						
						<div class="form-group col-6 no-margin no-padding has-danger">
							<label class="col-4 control-label text-right">주차장 ID</label>
							<div class="col-8 inputGroupContainer label-attached">
								<div class="input-group">
									<span class="input-group-addon"><i class="fas fa-pencil-alt" data-icon="fas fa-eye"></i></span>
									<input name="parkingId" id="parkingId" class="form-control" type="text" value="" maxlength="5" placeholder="ex)00001">
									<c:if test="${empty param.generalParkingNo}">
										<span class="input-group-btn">
											<button id="btnParkingIdChk" type="button" name="btnParkingIdChk" class="btn btn-sm btn-primary">중복확인</button>
										</span>
									</c:if>
									
								</div>
							</div>
						</div>
						
						<label:input id="parkingName" caption="주차장명" size="6" className="danger" addAttr="maxlength='25'"/>
						<label:select id="gugun" caption="구역(시/군/구)" size="6" className="danger" queryId="select.select_gugun" all="true" allLabel="선택" />
						<label:select id="dong"  caption="구역(읍/면/동)" size="6" className="danger" queryId="" all="true" allLabel="선택" />

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
						
						<c:choose>
							<c:when test="${fn:contains(user_role_id, 'MANAGE') || fn:contains(user_role_id, 'AD')}">
								<label:select id="pGovCode" caption="관리기관" className="danger" size="6" queryId="select.select_parkingGovInfo" all="true" allLabel="선택"/>
							</c:when>
							<c:otherwise>
								<label:select id="pGovCode" caption="관리기관" className="danger" size="6" queryId="select.select_parkingGovInfo" all="false" allLabel="선택"/>
							</c:otherwise>
						</c:choose>
						
						<label:input id="parkingAddr" caption="지번주소" size="6" className="danger"/>
						<label:input id="parkingAddr2" caption="지번상세주소" size="6" addAttr="maxlength='50'"/>
						
						<label:input id="parkingRoadAddr" caption="도로명주소" size="6" className="danger"/>
						<label:input id="parkingRoadAddr2" caption="도로명상세주소" size="6" addAttr="maxlength='50'"/>
						
						<label:input id="parkingLatitude" caption="위도" size="6" addAttr="placeholder='ex)35.538619'"/>
						<label:input id="parkingLongitude" caption="경도" size="6" addAttr="placeholder='ex)129.311006'"/>
						
						<div class="form-group col-xl-6 col-lg-6 col-md-12 col-sm-12 no-margin no-padding has-danger"> 
							<label class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right">급지</label> 
							<div class="col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached"> 
								<div class="input-group"> 
									<span class="input-group-addon"><i class="fas fa-bars" data-icon="fas fa-bars"></i></span> 
									<select name="parkingGrade" id="parkingGrade" class="form-control selectpicker"> 
										<option value="">선택</option>
										<option value="1">1</option>
										<option value="2">2</option>
										<option value="3">3</option>
										<option value="4">4</option>
										<option value="5">5</option>
									</select> 
								</div> 
							</div> 
						</div>
						
						<label:input id="parkingTel" caption="전화번호" size="6" className="danger" addAttr="maxlength='11'"/>
						
						<label:input id="parkingSpot" caption="일반주차면수" size="6" addAttr="style='text-align:right;' maxlength='11'"/>
			            <label:input id="dpParkingSpot" caption="장애인주차면수" size="6" addAttr="style='text-align:right;' maxlength='11'"/>
			            
			            <label:input id="stdPrice" caption="기본요금(평일)" size="6" addAttr="style='text-align:right;' maxlength='11'"/>
						<label:input id="tenMPrice" caption="10분당요금(평일)" size="6" addAttr="style='text-align:right;' maxlength='11'"/>
			            
						<label:select id="useYn" caption="사용여부" size="6" className="danger" queryId="#use_yn" all="true" allLabel="선택" />
						<label:select id="mapMarkGubn" caption="지도표시구분" size="6" className="danger" queryId="#map_mark_gubn" all="true" allLabel="선택" />
						<label:textarea id="manageInfo" caption="운영정보" size="12" rows="4" addAttr="maxlength='500'"/>
					</div>
				<card:close />
			</div>

			</form>
		</div>
	</div>
	<div class="row padding-left-10 padding-right-10">
		<div class="bottom-btn-area">
			<div class="col-xl-6 col-lg-6 col-md-6 col-sm-6 col-6 text-left">
				<c:if test="${not empty param.generalParkingNo}">
					<form:button type="Delete" id="btnDelete" />
				</c:if>
			</div>
			<div class="col-xl-6 col-lg-6 col-md-6 col-sm-6 col-6 text-right">
				<form:button type="Save" id="btnSave" />
				<form:button type="Close" id="btnClose" />
			</div>
			<label:clear />
		</div>
	</div>
</div>


<%@ include file="../../core/include/footer.jsp"%>
