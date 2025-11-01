<%@page import="java.util.Base64"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="func" uri="http://ad.its.yeongju.kr/jsp/jstl/func" %>
<%@ taglib prefix="form" uri="http://ad.its.yeongju.kr/jsp/jstl/form" %>
<%@ taglib prefix="label" uri="http://ad.its.yeongju.kr/jsp/jstl/label" %>
<%@ taglib prefix="card" uri="http://ad.its.yeongju.kr/jsp/jstl/card" %>
<%@ page import="kr.yeongju.its.ad.proj.restcontroller.ApiCallController" %>
<%@ page import="kr.yeongju.its.ad.core.service.CommonService" %>
<%@ page import="kr.yeongju.its.ad.common.dto.CommonMap" %>
<%@ page import="java.net.InetAddress" %>
<%

String apiGubn = request.getParameter("apiGubn") == null ? "" : request.getParameter("apiGubn");
String walletFreeYn = request.getParameter("walletFreeYn") == null ? "" : request.getParameter("walletFreeYn");
String memberId = request.getParameter("memberId") == null ? "" : request.getParameter("memberId");

if(!("".equals(memberId) || "".equals(apiGubn) || "".equals(walletFreeYn))) {
    CommonService commonService = (CommonService)request.getAttribute("cmnSvc");
    ApiCallController acc = new ApiCallController(commonService);
    
    CommonMap p = new CommonMap();
    
    p.put("memberId", memberId);
    p.put("apiGubn", apiGubn);
    p.put("walletFreeYn", walletFreeYn);
    
    acc.callParkingApi(p);
}

InetAddress inet = InetAddress.getLocalHost();
String svrIP = inet.getHostAddress();
boolean isTest = svrIP.indexOf("192.168.") > -1;

%>
<html lang="ko">
<head>
    <meta charset="utf-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no" />
    <title>API Call Controller</title>
</head>
<body>
<h4 style="color:red"><%=isTest ? "테스트 서버" : "운영 서버" %> (관리자)</h4>
<form method="post">
    <pre>
        <table>
            <tr>
                <td>Member ID(복호화 된 아이디)</td>
                <td> : <input type="text" name="memberId" id="memberId" value="<%=memberId %>" /></td>
            </tr>
            <tr>
                <td>API 구분</td>
                <td> : <select name="apiGubn" id="apiGubn">
                        <option value="">선택</option>
                        <option value="1" <%=("1".equals(apiGubn) ? "selected" : "")%>>1 (자동결제 API만 호출)</option>
                        <option value="2" <%=("2".equals(apiGubn) ? "selected" : "")%>>2 (회원가입 API만 호출)</option>
                        <option value="3" <%=("3".equals(apiGubn) ? "selected" : "")%>>3 (자동결제 + 회원가입 모두 호출)</option>
                    </select>
                </td>
            </tr>
            <tr>
                <td>변경할 자동결제 여부</td>
                <td> : <select name="walletFreeYn" id="walletFreeYn">
                        <option value="">선택</option>
                        <option value="Y" <%=("Y".equals(walletFreeYn) ? "selected" : "")%>>Y (on)</option>
                        <option value="N" <%=("N".equals(walletFreeYn) ? "selected" : "")%>>N (off)</option>
                    </select>
                </td>
            </tr>
        </table>
        <button type="submit">API 호출</button>
    </pre>
</form>
<pre>
<% if("".equals(memberId) || "".equals(apiGubn) || "".equals(walletFreeYn)) { %>
※ 아이디, API 구분, 자동결제 여부는 모두 필수값입니다.
<% } else { %>
※ 입력값
아이디 : <%=memberId %>
API 구분 : <%=apiGubn %>
자동결제 여부 : <%=walletFreeYn %>
<% } %>
</pre>
</body>
</html>