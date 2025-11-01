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
    padding:3px 3px 3px 6px;
    margin-right:5px;
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
    margin: 0 0 10px 0;
}

.list-del-btn2:last-child {
    margin-bottom:0px;
}
.upperbar-remove::before {
    content: none !important;
}
</style>
<script type="text/javascript" src="<c:url value='/common/js/compressor/compressor-1.2.1.min.js'/>"></script>
<script type="text/javascript" src="<c:url value='/common/js/compressor/compressor.common-1.2.1.js'/>"></script>
<script type="text/javascript" src="<c:url value='/common/js/compressor/compressor.esm-1.2.1.js'/>"></script>
<script type="text/javascript" src="<c:url value='/common/js/etcs/chunkUploadMulti.js'/>"></script>
<script type="text/javascript" src="<c:url value='/common/js/etcs/common.js'/>"></script>

<script type="text/javascript">

    function loadTableData() {
        var frm = $("#frmMain");
        frm.addParam("func", "IQ");
        frm.addParam("dataType", "json");           // 그리드 불러오는 타입 (기본 json)
        frm.addParam("boardId", $("#hBoardId").val());
        frm.addParam("query_id", "board.announcement.Select_Preview");
        frm.request();
    }
    
    function handleIQ(data, textStatus, jqXHR) {
        if(data.length > 0) {
            $(".tit").children("strong").text(data[0].boardTitle);
            
            var html = data[0].boardContent;
            
            if(data[0].contentViewYn == "Y") {
                $(".cont").append("<p>" + html + "</p>");
            } else {
                $(".cont").css("display", "none");
                $("#video_area").css("padding-top", "0px").addClass("upperbar-remove");
                $("#image_area").css("padding-top", "0px").addClass("upperbar-remove");
            }
            
            
            var bool = false;
            // 이미지 파일만 미리보기 처리
            for(var i=0; i<data.length; i++){
                if(data[i].fileName !== null) {
                    if(data[i].mimeType.indexOf("image/") > -1){
                        bool = true;
                        
                        var frm = $("#frmMain");
                        frm.addParam("func", "IQ_Img");
                        frm.setAction("<c:url value='/upload/getImgDataUri.do' />");
                        frm.addParam("fileRelKey", data[i].fileRelKey);
                        frm.addParam("fileKey", data[i].fileKey);
                        frm.addParam("fileName", data[i].fileName);
                        frm.addParam("dataType", "json");
                        frm.addParam("mainImgYn", "img");
                        frm.request();
                        
                        break;
                    } else if(data[i].mimeType.indexOf("video/") > -1) {
                        bool = true;
                        
                        var frm = $("#frmMain");
                        frm.addParam("func", "IQ_Img");
                        frm.setAction("<c:url value='/upload/getVideoDataUri.do' />");
                        frm.addParam("fileRelKey", data[i].fileRelKey);
                        frm.addParam("fileKey", data[i].fileKey);
                        frm.addParam("fileName", data[i].fileName);
                        frm.addParam("dataType", "json");
                        frm.addParam("mainImgYn", "mv");
                        frm.request();
                       
                        break;
                    }
                }
            }
            

            if(!bool){
                $(".img_box").hide();
            }
            
        } 
    }
    
    // IQ에 대한 이미지
    function handleIQ_Img(data, textStatus, jqXHR) {
        if(data.data.imgDataUri && data.data.imgDataUri.length > 0) {
            if(data.data.mainImgYn.indexOf("img") > -1) {
                $("#image_area").children("img").attr("src", data.data.imgDataUri);
                $("#image_area").children("img").attr("alt", data.data.fileName);
            } else if(data.data.mainImgYn.indexOf("mv") > -1) {
                $("#image_area").css("display", "none");
                $("#video_area").css("display", "");
                
                $("#video_area source").attr("src", data.data.imgDataUri);
                
                $("#playVideo")[0].load();
                $("#playVideo")[0].play();
                
                setTimeout(function() {
                    $("#playVideo").css({
                        "max-width" : $("#playVideo").width(),
                        "width" : "100%",
                    });
                }, 100);
            }
        } else {
            $(".img_box").hide();
        }
    }

    
    $(function(){
        
        $("#btnClose").click(function() {
            self.close();
        });
        
        loadTableData();
    });

</script>

<div class="page-body" style="font-size: 0.9em;">
    <div class="row">
        <div class="col-12" id="search_all_wrapper">
            <div class="card"> 
                <div class="card-header"> 
                    <h5>공지사항 미리보기</h5> 
                </div> 
                   <div class="card-block table-border-style" style="height:690px"> 
                    <div class="view_box">
                        <form id="frmMain" name="frmMain" method="post" onsubmit="return false" class="form-horizontal">
                            <form:input id="hBoardId" type="hidden" value="${param.boardId}" />
                            <div class="tit">
                                <strong>타이틀이 들어갑니다.</strong>
                            </div>
                            <div class="cont">
                            </div>
                            <div class="img_box" id="image_area">
                                <img src="/walletfree-admin/assets/images/no_img.jpg" alt="이미지없음">
                            </div>
                            <div class="img_box" id="video_area" style="display:none">
                                <video id="playVideo" controls muted>
                                    <source src="" />
                                </video>
                            </div>
                        </form>
                    </div>
                </div> 
            </div> 
        </div>
    </div>
    <div class="row padding-left-5 padding-right-5">
        <div class="bottom-btn-area">
            <div class="col-xl-6 col-lg-6 col-md-6 col-sm-12 col-12"></div>
            <div class="col-xl-6 col-lg-6 col-md-6 col-sm-12 col-12 text-right">
                <form:button type="Close" id="btnClose" />
            </div>
            <label:clear />
        </div>
    </div>
</div>