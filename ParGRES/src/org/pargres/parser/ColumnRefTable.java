package org.pargres.parser;

public class ColumnRefTable {
	public String name;
	public int tableLevel;
	public ColumnRefTable(String name,int tableLevel){
		this.name = name;
		this.tableLevel = tableLevel; 
	}
}
