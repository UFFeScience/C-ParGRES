package org.pargres.tpch;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.text.SimpleDateFormat;
import java.util.Date;

import org.pargres.parser.QueryReader;

public class TpchBatchTester {
	private static int REPEATS = 5;
	private int[] ids = new int[] {10};//1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,21,22}; 	
	private BufferedWriter writer = null;
	private Connection con;
	

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		TpchBatchTester tpchTester = new TpchBatchTester();
		tpchTester.run();
	}
	
	public void run() {
	//	try {
			for(int id :  ids) {		
			try {
					String sql = QueryReader.getSQL(id);
					for(int i = 1; i <= REPEATS; i++) {
						long init = System.currentTimeMillis();
						ResultSet rs = con.createStatement().executeQuery(sql);
						while(rs.next()) {
							// do nothing
						}
						long end = System.currentTimeMillis() - init;
						log(id,end,i,REPEATS);
					}			
				}catch (Exception e) {
					System.err.println("Error while executing Q"+id+": "+e.getMessage());
					e.printStackTrace();
					//throw e;
				}	
			}
	/*	}catch (Exception e) {
			System.err.println(e.getMessage());
			e.printStackTrace();;
		}*/				
	}
		
	public void log(int id, long time, int i, int n) throws IOException {
		String log = "";
		if(i == 1)
			log += id+"";
		
		log += time+";";
		
		if(i == n)
			log += "\n";
		
		writer.write(log);
	}

	public TpchBatchTester() {
		try {
			Class.forName("org.pargres.jdbc.Driver");
			con = DriverManager.getConnection("jdbc:pargres://localhost","user",""); 
				
			SimpleDateFormat df = new SimpleDateFormat("yyyyMMdd");
			writer = new BufferedWriter(new FileWriter("tpchtester"+df.format(new Date())+".csv"));
			String header = "Query;";
			for(int i = 1; i <= REPEATS; i++) 
				header += "Time"+i+";";
			
			writer.write(header);
			
		} catch (Exception e) {
			e.printStackTrace();
			System.err.println(e.getMessage());
		}
	}

	@Override
	protected void finalize() throws Throwable {
		con.close();
		writer.flush();
		writer.close();
		super.finalize();
	}

}
