/*
 * Created on 08/04/2005
 */
package org.pargres.jdbc;

import java.rmi.RemoteException;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.SQLWarning;

import org.pargres.commons.interfaces.ConnectionManager;
import org.pargres.commons.util.PargresException;

/**
 * @author Bernardo
 */
public class Statement implements java.sql.Statement {
    private org.pargres.jdbc.Connection con;
    
    public Statement(Connection con) {
        this.con = con;        
    }

    /* (non-Javadoc)
     * @see java.sql.Statement#executeQuery(java.lang.String)
     */
    public ResultSet executeQuery(String sql) throws SQLException {
		assertNotClosed();		
		try {
			ConnectionManager scon = con.getConnnectionManager();
			ResultSet rs = scon.executeQuery(con.getConnectionId(),sql);
			rs.beforeFirst();
			//if(!rs.isBeforeFirst()) 
				//throw new SQLException("ResultSet is not before first record!");
			return rs;
		} catch (RemoteException e) {
			throw new PargresException(e.getMessage());
		} catch (SQLException e) {
			System.err.println(e);
			throw e;
		}
    }
	
	private void assertNotClosed() throws SQLException {
		if(con == null)
			throw new SQLException("Statement is closed!");
	}
	
	private void assertNotReadOnly() throws SQLException {
		if(con.readOnly)
			throw new SQLException("This connection is read only!");		
	}

    /* (non-Javadoc)
     * @see java.sql.Statement#executeUpdate(java.lang.String)
     */
    public int executeUpdate(String sql) throws SQLException {
		assertNotClosed();
		assertNotReadOnly();
		try {
			if((!con.getAutoCommit()) && (sql.equals("CREATE") || sql.equals("DROP") || sql.equals("ALTER")))
				con.commit();
				
			return con.getConnnectionManager().executeUpdate(con.getConnectionId(),sql);
		} catch (RemoteException e) {
			throw new PargresException(e.getMessage());
		}
    }

    /* (non-Javadoc)
     * @see java.sql.Statement#close()
     */
    public void close() throws SQLException {
		this.con = null;        
    }

    /* (non-Javadoc)
     * @see java.sql.Statement#getMaxFieldSize()
     */
    public int getMaxFieldSize() throws SQLException {
		assertNotClosed();
        return 0;
    }

    /* (non-Javadoc)
     * @see java.sql.Statement#setMaxFieldSize(int)
     */
    public void setMaxFieldSize(int arg0) throws SQLException {
		assertNotClosed();
		throw new SQLException("Not implemented yet!");        
    }

    /* (non-Javadoc)
     * @see java.sql.Statement#getMaxRows()
     */
    public int getMaxRows() throws SQLException {
		assertNotClosed();
		throw new SQLException("Not implemented yet!");
    }

    /* (non-Javadoc)
     * @see java.sql.Statement#setMaxRows(int)
     */
    public void setMaxRows(int arg0) throws SQLException {
		assertNotClosed();
		throw new SQLException("Not implemented yet!");        
    }

    /* (non-Javadoc)
     * @see java.sql.Statement#setEscapeProcessing(boolean)
     */
    public void setEscapeProcessing(boolean arg0) throws SQLException {
		assertNotClosed();
		throw new SQLException("Not implemented yet!");
    }

    /* (non-Javadoc)
     * @see java.sql.Statement#getQueryTimeout()
     */
    public int getQueryTimeout() throws SQLException {
		assertNotClosed();
		throw new SQLException("Not implemented yet!");
    }

    /* (non-Javadoc)
     * @see java.sql.Statement#setQueryTimeout(int)
     */
    public void setQueryTimeout(int arg0) throws SQLException {
		assertNotClosed();
		throw new SQLException("Not implemented yet!");        
    }

    /* (non-Javadoc)
     * @see java.sql.Statement#cancel()
     */
    public void cancel() throws SQLException {
		assertNotClosed();
		throw new SQLException("Not implemented yet!");        
    }

    /* (non-Javadoc)
     * @see java.sql.Statement#getWarnings()
     */
    public SQLWarning getWarnings() throws SQLException {
		assertNotClosed();
		throw new SQLException("Not implemented yet!");
    }

    /* (non-Javadoc)
     * @see java.sql.Statement#clearWarnings()
     */
    public void clearWarnings() throws SQLException {
		assertNotClosed();
		throw new SQLException("Not implemented yet!");        
    }

    /* (non-Javadoc)
     * @see java.sql.Statement#setCursorName(java.lang.String)
     */
    public void setCursorName(String arg0) throws SQLException {
		assertNotClosed();
		throw new SQLException("Not implemented yet!");        
    }

    /* (non-Javadoc)
     * @see java.sql.Statement#execute(java.lang.String)
     */
    public boolean execute(String sql) throws SQLException {
		if(sql.toUpperCase().startsWith("SELECT")) {
			try {
				con.getConnnectionManager().executeQuery(con.getConnectionId(),sql);
			} catch (RemoteException e) {
				throw new PargresException(e.getMessage());
			}
			return true;
		} else {
			try {
				con.getConnnectionManager().executeUpdate(con.getConnectionId(),sql);
			} catch (RemoteException e) {
				throw new PargresException(e.getMessage());
			}
			return true;			
		}
    }

    /* (non-Javadoc)
     * @see java.sql.Statement#getResultSet()
     */
    public ResultSet getResultSet() throws SQLException {
		assertNotClosed();
		throw new SQLException("Not implemented yet!");
    }

    /* (non-Javadoc)
     * @see java.sql.Statement#getUpdateCount()
     */
    public int getUpdateCount() throws SQLException {
		assertNotClosed();
		throw new SQLException("Not implemented yet!");
    }

    /* (non-Javadoc)
     * @see java.sql.Statement#getMoreResults()
     */
    public boolean getMoreResults() throws SQLException {
		assertNotClosed();
		throw new SQLException("Not implemented yet!");        
    }
    
    /* (non-Javadoc)
     * @see java.sql.Statement#setFetchDirection(int)
     */
    public void setFetchDirection(int arg0) throws SQLException {
		assertNotClosed();
		throw new SQLException("Not implemented yet!");        
    }

    /* (non-Javadoc)
     * @see java.sql.Statement#getFetchDirection()
     */
    public int getFetchDirection() throws SQLException {
		assertNotClosed();
		throw new SQLException("Not implemented yet!");
    }

    /* (non-Javadoc)
     * @see java.sql.Statement#setFetchSize(int)
     */
    public void setFetchSize(int arg0) throws SQLException {
		assertNotClosed();
		throw new SQLException("Not implemented yet!");        
    }

    /* (non-Javadoc)
     * @see java.sql.Statement#getFetchSize()
     */
    public int getFetchSize() throws SQLException {
		assertNotClosed();
		throw new SQLException("Not implemented yet!");
    }

    /* (non-Javadoc)
     * @see java.sql.Statement#getResultSetConcurrency()
     */
    public int getResultSetConcurrency() throws SQLException {
		assertNotClosed();
		throw new SQLException("Not implemented yet!");
    }

    /* (non-Javadoc)
     * @see java.sql.Statement#getResultSetType()
     */
    public int getResultSetType() throws SQLException {
		assertNotClosed();
		throw new SQLException("Not implemented yet!");
    }

    /* (non-Javadoc)
     * @see java.sql.Statement#addBatch(java.lang.String)
     */
    public void addBatch(String arg0) throws SQLException {
		assertNotClosed();
		throw new SQLException("Not implemented yet!");        
    }

    /* (non-Javadoc)
     * @see java.sql.Statement#clearBatch()
     */
    public void clearBatch() throws SQLException {
		assertNotClosed();
		throw new SQLException("Not implemented yet!");        
    }

    /* (non-Javadoc)
     * @see java.sql.Statement#executeBatch()
     */
    public int[] executeBatch() throws SQLException {
		assertNotClosed();
		throw new SQLException("Not implemented yet!");
    }

    /* (non-Javadoc)
     * @see java.sql.Statement#getConnection()
     */
    public java.sql.Connection getConnection() throws SQLException {
		return con;
    }

    /* (non-Javadoc)
     * @see java.sql.Statement#getMoreResults(int)
     */
    public boolean getMoreResults(int arg0) throws SQLException {
		assertNotClosed();
		throw new SQLException("Not implemented yet!");
    }

    /* (non-Javadoc)
     * @see java.sql.Statement#getGeneratedKeys()
     */
    public ResultSet getGeneratedKeys() throws SQLException {
		assertNotClosed();
		throw new SQLException("Not implemented yet!");
    }

    /* (non-Javadoc)
     * @see java.sql.Statement#executeUpdate(java.lang.String, int)
     */
    public int executeUpdate(String arg0, int arg1) throws SQLException {
		assertNotClosed();
		assertNotReadOnly();
		throw new SQLException("Not implemented yet!");
    }

    /* (non-Javadoc)
     * @see java.sql.Statement#executeUpdate(java.lang.String, int[])
     */
    public int executeUpdate(String arg0, int[] arg1) throws SQLException {
		assertNotClosed();
		assertNotReadOnly();
		throw new SQLException("Not implemented yet!");
    }

    /* (non-Javadoc)
     * @see java.sql.Statement#executeUpdate(java.lang.String, java.lang.String[])
     */
    public int executeUpdate(String arg0, String[] arg1) throws SQLException {
		assertNotClosed();
		assertNotReadOnly();
		throw new SQLException("Not implemented yet!");
    }

    /* (non-Javadoc)
     * @see java.sql.Statement#execute(java.lang.String, int)
     */
    public boolean execute(String arg0, int arg1) throws SQLException {
		assertNotClosed();
		throw new SQLException("Not implemented yet!");
    }

    /* (non-Javadoc)
     * @see java.sql.Statement#execute(java.lang.String, int[])
     */
    public boolean execute(String arg0, int[] arg1) throws SQLException {
		assertNotClosed();
		throw new SQLException("Not implemented yet!");
    }

    /* (non-Javadoc)
     * @see java.sql.Statement#execute(java.lang.String, java.lang.String[])
     */
    public boolean execute(String arg0, String[] arg1) throws SQLException {
		assertNotClosed();
		throw new SQLException("Not implemented yet!");
    }

    /* (non-Javadoc)
     * @see java.sql.Statement#getResultSetHoldability()
     */
    public int getResultSetHoldability() throws SQLException {
		assertNotClosed();
		throw new SQLException("Not implemented yet!");
    }

    @Override
    public boolean isClosed() throws SQLException {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }

    @Override
    public void setPoolable(boolean poolable) throws SQLException {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }

    @Override
    public boolean isPoolable() throws SQLException {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }

    @Override
    public void closeOnCompletion() throws SQLException {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }

    @Override
    public boolean isCloseOnCompletion() throws SQLException {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }

    @Override
    public <T> T unwrap(Class<T> iface) throws SQLException {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }

    @Override
    public boolean isWrapperFor(Class<?> iface) throws SQLException {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }

}
