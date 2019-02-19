/*
 * Created on 08/04/2005
 */
package org.pargres.cqp.connection;

import java.rmi.RemoteException;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.HashMap;
import java.util.Random;

import javax.sql.rowset.RowSetMetaDataImpl;

import org.pargres.commons.interfaces.ConnectionManager;
import org.pargres.commons.logger.Logger;
import org.pargres.commons.translation.Messages;
import org.pargres.commons.util.PargresAuthenticationException;
import org.pargres.commons.util.PargresException;
import org.pargres.configurator.Configurator;
import org.pargres.cqp.ClusterQueryProcessorEngine;
import org.pargres.cqp.UserManager;
import org.pargres.cqp.loadbalancer.LprfLoadBalancer;
import org.pargres.cqp.scheduller.QueryScheduler;
import org.pargres.jdbc.PargresDatabaseMetaData;
import org.pargres.jdbc.PargresRowSet;
import org.pargres.jdbc.specifics.DatabaseProperties;
import org.pargres.nodequeryprocessor.NodeQueryProcessor;
import org.pargres.util.MyRMIRegistry;


/**
 * @author Bernardo
 */
public class ConnectionManagerImpl implements ConnectionManager {
	/**
	 * 
	 */
	private static final long serialVersionUID = 4051324561100124982L;
	private Logger logger = Logger.getLogger(ConnectionManagerImpl.class);
	private ClusterQueryProcessorEngine clusterQueryProcessorEngine;
	private QueryScheduler queryScheduler;
	private LprfLoadBalancer loadBalancer;
	private int port;
	private PargresDatabaseMetaData meta;	
	private HashMap<Integer,ServerConnectionImpl> opennedConnections = new HashMap<Integer,ServerConnectionImpl>();
	private UserManager userManager;
	private DatabaseProperties databaseProperties;
    private DatabaseProperties sortProperties;
	private Random keyGen = new Random(System.currentTimeMillis());
	
    public ConnectionManagerImpl(int port, String configFileName) throws RemoteException {
    	try {
    		this.clusterQueryProcessorEngine = new ClusterQueryProcessorEngine();
    		Configurator configurator = new Configurator(configFileName,this);
	    	logger.info(Messages.getString("connectionManagerImpl.init"));
	    	loadBalancer = new LprfLoadBalancer(0);	    	
	     	configurator.config();
	    	userManager = configurator.getUserManager();
	    	databaseProperties = configurator.getDatabaseProperties();
            sortProperties = configurator.getSortProperties();
	    	
	    	logger.info(Messages.getString("connectionManagerImpl.step1"));
    		//RMISocketFactory
			this.port = port;
    		queryScheduler = new QueryScheduler(this);
    		logger.info(Messages.getString("connectionManagerImpl.step2"));
			logger.info(Messages.getString("connectionManagerImpl.step3"));

			reloadMetaData();
			if(meta == null)
				throw new Exception("PargresDatabaseMetaData not loaded!");
			logger.info(Messages.getString("connectionManagerImpl.step4"));
			meta.dump();
    		register();
    		logger.info(Messages.getString("connectionManagerImpl.pargresReady"));	
        } catch (Exception e) {
			e.printStackTrace();
        } 
    }
    /* (non-Javadoc)
     * @see org.pargres.cqp.ConnectionManager#createConnection()
     */    
    public int createConnection(String user, String password) throws PargresAuthenticationException,RemoteException {
    	userManager.verify(user,password);
    	ServerConnectionImpl serverConnection = new ServerConnectionImpl(this,clusterQueryProcessorEngine,queryScheduler,loadBalancer);
    	Integer key = new Integer(keyGen.nextInt());    	
    	opennedConnections.put(key,serverConnection);    	    	
    	return key;
    }
    
    public void notifyClosedConnection(ServerConnectionImpl serverConnection) {
    	opennedConnections.remove(serverConnection);
    }
    
	public void invalidMetaData() {
		meta = null;
	}    
	
	public PargresDatabaseMetaData getMetaData() throws PargresException, RemoteException {
		if(meta == null)
			reloadMetaData();
		return meta;
	}
	
	public synchronized void reloadMetaData() throws PargresException, RemoteException {
			logger.info(Messages.getString("connectionManagerImpl.metadataReloading"));
			NodeQueryProcessor nqp = clusterQueryProcessorEngine.getNQP(0);
			meta = nqp.getDatabaseMetaData(databaseProperties, sortProperties);
			logger.info(Messages.getString("connectionManagerImpl.metadataReloaded"));
	}	

    private void register() throws PargresException {
        try {
			//A comunicação via RMI é quase tão rápida quanto via socket
			//http://martin.nobilitas.com/java/thruput.html			
	    	MyRMIRegistry.bind(port,getRmiAddress(),this);
			logger.info(Messages.getString("connectionManagerImpl.register",new Object[]{port,getRmiAddress()}));
        } catch (Exception e) {
			e.printStackTrace();
            throw new PargresException(e.getMessage());
        } 
	}
	
	private String getRmiAddress() {
		return "//localhost:"+port+"/"+ConnectionManager.OBJECT_NAME;
	}
	
    private void unregister() throws PargresException {
        try {
			MyRMIRegistry.unbind(port,getRmiAddress(),this);
        } catch (Exception e) {
			e.printStackTrace();
            throw new PargresException(e.getMessage());
        }
    }	
	/* (non-Javadoc)
	 * @see java.lang.Object#finalize()
	 */
	protected void finalize() throws Throwable {
		logger.debug(Messages.getString("connectionManagerImpl.finalize"));
	}
	
	public void destroy() throws PargresException {
		queryScheduler.shutdown();
		try {
			clusterQueryProcessorEngine.shutdown();
			clusterQueryProcessorEngine = null;			
		} catch (Throwable e) {
			e.printStackTrace();
            throw new PargresException(e.getMessage());
		}
		Object[] array = opennedConnections.values().toArray();
		for(int i = 0; i < array.length; i++) {
			try {
				((ServerConnectionImpl)array[i]).close();
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
		unregister();
	}
	
    public static void main(String[] args) {
        int portNumber;
        String configFileName;

        if (args.length < 2) {
            System.out
                    .println("usage: java ConnectionManagerImpl "
                            + "query_processor_port_number ConfigFileName");
            return;
        }

        portNumber = Integer.parseInt(args[0]);
        configFileName = args[1].trim();

        try {
        	new ConnectionManagerImpl(
                    portNumber,configFileName);
        } catch (Exception e) {
            System.err.println(e);
            e.printStackTrace();
        }
    }
	
	public boolean forceNewPartitionLimits(String table, String field, long first, long last) throws RemoteException {
		return meta.forceNewPartitionLimits(table,field,first,last);
	}	
	
	public ResultSet executeQuery(int connectionId, String sql) throws RemoteException,SQLException {
		return opennedConnections.get(connectionId).executeQuery(sql);
	}
	
	public int executeUpdate(int connectionId, String sql) throws RemoteException,SQLException {
		return opennedConnections.get(connectionId).executeUpdate(sql);
	}	
	
	public PargresDatabaseMetaData getMetaData(int connectionId) throws RemoteException,PargresException {
		return opennedConnections.get(connectionId).getMetaData();
	}

	public void setAutoCommit(int connectionId, boolean autoCommit) throws SQLException, RemoteException {		
		opennedConnections.get(connectionId).setAutoCommit(autoCommit);				
	}
	
	public void commit(int connectionId) throws SQLException, RemoteException {
		opennedConnections.get(connectionId).commit();		
	}
	public void rollback(int connectionId) throws SQLException, RemoteException {
		opennedConnections.get(connectionId).rollback();
	}
	
	public void close(int connectionId) throws SQLException, RemoteException {
		opennedConnections.get(connectionId).close();
		//UnicastRemoteObject.unexportObject(this,true);		
	}

	public boolean getAutoCommit(int connectionId) throws SQLException, RemoteException {
		return opennedConnections.get(connectionId).getAutoCommit();
	}

	public ResultSet getNodesList() throws SQLException, RemoteException {
		return clusterQueryProcessorEngine.getNodesList();
	}
	
	public void addVirtualPartitionedTable(String table, String field) throws PargresException, RemoteException {
		databaseProperties.addProperties(table,field);
		try {			
			reloadMetaData();
		} catch (PargresException e) {
			databaseProperties.remove(table);
			throw e;
		}
	}
	
	public boolean dropVirtualPartitionedTable(String table) throws PargresException, RemoteException {
		boolean ok = databaseProperties.remove(table);
		if(ok)
			reloadMetaData();
		return ok;
	}	
	
	public void addNode(String host, int port) throws PargresException, RemoteException {
		clusterQueryProcessorEngine.addNode(host,port);
		loadBalancer.addNode();
	}
	public void dropNode(int nodeId) throws PargresException, RemoteException {
		clusterQueryProcessorEngine.dropNode(nodeId);		
		loadBalancer.dropNode(nodeId);
	}	
	
	public ResultSet listVirtualPartitionedTable() throws SQLException, RemoteException {
		int i = 0;		
		PargresRowSet rs = new PargresRowSet();
		
		RowSetMetaDataImpl meta = new RowSetMetaDataImpl();
		meta.setColumnCount(1);
		meta.setColumnName(1, "DUMMY");
		meta.setColumnType(1, Types.VARCHAR);
		rs.setMetaData(meta);

		for(org.pargres.commons.Range range : getMetaData().getRangeList()) {
			String list = i+" - "+(String)range.getTableName()+"\t: "+(String)range.getField()+
			       "\t[cardinality = "+range.getCardinality()+", " +
			       "range init = "+range.getRangeInit()+", " +
			       "range end = "+range.getRangeEnd()+"]\n";
			i++;
			rs.moveToInsertRow();
			rs.updateString(1, list);
			rs.insertRow();
			rs.moveToCurrentRow();			
		}
		return rs;
	}	
}
