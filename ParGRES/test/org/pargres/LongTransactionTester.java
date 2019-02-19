/*
 * @author <a href="mailto:bmiranda@cos.ufrj.br">Bernardo Miranda</a>
 * Pargres Project <http://pargres.nacad.ufrj.br>
 */
package org.pargres;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

import junit.framework.TestCase;

import org.pargres.cqp.querymanager.SelectQueryManager;
import org.pargres.cqp.scheduller.LongTransactionQueue;
import org.pargres.jdbc.PargresDatabaseMetaData;
import org.pargres.jdbc.specifics.DatabaseProperties;
import org.pargres.util.HsqlDatabase;
import org.pargres.util.PargresClusterProcessor;
import org.pargres.util.PargresNodeProcessor;

public class LongTransactionTester extends TestCase {
    HsqlDatabase hsqlDatabase1 = new HsqlDatabase(9001);
    HsqlDatabase hsqlDatabase2 = new HsqlDatabase(9002);	    
    PargresNodeProcessor nqp1 = new PargresNodeProcessor(3001,9001);          
    PargresNodeProcessor nqp2 = new PargresNodeProcessor(3002,9002);
    PargresClusterProcessor cqp = new PargresClusterProcessor(8050,"./config/PargresConfig2NodesLocal.xml");
	
	public void testSimple() throws Exception {
		final LongTransactionQueue longTransactionQueue = new LongTransactionQueue();
				
		Thread t = new Thread(new Runnable() {
			public void run() { 
				try {
					Connection con = DriverManager.getConnection("jdbc:hsqldb:mem:testdb9001");
					//ClusterQueryProcessorEngine cqp = new ClusterQueryProcessorEngine(8050,"./config/ConfigurationFile2NodesLocal.txt");
					longTransactionQueue.wait(new SelectQueryManager("SELECT * FROM REGION",new PargresDatabaseMetaData(new DatabaseProperties(),new DatabaseProperties(), con.getMetaData()),1,null,null));
				} catch (Exception e) {
					e.printStackTrace();					
				}
			}
		});
		
		assertFalse(longTransactionQueue.isBlocked(t));
		
		longTransactionQueue.block();
		
		assertTrue(longTransactionQueue.isBlocked(t));
		
		t.start();					
		Thread.sleep(100);		
		
		assertTrue(longTransactionQueue.isBlocked(t));
		
		longTransactionQueue.unblock();		
		
		assertFalse(longTransactionQueue.isBlocked(t));
		
		t.join();
	}
	
	public void testCommit() throws Exception {
        Class.forName("org.pargres.jdbc.Driver");
        Connection firstCon = DriverManager.getConnection("jdbc:pargres://localhost","user","");		
		firstCon.createStatement().executeUpdate("CREATE TABLE TEST (ID INTEGER)");
		firstCon.setAutoCommit(false);
						
		firstCon.commit();
	}	
	
	public void testLongTransaction() throws Exception {
        Class.forName("org.pargres.jdbc.Driver");
        Connection firstCon = DriverManager.getConnection("jdbc:pargres://localhost","user","");		
		firstCon.createStatement().executeUpdate("CREATE TABLE TEST (ID INTEGER)");
		firstCon.setAutoCommit(false);
						
		Worker w = new Worker("SELECT 'SECOND' FROM TEST");		
		w.start();			
		if(w.end)
			fail("Transaction serialization is not working!");
		
		firstCon.commit();
		w.join();
		
		if(!w.end)
			fail("Transaction serialization STILL is not working!");		
	}
		
    protected void setUp() throws Exception {
	    hsqlDatabase1.start();        
	    hsqlDatabase2.start();
	    nqp1.start();	    
	    nqp2.start();
	    cqp.start();
	}

    protected void tearDown() throws Exception {
	    cqp.stop();
	    nqp1.stop();	    
	    nqp2.stop();
	    hsqlDatabase1.stop();        
	    hsqlDatabase2.stop();		
	}
	
	class Worker extends Thread {
		private Connection secondCon;
		private boolean end = false;
		private String sql;
		
		public Worker(String sql) {
			try {
				this.sql = sql;
				secondCon = DriverManager.getConnection("jdbc:pargres://localhost","user","");			
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
		public void run() {
			try {
				secondCon.createStatement().executeQuery(sql);
				end = true;
				System.out.println("RUN!");
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
	
	}	
    	
}
