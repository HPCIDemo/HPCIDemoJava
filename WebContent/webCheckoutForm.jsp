<html>
<head>
<meta charset="utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport" content="width=device-width, initial-scale=1">

<title>HostedPCI Demo App Web Checkout Payment Page</title>
<!-- Bootstrap -->
<link href="https://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap.min.css" rel="stylesheet">
<link href="https://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap-theme.min.css" rel="stylesheet">

<!-- Font-Awesome -->
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/font-awesome/4.4.0/css/font-awesome.min.css">

<link href="css/checkout.css" rel="stylesheet">
<link rel="shortcut icon" href="./favicon-new.png">
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
		}
		if(errorCode == "MCC_2"){			
			console.error("%cErrorCode: " + errorCode + " \n ErrorMsg: " + errorMsg, "font-size: larger");
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
		} else if ((cvvLength >= 3) && (cvvLength <= 4) && (hpciCVVValidValue == "Y") && (hpciCVVValidValue == "Y")) {
			sendHPCIChangeClassMsg("ccCVV", "input-text__input input-text__input--populated");
		}
		
		console.log("=================End hpciCVVDigitsSuccessHandler=============");
	}
	
	var hpciCVVPreliminarySuccessHandlerV4 = function (hpciCVVLengthValue, hpciCVVValidValue,hpciMappedCCValue, 
		hpciMappedCVVValue, hpciCCBINValue, hpciGtyTokenValue, hpciCCLast4Value, hpciReportedFormFieldsObj, 
		hpciGtyTokenAuthRespValue, hpciTokenRespEncrypt) {

		console.log("=================Begin hpciCVVPreliminarySuccessHandlerV4=================");
		var data = [
			{ name: "hpciCVVLengthValue", value: hpciCVVLengthValue },
			{ name: "hpciCVVValidValue", value: hpciCVVValidValue },
			{ name: "hpciMappedCCValue", value: hpciMappedCCValue },
			{ name: "hpciMappedCVVValue", value: hpciMappedCVVValue },
			{ name: "hpciCCBINValue", value: hpciCCBINValue },
			{ name: "hpciGtyTokenValue", value: hpciGtyTokenValue },
			{ name: "hpciCCLast4Value", value: hpciCCLast4Value },
			{ name: "hpciGtyTokenAuthRespValue", value: hpciGtyTokenAuthRespValue },
			{ name: "hpciTokenRespEncrypt", value: hpciTokenRespEncrypt }
		  ];
		  
		console.table(data);

		if(hpciCVVValidValue == "Y"){
			document.getElementById('errorMessage').style.display = 'none';
		}
		console.log("=================End hpciCVVPreliminarySuccessHandlerV4=================");
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
    
    jQuery.get("IframeServlet",
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
    				    +"&reportCCType=Y&reportCCDigits=Y&reportCVVDigits=Y"
    				    +"&strictMsgFmt=Y"
    				    +"&formatCCDigits=Y&formatCCDigitsDelimiter=-"
    				    +"&fullParentHost=" + fullParentHost
    				    +"&fullParentQStr=" + fullParentQStr;
    			document.getElementById("ccframe").src=hpciCCFrameFullUrl;    			
    			console.log(hpciCCFrameFullUrl);
    		});
        
	jQuery('#paymentResetButton').click(function resetPayment() {
		document.getElementById('CCAcceptForm').reset();
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
		<div class="col-md-7 col-lg-10 col-centered">
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
			<form id="CCAcceptForm" action="./IframeServlet" method="post" class="form-horizontal">
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
								<iframe seamless id="ccframe" name="ccframe" onload="receiveHPCIMsg()" src="" style="border:none; max-width:800px; min-width:30px; width:100%" height="140"> 
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
						<!-- Input form-group (exp, month, cvv) -->
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
						<div class="booking-form__field form-group">
							<div class="col-xs-6 col-sm-3 col-md-4">
								<!-- Submit button -->
								<button type="submit" value="Submit" id="submitButton" class="btn btn-primary"
									onClick='return sendHPCIMsg();'>Process Payment</button>
							</div>	
							<div class="col-xs-6 col-sm-3 col-md-5">
								<!-- Reset button -->
								<button id="paymentResetButton" type="button" value="Reset Payment" class="btn btn-primary pull-right">Reset Payment</button><br />
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
			</form>
		</div><!-- col-md-7 col-centered -->
	</div><!-- form-group -->
</div><!-- container -->
</body>
</html>