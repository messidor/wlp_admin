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

	
	var columnDefs = [
		setColumn(["number", "번호", "center", 50], [false, ["index", "asc"]]),
		setColumn(["pGovName", "기관명", "left", 200]),
		setColumn(["d1", "1일", "right", 100]),
		setColumn(["d2", "2일", "right", 100]),
		setColumn(["d3", "3일", "right", 100]),
		setColumn(["d4", "4일", "right", 100]),
		setColumn(["d5", "5일", "right", 100]),
		setColumn(["d6", "6일", "right", 100]),
		setColumn(["d7", "7일", "right", 100]),
		setColumn(["d8", "8일", "right", 100]),
		setColumn(["d9", "9일", "right", 100]),
		setColumn(["d10", "10일", "right", 100]),
		setColumn(["d11", "11일", "right", 100]),
		setColumn(["d12", "12일", "right", 100]),
		setColumn(["d13", "13일", "right", 100]),
		setColumn(["d14", "14일", "right", 100]),
		setColumn(["d15", "15일", "right", 100]),
		setColumn(["d16", "16일", "right", 100]),
		setColumn(["d17", "17일", "right", 100]),
		setColumn(["d18", "18일", "right", 100]),
		setColumn(["d19", "19일", "right", 100]),
		setColumn(["d20", "20일", "right", 100]),
		setColumn(["d21", "21일", "right", 100]),
		setColumn(["d22", "22일", "right", 100]),
		setColumn(["d23", "23일", "right", 100]),
		setColumn(["d24", "24일", "right", 100]),
		setColumn(["d25", "25일", "right", 100]),
		setColumn(["d26", "26일", "right", 100]),
		setColumn(["d27", "27일", "right", 100]),
		setColumn(["d28", "28일", "right", 100]),
		setColumn(["d29", "29일", "right", 100]),
		setColumn(["d30", "30일", "right", 100]),
		setColumn(["d31", "31일", "right", 100]),
		
	]; 
	
	var _gridHelper = new initGrid(columnDefs, true);
	var gridOptions = _gridHelper.setGridOption();
	
	columnDefs = setColumnMask(columnDefs, "d1", "number");
	columnDefs = setColumnMask(columnDefs, "d2", "number");
	columnDefs = setColumnMask(columnDefs, "d3", "number");
	columnDefs = setColumnMask(columnDefs, "d4", "number");
	columnDefs = setColumnMask(columnDefs, "d5", "number");
	columnDefs = setColumnMask(columnDefs, "d6", "number");
	columnDefs = setColumnMask(columnDefs, "d7", "number");
	columnDefs = setColumnMask(columnDefs, "d8", "number");
	columnDefs = setColumnMask(columnDefs, "d9", "number");
	columnDefs = setColumnMask(columnDefs, "d10", "number");
	columnDefs = setColumnMask(columnDefs, "d11", "number");
	columnDefs = setColumnMask(columnDefs, "d12", "number");
	columnDefs = setColumnMask(columnDefs, "d13", "number");
	columnDefs = setColumnMask(columnDefs, "d14", "number");
	columnDefs = setColumnMask(columnDefs, "d15", "number");
	columnDefs = setColumnMask(columnDefs, "d16", "number");
	columnDefs = setColumnMask(columnDefs, "d17", "number");
	columnDefs = setColumnMask(columnDefs, "d18", "number");
	columnDefs = setColumnMask(columnDefs, "d19", "number");
	columnDefs = setColumnMask(columnDefs, "d20", "number");
	columnDefs = setColumnMask(columnDefs, "d21", "number");
	columnDefs = setColumnMask(columnDefs, "d22", "number");
	columnDefs = setColumnMask(columnDefs, "d23", "number");
	columnDefs = setColumnMask(columnDefs, "d24", "number");
	columnDefs = setColumnMask(columnDefs, "d25", "number");
	columnDefs = setColumnMask(columnDefs, "d26", "number");
	columnDefs = setColumnMask(columnDefs, "d27", "number");
	columnDefs = setColumnMask(columnDefs, "d28", "number");
	columnDefs = setColumnMask(columnDefs, "d29", "number");
	columnDefs = setColumnMask(columnDefs, "d30", "number");
	columnDefs = setColumnMask(columnDefs, "d31", "number");
	
	// 그리드 하단
    var BottomcolumnDefs = [
    	setColumn(["number", "번호", "center", 50]),
		setColumn(["pGovName", "기관명", "center", 200]),
		setColumn(["d1", "1일", "right", 100]),
		setColumn(["d2", "2일", "right", 100]),
		setColumn(["d3", "3일", "right", 100]),
		setColumn(["d4", "4일", "right", 100]),
		setColumn(["d5", "5일", "right", 100]),
		setColumn(["d6", "6일", "right", 100]),
		setColumn(["d7", "7일", "right", 100]),
		setColumn(["d8", "8일", "right", 100]),
		setColumn(["d9", "9일", "right", 100]),
		setColumn(["d10", "10일", "right", 100]),
		setColumn(["d11", "11일", "right", 100]),
		setColumn(["d12", "12일", "right", 100]),
		setColumn(["d13", "13일", "right", 100]),
		setColumn(["d14", "14일", "right", 100]),
		setColumn(["d15", "15일", "right", 100]),
		setColumn(["d16", "16일", "right", 100]),
		setColumn(["d17", "17일", "right", 100]),
		setColumn(["d18", "18일", "right", 100]),
		setColumn(["d19", "19일", "right", 100]),
		setColumn(["d20", "20일", "right", 100]),
		setColumn(["d21", "21일", "right", 100]),
		setColumn(["d22", "22일", "right", 100]),
		setColumn(["d23", "23일", "right", 100]),
		setColumn(["d24", "24일", "right", 100]),
		setColumn(["d25", "25일", "right", 100]),
		setColumn(["d26", "26일", "right", 100]),
		setColumn(["d27", "27일", "right", 100]),
		setColumn(["d28", "28일", "right", 100]),
		setColumn(["d29", "29일", "right", 100]),
		setColumn(["d30", "30일", "right", 100]),
		setColumn(["d31", "31일", "right", 100]),
    ];

	BottomcolumnDefs = setColumnMask(BottomcolumnDefs, "d1", "number");
	BottomcolumnDefs = setColumnMask(BottomcolumnDefs, "d2", "number");
	BottomcolumnDefs = setColumnMask(BottomcolumnDefs, "d3", "number");
	BottomcolumnDefs = setColumnMask(BottomcolumnDefs, "d4", "number");
	BottomcolumnDefs = setColumnMask(BottomcolumnDefs, "d5", "number");
	BottomcolumnDefs = setColumnMask(BottomcolumnDefs, "d6", "number");
	BottomcolumnDefs = setColumnMask(BottomcolumnDefs, "d7", "number");
	BottomcolumnDefs = setColumnMask(BottomcolumnDefs, "d8", "number");
	BottomcolumnDefs = setColumnMask(BottomcolumnDefs, "d9", "number");
	BottomcolumnDefs = setColumnMask(BottomcolumnDefs, "d10", "number");
	BottomcolumnDefs = setColumnMask(BottomcolumnDefs, "d11", "number");
	BottomcolumnDefs = setColumnMask(BottomcolumnDefs, "d12", "number");
	BottomcolumnDefs = setColumnMask(BottomcolumnDefs, "d13", "number");
	BottomcolumnDefs = setColumnMask(BottomcolumnDefs, "d14", "number");
	BottomcolumnDefs = setColumnMask(BottomcolumnDefs, "d15", "number");
	BottomcolumnDefs = setColumnMask(BottomcolumnDefs, "d16", "number");
	BottomcolumnDefs = setColumnMask(BottomcolumnDefs, "d17", "number");
	BottomcolumnDefs = setColumnMask(BottomcolumnDefs, "d18", "number");
	BottomcolumnDefs = setColumnMask(BottomcolumnDefs, "d19", "number");
	BottomcolumnDefs = setColumnMask(BottomcolumnDefs, "d20", "number");
	BottomcolumnDefs = setColumnMask(BottomcolumnDefs, "d21", "number");
	BottomcolumnDefs = setColumnMask(BottomcolumnDefs, "d22", "number");
	BottomcolumnDefs = setColumnMask(BottomcolumnDefs, "d23", "number");
	BottomcolumnDefs = setColumnMask(BottomcolumnDefs, "d24", "number");
	BottomcolumnDefs = setColumnMask(BottomcolumnDefs, "d25", "number");
	BottomcolumnDefs = setColumnMask(BottomcolumnDefs, "d26", "number");
	BottomcolumnDefs = setColumnMask(BottomcolumnDefs, "d27", "number");
	BottomcolumnDefs = setColumnMask(BottomcolumnDefs, "d28", "number");
	BottomcolumnDefs = setColumnMask(BottomcolumnDefs, "d29", "number");
	BottomcolumnDefs = setColumnMask(BottomcolumnDefs, "d30", "number");
	BottomcolumnDefs = setColumnMask(BottomcolumnDefs, "d31", "number");
	
    var gridOptionsBottom = {
	    defaultColDef: {
	        editable: false,
	        sortable: true,
	        resizable: true,
	        filter: true
	    },
	    columnDefs: BottomcolumnDefs,
	    // we are hard coding the data here, it's just for demo purposes
	    rowData: [{
	        pGovName: "합계",
	        d1: 0,
	        d2: 0,
	        d3: 0,
	        d4: 0,
	        d5: 0,
	        d6: 0,
	        d7: 0,
	        d8: 0,
	        d9: 0,
	        d10: 0,
	        d11: 0,
	        d12: 0,
	        d13: 0,
	        d14: 0,
	        d15: 0,
	        d16: 0,
	        d17: 0,
	        d18: 0,
	        d19: 0,
	        d20: 0,
	        d21: 0,
	        d22: 0,
	        d23: 0,
	        d24: 0,
	        d25: 0,
	        d26: 0,
	        d27: 0,
	        d28: 0,
	        d29: 0,
	        d30: 0,
	        d31: 0
	    }],
	    // hide the header on the bottom grid
	    headerHeight: 0,
	    alignedGrids: [],
	};

    // 그리드 하단
    gridOptions.alignedGrids.push(gridOptionsBottom);
    gridOptionsBottom.alignedGrids.push(gridOptions);
	
	function loadTableData2() {
    	var frm = $("#frmMain");
        //---- 그리드 조회 시 필수요소 start
        frm.addParam("result", $("#myGrid"));       // 그리드 태그
        frm.addParam("grid", "gridOptions");        // 그리드 옵션
        frm.addParam("baseData", "_originData");    // 그리드 원본 데이터 저장 변수
        //---- 그리드 조회 시 필수요소 end
		frm.addParam("func", "IQ_Grid");
		frm.addParam("kUseYear", $("#kYearDate").val());
	    frm.addParam("kUseMonth", $("#kMonthDate").val());
	    frm.addParam("hParkingGovCode", $("#kParkingGovCode").val());
		frm.addParam("query_id", "status.govSalesByDate.select_govSalesByDateList");
        frm.addParam("dataType", "json");           // 그리드 불러오는 타입 (기본 json)
		frm.request();
    }
 
	function handleIQ_Grid(data, textStatus, jqXHR) {
		var bottomRow = [{
	        pGovName: "합계",
	        d1: 0,
	        d2: 0,
	        d3: 0,
	        d4: 0,
	        d5: 0,
	        d6: 0,
	        d7: 0,
	        d8: 0,
	        d9: 0,
	        d10: 0,
	        d11: 0,
	        d12: 0,
	        d13: 0,
	        d14: 0,
	        d15: 0,
	        d16: 0,
	        d17: 0,
	        d18: 0,
	        d19: 0,
	        d20: 0,
	        d21: 0,
	        d22: 0,
	        d23: 0,
	        d24: 0,
	        d25: 0,
	        d26: 0,
	        d27: 0,
	        d28: 0,
	        d29: 0,
	        d30: 0,
	        d31: 0
        }];

	    var sum_day1 = 0;
	    var sum_day2 = 0;
	    var sum_day3 = 0;
	    var sum_day4 = 0;
	    var sum_day5 = 0;
	    var sum_day6 = 0;
	    var sum_day7 = 0;
	    var sum_day8 = 0;
	    var sum_day9 = 0;
	    var sum_day10 = 0;
	    var sum_day11 = 0;
	    var sum_day12 = 0;
	    var sum_day13 = 0;
	    var sum_day14 = 0;
	    var sum_day15 = 0;
	    var sum_day16 = 0;
	    var sum_day17 = 0;
	    var sum_day18 = 0;
	    var sum_day19 = 0;
	    var sum_day20 = 0;
	    var sum_day21 = 0;
	    var sum_day22 = 0;
	    var sum_day23 = 0;
	    var sum_day24 = 0;
	    var sum_day25 = 0;
	    var sum_day26 = 0;
	    var sum_day27 = 0;
	    var sum_day28 = 0;
	    var sum_day29 = 0;
	    var sum_day30 = 0;
	    var sum_day31 = 0;
	
	    $.each(data, function(k, v) {
	        sum_day1 += parseInt(v.d1);
	        sum_day2 += parseInt(v.d2);
	        sum_day3 += parseInt(v.d3);
	        sum_day4 += parseInt(v.d4);
	        sum_day5 += parseInt(v.d5);
	        sum_day6 += parseInt(v.d6);
	        sum_day7 += parseInt(v.d7);
	        sum_day8 += parseInt(v.d8);
	        sum_day9 += parseInt(v.d9);
	        sum_day10 += parseInt(v.d10);
	        sum_day11 += parseInt(v.d11);
	        sum_day12 += parseInt(v.d12);
	        sum_day13 += parseInt(v.d13);
	        sum_day14 += parseInt(v.d14);
	        sum_day15 += parseInt(v.d15);
	        sum_day16 += parseInt(v.d16);
	        sum_day17 += parseInt(v.d17);
	        sum_day18 += parseInt(v.d18);
	        sum_day19 += parseInt(v.d19);
	        sum_day20 += parseInt(v.d20);
	        sum_day21 += parseInt(v.d21);
	        sum_day22 += parseInt(v.d22);
	        sum_day23 += parseInt(v.d23);
	        sum_day24 += parseInt(v.d24);
	        sum_day25 += parseInt(v.d25);
	        sum_day26 += parseInt(v.d26);
	        sum_day27 += parseInt(v.d27);
	        sum_day28 += parseInt(v.d28);
	        sum_day29 += parseInt(v.d29);
	        sum_day30 += parseInt(v.d30);
	        sum_day31 += parseInt(v.d31);
	    });
	
	    bottomRow[0].d1 = sum_day1;
	    bottomRow[0].d2 = sum_day2;
	    bottomRow[0].d3 = sum_day3;
	    bottomRow[0].d4 = sum_day4;
	    bottomRow[0].d5 = sum_day5;
	    bottomRow[0].d6 = sum_day6;
	    bottomRow[0].d7 = sum_day7;
	    bottomRow[0].d8 = sum_day8;
	    bottomRow[0].d9 = sum_day9;
	    bottomRow[0].d10 = sum_day10;
	    bottomRow[0].d11 = sum_day11;
	    bottomRow[0].d12 = sum_day12;
	    bottomRow[0].d13 = sum_day13;
	    bottomRow[0].d14 = sum_day14;
	    bottomRow[0].d15 = sum_day15;
	    bottomRow[0].d16 = sum_day16;
	    bottomRow[0].d17 = sum_day17;
	    bottomRow[0].d18 = sum_day18;
	    bottomRow[0].d19 = sum_day19;
	    bottomRow[0].d20 = sum_day20;
	    bottomRow[0].d21 = sum_day21;
	    bottomRow[0].d22 = sum_day22;
	    bottomRow[0].d23 = sum_day23;
	    bottomRow[0].d24 = sum_day24;
	    bottomRow[0].d25 = sum_day25;
	    bottomRow[0].d26 = sum_day26;
	    bottomRow[0].d27 = sum_day27;
	    bottomRow[0].d28 = sum_day28;
	    bottomRow[0].d29 = sum_day29;
	    bottomRow[0].d30 = sum_day30;
	    bottomRow[0].d31 = sum_day31;
		 
		var search_date = $("#kYearDate").val() + '-' + $("#kMonthDate").val(); 
		var last_day = moment(search_date).daysInMonth()+1;
		
		for(var i=1; i<32; i++){
			gridOptions.columnApi.setColumnVisible("d"+i, true);
		}
		
		for(var i=last_day; i<32; i++){
			gridOptions.columnApi.setColumnVisible("d"+i, false);
		}

	    gridOptionsBottom.api.setRowData(bottomRow);
	    $(window).trigger('resize');
		$("#myGrid").height($("#chart").height());
	}
	
	function loadTableData() {

	    var frm = $("#frmMain");
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

	    //---- 그리드 조회 시 필수요소 start
	    //---- 그리드 조회 시 필수요소 end
		frm.addParam("func", "IQ");
	    frm.addParam("query_id", "status.govSalesByDate.select_govSalesByDateList");
		frm.addParam("kUseYear", $("#kYearDate").val());
	    frm.addParam("kUseMonth", $("#kMonthDate").val());
	    frm.addParam("hParkingGovCode", $("#kParkingGovCode").val());
	    frm.addParam("kDayArr", dayArray);
	    frm.addParam("dataType", "json");           // 그리드 불러오는 타입 (기본 json)
		frm.request();
	}

	function handleIQ(data, textStatus, jqXHR) {
		if(data.length > 0) {
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
				labelArray2.push((i+1)+"일");
			}
			
	        chart.data.datasets = [];

	        for(var i=0; i<data.length; i++){

	        	var emisArray = [];

	        	for(var key in data[i]){
		        	if(data[i].hasOwnProperty(key)){
						if(key != "pGovName"){
							emisArray.push(data[i][key]);
						}
		            }
		        }

	        	chart.data.datasets.push({
		            label: data[i].pGovName,
		            borderColor: colorArray[i],
		            backgroundColor: "#00ff0000",
		            data: emisArray,
		            type: 'line',
		            pointStyle : 'circle',
		            borderWidth: 2,
		            pointRadius: 2
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
	           		beginAtZero: true,
	             	minTicksLimit: 5,
	              	maxTicksLimit: 5,
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
		loadTableData2();
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
		frm.addInput("kUseYear", $("#kYearDate").val());
	    frm.addInput("kUseMonth", $("#kMonthDate").val());
	    frm.addInput("hParkingGovCode", $("#kParkingGovCode").val());
		frm.addInput("query_id", "status.govSalesByDate.select_govSalesByDateExcel");
		frm.addInput("type", "govSalesByDate");
		frm.setAction("<c:url value='/common_excel.do'/>");
		frm.removeAttr("onsubmit");
		frm.submit();
		frm.setAction("<c:url value='/common_select.do'/>");
		$("input[name='kDayArr[]']").remove();
	}

	function handleIQ_Excel(data, textStatus, jqXHR) {}

	$(function() {
		var tHeight = ($("#mCSB_1_container_wrapper").innerHeight() - ($(".card").eq(0).height()+15)) / 2 - 140;
		$("#chart").height(tHeight);
		
		let date = new Date();
		let month = ((date.getMonth()+1) < 10 ? "0" + (date.getMonth()+1) : (date.getMonth()+1)) ;
		
		// 그리드 생성
		var eGridDiv = document.querySelector('#myGrid');
		new agGrid.Grid(eGridDiv, gridOptions);
		// 그리드 하단
        var gridDivBottom = document.querySelector('#myGridBottom');
        var gridObj2 = new agGrid.Grid(gridDivBottom, gridOptionsBottom);
	        
		
		//일자
		$("#kYearDate").initDateSingle("year");

     	// 조회
        $("#kParkingGovCode, #kYearDate, #kMonthDate").change(function(){
        	chartInitialize();
        	loadTableData2();
        });
     	
        // 조회
        $("#btnSearch").click(function(){
        	chartInitialize();
        	loadTableData2();
        });

        var height = $("#mCSB_1_container_wrapper").outerHeight() - 337;

		$(".card-block").eq(2).css("padding-bottom","0px");
		$(".card-header").eq(2).css("padding-bottom","0px")
		$("canvas").width("100%");
		//$("canvas").height(height); 

		$("#kMonthDate").val(month);

		// 다운로드
		$("#btnExcel").click(function(){
			if(_gridHelper.getAllGridData().length < 1) {
				alert("조회된 데이터가 없습니다.");
				return false;
			}
			downExcelData();
		});

        chartInitialize();
        
     	// 높이 지정
        $("#myGridBottom").css("height", "49px");
        $("#myGrid").children().prop("style","border-bottom:0px");
        $("#myGridBottom").children().prop("style","border-top:0px");
        
        $(".ag-body-horizontal-scroll").eq(0).css("display", "none");
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
					<c:choose>  
						<c:when test="${fn:contains(user_role_id, 'MANAGE') || fn:contains(user_role_id, 'AD')}"> 
							<form:select id="kParkingGovCode" caption="관리기관" all="true" allLabel="전체" queryId="select.select_parkingGovInfo"/>
						</c:when> 
						<c:otherwise> 
							<form:select id="kParkingGovCode" caption="관리기관" all="false" allLabel="전체" queryId="select.select_parkingGovInfo"/>
						</c:otherwise>
					</c:choose>
				</form>
				<form id="frmHidden" name="frmHidden" method="post" onsubmit="return false" class="form-material form-inline" style="display:none;">
				</form>
			</div>
			<card:close />
		</div>
		<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12">
			<card:open title="일자별 기관 매출/정산 집계" />
			<card:content />
            <div class="card-block table-border-style">
				<canvas id="chart" ></canvas>
			</div>
			<card:close />
		</div>
		<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12" style="padding: 0;">
			<card:open title="일자별 기관 매출/정산 집계 리스트" />
			<card:toolButton title="">
			</card:toolButton>
			<card:content />
			<form:grid id="myGrid" />
			<form:grid id="myGridBottom" />
			<card:close />
		</div>
	</div>
</div>

<%@ include file="../../core/include/footer.jsp"%>
