<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="form" uri="http://ad.its.yeongju.kr/jsp/jstl/form"%>
<%@ taglib prefix="card" uri="http://ad.its.yeongju.kr/jsp/jstl/card"%>
<%@ taglib prefix="func" uri="http://ad.its.yeongju.kr/jsp/jstl/func"%>
<%@ taglib prefix="label" uri="http://ad.its.yeongju.kr/jsp/jstl/label" %>


<%@ include file="../../core/include/head.jsp" %>
<%@ include file="../../core/include/headerPopup.jsp" %>

<style type="text/css">
div.card {padding: 10px;}
body {
    background-color: #fff;
}
.popup-content {
    padding: 0px;
}
.pop_list {
    margin-bottom: 10px;
}
.cont {
    padding: 5px;
}
.pop_list label {
    display: block;
    background-color: #e9f1ff;
    padding: 2px 10px;
    border: 1px solid #dddddd;
    margin: 0px;
    font-size: 0.9em;
}
.pop_btn {
    padding: 0px 15px;
}
#multiFiles {
    display: block;
    width: 100%;
    border: 1px solid #dddddd;
    padding: 2px 10px;
    height: 32px;
}
</style>
<script type="text/javascript" src="<c:url value='/common/js/compressor/compressor-1.2.1.min.js'/>"></script>
<script type="text/javascript" src="<c:url value='/common/js/compressor/compressor.common-1.2.1.js'/>"></script>
<script type="text/javascript" src="<c:url value='/common/js/compressor/compressor.esm-1.2.1.js'/>"></script>
<script type="text/javascript" src="<c:url value='/common/js/etcs/chunkUploadMulti.js'/>"></script>
<script type="text/javascript" src="<c:url value='/common/js/etcs/common.js'/>"></script>
<script type="text/javascript">

    var cuObj;
    var _originData;

    var result_json = [

        <c:forEach var="item" items="${xlsResultList}" varStatus="status">
        {
            "state_col" : "${item.stateCol}",
            "hasError" : "${item.hasError}",
            "hasErrorName" : "${item.hasError == 'T' ? '실패' : '성공'}",
            "isReCheck" : "${item.hasError == 'T' ? 'N' : 'Y'}",
            "isReCheckName" : "${item.hasError == 'T' ? '오류' : '정상'}",
            "errorReason" : "${item.errorReason}",

            "rowNumber" : "${item.rowNumber}",
            "parkingId" : "${item.parkingId}",
            "siteName" : "${item.parkingId}",
            "parkingName" : "${item.parkingName}",
            "gugun" : "${item.gugun}",
            "dong" : "${item.dong}",
            "pGovCode" : "${item.pGovCode}",
            "parkingPost" : "${item.parkingPost}",
            "parkingAddr" : "${item.parkingAddr}",
            "parkingAddr2" : "${item.parkingAddr2}",
            "parkingRoadAddr" : "${item.parkingRoadAddr}",
            "parkingRoadAddr2" : "${item.parkingRoadAddr2}",
            "parkingLatitude" : "${item.parkingLatitude}",
            "parkingLongitude" : "${item.parkingLongitude}",
            "parkingGrade" : "${item.parkingGrade}",
            "parkingTel" : "${item.parkingTel}",
            "parkingSpot" : "${item.parkingSpot}",
            "dpParkingSpot" : "${item.dpParkingSpot}",
            "stdPrice" : "${item.stdPrice}",
            "tenMPrice" : "${item.tenMPrice}",
            "useYn" : "${item.useYn}",
            "mapMarkGubn" : "${item.mapMarkGubn}",
            "manageInfo" : "${item.manageInfo}",
            
            "parkingIdDp" : "${item.parkingId}",
            "siteNameDp" : "${item.parkingId}",
            "parkingNameDp" : "${item.parkingName}",
            "gugunDp" : "${item.gugunName}",
            "dongDp" : "${item.dongName}",
            "pGovNameDp" : "${item.pGovName}",
            "parkingPostDp" : "${item.parkingPost}",
            "parkingAddrDp" : "${item.parkingAddr}",
            "parkingAddr2Dp" : "${item.parkingAddr2}",
            "parkingRoadAddrDp" : "${item.parkingRoadAddr}",
            "parkingRoadAddr2Dp" : "${item.parkingRoadAddr2}",
            "parkingLatitudeDp" : "${item.parkingLatitude}",
            "parkingLongitudeDp" : "${item.parkingLongitude}",
            "parkingGradeDp" : "${item.parkingGrade}",
            "parkingTelDp" : "${item.parkingTel}",
            "parkingSpotDp" : "${item.parkingSpot}",
            "dpParkingSpotDp" : "${item.dpParkingSpot}",
            "stdPriceDp" : "${item.stdPrice}",
            "tenMPriceDp" : "${item.tenMPrice}",
            "useYnDp" : "${item.useYnName}",
            "mapMarkGubnDp" : "${item.mapMarkGubnName}",
            "manageInfoDp" : "${item.manageInfo}",
        },
        </c:forEach>
    ];

    const selectCombo = {
			"query_id" :  "park.generalParkingUploadPopup.select_ExcelUploadGetGugunCombo",
			"params" : ["gugun"],
			"draw_data" : true,
		};
    
    // 컬럼 옵션
    var columnDefs = [
    	
        setGubunColumn(50, false, 50),
        setColumn(["isReCheckName", "재확인", "center", 80], [], false, [], true),
        setColumn(["rowNumber", "행번호", "center", 60], [], false, [], true),
        setColumn(["isReCheck", "H_재확인", "center", 80], [], true),
        setColumn(["hasError", "H_변환여부", "center", 80], [], true),

        setColumn(["hasErrorName", "변환여부", "center", 80]),
        setColumn(["errorReason", "실패 사유", "left", 200]),

        setColumn(["parkingId", "주차장 ID", "left", 120],[true, [], true, "", "5"]),
        setColumn(["parkingIdDp", "주차장 ID(Excel)", "left", 140]),
        
        setColumn(["parkingName", "주차장명", "left", 140],[true, [], true, "", "25"]),
        setColumn(["parkingNameDp", "주차장명(Excel)", "left", 140]),
        
        setColumn(["gugun", "구역(시/군/구)", "center", 100], [true, ["select", ${func:codeToJSON(pageContext, 'RESION')}, "value", "text"], true, "", "20"], false, false, false, ""),
        setColumn(["gugunDp", "구역(시/군/구)(Excel)", "center", 120]),
        
        setColumn(["dong", "구역(읍/면/동)", "center", 100], [true, ["select_ajax", selectCombo, "value", "text"], true, "", "20"], false, false, false, ""),
        setColumn(["dongDp", "구역(읍/면/동)(Excel)", "center", 120]),
        
        setColumn(["pGovCode", "관리기관", "center", 180], [true, ["select", ${func:queryToJSON(pageContext, 'park.generalParkingUploadPopup.select_ExcelUploadGetGov')}, "value", "text"], true, "", "100"], false, false, false, ""),
        setColumn(["pGovNameDp", "관리기관(Excel)", "left", 180]),
        
        setColumn(["parkingPost", "우편번호", "center", 100],[true, [], false, "", "6"]),
        setColumn(["parkingPostDp", "우편번호(Excel)", "center", 120]),
        
        setColumn(["parkingAddr", "지번주소", "left", 160],[true, [], true, "", "50"]),
        setColumn(["parkingAddrDp", "지번주소(Excel)", "left", 160]),
        
        setColumn(["parkingAddr2", "지번상세주소", "left", 120],[true, [], false, "", "50"]),
        setColumn(["parkingAddr2Dp", "지번상세주소(Excel)", "left", 140]),
        
        setColumn(["parkingRoadAddr", "도로명주소", "left", 160],[true, [], true, "", "50"]),
        setColumn(["parkingRoadAddrDp", "도로명주소(Excel)", "left", 160]),
        
        setColumn(["parkingRoadAddr2", "도로명상세주소", "left", 140],[true, [], false, "", "50"]),
        setColumn(["parkingRoadAddr2Dp", "도로명상세주소(Excel)", "left", 140]),
        
        setColumn(["parkingLatitude", "위도", "right", 100],[true, [], false, "", "20"]),
        setColumn(["parkingLatitudeDp", "위도(Excel)", "right", 100]),
        
        setColumn(["parkingLongitude", "경도", "right", 100],[true, [], false, "", "20"]),
        setColumn(["parkingLongitudeDp", "경도(Excel)", "right", 100]),
        
        setColumn(["parkingGrade", "급지", "right", 100],[true, [], true, "", "1"]),
        setColumn(["parkingGradeDp", "급지(Excel)", "right", 100]),
        
        setColumn(["parkingTel", "전화번호", "center", 100],[true, [], true, "", "11"]),
        setColumn(["parkingTelDp", "전화번호(Excel)", "center", 120]),
        
        setColumn(["parkingSpot", "일반주차면수", "right", 120],[true, [], false, "", "11"]),
        setColumn(["parkingSpotDp", "일반주차면수(Excel)", "right", 140]),
        
        setColumn(["dpParkingSpot", "장애인주차면수", "right", 120],[true, [], false, "", "11"]),
        setColumn(["dpParkingSpotDp", "장애인주차면수(Excel)", "right", 150]),
        
        setColumn(["stdPrice", "기본요금(평일)", "right", 140], [true, [], false, "", "11"]),
        setColumn(["stdPriceDp", "기본요금(평일)(Excel)", "right", 140]),
        
        setColumn(["tenMPrice", "10분당요금(평일)", "right", 140], [true, [], false, "", "11"]),
        setColumn(["tenMPriceDp", "10분당요금(평일)(Excel)", "right", 160]),
        
        setColumn(["useYn", "사용여부", "center", 100], [true, ["select", ${func:codeToJSON(pageContext, 'USE_YN')}, "value", "text"], true, "", "20"], false, false, false, ""),
        setColumn(["useYnDp", "사용여부(Excel)", "center", 120]),
        
        setColumn(["mapMarkGubn", "지도표시구분", "center", 120], [true, ["select", ${func:codeToJSON(pageContext, 'MAP_MARK_GUBN')}, "value", "text"], true, "", "20"], false, false, false, ""),
        setColumn(["mapMarkGubnDp", "지도표시구분(Excel)", "center", 140]),
        
        setColumn(["manageInfo", "운영정보", "left", 150],[true, ["textarea"], false, "", "500"]),
        setColumn(["manageInfoDp", "운영정보(Excel)", "left", 150]),
    ];
    
    setColumnMask(columnDefs, "parkingPost", "zip");
    setColumnMask(columnDefs, "parkingLatitude", "number", {decimal: 13});
    setColumnMask(columnDefs, "parkingLongitude", "number", {decimal: 13});
    setColumnMask(columnDefs, "parkingGrade", "number");
    setColumnMask(columnDefs, "parkingSpot", "number");
    setColumnMask(columnDefs, "dpParkingSpot", "number");
    setColumnMask(columnDefs, "stdPrice", "number");
    setColumnMask(columnDefs, "tenMPrice", "number");
    setColumnMask(columnDefs, "parkingTel", "phone");
    

    // 컬럼정의 / 화면에 그리드 맞추기 / 행추가 func
    var _gridHelper = new initGrid(columnDefs, true, null, checkData);
    var gridOptions = _gridHelper.setGridOption();
    gridOptions.pagination = false;

 	function checkData(event) {

        if(event.column.colId == "gugun") {
            // 구군 코드를 바꾸면 동 비움
            let data = event.data;
            data["dong"] = "";
            _gridHelper.__gridOption.api.updateRowData({update: [data]});
        }

        // 수정 시 한 행 씩 데이터 검사
        checkRowData(event.data, event.rowIndex);
    }

    // 성공 여부 표시 색깔
    _gridHelper.__gridOption.columnDefs[4].cellStyle = function(params) {
        switch(params.value) {
            case "성공":
                return {backgroundColor: "#0f0",color:"#000", "text-align" : "center"};
                break;

            case "실패":
                return {backgroundColor: "#f00",color:"#fff", "text-align" : "center"};
                break;

            default:
                return {backgroundColor: "transparent", color: "#000", "text-align" : "center"};
        }
    }

    // 재확인 여부 성공/실패
    _gridHelper.__gridOption.columnDefs[1].cellStyle = function(params) {
        switch(params.value) {
            case "정상":
                return {backgroundColor: "#0f0",color:"#000", "text-align" : "center"};
                break;

            case "오류":
                return {backgroundColor: "#f00",color:"#fff", "text-align" : "center"};
                break;

            default:
                return {backgroundColor: "transparent", color: "#000", "text-align" : "center"};
        }
    }

    function addData() {
        gridOptions.api.updateRowData({ add : result_json });

        _originData = JSON.parse(JSON.stringify(result_json));
        gridOptions.api.setRowData(JSON.parse(JSON.stringify(_originData)));
        gridOptions.setOriginalData(JSON.parse(JSON.stringify(_originData)));
    }

    // 그리드 데이터 받아옴
    function getCheckedExcelData(fk) {
        let frm = $("#frmMain");
        frm.setAction('<c:url value="/park/generalParkingMassRegister.do" />');
        frm.addParam("method", "POST");
        frm.addParam("func", "UP_Reg");
        frm.addParam("dataType", "json");
        frm.addParam("grid", "gridOptions");
        frm.addParam("fileKey", fk);
        frm.request();
    }
    
    // 그리드 데이터 저장 핸들
    function handleUP_Reg(data, textStatus, jqXHR) {
        if(data.data.resultList) {
            // 그리드에 데이터 세팅...
            //result_json = JSON.parse(JSON.stringify(data.data.resultList));
            let xls_data = JSON.parse(JSON.stringify(data.data.resultList));
            
            // 버튼 처리
            if(xls_data.length > 0) {
                $("#btnApply,#btnReset").show();
                $("#btnSave").hide();
            } else {
                $("#btnApply,#btnReset").hide();
                $("#btnSave").show();
            }
            
            for(let i = 0; i < xls_data.length; i++) {
            
	            result_json.push({
		            "state_col" : xls_data[i]["stateCol"],
		            "hasError" : xls_data[i]["hasError"],
		            "hasErrorName" : xls_data[i]["hasError"] == 'T' ? '실패' : '성공',
		            "isReCheck" : xls_data[i]["hasError"] == 'T' ? 'N' : 'Y',
		            "isReCheckName" : xls_data[i]["hasError"] == 'T' ? '오류' : '정상',
		            "errorReason" : xls_data[i]["errorReason"],
		
                    "rowNumber" : xls_data[i]["rowNumber"],
                    "parkingId" : xls_data[i]["parkingId"],
                    "siteName" : xls_data[i]["parkingId"],
                    "parkingName" : xls_data[i]["parkingName"],
                    "gugun" : xls_data[i]["gugun"],
                    "dong" : xls_data[i]["dong"],
                    "pGovCode" : xls_data[i]["pGovCode"],
                    "parkingPost" : xls_data[i]["parkingPost"],
                    "parkingAddr" : xls_data[i]["parkingAddr"],
                    "parkingAddr2" : xls_data[i]["parkingAddr2"],
                    "parkingRoadAddr" : xls_data[i]["parkingRoadAddr"],
                    "parkingRoadAddr2" : xls_data[i]["parkingRoadAddr2"],
                    "parkingLatitude" : xls_data[i]["parkingLatitude"],
                    "parkingLongitude" : xls_data[i]["parkingLongitude"],
                    "parkingGrade" : xls_data[i]["parkingGrade"],
                    "parkingTel" : xls_data[i]["parkingTel"],
                    "parkingSpot" : xls_data[i]["parkingSpot"],
                    "dpParkingSpot" : xls_data[i]["dpParkingSpot"],
                    "stdPrice" : xls_data[i]["stdPrice"],
                    "tenMPrice" : xls_data[i]["tenMPrice"],
                    "useYn" : xls_data[i]["useYn"],
                    "mapMarkGubn" : xls_data[i]["mapMarkGubn"],
                    "manageInfo" : xls_data[i]["manageInfo"],
		            
                    "parkingIdDp" : xls_data[i]["parkingId"],
                    "siteNameDp" : xls_data[i]["parkingId"],
                    "parkingNameDp" : xls_data[i]["parkingName"],
                    "gugunDp" : xls_data[i]["gugun"],
                    "dongDp" : xls_data[i]["dong"],
                    "pGovCodeDp" : xls_data[i]["pGovCode"],
                    "parkingPostDp" : xls_data[i]["parkingPost"],
                    "parkingAddrDp" : xls_data[i]["parkingAddr"],
                    "parkingAddr2Dp" : xls_data[i]["parkingAddr2"],
                    "parkingRoadAddrDp" : xls_data[i]["parkingRoadAddr"],
                    "parkingRoadAddr2Dp" : xls_data[i]["parkingRoadAddr2"],
                    "parkingLatitudeDp" : xls_data[i]["parkingLatitude"],
                    "parkingLongitudeDp" : xls_data[i]["parkingLongitude"],
                    "parkingGradeDp" : xls_data[i]["parkingGrade"],
                    "parkingTelDp" : xls_data[i]["parkingTel"],
                    "parkingSpotDp" : xls_data[i]["parkingSpot"],
                    "dpParkingSpotDp" : xls_data[i]["dpParkingSpot"],
                    "stdPriceDp" : xls_data[i]["stdPrice"],
                    "tenMPriceDp" : xls_data[i]["tenMPrice"],
                    "useYnDp" : xls_data[i]["useYn"],
                    "mapMarkGubnDp" : xls_data[i]["mapMarkGubn"],
                    "manageInfoDp" : xls_data[i]["manageInfo"],
	            });
            }
            addData();
        }
    }

    function filterData(frm) {
        // 필요한 항목만 필터링 처리
        let chk_data_header = [
            "state_col", "isReCheck", "parkingId", "parkingName", "gugun",
            "dong", "pGovCode", "parkingPost", "parkingAddr", "parkingAddr2",
            "parkingRoadAddr", "parkingRoadAddr2", "parkingLatitude", "parkingLongitude", "parkingGrade",
            "parkingTel", "parkingSpot", "dpParkingSpot", "stdPrice", "tenMPrice",
            "useYn", "mapMarkGubn", "manageInfo"
        ];
        let chk_data = {
            "state_col" : [],
            "isReCheck" : [],
            "parkingId" : [],
            "parkingName" : [],
            "gugun" : [],
            "dong" : [],
            "pGovCode" : [],
            "parkingPost" : [],
            "parkingAddr" : [],
            "parkingAddr2" : [],
            "parkingRoadAddr" : [],
            "parkingRoadAddr2" : [],
            "parkingLatitude" : [],
            "parkingLongitude" : [],
            "parkingGrade" : [],
            "parkingTel" : [],
            "parkingSpot" : [],
            "dpParkingSpot" : [],
            "stdPrice" : [],
            "tenMPrice" : [],
            "useYn" : [],
            "mapMarkGubn" : [],
            "manageInfo" : [],
        };
        let grid_data = _gridHelper.getAllGridData();

        for(let i = 0; i < grid_data.length; i++) {
            for(let j = 0; j < chk_data_header.length; j++) {
                chk_data[chk_data_header[j]].push(grid_data[i][chk_data_header[j]]);
            }
        }

        for(let j = 0; j < chk_data_header.length; j++) {
            frm.addParam("grd_" + chk_data_header[j], chk_data[chk_data_header[j]]);
        }
    }

    function applyData() {
        let frm = $("#frmMain");
        frm.removeAttr("action");
        frm.attr("onsubmit", "return false;");

        //filterData(frm);

        frm.addParam("grid", "gridOptions.all");
        frm.addParam("func", "IS_A");
        frm.addParam("dataType", "json");
        frm.addParam("afterAction", false);
        frm.addParam("useChunkDataUpload", true);
        frm.setAction('<c:url value="/park/parkingMassRegisterSave.do" />');
        frm.request();
    }

    function handleIS_A(data, textStatus, jqXHR) {
        if(data["count"] != undefined) {
            if(data["count"] > 0) {
                let obj = $("#resultWrapper");
                obj.empty();

                obj.append("<div>성공 : " + data["data"]["okCount"] + "건" +"</div>");
                obj.append("<div>실패 : " + data["data"]["newErrCnt"] + "건" +"</div>");
                obj.append("<div>재확인 오류 : " + data["data"]["oldErrCnt"] + "건" +"</div>");
                obj.append("<div>전체 : " + data["data"]["totalCount"] + "건" +"</div>");

                $("#btnApply").hide();
                
                // 그리드 숨기기
                $("#myGrid").parent().hide();
                $("#multiFiles").parent().hide();

            }
        } else {
            notifyDanger("오류가 발생하였습니다.");
        }
    }

    // 데이터 변경시 서버로 보내서 해당 데이터가 정상적인지 체크하도록 하는 함수
    function checkRowData(rowData, changeIdx) {
        let frm = $("#frmMain");
        frm.removeAttr("action");
        frm.attr("onsubmit", "return false;");

        frm.addParam("changeIdx", changeIdx);
        frm.addParam("func", "IQ_Chk");
        frm.addParam("dataType", "json");
        frm.addParam("rowData", JSON.stringify(rowData));
        frm.addParam("afterAction", false);
        frm.setAction('<c:url value="/park/parkingRowDataCheck.do" />');
        frm.request();
    }

    function handleIQ_Chk(response, textStatus, jqXHR) {

        if(typeof response.data != 'undefined') {
            let idx = parseInt(response.data["changeIdx"]);
            idx = isNaN(idx) ? -1 : idx;

            if(idx > -1) {
                let row_data = _gridHelper.getGridRowData(idx);

                if(response["data"]["result"] == "T") {
                    row_data["isReCheck"] = "Y";
                    row_data["isReCheckName"] = "정상";
                    row_data["errorReason"] = "";
                } else {
                    row_data["isReCheck"] = "N";
                    row_data["isReCheckName"] = "오류";
                    row_data["errorReason"] = response["data"]["errorMessage"];
                }

                gridOptions.api.updateRowData({ update : [row_data] });
            }

            // 결과에 현재 상태를 요약해서 보여줄 것
        }
    }
    
    function xlsUpload() {
        $("#upload_progress").text("0%");
        cuObj.url = "<c:url value='/park/parkingExcelUpload.do' />"; // URL 설정
        
        let dataObj = $("#frmMain").serializeArray();
        for(let i = 0; i < dataObj.length; i++) {
            cuObj.param[dataObj[i]["name"]] = dataObj[i]["value"];
        }
        cuObj.param["enc_col"] = "userId";
        cuObj.param["fnPrefix"] = "";
        cuObj.param["uploadFolder"] = "xlsTemp/";
        cuObj.goUpload();
    }

    $(function() {
        
        cuObj = new ChunkUploadMulti(document.getElementById("multiFiles")); // upload file 객체를 넣어주어야 함
        cuObj.addFileEvent(); // 초기화 하고 실행해 주어야 함
        cuObj.uploadFileExt = "xls|xlsx"; // 기본값은 "pdf|jpg|jpeg|png|gif|hwp|hwpx|xls|xlsx" 이며, 확장자를 "|" 으로 구분할 것
        cuObj.fileExtChange(); // uploadFileExt 속성을 바꾸고 실행해줘야 함
        cuObj.maxFileSize = 50 * 1024 * 1024;
        cuObj.setFilesLimit(1);
        
        // 파일을 선택하지 않고 업로드 버튼을 누르면 발생하는 이벤트
        cuObj.onNoFileSelected = function() {
            $("#upload_progress").text("0%");
            alert("파일을 선택해 주세요.");
        };
        
        // 모두 성공시 발생하는 함수
        cuObj.onSuccessFunc = function(percent, curIdx, totalIdx, result, textStatus, jqXHR, allPercent) {
            //document.getElementById("result").value = percent + "% (" + (curIdx + 1) + " / " + totalIdx + ") " + result.message;
            $("#upload_progress").text(percent + "% (" + (curIdx) + " / " + totalIdx + ")");
            console.log(result);
            $("#fileRelKey").val(result.data.newFileRelKey);
            $("#fileKey").val(result.data.newFileKey);
            $("#multiFiles").val("");
            getCheckedExcelData(result.data.newFileKey);
        };
        
        // 업로드 과정이 성공적으로 진행되는 도중에 발생하는 함수
        cuObj.onProcessFunc = function(percent, curIdx, totalIdx, result, textStatus, jqXHR, allPercent) {
            //document.getElementById("result").value = allPercent + "%";
            $("#upload_progress").text(allPercent + "%");
        };
        
        // 파일을 선택하면 바로 발생하는 이벤트
        // 업로드 버튼을 비활성화 시켜 누르지 못하게 하는것을 추천
        // file 객체가 파라미터로 넘어오며, return false 하면 선택한 파일이 취소된다.
        cuObj.onBeforeFileChange = function(e, fileList) {
            if(fileList.length + $("p[data-id='viewFile']").length > cuObj.getFilesLimit()) {
                alert("최대 업로드 제한 개수인 " + cuObj.getFilesLimit() + "개를 넘어섰습니다.");
                return false;
            }
            isFileReady = false;
        };
        
        // 파일을 선택한 후 내부 처리를 다 하면 발생하는 이벤트
        // 비활성화된 업로드 버튼을 다시 활성화 시키는 것을 추천
        // file 객체가 파라미터로 넘어온다.
        cuObj.onAfterFileChange = function(e) {
            isFileReady = true;
            alert("업로드 할 준비를 마쳤습니다.");
        };

        // 파일 업로드 도중 오류 발생 (chunk 업로드가 완료되지 않음)
        cuObj.onProcErrorFunc = function(curIdx, totalIdx, result, textStatus, jqXHR) {
            alert("파일 업로드 도중 오류가 발생하였습니다. 다시 시도해 주시기 바랍니다.");
        };

        // 마지막 chunk 업로드시 오류 발생
        cuObj.onFinalErrorFunc = function(curIdx, totalIdx, result, textStatus, jqXHR) {
            alert("파일 업로드 및 저장 도중 오류가 발생하였습니다. 다시 시도해 주시기 바랍니다.");
        };

        // ajax error 오류 발생
        cuObj.onErrorFunc = function(curIdx, totalIdx, result, textStatus, jqXHR) {
            alert("업로드 요청 오류 발생 : " + textStatus);
        };
        
        cuObj.onFileSizeExceed = function(fileObj) {
            alert("파일 업로드 최대 크기를 넘어섰습니다. (최대 " + (cuObj.maxFileSize / 1024 / 1024) + " MB)");
        };
        
        cuObj.onInvalidExtension = function(fileObj) {
            alert("해당 파일은 업로드 할 수 없습니다.\n(가능 파일: " + cuObj.uploadFileExt.replace(/\|/gi, ", ") + ")");
        };
        
        $("#btnClose").click(function() {
            window.close();
        });

        $("#btnSave").click(function() {
        	if($("#multiFiles").val().length > 0){
        		if(confirm("업로드 하시겠습니까?")) {
        		    xlsUpload();
                }
        	}else{
				alert("파일을 선택해주세요.");
        	}

        });

        $("#modalStylePopupDesign .close_btn, #btnClose").click(function() {
            window.close();
        });

        $("#downloadExample").click(function() {
            window.open('<c:url value="/assets/excel/parking_upload_form.xlsx" />');
        });

        var eGridDiv = document.querySelector('#myGrid');
        new agGrid.Grid(eGridDiv, gridOptions);

        _gridHelper.clearData();

        if(result_json.length > 0) {
            addData();
            $("#btnApply,#btnReset").show();
            $("#btnSave").hide();
        } else {
            $("#btnApply,#btnReset").hide();
            $("#btnSave").show();
        }

        $("#btnReset").click(function() {
            if(confirm("초기화 하시겠습니까?")) {
                location.replace('<c:url value="/park/generalParkingUploadPopup.do" />');
            }
        });

        $("#btnApply").click(function() {
        	const allData = _gridHelper.getAllGridData();
        	var bool = true;
        	for(var i=0; i<allData.length; i++){
        		const row = allData[i];
        		if(row.isReCheck != "Y") bool = false;
        	}

        	if(bool){
        		if(confirm("위 결과를 적용 하시겠습니까?")) {
                    applyData();
                }
        	}else{
        		alert("재확인이 모두 정상이어야 업로드를 진행할 수 있습니다.");
        	}
        });

        $("#undo_selected").click(function() {
            _gridHelper.onUndoSelected();
        });

        if(result_json.length > 0) {
            let suc_cnt = 0;
            let err_cnt = 0;
            for(let i = 0; i < result_json.length; i++) {
                if(result_json[i]["hasError"] == "T") {
                    err_cnt++;
                } else {
                    suc_cnt++;
                }
            }
            $("#resultWrapper").append("<div>전체 : " + result_json.length + "건</div>");
            $("#resultWrapper").append("<div>정상 : " + suc_cnt + "건</div>");
            $("#resultWrapper").append("<div>오류 : " + err_cnt + "건</div>");
        }
        <c:choose>
        <c:when test='${not empty xlsChkMsg}'>
        alert("${xlsChkMsg}");
        location.replace("<c:url value='/park/generalParkingUploadPopup.do' />");
        </c:when>
        </c:choose>
        
        <c:choose>
        <c:when test='${not empty xlsResultList}'>
        $("#upload_progress").text("(업로드 완료)");
        </c:when>
        <c:otherwise>
        $("#upload_progress").text("0%");
        </c:otherwise>
        </c:choose>
    });

</script>
<div class="layer_pop" id="modalStylePopupDesign" style="margin:0; padding:0; z-index: inherit">
    <form id="frmMain" name="frmMain" onsubmit="javascript:return false;" method="post" enctype="multipart/form-data">
        <input type="hidden" id="fileRelKey" name="fileRelKey" value="" />
        <input type="hidden" id="fileKey" name="fileKey" value="" />
        <div class="pop_box card_pop_box" style="max-width: 100%; border-radius: 0px;">
            <div class="input_pop">
                <div class="card_box">
                    <div class="card w100p">
                        <strong>엑셀 업로드</strong>
                        <div class="cont">
                            <div class="pop_list w100p">
                                <label for="">양식 다운로드</label>
                                <a href="javascript:;" id="downloadExample" style="padding: 8px; display: inline-block; width: 100%; border:1px solid #dddddd;"><i class="fas fa-arrow-circle-down"></i>&nbsp;주차장 등록</a>
                            </div>
                            <div class="pop_list w100p">
                                <label for="">양식 업로드 <span style="margin-left: 50px; font-weight: bold;">업로드 진행상황: <span id="upload_progress" >0%</span></span></label>
                                <input type="file" id="multiFiles" name="multiFiles" accept=".xls, .xlsx" class="w100p input">
                            </div>
                            <div class="pop_list w100p">
                                <label for="" style="display: flex;justify-content: space-between;flex-wrap: nowrap; color:red;">
                                    <span>엑셀 업로드 데이터 확인</span>
                                    <span>※운영정보  수정 시 줄바꿈(Shift + Enter)</span>
                                </label>
                                <div id="myGrid" class="ag-theme-balham" style="display: block; height: 300px;"></div>
                            </div>
                            <div class="pop_list w100p">
                                <label for="">결과 확인</label>
                                <div id="resultWrapper" style="display:block; width: 100%; padding: 5px 10px; border-radius: 0 0 5px 5px; border: 1px solid #dddddd; font-size: 14px; color: #000; height: 100px;"></div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="pop_btn" style="justify-content: center;">
                    <form:button type="ExcelUpload" id="btnSave" caption="데이터 변환" attr=" style='width: auto; padding-left: 10px; padding-right: 10px;' "  className="bg_save"/>
                    <form:button type="Save" id="btnApply" caption="데이터 저장" attr=" style='width: auto; padding-left: 10px; padding-right: 10px;' "  className="bg_save"/>
                    <form:button type="Search" id="btnReset" caption="초기화" className="bg_delete"/>
                    <form:button type="Close" id="btnClose" className="bg_close"/>
                </div>
            </div>
        </div>
    </form>
</div>

<%@ include file="../../core/include/footerPopup.jsp"%>
