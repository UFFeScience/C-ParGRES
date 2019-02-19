package org.pargres;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;

import junit.framework.TestCase;

import org.pargres.commons.util.JdbcUtil;
import org.pargres.jdbc.PargresRowSet;
import org.pargres.util.HsqlDatabase;
import org.pargres.util.PargresClusterProcessor;
import org.pargres.util.PargresNodeProcessor;

public class PargresRowSetTester extends TestCase {
    HsqlDatabase hsqlDatabase1 = new HsqlDatabase(9001);
    HsqlDatabase hsqlDatabase2 = new HsqlDatabase(9002);	    
    PargresNodeProcessor nqp1 = new PargresNodeProcessor(3001,9001);          
    PargresNodeProcessor nqp2 = new PargresNodeProcessor(3002,9002);
    PargresClusterProcessor cqp = new PargresClusterProcessor(8050,"./config/PargresConfig2NodesLocal.xml");	

	public void testPargresRowSet() throws Exception {
		Class.forName("org.hsqldb.jdbcDriver");
		int port = 9001;
		Connection con = DriverManager.getConnection("jdbc:hsqldb:mem:testdb" + port
				+ ";ifexists=true");
		ResultSet rs = con.createStatement().executeQuery("SELECT 'TEST',COUNT(*) FROM REGION");//"select 'X',count(*) from nation");
		PargresRowSet pargresRowSet = new PargresRowSet();
		assertNotNull(pargresRowSet);
		pargresRowSet.populate(rs);
		while(pargresRowSet.next()) {
			assertNotNull(pargresRowSet.getObject(1));
		}
		
		PargresRowSet pargresRowSet2 = pargresRowSet.cloneThis();
		while(pargresRowSet2.next()) {
			assertNotNull(pargresRowSet2.getObject(1));
		}			
	}	
		
	public void testPargresRowSet2() throws Exception {
        Class.forName("org.pargres.jdbc.Driver");
        Connection con = DriverManager.getConnection("jdbc:pargres://localhost","user","");
        assertNotNull(con);        		
		ResultSet rs = con.createStatement().executeQuery("select 'X',COUNT(*) from REGION");
		assertNotNull(rs);
		assertEquals(2,rs.getMetaData().getColumnCount());		
		assertTrue(rs.next());
		assertNotNull(rs.getString(1));					
	}
	
	public void testPargresRowSet3() throws Exception {
    	int n = 7;
    	Worker[] w2 = new Worker[n];
    	for(int i = 0; i < n; i++)
    		w2[i] = new Worker(JdbcUtil.TEST_QUERY);

    	for(int i = 0; i < n; i++)
    		w2[i].start();
    	
    	for(int i = 0; i < n; i++)
    		w2[i].join();

    	for(int i = 0; i < n; i++) {
	    	if(w2[i].endTime == 0)
	    		fail("Query w2 failed!");
    	}
	
	}			
	
	public void testPargresRowSetReadingMetaData() throws Exception {
	    Class.forName("org.pargres.jdbc.Driver");
	    Connection con = DriverManager.getConnection("jdbc:pargres://localhost","user","");
		ResultSet rs = con.getMetaData().getColumns(null,null,"REGION",null);
		
		assertEquals(23,rs.getMetaData().getColumnCount());
		PargresRowSet pargresRowSet = new PargresRowSet();
		
		assertNotNull(pargresRowSet);
		pargresRowSet.populate(rs);
		assertEquals(23,pargresRowSet.getMetaData().getColumnCount());		
		
		while(pargresRowSet.next()) {
			assertEquals("REGION",pargresRowSet.getString("TABLE_NAME"));
			assertNotNull(pargresRowSet.getObject(4));
		}
		
		PargresRowSet pargresRowSet2 = pargresRowSet.cloneThis();
		
		assertEquals(23,pargresRowSet2.getMetaData().getColumnCount());
		while(pargresRowSet2.next()) {
			assertNotNull(pargresRowSet2.getObject(4));
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
