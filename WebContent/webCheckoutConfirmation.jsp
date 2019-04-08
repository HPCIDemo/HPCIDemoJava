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
<link href="https://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap-theme.min.css" rel="stylesheet">
<link href="css/template.css" rel="stylesheet">

<script src="js/jquery-2.1.1.js" type="text/javascript" charset="utf-8"></script>
<script src="https://ccframe.hostedpci.com/WBSStatic/site60/proxy/js/jquery.ba-postmessage.2.0.0.min.js" type="text/javascript" charset="utf-8"></script>
<script type="text/javascript">
$(document).ready(function () {
	$("#toggleMessage").click(function() {
		$("#message").toggle("slow");
		$(this).val($(this).val() == "Show response" ? "Hide response" : "Show response");
	});
});
</script>
</head>
<body>
<!-- container class sets the page to use 100% width -->
<div class="container">
	<!-- row class sets the margins -->
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
			<form class = "checkout-confirmation">
				<section>
					<fieldset style="min-height: 100px;">
						<!-- Form Name -->
						<legend>Web Checkout</legend>
						<!-- Text Input -->
						<div>
							Dear Hosted PCI Customer,<br /> Thank you for trying our
							services. If you have any questions, please contact us at
							www.hostedpci.com<br />
							<br /> <label>Transaction Summary</label><br /> <label>*******************</label><br />
							<!-- Get the response that the hpci's server sent back -->
							<c:if test="${not empty map['status']}">
								<label>HPCI Status: <c:out value="${map['status']}" /></label><br />
							</c:if>
							<c:if test="${not empty map['pxyResponse.responseStatus.name']}">
								<label>Status Name: <c:out value="${map['pxyResponse.responseStatus.name']}" /></label><br />
							</c:if>
							<c:if test="${not empty map['pxyResponse.responseStatus.description']}">							
								<label>Description: <c:out value="${map['pxyResponse.responseStatus.description']}" /></label><br />
							</c:if>
							<c:if test="${not empty map['pxyResponse.responseStatus.code']}">							
								<label>Status Code: <c:out value="${map['pxyResponse.responseStatus.code']}" /></label><br />
							</c:if>
							<c:if test="${not empty map['pxyResponse.responseStatus.reasonCode']}">							
								<label>Reason Code: <c:out value="${map['pxyResponse.responseStatus.reasonCode']}" /></label><br />
							</c:if>
							<c:if test="${not empty map['pxyResponse.responseStatus']}">							
								<label>Status: <c:out value="${map['pxyResponse.responseStatus']}" /></label><br />
							</c:if>
							<c:if test="${not empty map['errId']}">
								<label>HPCI Error Code: <c:out value="${map['errId']}" /></label><br />	
								<label>HPCI Description: <c:out value="${map['errFullMsg']}" /></label><br />
								<c:if test="${not empty map['errParamName']}">
									<label>HPCI Error Parameter Name: <c:out value="${map['errParamName']}" /></label><br />
								</c:if>
								<c:if test="${not empty map['errParamValue']}">
									<label>HPCI Error Parameter Value: <c:out value="${map['errParamValue']}" /></label><br />	
								</c:if>		
							</c:if>
							<c:if test="${not empty map['pxyResponse.fullNativeResp']}">							
								<label>Native Response: <c:out value="${map['pxyResponse.fullNativeResp']}" /></label><br />
							</c:if>
							<c:if test="${not empty map['pxyResponse.processorRefId']}">
								<label>Processor Reference ID: <c:out value="${map['pxyResponse.processorRefId']}" /></label><br />
							</c:if>
							<!-- Gets cardNumber(token)  -->
							<label>Token Card Number: <c:out value="${globalMap['cardNumber']}" /></label><br />
							<!-- Gets cvvNumber(token)  -->
							<label>Token CVV Number: <c:out value="${globalMap['cardCVV']}" /></label><br />
							<!-- Gets today's date -->
							<label>
								Payment Date: <c:set var="now" value="<%=new java.util.Date()%>" />
								<fmt:formatDate type="both" value="${now}" />
							</label><br />
							<input type="button" id="toggleMessage" value="Show response" class="btn">
							<div id="message">
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
</div><!-- container -->
</body>
</html>