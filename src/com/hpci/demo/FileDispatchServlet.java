package com.hpci.demo;

import java.io.BufferedReader;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.net.URL;
import java.net.URLConnection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;

@WebServlet("/FileDispatchServlet")
@MultipartConfig
public class FileDispatchServlet extends HttpServlet {

	private static final long serialVersionUID = 1L;
	private String flag = "";
	private Map<String, String> mapConfig ;
	
	private static final String PXY_MSGDISPATCH = "/iSynSApp/paymentFileDispatch.action";
	
	private static final String PXYPARAM_APIVERSION = "apiVersion";
	private static final String PXYPARAM_APIVERSION_NUM = "1.0.1";	
	private static final String PXYPARAM_APITYPE = "apiType";
	private static final String PXYPARAM_APITYPE_PXYHPCI = "pxyhpci";
	private static final String PXYPARAM_DISPATCHREQUEST_PROFILENAME = "dispatchRequest.profileName";
	private static final String PXYPARAM_DISPATCHREQUEST_DESTFILENAME = "dispatchRequest.destFileName";
	private static final String PXYPARAM_USERNAME = "userName";
	private static final String PXYPARAM_USERPASSKEY = "userPassKey";
	
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
	
	private String authId;

	private String getFilename(Part part) {
		String contentDispositionHeader = part.getHeader("content-disposition");
		String[] elements = contentDispositionHeader.split(";");
		for (String element : elements) {
			if (element.trim().startsWith("filename")) {
				return element.substring(element.indexOf('=') + 1).trim().replace("\"", "");
			}
		}
		return null;
	}
	
	private void logMessage(String msg) {
		System.out.println(msg);
	}
	
	public static String callUrl(String urlString, Map<String, String> paramMap, String fileName,
			InputStream dispatchFileStream) {

		String urlReturnValue = "";
		String charset = "UTF-8";
		URLConnection connection = null;
		
		String boundary = Long.toHexString(System.currentTimeMillis()); // Just generate some unique random value.
		String CRLF = "\r\n"; // Line separator required by multipart/form-data.

		try {

			connection = new URL(urlString).openConnection();
			connection.setDoOutput(true);
			connection.setRequestProperty("Content-Type", "multipart/form-data; boundary=" + boundary);
			PrintWriter writer = null;
			try {
			    OutputStream output = connection.getOutputStream();
			    writer = new PrintWriter(new OutputStreamWriter(output, charset), true);
	
			    // Send normal param.
			    for (Entry<String, String> paramEntry : paramMap.entrySet()) {
	
				    writer.append("--" + boundary).append(CRLF);
				    writer.append("Content-Disposition: form-data; name=\"" + paramEntry.getKey() + "\"").append(CRLF);
				    writer.append("Content-Type: text/plain; charset=" + charset).append(CRLF);
				    writer.append(CRLF);
				    writer.append(paramEntry.getValue()).append(CRLF).flush();
			    }
	
			    // Send text file.
			    writer.append("--" + boundary).append(CRLF);
			    writer.append("Content-Disposition: form-data; name=\"tokenFile\"; filename=\"" + fileName +"\"").append(CRLF);
			    writer.append("Content-Type: text/plain; charset=" + charset).append(CRLF);
			    writer.append(CRLF).flush();
			    BufferedReader reader = null;
			    try {
			        reader = new BufferedReader(new InputStreamReader(dispatchFileStream, charset));
			        for (String line; (line = reader.readLine()) != null;) {
			            writer.append(line).append(CRLF);
			        }
			    } finally {
			        if (reader != null) try { reader.close(); } catch (IOException logOrIgnore) {}
			    }
			    // End of multipart/form-data.
			    writer.append("--" + boundary + "--").append(CRLF);
			    writer.flush();
			    
			    // Get the response
			    BufferedReader rd = new BufferedReader(new InputStreamReader(connection.getInputStream()));
			    String line;
			    while ((line = rd.readLine()) != null) {
			    	urlReturnValue = urlReturnValue + line;
			    }
			    rd.close();

			} finally {
			    if (writer != null) writer.close();
			}		
		
		} catch (Exception e) {
			e.printStackTrace();
			urlReturnValue = "";
			Map<String, List<String>> map = connection.getHeaderFields();
			for (Map.Entry<String, List<String>> entry : map.entrySet()) {
				System.out.println("Key : " + entry.getKey() +
			                 " ,Value : " + entry.getValue());
			}
			return map.toString();
		}	
		return urlReturnValue;
	}
	
	private String dispatchOnly(String serviceUrl, String userName, String userPassKey, String fileName,
			String destFileName, InputStream dispatchFileStream, String profileName) {

		// make the remote call
		String callUrl = serviceUrl + PXY_MSGDISPATCH;
		
	    // prepare the api call
		Map<String, String> paramMap = new HashMap<String, String>();
		paramMap.put(PXYPARAM_APIVERSION, PXYPARAM_APIVERSION_NUM);
		paramMap.put(PXYPARAM_APITYPE, PXYPARAM_APITYPE_PXYHPCI);
		paramMap.put(PXYPARAM_USERNAME, userName);
		paramMap.put(PXYPARAM_USERPASSKEY, userPassKey);
		paramMap.put(PXYPARAM_DISPATCHREQUEST_PROFILENAME, profileName);
		if(destFileName != null && !destFileName.isEmpty())
			paramMap.put(PXYPARAM_DISPATCHREQUEST_DESTFILENAME, destFileName);
	    
	    logMessage("========================================================");
		logMessage("Make the call: " + callUrl);
		logMessage("Call payload: " + paramMap);
		String callResult = callUrl(callUrl, paramMap, fileName, dispatchFileStream);
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
	
	private InputStream copyInputStream( InputStream input) {
		InputStream inFileStream = null;
		
		try {
	    		ByteArrayOutputStream baos = new ByteArrayOutputStream();
	    		
	    		byte[] buffer = new byte[1024];
	    		int len;
	    		while ((len = input.read(buffer)) > -1 ) {
	    		    baos.write(buffer, 0, len);
	    		}
	    		baos.flush();
	    		
	    		inFileStream = new ByteArrayInputStream(baos.toByteArray()); 
	    		
	    } catch (Exception e) {
	        e.printStackTrace();
	        logMessage("Error coping the multipart file.");
	    }
		
		return inFileStream;
	}
	
	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		// Preprocess request
		/// Get flag from the ajax call
		if (request.getParameterMap().containsKey("flag")) {
			flag = request.getParameter("flag");
		}
		mapConfig = DemoUtil.getConfigProperties(null);

		if (flag.equals("config")) {
			response.setHeader("Cache-Control", "no-cache");
			response.setHeader("Pragma", "no-cache");
			response.setCharacterEncoding("utf-8");
			response.setContentType("text/html");

			PrintWriter out = response.getWriter();

			// Initiate the call back
			out.print("sid;" + mapConfig.get(PROPERTY_SID) + "," + "locationName;" + mapConfig.get(PROPERTY_LOCATION_NAME) + ","
					+ "serviceUrl;" + mapConfig.get(PROPERTY_SERVICE_URL)
					+","+"paymentProfile;" + mapConfig.get("paymentProfile"));
		}
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		
		if(mapConfig == null)
			mapConfig = DemoUtil.getConfigProperties(null);
		
		InputStream dispatchFileStream = null;
		Part part = request.getPart("tokenFile");
		
		String serviceUrl = mapConfig.get(PROPERTY_API_SERVICE_URL);
		String userName = mapConfig.get(PXYPARAM_USERNAME);
		String userPassKey = mapConfig.get(PXYPARAM_USERPASSKEY);
		String fileName = getFilename(part);
		String destFileName = request.getParameter(PXYPARAM_DISPATCHREQUEST_DESTFILENAME);
		String profileName = request.getParameter(PXYPARAM_DISPATCHREQUEST_PROFILENAME);
		
		response.setHeader("Cache-Control", "no-cache");
		response.setHeader("Pragma", "no-cache");
		response.setCharacterEncoding("utf-8");
		response.setContentType("text/html");

		PrintWriter out = response.getWriter();
		
		if (fileName != null && !fileName.isEmpty()) {
			//Copy file
			dispatchFileStream = copyInputStream(part.getInputStream());
		}
		
		if(dispatchFileStream == null){
			out.print("Error uploading the file.");
			return;
		}

		String callResult = dispatchOnly(serviceUrl, userName, userPassKey, fileName, destFileName, 
				dispatchFileStream, profileName);
		
		// Initiate the call back
		out.print(callResult);
	}
}
