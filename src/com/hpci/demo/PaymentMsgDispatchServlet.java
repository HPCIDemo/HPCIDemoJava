package com.hpci.demo;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/PaymentMsgDispatchServlet")
@MultipartConfig
public class PaymentMsgDispatchServlet extends HttpServlet {

	private static final long serialVersionUID = 1L;
	private String flag = "";
	private Map<String, String> mapConfig ;
	
	private static final String PXY_MSGDISPATCH = "/iSynSApp/paymentMsgDispatch.action";
	
	private static final String PXYPARAM_APIVERSION = "apiVersion";
	private static final String PXYPARAM_APIVERSION_NUM = "1.0.1";
	private static final String PXYPARAM_APITYPE = "apiType";
	private static final String PXYPARAM_APITYPE_PXYHPCI = "pxyhpci";
	private static final String PXYPARAM_CURRENCY = "pxyTransaction.txnCurISO";
	private static final String PXYPARAM_USERNAME = "userName";
	private static final String PXYPARAM_USERPASSKEY = "userPassKey";
	
	private static final String PXYPARAM_DISPATCHREQUEST_PROFILENAME = "dispatchRequest.profileName";
	private static final String PXYPARAM_DISPATCHREQUEST_CONTENTTYPE = "dispatchRequest.contentType";
	private static final String PXYPARAM_DISPATCHREQUEST_REQUEST = "dispatchRequest.request";
	
	private static final String PXYPARAM_CCPARAMLIST = "ccParamList[";
	private static final String PXYPARAM_CCPARAM_CCMSGTOKEN = "].ccMsgToken";
	private static final String PXYPARAM_CCPARAM_CCTOKEN = "].ccToken";
	private static final String PXYPARAM_CCPARAM_CVVMSGTOKEN = "].cvvMsgToken";
	private static final String PXYPARAM_CCPARAM_CVVTOKEN = "].cvvToken";
	
	private static final String PXYRESP_AUTH_ID = "authId";
	private static final String PXYRESP_CALL_STATUS = "status";
	private static final String PXYRESP_CALL_STATUS_SUCCESS = "success";
	private static final String PXYRESP_RESPSTATUS_CODE = "pxyResponse.responseStatus.code";
	private static final String PXYRESP_RESPSTATUS_DESCRIPTION = "pxyResponse.responseStatus.description";
	private static final String PXYRESP_RESPSTATUS_NAME = "pxyResponse.responseStatus.name";
	
	private static final String PROPERTY_API_SERVICE_URL = "apiServiceUrl";
	private static final String PROPERTY_LOCATION_NAME= "locationName";
	private static final String PROPERTY_SERVICE_URL = "serviceUrl";
	private static final String PROPERTY_SID  = "sid";
	private static final String PROPERTY_CURRENCY = "currency";
	private static final String PROPERTY_CC_TOKEN = "ccToken";
	
	private String authId;

	
	private void logMessage(String msg) {
		System.out.println(msg);
	}
	
	
	private String dispatchOnly(String serviceUrl, Map<String, String> paramMap) {
		// make the remote call
		String callUrl = serviceUrl + PXY_MSGDISPATCH;
		
	    
	    logMessage("========================================================");
		logMessage("Make the call: " + callUrl);
		logMessage("Call payload: " + paramMap);
		String callResult = DemoUtil.callUrl(callUrl, paramMap);
		logMessage("Call result:" + callResult);
		
		// parse the url encoded key value pairs
		Map<String, String> resultMap = DemoUtil.parseQueryString(callResult);
		
		// get the network call status
		String callStatus = resultMap.get(PXYRESP_CALL_STATUS);
		
		if (callStatus != null && callStatus.equals(PXYRESP_CALL_STATUS_SUCCESS)){ 
			logMessage("Successful transaction");
			authId = resultMap.get(PXYRESP_AUTH_ID);
			logMessage("Auth Ref Id:" + authId);
		}
		else {
			logMessage("Unsuccessful transaction");
			String statusCode = resultMap.get(PXYRESP_RESPSTATUS_CODE);
			String statusName = resultMap.get(PXYRESP_RESPSTATUS_NAME);
			String statusDesc = resultMap.get(PXYRESP_RESPSTATUS_DESCRIPTION);
			logMessage("Auth Status Code:" + statusCode);
			logMessage("Auth Status Name:" + statusName);
			logMessage("Auth Status Desc:" + statusDesc);
		}
		return callResult;
	}
	
	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		// Preprocess request
		/// Get flag from the ajax call
		if (request.getParameterMap().containsKey("flag")) {
			flag = request.getParameter("flag");
		}
		mapConfig = DemoUtil.getConfigProperties();

		if (flag.equals("config")) {
			response.setHeader("Cache-Control", "no-cache");
			response.setHeader("Pragma", "no-cache");
			response.setCharacterEncoding("utf-8");
			response.setContentType("text/html");

			PrintWriter out = response.getWriter();

			// Initiate the call back
			out.print("sid;" + mapConfig.get(PROPERTY_SID) + "," + "locationName;" + mapConfig.get(PROPERTY_LOCATION_NAME) + ","
					+ "serviceUrl;" + mapConfig.get(PROPERTY_SERVICE_URL)
					+ "," + "currency;" + mapConfig.get(PROPERTY_CURRENCY)
					+ "," +"paymentProfile;" + mapConfig.get("paymentProfile")
					+ "," + "ccNum;" + mapConfig.get(PROPERTY_CC_TOKEN));
		}
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		Map<String, String> paramMap = new HashMap<String, String>();
		if(mapConfig == null)
			mapConfig = DemoUtil.getConfigProperties();
		
		String serviceUrl = mapConfig.get(PROPERTY_API_SERVICE_URL);
		String userName = mapConfig.get(PXYPARAM_USERNAME);
		String userPassKey = mapConfig.get(PXYPARAM_USERPASSKEY);
		
		String paymentMsg = request.getParameter(PXYPARAM_DISPATCHREQUEST_REQUEST);
		String ccMsgToken = request.getParameter("ccMsgToken");
		String ccToken = request.getParameter("ccToken");
		String ccvMsgToken = request.getParameter("cvvMsgToken");
		String ccvToken = request.getParameter("cvvToken");
		String profileName = request.getParameter(PXYPARAM_DISPATCHREQUEST_PROFILENAME);
		String contentType = request.getParameter(PXYPARAM_DISPATCHREQUEST_CONTENTTYPE);
		String currency = request.getParameter("currency");
		
		paramMap.put(PXYPARAM_APIVERSION, PXYPARAM_APIVERSION_NUM);
		paramMap.put(PXYPARAM_APITYPE, PXYPARAM_APITYPE_PXYHPCI);
		paramMap.put(PXYPARAM_USERNAME, userName);
		paramMap.put(PXYPARAM_USERPASSKEY, userPassKey);
		
		paramMap.put(PXYPARAM_DISPATCHREQUEST_PROFILENAME, profileName);
		paramMap.put(PXYPARAM_CURRENCY, currency);
		paramMap.put(PXYPARAM_DISPATCHREQUEST_CONTENTTYPE, contentType);
		paramMap.put(PXYPARAM_DISPATCHREQUEST_REQUEST, paymentMsg);
		
		// Credit card token
		paramMap.put(PXYPARAM_CCPARAMLIST + "0" + PXYPARAM_CCPARAM_CCMSGTOKEN, ccMsgToken);
		paramMap.put(PXYPARAM_CCPARAMLIST + "0" + PXYPARAM_CCPARAM_CCTOKEN, ccToken);
		//Credit card cvv
		paramMap.put(PXYPARAM_CCPARAMLIST + "0" + PXYPARAM_CCPARAM_CVVMSGTOKEN, ccvMsgToken);
		paramMap.put(PXYPARAM_CCPARAMLIST + "0" + PXYPARAM_CCPARAM_CVVTOKEN, ccvToken);
		
		String callResult = dispatchOnly(serviceUrl, paramMap);
		
		response.setHeader("Cache-Control", "no-cache");
		response.setHeader("Pragma", "no-cache");
		response.setCharacterEncoding("utf-8");
		response.setContentType("text/html");

		PrintWriter out = response.getWriter();

		// Initiate the call back
		out.print(callResult);
	}
}
