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
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import org.pargres.commons.logger.Logger;
import org.pargres.commons.translation.Messages;
import org.pargres.commons.util.JdbcUtil;
import org.pargres.jdbc.PargresDatabaseMetaData;
import org.pargres.jdbc.PargresRowSet;
import org.pargres.jdbc.specifics.DatabaseProperties;


public class DBConnectionEngine /*extends UnicastRemoteObject implements
		DBConnection*/ {

	private static final long serialVersionUID = 3616727171272880692L;
	private Logger logger = Logger.getLogger(DBConnectionEngine.class);
	private static Object block = new Object();
	private static int connectionCount = 0;
	private int connectionId;
	private Connection dbConn = null;
	/* prepStat can't be global because of an lack of performance on how PostgreSQL treat 
       preparedStatement */
    //private PreparedStatement prepStat;
    //private String sql;
    //private int[] arguments;
	private DBConnectionPoolEngine dbPool;

	/** Creates a new instance of DBGatewayEngine */
	public DBConnectionEngine(DBConnectionPoolEngine dbPool, String jdbcDriver,
			String dbUrl, String login, String password)
			throws RemoteException, SQLException {
		super();
		this.dbPool = dbPool;
		connectDb(jdbcDriver, dbUrl, login, password);
		synchronized (block) {
			connectionId = connectionCount;
			connectionCount++;
		}
	}

	public Connection getConnection() {
		return dbConn;
	}
	
	protected void finalize() throws Throwable {
		close();
		super.finalize();
	}

	public void disposeConnection() throws RemoteException {
		try {
			dbPool.disposeConnection(this);
		} catch (Exception e) {
			logger.error(e);
			e.printStackTrace();
		}
	}

	private void connectDb(String jdbcDriver, String dbUrl, String login,
			String password) throws SQLException {
		try {
			Class.forName(jdbcDriver);
			this.dbConn = DriverManager.getConnection(dbUrl, login, password);
			//TODO: Ver como fica o autocommit
			this.dbConn.setAutoCommit(false);
			checkAvaibility();
			logger.debug(Messages.getString("dbconnection.newconnection",
					connectionId));
                        Object params[] = {connectionId, dbConn.getAutoCommit()};
                        logger.debug(Messages.getString("dbconnection.connectionAutoCommitStatus",
                                                        params));
		} catch (Exception e) {
			e.printStackTrace();
			logger.error(e);
			throw new SQLException(e.getMessage());
		}
	}

	public void close() throws SQLException, RemoteException {
		logger.debug(Messages.getString("dbconnection.closed", connectionId));
		if (!dbConn.isClosed()) {
			dbConn.close();
		}
		//UnicastRemoteObject.unexportObject(this, true);
	}

/*	public void prepareStatement(String query) throws SQLException,
			RemoteException {
		//prepStat = dbConn.prepareStatement(query);
        sql = query;
        int numberOfArguments = 0;
        int i = 0;
        while (i < sql.lastIndexOf("?")){
            i = sql.indexOf("?", i + 1);
            numberOfArguments++;
        }
        arguments = new int[numberOfArguments + 1];
                
		logger.debug(Messages.getString("dbconnection.prepare",new Object[]{connectionId,query}));
	}
*/
	/*public void setArgumentPreparedStatement(int argumentNumber, int value)
			throws SQLException, RemoteException {
		//prepStat.setInt(argumentNumber, value);
        arguments[argumentNumber] =  value;
	}
*/
	/*public ResultSet executePreparedStatement() throws SQLException,
			RemoteException {
		ResultSet rs;
        
        //PreparedStatement prepStat;
        //prepStat = dbConn.prepareStatement(sql);
		Statement st = dbConn.createStatement();
		String mysql = sql;
        for (int i = 1; i <= arguments.length - 1; ++i)
        	mysql = mysql.replaceFirst("\\?",""+arguments[i]);
            //prepStat.setInt(i, arguments[i]);
        
        
        long begin = System.currentTimeMillis();
        //rs = prepStat.executeQuery();
        rs = st.executeQuery(mysql);
        
        logger.debug(Messages.getString("dbconnection.prepare",new Object[]{connectionId,(System.currentTimeMillis() - begin)}));
        PargresRowSet result = new PargresRowSet();
        result.populate(rs);
        rs.close();
		return result;
	}

	public void closePreparedStetement() throws SQLException, RemoteException {
		//if (prepStat != null) {
		//	prepStat.close();
		//	prepStat = null;
		//}
		//System.out.println("PreparedStatement closed");
	}*/

	public boolean isClosed() throws SQLException, RemoteException {
		return dbConn.isClosed();
	}

	public ResultSet executeQuery(String query) throws SQLException,
			RemoteException {
		//QueryResult result;
		Statement stmt;
		ResultSet rs;

		dbConn.setAutoCommit(true);
		stmt = dbConn.createStatement();		
		try {
			rs = stmt.executeQuery(query);
		} catch (SQLException e) {
			checkAvaibility();			
			logger.error(e);
			throw e;
		}
		logger.debug(Messages.getString("dbconnection.queryexecuted",
				new String[] { connectionId + "", query }));

		PargresRowSet result = new PargresRowSet();
		result.populate(rs);

		rs.close();
		stmt.close();
		return (ResultSet) result;
	}

	private void checkAvaibility() throws DatabaseDisconnectionException {
		
		boolean ok = false;
		try {
			//TODO: CONSULTA TESTE
			String testQuery;
			if(dbConn.getMetaData().getDatabaseProductName().equals("PostgreSQL"))
				testQuery = "SELECT 1";
			else 
				testQuery = "call now()";			
			
			ok = dbConn.createStatement().execute(testQuery); 
		} catch (SQLException e) {
			throw new DatabaseDisconnectionException();
		}
		if(!ok)
			throw new DatabaseDisconnectionException();			
	}

	public void clear() throws SQLException, RemoteException {
		dbConn.clearWarnings();
		dbConn.rollback();
		//System.gc();
	}

	public int executeUpdate(String query) throws SQLException, RemoteException {
		if (query.equals(JdbcUtil.BEGIN_TRANSACTION)) {
			dbConn.setAutoCommit(true);
			return 0;
		} else if (query.equals(JdbcUtil.COMMIT)) {
			dbConn.commit();
			return 0;
		} else if (query.equals(JdbcUtil.ROLLBACK)) {
			dbConn.rollback();
			return 0;
		} else {
			int count = -1;
			try {
				count = dbConn.createStatement().executeUpdate(query);
			} catch (SQLException e) {
				logger.error(e);
				throw e;
			}
			logger.debug(Messages.getString("dbconnection.updateexecuted",
					new String[] { connectionId + "", query }));
			logger.debug(Messages.getString("dbconnection.rowsmodified",
					new String[] { connectionId + "", count + "" }));
			return count;
		}
	}

	public PargresDatabaseMetaData getMetaData(DatabaseProperties prop, DatabaseProperties sort) throws SQLException,
			RemoteException {
		if (dbConn == null) {
			try {
				Thread.sleep(10000);
			} catch (Exception e) {

			}
		}
		if (dbConn == null)
			throw new SQLException("DBConnection not created yet!");
		return new PargresDatabaseMetaData(prop, sort, dbConn.getMetaData());
	}

}
