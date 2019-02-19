/*
 * Created on 08/04/2005
 */
package org.pargres;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;

import junit.framework.TestCase;

import org.pargres.benchmark.ResultSetComparator;
import org.pargres.console.Console;
import org.pargres.util.HsqlDatabase;
import org.pargres.util.PargresClusterProcessor;
import org.pargres.util.PargresNodeProcessor;

/**
 * @author Bernardo
 */
public class IntraQueryCorrectnessTester extends TestCase {
    public static int TIME = 400;
    HsqlDatabase hsqlDatabase1 = new HsqlDatabase(9001);
    HsqlDatabase hsqlDatabase2 = new HsqlDatabase(9002);
    PargresNodeProcessor nqp1 = new PargresNodeProcessor(3001, 9001);
    PargresNodeProcessor nqp2 = new PargresNodeProcessor(3002, 9002);
    PargresClusterProcessor cqp = new PargresClusterProcessor(8050,
            "./config/PargresConfig2NodesLocal.xml");

    public void testSimpleQuery() throws Exception {
    	String sql = "select  l_shipdate, sum(l_quantity) as sum_qty, sum(l_extendedprice) as sum_base_price, sum(l_extendedprice * (1 - l_discount)) as sum_disc_price, sum(l_extendedprice * (1 - l_discount) * (1 + l_tax)) as sum_charge, avg(l_quantity) as avg_qty, avg(l_extendedprice) as avg_price, avg(l_discount) as avg_disc, count(*) as count_order from lineitem group by l_shipdate order by l_shipdate;";
        
    	Class.forName("org.hsqldb.jdbcDriver");        
        int port = 9001;
        Connection conHsqldb = DriverManager
		.getConnection("jdbc:hsqldb:mem:testdb" + port
				+ ";ifexists=true");
        assertNotNull(conHsqldb);
        ResultSet rsHsqldb = conHsqldb.createStatement().executeQuery(sql);
        assertNotNull(rsHsqldb);
                
        Class.forName("org.pargres.jdbc.Driver");
        Connection con = DriverManager.getConnection(
                "jdbc:pargres://localhost", "user", "");
        assertNotNull(con);
        ResultSet rs = con.createStatement().executeQuery(sql);
        assertNotNull(rs);
        
        ResultSetComparator.compare(rs,rsHsqldb);
    }
    
    public void testAll() throws Exception {
                
    	Class.forName("org.hsqldb.jdbcDriver");        
        int port = 9001;
        Connection conHsqldb = DriverManager
		.getConnection("jdbc:hsqldb:mem:testdb" + port
				+ ";ifexists=true");
        
        Class.forName("org.pargres.jdbc.Driver");
        Connection con = DriverManager.getConnection(
                "jdbc:pargres://localhost", "user", "");
        assertNotNull(con);
        con.createStatement().executeUpdate("CREATE TABLE TEST(ID INTEGER, VALUE INTEGER)");
        for(int i = 0; i < 100; i++) {
        	if(i%2 == 0)
        		con.createStatement().executeUpdate("INSERT INTO TEST VALUES ("+i+",1)");
        	else
        		con.createStatement().executeUpdate("INSERT INTO TEST VALUES ("+i+",2)");
        }
        
        Console console = new Console("localhost",8050);
        console.addVirtualPartition("test","ID");               
        
        String sql = "SELECT VALUE, COUNT(ID) FROM TEST " +
        		" where 1 in ( select 1 from region ) " +
        		" group by VALUE" +
        		" order by VALUE;";
        
        
        ResultSet rsHsqldb = conHsqldb.createStatement().executeQuery(sql);
        ResultSet rs = con.createStatement().executeQuery(sql);
        
        ResultSetComparator.compare(rsHsqldb,rs);
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
    }

}