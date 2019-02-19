/*
 * @author <a href="mailto:bmiranda@cos.ufrj.br">Bernardo Miranda</a>
 * Pargres Project <http://pargres.nacad.ufrj.br>
 */
package org.pargres;

import java.sql.Connection;
import java.sql.DriverManager;

import junit.framework.TestCase;

import org.pargres.util.HsqlDatabase;
import org.pargres.util.PargresClusterProcessor;
import org.pargres.util.PargresNodeProcessor;

public class MemoryCostTester extends TestCase {
	
	
	public void testStressInter() throws Exception {
	    HsqlDatabase hsqlDatabase1 = new HsqlDatabase(9001);
	    HsqlDatabase hsqlDatabase2 = new HsqlDatabase(9002);	    
	    PargresNodeProcessor nqp1 = new PargresNodeProcessor(3001,9001);          
	    PargresNodeProcessor nqp2 = new PargresNodeProcessor(3002,9002);
	    PargresClusterProcessor cqp = new PargresClusterProcessor(8050,"./config/PargresConfig2NodesLocal.xml");
	    
	    hsqlDatabase1.start();        
	    hsqlDatabase2.start();
	    nqp1.start();	    
	    nqp2.start();
	    cqp.start();	    
	    
	 //   NodeQueryProcessorEngine nqp = new NodeQueryProcessorEngine(9003,"org.hsqldb.jdbcDriver","jdbc:hsqldb:mem:testdb9001;ifexists=true","sa","",false);
	  //  nqp.shutdown();
	   // nqp = null;
        Class.forName("org.pargres.jdbc.Driver");
        Connection con = DriverManager.getConnection("jdbc:pargres://localhost","user","");
        assertNotNull(con);
        for(int i = 0; i < 5; i++) {
        	boolean e = con.createStatement().execute("SELECT 'X',COUNT(*) FROM LINEITEM");
        	assertTrue(e);
        	boolean e2 = con.createStatement().execute("SELECT * FROM NATION");
        	assertTrue(e2);
        	boolean e3 = con.createStatement().execute("INSERT INTO REGION VALUES (1,'OCEANIA','')");
        	assertTrue(e3);        	
        }
		con.close();
		con = null;
	    
	    cqp.stop();
	    nqp1.stop();	    
	    nqp2.stop();
	    hsqlDatabase1.stop();        
	    hsqlDatabase2.stop();
	    
	    cqp = null;
	    nqp1 = null;
	    nqp2 = null;
	    hsqlDatabase1 = null;
	    hsqlDatabase2 = null;	   
	    
	    for(int i = 0; i < 20; i++)
	    	System.gc();	   
	    	    
	}
}
