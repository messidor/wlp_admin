<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="form" uri="http://ad.its.yeongju.kr/jsp/jstl/form" %>
<%@ taglib prefix="card" uri="http://ad.its.yeongju.kr/jsp/jstl/card" %>
<%@ taglib prefix="func" uri="http://ad.its.yeongju.kr/jsp/jstl/func" %>
<%@ taglib prefix="label" uri="http://ad.its.yeongju.kr/jsp/jstl/label" %>

<%@ include file="../../core/include/head.jsp" %>
<%@ include file="../../core/include/headerPopup.jsp" %>

<style>
/* .fancybox-content { */
/*         width: 100% !important; */
/*         transform: translate(0px, 0px) !important; */
/*         height: 100% !important; */
/*     } */
</style>
<script type="text/javascript">
	
	$(function() {
           
        $('.fancybox.fancybox--narrow').fancybox({
            maxWidth: 640
        });
	    
	    // image Data Uri로 받은 경우
	    if(opener.imageUriData && opener.imageUriData != '') {
	        
	        $("a[data-id='popupImage']").fancybox({
	            'showCloseButton':false,
                margin: [0,0,0,0],
                padding: [0,0,0,0],
                openEffect: 'fade',
                openEasing: 'easeInQuad',
                openSpeed: 400,
                title: false,
                fitToView : false,
                autoSize : true,
                scrolling : 'auto',
                width : 'auto',
                maxWidth : '50%',
                keyboard: false,
                opts: {
                    touch: false
                },
                animationEffect: false,
                beforeLoad:function(instance, current) {
                    if(current.src=== '#') {
                        current.src = current.opts.$orig.find('img').attr('src');
                    }
                },
                beforeClose: function() {
                    return false;
                }
            });
	        $("#iframe").css("display", "none");
	        $("a[data-id='popupImage']").css("display", "inherit");
	        $("#popupImg").attr("src", opener.imageUriData);
	        $("a[data-id='popupImage']").trigger("click");
	        
	        setTimeout(function() {
	            $("[data-fancybox-close]").remove();
	        }, 100);
            
            $("body").on("click", ".fancybox-slide",function(){
                $("a[data-id='popupImage']").trigger("click");
                setTimeout(function() {
                    $("[data-fancybox-close]").remove();
                }, 100);
            });
	        
	    } else {
	        
	        $(".fancybox").fancybox({
	            'showCloseButton':false,
	            margin: [0,0,0,0],
	            padding: [0,0,0,0],
	            openEffect: 'fade',
	            openEasing: 'easeInQuad',
	            openSpeed: 400,
	            title: false,
	            fitToView : false,
	            autoSize : true,
	            scrolling : 'auto',
	            width : 'auto',
	            maxWidth : '50%',
	            keyboard: false,
	            opts: {
	                touch: false
	            }
	        });  
	    
			//$("#iframe").trigger("click");
			//$("button[type='button']").remove();
			
		    $("#iframe").trigger("click");
		    document.body.style.zoom = "150%";
		    $("[data-fancybox-close]").remove();
		    
		    $("body").on("click", ".fancybox-slide",function(){
		    	$("#iframe").trigger("click");
		    	$("[data-fancybox-close]").remove();
		    });
	    }
	    
	});
</script>

<div class="page-body" style="font-size: 0.9em;">
	<div class="row">
        <div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12 text-center">
             <a href="<c:url value='${param.imageSrc}'/>" id="iframe" class="fancybox fancybox--narrow" data-options='{"touch" : false}'></a>
             <a href="#popupImg" data-id="popupImage" style="display:none;" class="fancybox fancybox--narrow" data-options='{"touch" : false}' data-fancybox="images" data-type="image" data-src="#" data-small-btn="true">
                <img src="" id="popupImg" style="max-height:929px; max-width:1753px; display:none;" />
             </a>
        </div>
	</div>
</div>


<%@ include file="../../core/include/footerPopup.jsp" %>
