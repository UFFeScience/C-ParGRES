package org.pargres.profile;

import org.pargres.util.HsqlDatabase;
import org.pargres.util.PargresNodeProcessor;

public class ProfileTester {
	public static void main(String[] args) throws Exception {
	    HsqlDatabase hsqlDatabase1 = new HsqlDatabase(9001);
	    HsqlDatabase hsqlDatabase2 = new HsqlDatabase(9002);	    
	    PargresNodeProcessor nqp1 = new PargresNodeProcessor(3001,9001);          
	    PargresNodeProcessor nqp2 = new PargresNodeProcessor(3002,9002);
	    hsqlDatabase1.start();        
	    hsqlDatabase2.start();
	    nqp1.start();	    
	    nqp2.start();
	    nqp1 = null;
	    nqp1.stop();	    
	    nqp2.stop();
	    nqp2 = null;
	    
	    hsqlDatabase1.stop();
	    hsqlDatabase1 = null;
	    hsqlDatabase2.stop();
	    hsqlDatabase2 = null;
	    System.gc();
	}
	
	static class MyTest {
		
	}
}
