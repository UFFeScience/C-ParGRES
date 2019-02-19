package org.pargres.parser;

public class Const {	
	//ARITHMETICS OPERATORS
	public static final int PLUS = 1;
	public static final int MINUS = 2;
	public static final int MULTIPLICATION = 3;
	public static final int DIVISION = 4;
	public static final int UNARY_PLUS = 5;
	public static final int UNARY_MINUS = 6;
	
	//LOGICS OPERATORS
	public static final int OR = 7;
	public static final int AND = 8;
	public static final int NOT = 9;
	
	//RELATIONALS OPERATORS
	public static final int EQUAL = 10;
	public static final int DIFFERENT = 11;
	public static final int LESS = 12;
	public static final int GREATER = 13;
	public static final int LESS_EQUAL = 14;
	public static final int GREATER_EQUAL = 15;
	
	//OTHERS 
	public static final int IS_NULL = 16;
	public static final int IS_NOT_NULL = 17;
	public static final int CONCATENATION = 18;
	
	//AGGREGATION FUNCTION
	public static final int AVG = 19;
	public static final int MIN = 20;
	public static final int MAX = 21;	
	public static final int SUM = 22;
	public static final int COUNT = 23;
	
    //NONE INDICATOR
	public static final int NONE = 25;
	
	//TYPES
		
	public static final int CHAR = 26;
	public static final int CONST_STRING = 27;
	public static final int VARCHAR = 28;
	public static final int LONGVARCHAR = 29;
	public static final int DOUBLE = 30;
	public static final int CONST_DOUBLE = 31;
	public static final int DECIMAL = 32;
	public static final int NUMERIC = 33;
	public static final int FLOAT = 34;
	public static final int REAL = 35;
	public static final int INTEGER = 36;
	public static final int CONST_INTEGER = 37;
	public static final int SMALLINT = 38;
	public static final int TINYINT = 39;
	public static final int BIGINT = 40;
	public static final int DATE = 41;
	public static final int CONST_DATE = 42;
	public static final int TIME = 43;
	public static final int CONST_TIME = 44;
	public static final int TIMESTAMP = 45;
	public static final int BOOLEAN = 46;
	public static final int CONST_BOOLEAN = 47;
	public static final int NULL = 48;
	public static final int CONST_NULL = 49;	
	public static final int WILDCARD = 50;
	

	// ORDER TYPES
	public static final int ASC = 43;
	public static final int DESC = 44;
	
    //Column prefix used by Parser and Result Composition
	public static final String COLUMN_PREFIX = "qvp";
    public static final String GROUPER_TABLE_NAME = "grouper";
}
