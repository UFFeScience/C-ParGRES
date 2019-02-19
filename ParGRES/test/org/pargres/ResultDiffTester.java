package org.pargres;

import java.sql.SQLException;

import junit.framework.TestCase;

import org.pargres.cqp.querymanager.ResultDiff;

public class ResultDiffTester extends TestCase {

	/*
	 * Test method for 'org.pargres.cqp.querymanager.ResultDiff.add(int, Exception)'
	 */
	public void testAddException() {
		ResultDiff resultDiff = new ResultDiff();
		resultDiff.add(0,-1,new SQLException("Erro 1"));
		resultDiff.add(1,-1,new SQLException("Erro 1"));
		resultDiff.compare();
		assertTrue(resultDiff.hasError());
		assertEquals(resultDiff.getNodesToDrop().size(),0);
		assertNotNull(resultDiff.getException());
		assertEquals(resultDiff.getUpdateCount(),-1);
	}
	
	public void testAddUpdateCount() {
		ResultDiff resultDiff = new ResultDiff();
		resultDiff.add(0,1,null);
		resultDiff.add(1,1,null);
		resultDiff.compare();
		assertFalse(resultDiff.hasError());
		assertEquals(resultDiff.getNodesToDrop().size(),0);
		assertNull(resultDiff.getException());
		assertEquals(resultDiff.getUpdateCount(),1);
	}	
	
	public void testGetNodesToDrop() {
		ResultDiff resultDiff = new ResultDiff();
		resultDiff.add(0,-1,new SQLException("Erro 1"));
		resultDiff.add(1,-1,new SQLException("Erro 2"));
		resultDiff.add(2,-1,new SQLException("Erro 2"));
		resultDiff.compare();
		assertTrue(resultDiff.hasError());
		assertEquals(resultDiff.getNodesToDrop().size(),0);
	}	
	
	public void testGetNodesToDrop2() {
		ResultDiff resultDiff = new ResultDiff();
		resultDiff.add(0,-1,new SQLException("Erro 2"));
		resultDiff.add(1,-1,new SQLException("Erro 2"));
		resultDiff.add(2,1,null);		
		resultDiff.compare();
		assertFalse(resultDiff.hasError());
		assertEquals(resultDiff.getNodesToDrop().size(),2);
		assertEquals(resultDiff.getNodesToDrop().get(0),new Integer(0));
		assertEquals(resultDiff.getNodesToDrop().get(1),new Integer(1));
	}		

	public void testGetNodesToDrop3() {
		ResultDiff resultDiff = new ResultDiff();
		resultDiff.add(0,-1,new SQLException("Erro 2"));
		resultDiff.add(1,1,null);
		resultDiff.add(2,1,null);		
		resultDiff.compare();
		assertFalse(resultDiff.hasError());
		assertEquals(resultDiff.getNodesToDrop().size(),1);
		assertEquals(resultDiff.getNodesToDrop().get(0),new Integer(0));
	}		
}
