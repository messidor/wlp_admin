<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<body>    
    <!-- S: 로그아웃 레이어팝업 -->
    <div class="modal_pop" id="logout_pop" style="display: none;">
        <div class="cont">
            <strong>자동 로그아웃 안내</strong>
            <div class="cnt">
                <p>고객님의 보안을 위해 자동 로그아웃 되었습니다.<br>
                            로그인 후 일정 시간 동안 사이트를 이용하지 않으셨습니다.<br>
                            다시 이용하시려면 재로그인 해주세요.</p>
                <div class="pop_btn">
                    <a href="javascript:void(0);" class="confirm">확인</a>
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
    
    <!-- Pre-loader end -->
    <div id="pcoded" class="pcoded">
        <div class="pcoded-overlay-box"></div>
        <div class="pcoded-container navbar-wrapper">
            <nav id="menu_all_wrapper" class="navbar header-navbar pcoded-header">
				<c:if test="${browser eq '4'}">
                	<div class="alert-browser"><img src="<c:url value='/images/alert_image.png'/>" style="width:15px; height:15px; vertical-align:sub" /> 현재 시스템은 크롬 브라우저에 최적화 되어있습니다. 크롬 브라우저를 사용해주시기 바랍니다. <a href="#"><i class="fa fa-times">&nbsp;</i></a></div>
                </c:if>
                <div class="navbar-wrapper">
                    <div class="navbar-logo">
                        <a class="mobile-menu waves-effect waves-light" id="mobile-collapse" href="#!">
                            <i class="ti-menu"></i>
                        </a>
                        <a href="<c:url value='/index.do'/>">
							<img class="img-fluid" src="<c:url value='/assets/images/logo_yeongju.png'/>" alt="Theme-Logo" style="height: 30px; width: 240px;" />
                        </a>
                        <a class="mobile-options waves-effect waves-light">
                            <i class="ti-more"></i>
                        </a>
                    </div>
                    <div class="navbar-container container-fluid">
                        <!-- 모바일 메뉴 -->
                        <ul class="nav-left" id="mobile_menu_wrapper" style="display:none;">
                       	<c:forEach var="menu" items="${menuList}" varStatus="status">
                       		<c:if test="${menu.getString('menuDepth') eq '1'}">
                       			<c:if test="${status.index ne 0}">
                       				<c:if test="${menuList.get(status.index - 1).getString('menuDepth') ne '1'}">
                       					</ul>
                       				</c:if>
                       				</li>
                       			</c:if> 
                       		
	                            <li class="level1">
		                            <c:choose>
										<c:when test="${menu.getString('childNode') eq 'Y' and empty menu.getString('menuUrl')}">
		                            		<c:set var="url" value="javascript:;" />
										</c:when>
		        						<c:otherwise>
		                            		<c:url var="url" value="${menu.getString('menuUrl')}" />
		        						</c:otherwise>
		                            </c:choose>
	                                <a href="${url}" class="${menu.has('menuUrl') and menu.getString('menuUrl') eq requestScope['javax.servlet.forward.request_uri'] ? 'active' : ''} ${menu.getString('childNode') eq 'Y' ? 'has-child closed' : ''}">
	                                	<span>&nbsp;</span>${menu.getString("menuName")}
	                               	</a>
	                               	<c:if test="${menu.getString('childNode') eq 'Y'}">
	                              		<ul class="level2-wrapper" style="display:none;">
	                               	</c:if>
	                               	<c:if test="${menu.getString('childNode') ne 'Y'}">
	                            </li>
	                               	</c:if>
                       		</c:if>
                       		<c:if test="${menu.getString('menuDepth') eq '2'}">
	              				<c:if test="${menuList.get(status.index - 1).getString('menuDepth') eq '3'}">
	              					</li>
	              				</c:if>
	              				
                                <li class="level2">
		                            <c:choose>
										<c:when test="${menu.getString('childNode') eq 'Y' and empty menu.getString('menuUrl')}">
		                            		<c:set var="url" value="javascript:;" />
										</c:when>
		        						<c:otherwise>
		                            		<c:url var="url" value="${menu.getString('menuUrl')}" />
		        						</c:otherwise>
		                            </c:choose>
	                                <a href="${url}" class="${menu.has('menuUrl') and menu.getString('menuUrl') eq requestScope['javax.servlet.forward.request_uri'] ? 'active' : ''} ${menu.getString('childNode') eq 'Y' ? 'has-child closed' : ''}">
	                                	<span>&nbsp;</span>${menu.getString("menuName")}
	                               	</a>
	                               	<c:if test="${menu.getString('childNode') eq 'Y'}">
	                              		<ul class="level3-wrapper" style="display:none;">
	                               	</c:if>
	                               	<c:if test="${menu.getString('childNode') ne 'Y'}">
                                </li>
	                               	</c:if>
                       		</c:if>
                       		<c:if test="${menu.getString('menuDepth') eq '3'}">
	              				
                                <li class="level3">
		                            <c:choose>
										<c:when test="${menu.getString('childNode') eq 'Y' and empty menu.getString('menuUrl')}">
		                            		<c:set var="url" value="javascript:;" />
										</c:when>
		        						<c:otherwise>
		                            		<c:url var="url" value="${menu.getString('menuUrl')}" />
		        						</c:otherwise>
		                            </c:choose>
	                                <a href="${url}" class="${menu.has('menuUrl') and menu.getString('menuUrl') eq requestScope['javax.servlet.forward.request_uri'] ? 'active' : ''} ${menu.getString('childNode') eq 'Y' ? 'has-child closed' : ''}">
	                                	<span>&nbsp;</span>${menu.getString("menuName")}
	                               	</a>
	                               	<c:if test="${menu.getString('mnDesc') eq '1' and menu.getString('childNode') ne 'Y'}">
                                        </ul>
	                               	</c:if>
                                </li>
                       		</c:if>
                       	</c:forEach>
                       	<c:if test="${menuList.get(menuList.size() - 1).getString('menuDepth') eq '3'}">
                        	</li></ul>
                       	</c:if>
                       	<c:if test="${menuList.get(menuList.size() - 1).getString('menuDepth') eq '2'}">
                        	</ul>
                       	</c:if>
                        </ul>
                        <!-- PC 메뉴 -->
                        <ul class="nav-left" id="menu_wrapper">
                            <li>
                                <div class="sidebar_toggle"><a href="javascript:void(0)"><i class="ti-menu"></i></a></div>
                            </li>
							<c:if test="${browser ne '4'}">
                            <li>
                                <a href="#!" onclick="javascript:toggleFullScreen()" class="waves-effect waves-light">
                                    <i class="ti-fullscreen"></i>
                                </a>
                            </li>
                            </c:if>
                            <li class="top-menu-seperator"></li>
                       		<c:forEach var="menu" items="${topMenuList}" varStatus="status">
	                            <c:choose>
									<c:when test="${topMenuId eq menu.getString('menuId')}">
	                            		<c:set var="isActive" value="true" />
									</c:when>
	        						<c:otherwise>
	                            		<c:set var="isActive" value="false" />
	        						</c:otherwise>
	                            </c:choose>
	                            <c:choose>
									<c:when test="${menu.has('menuId')}">
	                            		<c:url var="url" value="/" />
									</c:when>
	        						<c:otherwise>
	                            		<c:url var="url" value="${menu.getString('menuUrl')}" />
	        						</c:otherwise>
	                            </c:choose>
	                            <li class="top-menu">
	                                <a class="top-menu-link ${isActive ? 'selected' : ''}" data-sec_depth="${menu.getString('menuId')}" href="${url}"><span>${menu.getString('menuName')}</span></a>
	                                <div class="menu-bottom ${isActive ? '' : 'hide'}"><img src="<c:url value='/images/menu_bottom_arrow.png'/>"></div>
	                            </li>
                            	<c:if test="${not status.last}">
	                            	<li class="top-menu-seperator-line"></li>
	                            </c:if>
                       		</c:forEach>
                        </ul>
                        <ul class="nav-right">
                            <form id="frmLayoutAlarmMain" method="POST"></form>
                            <li class="header-notification" id="layout_alarm">
                                <a href="#!" id="control_noti" class="waves-effect waves-light" style="line-height:50px; padding-top: 6px;">
                                    <%-- <i class="fa fa-shopping-cart" style="font-size:20px;">
                                        <span class="badge bg-danger" style="font-size:12px; top:0px; right:0px; display:none !important;">0</span>
                                    </i> --%>
                                </a>
                                <%--
                                    <li>
                                        <h6>Notifications</h6>
                                        <label class="label label-danger">New</label>
                                    </li>

                                    <li class="waves-effect waves-light">
                                        <div class="media">
                                            <img class="d-flex align-self-center img-radius" src="<c:url value='/assets/images/avatar-4.jpg'/>">
                                            <div class="media-body">
                                                <h5 class="notification-user">Joseph William</h5>
                                                <p class="notification-msg">Lorem ipsum dolor sit amet, consectetuer elit.</p>
                                                <span class="notification-time">30 minutes ago</span>
                                            </div>
                                        </div>
                                    </li>
                                    <li class="waves-effect waves-light">
                                        <div class="media">
                                            <img class="d-flex align-self-center img-radius" src="<c:url value='/assets/images/avatar-3.jpg'/>">
                                            <div class="media-body">
                                                <h5 class="notification-user">Sara Soudein</h5>
                                                <p class="notification-msg">Lorem ipsum dolor sit amet, consectetuer elit.</p>
                                                <span class="notification-time">30 minutes ago</span>
                                            </div>
                                        </div>
                                    </li>

                                </ul> --%>
                            </li>
                            <li class="user-profile header-notification" id="control_mymenu">
                                <a href="#!" class="waves-effect waves-light">
                                    <%-- <img src="<c:url value='/assets/images/avatar-4.jpg'/>" class="img-radius"> --%>
                                    <span>${user_name}</span>
                                    <i class="ti-angle-down"></i>
                                </a>
                                <ul class="show-notification profile-notification">
                                    <%-- <li class="waves-effect waves-light">
                                        <a href="#!">
                                            <i class="ti-settings"></i> Settings
                                        </a>
                                    </li>
                                    <li class="waves-effect waves-light">
                                        <a href="<c:url value='/sample/user-profile'/>">
                                            <i class="ti-user"></i> Profile
                                        </a>
                                    </li>
                                    <li class="waves-effect waves-light">
                                        <a href="<c:url value='/sample/email-inbox'/>">
                                            <i class="ti-email"></i> My Messages
                                        </a>
                                    </li>
                                    <li class="waves-effect waves-light">
                                        <a href="<c:url value='/sample/auth-lock-screen'/>">
                                            <i class="ti-lock"></i> Lock Screen
                                        </a>
                                    </li> --%>
                                    <li class="waves-effect waves-light">
                                        <a href="<c:url value='/userInfo.do'/>">
                                            <i class="ti-user"></i> 정보수정
                                        </a>
                                    </li>
                                    <li class="waves-effect waves-light">
                                        <a href="<c:url value='/logout.do'/>">
                                            <i class="ti-layout-sidebar-left"></i> Logout
                                        </a>
                                    </li>
                                </ul>
                            </li>
                        </ul>
                    </div>
                </div>
            </nav>

            <div class="pcoded-main-container">
                <div class="pcoded-wrapper">
                    <nav class="pcoded-navbar" style="width:0px;">
                        <div class="sidebar_toggle"><a href="#"><i class="icon-close icons"></i></a></div>
                        <div class="pcoded-inner-navbar main-menu" id="sub_menu_wrapper">
                            <div class="">
                                <div class="main-menu-header">
                                    <%-- <img class="img-80 img-radius" src="<c:url value='/assets/images/avatar-4.jpg'/>"> --%>
                                    <%-- <div class="user-details">
                                        <span id="more-details">John Doe<i class="fa fa-caret-down"></i></span>
                                    </div> --%>
                                </div>
                                <div class="main-menu-content">
                                    <ul>
                                        <li class="more-details">
                                            <a href="<c:url value='/sample/user-profile'/>"><i class="ti-user"></i>View Profile</a>
                                            <a href="#!"><i class="ti-settings"></i>Settings</a>
                                            <a href="<c:url value='/sample/auth-normal-sign-in'/>"><i class="ti-layout-sidebar-left"></i>Logout</a>
                                        </li>
                                    </ul>
                                </div>
                            </div>
                            <%--
                            <div class="p-15 p-b-0">
                                <form class="form-material">
                                    <div class="form-group form-primary">
                                        <input type="text" name="footer-email" class="form-control">
                                        <span class="form-bar"></span>
                                        <label class="float-label"><i class="fa fa-search m-r-10"></i>Search Friend</label>
                                    </div>
                                </form>
                            </div>
                            --%>
                            
                            
	                       	<c:forEach var="menu" items="${menuList}" varStatus="status">
	                            <c:choose>
									<c:when test="${menu.getString('childNode') eq 'Y'}">
	                            		<c:set var="isChildNode" value="true" />
									</c:when>
	        						<c:otherwise>
	                            		<c:set var="isChildNode" value="false" />
	        						</c:otherwise>
	                            </c:choose>
	                            <c:choose>
									<c:when test="${not menu.isEmpty('menuUrl') and menu.getString('activeMenuUrl') eq requestScope['javax.servlet.forward.request_uri']}">
	                            		<c:set var="isActive" value="true" />
									</c:when>
	        						<c:otherwise>
	                            		<c:set var="isActive" value="false" />
	        						</c:otherwise>
	                            </c:choose>
	                       		<c:if test="${menu.getString('menuDepth') eq '2'}">		                            
		                            <ul class="pcoded-item pcoded-left-item" data-sec_depth="${menu.getString('parentMenuId')}">
		                                <li class="${isChildNode ? 'pcoded-hasmenu' : ''} ${(menu.getString('childNode') eq 'Y' and menu.getString('menuId') eq parentMenuId) or isActive ? ' active pcoded-trigger' : ''}">
		                                	<c:url var="url" value="${menu.getString('menuUrl')}" />
		                                    <a href="${menu.getString('childNode') eq 'Y' and menu.isEmpty('menuUrl') ? 'javascript:;' : url}" class="waves-effect waves-dark">
		                                        <span class="pcoded-micon"><i class="${menu.getString('menuIcon')}"></i></span>
		                                        <span class="pcoded-mtext">${menu.getString('menuName')}</span>
		                                        <span class="pcoded-mcaret"></span>
		                                    </a>
		                                    
				                            <c:choose>
												<c:when test="${not isChildNode}">
		                                </li>
		                            </ul>
												</c:when>
				        						<c:otherwise>
                                    <ul class="pcoded-submenu">
				        						</c:otherwise>
				                            </c:choose>
	                       		</c:if>
	                       		<c:if test="${menu.getString('menuDepth') eq '3'}"> 
                                        <li class="${isActive ? 'active' : '' }">
                                            <a href="<c:url value='${menu.getString("menuUrl")}' />" class="waves-effect waves-dark">
                                                <span class="pcoded-micon"><i class="ti-angle-right"></i></span>
                                                <span class="pcoded-mtext">${menu.getString('menuName')}</span>
                                                <span class="pcoded-mcaret"></span>
                                            </a>
                                        </li>
                                        <c:if test="${menu.getString('mnDesc') eq '1'}">
                                    </ul>
                                </li>
                            </ul>
		                               	</c:if>
	                       		</c:if>
                       		</c:forEach>
                            <!-- Menu Ends -->
                        </div>
                    </nav>
                    <div class="pcoded-content">
                        <!-- Page-header start -->
                        <div id="head_all_wrapper" class="page-header">
                            <div class="page-block">
                                <div class="row align-items-center">
                                    <div class="col-md-6">
                                        <div class="page-header-title">
                                            <h5 class="m-b-10" style="margin-bottom: 0px;">${menuName}</h5>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <ul class="breadcrumb">
                                            <li class="breadcrumb-item">
                                                <a href="<c:url value='/index.do'/>"> <i class="fa fa-home"></i> </a>
                                            </li>
                                            <c:forTokens var="name" items="${menuStr}" delims="|" varStatus="status">
					                            <c:choose>
													<c:when test="${status.last}">
                                                <li class="breadcrumb-item"><a href="${requestScope['javax.servlet.forward.request_uri']}">${name}</a></li>
													</c:when>
					        						<c:otherwise>
                                                <li class="breadcrumb-item">${name}</li>
					        						</c:otherwise>
					                            </c:choose>
                                            </c:forTokens>
                                        </ul>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <!-- Page-header end -->
                        <div class="pcoded-inner-content" id="body_content_wrapper">
                            <!-- Main-body start -->
                            <div class="main-body">
                                <div class="page-wrapper">
                                    <!-- Page-body start -->