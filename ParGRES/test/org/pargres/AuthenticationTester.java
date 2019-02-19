/*
 * Created on 08/04/2005
 */
package org.pargres;
import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.DriverManager;
import java.sql.ResultSet;

import junit.framework.TestCase;

import org.pargres.commons.logger.Logger;
import org.pargres.util.HsqlDatabase;
import org.pargres.util.PargresNodeProcessor;
import org.pargres.util.PargresClusterProcessor;

/**
 * @author Bernardo
 */
public class AuthenticationTester extends TestCase {
    HsqlDatabase hsqlDatabase1 = new HsqlDatabase(9001);
    HsqlDatabase hsqlDatabase2 = new HsqlDatabase(9002);	    
    PargresNodeProcessor nqp1 = new PargresNodeProcessor(3001,9001);          
    PargresNodeProcessor nqp2 = new PargresNodeProcessor(3002,9002);
    PargresClusterProcessor cqp = new PargresClusterProcessor(8050,"./config/PargresConfig2NodesLocal.xml");
	
	private static Logger logger = Logger.getLogger(AuthenticationTester.class);
	   
    public void testConnection() throws Exception {
        Class.forName("org.pargres.jdbc.Driver");
        Connection con = DriverManager.getConnection("jdbc:pargres://localhost","user","");
        assertNotNull(con); 
        DatabaseMetaData meta = con.getMetaData();
        assertNotNull(meta); 
       // assertTrue(con.createStatement().execute("SELECT 'X', COUNT(L_LINENUMBER) FROM LINEITEM"));//JdbcUtil.TEST_QUERY),true);
		ResultSet rs = con.createStatement().executeQuery("SELECT 'X', COUNT(L_LINENUMBER) FROM LINEITEM");//JdbcUtil.TEST_QUERY);
		assertNotNull(rs);
		rs.next();
		assertEquals(rs.getString(1),"X");
		con.close();
    }
    
    public void testBadConnection() throws Exception {
        Class.forName("org.pargres.jdbc.Driver");
        boolean fail = false;
        Connection con = null;
        try {
        	con = DriverManager.getConnection("jdbc:pargres://localhost","user","bad");
        	con.createStatement().execute("SELECT * FROM REGION");
        } catch (Exception e) {
        	fail = true;
        }
        if(con != null)
        	con.close();
        if(!fail)  {
        	fail("Pargres authetication is not working!");
        }
        
    }    
    /*
     * @see TestCase#setUp()
     */
    protected void setUp() throws Exception {
	    hsqlDatabase1.start();        
	    hsqlDatabase2.start();
	    nqp1.start();	    
	    nqp2.start();
	    cqp.start();
	    logger.info("setUp done!");		
    }

    /*
     * @see TestCase#tearDown()
     */
    protected void tearDown() throws Exception {
	    cqp.stop();
	    nqp1.stop();	    
	    nqp2.stop();
	    hsqlDatabase1.stop();        
	    hsqlDatabase2.stop();		
    }

}
