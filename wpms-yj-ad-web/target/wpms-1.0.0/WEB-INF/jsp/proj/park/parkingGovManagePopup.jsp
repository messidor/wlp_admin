<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="form" uri="http://ad.its.yeongju.kr/jsp/jstl/form"%>
<%@ taglib prefix="card" uri="http://ad.its.yeongju.kr/jsp/jstl/card"%>
<%@ taglib prefix="func" uri="http://ad.its.yeongju.kr/jsp/jstl/func"%>
<%@ taglib prefix="label" uri="http://ad.its.yeongju.kr/jsp/jstl/label" %>

<%@ include file="../../core/include/head.jsp"%>
<%@ include file="../../core/include/headerPopup.jsp" %>

<script type="text/javascript">
	
	var _originData;

	var useYnUupdate = "F";
	// 새로운 행 기본값 세팅
    function createNewRowData() {
        var newData = {
       		state_col: "C",
       		//parkingName: "",
       		govBankCode: "",
       		pGovAccountCode: "",
       		billingMid: "",
       		merchantKey:"",
       		pGovAccountName: "",
       		pGovAccountNumber: "",
       		pGovBankName: ""
        };
        return newData;
    }
	
	/* select_failCodeList */
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
		setGubunColumn(),
		setColumn(["govBankCode", "govBankCode", "left", 130],[],true),
		setColumn(["pGovAccountCode", "pGovAccountCode", "left", 130],[],true),
		//setColumn(["parkingName", "주차장명", "left", 120]),
		setColumn(["onceMid", "ONCE_MID", "center", 110],[true, [], true, "", "10"]), 
		setColumn(["onceMidPw", "ONCE_MID_PW", "center", 120],[true, [], true, "", "6"]),
		setColumn(["billingMid", "BILLING_MID", "center", 110],[true, [], true, "", "20"]),
		setColumn(["merchantKey", "MERCHANT_KEY", "left", 150],[true, [], false, "", "100"]),
		setColumn(["onceMerchantKey", "ONCE_MERCHANT_KEY", "left", 150],[true, [], false, "", "100"]),
		setColumn(["pGovAccountName", "통장명", "center", 110], [true, [], false, "", "100"]),
		setColumn(["pGovAccountNumber", "통장번호", "center", 140], [true, [], false, "", "20"]), 
		setColumn(["pGovBankName", "은행명", "center", 80], [true, [], false, "", "100"])
	]; 
	     
	// 그리드 옵션
	// 컬럼정의 / 화면에 그리드 맞추기 / 행추가 func
	var _gridHelper = new initGrid(columnDefs, true, createNewRowData);
	var gridOptions = _gridHelper.setGridOption();
	
	function govBankData() {

		var frm = $("#frmMain");
		//---- 그리드 조회 시 필수요소 start
		frm.addParam("result", $("#myGrid")); // 그리드 태그
		frm.addParam("grid", "gridOptions"); // 그리드 옵션
		frm.addParam("baseData", "_originData"); // 그리드 원본 데이터 저장 변수
		//---- 그리드 조회 시 필수요소 end
		frm.addParam("func", "IQ_Bank");
		frm.addParam("query_id", "park.parkingGovManagePopup.select_bankInfo");
		frm.addParam("dataType", "json"); // 그리드 불러오는 타입 (기본 json)
		frm.addParam("afterAction", true);
		frm.request();
	}

	function handleIQ_Bank(data, textStatus, jqXHR) {
		$("#myGrid").height($(".card-block").eq(0).innerHeight()-40);
	}
	
// 	function loadUseYn(){
// 		var frm = $("#frmMain");
//    		frm.addParam("func", "handleIQ_Useyn");
//    	    frm.addParam("query_id", "park.parkingGovManagePopup.select_useYnGov");
//    	    frm.addParam("dataType", "json");           // 그리드 불러오는 타입 (기본 json)
//    	    frm.request();
// 	}
	
// 	function handleIQ_Useyn(data, textStatus, jqXHR) {
// 		console.log("실행중2")
// 		if($("#useYn").val() == data[0].useYn){
// 			 alert("사용여부가 이미 변경되었습니다.");
// 			 loadTableData();   
// 		} 
// 	}
	
	function loadTableData() {
	    var frm = $("#frmMain");
	    frm.addParam("func", "IQ");
	    frm.addParam("query_id", "park.parkingGovManagePopup.select_list");
	    frm.addParam("dataType", "json");           // 그리드 불러오는 타입 (기본 json)
	    frm.request();
	}

	function handleIQ(data, textStatus, jqXHR) {
	    if(data.length > 0){

	    	$("#pGovName").val(data[0].pGovName);
	    	$("#pGovTel").val(data[0].pGovTel);
	        $("#pGovPost").val(data[0].pGovPost);
	        $("#pGovAddr").val(data[0].pGovAddr);
	        $("#pGovAddr2").val(data[0].pGovAddr2);
	        $("#pManager").val(data[0].pManager);
	        $("#pManagerPhone").val(data[0].pManagerPhone);
	        $("#pManagerEmail").val(data[0].pManagerEmail);
	        $("#mid").val(data[0].billingMid);
	        $("#sspMallId").val(data[0].sspMallId);
	        $("#mKey").val(data[0].mKey);
	        $("#useYn").val(data[0].useYn);
	        $("#pServiceKey").val(data[0].pServiceKey);
	        $("#regId").val(data[0].regId);
	        $("#regDt").val(data[0].regDt);
	        $("#modId").val(data[0].modId);
	        $("#modDt").val(data[0].modDt);
	        $("#onceMid").val(data[0].onceMid);
	        $("#midPw").val(data[0].billingMidPw);
	        $("#onceMidPw").val(data[0].onceMidPw);
	        $("#pGovTelRecv").val(data[0].pGovTelRecv);
	        $("#recvYn").val(data[0].recvYn);
	        $("#pGovTel").focus();
	        $('#pGovTel').blur();
	        $("#pGovTelRecv").focus();
	        $('#pGovTelRecv').blur();
	        $("#pManagerPhone").focus();
	        $('#pManagerPhone').blur();
	        
	        // 발급하였으면 발급 버튼 사라지도록 처리
	        if(data[0].pServiceKeyYn == "Y"){
	        	$("#issuanceSpan").css("display", "none");
	        }
	    }
	}
	
	function saveData() {
		
		var update_gubn = false;
		for(var i=0; i<_gridHelper.getAllGridData().length; i++){
			if(_gridHelper.getAllGridData()[i].state_col !== undefined){
				update_gubn = true;
			} 
		}
		
	    var frm = $("#frmMain");
	    frm.serializeArrayCustom();
	    frm.addParam("func", "IS");
	    frm.addParam("dataType", "json");
	    frm.addParam("useYnUupdate", useYnUupdate);
	    frm.addParam("hGovCode", $("#hGovCode").val());
	    frm.addParam("enc_col", "pManager, pManagerPhone, grd_pGovAccountName[], grd_pGovAccountNumber[], userId");
	    if(update_gubn){
	    	frm.addParam("grid", "gridOptions"); // 저장할 그리드의 그리드옵션 변수명	
	    }
	    frm.setAction("<c:url value='/park/parkGovInsert.do' />");
	    frm.request();
	}

	function handleIS(data, textStatus, jqXHR){
		if(data.count> 0) {
			if (opener && typeof opener.loadTableData === "function") {
				opener.loadTableData();
			}
		 	window.close();
		}
	}

	function deleteData() {
	    var frm = $("#frmMain");
	    frm.serializeArrayCustom();
	    frm.addParam("func", "IS2");
	    frm.addParam("dataType", "json");
	    frm.addParam("hGovCode", $("#hGovCode").val());
	    frm.addParam("enc_col", "userId");
	    frm.setAction("<c:url value='/park/parkGovUpdate.do' />");
	    frm.request();
	}

	function handleIS2(data, textStatus, jqXHR){
		if(data.count> 0) {
			if (opener && typeof opener.loadTableData === "function") {
				opener.loadTableData();
			}
		 	window.close();
		}
	}

	// 저장 제약조건
	function validation(){
		
		var postRule = /^(\d{3}-?\d{3}|\d{3}-?\d{2})$/u;
        
	    if($("#pGovName").val() == ""){
	        alert("기관명을 입력해 주세요.");
	        $("#pGovName").focus();
	        return;
	    }

	    if($("#pGovPost").val() == ""){
	    	alert("우편번호를 입력해 주세요.");
	        $("#pGovPost").focus();
	        return;
	    }
	    
		if(!postRule.test($("#pGovPost").val())){
			alert("우편번호가 올바르지 않습니다.");
	        $("#pGovPost").focus();
	        return;
		}

	    if($("#pGovAddr").val() == ""){
	    	alert("주소를 입력해 주세요.");
	        $("#pGovAddr").focus();
	        return;
	    }
	    
	    if($("#pManager").val() == ""){
	    	alert("담당자를 입력해 주세요.");
	        $("#pManager").focus();
	        return;
	    }
	    
	    if($("#pManagerPhone").val() == ""){
	    	alert("담당자연락처를 입력해 주세요.");
	        $("#pManagerPhone").focus();
	        return;
	    }
	    
	    if($("#pGovTel").val() == ""){
	    	alert("발신번호를 입력해 주세요.");
	        $("#pGovTel").focus();
	        return;
	    }
	    
	    if($("#recvYn").val() == "Y" && $("#pGovTelRecv").val() == ""){
	    	alert("수신번호를 입력해 주세요.");
	        $("#pGovTelRecv").focus();
	        return;
	    }
	    
	    if(_gridHelper.getAllGridData().length < 1 ){
	    	alert("통장 정보 1건 이상 존재하여야 합니다.");
	        return;
	    }
	
	    if(confirm("주차장 기관 정보를 저장하시겠습니까?")){
	    	saveData();	
	    }
	} 
	
	function saveData2() {
		var frm = $("#frmMain");
	    frm.serializeArrayCustom();
	    frm.addParam("func", "IS3");
	    frm.addParam("dataType", "json");
	    frm.addParam("enc_col", "userId");
	    frm.setAction("<c:url value='/park/parkingGovServiceInfo.do' />");
	    frm.request();
	}

	function handleIS3(data, textStatus, jqXHR){
		if(data.count> 0) {
			loadTableData();
		}
	}
	
	$(function() {
		
		var eGridDiv = document.querySelector('#myGrid');
		new agGrid.Grid(eGridDiv, gridOptions);
		
		// 그리드 툴 버튼 바로 표시
        $("i.open-card-option").trigger("click");
		
	    // 등록
	    $("#btnSave").on("click", function(){
	        validation();
	    });

	    // 삭제
	    $("#btnDelete").on("click", function(){
	        if(confirm("삭제시 주차장 정보 관리에 등록되어있는 해당 기관 삭제 됩니다.\n정말 삭제하시겠습니까?")){
	        	deleteData();
	        }
	    });

	    // 닫기
	    $("#btnClose").on("click", function(){
			self.close();
	    });

	    // 우편번호 선택
	    $("#btnPostcodeAdd").click(function(){
	        daum.postcode.load(function(){
	            new daum.Postcode({
	                oncomplete: function(data) {
	                    // 팝업에서 검색결과 항목을 클릭했을때 실행할 코드를 작성하는 부분.

	                    // 각 주소의 노출 규칙에 따라 주소를 조합한다.
	                    // 내려오는 변수가 값이 없을땐 공백('')값을 가지므로, 이를 참고하여 분기한다.
	                    var addr = ''; // 주소 변수
	                    //var extraAddr = ''; // 조합형 주소 변수

	                    fullAddr = data.roadAddress == "" ? data.autoRoadAddress : data.roadAddress;

	                    if(data.userSelectedType === 'R') {
	                        //법정동명이 있을 경우 추가한다.
	                        if(data.bname !== '') {
	                            addr += data.bname;
	                        }
	                        // 건물명이 있을 경우 추가한다.
	                        if(data.buildingName !== '') {
	                            addr += (addr !== '' ? ', ' + data.buildingName : data.buildingName);
	                        }
	                        // 조합형주소의 유무에 따라 양쪽에 괄호를 추가하여 최종 주소를 만든다.
	                        fullAddr += (addr !== '' ? ' ('+ addr +')' : '');
	                    }

	                    // 우편번호와 주소 정보를 해당 필드에 넣는다.
	                    document.getElementById("pGovPost").value = data.zonecode;
	                    document.getElementById("pGovAddr").value = fullAddr;

	                    // 커서를 상세주소 필드로 이동한다.
	                    document.getElementById("pGovAddr2").focus();
	                }
	            }).open();
	        });
	    });
	    
	 	// serviceKey 발급
	    $("#btnIssuance").click(function(){
	    	saveData2();
	    });

		<c:if test="${not empty param.pGovCode}">
			loadTableData();
		</c:if>
		govBankData();

		$("#pGovTel").inputMasking("phone");
		$("#pGovTelRecv").inputMasking("phone");
		$("#pManagerPhone").inputMasking("phone");
		
		
		// 그리드 행 추가
        $("body").on("click", "#toolInsert",function(){
        	_gridHelper.onAddRow();
        });

        // 그리드 행 삭제
        $("body").on("click", "#toolDelete",function(){
        	if(_gridHelper.getAllGridData().length <= 1){
        		alert("통장 정보 1건 이상 존재하여야 합니다.");
        		return
        	}else{        		
            	_gridHelper.onRemoveSelected();
        	}
        });

        // 그리드 행 복원
        $("body").on("click", "#toolUndo",function(){
            _gridHelper.onUndoSelected();
        });
        
      	//useyn 변경될떄
	   	$("#useYn").change(function(){
	   		//loadUseYn();
	   		useYnUupdate = "T";
	   	});

		$(".ag-body-horizontal-scroll").remove();
        
	});
</script>
<div class="page-body" style="font-size: 0.9em;">
	<div class="row">
			<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12">
					<card:open title="주차장 기관 정보" />
					<card:button>
					</card:button>
					<card:content />
						<form id="frmMain" name="frmMain" method="post" onsubmit="return false" class="form-horizontal">
							<form:input id="hGovCode" type="hidden" value="${param.pGovCode}"/>
							<label:input id="pGovName" caption="기관명" size="6" className="danger" addAttr="maxlength='50'"/>
							<label:input id="pGovTel" caption="발신번호" size="6" className="danger" addAttr="maxlength='10'"/>
							<div class="form-group col-xl-6 col-lg-6 col-md-6 col-sm-6 col-6 no-margin no-padding has-danger">
								<label class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right">우편번호</label>
								<div class="col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached">
									<div class="input-group">
										<span class="input-group-addon"><i class="fas fa-pencil-alt" data-icon="fas fa-eye"></i></span>
										<input name="pGovPost" id="pGovPost" class="form-control" type="text" value="">
										<span class="input-group-btn">
											<button id="btnPostcodeAdd" type="button" name="btnPostcodeAdd" class="btn btn-sm btn-primary">주소검색</button>
										</span>
									</div>
								</div>
							</div> 
							<label:input id="pGovTelRecv" caption="수신번호" size="6" addAttr="maxlength='10'"/>
							<label:input id="pGovAddr" caption="주소" size="6" className="danger"/>
							<label:select id="recvYn" caption="수신여부" size="6" queryId="#use_yn" all="false" className="danger" allLabel="" addAttr="style='height:35px;'" />
							<label:input id="pGovAddr2" caption="상세주소" size="6" addAttr="maxlength='50'"/>
							<label:select id="useYn" caption="사용여부" size="6" queryId="#use_yn" all="false" allLabel="" addAttr="style='height:35px;'" />
							<label:input id="pManager" caption="담당자" size="6" className="danger" addAttr="maxlength='25'"/>
							<label:input id="modId" caption="수정자" size="6" state="readonly"/>
							<label:input id="pManagerPhone" caption="담당자연락처" className="danger" size="6" addAttr="maxlength='12'"/>
							<label:input id="modDt" caption="수정일시" size="6" state="readonly"/>
						</form>
					<card:close />		
			</div>
			<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12">
				<card:open title="통장 정보" />
					<card:toolButton title="">
						<form:button type="RowAdd" id="toolInsert" wrap="li" />
						<form:button type="RowDel" id="toolDelete" wrap="li" />
						<form:button type="RowUndo" id="toolUndo" wrap="li" />
					</card:toolButton>
					<card:content />
					<form:grid id="myGrid"/>
				<card:close />
			</div>
		
	</div>
	<div class="row padding-left-5 padding-right-5">
		<div class="bottom-btn-area">
			<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12 text-right">
				<c:if test = "${empty param.pGovCode}">
					<form:button type="Save" id="btnSave" />
				</c:if>
				<c:if test = "${not empty param.pGovCode}">
					<form:button type="Save" id="btnSave" />
				</c:if>
				<form:button type="Close" id="btnClose" />
			</div>
			<label:clear />
		</div>
	</div>
</div>


<%@ include file="../../core/include/footer.jsp"%>
