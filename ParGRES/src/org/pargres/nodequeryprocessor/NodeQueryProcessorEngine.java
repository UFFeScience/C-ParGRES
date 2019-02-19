/*
 * OlapClusterServerEngine.java
 *
 * Created on 15 decembre 2003, 17:35
 */

package org.pargres.nodequeryprocessor;

/**
 * 
 * @author lima
 */

import java.io.IOException;
import java.net.MalformedURLException;
import java.rmi.NotBoundException;
import java.rmi.RemoteException;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;

import org.pargres.commons.logger.Logger;
import org.pargres.commons.translation.Messages;
import org.pargres.commons.util.PargresException;
import org.pargres.connection.DBConnectionEngine;
import org.pargres.connection.DBConnectionPoolEngine;
import org.pargres.cqp.queryplanner.QueryInfo;
import org.pargres.globalquerytask.GlobalQueryTask;
import org.pargres.globalquerytask.GlobalQueryTaskEngine;
import org.pargres.jdbc.PargresDatabaseMetaData;
import org.pargres.jdbc.specifics.DatabaseProperties;
import org.pargres.localquerytask.LocalQueryTask;
import org.pargres.localquerytask.LocalQueryTaskEngine;
import org.pargres.resultcomposer.ResultComposerEngineGlobal;
import org.pargres.resultcomposer.ResultComposerGlobal;
import org.pargres.util.MyRMIRegistry;
import org.pargres.util.Range;
import org.pargres.util.SystemResourceStatistics;
import org.pargres.util.SystemResourcesMonitor;


public class NodeQueryProcessorEngine implements
		NodeQueryProcessor {

//	private static final long serialVersionUID = 3257288049812322103L;
	private boolean started = false;
	private Logger logger = Logger
			.getLogger(NodeQueryProcessorEngine.class);
	private String objectName;
//	private boolean shutdownRequested;
	private DBConnectionPoolEngine localDbPool;
	private boolean quotedDateIntervals;
	private SystemResourcesMonitor monitor;
	private int port;
    //private static NodeQueryProcessor nqpDummy;

	/** Creates a new instance of OlapClusterServerEngine */
	public NodeQueryProcessorEngine(int port, String jdbcDriver,
			String jdbcUrl, String jdbcLogin, String jdbcPassword,
			boolean quotedDateIntervals) throws RemoteException, SQLException {
		super();
		this.port = port;

		//this.shutdownRequested = false;
		this.localDbPool = new DBConnectionPoolEngine(jdbcUrl, jdbcDriver,
				jdbcLogin, jdbcPassword, 1);
		this.quotedDateIntervals = quotedDateIntervals;
		this.monitor = null;
		this.started = true;
		
        objectName = "//localhost:" + port + "/NodeQueryProcessor";
		try {
			//this.turnSystemMonitorOn();

			MyRMIRegistry.bind(port, objectName, this);
			//nqpDummy = (NodeQueryProcessor) 
            MyRMIRegistry.lookup("localhost",port,objectName);

		} catch (Exception e) {
			logger.error("NodeQueryProcessorEngine Exception: "
					+ e.getMessage());
			e.printStackTrace();
		} 		
		logger.info(Messages.getString("nodeQueryProcessorEngine.running",new Object[]{port,objectName}));		
	}

	protected void finalize() throws Throwable {
		turnSystemMonitorOff();
		((DBConnectionPoolEngine) localDbPool).shutdown();
	}
	
	/**
	 * @param args
	 *            the command line arguments
	 */
	public static void main(String[] args) {
		int portNumber;
		String jdbcDriverName, jdbcURL, dbLogin, dbPwd;
		boolean quotedDateIntervals;
		//SystemResourcesMonitor monitor = null;

		if (args.length != 6) {
			System.out
					.println("usage: java dbcluster.NodeQueryProcessorEngine port_number JDBC_driver_class_name  dburl dblogin dbpassword quotedDateInterval[0|1]");
			return;
		}
		portNumber = (new Integer(args[0])).intValue();
		jdbcDriverName = args[1];
		jdbcURL = args[2];
		dbLogin = args[3];
		dbPwd = args[4];
		if (Integer.parseInt(args[5]) == 0)
			quotedDateIntervals = false;
		else
			quotedDateIntervals = true;

		try {
			new NodeQueryProcessorEngine(
					portNumber, jdbcDriverName, jdbcURL, dbLogin, dbPwd,
					quotedDateIntervals);
		} catch (Exception e) {
			//logger.error(e);
			System.err.println(e);
			e.printStackTrace();
		}
	}

	public GlobalQueryTask newGlobalQueryTask(NodeQueryProcessor localnqp,
			ArrayList<NodeQueryProcessor> nqp, String query, Range range,
			int[] partitionSizes, boolean getStatistics,
			boolean localResultComposition, 
			int queryExecutionStrategy, boolean performDynamicLoadBalancing,
			boolean getSystemResourceStatistics, QueryInfo qi) throws RemoteException {
		GlobalQueryTask globalTask = new GlobalQueryTaskEngine(localnqp, nqp,
				query, range, getStatistics, localResultComposition,
				queryExecutionStrategy,
				performDynamicLoadBalancing, partitionSizes,
				getSystemResourceStatistics, qi);
		return globalTask;
	}

	public LocalQueryTask newLocalQueryTask(int id, GlobalQueryTask globalTask,
			ResultComposerGlobal globalResultComposer, String query,
			Range range, int queryExecutionStrategy, int numlqts,
			boolean localResultComposition,
			boolean performDynamicLoadBalancing, boolean getStatistics,
			boolean getSystemResourceStatistics, QueryInfo qi) throws RemoteException {
		LocalQueryTask localTask = new LocalQueryTaskEngine(id, globalTask,
				getDBConnectionPool(), globalResultComposer, query, range,
				queryExecutionStrategy, numlqts, localResultComposition,
				performDynamicLoadBalancing, getStatistics,
				(getSystemResourceStatistics ? monitor : null), qi);
		return localTask;
	}

	public ResultComposerGlobal newGlobalResultComposer(int numlqts, QueryInfo qi) throws RemoteException, SQLException {
		ResultComposerGlobal rc = new ResultComposerEngineGlobal(numlqts, qi);
		return rc;
	}

	public synchronized void shutdown() throws RemoteException,
			NotBoundException, MalformedURLException {
		logger.debug(Messages.getString("nodeQueryProcessorEngine.unbinding"));
		MyRMIRegistry.unbind(port,objectName,this);
		try {			
			finalize();
		} catch (Throwable t) {
			t.printStackTrace();
			logger.error(t);
		}
	}

	public DBConnectionPoolEngine getDBConnectionPool() throws RemoteException {
		return localDbPool;
	}

	public boolean quotedDateIntervals() throws RemoteException {
		return quotedDateIntervals;
	}

	public void turnSystemMonitorOn() throws IOException, RemoteException {
		if (monitor == null) {
			monitor = new SystemResourcesMonitor();
			monitor.start();
		}
	}

	public void turnSystemMonitorOff() throws RemoteException {
		if (monitor != null) {
			monitor.finish();
			monitor = null;
		}
	}

	public void resetSystemMonitorCounters() throws RemoteException {
		if (monitor != null)
			monitor.resetCounters();
	}

	public SystemResourceStatistics getSystemResourceStatistics()
			throws RemoteException {
		if (monitor != null)
			return monitor.getStatistics();
		else
			throw new RuntimeException(
					"NodeQueryProcessorEngine Exception: monitor was off but the number of misses was demanded");
	}

	/**
	 * @return Returns the started.
	 */
	public boolean isStarted() {
		return started;
	}

	public PargresDatabaseMetaData getDatabaseMetaData(DatabaseProperties prop, DatabaseProperties sort) throws RemoteException,PargresException {
		DBConnectionEngine con = null;
		PargresDatabaseMetaData meta = null;
		try {
			con = localDbPool.reserveConnection();
			meta = con.getMetaData(prop, sort);
			localDbPool.disposeConnection(con);
		} catch (SQLException e) {
			throw new PargresException(e.getMessage());
		}
		return meta;
	}
	
	public ResultSet executeQuery(String sql) throws RemoteException, SQLException {		
		DBConnectionEngine con = localDbPool.reserveConnection();
		ResultSet resultSet = con.executeQuery(sql);
		localDbPool.disposeConnection(con);
		return resultSet;
	}
	
	public int executeUpdate(String sql) throws RemoteException, SQLException {		
		DBConnectionEngine con = localDbPool.reserveConnection();
		int count = con.executeUpdate(sql);
		localDbPool.disposeConnection(con);
		return count;
	}
	
	public int getNodeId() throws RemoteException {
		return this.hashCode();
	}
}
