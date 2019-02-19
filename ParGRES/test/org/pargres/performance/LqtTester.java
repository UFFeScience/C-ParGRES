package org.pargres.performance;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.util.ArrayList;

import org.pargres.cqp.queryplanner.QueryInfo;
import org.pargres.cqp.queryplanner.QueryPlanner;
import org.pargres.globalquerytask.GlobalQueryTask;
import org.pargres.globalquerytask.GlobalQueryTaskEngine;
import org.pargres.jdbc.specifics.DatabaseProperties;
import org.pargres.nodequeryprocessor.NodeQueryProcessor;
import org.pargres.nodequeryprocessor.NodeQueryProcessorEngine;
import org.pargres.parser.QueryReader;
import org.pargres.util.Range;

public class LqtTester {
	public static void main(String[] args) throws Exception {

		if (args.length == 0) {
			System.err.println("usage: LqtTester [numberOfNodes]");
			return;
		}
		int total = 24000000;
		int beginRange = 1;
		int endRange = total / Integer.parseInt(args[0]);

		long end1 = 0;

		if (true) {
			Class.forName("org.postgresql.Driver");
			Connection con = DriverManager.getConnection(
					"jdbc:postgresql://localhost/tpch_sf5", "tpch", "");

			String sql = "select sum(l_extendedprice) "
					+ "from lineitem "
					+ "where (l_orderkey BETWEEN ? and ?) and "
					+ " l_tax < 100";

			con.createStatement().executeUpdate("SET ENABLE_SEQSCAN TO OFF");
			long init1 = System.currentTimeMillis();
			int actual = beginRange;
			int step = 10000;
			while (actual < endRange) {
				int next = actual + step;
				int[] arguments = { actual, next };

				String mysql = sql;
				for (int i = 0; i < arguments.length; i++)
					mysql = mysql.replaceFirst("\\?", "" + arguments[i]);

				long initIter = System.currentTimeMillis();
				ResultSet rs = con.createStatement().executeQuery(mysql);
				while (rs.next()) {
					// do nothing
				}
				long endIter = System.currentTimeMillis() - initIter;
				actual = next;
				System.out.println("DB Interaction: [" + actual + "," + next
						+ "] " + endIter + " ms");
			}

			end1 = System.currentTimeMillis() - init1;
			System.out.println("Elapsed time: " + end1 + " ms");
		}

		if(false) {
			NodeQueryProcessorEngine nqp = new NodeQueryProcessorEngine(4001,
					"org.postgresql.Driver",
					"jdbc:postgresql://localhost/tpch_sf5", "tpch", "", false);
			ArrayList<NodeQueryProcessor> nqps = new ArrayList<NodeQueryProcessor>();
			nqps.add(nqp);
	
			String query = QueryReader.getSQL(14);
	
			QueryInfo queryInfo = QueryPlanner.parser(query, nqp
					.getDatabaseMetaData(new DatabaseProperties(), new DatabaseProperties()), 1);
	
			org.pargres.cqp.queryplanner.QueryAvpDetail queryAvpDetail = queryInfo
					.getQueryAvpDetail();
	
			Range range = queryAvpDetail.getRange();
	
			range.setOriginalLastValue(endRange);
			range.setFirstValue(beginRange);
	
			GlobalQueryTaskEngine gqt = new GlobalQueryTaskEngine(nqp, nqps,
					queryAvpDetail.getQuery(), range, queryAvpDetail
							.isGetStatistics(), queryAvpDetail
							.isLocalResultComposition(),
					GlobalQueryTask.QE_STRATEGY_AVP, false, queryAvpDetail
							.getPartitionSizes(), false, queryInfo);
	
			long init2 = System.currentTimeMillis();
			gqt.start();
			long end2 = System.currentTimeMillis() - init2;
			System.out.println("Elapsed time: " + end2 + " ms");
	
			System.out.println("Comparing 1: " + end1 + " ms, 2: " + end2 + " ms");
		}

	}
}
