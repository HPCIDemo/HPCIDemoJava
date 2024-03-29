<html>
<head>
<meta charset="utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport" content="width=device-width, initial-scale=1">

<title>HostedPCI Demo App Gateway Tokenization</title>
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
		console.log("=================Begin hpciSiteErrorHandler=================");
		//alert("Error while processing credit card code:" + errorCode + "; msg:"	+ errorMsg);
		document.getElementById('errorMessage').style.display = 'block';
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

		// Name of the input (hidden) field required by ecommerce site
		// Typically this is a hidden input field.
		var gtyTokenInput = document.getElementById("gtyToken");
		gtyTokenInput.value = hpciGtyTokenValue;
		
		//Gateway tokenization
		gtwTokenize();
		
	}

	function gtwTokenize(){
		jQuery.post("GatewayTokenizationServlet",
	    	    {
				"ccNum": jQuery("#ccNum").val(),
				"ccCVV": jQuery("#ccCVV").val(),
				"expiryMonth": jQuery("#ccExpMonth").val(),
				"expiryYear": jQuery("#ccExpYear").val(),
				"firstName": jQuery("#firstName").val(),
				"lastName": jQuery("#lastName").val(),
				"currency" : jQuery("#currency option:selected").val(),
				"paymentProfile": jQuery("#paymentProfile").val()
	    		},
	    		function(data){
	    			//parse the result
	    			var resultMap = [], queryToken;
	    		    if(data != undefined) {
	    				queryTokenList = data.split('&');
	    				for(var i = 0; i < queryTokenList.length; i++){
	   						queryToken = queryTokenList[i].split('=');
	   						resultMap.push(queryToken[1]);
	   						let tokenValue = "";
	   						if(queryToken[1] != undefined && queryToken[1] != "")
	   							tokenValue = decodeURIComponent(queryToken[1].replace(/\+/g,  " "))
	   						resultMap[queryToken[0]] = tokenValue;
	    				}
	    				//Display the tokenization result message.
	    				var displayMessage = "";
	    				if(resultMap["status"] != undefined){
	    					displayMessage = "HPCI status: " + resultMap["status"] + "<br>";
	    					if(resultMap["status"] == "error") {	    						
	    						if(resultMap["errId"] != undefined && resultMap["errId"] != "")
	    							displayMessage = displayMessage + "HPCI error Id: " + resultMap["errId"] + "<br>";
	    						if(resultMap["errFullMsg"] != undefined && resultMap["errFullMsg"] != "")
	    							displayMessage = displayMessage + "HPCI error message: " + resultMap["errFullMsg"] + "<br>";
	    						if(resultMap["errParamName"] != undefined && resultMap["errParamName"] != "")
	    							displayMessage = displayMessage + "HPCI error parameter name: " + resultMap["errParamName"] + "<br>";
	    						if(resultMap["errParamValue"] != undefined && resultMap["errParamValue"] != "")
	    							displayMessage = displayMessage + "HPCI error parameter value: " + resultMap["errParamValue"] + "<br>";
	    					} else {
	    						displayMessage = displayMessage
	    										+ "HPCI cc token: " + jQuery("#ccNum").val()  + "<br>"
												+ "HPCI cvv token: " + jQuery("#ccCVV").val()  + "<br>"
												+ "Gateway token: " + resultMap["pxyResponse.gatewayToken"];
	    					}
	    				}
	    				document.getElementById("gtySummary").className = "";
	    				document.getElementById("message").style.display = "block";
	    				document.getElementById("message").innerHTML = displayMessage;
	    				document.getElementById("tokenizeButton").disabled = true;
	    		    }
	    		});
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
			document.getElementById("tokenizeButton").disabled = false;
			document.getElementById("errorMessage2").style.display = "none";
		} else {
			document.getElementById("tokenizeButton").disabled = true;
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
		} else if ((cvvLength >= 3) && (cvvLength <= 4) && (hpciCVVValidValue == "Y")) {
			sendHPCIChangeClassMsg("ccCVV", "input-text__input input-text__input--populated");
		}
		console.log("=================End hpciCVVDigitsSuccessHandler=============");
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
    
    jQuery.get("GatewayTokenizationServlet",
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
    			console.log("Payment Profiles:" +paymentProfile);
    			
    			hpciCCFrameFullUrl = hpciCCFrameHost + "/iSynSApp/showPxyPage!ccFrame.action?pgmode1=prod&"
    				    +"locationName="+locationName
    				    +"&sid=" + siteId
    				    +"&reportCCType=Y&reportCCDigits=Y&reportCVVDigits=Y"
    				    +"&fullParentHost=" + fullParentHost
    				    +"&fullParentQStr=" + fullParentQStr;
    			document.getElementById("ccframe").src=hpciCCFrameFullUrl;    			
    			console.log(hpciCCFrameFullUrl);
    		});
        
	jQuery('#formResetButton').click(function resetForm() {		
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
			<form id="CCAcceptForm" action="./GatewayTokenizationServlet" method="post" class="form-horizontal">
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
						<div class="form-group">
							<!-- <div class="col-xs-5 col-sm-4 col-md-4">
									<label>Expiry MM/YY</label>
									id is used in confirmation.jsp
							</div> -->
						</div><!-- form-group -->
						<div class="booking-form__field">
							<label>Expiry date</label>
					    </div>
					    <div>
							<div class="col-xs-4 col-sm-3 col-md-2">
								<div class="booking-form__field">
									<div class="input-text">
										<input id="ccExpMonth" type="text" name="ccExpMonth">
										<label for="ccExpMonth">
										Month
										</label>
									</div>
								</div>
							</div>
							<div class="col-xs-4 col-sm-3 col-md-2">
								<div class="booking-form__field">
									<div class="input-text">
										<input id="ccExpYear" type="text" name="ccExpYear">
										<label for="ccExpYear">
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
						<div class="booking-form__field form-group">
							<div class="col-xs-4 col-sm-3 col-md-4">
								<label>Currency:</label>
							</div>
							<div class="col-xs-4 col-sm-3 col-md-5">
								<select id="currency" name="currency">									
								</select>
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
						<div class="booking-form__field form-group" >
								<div class="col-xs-6 col-sm-3 col-md-4">
									<!-- Submit button -->
									<button type="button" value="Submit" class="btn btn-primary" id="tokenizeButton"
										onClick='return sendHPCIMsg();'>Tokenize Credit Card</button>
								</div>
								<div class="col-xs-6 col-sm-3 col-md-5">
									<!-- Reset button -->
									<button id="formResetButton" type="button" value="Reset form" class="btn btn-primary pull-right">Reset Form</button>
								</div>
						</div>
						<br />
						<div class="form-group">
							<!-- Hidden form-groups that are required by the iframe -->
							<div class="col-xs-6 col-sm-3 col-md-4">
								<input type="hidden" id="ccNum" name="ccNum" value="" class="form-control"> 
								<input type="hidden" id="ccCVV" name="ccCVV" value="" class="form-control"> 
								<input type="hidden" id="ccBIN" name="ccBIN" value="" class="form-control">
								<input type="hidden" id="gtyToken" name="gtyToken" value="" class="form-control"> 
							</div>
						</div>
					</fieldset>	
					<fieldset id="gtySummary" class="gtySummary">
                        <legend>Tokenization Summary</legend>
                        <div id="message"></div>
                    </fieldset>
				</fieldset><!-- Outer fieldset -->
			</form>
		</div><!-- col-md-7 col-centered -->
	</div><!-- form-group -->
</div><!-- container -->
</body>
</html>