package com.isyn;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.io.UnsupportedEncodingException;
import java.net.URL;
import java.net.URLConnection;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.util.LinkedHashMap;
import java.util.Map;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

public class DemoUtil {
	
	// The callUrl method, it needs a complete url + populated map of pairs
	// (key,value)
	public static String callUrl(String urlString, Map<String, String> paramMap) {
		String urlReturnValue = "";
		try {
			// Construct data
			StringBuffer dataBuf = new StringBuffer();
			boolean firstParam = true;
			for (String paramKey : paramMap.keySet()) {
				if (!firstParam)
					dataBuf.append("&");
				dataBuf.append(URLEncoder.encode(paramKey, "UTF-8"))
						.append("=")
						.append(URLEncoder.encode(paramMap.get(paramKey),
								"UTF-8"));
				firstParam = false;
			}
			String data = dataBuf.toString();

			// Send data
			URL url = new URL(urlString);
			URLConnection conn = url.openConnection();
			conn.setDoOutput(true);
			OutputStreamWriter wr = new OutputStreamWriter(
					conn.getOutputStream());
			wr.write(data);
			wr.flush();

			// Get the response
			BufferedReader rd = new BufferedReader(new InputStreamReader(
					conn.getInputStream()));
			String line;
			while ((line = rd.readLine()) != null) {
				urlReturnValue = urlReturnValue + line;
			}
			wr.close();
			rd.close();
		} catch (Exception e) {
			e.printStackTrace();
			urlReturnValue = "";
		}
		return urlReturnValue;
		
	} //END: callUrl
	
	// The parseQueryString method, it uses the response from the callUrl method
	// And puts it inside a map of pairs
	public static Map<String, String> parseQueryString(String queryStr) {
		Map<String, String> map = new LinkedHashMap<String, String>();
		String queryStrDecoded = "";
		if (queryStr == null)
			return map;

		try {
			queryStrDecoded = URLDecoder.decode(queryStr, "UTF-8");
		} catch (UnsupportedEncodingException e1) {
			e1.printStackTrace();
		}
		String[] params = queryStrDecoded.split("&");
		for (String param : params) {
			String name = "";
			String value = "";

			String[] paramPair = param.split("=", 2);
			if (paramPair != null && paramPair.length > 0) {
				name = paramPair[0];
				if (paramPair.length > 1 && paramPair[1] != null) {
					try {
						if (paramPair.length == 2) {
							value = URLDecoder.decode(paramPair[1], "UTF-8");
						} else // paramPair.length >= 3
						{
							value = URLDecoder.decode(
									paramPair[paramPair.length - 1], "UTF-8");
						}

					} catch (UnsupportedEncodingException e) {
						logMessage("Could not decode:" + paramPair[1]);
					}
				}
			}
			map.put(name, value);
		}
		return map;
	} // END: parseQueryString

	// Needed for the callUrl and parseQueryString methods
	public static void logMessage(String msg) {
		System.out.println(msg);
	}
			
	public static Map<String, String> getConfigProperties(){
		Map<String, String> mapConfig = new LinkedHashMap<String, String>();
		String homeDir = System.getProperty("user.home");
		String osName = System.getProperty("os.name");
		String configFile;
		
		if(osName.toUpperCase().indexOf("WINDOWS")>-1)
			configFile = homeDir + "\\" + "HostedPCIConfig.xml";			
		else
			configFile = homeDir + "/"+"HostedPCIConfig.xml";
		
		try (InputStream in = new FileInputStream(configFile)) {			
			Properties prop = new Properties();
			prop.loadFromXML(in);
									
			System.out.println("####Properties. Loading from xml ####");
			for (String property : prop.stringPropertyNames()) {
				String value = prop.getProperty(property);
				System.out.println(property + "=" + value);
				mapConfig.put(property, value);
			}
			
			return mapConfig;			
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		 }
		//Property not found
		return mapConfig;
	}
	
} // END: DemoUtil

