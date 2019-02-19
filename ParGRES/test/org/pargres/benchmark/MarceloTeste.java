package org.pargres.benchmark;
import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.util.ArrayList;

import org.pargres.commons.Range;
import org.pargres.commons.util.ParserException;
import org.pargres.jdbc.PargresDatabaseMetaData;
import org.pargres.parser.Q;
import org.pargres.util.HsqlDatabase;
import org.pargres.util.PargresNodeProcessor;
import org.pargres.util.PargresClusterProcessor;


public class MarceloTeste {		

	static HsqlDatabase hsqlDatabase1 = new HsqlDatabase(9001);
    static HsqlDatabase hsqlDatabase2 = new HsqlDatabase(9002);	    
    static PargresNodeProcessor nqp1 = new PargresNodeProcessor(3001,9001);          
    static PargresNodeProcessor nqp2 = new PargresNodeProcessor(3002,9002);
    static PargresClusterProcessor cqp = new PargresClusterProcessor(8050,"./config/PargresConfig2NodesLocal.xml");
	
		
	public static void main (String[] args) throws Exception {		
		//ResultSet rs = null;
		Range range = new Range("a1","T",0,0,0);
		ArrayList<Range> rangeTest = new ArrayList<Range>(0);
		rangeTest.add(range);
		String file = ".\\test\\org\\pargres\\parser\\q1.sql";
		
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
       
		 hsqlDatabase1.start();        
		 hsqlDatabase2.start();
		 nqp1.start();	    
		 nqp2.start();
		 cqp.start();
		Class.forName("org.pargres.jdbc.Driver");		
        Connection con = DriverManager.getConnection("jdbc:pargres://localhost","user","");
		PargresDatabaseMetaData meta = (PargresDatabaseMetaData) con.getMetaData();		
		
		//Q q = null;
		try {
			new Q(query,rangeTest,meta);
		} catch (ParserException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
			return;
		}
		/*ArrayList<String> partitionableTable;
		partitionableTable = q.getPartitionableTables();
		try {
			q.setVpQuery("T");
		} catch (ParserException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		try {
			String queryVp = q.getVpQuery();
		} catch (ParserException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}*/
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
	
        //org.pargres.cqp.connection.ConnectionManagerImpl.register();
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
		//org.pargres.cqp.connection.ConnectionManagerImpl.unregister();
    }	
	
}
	
	


