package org.pargres;

import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.DriverManager;
import java.util.ArrayList;

import org.pargres.util.HsqlDatabase;
import org.pargres.util.PargresClusterProcessor;
import org.pargres.util.PargresNodeProcessor;
import org.pargres.jdbc.PargresDatabaseMetaData;
import org.pargres.commons.Range;
import org.pargres.parser.Q;

import junit.framework.TestCase;

public class ParserFindColumnsTester extends TestCase {
	
    HsqlDatabase hsqlDatabase1 = new HsqlDatabase(9001);
    HsqlDatabase hsqlDatabase2 = new HsqlDatabase(9002);	    
    PargresNodeProcessor nqp1 = new PargresNodeProcessor(3001,9001);          
    PargresNodeProcessor nqp2 = new PargresNodeProcessor(3002,9002);
    PargresClusterProcessor cqp = new PargresClusterProcessor(8050,"./config/PargresConfig2NodesLocal.xml");
	
	public void testFindTypeColumns() throws Exception{
        Class.forName("org.pargres.jdbc.Driver");
        Connection con = DriverManager.getConnection("jdbc:pargres://localhost","user","");
		DatabaseMetaData meta = con.getMetaData();
        assertNotNull(meta);
		ArrayList<Range> rangeList = new ArrayList<Range>();
		Range r = new Range("L_ORDERKEY","LINEITEM",0,3000,3001);
		rangeList.add(r);
		r = new Range("O_ORDERKEY","ORDERS",0,3000,3001);
		rangeList.add(r);
		r = new Range("P_PARTKEY","PART",0,3000,3001);
		rangeList.add(r);
		/*String query = "SELECT case  when 2=12 then count(*) when 1>3 then 2 end from lineitem"+
					   ";";*/
		//String query = "Select * from lineitem  where exists(select * from orders  where l_orderkey = o_orderkey having avg(l_orderkey)>98);" ;
		String query = "Select * From Lineitem  Where l_orderkey in ( Select o_orderkey From orders) ;";

		Q q = new Q(query,rangeList,(PargresDatabaseMetaData)meta);
		q.setVpQuery("lineitem");
		q.getAliasTextList();
		System.out.println("LIMIT = " + q.getLimitText());
	}		
    protected void setUp() throws Exception {
	    hsqlDatabase1.start();        
	    hsqlDatabase2.start();
	    nqp1.start();	    
	    nqp2.start();
	    cqp.start();
	}
    protected void tearDown() throws Exception {
	    cqp.stop();
	    nqp1.stop();	    
	    nqp2.stop();
	    hsqlDatabase1.stop();        
	    hsqlDatabase2.stop();		
	}	
}
