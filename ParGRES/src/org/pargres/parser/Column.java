package org.pargres.parser;

import java.io.Serializable;

public class Column implements Serializable {
	private static final long serialVersionUID = 8847139794835400625L;
	private String text;	
	private int type;
	private int aggregationFunction;
	private String typeText;
	private boolean isConst;
	
	public Column(String text, int type, int aggregationFunction, String typeText, boolean isConst){
		this.text = text;
		this.type = type;
		this.aggregationFunction = aggregationFunction;
		this.typeText = typeText;
		this.isConst = isConst;		
	}
	public int getAggregationFunction() {
		return aggregationFunction;
	}
	public void setAggregationFunction(int aggregationFunction) {
		this.aggregationFunction = aggregationFunction;
	}
	public String getText() {
		return text;
	}
	public void setText(String text) {
		this.text = text;
	}
	public int getType() {
		return type;
	}
	public void setType(int type) {
		this.type = type;
	}
	public String getTypeText() {
		return typeText;
	}
	public void setTypeText(String typeText) {
		this.typeText = typeText;
	}
	public boolean isConst() {
		return isConst;
	}
	public void setConst(boolean isConst) {
		this.isConst = isConst;
	}
}
