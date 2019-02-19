package org.pargres;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;

import org.pargres.console.ResultSetPrinter;

public class SimpleConnection {

	public static void main(String[] args) {
		try { 
	        Class.forName("org.pargres.jdbc.Driver");
	        Connection con = DriverManager.getConnection("jdbc:pargres://localhost","user","");        		
			ResultSet rs = con.createStatement().executeQuery("select codmunicipio, v0300, pesodomi from cd2010adomi where v0300 >= 5501517 and v0300 <= 5501600");
			ResultSetPrinter.print(rs,10);
			ResultSetPrinter.print(con.getMetaData().getTables(null,null,null,null),10);
			System.out.println("FIM!");
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

}
