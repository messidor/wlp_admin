<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="form" uri="http://ad.its.yeongju.kr/jsp/jstl/form"%>
<%@ taglib prefix="card" uri="http://ad.its.yeongju.kr/jsp/jstl/card"%>
<%@ taglib prefix="func" uri="http://ad.its.yeongju.kr/jsp/jstl/func"%>
<%@ taglib prefix="label" uri="http://ad.its.yeongju.kr/jsp/jstl/label" %>

<%@ include file="../../core/include/head.jsp"%>
<%@ include file="../../core/include/header.jsp"%>

<script type="text/javascript">
	
	function xmlToJson(xml) {
	  // Create the return object
	  var obj = {};

	  if (xml.nodeType == 1) {
	    // element
	    // do attributes
	    if (xml.attributes.length > 0) {
	      obj["@attributes"] = {};
	      for (var j = 0; j < xml.attributes.length; j++) {
	        var attribute = xml.attributes.item(j);
	        obj["@attributes"][attribute.nodeName] = attribute.nodeValue;
	      }
	    }
	  } else if (xml.nodeType == 3) {
	    // text
	    obj = xml.nodeValue;
	  }

	  // do children
	  // If all text nodes inside, get concatenated text from them.
	  var textNodes = [].slice.call(xml.childNodes).filter(function(node) {
	    return node.nodeType === 3;
	  });
	  if (xml.hasChildNodes() && xml.childNodes.length === textNodes.length) {
	    obj = [].slice.call(xml.childNodes).reduce(function(text, node) {
	      return text + node.nodeValue;
	    }, "");
	  } else if (xml.hasChildNodes()) {
	    for (var i = 0; i < xml.childNodes.length; i++) {
	      var item = xml.childNodes.item(i);
	      var nodeName = item.nodeName;
	      if (typeof obj[nodeName] == "undefined") {
	        obj[nodeName] = xmlToJson(item);
	      } else {
	        if (typeof obj[nodeName].push == "undefined") {
	          var old = obj[nodeName];
	          obj[nodeName] = [];
	          obj[nodeName].push(old);
	        }
	        obj[nodeName].push(xmlToJson(item));
	      }
	    }
	  }
	  return obj;
	}
	
	function XMLToString(oXML) {
		 
	    //code for IE
	    if (window.ActiveXObject) {
	        var oString = oXML.xml;
	        return oString;
	    }
	    // code for Chrome, Safari, Firefox, Opera, etc.
	    else {
	        return (new XMLSerializer()).serializeToString(oXML);
	    }
	}
	
	$(function() {
		let today = new Date();   

		let hours = today.getHours(); // 시
		let minutes = today.getMinutes();  // 분
		let seconds = today.getSeconds();  // 초
		let milliseconds = today.getMilliseconds(); // 밀리초
		var phour = (hours+1) == "24" ? "00" : (hours+1); 
		
		//일자 
		$("#outDt").initDateOnly("days"); 
		$("#outDt2").initTimeOnly(phour + ':' + Math.floor(minutes / 10) * 10  + ':' + seconds); 
		     
		var card_height = $("#mCSB_1_container_wrapper").outerHeight() - $(".card").parent().outerHeight() - 50;
		$(".card-header").eq(1).css('height', card_height);
         
		// 조회
		$("#btnEnterApi").click(function() {
			if($("#kServiceKey").val() == ""){
				alert("ServiceKey를 입력해 주세요.");
				return;
			}
			
			if($("#kparkingAreaCode").val() == ""){
				alert("parkingAreaCode를 입력해 주세요.");
				return;	
			}
			
			if($("#kcarNumber").val() == ""){
				alert("carNumber를 입력해 주세요.");
				return;
			}
			
			if($("#parkingFee").val() == ""){
				alert("parkingFee를 입력해 주세요.");
				return;
			}
			 
			var apiUrl = "${apiUrl}";
			
			$.ajax({
				url: apiUrl+"getwalletFreeOut.do?serviceKey=" +encodeURIComponent($("#kServiceKey").val()) + "&parkingAreaCode=" + encodeURIComponent($("#kparkingAreaCode").val()) + "&carNumber=" + $("#kcarNumber").val() + "&parkingFee=" + $("#parkingFee").val() + "&reduceCode=" + $("#reduceCode").val() + "&outDt=" + $("#outDt").val()+" "+$("#outDt2").val().replace(/ /g,""),
				method: "GET",
                data: {},
                dataType: "xml",
               	success : function(data, textStatus, jqXHR) {
	                	if (data.count != 0) {
	                		var json = xmlToJson(data);
	                		
	                		$("#rCarNumber").val("");
	                		$("#paymentYN").val("");
	                		$("#mdfcnDt").val("");
	                		$("#XML").val("");
	                		
	                		if(json.walletFreeApi !== undefined){
		                		alert("출차 API 호출이 정상적으로 처리되었습니다.");
		                		
		                		$("#resultCode").val(json.walletFreeApi.header.resultCode);
		                		$("#resultMsg").val(json.walletFreeApi.header.resultMsg);
		                		$("#rCarNumber").val(json.walletFreeApi.body.carNumber);
		                		$("#paymentYN").val(json.walletFreeApi.body.data.list.paymentYN);
		                		$("#mdfcnDt").val(json.walletFreeApi.body.data.list.mdfcnDt);
		                		$("#XML").val(XMLToString(data));
	                		}else{
								alert(json.OpenAPI_ServiceResponse.cmmMsgHeader.returnAuthMsg);
		                		
		                		$("#resultCode").val(json.OpenAPI_ServiceResponse.cmmMsgHeader.returnReasonCode);
		                		$("#resultMsg").val(json.OpenAPI_ServiceResponse.cmmMsgHeader.errMsg);
		                		$("#rCarNumber").val("");
		                		$("#walletFreeYN").val("");
		                		$("#reduceCode").val("");
		                		$("#reduceNm").val("");
		                		$("#reduceRate").val("");
		                		$("#mdfcnDt").val("");
		                		$("#XML").val(XMLToString(data));
	                		}
	                	} else {
	                		alert("실행중 오류가 발생했습니다.");
	                	}
                },
                error: function(data, textStatus, jqXHR){
                    alert(xmlToJson(data));
                }
            });
		});

	});
</script>


<div class="page-body" style="font-size: 0.9em;">
	<div class="row">
		<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12" id="search_all_wrapper">
			<card:open title="출차 API 입력값" />
			<card:button>
				<button type="button" id="btnEnterApi" class="btn btn-sm waves-effect waves-light btn-info btn-outline-info default"> 
				    <span class="icofont icofont-login"></span> 
				    &nbsp;출차
				</button>
			</card:button>
			<card:content />
			<div class="search-area col-lg-12">
				<form id="frmMain" name="frmMain" method="post" onsubmit="return false" class="form-material form-inline">
					<form:input type="hidden" caption="hEnterUrl" id="hEnterUrl" value="http://192.168.0.55:8131/walletfree/walletFree/getwalletFreeOut.do"/>
					<form:input id="ServiceKey" caption="serviceKey" type="autocomplete" className="danger" code="kServiceKey" queryId="autocomplete.select_serviceKey" />
					<form:input id="parkingAreaCode" caption="parkingAreaCode" type="autocomplete" className="danger" code="kparkingAreaCode" queryId="autocomplete.select_parkingArea1" />
					<form:input id="parkingFee" caption="parkingFee" addAttr="maxlength='100'" value="500" className="danger"/>
					<form:input id="kcarNumber" caption="carNumber" className="danger" code="kcarNumber" />
					<form:input id="reduceCode" caption="reduceCode" addAttr="maxlength='100'" value="" />
					<div class="col-2"></div> 
					<form:input id="outDt" caption="outDt" className="danger"/>
					<form:input id="outDt2" caption="outDt2" className="danger"/>
				</form>
			</div>
			<card:close />
		</div> 
		<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12">
			<card:open title="출차 API 결과" />
			<card:content />
			<div id="enterResult">
				<div class="col-xl-12 col-lg-12 col-md-12 col-sm-12"> 
					<div class="form-group col-xl-3 col-lg-3 col-md-3 col-sm-3 no-margin no-padding"> 
		                <label class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right">결과</label> 
		                <div class="col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached"> 
		                    <div class="input-group"> 
		                        <span class="input-group-addon"><i class="fas fa-eye" data-icon="fas fa-eye"></i></span> 
		                        <input name="resultCode" id="resultCode" class="form-control " type="text" value="" readonly="readonly"> 
		                    </div> 
		                </div> 
		            </div>
		            <div class="form-group col-xl-3 col-lg-3 col-md-3 col-sm-3 no-margin no-padding"> 
		                <label class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right">결과메세지</label> 
		                <div class="col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached"> 
		                    <div class="input-group"> 
		                        <span class="input-group-addon"><i class="fas fa-eye" data-icon="fas fa-eye"></i></span> 
		                        <input name="resultMsg" id="resultMsg" class="form-control " type="text" value="" readonly="readonly"> 
		                    </div> 
		                </div> 
		            </div>
	            </div> 
	            <div class="col-xl-12 col-lg-12 col-md-12 col-sm-12">
		            <div class="form-group col-xl-3 col-lg-3 col-md-3 col-sm-3 no-margin no-padding"> 
		                <label class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right">차량번호</label> 
		                <div class="col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached"> 
		                    <div class="input-group"> 
		                        <span class="input-group-addon"><i class="fas fa-eye" data-icon="fas fa-eye"></i></span> 
		                        <input name="rCarNumber" id="rCarNumber" class="form-control " type="text" value="" readonly="readonly"> 
		                    </div> 
		                </div> 
		            </div>
		            <div class="form-group col-xl-3 col-lg-3 col-md-3 col-sm-3 no-margin no-padding"> 
		                <label class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right">결제완료여부</label> 
		                <div class="col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached"> 
		                    <div class="input-group"> 
		                        <span class="input-group-addon"><i class="fas fa-eye" data-icon="fas fa-eye"></i></span> 
		                        <input name="paymentYN" id="paymentYN" class="form-control " type="text" value="" readonly="readonly"> 
		                    </div> 
		                </div> 
		            </div>
		            <div class="form-group col-xl-3 col-lg-3 col-md-3 col-sm-3 no-margin no-padding">  
		                <label class="col-xl-5 col-lg-5 col-md-5 col-sm-5 col-5 control-label text-right" style="width: 120px !important;">데이터기준일자</label> 
		                <div class="col-xl-7 col-lg-7 col-md-7 col-sm-7 col-7 inputGroupContainer label-attached" style="max-width: calc(100% - 120px);"> 
		                    <div class="input-group"> 
		                        <span class="input-group-addon"><i class="fas fa-eye" data-icon="fas fa-eye"></i></span> 
		                        <input name="mdfcnDt" id="mdfcnDt" class="form-control " type="text" value="" readonly="readonly"> 
		                    </div> 
		                </div> 
		            </div>
	            </div>
	            <div class="form-group col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12 no-margin no-padding "> 
	                <label class="col-xl-4 col-lg-4 col-md-4 col-sm-4 col-4 control-label text-right">XML정보</label> 
	                <div class="col-xl-8 col-lg-8 col-md-8 col-sm-8 col-8 inputGroupContainer label-attached"> 
	                    <div class="input-group">   
	                        <span class="input-group-addon"><i class="fas fa-eye" data-icon="fas fa-eye"></i></span> 
	                        <textarea name="XML" id="XML" class="form-control" rows="18" style="background: #eeeeee"></textarea> 
	                    </div>  
	                </div>   
	            </div>
            </div> 
			</div>
			<card:close />
		</div>
	</div>
</div>

<%@ include file="../../core/include/footer.jsp"%>
