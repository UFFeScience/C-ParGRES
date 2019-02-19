package org.pargres;
import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
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
public class ParserTpchQueriesTester extends TestCase {
	
	HsqlDatabase hsqlDatabase1 = new HsqlDatabase(9001);
    HsqlDatabase hsqlDatabase2 = new HsqlDatabase(9002);	    
    PargresNodeProcessor nqp1 = new PargresNodeProcessor(3001,9001);          
    PargresNodeProcessor nqp2 = new PargresNodeProcessor(3002,9002);
    PargresClusterProcessor cqp = new PargresClusterProcessor(8050,"./config/PargresConfig2NodesLocal.xml");
	
	public void testTpchQuery() throws Exception{
        Class.forName("org.pargres.jdbc.Driver");
        Connection con = DriverManager.getConnection("jdbc:pargres://localhost","user","");
		DatabaseMetaData meta = con.getMetaData();
        assertNotNull(meta);
		ArrayList<Range> rangeList = new ArrayList<Range>();
		Range r = new Range("L_ORDERKEY","LINEITEM",0,3000,3001);
		rangeList.add(r);
		r = new Range("O_ORDERKEY","ORDERS",0,3000,3001);
		rangeList.add(r);
        r = new Range("PS_PARTKEY","PARTSUPP",0,3000,3001);
        rangeList.add(r);
        r = new Range("S_SUPPKEY","SUPPLIER",0,3000,3001);
        rangeList.add(r);
        r = new Range("P_PARTKEY","PART",0,3000,3001);
        rangeList.add(r);
        r = new Range("C_CUSTKEY","CUSTOMER",0,3000,3001);
        rangeList.add(r);		
        
        
		
		String file = ".\\test\\org\\pargres\\parser\\q21.sql";
		
		BufferedReader bufferReader = null;	
		
		try {
			bufferReader = new BufferedReader(new FileReader(file));
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		String query="";
		String temp="";	
		
		try {
			while((temp = bufferReader.readLine())!= null) {		
			query += temp + "\n";
			}
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}	
		
		Q q = new Q(query,rangeList,(PargresDatabaseMetaData)meta);
		q.setVpQuery("orders");
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
