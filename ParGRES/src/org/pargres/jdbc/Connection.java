/*
 * Created on 08/04/2005
 */
package org.pargres.jdbc;

import java.rmi.RemoteException;
import java.sql.Array;
import java.sql.Blob;
import java.sql.CallableStatement;
import java.sql.Clob;
import java.sql.DatabaseMetaData;
import java.sql.NClob;
import java.sql.PreparedStatement;
import java.sql.SQLClientInfoException;
import java.sql.SQLException;
import java.sql.SQLWarning;
import java.sql.SQLXML;
import java.sql.Savepoint;
import java.sql.Statement;
import java.sql.Struct;
import java.util.Map;
import java.util.Properties;
import java.util.concurrent.Executor;

import org.pargres.commons.interfaces.ConnectionManager;
import org.pargres.commons.translation.Messages;
import org.pargres.commons.util.JdbcNotImplementedYetException;
import org.pargres.commons.util.PargresException;
import org.pargres.util.MyRMIRegistry;
import org.pargres.commons.util.JdbcClientInfoNotImplementedYetException;


/**
 * @author Bernardo
 */
public class Connection implements java.sql.Connection {
    private int connectionId;
    private ConnectionManager connectionManager = null;
	protected boolean readOnly = false;
	
	protected ConnectionManager getConnnectionManager() {
		return connectionManager;
	}
	
	protected int getConnectionId() {
		return connectionId;
	}	

	public Connection(String host, int port, String user, String password) throws PargresException {
        try {			
			String url = "//"+host+":"+port+"/"+ConnectionManager.OBJECT_NAME;
			System.out.println("Trying to connect: "+url);
			Object o;
			try {
            	o = MyRMIRegistry.lookup(host,port,url);
			} catch (Exception e) {
				System.err.println("Connection failed!");
				e.printStackTrace();
				throw e;
			}
			connectionManager = (ConnectionManager) o;
			connectionId = connectionManager.createConnection(user,password);
			System.err.println("Connection successful!");
        } catch (Exception e) {
			e.printStackTrace();
            throw new PargresException(e.getMessage());
        }
        
    }
    /* (non-Javadoc)
     * @see java.sql.Connection#createStatement()
     */
    public Statement createStatement() throws SQLException {
		//logger.debug("Statement createStatement()");
        return new org.pargres.jdbc.Statement(this);
    }

    /* (non-Javadoc)
     * @see java.sql.Connection#prepareStatement(java.lang.String)
     */
    public PreparedStatement prepareStatement(String arg0) throws SQLException {
		//logger.debug("PreparedStatement prepareStatement()");
        return null;
    }

    /* (non-Javadoc)
     * @see java.sql.Connection#prepareCall(java.lang.String)
     */
    public CallableStatement prepareCall(String arg0) throws SQLException {
		//logger.debug("CallableStatement prepareCall()");
        return null;
    }

    /* (non-Javadoc)
     * @see java.sql.Connection#nativeSQL(java.lang.String)
     */
    public String nativeSQL(String arg0) throws SQLException {
		//logger.debug("String nativeSQL()");
        return null;
    }
	
    /* (non-Javadoc)
     * @see java.sql.Connection#setAutoCommit(boolean)
     */
    public void setAutoCommit(boolean arg0) throws SQLException {
		try {
			connectionManager.setAutoCommit(connectionId,arg0);
		} catch (RemoteException e) {
			throw new SQLException(Messages.getString("connection.communicationError",e.getMessage()));
		}
    }

    /* (non-Javadoc)
     * @see java.sql.Connection#getAutoCommit()
     */
    public boolean getAutoCommit() throws SQLException {
		try {
			return connectionManager.getAutoCommit(connectionId);
		} catch (RemoteException e) {
			throw new SQLException(Messages.getString("connection.communicationError",e.getMessage()));
		}			
    }

    /* (non-Javadoc)
     * @see java.sql.Connection#commit()
     */
    public void commit() throws SQLException {
		try {
			connectionManager.commit(connectionId);
		} catch (RemoteException e) {
			throw new SQLException("Communication error :"+e.getMessage());
		}			
    }

    /* (non-Javadoc)
     * @see java.sql.Connection#rollback()
     */
    public void rollback() throws SQLException {
		try {
			connectionManager.rollback(connectionId);
		} catch (RemoteException e) {
			throw new SQLException("Communication error :"+e.getMessage());
		}			
    }

    /* (non-Javadoc)
     * @see java.sql.Connection#close()
     */
    public void close() throws SQLException {
		try {
			connectionManager.close(connectionId);
			connectionManager = null;
		} catch (RemoteException e) {
			throw new SQLException("Communication error :"+e.getMessage());
		}			
    }

    /* (non-Javadoc)
     * @see java.sql.Connection#isClosed()
     */
    public boolean isClosed() throws SQLException {
		return (connectionManager == null);
    }

    /* (non-Javadoc)
     * @see java.sql.Connection#getMetaData()
     */
    public DatabaseMetaData getMetaData() throws SQLException {
		try {
        	return connectionManager.getMetaData(connectionId);
		} catch (RemoteException e) {
			e.printStackTrace();
			throw new SQLException(e.getMessage());
		}
    }

    /* (non-Javadoc)
     * @see java.sql.Connection#setReadOnly(boolean)
     */
    public void setReadOnly(boolean arg0) throws SQLException {
		readOnly = true;
    }

    /* (non-Javadoc)
     * @see java.sql.Connection#isReadOnly()
     */
    public boolean isReadOnly() throws SQLException {
		return readOnly;
    }

    /* (non-Javadoc)
     * @see java.sql.Connection#setCatalog(java.lang.String)
     */
    public void setCatalog(String arg0) throws SQLException {
		//logger.debug("void setCatalog()");  
		throw new JdbcNotImplementedYetException();
    }

    /* (non-Javadoc)
     * @see java.sql.Connection#getCatalog()
     */
    public String getCatalog() throws SQLException {
		//logger.debug("String getCatalog()");  
		throw new JdbcNotImplementedYetException();
    }

    /* (non-Javadoc)
     * @see java.sql.Connection#setTransactionIsolation(int)
     */
    public void setTransactionIsolation(int arg0) throws SQLException {
		//logger.debug("void setTransactionIsolation()");  
		throw new JdbcNotImplementedYetException();		
    }

    /* (non-Javadoc)
     * @see java.sql.Connection#getTransactionIsolation()
     */
    public int getTransactionIsolation() throws SQLException {
		return Connection.TRANSACTION_READ_COMMITTED;
    }

    /* (non-Javadoc)
     * @see java.sql.Connection#getWarnings()
     */
    public SQLWarning getWarnings() throws SQLException {
		//logger.debug("SQLWarning getWarnings");
		throw new JdbcNotImplementedYetException();
    }

    /* (non-Javadoc)
     * @see java.sql.Connection#clearWarnings()
     */
    public void clearWarnings() throws SQLException {
		//logger.debug("void clearWarnings");
		throw new JdbcNotImplementedYetException();   
    }

    /* (non-Javadoc)
     * @see java.sql.Connection#createStatement(int, int)
     */
    public Statement createStatement(int arg0, int arg1) throws SQLException {
		//logger.debug("Statement createStatement");
		throw new JdbcNotImplementedYetException();
    }

    /* (non-Javadoc)
     * @see java.sql.Connection#prepareStatement(java.lang.String, int, int)
     */
    public PreparedStatement prepareStatement(String arg0, int arg1, int arg2) throws SQLException {
		//logger.debug("PreparedStatement prepareStatement");
		throw new JdbcNotImplementedYetException();
    }

    /* (non-Javadoc)
     * @see java.sql.Connection#prepareCall(java.lang.String, int, int)
     */
    public CallableStatement prepareCall(String arg0, int arg1, int arg2) throws SQLException {
		//logger.debug("CallableStatement prepareCall");
		throw new JdbcNotImplementedYetException();
    }

    /* (non-Javadoc)
     * @see java.sql.Connection#getTypeMap()
     */
    public Map<String,Class<?>> getTypeMap() throws SQLException {
		//logger.debug("Map getTypeMap");
		throw new JdbcNotImplementedYetException();
    }

    /* (non-Javadoc)
     * @see java.sql.Connection#setTypeMap(java.util.Map)
     */
    public void setTypeMap(Map arg0) throws SQLException {
		//logger.debug("void setTypeMap");
		throw new JdbcNotImplementedYetException();		
    }

    /* (non-Javadoc)
     * @see java.sql.Connection#setHoldability(int)
     */
    public void setHoldability(int arg0) throws SQLException {
		//logger.debug("void setHoldability");
		throw new JdbcNotImplementedYetException();        		
    }

    /* (non-Javadoc)
     * @see java.sql.Connection#getHoldability()
     */
    public int getHoldability() throws SQLException {
		//logger.debug("int getHoldability");
		throw new JdbcNotImplementedYetException();
    }

    /* (non-Javadoc)
     * @see java.sql.Connection#setSavepoint()
     */
    public Savepoint setSavepoint() throws SQLException {
		//logger.debug("Savepoint setSavepoint");		
		throw new JdbcNotImplementedYetException();
    }

    /* (non-Javadoc)
     * @see java.sql.Connection#setSavepoint(java.lang.String)
     */
    public Savepoint setSavepoint(String arg0) throws SQLException {
		//logger.debug("Savepoint setSavepoint");	
		throw new JdbcNotImplementedYetException();
    }

    /* (non-Javadoc)
     * @see java.sql.Connection#rollback(java.sql.Savepoint)
     */
    public void rollback(Savepoint arg0) throws SQLException {
		//logger.debug("void rollback");	
		throw new JdbcNotImplementedYetException();
    }

    /* (non-Javadoc)
     * @see java.sql.Connection#releaseSavepoint(java.sql.Savepoint)
     */
    public void releaseSavepoint(Savepoint arg0) throws SQLException {
		//logger.debug("void releaseSavepoint");	
		throw new JdbcNotImplementedYetException();        
    }

    /* (non-Javadoc)
     * @see java.sql.Connection#createStatement(int, int, int)
     */
    public Statement createStatement(int arg0, int arg1, int arg2) throws SQLException {
		//logger.debug("Statement createStatement");
		throw new JdbcNotImplementedYetException();
    }

    /* (non-Javadoc)
     * @see java.sql.Connection#prepareStatement(java.lang.String, int, int, int)
     */
    public PreparedStatement prepareStatement(String arg0, int arg1, int arg2, int arg3) throws SQLException {
		//logger.debug("PreparedStatement prepareStatement");
		throw new JdbcNotImplementedYetException();
    }

    /* (non-Javadoc)
     * @see java.sql.Connection#prepareCall(java.lang.String, int, int, int)
     */
    public CallableStatement prepareCall(String arg0, int arg1, int arg2, int arg3) throws SQLException {
		//logger.debug("CallableStatement prepareCall");
		throw new JdbcNotImplementedYetException();
    }

    /* (non-Javadoc)
     * @see java.sql.Connection#prepareStatement(java.lang.String, int)
     */
    public PreparedStatement prepareStatement(String arg0, int arg1) throws SQLException {
		//logger.debug("PreparedStatement prepareStatement");
		throw new JdbcNotImplementedYetException();
    }

    /* (non-Javadoc)
     * @see java.sql.Connection#prepareStatement(java.lang.String, int[])
     */
    public PreparedStatement prepareStatement(String arg0, int[] arg1) throws SQLException {
		//logger.debug("PreparedStatement prepareStatement");
		throw new JdbcNotImplementedYetException();
    }

    /* (non-Javadoc)
     * @see java.sql.Connection#prepareStatement(java.lang.String, java.lang.String[])
     */
    public PreparedStatement prepareStatement(String arg0, String[] arg1) throws SQLException {
		//logger.debug("PreparedStatement prepareStatement");
		throw new JdbcNotImplementedYetException();
    }

    @Override
    public Clob createClob() throws SQLException {
		throw new JdbcNotImplementedYetException();
    }

    @Override
    public Blob createBlob() throws SQLException {
		throw new JdbcNotImplementedYetException();
    }

    @Override
    public NClob createNClob() throws SQLException {
		throw new JdbcNotImplementedYetException();
    }

    @Override
    public SQLXML createSQLXML() throws SQLException {
		throw new JdbcNotImplementedYetException();
    }

    @Override
    public boolean isValid(int timeout) throws SQLException {
		throw new JdbcNotImplementedYetException();
    }

    @Override
    public void setClientInfo(String name, String value) throws SQLClientInfoException {
		throw new JdbcClientInfoNotImplementedYetException();
    }

    @Override
    public void setClientInfo(Properties properties) throws SQLClientInfoException {
		throw new JdbcClientInfoNotImplementedYetException();
    }

    @Override
    public String getClientInfo(String name) throws SQLException {
		throw new JdbcNotImplementedYetException();
    }

    @Override
    public Properties getClientInfo() throws SQLException {
		throw new JdbcNotImplementedYetException();
    }

    @Override
    public Array createArrayOf(String typeName, Object[] elements) throws SQLException {
		throw new JdbcNotImplementedYetException();
    }

    @Override
    public Struct createStruct(String typeName, Object[] attributes) throws SQLException {
		throw new JdbcNotImplementedYetException();
    }

    @Override
    public void setSchema(String schema) throws SQLException {
		throw new JdbcNotImplementedYetException();
    }

    @Override
    public String getSchema() throws SQLException {
		throw new JdbcNotImplementedYetException();
    }

    @Override
    public void abort(Executor executor) throws SQLException {
		throw new JdbcNotImplementedYetException();
    }

    @Override
    public void setNetworkTimeout(Executor executor, int milliseconds) throws SQLException {
		throw new JdbcNotImplementedYetException();
    }

    @Override
    public int getNetworkTimeout() throws SQLException {
		throw new JdbcNotImplementedYetException();
    }

    @Override
    public <T> T unwrap(Class<T> iface) throws SQLException {
		throw new JdbcNotImplementedYetException();
    }

    @Override
    public boolean isWrapperFor(Class<?> iface) throws SQLException {
		throw new JdbcNotImplementedYetException();
    }

}
