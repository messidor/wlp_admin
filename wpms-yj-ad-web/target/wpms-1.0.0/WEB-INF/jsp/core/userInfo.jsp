<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="form" uri="http://ad.its.yeongju.kr/jsp/jstl/form" %>
<%@ taglib prefix="card" uri="http://ad.its.yeongju.kr/jsp/jstl/card" %>
<%@ taglib prefix="func" uri="http://ad.its.yeongju.kr/jsp/jstl/func" %>

<%@ include file="../core/include/head.jsp" %>
<%@ include file="../core/include/header.jsp" %>

<style type="text/css">
.control-label {
    width: 135px !important;
}

.inputGroupContainer.label-attached {
    max-width: calc(100% - 135px);
}

.item_form{
    margin: 6px 0;
}
.item-label{
    font-size:14px;
}
</style>

<script type="text/javascript">

    var _ogringData = [];

    function loadTableData() {
        var frm = $("#frmMain");
		frm.addParam("func", "IQ");
        frm.addParam("enc_col", "userId");
        frm.addParam("query_id", "index.user.select_userInfo");
        frm.addParam("dataType", "json");
		frm.request();
    }

    function handleIQ(data, textStatus, jqXHR) {
        if(data.length > 0){
            $("#userId").text(data[0].userId);
            $("#userPw").val(data[0].userPw);
            $("#userName").val(data[0].userName);
            $("#userPhone").val(data[0].userPhone);
            $("#userEmail").val(data[0].userEmail);
            $("#recvYn").val(data[0].recvYn);
            $('#userPhone').blur();

            _ogringData.push(data[0].userName);
            _ogringData.push(data[0].userPhone);

        }
    }

    function saveData() {
        var frm = $("#frmMain");

        frm.addParam("userInfoId", $("#userId").text());
        frm.addParam("userInfoName", $("#userName").val());
        frm.addParam("userInfoPw", $("#userPw").val());
        frm.addParam("newPassword1", $("#newPassword1").val());
        frm.addParam("userInfoPhone", $("#userPhone").val().replaceAll("-", ""));
        frm.addParam("userInfoEmail", $("#userEmail").val());
        frm.addParam("recvYn", $("#recvYn").val());
        frm.addParam("enc_col", "userInfoId, userInfoName, userInfoPw, newPassword1, userInfoPhone, userInfoEmail");
        frm.addParam("func", "IS");
        frm.setAction("<c:url value='/user/userUpdate.do' />");
        frm.addParam("dataType", "json");
        frm.addParam("reqAction", true);

        frm.request();

    }

    function handleIS(data, textStatus, jqXHR){
        if(data.count > 0) {
            $("#newPassword1").val("");
            $("#newPassword2").val("");
            loadTableData();

            _ogringData = [];
        }
    }
	
	function validation() {
		var orgPw = $("#userPw").val();
		var name = $("#userName").val();
		var pw = $("#newPassword1").val();
		var pwChk = $("#newPassword2").val();
		var phone = $("#userPhone").val();
		
		
		var idReg = /^[a-zA-Z0-9]{4,12}$/;
		var pwReg = /^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-]).{8,20}$/;
		var hangulcheck = /[ㄱ-ㅎ|ㅏ-ㅣ|가-힣]/;
		
		
		// 사용자명 입력 확인
		if(name == ""){
			notifyDanger("사용자명을 입력해주세요.");
			$("#userName").focus();
			return false;
		}
		
		// 현재 비밀번호 입력 확인
		if(orgPw == ""){
			notifyDanger("정보 변경시 현재 비밀번호를 입력해야합니다.");
			$("#userPw").focus();
			return false;
		}
		
		// 연락처 입력 확인
		if(phone == ""){
			notifyDanger("연락처를 입력해주세요.");
			$("#userPhone").focus();
			return false;
		}
		
		// 비밀번호 변경 여부 확인
		if(pw != "" || pwChk != ""){
			if(pw == ""){
				notifyDanger("새로운 비밀번호를 입력해주세요.");
				$("#newPassword1").focus();
				return false;
			}else if(!pwReg.test(pw)) {
				notifyDanger("비밀번호는 8~20자 이하, 숫자/대문자/소문자/특수문자를 모두 포함해야 합니다.");
				$("#newPassword1").focus();
				return false;
			}else if(pwChk == "") {
				notifyDanger("새로운 비밀번호 확인을 입력해주세요.");
				$("#newPassword2").focus();
				return false;
			}else if(!pwReg.test(pwChk)) {
				notifyDanger("비밀번호는 8~20자 이하, 숫자/대문자/소문자/특수문자를 모두 포함해야 합니다.");
				$("#newPassword2").focus();
				return false;
			}else if(pw != pwChk) {
				notifyDanger("비밀번호가 일치하지 않습니다.");
				$("#newPassword1").focus();
				return false;
			}
		}
		
		saveData();
	}


    $(function() {
        $("#btnSave").click(function(){
        	validation();
        });

        loadTableData();
        $('#userPhone').inputMasking("phone");
	
    });
</script>
</script>

<div class="page-body" style="font-size:0.9em;">
    <div class="row">
        <div class="col-xl-6 col-lg-12 col-md-12 col-sm-12 col-12" id="gubn_size" >
            <div>
                <card:open title="사용자 정보" />
            </div>
            <card:content />
            <form id="frmMain" name="frmMain" method="post" onsubmit="return false" class="form-horizontal;">
                <div class="form-group col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12 no-margin no-padding" style="display:flex; height:50px">
                    <label class="control-label text-right" style="width:130px !important;">사용자ID</label>
                    <div class="col-8" style="height:40px; line-height:33px; font-weight: bold; margin-left:5px;">
                        <span class="text-center" id="userId"></span>
                    </div>
                </div>
                <div class="form-group col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12 no-margin no-padding has-danger">
                    <label class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right">사용자명</label>
                    <div class="col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached">
                        <div class="input-group">
                            <span class="input-group-addon"><i class="fas fa-pencil-alt" data-icon="fas fa-pencil-alt"></i></span>
                            <input type="text" name="userName" id="userName" class="form-control text-left" type="text" value="" maxlength="10">
                        </div>
                    </div>
                </div>
                <div class="form-group col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12 no-margin no-padding has-danger">
                    <label class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right">비밀번호</label>
                    <div class="col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached">
                        <div class="input-group">
                            <span class="input-group-addon"><i class="fas fa-pencil-alt" data-icon="fas fa-pencil-alt"></i></span>
                            <input type="password" name="userPw" id="userPw" class="form-control text-left" type="text" value="" maxlength="20">
                        </div>
                    </div>
                </div>
                <div class="form-group col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12 no-margin no-padding ">
                    <label class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right">새로운 비밀번호</label>
                    <div class="col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached">
                        <div class="input-group">
                            <span class="input-group-addon"><i class="fas fa-pencil-alt" data-icon="fas fa-pencil-alt"></i></span>
                            <input type="password" name="newPassword1" id="newPassword1" class="form-control text-left" type="text" maxlength="20">
                        </div>
                    </div>
                </div>
                <div class="form-group col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12 no-margin no-padding ">
                    <label class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right">새로운 비밀번호 확인</label>
                    <div class="col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached">
                        <div class="input-group" style="margin-bottom: 5px;">
                            <span class="input-group-addon"><i class="fas fa-pencil-alt" data-icon="fas fa-pencil-alt"></i></span>
                            <input type="password" name="newPassword2" id="newPassword2" class="form-control text-left" type="text" maxlength="20">
                        </div>
                    </div>
                </div>
                <div class="form-group col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12 no-margin no-padding" style="display:flex; height:80px">
                    <label class="control-label text-right" style="width:130px !important;"></label>
                    <div class="col-8" style="margin-left:5px; margin-bottom:20px;">
                        <span class="text-center" style="margin-bottom:20px; color: red;">
                            ※ 새로운 비밀번호 규칙<br>
                            1. 비밀번호는 8~20자 이하, 숫자/대문자/소문자/특수문자를 모두 포함해야 합니다.<br>
                        </span>
                    </div>
                </div>
                <div class="form-group col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12 no-margin no-padding">
                    <label class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right">이메일</label>
                    <div class="col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached">
                        <div class="input-group" style="margin-bottom: 5px;">
                            <span class="input-group-addon"><i class="fas fa-pencil-alt" data-icon="fas fa-pencil-alt"></i></span>
                            <input type=text name="userEmail" id="userEmail" class="form-control text-left" type="text" maxlength="100">
                        </div>
                    </div>
                </div>
                <div class="form-group col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12 no-margin no-padding has-danger">
                    <label class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right">연락처</label>
                    <div class="col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached">
                        <div class="input-group" style="margin-bottom: 5px;">
                            <span class="input-group-addon"><i class="fas fa-pencil-alt" data-icon="fas fa-pencil-alt"></i></span>
                            <input type=text name="userPhone" id="userPhone" class="form-control text-left" type="text" maxlength="12">
                        </div>
                    </div>
                </div>
                <div class="form-group col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12 no-margin no-padding "> 
	                <label class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right">수신여부</label> 
	                <div class="col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached"> 
	                    <div class="input-group"> 
	                        <span class="input-group-addon"><i class="fas fa-bars" data-icon="fas fa-bars"></i></span> 
	                        <select name="recvYn" id="recvYn" class="form-control selectpicker " style='height:35px;'> 
	                        <option value="Y">사용</option> 
	                        <option value="N">미사용</option> 
	                        </select> 
	                    </div> 
	                </div> 
	            </div> 
            </form>
            <button type="button" id="btnSave" class="btn btn-sm waves-effect waves-light btn-success btn-outline-success" style="float: right; margin-right: 5px">
                <span class="icofont icofont-check"></span>&nbsp;저장
            </button>
            <card:close />
        </div>
    </div>
</div>
<%@ include file="../core/include/footer.jsp"%>