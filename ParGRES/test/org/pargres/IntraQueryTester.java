/*
 * Created on 08/04/2005
 */
package org.pargres;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.util.ArrayList;

import junit.framework.TestCase;

import org.apache.log4j.Logger;
import org.pargres.commons.Range;
import org.pargres.commons.util.JdbcUtil;
import org.pargres.console.ResultSetPrinter;
import org.pargres.cqp.queryplanner.QueryInfo;
import org.pargres.cqp.queryplanner.QueryPlanner;
import org.pargres.jdbc.PargresDatabaseMetaData;
import org.pargres.util.HsqlDatabase;
import org.pargres.util.PargresClusterProcessor;
import org.pargres.util.PargresNodeProcessor;

/**
 * @author Bernardo
 */

public class IntraQueryTester extends TestCase {
    public static int TIME = 400;
    HsqlDatabase hsqlDatabase1 = new HsqlDatabase(9001);
    HsqlDatabase hsqlDatabase2 = new HsqlDatabase(9002);
    PargresNodeProcessor nqp1 = new PargresNodeProcessor(3001, 9001);
    PargresNodeProcessor nqp2 = new PargresNodeProcessor(3002, 9002);
    PargresClusterProcessor cqp = new PargresClusterProcessor(8050,
            "./config/PargresConfig2NodesLocal.xml");

    private static Logger logger = Logger.getLogger(IntraQueryTester.class);

    public void testSimpleQuery() throws Exception {
        Class.forName("org.pargres.jdbc.Driver");
        Connection con = DriverManager.getConnection(
                "jdbc:pargres://localhost", "user", "");
        assertNotNull(con);
        ResultSet rs = con.createStatement().executeQuery("SELECT L_ORDERKEY, L_RETURNFLAG FROM LINEITEM order by L_QUANTITY");
        assertNotNull(rs);
        ResultSetPrinter.print(rs, 10);
    }    

   /* public void testManyAggregationQuery() throws Exception {
        Class.forName("org.pargres.jdbc.Driver");
        Connection con = DriverManager.getConnection(
                "jdbc:pargres://localhost", "user", "");
        assertNotNull(con);
        ResultSet rs = con
                .createStatement()
                .executeQuery(
                        "SELECT L_SHIPMODE,MAX(L_SHIPDATE), MIN(L_SHIPDATE) FROM LINEITEM GROUP BY L_SHIPMODE");
        assertNotNull(rs);
        ResultSetPrinter.print(rs, 10);
    }

    public void testParser() throws Exception {
        Class.forName("org.pargres.jdbc.Driver");
        Connection con = DriverManager.getConnection(
                "jdbc:pargres://localhost", "user", "");

        String sql = "SELECT 'X',SUM(L_QUANTITY) FROM LINEITEM";// WHERE
        // L_SHIPDATE =
        // 2";
        ArrayList<Range> rangeList = new ArrayList<Range>();
        rangeList
                .add(new Range("L_ORDERKEY", "LINEITEM", 0, 30000000, 30000001));
        QueryInfo qi = QueryPlanner.parser(sql, (PargresDatabaseMetaData) con
                .getMetaData(), 2);
        assertNotNull(qi.getQueryAvpDetail());
        assertEquals(qi.getQueryType(), QueryInfo.INTRA_QUERY);
        ResultSet rs = con.createStatement().executeQuery(sql);
        assertNotNull(rs);
        ResultSetPrinter.print(rs, 10);
    }

    public void testConcurrentIntra() throws Exception {
        long init = System.currentTimeMillis();
        Worker w1 = new Worker(JdbcUtil.LAZY_INTRA_QUERY);
        Worker w2 = new Worker("SELECT 'X',COUNT(*) FROM LINEITEM");
        Worker w3 = new Worker("SELECT 'X',COUNT(*) FROM LINEITEM");
        w1.start();
        Thread.sleep(TIME);
        w2.start();
        Thread.sleep(TIME);
        w3.start();
        w1.join();
        w2.join();
        w3.join();
        if (w1.endTime == 0)
            fail("Query w1 failed!");
        if (w2.endTime == 0)
            fail("Query w2 failed!");
        if (w3.endTime == 0)
            fail("Query w2 failed!");
        if ((w1.endTime < w2.endTime) || (w1.endTime < w3.endTime))
            fail("Concurrent processing failed! [w1=" + (w1.endTime - init)
                    + "][w2=" + (w2.endTime - init) + "][w3="
                    + (w3.endTime - init) + "]");
    }

    public void testTwoIntraAndOneUpdate() throws Exception {
        Worker w0 = new Worker(JdbcUtil.LAZY_UPDATE);
        Worker w1 = new Worker(JdbcUtil.LAZY_INTRA_QUERY);
        Worker w2 = new Worker(JdbcUtil.LAZY_INTRA_QUERY);
        w0.start();
        Thread.sleep(TIME);
        w1.start();
        Thread.sleep(TIME);
        w2.start();
        w1.join();
        w2.join();
        if (w0.endTime == 0)
            fail("Query w1 failed!");
        if (w1.endTime == 0)
            fail("Query w1 failed!");
        if (w2.endTime == 0)
            fail("Query w2 failed!");
        if ((w1.endTime < w0.endTime))
            fail("update block failed!");
        if ((w2.endTime < w0.endTime))
            fail("update block failed!");
    }

    public void testManyConcurrentQueriesWithIntra() throws Exception {
        Worker w1 = new Worker(JdbcUtil.LAZY_INTRA_QUERY);
        Worker w2 = new Worker(JdbcUtil.LAZY_UPDATE);
        Worker w3 = new Worker("SELECT 'X',COUNT(*) FROM LINEITEM");
        Worker w4 = new Worker("SELECT 'X',COUNT(*) FROM LINEITEM");
        Worker w5 = new Worker(JdbcUtil.LAZY_INTRA_QUERY);
        Worker w6 = new Worker("SELECT 'X',COUNT(*) FROM LINEITEM");
        w1.start();
        Thread.sleep(TIME);
        w2.start();
        Thread.sleep(TIME);
        w3.start();
        Thread.sleep(TIME);
        w4.start();
        Thread.sleep(TIME);
        w5.start();
        Thread.sleep(TIME);
        w6.start();
        w1.join();
        w2.join();
        w3.join();
        w4.join();
        w5.join();
        w6.join();
        if (w1.endTime == 0)
            fail("Query w1 failed!");
        if (w2.endTime == 0)
            fail("Query w1 failed!");
        if (w3.endTime == 0)
            fail("Query w2 failed!");
        if (w4.endTime == 0)
            fail("Query w2 failed!");
        if (w5.endTime == 0)
            fail("Query w1 failed!");
        if (w6.endTime == 0)
            fail("Query w2 failed!");
        if (w2.endTime < w1.endTime)
            fail("Concurrent update processing failed!");
        if (w3.endTime < w2.endTime)
            fail("Concurrent update processing failed!");
        if (w4.endTime < w2.endTime)
            fail("Concurrent update processing failed!");
        if (w5.endTime < w6.endTime)
            fail("Concurrent intra processing failed!");
    }*/

    
    /**@see TestCase#setUp()*/
     
    protected void setUp() throws Exception {
        hsqlDatabase1.start();
        hsqlDatabase2.start();
        nqp1.start();
        nqp2.start();
        cqp.start();
        logger.info("setUp done!");
        // org.pargres.cqp.connection.ConnectionManagerImpl.register();
    }

    
     /**@see TestCase#tearDown()*/
     
    protected void tearDown() throws Exception {
        cqp.stop();
        nqp1.stop();
        nqp2.stop();
        hsqlDatabase1.stop();
        hsqlDatabase2.stop();
        // org.pargres.cqp.connection.ConnectionManagerImpl.unregister();
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
                Connection con = DriverManager.getConnection(
                        "jdbc:pargres://localhost", "user", "");
                assertNotNull(con);
                boolean e = con.createStatement().execute(sql);
                assertTrue(e);
                endTime = System.currentTimeMillis();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

}