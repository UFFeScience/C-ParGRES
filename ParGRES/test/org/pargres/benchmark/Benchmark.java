package org.pargres.benchmark;

import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;

import org.pargres.console.ResultSetPrinter;
import org.pargres.parser.QueryReader;

public class Benchmark {

	/**
	 * @param args
	 */
	public static void main(String[] args) {
        Benchmark benchmark = new Benchmark();
		benchmark.runUpdateBenchmark();
	}
	
	public void runUpdateBenchmark() {		
        /*1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22*/      
        runIntraQuery("Pargres intra-query","org.pargres.jdbc.Driver","jdbc:pargres://localhost","user","",new int[]{1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22});		
        runIntraQuery("PostgreSQL inter-query","org.postgresql.Driver","jdbc:postgresql://localhost/tpch_sf2_5","tpch","",new int[]{1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22});
		
	    //runInterQuery("PostgreSQL inter-query","org.postgresql.Driver","jdbc:postgresql://localhost/tpch_sf0_1","tpch","");
	//	runInterQuery("Pargres inter-query","org.pargres.jdbc.Driver","jdbc:pargres://localhost","user","");
		
	//	runUpdate("PostgreSQL update","org.postgresql.Driver","jdbc:postgresql://localhost/tpch_sf5","tpch","");
	//	runUpdate("Pargres update","org.pargres.jdbc.Driver","jdbc:pargres://localhost","user","");
	}
	
	public void runIntraQuery(String benchmarkName, String jdbcDriver, String jdbcUrl, String jdbcUser, String jdbcPwd, int[] sqlIds) {
		try {
			int N = 5;
			Class.forName(jdbcDriver);
			java.sql.Connection con = DriverManager.getConnection(jdbcUrl,jdbcUser,jdbcPwd);

			System.out.println(benchmarkName+": Environment created. Running benchmark!");						
			
			for(int i = 0; i < sqlIds.length; i++) {
				
				for(int j = 0; j < N; j++) {
					System.out.println(benchmarkName+" Running Q"+sqlIds[i]);
					String sql = QueryReader.getSQL(sqlIds[i]);				
					long begin = System.currentTimeMillis();
					
					try {
						ResultSet rs = con.createStatement().executeQuery(sql);
						ResultSetPrinter.print(rs,10);
					} catch (SQLException e) {
                        System.err.println("Database error: " + e.getMessage());
					}	
						
					long end = System.currentTimeMillis() - begin;
					System.out.println(benchmarkName+" Elapsed time: "+end+" ("+ (j+1) +"/"+N+")");
				}
			}
			

			con.close();
						
		} catch (Exception e) {
			System.err.println(e.getMessage());
			e.printStackTrace();
		}		
	}	
	
	public void runInterQuery(String benchmarkName, String jdbcDriver, String jdbcUrl, String jdbcUser, String jdbcPwd) {
		try {
			int N = 1000;
			Class.forName(jdbcDriver);
			java.sql.Connection con = DriverManager.getConnection(jdbcUrl,jdbcUser,jdbcPwd);

			System.out.println(benchmarkName+": Environment created. Running benchmark!");			
			long begin = System.currentTimeMillis();

			for(int i = 0; i < N; i++) {
				ResultSet rs = con.createStatement().executeQuery("SELECT COUNT(*) FROM REGION");
				while(rs.next()) {
					// DO NOTHING
				}
			}
			long end = System.currentTimeMillis() - begin;

			con.close();
			System.out.println(benchmarkName+" Elapsed time: "+end+" ("+N+" interactions)");			
		} catch (Exception e) {
			System.err.println(e.getMessage());
			e.printStackTrace();
		}		
	}
	
		
	public void runUpdate(String benchmarkName, String jdbcDriver, String jdbcUrl, String jdbcUser, String jdbcPwd) {
		try {
			int N = 1000;
			Class.forName(jdbcDriver);
			java.sql.Connection con = DriverManager.getConnection(jdbcUrl,jdbcUser,jdbcPwd);
			try {
				con.createStatement().executeUpdate("DROP TABLE TEST");
			} catch (SQLException e) {	}
			con.createStatement().executeUpdate("CREATE TABLE TEST (ID INTEGER)");				
			System.out.println(benchmarkName+": Environment created. Running benchmark!");			
			long begin = System.currentTimeMillis();
			//PreparedStatement pst = con.prepareStatement("INSERT INTO TEST VALUES (?)");
			for(int i = 0; i < N; i++) {
				//pst.setInt(1,i);
				//pst.execute();
				con.createStatement().executeUpdate("INSERT INTO TEST VALUES ("+i+")");
			}
			long end = System.currentTimeMillis() - begin;
			con.createStatement().executeUpdate("DROP TABLE TEST");
			con.close();
			System.out.println(benchmarkName+" Elapsed time: "+end+" ("+N+" interactions)");			
		} catch (Exception e) {
			System.err.println(e.getMessage());
			e.printStackTrace();
		}
		
	}

}
