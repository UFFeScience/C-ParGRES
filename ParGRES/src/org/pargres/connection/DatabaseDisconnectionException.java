package org.pargres.connection;

import java.sql.SQLException;

public class DatabaseDisconnectionException extends SQLException {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	private int disconnectedNode = -1;

	public int getDisconnectedNode() {
		return disconnectedNode;
	}

	public void setDisconnectedNode(int disconnectedNode) {
		this.disconnectedNode = disconnectedNode;
	}
}
