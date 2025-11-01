<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="form" uri="http://ad.its.yeongju.kr/jsp/jstl/form" %>
<%@ taglib prefix="card" uri="http://ad.its.yeongju.kr/jsp/jstl/card" %>
<%@ taglib prefix="func" uri="http://ad.its.yeongju.kr/jsp/jstl/func" %>
<%@ taglib prefix="label" uri="http://ad.its.yeongju.kr/jsp/jstl/label"%>

<%@ include file="../../core/include/head.jsp" %>
<%@ include file="../../core/include/header.jsp" %>

<style type="text/css">
.control-label {
    width: 135px !important;
}

.inputGroupContainer.label-attached {
    max-width: calc(100% - 135px);
}

.item_form{
    margin: 6px 0;
}
.item-label{
    font-size:14px;
}
</style>

<script type="text/javascript">

    var _originData = [];
    var _originData2 = [];
    
    // 새로운 행 기본값 세팅
    function createNewRowData() {
        var newData = {
            state_col: "C",
            deptId: "",
            deptName : "",
            deptDesc : "",
            codeType: "C",
            useYn : "Y",
    
        };
        return newData;
    }
    
    function createNewRowData2() {
        return {
            state_col: "C",
            recvPhone: "",
            recvName: "",
            useYn: "Y",
            modIdName: "",
            modDt: ""
        };
    }
    
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
        setGubunColumn(100, false, 100),   // 그리드 에디터 사용시(Create,Update,Delete)
        setColumn(["parkingNo", "주차장코드", "center", 100]),
        setColumn(["parkingName", "주차장명", "left", 120]),
//         setColumn(["chkApi", "체크 API", "center", 80], [true, ["select", ${func:codeToJSON(pageContext, 'CHK_API_TYPE')}, "value", "text"]]),
        setColumn(["alertRecvYn", "알림수신여부", "center", 100], [true, ["select", ${func:codeToJSON(pageContext, 'ALERT_RECV_YN')}, "value", "text"]]),
//         setColumn(["alertSendGubn", "알림발송단계", "center", 100], [true, ["select", ${func:codeToJSON(pageContext, 'ALERT_SEND_GUBN')}, "value", "text"]]),
//         setColumn(["alertWarnHour", "알림경고시간", "right", 100], [true, ["text"], false, "", "2"]),
        setColumn(["alertCautHour", "미수신 시간", "right", 100], [true, ["text"], false, "", "2"]),
        setColumn(["alertMuteYn", "알림 미수신 기간 사용 여부", "center", 170], [true, ["select", ${func:codeToJSON(pageContext, 'USE_YN')}, "value", "text"]]),
        setColumn(["alertMuteStartDt", "알림 미수신 기간(시작)", "center", 150], [true, ["date"]], false, false, false, ""),
        setColumn(["alertMuteEndDt", "알림 미수신 기간(종료)", "center", 150], [true, ["date"]], false, false, false, ""),
        setColumn(["modIdName", "수정자", "left", 100]),
        setColumn(["modDt", "수정일시", "center", 150]),
    ];
    
//     setColumnMask(columnDefs, "alertWarnHour", "number", {maxLength : 2});
    setColumnMask(columnDefs, "alertCautHour", "number", {maxLength : 2});
    
    for(var x=0; x<3; x++){
    	columnDefs[x].pinned = "left";
    }
    
    // 그리드 옵션
    var _gridHelper = new initGrid(columnDefs, true, createNewRowData);
    var gridOptions = _gridHelper.setGridOption();
    
    
    var columnDefs2 = [
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
        setGubunColumn(50, false, 50),
        setColumn(["hRecvPhone", "수신자 번호", "center", 110], [], true),
        setColumn(["recvPhone", "수신자 번호", "center", 110], [true, ["text"], false, "", "13"]),
        //setColumn(["recvPhone", "수신자 번호", "center", 110], [function(_params) { return _params.data.checkValue === 'Y' ? false : true }, ["text"], false, "", "13"]),
        setColumn(["recvName", "수신자명", "center", 100], [true, ["text"], false, "", "50"]),
        setColumn(["useYn", "수신여부", "center", 80], [true, ["select", ${func:codeToJSON(pageContext, 'USE_YN')}, "value", "text"]]),
        setColumn(["modIdName", "수정자", "left", 100]),
        setColumn(["modDt", "수정일시", "center", 150]),
    ];
    
    setColumnMask(columnDefs2, "recvPhone", "phone", {maxLength : 13});
    
    // 그리드 옵션
    var _gridHelper2 = new initGrid(columnDefs2, true, createNewRowData2);
    var gridOptions2 = _gridHelper2.setGridOption();
    
    
    function loadTableData() {
        var frm = $("#frmMain");
		frm.addParam("func", "IQ");
        frm.addParam("enc_col", "userId");
        frm.addParam("query_id", "sys.optionManage.select_info");
        frm.addParam("dataType", "json");
		frm.request();
    }

    function handleIQ(data, textStatus, jqXHR) {
        if(data.length > 0){
        	$("#frmMain").formSet(data);
        	$("#frmMain5").formSet(data);
        }
    }
    
    function loadTableDataGrid1() {
        var frm = $("#frmMain2");
        //---- 그리드 조회 시 필수요소 start
        frm.addParam("result", $("#grdApiSetting"));       // 그리드 태그
        frm.addParam("grid", "gridOptions");        // 그리드 옵션
        frm.addParam("baseData", "_originData");    // 그리드 원본 데이터 저장 변수
        //---- 그리드 조회 시 필수요소 end
        frm.addParam("func", "IQ2");
        frm.addParam("query_id", "sys.optionManage.select_ApiSmsRecvStatus");
        frm.addParam("dataType", "json");           // 그리드 불러오는 타입 (기본 json)
        frm.addParam("afterAction", true);
        frm.request();
    }
    
    function handleIQ2(data, textStatus, jqXHR){
    }
    
    function loadTableData3() {
        var frm = $("#frmMain3");
        frm.addParam("func", "IQ3");
        frm.addParam("enc_col", "userId");
        frm.addParam("query_id", "sys.optionManage.select_ApiSmsMessageInfo");
        frm.addParam("dataType", "json");
        frm.request();
    }

    function handleIQ3(data, textStatus, jqXHR) {
        if(data.length > 0){
            $("#frmMain3").formSet(data);
        }
    }
    
    function loadTableDataGrid2() {
        var frm = $("#frmMain4");
        //---- 그리드 조회 시 필수요소 start
        frm.addParam("result", $("#grdApiRecv"));       // 그리드 태그
        frm.addParam("grid", "gridOptions2");        // 그리드 옵션
        frm.addParam("baseData", "_originData2");    // 그리드 원본 데이터 저장 변수
        //---- 그리드 조회 시 필수요소 end
        frm.addParam("func", "IQ_G2");
        frm.addParam("enc_col", "recvPhone,recvName");
        frm.addParam("query_id", "sys.optionManage.select_ApiSmsReceiveUserList");
        frm.addParam("dataType", "json");
        frm.request();
    }

    function handleIQ_G2(data, textStatus, jqXHR) { }

    function saveData() {
        var frm = $("#frmMain");
        frm.addParam("elecAutoYn", $("#elecAutoYn").val());
        frm.addParam("lowPltCfGubn", $("#lowPltCfGubn").val());
        frm.addParam("func", "IS");
        frm.addParam("dataType", "json");
        frm.addParam("reqAction", true);
        frm.setAction("<c:url value='/sys/optionManage.do' />");
        frm.request();
    }

    function handleIS(data, textStatus, jqXHR){
        if(data.count > 0) {
            loadTableData();
        }
    }
    
    // 그리드
    function saveData2() {
        var frm = $("#frmMain2");
        frm.addParam("func", "IS2");
        frm.addParam("grid", "gridOptions.all");        // 그리드 옵션
        frm.addParam("dataType", "json");
        frm.addParam("enc_col", "userId");
        frm.setAction("<c:url value='/sys/optionManageParking.do' />");
        frm.request();
    }
    
    function handleIS2(data, textStatus, jqXHR){
        if(data.count > 0) {
            loadTableDataGrid1();
        }
    }
    
    // 하단
    function saveData3() {
        var frm = $("#frmMain3");
        frm.addParam("func", "IS3");
        frm.addParam("dataType", "json");
        frm.addParam("topContents", $("#topContents").val().trim());
        frm.addParam("middleContents", $("#middleContents").val().trim());
        frm.addParam("bottomContents", $("#bottomContents").val().trim());
        frm.addParam("reqAction", true);
        frm.setAction("<c:url value='/sys/optionManageMsg.do' />");
        frm.request();
    }
    
    function handleIS3(data, textStatus, jqXHR){
        if(data.count > 0) {
            loadTableData3();
        }
    }
    
    function saveData4() {
        var frm = $("#frmMain4");
        frm.addParam("func", "IS4");
        frm.addParam("grid", "gridOptions2.all");        // 그리드 옵션
        frm.addParam("dataType", "json");
        frm.addParam("enc_col", "recvPhone,recvName");
        frm.setAction("<c:url value='/sys/optionManageReceiver.do' />");
        frm.request();
    }
    
    function handleIS4(data, textStatus, jqXHR){
        if(data.count > 0) {
            loadTableDataGrid2();
        }
    }
    
    function saveDataApi() {
        var frm = $("#frmMain5");
        frm.addParam("callApiYn", $("#callApiYn").val());
        frm.addParam("func", "IS_Api");
        frm.addParam("dataType", "json");
        frm.addParam("reqAction", true);
        frm.setAction("<c:url value='/sys/optionApiManage.do' />");
        frm.request();
    }

    function handleIS_Api(data, textStatus, jqXHR){
        if(data.count > 0) {
            loadTableData();
        }
    }

    $(function() {
//     	$("#frmMain5").find(".card").height($("#frmMain").find(".card").height());
    	
        // 그리드 툴 버튼 바로 표시
        $("i.open-card-option").trigger("click");
    
        // 그리드 선언
        var eGridDiv = document.querySelector('#grdApiSetting');
        // 그리드 옵션 초기화
        new agGrid.Grid(eGridDiv, gridOptions);
    
        // 그리드 선언
        var eGridDiv2 = document.querySelector('#grdApiRecv');
        // 그리드 옵션 초기화
        new agGrid.Grid(eGridDiv2, gridOptions2);
    	
        $("#btnSave").click(function(){
            if(confirm("전기자동차 신청 승인 관리를 저장하시겠습니까?")) {
                saveData();
            }
        });
        
        $("#btnApiSave").click(function(){
            if(confirm("API 호출 여부를 저장하시겠습니까?")) {
                saveDataApi();
            }
        });
        
        $("#gridSave").click(function() {
            if(confirm("API 미수신 알림 설정을 저장하시겠습니까?")) {
                saveData2();
            }
        });
        
        $("#toolUndo").click(function() {
            _gridHelper.onUndoSelected();
        });
        
        $("#gridSaveRecv").click(function() {
        	// 수신자번호, 수신자명 체크
        	let list = _gridHelper2.getAllGridData();
        	for(let i=0; i<list.length; i++){
        		if(list[i].recvPhone == ""){
        			notifyDanger("수신자 번호를 입력해 주세요.")
        			return;
        		}
        		
        		if(list[i].recvName == ""){
        			notifyDanger("수신자명을 입력해 주세요.")
        			return;
        		}
        	}
        	
            if(confirm("API 미수신 알림 수신자 목록을 저장하시겠습니까?")) {
                saveData4();
            }
        });
        $("#gridAddRecv").click(function() {
            _gridHelper2.onAddRow();
        });
        $("#gridDeleteRecv").click(function() {
            _gridHelper2.onRemoveSelected();
        });
        $("#gridUndoRecv").click(function() {
            _gridHelper2.onUndoSelected();
        });
        
        $("#btnMsgSave").click(function() {
            if(confirm("API 미수신 알림 메시지 설정을 저장하시겠습니까?")) {
                saveData3();
            }
        });
        
        loadTableData();
        loadTableDataGrid1();
        loadTableData3();
        loadTableDataGrid2();
    });
</script>

<div class="page-body" style="font-size:0.9em;">
    <form id="frmMain2" name="frmMain2" method="post" onsubmit="return false" class="form-horizontal;"></form>
    <form id="frmMain4" name="frmMain4" method="post" onsubmit="return false" class="form-horizontal;"></form>
    <div class="row">
        <div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12">
        	<div class="col-xl-6 col-lg-6 col-md-6 col-sm-6 col-6" style="padding-left: 0px;">
		        <form id="frmMain" name="frmMain" method="post" onsubmit="return false" class="form-horizontal;">
		        	<div>
	                <card:open title="전기자동차 신청 관리" />
	                <form:button type="Save" id="btnSave" caption="저장" className="pull-right" />
	                </div>
	            <card:content />
		            <label:select id="elecAutoYn" caption="승인 구분" size="6" queryId="#ELEC_AUTO_YN" />
		            <label:select id="lowPltCfGubn" caption="신청 가능 등급" size="6" queryId="sys.optionManage.select_lowPltGubn" />
	            <card:close />
	            </form>
            </div>
            </div>
            <div class="col-xl-6 col-lg-6 col-md-6 col-sm-6 col-6" style="padding-right: 0px;">
	            <form id="frmMain5" name="frmMain5" method="post" onsubmit="return false" class="form-horizontal;">
	            	<div>
	                <card:open title="API 호출 여부" />
	                <form:button type="Save" id="btnApiSave" caption="저장" className="pull-right" />
					</div>
	            <card:content />
		            <label:select id="callApiYn" caption="API 호출 여부" size="6" queryId="#USE_YN" />
	            <card:close />
	            </form>
            </div>
            
        </div></div>
    </div>
    
    <div class="row">
        
        <div class="col-xl-9 col-lg-9 col-md-9 col-sm-9 col-12">
            <card:open title="API 미수신 알림 설정" />
                <card:toolButton title="">
                    <form:button type="GridSave" id="gridSave" wrap="li" />
                    <form:button type="RowUndo" id="toolUndo" wrap="li" />
                </card:toolButton>
                <card:content />
                <form:grid id="grdApiSetting" style="height: 300px;" />
            <card:close />
        </div>
        
        <div class="col-xl-3 col-lg-3 col-md-3 col-sm-3 col-12">
            <card:open title="API 미수신 알림 수신자 목록" />
                <card:toolButton title="">
                    <form:button type="GridSave" id="gridSaveRecv" wrap="li" />
                    <form:button type="RowAdd" id="gridAddRecv" wrap="li" />
                    <form:button type="RowDel" id="gridDeleteRecv" wrap="li" />
                    <form:button type="RowUndo" id="gridUndoRecv" wrap="li" />
                </card:toolButton>
                <card:content />
                <form:grid id="grdApiRecv" style="height: 300px;" />
            <card:close />
        </div>
    </div>
    
    <div class="row">
        
        <div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12">
            <form id="frmMain3" name="frmMain3" method="post" onsubmit="return false" class="form-horizontal;">
            <div>
                <card:open title="API 미수신 알림 메시지 설정" />
                <form:button type="Save" id="btnMsgSave" caption="저장" className="pull-right" />
            </div>
            <card:content />
                <label:textarea id="topContents" caption="API 알림 문자 내용<br />(상단)" size="4" className="default" rows="6" addAttr="maxlength='1000';"/>
                <label:textarea id="middleContents" caption="API 알림 문자 내용<br />(중단)" size="4" className="default" rows="6" addAttr="maxlength='1000';"/>
                <label:textarea id="bottomContents" caption="API 알림 문자 내용<br />(하단)" size="4" className="default" rows="6" addAttr="maxlength='1000';"/>
            <card:close />
            </form>
        </div></div>
    </div>
    
</div>
<%@ include file="../../core/include/footer.jsp"%>