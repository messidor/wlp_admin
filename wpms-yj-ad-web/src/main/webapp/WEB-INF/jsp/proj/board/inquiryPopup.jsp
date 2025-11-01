<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="form" uri="http://ad.its.yeongju.kr/jsp/jstl/form"%>
<%@ taglib prefix="card" uri="http://ad.its.yeongju.kr/jsp/jstl/card"%>
<%@ taglib prefix="func" uri="http://ad.its.yeongju.kr/jsp/jstl/func"%>
<%@ taglib prefix="label" uri="http://ad.its.yeongju.kr/jsp/jstl/label"%>

<%@ include file="../../core/include/head.jsp"%>
<%@ include file="../../core/include/headerPopup.jsp"%>
<%
String boardId = request.getParameter("boardId");
boardId = boardId == null ? "" : boardId;
%>
<script type="text/javascript">

	var userUrl = "${userUrl}";
	var imageUriData = "";
	var encData = "";
    var reqBid = "<%=boardId%>";

	function loadTableData() {		
		var frm = $("#frmMain");
		frm.addParam("func", "IQ");
	    frm.addParam("dataType", "json");           // 그리드 불러오는 타입 (기본 json)
	    frm.addParam("boardId", $("#hBoardId").val());
	    frm.setAction("<c:url value='/board/selectInquiry.do' />");
		frm.request();
	}
	
	function handleIQ(data, textStatus, jqXHR) {
	    
	    let list = data.data.list;
	    
		if(list.length > 0) {
			$("#frmMain").formSet(list);
			$("#boardContent").css("background-color", "#EEEEEE");
			$('#filePath').attr('href', userUrl + list[0].filePath);
			$('#hFilePath').attr('href', list[0].filePath);
			$('#downloadFilePath').attr('href', userUrl + list[0].filePath);
			$('#downloadFilePath').attr('download', list[0].fileName);
			$("#fileRelKey").val(list[0].fileRelKey);
			
			if(list[0].fileRelKey != null && list[0].fileRelKey != '') {
			    
			    if(list[0].mimeType.indexOf("image/") > -1) {
			        var frm = $("#frmMain");
                    frm.addParam("func", "IQ_Img");
                    frm.setAction("<c:url value='/upload/getImgDataUri.do' />");
                    frm.addParam("fileRelKey", list[0].fileRelKey);
                    frm.addParam("fileKey", list[0].fileKey);
                    frm.addParam("dataType", "json");
                    frm.request();
			    } else {
			        var frm = $("#frmMain");
                    frm.addParam("func", "IQ_Data");
                    frm.setAction("<c:url value='/upload/getEncFileData.do' />");
                    frm.addParam("fileRelKey", list[0].fileRelKey);
                    frm.addParam("fileKey", list[0].fileKey);
                    frm.addParam("dataType", "json");
                    frm.request();
			    }
            }
			
			$("#frmMain").formSet(list);
		} else {
            if(reqBid != "") {
                alert("잘못된 접근입니다.");
                window.close();
            }
		}
	}
	
	// IQ에 대한 이미지
    function handleIQ_Img(data, textStatus, jqXHR) {
        if(data.data.imgDataUri && data.data.imgDataUri.length > 0) {
            imageUriData = data.data.imgDataUri;
            $("#image img").attr("src", data.data.imgDataUri);
        }
    }
	
	// 다운로드용
    function handleIQ_Data(data, textStatus, jqXHR) {
        if(data.data.encData && data.data.encData.length > 0) {
            encData = data.data.encData;
        }
    }
	
	function saveData() {
	    var frm = $("#frmMain");
	    frm.serializeArrayCustom();
	    frm.addParam("func", "IS");
	    frm.addParam("dataType", "json");
	    frm.addParam("enc_col", "userId");
	    frm.setAction("<c:url value='/board/updateInquiry.do' />");
		frm.request();
	}
	
	function handleIS(data, textStatus, jqXHR) {
		self.close();
		opener.loadTableData();
	}
	
	function dataValidation() {
		if($("#boardComment").val() == '') {
			alert("답글을 입력해 주세요.");
			return false;
		}
		
		return true;
	}
	
	$(function(){
		
		$("#btnSave").click(function() {
			if(dataValidation()) {
				if(confirm("저장 하시겠습니까?")) {
					saveData();
				}
			}
		});
		
		$("#btnClose").click(function() {				
			self.close();
		});
		
		$("#fileName").click(function() {
			if(!$('#downloadFilePath').attr('download')){
				//파일경로가 아무것도없으면 동작 하지않는다.
			}else{
				var userUrl = $("#downloadFilePath").attr("href") 
	    		var fileForm = new RegExp(/jpg|png|gif|bmp|jpeg/,"gi"); // 확장자 
	    		var ext = userUrl.match(fileForm); // 파일이름과 확장자 가 일치하는 부분을 찾는다 jpg,png,gif
	    		for(let i = 0; i < ext.length; i++) {
	    		    ext[i] = ext[i].toLowerCase();
	    		}
	    		
				if(ext == 'jpg' || ext == 'png' || ext == 'gif' || ext == 'bmp' || ext == 'jpeg') {     //이미지 파일인 경우 이미지 팝업 open	
					OpenPopupSingle("/sys/imagePopup.do", 1800, 990, "imagePopup");
					
				}else{	 //이미지 파일이아닌 경우 다운로드 되도록 하기.
				    startDownload(encData, "W");
				}
			}
		});
		
		$("#boardComment").keyup(function(){
		    var x = $(this).val().replace(/(<([^>]+)>)/ig,"");;
		    $("#boardComment").val(x);
		}).blur(function(){
            var x = $(this).val().replace(/(<([^>]+)>)/ig,"");;
            $("#boardComment").val(x);
        });
		

		$("textarea.form-control").on("blur",function(){		
        	$(this).val($.trim($(this).val())); 	
        })
		
		loadTableData();
		
		$("#memberPhone").inputMasking("phone");
	});

</script>

<div class="page-body" style="font-size: 0.9em;">
	<div class="row">
		<div class="col-12" id="search_all_wrapper">
			<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12">
				<card:open title="1:1문의" />
				<card:button>
				</card:button>
				<card:content />
				<form id="frmMain" name="frmMain" method="post" onsubmit="return false" class="form-horizontal">
					<input type="hidden" id="fileRelKey" name="fileRelKey" value="" />
					<form:input id="hBoardId" type="hidden" value="${param.boardId}" />
					<form:input id="uploadFolder" type="hidden" value="board/" />
					<label:input id="memberId" caption="ID" size="20" state="readonly" stateIcon="fas fa fa-eye" addClassName="text-left" />
					<label:input id="memberName" caption="작성자" size="12" state="readonly" stateIcon="fas fa fa-eye" addClassName="text-left" />
					<label:input id="memberPhone" caption="연락처" size="12" state="readonly" stateIcon="fas fa fa-eye" addClassName="text-left" />
					<label:input id="boardTitle" caption="제목" size="12" state="readonly" stateIcon="fas fa fa-eye" addClassName="text-left" />
					<label:textarea id="boardContent" caption="내용" size="12" state="readonly" stateIcon="fas fa fa-eye" rows="10" />
					<label:textarea id="boardComment" caption="답글" size="12" className="danger" stateIcon="fas fa-pencil-alt" rows="10" addAttr="maxlength='250'" />
					<div class="form-group col-xl-12 col-lg-12 col-md-12 col-12 no-margin no-padding has-defualt">
                        <label class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right">파일</label>
                        <div class="col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached">
                            <div class="input-group">
                                <span class="input-group-addon" style="width: 38px;">
                                    <i class="fas fa-mouse-pointer" data-icon="fas fa-mouse-pointer"></i>
                                </span>
                                <a href="/" id="downloadFilePath" download></a> 
                                <a href="/" id="filePath" style="display:none;" data-fancybox="" data-small-btn="true"></a>
                                <a href="/" id="hFilePath" style="display:none;" data-fancybox="" data-small-btn="true"></a>
                                <input type="file" name="multiFiles" id="multiFiles" style="display:none;" accept=".pdf, .jpg, .jpeg, .png, .gif, .hwp, .hwpx, .xls, .xlsx">
                                <input name="fileName" id="fileName" class="form-control" type="text" readonly="readonly" data-path="" style="font-weight:bold; cursor:pointer;">       
                            </div>
                        </div>
                    </div>
				</form>
				<card:close />
			</div>
		</div>
	</div>
	<div class="row padding-left-10 padding-right-10">
		<div class="bottom-btn-area">
			<div class="col-xl-6 col-lg-6 col-md-6 col-sm-12 col-12"></div>
			<div class="col-xl-6 col-lg-6 col-md-6 col-sm-12 col-12 text-right">
				<form:button type="Save" id="btnSave" />
				<form:button type="Close" id="btnClose" />
			</div>
			<label:clear />
		</div>
	</div>
</div>