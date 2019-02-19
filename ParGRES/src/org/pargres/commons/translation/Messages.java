package org.pargres.commons.translation;

import java.io.File;
import java.net.URL;
import java.net.URLClassLoader;
import java.text.MessageFormat;
import java.util.Locale;
import java.util.ResourceBundle;

public class Messages {
	private static ResourceBundle messages;
	
	static File getDir(String dir) {
		File file = new File(dir);
		if(!file.exists()) {
			return null;
		} else
			return file;
	}
	
	static {
		try {
			File file;
			if((file = getDir("../language")) != null || (file = getDir("./language")) != null) {	
				URL propUrl = file.toURL();
			    if (propUrl != null) {
			    	URL[] aurl = new URL[1];
			    	aurl[0] = propUrl;
			    	ClassLoader cl = new URLClassLoader(aurl);
			    	
					//String language = "en";
					//String country = new String("US");
					Locale currentLocale = Locale.getDefault();
					//Locale currentLocale = new Locale(language, country);
					
			    	messages = ResourceBundle.getBundle("MessagesBundle",currentLocale,cl);
			    }
			} else	
				System.err.println("Language configuration directory not found!");			
		} catch (Exception e) {
			e.printStackTrace();
			System.out.println("Translation start failed!");
		}
            
	}
	
	public static String getString(String key) {
		return messages.getString(key);
	}
	
	public static String getString(String key, int param) {		
		return getString(key, new Integer[]{param});
	}
	
	public static String getString(String key, double param) {		
		return getString(key, new Double[]{param});
	}	
	
	public static String getString(String key, long param) {		
		return getString(key, new Long[]{param});
	}	
	
	public static String getString(String key, String param) {		
		return getString(key, new String[]{param});
	}	
	
	public static String getString(String key, boolean param) {		
		return getString(key, new Boolean[]{param});
	}
	
	public static String getString(String key, Exception error) {		
		return getString(key, error.getMessage());
	}		
	
	public static String getString(String key, Object[] params) {		
		return MessageFormat.format(getString(key),params);
	}		

}
