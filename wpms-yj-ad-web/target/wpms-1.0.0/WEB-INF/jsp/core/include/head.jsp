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
    <meta name="csrf-token" content="${_csrf.token}" />

    <!-- Favicon icon -->
    <link rel="icon" href="<c:url value='/assets/images/favicon.ico'/>" type="image/x-icon">
    <!-- Google font-->
    <link href="https://fonts.googleapis.com/css?family=Open+Sans:400,600,700" rel="stylesheet">
    <!-- waves.css -->
    <link rel="stylesheet" href="<c:url value='/assets/pages/waves/css/waves.min.css'/>" type="text/css" media="all">
    <!-- Required Fremwork -->
    <link rel="stylesheet" type="text/css" href="<c:url value='/common/css/bootstrap/bootstrap.min.css'/>">
    <link rel="stylesheet" type="text/css" href="<c:url value='/common/css/bootstrap/bootstrap-extras-margins-paddings.css'/>">

    <!-- waves.css -->
    <link rel="stylesheet" href="<c:url value='/assets/pages/waves/css/waves.min.css'/>" type="text/css" media="all">
    <!-- themify icon -->
    <link rel="stylesheet" type="text/css" href="<c:url value='/common/css/icon/themify-icons/themify-icons.css'/>">
    <!-- font-awesome-n -->
    <link rel="stylesheet" type="text/css" href="<c:url value='/common/css/font-awesome/font-awesome-5.13.0.font-face.css'/>">
    <link rel="stylesheet" type="text/css" href="<c:url value='/common/css/font-awesome/font-awesome-5.13.0.css'/>">
    <link rel="stylesheet" type="text/css" href="<c:url value='/common/css/font-awesome/font-awesome-5.13.0-v4.css'/>">

    <!-- scrollbar.css -->
    <link rel="stylesheet" type="text/css" href="<c:url value='/common/css/jquery.custom-scrollbar/jquery.mCustomScrollbar.css'/>">
    <!-- Style.css -->
    <link rel="stylesheet" type="text/css" href="<c:url value='/common/css/framework/style.css'/>">
    <link rel="stylesheet" type="text/css" href="<c:url value='/common/css/framework/style_kyungbuk.css'/>">
    <!-- ico font -->
    <link rel="stylesheet" type="text/css" href="<c:url value='/common/css/icon/icofont/css/icofont.css'/>">
    <!-- Notification.css -->
    <link rel="stylesheet" type="text/css" href="<c:url value='/assets/pages/notification/notification.css'/>">
    <!-- Animate.css -->
    <link rel="stylesheet" type="text/css" href="<c:url value='/common/css/animate.css/css/animate.css'/>">
    <!-- morris chart -->
    <link rel="stylesheet" type="text/css" href="<c:url value='/common/css/morris.js/css/morris.css'/>">

    <link rel="stylesheet" type="text/css" href="<c:url value='/common/css/framework/non-bootstrap.css'/>">

    <link rel="stylesheet" type="text/css" href="<c:url value='/common/css/daterangepicker/daterangepicker-3.0.5.css'/>">
    
    <link rel="stylesheet" type="text/css" href="<c:url value='/common/css/jquery-fancybox/jquery.fancybox.min.css'/>">

    <!-- 내부 포함 소스로 변경 해야됨 -->

    <%--<script type="text/javascript" src="<c:url value='/assets/js/ag-grid/ag-grid-community.min.noStyle.js'/>"></script> --%>
    <script type="text/javascript" src="<c:url value='/common/js/ag-grid/ag-grid-community.min.noStyle_new.js'/>"></script>

    <link rel="stylesheet" type="text/css" href="<c:url value='/common/css/ag-grid/ag-grid.css'/>">
    <link rel="stylesheet" type="text/css" href="<c:url value='/common/css/ag-grid/ag-theme-balham.css'/>">

    <link rel="stylesheet" type="text/css" href="<c:url value='/common/css/jstree/jstreeStyle.min.css'/>">
    <link rel="stylesheet" type="text/css" href="<c:url value='/common/css/framework/style_black.css'/>">

    <!-- fancytree -->
    <link rel="stylesheet" type="text/css" href="<c:url value='/common/css/fancytree-2.23/skin-win7/ui.fancytree.min.css'/>" />

    <!-- fancytree -->
    <link rel="stylesheet" type="text/css" href="<c:url value='/common/css/dropzone/dropzone.css'/>">

    <!-- chart.css -->
    <link rel="stylesheet" href="<c:url value='/common/js/chartjs/Chart.min.css'/>" charset="utf-8" />

    <!-- bootstrap input-group -->
    <link rel="stylesheet" href="<c:url value='/common/css/framework/bootstrap-input-group.css'/>" type="text/css" />

    <link rel="stylesheet" href="<c:url value='/common/css/dropzone/dropzone-custom.css'/>" type="text/css" />
    <link rel="stylesheet" href="<c:url value='/proj/css/projcommon.css'/>" type="text/css" />

    <link rel="stylesheet" href="<c:url value='/common/css/datepicker/datepicker-1.9.0.css'/>" />

    <link rel="stylesheet" href="<c:url value='/common/css/framework/ranged-css.css'/>" />


    <!-- 내부 포함 소스로 변경 해야됨 -->

    <!-- Script block starts -->
    <!-- Required Jquery -->
    <script type="text/javascript" src="<c:url value='/common/js/jquery/jquery-1.12.4.min.js'/>"></script>
    <script type="text/javascript" src="<c:url value='/common/js/jquery-cookie/jquery.cookie.js'/>"></script>
    <script type="text/javascript" src="<c:url value='/common/js/jstree/jstree.min.js'/>"></script>
    <script type="text/javascript" src="<c:url value='/common/js/jquery-ui/jquery-ui.min.js'/>"></script>
    <script type="text/javascript" src="<c:url value='/common/js/popper.js/popper.min.js'/>"></script>
    <script type="text/javascript" src="<c:url value='/common/js/bootstrap/js/bootstrap.4.0.0.min.js'/>"></script>
    <!-- waves js -->
    <script src="<c:url value='/assets/pages/waves/js/waves.min.js'/>"></script>
    <!-- jquery slimscroll js -->
    <script type="text/javascript" src="<c:url value='/common/js/jquery-slimscroll/jquery.slimscroll.js'/>"></script>

    <!-- slimscroll js -->
    <script src="<c:url value='/common/js/jquery-mCustomScrollbar/jquery.mCustomScrollbar.concat.min.js'/>"></script>
    <!-- ag-grid -->
    <script type="text/javascript" src="<c:url value='/common/js/framework/ag-grid_custom_input.js'/>"></script>
    <!-- javascript language -->
    <script type="text/javascript" src="<c:url value='/common/js/framework/language.js'/>"></script>
    <!-- common -->
    <script type="text/javascript" src="<c:url value='/common/js/framework/common.js'/>"></script>
    <!-- framework -->
    <script type="text/javascript" src="<c:url value='/common/js/framework/framework.js'/>?v=220731"></script>
    <!-- using ag-grid helper -->
    <script type="text/javascript" src="<c:url value='/common/js/framework/gridhelper.js'/>?v=220731"></script>
    <!-- using fancytree helper -->
    <script type="text/javascript" src="<c:url value='/common/js/framework/treehelper.js'/>"></script>
    <!-- moment (date object helper) -->
    <script type="text/javascript" src="<c:url value='/common/js/moment.js/moment-2.18.1.min.js'/>"></script>
    <!-- date range picker -->
    <script type="text/javascript" src="<c:url value='/common/js/daterangepicker/daterangepicker-3.0.5.min.js'/>"></script>
    <!-- IE10, IE11 formData -->
    <script type="text/javascript" src="<c:url value='/common/js/formdata/formdata.min.js'/>"></script>
    
    <script type="text/javascript" src="<c:url value='/common/js/jquery-fancybox/jquery.fancybox.min.js'/>"></script>

    <!-- menu js -->
    <script src="<c:url value='/common/js/etcs/pcoded.min.js'/>"></script>
    <script src="<c:url value='/common/js/vertical/vertical-layout.min.js'/>"></script>

    <script type="text/javascript" src="<c:url value='/common/js/etcs/script.js'/>"></script>

    <!-- Accordion js -->
    <script type="text/javascript" src="<c:url value='/assets/pages/accordion/accordion.js'/>"></script>

    <!-- notification js -->
    <script type="text/javascript" src="<c:url value='/common/js/bootstrap-growl/bootstrap-growl.min.js'/>"></script>

    <!-- tinyMCE -->
    <script type="text/javascript" src="<c:url value='/common/js/tinymce/tinymce.min.js'/>" charset="utf-8"></script>

    <!-- full calendar css -->
    <link rel="stylesheet" type="text/css" href="<c:url value='/common/js/fullCalendar-4.4.0/packages/core/main.css'/>">
    <link rel="stylesheet" type="text/css" href="<c:url value='/common/js/fullCalendar-4.4.0/packages/daygrid/main.css'/>">
    <link rel="stylesheet" type="text/css" href="<c:url value='/common/js/fullCalendar-4.4.0/packages/list/main.css'/>">
    <link rel="stylesheet" type="text/css" href="<c:url value='/common/js/fullCalendar-4.4.0/packages/timegrid/main.css'/>">

    <!-- full calendar js -->
    <script type="text/javascript" src="<c:url value='/common/js/fullCalendar-4.4.0/packages/core/main.min.js'/>" charset="utf-8"></script>
    <script type="text/javascript" src="<c:url value='/common/js/fullCalendar-4.4.0/packages/core/locales/ko.js'/>" charset="utf-8"></script>
    <script type="text/javascript" src="<c:url value='/common/js/fullCalendar-4.4.0/packages/daygrid/main.min.js'/>" charset="utf-8"></script>
    <script type="text/javascript" src="<c:url value='/common/js/fullCalendar-4.4.0/packages/interaction/main.min.js'/>" charset="utf-8"></script>
    <script type="text/javascript" src="<c:url value='/common/js/fullCalendar-4.4.0/packages/list/main.min.js'/>" charset="utf-8"></script>
    <script type="text/javascript" src="<c:url value='/common/js/fullCalendar-4.4.0/packages/timegrid/main.min.js'/>" charset="utf-8"></script>

    <!-- fancytree -->
    <script type="text/javascript" src="<c:url value='/common/js/fancytree-2.23/jquery.fancytree-all-deps.min.js'/>"></script>

    <!-- dropzone -->
    <script type="text/javascript" src="<c:url value='/common/js/dropzone/dropzone.js'/>"></script>

    <!-- other js -->
    <%--
    <script type="text/javascript" src="<c:url value='/common/js/framework/loop.js'/>"></script>
    --%>

    <!-- project js -->
    <script type="text/javascript" src="<c:url value='/proj/js/projcommon.js'/>"></script>
    <script type="text/javascript" src="<c:url value='/proj/js/projframework.js'/>"></script>
    <script type="text/javascript" src="<c:url value='/proj/js/projgridhelper.js'/>"></script>

    <!-- daum postcode js -->
    <script type="text/javascript" src="https://ssl.daumcdn.net/dmaps/map_js_init/postcode.v2.js"></script>

    <!-- Chart.js -->
    <script type="text/javascript" src="<c:url value='/common/js/chartjs/Chart.min.js'/>" charset="utf-8"></script>
    <script type="text/javascript" src="<c:url value='/common/js/chartjs/Chart.bundle.min.js'/>" charset="utf-8"></script>

    <script type="text/javascript" src="<c:url value='/common/js/framework/uploadhelper.js'/>" charset="utf-8"></script>
    <!-- imask -->
    <script type="text/javascript" src="<c:url value='/common/js/imask/imask-6.0.5.js'/>" charset="utf-8"></script>

    <!-- datepicker -->
    <script type="text/javascript" src="<c:url value='/common/js/datepicker/datepicker-1.9.0.js'/>"></script>
    <script type="text/javascript" src="<c:url value='/common/js/datepicker/datepicker.ko.min.js'/>"></script>

    <!-- treePopup.js -->
    <script type="text/javascript" src="<c:url value='/common/js/framework/treepopup.js'/>"></script>

    <!-- charthelper.js -->
    <script type="text/javascript" src="<c:url value='/common/js/framework/charthelper.js'/>"></script>
    
    <!-- bootstrap autocomplete -->
    <script type="text/javascript" src="<c:url value='/common/js/bootstrap-autocomplete/bootstrap-autocomplete.min.js'/>"></script>
    
    <!-- etc common -->
    <script type="text/javascript" src="<c:url value='/common/js/etcs/common.js'/>" charset="utf-8"></script>

    <!-- custom css -->
    <style type="text/css">
    #noti_list {max-height:300px; overflow-y:auto;}
    </style>

	<script type="text/javascript">
	
	<!-- Language pack -->
	var LangData = {
	    get: function(_langCode) {
	        if(typeof(this.data[_langCode]) != 'undefined') {
	            return this.data[_langCode];
	        } else {
	            if(console) console.warn('No langCode for ' + _langCode + '.');
	            return _langCode;
	        }
	    },
	    data: ${func:langToJSON(pageContext)}
	};    
	</script>

    <!-- Custom js -->
    <script>
        <%-- 서버 세팅 (최대 파일 크기) --%>
        var g_ServerMaxUploadFileSize = parseInt('500', 10);
        <%-- 업로드 가능한 최대 파일 개수 --%>
        var g_ServerMaxUploadFileCount = parseInt('20', 10);
        <%-- 업로드 기본 경로 --%>
        var g_RealFileUploadFolderBase = "";
        
        <%-- 세션값 --%>
        var g_UserId = "${user_id}";
        var g_UserName = "${user_name}";
        var g_UserToken = "${user_token}";
        var g_UserCompName = "${user_comp_name}";
        var g_UserDeptCode = "${user_dept_code}";
        var g_UserDeptName = "${user_dept_name}";
        var g_UserRoleId = "${user_role_id}";
        var g_UserRoleName = "${user_role_name}";
        var g_UserRoleIdAry = "${user_role_id_ary}";
        var g_UserRoleNameAry = "${user_role_name_ary}";
        var g_UserPosGubn = "${user_pos_gubn}";
        var g_UserPosGubnName = "${user_pos_gubn_name}";
        var g_UserLangPack = "${user_lang_pack}";
        var g_UserRoleGubnAry = "${user_role_gubn_ary}";
        var g_UserRoleGubnNameAry = "${user_role_gubn_name_ary}";
        var g_UserParkingGov = "${user_parking_gov}";

        var g_AlarmTimer = null;
        var g_ShowAppDocNo = "";
        var g_ChgGubn = "";
        var g_Id_Gubn = false;

        function readAlarmProcess(p_Obj) {

            // 알람 읽음 처리 코드는 추후 사용 여지가 있어서 남김
            // 쿼리는 삭제함
            return;

            setLoadImage(false);
            g_ShowAppDocNo = p_Obj.attr("data-show_app_doc_no");
            g_ChgGubn = p_Obj.attr("data-chg_gubn");

            var frm = $("#frmLayoutAlarmMain");
            frm.addParam("query_id", "Common/ProjectQuery.Update_LayoutReadDateTime");
            frm.addParam("app_doc_no", p_Obj.attr("data-app_doc_no"));
            frm.addParam("app_doc_seq", p_Obj.attr("data-app_doc_seq"));
            frm.addParam("func", "IS_LAM");
            frm.addParam("afterAction", false);
            frm.request();
        }

        function handleIS_LAM(data, textStatus, jqXHR) {
            setLoadImage(true);
            if(g_ChgGubn == "C012") {
                location.href="<c:url value='/apr/apr_doc'/>?k_show_app_doc_no=" + g_ShowAppDocNo;
            } else {
                location.href="<c:url value='/apr/status'/>?k_show_app_doc_no=" + g_ShowAppDocNo;
            }
        }

        // 알람 버튼 클릭시 전부 읽음 처리
        function readAlarmProcessAll() {
            // 알람 읽음 처리 코드는 추후 사용 여지가 있어서 남김
            // 쿼리는 삭제함
            return;
            setLoadImage(false);
            var frm = $("#frmLayoutAlarmMain");
            frm.addParam("query_id", "Common/ProjectQuery.Update_LayoutReadDateTimeAll");
            frm.addParam("func", "IS_LAM2");
            frm.addParam("afterAction", false);
            frm.request();
        }

        function handleIS_LAM2(data, textStatus, jqXHR) {
            setLoadImage(true);
        }

        <% if(session.getAttribute("user_id") != null ) { %>
            var sessionStartDate = new Date();
            var currentDate = new Date();
            var TIMEOUT_SECOND = 3600;
            
            // 시간 초기화
            function clearTime() {
                sessionStartDate = new Date();
                
                if(opener) {
                    if(opener.sessionStartDate) {
                        opener.sessionStartDate = sessionStartDate;
                    } else {
                        // 0.1초후 재시도
                        // 부모창이 로딩 도중에는 이 로직에 걸리게 되며, opener.sessionStartDate 속성을 읽지 못함
                        console.log("clearTime is not run because parent window is initializing..");
                        setTimeout(clearTime, 100);
                    }
                }
            }
            
            function setTimer() {
                
                if(opener != null) {
                    // 팝업인 경우 부모창과 시작시간을 매초 동기화 한다.
                    // 더 늦게 갱신된 쪽의 시간을 따르도록 처리한다.
                    // 부모창이 갱신되면 부모창의 시간을, 팝업창이 갱신되면 팝업창의 시간을 시작시간으로 한다.
                    if(opener.sessionStartDate) {
                        if(opener.sessionStartDate.getTime() - sessionStartDate.getTime() < 0) {
                            opener.sessionStartDate = sessionStartDate;
                        } else if(opener.sessionStartDate.getTime() - sessionStartDate.getTime() > 0) {
                            sessionStartDate = opener.sessionStartDate;
                        }
                    }
                }
                
                currentDate = new Date();
                let diff = (currentDate.getTime() - sessionStartDate.getTime()) / 1000;
                
                // // Time Log
                // if(opener != null) {
                //     if(opener.sessionStartDate) {
                //         let diff_opener = (currentDate.getTime() - opener.sessionStartDate.getTime()) / 1000;
                //         console.log("Time Difference (opener): " + diff + " / " + diff_opener);
                //     } else {
                //         console.log("Time Difference (opener is refreshing...): " + diff);
                //     }
                // } else {
                //     console.log("Time Difference: " + diff);
                // }
                
                if(diff > TIMEOUT_SECOND) {
                    /* 세션 종료시 작동할 이벤트 */ 
                    
                    if(opener) {
                        $("#logout_pop_popup").css("display", "inherit");
                    } else {
                        $("#logout_pop").css("display", "block");
                    }
                    
                    $.ajax({
                        method: "post",
                        url: "<c:url value='/api/logout.do' />",
                        data: { },
                        success : function(data, textStatus, jqXHR) {
                            if (data.count > 0) {
                                if(opener) {
                                    $("#logout_pop_popup").css("display", "block");
                                } else {
                                    $("#logout_pop").css("display", "block");
                                }
                            }
                        },
                        error: function(data, textStatus, jqXHR){
                            alert(data);
                        },
                        dataType: "json"
                    });
                } else {
                    // 시간이 넘지 않으면 자신을 재호출
                    setTimeout(setTimer, 1000);
                }
            }
        <% } %>

        // function GetCookies(){

        //     //html 초기화
        //     $("#noti_list").children("li").remove();
        //     var cart = $.cookie("data");

        //     if(cart === undefined){
        //         cart = {};
        //     }
        //     const cart_list = cart[g_UserId];

        //     if (cart_list === undefined || Object.keys(cart_list).length == 0) {
        //         //alert("장바구니가 비어있습니다.");
        //         $("#noti_list").prepend($("#cart_tmpl").tmpl({product_code: ""}));
        //     } else {
        //         $.each(cart_list, function(k, v) {
        //             $("#noti_list").prepend($("#cart_tmpl").tmpl(v));
        //         });
        //     }

        //     return;
        // }

        // function loadAlarmList() {
        //     setLoadImage(false);
        //     var frm = $("#frmLayoutAlarmMain");
        //     frm.addParam("query_id", "Common/ProjectQuery.Select_LayoutAlarmList");
        //     frm.addParam("func", "IQ_LAM");
        //     frm.request();
        // }

        // function handleIQ_LAM(data, textStatus, jqXHR) {
        //     setLoadImage(true);
        //     var log_html = "";
        //     var log_count = 0;
        //     var log_count_str = "";

        //     if(data.length > 0) {
        //         for(var i = 0; i < data.length; i++) {
        //             log_count += parseInt(data[i]["alarm_cnt"], 10);
        //             log_html += '<li class="waves-effect waves-light" data-show_app_doc_no="' + data[i]["show_app_doc_no"] + '" data-app_doc_no="' + data[i]["app_doc_no"] + '" data-app_doc_seq="' + data[i]["app_doc_seq"] + '" data-chg_gubn="' + data[i]["chg_gubn"] + '">';
        //             log_html += '    <div class="media-body">';
        //             log_html += '        <h5 class="notification-user">' + data[i]["show_app_doc_no"];
        //             if(parseInt(data[i]["alarm_cnt"], 10) > 0){
        //                 log_html += ' <span style="color:red;"><i class="fas fa-bolt"></i></span>';
        //             }
        //             log_html += '</h5>';
        //             log_html += '        <p class="notification-msg">' + data[i]["alarm_message"] + '</p>';
        //             log_html += '    </div>';
        //             log_html += '</li>';
        //         }

        //         $("#noti_list").html(log_html);
        //     } else {
        //         log_count = 0;

        //         $("#noti_list").html('<li class="waves-effect waves-light"><div class="media-body"><h5 class="notification-user">알림이 없습니다.</h5></div></li>');
        //     }

        //     if(log_count > 99) {
        //         log_count_str = "99+";
        //     } else {
        //         log_count_str = log_count + "";
        //     }

        //     if(log_count > 0) {
        //         $("#control_noti i span.badge").attr("style", "font-size: 12px; top: 0px; right: 0px; display: inherit !important;").text(log_count_str);
        //     } else {
        //         $("#control_noti i span.badge").attr("style", "font-size: 12px; top: 0px; right: 0px; display: none !important;").text("");
        //     }
        // }

        // function initAlarmInterval() {
        //     // 알람 타이머 시작 (10초)
        //     g_AlarmTimer = setInterval(loadAlarmList, 10000);
        // }

        $(function() {

            $('[data-toggle="tooltip"]').tooltip();
            $('[data-toggle="popover"]').popover({
                html: true,
                content: function() {
                    return $('#primary-popover-content').html();
                }
            });

            // menu control
            $("a[data-sec_depth]").click(function(ev) {
                ev.preventDefault();
                var obj = $(this);
                sec_depth = obj.attr("data-sec_depth");
                $("#sub_menu_wrapper [data-sec_depth]").css("display", "none");
                $("#sub_menu_wrapper [data-sec_depth='" + sec_depth + "']").css("display", "");
                $("#menu_wrapper div.menu-bottom").addClass("hide");
                $("a.top-menu-link").removeClass("selected");
                obj.addClass("selected");
                obj.next().removeClass("hide");

                $('.pcoded[theme-layout="vertical"][vertical-nav-type="expanded"] .pcoded-navbar').width(247);
            });

            // 기존 이벤트 제거
            $("#mobile-collapse").off("click");
            // 왼쪽 메뉴 크기 컨트롤
            $("#mobile-collapse").click(function(ev) {

                ev.preventDefault();

                if($(window).width() >= 993 - 16) {
                    // 큰 화면
                    if($('.pcoded[theme-layout="vertical"][vertical-nav-type="expanded"] .pcoded-navbar').width() <= 60) {
                        $('.pcoded[theme-layout="vertical"][vertical-nav-type="expanded"] .pcoded-navbar').width(247);
                        $("#body_content_wrapper").css({
                            "width" : "calc(100% - 247px)",
                            "margin-left" : 247
                        });
                    } else {
                        $('.pcoded[theme-layout="vertical"][vertical-nav-type="expanded"] .pcoded-navbar').width(0);
                        $("#body_content_wrapper").css({
                            "width" : "calc(100%)",
                            "margin-left" : 0
                        });
                    }
                } else {
                    // 작은 화면
                    $("#mobile_menu_wrapper").slideToggle(400);
                }
            });

            $(window).resize(function() {
                if($(window).width() >= 993) {
                    $('.pcoded[theme-layout="vertical"][vertical-nav-type="expanded"] .pcoded-navbar').width(247);
                    $("#body_content_wrapper").css({
                        "width" : "calc(100% - 247px)",
                        "margin-left" : 247
                    });
                } else {
                    $('.pcoded[theme-layout="vertical"][vertical-nav-type="expanded"] .pcoded-navbar').width(0);
                    $("#body_content_wrapper").css({
                        "width" : "calc(100%)",
                        "margin-left" : 0
                    });
                }
            });

            // 모바일 메뉴 컨트롤
            $("#mobile_menu_wrapper a.has-child").click(function(ev) {
                ev.preventDefault();
                var obj = $(this);

                if(obj.hasClass("closed")) {

                    $("#mobile_menu_wrapper a.has-child").each(function(idx, elem) {
                        if(obj.next().hasClass("level2-wrapper")) {
                            if($(elem).next().hasClass("level2-wrapper")) {
                                $(elem).addClass("closed").next().slideUp(400);
                            }
                        } else if(obj.next().hasClass("level3-wrapper")) {
                            if($(elem).next().hasClass("level3-wrapper")) {
                                $(elem).addClass("closed").next().slideUp(400);
                            }
                        }
                    });

                    obj.removeClass("closed").next().slideDown(400);
                } else {
                    obj.addClass("closed").next().slideUp(400);
                }
            });

            // page open menu selected
            $("#sub_menu_wrapper [data-sec_depth]").css("display", "none");
            if($("a[data-sec_depth].selected").length > 0) {
                $("#sub_menu_wrapper [data-sec_depth='" + $("a[data-sec_depth].selected").attr("data-sec_depth") + "']").css("display", "");
            } else {
                $("#sub_menu_wrapper [data-sec_depth='" + $("a[data-sec_depth]:eq(0)").attr("data-sec_depth") + "']").css("display", "");
            }

            $("#control_mymenu").find("a.waves-effect").click(function(ev) {
                ev.preventDefault();
                $(this).parent().find(".show-notification").slideToggle(500);
            });

            $('.pcoded[theme-layout="vertical"][vertical-nav-type="expanded"] .pcoded-navbar').width(247);
            $("#body_content_wrapper").css({
                "width" : "calc(100% - 247px)",
                "margin-left" : 247
            });

            // 알람 읽음 처리
            $("#layout_alarm").click(function(){
                if($("#layout_alarm").hasClass("active")) {
                    // clearInterval(g_AlarmTimer);
                    // readAlarmProcessAll();
                } else {
                    //initAlarmInterval();
                    //loadAlarmList();
                }
            });

            // 알림 클릭
            $(document).on("click", "li.waves-effect[data-show_app_doc_no]", function() {
                //location.href="<c:url value='/apr/status'/>?k_show_app_doc_no=" + $(this).attr("data-show_app_doc_no");
                var obj = $(this);
                readAlarmProcess(obj);
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

                $(".pcoded-main-container").animate({
                    "margin-top" : 56
                }, 200)
            });

            //loadAlarmList();
            //initAlarmInterval();
	    	
            
            <% if(session.getAttribute("user_id") != null ) { %>
                // clearTime();    // 세션 만료 적용 시간 
                setTimer();     // 문서 로드시 타이머 시작

                $("#logout_pop .confirm").click(function () {
                    window.location.replace("/walletfree-admin/login.do");
                });
                $("#logout_pop .cancel").click(function () {
                    $("#logout_pop").css("display", "none");
                });
            <% } %>
            
            // 앞뒤 공백 제거
//             $("input.form-control").on("blur",function(){
//             	$(this).val($.trim($(this).val()));
//             })
            
            $(window).trigger("resize");

            setDataHeight();
        });
    </script>
</head>
