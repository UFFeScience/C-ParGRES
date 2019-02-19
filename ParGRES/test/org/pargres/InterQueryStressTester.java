/*
 * @author <a href="mailto:bmiranda@cos.ufrj.br">Bernardo Miranda</a>
 * Pargres Project <http://pargres.nacad.ufrj.br>
 */
package org.pargres;

import java.sql.Connection;
import java.sql.DriverManager;
import java.util.ArrayList;

import org.pargres.util.HsqlDatabase;
import org.pargres.util.PargresClusterProcessor;
import org.pargres.util.PargresNodeProcessor;

import junit.framework.TestCase;

public class InterQueryStressTester extends TestCase {
	
    HsqlDatabase hsqlDatabase1 = new HsqlDatabase(9001);
    HsqlDatabase hsqlDatabase2 = new HsqlDatabase(9002);	    
    PargresNodeProcessor nqp1 = new PargresNodeProcessor(3001,9001);          
    PargresNodeProcessor nqp2 = new PargresNodeProcessor(3002,9002);
    PargresClusterProcessor cqp = new PargresClusterProcessor(8050,"./config/PargresConfig2NodesLocal.xml");
	
	static int N = 100;	
	public void testStress() throws Exception {
		ArrayList<Worker> list = new ArrayList<Worker>();
		
		for(int i = 0; i < N; i++)
			list.add(new Worker("SELECT COUNT(*) FROM REGION"));

		for(int i = 0; i < N; i++)
			list.get(i).start();
		
		for(int i = 0; i < N; i++)
			list.get(i).join();
		
		System.out.println("FIM!");
		
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
		        System.out.println("Enviando consulta...");
		        for(int i = 0; i < 2; i++) {
		        	boolean e = con.createStatement().execute(sql);
		        	assertTrue(e);
		        }
				endTime = System.currentTimeMillis();
			} catch (Exception e) {
				e.printStackTrace();
				System.out.flush();
				System.exit(1);
			}
		}
	}
		
}
