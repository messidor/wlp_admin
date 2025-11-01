<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<body>
    <!-- S: 로그아웃 레이어팝업 -->
    <div class="modal_pop" id="logout_pop_popup" style="display:none;">
        <div class="cont">
            <strong>자동 로그아웃 안내</strong>
            <div class="cnt">
                <p>고객님의 보안을 위해 자동 로그아웃 되었습니다.<br>
                            로그인 후 일정 시간 동안 사이트를 이용하지 않으셨습니다.<br>
                            다시 이용하시려면 재로그인 후 창을 다시 열어주세요.</p>
                <div class="pop_btn">
                    <a href="javascript:window.close();" class="confirm">닫기</a>
                </div>
            </div>
        </div>
    </div>
    <!-- E: 로그아웃 레이어팝업 -->
    
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
            <div class="disp-percent"></div>
        </div>
    </div>

    <!-- Page-body start -->
    <div class="popup-content">