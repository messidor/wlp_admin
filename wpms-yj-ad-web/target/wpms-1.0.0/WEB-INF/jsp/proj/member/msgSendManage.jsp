<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="form" uri="http://ad.its.yeongju.kr/jsp/jstl/form" %>
<%@ taglib prefix="card" uri="http://ad.its.yeongju.kr/jsp/jstl/card" %>
<%@ taglib prefix="func" uri="http://ad.its.yeongju.kr/jsp/jstl/func" %>

<%@ include file="../../core/include/head.jsp" %>
<%@ include file="../../core/include/header.jsp" %>

<style type="text/css">
#loading_message {
    position: absolute;
    width: 100%;
    text-align: center;
    top: calc(50% + 40px);
    display: block;
    font-weight: bold;
    font-size: 1.5em;
    opacity: 1.0;
    color: white;
    z-index: 999999;
    display:none;
}
#loading_message span {
    background-color:transparent;
    padding:5px;
}
</style>
<script type="text/javascript">

    // 데이터 복원 시 사용할 원본 데이터 변수
    var _originData;

	var includeCnt = 0;
	var totalCnt = 0;
	var successCnt = 0;
	var failCnt = 0;
	var memberName = [];
	var memberPhone = [];
	var memberId = [];

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
        setColumn(["confirmYn", "confirmYn", "center", 60],[],true),
        setColumn(["memberId", "memberId", "center", 60],[],true),
        setColumn(["includeValue", "선택", "center", 60 ], [ true,[ "check" ], false, "", "20" ], false, false, false, ""),
        setColumn(["memberId", "ID", "left", 110]),
        setColumn(["memberName", "이름", "center", 110]),
        setColumn(["memberPhone", "전화번호", "center", 100]),
        setColumn(["memberEmail", "이메일", "left", 200]),
        setColumn(["memberGubn", "회원구분", "center", 120]),
        setColumn(["carYn", "차량등록여부", "center", 80]),
        setColumn(["creditYn", "카드등록여부", "center", 80]),
        setColumn(["confirmDt", "가입일시", "center", 130])
    ];

	// setColumnMask(컬럼옵션변수, 컬럼명, 타입, 추가옵션)
	setColumnMask(columnDefs, "memberPhone", "phone");

    // 컬럼정의 / 화면에 그리드 맞추기 / 행추가 func
    var _gridHelper = new initGrid(columnDefs, true);
    var gridOptions = _gridHelper.setGridOption();
    
	function loadTableData() {
    	var frm = $("#frmMain");
        //---- 그리드 조회 시 필수요소 start
        frm.addParam("result", $("#myGrid"));       // 그리드 태그
        frm.addParam("grid", "gridOptions");        // 그리드 옵션
        frm.addParam("baseData", "_originData");    // 그리드 원본 데이터 저장 변수
        //---- 그리드 조회 시 필수요소 end
		frm.addParam("func", "IQ");
		frm.addParam("enc_col", "kMemberName,kMemberPhone,kMemberEmail");
        frm.addParam("query_id", "member.msgSendManage.select_list");
        frm.addParam("dataType", "json");           // 그리드 불러오는 타입 (기본 json)
		frm.request();
    }

    function handleIQ(data, textStatus, jqXHR) {}
    
	
	function saveData() {
		$.ajax({
			method: "post",
			url: "<c:url value='/member/msgSendManage.do' />",
			data: {
			    "memberId": memberId[totalCnt],
			    "memberName": memberName[totalCnt],
			    "memberPhone": memberPhone[totalCnt],
			    "hMsgTitle": $("#hMsgTitle").val(),
			    "hContent": $("#hContent").val()
			},
			success : function(data, textStatus, jqXHR) {
			    if (data.count == 0) {
			        alert(data.message);
			    } else {
			    	totalCnt++;
			    	successCnt++;
			    }
			},
			error: function(data, textStatus, jqXHR){
		    	totalCnt++;
		    	failCnt++;
			    alert(data);
			},
			complete : function(){
			    let pcnt = 0;
			    if(memberId.length > 0) {
			        pcnt = (totalCnt + failCnt) * 100 / memberId.length;
	                if(pcnt > 100) {
	                    pcnt = 100;
	                }
	                pcnt = pcnt.toFixed(1);
			    }
			    changeLoadingMsg("진행중 " + pcnt + "% (" + (totalCnt + failCnt + 0) + " / " + memberId.length + ")");
		    	if(totalCnt == includeCnt){
		    	    setTimeout(function() {
		    	        window.location.replace("<c:url value='/member/msgSendManage.do' />");
		    	    }, 500);
		    	}else{
		    	    saveData();
		    	}
			},
			dataType: "json"
		});
	}
	
	// 로딩 이미지 보여주거나 숨기기 (true 보여주기, false 숨겨주기)
	// 원래 동작을 바꾸기 위해 이 페이지에 선언함
	function changeLoadingImageStatus(p_IsShow) {

	    // 로딩 이미지를 표시해야 하는 경우에만 표시하도록 수정함
	    if(__g_Check_Loading_Display) {

	        if(p_IsShow == true) {
	            if(g_StackLoadingImageStatus > 0) {
	                ++g_StackLoadingImageStatus;
	                //console.log("p_IsShow::" + p_IsShow + "   g_StackLoadingImageStatus::::" + g_StackLoadingImageStatus);
	            } else {
	                $(".theme-loader").css({
	                    "display" : "block"
	                });
	                if($("#loading_message").length > 0) {
                        $("#loading_message").css("display", "block");
                    }
	                ++g_StackLoadingImageStatus;
	                //console.log("p_IsShow::" + p_IsShow + "   g_StackLoadingImageStatus::::" + g_StackLoadingImageStatus);
	            }
	        } else {
	            if(g_StackLoadingImageStatus > 0) {
	                --g_StackLoadingImageStatus;
	                //console.log("p_IsShow::" + p_IsShow + "   g_StackLoadingImageStatus::::" + g_StackLoadingImageStatus);
	                if(g_StackLoadingImageStatus <= 0){
	                    $(".theme-loader").css({
	                        "display" : "none"
	                    });
	                    if($("#loading_message").length > 0) {
	                        $("#loading_message").css("display", "none");
	                    }
	                    g_ShowResultMessageFlag = true;
	                    g_StackLoadingImageStatus = 0;
	                }
	            } else {
	                $(".theme-loader").css({
	                    "display" : "none"
	                });
	                if($("#loading_message").length > 0) {
                        $("#loading_message").css("display", "none");
                    }
	                g_StackLoadingImageStatus = 0;
	                //console.log("p_IsShow::" + p_IsShow + "   g_StackLoadingImageStatus::::" + g_StackLoadingImageStatus);
	            }
	        }

	    }
	}
	
	// 로딩 메시지 영역을 임시로 추가 (SMS 전송을 위함)
	function createMessageDisplayForLoadingIcon() {
        if($("#loading_message").length < 1) {
            $(".theme-loader").after(
                    `<div id="loading_message"><span></span></div>`
            );
        }
    }
    
	// 로딩 메시지 영역에 메시지를 표시한다(html이 아님)
    function changeLoadingMsg(msg) {
        if($("#loading_message").length > 0) {
            $("#loading_message").text(msg);
        }
    }
    
    $(function() {

        var eGridDiv = document.querySelector('#myGrid');
        new agGrid.Grid(eGridDiv, gridOptions);
        
     	// 그리드 툴 버튼 바로 표시
		$("i.open-card-option").trigger("click");

        // frmMain 자동조회
        $("#frmMain").autoSearch(loadTableData);

        // 조회
        $("#btnSearch").click(function(){
            loadTableData();
        });
        
        // SMS 발송
        $("#btnSend").on("click", function(){
        	var gridAllData = _gridHelper.getAllGridData();
        	
        	includeCnt = 0;
        	memberName = [];
        	memberPhone = [];
        	memberId = [];
        	
        	for(var i=0; i<gridAllData.length; i++){
        		if(gridAllData[i]["includeValue"] == "Y"){
        			includeCnt++
        			memberName.push(gridAllData[i]["memberName"]);
        			memberPhone.push(gridAllData[i]["memberPhone"]);
        			memberId.push(gridAllData[i]["memberId"]);
        		}
        	}
        	
        	if(includeCnt > 0){
        		OpenPopupSingle("/member/msgSendManagePopup.do", 650, 500, "_MsgPop");
        	}else{
        		alert("메세지를 전송할 회원을 선택해 주세요.");
        	}
        });

		// 전체 포함
		$("#btnIncludeAll").click(function() {
			// 전체 체크 상태 변경 (컬럼명, 포함 여부(true:포함, false:미포함))
			_gridHelper.changeCheckState("includeValue", true);
		});

		// 전체 미포함
		$("#btnExcludeAll").click(function() {
			// 전체 체크 상태 변경 (컬럼명, 포함 여부(true:포함, false:미포함))
			_gridHelper.changeCheckState("includeValue", false);
		});
		
		createMessageDisplayForLoadingIcon();
        
        loadTableData();
    });
</script>


<div class="page-body" style="font-size: 0.9em;">
	<div class="row">
		<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12" id="search_all_wrapper">
			<card:open title="검색 조건" />
				<card:button>
					<form:button type="Search" id="btnSearch" />
					<form:button type="Send" id="btnSend" caption="발송"/>
				</card:button>
				<card:content />
                <div class="search-area col-lg-12" >
                    <form id="frmMain" name="frmMain" method="post" onsubmit="return false" class="form-material form-inline">
                    	<div class="col-lg-12">
	                    	<form:input id="hMsgTitle" type="hidden" />
	                    	<form:input id="hContent" type="hidden" />
	                    	<form:input id="kMemberName" caption="이름" addAttr="maxlength='20'" />
	                    	<form:input id="kMemberPhone" caption="전화번호" addAttr="maxlength='11'" />
	                    	<form:input id="kMemberEmail" caption="이메일" addAttr="maxlength='200'" />
	                    	<form:select id="kMemberGubn" caption="회원구분" all="true" allLabel="전체" queryId="#MEMBER_GUBN"/>
	                    	<form:select id="kCarYn" caption="차량등록여부" all="true" allLabel="전체" queryId="member.member.select_YesOrNo" value="Y"/>
	                    	<form:select id="kCreditYn" caption="카드등록여부" all="true" allLabel="전체" queryId="member.member.select_YesOrNo" value="Y"/>
                    	</div>             
                    </form>
                    <form id="frmHidden" name="frmHidden" method="post" onsubmit="return false" class="form-material form-inline" style="display: none;">
					</form>
				</div>
			<card:close />
        </div> 
        <div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12">
			<card:open title="회원 목록" />
				<card:toolButton title="L00087">
					<form:button type="IncludeAll" id="btnIncludeAll" wrap="li" />
					<form:button type="ExcludeAll" id="btnExcludeAll" wrap="li" />
				</card:toolButton>
				<card:content />
				<form:grid id="myGrid" />
			<card:close />
        </div>
	</div>
</div>

<%@ include file="../../core/include/footer.jsp"%>
