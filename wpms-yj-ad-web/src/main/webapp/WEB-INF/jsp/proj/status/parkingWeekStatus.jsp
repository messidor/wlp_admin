<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="form" uri="http://ad.its.yeongju.kr/jsp/jstl/form"%>
<%@ taglib prefix="card" uri="http://ad.its.yeongju.kr/jsp/jstl/card"%>
<%@ taglib prefix="func" uri="http://ad.its.yeongju.kr/jsp/jstl/func"%>
<%@ taglib prefix="label" uri="http://ad.its.yeongju.kr/jsp/jstl/label" %>

<%@ include file="../../core/include/head.jsp"%>
<%@ include file="../../core/include/header.jsp"%>

<script type="text/javascript">



	function loadTableData() {

		var searchDate = $("#kMonthDate").val();
		var day = "";
		var endDay = "";
		var WeekArray = ['일요일','월요일','화요일','수요일','목요일','금요일','토요일'];
		
		/*for(var i=1; i<=7; i++){
			
			WeekArray.push(i);
		}*/
		
	    var frm = $("#frmMain");
	    //---- 그리드 조회 시 필수요소 start
	    //---- 그리드 조회 시 필수요소 end
		frm.addParam("func", "IQ");
	    frm.addParam("query_id", "status.parkingWeekStatus.select_parkWeekStatusList");
		frm.addParam("kYearDate", $("#kYearDate").val());
	    frm.addParam("kMonthDate", $("#kMonthDate").val());
	    frm.addParam("kWeekArr", WeekArray);
	    frm.addParam("dataType", "json");           // 그리드 불러오는 타입 (기본 json)
		frm.request();
	}

	function handleIQ(data, textStatus, jqXHR) {
		if(data.length > 0) {
			var inArray = [];
    		var outArray = [];
    		var maxArray = [];
 	        var useLabelArray = [];

 			for(var key in data[0]){
	        	if(data[0].hasOwnProperty(key)){
	        		if(key != "parkingName"){
						useLabelArray.push(key);
					}
					if(key != "parkingName"){
						inArray.push(data[0][key]);
					}
	            }
	        }
 			
 			for(var key in data[1]){
	        	if(data[1].hasOwnProperty(key)){
					
					if(key != "parkingName"){
						outArray.push(data[1][key]);
					}
	            }
	        }
 		
         	
 			var chart_func = $("#chart").data("chart_func");
			var chart = $("#chart").data("chart_obj");
			chart.data.datasets = [];

	        chart.data.datasets.push({
	            label: '입차',
	            borderColor: '#bcb7b0',
	            backgroundColor: "#bcb7b0",
	            data: inArray,
	            type: 'bar',
	            pointBackgroundColor: '#bcb7b0',
            	pointRadius: 3,
            	borderWidth : 2 
	        },{
	            label: '출차',
	            borderColor: '#a4b3c1',
	            backgroundColor: "#a4b3c1",
	            data: outArray,
	            type: 'bar',
	            pointBackgroundColor: '#a4b3c1',
            	pointRadius: 3,
            	borderWidth : 2 
	        });
	        
	       
	        chart.data.labels = useLabelArray;
	        /* chart.options.plugins.datalabels.formatter = function(value, context) {return null;} */
	        
	        chart.options.tooltips.callbacks = {
		            label: function(tooltipItem, data) {
		            	var str = "";
		            	var str_arr = "";
		            	if(data.datasets[tooltipItem.datasetIndex].data[tooltipItem.index].toString().includes(".")){
		            		str_arr = data.datasets[tooltipItem.datasetIndex].data[tooltipItem.index].toString().split(".")
		            		str = str_arr[0].replace(/\B(?=(\d{3})+(?!\d))/g, ",") + "." + str_arr[1]
		            	}else{
		            		str = data.datasets[tooltipItem.datasetIndex].data[tooltipItem.index].toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",")
		            		// 퍼센트가 정수일경우에도 소수점 둘째자리까지 표시 (50.00%)
		            		str = (Math.round(str*100)/100).toFixed(2);
		            	}
	                	return data.datasets[tooltipItem.datasetIndex].label + ': ' + str + '%'
	                },
			};
        		
	        chart.options.scales.yAxes[0].ticks = {
       				beginAtZero: true,
               		minTicksLimit: 5,
               		maxTicksLimit: 5,
	        		callback: function(value, index) {
	        			return value.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",")
	                }
    		};
	        chart.options.animation.duration = 700;
	        chart.options.legend = {
	                "display": "useLegend",
	                "position":'bottom'
    	    };

	        chart_func.update();
		}else{
			
			var chart_func = $("#chart").data("chart_func");
			var chart = $("#chart").data("chart_obj");
			chart.data.datasets = [];
			
			chart.options.scales.yAxes[0].ticks = {
       				beginAtZero: true,
               		minTicksLimit: 5,
               		maxTicksLimit: 5,
	        		callback: function(value, index) {
	        			return value.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",")
	                }
    		};
			
			chart_func.update();
		}
	}

	function chartInitialize() {
		
	 	g_chart = $("#chart").chartHelper({
	        type: "bar",        // 바 차트
	        data: [],           // 데이터
	        label: ["일요일", "월요일", "화요일", "수요일", "목요일", "금요일", "토요일"],          // 라벨
	        backgroundColor: 'rgba(237, 134, 117, 0.2)',
	        borderColor: 'rgba(237, 134, 117, 1)',
	        tooltip: true,
	        borderWidth: 1,
	        pointRadius: 0,
	        lineTension: 0,
	        fill:false,
	    });
	 	var chart_func = $("#chart").data("chart_func");
		var chart = $("#chart").data("chart_obj");
	 	chart.data.datasets = [];
		
		chart.options.scales.yAxes[0].ticks = {
   				beginAtZero: true,
   				suggestedMax: 100,
           		stepSize : 20,
           		minTicksLimit: 5,
        		callback: function(value, index) {
        			return value.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",")
                }
		};
		
		chart_func.update();
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
		$("#kParkingNo option[value!='']").remove();
		
		if(data.length > 0){
			$("#kParkingNo").parent().parent().show();
			$.each(data, function(k, v) {
				$("#kParkingNo").append("<option value='" + v.value + "'>" + v.text + "</option>");			
			});
		}else{
			$("#kParkingNo").parent().parent().show();
		}
		
		loadTableData()
	}
	
	function chartMaxVal(valArr){
    	var maxVal = Math.max.apply(null, valArr);
    	
    	// ex) val = 1470
    	// 1. 1479의 length는 4 => 10^(4-1) => 10의 3승이므로 1000
    	// 2. 1479 / 1000 = 1.479 => 2
    	// 3. 2 * 1000 = 2000
    	// 4. 1500이 1470 보다 크면 1500을 리턴 아니면 2000을 리턴 => 맥스값 근사치를 구하기 위함
    	
    	// ex) val = 1780
    	// 1. 1780의 length는 4 => 10^(4-1) => 10의 3승이므로 1000
    	// 2. 1479 / 1000 = 1.78 => 2
    	// 3. 2 * 1000 = 2000
    	// 4. 1500이 1780 보다 크면 1500을 리턴 아니면 2000을 리턴 => 맥스값 근사치를 구하기 위함
    	
    	const powVal = Math.pow(10, parseInt(maxVal.toString().length - 1));	// 1. length 만큼 데이터 get
    	const ceilVal = Math.ceil(maxVal / powVal);								// 2. 자릿수 만큼 올림처리
    	const multiVal = ceilVal * powVal;										// 3. y축 최대 자릿수 구하기
    	
    	// 한자리수일 경우 계산하지 않고 5 또는 10리턴
    	if(powVal == 1){
    		if(5 > maxVal){
    			return 5;	
    		}else{
    			return 10;
    		}
    	}
    	if(multiVal - (powVal / 2) > maxVal){
    		return multiVal - powVal / 2;										// 4. powVal / 2 만큼 뺀 값이 최대값보다 크면 뺀 값을 return
    	}else{
    		return multiVal;
    	}
    }
	
	function downExcelData() {
		var frm = $("#frmHidden");
		
		var searchDate = $("#kMonthDate").val();
		var day = "";
		var WeekArray = ['일요일','월요일','화요일','수요일','목요일','금요일','토요일'];

		for(var i=0; i<WeekArray.length; i++){
			day = WeekArray[i];
			frm.append("<input type='hidden' name='kWeekArr[]' value='" + (day) + "' />");
		}
		
		frm.addInput("func", "IQ_Excel");
		frm.addInput("kYearDate", $("#kYearDate").val());
	    frm.addInput("kMonthDate", $("#kMonthDate").val());
	    frm.addInput("kParkingGovCode", $("#kParkingGovCode").val());
	    frm.addInput("kParkingNo", $("#kParkingNo").val());
	    frm.addInput("kYearDate", $("#kYearDate").val());
	    frm.addInput("kMonthDate", $("#kMonthDate").val());
	    frm.addInput("kMemberYn", $("#kMemberYn").val());
	    frm.addInput("parkingGovName", $("#kParkingGovCode option:checked").text());
	    frm.addInput("parkingName", $("#kParkingNo option:checked").text());
		frm.addInput("memberYnName", $("#kMemberYn option:checked").text());
	    frm.addInput("query_id", "status.parkingWeekStatus.select_parkWeekStatusExcel");
		frm.addInput("type", "parkingWeekStatus");
		frm.setAction("<c:url value='/common_excel.do'/>");
		frm.removeAttr("onsubmit");
		frm.submit();
		frm.setAction("<c:url value='/common_select.do'/>");
	}

	function handleIQ_Excel(data, textStatus, jqXHR) {}
	
	$(function() {
		let date = new Date();
		let month = ((date.getMonth()+1) < 9 ? "0" + (date.getMonth()+1) : (date.getMonth()+1)) ;
		// let month = String(new Date().getMonth()+1).padStart(2, '0');

		//일자
		$("#kYearDate").initDateSingle("year");

     	// 조회
        $("#kYearDate, #kMonthDate").change(function(){
        	//chartInitialize();
        	loadTableData();
        });

        // 조회
        $("#btnSearch").click(function(){
        	//chartInitialize();
        	loadTableData();
        });

        var height = $("#mCSB_1_container_wrapper").outerHeight() - 337;

		$(".card-block").eq(2).css("padding-bottom","0px");
		$(".card-header").eq(2).css("padding-bottom","0px")
		$("canvas").width("100%");
		$("canvas").height(height);

		$("#kYearDate, #kMonthDate, #kLocalGubn, #kMemberYn").on("change", function(e) {
			loadTableData();
		});
		
		$("#kMonthDate").val(month);
		
		$("#kParkingGovCode").change(function() {
			loadComboData();
		});

		$("#kParkingNo").change(function() {
			loadTableData();
		});
		
		// 다운로드
		$("#btnExcel").click(function(){
			if($("#kParkingNo").val() == ""){
				alert("주차장을 선택해주세요");
			}else{
				downExcelData();				
			}
		});
		
        chartInitialize();
        loadComboData();
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
					<form:select id="kParkingGovCode" caption="관리기관" all="false" allLabel="선택" queryId="select.select_parkingGovInfo"/>
					<form:select id="kParkingNo" caption="주차장" all="false" allLabel="선택" queryId="select.select_parkingInfo"/>  
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
			<card:open title="주차장별 이용 현황" />
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
