<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="form" uri="http://ad.its.yeongju.kr/jsp/jstl/form" %>
<%@ taglib prefix="card" uri="http://ad.its.yeongju.kr/jsp/jstl/card" %>
<%@ taglib prefix="func" uri="http://ad.its.yeongju.kr/jsp/jstl/func" %>

<%@ include file="../../core/include/head.jsp" %>
<%@ include file="../../core/include/header.jsp" %>

<script type="text/javascript">

	function content() {
		
	}

	$(function() {
		$("#btnSearch").click(function() {

	    	$.ajax({
	            method: "POST",
	            url: "<c:url value='/resource' />",
	            data: {
	            		"kSearchLine": $("#kSearchLine").val()
	            },
	            success : function(result) {
		            	if (result.count != 0) {
		            		$("#content").html("");
		            		
	            			for(var i = 0; i<result.data.log.length; i++) {
		            			var log = result.data.log[i] + "\n";
		            			var content = $("#content").val();
		            			
		            			content = content + log
		            			$("#content").html(content);
		            		}
		            	} else {
		            		alert("처리중 오류가 발생했습니다.");
		            	}
	            },
	            error: function(data, textStatus, jqXHR){
	                alert(data);
	            }
	        });	
		});
		
		$("#btnSearch").trigger("click");
	});
</script>

<div class="page-body" style="font-size: 0.9em;">
	<div class="row">
		<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12"
			id="search_all_wrapper">
			<card:open title="검색조건" />
			<card:button>
				<form:button type="Search" id="btnSearch" />
			</card:button>
			<card:content />
			<div class="search-area col-lg-12">
				<form id="frmMain" name="frmMain" method="post" onsubmit="return false" class="form-material form-inline">
					<form:input id="kSearchLine" caption="조회라인" addAttr="maxlength='20'" value="100" />
				</form>
			</div>
			<card:close />
		</div>
        <div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12">
            <textarea style="width:100%; height:590px;" id="content"></textarea>
        </div>
	</div>
</div>
<%@ include file="../../core/include/footer.jsp"%>

