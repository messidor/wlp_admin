<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE HTML>
<html lang="ko">

<head>
<meta charset="UTF-8">
<meta http-equiv="X-UA-Compatible" content="IE=Edge">
<meta name="description" content="">
<meta name="keywords" content="">
<title>일시적인 서비스 장애 안내</title>
<style type="text/css">
.error {padding-top: 4%; margin: 0; font-family: 'Pretendard', 'ëì', dotum, sans-serif; text-align: center;}
.error::before {content: ''; display:block; width:410px; height:239px; margin: 0 auto 50px; background: url(/walletfree-admin/assets/images/img_error.png)no-repeat;}
.error strong {display: block; margin-bottom: 40px; font-size: 40px; font-weight: 300; color: #009fb5;}
.error p {line-height: 23px; margin: 0;}
.error a {display: inline-block; padding: 10px 30px; margin-top: 30px; font-weight: 600; border: 2px solid #009fb5; border-radius: 30px; color:#009fb5; text-decoration: none;}
</style>
</head>
<body>
    <div class="error">
        <strong>이용에 불편을 드려 죄송합니다.</strong>
        <p>페이지의 주소가 올바른지 다시 한번 확인해 주시길 부탁드립니다. <br>계속된 오류시에 관리자에게 문의바랍니다.</p>
        <a href="javascript:history.back();">이전 페이지로</a>
    </div>
</body> 
</html>