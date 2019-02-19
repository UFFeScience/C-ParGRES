/*
 * OlapClusterServer.java
 *
 * Created on 15 decembre 2003, 17:27
 */

package org.pargres.nodequeryprocessor;

/**
 * 
 * @author lima
 */

import java.io.IOException;
import java.net.MalformedURLException;
import java.rmi.NotBoundException;
import java.rmi.Remote;
import java.rmi.RemoteException;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;

import org.pargres.commons.util.PargresException;
import org.pargres.cqp.queryplanner.QueryInfo;
import org.pargres.globalquerytask.GlobalQueryTask;
import org.pargres.jdbc.PargresDatabaseMetaData;
import org.pargres.jdbc.specifics.DatabaseProperties;
import org.pargres.localquerytask.LocalQueryTask;
import org.pargres.resultcomposer.ResultComposerGlobal;
import org.pargres.util.Range;
import org.pargres.util.SystemResourceStatistics;


public interface NodeQueryProcessor extends Remote {

	public GlobalQueryTask newGlobalQueryTask(NodeQueryProcessor localnqp,
			ArrayList<NodeQueryProcessor> nqp, String query, Range range,
			int[] partitionSizes, boolean getStatistics,
			boolean localResultComposition, 
			int queryExecutionStrategy, boolean performDynamicLoadBalancing,
			boolean getSystemResourceStatistics, QueryInfo qi) throws RemoteException;

	public LocalQueryTask newLocalQueryTask(int id, GlobalQueryTask globalTask,
			ResultComposerGlobal globalResultComposer, String query,
			Range range, int queryExecutionStrategy, int numlqts,
			boolean localResultComposition,
			boolean performDynamicLoadBalancing, boolean getStatistics,
			boolean getSystemResourceStatistics, QueryInfo qi) throws RemoteException;

	public ResultComposerGlobal newGlobalResultComposer(int numlqts, QueryInfo qi) throws RemoteException, SQLException;

	public void turnSystemMonitorOn() throws IOException, RemoteException;

	public void turnSystemMonitorOff() throws RemoteException;

	public void resetSystemMonitorCounters() throws RemoteException;

	public SystemResourceStatistics getSystemResourceStatistics()
			throws RemoteException;

	public boolean quotedDateIntervals() throws RemoteException;

	public void shutdown() throws RemoteException, NotBoundException,
			MalformedURLException;

	public PargresDatabaseMetaData getDatabaseMetaData(DatabaseProperties prop, DatabaseProperties sort) throws RemoteException, PargresException;
	public ResultSet executeQuery(String sql) throws RemoteException, SQLException;
	public int executeUpdate(String sql) throws RemoteException, SQLException;

	public int getNodeId() throws RemoteException;
}
