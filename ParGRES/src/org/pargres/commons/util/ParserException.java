package org.pargres.commons.util;

import java.sql.SQLException;

public class ParserException extends SQLException {
	
	private static final long serialVersionUID = 3832618478359425078L;
	public ParserException(String error){
		super(error);
	}

}
