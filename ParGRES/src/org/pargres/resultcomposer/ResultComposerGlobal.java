/*
 * ResultComposer_Global.java
 *
 * Created on 2 juin 2004, 14:05
 */

package org.pargres.resultcomposer;

import java.rmi.RemoteException;
import java.sql.ResultSet;
import java.lang.InterruptedException;

public interface ResultComposerGlobal extends ResultComposer {
	public ResultSet getResult() throws RemoteException,
			InterruptedException, Exception;
    
}
