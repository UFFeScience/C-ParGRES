package org.pargres.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;

import org.pargres.console.ResultSetPrinter;

public class TestRmiTunneling {

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		try {
			Class.forName("org.pargres.jdbc.Driver");
			Connection con = DriverManager.getConnection("jdbc:pargres://localhost","user","");
			ResultSet rs = con.createStatement().executeQuery("SELECT * FROM NATION");
			ResultSetPrinter.print(rs,10);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

}
