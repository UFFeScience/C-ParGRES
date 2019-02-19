/*
 * DBGatewayEngine.java
 *
 * Created on 12 novembre 2003, 16:57
 */

package org.pargres.connection;

/**
 *
 * @author  lima
 */

import java.rmi.RemoteException;
import java.sql.SQLException;
import java.util.LinkedList;

import org.pargres.commons.logger.Logger;
import org.pargres.commons.translation.Messages;
 
public class DBConnectionPoolEngine /*extends UnicastRemoteObject implements DBConnectionPool*/ {
	
	/**
	 * 
	 */
	private static final long serialVersionUID = 3258415044935824178L;

	private Logger logger = Logger.getLogger(DBConnectionPoolEngine.class);
	
    private String jdbcUrl;
    private String jdbcDriver;
    private String login;
    private String password;
    private LinkedList<DBConnectionEngine> connPool;
    private int iniConnectionPoolSize;
    
   
    /** Creates a new instance of DBGatewayEngine */
    public DBConnectionPoolEngine(String jdbcUrl, String jdbcDriver, String login, String password, int iniPoolSize) throws RemoteException, SQLException {
        super();
        this.jdbcUrl = jdbcUrl;
        this.jdbcDriver = jdbcDriver;
        this.login = login;
        this.password = password;
        this.iniConnectionPoolSize = iniPoolSize;
        createConnectionPool();
		logger.info("DBConnection Pool created!");		
    }

	public void shutdown() throws Throwable {
		//UnicastRemoteObject.unexportObject(this,true);
		finalize();
	}
	
    protected void finalize() throws Throwable {
        closeConnectionPool();
        super.finalize();		
    }
	   
    public synchronized void createConnectionPool() throws RemoteException, SQLException {
        connPool = new LinkedList<DBConnectionEngine>();
        if( iniConnectionPoolSize > 0 ) {
            for( int i = 0; i < iniConnectionPoolSize; i++ ) {
            	DBConnectionEngine conn = new DBConnectionEngine(this, jdbcDriver, jdbcUrl, login, password );
                connPool.addLast( conn );
            }
        }
        notifyAll();
    }
    
    public synchronized void closeConnectionPool() throws RemoteException, SQLException {
        DBConnectionEngine conn;		
        while( connPool.size() > 0 ) {
            conn = (DBConnectionEngine) connPool.removeFirst();
            conn.close();
            conn = null;
        }
		logger.debug(Messages.getString("dbconnectionpool.closed"));		
        notifyAll();
    }

    public synchronized DBConnectionEngine reserveConnection() throws SQLException, RemoteException {
        DBConnectionEngine conn;
        if( connPool.size() > 0 )
            conn = (DBConnectionEngine) connPool.removeFirst();
        else
            conn = new DBConnectionEngine(this, jdbcDriver, jdbcUrl, login, password );
        notifyAll();
        return conn;
    }
    
    public synchronized void disposeConnection(DBConnectionEngine conn) throws RemoteException, SQLException {
        if( !conn.isClosed() ) {
            conn.clear();
            connPool.addFirst( conn );
        }
        notifyAll();
    }
    
}
