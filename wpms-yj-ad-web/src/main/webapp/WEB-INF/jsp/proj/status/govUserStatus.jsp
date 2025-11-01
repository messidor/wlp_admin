<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="form" uri="http://ad.its.yeongju.kr/jsp/jstl/form"%>
<%@ taglib prefix="card" uri="http://ad.its.yeongju.kr/jsp/jstl/card"%>
<%@ taglib prefix="func" uri="http://ad.its.yeongju.kr/jsp/jstl/func"%>
<%@ taglib prefix="label" uri="http://ad.its.yeongju.kr/jsp/jstl/label"%>

<%@ include file="../../core/include/head.jsp"%>
<%@ include file="../../core/include/header.jsp"%>

<script type="text/javascript" src="<c:url value='/common/js/chartjs/Chartjs.plugin.datalabels.js'/>"></script>
<script type="text/javascript">
	var g_Chart1, g_Chart2, g_Chart3;

	//컬럼 옵션
	var columnDefs = [
		setColumn(["memberId", "아이디", "left", 100]),
		setColumn(["memberName", "이름", "center", 100]),
		setColumn(["carNo", "차량번호", "center", 100]),
		setColumn(["useCnt", "이용 건수", "right", 100])
	];
	
	var _gridHelper = new initGrid(columnDefs, true);
	var gridOptions = _gridHelper.setGridOption();

	function loadTableData() {
		var frm = $("#frmMain");
		//---- 그리드 조회 시 필수요소 start
		frm.addParam("result", $("#myGrid"));	   // 그리드 태그
		frm.addParam("grid", "gridOptions");		// 그리드 옵션
		//---- 그리드 조회 시 필수요소 end
		frm.addParam("func", "IQ");
		frm.addParam("kParkingGovCode", $("#kParkingGovCode").val());
		frm.addParam("kUseYear", $("#kUseYear").val());
        frm.addParam("kUseMonth", $("#kUseMonth").val());
		frm.addParam("query_id", "status.govUserStatus.select_govUserList");
		frm.addParam("dataType", "json");		   // 그리드 불러오는 타입 (기본 json)
		frm.request();
	}

	function handleIQ(data, textStatus, jqXHR) {
		var tHeight = ($("#mCSB_1_container_wrapper").innerHeight()) / 7 -35;
		$("#myGrid").height(tHeight);
   		$("#chart").remove();
       	$(".card-block").eq(2).append("<canvas id='chart' class='pieChart' height='" + $("#myGrid").height() + "'></canvas>");
		loadTableData2();
	}
	
	//이용현황 TOP5 차트
	function loadTableData2() {
        var frm = $("#frmMain");
		frm.addParam("func", "IQ2");
        frm.addParam("query_id", "status.govUserStatus.select_govUserChart");
        frm.addParam("kParkingGovCode", $("#kParkingGovCode").val());
        frm.addParam("kUseYear", $("#kUseYear").val());
        frm.addParam("kUseMonth", $("#kUseMonth").val());
        frm.addParam("dataType", "json");
		frm.request();
    }
	
	function handleIQ2(data, textStatus, jqXHR) {
		
		//$("#chart").remove();
    	//$(".card-block").eq(1).append("<canvas id='chart' ></canvas>");
    	//$("#chart").destroy();
    	

    	var ctx = document.getElementById("chart");
		var dataArrCnt = 0;
		var dataArr = [];
		var gubnArr = [];
		var bgColorArr = [];
		var txtColorArr = [];

		for(var i=0; i<data.length; i++){
			dataArr.push(data[i].percent);
			gubnArr.push(data[i].parkingName);
			dataArrCnt++;
		}

		if(dataArr.length > 0){
			bgColorArr = ["#20cbc2","#074d81","#3fb1e7","#ffac31","#5742cd"];
			txtColorArr = ["#000000","#000000","#000000","#000000","#000000"];
			
		}else{
			// 숫자 0을 넣을 경우 chart js가 그려지지 않음으로 1로 처리하여 datalabels에서 분기처리
			dataArr.push(1);
			gubnArr.push("이용 현황 없음");
			bgColorArr = ["#20cbc2"];
			txtColorArr = ["#000000"];
		}

		var chart = new Chart(ctx, {
   		    type: 'pie',
   		    data: {
   		        labels: gubnArr,
   		        datasets: [{
   		            data: dataArr,
   		            backgroundColor: bgColorArr,
   		            borderColor: bgColorArr,
   		            borderWidth: 1
   		        }]
   		    },
   		    options: {
   		        title: {
   		            display: false,
   		        },
   		        legend: {
	                "display": "useLengend",
	                "position":'right'
   		        },
	   		    plugins: {
	                 datalabels: {
	                	 formatter: (value) => {
	                         if (value < 15) return '';
	                         return value + '%';
	                     },
	                     color: 'white',
	                     font: {
                        	size: 10
                      	},
	                 },
	            },
	            

	            maintainAspectRatio: false,
	   	   	//	responsive: true,
	 	   	    tooltips: {
	 	   	      callbacks: {
	 	   	        label: function(tooltipItem, data) {
		 	   	        if(dataArrCnt > 0){
		 	   	        	var str = "";
			            	var str_arr = "";
			            	if(data.datasets[tooltipItem.datasetIndex].data[tooltipItem.index].toString().includes(".")){
			            		str_arr = data.datasets[tooltipItem.datasetIndex].data[tooltipItem.index].toString().split(".")
			            		str = str_arr[0].replace(/\B(?=(\d{3})+(?!\d))/g, ",") + "." + str_arr[1]
			            	}else{
			            		str = data.datasets[tooltipItem.datasetIndex].data[tooltipItem.index].toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",")
			            	}
		                	return data.labels[tooltipItem.index] + ': ' + str + '%'
	 	   	        	}
	 	   	        }
	 	   	      }
	 	   	    },
	 	   		aspectRatio: 1,

	   	    	showAllTooltips: true
   		    }
		});
		
		$("#chart2").height($("#chart").height());
		loadTableData3();
    }
	
	// 이용현황 차트
	function loadTableData3() {
		var searchDate = $("#kUseMonth").val();
		var day = "";
		var endDay = "";
		var dayArray = [];
		
		// 윤달체크
		if($("#kUseMonth").val() != '02'){
			var date = new Date($("#kUseMonth").val(), $("#kUseMonth").val());
			date = new Date(date - 1);
			endDay = date.getDate();
		}else{
			if(($("#kUseYear").val()%4 == 0 && $("#kUseYear").val()%100 != 0) || $("#kUseYear").val()%400 == 0){
				endDay = 29;
			} else{
				endDay = 28;
			}
		}
		for(var i=0; i<endDay; i++){
			dayArray.push(i+1);
		}
		
        var frm = $("#frmMain");
		frm.addParam("func", "IQ3");
        frm.addParam("query_id", "status.govUserStatus.select_parkingInoutChart");
        frm.addParam("kParkingGovCode", $("#kParkingGovCode").val());
        frm.addParam("kParkingNo", $("#kParkingNo").val());
        frm.addParam("kUseYear", $("#kUseYear").val());
        frm.addParam("kUseMonth", $("#kUseMonth").val());
        frm.addParam("kDayArr", dayArray);
        frm.addParam("dataType", "json");
		frm.request();
    }
	
	function handleIQ3(data, textStatus, jqXHR) {
		if(data.length > 0) {

			var date = new Date();
			var year = date.getFullYear();
			var month= date.getMonth() +1;
			var day= date.getDate();
			var nowMonth = false;

			if($("#kUseYear").val() == year && $("#kUseMonth").val() == month){
				nowMonth = true;
			}


	        var labelArray = [];
	        var labelArray2 = [];
	        var colorArray = ["#0174DF","#FF8000"];

	        /* for(var i=0; i<data.length; i++){
	        	var color_r = Math.floor(Math.random() * 127 + 128).toString(16);
	      	  	var color_g = Math.floor(Math.random() * 127 + 128).toString(16);
	      	  	var color_b = Math.floor(Math.random() * 127 + 128).toString(16);

	      	  	colorArray.push('#' + color_r + color_g + color_b)
	        } */

	        var result = [];
	        var chart_func = $("#chart2").data("chart_func");
			var chart = $("#chart2").data("chart_obj");
	        chart.data.datasets = [];

	        for(var i=0; i<data.length; i++){

	        	var emisArray = [];
				var temp = 0;
				var cnt = 0;

	        	for(var key in data[i]){


		        	if(data[i].hasOwnProperty(key)){

						if(i == 0 && key != "io"){
							labelArray2.push(key);
						}
						if(key != "io"){
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
	        		
		            label: data[i].io,
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
	            		str_arr = data.datasets[tooltipItem.datasetIndex].data[tooltipItem.index].toString().split(".");
	            		str = str_arr[0].replace(/\B(?=(\d{3})+(?!\d))/g, ",") + "." + str_arr[1];
	            	}else{
	            		str = data.datasets[tooltipItem.datasetIndex].data[tooltipItem.index].toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
	            	}
                	return data.datasets[tooltipItem.datasetIndex].label + ': ' + str + '건';
                	
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
	                "position":'bottom',
    	    };
	        

	        chart_func.update();

		}else{
			g_chart2 = $("#chart2").chartHelper({
		        type: "line",       
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
		$("#chart3").height($("#chart2").height());
		loadTableData4();
	}
	
	
	// 매출 차트
	function loadTableData4() {
        var frm = $("#frmMain");
		frm.addParam("func", "IQ4");
        frm.addParam("query_id", "status.govUserStatus.select_parkingPayChart");
        frm.addParam("kParkingGovCode", $("#kParkingGovCode").val());
        frm.addParam("kUseYear", $("#kUseYear").val());
        frm.addParam("kUseMonth", $("#kUseMonth").val());
        frm.addParam("dataType", "json");
		frm.request();
    }
	
	function handleIQ4(data, textStatus, jqXHR) {
		if(data.length > 0) {
    		var parkingName = [];
	        var payTotal = [];

       		for(var i=0; i<data.length; i++){
       			parkingName.push(data[i].parkingName);
       			payTotal.push(data[i].total);
       		}

	        
	        var chart_func3 = $("#chart3").data("chart_func");
			var chart3 = $("#chart3").data("chart_obj");
			const maxVal = chartMaxVal(payTotal);
			
			chart_func3.changeLabel(parkingName);
	        chart3.data.datasets = [];

	        chart3.data.datasets.push({
	        	label: "매출",
	        	borderColor: "#177d8a",
	            backgroundColor: "#177d8a",
	            data: payTotal
	        });  

	        chart3.options.tooltips.callbacks = {
		            label: function(tooltipItem, data) {
		            	var str = "";
		            	var str_arr = "";
		            	if(data.datasets[tooltipItem.datasetIndex].data[tooltipItem.index].toString().includes(".")){
		            		str_arr = data.datasets[tooltipItem.datasetIndex].data[tooltipItem.index].toString().split(".")
		            		str = str_arr[0].replace(/\B(?=(\d{3})+(?!\d))/g, ",") + "." + str_arr[1]
		            	}else{
		            		str = data.datasets[tooltipItem.datasetIndex].data[tooltipItem.index].toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",")
		            	}
	                	return data.datasets[tooltipItem.datasetIndex].label + ': ' + str + '원'
	                },
			}
	        chart3.options.scales.yAxes[0].ticks = {
	        		beginAtZero: true,
					suggestedMax: maxVal,
	        		stepSize : maxVal / 5,
	        		minTicksLimit: 5,
	        		callback: function(value, index) {
	        			return value.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",")
	                }
    		};
	        chart3.options.scales.xAxes[0].ticks = {
	        		autoSkip: false,
	        		maxRotation: 90,
                    minRotation: 90
	        }
	        
	        chart3.options.animation.duration = 700;
	        chart3.options.legend = {
	                "display": false,
	                "position":'bottom'
    	    };
	        
	        chart3.options.plugins.datalabels = {
	        		display: false,
		         };

	        chart_func3.update();
	        
		}else{
			var chart_func3 = $("#chart3").data("chart_func");
			var chart3 = $("#chart3").data("chart_obj");
			
			chart3.options.scales.yAxes[0].ticks = {
	        		beginAtZero: true,
					suggestedMax: 5,
	        		stepSize : 1,
	        		callback: function(value, index) {
	        			return value.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",")
	                }
    		};
			
			chart3.options.scales.xAxes[0].stacked = true;
	        chart3.options.scales.xAxes[0].barPercentage = 0.5;
	        chart3.options.animation.duration = 700;
	        chart3.options.legend = {
	                "display": false,
	                "position":'bottom'
    	    };

	        chart_func3.update();
		}
		
	}
 
	
	function chartInitialize() {
	 	g_chart1 = $("#chart").chartHelper({
	        type: "pie",        // 파이 차트
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
	 	
	 	g_chart2 = $("#chart2").chartHelper({
	        type: "line",        // 라인 차트
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
	 	
	 	g_chart3 = $("#chart3").chartHelper({
	        type: "bar",        // 바 차트
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
	
	function loadComboData() {
		var frm = $("#frmMain");
		frm.addParam("func", "IQCombo");
		frm.addParam("kParkingGovCode", $("#kParkingGovCode").val());
		frm.addParam("kParkingCompCode", $("#kParkingCompCode").val());
		frm.addParam("queryId", "select.select_parkingInfo2");
		frm.addParam("afterAction", false);
		frm.request();
	}
	
	function handleIQCombo(data, textStatus, jqXHR) {
		$("#kParkingNo option[value!='']").remove();
		$.each(data, function(k, v) {
			$("#kParkingNo").append("<option value='" + v.value + "'>" + v.text + "</option>");			
		});
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
	
	$(function() {

		//일자
		$("#kUseYear").initDateSingle("year");
		let date = new Date();
		let month = ((date.getMonth()+1) < 10 ? "0" + (date.getMonth()+1) : (date.getMonth()+1)) ;
		$("#kUseMonth").val(month);

		// lookup the container we want the Grid to use
		var eGridDiv = document.querySelector('#myGrid');

		// create the grid passing in the div to use together with the columns & data we want to use
		new agGrid.Grid(eGridDiv, gridOptions);


		$("#kParkingNo, #kUseYear, #kUseMonth").change(function(){
			_gridHelper.clearData();
			chartInitialize();
		});
		
		$("#kParkingGovCode").change(function(){
			loadTableData2();
			loadComboData();
		});

		
		// 조회
		$("#btnSearch").click(function() {
			_gridHelper.clearData();
			chartInitialize();
		});
		
		chartInitialize();
				
		$(".ag-body-horizontal-scroll").eq(0).css("display", "none");
	});

</script>


<div class="page-body" style="font-size: 0.9em;">
	<div class="row">
		<div class="col-12" id="search_all_wrapper">
			<card:open title="검색 조건" />
				<card:button>
					<form:button type="Search" id="btnSearch" />
				</card:button>
				<card:content />
				<div class="search-area col-lg-12" >
					<form id="frmMain" name="frmMain" method="post" onsubmit="return false" class="form-material form-inline">
						<form:input type="hidden" id="hLoginDt" />
						<form:input type="hidden" id="hMemberId" />
						<form:select id="kParkingGovCode" caption="관리기관" all="true" allLabel="전체" queryId="select.select_parkingGovInfo"/>
						<form:input id="kUseYear" caption="연도" />
						<form:select id="kUseMonth" caption="월" queryId="#month"  />
					</form>
				</div>
			<card:close />
		</div>
		<div class="col-xl-6 col-lg-6 col-md-12 col-sm-12 col-12">
			<card:open title="" />
				<card:toolButton title="">
				</card:toolButton>
				<card:content />
                <form:grid id="myGrid" />
			<card:close />
		</div>
		<div class="col-xl-6 col-lg-6 col-md-12 col-sm-12 col-12">
			<card:open title="이용현황 (TOP 5)" />
				<card:toolButton title="">
				</card:toolButton>
				<card:content />
                <canvas id="chart" ></canvas>
			<card:close />
		</div>
		<div class="col-12" id="search_all_wrapper">
			<card:open title="검색 조건" />
				<card:button>
					<form:button type="Search" id="btnSearch" />
				</card:button>
				<card:content />
				<div class="search-area col-lg-12" >
					<form id="frmMain" name="frmMain" method="post" onsubmit="return false" class="form-material form-inline">
						<form:select id="kParkingNo" caption="주차장" queryId="select.select_parkingInfo"/>
					</form>
				</div>
			<card:close />
		</div>
		<div class="col-xl-6 col-lg-6 col-md-12 col-sm-12 col-12">
			<card:open title="이용 현황" />
				<card:toolButton title="">
				</card:toolButton>
				<card:content />
               <canvas id="chart2" ></canvas>
			<card:close />
		</div>
		<div class="col-xl-6 col-lg-6 col-md-12 col-sm-12 col-12">
			<card:open title="매출" />
				<card:toolButton title="">
				</card:toolButton>
				<card:content />
                <canvas id="chart3" ></canvas>
			<card:close />
		</div>
	</div>
</div>

<%@ include file="../../core/include/footer.jsp"%>
