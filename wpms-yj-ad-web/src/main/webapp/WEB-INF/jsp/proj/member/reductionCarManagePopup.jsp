<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="form" uri="http://ad.its.yeongju.kr/jsp/jstl/form"%>
<%@ taglib prefix="card" uri="http://ad.its.yeongju.kr/jsp/jstl/card"%>
<%@ taglib prefix="func" uri="http://ad.its.yeongju.kr/jsp/jstl/func"%>
<%@ taglib prefix="label" uri="http://ad.its.yeongju.kr/jsp/jstl/label"%>

<%@ include file="../../core/include/head.jsp"%>
<%@ include file="../../core/include/headerPopup.jsp"%>

<script type="text/javascript">
	
	var userUrl = "${userUrl}";
    var confirm_gubn = "${param.confirm_gubn}";
    confirm_gubn = confirm_gubn == "Y" ? true : false;
    	
	var columnDefs = [
		setColumn(["fileExt", "fileExt", "center", 120],[],true),
		setColumn(["fileName", "fileName", "center", 120],[],true),
		setColumn(["fileRelKey", "fileRelKey", "center", 120],[],true),
		setColumn(["reductionCode", "reductionCode", "center", 120],[],true),
		setColumn(["checkValue", "승인", "center", 80], [true, ["check"], false, "", "20", checking], confirm_gubn, false, false, ""),
		setColumn(["reductionName", "구분", "left", 140]),
		setColumn(["carNo", "차량번호", "center", 120]),
// 		setColumn(["redExpDate", "감면유효기간", "center", 120], [true,[],true, "", "10", checkDate]),
		setColumn(["file", "첨부파일", "center", 100], [grdCarReduction, ["button", null, "link", "첨부파일", ""] ]),
		setColumn(["rejectReason", "거절사유", "left", 180], [true,[],true, "", "250", reject])
	];  
		
	var _gridHelper = new initGrid(columnDefs, true);
	var gridOptions = _gridHelper.setGridOption();
	
	function grdCarReduction(e, data) {
		
		 gridOptions.api.forEachNode(function (node) {
		    node.setSelected(false);
		 });
		 
		if(data.fileName === undefined){
			alert("첨부파일이 존재하지 않습니다.");
			return;
		}
		
		$("#image").attr("href",userUrl+data.fileName);
		$("#iframe").attr("href",userUrl+data.fileName);
		
		if(data.fileExt == "pdf"){
			$("#image").children().attr("src","/images/no_img.jpg");
			$("#iframe").trigger("click");
		}else{
			$("#image").children().attr("src",userUrl+data.fileName);	
		}
	}
		
	function loadTableData() {
		var frm = $("#frmMain");
		//---- 그리드 조회 시 필수요소 start
		frm.addParam("result", $("#myGrid"));	   // 그리드 태그
		frm.addParam("grid", "gridOptions");		// 그리드 옵션
		frm.addParam("baseData", "_originData");	// 그리드 원본 데이터 저장 변수
		//---- 그리드 조회 시 필수요소 end
		frm.addParam("func", "IQ");
		frm.addParam("query_id", "member.reductionManage.Select_CarReduction");
		frm.addParam("dataType", "json");		   // 그리드 불러오는 타입 (기본 json)
		frm.request();
	}

	function handleIQ(data, textStatus, jqXHR) {
		
	}
	
	function saveData() {
				
		// 승인할 그리드2 데이터
		var grd_check_value = [];
		var grd_reduction_code = [];
		var grd_red_exp_date = [];
		var grd_car_no = [];
		var grd_file_rel_key = [];
		var grd_reject_reason = [];
		
		for(var i=0; i<_gridHelper.getAllGridData().length; i++){
			grd_check_value.push(_gridHelper.getAllGridData()[i].checkValue);
			grd_reduction_code.push(_gridHelper.getAllGridData()[i].reductionCode);
			grd_red_exp_date.push(_gridHelper.getAllGridData()[i].redExpDate);
			grd_car_no.push(_gridHelper.getAllGridData()[i].carNo);
			grd_file_rel_key.push(_gridHelper.getAllGridData()[i].fileRelKey);
			grd_reject_reason.push(_gridHelper.getAllGridData()[i].rejectReason);
		}
		 
		
	    var frm = $("#frmMain");
	    frm.addParam("func", "IS");
	    frm.addParam("dataType", "json");
	    
	    frm.addParam("grd2_check_value",grd_check_value);
	    frm.addParam("grd2_reduction_code",grd_reduction_code);
	    frm.addParam("grd2_red_exp_date",'99991231');
	    frm.addParam("grd2_car_no",grd_car_no);
	    frm.addParam("grd2_file_rel_key",grd_file_rel_key);
	    frm.addParam("grd2_reject_reason",grd_reject_reason);
	    frm.addParam("processGubn","car");
	    
	    frm.addParam("hApplyCode",$("#hApplyCode").val());
	    frm.addParam("hMemberId",$("#hMemberId").val());
	    frm.setAction("<c:url value='/reduction/popupUpdate.do' />");
		frm.request();
	}
	
	function handleIS(data, textStatus, jqXHR) {
		if(data.count > 0){
    		window.close();
    		opener.loadTableData();
    	}
	}
	
    function dataValidation() {
    	var grid_data = _gridHelper.getAllGridData();
    	
		for(var i=0; i<grid_data.length; i++){
			if(grid_data[i].checkValue == "N" && grid_data[i].rejectReason == ""){
    			notifyDanger("차량 감면 거절사유를 입력해 주세요.");
    			return;
    		}else{
    			
    			if(grid_data[i].checkValue == "N" && grid_data[i].rejectReason === undefined){
    				notifyDanger("차량 감면 거절사유를 입력해 주세요.");
        			return;
    			}
    			
    		}
    	}
		
		saveData();
    }
    
	function checkValidDate(value) {
		var result = true;
		try {
		    var date = value.split("-");
		    var y = parseInt(date[0], 10),
		        m = parseInt(date[1], 10),
		        d = parseInt(date[2], 10);
		    
		    var dateRegex = /^(?=\d)(?:(?:31(?!.(?:0?[2469]|11))|(?:30|29)(?!.0?2)|29(?=.0?2.(?:(?:(?:1[6-9]|[2-9]\d)?(?:0[48]|[2468][048]|[13579][26])|(?:(?:16|[2468][048]|[3579][26])00)))(?:\x20|$))|(?:2[0-8]|1\d|0?[1-9]))([-.\/])(?:1[012]|0?[1-9])\1(?:1[6-9]|[2-9]\d)?\d\d(?:(?=\x20\d)\x20|$))?(((0?[1-9]|1[012])(:[0-5]\d){0,2}(\x20[AP]M))|([01]\d|2[0-3])(:[0-5]\d){1,2})?$/;
		    result = dateRegex.test(d+'-'+m+'-'+y);
		} catch (err) {
			result = false;
		}    
	    return result;
	}
    
	function checkDate(_obj) {
        const index = _obj[0].__selecetedRowIndex;
        const row = _obj[0].getGridRowData(index);
        const api = _obj[0].__gridOption.api;
        const gridHelper = _obj[0];
		
        if(row.redExpDate !== undefined && row.redExpDate != ""){
        	var reg_date = moment(row.redExpDate).format("YYYY-MM-DD");
        	if(row.rejectReason == "" || row.rejectReason === undefined){
        		if(checkValidDate(reg_date)){
           			gridHelper.setGridData(index, "checkValue", "Y");	
           			gridHelper.setGridData(index, "redExpDate", reg_date);	
            	}else{
            		alert("감면유효기간 날짜 형식을 확인해 주세요.(ex.2023-01-01)");
            		gridHelper.setGridData(index, "checkValue", "N");
            		gridHelper.setGridData(index, "redExpDate", "");
            		return;
           		}	
        	}else{
        		gridHelper.setGridData(index, "rejectReason", "");
        	}
        }
    } 
	
	function reject(_obj) {
		const index = _obj[0].__selecetedRowIndex;
        const row = _obj[0].getGridRowData(index);
        const api = _obj[0].__gridOption.api;
        const gridHelper = _obj[0];
        
        if(row.redExpDate != ""  && row.rejectReason !== undefined){
        	gridHelper.setGridData(index, "checkValue", "N");
        }
	}
	
	function checking(_obj) {
		const index = _obj[0].__selecetedRowIndex;
        const row = _obj[0].getGridRowData(index);
        const api = _obj[0].__gridOption.api;
        const gridHelper = _obj[0];
        
        if(row.checkValue == "Y"){
        	gridHelper.setGridData(index, "rejectReason", "");	
        }
	}
	
	$(function(){
		
		var eGridDiv = document.querySelector('#myGrid');
		new agGrid.Grid(eGridDiv, gridOptions);
				
		$("#btnApproval").click(function() {
			if(confirm("승인하시겠습니까?")){
				dataValidation();	
			}
		});
		
		$("#btnClose").click(function() {				
			self.close();
		});
		
		$("#btnzoomIn").click(function() {				
			$("#image").trigger("click");
		});
		 
		$(window).on("resize", function() {     
			$("#myGrid").css("height", $(this).height() - 230);
		}); 
		
		gridOptions.api.setRowData([]);
		gridOptions.setOriginalData([]);
		
		$(window).trigger("resize");
		$(".ag-body-horizontal-scroll").remove();
		
		loadTableData();
	});

</script>


<div class="page-body" style="font-size: 0.9em;">
	<div class="row">
		<div class="col-xl-6 col-lg-6 col-md-6 col-sm-6 col-6">
			<card:open title="신청 정보" />
			<card:button>
			</card:button>
			<card:content />
			<form id="frmMain" name="frmMain" method="post" onsubmit="return false" class="form-horizontal" >
				<form:input id="hApplyCode" type="hidden" value="${param.apply_code}" />
				<form:input id="hMemberId" type="hidden" value="${param.member_id}" />
			</form>
			<form:grid id="myGrid" style="margin-top:10px"/>
			<card:close />
		</div>
		<div class="col-xl-6 col-lg-6 col-md-6 col-sm-6 col-6">
			<div class="card"> 
			    <div class="card-header"> 
			        <h5>파일 정보</h5> 
				</div>    
				<div class="card-block table-border-style"> 
					<a href="<c:url value='/images/no_img.jpg'/>" id="image" data-fancybox="" data-small-btn="true" data-width="1150" data-height="1365">  
						<img src="<c:url value='/images/no_img.jpg'/>" alt="logo2.png" style="height:650px; width:740px; margin-bottom: 15px; border: 1px solid #eee; border-radius: 22px;">
					</a>
					<a href="<c:url value='/images/no_img.jpg'/>" id="iframe" data-fancybox="" data-small-btn="true" style="display:none;" data-options='{"type" : "iframe", "iframe" : {"preload" : false, "css" : {"width" : "800px","height" : "800px"}}}'></a>
					<div class="text-right">
						<button type="button" id="btnzoomIn" class="btn btn-sm waves-effect waves-light btn-info btn-outline-info default text-right"> 
						    <span class="fa fa-search-plus"></span> 
						    &nbsp;크게보기
						</button> 
					</div>  
				</div> 
			</div>
		</div>
	</div>
	
	<div class="row padding-left-5 padding-right-5">
		<div class="bottom-btn-area">
			<div class="col-xl-6 col-lg-6 col-md-6 col-sm-12 col-12"></div>
			<div class="col-xl-6 col-lg-6 col-md-6 col-sm-12 col-12 text-right">
				<form:button type="Approval" id="btnApproval" />
				<form:button type="Close" id="btnClose" />
			</div>
			<label:clear />
		</div>
	</div>
</div>