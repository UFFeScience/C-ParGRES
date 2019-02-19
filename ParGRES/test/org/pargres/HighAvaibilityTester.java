package org.pargres;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;

import junit.framework.TestCase;

import org.pargres.util.HsqlDatabase;
import org.pargres.util.PargresClusterProcessor;
import org.pargres.util.PargresNodeProcessor;

public class HighAvaibilityTester extends TestCase {
    HsqlDatabase hsqlDatabase1 = new HsqlDatabase(9001);
    HsqlDatabase hsqlDatabase2 = new HsqlDatabase(9002);	    
    PargresNodeProcessor nqp1 = new PargresNodeProcessor(3001,9001);          
    PargresNodeProcessor nqp2 = new PargresNodeProcessor(3002,9002);
    PargresClusterProcessor cqp = new PargresClusterProcessor(8050,"./config/PargresConfig2NodesLocal.xml");
    
    public void testInterQueryDBMSError() throws Exception {
    	    hsqlDatabase1.start();        
    	    hsqlDatabase2.start();
    	    nqp1.start();	    
    	    nqp2.start();
    	    cqp.start();

    	    hsqlDatabase1.stop();    	
    	    
            Class.forName("org.pargres.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:pargres://localhost","user","");
            assertNotNull(con);        		
    		ResultSet rs = con.createStatement().executeQuery("SELECT COUNT(*) FROM REGION");
    		assertNotNull(rs);
    		assertTrue(rs.next());
    		assertNotNull(rs.getInt(1));
    	    
    	    nqp1.stop();	    
    	    nqp2.stop();        
    	    hsqlDatabase2.stop();		            
    }
    
    public void testUpdateWithNodeError() throws Exception {
	    hsqlDatabase1.start();        
	    hsqlDatabase2.start();
	    nqp1.start();	    
	    nqp2.start();
	    cqp.start();
	    
	    hsqlDatabase1.stop();    	
	    
        Class.forName("org.pargres.jdbc.Driver");
        Connection con = DriverManager.getConnection("jdbc:pargres://localhost","user","");
        assertNotNull(con);        		
		int count = con.createStatement().executeUpdate("CREATE TABLE TEST (ID INTEGER)");
		assertTrue(count == 0);	    
		
		ResultSet rs = con.createStatement().executeQuery("SELECT COUNT(*) FROM REGION");
		assertNotNull(rs);
		assertTrue(rs.next());
		assertNotNull(rs.getInt(1));		

	    nqp1.stop();	    
	    nqp2.stop();
	    hsqlDatabase2.stop();		            
}    

}
