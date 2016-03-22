<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE HTML>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>HostedPCI Demo App 3D Secure Confirmation2 Page</title>
<!-- Bootstrap 3.2.0-->
<link
	href="https://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap.min.css"
	rel="stylesheet">
<link
	href="http://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap-theme.min.css"
	rel="stylesheet">
<link href="css/template.css" rel="stylesheet">
<!-- Jquery 1.4.1-->
<!-- <script src="https://ccframe.hostedpci.com/WBSStatic/site60/proxy/js/jquery-1.4.1.min.js" type="text/javascript" charset="utf-8"></script> -->
<script src="js/jquery-2.1.1.js" type="text/javascript" charset="utf-8"></script>
<script src="https://ccframe.hostedpci.com/WBSStatic/site60/proxy/js/jquery.ba-postmessage.2.0.0.min.js" type="text/javascript" charset="utf-8"></script>
<script src="https://ccframe.hostedpci.com/WBSStatic/site60/proxy/js/hpci-cciframe-1.0.js" type="text/javascript" charset="utf-8"></script>
<script>
	var hpciCCFrameHost = "https://ccframe.hostedpci.com";
	var hpciCCFrameFullUrl ;
	var hpciCCFrameName = "ccframe"; // use the name of the frame containing the credit card

	var hpciSiteErrorHandler = function(errorCode, errorMsg) {
		// Please the following alert to properly display the error message
		//alert("Error while processing credit card code:" + errorCode + "; msg:"	+ errorMsg);
		document.getElementById('errorMessage').style.display = 'block';
	}

	var hpciSiteSuccessHandlerV2 = function(mappedCCValue, mappedCVVValue, ccBINValue) {
		// Please pass the values to the document input and then submit the form
		
		// No errors from iframe so hide the errorMessage div
		document.getElementById('errorMessage').style.display = 'none';
		// Name of the input (hidden) field required by ecommerce site
		// Typically this is a hidden input field.
		var ccNumInput = document.getElementById("ccNum");
		ccNumInput.value = mappedCCValue;
		alert("ccNumInput = " + ccNumInput);

		// name of the input (hidden) field required by ecommerce site
		// Typically this is a hidden input field.
		var ccCVVInput = document.getElementById("ccCVV");
		ccCVVInput.value = mappedCVVValue;

		// name of the input (hidden) field required by ecommerce site
		// Typically this is a hidden input field.
		var ccBINInput = document.getElementById("ccBIN");
		ccBINInput.value = ccBINValue;

		// name of the form submission for ecommerce site
		var pendingForm = document.getElementById("CCAcceptForm");
		pendingForm.submit();

	}

	var hpci3DSitePINSuccessHandler = function() {
		// name of the form submission for ecommerce site
		var pendingForm = document.getElementById("CCAcceptForm");
		pendingForm.submit();
	}

	var hpci3DSitePINErrorHandler = function() {
		// Adapt the following message / action to match your required experience
		alert("Could not verify PIN for the credit card");
	}

	var hpciCCPreliminarySuccessHandler = function(hpciCCTypeValue, hpciCCBINValue, hpciCCValidValue, hpciCCLengthValue) {
		// Adapt the following message / action to match your required experience
		alert("Received preliminary credit card details");
	}

	var hpciCVVPreliminarySuccessHandler = function(hpciCVVLengthValue) {
		// Adapt the following message / action to match your required experience
		alert("Received preliminary CVV details");
	}
</script>
<script type="text/javascript">
$(document).ready(function(){
    $("#showMessage").on('change', function() {
      if ( this.value == 'yes')
      {
        $("#message").show('slow');
      }
      else
      {
        $("#message").hide('slow');
      }
    });
});
</script>
<script type="text/javascript">
$(document).ready(function () {
	var siteId;
    var locationName;
    var fullParentQStr;
    var fullParentHost;    
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
    			siteId = resultMap["sid"];
    			locationName = resultMap["locationName"]; 
    			fullParentQStr = "webCheckoutConfirmation2.jsp";
    			fullParentHost = location.protocol.concat("//") + window.location.hostname +":" +location.port;
    			
    			console.log(location.protocol.concat("//") + window.location.hostname +":" +location.port);
    			console.log(location.pathname);
    			console.log("SiteId :" + siteId);
    			console.log("LocationName :" +locationName);  
    			
    			hpciCCFrameFullUrl = "https://ccframe.hostedpci.com/iSynSApp/showPxyPage!ccFrame.action?pgmode1=prod&"
    				    +"locationName="+locationName
    				    +"&sid=" + siteId
    				    +"&reportCCType=Y"
    				    +"&fullParentHost=" + fullParentHost
    				    +"&fullParentQStr=" + fullParentQStr;    			  			
    			console.log(hpciCCFrameFullUrl);
    		});
	
	$('#noButton').click(function () {
		$('#message').hide('slow');
	});
	$('#yesButton').click(function () {
		$('#message').show('slow');
	});
});
</script>

</head>
<body>
<!-- container class sets the page to use 100% width -->
<div class="container">
	<!-- row class sets the margins -->
	<div class="row">
		<!-- col-md-7 col-centered class uses the bootstrap grid system to use 7/12 of the screen and place it in the middle -->
		<div class="col-md-7 col-centered">
			<form id="CCAcceptForm" action="/Iframe3DSecServlet" method="post">
			<input type="hidden" name="action" value="form3DSecResponse">
				<section style="margin: 10px;">
					<fieldset style="min-height: 100px;">
						<!-- Form Name -->
						<legend>Web Checkout 3D Secure</legend>
						<!-- Text Input -->
						<div>
							Dear Hosted PCI Customer,<br /> Thank you for trying our
							services. If you have any questions, please contact us at
							www.hostedpci.com<br /><br /> 
							<label>Transaction Summary</label><br /> 
							<label>*******************</label><br />
							<!-- Checks if signature validation passed -->
							<c:if test="${responseMap['pxyResponse.threeDSSRS'].equals('Y')}">
								<!-- Gets responseStatus from the response map that the iframe sent back -->
								<label>Status: <c:out value="${responseMap['pxyResponse.responseStatus.name']}" /></label><br />
								<!-- Gets description from the response map that the iframe sent back -->
								<label>Description: <c:out value="${responseMap['pxyResponse.responseStatus.description']}" /></label><br />
								<!-- Gets processorRefId from the response map that the iframe sent back -->
								<label>Processor Reference ID: <c:out value="${responseMap['pxyResponse.processorRefId']}" /></label><br />
								<!-- Gets merchantRefId from the response map that the iframe sent back -->
								<label>Merchant ID: <c:out value="${globalMap['merchantRefId']}" /></label><br />
								<!-- Gets cardType from the user input on previous page -->
								<c:set var="mappedParams" value="${responseMap['pxyResponse.mappedParams']}" />
								<c:set var="mappedParamsValue" value="${fn:split(mappedParams, '=')}" />
								<label>Card Type: <c:out value="${mappedParamsValue[1]}" /></label><br />
								<!-- Gets cardNumber  -->
								<label>Token Card Number: <c:out value="${globalMap['cardNumber']}" /></label><br />
								<!-- Gets cvvNumber  -->
								<label>Token CVV Number: <c:out value="${globalMap['cardCVV']}" /></label><br />
								<!-- Gets authTxnId  -->
								<label>AuthTxnId: <c:out value="${responseMap['pxyResponse.threeDSTransactionId']}" /></label><br />
								<!-- Gets today's date -->
								<label>Payment Date: <c:set var="now" value="<%=new java.util.Date()%>" /><fmt:formatDate type="both" value="${now}" /></label><br />
								<!-- Gets amount from the user input on previous page -->
								<label>Amount: <c:out value="${globalMap['amount']}" /></label><br />
								<!-- Gets comment from the user input on previous page -->
								<label>Comments: <c:out value="${globalMap['comments']}" /></label><br />
							</c:if>
							<!-- Signature validation failed -->
							<c:if test="${responseMap['pxyResponse.threeDSSRS'].equals('N')}">
								<label>Signature validation failed, please try again</label><br />
							</c:if>
							<label>Show Full Message?</label><br />
								<input id="noButton" type="radio" name="radioButton" checked />No
								<input id="yesButton" type="radio" name="radioButton" />Yes
							<div id="message" style="display:none; word-wrap: break-word;">
								<label>Full Message: </label><br />
								<c:out value="${responseMap}" />
							</div><br />
							<label>*******************</label><br /> Thank you for using Hosted PCI.<br />
							<br /> <input Type="button" class="btn btn-primary" value="Back" onClick="history.go(-1);return true;"></input><br />
						</div>
					</fieldset>
				</section>
			</form>
		</div><!-- col-md-7 col-centered -->
	</div><!-- row -->
</div><!-- container -->
</body>
</html>