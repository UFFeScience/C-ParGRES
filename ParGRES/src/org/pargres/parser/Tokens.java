package org.pargres.parser;
import java.util.ArrayList;

public class Tokens{
          	public String alias;
          	public String compositorText; 
			public String text;		
			public ColumnRefTable columnRefTable = null;
			public String columnRefField;
			public int selectColumnCount;
			public int columnType;
			public int typeSize;
			public int typePrecision;
			public int typeLength;
			public int caseWhenType;
			public int operator;
			public int type;
			public int aggregationFunction;
			public ArrayList<Object> compositor = new ArrayList<Object>(0);
			public boolean isJoinPartitionable;
			public boolean isInPartitionable;
			public boolean isUniqueColumn;		
			public Tokens clone() {
				Tokens t = new Tokens();
				t.alias = alias;
				t.compositorText = compositorText;
				t.text = text;
				t.columnRefTable = columnRefTable;
				t.columnRefField = columnRefField;
				t.selectColumnCount = selectColumnCount;
				t.columnType = columnType;
				t.typeSize = typeSize;
				t.typePrecision = typePrecision;
				t.typeLength = typeLength;
				t.caseWhenType = caseWhenType;
				t.operator = operator;
				t.type = type;
				t.aggregationFunction = aggregationFunction;
				t.compositor = compositor;
				t.isJoinPartitionable = isJoinPartitionable;
				t.isInPartitionable = isInPartitionable;
				t.isUniqueColumn = isUniqueColumn;
				return t;
			}			
}

