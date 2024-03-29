<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib  uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE HTML>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>HostedPCI Demo App 3D Secure Confirmation1 Page</title>
<!-- Bootstrap 3.2.0-->
<link
	href="https://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap.min.css"
	rel="stylesheet">
<link
	href="https://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap-theme.min.css"
	rel="stylesheet">
<link href="css/template.css" rel="stylesheet">
<link rel="shortcut icon" href="./favicon-new.png">
<script src="js/jquery-2.1.1.js" type="text/javascript" charset="utf-8"></script>
<script src="https://ccframe.hostedpci.com/WBSStatic/site60/proxy/js/jquery.ba-postmessage.2.0.0.min.js" type="text/javascript" charset="utf-8"></script>
<script src="https://ccframe.hostedpci.com/WBSStatic/site60/proxy/js/hpci-cciframe-1.0.js" type="text/javascript" charset="utf-8"></script>
<script>
	var hpciCCFrameHost;
	
	var hpci3DSitePINSuccessHandler = function() {
		console.log("=================Begin hpci3DSitePINSuccessHandler=================");
		// name of the form submission for ecommerce site
		var pendingForm = document.getElementById("CCAcceptForm");
		console.log("=================End hpci3DSitePINSuccessHandler=================");
		
		pendingForm.submit();
	}

	var hpci3DSitePINErrorHandler = function() {
		console.log("=================Begin hpci3DSitePINErrorHandler=================");
		// Adapt the following message / action to match your required experience
		alert("Could not verify PIN for the credit card");
		console.log("=================End hpci3DSitePINErrorHandler=================");
	}
</script>
<script type="text/javascript">
$(document).ready(function () {
    var flag = "config";
    
    jQuery.get("Iframe3DSecServlet",
    	    {
    			flag:flag,
    		},
    		function(data){
    			//parse the result
    			var resultMap = [], queryToken;
    		    if(data != undefined) {
    				queryTokenList = data.split(',');
    				for(var i = 0; i < queryTokenList.length; i++){
   						queryToken = queryTokenList[i].split(';');
   						resultMap.push(queryToken[1]);
   						resultMap[queryToken[0]] = queryToken[1];
    				}
    		    }    			
    			hpciCCFrameHost = resultMap["serviceUrl"];		    			
    		});
	
	
    $("#toggleMessage").click(function() {
		$("#message").toggle("slow");
		$(this).val($(this).val() == "Show response" ? "Hide response" : "Show response");
	});
});
</script>
</head>
<body>
<!-- container class sets the page to use 100% width -->
<div class="container">
	<!-- row class sets the margins -->
		<!-- col-md-7 col-centered class uses the bootstrap grid system to use 7/12 of the screen and place it in the middle -->
		<div class="col-md-7 col-lg-10 col-centered">
			<div class="demo-navbar">
				<div class="row">
					<ul>
						<li><a href="home.jsp">Home</a></li>
						<li><a id = "hostedPCI" href="http://www.hostedpci.com/"></a></li>
					</ul>
				</div>
			</div>
			<form id="CCAcceptForm" action="/Iframe3DSecServlet" method="post" class = "checkout-confirmation">
			<input type="hidden" name="action" value="form3DSecResponse">
				<section>
					<fieldset style="min-height: 100px;">
						<!-- Form Name -->
						<legend>Web Checkout</legend>
						<!-- Text Input -->
						<div>
							Dear Hosted PCI Customer,<br /> Thank you for trying our
							services. If you have any questions, please contact us at
							www.hostedpci.com<br />
							<br /> <label>Transaction Summary</label><br />
							<label>*******************</label><br />
							<c:choose>
								<c:when test="${map['pxyResponse.threeDSEnrolled'].equals('Y')}">
									<iframe seamless id="threeDSecFrame" name="threeDSecFrame" onload="receivePINMsg()" 
										src="${globalMap['serviceUrl']}/iSynSApp/appUserVerify3DResp!verificationForm.action?
											sid=${globalMap['siteId']}&authTxnId=${map['pxyResponse.threeDSTransactionId']}
											&fullParentHost=${globalMap['fullParentHost']}&fullParentQStr=/webCheckoutConfirmation1.jsp" 
											width=450 height=400 style="border:none">
									If you can see this, your browser doesn't understand IFRAME.
									</iframe>
									<br />
								</c:when>
								<c:when test="${map['pxyResponse.threeDSEnrolled'] ne 'Y'}">
									<!-- Gets responseStatus from the response map that hpci's server sent back -->
									<c:if test="${not empty map['status']}">
										<label>HPCI Status: <c:out value="${map['status']}" /></label><br />
									</c:if>
									<c:if test="${not empty map['pxyResponse.responseStatus.name']}">
										<label>Status Name: <c:out value="${map['pxyResponse.responseStatus.name']}" /></label><br />
									</c:if>
									<c:if test="${not empty map['pxyResponse.responseStatus.description']}">							
										<label>Description: <c:out value="${map['pxyResponse.responseStatus.description']}" /></label><br />
									</c:if>
									<c:if test="${not empty map['pxyResponse.responseStatus.code']}">							
										<label>Status Code: <c:out value="${map['pxyResponse.responseStatus.code']}" /></label><br />
									</c:if>
									<c:if test="${not empty map['pxyResponse.responseStatus.reasonCode']}">							
										<label>Reason Code: <c:out value="${map['pxyResponse.responseStatus.reasonCode']}" /></label><br />
									</c:if>
									<c:if test="${not empty map['pxyResponse.responseStatus']}">							
										<label>Status: <c:out value="${map['pxyResponse.responseStatus']}" /></label><br />
									</c:if>
									<c:if test="${not empty map['errId']}">
										<label>HPCI Error Code: <c:out value="${map['errId']}" /></label><br />	
										<label>HPCI Description: <c:out value="${map['errFullMsg']}" /></label><br />
										<c:if test="${not empty map['errParamName']}">
											<label>HPCI Error Parameter Name: <c:out value="${map['errParamName']}" /></label><br />
										</c:if>
										<c:if test="${not empty map['errParamValue']}">
											<label>HPCI Error Parameter Value: <c:out value="${map['errParamValue']}" /></label><br />	
										</c:if>		
									</c:if>
									<c:if test="${not empty map['pxyResponse.fullNativeResp']}">							
										<label>Native Response: <c:out value="${map['pxyResponse.fullNativeResp']}" /></label><br />
									</c:if>
									<c:if test="${not empty map['pxyResponse.processorRefId']}">
										<label>Processor Reference ID: <c:out value="${map['pxyResponse.processorRefId']}" /></label><br />
									</c:if>
									<!-- Gets cardNumber -->
									<label>Token Card Number: <c:out value="${globalMap['cardNumber']}" /></label><br />
									<!-- Gets cardCVV -->
									<label>Token CVV Number: <c:out value="${globalMap['cardCVV']}" /></label><br />
									<!-- Gets today's date -->
									<label>Payment Date: <c:set var="now" value="<%=new java.util.Date()%>" /><fmt:formatDate type="both" value="${now}" /></label><br />
								</c:when>
							</c:choose>
							<input type="button" id="toggleMessage" value="Show response" class="btn">
							<div id="message" style="display:none; word-wrap: break-word;">
								<label>Full Message: </label><br />
								<c:out value="${map}" />
							</div><br />
							<label>*******************</label><br /> Thank you for using Hosted PCI.<br />
							<br /> <input Type="button" class="btn btn-primary" value="Back" onClick="history.go(-1);return true;"></input><br />
							<input type="hidden" id="ccNum" name="ccNum" value="${globalMap['cardNumber']}" />
							<input type="hidden" id="ccCVV" name="ccCVV" value="${globalMap['cardCVV']}" />
							<input type="hidden" name="action3DSec" value="verifyresp" />
							<input type="hidden" name="authTxnId" value="${map['pxyResponse.threeDSTransactionId']}" />
						</div>
					</fieldset>
				</section>
			</form>
		</div><!-- col-md-7 col-centered -->
</div><!-- container -->
</body>
</html>