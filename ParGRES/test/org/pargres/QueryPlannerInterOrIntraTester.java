package org.pargres;

import java.sql.Connection;
import java.sql.DriverManager;
import java.util.ArrayList;

import junit.framework.TestCase;

import org.pargres.commons.Range;
import org.pargres.commons.logger.Logger;
import org.pargres.cqp.queryplanner.QueryInfo;
import org.pargres.cqp.queryplanner.QueryPlanner;
import org.pargres.jdbc.PargresDatabaseMetaData;
import org.pargres.util.HsqlDatabase;
import org.pargres.util.PargresNodeProcessor;
import org.pargres.util.PargresClusterProcessor;

/**
 * @author Marcelo
 */
public class QueryPlannerInterOrIntraTester extends TestCase {	
	    HsqlDatabase hsqlDatabase1 = new HsqlDatabase(9001);
	    HsqlDatabase hsqlDatabase2 = new HsqlDatabase(9002);
	    PargresNodeProcessor nqp1 = new PargresNodeProcessor(3001, 9001);
	    PargresNodeProcessor nqp2 = new PargresNodeProcessor(3002, 9002);
	    PargresClusterProcessor cqp = new PargresClusterProcessor(8050,
	            "./config/PargresConfig2NodesLocal.xml");

	    private static Logger logger = Logger.getLogger(UpdateTester.class); 

	    public void testParser() throws Exception {
	        Class.forName("org.pargres.jdbc.Driver");
	        Connection con = DriverManager.getConnection("jdbc:pargres://localhost", "user", "");
			
	        String sql = "SELECT 'X',SUM(L_QUANTITY) FROM LINEITEM where 1 = (select 1 from lineitem) ";			
			ArrayList<Range> rangeList = new ArrayList<Range>();
	        rangeList.add(new Range("L_ORDERKEY", "LINEITEM", 0, 30000000, 30000001));
	        QueryInfo qi = QueryPlanner.parser(sql, (PargresDatabaseMetaData) con.getMetaData(), 2);	        
	        assertEquals(qi.getQueryType(), QueryInfo.INTER_QUERY);	       
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
	        logger.info("setUp done!");
	        // org.pargres.cqp.connection.ConnectionManagerImpl.register();
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
	        // org.pargres.cqp.connection.ConnectionManagerImpl.unregister();
	    }
}
