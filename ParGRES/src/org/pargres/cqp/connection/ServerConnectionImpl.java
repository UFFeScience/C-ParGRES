/*
 * Created on 08/04/2005
 */
package org.pargres.cqp.connection;

import java.rmi.RemoteException;
import java.sql.ResultSet;
import java.sql.SQLException;

import org.pargres.commons.logger.Logger;
import org.pargres.commons.translation.Messages;
import org.pargres.commons.util.JdbcUtil;
import org.pargres.commons.util.PargresException;
import org.pargres.cqp.ClusterQueryProcessorEngine;
import org.pargres.cqp.loadbalancer.LprfLoadBalancer;
import org.pargres.cqp.querymanager.SelectQueryManager;
import org.pargres.cqp.querymanager.UpdateQueryManager;
import org.pargres.cqp.scheduller.QueryScheduler;
import org.pargres.jdbc.PargresDatabaseMetaData;


/**
 * @author Bernardo
 */
public class ServerConnectionImpl {
	/**
	 * 
	 */
	private static final long serialVersionUID = 3258408439326781744L;
	public static final String ADD_VP = "ADD VP";
	public static final String DROP_VP = "DROP VP";
	public static final String GET_VP_LIST = "GET VP LIST";
	public static final String GET_NODE_LIST = "GET NODE LIST";
	public static final String DROP_NODE = "DROP NODE";
	public static final String ADD_NODE = "ADD NODE";
	
	private Logger logger = Logger.getLogger(ServerConnectionImpl.class);
	
	private ConnectionManagerImpl connectionManager;
	private QueryScheduler queryScheduler;
	private ClusterQueryProcessorEngine clusterQueryProcessorEngine;
	private LprfLoadBalancer loadBalancer;
	private boolean autoCommit = false;

    /**
     * 
     */
    public ServerConnectionImpl(ConnectionManagerImpl connectionManager, ClusterQueryProcessorEngine clusterQueryProcessorEngine, QueryScheduler queryScheduler, LprfLoadBalancer loadBalancer) throws RemoteException {
		this.connectionManager = connectionManager;
    	this.clusterQueryProcessorEngine = clusterQueryProcessorEngine;
    	this.queryScheduler = queryScheduler;
		this.loadBalancer = loadBalancer;		
		logger.info(Messages.getString("serverconnection.newconnection"));
    }
	
	public ResultSet executeQuery(String sql) throws RemoteException,SQLException {
		if(sql.startsWith(GET_VP_LIST))
			return connectionManager.listVirtualPartitionedTable();
		else if(sql.startsWith(GET_NODE_LIST))
			return connectionManager.getNodesList();
			
		if(sql.toUpperCase().trim().equals("SELECT DUMP"))
			return queryScheduler.dump();
		ResultSet rs = null;	
		
		SelectQueryManager qm = new SelectQueryManager(sql,connectionManager.getMetaData(),queryScheduler.getNextQueryNumber(),clusterQueryProcessorEngine,loadBalancer); 		
		rs = queryScheduler.executeQuery(qm);				
	
		return rs;
	}
	
	public int executeUpdate(String sql) throws RemoteException,SQLException {
		if(sql.startsWith(ADD_VP)) {
			String[] params = sql.substring(ADD_VP.length()+1).split(" ");
			connectionManager.addVirtualPartitionedTable(params[0],params[1]);
			return 0;
		} else if(sql.startsWith(DROP_VP)) {
			connectionManager.dropVirtualPartitionedTable(sql.substring(DROP_VP.length()+1));
			return 0;						
		} else if(sql.startsWith(ADD_NODE)) {
			String[] params = sql.substring(ADD_NODE.length()+1).split(" ");
			connectionManager.addNode(params[0],Integer.parseInt(params[1]));
			return 0;			
		} else if(sql.startsWith(DROP_NODE)) {
			connectionManager.dropNode(Integer.parseInt(sql.substring(DROP_NODE.length()+1)));
			return 0;			
		}			
		
		UpdateQueryManager qm = new UpdateQueryManager(sql,queryScheduler.getNextQueryNumber(),clusterQueryProcessorEngine);				
		int count = queryScheduler.executeUpdate(qm);
								
		return count;
	}	
	
	public PargresDatabaseMetaData getMetaData() throws RemoteException,PargresException {
		return connectionManager.getMetaData();
	}

	public void setAutoCommit(boolean autoCommit) throws SQLException, RemoteException {		
		if(this.autoCommit && !autoCommit)
			commit();
		this.autoCommit = autoCommit;		
		
		queryScheduler.beginTransaction();		
				
		if(!autoCommit)
			executeUpdate(JdbcUtil.BEGIN_TRANSACTION);					
	}
	
	public void commit() throws SQLException, RemoteException {
		executeUpdate(JdbcUtil.COMMIT);
		queryScheduler.endTransaction();		
	}
	public void rollback() throws SQLException, RemoteException {
		executeUpdate(JdbcUtil.ROLLBACK);		
		queryScheduler.endTransaction();
	}
	
	public void close() throws SQLException, RemoteException {
		if(connectionManager != null)
			connectionManager.notifyClosedConnection(this);			
		connectionManager = null;		
		queryScheduler = null;
		clusterQueryProcessorEngine = null;
		loadBalancer = null;
		//UnicastRemoteObject.unexportObject(this,true);		
	}

	public boolean getAutoCommit() throws SQLException, RemoteException {
		return autoCommit;
	}
}
