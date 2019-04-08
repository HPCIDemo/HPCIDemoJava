<html>
<head>
<meta charset="utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport" content="width=device-width, initial-scale=1">

<title>HostedPCI Demo App Autofill Payment</title>
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
	
	var hpciSiteErrorHandler = function(errorCode, errorMsg) {
		// Please the following alert to properly display the error message
		//alert("Error while processing credit card code:" + errorCode + "; msg:"	+ errorMsg);
		console.log("=================Begin hpciSiteErrorHandler=================");
		document.getElementById('errorMessage').style.display = 'block';
		if(errorCode == "MCC_1"){
			console.error("%cErrorCode: " + errorCode + "  \nErrorMsg: " + errorMsg, "font-size: larger");
			sendHPCIChangeTextMsg("ccErrorText", "Error code: " + errorCode);
			sendHPCIChangeStyleMsg("ccErrorText", "display", "block");			
		}
		if(errorCode == "MCC_2"){			
			console.error("%cErrorCode: " + errorCode + " \n ErrorMsg: " + errorMsg, "font-size: larger");
			sendHPCIChangeTextMsg("cvvErrorText", errorMsg);
			sendHPCIChangeStyleMsg("cvvErrorText", "display", "block");
		}
		console.log("=================End hpciSiteErrorHandler=================");
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

		// Get first name last name from the iframe
		var frameFirstName = "";
		var frameLastName = "";
		var frameFullName = hpciReportedFormFieldsObj.holderName;
		console.log("Reported name on card from the iframe : " + frameFullName);
		if (frameFullName != null && frameFullName != "") {
			var spaceIdx = frameFullName.indexOf(" ");
			if (spaceIdx >= 0) {
			   frameFirstName = frameFullName.substring(0, spaceIdx);
			   frameLastName = frameFullName.substring(spaceIdx + 1);
			}
			else {
			   frameFirstName = frameFullName;
			}
		}

		var firstNameInput = document.getElementById("firstName");
		firstNameInput.value = frameFirstName;
		
		var lastNameInput = document.getElementById("lastName");
		lastNameInput.value = frameLastName;
		
		//Get month
		var reportedExpMonth = hpciReportedFormFieldsObj.expiryMonth;
		var expMonthInput = document.getElementById("expiryMonth");
		if(reportedExpMonth != null && reportedExpMonth != "") {
			console.log("Reported expiry month from the iframe: " + reportedExpMonth);
			expMonthInput.value = reportedExpMonth;
		} else{
			reportedExpMonth = "";
		}

		//Get year
		var reportedExpYear = hpciReportedFormFieldsObj.expiryYear;	
		var expYearInput = document.getElementById("expiryYear")
		if(reportedExpYear != null && reportedExpYear != "") {
			console.log("Reported expiry year from the iframe: "  + reportedExpYear);
			expYearInput.value = reportedExpYear;
		}
		
		// Name of the form submission for ecommerce site
		var pendingForm = document.getElementById("CCAcceptForm");
		
		console.log("=================End hpciSiteSuccessHandlerV5=================");

		pendingForm.submit();
	}

	var hpci3DSitePINSuccessHandler = function() {
		// name of the form submission for ecommerce site
		var pendingForm = document.getElementById("CCAcceptForm");
		pendingForm.submit();
	}

	var hpci3DSitePINErrorHandler = function() {
		// Adapt the following message / action to match your required experience
		//alert("Could not verify PIN for the credit card");
	}

	var hpciCCPreliminarySuccessHandlerV4 = function(hpciCCTypeValue, hpciCCBINValue, hpciCCValidValue, hpciCCLengthValue, 
		hpciCCEnteredLengthValue, hpciMappedCCValue, hpciMappedCVVValue, hpciGtyTokenValue, hpciCCLast4Value, hpciReportedFormFieldsObj,
		hpciGtyTokenAuthRespValue, hpciTokenRespEncrypt) {

		console.log("=================Begin hpciCCPreliminarySuccessHandlerV4===========");
		let reportedNameOnCard = hpciReportedFormFieldsObj.holderName;
		let reportedExpMonth = hpciReportedFormFieldsObj.expiryMonth;
		let reportedExpYear = hpciReportedFormFieldsObj.expiryYear;
		
		if(reportedNameOnCard != null && reportedNameOnCard != "")
			sendHPCIChangeClassMsg("holderName", "input-text__input input-text__input--populated");
		if(reportedExpMonth != null && reportedExpMonth != "")
			sendHPCIChangeClassMsg("expiryMonth", "input-text__input input-text__input--populated");
		if(reportedExpYear != null && reportedExpYear != "")
			sendHPCIChangeClassMsg("expiryYear", "input-text__input input-text__input--populated");
		
		if(hpciCCValidValue == "Y")
			sendHPCIChangeStyleMsg("ccErrorText", "display", "none");
		
		var data = [
			{ name: "hpciCCTypeValue", value: hpciCCTypeValue },
			{ name: "hpciCCBINValue", value: hpciCCBINValue },
			{ name: "hpciCCValidValue", value: hpciCCValidValue },
			{ name: "hpciCCLengthValue", value: hpciCCLengthValue },
			{ name: "hpciCCEnteredLengthValue", value: hpciCCEnteredLengthValue },
			{ name: "hpciMappedCCValue", value: hpciMappedCCValue },
			{ name: "hpciMappedCVVValue", value: hpciMappedCVVValue },
			{ name: "hpciGtyTokenValue", value: hpciGtyTokenValue },
			{ name: "hpciCCLast4Value", value: hpciCCLast4Value },
			{ name: "hpciReportedFormFieldsObj.holderName", value: reportedNameOnCard },
			{ name: "hpciReportedFormFieldsObj.expiryMonth", value: reportedExpMonth },
			{ name: "hpciReportedFormFieldsObj.expiryYear", value: reportedExpYear },
			{ name: "hpciGtyTokenAuthRespValue", value: hpciGtyTokenAuthRespValue },
			{ name: "hpciTokenRespEncrypt", value: hpciTokenRespEncrypt }
			];
			
		console.table(data);

		if(hpciCCValidValue == "Y")
			document.getElementById('errorMessage').style.display = 'none';
		
		console.log("=================End hpciCCPreliminarySuccessHandlerV4=============");
	}
	
	var hpciCCDigitsSuccessHandlerV2 = function(hpciCCTypeValue, hpciCCBINValue, hpciCCValidValue, hpciCCLengthValue, hpciCCEnteredLengthValue) {
		console.log("================ Begin hpciCCDigitsSuccessHandlerV2================");
		// Use to enable credit card digits key press
		sendHPCIChangeClassMsg("ccNum-wrapper", "input-text input-text--validatable");
		sendHPCIChangeStyleMsg("ccErrorText", "display", "none");
		if(hpciCCValidValue == "Y") {
			sendHPCIChangeClassMsg("ccNum", "input-text__input input-text__input--populated");			
		} else if(hpciCCValidValue == "N" && hpciCCLengthValue == "0") {
			if(hpciCCEnteredLengthValue > "0") {
				sendHPCIChangeClassMsg("ccNum", "input-text__input input-text__input--invalid input-text__input--populated");				
			} 
			else {
				sendHPCIChangeClassMsg("ccNum", "input-text__input");
			    sendHPCIChangeStyleMsg("ccErrorText", "display", "none");
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
		sendHPCIChangeStyleMsg("cvvErrorText", "display", "none");
		if((cvvLength < 3) || (cvvLength > 4)) {
			if (cvvLength == 0) {
				sendHPCIChangeClassMsg("ccCVV", "input-text__input");				
			}else{
				sendHPCIChangeClassMsg("ccCVV", "input-text__input input-text__input--invalid input-text__input--populated");
			}
		} else if ((cvvLength >= 3) && (cvvLength <= 4) && (hpciCVVValidValue == "Y") && (hpciCVVValidValue == "Y")) {
			sendHPCIChangeClassMsg("ccCVV", "input-text__input input-text__input--populated");
		}
		
		console.log("=================End hpciCVVDigitsSuccessHandler=============");
	}
	
	var hpciCVVPreliminarySuccessHandlerV4 = function (hpciCVVLengthValue, hpciCVVValidValue,hpciMappedCCValue, 
		hpciMappedCVVValue, hpciCCBINValue, hpciGtyTokenValue, hpciCCLast4Value, hpciReportedFormFieldsObj, 
		hpciGtyTokenAuthRespValue, hpciTokenRespEncrypt) {

		console.log("=================Begin hpciCVVPreliminarySuccessHandlerV4=================");
		let reportedNameOnCard = hpciReportedFormFieldsObj.holderName;
		let reportedExpMonth = hpciReportedFormFieldsObj.expiryMonth;
		let reportedExpYear = hpciReportedFormFieldsObj.expiryYear;
		
		if(reportedNameOnCard != null && reportedNameOnCard != ""){
			sendHPCIChangeClassMsg("holderName", "input-text__input input-text__input--populated");
			sendHPCIChangeStyleMsg("holderNameErrorText", "display", "none");
		}
		if(reportedExpMonth != null && reportedExpMonth != ""){
			sendHPCIChangeClassMsg("expiryMonth", "input-text__input input-text__input--populated");
			sendHPCIChangeStyleMsg("expiryMonthErrorText", "display", "none");
		}
		if(reportedExpYear != null && reportedExpYear != ""){
			sendHPCIChangeClassMsg("expiryYear", "input-text__input input-text__input--populated");
			sendHPCIChangeStyleMsg("expiryYearErrorText", "display", "none");
		}
		
		var data = [
			{ name: "hpciCVVLengthValue", value: hpciCVVLengthValue },
			{ name: "hpciCVVValidValue", value: hpciCVVValidValue },
			{ name: "hpciMappedCCValue", value: hpciMappedCCValue },
			{ name: "hpciMappedCVVValue", value: hpciMappedCVVValue },
			{ name: "hpciCCBINValue", value: hpciCCBINValue },
			{ name: "hpciGtyTokenValue", value: hpciGtyTokenValue },
			{ name: "hpciCCLast4Value", value: hpciCCLast4Value },
			{ name: "hpciReportedFormFieldsObj.holderName", value: reportedNameOnCard },
			{ name: "hpciReportedFormFieldsObj.expiryMonth", value: reportedExpMonth },
			{ name: "hpciReportedFormFieldsObj.expiryYear", value: reportedExpYear },
			{ name: "hpciGtyTokenAuthRespValue", value: hpciGtyTokenAuthRespValue },
			{ name: "hpciTokenRespEncrypt", value: hpciTokenRespEncrypt }
		  ];
		  
		console.table(data);

		if(hpciCVVValidValue == "Y"){
			document.getElementById('errorMessage').style.display = 'none';
		}
		console.log("=================End hpciCVVPreliminarySuccessHandlerV4=================");
	}
	
	var hpciFormFieldPreliminarySuccessHandler  = function (hpciFormFieldName, hpciFormFieldValue) {
		console.log("=================Begin hpciFormFieldPreliminarySuccessHandler=================");
		console.log("hpciFormFieldName: " + hpciFormFieldName);
		console.log("hpciFormFieldValue: " + hpciFormFieldValue);
		if(hpciFormFieldName == "expiryMonth") {
			if(hpciFormFieldValue != "") {
			 	sendHPCIChangeClassMsg("expiryMonth", "input-text__input input-text__input--populated");
			 	sendHPCIChangeStyleMsg("expiryMonthErrorText", "display", "none");
			}else {
				sendHPCIChangeStyleMsg("expiryMonthErrorText", "display", "block");
			}
		}
		if(hpciFormFieldName == "expiryYear"){ 
			if(hpciFormFieldValue != "") {
				sendHPCIChangeClassMsg("expiryYear", "input-text__input input-text__input--populated");
				sendHPCIChangeStyleMsg("expiryYearErrorText", "display", "none");
			} else {
				sendHPCIChangeStyleMsg("expiryYearErrorText", "display", "block");
			}
		}	
		if(hpciFormFieldName == "holderName"){
			if(hpciFormFieldValue != "") {
				sendHPCIChangeClassMsg("holderName", "input-text__input input-text__input--populated");
				sendHPCIChangeStyleMsg("holderNameErrorText", "display", "none");
			} else {
				sendHPCIChangeStyleMsg("holderNameErrorText", "display", "block");
			}
	  	}
		console.log("=================End hpciFormFieldPreliminarySuccessHandler=================");
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
    
    jQuery.get("IframeAutofillServlet",
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
    			console.log(fullParentHost);
    			console.log(location.pathname);
    			console.log("SiteId :" + siteId);
    			console.log("LocationName :" +locationName);
    			console.log("Currency:" +currency);
    			console.log("Payment Profiles:" +paymentProfile);
    			hpciCCFrameFullUrl = hpciCCFrameHost + "/iSynSApp/showPxyPage!ccFrame.action?pgmode1=prod&"
    				    +"locationName="+locationName
    				    +"&sid=" + siteId
    				    +"&reportCCType=Y&reportCCDigits=Y&reportCVVDigits=Y&cvvValidate=Y"
    				    +"&strictMsgFmt=Y"
    					+"&enableEarlyToken=Y"
    				    +"&formatCCDigits=Y&formatCCDigitsDelimiter=%20/-/%09"
    				    +"&reportFormFields=holderName;expiryMonth;expiryYear"
    				    +"&fullParentHost=" + fullParentHost
    				    +"&fullParentQStr=" + fullParentQStr;
    			document.getElementById("ccframe").src=hpciCCFrameFullUrl;    			
    			console.log(hpciCCFrameFullUrl);
    		});
        
	jQuery('#paymentResetButton').click(function resetPayment() {
		location.reload(true);
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
			<form id="CCAcceptForm" action="/IframeAutofillServlet" method="post" class="form-horizontal">
				<fieldset>
					<!-- Form Name -->
					<legend>Web Checkout</legend>
					<fieldset>
						<legend>Credit Card Information</legend>
						<!-- Error message for invalid credit card -->
						<div id="errorMessage" style="display:none;color:red"><label>Invalid card number, try again</label><br/></div>
						<div id="errorMessage2" style="display:none;color:red"><label>We only accept Visa and MasterCard!</label><br/></div>
						<!-- <div class="form-group">
							<div class="col-xs-4 col-sm-3 col-md-4">
								Select credit card
								<label for="cardType">Card Type</label>
							</div>
						<!-- <div>form-group
						<div class="form-group">
							<div class="col-xs-4 col-sm-3 col-md-4">
								id is used in confirmation.jsp
								<select id="cardType" name="cardType" class="selectpicker">
									<option value="visa">Visa</option>
									<option value="mastercard">MasterCard</option>
									<option value="amex">American Express</option>
								</select>
							</div>
						</div>form-group -->
						<!-- iframe -->
						<div class="form-group">
							<div class="col-xs-12">
								<iframe seamless id="ccframe" name="ccframe" onload="receiveHPCIMsg()" 
									src="" style="border:none; max-width:800px; min-width:30px; width:100%" height="350"> 
								If you can see this, your browser doesn't understand IFRAME. 
								</iframe>
							</div>
						</div><!-- form-group -->
						<!-- Credit card icons -->
						<div class="form-group">
							<div class="col-xs-12">
								<i id="visa" class="fa fa-cc-visa"></i>
								<i id="mastercard" class="fa fa-cc-mastercard"></i>
								<i id="amex" class="fa fa-cc-amex"></i>
								<i id="discover" class="fa fa-cc-discover"></i>
								<i id="jcb" class="fa fa-cc-jcb"></i>
							</div>
						</div><!-- form-group -->
					</fieldset>
					<fieldset>
						<legend>Personal Information</legend>
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
								<button type="submit" value="Submit" id="submitButton" class="btn btn-primary"
									onClick='return sendHPCIMsg();'>Process Payment</button>
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
								<input type="hidden" id="firstName" name="firstName" value="" class="form-control">
								<input type="hidden" id="lastName" name="lastName" value="" class="form-control">
								<input type="hidden" id="expiryMonth" name="expiryMonth" value="" class="form-control">
								<input type="hidden" id="expiryYear" name="expiryYear" value="" class="form-control">
							</div>
						</div>
					</fieldset>	
				</fieldset><!-- Outer fieldset -->
			</form>
		</div><!-- col-md-7 col-centered -->
	</div><!-- form-group -->
</div><!-- container -->
</body>
</html>