<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport" content="width=device-width, initial-scale=1">

<title>HostedPCI Demo App Web Checkout Multiple iFrames</title>
<!-- Bootstrap -->
<link
	href="https://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap.min.css"
	rel="stylesheet">
<link
	href="https://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap-theme.min.css"
	rel="stylesheet">

<!-- Font-Awesome -->
<link rel="stylesheet"
	href="https://maxcdn.bootstrapcdn.com/font-awesome/4.4.0/css/font-awesome.min.css">

<link href="css/checkout.css" rel="stylesheet">

<script src="js/jquery-2.1.1.js" type="text/javascript" charset="utf-8"></script>
<script
	src="https://ccframe.hostedpci.com/WBSStatic/site60/proxy/js/jquery.ba-postmessage.2.0.0.min.js"
	type="text/javascript" charset="utf-8"></script>
<script
	src="https://ccframe.hostedpci.com/WBSStatic/site60/proxy/js/hpci-cciframe-1.0.js"
	type="text/javascript" charset="utf-8"></script>

<script>
	var hpciCCFrameHost;

	var hpciCCFrameName; // use the name of the iframe containing the credit card
	var hpciCCFrameFullUrl; // HPCI iframe "src" attribute used for tokenization
	var flag = "config";
	var CCFrameFullUrl; //Credit card iframe "src" attribute
	var siteId;
	var locationName;
	var fullParentQStr;
	var fullParentHost;
	var currency;
	var paymentProfile;

	var iframes;
	var iframeCounter = 0;
	// Notify when the tokenization process is finished.
	var deferred;

	var hpciSiteErrorHandler = function(errorCode, errorMsg) {
		// Please the following alert to properly display the error message
		//alert("Error while processing credit card code:" + errorCode + "; msg:"	+ errorMsg);
		console.log("=================Begin hpciSiteErrorHandler=================");
		document.getElementById('errorMessage').style.display = 'block';

		return deferred.reject();
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
		var ccNumInput = jQuery('#ccNum' + (iframeCounter + 1));
		ccNumInput.val(hpciMappedCCValue);

		// Name of the input (hidden) field required by ecommerce site
		// Typically this is a hidden input field.
		var ccCVVInput = jQuery('#ccCVV' + (iframeCounter + 1));
		ccCVVInput.val(hpciMappedCVVValue);

		// Name of the input (hidden) field required by ecommerce site
		// Typically this is a hidden input field.
		var ccBINInput = jQuery('#ccBIN' + (iframeCounter + 1));
		ccBINInput.val(hpciCCBINValue);

		console.log("Success Handler");
		jQuery('#trSummary' + (iframeCounter + 1)).html(
				jQuery('#trSummary' + (iframeCounter + 1)).html()
						+ "Tokenize iframe " + (iframeCounter + 1) + ", id: "
						+ iframes[iframeCounter].id + "." + "<br/>");
		jQuery('#trSummary' + (iframeCounter + 1)).html(
				jQuery('#trSummary' + (iframeCounter + 1)).html()
						+ "Credit card token: "
						+ jQuery('#ccNum' + (iframeCounter + 1)).val() + "."
						+ "<br/>");
		if (hasNextIframe()) {
			setNextIframe();
			sendHPCIMsg();
		} else {
			deferred.resolve();
		}

		console.log("=================End hpciSiteSuccessHandlerV5=================");		
		return false;
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

	var hpciCCPreliminarySuccessHandler = function(hpciCCTypeValue,
			hpciCCBINValue, hpciCCValidValue, hpciCCLengthValue) {
		// Adapt the following message / action to match your required experience
		//alert("Received preliminary credit card details");
	}

	var hpciCVVPreliminarySuccessHandler = function(hpciCVVLengthValue) {
		// Adapt the following message / action to match your required experience
		//alert("Received preliminary CVV details");
	}

	function submitForm() {
		console.log("Submitting the form...");
		deferred.done(
				function() {
					processPayment();
				}).fail(
				function() {
					jQuery('#trSummary').html(
							jQuery('#trSummary').html()
									+ 'Error tokenizing a credit card.'
									+ "<br/>");
				});

		sendHPCIMsg();
	}

	function processPayment() {
		var merchantRefId;
		var counter;
		for (counter = 0; counter < iframes.length; counter++) {
			merchantRefId = (new Date().valueOf()) + counter;
			(function(counter, merchantRefId){
				jQuery.post(
							"MultipleIframesServlet",
							{
								"ccNum" : jQuery("#ccNum" + (counter + 1)).val(),
								"ccCVV" : jQuery("#ccCVV" + (counter + 1)).val(),
								"amount" : jQuery("#amount" + (counter + 1)).val(),
								"merchantRefId" : merchantRefId,
								"currency" : jQuery("#currency option:selected").val(),
								"paymentProfile" : jQuery("#paymentProfile option:selected").val(),
								"expiryMonth" : jQuery("#expiryMonth" + (counter + 1)).val(),
								"expiryYear" : jQuery("#expiryYear" + (counter + 1)).val()
							},
							function(data) {
								//parse the result
								var resultMap = parseQueryString(decodeURIComponent(data.replace(/\+/g,  " ")));
								if (data != undefined) {
									jQuery('#result' + (counter + 1)).html(
											jQuery('#result' + (counter + 1)).html()
													+ "====================================================="
													+ "<br/>");
									jQuery("#result" + (counter + 1)).html(
											 jQuery('#result' + (counter + 1)).html() +
											 "Status: " + resultMap["status"] + "<br/>"
											 + "Description: " + resultMap["pxyResponse.responseStatus.description"] + "<br/>"
											 + "Processor Reference ID: " + resultMap["pxyResponse.processorRefId"] + "<br/>"
											 + "Merchant ID: " + merchantRefId + "<br/>"
											 + "Token Card Number: " + jQuery("#ccNum" + (counter + 1)).val() + "<br/>"
											 + "Token CVV Number: " + jQuery("#ccCVV" + (counter + 1)).val() + "<br/>"
											);
									jQuery("#message" + (counter + 1)).html("Full Message: " + "<br/>" 
												+ decodeURIComponent(data));
									if(counter == 1){
										jQuery('#checkout').hide();
										jQuery('#trSummary').show();
									}
								}
							});
			})(counter, merchantRefId);
		}
	}
	function hasNextIframe() {
		return (++iframeCounter < iframes.length) ? iframeCounter : false;
	}

	function setNextIframe() {
		hpciCCFrameName = iframes[iframeCounter].id;
		hpciStatusReset();
	}

	function parseQueryString(data) {
		//parse the result
		var resultMap = [], queryToken;

		queryTokenList = data.split('&');
		for (var i = 0; i < queryTokenList.length; i++) {
			queryToken = queryTokenList[i].split('=');
			resultMap.push(queryToken[1]);
			resultMap[queryToken[0]] = queryToken[1];
		}

		return resultMap;
	}	
</script>

<script type="text/javascript">
	jQuery(document).ready(function() {
			deferred = $.Deferred();

			jQuery(document).ajaxSend(function(event, request, settings) {
				jQuery('#modal').show();
			});
		    jQuery(document).ajaxComplete(function(event, request, settings) {
				jQuery('#modal').hide();
			});
		    
			jQuery.get(
					//"IframeServlet",
					"MultipleIframesServlet",
					{
						flag : flag,
					},
					function(data) {
						//parse the result
						var resultMap = [], queryToken;
						if (data != undefined) {
							queryTokenList = data
									.split(',');
							for (var i = 0; i < queryTokenList.length; i++) {
								queryToken = queryTokenList[i]
										.split(';');
								resultMap
										.push(queryToken[1]);
								resultMap[queryToken[0]] = queryToken[1];
							}
						}
						siteId = resultMap["sid"];
						locationName = resultMap["locationName"];
						fullParentQStr = location.pathname;
						fullParentHost = location.protocol
								.concat("//")
								+ window.location.hostname
								+ (location.port ? ':' + location.port: '');
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
						console.log("LocationName :"
								+ locationName);

						iframes = jQuery("iframe");
						//Set the "src" attribute for the Hpci iframe
						for (i = 0; i < iframes.length; i++) {
							CCFrameFullUrl = hpciCCFrameHost + "/iSynSApp/showPxyPage!ccFrame.action?pgmode1=prod&"
									+ "locationName=" + locationName
									+ "&sid=" + siteId
									//	+ "&reportCCType=Y&reportCCDigits=Y&reportCVVDigits=Y"
									+ "&ccNumTokenIdx=" + (i + 1)
									+ "&fullParentHost=" + fullParentHost
									+ "&fullParentQStr=" + fullParentQStr;

									jQuery("#" + iframes[i].id)
											.attr("src",
													CCFrameFullUrl);

									console.log("Iframe " + (i + 1)
											+ " src param: "
											+ CCFrameFullUrl);

									if (i == 0) {
										//Set the first iframe for a credit card tokenization
										hpciCCFrameFullUrl = CCFrameFullUrl;
										hpciCCFrameName = iframes[i].id;
									}
								}
								console.log(iframes);
						});

			jQuery('#paymentResetButton').click(
							function resetPayment() {
								jQuery('#CCAcceptForm').trigger('reset');
								//Reset iframes
								for (i = 0; i < iframes.length; i++) {
									jQuery("#" + iframes[i].id)
											.attr("src", jQuery("#"+ iframes[i].id).attr("src"));
									jQuery('#trSummary' + (i + 1)).html("");
								}
								// Set the name of the iframe containing the credit card
								hpciCCFrameName = iframes[0].id;
								jQuery('#trSummary').hide();
							});

			jQuery('#submitBtn').click(function() {
				submitForm();
			});

			jQuery('#backBtn').click(function () {
				location.reload(true);
			});
			
			jQuery("#toggleMessage1").click(function() {
				jQuery("#message1").toggle("slow");
				jQuery(this).val(jQuery(this).val() == "Show response" ? "Hide response" : "Show response");
			});
			jQuery("#toggleMessage2").click(function() {
				jQuery("#message2").toggle("slow");
				jQuery(this).val(jQuery(this).val() == "Show response" ? "Hide response" : "Show response");
			});
			
			jQuery('input:text').on('blur', function() {
				if (jQuery(this).val()) {
					jQuery(this).attr("class", "input-text__input input-text__input--populated");
				} else {
					jQuery(this).attr("class", "");
				}
			});
		});
</script>
</head>
<body>
	<!-- container class sets the page to use 100% width -->
	<div class="container">
		<div id = "modal" style="display: none">
			<div id = "loader"></div>
		</div>
		<div>
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
					<form id="CCAcceptForm" action="/IframeServlet" method="post"
						class="form-horizontal">
						<fieldset id = "checkout">
							<!-- Form Name -->
							<legend>Web Checkout Multiple Iframes</legend>
							<fieldset>
								<legend>Credit Card Information</legend>
								<!-- Error message for invalid credit card -->
								<div id="errorMessage" style="display: none; color: red">
									<label>Invalid card number, try again</label><br />
								</div>

								<div class="form-group">
									<div class="row">
										<div class="col-xs-6">
											<iframe seamless id="ccframe1" name="ccframe1"
												onload="receiveHPCIMsg()" src=""
												style="border: none; max-width: 800px; min-width: 30px; width: 100%"
												height="140"> If you can see this, your browser
												doesn't understand IFRAME. </iframe>
										</div>
										<div class="col-xs-6">
											<div id="trSummary1"></div>
										</div>
									</div>
									<div class="row">
										<div class="booking-form__field">
											<label style="margin-left: 0.75rem;font-size: 0.9rem;">Expiry date</label>
									    </div>
									    <div>
											<div class="col-xs-4 col-sm-3 col-md-2">
												<div class="booking-form__field">
													<div class="input-text">
														<input id="expiryMonth1" type="text" name="expiryMonth1">
														<label for="expiryMonth">
														Month
														</label>
													</div>
												</div>
											</div>
											<div class="col-xs-4 col-sm-3 col-md-2">
												<div class="booking-form__field">
													<div class="input-text">
														<input id="expiryYear1" type="text" name="expiryYear1">
														<label for="expiryYear">
														Year
														</label>
													</div>
												</div>
											</div>
										</div>
									</div>
									<div class="row">
										<div class="booking-form__field">
											<div class="input-text col-xs-6">
												<input id="amount1" type="text" name="amount1"> <label
													for="amount1"> Payment Amount </label>
											</div>
										</div>
									</div>
									<div class="form-group">
										<!-- Hidden form-groups that are required by the iframe -->
										<div class="col-xs-6 col-sm-3 col-md-4">
											<input type="hidden" id="ccNum1" name="ccNum1" value=""
												class="form-control"> <input type="hidden"
												id="ccCVV1" name="ccCVV1" value="" class="form-control">
											<input type="hidden" id="ccBIN1" name="ccBIN1" value=""
												class="form-control">
										</div>
									</div>

								</div>
								<div class="form-group">
									<div class="row">
										<div class="col-xs-6">
											<iframe seamless id="ccframe2" name="ccframe2"
												onload="receiveHPCIMsg()" src=""
												style="border: none; max-width: 800px; min-width: 30px; width: 100%"
												height="140"> If you can see this, your browser
												doesn't understand IFRAME. </iframe>
										</div>
										<div class="col-xs-6">
											<div id="trSummary2"></div>
										</div>
									</div>
									<div class="row">
										<div class="booking-form__field">
											<label style="margin-left: 0.75rem;font-size: 0.9rem;">Expiry date</label>
									    </div>
									    <div>
											<div class="col-xs-4 col-sm-3 col-md-2">
												<div class="booking-form__field">
													<div class="input-text">
														<input id="expiryMonth2" type="text" name="expiryMonth2">
														<label for="expiryMonth">
														Month
														</label>
													</div>
												</div>
											</div>
											<div class="col-xs-4 col-sm-3 col-md-2">
												<div class="booking-form__field">
													<div class="input-text">
														<input id="expiryYear2" type="text" name="expiryYear2">
														<label for="expiryYear">
														Year
														</label>
													</div>
												</div>
											</div>
										</div>
										<div class="booking-form__field">
											<div class="input-text col-xs-6">
												<input id="amount2" type="text" name="amount2"> <label
													for="amount2"> Payment Amount </label>
											</div>
										</div>
										<div class="form-group">
											<!-- Hidden form-groups that are required by the iframe -->
											<div class="col-xs-6 col-sm-3 col-md-4">
												<input type="hidden" id="ccNum2" name="ccNum2" value=""
													class="form-control"> <input type="hidden"
													id="ccCVV2" name="ccCVV2" value="" class="form-control">
												<input type="hidden" id="ccBIN2" name="ccBIN2" value=""
													class="form-control">
											</div>
										</div>
									</div>
								</div>
								<div class="row">
									<div class="booking-form__field form-group">
										<div class="col-xs-4 col-sm-3 col-md-4">
											<label>Currency:</label>
										</div>
										<div class="col-xs-4 col-sm-3 col-md-5">
											<select id="currency" name="currency">									
											</select>
										</div>
									</div>
								</div>
								<div class="row">
									<div class="booking-form__field form-group">
										<div class="col-xs-4 col-sm-3 col-md-4">
											<label>Payment Profile:</label>
										</div>
										<div class="col-xs-4 col-sm-3 col-md-5">
											<select id="paymentProfile" name="paymentProfile">									
											</select>
										</div>
									</div>
								</div>
								<!-- form-group -->
								<div class="row">
									<div class="form-group">
										<div class="col-xs-6 col-sm-3 col-md-4">
											<!-- Submit button -->
											<button type="button" value="Submit" id="submitBtn"
												class="btn btn-primary">Process Payment</button>
										</div>
										<div class="col-xs-6 col-sm-3 col-md-4">
											<!-- Reset button -->
											<button id="paymentResetButton" type="button"
												value="Reset Payment" class="btn btn-primary">Reset
												Payment</button>
											<br />
										</div>
									</div>
								</div>
								<br />
							</fieldset>
						</fieldset><!-- Outer fieldset -->
						<fieldset id="trSummary">
							<legend>Transaction Summary</legend>					
							<div id = "result1">
							</div>
							<br/>
							<input type="button" id="toggleMessage1" value="Show response" class="btn">						
							<div id = "message1" style="word-wrap: break-word;">
							</div><br/><br/>
							<div id = "result2">
							</div>
							<br/>
							<input type="button" id="toggleMessage2" value="Show response" class="btn">
							<div id = "message2" style="word-wrap: break-word;">
							</div><br/><br/>
							<br /> <input Type="button"  id = "backBtn" class="btn btn-primary" value="Back"></input><br />
						</fieldset>
					</form>
				</div>
				<!-- col-md-7 col-centered -->
			</div>
			<!-- form-group -->
		</div>
		<br />
		
	</div>
	<!-- container -->
</body>
</html>