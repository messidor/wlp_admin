<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="form" uri="http://ad.its.yeongju.kr/jsp/jstl/form" %>
<%@ taglib prefix="card" uri="http://ad.its.yeongju.kr/jsp/jstl/card" %>
<%@ taglib prefix="func" uri="http://ad.its.yeongju.kr/jsp/jstl/func" %>

<%@ include file="../../core/include/head.jsp" %>
<%@ include file="../../core/include/header.jsp" %>


<script type="text/javascript">

    // 데이터 복원 시 사용할 원본 데이터 변수
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
        setColumn(["confirmYn", "confirmYn", "center", 60],[],true),
        setColumn(["memberId", "memberId", "center", 60],[],true),
        setColumn(["num", "번호", "center", 50]),
        setColumn(["memberId", "ID", "left", 110]),
        setColumn(["memberName", "이름", "center", 110]),
        setColumn(["memberPhone", "전화번호", "center", 100]),
        setColumn(["memberEmail", "이메일", "left", 200]),
        setColumn(["memberGubn", "회원구분", "center", 120]),
        setColumn(["carYn", "차량등록여부", "center", 80]),
        setColumn(["creditYn", "카드등록여부", "center", 80]),
        setColumn(["reductionYn", "인적감면등록여부", "center", 90]),
//         setColumn(["confirmName", "승인자", "center", 100]),
        setColumn(["confirmDt", "가입일시", "center", 120])
    ];

	// setColumnMask(컬럼옵션변수, 컬럼명, 타입, 추가옵션)
	setColumnMask(columnDefs, "memberPhone", "phone");

    // 컬럼정의 / 화면에 그리드 맞추기 / 행추가 func
    var _gridHelper = new initGrid(columnDefs, true);
    var gridOptions = _gridHelper.setGridOption();
    gridOptions.pagination = true;
	
    _gridHelper.addRowDblClickEvent(function(event) {			
		OpenPopupSingle("/member/memberPopup.do?memberId=" + event.data.memberId + "&confirmYn=" + event.data.confirmYn, 1600, 1000, "_Pop1");
	});
    
	function loadTableData() {
    	var frm = $("#frmMain");
        //---- 그리드 조회 시 필수요소 start
        frm.addParam("result", $("#myGrid"));       // 그리드 태그
        frm.addParam("grid", "gridOptions");        // 그리드 옵션
        frm.addParam("baseData", "_originData");    // 그리드 원본 데이터 저장 변수
        //---- 그리드 조회 시 필수요소 end
		frm.addParam("func", "IQ");
		frm.addParam("enc_col", "kMemberName , kMemberPhone , kMemberEmail");
        frm.addParam("query_id", "member.member.select_list");
        frm.addParam("dataType", "json");           // 그리드 불러오는 타입 (기본 json)
		frm.request();
    }

    function handleIQ(data, textStatus, jqXHR) {}
	
    function saveData() {
	    var frm = $("#frmMain");
	    frm.addParam("func", "IS");
	    frm.addParam("dataType", "json");
	    frm.addParam("grid", "gridOptions.check");
	    frm.setAction("<c:url value='/member/memberUpdate.do' />");
		frm.request();
	}
    
    function handleIS(data, textStatus, jqXHR){
    	loadTableData();
    }
    
	function downExcelData() {
		var frm = $("#frmMain");
		
		frm.addInput("func", "IQ_Excel");
		frm.addInput("hMemberId",$("#hMemberId").val());
		frm.addInput("enc_col", "hMemberId, kMemberName , kMemberPhone , kMemberEmail");
		frm.addInput("endDate", moment().format('YYYY-MM-DD'));
		frm.addInput("query_id", "member.memberPopup.select_user_excel");
		frm.addInput("type", "UserStatusExcel");
		frm.setAction("<c:url value='/common_excel.do'/>");
		frm.removeAttr("onsubmit");
		frm.submit();
		frm.setAction("<c:url value='/common_select.do'/>");
	}

	function handleIQ_Excel(data, textStatus, jqXHR) {}
    
    $(function() {

        // lookup the container we want the Grid to use
        var eGridDiv = document.querySelector('#myGrid');

        // create the grid passing in the div to use together with the columns & data we want to use
        new agGrid.Grid(eGridDiv, gridOptions);
        
        loadTableData();

        // frmMain 자동조회
        $("#frmMain").autoSearch(loadTableData);

        // 조회
        $("#btnSearch").click(function(){
            loadTableData();
        });

        // 저장
        $("#btnApproval").click(function(){
        	if(_gridHelper.getSelectedRows().length < 1){
        		alert("승인 처리할 회원을 선택해 주세요.");
        		return;
        	}
        	
            if(confirm("승인하시겠습니까?")) {
                saveData();
            }
        });
        
        $("#btnExcel").on("click", function(){
            if(_gridHelper.getAllGridData().length < 1) {
				alert("조회된 데이터가 없습니다.");
				return false;
			}
        	downExcelData();
        });
 
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
                <div class="search-area col-lg-12" >
                    <form id="frmMain" name="frmMain" method="post" onsubmit="return false" class="form-material form-inline">
                    	<div class="col-lg-12">
	                    	<form:input id="kMemberName" caption="이름" addAttr="maxlength='20'" />
	                    	<form:input id="kMemberPhone" caption="전화번호" addAttr="maxlength='11'" />
	                    	<form:input id="kMemberEmail" caption="이메일" addAttr="maxlength='200'" />
	                    	<form:select id="kMemberGubn" caption="회원구분" all="true" allLabel="전체" queryId="#MEMBER_GUBN"/>
	                    	<form:select id="kCarYn" caption="차량등록여부" all="true" allLabel="전체" queryId="member.member.select_YesOrNo" size="1" />
	                    	<form:select id="kCreditYn" caption="카드등록여부" all="true" allLabel="전체" queryId="member.member.select_YesOrNo" size="1" />
	                    	<form:select id="kReductionYn" caption="감면등록여부" all="true" allLabel="전체" queryId="member.member.select_YesOrNo" size="1"/>
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
					<form:button type="RowAdd" id="tool_insert" wrap="li" />
					<form:button type="RowDel" id="tool_delete" wrap="li" />
					<form:button type="RowUndo" id="tool_undo" wrap="li" />
				</card:toolButton>
				<card:content />
				<form:grid id="myGrid" />
			<card:close />
        </div>
	</div>
</div>

<%@ include file="../../core/include/footer.jsp"%>
