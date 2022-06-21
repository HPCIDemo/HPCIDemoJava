package com.hpci.demo;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.io.UnsupportedEncodingException;
import java.net.URL;
import java.net.URLConnection;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

public class DemoUtil {
	
	private static String SETTINGS_FILE_NAME_DEF = "HostedPCIConfig.xml";
	
	// The callUrl method, it needs a complete url + populated map of pairs
	// (key,value)
	public static String callUrl(String urlString, Map<String, String> paramMap) {
		String urlReturnValue = "";
		URLConnection conn = null;
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
			conn = url.openConnection();
			conn.setDoOutput(true);
			System.out.println("====================================");
			System.out.printf("Calling URL: %n 	%s %n", urlString);
			System.out.println("Request parameters:");
			paramMap.forEach((k,v) -> {
				System.out.printf("	%s=%s%n",k, v);
			});
			
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
			Map<String, List<String>> map = conn.getHeaderFields();
			for (Map.Entry<String, List<String>> entry : map.entrySet()) {
				System.out.println("Key : " + entry.getKey() +
			                 " ,Value : " + entry.getValue());
			}
			return map.toString();
		}
		
		Map<String, String> sortedMap = null;

		if (urlReturnValue != null && !urlReturnValue.isEmpty()) {
			sortedMap = parseQueryString(urlReturnValue);
			if (sortedMap != null) {
				System.out.println("================Begin HPCI Response log(formatted)===========");

				sortedMap = sortedMap.entrySet().stream()
						.sorted(Map.Entry.comparingByKey()).collect(Collectors.toMap(Map.Entry::getKey, Map.Entry::getValue,
								(e1, e2) -> e1, LinkedHashMap::new));

				sortedMap.forEach((k, v) -> {
					if(!k.isEmpty())
						System.out.println(k + "=" + v);
				});
				System.out.println("================End HPCI Response log(formatted)===========");
			}
			else {
				System.out.printf("Response:%n	%s%n", urlReturnValue);
				System.out.println("====================================");
			}
		}
		
		return urlReturnValue;
		
	} //END: callUrl
	
	// The parseQueryString method, it uses the response from the callUrl method
	// And puts it inside a map of pairs
	public static Map<String, String> parseQueryString(String queryStr) {
		Map<String, String> map = new LinkedHashMap<String, String>();
		String queryStrDecoded = "";
		String name = "";
		String value = "";
		
		if (queryStr == null)
			return map;

		try {
			queryStrDecoded = URLDecoder.decode(queryStr, "UTF-8");
		} catch (UnsupportedEncodingException e1) {
			e1.printStackTrace();
		}
		
		Pattern pat = Pattern.compile("pxyResponse.fullNativeResp(.*?)pxyResponse");
        Matcher mat = pat.matcher(queryStrDecoded);
        
        String pxyFullNativeResp = "";
        String gtyTokenpxyFullNativeResp = "";
        
        if(mat.find()) {
        	pxyFullNativeResp = mat.group(0).replace("&pxyResponse","");
        	queryStrDecoded = mat.replaceAll("&pxyResponse");
        }
        
        pat = Pattern.compile("pxyResponse.gatewayToken.fullNativeResp(.*?)pxyResponse");
        mat = pat.matcher(queryStrDecoded);
        if(mat.find()) {
        	gtyTokenpxyFullNativeResp = mat.group(0).replace("&pxyResponse","");
        	queryStrDecoded = mat.replaceAll("&pxyResponse");
        }
        
		String[] params = queryStrDecoded.split("&");
		for (String param : params) {
			name = "";
			value = "";

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
		
		if(!pxyFullNativeResp.isEmpty()){
			params = pxyFullNativeResp.split("=", 2);
			if(params != null && params.length > 0) {
				try{
					name = params[0];
					value = "";
					if (params[1] != null && !params[1].isEmpty())
						value = URLDecoder.decode(params[1], "UTF-8");

					map.put(name, value);
				} catch (UnsupportedEncodingException e) {
					logMessage("Could not decode:" + value);
				}
			}
		}
		
		if(!gtyTokenpxyFullNativeResp.isEmpty()){
			params = gtyTokenpxyFullNativeResp.split("=", 2);
			if(params != null && params.length > 0) {
				try {
					name = params[0];
					value = "";
					if (params[1] != null && !params[1].isEmpty())
						value = URLDecoder.decode(params[1], "UTF-8");

					map.put(name, value);
				} catch (UnsupportedEncodingException e) {
					logMessage("Could not decode:" + value);
				}
			}
		}
		
		return map;
	} // END: parseQueryString

	// Needed for the callUrl and parseQueryString methods
	public static void logMessage(String msg) {
		System.out.println(msg);
	}
			
	public static Map<String, String> getConfigProperties(String settingsFileName){
		Map<String, String> mapConfig = new LinkedHashMap<String, String>();
		String homeDir = System.getProperty("user.home");
		String osName = System.getProperty("os.name");
		String configFile;
		String fileName = SETTINGS_FILE_NAME_DEF;
		if(settingsFileName != null && !settingsFileName.isEmpty())
			fileName = settingsFileName;
		
		if(osName.toUpperCase().indexOf("WINDOWS")>-1)
			configFile = homeDir + "\\" + fileName;			
		else
			configFile = homeDir + "/" + fileName;
		
		try (InputStream in = new FileInputStream(configFile)) {			
			Properties prop = new Properties();
			prop.loadFromXML(in);
									
			System.out.printf("####Begin Properties. Loading from xml ####%n", fileName);
			for (String property : prop.stringPropertyNames()) {
				String value = prop.getProperty(property);
				System.out.println(property + "=" + value);
				mapConfig.put(property, value);
			}
			System.out.println("###########End Properties#################");
			return mapConfig;			
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		 }
		//Property not found
		return mapConfig;
	}
	
} // END: DemoUtil

