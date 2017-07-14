package com.hpci.demo;

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
@WebServlet("/GatewayTokenizationServlet")
public class GatewayTokenizationServlet extends HttpServlet {
	private final String PXY_GATEWAY_TOKEN = "/iSynSApp/paymentGatewayToken.action";
	private String cardNumber = "";
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
			out.print("sid;" + mapConfig.get("sid")
					+","+"locationName;" + mapConfig.get("locationName")
					+","+"currency;" + mapConfig.get("currency")
					+","+"paymentProfile;" + mapConfig.get("paymentProfile")
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
		String expiryMonth = request.getParameter("expiryMonth");
		String expiryYear = request.getParameter("expiryYear");
		String firstName = request.getParameter("firstName");
		String lastName = request.getParameter("lastName");
		String paymentProfile = request.getParameter("paymentProfile");

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
		hpciRequestParamMap.put("pxyTransaction.txnPayName", paymentProfile);
		hpciRequestParamMap.put("pxyCustomerInfo.billingLocation.firstName", firstName);
		hpciRequestParamMap.put("pxyCustomerInfo.billingLocation.lastName", lastName);
			
		// Assuming the full request param map is ready
		// Url string is made of the api url which is given by
		// HostedPCI + "/iSynSApp/paymentGatewayToken.action"
				
		String urlString = mapConfig.get("apiServiceUrl") + PXY_GATEWAY_TOKEN;
		// Uses the callUrl method to initiate the call to HostedPCI using the iframe,
		// It requires the complete url and the populated map
		String callResponse = DemoUtil.callUrl(urlString, hpciRequestParamMap);

		response.setHeader("Cache-Control", "no-cache");
		response.setHeader("Pragma", "no-cache");
		response.setCharacterEncoding("utf-8");
		response.setContentType("text/html");

		PrintWriter out = response.getWriter();

		// Initiate the call back
		out.print(callResponse);
	}
}