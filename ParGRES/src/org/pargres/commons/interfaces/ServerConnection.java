/*
 * Created on 08/04/2005
 */
package org.pargres.commons.interfaces;

import java.rmi.Remote;
import java.rmi.RemoteException;
import java.sql.ResultSet;
import java.sql.SQLException;

import org.pargres.commons.util.PargresException;
import org.pargres.jdbc.PargresDatabaseMetaData;

/**
 * 
 * @author <a href="mailto:bmiranda@cos.ufrj.br">Bernardo Miranda</a>
 */

public interface ServerConnection extends Remote {
    	
	public ResultSet executeQuery(String sql) throws RemoteException,SQLException;	
	public int executeUpdate(String sql) throws RemoteException,SQLException;
	public PargresDatabaseMetaData getMetaData() throws RemoteException, PargresException;
	public void setAutoCommit(boolean arg0) throws SQLException, RemoteException;
	public boolean getAutoCommit() throws SQLException, RemoteException;
	public void commit() throws SQLException, RemoteException;
	public void rollback() throws SQLException, RemoteException;
	public void close() throws SQLException, RemoteException;
	
}
