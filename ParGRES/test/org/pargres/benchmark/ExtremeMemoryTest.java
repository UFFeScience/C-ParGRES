package org.pargres.benchmark;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.util.Random;

import junit.framework.TestCase;

public class ExtremeMemoryTest extends TestCase {
	public void testMemory() throws Exception {
		Class.forName("org.hsqldb.jdbcDriver");
		Connection con = DriverManager.getConnection("jdbc:hsqldb:file:deletethis",
				"sa", "");
		
        //Statement sStatement = con.createStatement();

        /*String  tableType      = "CACHED";
        int     cacheScale     = 1000;
        int     cacheSizeScale = 1000;
        boolean nioMode        = false;
        
        String  logType       = "COMPRESSED";
        */
        //sStatement.execute("SET SCRIPTFORMAT " + logType);
        /*sStatement.execute("SET WRITE_DELAY " + 10);
        //sStatement.execute("SET CHECKPOINT DEFRAG " + 10);
        
        sStatement.execute("SET LOGSIZE " + 6);
        sStatement.execute("SET PROPERTY \"hsqldb.cache_scale\" "
                           + cacheScale);
        sStatement.execute("SET PROPERTY \"hsqldb.cache_size_scale\" "
                           + cacheSizeScale);
        sStatement.execute("SET PROPERTY \"hsqldb.nio_data_file\" "
                           + nioMode);*/        	
		
		long begin = System.currentTimeMillis();
		
		con.createStatement().executeUpdate("CREATE CACHED TABLE TEST (A INTEGER, B INTEGER)");
		Random r = new Random();

		for(int i = 0; i < 10000000; i++) {
			if(i%100000 == 0)
				System.out.println(i+" inseridos");
			con.createStatement().executeUpdate("INSERT INTO TEST VALUES ("+r.nextInt(3000000)+",2)");
		}
		
		long end = System.currentTimeMillis() - begin;
		System.out.println("Elapsed time: "+end+" ms");
		long begin2 = System.currentTimeMillis();
		
		System.out.println("Executando select com Group by");
		ResultSet rs = con.createStatement().executeQuery("select A, count(B) from TEST group by A");
		int count = 0;
		while(rs.next()) {
			count++;
		}
		long end2 = System.currentTimeMillis() - begin2;
		System.out.println("ResultSet created in "+end2+" ms with "+count+" registers");
		con.createStatement().execute("SHUTDOWN");
		con.close();
		
	}
}
