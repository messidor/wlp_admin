<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="ko">
	<head>
		<title>스마트 주차 시스템</title>
	    <!-- HTML5 Shim and Respond.js IE10 support of HTML5 elements and media queries -->
	    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
	    <!--[if lt IE 10]>
	      <script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>
	      <script src="https://oss.maxcdn.com/libs/respond.js/1.4.2/respond.min.js"></script>
	      <![endif]-->
	    <!-- Meta -->
	    <meta charset="utf-8">
	    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=0, minimal-ui">
	    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
	    <meta name="keywords" content="" />
	    <meta name="author" content="WPMS" />
		
		<link rel="icon" href="assets/images/favicon.ico" type="image/x-icon">
		<!-- Google font-->
		<link href="https://fonts.googleapis.com/css?family=Open+Sans:400,600,700" rel="stylesheet">
		<!-- Required Fremwork -->
		<link rel="stylesheet" type="text/css" href="<c:url value='/common/css/bootstrap/bootstrap.min.css'/>">
		<!-- waves.css -->
		<link rel="stylesheet" type="text/css" href="<c:url value='/assets/pages/waves/css/waves.min.css'/>" media="all">
		<!-- themify-icons line icon -->
		<link rel="stylesheet" type="text/css" href="<c:url value='/common/css/icon/themify-icons/themify-icons.css'/>">
		<!-- ico font -->
		<link rel="stylesheet" type="text/css" href="<c:url value='/common/css/icon/icofont/css/icofont.css'/>">
		<!-- Font Awesome -->
		<link rel="stylesheet" type="text/css" href="<c:url value='/common/css/font-awesome/font-awesome-5.13.0.font-face.css'/>">
		<link rel="stylesheet" type="text/css" href="<c:url value='/common/css/font-awesome/font-awesome-5.13.0.css'/>">
		<link rel="stylesheet" type="text/css" href="<c:url value='/common/css/font-awesome/font-awesome-5.13.0-v4.css'/>">
		<!-- Style.css -->
		<link rel="stylesheet" type="text/css" href="<c:url value='/common/css/framework/style.css'/>">

		<!-- Required Jquery -->
		<script type="text/javascript" src="<c:url value='/common/js/jquery/jquery-1.12.4.min.js'/>"></script>
		<script type="text/javascript" src="<c:url value='/common/js/jquery-ui/jquery-ui.min.js'/>"></script>
		<script type="text/javascript" src="<c:url value='/common/js/popper.js/popper.min.js'/>"></script>
		<script type="text/javascript" src="<c:url value='/common/js/bootstrap/js/bootstrap.4.0.0.min.js'/>"></script>
	    <!-- javascript language -->
	    <script type="text/javascript" src="<c:url value='/common/js/framework/language.js'/>"></script>
	    <!-- common -->
	    <script type="text/javascript" src="<c:url value='/common/js/framework/common.js'/>"></script>
	    <!-- framework -->
	    <script type="text/javascript" src="<c:url value='/common/js/framework/framework.js'/>"></script>
	    <!-- using ag-grid helper -->
	    <script type="text/javascript" src="<c:url value='/common/js/framework/gridhelper.js'/>"></script>
	    <!-- using fancytree helper -->
	    <script type="text/javascript" src="<c:url value='/common/js/framework/treehelper.js'/>"></script>
	    <!-- moment (date object helper) -->
	    <script type="text/javascript" src="<c:url value='/common/js/moment.js/moment-2.18.1.min.js'/>"></script>
	    <!-- date range picker -->
	    <script type="text/javascript" src="<c:url value='/common/js/daterangepicker/daterangepicker-3.0.5.min.js'/>"></script>
	    <!-- IE10, IE11 formData -->
	    <script type="text/javascript" src="<c:url value='/common/js/formdata/formdata.min.js'/>"></script>
		<!-- waves js -->
		<script type="text/javascript" src="<c:url value='/assets/pages/waves/js/waves.min.js'/>"></script>
		<!-- jquery slimscroll js -->
		<script type="text/javascript" src="<c:url value='/common/js/jquery-slimscroll/jquery.slimscroll.js'/>"></script>
		<script type="text/javascript" src="<c:url value='/common/js/etcs/common-pages.js'/>"></script>
		<!-- moment (date object helper) -->
		<script type="text/javascript" src="<c:url value='/common/js/moment.js/moment-2.18.1.min.js'/>"></script>
		<!-- project js -->
		<script type="text/javascript" src="<c:url value='/proj/js/projcommon.js'/>"></script>
		<script type="text/javascript" src="<c:url value='/proj/js/projframework.js'/>"></script>
		<script type="text/javascript" src="<c:url value='/proj/js/projgridhelper.js'/>"></script>
	</head>

	<body style="background:url('<c:url value='/assets/images/login_background.png'/>') center no-repeat; background-size:100% 100%; height:calc(100vh - 30px)">
   	<c:if test="${browser eq '4'}">
   		<div class="alert-browser"><img src="<c:url value='/images/alert_image.png'/>" style="width:15px; height:15px; vertical-align:sub" /> 현재 시스템은 크롬 브라우저에 최적화 되어있습니다. 크롬 브라우저를 사용해주시기 바랍니다. <a href="#"><i class="fa fa-times">&nbsp;</i></a></div>
   	</c:if>
  	<!-- Pre-loader start -->
  	<div class="theme-loader">
      <div class="loader-track">
          <div class="preloader-wrapper">
              <div class="spinner-layer spinner-blue">
                  <div class="circle-clipper left">
                      <div class="circle"></div>
                  </div>
                  <div class="gap-patch">
                      <div class="circle"></div>
                  </div>
                  <div class="circle-clipper right">
                      <div class="circle"></div>
                  </div>
              </div>
              <div class="spinner-layer spinner-red">
                  <div class="circle-clipper left">
                      <div class="circle"></div>
                  </div>
                  <div class="gap-patch">
                      <div class="circle"></div>
                  </div>
                  <div class="circle-clipper right">
                      <div class="circle"></div>
                  </div>
              </div>

              <div class="spinner-layer spinner-yellow">
                  <div class="circle-clipper left">
                      <div class="circle"></div>
                  </div>
                  <div class="gap-patch">
                      <div class="circle"></div>
                  </div>
                  <div class="circle-clipper right">
                      <div class="circle"></div>
                  </div>
              </div>

              <div class="spinner-layer spinner-green">
                  <div class="circle-clipper left">
                      <div class="circle"></div>
                  </div>
                  <div class="gap-patch">
                      <div class="circle"></div>
                  </div>
                  <div class="circle-clipper right">
                      <div class="circle"></div>
                  </div>
              </div>
          </div>
      </div>
  </div>
  <!-- Pre-loader end -->

    <section class="login-block">
        <!-- Container-fluid starts -->
        <div class="container">
            <div class="row">
                <div class="col-sm-12">
                    <!-- Authentication card start -->

                        <form class="md-float-material form-material">
                            <div style="max-width:450px; margin:150px auto 0px auto">
                                <div class="text-left no-margin no-padding" style="width:50%; max-width:225px; float:left; padding:0px; margin:0px;">
                                    <img src="<c:url value='/assets/images/logo.png'/>" alt="logo2.png" style="width:230px;">
                                </div>
                                <div class="text-right no-margin no-padding" style="width:50%; max-width:225px; float:right; padding:0px; margin:0px;float:right; height:29px; display:flex; align-items:flex-end; justify-content: flex-end; font-weight:bold; color:#454e5a;">
                                    스마트 주차 시스템
                                </div>
                                <div class="clearfix"></div>
                            </div>
                            <div class="auth-box card" style="margin-top:10px;">
                                <div class="card-block" style="padding-top:0px;">
                                    <div class="row m-b-20" style="margin:0px -20px 20px -20px; background-color:#26818c">
                                        <div class="col-md-12">
                                            <h4 class="text-left" style="padding:15px 0px 13px 0px; color:#fff">Login</h4>
                                        </div>
                                    </div>
                                    <div class="form-group form-primary">
                                        <input type="text" name="email" id="email" class="form-control">
                                        <span class="form-bar"></span>
                                        <label class="float-label">아이디</label>
                                    </div>
                                    <div class="form-group form-primary">
                                        <input type="password" name="password" id="password" class="form-control">
                                        <span class="form-bar"></span>
                                        <label class="float-label">비밀번호</label>
                                    </div>
                                    <%--
                                    <div class="row m-t-25 text-left">
                                        <div class="col-12">
                                            <div class="checkbox-fade fade-in-primary d-">
                                                <label>
                                                    <input type="checkbox" value="">
                                                    <span class="cr"><i class="cr-icon icofont icofont-ui-check txt-primary"></i></span>
                                                    <span class="text-inverse">Remember me</span>
                                                </label>
                                            </div>
                                            <div class="forgot-phone text-right f-right">
                                                <a href="<c:url value='/auth-reset-password.html'/>" class="text-right f-w-600"> Forgot Password?</a>
                                            </div>
                                        </div>
                                    </div> --%>
                                    <div class="row m-t-30">
                                        <div class="col-md-12">
                                            <button type="button" id="login" class="btn btn-primary btn-md btn-block waves-effect waves-light text-center m-b-20">로그인</button>
                                        </div>
                                    </div>
                                    <hr/>
                                    <div class="row">
                                        <div class="col-md-12">
                                        </div>
                                        <%-- <div class="col-md-2">
                                            <img src="<c:url value='/assets/images/auth/Logo-small-bottom.png'/>" alt="small-logo.png">
                                        </div> --%>
                                    </div>
                                </div>
                            </div>
                        </form>
                        <!-- end of form -->
                </div>
                <!-- end of col-sm-12 -->
            </div>
            <!-- end of row -->
        </div>
        <!-- end of container-fluid -->
    </section>
    <!-- Warning Section Starts -->
    <!-- Older IE warning message -->
    <!--[if lt IE 10]>
	<div class="ie-warning">
	    <h1>Warning!!</h1>
	    <p>You are using an outdated version of Internet Explorer, please upgrade <br/>to any of the following web browsers to access this website.</p>
	    <div class="iew-container">
	        <ul class="iew-download">
	            <li>
	                <a href="http://www.google.com/chrome/">
	                    <img src="<c:url value='/assets/images/browser/chrome.png'/>" alt="Chrome">
	                    <div>Chrome</div>
	                </a>
	            </li>
	            <li>
	                <a href="https://www.mozilla.org/en-US/firefox/new/">
	                    <img src="<c:url value='/assets/images/browser/firefox.png'/>" alt="Firefox">
	                    <div>Firefox</div>
	                </a>
	            </li>
	            <li>
	                <a href="http://www.opera.com">
	                    <img src="<c:url value='/assets/images/browser/opera.png'/>" alt="Opera">
	                    <div>Opera</div>
	                </a>
	            </li>
	            <li>
	                <a href="https://www.apple.com/safari/">
	                    <img src="<c:url value='/assets/images/browser/safari.png'/>" alt="Safari">
	                    <div>Safari</div>
	                </a>
	            </li>
	            <li>
	                <a href="http://windows.microsoft.com/en-us/internet-explorer/download-ie">
	                    <img src="<c:url value='/assets/images/browser/ie.png'/>" alt="">
	                    <div>IE (9 & above)</div>
	                </a>
	            </li>
	        </ul>
	    </div>
	    <p>Sorry for the inconvenience!</p>
	</div>
	<![endif]-->
	<!-- Warning Section Ends -->
	
<script type="text/javascript">
$(function() {
    setInterval(function() {
        $.ajax({
            url: '<c:url value="/refresh-csrf"/>',
            type: 'post'
        }).done(function (data) {
            $("meta[name='csrf-token']").prop("content", data);
        }).fail(function () {
            //alert('Error');
            location.reload();
        });
    },120*60*1000);
	
    $("#email").focus();

    //ID 입력 후 Enter 시
    $("#email").keydown(function(key) {
        if (key.keyCode == 13) {
            $("#password").focus();
        }
    });

    //패스워드 입력 후 Enter 시
    $("#password").keydown(function(key) {
        if (key.keyCode == 13) {
            $("#login").trigger("click");
        }
    });

    $("#login").click(function(){
        $.ajax({
            method: "post",
            url: "<c:url value='/api/login.do' />",
            data: {
                "id":$("#email").val(),
                "pw":$("#password").val()
            },
            success : function(data, textStatus, jqXHR) {
            	if (data.count == 0) {
                    alert(data.message);
            	} else {
                    window.location.replace("<c:url value='/index.do' />");
            	}
            },
            error: function(data, textStatus, jqXHR){
                alert(data);
            },
            dataType: "json"
        });
    });

    $(".alert-browser").find("a").click(function(ev) {
        ev.preventDefault();
        var obj = $(this);
        obj.parent().slideUp(200, function() {
            obj.parent().css({
                "display" : "none"
            });

            $(".pcoded-main-container").css("margin-top", 56);
        });
    });

    // 브라우저 종류에 따라 body 의 height 속성을 변경처리함
    if(getBrowser() == "4") {
        $("body").css("height", "100vh");
    }
});
</script>