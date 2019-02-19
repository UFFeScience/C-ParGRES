package org.pargres;

import java.sql.Connection;
import java.sql.DriverManager;

import junit.framework.TestCase;

import org.pargres.console.Console;
import org.pargres.cqp.connection.ServerConnectionImpl;
import org.pargres.util.HsqlDatabase;
import org.pargres.util.PargresClusterProcessor;
import org.pargres.util.PargresNodeProcessor;


public class ConsoleTester extends TestCase {
    HsqlDatabase hsqlDatabase1 = new HsqlDatabase(9001);
    HsqlDatabase hsqlDatabase2 = new HsqlDatabase(9002);	    
    PargresNodeProcessor nqp1 = new PargresNodeProcessor(3001,9001);          
    PargresNodeProcessor nqp2 = new PargresNodeProcessor(3002,9002);
    PargresClusterProcessor cqp = new PargresClusterProcessor(8050,"./config/PargresConfig2NodesLocal.xml");	

	/*public void testIntra() throws Exception {
		Console c = new Console("localhost",8050,"SELECT SUM(L_QUANTITY) FROM LINEITEM",10);			
		c.execute();
	}*/
	
	public void testInter() throws Exception {
		Console c = new Console("localhost",8050);			
		c.execute("select 'X',count(*) from nation",10);
	}	
	
	public void testCommandLineCompleteParams() throws Exception {
		String[] command = new String[6];
		command[0] = "-h";
		command[1] = "localhost";
		command[2] = "-p";
		command[3] = "8050";
		command[4] = "-e";
		command[5] = "SELECT 'X',SUM(L_QUANTITY) FROM LINEITEM";
		assertTrue(Console.commander(command));
	}
	
	public void testConsoleError() throws Exception {
		//[usage] java org.pargres.jdbc.Console -h host -p port -n numberOfThreads -r numberOfResultLines -q sql -f fileName"
		String sql = "SELECT 'X',SUM(L_QUANTITY) FROM LINEITEM";
		boolean fail = false;
		try {
			Console console = new Console("localhost",8051);
			console.execute(sql,10);
		} catch (Exception e) {
			fail = true;
		}
		if(!fail)
			fail("Console is not working ok!");
		
		fail = false;
		try {
			Console console = new Console("mymachine",8050);
			console.execute(sql,10);
		} catch (Exception e) {
			fail = true;
		}
		if(!fail)
			fail("Console is not working ok!");		
	}
	
	public void testAddNode() throws Exception {
		//[usage] java org.pargres.jdbc.Console -h host -p port -n numberOfThreads -r numberOfResultLines -q sql -f fileName"
		String sql = "SELECT 'X',SUM(L_QUANTITY) FROM LINEITEM";
		boolean fail = false;
		try {
			Console console = new Console("localhost",8051);
			console.execute(sql,10);
		} catch (Exception e) {
			fail = true;
		}
		if(!fail)
			fail("Console is not working ok!");
		
		fail = false;
		try {
			Console console = new Console("mymachine",8050);
			console.execute(sql,10);
		} catch (Exception e) {
			fail = true;
		}
		if(!fail)
			fail("Console is not working ok!");		
	}		
	
	public void testCommandLineMinimalParams() throws Exception {		
		assertTrue(Console.commander(new String[]{"-e","SELECT 'X',SUM(L_QUANTITY) FROM LINEITEM"}));		
	}		
		
	public void testCommandLineWithSqlFile() throws Exception {
		//[usage] java org.pargres.jdbc.Console -h host -p port -n numberOfThreads -r numberOfResultLines -q sql -f fileName"
		String[] command = new String[2];
		command[0] = "-execfile";
		command[1] = "./install/queries/q0.sql";

		assertTrue(Console.commander(new String[]{command[0],command[1]}));		
	}		
	
	public void testManageNodes() throws Exception {
		String sql = "SELECT 'X',SUM(L_QUANTITY) FROM LINEITEM";
		Console console = new Console("localhost",8050);
		console.execute(sql,10);
		
		HsqlDatabase hsqlDatabase3 = new HsqlDatabase(9003);
		PargresNodeProcessor nqp3 = new PargresNodeProcessor(3003,9003);
		hsqlDatabase3.start();
		nqp3.start();
		console.addNode("localhost",3003);
		console.execute(sql,10);
		
		console.listNodes();
		
		console.dropNode(2);
		nqp3.stop();		
		hsqlDatabase3.stop();	
		console.execute(sql,10);		
		
		console.dropNode(1);
		console.execute(sql,10);		
	}		
	
	public void testCommandLine() throws Exception {
		HsqlDatabase hsqlDatabase3 = new HsqlDatabase(9003);
		PargresNodeProcessor nqp3 = new PargresNodeProcessor(3003,9003);
		hsqlDatabase3.start();
		nqp3.start();
		
		assertTrue(Console.commander("-v".split(" ")));
		assertTrue(Console.commander("-listnodes".split(" ")));
		assertTrue(Console.commander(new String[]{"-e","SELECT * FROM REGION"}));
		assertTrue(Console.commander(new String[]{"-execfile","./test/org/pargres/parser/q0.sql"}));
		assertTrue(Console.commander(new String[]{"-addnode","localhost:3003"}));
		assertTrue(Console.commander(new String[]{"-dropnode","2"}));
		assertTrue(Console.commander(new String[]{"-help"}));		
		assertTrue(Console.commander(new String[]{"-h","localhost","-e","SELECT 'X',COUNT(*) FROM LINEITEM WHERE L_ORDERKEY < 10000"}));
		assertTrue(Console.commander(new String[]{"-addvp","region:r_regionkey"}));
		assertTrue(Console.commander(new String[]{"-dropvp","region"}));		
		
		nqp3.stop();		
		hsqlDatabase3.stop();			
	}
	
	public void testManageVPs() throws Exception {
		String host = "localhost";
		int port = 8050;
		Class.forName("org.pargres.jdbc.Driver");
		Connection con = DriverManager.getConnection("jdbc:pargres://"+host+":"+port,"user","");
		con.createStatement().executeUpdate(ServerConnectionImpl.DROP_VP+" lineitem");
		con.createStatement().executeUpdate(ServerConnectionImpl.DROP_VP+" orders");		
		assertFalse(con.createStatement().executeQuery(ServerConnectionImpl.GET_VP_LIST).next());
		
		con.createStatement().executeUpdate(ServerConnectionImpl.ADD_VP+" region R_REGIONKEY");

		String sql = "SELECT 'X',COUNT(*) FROM REGION";
		Console console = new Console("localhost",8050);
		console.execute(sql,10);
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
        //org.pargres.cqp.connection.ConnectionManagerImpl.register();
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
		//org.pargres.cqp.connection.ConnectionManagerImpl.unregister();
    }	

}
