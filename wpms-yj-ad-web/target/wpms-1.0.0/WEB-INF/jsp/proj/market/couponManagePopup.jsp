<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="form" uri="http://ad.its.yeongju.kr/jsp/jstl/form"%>
<%@ taglib prefix="card" uri="http://ad.its.yeongju.kr/jsp/jstl/card"%>
<%@ taglib prefix="func" uri="http://ad.its.yeongju.kr/jsp/jstl/func"%>
<%@ taglib prefix="label" uri="http://ad.its.yeongju.kr/jsp/jstl/label"%>

<%@ include file="../../core/include/head.jsp"%>
<%@ include file="../../core/include/headerPopup.jsp"%>

<script type="text/javascript">

	var _originData;

	var columnDefs = [
		setColumn(["no", "번호", "center", 50], [false, ["index", "asc"]]),
		setColumn(["areaName", "장소", "left", 100]),
		setColumn(["pGovName", "관리기관", "center", 140]),
		setColumn(["parkingName", "주차장명", "center", 120]),
	];
	
	var _gridHelper = new initGrid(columnDefs, true);
    var gridOptions = _gridHelper.setGridOption();
	
	function loadTableData() {

		var frm = $("#frmMain");
		frm.addParam("func", "IQ");
		frm.addParam("query_id", "market.couponManage.select_detailList");
		frm.addParam("enc_col", "hCouponMemberId");
	    frm.addParam("dataType", "json");           // 그리드 불러오는 타입 (기본 json)
		frm.request();
	}

	function handleIQ(data, textStatus, jqXHR) {
		if(data.length > 0){
			$("#kCouponMemberId").val(data[0].couponMemberId);
			$("#kCouponMemberName").val(data[0].couponMemberName);
			$("#kMemberPhone").val(data[0].memberPhone);
			$("#kZipCode").val(data[0].zipCode);
			$("#kAddrCode1").val(data[0].address1);
			$("#kAddrCode2").val(data[0].address2);
			$("#kRegDt").val(data[0].regDt);
			
			$('#kMemberPhone').blur();
			$('#kMemberPhone').attr("readonly", "true");
			$("#kMemberPhone").siblings("span").children("i").removeClass();
			$("#kMemberPhone").siblings("span").children("i").addClass("fas fa-eye");
			$("#kMemberPhone").siblings("span").children("i").data("icon", "fas fa-eye");
		}
		
		loadTableData2();
	}
	
	function loadTableData2() {

		var frm = $("#frmMain");
		//---- 그리드 조회 시 필수요소 start
		frm.addParam("result", $("#myGrid")); // 그리드 태그
		frm.addParam("grid", "gridOptions"); // 그리드 옵션
		frm.addParam("baseData", "_originData"); // 그리드 원본 데이터 저장 변수
		//---- 그리드 조회 시 필수요소 end
		frm.addParam("func", "IQ2");
		frm.addParam("query_id", "market.couponManage.select_areaList");
		frm.addParam("enc_col", "hCouponMemberId");
	    frm.addParam("dataType", "json");           // 그리드 불러오는 타입 (기본 json)
		frm.request();
	}

	function handleIQ2(data, textStatus, jqXHR) {
		gridOptions.api.sizeColumnsToFit();
	}
	
   /*  function saveData() {
		var frm = $("#frmMain");
		frm.addParam("func", "IS");
        frm.addParam("dataType", "json");
        frm.addParam("kCouponMemberId", $("#kCouponMemberId").val());
        frm.addParam("kUseYn", $("#kUseYn").val());
	    frm.addParam("enc_col", "kCouponMemberId");
        frm.setAction("<c:url value='/market/CouponManageSave.do' />");
		frm.request();
    }

    function handleIS(data, textStatus, jqXHR){
    	if(data.count > 0){
    		if (opener && typeof opener.loadTableData === "function") {
        		opener.loadTableData();
        	}

        	window.close();
    	}
    	$("#kMemberPw").val("");
    	$("#kMemberPw").attr("readonly", true);
		$("#kMemberPw").siblings("span").children("i").removeClass();
		$("#kMemberPw").siblings("span").children("i").addClass("fas fa-eye");
		$("#kMemberPw").siblings("span").children("i").data("icon", "fas fa-eye");
		$("#btnPwChange").text("활성화");
		$("#btnPwChange").data("gubn", "activation");
    } */
    
    function saveData2() {
		var frm = $("#frmMain");
		frm.addParam("func", "IS2");
        frm.addParam("dataType", "json");
        frm.addParam("kCouponMemberId", $("#kCouponMemberId").val());
	    frm.addParam("kMemberPw", $("#kMemberPw").val());
	    frm.addParam("enc_col", "kCouponMemberId");
        frm.setAction("<c:url value='/market/CouponPasswordUpdate.do' />");
		frm.request();
    }

    function handleIS2(data, textStatus, jqXHR){
    	$("#kMemberPw").val("");
    	$("#kMemberPw").attr("readonly", true);
		$("#kMemberPw").siblings("span").children("i").removeClass();
		$("#kMemberPw").siblings("span").children("i").addClass("fas fa-eye");
		$("#kMemberPw").siblings("span").children("i").data("icon", "fas fa-eye");
		$("#btnPwChange").text("활성화");
		$("#btnPwChange").data("gubn", "activation");
    }
    
	//비밀번호 체크
	function passNotify(){
		var pwReg = /^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-]).{8,20}$/;
		var pwSpaceReg = /\s/g;
		var pw = $("#kMemberPw").val();

		if(!pw || pw.length <= 0){
			//비밀번호가 공백
			alert("비밀번호를 입력해 주세요.");

			return false;
		}else if(!pwReg.test(pw)){
			//비밀번호가 정규표현식에 맞지않을경우
			alert("비밀번호는 8~20자 영문 대 소문자, 숫자, 특수문자를 사용하세요.");

			return false;
		}else if(pwSpaceReg.test(pw)){
			//비밀번호가 정규표현식에 맞지않을경우
			alert("비밀번호에 공백을 입력할 수 없습니다.");

			return false;
		}

		return true;
	}

	$(function(){
		
		// lookup the container we want the Grid to use
		var eGridDiv = document.querySelector('#myGrid');

		// create the grid passing in the div to use together with the columns & data we want to use
		new agGrid.Grid(eGridDiv, gridOptions);
		
		$("#btnClose").click(function() {
			self.close();
		});
		
		$("#btnSave").click(function() {
			if(confirm("저장하시겠습니까?")){
				saveData();
			}
		});
		
		// 비밀번호 변경
		$("#btnPwChange").click(function() {
			if($(this).data("gubn") == "activation"){
				$("#kMemberPw").attr("readonly", false);
				$("#kMemberPw").siblings("span").children("i").removeClass();
				$("#kMemberPw").siblings("span").children("i").addClass("fas fa-pencil-alt");
				$("#kMemberPw").siblings("span").children("i").data("icon", "fas fa-pencil-alt");
				$("#btnPwChange").text("변경");
				$("#btnPwChange").data("gubn", "change");

			}else if($(this).data("gubn") == "change"){
				if(passNotify()){
					if(confirm("비밀번호를 변경하시겠습니까?")){
						saveData2();
					}
				}
			}
		});

		$("#kMemberPhone").inputMasking("phone");
		
		loadTableData();
	});
</script>

<div class="page-body" style="font-size: 0.9em;">
	<div class="row">
		<!-- <div class="col-12" id="search_all_wrapper">
		</div> -->
		<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12">
			<div class="col-xl-5 col-lg-5 col-md-5 col-sm-5 col-5">
                <card:open title="주차권관리자 상세" />
                <card:button>
                </card:button>
                <card:content />
                <form id="frmMain" name="frmMain" method="post" onsubmit="return false" class="form-horizontal" >
                    <form:input id="hCouponMemberId" caption="hCouponMemberId" type="hidden" value="${param.couponMemberId}"/>
					<label:input id="kCouponMemberId" caption="ID" size="12" state="readonly"/>
					<div class="form-group col-xl-12 col-lg-12 col-md-12 col-sm-12 no-margin no-padding ">
                        <label class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right">비밀번호</label>
                        <div class="col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached">
                            <div class="input-group">
                                <span class="input-group-addon"><i class="fas fa-eye" data-icon="fas fa-pencil-alt"></i></span>
                                <input name="kMemberPw" id="kMemberPw" class="form-control text-center" type="password" value="" maxlength="20" title="8~20자 영문 대 소문자, 숫자, 특수문자를 사용하세요." readonly="readonly">
                                <span class="input-group-btn">
									<button id="btnPwChange" type="button" name="btnPwChange" class="btn btn-sm btn-primary" data-gubn="activation">활성화</button>
								</span>
                            </div>
                        </div>
                    </div>
                    <label:input id="kCouponMemberName" caption="주차권관리자" size="12" state="readonly" addAttr="style='text-align:center;'"/>
                    <label:input id="kMemberPhone" caption="휴대폰번호" size="12" state="" addAttr="style='text-align:center;'"/>
					<label:input id="kZipCode" caption="우편번호" size="12" state="readonly"/>
					<label:input id="kAddrCode1" caption="주소" size="12" state="readonly"/>
					<label:input id="kAddrCode2" caption="상세주소" size="12" state="readonly"/>
					<label:input id="kRegDt" caption="가입일시" size="12" state="readonly" addAttr="style='text-align:center;'"/>
					<label:clear />
                </form>
                <card:close />
            </div>
            <div class="col-xl-7 col-lg-7 col-md-7 col-sm-7 col-7">
				<card:open title="사용 신청 장소 목록" />
				<card:toolButton title="">
				</card:toolButton>
				<card:content />
				<form:grid id="myGrid" height="422px" />
				<card:close />
			</div>					
		</div>
	</div>
	<div class="row padding-left-10 padding-right-10">
		<div class="bottom-btn-area">
			<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12 text-right">
				<%-- <form:button type="Save" id="btnSave" /> --%>
				<form:button type="Close" id="btnClose" />
			</div>
			<label:clear />
		</div>
	</div>
</div>