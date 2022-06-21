<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE HTML>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Hosted PCI Demo App for Java</title>
<!-- Bootstrap -->
<link href="https://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap.min.css" rel="stylesheet">
<link href="https://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap-theme.min.css" rel="stylesheet">
<link href="css/home.css" rel="stylesheet">
<link rel="shortcut icon" href="./favicon-new.png">
<script src="js/jquery-2.1.1.js" type="text/javascript"></script>
</head>
<body>
<div class="container">
	<div class="row">
		<div class="col-md-7 col-lg-10 col-centered">
			<form id="paymentForm">
				<fieldset class="fieldset">
					<legend>HostedPCI Demo App For Java</legend><br />
					<fieldset >
						<!-- <legend>Session Information</legend> -->
						<div class="row">
							<div class="col-xs-6 col-sm-4 col-md-5 text-center col-centered">
								<!-- Standart iframe -->
								<a href="./webCheckoutForm.jsp" role="button" class="btn btn-primary">Standard iframe</a>
								<br /><br />
								<!-- 3DSecure iframe -->
								<a href="./webCheckoutForm3DSec.jsp" role="button" class="btn btn-primary">3D Secure iframe</a>
								<br /><br />
								<!-- Autofill iframe -->
								<a href="./iframeAutofill.jsp" role="button" class="btn btn-primary">Autofill checkout</a>
								<br /><br />
								<!-- Multiple iframes -->
								<a href="./webCheckoutMultipleIframes.jsp" role="button" class="btn btn-primary">Multiple iframes</a>
								<br /><br />
								<!-- Split mode -->
								<a href="./iframeSplitMode.jsp" role="button" class="btn btn-primary">Split mode iframe</a>
								<br /><br />
								<!-- CvvOnly iframe -->
								<a href="./webCheckoutCvvOnlyIframe.jsp" role="button" class="btn btn-primary">Cvv only iframe</a>
								<br /><br />
								<!-- ACH iframe -->
								<a href="./iframeACH.jsp" role="button" class="btn btn-primary">ACH iframe</a>
								<br /><br />
								<!-- Iframe Gateway tokenization -->
								<div id ="iframe-tokenization">
									<a href="./iframeGatewayTokenization.jsp" role="button" class="btn btn-primary">Iframe gateway tokenization</a>
									<br /><br />
								</div>
								<!-- IVR -->
								<a href="./phoneSession.jsp" role="button" class="btn btn-primary">Phone/Call center (IVR)</a>
								<br /><br />
								<!-- Gateway tokenization -->
								<a href="./gatewayTokenization.jsp" role="button" class="btn btn-primary">Gateway tokenization</a>
								<br /><br />
								<!-- File dispatch -->
								<a href="./fileDispatch.jsp" role="button" class="btn btn-primary">File dispatch</a>
								<br /><br />
								<!-- XML file dispatch -->
								<a href="./paymentMsgDispatch.jsp" role="button" class="btn btn-primary">XML dispatch</a>
							</div>
						</div>
					</fieldset>
				</fieldset>
			</form>
		</div><!-- col-md-7 col-centered -->
	</div><!-- row -->
</div><!-- container -->
</body>
</html>