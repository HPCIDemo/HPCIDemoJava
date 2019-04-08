<html>
<head>
<meta charset="utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport" content="width=device-width, initial-scale=1">

<title>HostedPCI Demo App CvvOnly iFrame</title>
<!-- Bootstrap -->
<link href="https://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap.min.css" rel="stylesheet">
<link href="https://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap-theme.min.css" rel="stylesheet">

<!-- Font-Awesome -->
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/font-awesome/4.4.0/css/font-awesome.min.css">

<link href="css/checkout.css" rel="stylesheet">

<script src="js/jquery-2.1.1.js" type="text/javascript" charset="utf-8"></script>
<script src="https://ccframe.hostedpci.com/WBSStatic/site60/proxy/js/jquery.ba-postmessage.2.0.0.min.js" type="text/javascript" charset="utf-8"></script>
<script src="https://ccframe.hostedpci.com/WBSStatic/site60/proxy/js/hpci-cciframe-1.0.js" type="text/javascript" charset="utf-8"></script>
<script>
	var hpciCCFrameHost;
	var hpciCCFrameName = "ccframe"; // use the name of the frame containing the credit card
	var hpciCCFrameFullUrl;
	var cvvOnlyLocationName;
	//Notify when the tokenization process is finished.
	var deferredCC;
	
	var hpciSiteErrorHandler = function(errorCode, errorMsg) {
		// Please the following alert to properly display the error message
		//alert("Error while processing credit card code:" + errorCode + "; msg:"	+ errorMsg);
		console.log("=================Begin hpciSiteErrorHandler=================");
		document.getElementById('errorMessage').style.display = 'block';
		
		console.log("=================End hpciSiteErrorHandler=================");
		if(deferredCC.state() == 'pending')
			return deferredCC.reject();
	}

	var hpciSiteSuccessHandlerV5 = function(hpciMappedCCValue, hpciMappedCVVValue, hpciCCBINValue, 
			hpciGtyTokenValue, hpciCCLast4Value, hpciReportedFormFieldsObj, 
			hpciGtyTokenAuthRespValue, hpciTokenRespEncrypt) {

		console.log("=================Begin hpciSiteSuccessHandlerV5=================");
		// Please pass the values to the document input and then submit the form
		
		// No errors from iframe so hide the errorMessage div
		document.getElementById('errorMessage').style.display = 'none';
		// Name of the input (hidden) field required by ecommerce site
		// Typically this is a hidden input field.
		var ccNumInput = document.getElementById("ccNum");
		ccNumInput.value = hpciMappedCCValue;

		// Name of the input (hidden) field required by ecommerce site
		// Typically this is a hidden input field.
		var ccCVVInput = document.getElementById("ccCVV");
		ccCVVInput.value = hpciMappedCVVValue;

		// Name of the input (hidden) field required by ecommerce site
		// Typically this is a hidden input field.
		var ccBINInput = document.getElementById("ccBIN");
		ccBINInput.value = hpciCCBINValue;

		if(deferredCC.state() == 'pending')
			deferredCC.resolve();

		console.log("=================End hpciSiteSuccessHandlerV5=================");
		
		return false;
	}

	var hpci3DSitePINSuccessHandler = function() {
		
	}

	var hpci3DSitePINErrorHandler = function() {
		// Adapt the following message / action to match your required experience
		//alert("Could not verify PIN for the credit card");
	}

	var hpciCCPreliminarySuccessHandler = function(hpciCCTypeValue, hpciCCBINValue, hpciCCValidValue, hpciCCLengthValue) {
		// Adapt the following message / action to match your required experience
		//alert("Received preliminary credit card details");
	}

	var hpciCVVPreliminarySuccessHandler = function(hpciCVVLengthValue) {
		// Adapt the following message / action to match your required experience
		//alert("Received preliminary CVV details");
	}

	var hpciCCDigitsSuccessHandlerV2 = function(hpciCCTypeValue, hpciCCBINValue, hpciCCValidValue, hpciCCLengthValue, hpciCCEnteredLengthValue) {
		console.log("================ Begin hpciCCDigitsSuccessHandlerV2================");
		// Use to enable credit card digits key press
		sendHPCIChangeClassMsg("ccNum-wrapper", "input-text input-text--validatable");
		
		if(hpciCCValidValue == "Y") {
			sendHPCIChangeClassMsg("ccNum", "input-text__input input-text__input--populated");
		} else if(hpciCCValidValue == "N" && hpciCCLengthValue == "0") {
			if(hpciCCEnteredLengthValue > "0") {
				sendHPCIChangeClassMsg("ccNum", "input-text__input input-text__input--invalid input-text__input--populated");
			} 
			else {
				sendHPCIChangeClassMsg("ccNum", "input-text__input");
			}
		} else if(hpciCCValidValue == "N" && hpciCCLengthValue > "0" && hpciCCEnteredLengthValue > "0") {
			sendHPCIChangeClassMsg("ccNum", "input-text__input input-text__input--invalid input-text__input--populated");
		} 
		
		// Display the card type icon on keypress
		if(hpciCCTypeValue == "visa") {
			document.getElementById("visa").className = "fa fa-cc-visa active";
		} else if(hpciCCTypeValue == "mastercard") {
			document.getElementById("mastercard").className = "fa fa-cc-mastercard active";
		} else if(hpciCCTypeValue == "amex") {
			document.getElementById("amex").className = "fa fa-cc-amex active";
		} else if(hpciCCTypeValue == "discover") {
			document.getElementById("discover").className = "fa fa-cc-discover active";
		} else if(hpciCCTypeValue == "jcb") {
			document.getElementById("jcb").className = "fa fa-cc-jcb active";
		} else {
			document.getElementById("visa").className = "fa fa-cc-visa";
			document.getElementById("mastercard").className = "fa fa-cc-mastercard";
			document.getElementById("amex").className = "fa fa-cc-amex";
			document.getElementById("discover").className = "fa fa-cc-discover";
			document.getElementById("jcb").className = "fa fa-cc-jcb";
		}
		
		// Custom validation to only accept certain card types
		if(hpciCCTypeValue == "visa" || hpciCCTypeValue == "mastercard" || hpciCCTypeValue == "na") {
			document.getElementById("submitButton").disabled = false;
			document.getElementById("errorMessage2").style.display = "none";
		} else {
			document.getElementById("submitButton").disabled = true;
			document.getElementById("errorMessage2").style.display = "block";
		}
		console.log("=================End hpciCCDigitsSuccessHandlerV2==================");
	}
	
	var hpciCVVDigitsSuccessHandler = function(hpciCVVDigitsValue, hpciCVVValidValue) {
		console.log("=================Begin hpciCVVDigitsSuccessHandler===========");
		// Use to enable CVV digits key press
		sendHPCIChangeClassMsg("ccCVV-wrapper", "input-text input-text--validatable");
		
		var cvvLength = Number(hpciCVVDigitsValue);
		if((cvvLength < 3) || (cvvLength > 4)) {
			if (cvvLength == 0) {
				sendHPCIChangeClassMsg("ccCVV", "input-text__input");
			}else{
				sendHPCIChangeClassMsg("ccCVV", "input-text__input input-text__input--invalid input-text__input--populated");
			}
		} else if ((cvvLength >= 3) && (cvvLength <= 4)) {
			sendHPCIChangeClassMsg("ccCVV", "input-text__input input-text__input--populated");
		}
		
		console.log("=================End hpciCVVDigitsSuccessHandler=============");
	}
	
	function parseQueryString(data, split, separator) {
		//parse the result
		var resultMap = [], queryToken;

		queryTokenList = data.split(split);
		for (var i = 0; i < queryTokenList.length; i++) {
			queryToken = queryTokenList[i].split(separator);
			resultMap.push(queryToken[1]);
			resultMap[queryToken[0]] = queryToken[1];
		}

		return resultMap;
	}
	
</script>
<script type="text/javascript">
jQuery(document).ready(function() {	
	var siteId;
    var locationName;
    var fullParentQStr;
    var fullParentHost;
    var currency;
    var paymentProfile;
    var flag = "config";
    var ccNum;
    
    jQuery(document).ajaxSend(function(event, request, settings) {
		jQuery('#modal').show();
	});
    jQuery(document).ajaxComplete(function(event, request, settings) {
		jQuery('#modal').hide();
	});
    
    jQuery.get("CvvOnlyServlet",
    	    {
    			flag:flag,
    		},
    		function(data){
    			//parse the result
    			var resultMap = parseQueryString(data, ',', ';');
    		    
    			siteId = resultMap["sid"];
    			locationName = resultMap["locationName"]; 
    			cvvOnlyLocationName = resultMap["cvvOnlyLocationName"];
    			fullParentQStr = location.pathname;
    			fullParentHost = location.protocol.concat("//") + window.location.hostname + (location.port ? ':' + location.port: '');
    			hpciCCFrameHost = resultMap["serviceUrl"];
    			currency = resultMap["currency"];
    			//Setting currency drop-down list options
    			if(currency){
    				var currencyCombo = document.getElementById("currency");    				  				
    				queryTokenList = currency.split('/');
    				for(var i = 0; i < queryTokenList.length; i++){
    					var optionCurrency = document.createElement('option');  
    					queryToken = queryTokenList[i].split('=');
   						optionCurrency.value = queryToken[1];
   						optionCurrency.text = queryToken[0];
   						currencyCombo.add(optionCurrency, 0);	
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
    			ccNum = resultMap["ccNum"];
    			if(ccNum){    				
    				queryTokenList = ccNum.split('/');
    				queryToken = queryTokenList[0].split('=');
    				jQuery('#ccNum').val(queryToken[0]);
    				jQuery('#ccButtonLabel').html(queryToken[0]);
    				jQuery('#ccCVV').val(queryToken[1]);
    			}
    			console.log(fullParentHost);
    			console.log(location.pathname);
    			console.log("SiteId :" + siteId);
    			console.log("LocationName :" + locationName);
    			console.log("CvvOnlyLocationName :" + cvvOnlyLocationName);
    			console.log("Currency:" + currency);
    			console.log("Payment Profiles:" + paymentProfile);
    			console.log("CC number: " + ccNum);
    			
    			//Set cvvonly iframe 
			hpciCCFrameFullUrl = hpciCCFrameHost + "/iSynSApp/showPxyPage!ccFrame.action?pgmode1=prod&"
		    +"locationName=" + cvvOnlyLocationName 
		    +"&sid=" + siteId
		    +"&ccNumToken=" + jQuery('#ccNum').val()
		    +"&reportCCType=Y&reportCCDigits=Y&reportCVVDigits=Y"
		    +"&ccNumTokenIdx=" + (1)
		    +"&enableTokenDisplay=Y"
		    +"&fullParentHost=" + fullParentHost
		    +"&fullParentQStr=" + fullParentQStr;
			document.getElementById("ccframe").src=hpciCCFrameFullUrl;  
			
			console.log("hpciCCFrameFullUrl:\n" + hpciCCFrameFullUrl);
    			
    		});
    
    jQuery("#submitButton").click(function(){	
		var 	 merchantRefId = jQuery("#merchantRefId").val();
		deferredCC = jQuery.Deferred();
		
		deferredCC.done(
				function() {
					jQuery.post(
							"CvvOnlyServlet",
							{
								"ccNum" : jQuery("#ccNum").val(),
								"ccCVV" : jQuery("#ccCVV").val(),
								"amount" : jQuery("#amount").val(),
								"merchantRefId" : merchantRefId,
								"currency" : jQuery("#currency").val(),
								"paymentProfile" : jQuery("#paymentProfile").val() ,
								"expiryMonth" : jQuery("#expiryMonth").val(),
								"expiryYear" : jQuery("#expiryYear").val()
							},
							function(data) {
								//parse the result
								var resultMap = parseQueryString(decodeURIComponent(data.replace(/\+/g,  " ")), '&', '=');
								jQuery('#checkout').hide();
								jQuery('#trSummary').show();
								jQuery('#submitButton').attr("disabled", true);
								if (data != undefined) {
									 jQuery("#result").html(
										 "Status: " + resultMap["status"] + "<br/>"
										 + "Description: " + resultMap["pxyResponse.responseStatus.description"] + "<br/>"
										 + "Processor Reference ID: " + resultMap["pxyResponse.processorRefId"] + "<br/>"
										 + "Token Card Number: " + jQuery("#ccNum").val() + "<br/>"
										 + "Token CVV Number: " + jQuery("#ccCVV").val() + "<br/>"
										 + "Amount: " + jQuery("#amount").val() + "<br/>");
									jQuery("#message").html("Full Message: " + "<br/>" 
											+ decodeURIComponent(data));
								}
							});
				}).fail(
				function() {
					console.log("Error tokenizing cc number");
				});
		
		sendHPCIMsg();
	});
    
	jQuery('#paymentResetButton').click(function resetPayment() {
		location.reload(true);
	});	
	
	jQuery('#backBtn').click(function () {
		location.reload(true);
	});
	
	jQuery("#toggleMessage").click(function() {
		jQuery("#message").toggle("slow");
		jQuery(this).val(jQuery(this).val() == "Show response" ? "Hide response" : "Show response");
	}); 
	
	jQuery('input:text').on('blur', function(){
		if (jQuery(this).val() ) { 
			jQuery(this).attr("class", "input-text__input input-text__input--populated");
		} else {
			jQuery(this).attr("class", "");
		};
	});
});
</script>
</head>
<body>
<!-- container class sets the page to use 100% width -->
<div class="container">
	<!-- form-group class sets the margins on the sides -->
	<div id = "modal" style="display: none">
		<div id = "loader"></div>
	</div>
	<div class="form-group">
		<!-- col-md-7 col-centered class uses the bootstrap grid system to use 7/12 of the screen and place it in the middle -->
		<div class="col-md-7 col-centered">
			<div class="demo-navbar">
				<div class="row">
					<ul>
						<li><a href="home.jsp">Home</a></li>
						<li><a id = "hostedPCI" href="http://www.hostedpci.com/"></a></li>
					</ul>
				</div>
			</div>
			<!-- IMPORTANT: id CCAcceptForm needs to match the ID's in the HostedPCI script code -->
			<!-- So if you change this ID, make sure to change it in all other places -->
			<!-- Action points to the servlet -->
			<form id="CCAcceptForm" action="/IframeServlet" method="post" class="form-horizontal">
				<fieldset id = "checkout">
					<!-- Form Name -->
					<legend>Web Checkout</legend>
					<fieldset>
						<legend>Credit Card Information</legend>
						<!-- Error message for invalid credit card -->
						<div id="errorMessage" style="display:none;color:red"><label>Invalid card number, try again</label><br/></div>
						<div id="errorMessage2" style="display:none;color:red"><label>We only accept Visa and MasterCard!</label><br/></div>
						<div class="booking-form__field form-group">
							<div class="col-xs-8 col-sm-6 col-md-8">
								<label>Select credit card:</label><br/>
								<input id = "creditButton" type = "radio" name="creditButton" checked/>
								<label id = "ccButtonLabel" for = "creditButton"></label>
							</div>
						</div>							
						<div class="input-group">
							<iframe seamless id="ccframe" name="ccframe"
									onload="receiveHPCIMsg()"
									src=""
									style="border: none; max-width: 800px; min-width: 400px; width: 100%"
									height="100"> If you can see this, your browser
												doesn't understand IFRAME. 
							</iframe>					
						</div>
						<!-- Input form-group (exp, month, cvv) -->
						<div class="form-group">
							<!-- <div class="col-xs-5 col-sm-4 col-md-4">
									<label>Expiry MM/YY</label>
									id is used in confirmation.jsp
							</div> -->
						</div><!-- form-group -->
						<div class="booking-form__field">
							<label>Expiry date</label>
				    	</div>
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
								<input id="comment" type="text" name="comment">
								<label for="comment">
								Comments
								</label>
							</div>
						</div>
						<div class="booking-form__field">
							<div class="input-text">
								<input id="merchantRefId" type="text" name="merchantRefId">
								<label for="merchantRefId">
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
								<input id="amount" type="text" name="amount">
								<label for="amount">
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
								<!-- Submit button -->
								<button type="button" id="submitButton" class="btn btn-primary">Process Payment</button>
							</div>	
							<div class="col-xs-6 col-sm-3 col-md-4">
								<!-- Reset button -->
								<button id="paymentResetButton" type="button" value="Reset Payment" class="btn btn-primary">Reset Payment</button><br />
							</div>
						</div>
						<br />
						<div class="form-group">
							<!-- Hidden form-groups that are required by the iframe -->
							<div class="col-xs-6 col-sm-3 col-md-4">
								<input type="hidden" id="ccNum" name="ccNum" value="" class="form-control"> 
								<input type="hidden" id="ccCVV" name="ccCVV" value="" class="form-control"> 
								<input type="hidden" id="ccBIN" name="ccBIN" value="" class="form-control">
							</div>
						</div>
					</fieldset>	
				</fieldset><!-- Outer fieldset -->
				<fieldset id="trSummary">
					<legend>Transaction Summary</legend>					
					<div id = "result">
					</div>
					<br/>
					<input type="button" id="toggleMessage" value="Show response" class="btn">
					<div id = "message" style="word-wrap: break-word;">
					</div><br/><br/>
					<br /> <input Type="button"  id = "backBtn" class="btn btn-primary" value="Back"></input><br />					
				</fieldset>
			</form>		
		</div><!-- col-md-7 col-centered -->
	</div><!-- form-group -->
</div><!-- container -->
</body>
</html>