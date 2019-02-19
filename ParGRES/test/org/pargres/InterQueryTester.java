/*
 * Created on 08/04/2005
 */
package org.pargres;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;

import junit.framework.TestCase;

import org.pargres.commons.logger.Logger;
import org.pargres.commons.util.JdbcUtil;
import org.pargres.util.HsqlDatabase;
import org.pargres.util.PargresClusterProcessor;
import org.pargres.util.PargresNodeProcessor;

/**
 * @author Bernardo
 */
public class InterQueryTester extends TestCase {
    HsqlDatabase hsqlDatabase1 = new HsqlDatabase(9001);
    HsqlDatabase hsqlDatabase2 = new HsqlDatabase(9002);	    
    PargresNodeProcessor nqp1 = new PargresNodeProcessor(3001,9001);          
    PargresNodeProcessor nqp2 = new PargresNodeProcessor(3002,9002);
    PargresClusterProcessor cqp = new PargresClusterProcessor(8050,"./config/PargresConfig2NodesLocal.xml");
	
	private static Logger logger = Logger.getLogger(InterQueryTester.class);
	
    public void testSimpleQuery() throws Exception {
        Class.forName("org.pargres.jdbc.Driver");
        Connection con = DriverManager.getConnection("jdbc:pargres://localhost","user","");
        assertNotNull(con);        		
		ResultSet rs = con.createStatement().executeQuery("SELECT COUNT(*) FROM REGION");
		assertNotNull(rs);   
		rs.next();
		assertNotNull(rs.getString(1));
    }
	
    public void testLoadBalancer() throws Exception {
		int c = 10;
		Worker[] w = new Worker[c];
		for(int i = 0; i < c; i++)
			w[i] = new Worker("SELECT COUNT(*) FROM REGION");
		for(int i = 0; i < c; i++)
			w[i].start();
		for(int i = 0; i < c; i++)
			w[i].join();
		for(int i = 0; i < c; i++)
			if(w[i].endTime == 0)
				fail("Query w["+i+"] failed!");		
		
    	/*Worker w1 = new Worker("SELECT COUNT(*) FROM REGION");    	
    	Worker w2 = new Worker("SELECT COUNT(*) FROM REGION");
    	Worker w3 = new Worker("SELECT COUNT(*) FROM REGION");    	
    	Worker w4 = new Worker("SELECT COUNT(*) FROM REGION");		
			
    	w1.start();
    	w2.start();
    	w3.start();
    	w4.start();		
    	w1.join();
    	w2.join();
    	w3.join();
    	w4.join();*/		
    }	
    
    public void testScheduller() throws Exception {
    	
    	Worker w1 = new Worker(JdbcUtil.LAZY_INTER_QUERY);    	
    	Worker w2 = new Worker(JdbcUtil.TEST_QUERY);
			
    	w1.start();
    	w2.start();
    	w1.join();
    	w2.join();
    	if(w1.endTime == 0)
    		fail("Query w1 failed!");    	
    	if(w2.endTime == 0)
    		fail("Query w2 failed!");
    	if(w1.endTime < w2.endTime)
    		fail("Interquery processing failed!");
    }    
    
    public void testSchedullerManyQueries() throws Exception {
    	Worker w1 = new Worker(JdbcUtil.LAZY_INTER_QUERY);
    	int n = 7;
    	Worker[] w2 = new Worker[n];
    	for(int i = 0; i < n; i++)
    		w2[i] = new Worker(JdbcUtil.TEST_QUERY);

    	w1.start();
    	for(int i = 0; i < n; i++)
    		w2[i].start();
    	
    	w1.join();
    	for(int i = 0; i < n; i++)
    		w2[i].join();
    	
    	if(w1.endTime == 0)
    		fail("Query w1 failed!");
    	
    	for(int i = 0; i < n; i++) {
	    	if(w2[i].endTime == 0)
	    		fail("Query w2 failed!");
    	}
    	
    	for(int i = 0; i < n; i++) {
    		if(w1.endTime < w2[i].endTime)
        		fail("Interquery processing failed!");
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
				ResultSet rs = con.createStatement().executeQuery(sql);
				assertNotNull(rs);
				rs.next();
				assertNotNull(rs.getString(1));					
				endTime = System.currentTimeMillis();
			} catch (Exception e) {
				System.err.println("Query error: "+sql);				
				e.printStackTrace();
			}
		}
	}
	
}
