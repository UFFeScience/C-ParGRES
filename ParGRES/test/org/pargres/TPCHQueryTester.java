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
import org.pargres.cqp.connection.ConnectionManagerImpl;
import org.pargres.nodequeryprocessor.NodeQueryProcessorEngine;
import org.pargres.parser.QueryReader;

/**
 * @author Bernardo
 */
public class TPCHQueryTester extends TestCase {
    NodeQueryProcessorEngine nqp1;
    NodeQueryProcessorEngine nqp2;
    ConnectionManagerImpl cm;

    public static int TIME = 400;
    private static Logger logger = Logger.getLogger(UpdateTester.class);

 /*   public void testQueryGeneral() throws Exception {
    Class.forName("org.pargres.jdbc.Driver");
    Connection con = DriverManager.getConnection(
            "jdbc:pargres://localhost", "user", "");
    assertNotNull(con);
        String query = "select " +
                    "l_returnflag, " +
                    "l_linestatus, " +
                    "sum(l_quantity) as sum_qty, " +
                    "sum(l_extendedprice) as sum_base_price, " +
                    "sum(l_extendedprice * (1 - l_discount)) as sum_disc_price, " +
                    "sum(l_extendedprice * (1 - l_discount) * (1 + l_tax)) as sum_charge, " +
                    "avg(l_quantity) as avg_qty, " +
                    "avg(l_extendedprice) as avg_price, " +
                    "avg(l_discount) as avg_disc,   " +  
                    "count(*) as count_order " +
                "from " +
                "    lineitem " +
                "where " +
                "    l_shipdate <= date '1998-12-01' - interval '90 day' " +
                "    and l_orderkey < 10 " + 
                "group by " +
                "    l_returnflag, " +
                "    l_linestatus " +
                "order by " +
                "    l_returnflag, " +
                "    l_linestatus;";
        System.out.println("Primeira vez...");
        ResultSet rs = con.createStatement().executeQuery(query);
        System.out.println("Segunda vez...");
        rs = con.createStatement().executeQuery(query);
        System.out.println("Terceira vez...");
        rs = con.createStatement().executeQuery(query);

    assertNotNull(rs);
    ResultSetPrinter.print(rs, 10);
    rs.close();
    con.close();
  }*/
    public void testQuery() throws Exception {
        Class.forName("org.pargres.jdbc.Driver");
        Connection con = DriverManager.getConnection(
                "jdbc:pargres://localhost", "user", "");
        assertNotNull(con);
        ResultSet rs = con
                .createStatement()
                .executeQuery(QueryReader.getSQL(3));
        assertNotNull(rs);
        ResultSetPrinter.print(rs, 10);
        rs.close();
        con.close();
      }
    
    protected void setUp() throws Exception {
        String jdbcDriver = "org.postgresql.Driver";
        String jdbcUrl = "jdbc:postgresql://localhost:9001/tpch_sf0_1";
        String jdbcUser = "tpch";
        String jdbcPwd = "";
        nqp1 = new NodeQueryProcessorEngine(3001, jdbcDriver, jdbcUrl,
                jdbcUser, jdbcPwd, false);

        nqp2 = new NodeQueryProcessorEngine(3002, jdbcDriver, jdbcUrl,
                jdbcUser, jdbcPwd, false);

        cm = new ConnectionManagerImpl(8050,
                "./config/ConfigurationFile2NodesLocal.txt");
        logger.info("setUp done!");
        // org.pargres.cqp.connection.ConnectionManagerImpl.register();
    }

    /*
     * @see TestCase#tearDown()
     */
    protected void tearDown() throws Exception {
        cm.destroy();
        nqp1.shutdown();
        nqp2.shutdown();
        // org.pargres.cqp.connection.ConnectionManagerImpl.unregister();
    }

}