package org.pargres.benchmark;

import java.sql.ResultSet; 
import java.sql.SQLException;
import java.sql.Types;

import org.pargres.console.ResultSetPrinter;
import org.pargres.jdbc.PargresRowSet;

public class ResultSetComparator {

	public static ResultSet toCache(ResultSet rs) throws SQLException{
		PargresRowSet prs = new PargresRowSet();
		prs.populate(rs);
		if(prs.size() == 0)
			throw new SQLException("Empty resultSet!");
		return prs;
	}
	
	public static void compare(ResultSet rsA, ResultSet rsB) throws Exception {
		rsA = toCache(rsA);
		rsB = toCache(rsB);
		int lines = 10;
		int count = 0;		
		try {
			if(rsA.getMetaData().getColumnCount() != rsB.getMetaData().getColumnCount())
				throw new Exception("Número diferente de colunas: ResultSet A="+rsA.getMetaData().getColumnCount()+", ResultSet B="+rsB.getMetaData().getColumnCount());
			
			for(int j = 1; j <= rsA.getMetaData().getColumnCount(); j++)
				if(!rsA.getMetaData().getColumnName(j).equalsIgnoreCase(rsB.getMetaData().getColumnName(j)))
					throw new Exception("Ordem ou nome de campos diferente: campo "+j+", ResultSet A:"+rsA.getMetaData().getColumnName(j)+", ResulSet B:"+rsB.getMetaData().getColumnName(j));
				
			while(rsA.next()) {
				if(!rsB.next())
					throw new Exception("Número diferente de registros: ResultSet B parou em: "+count);
				
				for(int j = 1; j <= rsA.getMetaData().getColumnCount(); j++) {
					if(!rsA.getString(j).equals(rsB.getString(j))) {

						if((rsA.getMetaData().getColumnType(j) == Types.DECIMAL) ||
						   (rsA.getMetaData().getColumnType(j) == Types.DOUBLE) ||
						   (rsA.getMetaData().getColumnType(j) == Types.FLOAT) ||
						   (rsA.getMetaData().getColumnType(j) == Types.NUMERIC)) {
							double dif = rsA.getDouble(j) - rsB.getDouble(j);
							if(dif < 0)
								dif *= -1;
							if(dif > 0.1)
								throw new Exception("Valor errado do resultado.. fora da precis�o (linha "+count+") : campo "+rsA.getMetaData().getColumnName(j)+", A="+rsA.getDouble(j)+", B="+rsB.getDouble(j));
						}
						else 
							throw new Exception("Valor errado do resultado (linha "+count+") : campo "+rsA.getMetaData().getColumnName(j)+", A="+rsA.getDouble(j)+", B="+rsB.getDouble(j));												
					}
				}
				count++;
			}		
			if(rsB.next())
				throw new Exception("N�mero diferente de registros: ResultSet A ainda tem mais registros do que "+count);
			
		} catch (Exception e) {
			if(count > lines)
				lines = count+5;
			String saida = "";
			rsA.beforeFirst();
			rsB.beforeFirst();
			saida += ResultSetPrinter.getPrint(rsA,lines);
			saida += ResultSetPrinter.getPrint(rsB,lines);
		//	e.printStackTrace();
			throw new Exception(e.getMessage()+"\n"+saida);
		}
	}
}
