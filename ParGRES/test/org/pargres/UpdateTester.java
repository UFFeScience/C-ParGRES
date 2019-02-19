/*
 * Created on 08/04/2005
 */
package org.pargres;
import java.sql.Connection;
import java.sql.DriverManager;

import junit.framework.TestCase;

import org.pargres.commons.logger.Logger;
import org.pargres.commons.util.JdbcUtil;
import org.pargres.util.HsqlDatabase;
import org.pargres.util.PargresClusterProcessor;
import org.pargres.util.PargresNodeProcessor;

/**
 * @author Bernardo
 */
public class UpdateTester extends TestCase {
    HsqlDatabase hsqlDatabase1 = new HsqlDatabase(9001);
    HsqlDatabase hsqlDatabase2 = new HsqlDatabase(9002);	    
    PargresNodeProcessor nqp1 = new PargresNodeProcessor(3001,9001);          
    PargresNodeProcessor nqp2 = new PargresNodeProcessor(3002,9002);
    PargresClusterProcessor cqp = new PargresClusterProcessor(8050,"./config/PargresConfig2NodesLocal.xml");
	
	private static Logger logger = Logger.getLogger(UpdateTester.class);
	
    public void testSimpleQuery() throws Exception {
        Class.forName("org.pargres.jdbc.Driver");
        Connection con = DriverManager.getConnection("jdbc:pargres://localhost","user","");
        assertNotNull(con);        		
		con.createStatement().executeUpdate("UPDATE LINEITEM SET L_QUANTITY = -1 WHERE L_ORDERKEY = 0");
    }
	
	
    public void testCreateDropTable() throws Exception {
        Class.forName("org.pargres.jdbc.Driver");
        Connection con = DriverManager.getConnection("jdbc:pargres://localhost","user","");
        assertNotNull(con);
		String tableName = "TEST_TABLE";
		con.createStatement().executeUpdate("CREATE TABLE "+tableName+" (ID INTEGER)");
	/*	try {
			con.createStatement().executeQuery("SELECT * FROM "+tableName);
		} catch (Exception e) {
			fail("Table not created: "+e);
		}
		*/
		con.createStatement().executeUpdate("INSERT INTO "+tableName+" VALUES (1)");
		con.createStatement().executeUpdate("UPDATE "+tableName+" SET ID = 2");
		con.createStatement().executeUpdate("DROP TABLE "+tableName+"");
    }  	
    
    public void testConcurrentUpdate() throws Exception {
        Worker w1 = new Worker(JdbcUtil.LAZY_UPDATE);
        Worker w2 = new Worker("SELECT COUNT(*) FROM REGION");
        Worker w3 = new Worker("SELECT COUNT(*) FROM REGION");        
    	w1.start();
    	Thread.sleep(50);
    	w2.start();
    	Thread.sleep(50);
    	w3.start();    	
    	w1.join();
    	w2.join();
    	w3.join();    	
    	if(w1.endTime == 0)
    		fail("Query w1 failed!");    	
    	if(w2.endTime == 0)
    		fail("Query w2 failed!");
    	if(w3.endTime == 0)
    		fail("Query w2 failed!");    	
    	if((w2.endTime < w1.endTime) || (w3.endTime < w1.endTime))
    		fail("Concurrent update processing failed! [w1="+w1.endTime+"][w2="+w2.endTime+"][w3="+w3.endTime+"]");		
    }      
    
    public void testTwoUpdates() throws Exception {
    	Worker w1 = new Worker(JdbcUtil.LAZY_UPDATE);
    	Worker w2 = new Worker(JdbcUtil.LAZY_UPDATE);
    	w1.start();
    	Thread.sleep(10);
    	w2.start();
    	w1.join();
    	w2.join();
    	if(w1.endTime == 0)
    		fail("Query w1 failed!");    	
    	if(w2.endTime == 0)
    		fail("Query w2 failed!");    	
    	if((w1.endTime >= w2.endTime))
    		fail("update block failed!");	     	
    }
	
   public void testManyConcurrentUpdates() throws Exception {
        Worker w1 = new Worker(JdbcUtil.LAZY_UPDATE);
        Worker w2 = new Worker("SELECT COUNT(*) FROM REGION");
        Worker w3 = new Worker("SELECT COUNT(*) FROM REGION");
        Worker w4 = new Worker(JdbcUtil.LAZY_UPDATE);
        Worker w5 = new Worker("SELECT COUNT(*) FROM REGION");
    	w1.start();
    	Thread.sleep(50);
    	w2.start();
    	Thread.sleep(50);
    	w3.start(); 
    	Thread.sleep(50);
    	w4.start();
    	Thread.sleep(50);
    	w5.start();    	
    	w1.join();
    	w2.join();
    	w3.join();
    	w4.join();
    	w5.join();    	
    	if(w1.endTime == 0)
    		fail("Query w1 failed!");    	
    	if(w2.endTime == 0)
    		fail("Query w2 failed!");
    	if(w3.endTime == 0)
    		fail("Query w3 failed!");    
    	if(w4.endTime == 0)
    		fail("Query w4 failed!");    	
    	if(w5.endTime == 0)
    		fail("Query w5 failed!");    	
    	if(w2.endTime < w1.endTime)
    		fail("Concurrent update processing failed!");
    	if(w3.endTime < w1.endTime)
    		fail("Concurrent update processing failed!");	
    	if((w5.endTime < w4.endTime))
    		fail("Blocking failed!");	    	
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
        //org.pargres.cqp.connection.ConnectionManagerImpl.register();
    }

    /*
     * @see TestCase#tearDown()
     */
    protected void tearDown() throws Exception {
    //	System.out.println("TEAR DOWN!");
	    cqp.stop();
	   // System.out.println("TEAR DOWN 1!");
	    nqp1.stop();	    
	   // System.out.println("TEAR DOWN 2!");
	    nqp2.stop();
	   // System.out.println("TEAR DOWN 3!");
	    hsqlDatabase1.stop();        
	   // System.out.println("TEAR DOWN 4!");
	    hsqlDatabase2.stop();		
	   // System.out.println("TEAR DOWN 5!");
		//org.pargres.cqp.connection.ConnectionManagerImpl.unregister();
    }
    
	class Worker extends Thread {
		private String sql;
		public Worker(String sql) {
			this.sql = sql;
		}
		public long endTime = 0;
		public void run() {
			try {
		        Class.forName("org.pargres.jdbc.Driver");
		        Connection con = DriverManager.getConnection("jdbc:pargres://localhost","user","");
		        assertNotNull(con);        	
				boolean e = con.createStatement().execute(sql);
				assertTrue(e);
				endTime = System.currentTimeMillis();
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
	}
	
}
