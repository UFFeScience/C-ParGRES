package org.pargres.configurator;

import java.io.File;
import java.net.URL;
import java.net.URLClassLoader;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

import org.pargres.commons.logger.Logger;
import org.pargres.cqp.UserManager;
import org.pargres.cqp.connection.ConnectionManagerImpl;
import org.pargres.jdbc.specifics.DatabaseProperties;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;
import org.xml.sax.ErrorHandler;
import org.xml.sax.SAXException;
import org.xml.sax.SAXParseException;

public class Configurator {
	private static Logger logger = Logger.getLogger(Configurator.class);
	private UserManager userManager = new UserManager();
	private DatabaseProperties databaseProperties = new DatabaseProperties();
    private DatabaseProperties sortProperties = new DatabaseProperties();
	private ConnectionManagerImpl connectionManagerImpl;
	private String configurationFile;
	
	public Configurator(String configurationFile, ConnectionManagerImpl ConnectionManagerImpl) {
		this.connectionManagerImpl = ConnectionManagerImpl;
		this.configurationFile = configurationFile;
	}
	
	public void config() throws Exception {
		try {
		DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
		dbf.setCoalescing(true);
		dbf.setValidating(true);
		dbf.setIgnoringElementContentWhitespace(true);
		dbf.setNamespaceAware(true);
		DocumentBuilder db= dbf.newDocumentBuilder();
		db.setErrorHandler(new MyErrorHandler());
		
		Document doc = null;
		
			
			File file = new File(configurationFile);
			
			String fileName = file.getName();
			String dirName = file.getParentFile().getPath();
			
			File dir = new File(dirName);
			
			URL propUrl = dir.toURL();
	    	URL[] aurl = new URL[1];
	    	aurl[0] = propUrl;
	    	ClassLoader cl = new URLClassLoader(aurl);
			
			doc = db.parse(cl.getResourceAsStream(fileName));

			//users
			NodeList users = doc.getElementsByTagName("users").item(0).getChildNodes();			
			for(int i = 0; i < users.getLength(); i++) {
				Element user = (Element)users.item(i);
				userManager.put(user.getAttribute("name"),user.getAttribute("password"));
			}
			//metadata
			NodeList vps = doc.getElementsByTagName("metadata").item(0).getChildNodes();			
			for(int i = 0; i < vps.getLength(); i++) {
				Element vp = (Element)vps.item(i);
				databaseProperties.addProperties(vp.getAttribute("table"),vp.getAttribute("field"));
			}
      
			//nodes			
			NodeList nodes = doc.getElementsByTagName("cluster").item(0).getChildNodes();			
			for(int i = 0; i < nodes.getLength(); i++) {
				Element node = (Element)nodes.item(i);
				connectionManagerImpl.addNode(node.getAttribute("host"),Integer.parseInt(node.getAttribute("port")));
			}
            
             //sort
            if (doc.getElementsByTagName("sort").item(0) != null) {
                NodeList sortFields = doc.getElementsByTagName("sort").item(0).getChildNodes();            
                for(int i = 0; i < sortFields.getLength(); i++) {
                    Element field = (Element)sortFields.item(i);
                    sortProperties.addProperties(field.getAttribute("table"),field.getAttribute("field"));
                }
            }    
		} catch (Exception e) {	
			logger.error(e);
			throw e;
		}
	}
	
	   private static class MyErrorHandler implements ErrorHandler {
		      public void warning(SAXParseException e) throws SAXException {
		         System.out.println("Warning: "); 
		         printInfo(e);
		      }
		      public void error(SAXParseException e) throws SAXException {
		         System.out.println("Error: "); 
		         printInfo(e);
		      }
		      public void fatalError(SAXParseException e) throws SAXException {
		         System.out.println("Fattal error: "); 
		         printInfo(e);
		      }
		      private void printInfo(SAXParseException e) {
		      	 System.out.println("   Public ID: "+e.getPublicId());
		      	 System.out.println("   System ID: "+e.getSystemId());
		      	 System.out.println("   Line number: "+e.getLineNumber());
		      	 System.out.println("   Column number: "+e.getColumnNumber());
		      	 System.out.println("   Message: "+e.getMessage());
		      }
		   }

	public DatabaseProperties getDatabaseProperties() {
		return databaseProperties;
	}

	public UserManager getUserManager() {
		return userManager;
	}

    public DatabaseProperties getSortProperties() {
        return sortProperties;
    }	
}
