package org.pargres.commons.util;

import java.sql.SQLException;

public class JdbcNotImplementedYetException extends SQLException {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	public JdbcNotImplementedYetException() {
		super("Not implemented yet!");
	}

}
