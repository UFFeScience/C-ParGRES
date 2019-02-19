/*
 * Created on 08/04/2005
 */
package org.pargres;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;

import junit.framework.TestCase;

import org.pargres.commons.logger.Logger;
import org.pargres.console.ResultSetPrinter;
import org.pargres.util.HsqlDatabase;
import org.pargres.util.PargresClusterProcessor;
import org.pargres.util.PargresNodeProcessor;

/**
 * @author Bernardo
 */
public class SimpleQueryTester extends TestCase {
    HsqlDatabase hsqlDatabase1 = new HsqlDatabase(9001);
    HsqlDatabase hsqlDatabase2 = new HsqlDatabase(9002);
    HsqlDatabase hsqlDatabase3 = new HsqlDatabase(9003);
    HsqlDatabase hsqlDatabase4 = new HsqlDatabase(9004);
    HsqlDatabase hsqlDatabase5 = new HsqlDatabase(9005);
    HsqlDatabase hsqlDatabase6 = new HsqlDatabase(9006);
   
    PargresNodeProcessor nqp1 = new PargresNodeProcessor(3001, 9001);
    PargresNodeProcessor nqp2 = new PargresNodeProcessor(3002, 9002);
    PargresNodeProcessor nqp3 = new PargresNodeProcessor(3003, 9003);
    PargresNodeProcessor nqp4 = new PargresNodeProcessor(3004, 9004);
    PargresNodeProcessor nqp5 = new PargresNodeProcessor(3005, 9005);
    PargresNodeProcessor nqp6 = new PargresNodeProcessor(3006, 9006);
    PargresClusterProcessor cqp = new PargresClusterProcessor(8050,
            "./config/PargresConfig2NodesLocal.xml");

    private static Logger logger = Logger.getLogger(SimpleQueryTester.class);

    public void testSimpleQuery() throws Exception {
        Class.forName("org.pargres.jdbc.Driver");
        Connection con = DriverManager.getConnection(
                "jdbc:pargres://localhost", "user", "");
        assertNotNull(con);
        ResultSet rs = con
        .createStatement()
        .executeQuery("SELECT 1");
        //ResultSet rs = con
          //      .createStatement()
            //    .executeQuery(
              //          "SELECT l_quantity, l_shipdate, SUM(l_discount) FROM lineitem group by l_quantity, l_shipdate");
        assertNotNull(rs);
        ResultSetPrinter.print(rs, 1000);
    }

    /*
     * @see TestCase#setUp()
     */
    protected void setUp() throws Exception {
        hsqlDatabase1.start();
        hsqlDatabase2.start();
        hsqlDatabase3.start();
        hsqlDatabase4.start();
        hsqlDatabase5.start();
        hsqlDatabase6.start();
   
        nqp1.start();
        nqp2.start();
        nqp3.start();
        nqp4.start();
        nqp5.start();
        nqp6.start();
        cqp.start();
        logger.info("setUp done!");
    }

    /*
     * @see TestCase#tearDown()
     */
    protected void tearDown() throws Exception {
        cqp.stop();
        nqp1.stop();
        nqp2.stop();
        nqp3.stop();
        nqp4.stop();
        nqp5.stop();
        nqp6.stop();
        hsqlDatabase1.stop();
        hsqlDatabase2.stop();
        hsqlDatabase3.stop();
        hsqlDatabase4.stop();
        hsqlDatabase5.stop();
        hsqlDatabase6.stop();
    }

}
