/*
 * @author <a href="mailto:bmiranda@cos.ufrj.br">Bernardo Miranda</a>
 * Pargres Project <http://pargres.nacad.ufrj.br>
 */
package org.pargres;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.util.ArrayList;

import junit.framework.TestCase;

import org.pargres.util.HsqlDatabase;
import org.pargres.util.MemoryLeakDetector;
import org.pargres.util.PargresClusterProcessor;
import org.pargres.util.PargresNodeProcessor;

public class StressTester extends TestCase {
	
    HsqlDatabase hsqlDatabase1 = new HsqlDatabase(9001);
    HsqlDatabase hsqlDatabase2 = new HsqlDatabase(9002);	    
    PargresNodeProcessor nqp1 = new PargresNodeProcessor(3001,9001);          
    PargresNodeProcessor nqp2 = new PargresNodeProcessor(3002,9002);
    PargresClusterProcessor cqp = new PargresClusterProcessor(8050,"./config/PargresConfig2NodesLocal.xml");
	MemoryLeakDetector memoryLeakDetector = new MemoryLeakDetector();
	static final int MAX = 500;
	
	public void testStressInter() throws Exception {
		ArrayList<StressTester.Worker> list = new ArrayList<StressTester.Worker>();
		for(int i = 0; i < 1; i++) 
			list.add(new Worker("SELECT * FROM NATION"));
		Object o;
		
		memoryLeakDetector.begin();

		for(int i = 0; i < list.size(); i++) 
			list.get(i).start();		
		for(int i = 0; i < list.size(); i++) 
			list.get(i).join();

		o = new Object();
		memoryLeakDetector.end();
		assertNotNull(o);
		
	}
	/*
	public void testStressIntra() throws Exception {
		ArrayList<StressTester.Worker> list = new ArrayList<StressTester.Worker>();
		for(int i = 0; i < 1; i++) 
			list.add(new Worker("SELECT SUM(L_QUANTITY) FROM LINEITEM"));
		
		memoryLeakDetector.begin();
		for(int i = 0; i < list.size(); i++) 
			list.get(i).start();		
		for(int i = 0; i < list.size(); i++) 
			list.get(i).join();
		memoryLeakDetector.end();
	}*/
	
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

	class Worker extends Thread {
		private String sql;
		private Connection con;
		
		public Worker(String sql) {
			this.sql = sql;
			
			try {
			    Class.forName("org.pargres.jdbc.Driver");
			   con = DriverManager.getConnection("jdbc:pargres://localhost","user","");				
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
		
		public void run() {
			try {
				
				for(int i = 0; i < MAX; i++) {
					//if(i%100 == 0)			
					System.out.println("EXECUTION #"+i);
			        assertNotNull(con);        		
					ResultSet rs = con.createStatement().executeQuery(sql);
					assertNotNull(rs);
					while(rs.next()) {
						//..
					}
					rs.close();
				}
			} catch (Exception e) {
				System.err.println(e.getMessage());
				e.printStackTrace();
			}
		}
	}

}
