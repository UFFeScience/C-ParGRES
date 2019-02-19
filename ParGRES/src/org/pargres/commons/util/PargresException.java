/*
 * Created on 08/04/2005
 */
package org.pargres.commons.util;

import java.sql.SQLException;

/**
 * @author Bernardo
 */
public class PargresException extends SQLException {
	/**
	 * 
	 */
	private static final long serialVersionUID = 3256438110194776370L;

	public PargresException(String problemDescription) {
		super(problemDescription);
	}
}
