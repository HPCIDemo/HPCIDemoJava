<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>HostedPCI Demo App Payment Message Dispatch</title>
<link
	href="https://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap.min.css"
	rel="stylesheet">
<link
	href="https://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap-theme.min.css"
	rel="stylesheet">
<!-- Font-Awesome -->
<link rel="stylesheet"
	href="https://maxcdn.bootstrapcdn.com/font-awesome/4.4.0/css/font-awesome.min.css">
<link href="css/template.css" rel="stylesheet">
<script src="js/jquery-2.1.1.js" type="text/javascript" charset="utf-8"></script>
<script src="js/parsley.min.js" type="text/javascript" charset="utf-8"></script>
<script src="https://ccframe.hostedpci.com/WBSStatic/site60/proxy/js/jquery.ba-postmessage.2.0.0.min.js"
	type="text/javascript" charset="utf-8"></script>
<script src="https://ccframe.hostedpci.com/WBSStatic/site60/proxy/js/hpci-cciframe-1.0.js"
	type="text/javascript" charset="utf-8"></script>
<script>
	var hpciCCFrameHost;
	var hpciCCFrameName = "ccframe"; // use the name of the frame containing the credit card
	var hpciCCFrameFullUrl;
	var iframes;
	
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

		// Name of the input (hidden) field required by ecommerce site
		// Typically this is a hidden input field.
		var ccCVVInput = document.getElementById("ccCVV");
		ccCVVInput.value = mappedCVVValue;

		// Name of the input (hidden) field required by ecommerce site
		// Typically this is a hidden input field.
		var ccBINInput = document.getElementById("ccBIN");
		ccBINInput.value = ccBINValue;
		
		console.log("Success Handler");
		jQuery('#trSummary1').val(
				jQuery('#trSummary1').val()
						+ "Tokenize iframe 1" + ", id: " + iframes[0].id + "." + "\n"
						+ "Credit card token: " + jQuery('#ccNum').val() + "." + "\n"
						+ "CVV card token: " + jQuery('#ccCVV').val() + "." + "\n");
		jQuery('#paymentMsgDispatchCcToken').val(mappedCCValue);
		jQuery('#paymentMsgDispatchCvvToken').val(mappedCVVValue);
		
		return false;
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
	
	function populateFileField(){
		jQuery('#paymentMsgDispatch_file').val(
				"<Request version='2'>"+
				"<Authentication>"+
				"	<client>99009604</client>"+
				"	<password>v4sp6Y28wT2D</password>"+
				"</Authentication>"+
				"<Transaction>"+
				"	<CardTxn>"+
				"		<method>pre</method>"+
				"		<Card>"+
				"			<expirydate>01/20</expirydate>"+
				"			<pan>%%CC%%</pan>"+
				"			<Cv2Avs>"+
				"				<street_address1>1 High Street</street_address1>"+
				"				<street_address2>Unit 1</street_address2>"+
				"				<city>This Town</city>"+
				"				<state_province>Somewhere</state_province>"+
				"				<country>826</country>"+
				"				<postcode>S01 2CD</postcode>"+
				"				<cv2>%%CVV%%</cv2>"+
				"			</Cv2Avs>"+
				"		</Card>"+
				"	</CardTxn>"+
				"	<TxnDetails>"+
				"		<merchantreference>RANDOM_REF_ID_PLACE_HOLDER</merchantreference>"+
				"		<capturemethod>ecomm</capturemethod>"+
				"		<amount currency='CURRENCY_PLACE_HOLDER'>AMOUNT_PLACE_HOLDER</amount>"+
				"			<Airline>"+
				"				<clearingcount>1</clearingcount>"+
				"				<clearingsequence>1</clearingsequence>"+
				"				<customercode>randomcode</customercode>"+
				"				<customeremail>help@lost.com</customeremail>"+
				"				<customerip>192.168.0.1</customerip>"+
				"				<issuedate>20140101</issuedate>"+
				"				<issuingcarrier>PAP</issuingcarrier>"+
				"				<restrictedticket>0</restrictedticket>"+
				"				<totalfare>120.00</totalfare>"+
				"				<totalfees>10.00</totalfees>"+
				"				<totaltaxes>35.00</totaltaxes>"+
				"				<travelagencycode>87654321</travelagencycode>"+
				"				<travelagencyname>flightagency</travelagencyname>"+
				"				<LegData number='1'>"+
				"					<arrivaldate>20140102</arrivaldate>"+
				"					<arrivaltime>17:30</arrivaltime>"+
				"					<carriercode>AB</carriercode>"+
				"					<conjunctionticket>abcdefg1234</conjunctionticket>"+
				"					<couponnumber>B</couponnumber>"+
				"					<departuredate>20140101</departuredate>"+
				"					<departuretime>12:34</departuretime>"+
				"					<depart_airport_timezone>+01:00</depart_airport_timezone>"+
				"					<destinationairport>LHR</destinationairport>"+
				"					<endorsement>testvalue</endorsement>"+
				"					<exchangeticket>4321gfedcba</exchangeticket>"+
				"					<fare>120.00</fare>"+
				"					<farebasiscode>ABCDEF</farebasiscode>"+
				"					<fees>10.00</fees>"+
				"					<flightnumber>AB12</flightnumber>"+
				"					<originairport>EDI</originairport>"+
				"					<serviceclass>A</serviceclass>"+
				"					<stopovercode>1</stopovercode>"+
				"					<taxes>12.00</taxes>"+
				"					<currency_code>CURRENCY_CODE_PLACE_HOLDER</currency_code>"+
				"				</LegData>"+
				"				<PassengerData number='1'>"+
				"					<firstname>John</firstname>"+
				"					<passengerref>123457foo</passengerref>"+
				"					<surname>Doe</surname>"+
				"					<passenger_type>A</passenger_type>"+
				"					<ticketnumber>1234</ticketnumber>"+
				"					<ticketprice>500.00</ticketprice>"+
				"					<loyalty_tier>3</loyalty_tier>"+
				"				</PassengerData>"+
				"			</Airline>"+
				"	</TxnDetails>"+
				"</Transaction>"+
			"</Request>"		
			);
	}
	
	jQuery(document).ready(function() {
		var siteId;
	    var locationName;
	    var fullParentQStr;
	    var fullParentHost;
	    var flag = "config";
	    iframes = jQuery("iframe");
	    
		$(document).ajaxSend(function(event, request, settings) {
			jQuery('#modal').show();
		});
		$(document).ajaxComplete(function(event, request, settings) {
			jQuery('#modal').hide();
		});
		
		populateFileField();
		
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
		
//		///////// Wizard navigation ////////////
		var $sections = $('.form-section');

		function navigateTo(index) {
			// Mark the current section with the class 'current'
		    $sections
		      .removeClass('current')
		      .eq(index)
		        .addClass('current');
		    // Show only the navigation buttons that make sense for the current section:
		    jQuery('.form-navigation .previous').toggle(index > 0);
		    var atTheEnd = index >= $sections.length - 1;
		    jQuery('.form-navigation .next').toggle(!atTheEnd);
		}

		function curIndex() {
		    // Return the current index by looking at which section has the class 'current'
		    return $sections.index($sections.filter('.current'));
		}

		// Previous button is easy, just go back
		$('.form-navigation .previous').click(function() {
		    navigateTo(curIndex() - 1);
		});

		// Next button goes forward iff current block validates
		$('.form-navigation .next').click(function() {
		   var ccToken = jQuery('#ccNum').val();
		   
		   if(ccToken){
			   if (jQuery('.payment-msg-dispatch-wizard').parsley().validate({group: 'block-' + curIndex()}))
				   navigateTo(curIndex() + 1);
		   }
		});
		// Prepare sections by setting the `data-parsley-group` attribute to 'block-0', 'block-1', etc.
		$sections.each(function(index, section) {
			jQuery(section).find(':input').attr('data-parsley-group', 'block-' + index);
		});
	    navigateTo(0); // Start at the beginning
//		//////////////////////////////End Wizard navigation/////////////////////////// 
		
		jQuery.get("PaymentMsgDispatchServlet",
	    	    {
	    			flag:flag,
	    		},
	    		function(data){
	    			//parse the result
	    		    var resultMap = parseQueryString(data, ',', ';');
	    		    
	    			siteId = resultMap["sid"];
	    			locationName = resultMap["locationName"]; 
	    			fullParentQStr = location.pathname;
	    			fullParentHost = location.protocol.concat("//") + window.location.hostname +":" +location.port;
	    			hpciCCFrameHost = resultMap["serviceUrl"];
	    			
	    			
	    			console.log(location.protocol.concat("//") + window.location.hostname +":" +location.port);
	    			console.log(location.pathname);
	    			console.log("SiteId :" + siteId);
	    			console.log("LocationName :" +locationName);
	    			hpciCCFrameFullUrl = hpciCCFrameHost + "/iSynSApp/showPxyPage!ccFrame.action?pgmode1=prod&"
	    				    +"locationName="+locationName
	    				    +"&sid=" + siteId
	    				    +"&reportCCType=Y&reportCCDigits=Y&reportCVVDigits=Y"
	    				    +"&fullParentHost=" + fullParentHost
	    				    +"&fullParentQStr=" + fullParentQStr;
	    			document.getElementById("ccframe").src=hpciCCFrameFullUrl;    			
	    			console.log("hpciCCFrameFullUrl: " + hpciCCFrameFullUrl);
	    	});
	    
		jQuery("#ccTokenizeBtn").click(function(){
			sendHPCIMsg();
		});
		
		jQuery('#ccTokenizeResetBtn').click(function resetPayment() {
			jQuery('#trSummary1').val("");
			jQuery("#ccframe").attr("src", jQuery("#ccframe").attr("src"));
			jQuery('#ccNum').val("");
			jQuery('#ccCVV').val("");
			jQuery('#ccBIN').val("");
			jQuery('#paymentMsgDispatch_form').trigger("reset");
			populateFileField();
			jQuery('#paymentMsgDispatch_result').val("");
			hpciStatusReset();
		});
		
		jQuery("#paymentMsgDispatchBtn").click(function(){
			var 	 merchantRefId = new Date().valueOf();
			
	        var file = jQuery("#paymentMsgDispatch_file").val();
	        
	        re = /CURRENCY_PLACE_HOLDER/gi;
	        file = file.replace(re, jQuery("#currency_paymentMsgDispatch").val());
	        re = /CURRENCY_CODE_PLACE_HOLDER/gi;
	        file = file.replace(re, jQuery("#currency_paymentMsgDispatch").val());
	        re = /RANDOM_REF_ID_PLACE_HOLDER/gi;
	        file = file.replace(re, merchantRefId);
	        re = /AMOUNT_PLACE_HOLDER/gi;
	        file = file.replace(re, jQuery("#amount_paymentMsgDispatch").val());
	        
	        jQuery.post(
	        		"PaymentMsgDispatchServlet",
				{
					"dispatchRequest.profileName" : jQuery("#paymentProfile_paymentMsgDispatch").val(),
					"dispatchRequest.contentType": "xml",
					"ccMsgToken": jQuery("#ccParamCcMsgToken").val(),
					"ccToken": jQuery("#paymentMsgDispatchCcToken").val(),
					"cvvMsgToken": jQuery("#ccParamCvvMsgToken").val(),
					"cvvToken": jQuery("#paymentMsgDispatchCvvToken").val(),
					"dispatchRequest.request": file
				},
				function(data) {
					//parse the result
					var resultMap = parseQueryString(data, '&', '=');

					if (data != undefined) {
						jQuery("#paymentMsgDispatch_result").val(
								"Processing the payment message DISPATCH API call.."
								+ "\r\n"
								+ "Transaction result: "
								+ resultMap["status"]
								+ "\r\n"
								+ "Full log: \r\n"
								+ decodeURIComponent(decodeURIComponent(data)));
							jQuery("#paymenMsgDispatch_full_log").val(data);
					}
				});
		});
	});
</script>
</head>
<body>
	<div class="container">
		<div id = "modal" style="display: none">
			<div id = "loader"></div>
		</div>
		<div class="demo-navbar">
			<div class="row">
				<ul>
					<li><a href="home.jsp">Home</a></li>
					<li><a id = "hostedPCI" href="http://www.hostedpci.com/"></a></li>
				</ul>
			</div>
		</div>
		<div class="payment-msg-dispatch-wizard">
			<div class="form-section">
				<div class="row">
					<div class="col-xs-6">
							<fieldset>
								<legend>STEP 1 - CC/CVV TOKENIZATION</legend>					
								<div id="errorMessage" style="display: none; color: red">
									<label>Invalid card number, try again</label><br />
								</div>
								
								<div class="form-group">
								<div class="col-xs-12">
									<iframe seamless id="ccframe" name="ccframe"
											onload="receiveHPCIMsg()" src=""
											style="border: none; max-width: 800px; min-width: 70px; width: 100%"
											height="140"> If you can see this, your browser
														doesn't understand IFRAME. 
									</iframe>
									</div>					
								</div>
								<div class="form-group">
									<div class="col-xs-12">
										<i id="visa" class="fa fa-cc-visa"></i>
										<i id="mastercard" class="fa fa-cc-mastercard"></i>
										<i id="amex" class="fa fa-cc-amex"></i>
										<i id="discover" class="fa fa-cc-discover"></i>
										<i id="jcb" class="fa fa-cc-jcb"></i>
									</div>
								</div>
								<div class = "form-group">
									<div class=" col-xs-6">
										<button type="button" id="ccTokenizeBtn" class="btn btn-primary btn-lg">Tokenize</button>
									</div>
									<div class=" col-xs-6">
										<button type="button" id="ccTokenizeResetBtn" class="btn btn-primary btn-lg">Reset form</button>
									</div>
								</div>
								<div class="form-group">
									<div class="col-xs-6 col-sm-3 col-md-4">
										<input type="hidden" id="ccNum" name="ccNum" > 
										<input type="hidden" id="ccCVV" name="ccCVV" >
										<input type="hidden" id="ccBIN" name="ccBIN" >
									</div>
								</div>
							</fieldset>
					</div>
					<div class="col-xs-6">
					    <div class="form-group">
					      <label for="trSummary1">Result:</label>
					      <textarea class="form-control" rows="14" id="trSummary1"></textarea>
					    </div>
					</div>
				</div>
			</div>
			<div class="form-section">
				<div class="row">
					<div class="col-xs-6">
						<div class="col-xs-12">
							<form class="form-horizontal" id = "paymentMsgDispatch_form">
								<fieldset>
									<legend>STEP 2 - PAYMENT MESSAGE DISPATCH API</legend>
									<div class="input-group"> 
										<span class="input-group-addon">Payment Profile</span>
										<input id="paymentProfile_paymentMsgDispatch" type="text" class="form-control" name="paymentProfile_paymentMsgDispatch"
											value = "DISPATCHDATACASH">
									</div>
									<div class = "input-group">
										<span class="input-group-addon">Currency</span>
										<input id="currency_paymentMsgDispatch" type="text" class="form-control" name="currency_paymentMsgDispatch"
											value="GBP">
									</div>
									<div class="input-group"> 
										<span class="input-group-addon">Payment Amount</span>
										<input id="amount_paymentMsgDispatch" type="text" class="form-control" name="amount_paymentMsgDispatch">
									</div>
									<div class = "input-group">
										<span class="input-group-addon">Credit card token</span>
										<input id="paymentMsgDispatchCcToken" type="text" class="form-control" name="paymentMsgDispatchCcToken">
									</div>
									<div class = "input-group">
										<span class="input-group-addon">CVV token</span>
										<input id="paymentMsgDispatchCvvToken" type="text" class="form-control" name="paymentMsgDispatchCvvToken">
									</div>
									<div class = "input-group">
										<span class="input-group-addon">CC message placeholder </span>
										<input id="ccParamCcMsgToken" type="text" class="form-control" name="ccParamCcMsgToken"
												value="%%CC%%">
									</div>
									<div class = "input-group">
										<span class="input-group-addon">CCV message placeholder</span>
										<input id="ccParamCvvMsgToken" type="text" class="form-control" name="ccParamCvvMsgToken"
												value="%%CVV%%">
									</div>
									<div class="input-group">
										<span class="input-group-addon">File</span>
										<textarea class="form-control" rows="5" id="paymentMsgDispatch_file">
										</textarea>
									</div>
									<div class = "form-group">
										<div class=" col-xs-6">
											<button type="button" id="paymentMsgDispatchBtn" class="btn btn-primary btn-lg">Dispatch</button>
										</div>
									</div>
									<div class="form-group">
										<input type="hidden" id="paymenMsgDispatch_full_log" name="paymenMsgDispatch_full_log"> 
									</div>
								</fieldset>
							</form>
						</div>
					</div>
					<div class="col-xs-6">
						<form>
						    <div class="form-group">
						      <label for="paymentMsgDispatch_result">Result:</label>
						      <textarea class="form-control" rows="16" id="paymentMsgDispatch_result"></textarea>
						    </div>
						</form>
					</div>
				</div>
			</div>
			<div class="form-navigation">
		    		<button type="button" class="previous btn btn-info pull-left">&lt; Previous</button>
		    		<button type="button" class="next btn btn-info pull-right">Next &gt;</button>
		    		<span class="clearfix"></span>
		    </div>
		</div>
	</div>
</body>
</html>