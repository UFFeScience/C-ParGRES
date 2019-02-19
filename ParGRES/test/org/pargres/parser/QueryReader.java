package org.pargres.parser;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;

public class QueryReader {
	public static String getSQL(int id) throws IOException {
		BufferedReader br;
		try {
			br = new BufferedReader(new InputStreamReader(QueryReader.class
					.getResourceAsStream("q" + id + ".sql")));
			String sql = "";
			String line;
			while ((line = br.readLine()) != null) {
				sql += line +"\n";
			}
			return sql;
		} catch (Exception e) {
			e.printStackTrace();
			return null;
		}
	}
}
