package org.pargres;

import java.sql.Connection;
import java.sql.DriverManager;

import junit.framework.TestCase;

import org.pargres.jdbc.PargresDatabaseMetaData;
import org.pargres.jdbc.specifics.DatabaseProperties;
import org.pargres.parser.Q;
import org.pargres.parser.QueryReader;
import org.pargres.util.HsqlDatabase;

public class TpchQueryPlannerTester extends TestCase {
	HsqlDatabase hsqlDatabase1 = new HsqlDatabase(9001);
	PargresDatabaseMetaData meta;
	
	
	public void testTpchPlanner() throws Exception {
		//int[] ids = new int[] {1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,21,22};
		int[] ids = new int[] {1,2,3,4,5,6,10,14,21};
		String ok = ":::: Queries ok: ";
		String failed = ":::: Queries failed \n";
		for(int id : ids) {
			String sql = QueryReader.getSQL(id);			
			try {
				System.out.println("Testing query #"+id);
				assertParser(id,sql);
				ok += id+ ", ";
			} catch (Exception e) {
				failed += ">> "+id+ ": "+discoverError(e)+"\n";
				fail(failed);
			}
		}
		System.out.println(ok);
		System.out.println(failed);
	}
	
	public String discoverError(Exception e) {
		String s = e.getMessage();
		if(s.indexOf("Error: stack underflow") > 0) {
			int posLine = s.indexOf("Line: ")+"Line: ".length();
			int posColumn = s.indexOf("Column: ")+"Column: ".length();;
			int line = Integer.parseInt(s.substring(posLine,posLine+s.substring(posLine).indexOf("\n")).trim());
			int column = Integer.parseInt(s.substring(posColumn,posColumn+s.substring(posColumn).indexOf("\n")).trim());
			
			return "Syntaxe : line="+line+", column="+column;
		} else
			return e.getMessage();
	}
	
	public void assertParser(int id, String sql) throws Exception {
		if(new Q(sql, meta.getRangeList(), meta) == null)
			fail("Query #"+id+" failed!");
	}

	@Override
	protected void setUp() throws Exception {
		hsqlDatabase1.start();
		int port = 9001;
		Connection con = DriverManager
		.getConnection("jdbc:hsqldb:mem:testdb" + port
				+ ";ifexists=true");
		DatabaseProperties databaseProperties = new DatabaseProperties();
		meta = new PargresDatabaseMetaData(databaseProperties, new DatabaseProperties(), con.getMetaData());
	}

	@Override
	protected void tearDown() throws Exception {
		meta = null;
		hsqlDatabase1.stop();
		hsqlDatabase1 = null;
	}
}
