/*
 * OlapClusterServer.java
 *
 * Created on 15 decembre 2003, 17:27
 */

package org.pargres.resultcomposer;

/**
 *
 * @author  lima
 */

import java.rmi.Remote;
import java.rmi.RemoteException;
import java.sql.ResultSet;


public interface ResultComposer extends Remote {
	public void start() throws RemoteException;

	public void addResult(ResultSet q) throws RemoteException;

	public void finish() throws RemoteException;

	public boolean finished() throws RemoteException;
}
