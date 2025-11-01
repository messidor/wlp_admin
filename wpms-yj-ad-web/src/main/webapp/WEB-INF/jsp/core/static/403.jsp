<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE HTML>
<html lang="ko">

<head>
<meta charset="UTF-8">
<meta http-equiv="X-UA-Compatible" content="IE=Edge">
<meta name="description" content="">
<meta name="keywords" content="">
<title>접근 권한 없음</title>
<style type="text/css">
.error {max-width: 500px; margin: 0 auto; padding-top: 4%; font-family: 'Pretendard', '돋움', dotum, sans-serif; text-align: center;}
.error::before {content: ''; display:block; width:68px; height:60px; margin: 0 auto 35px; background: url(/walletfree-admin/assets/images/main/img_error_adm.png)no-repeat;}
.error strong {display: block; margin-bottom: 25px; font-size: 35px; letter-spacing: -0.5px; font-weight: bold; color: #000;}
.error strong em {font-style: normal; /* color: #009fb5; */}
.error p {line-height: 23px; margin: 0; padding: 15px; border-radius: 18px; background-color: #f7f7f7;}
.error a {display: inline-block; padding: 10px 30px; margin-top: 30px; border: 2px solid #eee; border-radius: 30px; color:#999999; text-decoration: none;}
</style>
</head>

<body>
    <div class="error">
        <strong><em>접근 권한이</em> 없습니다.</strong>
        <p>관리자에게 문의해 주시기 바랍니다.</p>
        <%-- <a href="">이전 페이지로</a> --%>
    </div>
</body>