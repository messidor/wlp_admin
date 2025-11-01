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
        setColumn(["no", "번호", "center", 30], [false, ["index", "asc"]]),
        setColumn(["applyCode", "applyCode", "center", 60],[],true),
        setColumn(["memberId", "memberId", "center", 60],[],true),
        setColumn(["hSeq", "hSeq", "center", 60],[],true),
        setColumn(["carNo", "차량번호", "center", 80]),
        setColumn(["carAlias", "별칭", "left", 110]),
        setColumn(["memberName", "이름", "center", 80]),
        setColumn(["moveCarAlias", "별칭(이관차량)", "left", 110]),
        setColumn(["moveMemberName", "이름(이관차량)", "center", 80]),
        setColumn(["detail", "상세보기", "center", 80], [grdPayGubn, ["button", null, "link", "text", ""] ]),
        setColumn(["confirmName", "처리자", "center", 100]),
        setColumn(["confirmDt", "처리일시", "center", 130])
    ];



    // 컬럼정의 / 화면에 그리드 맞추기 / 행추가 func
    var _gridHelper = new initGrid(columnDefs, true);
    var gridOptions = _gridHelper.setGridOption();
    
    function grdPayGubn(e, data) {
    	OpenPopupSingle("/member/carMoveRecordPopup.do?memberId=" + data.memberId + "&applyCode=" + data.applyCode + "&carNo=" + data.carNo + "&hSeq=" + data.hSeq, 950, 805, "_Pop2");
	}

	function loadTableData() {
    	var frm = $("#frmMain");
        //---- 그리드 조회 시 필수요소 start
        frm.addParam("result", $("#myGrid"));       // 그리드 태그
        frm.addParam("grid", "gridOptions");        // 그리드 옵션
        frm.addParam("baseData", "_originData");    // 그리드 원본 데이터 저장 변수
        //---- 그리드 조회 시 필수요소 end
		frm.addParam("func", "IQ");
		frm.addParam("enc_col", "kMemberName");
        frm.addParam("query_id", "member.carMoveRecord.select_list");
        frm.addParam("dataType", "json");           // 그리드 불러오는 타입 (기본 json)
		frm.request();
    }

    function handleIQ(data, textStatus, jqXHR) {}

    
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
        
        $("#kConfirmYn").change(function(){
        	loadTableData();
        });
        
        loadTableData();
    });
</script>


<div class="page-body" style="font-size: 0.9em;">
	<div class="row">
		<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12" id="search_all_wrapper">
			<card:open title="검색 조건" />
				<card:button>
					<form:button type="Search" id="btnSearch" />
				</card:button>
				<card:content />
                <div class="search-area col-lg-12" >
                    <form id="frmMain" name="frmMain" method="post" onsubmit="return false" class="form-material form-inline">
                    	<form:input id="kMemberName" caption="이름" addAttr="maxlength='20'" />
                    	<form:input id="kCarNum" caption="차량번호" addAttr="maxlength='20'" />
                    </form>
				</div>
			<card:close />
        </div>
        <div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12">
			<card:open title="차량 목록" />
				<card:toolButton title="L00087">
				</card:toolButton>
				<card:content />
				<form:grid id="myGrid" />
			<card:close />
        </div>
	</div>
</div>

<%@ include file="../../core/include/footer.jsp"%>
