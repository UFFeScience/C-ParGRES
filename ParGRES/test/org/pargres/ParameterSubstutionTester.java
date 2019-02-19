package org.pargres;

import junit.framework.TestCase;

public class ParameterSubstutionTester extends TestCase {
	public void testParameterSubstitution() throws Exception  {
		int[] limit = {1, 2};
		
		String mysql = "1=? 2=? 1=? 2=?";
        while(mysql.indexOf("?") > -1) {
        	mysql = mysql.replaceFirst("\\?",limit[0]+"");
        	mysql = mysql.replaceFirst("\\?",limit[1]+"");
        }
		
		assertEquals(mysql,"1=1 2=2 1=1 2=2");
	}
	
	

}
