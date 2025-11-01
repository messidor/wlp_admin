<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="func" uri="http://ad.its.yeongju.kr/jsp/jstl/func" %>
<%@ taglib prefix="form" uri="http://ad.its.yeongju.kr/jsp/jstl/form" %>
<%@ taglib prefix="label" uri="http://ad.its.yeongju.kr/jsp/jstl/label" %>
<%@ taglib prefix="card" uri="http://ad.its.yeongju.kr/jsp/jstl/card" %>

<%@ include file="../../core/include/head.jsp" %>
<%@ include file="../../core/include/header.jsp" %>

<style type="text/css">
</style>

<script type="text/javascript">

	var g_Calendar;
	
	// 휴일 드래그 앤 드랍 이벤트
	function checkUpdateSchedule(info) {
		// info.event.date : 일자 (YYYY-MM-DDTHH:mi:ss+09:00 의 형식으로 되어 있음)
		// info.event.name : 주차장
		// info.event.remark : 내용
		// info.event.id : 식별자 ID (이 화면에서는 train_code)

		if(!confirm("일정을 변경하시겠습니까?\n\n"
			+ "내용 : " + info.event.extendedProps.remark + "\n"
			+ "시작일자 : " + moment(info.event.start).format("YYYY-MM-DD") + "\n"
			+ "종료일자 : " + moment(info.event.end).format("YYYY-MM-DD") + "\n"
			+ "주차장 : " + info.event.extendedProps.parkname)) {

			info.revert();
			return;
		}

		saveData(info);
	}
	
	// 저장 함수
	function saveData(p_Info) {
		var frm = $("#frmModal");
		frm.addParam("func", "IS");
		frm.addParam("query_id", "park.parkingHolidayManage.update_holidayManage");
		frm.addParam("dataType", "json");
		frm.addParam("hPopupKey", p_Info.event.id);
		frm.addParam("startDate", moment(p_Info.event.start).format("YYYYMMDD"));
		frm.addParam("endDate", moment(p_Info.event.end).format("YYYYMMDD"));
		frm.addParam("hPopupName", p_Info.event.extendedProps.name);

		if(p_Info.event.extendedProps.allday == "Y"){
            frm.addParam("hPopupRepeat", "Y");
        }else{
            frm.addParam("hPopupRepeat", "N");
        }
		
		frm.addParam("kPopupRemark", p_Info.event.extendedProps.remark);
		
		frm.addParam("enc_col", "userId");
		frm.request();
	}

	function handleIS(data, textStatus, jqXHR) {
		g_Calendar.refetchEvents();
	}

	// 팝업 저장 함수
	function saveData2() {
		var frm = $("#frmModal");
		frm.addParam("func", "IS2");
		frm.addParam("dataType", "json");
		
		if($("#hPopupKey").val() == ""){
			frm.addParam("query_id", "park.parkingHolidayManage.insert_holidayManage");
			frm.addParam("startDate", moment($("#popupStartDate").val()).format("YYYYMMDD"));
			frm.addParam("startTime", $("#popupStartH").val() + $("#popupStartM").val());
			frm.addParam("endDate", moment($("#popupEndDate").val()).format("YYYYMMDD"));
			frm.addParam("endTime", $("#popupEndH").val() + $("#popupEndM").val());
			frm.addParam("hPopupName", $("#popupName").val());
			frm.addParam("hPopupRepeat", $("#popupRepeat").val());
			frm.addParam("kPopupRemark", $("#popupRemark").val());
		}else{
			frm.addParam("query_id", "park.parkingHolidayManage.update_holidayManage");
			frm.addParam("hPopupKey", $("#hPopupKey").val());
			frm.addParam("startDate", moment($("#popupStartDate").val()).format("YYYYMMDD"));
			frm.addParam("startTime", $("#popupStartH").val() + $("#popupStartM").val());
			frm.addParam("endDate", moment($("#popupEndDate").val()).format("YYYYMMDD"));
			frm.addParam("endTime", $("#popupEndH").val() + $("#popupEndM").val());
			frm.addParam("hPopupName", $("#popupName").val());
			frm.addParam("hPopupRepeat", $("#popupRepeat").val());
			frm.addParam("kPopupRemark", $("#popupRemark").val());
		}
		frm.addParam("enc_col", "userId");
		
		frm.request();
	}

	function handleIS2(data, textStatus, jqXHR) {
		$("#modalHoliday").modal('hide');

		g_Calendar.refetchEvents();
	}

	// 팝업 삭제 함수
	function deleteData(p_Info) {
		var frm = $("#frmModal");
		frm.serializeArrayCustom();
		frm.addParam("func", "DL");
		frm.addParam("query_id", "park.parkingHolidayManage.delete_holidayManage");
		frm.addParam("dataType", "json");
		frm.addParam("hPopupKey", $("#hPopupKey").val());
		frm.addParam("hPopupName", $("#popupName").val());
		frm.addParam("enc_col", "userId");
		frm.request();
	}

	function handleDL(data, textStatus, jqXHR) {
		$("#modalHoliday").modal('hide');

		g_Calendar.refetchEvents();
	}
	
	// 날짜 자체 클릭 이벤트
	function calendarOnClick(info) {
		// 모달 띄움
		$("#modalHoliday").modal('show');
		// 휴일 코드
		$("#hPopupKey").val("");
        // 주차장
        $("#hPopupName").val("");
        // 반복여부
        $("#hPopupRepeat").val("");
		// 삭제버튼
		$("#btnDelete").hide();
		
		$("#popupStartDate").data('daterangepicker').setStartDate(info.date);
        $("#popupStartDate").data('daterangepicker').setEndDate(info.date);
        $("#popupEndDate").data('daterangepicker').setStartDate(info.date);
        $("#popupEndDate").data('daterangepicker').setEndDate(info.date);
        $("#popupStartH, #popupStartM, #popupEndH, #popupEndM").val("");
        loadComboData();
        
		$("#popupRemark").val("");
		$("#popupRemark").removeClass("fill");
		$("#modalTitle").text("일정등록");
		
		// $("#popupName").val("").prop("selected", true);
		$("#popupRepeat").val("N").prop("selected", true);
	}

	// 일정 클릭 후의 함수
	function eventClickFunction(info) {
		// info.event.id 가 키값임 (쿼리에서 키값을 id 로 조회했으므로...)
		// info.event.id, info.event.start, info.event.end 를 제외한 나머지 값은 info.event.extendedProps 에 있음
		// 예) comp_code ==> info.event.extendedProps.comp_code

		if(info.event.id != ""){
			//값 세팅
			$("#hPopupKey").val(info.event.id);
			$("#hPopupName").val(info.event.extendedProps.name);
			$("#hPopupRepeat").val(info.event.extendedProps.allday);

			$("#popupStartDate").data('daterangepicker').setStartDate(info.event.start);
			$("#popupStartDate").data('daterangepicker').setEndDate(info.event.start);
			
			let endDate = new Date(info.event.extendedProps.hDateEnd);
	        $("#popupEndDate").data('daterangepicker').setStartDate(endDate);
	        $("#popupEndDate").data('daterangepicker').setEndDate(endDate);
	        $("#popupStartH").val(info.event.extendedProps.startH);
	        $("#popupStartM").val(info.event.extendedProps.startM);
	        $("#popupEndH").val(info.event.extendedProps.endH);
	        $("#popupEndM").val(info.event.extendedProps.endM);
	        
			$("#kParkingGovCode").val(info.event.extendedProps.pGovCode);
			loadComboData();
			$("#popupRemark").val(info.event.extendedProps.remark);
			$("#popupRemark").addClass("fill");
			$("#modalTitle").text("일정수정");
			
			if(info.event.extendedProps.allday == "Y"){
	            $("#popupRepeat").val("Y").prop("selected", true);
	        } else {
	            $("#popupRepeat").val("N").prop("selected", true);
	        }
		}
		
		$("#btnDelete").show();
		$("#modalHoliday").modal('show');
	}

	function loadComboData() {
		var frm = $("#frmMain");
		frm.addParam("func", "IQCombo");
		frm.addParam("kParkingGovCode", $("#kParkingGovCode").val());
		frm.addParam("queryId", "select.select_parkingInfo2");
		frm.addParam("afterAction", false);
		frm.request();
	}
	
	function handleIQCombo(data, textStatus, jqXHR) {
		$("#popupName option[value!='']").remove();
		$.each(data, function(k, v) {
			$("#popupName").append("<option value='" + v.value + "'>" + v.text + "</option>");			
		});
		
		if($("#hPopupName").val() != ''){
			$("#popupName").val($("#hPopupName").val());
		}
		
	}
	
	function loadComboData2() {
		var frm = $("#frmMain");
		frm.addParam("func", "IQCombo2");
		frm.addParam("kParkingGovCode", $("#kParkingGovCode").val());
		frm.addParam("queryId", "index.index.select_parkInfo");
		frm.addParam("afterAction", false);
		frm.request();
    }

    function handleIQCombo2(data, textStatus, jqXHR) {
    	if(data.length > 0){
    		var item = "";
    		
    		$("#kParkingNo").children().remove();
    		
    		item += "<option value=''>전체</option>"
    		
    		for(var i=0; i<data.length; i++){
    			item += "<option value='" + data[i].value + "'>" + data[i].text + "</option>";
    		}
    		
    		$("#kParkingNo").append(item);
    		
    	}
    }


	$(function() {
		if(!g_UserRoleIdAry.includes("AD") && !g_UserRoleIdAry.includes("MANAGE")){
			$("#kParkingGovCode").parent().parent().parent().hide();
		}
		
        // 시간, 분 select 생성
        var html = "";
        for(var i=0; i<24; i++){
        	if(i<10){
        		html += "<option value='" + "0"+i + "'>" + i + "</option>";
        	} else {
        		html += "<option value='" + i + "'>" + i + "</option>";
        	}
        }
        $("#popupStartH, #popupEndH").append(html);
        
        html = "";
        for(var i=0; i<6; i++){
        	if(i<1){
        		html += "<option value='" + "0"+ i*10 + "'>" + i*10 + "</option>";
        	} else {
        		html += "<option value='" + i*10 + "'>" + i*10 + "</option>";
        	}
        }
        $("#popupStartM, #popupEndM").append(html);
        
        var params = {
      	        "kParkingNo" : function(){return $("#kParkingNo").val();}
      	    };
		// 파라미터 : 순서대로
		// 아이디, 조회 쿼리 아이디, 최초 표시할 일자, 편집 사용 여부, 드래그 앤 드랍 이벤트 함수, 시간표시 여부(true/false),
		// 일자 클릭 함수, 일정 클릭 함수, 일정 크기 조정 후의 함수
		g_Calendar = $("#fullCalendar").setFullCalendar("#fullCalendar"
													, "park.parkingHolidayManage.select_holidaylist"
													, moment().format("YYYY-MM-DD")
													, true
													, false
													, checkUpdateSchedule
													, false
													, calendarOnClick
													, eventClickFunction
													, false
													, params);
	
		var card_height = $("#mCSB_1_container_wrapper").outerHeight() - $(".card").parent().outerHeight() -80;
        g_Calendar.setOption('height', card_height);
        
	
	 	// 팝업에서 일자 입력 가능하게 처리
		$("#popupStartDate, #popupEndDate").initDateOnly("d", 0);

		$("#btnDelete").hide();

		$("#kParkingGovCode").change(function() {
			$("#hPopupName").val("");
			loadComboData();
		});
		
	 	// 삭제
		$("#btnDelete").click(function() {
			if(confirm("삭제한 일정은 되돌릴 수 없습니다.\n\n정말 삭제하시겠습니까?")) {
				deleteData();
			}
		});
	 	
		$("#btnModalSave").click(function() {
			let start = $("#popupStartDate").val().replaceAll("-", "") + $("#popupStartH").val() + $("#popupStartM").val();
			let end = $("#popupEndDate").val().replaceAll("-", "") + $("#popupEndH").val() + $("#popupEndM").val();
        	
			if($("#popupStartH").val() == ""){
				notifyDanger("시작시간을 선택해 주세요.");
				return;
			}
			
			if($("#popupStartM").val() == ""){
				notifyDanger("시작시간을 선택해 주세요.");
				return;
			}
			
			if($("#popupEndH").val() == ""){
				notifyDanger("종료시간을 선택해 주세요.");
				return;
			}
			
			if($("#popupEndM").val() == ""){
				notifyDanger("종료시간을 선택해 주세요.");
				return;
			}
			
			// 시작/종료 시간 비교
			if(start == end){
				notifyDanger("시작일시와 종료일시가 같을 수 없습니다.");
        		return;
        	} else if(start > end){
        		notifyDanger("시작일시가 종료일시보다 클 수 없습니다.");
    			return;
        	}
			
			
			if($("#popupName").val() == ""){
				notifyDanger("주차장을 선택해 주세요.");
				return;
			}

			saveData2();
		});
		
		$("#btnModalClose").click(function() {
			$("#modalHoliday").modal('hide');
		});
		
		$("#kParkingNo").change(function() {
			g_Calendar.refetchEvents();
		});
		
		loadComboData2();
	});
</script>

<div class="page-body" style="font-size:0.9em;">
	<div class="select_wrap">
		<div class="card">
			<div class="select_ctn">
				<div class="select_cont">
					<form id="frmMain" name="frmMain" method="post" onsubmit="return false" class="form-material form-inline">
					<label for="kParkingNo">주차장</label>
					<select name="kParkingNo" id="kParkingNo" class="select">
					</select>
					</form>
				</div>
			</div>
		</div>
	</div>
	
    <div class="row">

        <div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12">
            <div class="card">
            	
                <div class="card-block table-border-style">
                    <div id="fullCalendar"></div>
                </div>
            </div>
		</div>
    </div>
</div>

<!-- 일정 등록 모달 팝업 -->
<div class="modal fade" id="modalHoliday" tabindex="-1" role="dialog" aria-labelledby="modalEdit" style="position: fixed;" data-backdrop="static" data-keyboard="false">
	<div class="modal-dialog" role="document" style="max-width: 650px;">
		<div class="modal-content">
			<div class="modal-header">
				<h5 id="modalTitle" class="modal-title">일정</h5>
			</div>
			<div class="modal-body">
				<div class="row">
					<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12">
						<form id="frmModal" name="frmModal" method="post" onsubmit="return false" class="form-horizontal">
							<form:input id="hPopupKey" type="hidden" caption="" />
							<form:input id="hPopupRepeat" type="hidden" caption="" />
							<form:input id="hPopupName" type="hidden" caption="" />
							
							<label:input id="popupStartDate" size="12" caption="시작일자" stateIcon="fas fa-pencil-alt" className="danger"/>
							
							<div class="form-group col-xl-12 col-lg-12 col-md-12 col-sm-12 no-margin no-padding has-danger"> 
	                            <label class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right">시작시간</label> 
	                            <div class="col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached"> 
	                                <div class="input-group"> 
	                                    <span class="input-group-addon"><i class="fas fa-bars" data-icon="fas fa-bars"></i></span>
	                                    <select name="popupStartH" id="popupStartH" class="form-control selectpicker col-6"> 
	                                        <option value="">선택</option> 
	                                    </select>
	                                    <select name="popupStartM" id="popupStartM" class="form-control selectpicker col-6"> 
	                                        <option value="">선택</option> 
	                                    </select> 
	                                </div> 
	                            </div> 
							</div>
							
							<label:input id="popupEndDate" size="12" caption="종료일자" stateIcon="fas fa-pencil-alt" className="danger"/>
							
							<div class="form-group col-xl-12 col-lg-12 col-md-12 col-sm-12 no-margin no-padding has-danger"> 
	                            <label class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right">종료시간</label> 
	                            <div class="col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached"> 
	                                <div class="input-group"> 
	                                    <span class="input-group-addon"><i class="fas fa-bars" data-icon="fas fa-bars"></i></span>
	                                    <select name="popupEndH" id="popupEndH" class="form-control selectpicker col-6"> 
	                                        <option value="">선택</option> 
	                                    </select>
	                                    <select name="popupEndM" id="popupEndM" class="form-control selectpicker col-6"> 
	                                        <option value="">선택</option> 
	                                    </select> 
	                                </div> 
	                            </div> 
							</div>
							
							<label:select id="kParkingGovCode" size="12" caption="관리기관" all="false" allLabel="전체" queryId="select.select_parkingGovInfo" className="danger"/>
							<label:select id="popupName" size="12" caption="주차장" all="false" allLabel="전체" className="danger" queryId="select.select_parkingInfo"/>
							<%--<label:select id="popupRepeat" size="12" caption="반복" queryId="#repeat_yn" className="danger"/> --%>
							<input type="hidden" id="popupRepeat" value="N">
							<label:textarea id="popupRemark" size="12" caption="내용" stateIcon="fas fa-pencil-alt" addAttr="maxlength='64'"/>
						</form>
						<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12 text-right">
                        <button type="button" id="btnModalSave" name="btnModalSave" class="btn btn-sm waves-effect waves-light btn-success btn-outline-success"><span class="icofont icofont-check"></span>저장</button>
                        <button type="button" id="btnDelete" name="btnDelete" class="btn btn-sm waves-effect waves-light btn-danger btn-outline-danger"><span class="icofont icofont-close"></span>삭제</button>
                        <button type="button" id="btnModalClose" name="btnModalClose" class="btn btn-sm waves-effect waves-light btn-warning btn-outline-warning"><span class="icofont icofont-close"></span>닫기</button>
                    </div>
					</div>
				</div>
			</div>
		</div>
	</div>
</div>

<%@ include file="../../core/include/footer.jsp"%>
