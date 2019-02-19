package org.pargres.cqp;

import java.util.HashMap;

import org.pargres.commons.util.PargresAuthenticationException;

public class UserManager {
	private HashMap<String,String> users = new HashMap<String,String>();

	public void put(String user, String password) {
		users.put(user,password);
	}
	
	public void verify(String user, String password) throws PargresAuthenticationException {
		String pwd = users.get(user);
		if(!(pwd != null && pwd.equals(password))) 
			throw new PargresAuthenticationException("User not exist or password is incorrect!");
	}

}
