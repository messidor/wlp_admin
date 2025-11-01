<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="form" uri="http://ad.its.yeongju.kr/jsp/jstl/form"%>
<%@ taglib prefix="card" uri="http://ad.its.yeongju.kr/jsp/jstl/card"%>
<%@ taglib prefix="func" uri="http://ad.its.yeongju.kr/jsp/jstl/func"%>
<%@ taglib prefix="label" uri="http://ad.its.yeongju.kr/jsp/jstl/label" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%@ include file="../../core/include/head.jsp"%>
<%@ include file="../../core/include/header.jsp"%>

<script type="text/javascript">



	function loadTableData() {

		var searchDate = $("#kMonthDate").val();
		var day = "";
		var endDay = "";
		var dayArray = [];

		// 윤달체크
		if($("#kMonthDate").val() != '02'){
			var date = new Date($("#kYearDate").val(), $("#kMonthDate").val());
			date = new Date(date - 1);
			endDay = date.getDate();
		}else{
			if(($("#kYearDate").val()%4 == 0 && $("#kYearDate").val()%100 != 0) || $("#kYearDate").val()%400 == 0){
				endDay = 29;
			} else{
				endDay = 28;
			}
		}
		for(var i=0; i<endDay; i++){
			dayArray.push(i+1);
		}

	    var frm = $("#frmMain");
	    //---- 그리드 조회 시 필수요소 start
	    //---- 그리드 조회 시 필수요소 end
		frm.addParam("func", "IQ");
	    frm.addParam("query_id", "status.parkingStatus.select_parkStatusList");
		frm.addParam("kYearDate", $("#kYearDate").val());
	    frm.addParam("kMonthDate", $("#kMonthDate").val());
	    frm.addParam("kDayArr", dayArray);
	    frm.addParam("dataType", "json");           // 그리드 불러오는 타입 (기본 json)
		frm.request();
	}

	function handleIQ(data, textStatus, jqXHR) {
		if(data.length > 0) {

			var date = new Date();
			var year = date.getFullYear();
			var month= date.getMonth() +1;
			var day= date.getDate();
			var nowMonth = false;

			if($("#kYearDate").val() == year && $("#kMonthDate").val() == month){
				nowMonth = true;
			}


	        var labelArray = [];
	        var labelArray2 = [];
	        var colorArray = [];

	        for(var i=0; i<data.length; i++){
	        	var color_r = Math.floor(Math.random() * 127 + 128).toString(16);
	      	  	var color_g = Math.floor(Math.random() * 127 + 128).toString(16);
	      	  	var color_b = Math.floor(Math.random() * 127 + 128).toString(16);

	      	  	colorArray.push('#' + color_r + color_g + color_b)
	        }

	        var result = [];
	        var chart_func = $("#chart").data("chart_func");
			var chart = $("#chart").data("chart_obj");
	        chart.data.datasets = [];

	        for(var i=0; i<data.length; i++){

	        	var emisArray = [];
				var temp = 0;
				var cnt = 0;

	        	for(var key in data[i]){


		        	if(data[i].hasOwnProperty(key)){

						if(i == 0 && key != "parkingName"){
							labelArray2.push(key);
						}
						if(key != "parkingName"){
							/* if(nowMonth == true && cnt >= day){
								temp = 0;
							}else{
								temp += parseInt(data[i][key], 10);
							} 
							emisArray.push(temp);
							cnt++;
							*/
							emisArray.push(data[i][key]);
						}
		            }
		        }

	        	chart.data.datasets.push({
		            label: data[i].parkingName,
		            borderColor: colorArray[i],
		            backgroundColor: "#00ff0000",
		            data: emisArray,
		            type: 'line',
		            pointStyle : 'circle',
		            borderWidth: 2,
		            pointRadius: 2,
		            lineTension: 0
		        });

	        }

	        chart_func.changeLabel(labelArray2);

	        chart.options.plugins.datalabels = {
        		display: false,
                color: ['#000', '#000', '#000', '#000'],
                borderWidth: 2,
                font:{size:8},
                borderRadius : 25,
                anchor: 'center'
	         };

	        chart.options.tooltips.callbacks = {
	            label: function(tooltipItem, data) {
	            	var str = "";
	            	var str_arr = "";
	            	if(data.datasets[tooltipItem.datasetIndex].data[tooltipItem.index].toString().includes(".")){
	            		str_arr = data.datasets[tooltipItem.datasetIndex].data[tooltipItem.index].toString().split(".")
	            		str = str_arr[0].replace(/\B(?=(\d{3})+(?!\d))/g, ",") + "." + str_arr[1]
	            	}else{
	            		str = data.datasets[tooltipItem.datasetIndex].data[tooltipItem.index].toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",")
	            	}
                	return data.datasets[tooltipItem.datasetIndex].label + ': ' + str
                },
			};

	        chart.options.tooltips.mode = 'point';

	        chart.options.scales.yAxes[0].ticks = {
        		stepSize : 20,
        		callback: function(value, index) {
        			return value.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",")
                }
			};
	        chart.options.animation.duration = 700;

	       chart.options.legend = {
	                "display": true,
	                "position":'right',
	                "align":'start',
	                title: {
	                	position : 'start',
	                },
	                labels: {
                    	usePointStyle: false,
                    }
    	    };

	        chart_func.update();

		}else{

			g_chart = $("#chart").chartHelper({
		        type: "line",        // 바 차트
		        data: [],           // 데이터
		        label: [""],          // 라벨
		        backgroundColor: 'rgba(237, 134, 117, 0.2)',
		        borderColor: 'rgba(237, 134, 117, 1)',
		        tooltip: true,
		        borderWidth: 1,
		        pointRadius: 0,
		        lineTension: 0,
		        fill:false,
		    });
		}
	}

	function chartInitialize() {
	 	g_chart = $("#chart").chartHelper({
	        type: "line",        // 바 차트
	        data: [],           // 데이터
	        label: [""],          // 라벨
	        backgroundColor: 'rgba(237, 134, 117, 0.2)',
	        borderColor: 'rgba(237, 134, 117, 1)',
	        tooltip: true,
	        borderWidth: 1,
	        pointRadius: 0,
	        lineTension: 0,
	        fill:false,
	    });

		loadTableData();
	}
	
	function downExcelData() {
		var frm = $("#frmHidden");
		var searchDate = $("#kMonthDate").val();
		var day = "";
		var endDay = "";
		var dayArray = [];

		// 윤달체크
		if($("#kMonthDate").val() != '02'){
			var date = new Date($("#kYearDate").val(), $("#kMonthDate").val());
			date = new Date(date - 1);
			endDay = date.getDate();
		}else{
			if(($("#kYearDate").val()%4 == 0 && $("#kYearDate").val()%100 != 0) || $("#kYearDate").val()%400 == 0){
				endDay = 29;
			} else{
				endDay = 28;
			}
		}
		for(var i=0; i<endDay; i++){
			dayArray.push(i+1);
			frm.append("<input type='hidden' name='kDayArr[]' value='" + (i+1) + "' />");
		}
		
		frm.addInput("func", "IQ_Excel");
		frm.addInput("endDay", endDay);
		frm.addInput("kYearDate", $("#kYearDate").val());
	    frm.addInput("kMonthDate", $("#kMonthDate").val());
	    frm.addInput("kMemberYn", $("#kMemberYn").val());
	    frm.addInput("kParkingGovCode", $("#kParkingGovCode").val());
		frm.addInput("parkingGovName", $("#kParkingGovCode option:checked").text());
		frm.addInput("memberYnName", $("#kMemberYn option:checked").text());
		frm.addInput("query_id", "status.parkingStatus.select_excelList");
		frm.addInput("type", "parkingStatus");
		frm.setAction("<c:url value='/common_excel.do'/>");
		frm.removeAttr("onsubmit");
		frm.submit();
		frm.setAction("<c:url value='/common_select.do'/>");
	}

	function handleIQ_Excel(data, textStatus, jqXHR) {}

	$(function() {
		let date = new Date();
		let month = ((date.getMonth()+1) < 10 ? "0" + (date.getMonth()+1) : (date.getMonth()+1)) ;
		// let month = String(new Date().getMonth()+1).padStart(2, '0');

		//일자
		$("#kYearDate").initDateSingle("year");

     	// 조회
        $("#kYearDate, #kMonthDate").change(function(){
        	chartInitialize();
        });

        // 조회
        $("#btnSearch").click(function(){
        	chartInitialize();
        });

        var height = $("#mCSB_1_container_wrapper").outerHeight() - 337;

		$(".card-block").eq(2).css("padding-bottom","0px");
		$(".card-header").eq(2).css("padding-bottom","0px")
		$("canvas").width("100%");
		$("canvas").height(height);

		$("#kParkingGovCode, #kYearDate, #kMonthDate, #kLocalGubn, #kMemberYn").on("change", function(e) {
			loadTableData();
		});

		$("#kMonthDate").val(month);
		
		// 다운로드
		$("#btnExcel").click(function(){
			downExcelData();
		});

        chartInitialize();
	});
</script>


<div class="page-body" style="font-size: 0.9em;">
	<div class="row">
		<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12" id="search_all_wrapper">
			<card:open title="검색 조건" />
			<card:button>
				<form:button type="Search" id="btnSearch" />
				<form:button type="Excel" id="btnExcel" />
			</card:button>
			<card:content />
			<div class="search-area col-lg-12">
				<form id="frmMain" name="frmMain" method="post" onsubmit="return false" class="form-material form-inline">
					<form:input type="hidden" caption="hParkingNo" id="hParkingNo"/>
					<c:choose>
						<c:when test="${fn:contains(user_role_id, 'MANAGE') || fn:contains(user_role_id, 'AD')}">
							<form:select id="kParkingGovCode" caption="관리기관" all="true" allLabel="전체" queryId="select.select_parkingGovInfo"/>
						</c:when>
						<c:otherwise>
							<form:select id="kParkingGovCode" caption="관리기관" all="false" allLabel="전체" queryId="select.select_parkingGovInfo"/>
						</c:otherwise>
					</c:choose>
					<form:input id="kYearDate" caption="이용연도" addAttr="maxlength='100'" />
					<div class="col-xl-2 col-lg-2 col-md-12 col-sm-12 col-12">
		                <div class="form-group form-default form-static-label">
		                    <select name="kMonthDate" id="kMonthDate" class="form-control">
								<option value="01">1월</option>
								<option value="02">2월</option>
								<option value="03">3월</option>
								<option value="04">4월</option>
								<option value="05">5월</option>
								<option value="06">6월</option>
								<option value="07">7월</option>
								<option value="08">8월</option>
								<option value="09">9월</option>
								<option value="10">10월</option>
								<option value="11">11월</option>
								<option value="12">12월</option>
		                    </select>
		                    <label class="float-label select-label">이용월</label>
		                </div>
		            </div>
		            <form:select id="kMemberYn" caption="회원여부" all="true" allLabel="전체" queryId="#MEMBER_YN"/>
				</form>
				<form id="frmHidden" name="frmHidden" method="post" onsubmit="return false" class="form-material form-inline" style="display: none;">
				</form>
			</div>
			<card:close />
		</div>
		<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12" name="search_all_wrapper">
			<card:open title="주차장별 이용 현황 (입차기준)" />
			<card:content />
			<div class="search-area col-lg-12">
				<form id="frmMain" name="frmMain" method="post" onsubmit="return false" class="form-material form-inline">
				</form>
			</div>
            <div class="card-block table-border-style">
				<canvas id="chart" ></canvas>
			</div>
			<card:close />
		</div>
	</div>
</div>

<%@ include file="../../core/include/footer.jsp"%>
