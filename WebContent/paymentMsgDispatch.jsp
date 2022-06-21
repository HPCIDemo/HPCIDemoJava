<html>
<head>
<meta charset="utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport" content="width=device-width, initial-scale=1">

<title>HostedPCI Demo App Payment Message Dispatch</title>
<!-- Bootstrap -->
<link href="https://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap.min.css" rel="stylesheet">
<link href="https://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap-theme.min.css" rel="stylesheet">

<!-- Font-Awesome -->
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/font-awesome/4.4.0/css/font-awesome.min.css">
<link href="css/checkout.css" rel="stylesheet">
<link rel="shortcut icon" href="./favicon-new.png">
<script src="js/jquery-2.1.1.js" type="text/javascript" charset="utf-8"></script>
<script>
	function parseQueryString(data, split, separator) {
		//parse the result
		var resultMap = [], queryToken;

		queryTokenList = data.split(split);
		for (var i = 0; i < queryTokenList.length; i++) {
			queryToken = queryTokenList[i].split(separator);
			resultMap.push(queryToken[1]);
			let tokenValue = "";
			if(queryToken[1] != undefined && queryToken[1] != "")
				tokenValue = decodeURIComponent(queryToken[1].replace(/\+/g,  " "))
			resultMap[queryToken[0]] = tokenValue;
		}

		return resultMap;
	}
	
</script>
<script type="text/javascript">
jQuery(document).ready(function() {	
    var paymentProfile;
    var currency;
    var ccNum;
    var flag = "config";
    var content;
    
    jQuery('#paymentMsgDispatchBtn').attr("disabled", true);
    
    jQuery(document).ajaxSend(function(event, request, settings) {
		jQuery('#modal').show();
	});
    
    jQuery(document).ajaxComplete(function(event, request, settings) {
		jQuery('#modal').hide();
	});
    
    jQuery.get("PaymentMsgDispatchServlet",
    	    {
    			flag:flag,
    		},
    		function(data){
    			//parse the result
    		    var resultMap = parseQueryString(data, ',', ';');
    		    
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
    			ccNum = resultMap["ccNum"];
    			if(ccNum){    				
    				queryTokenList = ccNum.split('/');
    				queryToken = queryTokenList[0].split('=');
    				jQuery('#ccNum').val(queryToken[0]);
    				jQuery('#ccButtonLabel').html(queryToken[0]);
    				jQuery('#ccCVV').val(queryToken[1]);
    			}
    			
    			console.log("Currency:" + currency);
    			console.log("Payment Profiles:" + paymentProfile);
    			console.log("CC number: " + ccNum);
    	});
    
    jQuery("#file").click(function(){
        var preview = jQuery("#preview");
        var file = {
        		dom    : jQuery("#file"),
            binary: null
          };
        
     	// Use the FileReader API to access file content
	    var reader = new FileReader();
        reader.addEventListener("load", function () {
	        file.binary = reader.result;
	        content = file.binary;
	        jQuery("#preview").val(content);
	        jQuery('#paymentMsgDispatchBtn').attr("disabled", false);
    		});
        
        file.dom.on("change", function (evt) {
	        if(reader.readyState === FileReader.LOADING) {
	          reader.abort();
	        }
	        
	        reader.readAsBinaryString(evt.target.files[0]);
	    });
        
    });
    
    
    jQuery("#paymentMsgDispatchBtn").click(function(){
		var 	 merchantRefId = new Date().valueOf();
		
        var file = jQuery("#preview").val();
        
        re = /RANDOM_REF_ID_PLACE_HOLDER/gi;
        file = file.replace(re, merchantRefId);
        
        jQuery.post(
        		"PaymentMsgDispatchServlet",
			{
				"dispatchRequest.profileName" : jQuery("#paymentProfile").val(),
				"currency" : jQuery("#currency option:selected").val(),
				"dispatchRequest.contentType": "xml",
				"ccMsgToken": '%%CC%%',
				"ccToken": jQuery("#ccNum").val(),
				"cvvMsgToken": '%%CVV%%',
				"cvvToken": jQuery("#ccCVV").val(),
				"dispatchRequest.request": file
			},
			function(data) {
				jQuery('#checkout').hide();
				jQuery('#trSummary').show();
				console.log(data);
				if (data != undefined) {
					//parse the result
					var resultMap = parseQueryString(data, '&', '=');
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
    										+ "Description: " + resultMap["pxyResponse.responseStatus"] + "<br/>"
							 				+ "AuthId: " + resultMap["authId"] + "<br/>";
    					}
					}
					jQuery("#result").html(displayMessage);
					jQuery("#message").html("Full Message: " + "<br/>" 
							+ data);
					if(resultMap["pxyResponse.dispatchResp"] != undefined && resultMap["pxyResponse.dispatchResp"] != "")
						console.log("Gateway response: " + decodeURIComponent(decodeURIComponent(resultMap["pxyResponse.dispatchResp"])));
				}else{
					jQuery("#result").html(
							 "Status: undefined" +"<br/>"
							 + "Description: error processing transaction");
				}
			});
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
				<fieldset id = "checkout">
					<!-- Form Name -->
					<legend>Message Dispatch</legend>
					<fieldset>
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
						<div class="booking-form__field form-group">
							<div class="col-xs-4 col-sm-3 col-md-4">
								<label>Select credit card:</label><br/>
							</div>
							<div class="col-xs-4 col-sm-3 col-md-5">
								<input id = "creditButton" type = "radio" name="creditButton" checked/>
								<label id = "ccButtonLabel" for = "creditButton"></label>
							</div>
						</div>
						<div class="booking-form__field form-group">
							<div class="col-xs-4 col-sm-3 col-md-5">
								<input type="file" name="file" id="file" required />
							</div>
						</div>
						<div class = "booking-form__field form-group">
							<div class=" col-xs-6 col-sm-3 col-md-4">
								<textarea id="preview" cols="60" rows="10" 
									placeholder = "Preview..."></textarea>
							</div>
						</div>
						<div class = "booking-form__field form-group">
							<div class=" col-xs-6 col-sm-3 col-md-4">
								<button type="button" id="paymentMsgDispatchBtn" class="btn btn-primary">Send file</button>
							</div>
						</div>
						<br />
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
				<div class="form-group">
					<!-- Hidden form-groups that are required by the iframe -->
					<div class="col-xs-6 col-sm-3 col-md-4">
						<input type="hidden" id="ccNum" name="ccNum" value="" class="form-control"> 
						<input type="hidden" id="ccCVV" name="ccCVV" value="" class="form-control"> 
						<input type="hidden" id="ccBIN" name="ccBIN" value="" class="form-control">
					</div>
				</div>
			</form>
		</div><!-- col-md-7 col-centered -->
	</div><!-- form-group -->
</div><!-- container -->
</body>
</html>