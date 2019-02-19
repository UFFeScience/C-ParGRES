package org.pargres.benchmark;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import org.pargres.util.PargresStringUtils;


/**
 * 
 */

/**
 * @author kinder
 * 
 */
public class Hypersonic {

	/**
	 * @param args
	 * @throws SQLException
	 * @throws ClassNotFoundException
	 */
	public static void main(String[] args) throws SQLException,
			ClassNotFoundException {

		if (args.length != 3) {
			System.out.println("Argumento Errado");
			System.exit(0);
		}
		
		Hypersonic hypersonic = new Hypersonic();
		hypersonic.run(Integer.parseInt(args[0]), args[1],args[2]);
	}
		
	public void run(int numberOfGroups, String executionMode,String idx) throws SQLException, ClassNotFoundException {
		
			Class.forName("org.hsqldb.jdbcDriver");
			Connection con = DriverManager.getConnection("jdbc:hsqldb:mem:testdb",
					"sa", "");
			Statement st = con.createStatement();
			long begin = 0;
			long end = 0;
	
			begin = System.currentTimeMillis();
	
			try {
				st.executeUpdate("drop table teste");
	
			} catch (Exception e) {
				System.out.println("Criando tabela");
			}
	
			if (executionMode.equals("mem")) {
				st.executeUpdate("create table teste(t1 varchar, t2 varchar)");
				if (idx.equals("idx"))
					st.executeUpdate("create index idx_t1 on teste(t1)");
			} else if (executionMode.equals("disk")) {
				st
						.executeUpdate("create cached table teste(t1 varchar, t2 varchar)");
				if (idx.equals("idx"))
	
					st.executeUpdate("create index idx_t1 on teste(t1)");
			}
			int groupSize = 8;
			char[] c = { 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j' };
			// Storage disk = new DiskHashTable(100);
			int numberOfFields = 1;
	
			String a = null;
			for (int i = 1; i <= numberOfGroups; ++i) {
				for (int j = 0; j < numberOfFields; ++j)
					a = PargresStringUtils.random(groupSize, c);
				st.executeUpdate("insert into teste(t1 , t2) values ( '" + a
						+ "','" + a + "')");
				if (i % 50000 == 0)
					System.out.println(i);
			}
			System.out.println("Executando select com Group by");
			ResultSet rs = st
					.executeQuery("select t1, count(t2) from teste group by t1");
			
			end = System.currentTimeMillis();
			rs.next();
			System.out.println((end - begin) + " ms");
			
			st.close();
			con.close();
	}

}
