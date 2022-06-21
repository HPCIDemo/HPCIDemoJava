<html>
<head>
<meta charset="utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport" content="width=device-width, initial-scale=1">

<title>HostedPCI Demo App - ACH tokenization</title>
<!-- Bootstrap -->
<link href="https://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap.min.css" rel="stylesheet">
<link href="https://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap-theme.min.css" rel="stylesheet">
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

	var hpciSiteSuccessHandlerV9 = function(hpciMsgSrcFrameName, hpciMappedACHValue, hpciMappedCVVValue, hpciCCBINValue, hpciGtyTokenValue, 
			hpciACHLast4Value, hpciReportedFormFieldsObj, hpciGtyTokenAuthRespValue, hpciTokenRespEncrypt, threeDSValuesObj, hpciCCTypeValue, 
			hpciMappedACHValue1, hpciMappedACHValue2, hpciMappedACHValue3, hpciMappedACHValue4) {
		
		console.log("=================Begin hpciSiteSuccessHandlerV9=================");
		
		var data = [
			{ name: "hpciMappedACHValue", value: hpciMappedACHValue },
			{ name: "hpciACHLast4Value", value: hpciACHLast4Value },
			{ name: "hpciMappedACHValue1", value: hpciMappedACHValue1 },
			{ name: "hpciMappedACHValue2", value: hpciMappedACHValue2 },
			{ name: "hpciMappedACHValue3", value: hpciMappedACHValue3 },
			{ name: "hpciMappedACHValue4", value: hpciMappedACHValue4 }
		];
			
		console.table(data);
		
		var achNumInput = document.getElementById("achNum");
		achNumInput.value = hpciMappedACHValue;
		
		var ccLast4Input = document.getElementById("achLast4");
		ccLast4Input.value = hpciACHLast4Value;
		
		var achToken1Input = document.getElementById("achToken1");
		achToken1Input.value = hpciMappedACHValue1;
		
		var achToken2Input = document.getElementById("achToken2");
		achToken2Input.value = hpciMappedACHValue2;
		
		var achToken3Input = document.getElementById("achToken3");
		achToken3Input.value = hpciMappedACHValue3;
		
		var achToken4Input = document.getElementById("achToken4");
		achToken4Input.value = hpciMappedACHValue4;
		
		console.log("=================End hpciSiteSuccessHandlerV9=================");
		
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
		//alert("Could not verify PIN for the credit card");
	}

	var hpciACHPreliminarySuccessHandlerV1 = function(hpciMsgSrcFrameName, hpciMappedACHValue1, hpciMappedACHValue2,
			hpciMappedACHValue3, hpciMappedACHValue4, hpciTokenRespEncrypt, hpciReportedFormFieldsObj) {
		
		console.log("=================Begin hpciACHPreliminarySuccessHandlerV1=============");
		
		var data = [
			{ name: "hpciMappedACHValue1", value: hpciMappedACHValue1 },
			{ name: "hpciMappedACHValue2", value: hpciMappedACHValue2 },
			{ name: "hpciMappedACHValue3", value: hpciMappedACHValue3 },
			{ name: "hpciMappedACHValue4", value: hpciMappedACHValue4 }
		];
			
		console.table(data);
		
		if (!!hpciMappedACHValue1) {
			sendHPCIChangeClassMsg("achNum1", "input-text__input input-text__input--populated");
		} else {
			sendHPCIChangeClassMsg("achNum1", "input-text__input");
		}
		
		if (!!hpciMappedACHValue2) {
			sendHPCIChangeClassMsg("achNum2", "input-text__input input-text__input--populated");
		} else {
			sendHPCIChangeClassMsg("achNum2", "input-text__input");
		}
		
		console.log("=================End hpciACHPreliminarySuccessHandlerV1=============");
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
    
    jQuery.get("ACHServlet",
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
    				    +"&enableEarlyToken=Y"
    				    +"&dataType=achus1"
    				    +"&pluginModeDef=jq3"
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
			<form id="CCAcceptForm" action="./ACHServlet" method="post" class="form-horizontal">
				<fieldset>
					<!-- Form Name -->
					<legend>ACH Checkout</legend>
					<fieldset>
						<legend>Acount Information</legend>
						<!-- Error message for invalid credit card -->
						<div id="errorMessage" style="display:none;color:red"><label>Invalid card number, try again</label><br/></div>
						<!-- iframe -->
						<div class="booking-form__field embed-responsive embed-responsive-4by1">
							
								<iframe seamless id="ccframe" name="ccframe" onload="receiveHPCIMsg()" src=""> 
								If you can see this, your browser doesn't understand IFRAME. 
								</iframe>
							
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
								<input type="hidden" id="achNum" name="achNum"> 
								<input type="hidden" id="achLast4" name="achLast4"> 
								<input type="hidden" id="achToken1" name="achToken1">
								<input type="hidden" id="achToken2" name="achToken2">
								<input type="hidden" id="achToken3" name="achToken3">
								<input type="hidden" id="achToken4" name="achToken4">
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