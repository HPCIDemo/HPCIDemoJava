package com.isyn;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.LinkedHashMap;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


@SuppressWarnings("serial")
// physical url for the servlet
@WebServlet("/IframeServlet")
public class IframeServlet extends HttpServlet {

	private String cardNumber = "";
	private String cardCVV = "";
	private String merchantRefId = "";
	private String comments = "";
	private String amount = "";
	private String flag = "";
	private Map<String, String> mapConfig ;
	
	@Override
	protected void doGet(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {
		// Preprocess request
		// Get flag from the ajax call
		if(request.getParameterMap().containsKey("flag")){
					flag = request.getParameter("flag");
		}
		mapConfig = DemoUtil.getConfigProperties();
		
		if(flag.equals("config")) {
			response.setHeader("Cache-Control", "no-cache");
			response.setHeader("Pragma", "no-cache");
			response.setCharacterEncoding("utf-8");
			response.setContentType("text/html");
			
			// Call HPCI using the populated map and action url string			
			PrintWriter out = response.getWriter();
			
			// Initiate the call back
			out.print("sid:"+mapConfig.get("sid")
					+","+"locationName:" +mapConfig.get("locationName"));							
		}		
	}

	@Override
	protected void doPost(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {
		// Postprocess request: gather and validate submitted data and display
		// result in same JSP.
		// Here on happens once we click the submit button

		// Get request parameters from form.jsp (all the attributes that the
		// user inputs)
		cardNumber = request.getParameter("ccNum");
		cardCVV = request.getParameter("ccCVV");
		String expiryMonth = request.getParameter("expiryMonth");
		String expiryYear = request.getParameter("expiryYear");
		String firstName = request.getParameter("firstName");
		String lastName = request.getParameter("lastName");
		//String cardType = request.getParameter("cardType");
		amount = request.getParameter("amount");
		merchantRefId = request.getParameter("merchantRefId");
		String currency = request.getParameter("currency");
		String paymentProfile = request.getParameter("paymentProfile");
		comments = request.getParameter("comment");
		String country = request.getParameter("country");
		String zip = request.getParameter("zip");
		String state = request.getParameter("state");
		String city = request.getParameter("city");
		String address1 = request.getParameter("address1");
		String address2 = request.getParameter("address2");

		// Setup request param map
		Map<String, String> hpciRequestParamMap = new LinkedHashMap<String, String>();

		// Populate hpciRequestParamMap with all the needed pairs of information
		hpciRequestParamMap.put("apiVersion",mapConfig.get("apiVersion"));
		hpciRequestParamMap.put("apiType", mapConfig.get("apiType"));

		// The username is given by HostedPCI
		hpciRequestParamMap.put("userName", mapConfig.get("userName"));

		// The passkey is given by HostedPCI
		hpciRequestParamMap.put("userPassKey", mapConfig.get("userPassKey"));

		// Continue to populate hpciRequestParamMap with all the required
		// information
		//hpciRequestParamMap.put("pxyCreditCard.cardType", cardType);
		hpciRequestParamMap.put("pxyCreditCard.creditCardNumber", cardNumber);
		hpciRequestParamMap.put("pxyCreditCard.expirationMonth", expiryMonth);
		hpciRequestParamMap.put("pxyCreditCard.expirationYear", expiryYear);
		hpciRequestParamMap.put("pxyCreditCard.cardCodeVerification", cardCVV);
		hpciRequestParamMap.put("pxyTransaction.txnAmount", amount);
		hpciRequestParamMap.put("pxyTransaction.txnCurISO", currency);
		hpciRequestParamMap.put("pxyTransaction.merchantRefId", merchantRefId);
		hpciRequestParamMap.put("pxyTransaction.txnPayName", paymentProfile);
		hpciRequestParamMap.put("pxyTransaction.txnComment", comments);
		hpciRequestParamMap.put("pxyCustomerInfo.email", "email@email.com");
		hpciRequestParamMap.put("pxyCustomerInfo.customerId", "111");
		hpciRequestParamMap.put("pxyCustomerInfo.billingLocation.firstName", firstName);
		hpciRequestParamMap.put("pxyCustomerInfo.billingLocation.lastName", lastName);
		hpciRequestParamMap.put("pxyCustomerInfo.billingLocation.address", address1);
		hpciRequestParamMap.put("pxyCustomerInfo.billingLocation.address2", address2);
		hpciRequestParamMap.put("pxyCustomerInfo.billingLocation.city", city);
		hpciRequestParamMap.put("pxyCustomerInfo.billingLocation.state", state);
		hpciRequestParamMap.put("pxyCustomerInfo.billingLocation.zipCode", zip);
		hpciRequestParamMap.put("pxyCustomerInfo.billingLocation.country", country);
			

		// Assuming the full request param map is ready
		// Url string is made of the api url which is given by
		// HostedPCI + "iSynSApp/paymentAuth.action"
		String urlString = "https://api-sampqa1stg.c1.hostedpci.com/iSynSApp/paymentAuth.action";
		// Uses the callUrl method to initiate the call to HostedPCI using the iframe,
		// It requires the complete url and the populated map
		String callResponse = DemoUtil.callUrl(urlString, hpciRequestParamMap);

		// Uses the parseQueryString method to collect the response from HostedPCI
		// And pass the resulting map in a parameter "map" to be used in the
		// webCheckoutConfirmation.jsp file
		request.setAttribute("map", DemoUtil.parseQueryString(callResponse));

		// Create a map to be returned to the client's browser at the end
		Map<String, String> globalMap = new LinkedHashMap<String, String>();
		globalMap.put("cardNumber", cardNumber);
		globalMap.put("cardCVV", cardCVV);
		globalMap.put("merchantRefId", merchantRefId);
		globalMap.put("amount", amount);
		globalMap.put("comments", comments);
		// Send globalMap to the response page
		request.setAttribute("globalMap", globalMap);
			
		// Pass all the information that was collected to the confirmation page
		// "webCheckoutConfirmation.jsp"
		request.getRequestDispatcher("/webCheckoutConfirmation.jsp").forward(request, response);
	

		// END: of doPost
	}
}