<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="func" uri="http://ad.its.yeongju.kr/jsp/jstl/func" %>
<%@ taglib prefix="form" uri="http://ad.its.yeongju.kr/jsp/jstl/form" %>
<%@ taglib prefix="label" uri="http://ad.its.yeongju.kr/jsp/jstl/label" %>
<%@ taglib prefix="card" uri="http://ad.its.yeongju.kr/jsp/jstl/card" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>

<%@ include file="./include/head.jsp" %>
<%@ include file="./include/header.jsp" %>

<script type="text/javascript" src="<c:url value='/common/js/chartjs/Chart.min.js'/>" charset="utf-8"></script>
<script type="text/javascript" src="<c:url value='/common/js/chartjs/Chart.bundle.min.js'/>" charset="utf-8"></script>
<script type="text/javascript" src="<c:url value='/common/js/chartjs/Chartjs.plugin.datalabels.js'/>" charset="utf-8"></script>
<script type="text/javascript" src="<c:url value='/common/js/chartjs/Chartjs.plugin.piechart.outlabels.js'/>" charset="utf-8"></script>

<c:set var="now" value="<%=new java.util.Date()%>" />
<c:set var="sysYear"><fmt:formatDate value="${now}" pattern="yyyy" /></c:set>
<c:set var="sysMonth"><fmt:formatDate value="${now}" pattern="mm" /></c:set>  

<style>

body {overflow: hidden;}
</style> 

<script type="text/javascript">
	var g_Chart1, g_Chart2, g_Chart3, g_Chart4, g_Chart5, g_Chart6;
	var labelArrayDate = [];
	var labelArrayYear = [];
	var dayArray = [];
	var chartdata = {};
	
	var now = new Date();
	var yearStr;
	var dateStr;
	var endDate;

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

	// 월별 매출 대비 미납 현황 차트
    function loadChartData() {
    	$("#hParkingName").val($("#kParkingName").val());
        var frm = $("#frmMain");
		frm.addParam("func", "IQ");
        frm.addParam("query_id", "index.index.select_salesStatus");
        frm.addParam("dataType", "json");
		frm.request();
    }

    function handleIQ(data, textStatus, jqXHR) {
    	if(data.length > 0) {
	        var salesArray = [];
	        var unpaidArray = [];
	        var maxArray = [];
	        
        	$.each(data[0], function(k, v) {
        		salesArray.push(v);
        	});
        	
        	var top_value = 0;
			$.each(data[1], function(k, v) {
				if(top_value < v){
					top_value = v;
				}
				unpaidArray.push(v);
			});
        	
	        var chart_func = $("#chart").data("chart_func");
			var chart = $("#chart").data("chart_obj");
			// 배열 합치기
			maxArray.push(...salesArray);
			maxArray.push(...unpaidArray);
			const maxVal = chartMaxVal(maxArray);
			
			chart.datasets[0].data = unpaidArray;
			chart.datasets[1].data = salesArray;
			
			JsChartBar.options.animation.duration = 700;
			
			JsChartBar.options.scales.yAxes[0].ticks = {
				beginAtZero: true,
				suggestedMax: maxVal,
        		stepSize : maxVal / 5,
        		minTicksLimit: 5, 
        		callback: function(value, index) {
        			return value.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",")
                }
			}
			
			JsChartBar.options.tooltips.callbacks = {
		            label: function(tooltipItem, data) {
		            	return data.datasets[tooltipItem.datasetIndex].data[tooltipItem.index].toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
	                },
			}
			
			//JsChartBar.options.scales.yAxes[1].ticks.min = top_value * -1;
			JsChartBar.update();
		} 
    }

    // 웹접속자 이용 현황 차트
    function loadChartData2() {
        var frm = $("#frmMain");
		frm.addParam("func", "IQ2");
        frm.addParam("query_id", "index.index.select_webUseStatus");
        frm.addParam("dataType", "json");
		frm.request();
    }

    function handleIQ2(data, textStatus, jqXHR) {
    	if(data.length > 0) {
	        var loginArray = [];

        	for(var i=1; i<13; i++){
       			loginArray.push(data[0]["m"+i]);
	        }

	        var chart_func2 = $("#chart2").data("chart_func");
			var chart2 = $("#chart2").data("chart_obj");
			const maxVal = chartMaxVal(loginArray);
			
	        chart2.data.datasets = [];

	        chart2.data.datasets.push({
	            label: '접속 횟수',
	            borderColor: '#dbd0c7',
	            backgroundColor: "#00ff0000",
	            data: loginArray,
	            type: 'line',
	            pointStyle : 'line',
	            pointBackgroundColor: '#dbd0c7',
            	pointRadius: 3,
            	borderWidth : 2
	        });
			
	        chart2.options.plugins.datalabels.formatter = function(value, context) {return null;}
	        
	        chart2.options.tooltips.callbacks = {
		            label: function(tooltipItem, data) {
		            	var str = "";
		            	var str_arr = "";
		            	if(data.datasets[tooltipItem.datasetIndex].data[tooltipItem.index].toString().includes(".")){
		            		str_arr = data.datasets[tooltipItem.datasetIndex].data[tooltipItem.index].toString().split(".")
		            		str = str_arr[0].replace(/\B(?=(\d{3})+(?!\d))/g, ",") + "." + str_arr[1]
		            	}else{
		            		str = data.datasets[tooltipItem.datasetIndex].data[tooltipItem.index].toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",")
		            	}
	                	return data.datasets[tooltipItem.datasetIndex].label + ': ' + str + '회'
	                },
			}
        		
	        chart2.options.scales.yAxes[0].ticks = {
       				beginAtZero: true,
       				suggestedMax: maxVal,
               		stepSize : maxVal / 5,
               		minTicksLimit: 5, 
	        		callback: function(value, index) {
	        			return value.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",")
	                }
    		};
	        chart2.options.animation.duration = 700;
	        chart2.options.legend = {
	                "display": "useLegend",
	                "position":'bottom',
	                "pointStyle": 'line'
    	    }; 
	        chart_func2.update();
		}
    }
	
 	// 2023년 03월 시간대별 주차장 이용 현황
    function loadChartData3() {
    	$("#hParkingName").val($("#kParkingName").val());
    	var timeArray = [];
    	
    	for(var i=0; i<24; i++){
			time = (i+1) < 10 ? "0" + (i+1) : (i+1);
			timeArray.push(time);
		}
    	
        var frm = $("#frmMain");
		frm.addParam("func", "IQ3");
        frm.addParam("query_id", "index.index.select_parkingUse");
        frm.addParam("kTimeArr", timeArray);
        frm.addParam("kYearDate", moment().format('YYYY'));
	    frm.addParam("kMonthDate", moment().format('MM'));
        frm.addParam("dataType", "json");
		frm.request();
    }

    function handleIQ3(data, textStatus, jqXHR) {
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
 		
         	
 			var chart_func3 = $("#chart3").data("chart_func");
			var chart3 = $("#chart3").data("chart_obj");
			chart3.data.datasets = [];

	        chart3.data.datasets.push({
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
	        
	       
	        chart3.data.labels = useLabelArray;
	        chart3.options.plugins.datalabels.formatter = function(value, context) {return null;}
	        
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
			}
        		
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
	                "display": "useLegend",
	                "position":'bottom'
    	    };

	        chart_func3.update();
 		} 
    	
    }

    // 일자별 주차장 현황 차트
    function loadChartData4() {
    	$("#hParkingName").val($("#kParkingName").val());
        var frm = $("#frmMain");
		frm.addParam("func", "IQ4");
        frm.addParam("query_id", "index.index.select_parkingDate");
        frm.addParam("kDayArray", dayArray);
        frm.addParam("dataType", "json");
		frm.request();
    }

    function handleIQ4(data, textStatus, jqXHR) {
    	if(data.length > 0) {
	        var parkingDateArray = [];

       		for(var i=1; i<=endDate; i++){
       			parkingDateArray.push(data[0]["d"+i])
        	}

	        var chart_func4 = $("#chart4").data("chart_func");
			var chart4 = $("#chart4").data("chart_obj");
			const maxVal = chartMaxVal(parkingDateArray);
			
	        chart4.options.plugins.datalabels.formatter = function(value, context) {return null;}
	        chart4.data.datasets = [];
 
	        chart4.data.datasets.push({
	            label: '주차 건수',
	            borderColor: '#454e5a',
	            backgroundColor: "#454e5a",
	            data: parkingDateArray,
	            type: 'bar',
	            pointBackgroundColor: '#454e5a',
            	pointRadius: 3,
            	borderWidth : 1
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
	                	return data.datasets[tooltipItem.datasetIndex].label + ': ' + str + '회'
	                },
			}
        		
	        chart4.options.scales.yAxes[0].ticks = {
        				beginAtZero: true,
        				suggestedMax: maxVal,
                		stepSize : maxVal / 5,
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
    }

	// 2023년 3월 주차현황 TOP5
    function loadChartData5() {
        var frm = $("#frmMain");
		frm.addParam("func", "IQ5");
        frm.addParam("query_id", "index.index.select_parkingTop5");
        frm.addParam("dataType", "json");
		frm.request();
    }

    function handleIQ5(data, textStatus, jqXHR) {
    	if(data.length > 0) {
    		var parkingTop5Label = [];
	        var parkingTop5 = [];

       		for(var i=0; i<data.length; i++){
       			parkingTop5Label.push(data[i].parkingName);
       			parkingTop5.push(data[i].cnt);
       		}
       		
       		if(data.length < 5){
       			for(i=0; i<5-data.length; i++){
       				parkingTop5Label.push("");
           			parkingTop5.push(0);	
       			}
       		}
	        
	        var chart_func5 = $("#chart5").data("chart_func");
			var chart5 = $("#chart5").data("chart_obj");
			const maxVal = chartMaxVal(parkingTop5);
			
			chart_func5.changeLabel(parkingTop5Label);
	        chart5.data.datasets = [];

	        chart5.data.datasets.push({
	        	label: "주차 건수",
	        	borderColor: ["#177d8a","#ccd2da","#d4d2c9","#b3b3ad","#646e7a"],
	            backgroundColor: ["#177d8a","#ccd2da","#d4d2c9","#b3b3ad","#646e7a"],
	            data: parkingTop5
	        });  
	        
	        chart5.options.scales.xAxes[0].stacked = true;
	        chart5.options.scales.xAxes[0].barPercentage = 0.5;
	        chart5.options.plugins.datalabels.formatter = function(value, context) {return null;}

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
	        		stepSize : maxVal / 5,
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
		}else{
			var chart_func5 = $("#chart5").data("chart_func");
			var chart5 = $("#chart5").data("chart_obj");
			
			chart5.options.scales.yAxes[0].ticks = {
	        		beginAtZero: true,
					suggestedMax: 5,
	        		stepSize : 1,
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
    }

	// 미납차량 TOP5 차트
    function loadChartData6() {
        var frm = $("#frmMain");
		frm.addParam("func", "IQ6");
        frm.addParam("query_id", "index.index.select_unpaidTop5");
        frm.addParam("dataType", "json");
		frm.request();
    }

    function handleIQ6(data, textStatus, jqXHR) {
    	if(data.length > 0) {
    		var unpaidLabel = [];
	        var unpaidPrice = [];

       		for(var i=0; i<data.length; i++){
       			unpaidLabel.push(data[i].carNo);
       			unpaidPrice.push(data[i].parkingPrice);
       		}
       		
       		if(data.length < 5){
       			for(i=0; i<5-data.length; i++){
       				unpaidLabel.push("");
       				unpaidPrice.push(0);	
       			}
       		}

	        var chart_func6 = $("#chart6").data("chart_func");
			var chart6 = $("#chart6").data("chart_obj");
			const maxVal = chartMaxVal(unpaidPrice);

			chart_func6.changeLabel(unpaidLabel);
	        chart6.data.datasets = [];

	        chart6.data.datasets.push({
	        	label: "미납금액",
	        	borderColor: ["#d4d2c9","#bcb7b0","#c0cddb","#a4b3c1","#807f7d"],
	            backgroundColor: ["#d4d2c9","#bcb7b0","#c0cddb","#a4b3c1","#807f7d"],
	            data: unpaidPrice
	        });  
	        
	        chart6.options.scales.xAxes[0].stacked = true;
	        chart6.options.scales.xAxes[0].barPercentage = 0.5;
	        chart6.options.plugins.datalabels.formatter = function(value, context) {return null;}

	        chart6.options.tooltips.callbacks = {
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
	        chart6.options.scales.yAxes[0].ticks = {
	        		beginAtZero: true,
	    			suggestedMax: maxVal,
	    			stepSize : maxVal / 5,
	    			minTicksLimit: 5,
	        		callback: function(value, index) {
	        			return value.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",")
	                }
    		};
	        chart6.options.animation.duration = 700;
	        chart6.options.legend = {
	                "display": false,
	                "position":'bottom'
    	    };

	        chart_func6.update();
		}else{
			var chart_func6 = $("#chart6").data("chart_func");
			var chart6 = $("#chart6").data("chart_obj");
			
			chart6.options.scales.yAxes[0].ticks = {
	        		beginAtZero: true,
	    			suggestedMax: 5,
	    			stepSize : 1,
	        		callback: function(value, index) {
	        			return value.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",")
	                }
    		};
	        chart6.options.animation.duration = 700;
	        chart6.options.legend = {
	                "display": false,
	                "position":'bottom'
    	    };

	        chart_func6.update();
		}
    }

    function chartInitialize() {
    	chartdata = {
     		    labels: ["1월","2월","3월","4월","5월","6월","7월","8월","9월","10월","11월","12월"],
     		    datasets: [
     		    	{  
     		            label: "미납금액", 
     		            lineTension: 0.1,
     		            borderColor: '#177d8a',
     		            backgroundColor: '#fff',
     		            pointBackgroundColor: "#177d8a",
     		           	type: 'line',
     		            pointBorderWidth: 1,
     		            pointHoverRadius: 5,
     		            pointHoverBorderWidth: 2,
     		            data: [0,0.0,0,0,0,0,0,0,0,0,0]
     		        },
     		        {
     		            label: "매출/정산액",
     		            lineTension: 0.1,
     		            borderColor: '#dcdbd0',
     		            backgroundColor: '#dcdbd0',
     		            pointBorderColor: "#dcdbd0",
     		            pointBorderWidth: 1,
     		            pointHoverRadius: 5,
     		            pointHoverBorderWidth: 2,
     		            data: [0,0.0,0,0,0,0,0,0,0,0,0]
     		        } 
     		    ]
     		};  
      	 
    		//차트 옵션 설정(X,Y축)
    		var chartOptions = {
    		    scales: { 
    		        xAxes: [ 
    		            {
    		                ticks: {
    		                	fontSize: 10,
    		                    beginAtZero: true
    		                }, 
    		                stacked: true,
    		             	barPercentage: 0.5
    		            }
    		        ],
    	        yAxes: [
	    	        	{
	    	                scaleLabel: {  
	    	                	fontSize: 10,
	    	                    display: true,
	    	                    fontColor: "#000"
	    	                },
   	              			ticks: {
	    	                	padding:10,
	    	                	fontSize: 10,
	    	                	beginAtZero: true,
	    	                    stepSize: 10000,
	    		        		suggestedMax: 1000000,
	    	                    autoSkip: true
   	                		}
	    	        	} 
    	        ]
    	  },
     	  maintainAspectRatio: false,
     	  responsive: true,
  	      legend: {
  	    	"display": "useLegend",
            "position":'bottom'
   		  },
   		  plugins: { 
                 datalabels: {
                     color: ['#000', '#000', '#000', '#000', '#000', '#000', '#000', '#000', '#000', '#000', '#000', '#000'],
                     borderWidth: 2,
                     font:{size:10},
                     borderRadius : 25,
                     anchor: 'center',
                     formatter: function(value, context) {
                     	return null;
                    }
                 },
             }
     	};
     		
    	JsChartBar = new Chart($("#chart"), {
    	    type: 'bar',
    	    data: chartdata,
    	    options: chartOptions
    	});
    	
    	$("#chart").data("chart_obj", chartdata);
		chartevent($("#chart"));
		
		g_Chart2 = $("#chart2").chartHelper({
        	type: "line",
            data: [],           // 데이터
            label: ["1월", "2월", "3월", "4월", "5월", "6월", "7월", "8월", "9월", "10월", "11월", "12월"],          // 라벨
            backgroundColor: "#00ff0000",
            pointStyle : 'line',
            tooltip: true,
            borderWidth: 1,
            pointRadius: 0,
            lineTension: 0,
            fill:false
        });
		
		g_Chart3 = $("#chart3").chartHelper({
        	type: "line",
            data: [],           // 데이터
            label: ["1월", "2월", "3월", "4월", "5월", "6월", "7월", "8월", "9월", "10월", "11월", "12월"],          // 라벨
            backgroundColor: 'rgba(36, 145, 255, 0.5)',
            pointStyle : 'line',
            tooltip: true,
            borderWidth: 2,
            pointRadius: 0,
            lineTension: 0,
            fill:true,
        });
		
		
		g_Chart4 = $("#chart4").chartHelper({
        	type: "line",
            data: [],           // 데이터
            label: labelArrayDate,          // 라벨
            backgroundColor: '#454e5a', 
            pointStyle : 'line',
            tooltip: true,
            borderWidth: 2,
            pointRadius: 0,
            lineTension: 0,
            fill:true,
        });
		
		g_Chart5 = $("#chart5").chartHelper({
            type: "bar",        // 바 차트
            data: [],           // 데이터
            label: ["", "", "", "", ""],          // 라벨 
            backgroundColor: ["#177d8a","#ccd2da","#d4d2c9","#b3b3ad","#646e7a"],
            borderColor: ["#177d8a","#ccd2da","#d4d2c9","#b3b3ad","#646e7a"],
            tooltip: true,
            borderWidth: 1,
            pointRadius: 0,
            lineTension: 0,
            fill:false,
        });  
		
// 		g_Chart5 = new Chart($("#chart5"), {
//    		    type: 'pie',
//    		    data: { 
//    		        labels: ["데이터없음"],
//    		        datasets: [{
//    		            label: 'Number of votes',
//    		            data: [100],
//    		            backgroundColor: ["#177d8a","#ccd2da","#d4d2c9","#b3b3ad","#646e7a"],
//    		            borderColor: ["#177d8a","#ccd2da","#d4d2c9","#b3b3ad","#646e7a"],
//    		            borderWidth: 1
//    		        }]
//    		    },
//    		    options: {  
//    		    	layout: {  
//    		            padding: 30 
//    		        }, 
//    		        title: { 
//    		            display: false
//    		        }, 
//    		        legend: {
//    		        	display:false
//    		        }, 
//              	plugins: { 
             		
//              		datalabels: {
// 	                    color: [],
// 	                    borderWidth: 2,
// 	                    borderRadius : 25,
// 	                    anchor: 'center',
// 	                    formatter: function(value, context) {
// 	                     	return null;
// 	                    }
// 	                },           
//                     outlabels: {   
//                         color: '#000',
//                         backgroundColor: ["#00ff0000","#00ff0000","#00ff0000","#00ff0000","#00ff0000"],
//                         stretch: 5,     
//                         font: {  
//                         	   family: ['Pretendard', '돋움', 'dotum'], 
//                             resizable: true,
//                             minSize: 12,
//                             maxSize: 12
//                         },
//                         text: "%l (%v)"
//                      }
// 	             }, 
// 	             maintainAspectRatio: true,
// 	   	   		 responsive: false,
// 	   	   		 tootip: false
//    		    } 
//    		}); 
		
// 		$("#chart5").data("chart_obj", g_Chart5);
// 		chartevent($("#chart5"));
		
		g_Chart6 = $("#chart6").chartHelper({
            type: "bar",        // 바 차트
            data: [],           // 데이터
            label: ["", "", "", "", ""],          // 라벨 
            backgroundColor: ["#d4d2c9","#bcb7b0","#c0cddb","#a4b3c1","#807f7d"],
            borderColor: ["#d4d2c9","#bcb7b0","#c0cddb","#a4b3c1","#807f7d"],
            tooltip: true,
            borderWidth: 1,
            pointRadius: 0,
            lineTension: 0,
            fill:false,
        });  
	} 
	
    function chartevent(chart) {
        chart.data("chart_func", {
            // 변경내용 적용
            update: function() {
                chart.data("chart_obj").update();
            },
            reload: function() {
                loadDataFunc.call(null);
            },
            // 데이터 변경
            changeData: function(p_Data,idx) {
                chart.data("chart_obj").data.datasets[idx].data = p_Data;
                var chart_data = chart.data("chart_data");
                chart_data["data"] = p_Data;
                obj.data("chart_data", chart_data);
            },
            // X축 라벨 변경
            changeLabel: function(p_Label) {
                chart.data("chart_obj").data.labels = p_Label;
                var chart_data = chart.data("chart_data");
                chart_data["label"] = p_Label;
                obj.data("chart_data", chart_data);
            },
            // 그래프의 배경색(ex:막대 그래프의 배경색) 변경
            changeBackgroundColor: function(p_Color,idx) {
                chart.data("chart_obj").data.datasets[idx].backgroundColor = p_Color;
            },
            // 그래프의 선색 변경
            changeBorderColor: function(p_Color,idx) {
                chart.data("chart_obj").data.datasets[idx].borderColor = p_Color;
            },
            // 그래프의 선 두께 변경
            changeBorderWidth: function(p_Width,idx) {
                chart.data("chart_obj").data.datasets[idx].borderWidth = p_Width;
            },
            // 한 칸에서 하나의 그래프가 차지하는 비율 변경
            changeChartBarPercentage: function(p_Percentage,idx) {
                chart.data("chart_obj").data.datasets[idx].borderWidth = p_Percentage;
            },
        });
    }
    
    function loadCombo() {
        var frm = $("#frmMain");
		frm.addParam("func", "IQ_Combo");
        frm.addParam("query_id", "index.index.select_parkInfo");
        frm.addParam("dataType", "json");
		frm.request();
    }

    function handleIQ_Combo(data, textStatus, jqXHR) {
    	if(data.length > 0){
    		var item = "";
    		
    		$("#kParkingName").children().remove();
    		
    		for(var i=0; i<data.length; i++){
    			item += "<option value='" + data[i].value + "'>" + data[i].text + "</option>";
    		}
    		
    		$("#kParkingName").append(item);
    		
    	}
    	
    	chartInitialize();
		loadChartData();
		loadChartData2();
		loadChartData3();
		loadChartData4();
		loadChartData5();
		loadChartData6();
    }
    
    function chageInit(){
    	var height = $("canvas").height();
		$("canvas").width("100%");
		
    	$(".card-block:eq(0)").children().remove();
		$(".card-block:eq(0)").append("<canvas id='chart' ></canvas>");
		$("canvas").height(height);
		chartdata = {
     		    labels: ["1월","2월","3월","4월","5월","6월","7월","8월","9월","10월","11월","12월"],
     		    datasets: [
     		    	{  
     		            label: "미납금액",
     		            type: "line",
     		            lineTension: 0.1,
     		            borderColor: '#177d8a',
     		            pointBackgroundColor: "#177d8a",
     		            backgroundColor: '#fff',
     		            pointBorderWidth: 1,
     		            pointHoverRadius: 5,
     		            pointHoverBorderWidth: 2,
     		            data: [0,0.0,0,0,0,0,0,0,0,0,0],
     		            yAxisID: 'A'
     		        }, 
     		        {
     		            label: "매출/정산액",
     		            type: "bar", 
     		            lineTension: 0.1,
     		            borderColor: '#dcdbd0',
     		            backgroundColor: '#dcdbd0',
     		            pointBorderColor: "#dcdbd0",
     		            pointBorderWidth: 1,
     		            pointHoverRadius: 5,
     		            pointHoverBorderWidth: 2,
     		            data: [0,0.0,0,0,0,0,0,0,0,0,0],
     		            yAxisID: 'A'
     		        }  
     		    ]
     		}; 
      	 
		//차트 옵션 설정(X,Y축)
		var chartOptions = {
    		    scales: { 
    		        xAxes: [ 
    		            {
    		                ticks: {
    		                	fontSize: 10,
    		                    beginAtZero: true
    		                }, 
    		                stacked: true,
    		             	barPercentage: 0.5
    		            }
    		        ],
    	        yAxes: [
	    	        	{
	    	        		id: 'A',
	    	        		position: 'left',
	    	                scaleLabel: {  
	    	                	fontSize: 10,
	    	                    display: true,
	    	                    fontColor: "#000"
	    	                },
   	              			ticks: {
	    	                	padding:10,
	    	                	fontSize: 10,
	    	                	stepSize: 10000,
	    	                    min: 0,
	    	                    autoSkip: true
   	                		},
   	                		stacked: true
	    	        	}
    	        ]
    	  },
     	  maintainAspectRatio: false,
     	  responsive: true,
  	      legend: {
  	    	"display": "useLegend",
            "position":'bottom'
   		  },
   		  plugins: { 
                 datalabels: {
                     color: ['#000', '#000', '#000', '#000', '#000', '#000', '#000', '#000', '#000', '#000', '#000', '#000'],
                     borderWidth: 2,
                     font:{size:10},
                     borderRadius : 25,
                     anchor: 'center',
                     formatter: function(value, context) {
                     	return null;
                    }
                 },
             }
     	};
     		
    	JsChartBar = new Chart($("#chart"), {
    	    type: 'bar',
    	    data: chartdata,
    	    options: chartOptions
    	});
    	
    	$("#chart").data("chart_obj", chartdata);
		chartevent($("#chart"));
	
		g_Chart3 = $("#chart3").chartHelper({
        	type: "line",
            data: [],           // 데이터
            label: ["1월", "2월", "3월", "4월", "5월", "6월", "7월", "8월", "9월", "10월", "11월", "12월"],          // 라벨
            backgroundColor: 'rgba(36, 145, 255, 0.5)',
            pointStyle : 'line',
            tooltip: true,
            borderWidth: 1,
            pointRadius: 0,
            lineTension: 0,
            fill:true,
        });
		
		g_Chart4 = $("#chart4").chartHelper({
        	type: "line",
            data: [],           // 데이터
            label: labelArrayDate,          // 라벨
            backgroundColor: 'rgba(36, 145, 255, 0.5)',
            pointStyle : 'line',
            tooltip: true,
            borderWidth: 1,
            pointRadius: 0,
            lineTension: 0,
            fill:true,
        });			
		
		loadChartData();
		loadChartData3();
		loadChartData4();
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
		var roleName = '<%=session.getAttribute("role_name")%>'
		$(".card-header h5").eq(2).text(moment().format('YYYY') + "년 " + moment().format('MM') + "월 시간대별 주차장 이용현황");
		$(".card-header h5").eq(3).text(moment().format('YYYY') + "년 " + moment().format('MM') + "월 " + roleName + " 주차현황 TOP5");
		$(".card-header h5").eq(4).text(moment().format('YYYY') + "년 " + roleName + " 미납차량 TOP5");
		$(".card-header h5").eq(5).text(moment().format('YYYY') + "년 " + "접속자 이용 현황"); 
		
		$("#mobile-collapse").trigger("click");

		var height = ($(window).height() - 58 - 39 - (75 * 3)) /2 - ($(".select_ctn").innerHeight() - 20); 
		$("canvas").height(height); 
		$("canvas").width("100%");

		$("#kParkingName").on("change", function(e) {
			chageInit();
		});
		
// 		$("#kParkingName3").on("change", function(e) {
			
// 			g_Chart3 = $("#chart3").chartHelper({
// 	        	type: "line",
// 	            data: [],           // 데이터
// 	            label: ["1월", "2월", "3월", "4월", "5월", "6월", "7월", "8월", "9월", "10월", "11월", "12월"],          // 라벨
// 	            backgroundColor: 'rgba(36, 145, 255, 0.5)',
// 	            pointStyle : 'line',
// 	            tooltip: true,
// 	            borderWidth: 1,
// 	            pointRadius: 0,
// 	            lineTension: 0,
// 	            fill:true,
// 	        });
			
// 			loadChartData3();
// 		});
		
// 		$("#kParkingName4").on("change", function(e) {

// 			g_Chart4 = $("#chart4").chartHelper({
// 	        	type: "line",
// 	            data: [],           // 데이터
// 	            label: labelArrayDate,          // 라벨
// 	            backgroundColor: 'rgba(36, 145, 255, 0.5)',
// 	            pointStyle : 'line',
// 	            tooltip: true,
// 	            borderWidth: 1,
// 	            pointRadius: 0,
// 	            lineTension: 0,
// 	            fill:true,
// 	        });			
			
// 			loadChartData4();
// 		});

// 		$("#kParkingName").html($("#kParkingNo").html());
// 		$("#kParkingName3").html($("#kParkingNo").html());
// 		$("#kParkingName4").html($("#kParkingNo").html());

		// 전체 관리
		$("#btnAllManage").on("click", function(){
        	OpenPopupSingle("/member/memberFullManagePopup.do", 1900, 960, "_Pop13");
        });
 
		loadCombo();
	});
</script>

<div class="page-body" style="font-size: 0.9em;">
	<div class="select_wrap">
		<div class="card">
			<div class="select_ctn">
				<div class="select_cont">
					<label for="select_box">주차장</label>
					<select name="kParkingName" id="kParkingName" class="select">
					</select>
				</div>
				<div class="button_cont">
					<button type="button" id="btnAllManage" class="btn btn-sm waves-effect waves-light btn-primary btn-outline-primary default"> 
						<span class="icofont icofont-search"></span> 
						&nbsp;차량 모니터링
					</button>
				</div>
			</div>
		</div>
	</div>
	<div class="row">
		<div class="search-area col-lg-12" hidden="hidden">
			<form id="frmMain" name="frmMain" method="post" onsubmit="return false" class="form-material form-inline">
				<form:select id="kParkingNo" caption="주차장" queryId="index.index.select_parkInfo"/>
				<form:input type="hidden" id="hParkingName" />
				<form:input type="hidden" id="hParkingName3" />
				<form:input type="hidden" id="hParkingName4" />
				<form:input type="hidden" id="hParkingName5" />
				<form:input type="hidden" id="hParkingName6" />
			</form>
		</div>
		<div class="col-xl-4 col-lg-6 col-md-12 col-sm-12 col-12">
			<card:open title="월별 매출 대비 미납 현황" />
				<card:toolButton title="L00087">
				</card:toolButton>
				<card:content />
                <canvas id="chart" ></canvas>
			<card:close />
		</div>
		<div class="col-xl-4 col-lg-6 col-md-12 col-sm-12 col-12">
			<card:open title="일자별 주차장 현황" />
				<card:toolButton title="L00087">
				</card:toolButton>
				<card:content />
                <canvas id="chart4" ></canvas>
			<card:close />
		</div>
		<div class="col-xl-4 col-lg-6 col-md-12 col-sm-12 col-12">
			<card:open title="월별 미납 현황" />
				<card:toolButton title="L00087">
				</card:toolButton>
				<card:content />
                <canvas id="chart3" ></canvas>
			<card:close />
		</div>
		<div class="col-xl-4 col-lg-6 col-md-12 col-sm-12 col-12">
			<card:open title="주차현황 TOP5" />
				<card:toolButton title="L00087">
				</card:toolButton>
				<card:content />
                <canvas id="chart5" ></canvas>
			<card:close />
		</div>
		<div class="col-xl-4 col-lg-6 col-md-12 col-sm-12 col-12">
			<card:open title="미납차량 TOP5" />
				<card:toolButton title="L00087">
				</card:toolButton>
				<card:content />
                <canvas id="chart6" ></canvas>
			<card:close />
		</div>
		<div class="col-xl-4 col-lg-6 col-md-12 col-sm-12 col-12">
			<card:open title="웹접속자 이용 현황" />
				<card:toolButton title="L00087">
				</card:toolButton>
				<card:content />
                <canvas id="chart2" ></canvas>
			<card:close />
		</div>
	</div>
</div>

<%@ include file="./include/footer.jsp" %>
