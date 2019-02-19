package org.pargres.commons.util;

import java.sql.SQLException;

public class ParserSilentException extends SQLException {	

	private static final long serialVersionUID = 3256720671731167539L;
	public ParserSilentException(String error){
		super(error);
	}
}
