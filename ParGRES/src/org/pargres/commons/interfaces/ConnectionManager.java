package org.pargres.commons.interfaces;

import java.rmi.Remote;
import java.rmi.RemoteException;
import java.sql.ResultSet;
import java.sql.SQLException;

import org.pargres.commons.util.PargresAuthenticationException;
import org.pargres.commons.util.PargresException;
import org.pargres.jdbc.PargresDatabaseMetaData;

public interface ConnectionManager extends Remote {
	public static String OBJECT_NAME = "ConnectionCqp";
	public static int DEFAULT_PORT = 8050;
	public int createConnection(String user, String password) throws PargresAuthenticationException,RemoteException;
	public boolean forceNewPartitionLimits(String table, String field, long first, long last) throws RemoteException;
	public ResultSet executeQuery(int connectionId, String sql) throws RemoteException,SQLException;
	public int executeUpdate(int connectionId, String sql) throws RemoteException,SQLException;
	public PargresDatabaseMetaData getMetaData(int connectionId) throws RemoteException,PargresException;
	public void setAutoCommit(int connectionId, boolean autoCommit) throws SQLException, RemoteException;
	public void commit(int connectionId) throws SQLException, RemoteException;
	public void rollback(int connectionId) throws SQLException, RemoteException;
	public void close(int connectionId) throws SQLException, RemoteException;
	public boolean getAutoCommit(int connectionId) throws SQLException, RemoteException;
			
}
