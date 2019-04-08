<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE HTML>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Hosted PCI Demo App Phone Session</title>
<!-- Bootstrap -->
<link href="https://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap.min.css" rel="stylesheet">
<link href="https://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap-theme.min.css" rel="stylesheet">
<link href="css/template.css" rel="stylesheet">
<script src="js/jquery-2.1.1.js" type="text/javascript"></script>
<script type="text/javascript">
$(document).ready(function(event){
	
	// Initial value for flag is createSession, meaning it's a fresh page load and only possible action is createSession
	var flag = "createSession";
	var currentSessionId = "";	
	
	jQuery.get("PhoneSessionServlet",
    	    {
    			flag:"config",
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
    			currency = resultMap["currency"];
    			//Setting currency drop-down list options
    			if(currency){
    				var currencyCombo = document.getElementById("currency");    				  				
    				queryTokenList = currency.split('/');
    				for(var i = 0; i < queryTokenList.length; i++){
    					var option = document.createElement('option');  
    					queryToken = queryTokenList[i].split('=');
   						option.value = queryToken[1];
   						option.text = queryToken[0];
   						currencyCombo.add(option, 0);	
    				}
    			}
    			//Setting Payment Profile drop-down list options
    			paymentProfile= resultMap["paymentProfile"];
    			if(paymentProfile){    				
    				var paymentProfileCombo = document.getElementById("paymentProfile");    				  				
    				queryTokenList = paymentProfile.split('/');
    				for(var i = 0; i < queryTokenList.length; i++){
    					var optionPaymentProfile = document.createElement('option');  
    					queryToken = queryTokenList[i].split('=');
   						optionPaymentProfile.value = queryToken[1];
   						optionPaymentProfile.text = queryToken[0];
   						paymentProfileCombo.add(optionPaymentProfile, 0);	
    				}
    			}    			
    			console.log("Currency:" +currency);
    			console.log("Payment Profiles:" +paymentProfile);    			
    		});
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
						$('#ccToken').blur();
						
						// Flag used to know that cc was verified and filled into the form
						tokenFlag = "ccTokenReturned";
					} else if(taskType == "cccvvsetup" && compCode == "success" && tokenFlag == "ccTokenReturned") {
						var mappedCVV = responseMap["sessionTask[" + sessionTaskIdx + "].respToken1"];
						
						// Fill the cvv token into the form
						$('#cvvToken').val(mappedCVV);
						$('#cvvToken').blur();
						
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
	
	$("input:text").on("blur", function(){
		if (jQuery(this).val() ) { 
			jQuery(this).attr("class", "input-text__input input-text__input--populated");
		} else {
			jQuery(this).attr("class", "");
		};
	});
});
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
	$("#toggleMessage").click(function() {
		$("#message").toggle("slow");
		$(this).val($(this).val() == "Show message" ? "Hide message" : "Show message");
	});
});
</script>
</head>
<body>
<div class="container">
		<div class="col-md-7 col-centered">
			<div class="demo-navbar">
				<div class="row">
					<ul>
						<li><a href="home.jsp">Home</a></li>
						<li><a id = "hostedPCI" href="http://www.hostedpci.com/"></a></li>
					</ul>
				</div>
			</div>
			<form id="paymentForm">
				<fieldset>
					<legend>Phone Session App</legend>
					<fieldset>
						<legend>Session Information</legend>
						<div class="form-group session-group">
							<div class="col-xs-4 col-sm-3 col-md-4">
								<button id="createSessionButton" type="button" value="Create Session" 
									class="btn btn-primary">Create Session</button>
								
							</div>
							<div class="col-xs-4 col-sm-3 col-md-5">
								Session Key:<div id="sessionKeyResponse"></div>
							</div>
							
							<div class="clearfix visible-xs-block visible-sm-block visible-md-block visible-lg-block"></div>
							<br>
							<div class="col-xs-4 col-sm-3 col-md-4">
								<button id="showProgressButton" type="button" value="Update Progress" 
									class="btn btn-primary" disabled>Update Progress</button>
							</div>
							<div class="col-xs-4 col-sm-3 col-md-5">
								Session Status: <div id="sessionStatus"></div><br />
							</div>
						</div><!-- row -->
					</fieldset>
					<br />
					<fieldset>
						<legend>Credit Card Information</legend>
						<div class="booking-form__field form-group">
							<div class="col-xs-4 col-sm-3 col-md-4">
								<!-- Select credit card -->
								<label for="cardType">Card Type</label>
							</div>
							<div class="col-xs-4 col-sm-3 col-md-5">
								<select id="cardType" name="cardType" class="selectpicker">
									<option value="visa">Visa</option>
									<option value="mastercard">MasterCard</option>
									<option value="amex">American Express</option>
								</select>
							</div>
						</div><!-- row -->
						<div class="booking-form__field">
							<div class="input-text">
								<input id="ccToken" type="text" name="ccToken">
								<label for="ccToken">
								Credit Card Token
								</label>
							</div>
						</div>
						<div class="booking-form__field">
							<div class="input-text">
								<input id="cvvToken" type="text" name="cvvToken">
								<label for="cvvToken">
								CVV Token
								</label>
							</div>
						</div>
						<div class="booking-form__field">
							<label>Expiry date</label>
					    </div>
					    <div>
							<div class="col-xs-4 col-sm-3 col-md-2">
								<div class="booking-form__field">
									<div class="input-text">
										<input id="expiryMonth" type="text" name="expiryMonth">
										<label for="expiryMonth">
										Month
										</label>
									</div>
								</div>
							</div>
							<div class="col-xs-4 col-sm-3 col-md-2">
								<div class="booking-form__field">
									<div class="input-text">
										<input id="expiryYear" type="text" name="expiryYear">
										<label for="expiryYear">
										Year
										</label>
									</div>
								</div>
							</div>
						</div>						
					</fieldset>
					<br />
					<fieldset>
						<legend>Personal Information</legend>
						<div class="booking-form__field">
							<div class="input-text">
								<input id="firstName" type="text" name="firstName">
								<label for="firstName">
								First Name
								</label>
							</div>
						</div>
						<div class="booking-form__field">
							<div class="input-text">
								<input id="lastName" type="text" name="lastName">
								<label for="lastName">
								Last Name
								</label>
							</div>
						</div>
						<div class="booking-form__field">
							<div class="input-text">
								<input id="address1" type="text" name="address1">
								<label for="address1">
								Address Line 1
								</label>
							</div>
						</div>
						<div class="booking-form__field">
							<div class="input-text">
								<input id="address2" type="text" name="address2">
								<label for="address2">
								Address Line 2
								</label>
							</div>
						</div>
						<div class="booking-form__field">
							<div class="input-text">
								<input id="city" type="text" name="city">
								<label for="city">
								City
								</label>
							</div>
						</div>
						<div class="booking-form__field">
							<div class="input-text">
								<input id="state" type="text" name="state">
								<label for="state">
								State / Province
								</label>
							</div>
						</div>
						<div class="booking-form__field">
							<div class="input-text">
								<input id="zip" type="text" name="zip">
								<label for="zip">
								Zip / Postal Code
								</label>
							</div>
						</div>
						<div class="booking-form__field form-group">
							<div class="col-xs-4 col-sm-3 col-md-4">
								<label>Country:</label>
							</div>
							<div class="col-xs-4 col-sm-3 col-md-5">
								<select id="country" name="country">
									<option value="CAN">Canada</option>
									<option value="US">United States</option>
								</select>
							</div>
						</div>
						<div class="booking-form__field">
							<div class="input-text">
								<input id="paymentComments" type="text" name=paymentComments>
								<label for="paymentComments">
								Comments
								</label>
							</div>
						</div>
						<div class="booking-form__field">
							<div class="input-text">
								<input id="paymentReference" type="text" name="paymentReference">
								<label for="paymentReference">
								Merchant Reference
								</label>
							</div>
						</div>
						<div class="booking-form__field form-group">
							<div class="col-xs-4 col-sm-3 col-md-4">
								<label>Currency:</label>
							</div>
							<div class="col-xs-4 col-sm-3 col-md-5">
								<select id="currency" name="currency">									
								</select>
							</div>
						</div>
						<div class="booking-form__field">
							<div class="input-text">
								<input id="paymentAmount" type="text" name="paymentAmount">
								<label for="paymentAmount">
								Payment Amount
								</label>
							</div>
						</div>
						<div class="booking-form__field form-group">
							<div class="col-xs-4 col-sm-3 col-md-4">
								<label>Payment Profile:</label>
							</div>
							<div class="col-xs-4 col-sm-3 col-md-5">
								<select id="paymentProfile" name="paymentProfile">									
								</select>
							</div>
						</div>
						<div class="form-group">
							<div class="col-xs-6 col-sm-3 col-md-4">
								<button id="processPaymentButton" type="button" value="Process Payment" 
									class="btn btn-primary" disabled>Process Payment</button><br />
							</div>
							<div class="col-xs-6 col-sm-3 col-md-4">
								<button id="paymentResetButton" type="button" value="Reset Payment" 
									class="btn btn-primary" disabled>Reset Payment</button><br />
							</div>
						</div><!-- row -->
					</fieldset>
					<br />
					<fieldset>
						<legend>Response</legend>
						<div class="form-group">
							<div class="col-md-8">
								<label>Payment Status: </label>
								<div id="paymentStatus" style="word-wrap: break-word;"></div><br />
							</div>	
						</div><!-- row -->
						<div class="form-group">
							<div class="col-md-8">
								<label>Reference ID: </label>
								<div id="referenceId" style="word-wrap: break-word;"></div><br />
							</div>	
						</div><!-- row -->
						<div class="form-group">
							<div class="col-md-8">
								<label>Response Code: </label>
								<div id="paymentResponseCode" style="word-wrap: break-word;"></div><br />
							</div>	
						</div><!-- row -->
						<div class="form-group">
							<div class="col-md-8">
								<label>Response Message: </label>
								<div id="paymentResponseMessage" style="word-wrap: break-word;"></div><br />
							</div>	
						</div><!-- row -->
						<div class="form-group">
							<div class="col-md-12">
								<input type="button" id="toggleMessage" value="Show message" class="btn">
								<div id="message">
								</div><br />
							</div>	
						</div><!-- row -->
					</fieldset>
				</fieldset><!-- Outer fieldset -->
			</form>
		</div><!-- col-md-7 col-centered -->
</div><!-- container -->
</body>
</html>