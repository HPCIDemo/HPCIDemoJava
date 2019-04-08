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
@WebServlet("/Iframe3DSecServlet")
public class Iframe3DSecServlet extends HttpServlet {

	// Global variables to be used through all the pages
	private String cardNumber = "";
	private String cardCVV = "";
	private String expiryMonth = "";
	private String expiryYear = "";
	private String firstName = "";
	private String lastName = "";	
	private String amount = "";
	private String merchantRefId = "";
	private String currency = "";
	private String paymentProfile = "";
	private String comments = "";
	private String country = "";
	private String zip = "";
	private String state = "";
	private String city = "";
	private String address1 = "";
	private String address2 = "";
	private String authTxnId = "";
	private String flag = "";
	private Map<String, String> mapConfig ;
	
	@Override
	protected void doGet(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {
		// Preprocess request
		/// Get flag from the ajax call
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
			out.print("sid;"+mapConfig.get("sid")
				+","+"locationName;" +mapConfig.get("locationName")
				+","+"currency;" +mapConfig.get("currency")
				+","+"securePaymentProfile;" +mapConfig.get("securePaymentProfile")
				+","+"serviceUrl;"+ mapConfig.get("serviceUrl"));				
		}	
	}

	@Override
	protected void doPost(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {
		// Postprocess request: gather and validate submitted data and display
		// result in same JSP.
		// From here on, everything happens once we click the submit button
		// action variable which comes from the specific form/page that initiated the call
		String action = request.getParameter("action");
		String customerId = "";
		if(mapConfig == null)
			mapConfig = DemoUtil.getConfigProperties();
		
		if(action.equals("formRequest")) {
			// Get request parameters from form.jsp (all the attributes that the
			// user inputs)
			cardNumber = request.getParameter("ccNum");
			cardCVV = request.getParameter("ccCVV");
			expiryMonth = request.getParameter("expiryMonth");
			expiryYear = request.getParameter("expiryYear");
			firstName = request.getParameter("firstName");
			lastName = request.getParameter("lastName");			
			amount = request.getParameter("amount");
			merchantRefId = request.getParameter("merchantRefId");
			currency = request.getParameter("currency");
			paymentProfile = request.getParameter("paymentProfile");
			comments = request.getParameter("comment");
			country = request.getParameter("country");
			zip = request.getParameter("zip");
			state = request.getParameter("state");
			city = request.getParameter("city");
			address1 = request.getParameter("address1");
			address2 = request.getParameter("address2");
			String action3DSec = request.getParameter("action3DSec");

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
			if (firstName != null && !firstName.isEmpty())
				hpciRequestParamMap.put("pxyCustomerInfo.billingLocation.firstName", firstName);
			if (lastName != null && !lastName.isEmpty())
				hpciRequestParamMap.put("pxyCustomerInfo.billingLocation.lastName", lastName);
			if (address1 != null && !address1.isEmpty())
				hpciRequestParamMap.put("pxyCustomerInfo.billingLocation.address", address1);
			if (address2 != null && !address2.isEmpty())
				hpciRequestParamMap.put("pxyCustomerInfo.billingLocation.address2", address2);
			if (city != null && !city.isEmpty())
				hpciRequestParamMap.put("pxyCustomerInfo.billingLocation.city", city);
			if (state != null && !state.isEmpty())
				hpciRequestParamMap.put("pxyCustomerInfo.billingLocation.state", state);
			if (zip != null && !zip.isEmpty())
				hpciRequestParamMap.put("pxyCustomerInfo.billingLocation.zipCode", zip);
			if (country != null && !country.isEmpty())
				hpciRequestParamMap.put("pxyCustomerInfo.billingLocation.country", country);
			
			// Test
			hpciRequestParamMap.put("pxyCustomerInfo.shippingLocation.phoneNumber", "4168351525");
			hpciRequestParamMap.put("pxyCustomerInfo.billingLocation.phoneNumber", "4168351525");
			// populate 3D Secure info
			hpciRequestParamMap.put("pxyThreeDSecAuth.actionName", action3DSec);
			hpciRequestParamMap.put("pxyOrder.orderItems[0].itemDescription", "Best");
			hpciRequestParamMap.put("pxyOrder.orderItems[0].itemName", "item");
			hpciRequestParamMap.put("pxyOrder.orderItems[0].itemPrice", "10.00");
			hpciRequestParamMap.put("pxyOrder.orderItems[0].itemQuantity", "1");

			hpciRequestParamMap.put("pxyOrder.invoiceNumber", "Order:" + merchantRefId);
			hpciRequestParamMap.put("pxyOrder.description", "Test Order");
			hpciRequestParamMap.put("pxyOrder.totalAmount", amount);

			hpciRequestParamMap.put("pxyOrder.orderItems[" + "0" + "].itemId", "Item-1-" + merchantRefId);
			hpciRequestParamMap.put("pxyOrder.orderItems[" + "0" + "].itemTaxable", "N"); // Y/N
			
			// Assuming the full request param map is ready
			// Url string is made of the api url which is given by
			// HostedPCI + "iSynSApp/paymentAuth.action"
			String urlString = mapConfig.get("apiServiceUrl") + "/iSynSApp/paymentAuth.action";
			// Uses the callUrl method to initiate the call to HostedPCI using the iframe,
			// It requires the complete url and the populated map
			String callResponse = DemoUtil.callUrl(urlString, hpciRequestParamMap);

			// Uses the parseQueryString method to collect the response from HostedPCI
			// And pass the resulting map in a parameter "map" to be used in the
			// webCheckoutConfirmation1.jsp file
			request.setAttribute("map", DemoUtil.parseQueryString(callResponse));

			// Create a map to be returned to the client browser at the end
			Map<String, String> globalMap = new LinkedHashMap<String, String>();
			globalMap.put("merchantRefId", merchantRefId);
			globalMap.put("cardNumber", cardNumber);
			globalMap.put("cardCVV", cardCVV);
			globalMap.put("amount", amount);
			globalMap.put("comments", comments);
			globalMap.put("siteId", mapConfig.get("sid"));
			globalMap.put("serviceUrl", mapConfig.get("serviceUrl"));
			
			String hostName = request.getServerName();
			Integer portNum = request.getServerPort();
			String fullParentHost = request.getScheme() + "://" + hostName + ":" +portNum;
			globalMap.put("fullParentHost", fullParentHost);
			
			// Send globalMap to the 2nd response page
			request.setAttribute("globalMap", globalMap);
			
			// Pass all the information that was collected to the confirmation page
			// "webCheckoutConfirmation1.jsp"
			request.getRequestDispatcher("/webCheckoutConfirmation1.jsp").forward(request, response);
		}
		// 2nd page
		else if(action.equals("form3DSecResponse")) {
//			System.out.println("responding!!!");
			
			String action3DSec = request.getParameter("action3DSec");
			authTxnId = request.getParameter("authTxnId");
			
			Map<String, String> hpciResponseMap = new LinkedHashMap<String, String>();

			// Populate hpciRequestParamMap with all the needed pairs of information
			hpciResponseMap.put("apiVersion",mapConfig.get("apiVersion"));
			hpciResponseMap.put("apiType", mapConfig.get("apiType"));

			// The username is given by HostedPCI
			hpciResponseMap.put("userName", mapConfig.get("userName"));

			// The passkey is given by HostedPCI
			hpciResponseMap.put("userPassKey", mapConfig.get("userPassKey"));;

			// Continue to populate hpciResponseMap with all the required
			// information			
			if (cardNumber != null && !cardNumber.isEmpty())
				hpciResponseMap.put("pxyCreditCard.creditCardNumber", cardNumber);
			if (expiryMonth != null && !expiryMonth.isEmpty())
				hpciResponseMap.put("pxyCreditCard.expirationMonth", expiryMonth);
			if (expiryYear != null && !expiryYear.isEmpty())
				hpciResponseMap.put("pxyCreditCard.expirationYear", expiryYear);
			if (cardCVV != null && !cardCVV.isEmpty())
				hpciResponseMap.put("pxyCreditCard.cardCodeVerification", cardCVV);
			if (amount != null && !amount.isEmpty())
				hpciResponseMap.put("pxyTransaction.txnAmount", amount);
			if (currency != null && !currency.isEmpty())
				hpciResponseMap.put("pxyTransaction.txnCurISO", currency);
			if (merchantRefId == null || merchantRefId.isEmpty()){
				merchantRefId = UUID.randomUUID().toString().substring(0,15);
				hpciResponseMap.put("pxyTransaction.merchantRefId", merchantRefId);
			}
			if (paymentProfile != null && !paymentProfile.isEmpty())
				hpciResponseMap.put("pxyTransaction.txnPayName", paymentProfile);
			if (comments != null && !comments.isEmpty())
				hpciResponseMap.put("pxyTransaction.txnComment", comments);
			hpciResponseMap.put("pxyCustomerInfo.email", "user@testemail.com");
			customerId = UUID.randomUUID().toString().substring(0,15);
			hpciResponseMap.put("pxyCustomerInfo.customerId", customerId);
			if (firstName != null && !firstName.isEmpty())
				hpciResponseMap.put("pxyCustomerInfo.billingLocation.firstName", firstName);
			if (lastName != null && !lastName.isEmpty())
				hpciResponseMap.put("pxyCustomerInfo.billingLocation.lastName", lastName);
			if (address1 != null && !address1.isEmpty())
				hpciResponseMap.put("pxyCustomerInfo.billingLocation.address", address1);
			if (address2 != null && !address2.isEmpty())
				hpciResponseMap.put("pxyCustomerInfo.billingLocation.address2", address2);
			if (city != null && !city.isEmpty())
				hpciResponseMap.put("pxyCustomerInfo.billingLocation.city", city);
			if (state != null && !state.isEmpty())
				hpciResponseMap.put("pxyCustomerInfo.billingLocation.state", state);
			if (zip != null && !zip.isEmpty())
				hpciResponseMap.put("pxyCustomerInfo.billingLocation.zipCode", zip);
			if (country != null && !country.isEmpty())
				hpciResponseMap.put("pxyCustomerInfo.billingLocation.country", country);

			// Test
			hpciResponseMap.put("pxyCustomerInfo.shippingLocation.phoneNumber", "4168351525");
			hpciResponseMap.put("pxyCustomerInfo.billingLocation.phoneNumber", "4168351525");
			// populate 3D Secure info
			hpciResponseMap.put("pxyThreeDSecAuth.actionName", action3DSec);
			hpciResponseMap.put("pxyThreeDSecAuth.authTxnId", authTxnId);
			hpciResponseMap.put("pxyThreeDSecAuth.authSignComboList[0]", "YY");
			hpciResponseMap.put("pxyThreeDSecAuth.authSignComboList[1]", "AY");
			hpciResponseMap.put("pxyThreeDSecAuth.authSignComboList[2]", "UY");
			
			hpciResponseMap.put("pxyOrder.orderItems[0].itemDescription", "Best");
			hpciResponseMap.put("pxyOrder.orderItems[0].itemName", "item");
			hpciResponseMap.put("pxyOrder.orderItems[0].itemPrice", "10.00");
			hpciResponseMap.put("pxyOrder.orderItems[0].itemQuantity", "1");

			hpciResponseMap.put("pxyOrder.invoiceNumber", "Order:" + merchantRefId);
			hpciResponseMap.put("pxyOrder.description", "Test Order");
			hpciResponseMap.put("pxyOrder.totalAmount", amount);

			hpciResponseMap.put("pxyOrder.orderItems[" + "0" + "].itemId", "Item-1-" + merchantRefId);
			hpciResponseMap.put("pxyOrder.orderItems[" + "0" + "].itemTaxable", "N"); // Y/N

			String urlString = mapConfig.get("apiServiceUrl") + "/iSynSApp/paymentAuth.action";
			String callResponse = DemoUtil.callUrl(urlString, hpciResponseMap);
			// Send the response call back to the 3rd page
			request.setAttribute("responseMap", DemoUtil.parseQueryString(callResponse));

			// Create a map to be returned to the client browser at the end
			Map<String, String> globalMap = new LinkedHashMap<String, String>();
			globalMap.put("merchantRefId", merchantRefId);
			globalMap.put("cardNumber", cardNumber);
			globalMap.put("cardCVV", cardCVV);
			globalMap.put("amount", amount);
			globalMap.put("comments", comments);
			// Send globalMap to the 3rd response page
			request.setAttribute("globalMap", globalMap);
			
			request.getRequestDispatcher("/webCheckoutConfirmation2.jsp").forward(request, response);
		}
		else {
			System.out.println("Shouldn't happen, we have a problem");
		}
		// END: of doPost
	}
}