<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE HTML>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>HostedPCI Demo App Confirmation Page</title>
<!-- Bootstrap 3.2.0-->
<link href="https://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap.min.css" rel="stylesheet">
<link href="http://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap-theme.min.css" rel="stylesheet">
<link href="css/template.css" rel="stylesheet">

<script src="js/jquery-2.1.1.js" type="text/javascript" charset="utf-8"></script>
<script src="https://cc.hostedpci.com/WBSStatic/site60/proxy/js/jquery.ba-postmessage.2.0.0.min.js" type="text/javascript" charset="utf-8"></script>
<script type="text/javascript">
$(document).ready(function () {
	$('#noButton').click(function () {
		$('#message').hide('slow');
	});
	$('#yesButton').click(function () {
		$('#message').show('slow');
	});
});
</script>
</head>
<body>
<!-- container class sets the page to use 100% width -->
<div class="container">
	<!-- row class sets the margins -->
	<div class="row">
		<!-- col-md-7 col-centered class uses the bootstrap grid system to use 7/12 of the screen and place it in the middle -->
		<div class="col-md-7 col-centered">
			<form>
				<section style="margin: 10px;">
					<fieldset style="min-height: 100px;">
						<!-- Form Name -->
						<legend>Web Checkout</legend>
						<!-- Text Input -->
						<div>
							Dear Hosted PCI Customer,<br /> Thank you for trying our
							services. If you have any questions, please contact us at
							www.hostedpci.com<br />
							<br /> <label>Transaction Summary</label><br /> <label>*******************</label><br />
							<!-- Gets responseStatus from the response map that the iframe sent back -->
							<label>Status: <c:out value="${map['pxyResponse.responseStatus.name']}" /></label><br />
							<!-- Gets description from the response map that the iframe sent back -->
							<label>Description: <c:out value="${map['pxyResponse.responseStatus.description']}" /></label><br />
							<!-- Gets processorRefId from the response map that the iframe sent back -->
							<label>Processor Reference ID: <c:out value="${map['pxyResponse.processorRefId']}" /></label><br />
							<!-- Gets merchantRefId from the response map that the iframe sent back -->
							<label>Merchant ID: <c:out value="${globalMap['merchantRefId']}" /></label><br />
							<!-- Gets cardType from the user input on previous page -->
							<c:set var="mappedParams" value="${map['pxyResponse.mappedParams']}" />
							<c:set var="mappedParamsValue" value="${fn:split(mappedParams, '=')}" />
							<label>Card Type: <c:out value="${mappedParamsValue[1]}" /></label><br />
							<!-- Gets cardNumber  -->
							<label>Token Card Number: <c:out value="${globalMap['cardNumber']}" /></label><br />
							<!-- Gets cvvNumber  -->
							<label>Token CVV Number: <c:out value="${globalMap['cardCVV']}" /></label><br />
							<!-- Gets today's date -->
							<label>Payment Date: <c:set var="now" value="<%=new java.util.Date()%>" /><fmt:formatDate type="both" value="${now}" /></label><br />
							<!-- Gets amount from the user input on previous page -->
							<label>Amount: <c:out value="${param.amount}" /></label><br />
							<!-- Gets comment from the user input on previous page -->
							<label>Comments: <c:out value="${param.comment}" /></label><br />
							<label>Show Full Message?</label><br />
								<input id="noButton" type="radio" name="radioButton" checked />No
								<input id="yesButton" type="radio" name="radioButton" />Yes
							<div id="message" style="display:none; word-wrap: break-word;">
								<label>Full Message: </label><br />
								<c:out value="${map}" />
							</div><br />
							<label>*******************</label><br /> Thank you for using Hosted PCI.<br />
							<br /> <input Type="button" class="btn btn-primary" value="Back" onClick="history.go(-1);return true;"></input>
						</div>
					</fieldset>
				</section>
			</form>
		</div><!-- col-md-7 col-centered -->
	</div><!-- row -->
</div><!-- container -->
</body>
</html>