package org.pargres;

import junit.framework.TestCase;

import org.pargres.util.HsqlDatabase;
import org.pargres.util.PargresNodeProcessor;
import org.pargres.util.PargresClusterProcessor;
import org.pargres.webadmin.WebAdmin;

public class WebAdminTester extends TestCase {
    HsqlDatabase hsqlDatabase1 = new HsqlDatabase(9001);
    HsqlDatabase hsqlDatabase2 = new HsqlDatabase(9002);
    PargresNodeProcessor nqp1 = new PargresNodeProcessor(3001, 9001);
    PargresNodeProcessor nqp2 = new PargresNodeProcessor(3002, 9002);
    PargresClusterProcessor cqp = new PargresClusterProcessor(8050,
            "./config/PargresConfig2NodesLocal.xml");
    
	public void testWebAdmin() throws Exception {
		WebAdmin webAdmin = new WebAdmin();
		assertFalse(webAdmin.isLogged());
		webAdmin.login("localhost","8050","user","");
		assertTrue(webAdmin.isLogged());
		assertNotNull(webAdmin.executeQuery("SELECT * FROM NATION",10));
		assertTrue(webAdmin.isLogged());
		assertNotNull(webAdmin.listNodes());
		System.out.println(webAdmin.listNodes());
		assertTrue(webAdmin.isLogged());
		System.out.println(webAdmin.listVirtualPartitionedTable());
		assertTrue(webAdmin.isLogged());		
	}
	
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
