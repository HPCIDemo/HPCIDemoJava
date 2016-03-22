package com.isyn;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.LinkedHashMap;
import java.util.Map;
//import org.json.JSONArray;
//import org.json.JSONObject;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Servlet implementation class PhoneSessionServlet
 */
@WebServlet(asyncSupported = true, urlPatterns = { "/PhoneSessionServlet" })
public class PhoneSessionServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private Map<String, String> mapConfig ;
	private String flag = "";
	
	protected void doGet(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {
		// Preprocess request
		// Get flag from the ajax call
		if(request.getParameterMap().containsKey("flag")){
					flag = request.getParameter("flag");
		}
		// Populate hpciRequestParamMap with all the needed pairs of information
		mapConfig = DemoUtil.getConfigProperties();
		
		if(flag.equals("config")) {
			response.setHeader("Cache-Control", "no-cache");
			response.setHeader("Pragma", "no-cache");
			response.setCharacterEncoding("utf-8");
			response.setContentType("text/html");
			
			// Call HPCI using the populated map and action url string			
			PrintWriter out = response.getWriter();
			
			// Initiate the call back
			out.print("currency;" +mapConfig.get("currency")
					+","+"paymentProfile;" +mapConfig.get("paymentProfile"));							
		}		
	}
 
	public void doPost (HttpServletRequest request,HttpServletResponse response)
            throws ServletException, IOException {
    	
		// Setup request param map
		Map<String, String> hpciRequestParamMap = new LinkedHashMap<String, String>();
		// Populate hpciRequestParamMap with all the needed pairs of information
		mapConfig = DemoUtil.getConfigProperties();
		
		hpciRequestParamMap.put("apiVersion",mapConfig.get("apiVersion"));
		hpciRequestParamMap.put("apiType", mapConfig.get("apiType"));
		
		// The username is given by HostedPCI
		hpciRequestParamMap.put("userName", mapConfig.get("userName"));
		
		// The passkey is given by HostedPCI
		hpciRequestParamMap.put("userPassKey", mapConfig.get("userPassKey"));
		
		// Prepare the urlString which will be initialized as empty
		String urlString = "";
		// Get flag from the ajax call
		if(request.getParameterMap().containsKey("flag")){
			flag = request.getParameter("flag");
		}
		
		// Get sessionId from the ajax call
		String sessionId = request.getParameter("sessionId");

		if(flag.equals("createSession")) {
			
			// Values required for createSession
			hpciRequestParamMap.put("cmd", "createsession");
			hpciRequestParamMap.put("promptLang", "en_US");
			hpciRequestParamMap.put("cvvEntry", "");
			hpciRequestParamMap.put("sessionKeyType", "venue");
			hpciRequestParamMap.put("userMarker1", "any");
			hpciRequestParamMap.put("userMarker2", "any");
			hpciRequestParamMap.put("userMarker3", "any");
			
			// Test for ccExpiry
			hpciRequestParamMap.put("ccExpiry", "request");
			
			// URL action used			
			urlString = mapConfig.get("serviceUrl") + "/iSynSApp/manageCCMapPhoneAPI.action";
			
		} else if(flag.equals("checkStatus")) {
			
			// Values required for showProgress command
			hpciRequestParamMap.put("cmd", "showprogress");
			hpciRequestParamMap.put("promptLang", "en_US");
			hpciRequestParamMap.put("cvvEntry", "");
			hpciRequestParamMap.put("sessionKeyType", "venue");
			hpciRequestParamMap.put("userMarker1", "any");
			hpciRequestParamMap.put("userMarker2", "any");
			hpciRequestParamMap.put("userMarker3", "any");
			hpciRequestParamMap.put("selectedPcsId", sessionId);
			
			//URL action used
			urlString = mapConfig.get("serviceUrl") + "/iSynSApp/manageCCMapPhoneAPI.action";
				
		} else if(flag.equals("processPayment")) {
			
			// Get the values from the form
			String ccToken = request.getParameter("ccToken");
			String cvvToken = request.getParameter("cvvToken");
			String expiryMonth = request.getParameter("expiryMonth");
			String expiryYear = request.getParameter("expiryYear");
			String cardType = request.getParameter("cardType");
			String firstName = request.getParameter("firstName");
			String lastName = request.getParameter("lastName");
			String address1 = request.getParameter("address1");
			String address2 = request.getParameter("address2");
			String city = request.getParameter("city");
			String state = request.getParameter("state");
			String zip = request.getParameter("zip");
			String country = request.getParameter("country");
			String paymentComments = request.getParameter("paymentComments");
			String paymentReference = request.getParameter("paymentReference");
			String currency = request.getParameter("currency");
			String paymentAmount = request.getParameter("paymentAmount");
			String paymentProfile = request.getParameter("paymentProfile");
			
			// Fill the map with the required pairs
			hpciRequestParamMap.put("pxyCreditCard.cardType", cardType);
			hpciRequestParamMap.put("pxyCreditCard.creditCardNumber", ccToken);
			hpciRequestParamMap.put("pxyCreditCard.cardCodeVerification", cvvToken);
			hpciRequestParamMap.put("pxyCreditCard.expirationMonth", expiryMonth);
			hpciRequestParamMap.put("pxyCreditCard.expirationYear", expiryYear);
			hpciRequestParamMap.put("pxyCustomerInfo.billingLocation.firstName", firstName);
			hpciRequestParamMap.put("pxyCustomerInfo.billingLocation.lastName", lastName);
			hpciRequestParamMap.put("pxyCustomerInfo.billingLocation.address", address1);
			hpciRequestParamMap.put("pxyCustomerInfo.billingLocation.address2", address2);
			hpciRequestParamMap.put("pxyCustomerInfo.billingLocation.city", city);
			hpciRequestParamMap.put("pxyCustomerInfo.billingLocation.state", state);
			hpciRequestParamMap.put("pxyCustomerInfo.billingLocation.zipCode", zip);
			hpciRequestParamMap.put("pxyCustomerInfo.billingLocation.country", country);
			hpciRequestParamMap.put("pxyTransaction.txnCurISO", currency);
			hpciRequestParamMap.put("pxyTransaction.txnAmount", paymentAmount);
			hpciRequestParamMap.put("pxyTransaction.merchantRefId", paymentReference);
			hpciRequestParamMap.put("pxyTransaction.txnComment", paymentComments);
			hpciRequestParamMap.put("pxyTransaction.txnPayName", paymentProfile);
			
			// URL action used			
			urlString = mapConfig.get("serviceUrl") + "/iSynSApp/paymentAuth.action";
		}
		
		response.setHeader("Cache-Control", "no-cache");
		response.setHeader("Pragma", "no-cache");
		response.setCharacterEncoding("utf-8");
		response.setContentType("text/html");
		
		// Call HPCI using the populated map and action url string
		String callResponse = DemoUtil.callUrl(urlString, hpciRequestParamMap);
		PrintWriter out = response.getWriter();
		
		// Initiate the call back
		out.print(callResponse);
    }
}