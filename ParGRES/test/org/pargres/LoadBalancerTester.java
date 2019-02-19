package org.pargres;

import junit.framework.TestCase;

import org.pargres.cqp.loadbalancer.LprfLoadBalancer;

public class LoadBalancerTester extends TestCase {
	public void testLpfr() {
		LprfLoadBalancer lb = new LprfLoadBalancer(4);
		assertEquals(lb.next(),0);
		
		lb.notifyStartInterQuery(0);
		//1,0,0,0		
		assertEquals(lb.next(),1);		
		
		lb.notifyFinishInterQuery(0);
		//0,0,0,0
		assertEquals(lb.next(),0);		
		
		lb.notifyStartIntraQuery(1);
		//0,3,0,0
		assertEquals(lb.next(),0);
		
		lb.notifyStartIntraQuery(0);
		//3,3,0,0
		assertEquals(lb.next(),2);
		
		lb.notifyStartInterQuery(2);
		//3,3,1,0
		assertEquals(lb.next(),3);
		
		lb.notifyStartIntraQuery(3);
		//3,3,1,3
		assertEquals(lb.next(),2);
		
		lb.notifyFinishIntraQuery(1);
		//3,0,1,3
		assertEquals(lb.next(),1);		
		
		lb.notifyFinishInterQuery(2);
		//3,0,0,3
		assertEquals(lb.next(),1);	
		
		lb.notifyFinishIntraQuery(3);
		//3,0,0,0
		assertEquals(lb.next(),1);				
		
		lb.notifyFinishIntraQuery(0);
		//0,0,0,0
		assertEquals(lb.next(),0);		
	}
}
