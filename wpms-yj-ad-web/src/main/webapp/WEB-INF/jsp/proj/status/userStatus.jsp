<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="form" uri="http://ad.its.yeongju.kr/jsp/jstl/form"%>
<%@ taglib prefix="card" uri="http://ad.its.yeongju.kr/jsp/jstl/card"%>
<%@ taglib prefix="func" uri="http://ad.its.yeongju.kr/jsp/jstl/func"%>
<%@ taglib prefix="label" uri="http://ad.its.yeongju.kr/jsp/jstl/label"%>

<%@ include file="../../core/include/head.jsp"%>
<%@ include file="../../core/include/header.jsp"%>

<script type="text/javascript">
	var g_Chart1, g_Chart2, g_Chart3, g_Chart4, g_Chart5;
	var labelArrayDate = [];
	var dayArray = [];
	
	var now = new Date();
	var dateStr;
	var endDate;
	
	// 검색조건 현재 월 세팅
	var monthStr;
	if(now.getMonth()+1 < 10){
		monthStr = "0" + (now.getMonth()+1);
	}else{
		monthStr = now.getMonth()+1;
	}
	
	// 현재 월의 일자 배열
	// 일자 라벨
	var lastDay = new Date(now.getFullYear(), now.getMonth()+1, 0);
	endDate = lastDay.getDate();

	for(var i=0; i<endDate; i++){
		dateStr = (i+1) + "일";
		labelArrayDate.push(dateStr);
	}
	// 쿼리에 들어갈 일자 배열
	for(var i=0; i<endDate; i++){
		dayArray.push(i+1);
	}
	
	// 회원 비율 차트
	function loadChartData() {
        var frm = $("#frmMain");
		frm.addParam("func", "IQ");
        frm.addParam("query_id", "status.userStatus.select_memberGubnStatus");
        frm.addParam("kUseYear", $("#kUseYear").val());
        frm.addParam("kUseMonth", $("#kUseMonth").val());
        frm.addParam("dataType", "json");
		frm.request();
    }

    function handleIQ(data, textStatus, jqXHR) {
    	$("#chart").remove();
    	$(".card-block").eq(0).append("<canvas id='chart' class='pieChart' height='" + $("#chart3").height() + "'></canvas>");
    	
    	var ctx = document.getElementById("chart");
		var dataArrCnt = 0;
		var dataArr = [];
		var gubnArr = [];
		var bgColorArr = [];
		var txtColorArr = [];

		for(var i=0; i<data.length; i++){
			dataArr.push(data[i].memberCnt);
			gubnArr.push(data[i].memberGubnName);
			dataArrCnt++;
		}

		if(dataArr.length > 0){
			bgColorArr = ["#20cbc2","#074d81"];
			txtColorArr = ["#000000","#000000"];
		}else{
			// 숫자 0을 넣을 경우 chart js가 그려지지 않음으로 1로 처리하여 datalabels에서 분기처리
			dataArr.push(1);
			gubnArr.push("회원가입 현황 없음");
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
	                     formatter: function (value, context) {
	                    	 return "";
	                     },
	                     color: 'white',
	                     font: {
                        	weight: 'bold',
                        	size: 20
                      	},
	                 },
                     outlabels: {
	                   	display: true
                	}
	            },
	            maintainAspectRatio: false,
	   	   		responsive: true,
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
		                	return data.labels[tooltipItem.index] + ': ' + str + '명'
	 	   	        	}
	 	   	        }
	 	   	      }
	 	   	    },
 	   	   		aspectRatio: 1,
 	   	    	showAllTooltips: true
   		    }
		});
		 
		loadTableData();
    }
    
 	// 접속 환경 비율 차트
	function loadChartData2() {
        var frm = $("#frmMain");
		frm.addParam("func", "IQ2");
        frm.addParam("query_id", "status.userStatus.select_userMobileYn");
        frm.addParam("kUseYear", $("#kUseYear").val());
        frm.addParam("kUseMonth", $("#kUseMonth").val());
        frm.addParam("dataType", "json");
		frm.request();
    }

    function handleIQ2(data, textStatus, jqXHR) {
    	$("#chart2").remove();
    	$(".card-block").eq(1).append("<canvas id='chart2' class='pieChart' height='" + $("#chart3").height() + "'></canvas>");
    	var ctx = document.getElementById("chart2");
		var dataArrCnt = 0;
		var dataArr = [];
		var gubnArr = [];
		var bgColorArr = [];
		var txtColorArr = [];

		for(var i=0; i<data.length; i++){
			dataArr.push(data[i].cnt);
			gubnArr.push(data[i].mobileYn);
			dataArrCnt++;
		}

		if(dataArr.length > 0){
			bgColorArr = ["#20cbc2","#074d81"];
			txtColorArr = ["#000000","#000000"];
		}else{
			// 숫자 0을 넣을 경우 chart js가 그려지지 않음으로 1로 처리하여 datalabels에서 분기처리
			dataArr.push(1);
			gubnArr.push("접속 현황 없음");
			bgColorArr = ["#20cbc2"];
			txtColorArr = ["#000000"];
		}

		var chart2 = new Chart(ctx, {
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
	                     formatter: function (value, context) {
	                    	 return "";
	                     },
	                     color: 'white',
	                     font: {
                        	weight: 'bold',
                        	size: 20
                      	},
	                 },
                     outlabels: {
	                   	display: true
                	}
	            },
	            maintainAspectRatio: false,
	   	   		responsive: true,
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
    }
	  
	// 감면승인현황 차트
	function loadChartData3() {
        var frm = $("#frmMain");
		frm.addParam("func", "IQ3");
        frm.addParam("query_id", "status.userStatus.select_reductionList");
        frm.addParam("kUseYear", $("#kUseYear").val());
        frm.addParam("kUseMonth", $("#kUseMonth").val());
        frm.addParam("dataType", "json");
		frm.request();
    }

    function handleIQ3(data, textStatus, jqXHR) {
    	
    	
    	if(data.length > 0) {
    		var reductionTop10Label = [];
	        var reductionTop10 = [];

       		for(var i=0; i<data.length; i++){
       			reductionTop10Label.push(data[i].reductionName);
       			reductionTop10.push(data[i].cnt);
       		}
       		
       		if(data.length < 10){
       			for(i=0; i<10-data.length; i++){
       				reductionTop10Label.push("");
       				reductionTop10.push(0);
       			}
       		}
	        
	        var chart_func3 = $("#chart3").data("chart_func");
			var chart3 = $("#chart3").data("chart_obj");
			
			chart_func3.changeLabel(reductionTop10Label);
	        chart3.data.datasets = [];

	        chart3.data.datasets.push({
	        	label: "감면 승인 비율",
	        	borderColor: "#455a64",
	            backgroundColor: "#455a64",
	            data: reductionTop10
	        });  
	        
	        chart3.options.scales.xAxes[0].stacked = true;
	        chart3.options.scales.xAxes[0].barPercentage = 0.5;
	        chart3.options.scales.xAxes[0].ticks = { maxRotation: 30, minRotation: 30 }

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
	                	return data.datasets[tooltipItem.datasetIndex].label + ': ' + str + '%'
	                },
			};
	        chart3.options.scales.yAxes[0].ticks = {
	        		beginAtZero: true,
	        		minTicksLimit: 5,
               		maxTicksLimit: 5,
	        		callback: function(value, index) {
	        			return value.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",")
	                }
    		};
	        chart3.options.animation.duration = 700;
	        chart3.options.legend = {
	                "display": false,
	                "position":'bottom'
    	    };

	        chart_func3.update();
	    }else{
			var chart_func3 = $("#chart3").data("chart_func");
			var chart3 = $("#chart3").data("chart_obj");
			
			chart3.options.scales.yAxes[0].ticks = {
	        		beginAtZero: true,
	           		minTicksLimit: 5,
	           		maxTicksLimit: 5,
	        		callback: function(value, index) {
	        			return value.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",")
	                }
			};
	        chart3.options.animation.duration = 700;
	        chart3.options.legend = {
	                "display": false,
	                "position":'bottom'
		    };
	
	        chart_func3.update();
		}
    } 
    
	// 가입자/탈퇴자 현황 차트
    function loadChartData4() {
        var frm = $("#frmMain");
		frm.addParam("func", "IQ4");
        frm.addParam("query_id", "status.userStatus.select_joinStatus");
        frm.addParam("kDayArray", dayArray);
        frm.addParam("kUseYear", $("#kUseYear").val());
        frm.addParam("kUseMonth", $("#kUseMonth").val());
        frm.addParam("dataType", "json");
		frm.request();
    }

    function handleIQ4(data, textStatus, jqXHR) {
    	
    	 
    	if(data.length > 0) {
	        var walletFreeArray = [];
	        var digitalArray = [];

       		for(var i=1; i<=endDate; i++){
       			if(data[0]){
	       			walletFreeArray.push(data[0]["d"+i]);
       			}else{
       				walletFreeArray.push(0);
       			}
       			if(data[1]){
	       			digitalArray.push(data[1]["d"+i]);
       			}else{
       				digitalArray.push(0);
       			}
        	}

	        var chart_func4 = $("#chart4").data("chart_func");
			var chart4 = $("#chart4").data("chart_obj");
			var maxVal;
			
			if(chartMaxVal(walletFreeArray) >=  chartMaxVal(digitalArray)){
				maxVal = chartMaxVal(walletFreeArray);
			}else{
				maxVal = chartMaxVal(digitalArray);
			}
			
	        chart4.data.datasets = [];
	        
	        chart4.data.datasets.push({
	            label: '가입회원',
	            borderColor: '#bcb7b0',
	            backgroundColor: "#bcb7b0",
	            data: walletFreeArray,
	            type: 'bar',
	            pointBackgroundColor: '#bcb7b0',
            	pointRadius: 3,
            	borderWidth : 2 
	        },{
	            label: '탈퇴회원',
	            borderColor: '#a4b3c1',
	            backgroundColor: "#a4b3c1",
	            data: digitalArray,
	            type: 'bar',
	            pointBackgroundColor: '#a4b3c1',
            	pointRadius: 3,
            	borderWidth : 2 
	        });
 
	        chart4.options.tooltips.callbacks = {
		            label: function(tooltipItem, data) {
		            	var str = "";
		            	var str_arr = "";
		            	if(data.datasets[tooltipItem.datasetIndex].data[tooltipItem.index].toString().includes(".")){
		            		str_arr = data.datasets[tooltipItem.datasetIndex].data[tooltipItem.index].toString().split(".")
		            		str = str_arr[0].replace(/\B(?=(\d{3})+(?!\d))/g, ",") + "." + str_arr[1]
		            	}else{
		            		str = data.datasets[tooltipItem.datasetIndex].data[tooltipItem.index].toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",")
		            	}
	                	return data.datasets[tooltipItem.datasetIndex].label + ': ' + str + '명'
	                },
			}
        		
	        chart4.options.scales.yAxes[0].ticks = {
        				beginAtZero: true,
        				suggestedMax: maxVal,
                		stepSize : maxVal / 2,
                		minTicksLimit: 5, 
	        		callback: function(value, index) {
	        			return value.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",")
	                }
    		};
	        
	        chart4.options.animation.duration = 700;
	        chart4.options.legend = {
	                "display": "useLegend",
	                "position":'bottom'
    	    };

	        chart_func4.update();
		}
    	
    	$(".card-header h5").eq(4).text($("#kUseYear").val() + "년 " + $("#kUseMonth option:checked").text() + " 가입자/탈퇴자 현황");
    }
    
    // 이용자현황 차트
    function loadChartData5() {
        var frm = $("#frmMain");
		frm.addParam("func", "IQ5");
        frm.addParam("query_id", "status.userStatus.select_useStatus");
        frm.addParam("kDayArray", dayArray);
        frm.addParam("kUseYear", $("#kUseYear").val());
        frm.addParam("kUseMonth", $("#kUseMonth").val());
        frm.addParam("dataType", "json");
		frm.request();
    }

    function handleIQ5(data, textStatus, jqXHR) {
    	if(data.length > 0) {
	        var joinArray = [];

       		for(var i=1; i<=endDate; i++){
       			joinArray.push(data[0]["d"+i])
        	}

	        var chart_func5 = $("#chart5").data("chart_func");
			var chart5 = $("#chart5").data("chart_obj");
			const maxVal = chartMaxVal(joinArray);
			
	        chart5.data.datasets = [];
 
	        chart5.data.datasets.push({
	            label: '이용자 수',
	            borderColor: '#454e5a',
	            backgroundColor: "#454e5a",
	            data: joinArray,
	            type: 'bar', 
	            pointBackgroundColor: '#454e5a',
            	pointRadius: 3,
            	borderWidth : 1
	        });
 
	        chart5.options.tooltips.callbacks = {
		            label: function(tooltipItem, data) {
		            	var str = "";
		            	var str_arr = "";
		            	if(data.datasets[tooltipItem.datasetIndex].data[tooltipItem.index].toString().includes(".")){
		            		str_arr = data.datasets[tooltipItem.datasetIndex].data[tooltipItem.index].toString().split(".")
		            		str = str_arr[0].replace(/\B(?=(\d{3})+(?!\d))/g, ",") + "." + str_arr[1]
		            	}else{
		            		str = data.datasets[tooltipItem.datasetIndex].data[tooltipItem.index].toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",")
		            	}
	                	return data.datasets[tooltipItem.datasetIndex].label + ': ' + str + '건'
	                },
			}
        		
	        chart5.options.scales.yAxes[0].ticks = {
        				beginAtZero: true,
        				suggestedMax: maxVal,
                		stepSize : maxVal / 2,
                		minTicksLimit: 5, 
	        		callback: function(value, index) {
	        			return value.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",")
	                }
    		};
	        
	        chart5.options.animation.duration = 700;
	        chart5.options.legend = {
	                "display": false,
	                "position":'bottom'
    	    };

	        chart_func5.update();
		}
    	
    	$(".card-header h5").eq(5).text($("#kUseYear").val() + "년 " + $("#kUseMonth option:checked").text() + " 이용자 현황");
    }
    
    // 총 가입자/탈퇴자 현황 조회
    function loadTableData(){
    	var frm = $("#frmMain");
		frm.addParam("func", "IQ6");
        frm.addParam("query_id", "status.userStatus.select_joinStatusTotal");
        frm.addParam("kDayArray", dayArray);
        frm.addParam("dataType", "json");
		frm.request();
    }
    
    function handleIQ6(data, textStatus, jqXHR) {
    	if(data.length > 0) {
    		
    		var joinCntStr = ""; 
    		var withdrawCntStr = ""; 
    		joinCntStr = data[0].joinCnt.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
    		withdrawCntStr = data[0].withdrawCnt.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
    		
    		$(".card-header h5").eq(0).text("회원 비율 (가입자 : " + joinCntStr + " 명 / 탈퇴자 : " + withdrawCntStr + " 명)");
    	}
    }

	function chartInitialize() {
		g_Chart4 = $("#chart4").chartHelper({
            type: "bar",
            data: [],           // 데이터
            label: labelArrayDate,
        	borderColor: "#455a64",
            backgroundColor: "#455a64",
            tooltip: true,
            borderWidth: 1,
            pointRadius: 0,
            lineTension: 0,
            fill:false,
        });
		
		g_Chart5 = $("#chart5").chartHelper({
            type: "bar",
            data: [],           // 데이터
            label: labelArrayDate,
        	borderColor: "#455a64",
            backgroundColor: "#455a64",
            tooltip: true,
            borderWidth: 1,
            pointRadius: 0,
            lineTension: 0,
            fill:false,
        });
		
		loadChartData4();
		loadChartData5();
	}
	
	function chartInitialize2(){
		g_Chart3 = $("#chart3").chartHelper({
	        type: "bar",        // 바 차트
	        data: [],           // 데이터
	        label: ["", "", "", "", "", "", "", "", "", ""],
	    	borderColor: "#455a64",
	        backgroundColor: "#455a64",
	        tooltip: true,
	        borderWidth: 1,
	        pointRadius: 0,
	        lineTension: 0,
	        fill:false,
	    });
		
		loadChartData();
		loadChartData2();
		loadChartData3();
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
		
		var height = $("#mCSB_1_container_wrapper").outerHeight() - 845; 

		$("canvas").width("100%");
		$("canvas").not(".pieChart").height(height);
		
		// 조회
		$("#btnSearch").click(function() {
			chartInitialize();
		});
		
		//연도
		$("#kUseYear").initDateSingle("year");
		
		$("#kUseMonth").val(monthStr);
		
		$("#kUseYear, #kUseMonth").change(function(){
			dayArray = [];
			labelArrayDate = [];
			// 일자 라벨
			var lastDay = new Date($("#kUseYear").val(), $("#kUseMonth").val(), 0);
			endDate = lastDay.getDate();

			for(var i=0; i<endDate; i++){
				dateStr = (i+1) + "일";
				labelArrayDate.push(dateStr);
			}
			// 쿼리에 들어갈 일자 배열
			for(var i=0; i<endDate; i++){
				dayArray.push(i+1);
			}
			
			chartInitialize();
		});
		
		chartInitialize();
		chartInitialize2();
	});
</script>


<div class="page-body" style="font-size: 0.9em;">
	<div class="row">
		<div class="col-xl-3 col-lg-3 col-md-12 col-sm-12 col-12">
			<card:open title="회원 비율" />
				<card:toolButton title="L00087">
				</card:toolButton>
				<card:content />
                <canvas id="chart" ></canvas>
			<card:close />
		</div>
		<div class="col-xl-3 col-lg-3 col-md-12 col-sm-12 col-12">
			<card:open title="접속 환경 비율" />
				<card:toolButton title="L00087">
				</card:toolButton>
				<card:content />
                <canvas id="chart2" ></canvas>
			<card:close />
		</div>
		<div class="col-xl-6 col-lg-6 col-md-12 col-sm-12 col-12">
			<card:open title="감면 적용 현황" />
				<card:toolButton title="L00087">
				</card:toolButton>
				<card:content />
                <canvas id="chart3" ></canvas>
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
						<form:input type="hidden" id="hLoginDt" />
						<form:input type="hidden" id="hMemberId" />
						<form:input id="kUseYear" caption="연도" />
						<form:select id="kUseMonth" caption="월" all="false" allLabel="전체" queryId="#month"  />
					</form>
				</div>
			<card:close />
		</div>
		<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12">
			<card:open title="가입자/탈퇴자 현황" />
				<card:toolButton title="L00087">
				</card:toolButton>
				<card:content />
                <canvas id="chart4" ></canvas>
			<card:close />
		</div>
		<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12">
			<card:open title="이용자 현황" />
				<card:toolButton title="L00087">
				</card:toolButton>
				<card:content />
                <canvas id="chart5" ></canvas>
			<card:close />
		</div>
	</div>
</div>

<%@ include file="../../core/include/footer.jsp"%>
