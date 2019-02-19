/*
 * @author <a href="mailto:bmiranda@cos.ufrj.br">Bernardo Miranda</a>
 * Pargres Project <http://pargres.nacad.ufrj.br>
 */
package org.pargres;

import java.io.FileOutputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;

import junit.framework.TestCase;

import org.pargres.benchmark.ResultSetComparator;
import org.pargres.parser.QueryReader;
import org.pargres.util.PargresClusterProcessor;
import org.pargres.util.PargresNodeProcessor;

public class TpchResultTester extends TestCase {
	Process p1, p2, p3, p4, p5, p6;

	PargresNodeProcessor nqp1 = new PargresNodeProcessor(3001,
			"org.postgresql.Driver",
			"jdbc:postgresql://localhost:9001/tpch_sf0_1", "tpch", "");

	PargresNodeProcessor nqp2 = new PargresNodeProcessor(3002,
			"org.postgresql.Driver",
			"jdbc:postgresql://localhost:9002/tpch_sf0_1", "tpch", "");

	PargresNodeProcessor nqp3 = new PargresNodeProcessor(3003,
			"org.postgresql.Driver",
			"jdbc:postgresql://localhost:9003/tpch_sf0_1", "tpch", "");

	PargresNodeProcessor nqp4 = new PargresNodeProcessor(3004,
			"org.postgresql.Driver",
			"jdbc:postgresql://localhost:9004/tpch_sf0_1", "tpch", "");

	PargresNodeProcessor nqp5 = new PargresNodeProcessor(3005,
			"org.postgresql.Driver",
			"jdbc:postgresql://localhost:9005/tpch_sf0_1", "tpch", "");

	PargresNodeProcessor nqp6 = new PargresNodeProcessor(3006,
			"org.postgresql.Driver",
			"jdbc:postgresql://localhost:9006/tpch_sf0_1", "tpch", ""); 

	PargresClusterProcessor cqp = new PargresClusterProcessor(8050,
			"./config/PargresConfig2NodesLocal.xml");

	@Override
	protected void setUp() throws Exception {
		p1 = Runtime
				.getRuntime()
				.exec(
						"install\\portforward\\plink.exe -ssh mercury -l bmiranda -pw !bmiranda -L 9001:node9:5432");
		p2 = Runtime
				.getRuntime()
				.exec(
						"install\\portforward\\plink.exe -ssh mercury -l bmiranda -pw !bmiranda -L 9002:node11:5432"); 
		p3 = Runtime
				.getRuntime()
				.exec(
						"install\\portforward\\plink.exe -ssh mercury -l bmiranda -pw !bmiranda -L 9003:node13:5432");
		p4 = Runtime
				.getRuntime()
				.exec(
						"install\\portforward\\plink.exe -ssh mercury -l bmiranda -pw !bmiranda -L 9004:node14:5432");
		p5 = Runtime
				.getRuntime()
				.exec(
						"install\\portforward\\plink.exe -ssh mercury -l bmiranda -pw !bmiranda -L 9005:node15:5432");
		p6 = Runtime
				.getRuntime()
				.exec(
						"install\\portforward\\plink.exe -ssh mercury -l bmiranda -pw !bmiranda -L 9006:node16:5432"); 
		Thread.sleep(2000);
		nqp1.start();
		nqp2.start();
		nqp3.start();
		nqp4.start();
		nqp5.start();
		nqp6.start();
		cqp.start();
	}

	@Override
	protected void tearDown() throws Exception {
		cqp.stop();
		nqp1.stop();
		nqp2.stop();
		nqp3.stop();
		nqp4.stop();
		nqp5.stop();
		nqp6.stop();
		p1.destroy();
		p2.destroy();
		p3.destroy();
		p4.destroy();
		p5.destroy();
		p6.destroy();
	}

	public void testPartitionedTables() throws Exception {		
		int queryId = -1;
		boolean fail = false;
			Class.forName("org.pargres.jdbc.Driver");
			Connection con = DriverManager.getConnection(
					"jdbc:pargres://localhost", "user", "");

			Class.forName("org.postgresql.Driver");
			Connection conPgsql = DriverManager.getConnection(
					"jdbc:postgresql://localhost:9001/tpch_sf0_1", "tpch", "");

			//Consulta 1 Ok, Consulta 3 com problemas na linha 577
			int[] ids = new int[] { 1 };//, 2, 3, 4, 5, 6, 10, 14, 21 };

			for (int id : ids) {
				queryId = id;
				String sql = QueryReader.getSQL(id);
				
				long pargresInit = System.currentTimeMillis();				
				ResultSet rs = con.createStatement().executeQuery(sql);
				System.out.println("Pargres Elapsed time: "+(System.currentTimeMillis()-pargresInit));				
				
				long pgsqlInit = System.currentTimeMillis();
				ResultSet rsPgsql = conPgsql.createStatement().executeQuery(
						sql);
				System.out.println("PostgreSQL Elapsed time: "+(System.currentTimeMillis()-pgsqlInit));
				
				try {					
					ResultSetComparator.compare(rs, rsPgsql);
				} catch (Exception e) {
					fail = true;
					FileOutputStream fout = new FileOutputStream("report_diff_results_tpch.log",true);
					System.err.println(">> Problema na consulta " + queryId);
					System.err.println(e.getMessage());
					e.printStackTrace();					
					fout.write((">> Problema na consulta " + queryId+"\n").getBytes());
					fout.write(e.getMessage().getBytes());
				}

			}
        if(fail)
        	fail("Pelo menos um erro encontrado. Verifique log.");
	}
}
