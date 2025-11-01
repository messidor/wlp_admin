<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="form" uri="http://ad.its.yeongju.kr/jsp/jstl/form" %>
<%@ taglib prefix="card" uri="http://ad.its.yeongju.kr/jsp/jstl/card" %>
<%@ taglib prefix="func" uri="http://ad.its.yeongju.kr/jsp/jstl/func" %>
<%@ taglib prefix="label" uri="http://ad.its.yeongju.kr/jsp/jstl/label" %>

<%@ include file="../../core/include/head.jsp"%>
<%@ include file="../../core/include/headerPopup.jsp"%>

<script type="text/javascript">
	
	var userUrl = "${userUrl}";
	
	function openerSaveData() {		
		opener.document.getElementById("hMsgTitle").value = $("#msgTitle").val();
		opener.document.getElementById("hContent").value = $("#content").val();
		opener.saveData();	
		self.close();
	}
	
	function validation(){
		if($("#msgTitle").val() == ""){
			notifyDanger("메세지 제목을 입력해 주세요.");
			$("#msgTitle").focus();
			return false;
		}
		if($("#content").val() == ""){
			notifyDanger("메세지 내용을 입력해 주세요.");
			$("#content").focus();
			return false;
		}
		
		if(confirm("메세지를 전송하시겠습니까?")){
			openerSaveData();
		}
	}
    
	$(function(){
		
		// 앞뒤공백없애기
		$("textarea.form-control").on("blur",function(){
        	$(this).val($.trim($(this).val()));
	    })
		
		$("#btnSend").click(function() {
			validation();
		});
		
		$("#btnClose").click(function() {				
			self.close();
		});
	});

</script>

<div class="page-body" style="font-size: 0.9em;">
	<div class="row">
		<div class="col-12" id="search_all_wrapper">
			<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12">
				<card:open title="SMS 발송" />
				<card:button>
				</card:button>
				<card:content />
				<form id="frmMain" name="frmMain" method="post" onsubmit="return false" class="form-horizontal">
		            <div class="form-group col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12 no-margin no-padding "> 
		                <label class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right" style="width: 150px !important;">메세지 제목</label> 
		                <div class="col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached" style="max-width: calc(100% - 150px);"> 
		                    <div class="input-group"> 
		                        <span class="input-group-addon"><i class="fas fa-pencil-alt" data-icon="fas fa-pencil-alt"></i></span> 
		                        <input name="msgTitle" id="msgTitle" class="form-control fill" type="text" value="" maxLength="20"> 
		                    </div> 
		                </div> 
		            </div>
					<div class="form-group col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12 no-margin no-padding "> 
		                <label class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right" style="width: 150px !important;">메세지 내용</label> 
		                <div class="col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached" style="max-width: calc(100% - 150px);"> 
		                    <div class="input-group"> 
		                        <span class="input-group-addon"><i class="fas fa-pencil-alt" data-icon="fas fa-pencil-alt"></i></span> 
		                        <textarea name="content" id="content" class="form-control " rows="10"></textarea> 
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
			<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12 text-right">
				<form:button type="Send" id="btnSend" caption="발송"/>
				<form:button type="Close" id="btnClose" />
			</div>
			<label:clear />
		</div>
	</div>
</div>