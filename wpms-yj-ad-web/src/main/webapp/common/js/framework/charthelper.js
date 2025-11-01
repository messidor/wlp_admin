$(function() {

    /**
     * chartjs 를 조금 더 편하게 사용하기 위한 함수
     *
     * @param {JSON} param 파라미터
     */
    $.fn.chartHelper = function(param) {

        // 차트 종류 (기본값: "bar")
        var chartType = typeof(param["type"]) != 'undefined' ? param["type"] : "bar";
        // 차트 데이터
        var chartData = typeof(param["data"]) != 'undefined' ? param["data"] : [];
        // 차트 라벨 (X축)
        var chartLabel = typeof(param["label"]) != 'undefined' ? param["label"] : [];
        // 그래프 안쪽 색깔 (단일값은 모두 같은 색깔로 처리하고, 배열은 각각의 그래프를 다르게 처리함)
        var chartBackgroundColor = typeof(param["backgroundColor"]) != 'undefined' ? param["backgroundColor"] : [];
        // 그래프 선 색깔 (단일값은 모두 같은 색깔로 처리하고, 배열은 각각의 그래프를 다르게 처리함)
        var chartBorderColor = typeof(param["borderColor"]) != 'undefined' ? param["borderColor"] : [];
        // 그래프 선 두께 (기본값 1)
        var chartBorderWidth = typeof(param["borderWidth"]) != 'undefined' ? param["borderWidth"] : 1;
        // 차트 라벨 (Y축)
        var chartYAxisLabel = typeof(param["yAxisLabel"]) != 'undefined' ? param["yAxisLabel"] : "";
        // 한 칸에서 하나의 그래프가 차지하는 비율 (기본 0.2)
        var chartBarPercentage = typeof(param["barPercentage"]) != 'undefined' ? param["barPercentage"] : 0.2;
        // 툴팁 사용 여부
        var useToolTip = typeof(param["tooltip"]) != 'boolean' ? true : param["tooltip"];
        // 툴팁 사용 여부
        var useLegend = typeof(param["legend"]) != 'boolean' ? false : param["legend"];
        // 데이터 불러오는 함수
        var loadDataFunc = typeof(param["loadDataFunc"]) != 'function' ? function() {} : param["loadDataFunc"];

        // line tension
        var chartLineTension = typeof(param["lineTension"]) != 'undefined' ? param["lineTension"] : 0;
        // fill
        var chartFill = typeof(param["fill"]) != 'boolean' ? false : param["fill"];

        // 그래프 옵션
        var defaultOptions = {
            responsive: true,
            maintainAspectRatio: false,
            bezierCurve: true,
            tooltips: {
                enabled: useToolTip,
                mode:'index',
                intersect: false
            },
            animation: {
                duration: 0,
                easing: 'linear'
            },
            legend: {
                display: useLegend,
                labels: {
                    fontSize: 12
                },
                position:'bottom'
            },
            scales: {
                xAxes: [{
                    ticks: {
                        maxRotation: 0,
                        minRotation: 0
                    }
                }],
                yAxes: [{
                    scaleLabel: {
                        display: chartYAxisLabel == "" ? false : true,
                        labelString: chartYAxisLabel,
                        fontStyle: "bold",
                        fontColor: "black"
                    },
                    ticks: {
                        beginAtZero: true
                    }
                }]
            }
        }

        var obj = $(this);
        if (obj.data("chart_obj")) {
        	obj.data("chart_obj").reset();
        	obj.data("chart_obj").destroy();
        }
        var chartObj = new Chart(obj, {
            type: chartType,
            data: {
                labels: chartLabel,
                datasets: [{
                    label: "",
                    data: chartData,
                    backgroundColor: chartBackgroundColor,
                    borderColor: chartBorderColor,
                    borderWidth: chartBorderWidth,
                    pointRadius: 0,
                    categoryPercentage: 1.0,
                    barPercentage: chartBarPercentage,
                    lineTension: chartLineTension,
                    fill: chartFill
                }]
            },
            options: defaultOptions
        });

        obj.data("chart_obj", chartObj);

        obj.data("chart_data", {
            data: chartData,
            label: chartLabel
        });

        obj.data("chart_func", {
            // 변경내용 적용
            update: function() {
                obj.data("chart_obj").update();
            },
            reload: function() {
                loadDataFunc.call(null);
            },
            // 데이터 변경
            changeData: function(p_Data) {
                obj.data("chart_obj").data.datasets[0].data = p_Data;
                var chart_data = obj.data("chart_data");
                chart_data["data"] = p_Data;
                obj.data("chart_data", chart_data);
            },
            // X축 라벨 변경
            changeLabel: function(p_Label) {
                obj.data("chart_obj").data.labels = p_Label;
                var chart_data = obj.data("chart_data");
                chart_data["label"] = p_Label;
                obj.data("chart_data", chart_data);
            },
            // 그래프의 배경색(ex:막대 그래프의 배경색) 변경
            changeBackgroundColor: function(p_Color) {
                obj.data("chart_obj").data.datasets[0].backgroundColor = p_Color;
            },
            // 그래프의 선색 변경
            changeBorderColor: function(p_Color) {
                obj.data("chart_obj").data.datasets[0].borderColor = p_Color;
            },
            // 그래프의 선 두께 변경
            changeBorderWidth: function(p_Width) {
                obj.data("chart_obj").data.datasets[0].borderWidth = p_Width;
            },
            // 한 칸에서 하나의 그래프가 차지하는 비율 변경
            changeChartBarPercentage: function(p_Percentage) {
                obj.data("chart_obj").data.datasets[0].borderWidth = p_Percentage;
            },
        });

        // obj.data("chart_func").update();
        loadDataFunc.call(null);
    };

});
