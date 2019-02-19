package org.pargres.console;

import java.sql.ResultSet;
import java.sql.SQLException;

public class ResultSetPrinter {

	public static String getPrint(ResultSet rs, int lines) throws SQLException {
		String saida = "#### RESULTS ####\n";
		for(int i = 1; i <= rs.getMetaData().getColumnCount(); i++) {
			saida += rs.getMetaData().getColumnName(i)+" |\t";
		}			
		saida += "\n";
		int j = 0;
		while(rs.next() && (j < lines)) {
			saida += "line "+j+": ";
			for(int i = 1; i <= rs.getMetaData().getColumnCount(); i++)
				saida += rs.getString(i)+" |\t";
			saida += "\n";
			j++;				
		}
		return saida;
	}
	
	public static String getPrintHtml(ResultSet rs, int lines) throws SQLException {
		String saida = "<table border=\"1\">";
		saida += "<tr>";
		for(int i = 1; i <= rs.getMetaData().getColumnCount(); i++) {
			saida += "<th class=\"main\">"+rs.getMetaData().getColumnName(i)+" </th>";
		}			
		saida += "</tr>\n";
		int j = 0;
		while(rs.next() && (j < lines)) {
			saida += "<tr>";
			for(int i = 1; i <= rs.getMetaData().getColumnCount(); i++)
				saida += "<td class=\"main\"><center>"+rs.getString(i)+"</center></td>";
			saida += "</tr>\n";
			j++;				
		}
		saida += "</table>";
		return saida;
	}	
	
	public static void print(ResultSet rs, int lines) throws SQLException {
		System.out.print(getPrint(rs,lines));
	}

}
