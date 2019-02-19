/*
 * @author <a href="mailto:bmiranda@cos.ufrj.br">Bernardo Miranda</a>
 * Pargres Project <http://pargres.nacad.ufrj.br>
 */
package org.pargres;

import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.DriverManager;
import java.util.ArrayList;

import junit.framework.TestCase;

import org.pargres.commons.Range;
import org.pargres.console.Console;
import org.pargres.jdbc.PargresDatabaseMetaData;
import org.pargres.util.HsqlDatabase;
import org.pargres.util.PargresClusterProcessor;
import org.pargres.util.PargresNodeProcessor;

public class IntraQueryMetaDataTester extends TestCase {
	public void testPartitionedTables() throws Exception {
	    HsqlDatabase hsqlDatabase1 = new HsqlDatabase(9001);
	    HsqlDatabase hsqlDatabase2 = new HsqlDatabase(9002);	    
	    PargresNodeProcessor nqp1 = new PargresNodeProcessor(3001,9001);          
	    PargresNodeProcessor nqp2 = new PargresNodeProcessor(3002,9002);		
		
		hsqlDatabase1.start();
		hsqlDatabase2.start();
		nqp1.start();
		nqp2.start();
		PargresClusterProcessor cqp = new PargresClusterProcessor(8050,"./config/PargresConfig2NodesLocal.xml");
		cqp.start();
		
        Class.forName("org.pargres.jdbc.Driver");
		Connection con = DriverManager.getConnection("jdbc:pargres://localhost","user","");
		
		DatabaseMetaData meta = con.getMetaData();
		ArrayList<String> list = ((PargresDatabaseMetaData)meta).getPartitionableTables();
		assertEquals(list.get(0).toLowerCase(),"lineitem");
		assertEquals(list.get(1).toLowerCase(),"orders");
		
		ArrayList<Range> rangeList = ((PargresDatabaseMetaData)meta).getRangeList();
		
		assertEquals(1,rangeList.get(0).getRangeInit());
		assertEquals(100,rangeList.get(0).getRangeEnd());
		assertEquals(0,rangeList.get(1).getRangeInit());
		assertEquals(0,rangeList.get(1).getRangeEnd());
		
		Console c = new Console("localhost",8050);			
		c.execute("SELECT 'X',COUNT(*) FROM LINEITEM",10);
	
		
		cqp.stop();
		nqp1.stop();
		nqp2.stop();		
		hsqlDatabase1.stop();
		hsqlDatabase2.stop();		
	}
}
