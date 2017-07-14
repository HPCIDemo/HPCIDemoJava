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
<script src="js/jquery-2.1.1.js" type="text/javascript"></script>
</head>
<body>
<div class="container">
	<div class="row">
		<div class="col-md-7 col-centered">
			<form id="paymentForm">
				<fieldset class="fieldset">
					<legend>HostedPCI Demo App For Java</legend><br />
					<fieldset >
						<!-- <legend>Session Information</legend> -->
						<div class="row">
							<div class="col-xs-6 col-sm-4 col-md-5 col-centered">
								<!-- Link to iframe demo app -->
								<a href="/webCheckoutForm.jsp" role="button" class="btn btn-primary">Standard iFrame</a>
								<br /><br />
								<!-- Link to iframe3dsec demo app -->
								<a href="/webCheckoutForm3DSec.jsp" role="button" class="btn btn-primary">iFrame 3D Secure</a>
								<br /><br />
								<!-- Link to IVR demo app -->
								<a href="/phoneSession.jsp" role="button" class="btn btn-primary">Phone/Call Center (IVR)</a>
								<br /><br />
								<!-- Link to Multiple Iframes demo app -->
								<a href="/webCheckoutMultipleIframes.jsp" role="button" class="btn btn-primary">Multiple iFrames </a>
								<br /><br />
								<!-- Link to CvvOnly Iframe demo app -->
								<a href="/webCheckoutCvvOnlyIframe.jsp" role="button" class="btn btn-primary">Cvv only iFrame</a>
								<br /><br />
								<!-- Link to iframe Gateway tokenization demo app -->
								<div id ="iframe-tokenization">
									<a href="/iframeGatewayTokenization.jsp" role="button" class="btn btn-primary">Iframe Gateway Tokenization</a>
									<br /><br />
								</div>
								<!-- Link to Gateway tokenization demo app -->
								<a href="/gatewayTokenization.jsp" role="button" class="btn btn-primary">Gateway Tokenization</a>
								<br /><br />
								<!-- Link to File dispatch demo app -->
								<a href="/fileDispatch.jsp" role="button" class="btn btn-primary">File Dispatch</a>
								<br /><br />
								<!-- Link to Xml file dispatch demo app -->
								<a href="/paymentMsgDispatch.jsp" role="button" class="btn btn-primary">Xml Dispatch</a>
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