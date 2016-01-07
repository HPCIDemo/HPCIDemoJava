<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE HTML>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Hosted PCI Demo App Phone Session</title>
<!-- Bootstrap -->
<link href="https://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap.min.css" rel="stylesheet">
<link href="http://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap-theme.min.css" rel="stylesheet">
<link href="css/template.css" rel="stylesheet">
<script src="js/jquery-2.1.1.js" type="text/javascript"></script>
<script type="text/javascript">
$(document).ready(function(event){
	
	// Initial value for flag is createSession, meaning it's a fresh page load and only possible action is createSession
	var flag = "createSession";
	var currentSessionId = "";
	// Initiate createSession function on createSessionButton click
	$("#createSessionButton").click(function createSession(){
		$.post("PhoneSessionServlet",
	    {
			flag:flag,
		},
		function(data){
			var responseMap = $.hpciParamMap(data);
			var callStatus = responseMap['status'];
			if(callStatus == "success") {
				$('#createSessionButton').attr("disabled", true);
				$('#showProgressButton').attr("disabled", false);
				
		    	var sessionKey = responseMap['sessionKey'];
		    	currentSessionId = responseMap['sessionId'];
		    	
		    	// Format the session key to make it easy to read
		    	var sessionKeyFormatted = sessionKey.substring(0, 3) + "-" + 
		    	sessionKey.substring(3, 6) + "-" + sessionKey.substring(6, 10) + "#";
		    	
		    	document.getElementById("message").innerHTML=responseMap;
		        document.getElementById("sessionKeyResponse").innerHTML=sessionKeyFormatted;
				$('#sessionStatus').text("Waiting for session setup, please punch the session ID");
		        
			} else {
				$('#createSessionButton').attr("disabled", false);
				$('#showProgressButton').attr("disabled", true);
				document.getElementById("message").innerHTML=responseMap;
				$('#sessionStatus').text("Error, please try again: " + callStatus);
			}
		});
	}); // End of createSession
	
	// Initiate showProgress function on click
	$("#showProgressButton").click(function showProgress(){
		// Set flag to "checkStatus" so the servlet will know what kind of action is coming
		flag = "checkStatus";
		
		$.post("PhoneSessionServlet",
		{
			flag:flag,
			sessionId:currentSessionId,
		},
		function(data){
			var responseMap = $.hpciParamMap(data);
			var callStatus = responseMap['status'];
			if(callStatus == "success") {
				
				var compCode = "";
				var tokenFlag = "";
				var sessionTaskCount = responseMap['sessionTaskCount'];
				
				for (var sessionTaskIdx = 1 ; sessionTaskIdx <= sessionTaskCount ; sessionTaskIdx++) {
			        var taskType = responseMap["sessionTask[" + sessionTaskIdx + "].type"];
			        var promptCode = responseMap["sessionTask[" + sessionTaskIdx + "].promptCode"];
			        var compCode = responseMap["sessionTask[" + sessionTaskIdx + "].completionCode"];
			        
					// Fill the values in the form
					if(taskType == "ccmapsetup" && compCode == "success" && tokenFlag == "") {
						var mappedCC = responseMap["sessionTask[" + sessionTaskIdx + "].paramValue"];
						
						// Fill the cc token into the form
						$('#ccToken').val(mappedCC);
						
						// Flag used to know that cc was verified and filled into the form
						tokenFlag = "ccTokenReturned";
					} else if(taskType == "cccvvsetup" && compCode == "success" && tokenFlag == "ccTokenReturned") {
						var mappedCVV = responseMap["sessionTask[" + sessionTaskIdx + "].respToken1"];
						
						// Fill the cvv token into the form
						$('#cvvToken').val(mappedCVV);
						
						// Flag to know both cc and cvv been verified and filled into the form
						tokenFlag = "ccAndCvvTokenReturned";
					}
				}
				var sessionStatus = responseMap['sessionStatus'];
				document.getElementById("message").innerHTML=responseMap;
				$('#sessionStatus').text(sessionStatus + " " + compCode);
				
				// Checks if cc and cvv tokens returned and validated by HPCI, if it is, no need to check progress anymore
				if(tokenFlag == "ccAndCvvTokenReturned") {
					// Enable/Disable the correct buttons
					$('#showProgressButton').attr("disabled", true);
					$('#processPaymentButton').attr("disabled", false);
				} else {
					// Enable showProgressButton, disable processPaymentButton
					$('#showProgressButton').attr("disabled", false);
					$('#processPaymentButton').attr("disabled", true);
				}
			}
		});
	});
	// processPayment function
	$('#processPaymentButton').click(function processPayment(){
		flag = "processPayment";
		// Take values from the form
		var ccToken = $('#ccToken').val();
		var cvvToken = $('#cvvToken').val();
		var cardType = $("#country option:selected").val();
		var expiryMonth = $("#expiryMonth").val();
	    var expiryYear = $("#expiryYear").val();
		var firstName = $("#firstName").val();
		var lastName = $("#lastName").val();
		var address1 = $("#address1").val();
		var address2 = $("#address2").val();
		var city = $("#city").val();
		var state = $("#state").val();
		var zip = $("#zip").val();
		var country = $("#country option:selected").val();
		var currency = $("#currency option:selected").val();
		var paymentAmount = $("#paymentAmount").val();
		var paymentComments = $("#paymentComments").val();
		var paymentReference = $("#paymentReference").val();
		var paymentProfile = $("#paymentProfile option:selected").val();

		$.post("PhoneSessionServlet",
		{
			flag: flag, ccToken: ccToken, cvvToken: cvvToken, cardType: cardType, expiryMonth: expiryMonth, 
			expiryYear: expiryYear, firstName: firstName, lastName: lastName, address1: address1, 
			address2: address2, city: city, state: state, zip: zip, country: country, currency: currency,
			paymentAmount: paymentAmount, paymentComments: paymentComments,
			paymentReference: paymentReference, paymentProfile: paymentProfile,
			
		},
		function(data){
			var responseMap = $.hpciParamMap(data);
			var callPaymentStatus = responseMap['pxyResponse.responseStatus'];
			var processorRefId = responseMap['pxyResponse.processorRefId'];
			var responseStatusCode = responseMap['pxyResponse.responseStatus.code'];
			var responseStatusMsg = responseMap['pxyResponse.responseStatus.description'];
			
			if(callPaymentStatus == "approved") {
				$('#processPaymentButton').attr("disabled", true);
				$('#paymentResetButton').attr("disabled", false);
			}
			document.getElementById("message").innerHTML=data;
			document.getElementById("paymentStatus").innerHTML=callPaymentStatus;
			document.getElementById("referenceId").innerHTML=processorRefId;
			document.getElementById("paymentResponseCode").innerHTML=responseStatusCode;
			// Replace "+" in the string with " "
			document.getElementById("paymentResponseMessage").innerHTML=responseStatusMsg.replace(/\+/g, ' ');
			
		});
	});
	$('#paymentResetButton').click(function resetPayment() {
		document.getElementById('paymentForm').reset();
		document.getElementById("paymentStatus").innerHTML="";
		document.getElementById("referenceId").innerHTML="";
		document.getElementById("paymentResponseCode").innerHTML="";
		document.getElementById("paymentResponseMessage").innerHTML="";
		document.getElementById("message").innerHTML="";
		document.getElementById("sessionKeyResponse").innerHTML="";
		document.getElementById("sessionStatus").innerHTML="";
		// Reset flag back to new page value which is "createSession"
		flag = "createSession";
		// Reset currentSessionId to default value which is ""
		currentSessionId = "";
		$('#createSessionButton').attr("disabled", false);
		$('#showProgressButton').attr("disabled", true);
		$('#resetPaymentButton').attr("disabled", true);
		
	});
});
/* $.hpciUrlParam = function(name, queryStr){
	var results = new RegExp('[\\?&]' + name + '=([^&#]*)').exec(queryStr);
	if (!results) { return 0; }
	return results[1] || 0;
}
$.hpciUrlParamStr = function(name, queryStr) {
	var results = new RegExp('[\\?&]' + name + '=([^&#]*)').exec(queryStr);
	if (!results) { return ""; }
	return results[1] || "";
}
$.hpciUrlParamArry = function(name, queryStr) {
	var results = new RegExp('[\\?&]' + name + '=([^&#]*)').exec(queryStr);
	if (!results) { return ""; }
	return results[1] || "";
} */
// Function that reads a query string and organizes it
$.hpciParamMap = function(queryStr) {
	var queryMap = [], queryToken;
    if(queryStr != undefined) {
		queryTokenList = queryStr.split('&');
		for(var i = 0; i < queryTokenList.length; i++){
			queryToken = queryTokenList[i].split('=');
			queryMap.push(queryToken[1]);
			queryMap[queryToken[0]] = queryToken[1];
		}
	}
	return queryMap;
}
</script>
<script type="text/javascript">
$(document).ready(function () {
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
<div class="container">
	<div class="row">
		<div class="col-md-7 col-centered">
			<form id="paymentForm">
				<fieldset>
					<legend>Phone Session App</legend>
					<fieldset>
						<legend>Session Information</legend>
						<div class="row">
							<div class="col-md-4">
								<button id="createSessionButton" type="button" value="Create Session" 
									class="btn btn-primary">Create Session</button><br /><br />
								<button id="showProgressButton" type="button" value="Update Progress" 
									class="btn btn-primary" disabled>Update Progress</button><br />
							</div>
							<div class="col-md-8">
								Session Key: <div id="sessionKeyResponse"></div><br />
								Session Status: <div id="sessionStatus"></div><br />
							</div>
						</div><!-- row -->
					</fieldset>
					<br />
					<fieldset>
						<legend>Credit Card Information</legend>
						<div class="row">
							<div class="col-xs-4 col-sm-3 col-md-4">
								<!-- Select credit card -->
								<label for="cardType">Card Type</label>
							</div>
						</div><!-- row -->
						<div class="row">
							<div class="col-xs-4 col-sm-3 col-md-4">
								<select id="cardType" name="cardType" class="selectpicker">
									<option value="visa">Visa</option>
									<option value="mastercard">MasterCard</option>
									<option value="amex">American Express</option>
								</select>
							</div>
						</div><!-- row -->
						<div class="row">
							<div class="col-xs-6 col-sm-5 col-md-5">
								<label>Credit Card Token</label><br />
								<input id="ccToken" type="text" name="ccToken" placeholder="Automatically Filled">
							</div>
							<div class="col-xs-6 col-sm-5 col-md-5">
								<label>CVV Token</label><br />
								<input id="cvvToken" type="text" name="cvvToken" placeholder="Automatically Filled">
							</div>
						</div><!-- row -->
						<br />
						<div class="row">
							<div class="col-xs-5 col-sm-4 col-md-4">
								<label>Expiry MM/YY</label>
							</div>
						</div><!-- row -->
						<div class="row">
							<div class="col-xs-5 col-sm-3 col-md-3">
								<select id="expiryMonth" name="expiryMonth" class="selectpicker">
									<option value="01">01 - January</option>
									<option value="02">02 - February</option>
									<option value="03">03 - March</option>
									<option value="04">04 - April</option>
									<option value="05">05 - May</option>
									<option value="06">06 - June</option>
									<option value="07">07 - July</option>
									<option value="08">08 - August</option>
									<option value="09">09 - September</option>
									<option value="10">10 - October</option>
									<option value="11">11 - November</option>
									<option value="12">12 - December</option>
								</select>
							</div>
							<div class="col-xs-2 col-sm-2 col-md-2">		
								<!-- id is used in confirmation.jsp -->
								<select id="expiryYear" name="expiryYear" class="selectpicker">
									<option value="15">2015</option>
									<option value="16">2016</option>
									<option value="17">2017</option>
									<option value="18">2018</option>
									<option value="19">2019</option>
									<option value="20">2020</option>
									<option value="21">2021</option>
									<option value="22">2022</option>
									<option value="23">2023</option>
									<option value="24">2024</option>
									<option value="25">2025</option>
									<option value="26">2026</option>
								</select>
							</div>
						</div><!-- row -->
					</fieldset>
					<br />
					<fieldset>
						<legend>Personal Information</legend>
						<div class="row">
							<div class="col-xs-4 col-sm-3 col-md-4">
								<label>First Name:</label>
							</div>
							<div class="col-xs-4 col-sm-3 col-md-5">
								<input id="firstName" type="text" name="firstName">
							</div>
						</div><!-- row -->
						<div class="row">
							<div class="col-xs-4 col-sm-3 col-md-4">
								<label>Last Name:</label>
							</div>
							<div class="col-xs-4 col-sm-3 col-md-5">
								<input id="lastName" type="text" name="lastName">
							</div>
						</div><!-- row -->
						<div class="row">
							<div class="col-xs-4 col-sm-3 col-md-4">
								<label>Address Line 1:</label>
							</div>
							<div class="col-xs-4 col-sm-3 col-md-5">
								<input id="address1" type="text" name="address1">
							</div>
						</div><!-- row -->
						<div class="row">
							<div class="col-xs-4 col-sm-3 col-md-4">
								<label>Address Line 2:</label>
							</div>
							<div class="col-xs-4 col-sm-3 col-md-5">
								<input id="address2" type="text" name="address2">
							</div>
						</div><!-- row -->
						<div class="row">
							<div class="col-xs-4 col-sm-3 col-md-4">
								<label>City:</label>
							</div>
							<div class="col-xs-4 col-sm-3 col-md-5">
								<input id="city" type="text" name="city">
							</div>
						</div><!-- row -->
						<div class="row">
							<div class="col-xs-4 col-sm-3 col-md-4">
								<label>State / Province:</label>
							</div>
							<div class="col-xs-4 col-sm-3 col-md-5">
								<input id="state" type="text" name="state">
							</div>
						</div><!-- row -->
						<div class="row">
							<div class="col-xs-4 col-sm-3 col-md-4">
								<label>Zip / Postal Code:</label>
							</div>
							<div class="col-xs-4 col-sm-3 col-md-5">
								<input id="zip" type="text" name="zip">
							</div>
						</div><!-- row -->
						<div class="row">
							<div class="col-xs-4 col-sm-3 col-md-4">
								<label>Country:</label>
							</div>
							<div class="col-xs-4 col-sm-3 col-md-5">
								<select id="country" name="country">
									<option value="CAN">Canada</option>
									<option value="US">United States</option>
								</select>
							</div>
						</div><!-- row -->
						<div class="row">
							<div class="col-xs-4 col-sm-3 col-md-4">
								<label>Payment Comments:</label>
							</div>
							<div class="col-xs-4 col-sm-3 col-md-5">
								<input id="paymentComments" type="text" name="paymentComments">
							</div>
						</div><!-- row -->
						<div class="row">
							<div class="col-xs-4 col-sm-3 col-md-4">
								<label>Payment Reference:</label>
							</div>
							<div class="col-xs-4 col-sm-3 col-md-5">
								<input id="paymentReference" type="text" name="paymentReference">
							</div>
						</div><!-- row -->
						<div class="row">
							<div class="col-xs-4 col-sm-3 col-md-4">
								<label>Currency:</label>
							</div>
							<div class="col-xs-4 col-sm-3 col-md-5">
								<select id="currency" name="currency">
									<option value="CAD">Canadian Dollar</option>
									<option value="USD">US Dollar</option>
								</select>
							</div>
						</div><!-- row -->
						<div class="row">
							<div class="col-xs-4 col-sm-3 col-md-4">
								<label>Payment Amount:</label>
							</div>
							<div class="col-xs-4 col-sm-3 col-md-5">
								<input id="paymentAmount" type="text" name="PaymentAmount">
							</div>
						</div><!-- row -->
						<div class="row">
							<div class="col-xs-4 col-sm-3 col-md-4">
								<label>Payment Profile:</label>
							</div>
							<div class="col-xs-4 col-sm-3 col-md-5">
								<select id="paymentProfile" name="paymentProfile">
									<option value="DEF">DEF - Currency: CAD</option>
									<option value="DEF_MONERIS">DEF_MONERIS - Currency: CAD</option>
									<option value="DEF_MONERIS">DEF_MONERIS - Currency: USD</option>
								</select>
							</div>
						</div><!-- row -->
						<div class="row">
							<div class="col-xs-6 col-sm-3 col-md-4">
								<button id="processPaymentButton" type="button" value="Process Payment" 
									class="btn btn-primary" disabled>Process Payment</button><br />
							</div>
							<div class="col-xs-6 col-sm-3 col-md-4">
								<button id="paymentResetButton" type="button" value="Reset Payment" 
									class="btn btn-primary" disabled>Reset Payment</button><br />
							</div>
						</div><!-- row -->
						<br />
						<div class="row">
							<div class="col-xs-6 col-sm-3 col-md-4">
								<button Type="button" class="btn btn-primary" value="Back" 
									onClick="location.assign('home.jsp');">Back</button>
							</div>
						</div><!-- row -->
					</fieldset>
					<br />
					<fieldset>
						<legend>Response</legend>
						<div class="row">
							<div class="col-md-8">
								<label>Payment Status: </label>
								<div id="paymentStatus" style="word-wrap: break-word;"></div><br />
							</div>	
						</div><!-- row -->
						<div class="row">
							<div class="col-md-8">
								<label>Reference ID: </label>
								<div id="referenceId" style="word-wrap: break-word;"></div><br />
							</div>	
						</div><!-- row -->
						<div class="row">
							<div class="col-md-8">
								<label>Response Code: </label>
								<div id="paymentResponseCode" style="word-wrap: break-word;"></div><br />
							</div>	
						</div><!-- row -->
						<div class="row">
							<div class="col-md-8">
								<label>Response Message: </label>
								<div id="paymentResponseMessage" style="word-wrap: break-word;"></div><br />
							</div>	
						</div><!-- row -->
						<div class="row">
							<div class="col-md-12">
								<label>Show Full Message?</label><br />
								<input id="noButton" type="radio" name="radioButton" checked />No
								<input id="yesButton" type="radio" name="radioButton" />Yes
								<br />
								<label>Full Message: </label><br />
								<div id="message">
								</div><br />
							</div>	
						</div><!-- row -->
					</fieldset>
				</fieldset><!-- Outer fieldset -->
			</form>
		</div><!-- col-md-7 col-centered -->
	</div><!-- row -->
</div><!-- container -->
</body>
</html>