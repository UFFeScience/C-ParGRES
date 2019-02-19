/*
 * @author <a href="mailto:bmiranda@cos.ufrj.br">Bernardo Miranda</a>
 * Pargres Project <http://pargres.nacad.ufrj.br>
 */
package org.pargres;

import java.sql.Connection;
import java.sql.DriverManager;
import java.util.ArrayList;

import junit.framework.TestCase;

import org.pargres.commons.Range;
import org.pargres.jdbc.PargresDatabaseMetaData;
import org.pargres.jdbc.specifics.DatabaseProperties;
import org.pargres.parser.Q;
import org.pargres.util.HsqlDatabase;

public class QueryParserTester extends TestCase {
	HsqlDatabase hsqldb;
	PargresDatabaseMetaData meta;
	Connection con;
	
	public void testParser() throws Exception {
		
		ArrayList<Range> rangeList = new ArrayList<Range>();
		Range r = new Range("L_ORDERKEY","LINEITEM",0,3000,3001);
		rangeList.add(r);
		String query = "SELECT SUM(L_DISCOUNT) FROM LINEITEM AS V WHERE V.L_PARTKEY = 1;";
		
		Q q = new Q(query,rangeList,meta);
		System.out.println(q.isPartitionable());
		assertTrue(q.isPartitionable());
		assertEquals(q.getPartitionableTables().get(0),"LINEITEM");
		q.setVpQuery("LINEITEM");
		String vpquery = q.getVpQuery();
		System.out.println(vpquery);
		assertEquals("SELECT SUM(L_DISCOUNT)\nFROM LINEITEM as V\nWHERE V.L_ORDERKEY >= ? and V.L_ORDERKEY < ? and (V.L_PARTKEY = 1);",vpquery);
	}
	
	public void testParserWithoutWhereClause() throws Exception {
		ArrayList<Range> rangeList = new ArrayList<Range>();
		Range r = new Range("L_ORDERKEY","LINEITEM",0,3000,3001);
		rangeList.add(r);
		String query = "SELECT COUNT(*) FROM LINEITEM;";		
		
		Q q = new Q(query,rangeList,meta);
		System.out.println(q.isPartitionable());
		assertTrue(q.isPartitionable());
		assertEquals(q.getPartitionableTables().get(0),"LINEITEM");
		q.setVpQuery("LINEITEM");
		String vpquery = q.getVpQuery();
		System.out.println(vpquery);
		assertEquals("SELECT COUNT(*)\nFROM LINEITEM\nwhere LINEITEM.L_ORDERKEY >= ? and LINEITEM.L_ORDERKEY < ?;",vpquery);
	}	
	
	public void testAnother() throws Exception {
		Range range = new Range("L_ORDERKEY","LINEITEM",0,0,1);
		ArrayList<Range> rangeTest = new ArrayList<Range>();
		rangeTest.add(range);
		
		String query = "select sum(V.L_ORDERKEY), L_LINESTATUS as a3, (avg(V.L_ORDERKEY)+ORDERS.O_TOTALPRICE*(2+3)) ,L_QUANTITY-1-5 as calc "+
						"from LINEITEM as V,ORDERS,PARTSUPP "+
						"where L_SHIPDATE = DATE '2005-12-04' " +
						"group by L_LINESTATUS, ORDERS.O_TOTALPRICE, L_QUANTITY, L_LINENUMBER "+
						"having L_LINENUMBER between 10 and 20;";
		
		String query2 = "select sum(V.L_ORDERKEY), L_LINESTATUS, count(V.L_ORDERKEY), ORDERS.O_TOTALPRICE, L_QUANTITY - 1 - 5, L_QUANTITY, L_LINENUMBER\n"+
						"from LINEITEM as V,ORDERS,PARTSUPP\n"+
						"where V.L_ORDERKEY >= ? and V.L_ORDERKEY < ? " +
						"and (L_SHIPDATE = DATE '2005-12-04')\n" +
						"group by L_LINESTATUS,ORDERS.O_TOTALPRICE,L_QUANTITY,L_LINENUMBER;";

		Q q =new Q(query,rangeTest,meta);
		assertEquals(q.getPartitionableTables().get(0),"LINEITEM");		
		
		q.setVpQuery("LINEITEM");
		String vpquery = q.getVpQuery();
		System.out.println(vpquery);		

		assertEquals(query2,vpquery);		
	}

	@Override
	protected void setUp() throws Exception {
		int port = 9001;
		hsqldb = new HsqlDatabase(port);
		hsqldb.start();
		con = DriverManager.getConnection("jdbc:hsqldb:mem:testdb" + port
				+ ";ifexists=true");
		meta = new PargresDatabaseMetaData(new DatabaseProperties(), new DatabaseProperties(), con.getMetaData());
	}

	@Override
	protected void tearDown() throws Exception {
		con.close();		
		hsqldb.stop();
	}
}
