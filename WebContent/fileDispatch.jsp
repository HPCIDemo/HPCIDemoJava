<html>
<head>
<meta charset="utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport" content="width=device-width, initial-scale=1">

<title>HostedPCI Demo App File Dispatch</title>
<!-- Bootstrap -->
<link href="https://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap.min.css" rel="stylesheet">
<link href="https://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap-theme.min.css" rel="stylesheet">

<!-- Font-Awesome -->
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/font-awesome/4.4.0/css/font-awesome.min.css">

<link href="css/checkout.css" rel="stylesheet">

<script src="js/jquery-2.1.1.js" type="text/javascript" charset="utf-8"></script>
<script>
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
	
</script>
<script type="text/javascript">
jQuery(document).ready(function() {	
    var paymentProfile;
    var flag = "config";
    var content;
    
    jQuery('#filedispatchBtn').attr("disabled", true);
    
    jQuery(document).ajaxSend(function(event, request, settings) {
		jQuery('#modal').show();
	});
    
    jQuery(document).ajaxComplete(function(event, request, settings) {
		jQuery('#modal').hide();
	});
    
    jQuery.get("FileDispatchServlet",
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
	        jQuery('#filedispatchBtn').attr("disabled", false);
    		});
        
        file.dom.on("change", function (evt) {
	        if(reader.readyState === FileReader.LOADING) {
	          reader.abort();
	        }
	        
	        reader.readAsBinaryString(evt.target.files[0]);
	    });
        
    });
    
    jQuery("#filedispatchBtn").click(function(){
        var blob = new Blob([content], { type: "text/plain"});
        
        var formData = new FormData();
        formData.append("tokenFile", blob, "data.csv");
        formData.append("dispatchRequest.destFileName", "data.csv");
        formData.append("dispatchRequest.profileName" , jQuery("#paymentProfile").val());
        
        jQuery.ajax({
			  url: "FileDispatchServlet",
			  type: "POST",
			  data: formData,
			  processData: false,  // tell jQuery not to process the data
			  contentType: false   // tell jQuery not to set contentType
			}).done(function(data) {
				jQuery('#checkout').hide();
				jQuery('#trSummary').show();
				console.log(data);
			    //parse the result
			    var resultMap = parseQueryString(data, '&', '=');
				if (data != undefined) {
					 jQuery("#result").html(
							 "Status: " + resultMap["status"] + "<br/>"
							 + "Description: " + resultMap["pxyResponse.responseStatus"] + "<br/>"
							 + "AuthId: " + resultMap["authId"] + "<br/>"
							 + "File rows count: " + resultMap["pxyResponse.fileRowCount"]);
					jQuery("#message").html("Full Message: " + "<br/>" + data);
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
	
	jQuery('#noButton').click(function(){
		jQuery('#message').hide('slow');
	});
	
	jQuery('#yesButton').change(function(){
		jQuery('#message').show('slow');
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
			<form id="CCAcceptForm" action="/IframeServlet" method="post" class="form-horizontal">
				<fieldset id = "checkout">
					<!-- Form Name -->
					<legend>File Dispatch</legend>
					<fieldset>
						<div class="booking-form__field form-group">
							<div class="col-xs-4 col-sm-3 col-md-4">
								<label for ="paymentProfile">Payment Profile:</label>
								<select id="paymentProfile" name="paymentProfile">									
								</select>
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
								<button type="button" id="filedispatchBtn" class="btn btn-primary">Send file</button>
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
					<label>Show Full Message?</label><br />
					<input id ="noButton" type = "radio" name="yesNoButton" checked="checked"/>
					<label for = "noButton">No</label>
					<input id="yesButton" type="radio" name="yesNoButton" />
					<label for = "yesNoButton">Yes</label>
					<div id = "message" style="word-wrap: break-word;">
					</div><br/><br/>
					<br /> <input Type="button"  id = "backBtn" class="btn btn-primary" value="Back"></input><br />					
				</fieldset>
			</form>		
		</div><!-- col-md-7 col-centered -->
	</div><!-- form-group -->
</div><!-- container -->
</body>
</html>