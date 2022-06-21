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

@WebServlet("/ACHServlet")
public class ACHServlet extends HttpServlet {

	private static final long serialVersionUID = 20220620001L;
	private String achNum = "";
	private String achLast4 = "";
	private String achToken1 = "";
	private String achToken2 = "";
	private String achToken3 = "";
	private String achToken4 = "";
	private String flag = "";
	private Map<String, String> mapConfig ;
	
	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
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
			out.print("sid;" + mapConfig.get("sid")
					+","+"locationName;" + mapConfig.get("achLocationName")
					+","+"currency;" + mapConfig.get("currency")
					+","+"paymentProfile;" + mapConfig.get("paymentProfile")
					+","+"serviceUrl;"+ mapConfig.get("serviceUrl"));							
		}		
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// Postprocess request: gather and validate submitted data and display result in same JSP.

		// Get request parameters from form.jsp (all the attributes that the user inputs)
		achNum = request.getParameter("achNum");
		achLast4 = request.getParameter("achLast4");
		achToken1 = request.getParameter("achToken1");
		achToken2 = request.getParameter("achToken2");
		achToken3 = request.getParameter("achToken3");
		achToken4 = request.getParameter("achToken4");
		
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

		// Create a map to be returned to the client's browser at the end
		Map<String, String> globalMap = new LinkedHashMap<String, String>();
		globalMap.put("achNum", achNum);
		globalMap.put("achLast4", achLast4);
		globalMap.put("achToken1", achToken1);
		globalMap.put("achToken2", achToken2);
		globalMap.put("achToken3", achToken3);
		globalMap.put("achToken4", achToken4);
		// Send globalMap to the response page
		request.setAttribute("globalMap", globalMap);
			
		// Pass all the information that was collected to the confirmation page
		// "webCheckoutConfirmation.jsp"
		request.getRequestDispatcher("/webCheckoutConfirmation.jsp").forward(request, response);
	
		// END: of doPost
	}
}