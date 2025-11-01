<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="form" uri="http://ad.its.yeongju.kr/jsp/jstl/form" %>
<%@ taglib prefix="card" uri="http://ad.its.yeongju.kr/jsp/jstl/card" %>
<%@ taglib prefix="func" uri="http://ad.its.yeongju.kr/jsp/jstl/func" %>
<%@ taglib prefix="label" uri="http://ad.its.yeongju.kr/jsp/jstl/label" %>

<%@ include file="../../core/include/head.jsp" %>
<%@ include file="../../core/include/headerPopup.jsp" %>


<style type="text/css">
div.z-idx-item2 {
	margin-left: calc(50vw - 350px);
	margin-top: calc(30vh);
}
</style>

<script type="text/javascript">
	// 로딩 이미지 표시 여부
	//setLoadImage(false);

	//데이터 복원 시 사용할 원본 데이터 변수
	var _originData, _originData2, _originData3;

	var memberId = "${param.memberId}";
	var confirmYn = "${param.confirmYn}";
	var userUrl = "${userUrl}";
    var imageUriData = "";
    var downloadCode = "";


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
		setColumn(["fileExt", "첨부파일 경로", "left", 100],[],true),
		setColumn(["fileName", "첨부파일 경로", "left", 100],[],true),
		setColumn(["fileRelKey", "첨부파일 연계키", "left", 100],[],true),
		setColumn(["fileKey", "첨부파일 키", "left", 100],[],true),
		setColumn(["num", "번호", "center", 50], [false, ["index", "asc"]]),
		setColumn(["carAlias", "차량별칭", "left", 100]),
		setColumn(["carNo", "차량번호", "center", 100]),
		setColumn(["frightCarYn", "대형차량 여부", "center", 100]),
		setColumn(["lowPltGubn", "친환경차량", "center", 100]),
		setColumn(["file", "첨부파일", "center", 100], [grdCarFile, ["button", null, "link", "첨부파일", ""] ]),
		setColumn(["deleteBtn", "삭제", "center", 100], [carInfoDel, ["button", null, "link"] ]),
        setColumn(["isCarParking", "입차중 여부", "left", 100],[],true), // 20240710 :: 입차 상태인 차량은 삭제 불가능하도록 처리
		
	];


	var columnDefs2 = [
		setColumn(["num", "번호", "center", 50], [false, ["index", "asc"]]),
		setColumn(["repYn", "대표카드여부", "center", 100], [false, ["check"], false, "", "20"]),
		setColumn(["creditComp", "카드사", "center", 100]),
		setColumn(["creditNo", "카드번호", "center", 240]),
		setColumn(["creditExpDateStr", "유효기간", "center", 100]),
	];

	// 컬럼 조건에 따른 에디팅 여부
	function codeEditFunc(_params){
		if("${param.confirmYn}" == "Y"){
			return false;
		}else{
			if(_params.data.checkValue === 'Y'){
		    	return true;
		    }
		    else{
		    	return false;
		    }
		}
	}

	var columnDefs3 = [
		setGubunColumn(50),
		setColumn(["fileExt", "fileExt", "center", 120],[],true),
		setColumn(["fileName", "fileName", "center", 120],[],true),
		setColumn(["reductionCode", "reductionCode", "center", 120],[],true),
		setColumn(["fileRelKey", "첨부파일 연계키", "left", 130],[],true),
        setColumn(["fileKey", "첨부파일 키", "left", 130],[],true),
		setColumn(["reductionName", "구분", "left", 120]),
		setColumn(["reductionRate", "감면율", "center", 60]),
		setColumn(["redExpDate", "인적감면유효기간", "center", 120], [reductionBool,[],false, "date", ""]),
		setColumn(["confirmDt", "승인일시", "center", 130]),
		setColumn(["fileLink", "첨부파일", "center", 90], [grdMemberReduction, ["button", null, "link"] ]),
		setColumn(["confirmYnName", "처리여부", "center", 80]),
		setColumn(["deleteBtn", "삭제", "center", 80], [memberReductionDel, ["button", null, "link"] ]),
        setColumn(["inputGubn", "inputGubn", "center", 120],[],true),
	];

	setColumnMask(columnDefs3, "redExpDate", "date");
	
	// 기본감면 - 인적감면 유효기간 수정 불가
	function reductionBool(e){
		if(e.data.reductionCode == 'A14'){
			return false;
		} else{
			return true;
		}
	}

	var columnDefs4 = [
		setColumn(["fileExt", "fileExt", "center", 120],[],true),
		setColumn(["fileName", "fileName", "center", 120],[],true),
		setColumn(["reductionCode", "reductionCode", "center", 120],[],true),
		setColumn(["redExpDate", "redExpDate"],[],true),
		setColumn(["num", "번호", "center", 30], [false, ["index", "asc"]]),
		setColumn(["carNo", "차량번호", "center", 100]),
		setColumn(["reductionName", "구분", "left", 130]),
		setColumn(["reductionRate", "감면율", "center", 100])
	];

	// 그리드 옵션
	// 컬럼정의 / 화면에 그리드 맞추기 / 행추가 func
	var _gridHelper = new initGrid(columnDefs, true);
	var gridOptions = _gridHelper.setGridOption();

	var _gridHelper2 = new initGrid(columnDefs2, true);
	var gridOptions2 = _gridHelper2.setGridOption();

	var _gridHelper3 = new initGrid(columnDefs3, true);
	var gridOptions3 = _gridHelper3.setGridOption();

	var _gridHelper4 = new initGrid(columnDefs4, true);
	var gridOptions4 = _gridHelper4.setGridOption();

	var car_num = "";
	var file_click = false;

	function grdCarFile(e, data) {

		gridOptions3.api.forEachNode(function (node) {
		    node.setSelected(false);
		 });

		gridOptions4.api.forEachNode(function (node) {
		    node.setSelected(false);
		});

		car_num = data.carNo;

		imageUriData = "";
        downloadCode = "";

		if(data.mimeType != null && data.mimeType.indexOf("image/") > -1) {
            var frm = $("#frmMain");
            frm.addParam("func", "IQ_Img");
            frm.setAction("<c:url value='/upload/getImgDataUri.do' />");
            frm.addParam("fileRelKey", data.fileRelKey);
            frm.addParam("fileKey", data.fileKey);
            frm.addParam("dataType", "json");
            frm.request();
        } else {
            var frm = $("#frmMain");
            frm.addParam("func", "IQ_DNC");
            frm.setAction("<c:url value='/upload/getEncFileData.do' />");
            frm.addParam("fileRelKey", data.fileRelKey);
            frm.addParam("fileKey", data.fileKey);
            frm.addParam("dataType", "json");
            frm.request();
        }
	}

	function handleIQ_Img(data, textStatus, jqXHR) {
		$("#btnzoomIn").show();
	    if(typeof(data.data.imgDataUri) != 'undefined') {
	        imageUriData = data.data.imgDataUri;

	        if(imageUriData.length > 0) {
	            $("#image img").attr("src", imageUriData);
	        } else {
	            $("#image img").attr("src", "<c:url value='/images/no_img.jpg'/>");
	        }
	    }

	    $("#image").css("cursor", "pointer");
	    $("#image")[0].onclick = openPopup;
	    $("#btnzoomIn").data("dataType", "I");
	    $("#btnzoomIn").html("").append("<span class=\"fa fa-search-plus\"></span>&nbsp;&nbsp;크게보기");
	}

    function handleIQ_DNC(data, textStatus, jqXHR) {
    	$("#btnzoomIn").show();
        if(typeof(data.data.encData) != 'undefined') {
	        downloadCode = data.data.encData;
        }

        $("#btnzoomIn").data("dataType", "D");
        $("#image").css("cursor", "default");
        $("#image")[0].onclick = null;
        $("#image img").attr("src", "<c:url value='/images/no_preview.jpg'/>");
        $("#btnzoomIn").html("").append("<span class=\"fa fa-download\"></span>&nbsp;&nbsp;첨부파일 다운로드");
    }

	function grdMemberReduction(e, data) {
	    if(data.inputGubn == "A") {
	    	// 버튼이 숨겨지면서 카드 높이가 변하는 현상 보완
	    	var orgHeight = $(".card").eq(4).innerHeight();
	    	$(".card").eq(4).height(orgHeight);
	    	$("#btnzoomIn").hide();
	    	
	        $("#image img").attr("src", "<c:url value='/assets/images/auto_img.jpg' />");
	    } else if(data.fileLink != null){
			gridOptions.api.forEachNode(function (node) {
			    node.setSelected(false);
			});

			gridOptions4.api.forEachNode(function (node) {
			    node.setSelected(false);
			});

			file_click = true;


	        imageUriData = "";
	        downloadCode = "";

			if(data.mimeType == null) {
			    $("#image img").attr("src", "<c:url value='/images/no_img.jpg'/>");
			    $("#image")[0].onclick = openPopup;
			    $("#image").css("cursor", "pointer");
		        $("#btnzoomIn").data("dataType", "I");
		        $("#btnzoomIn").html("").append("<span class=\"fa fa-search-plus\"></span>&nbsp;&nbsp;크게보기");
			}else if(data.mimeType.indexOf("image/") > -1) {
	            var frm = $("#frmMain");
	            frm.addParam("func", "IQ_Img");
	            frm.setAction("<c:url value='/upload/getImgDataUri.do' />");
	            frm.addParam("fileRelKey", data.fileRelKey);
	            frm.addParam("fileKey", data.fileKey);
	            frm.addParam("dataType", "json");
	            frm.request();
	        } else {
	            var frm = $("#frmMain");
	            frm.addParam("func", "IQ_DNC");
	            frm.setAction("<c:url value='/upload/getEncFileData.do' />");
	            frm.addParam("fileRelKey", data.fileRelKey);
	            frm.addParam("fileKey", data.fileKey);
	            frm.addParam("dataType", "json");
	            frm.request();
	        }
		}
	}

    /* 인적감면 삭제버튼 */
    function memberReductionDel(e, data) {
    	 // 기본할인은 삭제 X
    	if(data.reductionCode != 'A14' && data.reductionCode != 'undefined') {
    		if(confirm("감면정보를 삭제하시겠습니까?")){
    			$("#modalEdit").modal('show');
    			$("#hRowIndex").val(data.rowIndex);
    			$("#hDelGubn").val("memberReduction");
    		} else{
    			return false;
    		}
    	}
    }

    /* 인적감면 삭제기능 */
    function memberReductionDel2() {
    	var list = _gridHelper3.getAllGridData();
    	var index = $("#hRowIndex").val();

    	var frm = $("#frmMain");
    	frm.addParam("func", "DL");
    	frm.addParam("dataType", "json");

    	frm.addParam("grdReductionCode", list[index].reductionCode);
    	frm.addParam("grdRedExpDate", list[index].redExpDate);
    	frm.addParam("grdReductionName", list[index].reductionName);
    	frm.addParam("hMemberId", $("#hMemberId").val());
    	frm.addParam("delComment", $("#delComment").val());
    	frm.addParam("enc_col", "hMemberId, userId");

    	frm.setAction("<c:url value='/member/memberReductionDel.do' />");
    	frm.request();

    	$("#modalEdit").modal('hide');
    	$("#delComment").val("");
    }

    function handleDL(data, textStatus, jqXHR) {
		loadTableData();
	}

    /* 차량정보 삭제 */
    function carInfoDel(e, data) {
        // 20240710 :: 입차 상태인 차량은 삭제 불가능하도록 처리
        if(data.isCarParking == "Y") {
            alert("해당 차량은 현재 주차장 입차 상태입니다. 출차 후 삭제가 가능합니다.");
            return false;
        }
        
		if(confirm("차량정보를 삭제하시겠습니까?")){
			$("#modalEdit").modal('show');
			$("#hRowIndex").val(data.rowIndex);
			$("#hDelGubn").val("carInfo");
		} else{
			return false;
		}
    }

    /* 차량정보 삭제 기능*/
    function carInfoDel2() {
    	var list = _gridHelper.getAllGridData();
    	var list4 = _gridHelper4.getAllGridData();
    	var index = $("#hRowIndex").val();
    	var carReductionCode = '';
    	var carRedExpDate = '';

    	for(var j=0; j<list4.length; j++){
    		if(list[index].carNo == list4[j].carNo){
    			carReductionCode = list4[j].reductionCode;
    			carRedExpDate = list4[j].redExpDate;
    			break;
    		}
    	}

		var frm = $("#frmMain");
    	frm.addParam("func", "DL2");
    	frm.addParam("dataType", "json");

    	frm.addParam("grdCarAlias", list[index].carAlias);
    	frm.addParam("grdCarNo", list[index].carNo);
    	frm.addParam("grdReductionCode", carReductionCode);
    	frm.addParam("grdRedExpDate", carRedExpDate);
    	frm.addParam("hMemberId", $("#hMemberId").val());
    	frm.addParam("delComment", $("#delComment").val());
    	frm.addParam("enc_col", "hMemberId");

    	frm.setAction("<c:url value='/member/memberCarDel.do' />");
    	frm.request();

    	$("#modalEdit").modal('hide');
    	$("#delComment").val("");
    }

    function handleDL2(data, textStatus, jqXHR) {
		loadTableData();
	}

	function loadTableDetail() {
		var frm = $("#frmMain");
		frm.addParam("func", "IQ_Detail");
		frm.addParam("query_id", "member.memberPopup.select_MemberName");
		frm.addParam("enc_col", "hMemberId");
		frm.addParam("dataType", "json"); // 그리드 불러오는 타입 (기본 json)
		frm.request();
	}

	function handleIQ_Detail(data, textStatus, jqXHR) {
		if(data.length > 0){
			// 회원 이름
			$("#kMemberId").val(data[0].memberId);
			$("#kMemberName").val(data[0].memberName);
			$("#kMemberPhone").val(data[0].memberPhone);
	        $('#kMemberPhone').blur();
	        $('#kMemberPhone').attr("readonly", "true");
	        $("#kMemberEmail").val(data[0].memberEmail);
	        $("#kMemberGubnName").val(data[0].memberGubnName);
	        $("#hMemberGubn").val(data[0].memberGubn);
	        $("#kZipCode").val(data[0].zipCode);
	        $("#kAddrCode1").val(data[0].addrCode1);
	        $("#kAddrCode2").val(data[0].addrCode2);
	        $("#kGugun").val(data[0].gugun);
			loadTableData();
		}
	}

	function loadTableData() {

		var frm = $("#frmMain");
		//---- 그리드 조회 시 필수요소 start
		frm.addParam("result", $("#myGrid")); // 그리드 태그
		frm.addParam("grid", "gridOptions"); // 그리드 옵션
		frm.addParam("baseData", "_originData"); // 그리드 원본 데이터 저장 변수
		//---- 그리드 조회 시 필수요소 end
		frm.addParam("func", "IQ");
		frm.addParam("query_id", "member.memberPopup.select_carInfo");
		frm.addParam("enc_col", "hMemberId");
		frm.addParam("dataType", "json"); // 그리드 불러오는 타입 (기본 json)
		frm.addParam("afterAction", true);
		frm.request();
	}

	function handleIQ(data, textStatus, jqXHR) {
		gridOptions.api.sizeColumnsToFit();
		loadTableData2();
	}

	function loadTableData2() {
		var frm = $("#frmMain");
		//---- 그리드 조회 시 필수요소 start
		frm.addParam("result", $("#myGrid2"));	   // 그리드 태그
		frm.addParam("grid", "gridOptions2");		// 그리드 옵션
		frm.addParam("baseData", "_originData2");	// 그리드 원본 데이터 저장 변수
		//---- 그리드 조회 시 필수요소 end
		frm.addParam("func", "IQ2");
		frm.addParam("query_id", "member.memberPopup.select_creditInfo");
		frm.addParam("enc_col", "hMemberId");
		frm.addParam("dataType", "json");		   // 그리드 불러오는 타입 (기본 json)
		frm.addParam("afterAction", false);
		frm.request();
	}

	function handleIQ2(data, textStatus, jqXHR) {
		if(data.length > 0) {

			for(var i=0; i<data.length; i++){
				var fullCardNo = data[i].creditNo + "-" + data[i].creditNo2 + "-" + data[i].creditNo3 + "-" + data[i].creditNo4;
				data[i].creditNo = fullCardNo;

				var FullcreditExpDate = "";
				if(data[i].creditExpDate != null) {
					FullcreditExpDate = data[i].creditExpDate.substr(0,2) + " / " + data[i].creditExpDate.substr(2,2);
				}
				data[i].creditExpDateStr = FullcreditExpDate;
			}

	        gridOptions2.api.setRowData(data);
	        gridOptions2.setOriginalData(data);
		}
		gridOptions2.api.sizeColumnsToFit();
		loadTableData3();
	}

	function loadTableData3() {
		var frm = $("#frmMain");
		//---- 그리드 조회 시 필수요소 start
		frm.addParam("result", $("#myGrid3"));	   // 그리드 태그
		frm.addParam("grid", "gridOptions3");		// 그리드 옵션
		frm.addParam("baseData", "_originData3");	// 그리드 원본 데이터 저장 변수
		//---- 그리드 조회 시 필수요소 end
		frm.addParam("func", "IQ3");
		frm.addParam("query_id", "member.memberPopup.select_MemberReduction");
		frm.addParam("enc_col", "hMemberId");
		frm.addParam("dataType", "json");		   // 그리드 불러오는 타입 (기본 json)
		frm.addParam("afterAction", false);
		frm.request();
	}

	function handleIQ3(data, textStatus, jqXHR) {
		gridOptions3.api.sizeColumnsToFit();
		loadTableData4();
	}

	function loadTableData4() {
		if(!file_click){
			var frm = $("#frmMain");
			//---- 그리드 조회 시 필수요소 start
			frm.addParam("result", $("#myGrid4"));	   // 그리드 태그
			frm.addParam("grid", "gridOptions4");		// 그리드 옵션
			frm.addParam("baseData", "_originData4");	// 그리드 원본 데이터 저장 변수
			frm.addParam("car_num", car_num);	// 그리드 원본 데이터 저장 변수
			//---- 그리드 조회 시 필수요소 end
			frm.addParam("func", "IQ4");
			frm.addParam("query_id", "member.memberPopup.select_CarReductionGrid");
			frm.addParam("enc_col", "hMemberId");
			frm.addParam("dataType", "json");		   // 그리드 불러오는 타입 (기본 json)
			frm.addParam("afterAction", false);
			frm.request();
		}
	}

	function handleIQ4(data, textStatus, jqXHR) {
		gridOptions4.api.sizeColumnsToFit();
	}

	function saveData() {
	    var frm = $("#frmMain");
	    frm.serializeArrayCustom();
	    frm.addParam("func", "IS");
	    frm.addParam("dataType", "json");
		frm.addParam("grid", "gridOptions3"); // 그리드 옵션
	    frm.setAction("<c:url value='/member/memberSaveData.do' />");
		frm.request();
	}

    function handleIS(data, textStatus, jqXHR){
    	if(data.count > 0){
    		window.close();
    	}
    }

    function saveData2() {
	    var frm = $("#frmMain");
	    frm.addParam("func", "IS2");
	    frm.addParam("dataType", "json");
	    frm.addParam("kMemberId", $("#kMemberId").val());
	    frm.addParam("kMemberPw", $("#kMemberPw").val());
	    frm.addParam("enc_col", "kMemberPw, kMemberId");
	    frm.setAction("<c:url value='/member/memberPasswordUpdate.do' />");
		frm.request();
	}

    function handleIS2(data, textStatus, jqXHR){
    	$("#kMemberPw").val("");
    	$("#kMemberPw").attr("readonly", true);
		$("#kMemberPw").siblings("span").children("i").removeClass();
		$("#kMemberPw").siblings("span").children("i").addClass("fas fa-eye");
		$("#kMemberPw").siblings("span").children("i").data("icon", "fas fa-eye");
		$("#btnPwChange").text("활성화");
		$("#btnPwChange").data("gubn", "activation");
    }

	//이미지 팝업창 생성
	function openPopup(imageSrc) {
	    if($("#btnzoomIn").data("dataType") == "I") {
	        if(imageUriData.length > 0) {
	            OpenPopupSingle("/sys/imagePopup.do", 1800, 990, "imagePopup");
	        }
	    } else {
	        if(downloadCode.length > 0) {
	            startDownload(downloadCode, "W");
	        }
	    }
	}

	//비밀번호 체크
	function passNotify(){
		var pwReg = /^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-]).{8,20}$/;
		var pwSpaceReg = /\s/g;
		var pw = $("#kMemberPw").val();

		if(!pw || pw.length <= 0){
			//비밀번호가 공백
			alert("비밀번호를 입력해 주세요.");

			return false;
		}else if(!pwReg.test(pw)){
			//비밀번호가 정규표현식에 맞지않을경우
			alert("비밀번호는 8~20자 영문 대 소문자, 숫자, 특수문자를 사용하세요.");

			return false;
		}else if(pwSpaceReg.test(pw)){
			//비밀번호가 정규표현식에 맞지않을경우
			alert("비밀번호에 공백을 입력할 수 없습니다.");

			return false;
		}

		return true;
	}

	function addrSearch(){
		daum.postcode
		.load(function() {
			new daum.Postcode(
					{
						oncomplete : function(data) {
							// 팝업에서 검색결과 항목을 클릭했을때 실행할 코드를 작성하는 부분.

							// 각 주소의 노출 규칙에 따라 주소를 조합한다.
							// 내려오는 변수가 값이 없을땐 공백('')값을 가지므로, 이를 참고하여 분기한다.
							var addr = ''; // 주소 변수
							//var extraAddr = ''; // 조합형 주소 변수

							fullAddr = data.roadAddress == "" ? data.autoRoadAddress
									: data.roadAddress;

							if (data.userSelectedType === 'R') {
								//법정동명이 있을 경우 추가한다.
								if (data.bname !== '') {
									addr += data.bname;
								}
								// 건물명이 있을 경우 추가한다.
								if (data.buildingName !== '') {
									addr += (addr !== '' ? ', '
											+ data.buildingName
											: data.buildingName);
								}
								// 조합형주소의 유무에 따라 양쪽에 괄호를 추가하여 최종 주소를 만든다.
								fullAddr += (addr !== '' ? ' ('
										+ addr
										+ ')'
										: '');
							}

							// 우편번호와 주소 정보를 해당 필드에 넣는다.
							document.getElementById("kZipCode").value = data.zonecode;
							document.getElementById("kGugun").value = data.sigungu;
							document.getElementById("kAddrCode1").value = fullAddr;

							// 커서를 상세주소 필드로 이동한다.
							document.getElementById("kAddrCode2").focus();
						}
					}).open();
		});
	}

	$(function() {

		var eGridDiv = document.querySelector('#myGrid');
		new agGrid.Grid(eGridDiv, gridOptions);

		var eGridDiv2 = document.querySelector('#myGrid2');
		new agGrid.Grid(eGridDiv2, gridOptions2);

		var eGridDiv3 = document.querySelector('#myGrid3');
		new agGrid.Grid(eGridDiv3, gridOptions3);

		var eGridDiv4 = document.querySelector('#myGrid4');
		new agGrid.Grid(eGridDiv4, gridOptions4);

		// 그리드 툴 버튼 바로 표시
        $("i.open-card-option").trigger("click");


		// 닫기
		$("#btnClose").click(function() {
			window.close();
		});

		// 크게 보기
		$("#btnzoomIn").click(function() {
			//$("#image").trigger("click");
			//window.open($("#image img").attr("src"),)
			openPopup($("#image img").attr("src"));
		});

		// 저장
		$("#btnSave").click(function() {
			if(confirm("저장하시겠습니까?")){
				saveData();
			}
		});


		// 비밀번호 변경
		$("#btnPwChange").click(function() {
			if($("#hMemberGubn").val() == "O"){
				alert("디지털원패스 회원은 비밀번호 변경이 불가능합니다.");
				return false;
			}
			/* alert("준비중입니다.");
			return false; */
			if($(this).data("gubn") == "activation"){
				$("#kMemberPw").attr("readonly", false);
				$("#kMemberPw").siblings("span").children("i").removeClass();
				$("#kMemberPw").siblings("span").children("i").addClass("fas fa-pencil-alt");
				$("#kMemberPw").siblings("span").children("i").data("icon", "fas fa-pencil-alt");
				$("#btnPwChange").text("변경");
				$("#btnPwChange").data("gubn", "change");

			}else if($(this).data("gubn") == "change"){
				if(passNotify()){
					if(confirm("비밀번호를 변경하시겠습니까?")){
						saveData2();
					}
				}
			}
		});

		// 모달 - 삭제버튼
		$("#btnModalDelete").click(function() {
			// 공백 처리
			var delComment = $("#delComment").val();
			$("#delComment").val(delComment.trim());

			if($("#delComment").val() != ""){
				if($("#hDelGubn").val() == "memberReduction"){
					memberReductionDel2();
				}else if($("#hDelGubn").val() == "carInfo"){
					carInfoDel2();
				}
			}else{
				alert("삭제 사유를 입력해 주세요.");
			}
		});

		// 모달 - 닫기
		$("#btnModalClose").click(function() {
			$("#delComment").val("");
			$("#modalEdit").modal('hide');
		});

		// 그리드 행 복원
        $("body").on("click", "#toolUndo",function(){
            _gridHelper3.onUndoSelected();
        });

		//최초 갭 : 205
		$(window).on("resize", function() {
		    if($(window).height() > 899) {
/* 			    $("#myGrid").css("height", $(this).height() - 763);
			    $("#myGrid2").css("height", $(this).height() - 763);
			    $("#myGrid3").css("height", $(this).height() - 763);
			    $("#myGrid4").css("height", $(this).height() - 763); */
		    } else {
		        $("#myGrid,#myGrid2,#myGrid3,#myGrid4").css("height", "80px");
		    }
		});


		loadTableDetail();
		/* loadTableData2(); */

		gridOptions.api.setRowData([]);
		gridOptions.setOriginalData([]);
		gridOptions2.api.setRowData([]);
		gridOptions2.setOriginalData([]);
		gridOptions3.api.setRowData([]);
		gridOptions3.setOriginalData([]);
		gridOptions4.api.setRowData([]);
		gridOptions4.setOriginalData([]);

		$("#kMemberPhone").inputMasking("phone");

		$(window).trigger("resize");
		$(".ag-body-horizontal-scroll").remove();

		$("#btnzoomIn").data("dataType", "I");


	});
</script>

<div class="page-body" style="font-size: 0.9em;">
	<div class="row">
        <div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12">
            <div class="col-xl-6 col-lg-6 col-md-6 col-sm-6 col-6" data-windir="leftSide">
                <card:open title="회원 정보" />
                <card:button>
                </card:button>
                <card:content />
                <form id="frmMain" name="frmMain" method="post" onsubmit="return false" class="form-horizontal" >
                    <form:input id="hMemberId" type="hidden" value="${param.memberId}" />
                    <form:input id="hRowIndex" type="hidden" value="" />
                    <form:input id="hDelGubn" type="hidden" value="" />
                    <div class="form-group col-xl-6 col-lg-6 col-md-6 col-sm-6 no-margin no-padding ">
                        <label class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right">ID</label>
                        <div class="col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached">
                            <div class="input-group">
                                <span class="input-group-addon"><i class="fas fa-eye" data-icon="fas fa-pencil-alt"></i></span>
                                <input name="kMemberId" id="kMemberId" class="form-control" type="text" value="" readonly="readonly">
                            </div>
                        </div>
                    </div>
                     <div class="form-group col-xl-6 col-lg-6 col-md-6 col-sm-6 no-margin no-padding ">
                        <label class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right">비밀번호변경</label>
                        <div class="col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached">
                            <div class="input-group">
                                <span class="input-group-addon"><i class="fas fa-eye" data-icon="fas fa-pencil-alt"></i></span>
                                <input name="kMemberPw" id="kMemberPw" class="form-control text-center" type="password" value="" maxlength="20" title="8~20자 영문 대 소문자, 숫자, 특수문자를 사용하세요." readonly="readonly">
                                <span class="input-group-btn">
									<button id="btnPwChange" type="button" name="btnPwChange" class="btn btn-sm btn-primary" data-gubn="activation">활성화</button>
								</span>
                            </div>
                        </div>
                    </div>
                    <div class="form-group col-xl-6 col-lg-6 col-md-6 col-sm-6 no-margin no-padding ">
                        <label class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right">이름</label>
                        <div class="col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached">
                            <div class="input-group">
                                <span class="input-group-addon"><i class="fas fa-eye" data-icon="fas fa-pencil-alt"></i></span>
                                <input name="kMemberName" id="kMemberName" class="form-control" type="text" value="" readonly="readonly">
                            </div>
                        </div>
                    </div>
                    <div class="form-group col-xl-6 col-lg-6 col-md-6 col-sm-6 no-margin no-padding ">
                        <label class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right">전화번호</label>
                        <div class="col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached">
                            <div class="input-group">
                                <span class="input-group-addon"><i class="fas fa-eye" data-icon="fas fa-pencil-alt"></i></span>
                                <input name="kMemberPhone" id="kMemberPhone" class="form-control text-center" type="text" value="">
                            </div>
                        </div>
                    </div>
                    <div class="form-group col-xl-6 col-lg-6 col-md-6 col-sm-6 no-margin no-padding ">
                        <label class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right">이메일</label>
                        <div class="col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached">
                            <div class="input-group">
                                <span class="input-group-addon"><i class="fas fa-eye" data-icon="fas fa-pencil-alt"></i></span>
                                <input name="kMemberEmail" id="kMemberEmail" class="form-control" type="text" value="" readonly="readonly">
                            </div>
                        </div>
                    </div>
                    <div class="form-group col-xl-6 col-lg-6 col-md-6 col-sm-6 no-margin no-padding ">
                        <label class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right">회원구분</label>
                        <div class="col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached">
                            <div class="input-group">
                                <span class="input-group-addon"><i class="fas fa-eye" data-icon="fas fa-pencil-alt"></i></span>
                                <input name="kMemberGubnName" id="kMemberGubnName" class="form-control text-center" type="text" value="" readonly="readonly">
                                <form:input id="hMemberGubn" type="hidden" value="" />
                            </div>
                        </div>
                    </div>
                     <div class="form-group col-xl-6 col-lg-6 col-md-6 col-sm-6 no-margin no-padding ">
                        <label class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right">우편번호</label>
                        <div class="col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached">
                            <div class="input-group">
                                <span class="input-group-addon"><i class="fas fa-eye" data-icon="fas fa-pencil-alt"></i></span>
                                <input name="kZipCode" id="kZipCode" class="form-control text-center" type="text" value="" maxlength="20" readonly="readonly">
<!--                                 <span class="input-group-btn"> -->
<!-- 									<button id="btnZipCode" type="button" name="btnZipCode" onClick="addrSearch()" class="btn btn-sm btn-primary" data-gubn="activation">검색</button> -->
<!-- 								</span> -->
                            </div>
                        </div>
                    </div>
                    <div class="form-group col-xl-6 col-lg-6 col-md-6 col-sm-6 no-margin no-padding ">
                        <label class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right">구역(시/군/구)</label>
                        <div class="col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached">
                            <div class="input-group">
                                <span class="input-group-addon"><i class="fas fa-eye" data-icon="fas fa-pencil-alt"></i></span>
                                <input name="kGugun" id="kGugun" class="form-control text-center" type="text" value="" readonly="readonly">
                            </div>
                        </div>
                    </div>
                    <div class="form-group col-xl-12 col-lg-12 col-md-12 col-sm-12 no-margin no-padding ">
                        <label class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right">주소</label>
                        <div class="col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached">
                            <div class="input-group">
                                <span class="input-group-addon"><i class="fas fa-eye" data-icon="fas fa-pencil-alt"></i></span>
                                <input name="kAddrCode1" id="kAddrCode1" class="form-control text-center" type="text" value="" readonly="readonly" style="text-align:left !important">
                            </div>
                        </div>
                    </div>
                    <div class="form-group col-xl-12 col-lg-12 col-md-12 col-sm-12 no-margin no-padding ">
                        <label class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right">상세주소</label>
                        <div class="col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached">
                            <div class="input-group">
                                <span class="input-group-addon"><i class="fas fa-pencil-alt" data-icon="fas fa-pencil-alt"></i></span>
                                <input name="kAddrCode2" id="kAddrCode2" class="form-control text-center" type="text" value="" readonly="readonly" style="text-align:left !important" >
                            </div>
                        </div>
                    </div>
                    <label:clear />
                </form>
                <card:close />
                <card:open title="차량 정보" />
                <card:button>
                </card:button>
                <card:content />
                    <form:grid id="myGrid" style="height: 120px;"/>
                <card:close />
            	<card:open title="카드 정보" />
                <card:button>
                </card:button>
                <card:content />
                    <form:grid id="myGrid2" style="height: 120px;"/>
                <card:close />
            </div>



            <div class="col-xl-6 col-lg-6 col-md-6 col-sm-6 col-6" data-windir="rightSide">
            	<card:open title="감면정보" />
                <card:toolButton title="L00087">
					<form:button type="RowUndo" id="toolUndo" wrap="li" />
				</card:toolButton>
                <card:content />
                    <form:grid id="myGrid3" style="height: 120px;"/>
                    <form:grid id="myGrid4" style="margin-top:10px; height: 120px;"/>
                <card:close />
            </div>
                <div class="col-xl-6 col-lg-6 col-md-6 col-sm-6 col-6" data-windir="rightSide">
                <div class="card">
                    <div class="card-header">
                        <h5>파일 정보</h5>
                    </div>
                    <div class="card-block table-border-style">
                        <!-- <a href="javascript:window.open(this.src,'_blank')" id='image' style="height:640px">  -->
                        <div onClick="openPopup()" id="image" style="text-align:center;">
                            <img src="<c:url value='/images/nonselect_image.jpg'/>" alt="존재하지않는파일.png" style="cursor:pointer; height:356px; width:409px; margin-bottom: 15px; border: 1px solid #eee; border-radius: 22px;">
                        </div>
                        <a href="<c:url value='/images/no_img.jpg'/>" id="iframe" data-fancybox="" data-small-btn="true" style="display:none;" data-options='{"type" : "iframe", "iframe" : {"preload" : false, "css" : {"width" : "800px","height" : "800px"}}}'></a>
                        <div class="text-right">
                            <button type="button" id="btnzoomIn" class="btn btn-sm waves-effect waves-light btn-info btn-outline-info default text-right">
                                <span class="fa fa-search-plus"></span>
                                &nbsp;크게보기
                            </button>
                        </div>
                    </div>
                </div>
            </div>

        </div>
	</div>
	<div class="row padding-left-10 padding-right-10">
		<div class="bottom-btn-area">
			<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12 text-right">
				<form:button type="Save" id="btnSave" />
				<form:button type="Close" id="btnClose" />
			</div>
			<label:clear />
		</div>
	</div>
</div>
<!-- 삭제 모달 팝업 -->
<div class="modal fade" id="modalEdit" tabindex="-1" role="dialog" aria-labelledby="modalEdit" style="position: fixed;"
	data-backdrop="static" data-keyboard="false">
	<div class="modal-dialog" role="document" style="max-width: 650px;">
		<div class="modal-content">
			<div class="modal-header">
				<h5 class="modal-title">삭제 사유</h5>
			</div>
			<div class="modal-body">
				<div class="row">
					<div class="col-12">
						<form id="frmModal" name="frmModal" method="post" onsubmit="return false" class="form-horizontal">
							<label:textarea id="delComment" caption="삭제 사유" stateIcon="fas fa-pencil-alt" />
						</form>
						<div class="col-12 text-right">
							<form:button type="Delete" id="btnModalDelete" />
							<form:button type="Close" id="btnModalClose" />
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>
</div>

<%@ include file="../../core/include/footerPopup.jsp" %>
