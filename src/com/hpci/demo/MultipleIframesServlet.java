package com.hpci.demo;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.UUID;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


@SuppressWarnings("serial")
// physical url for the servlet
@WebServlet("/MultipleIframesServlet")
public class MultipleIframesServlet extends HttpServlet{
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
		mapConfig = DemoUtil.getConfigProperties(null);
		
		if(flag.equals("config")) {
			response.setHeader("Cache-Control", "no-cache");
			response.setHeader("Pragma", "no-cache");
			response.setCharacterEncoding("utf-8");
			response.setContentType("text/html");
			
			// Call HPCI using the populated map and action url string			
			PrintWriter out = response.getWriter();
			
			// Initiate the call back
			out.print("sid;"+mapConfig.get("sid")
					+","+"locationName;" +mapConfig.get("multipleIframeslocationName")
					+","+"currency;" +mapConfig.get("currency")
					+","+"paymentProfile;" +mapConfig.get("paymentProfile")
					+","+"serviceUrl;"+ mapConfig.get("serviceUrl"));							
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
//		String firstName = request.getParameter("firstName");
//		String lastName = request.getParameter("lastName");
		//String cardType = request.getParameter("cardType");
		amount = request.getParameter("amount");
		merchantRefId = request.getParameter("merchantRefId");
		String currency = request.getParameter("currency");
		String paymentProfile = request.getParameter("paymentProfile");
		String customerId = "";
//		comments = request.getParameter("comment");
//		String country = request.getParameter("country");
//		String zip = request.getParameter("zip");
//		String state = request.getParameter("state");
//		String city = request.getParameter("city");
//		String address1 = request.getParameter("address1");
//		String address2 = request.getParameter("address2");
		
		if(mapConfig == null)
			mapConfig = DemoUtil.getConfigProperties(null);

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
		if (cardNumber != null && !cardNumber.isEmpty())
			hpciRequestParamMap.put("pxyCreditCard.creditCardNumber", cardNumber);
		if (expiryMonth != null && !expiryMonth.isEmpty())
			hpciRequestParamMap.put("pxyCreditCard.expirationMonth", expiryMonth);
		if (expiryYear != null && !expiryYear.isEmpty())
			hpciRequestParamMap.put("pxyCreditCard.expirationYear", expiryYear);
		if (cardCVV != null && !cardCVV.isEmpty())
			hpciRequestParamMap.put("pxyCreditCard.cardCodeVerification", cardCVV);
		if (amount != null && !amount.isEmpty())
			hpciRequestParamMap.put("pxyTransaction.txnAmount", amount);
		if (currency != null && !currency.isEmpty())
			hpciRequestParamMap.put("pxyTransaction.txnCurISO", currency);
		if (merchantRefId == null || merchantRefId.isEmpty()){
			merchantRefId = UUID.randomUUID().toString().substring(0,15);
		}
		hpciRequestParamMap.put("pxyTransaction.merchantRefId", merchantRefId);
		if (paymentProfile != null && !paymentProfile.isEmpty())
			hpciRequestParamMap.put("pxyTransaction.txnPayName", paymentProfile);
		if (comments != null && !comments.isEmpty())
			hpciRequestParamMap.put("pxyTransaction.txnComment", comments);
		hpciRequestParamMap.put("pxyCustomerInfo.email", "user@testemail.com");
		customerId = UUID.randomUUID().toString().substring(0,15);
		hpciRequestParamMap.put("pxyCustomerInfo.customerId", customerId);
//		hpciRequestParamMap.put("pxyCustomerInfo.billingLocation.firstName", firstName);
//		hpciRequestParamMap.put("pxyCustomerInfo.billingLocation.lastName", lastName);
//		hpciRequestParamMap.put("pxyCustomerInfo.billingLocation.address", address1);
//		hpciRequestParamMap.put("pxyCustomerInfo.billingLocation.address2", address2);
//		hpciRequestParamMap.put("pxyCustomerInfo.billingLocation.city", city);
//		hpciRequestParamMap.put("pxyCustomerInfo.billingLocation.state", state);
//		hpciRequestParamMap.put("pxyCustomerInfo.billingLocation.zipCode", zip);
//		hpciRequestParamMap.put("pxyCustomerInfo.billingLocation.country", country);
			

		// Assuming the full request param map is ready
		// Url string is made of the api url which is given by
		// HostedPCI + "iSynSApp/paymentAuth.action"
				
		String urlString = mapConfig.get("apiServiceUrl") + "/iSynSApp/paymentAuth.action";
		// Uses the callUrl method to initiate the call to HostedPCI using the iframe,
		// It requires the complete url and the populated map
		String callResponse = DemoUtil.callUrl(urlString, hpciRequestParamMap);

		response.setHeader("Cache-Control", "no-cache");
		response.setHeader("Pragma", "no-cache");
		response.setCharacterEncoding("utf-8");
		response.setContentType("text/html");
		
		// Call HPCI using the populated map and action url string			
		PrintWriter out = response.getWriter();
		
		out.print(callResponse);	
		// END: of doPost
	}
}
