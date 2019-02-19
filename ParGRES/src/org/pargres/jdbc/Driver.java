/*
 * Created on 08/04/2005
 */
package org.pargres.jdbc;

import java.sql.DriverManager;
import java.sql.DriverPropertyInfo;
import java.sql.SQLException;
import java.sql.SQLFeatureNotSupportedException;
import java.util.Properties;
import java.util.logging.Logger;

import org.pargres.commons.interfaces.ConnectionManager;

/**
 * @author Bernardo
 */
public class Driver implements java.sql.Driver {
    public static final String URL_PATTERN = "jdbc:pargres://";
    
    static {
        try {
            DriverManager.registerDriver(new org.pargres.jdbc.Driver());
        } catch (Exception e) {
            
        }
    }

    /* (non-Javadoc)
     * @see java.sql.Driver#connect(java.lang.String, java.util.Properties)
     */
    public java.sql.Connection connect(String arg0, Properties arg1) throws SQLException {
    	if(!acceptsURL(arg0))
    		return null;
		arg0 = arg0.substring(URL_PATTERN.length());
		String host;
		int port;
		if(arg0.indexOf(":") > 0) {
			String[] params = arg0.split(":");
			host = params[0];
			port = (new Integer(params[1])).intValue();
		} else { 
			host = arg0;
			port = ConnectionManager.DEFAULT_PORT;
		}
		
        String user = arg1.getProperty("user");
        String passwd = arg1.getProperty("password");
        return new Connection(host,port,user,passwd);
    }

    /* (non-Javadoc)
     * @see java.sql.Driver#acceptsURL(java.lang.String)
     */
    public boolean acceptsURL(String arg0) throws SQLException {
        return arg0.startsWith(URL_PATTERN);
    }

    /* (non-Javadoc)
     * @see java.sql.Driver#getPropertyInfo(java.lang.String, java.util.Properties)
     */
    public DriverPropertyInfo[] getPropertyInfo(String arg0, Properties arg1) throws SQLException {
        return null;
    }

    /* (non-Javadoc)
     * @see java.sql.Driver#getMajorVersion()
     */
    public int getMajorVersion() {
        return 0;
    }

    /* (non-Javadoc)
     * @see java.sql.Driver#getMinorVersion()
     */
    public int getMinorVersion() {
        return 0;
    }

    /* (non-Javadoc)
     * @see java.sql.Driver#jdbcCompliant()
     */
    public boolean jdbcCompliant() {
        return false;
    }

    @Override
    public Logger getParentLogger() throws SQLFeatureNotSupportedException {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }
       
}
