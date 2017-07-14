<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>HostedPCI Demo App CvvOnly iFrame</title>
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
var hpciCCFrameName = "ccframe1"; // use the name of the frame containing the credit card
var hpciCCFrameFullUrl;
var stepCounter = 0;
var iframes;
var siteId;
var locationName;
var cvvOnlyLocationName;
var fullParentQStr;
var fullParentHost;
//Notify when the tokenization process is finished.
var deferred;

var hpciSiteErrorHandler = function(errorCode, errorMsg) {
	// Please the following alert to properly display the error message
	//alert("Error while processing credit card code:" + errorCode + "; msg:"	+ errorMsg);
	document.getElementById('errorMessage' + (stepCounter + 1)).style.display = 'block';
	
	return deferred.reject();
}

var hpciSiteSuccessHandlerV2 = function(mappedCCValue, mappedCVVValue, ccBINValue) {
	// Please pass the values to the document input and then submit the form
	
	// No errors from iframe so hide the errorMessage div
	document.getElementById('errorMessage' + (stepCounter + 1)).style.display = 'none';
	// Name of the input (hidden) field required by ecommerce site
	// Typically this is a hidden input field.
	var ccNumInput = jQuery('#ccNum' + (stepCounter + 1));
	ccNumInput.val(mappedCCValue);

	// Name of the input (hidden) field required by ecommerce site
	// Typically this is a hidden input field.
	var ccCVVInput = jQuery('#ccCVV' + (stepCounter + 1));
	ccCVVInput.val(mappedCVVValue);

	// Name of the input (hidden) field required by ecommerce site
	// Typically this is a hidden input field.
	var ccBINInput = jQuery('#ccBIN' + (stepCounter + 1));
	ccBINInput.val(ccBINValue);

	console.log("Tokenization success Handler: step" + (stepCounter + 1));
	jQuery('#trSummary' + (stepCounter + 1)).val(
			jQuery('#trSummary' + (stepCounter + 1)).val()
					+ "Tokenize iframe " + (stepCounter + 1) + ", id: " + iframes[stepCounter].id + "." + "\n"
					+ "Credit card token: " + jQuery('#ccNum' + (stepCounter + 1)).val() + "." + "\n"
					+ "CVV card token: " + jQuery('#ccCVV' + (stepCounter + 1)).val() + "." + "\n");
	
	if (hasNextIframe()) {
		setNextIframe();
	}
	
	deferred.resolve();

	return false;
}

function setNextIframe() {	
	hpciCCFrameName = iframes[stepCounter].id;
	hpciStatusReset();
}

function hasNextIframe() {
	return (++stepCounter < iframes.length) ? stepCounter : false;
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

jQuery(document).ready(function() {
    var flag = "config";
	
	$(document).ajaxSend(function(event, request, settings) {
		jQuery('#modal').show();
	});
	$(document).ajaxComplete(function(event, request, settings) {
		jQuery('#modal').hide();
	});

//	///////// Wizard navigation ////////////
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
	   var ccToken = jQuery('#ccNum' + (curIndex()+1)).val();
	   
	   if(ccToken){
		   if (jQuery('.cvvonly-wizard').parsley().validate({group: 'block-' + curIndex()}))
			   navigateTo(curIndex() + 1);
	   }
	});
	// Prepare sections by setting the `data-parsley-group` attribute to 'block-0', 'block-1', etc.
	$sections.each(function(index, section) {
		jQuery(section).find(':input').attr('data-parsley-group', 'block-' + index);
	});
    navigateTo(0); // Start at the beginning
//	//////////////////////////////End Wizard navigation/////////////////////////// 
	jQuery.get("CvvOnlyServlet",
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
    			cvvOnlyLocationName = resultMap["cvvOnlyLocationName"];
    			fullParentQStr = location.pathname;
    			fullParentHost = location.protocol.concat("//") + window.location.hostname +":" +location.port;
    			hpciCCFrameHost = resultMap["serviceUrl"];
    			
    			console.log(location.protocol.concat("//") + window.location.hostname +":" +location.port);
    			console.log(location.pathname);
    			console.log("SiteId :" + siteId);
    			console.log("LocationName :" + locationName);
    			console.log("CvvOnlyLocationName :" + cvvOnlyLocationName);
    			hpciCCFrameFullUrl = hpciCCFrameHost + "/iSynSApp/showPxyPage!ccFrame.action?pgmode1=prod&"
    				    +"locationName="+locationName
    				    +"&sid=" + siteId
    				    +"&fullParentHost=" + fullParentHost
    				    +"&fullParentQStr=" + fullParentQStr;
    			document.getElementById("ccframe" + (stepCounter + 1) ).src=hpciCCFrameFullUrl;  
    			
    			iframes = jQuery("iframe");
    			console.log("hpciCCFrameName: " + hpciCCFrameName);
    			console.log("hpciCCFrameFullUrl:\n" + hpciCCFrameFullUrl);
    		});
	
	jQuery('#ccTokenizeBtn').click(function () {
		deferred = $.Deferred();
		
		deferred.done(
				function() {
					//Set step 2: cvvonly iframe 
					hpciCCFrameFullUrl = hpciCCFrameHost + "/iSynSApp/showPxyPage!ccFrame.action?pgmode1=prod&"
				    +"locationName=" + cvvOnlyLocationName 
				    +"&sid=" + siteId
				    +"&ccNumToken=" + jQuery('#ccNum' + (stepCounter)).val()
				    +"&ccNumTokenIdx=" + (stepCounter + 1)
				    +"&enableTokenDisplay=Y"
				    +"&fullParentHost=" + fullParentHost
				    +"&fullParentQStr=" + fullParentQStr;
					document.getElementById("ccframe" + (stepCounter + 1)).src=hpciCCFrameFullUrl;  
					
					hpciCCFrameName = "ccframe" + (stepCounter + 1);
					console.log("hpciCCFrameName: " + hpciCCFrameName);
					console.log("hpciCCFrameFullUrl:\n" + hpciCCFrameFullUrl);
				}).fail(
				function() {
					jQuery('#trSummary' + (stepCounter + 1)).html(
							jQuery('#trSummary' + (stepCounter + 1)).html()
									+ 'Error tokenizing a credit card.'
									+ "<br/>");
				});
		
		sendHPCIMsg();
		
	});	
	
	jQuery('#ccTokenizeResetBtn').click(function resetPayment() {
		jQuery('#trSummary1').val("");
		jQuery("#ccframe1").attr("src", jQuery("#ccframe1").attr("src"));
		jQuery('#ccNum1').val("");
		jQuery('#ccCVV1').val("");
		jQuery('#ccBIN1').val("");
	});	
	
	jQuery('#ccCVVOnlyTokenizeBtn').click(function () {
		sendHPCIMsg();
		jQuery("#ccNum_auth").val(jQuery('#ccNum' + (stepCounter)).val());
		jQuery("#ccCVV_auth").val(jQuery('#ccCVV' + (stepCounter)).val());
	});	
	
	jQuery('#ccCVVOnlyTokenizeResetBtn').click(function resetPayment() {
		jQuery('#trSummary2').val("");
		jQuery("#ccframe2").attr("src", jQuery("#ccframe2").attr("src"));
		jQuery('#ccNum2').val("");
		jQuery('#ccCVV2').val("");
		jQuery('#ccBIN2').val("");
	});
	
	jQuery("#authBtn").click(function(){	
		var 	 merchantRefId = new Date().valueOf();
		jQuery("#authMerchantRefId").val(merchantRefId);
		
		jQuery.post(
				"CvvOnlyServlet",
				{
					"ccNum" : jQuery("#ccNum_auth").val(),
					"ccCVV" : jQuery("#ccCVV_auth").val(),
					"amount" : jQuery("#amount_auth").val(),
					"merchantRefId" : merchantRefId,
					"currency" : jQuery("#currency_auth").val(),
					"paymentProfile" : jQuery("#paymentProfile_auth").val() ,
					"expiryMonth" : jQuery("#expiryMonth_auth").val(),
					"expiryYear" : jQuery("#expiryYear_auth").val()
				},
				function(data) {
					//parse the result
					var resultMap = parseQueryString(data);

					if (data != undefined) {
						jQuery("#auth_result").val(
							"Processing the payment AUTH API call.."
							+ "\r\n"
							+ "Transaction result: "
							+ resultMap["status"]
							+ "\r\n"
							+ "Full log: \r\n"
							+ decodeURIComponent(decodeURIComponent(data)));
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
		<form class="cvvonly-wizard">
			<div class="form-section">
				<div class="row">
					<div class="col-xs-6">
							<fieldset>
								<legend>STEP 1 - CC/CVV TOKENIZATION</legend>					
								<div id="errorMessage1" style="display: none; color: red">
									<label>Invalid card number, try again</label><br />
								</div>
								<div class="input-group">
									<iframe seamless id="ccframe1" name="ccframe1"
											onload="receiveHPCIMsg()" src=""
											style="border: none; max-width: 800px; min-width: 70px; width: 100%"
											height="140"> If you can see this, your browser
														doesn't understand IFRAME. 
									</iframe>					
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
										<input type="hidden" id="ccNum1" name="ccNum1" > 
										<input type="hidden" id="ccCVV1" name="ccCVV1" >
										<input type="hidden" id="ccBIN1" name="ccBIN1" >
									</div>
								</div>
							</fieldset>
					</div>
					<div class="col-xs-6">
					    <div class="form-group">
					      <label for="trSummary1">Result:</label>
					      <textarea class="form-control" rows="12" id="trSummary1"></textarea>
					    </div>
					</div>
					
				</div>
			</div>
			<div class="form-section">
				<div class="row">
					<div class="col-xs-6">
						<fieldset>
							<legend>STEP 2 - CVV TOKENIZATION</legend>					
							<div id="errorMessage2" style="display: none; color: red">
								<label>Invalid card number, try again</label><br />
							</div>
							<div class="input-group">
								<iframe seamless id="ccframe2" name="ccframe2"
										onload="receiveHPCIMsg()" src=""
										style="border: none; max-width: 800px; min-width: 70px; width: 100%"
										height="140"> If you can see this, your browser
													doesn't understand IFRAME. 
								</iframe>					
							</div>
							<div class = "form-group">
								<div class=" col-xs-6">
									<button type="button" id="ccCVVOnlyTokenizeBtn" class="btn btn-primary btn-lg">Tokenize</button>
								</div>
								<div class=" col-xs-6">
									<button type="button" id="ccCVVOnlyTokenizeResetBtn" class="btn btn-primary btn-lg">Reset form</button>
								</div>
							</div>
							<div class="form-group">
								<div class="col-xs-6 col-sm-3 col-md-4">
									<input type="hidden" id="ccNum2" name="ccNum2" > 
									<input type="hidden" id="ccCVV2" name="ccCVV2" >
									<input type="hidden" id="ccBIN2" name="ccBIN2" >
								</div>
							</div>
						</fieldset>
					</div>
					<div class="col-xs-6">
					    <div class="form-group">
					      <label for="trSummary2">Result:</label>
					      <textarea class="form-control" rows="10" id="trSummary2"></textarea>
					    </div>
					</div>
				</div>
			</div>
			<div class="form-section">
				<div class="row">
					<div class="col-xs-6">
						<fieldset>
							<legend>STEP 3 - AUTH API</legend>
							<div class = "form-group">
								<div class="col-xs-offset-2 col-xs-2">
									<select id="expiryMonth_auth" name="expiryMonth_auth"
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
								<div class="col-xs-offset-2 col-xs-2 ">
									<select id="expiryYear_auth" name="expiryYear_auth"
											class="selectpicker">
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
										<option value="27">2027</option>
										<option value="28">2028</option>
									</select>
								</div>
							</div>
							<div class="input-group"> 
								<span class="input-group-addon">Payment Profile</span>
								<input id="paymentProfile_auth" type="text" class="form-control" name="paymentProfile_auth"
									value="DEF">
							</div>
							<div class = "input-group">
								<span class="input-group-addon">Currency</span>
								<input id="currency_auth" type="text" class="form-control" name="currency_auth"
									value="CAD">
							</div>
							<div class="input-group"> 
								<span class="input-group-addon">Payment Amount</span>
								<input id="amount_auth" type="text" class="form-control" name="amount_auth">
							</div>
							<div class = "input-group">
								<span class="input-group-addon">Merchant referenceId</span>
								<input id="authMerchantRefId" type="text" class="form-control" name="authMerchantRefId">
							</div>
							
							<div class="form-group">
							
								<div class="col-xs-6 col-sm-3 col-md-4">
									<input type="hidden" id="ccNum_auth" name="ccNum_auth" > 
									<input type="hidden" id="ccCVV_auth" name="ccCVV_auth" >
									<input type="hidden" id="ccBIN_auth" name="ccBIN_auth" >
								</div>
							</div>
							<div class = "form-group">
								<div class=" col-xs-6">
									<button type="button" id="authBtn" class="btn btn-primary btn-lg">Payment Auth</button>
								</div>
								<div class=" col-xs-6">
									<button type="button" id="authResetBtn" class="btn btn-primary btn-lg">Reset form</button>
								</div>					
							</div>
						</fieldset>
					</div>
					<div class="col-xs-6">
				    <div class="form-group">
						<label for="auth_result">Result:</label>
					    <textarea class="form-control" rows="14" id="auth_result"></textarea>
				    </div>
			</div>
				</div>
			</div>	
			<div class="form-navigation">
		    		<button type="button" class="previous btn btn-info pull-left">&lt; Previous</button>
		    		<button type="button" class="next btn btn-info pull-right">Next &gt;</button>
		    		<span class="clearfix"></span>
		    </div>
		</form>
	</div>
</body>
</html>