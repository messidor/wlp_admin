<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="form" uri="http://ad.its.yeongju.kr/jsp/jstl/form" %>
<%@ taglib prefix="card" uri="http://ad.its.yeongju.kr/jsp/jstl/card" %>
<%@ taglib prefix="func" uri="http://ad.its.yeongju.kr/jsp/jstl/func" %>
<%@ taglib prefix="label" uri="http://ad.its.yeongju.kr/jsp/jstl/label" %>

<%@ include file="../../core/include/head.jsp" %>
<%@ include file="../../core/include/headerPopup.jsp" %>

<script type="text/javascript">
    
    $(function() {
        if(opener.imageUriData && opener.imageUriData != '') {
            $("#playVideo source").attr("src", opener.imageUriData);
            $("#playVideo")[0].load();
            $("#playVideo")[0].play();
            
            setTimeout(function() {
                $("#playVideo").css({
                    "max-width" : $("#playVideo").width(),
                    "width" : "100%",
                });
            }, 300);
        }
    });
</script>

<div class="page-body" style="font-size: 0.9em;">
    <div class="row">
        <div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12 text-center">
            <video id="playVideo" controls muted>
                <source src="" />
            </video>
        </div>
    </div>
</div>


<%@ include file="../../core/include/footerPopup.jsp" %>
