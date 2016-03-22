<html>
<head>
<meta charset="utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport" content="width=device-width, initial-scale=1">

<title>HostedPCI Demo App Web Checkout 3D Sec Payment Page</title>
<!-- Bootstrap -->
<link href="https://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap.min.css" rel="stylesheet">
<link href="http://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap-theme.min.css" rel="stylesheet">
<!-- Font-Awesome -->
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/font-awesome/4.4.0/css/font-awesome.min.css">

<link href="css/checkout.css" rel="stylesheet">
<!-- HTML5 Shim and Respond.js IE8 support of HTML5 elements and media queries -->
<!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
<!--[if lt IE 9]>
      <script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>
      <script src="https://oss.maxcdn.com/libs/respond.js/1.4.2/respond.min.js"></script>
    <![endif]-->
<script src="js/jquery-2.1.1.js" type="text/javascript" charset="utf-8"></script>
<script src="https://ccframe.hostedpci.com/WBSStatic/site60/proxy/js/jquery.ba-postmessage.2.0.0.min.js" type="text/javascript" charset="utf-8"></script>
<script src="https://ccframe.hostedpci.com/WBSStatic/site60/proxy/js/hpci-cciframe-1.0.js" type="text/javascript" charset="utf-8"></script>
<script>
	var hpciCCFrameHost = "https://ccframe.hostedpci.com";	
	var hpciCCFrameFullUrl;
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
		//alert("Received preliminary credit card details");
	}

	var hpciCVVPreliminarySuccessHandler = function(hpciCVVLengthValue) {
		// Adapt the following message / action to match your required experience
		//alert("Received preliminary CVV details");
	}	
	var hpciCCDigitsSuccessHandlerV2 = function(hpciCCTypeValue, hpciCCBINValue, hpciCCValidValue, hpciCCLengthValue, hpciCCEnteredLengthValue) {
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
			sendHPCIChangeClassMsg("ccNum", "input-text__input input-text__input--invalid");
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
	}
	
	var hpciCVVDigitsSuccessHandler = function(hpciCVVDigitsValue) {
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
    			fullParentQStr = location.pathname;
    			fullParentHost = location.protocol.concat("//") + window.location.hostname +":" +location.port;
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
    			console.log(location.protocol.concat("//") + window.location.hostname +":" +location.port);
    			console.log(location.pathname);
    			console.log("SiteId :" + siteId);
    			console.log("LocationName :" +locationName);  
    			console.log("Currency:" +currency);
    			console.log("Payment Profiles:" +paymentProfile);
    			hpciCCFrameFullUrl = "https://ccframe.hostedpci.com/iSynSApp/showPxyPage!ccFrame.action?pgmode1=prod&"
    				    +"locationName="+locationName
    				    +"&sid=" + siteId
    				    +"&reportCCType=Y&reportCCDigits=Y&reportCVVDigits=Y"
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
		<div class="col-md-7 col-centered">
			<!-- IMPORTANT: id CCAcceptForm needs to match the ID's in the HostedPCI script code -->
			<!-- So if you change this ID, make sure to change it in all other places -->
			<!-- Action points to the servlet -->
			<form id="CCAcceptForm" action="/Iframe3DSecServlet" method="post">
			<input type="hidden" name="action" value="formRequest">
				<fieldset>
					<!-- Form Name -->
					<legend>Web Checkout</legend>
					<fieldset>
						<legend>Credit Card Information</legend>
						<!-- Error message for invalid credit card -->
						<div id="errorMessage" style="display:none;color:red"><label>Invalid card number, try again</label><br/></div>										
						<!-- iframe -->
						<div class="form-group">
							<iframe seamless id="ccframe" name="ccframe" onload="receiveHPCIMsg()" src="" style="border:none; max-width:800px; min-width:30px; width:100%" height="140"> 
							If you can see this, your browser doesn't understand IFRAME. 
							</iframe>
						</div><!-- form-group -->
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
							<div class="col-xs-5 col-sm-4 col-md-4">
									<label>Expiry MM/YY</label>
									<!-- id is used in confirmation.jsp -->
							</div>
						</div><!-- form-group -->
						<!-- Input form-group (exp, month, cvv) -->
						<div class="form-group">
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
						</div><!-- form-group -->
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
						<div class="form-group">
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
									<option value="DEF_3DSEC">DEF_3DSEC - Currency: any</option>									
								</select>
							</div>
						</div>						
						<div class="form-group">
							<div class="col-xs-6 col-sm-3 col-md-4">
								<!-- Submit button -->
								<button type="submit" value="Submit" class="btn btn-primary"
									onClick='return sendHPCIMsg();'>Process Payment</button>
							</div>	
							<div class="col-xs-6 col-sm-3 col-md-4">
								<!-- Reset button -->
								<button id="paymentResetButton" type="button" value="Reset Payment" class="btn btn-primary">Reset Payment</button><br />
							</div>
						</div>
						<br />
						<div class="form-group">
							<div class="col-xs-6 col-sm-3 col-md-4">
								<!-- Back button -->
								<input Type="button" class="btn btn-primary" value="Back" onClick="location.assign('home.jsp');"></input>
							</div>
						</div>
						<div class="form-group">
							<!-- Hidden form-groups that are required by the iframe -->
							<div class="col-xs-6 col-sm-3 col-md-4">
								<input type="hidden" id="ccNum" name="ccNum" value="" class="form-control"> 
								<input type="hidden" id="ccCVV" name="ccCVV" value="" class="form-control"> 
								<input type="hidden" id="ccBIN" name="ccBIN" value="" class="form-control">
								<input type="hidden" id="action3DSec" name="action3DSec" value="verifyenroll" class="form-control">
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