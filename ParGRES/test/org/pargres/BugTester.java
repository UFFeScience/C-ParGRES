/*
 * @author <a href="mailto:bmiranda@cos.ufrj.br">Bernardo Miranda</a>
 * Pargres Project <http://pargres.nacad.ufrj.br>
 */
package org.pargres;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;

import org.pargres.util.HsqlDatabase;
import org.pargres.util.PargresClusterProcessor;
import org.pargres.util.PargresNodeProcessor;

import junit.framework.TestCase;

public class BugTester extends TestCase {
    HsqlDatabase hsqlDatabase1 = new HsqlDatabase(9001);
    HsqlDatabase hsqlDatabase2 = new HsqlDatabase(9002);	    
    PargresNodeProcessor nqp1 = new PargresNodeProcessor(3001,9001);          
    PargresNodeProcessor nqp2 = new PargresNodeProcessor(3002,9002);
    PargresClusterProcessor cqp = new PargresClusterProcessor(8050,"./config/PargresConfig2NodesLocal.xml");
	/*
	public void testBug1() throws Exception {
		String sql = "SELECT 1 FROM LINEITEM";// WHERE L_ORDERKEY < 500";
        Class.forName("org.pargres.jdbc.Driver");
        Connection con = DriverManager.getConnection("jdbc:pargres://localhost","user","");
		ResultSet rs = con.createStatement().executeQuery(sql);
		assertNotNull(rs);
	}*/
	
	public void testBug2() throws Exception {
		//Sem where funciona
		//String sql = "SELECT L_QUANTITY FROM LINEITEM";
        Class.forName("org.pargres.jdbc.Driver");
        Connection con = DriverManager.getConnection("jdbc:pargres://localhost","user","");
		/*ResultSet rs = con.createStatement().executeQuery(sql);
		assertNotNull(rs);*/
	
		String sql2 = "SELECT 1, COUNT(L_ORDERKEY) FROM LINEITEM group by 1";
		ResultSet rs2 = con.createStatement().executeQuery(sql2);
		while (rs2.next())
		  System.out.println("COUNT: " + rs2.getString(1));
		
		//Com where NAO funciona		
		/*String sql3 = "SELECT L_QUANTITY FROM LINEITEM WHERE L_ORDERKEY < 500";
		ResultSet rs3 = con.createStatement().executeQuery(sql2);
		assertNotNull(rs3);*/
	}	
	/*	
	public void testBug3() throws Exception {
		String sql = "SELECT SUM(L_QUANTITY) FROM LINEITEM WHERE L_ORDERKEY < 500";
        Class.forName("org.pargres.jdbc.Driver");
        Connection con = DriverManager.getConnection("jdbc:pargres://localhost","user","");
		ResultSet rs = con.createStatement().executeQuery(sql);
		assertNotNull(rs);
	}		*/
	
    /*
     * @see TestCase#setUp()
     */
    protected void setUp() throws Exception {
	    hsqlDatabase1.start();        
	    hsqlDatabase2.start();
	    nqp1.start();	    
	    nqp2.start();
	    cqp.start();
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
