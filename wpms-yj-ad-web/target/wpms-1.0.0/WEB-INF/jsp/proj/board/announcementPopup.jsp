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
<style type="text/css">
.custom-btn {
    padding: 0px 3px 0px 3px;
    /* margin-right:5px; */
    -webkit-touch-callout: none;
    -webkit-user-select: none;
    -ms-user-select: none;
    user-select: none;
}
.list-del-btn {
    margin: 0 0 10px 0;
    cursor: pointer;
}

.list-del-btn:last-child {
    margin-bottom:0px;
}
.list-del-btn2 {
    margin: 0 0 -2px 0;
}

.list-del-btn2:last-child {
    margin-bottom:0px;
}
.inline-block {
    display: inline-block;
    vertical-align: middle;
}
.list-del-btn {
    margin: 0;
    padding: 0;
    width: 60%;
}

.file-name-wrapper {
    display: flex;
}
.file-name-wrapper .td1 {
    width: 15%;
}
.file-name-wrapper .td2 {
    width: 25%;
}
</style>
<script type="text/javascript" src="<c:url value='/common/js/compressor/compressor-1.2.1.min.js'/>"></script>
<script type="text/javascript" src="<c:url value='/common/js/compressor/compressor.common-1.2.1.js'/>"></script>
<script type="text/javascript" src="<c:url value='/common/js/compressor/compressor.esm-1.2.1.js'/>"></script>
<script type="text/javascript" src="<c:url value='/common/js/etcs/chunkUploadMulti.js'/>"></script>
<script type="text/javascript" src="<c:url value='/common/js/etcs/common.js'/>"></script>

<script type="text/javascript">

    var cuObj;
    var isFileReady = false;
    var imageUriData = "";
    var encData = "";
    var fRKey = "";
    var reqBid = "<%=boardId%>";

	function loadTableData() {
	    
	    var frm = $("#frmMain");
        frm.addParam("func", "IQ");
        frm.addParam("dataType", "json");           // 그리드 불러오는 타입 (기본 json)
        frm.addParam("boardId", $("#hBoardId").val());
        frm.setAction("<c:url value='/board/selectNotice.do' />");
        frm.request();
	}
	
	function handleIQ(data, textStatus, jqXHR) {
	    let list = data.data.list;
	    
	    if(list[0].popNotice == "PN001"){
            $("#popNoticeDate").parent().parent().parent().hide();
            $("#contentViewYn").parent().parent().parent().hide();
            $("#popNoticeOrder").parent().parent().parent().hide();
			$("#popNoticeDate").val("");
			
		} else {
            $("#popNoticeDate").parent().parent().parent().show();
            $("#contentViewYn").parent().parent().parent().show();
            $("#popNoticeOrder").parent().parent().parent().show();
			
			if(list[0].popNoticeStartDate != null) {
				$("#popNoticeDate").data('daterangepicker').setStartDate(list[0].popNoticeStartDate);
			}
			
			if(list[0].popNoticeEndDate != null) {
				$("#popNoticeDate").data('daterangepicker').setEndDate(list[0].popNoticeEndDate);
			}
	        
		}
	    
		if(list.length > 0) {
			if(list[0].filePath != '') {
				// $('#filePath').attr('href', "/walletfree-admin" + data[0].filePath);
				// $('#downloadFilePath').attr('href', "/walletfree-admin" + data[0].filePath);
				// $('#downloadFilePath').attr('download', data[0].fileName);
				// $("#hFilePath").attr('href', data[0].filePath);
				$("#fileRelKey").val(list[0].fileRelKey);
			}
			
			for(let i = 0; i < list.length; i++) {
			    if(list[i].fileRelKey != null && list[i].fileRelKey != '' && list[i].fileKey != null && list[i].fileKey != '') {
			        
			        fRKey = list[i].fileRelKey;
	                
	                if(list[i].mimeType.indexOf("image/") > -1) {
	                    var frm = $("#frmMain");
	                    frm.addParam("func", "IQ_Img");
	                    frm.setAction("<c:url value='/upload/getImgDataUri.do' />");
	                    frm.addParam("fileRelKey", list[i].fileRelKey);
	                    frm.addParam("fileKey", list[i].fileKey);
	                    frm.addParam("fileName", list[i].fileName);
	                    frm.addParam("mainImgYn", "img_" + list[i].mainImgYn + "_mobImg_" + list[i].mobImgYn);
	                    frm.addParam("dataType", "json");
	                    frm.request();
	                } else if(list[i].mimeType.indexOf("video/") > -1) {
	                    var frm = $("#frmMain");
                        frm.addParam("func", "IQ_Img");
                        frm.setAction("<c:url value='/upload/getVideoDataUri.do' />");
                        frm.addParam("fileRelKey", list[i].fileRelKey);
                        frm.addParam("fileKey", list[i].fileKey);
                        frm.addParam("fileName", list[i].fileName);
                        frm.addParam("mainImgYn", "mv_" + list[i].mainImgYn);
                        frm.addParam("dataType", "json");
                        frm.request();
	                } else {
	                    var frm = $("#frmMain");
	                    frm.addParam("func", "IQ_Data");
	                    frm.setAction("<c:url value='/upload/getEncFileData.do' />");
	                    frm.addParam("fileRelKey", list[i].fileRelKey);
	                    frm.addParam("fileKey", list[i].fileKey);
	                    frm.addParam("fileName", list[i].fileName);
	                    frm.addParam("mainImgYn", "file_N");
	                    frm.addParam("dataType", "json");
	                    frm.request();
	                }
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
//             imageUriData = data.data.imgDataUri;
//             $("#image img").attr("src", data.data.imgDataUri);
            $("#uploadedFiles").append(createAttachedFiles(data.data.fileName, data.data.imgDataUri, "", data.data.fileKey, data.data.mainImgYn));
        }
    }
    
    // 다운로드용
    function handleIQ_Data(data, textStatus, jqXHR) {
        if(data.data.encData && data.data.encData.length > 0) {
//             encData = data.data.encData;
            $("#uploadedFiles").append(createAttachedFiles(data.data.fileName, "", data.data.encData, data.data.fileKey, data.data.mainImgYn));
        }
    }
    // haha
    function createAttachedFiles(fileName, dataUri, downData, fileKey, gubn) {
        
        let mainChecked = "";
        let mobMainChecked = "";
        
        // 이미지 여부
        if (gubn.indexOf('img') != -1 || gubn.indexOf("mv_") > -1) {
            let mainYn = gubn.indexOf('img_Y') != -1 ? "Y" : "N";
            
            // 메인이미지 여부
            if(gubn.indexOf('img_Y') != -1 || gubn.indexOf("mv_Y") > -1) {
                mainChecked = " checked ";
            } else {
                mainChecked = "";
            }
            
            if(gubn.indexOf("mobImg_Y") > -1) {
                mobMainChecked = " checked ";
            } else {
                mobMainChecked = "";
            }
        }
        
    	// 이미지 여부
    	if (gubn.indexOf('img') != -1 || gubn.indexOf("mv_") > -1) {
			let mainYn = gubn.indexOf('img_Y') != -1 ? "Y" : "N";
			// 메인이미지 여부
			if(gubn.indexOf('img_Y') != -1 || gubn.indexOf("mv_Y") > -1){
				return `
			        <div class="file-name-wrapper">
				        <label class="td1"><input type="radio" name="mainImg" class="inline-block"` + mainChecked + ` />&nbsp;PC</label>
				        <label class="td2"><input type="radio" name="mainMobImg" class="inline-block"` + mobMainChecked + ` />&nbsp;모바일</label>
			            <p class="list-del-btn inline-block" data-id="viewFile" data-dataUri="` + dataUri + `" data-downData="` + downData + `" data-gubn="` + gubn + `">
				            ` + fileName + `
				            <span class="btn-danger custom-btn" data-id="removeUploadedFiles" data-fk="` + fileKey + `" style="float:right;">
				                <i class="fas fa-times"> </i>
				            </span>
				        </p>
			        </div>
		        `;
			}else{
				return `
	                <div class="file-name-wrapper">
				        <label class="td1"><input type="radio" name="mainImg" class="inline-block"` + mainChecked + ` />&nbsp;PC</label>
	                    <label class="td2"><input type="radio" name="mainMobImg" class="inline-block"` + mobMainChecked + ` />&nbsp;모바일</label>
			            <p class="list-del-btn inline-block" data-id="viewFile" data-dataUri="` + dataUri + `" data-downData="` + downData + `" data-gubn="` + gubn + `">
				            ` + fileName + `
				            <span class="btn-danger custom-btn" data-id="removeUploadedFiles" data-fk="` + fileKey + `" style="float:right;">
				                <i class="fas fa-times"> </i>
				            </span>
				        </p>
                    </div>
		        `;
			}
   		} else {
   		    return `
               <div class="file-name-wrapper">
	               <label class="td1"><input type="radio" name="mainImg" class="inline-block" disabled />&nbsp;PC</label>
	               <label class="td2"><input type="radio" name="mainMobImg" class="inline-block" />&nbsp;모바일</label>
		           <p class="list-del-btn inline-block" data-id="viewFile" data-dataUri="` + dataUri + `" data-downData="` + downData + `" data-gubn="` + gubn + `">
			           ` + fileName + `
			           <span class="btn-danger custom-btn" data-id="removeUploadedFiles" data-fk="` + fileKey + `" style="float:right;">
			               <i class="fas fa-times"> </i>
			           </span>
			       </p>
                </div>
	        `;
   		}
    }
	 
	function saveData() {
		if($("#multiFiles").val() == "") {
		    var frm = $("#frmMain");
		    
		    frm.serializeArrayCustom();
		    
		    if($("#popNotice").val() == "PN001"){
		    	frm.addParam("popNoticeStartDate", "");
				frm.addParam("popNoticeEndDate", "");
		    } else {
		    	frm.addParam("popNoticeStartDate", moment(replaceDate($("#popNoticeDate").val())[0]).format('YYYYMMDD'));
				frm.addParam("popNoticeEndDate", moment(replaceDate($("#popNoticeDate").val())[1]).format('YYYYMMDD'));
		    }
		    frm.addParam("func", "IS");
		    frm.addParam("dataType", "json");
		    frm.addParam("ajaxType", "file");
		    frm.addParam("enc_col", "userId");
		    frm.setAction("<c:url value='/board/insertNotice.do' />");
		    frm.request();
		} else {
		    cuObj.url = "<c:url value='/board/insertNotice.do' />"; // URL 설정
		    var index = getMainImgIndex(); 
		    
		    let dataObj = $("#frmMain").serializeArray();
            for(let i = 0; i < dataObj.length; i++) {
                cuObj.param[dataObj[i]["name"]] = dataObj[i]["value"];
            }
            if($("#popNotice").val() == "PN001"){
                cuObj.param["popNoticeStartDate"] = "";
                cuObj.param["popNoticeEndDate"] = "";
            } else {
                cuObj.param["popNoticeStartDate"] = moment(replaceDate($("#popNoticeDate").val())[0]).format('YYYYMMDD');
                cuObj.param["popNoticeEndDate"] = moment(replaceDate($("#popNoticeDate").val())[1]).format('YYYYMMDD');
            }
            cuObj.param["mainImgIndex"] = index;
		    cuObj.param["enc_col"] = "userId";
            cuObj.goUpload();
		}
	}
	
	function saveData2() {
		if($("#multiFiles").val() == "") {
		    var frm = $("#frmMain");
		    var key = getMainImgKey(); 
		    var mobKey = getMobileImgKey();
		    frm.serializeArrayCustom();
		    
		    if($("#popNotice").val() == "PN001"){
		    	frm.addParam("popNoticeStartDate", "");
				frm.addParam("popNoticeEndDate", "");
		    } else {
		    	frm.addParam("popNoticeStartDate", moment(replaceDate($("#popNoticeDate").val())[0]).format('YYYYMMDD'));
				frm.addParam("popNoticeEndDate", moment(replaceDate($("#popNoticeDate").val())[1]).format('YYYYMMDD'));
		    }
		    
		    
		    frm.addParam("func", "IS");
		    frm.addParam("dataType", "json");
		    frm.addParam("ajaxType", "file");
		    frm.addParam("enc_col", "userId");
		    frm.addParam("mainFileKey", key);
		    frm.addParam("mainMobKey", mobKey);
		    frm.setAction("<c:url value='/board/updateNotice.do' />");
			frm.request();
		} else {
            cuObj.url = "<c:url value='/board/updateNotice.do' />"; // URL 설정
            var key = getMainImgKey();
            
            let dataObj = $("#frmMain").serializeArray();
            for(let i = 0; i < dataObj.length; i++) {
            	cuObj.param[dataObj[i]["name"]] = dataObj[i]["value"];
            }
            if($("#popNotice").val() == "PN001"){
                cuObj.param["popNoticeStartDate"] = "";
                cuObj.param["popNoticeEndDate"] = "";
            } else {
                cuObj.param["popNoticeStartDate"] = moment(replaceDate($("#popNoticeDate").val())[0]).format('YYYYMMDD');
                cuObj.param["popNoticeEndDate"] = moment(replaceDate($("#popNoticeDate").val())[1]).format('YYYYMMDD');
            }
            
            cuObj.param["mainFileKey"] = key;
            cuObj.param["enc_col"] = "userId";
            cuObj.goUpload();
        }
	}
	
    function getMainImgIndex(){
        var idx = 0;
        
        $("input[type='radio'][name='mainImg']").each(function(index, elem) {
            if($(elem).is(":checked")) {
                idx = index + 1;
                return true;
            }
        });
        
        return idx;
    }
    
    function getMainImgKey(){
        var key = "";
        
        $("input[type='radio'][name='mainImg']").each(function(idx, elem) {
            if($(elem).is(":checked")) {
                //key = $(elem).next().find("span").attr("data-fk");
                key = $(elem).parent().parent().find("span[data-fk]").attr("data-fk");
                return true;
            }
        });
        
        return key;
    }
    
    function getMobileImgKey(){
        var key = "";
        
        $("input[type='radio'][name='mainMobImg']").each(function(idx, elem) {
            if($(elem).is(":checked")) {
                //key = $(elem).next().find("span").attr("data-fk");
                key = $(elem).parent().parent().find("span[data-fk]").attr("data-fk");
                return true;
            }
        });
        
        return key;
    }
	
	function deleteData() {
		var frm = $("#frmMain");
		frm.serializeArrayCustom();
		frm.addParam("func", "IS");
		frm.addParam("hBoardId", $("#hBoardId").val());
		frm.addParam("query_id", "board.announcement.Delete_PopupData");
		frm.addParam("dataType", "json");
		frm.setAction("<c:url value='/board/deleteNotice.do' />");
		frm.request();
	}
	
	function handleIS(data, textStatus, jqXHR) {
		self.close();
		opener.loadTableData();
	}
	
	function dataValidation() {
		if($("#boardTitle").val() == '') {
			alert("제목을 입력해 주세요.");
			return false;
		}
		
		if($("#boardContent").val() == '') {
			alert("내용을 입력해 주세요.");
			return false;
		}
		
		if($("#popNotice").val() == '') {
			alert("팝업공지화면을 선택해 주세요.");
			return false;
		}
		
		if($("#contentViewYn").val() == '') {
			alert("공지내용표시여부를 선택해 주세요.");
			return false;
		}
		
		if($("#popNoticeOrder").val() == '') {
			alert("팝업공지순서를 선택해 주세요.");
			return false;
		}
		
		if($("#popNotice").val() != 'PN001'){
			if($("#popNoticeDate").val() == '') {
				alert("팝업공지기간을 선택해 주세요.");
				return false;
			}
		}
		
		return true;
	}
	
	function singleFileDelete(fk) {
	    let frm = $("#frmMain");
	    frm.addParam("func", "DL_File");
        frm.addParam("dataType", "json");
        frm.addParam("fileRelKey", fRKey);
        frm.addParam("fileKey", fk);
        frm.addParam("enc_col", "userId");
        frm.addParam("hBoardId", $("#hBoardId").val());
        frm.setAction("<c:url value='/board/deleteFile.do' />");
        frm.request();
	}
	
	function handleDL_File(data, textStatus, jqXHR) {
        if(data.count > 0) {
        	$("span[data-fk='" + data.data.fileKey + "']").parent().parent().remove();
        } else {
            alert(data.message);
        }
	}
	
	$(function(){
		$("#popNoticeDate").initDateOnly("month", 0, "month", 1);
		
        // 제목 앞뒤공백없애기
       	$("input.form-control").on("blur",function(){
        	$(this).val($.trim($(this).val()));
        })
		
		// 내용 앞뒤공백없애기
		$("textarea.form-control").on("blur",function(){
        	$(this).val($.trim($(this).val()));
        })
		
		cuObj = new ChunkUploadMulti(document.getElementById("multiFiles")); // upload file 객체를 넣어주어야 함
	    cuObj.addFileEvent(); // 초기화 하고 실행해 주어야 함
	    cuObj.uploadFileExt = "bmp|pdf|jpg|jpeg|png|gif|hwp|hwpx|xls|xlsx|doc|docx|mp4|webm|ogg"; // 기본값은 "pdf|jpg|jpeg|png|gif|hwp|hwpx|xls|xlsx" 이며, 확장자를 "|" 으로 구분할 것
	    cuObj.fileExtChange(); // uploadFileExt 속성을 바꾸고 실행해줘야 함
	    cuObj.maxFileSize = 50 * 1024 * 1024;
	    cuObj.setFilesLimit(5);
	    cuObj.param["fileRelKey"] = fRKey;
	    
	    // 파일을 선택하지 않고 업로드 버튼을 누르면 발생하는 이벤트
	    cuObj.onNoFileSelected = function() {
	    	alert("파일을 선택해 주세요.");
	    	$("#result").val("");
	    };
	    
	    // 모두 성공시 발생하는 함수
	    cuObj.onSuccessFunc = function(percent, curIdx, totalIdx, result, textStatus, jqXHR, allPercent) {
	        //document.getElementById("result").value = percent + "% (" + (curIdx + 1) + " / " + totalIdx + ") " + result.message;
	        self.close();
	        opener.loadTableData();
	    };
	    
	    // 업로드 과정이 성공적으로 진행되는 도중에 발생하는 함수
	    cuObj.onProcessFunc = function(percent, curIdx, totalIdx, result, textStatus, jqXHR, allPercent) {
	        document.getElementById("result").value = allPercent + "%";
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
	        $("#result").val("파일 업로드 준비 중입니다.");
	    };
	    
	    // 파일을 선택한 후 내부 처리를 다 하면 발생하는 이벤트
	    // 비활성화된 업로드 버튼을 다시 활성화 시키는 것을 추천
	    // file 객체가 파라미터로 넘어온다.
	    cuObj.onAfterFileChange = function(e) {
	        // imageUriData = e.target.result;
	        isFileReady = true;
	        // $("#fileName").val($("#multiFiles")[0].files[0].name);
	        
	        // $("#filePath").attr("href", e.target.result);
	        // $("#downloadFilePath").attr("href", e.target.result);
	        
	        let fileObj = cuObj.getUploadFileInfo();
	        $("#waitUploadFiles").html("");
	        
	        for(let i = 0; i < fileObj.length; i++) {
	        	var html = "";
	        	
	        	if(fileObj[i].base64.indexOf("image/") > -1){
	        		html += "<input type=\"radio\" name=\"mainImg\" class=\"inline-block\"/> <p class=\"list-del-btn2 inline-block\" data-id=\"viewTempFile\" style=\"width:95%;\">" + fileObj[i]["fileName"] + "</p>";
	        	}else{
	        		html += "<input type=\"radio\" name=\"mainImg\" class=\"inline-block\" disabled/> <p class=\"list-del-btn2 inline-block\" data-id=\"viewTempFile\" style=\"width:95%;\">" + fileObj[i]["fileName"] + "</p>";
	        	}
	            $("#waitUploadFiles").append(
	                    //"<p class=\"list-del-btn\"><span class=\"btn-danger custom-btn\" data-id=\"removeUploadedFiles\"><i class=\"fas fa-times\"> </i></span>" + e.target.files[i].name + "</p>"
	                    html
                );
	        }
	        
	        alert("업로드 할 준비를 마쳤습니다.");
	        $("#result").val("업로드 할 준비를 마쳤습니다.");
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
	    
		$("#fileData").hide();
		
		$("#btnSave").click(function() {
			
			// file validation
			
			if(!isFileReady && $("#multiFiles").val() != "") {
				alert("파일이 준비된 후에 진행해 주시기 바랍니다.");
				return;
			}
			
			if(dataValidation()) {
				if(confirm("저장 하시겠습니까?")) {
					if($("#hBoardId").val() != '') {
						saveData2();
					} else {
						saveData();
					}
				}
			}
		});
		
		$("#btnDelete").click(function() {				
			if(confirm("삭제 하시겠습니까?")) {
				deleteData();
			}
		});
		
		$("#btnClose").click(function() {				
			self.close();
		});
		
		$("#btnUpload").click(function() {
			$("[name='multiFiles']").trigger("click");
		});
		
		$("#fileName").click(function() {
			if($("#fileName").val() != ""){
				var exe = $("#fileName").val().split(".")[$("#fileName").val().split(".").length-1];
				
				if(exe == "jpg" || exe == "png" || exe == "gif"){
					OpenPopupSingle("/sys/imagePopup.do", 1800, 990, "imagePopup");
				}else{
				    startDownload(encData, "W");
				}				
			}
		});
		
		$("#boardContent").keyup(function(){
		    var x = $(this).val().replace(/(<([^>]+)>)/ig,"");;
		    $("#boardContent").val(x);
		}).blur(function(){
            var x = $(this).val().replace(/(<([^>]+)>)/ig,"");;
            $("#boardContent").val(x);
        });
		
		$("#boardTitle").keyup(function(){
            var x = $(this).val().replace(/(<([^>]+)>)/ig,"");;
            $("#boardTitle").val(x);
        }).blur(function(){
            var x = $(this).val().replace(/(<([^>]+)>)/ig,"");;
            $("#boardTitle").val(x);
        });
		
		//--------
		
		$("#btnSelectFile").click(function() {
            if($("p[data-id='viewFile']").length >= cuObj.getFilesLimit()) {
                alert("이미 업로드 된 파일 개수가 최대치인 " + cuObj.getFilesLimit() + "개 입니다.\n(게시글 하나당  " + cuObj.getFilesLimit() + "개까지 업로드 가능)");
                return;
            }
            $("#result").val("");
            $("#waitUploadFiles").text("");
            $("#multiFiles").val("");
		    $("#multiFiles").trigger("click");
		});
		
		$("#btnRemoveFile").click(function() {
		    $("#multiFiles").val("");
		    $("#waitUploadFiles").html("");
		});
		
		// 이미 업로드된 파일 삭제
		$("#uploadedFiles").on("click", "span[data-id='removeUploadedFiles']", function(ev) {
		    ev.stopPropagation();
		    if(confirm("첨부파일을 지우시겠습니까? 지워진 파일은 복구할 수 없습니다.")) {
		        singleFileDelete($(this).attr("data-fk"));
		    }
		});
		
		// 이미 업로드 된 파일 보기
		$("#uploadedFiles").on("click", "p[data-id='viewFile']", function(ev) {
            ev.stopPropagation();
            let obj = $(this);
            
            if(obj.attr("data-dataUri").length > 0) {
                // 이미지 show
                if(obj.attr("data-gubn").indexOf("img_") > -1) {
	                imageUriData = obj.attr("data-dataUri");
	                OpenPopupSingle("/sys/imagePopup.do", 1800, 990, "imagePopup");
                } else if(obj.attr("data-gubn").indexOf("mv_") > -1) {
                    imageUriData = obj.attr("data-dataUri");
                    OpenPopupSingle("/sys/videoPopup.do", 1440, 755, "imagePopup");
                }
            } else {
                // file download
                startDownload(obj.attr("data-downData"), "W");
            }
        });
		
		$("#btnPreview").click(function(){
			OpenPopupSingle("/board/announcementPreviewPopup.do?boardId=" + $("#hBoardId").val() , 800, 855, "_PreviewPop");
		});
		
	
		$("#popNotice").change(function(){
			if($(this).val() == "PN001") {
			    $("#popNoticeDate").parent().parent().parent().hide();
			    $("#contentViewYn").parent().parent().parent().hide();
			    $("#popNoticeOrder").parent().parent().parent().hide();
				$("#popNoticeDate").val("");
			} else {
                $("#popNoticeDate").initDateOnly("month", 0, "month", 1);
                $("#popNoticeDate").parent().parent().parent().show();
                $("#contentViewYn").parent().parent().parent().show();
                $("#popNoticeOrder").parent().parent().parent().show();
			}
		});
		
		<c:choose>
		<c:when test="${param.boardId != null}">
		loadTableData();
		</c:when>
		<c:otherwise>
		if($("#popNotice").val() == "PN001") {
		    $("#popNoticeDate").parent().parent().parent().hide();
		    $("#contentViewYn").parent().parent().parent().hide();
		    $("#popNoticeOrder").parent().parent().parent().hide();
		    $("#popNoticeDate").val("");
		}
		</c:otherwise>
		</c:choose>
	});

</script>

<div class="page-body" style="font-size: 0.9em;">
	<div class="row">
		<div class="col-12" id="search_all_wrapper">
			<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12">
				<card:open title="공지사항" />
				<card:button>
				</card:button>
				<card:content />
				<form id="frmMain" name="frmMain" method="post" onsubmit="return false" class="form-horizontal">
				    <input type="hidden" id="fileRelKey" name="fileRelKey" value="" />
					<form:input id="hBoardId" type="hidden" value="${param.boardId}" />
					<form:input id="uploadFolder" type="hidden" value="board/" />
					<label:input id="boardTitle" caption="제목" size="12" stateIcon="fas fa fa-pencil-alt" addClassName="text-left" addAttr="maxlength='250'" className="danger"/>
					<label:textarea id="boardContent" caption="내용" size="12" stateIcon="fas fa-pencil-alt" rows="12" addAttr="maxlength='1300'" className="danger"/>
					<label:select id="popNotice" queryId="#POP_NOTICE" caption="팝업공지화면" size="12" all="false" allLabel="선택" className="danger"/>
					<label:select id="contentViewYn" queryId="#CONTENT_VIEW_YN" caption="공지내용표시여부" size="12" all="false" allLabel="선택" className="danger"/>
					<label:select id="popNoticeOrder" queryId="#POP_NOTICE_ORDER" caption="팝업공지순서" size="12" all="false" allLabel="선택" className="danger"/>
					<label:input id="popNoticeDate" queryId="" caption="팝업공지기간" size="12" className="danger"/>
					<!-- 
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
                                <span class="input-group-btn">
                                    <button id="btnUpload" type="button" name="btnModalDocList" class="btn btn-sm btn-secondary" style="line-height: 17px;">첨부/변경</button>
                                </span>
                            </div>
                        </div>
                    </div>
                     -->
                    <div class="form-group col-xl-12 col-lg-12 col-md-12 col-12 no-margin no-padding has-defualt">
                        <label class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right">첨부파일</label>
                        <div class="col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached">
                            <div class="input-group">
                                <span class="input-group-addon" style="width: 38px;">
                                    <i class="fas fa-list" data-icon="fas fa-list"></i>
                                </span>
                                <div id="uploadedFiles" name="uploadedFiles" class="form-control fill" style="font-weight:bold; color:#000; min-height:32px;">
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="form-group col-xl-12 col-lg-12 col-md-12 col-12 no-margin no-padding has-defualt">
                        <label class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right">업로드파일</label>
                        <div class="col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached">
                            <div class="input-group">
                                <span class="input-group-addon" style="width: 38px;">
                                    <i class="fas fa-list" data-icon="fas fa-list"></i>
                                </span>
                                <div id="waitUploadFiles" name="waitUploadFiles" class="form-control fill" style="font-weight:bold; color:#000; min-height:32px;">
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="form-group col-xl-12 col-lg-12 col-md-12 col-12 no-margin no-padding has-defualt">
                        <label class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right">버튼</label>
                        <div class="col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached">
	                        <div class="input-group">
	                            <button id="btnSelectFile" type="button" class="btn btn-sm btn-secondary" style="line-height: 17px; width:50%;">첨부/변경</button>
	                            <button id="btnRemoveFile" type="button" class="btn btn-sm btn-danger" style="line-height: 17px; width:50%;">삭제</button>
	                        </div>
                        </div>
                    </div>
                    <div class="form-group col-xl-12 col-lg-12 col-md-12 col-12 no-margin no-padding has-defualt">
                        <label class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right">업로드 상황</label>
                        <div class="col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached">
                            <div class="input-group">
                                <span class="input-group-addon" style="width: 38px;">
                                    <i class="fas fa-clock" data-icon="fas fa-clock"></i>
                                </span>
                                <input type="text" disabled class="form-control" style="font-weight:bold;" name="upload_process" id="result" value="0%">
                            </div>
                        </div>
                    </div>
                    <input type="file" name="multiFiles" id="multiFiles" style="display:none;" multiple>
				</form>
				<card:close />
			</div>
		</div>
	</div>
	<div class="row padding-left-5 padding-right-5">
		<div class="bottom-btn-area">
			<div class="col-xl-6 col-lg-6 col-md-6 col-sm-12 col-12"></div>
			<div class="col-xl-6 col-lg-6 col-md-6 col-sm-12 col-12 text-right">
				<c:if test="${param.boardId != null}">
					<form:button type="Search" id="btnPreview" caption="미리보기" />
				</c:if>
				<form:button type="Save" id="btnSave" />
				<c:if test="${param.boardId != null}">
					<form:button type="Delete" id="btnDelete" />
				</c:if>
				<form:button type="Close" id="btnClose" />
			</div>
			<label:clear />
		</div>
	</div>
</div>