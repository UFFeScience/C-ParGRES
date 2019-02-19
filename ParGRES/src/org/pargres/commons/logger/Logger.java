/*
 * Created on 20/04/2005
 */
package org.pargres.commons.logger;

import java.io.File;
import java.net.URL;

import org.apache.log4j.PropertyConfigurator;



/**
 * Systems logger.
 * 
 * @author <a href="mailto:bmiranda@cos.ufrj.br">Bernardo Miranda</a>
 */

public class Logger {
    
    /**
	 * 
	 */
	static File getFile(String fileName) {
		File file = new File(fileName);
		if(!file.exists()) {
			return null;
		} else
			return file;
	}	
	
	static {
		try {
			File file;
			if((file = getFile("../log4j.properties")) != null || (file = getFile("log4j.properties")) != null) {
				URL log4jprops = file.toURL();
			    if (log4jprops != null) {
			        PropertyConfigurator.configure(log4jprops);
			    }
			} else
				System.err.println("Log configuration file not found!");
			
		} catch (Exception e) {
			e.printStackTrace();
			System.err.println(e.getMessage());
		}
	}
	
	private org.apache.log4j.Logger logger;
    
    private Logger(org.apache.log4j.Logger logger) {
        this.logger = logger;
    }
    /**
     * @param arg0
     * @return
     */
    public static Logger getLogger(Class arg0) {
        return new Logger(org.apache.log4j.Logger.getLogger(arg0));
    }

    /**
     * @param arg0
     */
    public void debug(Object arg0) {
        logger.debug(arg0);
    }
    /**
     * @param arg0
     */
    public void error(Object arg0) {
        logger.error(arg0);
    }
    /**
     * @param arg0
     */
    public void fatal(Object arg0) {
        logger.fatal(arg0);
    }
    /**
     * @param arg0
     */
    public void info(Object arg0) {
        logger.info(arg0);
    }
    /**
     * @param arg0
     */
    public void warn(Object arg0) {
        logger.warn(arg0);
    }
}
