<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport" content="width=device-width, initial-scale=1">

<title>HostedPCI Demo App Web Checkout Payment Page</title>
<!-- Bootstrap -->
<link
	href="https://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap.min.css"
	rel="stylesheet">
<link
	href="http://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap-theme.min.css"
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
	var hpciCCFrameHost = "https://ccframe.hostedpci.com";

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
		document.getElementById('errorMessage').style.display = 'block';

		return deferred.reject();
	}

	var hpciSiteSuccessHandlerV2 = function(mappedCCValue, mappedCVVValue,
			ccBINValue) {

		// Please pass the values to the document input and then submit the form

		// No errors from iframe so hide the errorMessage div
		document.getElementById('errorMessage').style.display = 'none';
		// Name of the input (hidden) field required by ecommerce site
		// Typically this is a hidden input field.
		var ccNumInput = jQuery('#ccNum' + (iframeCounter + 1));
		ccNumInput.val(mappedCCValue);

		// Name of the input (hidden) field required by ecommerce site
		// Typically this is a hidden input field.
		var ccCVVInput = jQuery('#ccCVV' + (iframeCounter + 1));
		ccCVVInput.val(mappedCVVValue);

		// Name of the input (hidden) field required by ecommerce site
		// Typically this is a hidden input field.
		var ccBINInput = jQuery('#ccBIN' + (iframeCounter + 1));
		ccBINInput.val(ccBINValue);

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

	var hpciCCDigitsSuccessHandlerV2 = function(hpciCCTypeValue,
			hpciCCBINValue, hpciCCValidValue, hpciCCLengthValue,
			hpciCCEnteredLengthValue) {
		// Use to enable credit card digits key press
		sendHPCIChangeClassMsg("ccNum-wrapper",
				"input-text input-text--validatable");

		if (hpciCCValidValue == "Y") {
			sendHPCIChangeClassMsg("ccNum",
					"input-text__input input-text__input--populated");
		} else if (hpciCCValidValue == "N" && hpciCCLengthValue == "0") {
			if (hpciCCEnteredLengthValue > "0") {
				sendHPCIChangeClassMsg("ccNum",
						"input-text__input input-text__input--invalid input-text__input--populated");
			} else {
				sendHPCIChangeClassMsg("ccNum", "input-text__input");
			}
		} else if (hpciCCValidValue == "N" && hpciCCLengthValue > "0"
				&& hpciCCEnteredLengthValue > "0") {
			sendHPCIChangeClassMsg("ccNum",
					"input-text__input input-text__input--invalid input-text__input--populated");
		}

		if (hpciCCTypeValue == "visa") {
			document.getElementById("visa").className = "fa fa-cc-visa active";
		} else if (hpciCCTypeValue == "mastercard") {
			document.getElementById("mastercard").className = "fa fa-cc-mastercard active";
		} else if (hpciCCTypeValue == "amex") {
			document.getElementById("amex").className = "fa fa-cc-amex active";
		} else if (hpciCCTypeValue == "discover") {
			document.getElementById("discover").className = "fa fa-cc-discover active";
		} else if (hpciCCTypeValue == "jcb") {
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
		sendHPCIChangeClassMsg("ccCVV-wrapper",
				"input-text input-text--validatable");

		var cvvLength = Number(hpciCVVDigitsValue);
		if ((cvvLength < 3) || (cvvLength > 4)) {
			if (cvvLength == 0) {
				sendHPCIChangeClassMsg("ccCVV", "input-text__input");
			} else {
				sendHPCIChangeClassMsg("ccCVV",
						"input-text__input input-text__input--invalid input-text__input--populated");
			}
		} else if ((cvvLength >= 3) && (cvvLength <= 4)) {
			sendHPCIChangeClassMsg("ccCVV",
					"input-text__input input-text__input--populated");
		}

	}

	function submitForm() {
		console.log("submit");
		jQuery('#trSummary').show();
		deferred.done(
				function() {
					jQuery('#trSummary').html(
							jQuery('#trSummary').html()
									+ 'The tokenization process is completed.'
									+ "<br/>");
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
		for (i = 0; i < iframes.length; i++) {
			jQuery
					.post(
							"MultipleIframesServlet",
							{
								"ccNum" : jQuery("#ccNum" + (i + 1)).val(),
								"ccCVV" : jQuery("#ccCVV" + (i + 1)).val(),
								"amount" : jQuery("#amount" + (i + 1)).val(),
								"merchantRefId" : new Date().valueOf(),
								"currency" : "CAD",
								"paymentProfile" : "DEF",
								"expiryMonth" : jQuery("#expiryMonth" + (i + 1))
										.val(),
								"expiryYear" : jQuery("#expiryYear" + (i + 1))
										.val(),

							},
							function(data) {
								//parse the result
								var resultMap = parseQueryString(data);

								if (data != undefined) {
									jQuery('#trSummary')
											.html(
													jQuery('#trSummary').html()
															+ "====================================================="
															+ "<br/>");
									jQuery('#trSummary')
											.html(
													jQuery('#trSummary').html()
															+ "Processing the payment.."
															+ "<br/>"
															+ "Transaction result: "
															+ resultMap["status"]
															+ "<br/>");
									jQuery('#trSummary').html(
											jQuery('#trSummary').html() + data
													+ "<br/>");

								}
							});
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
	jQuery(document)
			.ready(
					function() {
						deferred = $.Deferred();

						jQuery
								.get(
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
													+ ":" + location.port;

											console.log(location.protocol
													.concat("//")
													+ window.location.hostname
													+ ":" + location.port);
											console.log(location.pathname);
											console.log("SiteId :" + siteId);
											console.log("LocationName :"
													+ locationName);

											iframes = jQuery("iframe");
											//Set the "src" attribute for the Hpci iframe
											for (i = 0; i < iframes.length; i++) {
												CCFrameFullUrl = "https://ccframe.hostedpci.com/iSynSApp/showPxyPage!ccFrame.action?pgmode1=prod&"
														+ "locationName="
														+ locationName
														+ "&sid="
														+ siteId
													//	+ "&reportCCType=Y&reportCCDigits=Y&reportCVVDigits=Y"
														+ "&ccNumTokenIdx="
														+ (i + 1)
														+ "&fullParentHost="
														+ fullParentHost
														+ "&fullParentQStr="
														+ fullParentQStr;

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
										jQuery("#" + iframes[i].id).attr(
												"src",
												jQuery("#" + iframes[i].id)
														.attr("src"));
										jQuery('#trSummary' + (i+1)).html("");
									}
									// Set the name of the iframe containing the credit card
									hpciCCFrameName = iframes[0].id;
									jQuery('#trSummary').hide();
								});

						jQuery('#submitBtn').click(function() {
							submitForm();
						});

						jQuery('input:text')
								.on(
										'blur',
										function() {
											if (jQuery(this).val()) {
												jQuery(this)
														.attr("class",
																"input-text__input input-text__input--populated");
											} else {
												jQuery(this).attr("class", "");
											}
											;
										});
					});
</script>
</head>
<body>
	<!-- container class sets the page to use 100% width -->
	<div class="container">
		<div>
			<!-- form-group class sets the margins on the sides -->
			<div class="form-group">
				<!-- col-md-7 col-centered class uses the bootstrap grid system to use 7/12 of the screen and place it in the middle -->
				<div class="col-md-7 col-centered">
					<!-- IMPORTANT: id CCAcceptForm needs to match the ID's in the HostedPCI script code -->
					<!-- So if you change this ID, make sure to change it in all other places -->
					<!-- Action points to the servlet -->
					<form id="CCAcceptForm" action="/IframeServlet" method="post"
						class="form-horizontal">
						<fieldset>
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
										<div class="col-xs-5 col-sm-3 col-md-3">
											<select id="expiryMonth1" name="expiryMonth1"
												class="selectpicker">
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
											<select id="expiryYear1" name="expiryYear1"
												class="selectpicker">
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
										<div class="col-xs-5 col-sm-3 col-md-3">
											<select id="expiryMonth2" name="expiryMonth2"
												class="selectpicker">
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
											<select id="expiryYear2" name="expiryYear2"
												class="selectpicker">
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

								<!-- Credit card icons -->
								<div class="form-group">
									<div class="col-xs-12">
										<i id="visa" class="fa fa-cc-visa"></i> <i id="mastercard"
											class="fa fa-cc-mastercard"></i> <i id="amex"
											class="fa fa-cc-amex"></i> <i id="discover"
											class="fa fa-cc-discover"></i> <i id="jcb"
											class="fa fa-cc-jcb"></i>
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
								<div class="row">
									<div class="form-group">
										<div class="col-xs-6 col-sm-3 col-md-4">
											<!-- Back button -->
											<input Type="button" class="btn btn-primary" value="Back"
												onClick="location.assign('home.jsp');"></input>
										</div>
									</div>
								</div>
							</fieldset>
						</fieldset>
						<!-- Outer fieldset -->
					</form>
				</div>
				<!-- col-md-7 col-centered -->
			</div>
			<!-- form-group -->
		</div>
		<br />
		<div id="trSummary" class="col-md-7 col-centered"></div>
	</div>
	<!-- container -->
</body>
</html>