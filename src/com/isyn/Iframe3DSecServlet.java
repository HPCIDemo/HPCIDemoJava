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
			out.print("sid:"+mapConfig.get("sid")
			+","+"locationName:" +mapConfig.get("locationName"));							
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
			String urlString = "https://api-sampqa1stg.c1.hostedpci.com/iSynSApp/paymentAuth.action";
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
			hpciResponseMap.put("pxyCreditCard.creditCardNumber", cardNumber);
			hpciResponseMap.put("pxyCreditCard.cardCodeVerification", cardCVV);
			hpciResponseMap.put("pxyCreditCard.expirationMonth", expiryMonth);
			hpciResponseMap.put("pxyCreditCard.expirationYear", expiryYear);
			hpciResponseMap.put("pxyTransaction.txnAmount", amount);
			hpciResponseMap.put("pxyTransaction.txnCurISO", currency);
			hpciResponseMap.put("pxyTransaction.merchantRefId", "merRef:" + merchantRefId);
			hpciResponseMap.put("pxyTransaction.txnPayName", paymentProfile);
			hpciResponseMap.put("pxyTransaction.txnComment", comments);
			hpciResponseMap.put("pxyCustomerInfo.email", "email@email.com");
			hpciResponseMap.put("pxyCustomerInfo.customerId", "111");
			hpciResponseMap.put("pxyCustomerInfo.billingLocation.firstName", firstName);
			hpciResponseMap.put("pxyCustomerInfo.billingLocation.lastName", lastName);
			hpciResponseMap.put("pxyCustomerInfo.billingLocation.address", address1);
			hpciResponseMap.put("pxyCustomerInfo.billingLocation.address2", address2);
			hpciResponseMap.put("pxyCustomerInfo.billingLocation.city", city);
			hpciResponseMap.put("pxyCustomerInfo.billingLocation.state", state);
			hpciResponseMap.put("pxyCustomerInfo.billingLocation.zipCode", zip);
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

			String urlString = "https://api-sampqa1stg.c1.hostedpci.com/iSynSApp/paymentAuth.action";
			
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