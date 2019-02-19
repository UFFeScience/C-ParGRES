package org.pargres.parser;

public class OrderByRef {
	private int index, orderType;
	public OrderByRef(int index, int orderType){
		this.index = index;
		this.orderType = orderType;
	}
	public int getIndex() {
		return index;
	}
	public int getOrderType() {
		return orderType;
	}
}
