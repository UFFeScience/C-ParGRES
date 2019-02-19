/*
 */
package org.pargres;

import junit.framework.Test;
import junit.framework.TestSuite;

/**
 * @author bmiranda
 *
 */
public class AllTests {

	public static Test suite() {
		TestSuite suite = new TestSuite("Test for org.pargres");
		//$JUnit-BEGIN$
		suite.addTestSuite(AuthenticationTester.class);
		suite.addTestSuite(QueryParserTester.class);
		suite.addTestSuite(ParserFindColumnsTester.class);		
		suite.addTestSuite(LoadBalancerTester.class);
		suite.addTestSuite(PargresRowSetTester.class);
		suite.addTestSuite(DatabaseMetaDataTester.class);				
		suite.addTestSuite(InterQueryTester.class);		
		suite.addTestSuite(IntraQueryMetaDataTester.class);
		suite.addTestSuite(UpdateTester.class);		
		suite.addTestSuite(IntraQueryTester.class);		
		suite.addTestSuite(ConsoleTester.class);		
		suite.addTestSuite(LongTransactionTester.class);
		suite.addTestSuite(HighAvaibilityTester.class);
		suite.addTestSuite(ResultDiffTester.class);
		suite.addTestSuite(IntraQueryCorrectnessTester.class);
		suite.addTestSuite(TpchQueryPlannerTester.class);
		suite.addTestSuite(WebAdminTester.class);
		//$JUnit-END$
		return suite;
	}
}
