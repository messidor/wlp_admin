<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="form" uri="http://ad.its.yeongju.kr/jsp/jstl/form"%>
<%@ taglib prefix="card" uri="http://ad.its.yeongju.kr/jsp/jstl/card"%>
<%@ taglib prefix="func" uri="http://ad.its.yeongju.kr/jsp/jstl/func"%>
<%@ taglib prefix="label" uri="http://ad.its.yeongju.kr/jsp/jstl/label" %>

<%@ include file="../../core/include/head.jsp"%>
<%@ include file="../../core/include/header.jsp"%>

<script type="text/javascript">

	var _originData;
	
	// 컬럼 옵션
	var columnDefs = [
	/*
		[*_field, *_headerName, _align, _width],
		[*_editable, _inputType[(select, check, radio, text("")), _data, _valueName, _textName], _required, _maskType(""(string), "number"), _maxLength("10.5", "5")],
		_hide, _rowDrag, _lockColumn, _addClass

		setColumn_New(
			[ (*필드명), (*헤더명), (정렬), (너비) ],
			[ (*편집여부), (입력종류(배열) [ (종류문자열), (데이터), (value컬럼명), (text컬럼명) ]), (필수여부), (마스크종류), (최대길이) ],
			(숨김여부),
			(row 드래그 여부),
			(고정 여부),
			(추가 클래스명)
		)

		(종류문자열) : "select", "check", "text"
		(최대길이) : 문자열로 입력할 것
	*/
		 setColumn(["number", "번호", "center", 50], [false, ["index", "asc"]]),
		 setColumn(["pGovName", "기관명", "left", 190]),
		 setColumn(["parkingName", "주차장명", "left", 130]),
		 setColumn(["m1", "1월", "right", 90]),
		 setColumn(["m2", "2월", "right", 90]),
		 setColumn(["m3", "3월", "right", 90]),
		 setColumn(["m4", "4월", "right", 90]),
		 setColumn(["m5", "5월", "right", 90]),
		 setColumn(["m6", "6월", "right", 90]),
		 setColumn(["m7", "7월", "right", 90]),
		 setColumn(["m8", "8월", "right", 90]),
		 setColumn(["m9", "9월", "right", 90]),
		 setColumn(["m10", "10월", "right", 90]),
		 setColumn(["m11", "11월", "right", 90]),
		 setColumn(["m12", "12월", "right", 90]),
	];
	
	setColumnMask(columnDefs, "m1", "number");
	setColumnMask(columnDefs, "m2", "number");
	setColumnMask(columnDefs, "m3", "number");
	setColumnMask(columnDefs, "m4", "number");
	setColumnMask(columnDefs, "m5", "number");
	setColumnMask(columnDefs, "m6", "number");
	setColumnMask(columnDefs, "m7", "number");
	setColumnMask(columnDefs, "m8", "number");
	setColumnMask(columnDefs, "m9", "number");
	setColumnMask(columnDefs, "m10", "number");
	setColumnMask(columnDefs, "m11", "number");
	setColumnMask(columnDefs, "m12", "number");
	
	// 그리드 하단
    var BottomcolumnDefs = [
    	setColumn(["number", "번호", "center", 50]),
		setColumn(["pGovName", "기관", "center", 200]),
		setColumn(["parkingName", "주차장명", "center", 130]),
		setColumn(["m1", "1월", "right", 90]),
		setColumn(["m2", "2월", "right", 90]),
		setColumn(["m3", "3월", "right", 90]),
		setColumn(["m4", "4월", "right", 90]),
		setColumn(["m5", "5월", "right", 90]),
		setColumn(["m6", "6월", "right", 90]),
		setColumn(["m7", "7월", "right", 90]),
		setColumn(["m8", "8월", "right", 90]),
		setColumn(["m9", "9월", "right", 90]),
		setColumn(["m10", "10월", "right", 90]),
		setColumn(["m11", "11월", "right", 90]),
		setColumn(["m12", "12월", "right", 90])
    ];
	
    setColumnMask(BottomcolumnDefs, "m1", "number");
	setColumnMask(BottomcolumnDefs, "m2", "number");
	setColumnMask(BottomcolumnDefs, "m3", "number");
	setColumnMask(BottomcolumnDefs, "m4", "number");
	setColumnMask(BottomcolumnDefs, "m5", "number");
	setColumnMask(BottomcolumnDefs, "m6", "number");
	setColumnMask(BottomcolumnDefs, "m7", "number");
	setColumnMask(BottomcolumnDefs, "m8", "number");
	setColumnMask(BottomcolumnDefs, "m9", "number");
	setColumnMask(BottomcolumnDefs, "m10", "number");
	setColumnMask(BottomcolumnDefs, "m11", "number");
	setColumnMask(BottomcolumnDefs, "m12", "number");
	
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
	        parkingName: "",
	        m1: 0,
	        m2: 0,
	        m3: 0,
	        m4: 0,
	        m5: 0,
	        m6: 0,
	        m7: 0,
	        m8: 0,
	        m9: 0,
	        m10: 0,
	        m11: 0,
	        m12: 0
	    }],
	    // hide the header on the bottom grid
	    headerHeight: 0,
	    alignedGrids: [],
	};
	
	var _gridHelper = new initGrid(columnDefs, true);
    var gridOptions = _gridHelper.setGridOption();
    // 그리드 하단
    gridOptions.alignedGrids.push(gridOptionsBottom);
    gridOptionsBottom.alignedGrids.push(gridOptions);
    
	function loadTableData() {

	    var frm = $("#frmMain");
	    //---- 그리드 조회 시 필수요소 start
		frm.addParam("func", "IQ");
		frm.addParam("result", $("#myGrid")); // 그리드 태그
		frm.addParam("grid", "gridOptions"); // 그리드 옵션
		frm.addParam("baseData", "_originData"); // 그리드 원본 데이터 저장 변수
		//---- 그리드 조회 시 필수요소 end
	    frm.addParam("query_id", "status.govBankSalesByMonth.select_govBankSalesList");
		frm.addParam("kYearDate", $("#kYearDate").val());
	    frm.addParam("dataType", "json");           // 그리드 불러오는 타입 (기본 json)
		frm.request();
	}

	function handleIQ(data, textStatus, jqXHR) {
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
        	var temp = "";

        	for(var key in data[i]){
	        	if(data[i].hasOwnProperty(key)){
					if((i == 0 && key != "pGovName") && (i == 0 && key != "parkingName")){
						temp = key.replace("m", "");
						temp = temp + "월";
						labelArray2.push(temp);
					}
					if(key != "pGovName" && key != "parkingName"){
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

       var bottomRow = [{
			pGovName: "합계",
	        parkingName: "",
	        m1: 0,
	        m2: 0,
	        m3: 0,
	        m4: 0,
	        m5: 0,
	        m6: 0,
	        m7: 0,
	        m8: 0,
	        m9: 0,
	        m10: 0,
	        m11: 0,
	        m12: 0
       }];

	    var sum_month1 = 0;
	    var sum_month2 = 0;
	    var sum_month3 = 0;
	    var sum_month4 = 0;
	    var sum_month5 = 0;
	    var sum_month6 = 0;
	    var sum_month7 = 0;
	    var sum_month8 = 0;
	    var sum_month9 = 0;
	    var sum_month10 = 0;
	    var sum_month11 = 0;
	    var sum_month12 = 0;
	
	    $.each(data, function(k, v) {
	        sum_month1 += parseInt(v.m1);
	        sum_month2 += parseInt(v.m2);
	        sum_month3 += parseInt(v.m3);
	        sum_month4 += parseInt(v.m4);
	        sum_month5 += parseInt(v.m5);
	        sum_month6 += parseInt(v.m6);
	        sum_month7 += parseInt(v.m7);
	        sum_month8 += parseInt(v.m8);
	        sum_month9 += parseInt(v.m9);
	        sum_month10 += parseInt(v.m10);
	        sum_month11 += parseInt(v.m11);
	        sum_month12 += parseInt(v.m12);
	    });
	
	    bottomRow[0].m1 = sum_month1;
	    bottomRow[0].m2 = sum_month2;
	    bottomRow[0].m3 = sum_month3;
	    bottomRow[0].m4 = sum_month4;
	    bottomRow[0].m5 = sum_month5;
	    bottomRow[0].m6 = sum_month6;
	    bottomRow[0].m7 = sum_month7;
	    bottomRow[0].m8 = sum_month8;
	    bottomRow[0].m9 = sum_month9;
	    bottomRow[0].m10 = sum_month10;
	    bottomRow[0].m11 = sum_month11;
	    bottomRow[0].m12 = sum_month12;
	
	    gridOptionsBottom.api.setRowData(bottomRow);
		$("#myGrid").height($("#chart").height());
		
        chart_func.update();
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
			$.each(data, function(k, v) {
				$("#kParkingNo").append("<option value='" + v.value + "'>" + v.text + "</option>");			
			});
		}else{
			$("#kParkingNo").parent().parent().show();
		}
	
		loadTableData();
	}
	
	function downExcelData() {
		var frm = $("#frmHidden");
		
		frm.addInput("func", "IQ_Excel");
		frm.addInput("kYearDate", $("#kYearDate").val());
		frm.addInput("hParkingGovCode", $("#kParkingGovCode").val());
		frm.addInput("kParkingNo", $("#kParkingNo").val());
		frm.addInput("query_id", "status.govBankSalesByMonth.select_govBankSalesExcel");
		frm.addInput("type", "govBankSalesByMonth");
		frm.setAction("<c:url value='/common_excel.do'/>");
		frm.removeAttr("onsubmit");
		frm.submit();
		frm.setAction("<c:url value='/common_select.do'/>");
	}

	function handleIQ_Excel(data, textStatus, jqXHR) {}
	
	$(function() {
		var tHeight = ($("#mCSB_1_container_wrapper").innerHeight() - ($(".card").eq(0).height()+15)) / 2 - 131;
		$("#chart").height(tHeight);
		
		let date = new Date();
		let month = ((date.getMonth()+1) < 10 ? "0" + (date.getMonth()+1) : (date.getMonth()+1)) ;

		//일자
		$("#kYearDate").initDateSingle("year");

     	// 조회
        $("#kYearDate").change(function(){
        	chartInitialize();
        });
     	
     	// 조회
        $("#kParkingCompCode").change(function(){
        	chartInitialize();
        });

        // 조회
        $("#btnSearch").click(function(){
        	chartInitialize();
        });
        
        // 그리드 생성
		var eGridDiv = document.querySelector('#myGrid');
		new agGrid.Grid(eGridDiv, gridOptions);
		// 그리드 하단
        var gridDivBottom = document.querySelector('#myGridBottom');
        var gridObj2 = new agGrid.Grid(gridDivBottom, gridOptionsBottom);

        var height = $("#mCSB_1_container_wrapper").outerHeight() - 337;

		$(".card-block").eq(2).css("padding-bottom","0px");
		$(".card-header").eq(2).css("padding-bottom","0px")
		$("canvas").width("100%");
		//$("canvas").height(height);

		$("#kParkingGovCode, #kYearDate, #kLocalGubn, #kParkingNo").on("change", function(e) {
			loadTableData();
		});
		
		$("#kParkingGovCode").on("change", function(e) {
			loadComboData();
		});
		
		// 다운로드
		$("#btnExcel").click(function(){
			if(_gridHelper.getAllGridData().length < 1) {
				alert("조회된 데이터가 없습니다.");
				return false;
			}
			downExcelData();
		});

        chartInitialize();
        loadComboData();
        
     	// 높이 지정
        $("#myGridBottom").css("height", "32px");
        $("#myGrid").children().prop("style","border-bottom:0px");
        $("#myGridBottom").children().prop("style","border-top:0px");
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
					<form:input id="kYearDate" caption="이용연도" addAttr="maxlength='100'" />
					<c:choose>  
						<c:when test="${user_role_id eq 'MANAGE'}"> 
							<form:select id="kParkingGovCode" caption="관리기관" all="false" allLabel="전체" queryId="select.select_parkingGovInfo"/>
							<form:select id="kParkingNo" caption="주차장" all="true" allLabel="전체" queryId="select.select_parkingInfo2"/>
						</c:when> 
						<c:otherwise> 
							<form:select id="kParkingGovCode" caption="관리기관" all="false" allLabel="전체" queryId="select.select_parkingGovInfo"/>
							<form:select id="kParkingNo" caption="주차장" all="true" allLabel="전체" queryId="select.select_parkingInfo2"/>
						</c:otherwise>
					</c:choose>
				</form>
				<form id="frmHidden" name="frmHidden" method="post" onsubmit="return false" class="form-material form-inline" style="display:none;">
				</form>
			</div>
			<card:close />
		</div>
		<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12">
			<card:open title="월별 기관 주차장 매출/정산 집계" />
			<card:content />
            <div class="card-block table-border-style">
				<canvas id="chart" ></canvas>
			</div>
			<card:close />
		</div>
		<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12" style="padding: 0;">
			<card:open title="월별 기관 주차장 매출/정산 집계" />
			<card:toolButton title="">
			</card:toolButton>
			<card:content />
			<form:grid id="myGrid"/>
			<form:grid id="myGridBottom" />
			<card:close />
		</div>
	</div>
</div>

<%@ include file="../../core/include/footer.jsp"%>
