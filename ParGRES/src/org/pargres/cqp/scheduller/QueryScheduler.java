/*
 * Created on 08/04/2005
 */
package org.pargres.cqp.scheduller;

import java.rmi.RemoteException;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Set;
import java.util.concurrent.ConcurrentLinkedQueue;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicInteger;

import javax.sql.rowset.RowSetMetaDataImpl;

import org.pargres.commons.logger.Logger;
import org.pargres.commons.translation.Messages;
import org.pargres.cqp.connection.ConnectionManagerImpl;
import org.pargres.cqp.querymanager.AbstractQueryManager;
import org.pargres.cqp.querymanager.SelectQueryManager;
import org.pargres.cqp.querymanager.UpdateQueryManager;

import com.sun.rowset.CachedRowSetImpl;

/**
 * @author Bernardo
 */
public class QueryScheduler implements Runnable {
	private Logger logger = Logger.getLogger(QueryScheduler.class);
	private AtomicInteger queryCounter = new AtomicInteger(0);
	private ConcurrentLinkedQueue<AbstractQueryManager> queue = new ConcurrentLinkedQueue<AbstractQueryManager>();
	private AtomicBoolean executingUpdate = new AtomicBoolean();
	private Set<AbstractQueryManager> executingQueries = new HashSet<AbstractQueryManager>();
	private boolean requestShutdown = false;
	private ConnectionManagerImpl connectionManager;
	private LongTransactionQueue longTransactionQueue = new LongTransactionQueue();
	private Thread thread;
	
	public QueryScheduler(ConnectionManagerImpl connectionManager) {
		this.connectionManager = connectionManager;		
		executingUpdate.set(false);		
		thread = new Thread(this);
		thread.start();
	}
	
	public void shutdown() {
		requestShutdown = true;
		
		try {
			while(thread.isAlive()) {			
				synchronized (this) {
					notifyAll();
				}		
				thread.join(200);				
			}
		} catch (InterruptedException e) {
			System.err.println(e.getMessage());
			e.printStackTrace();
		}
	}
		
	private int pendingQueries() {
		return executingQueries.size();
	}
	
	//** CONCURRENT METHODS **/
	
	public int getNextQueryNumber() {
		synchronized (queryCounter) {
			int i = queryCounter.intValue();
			queryCounter.set(i+1);
			return i;
		}
	}	
	
	public void put(AbstractQueryManager s) {		
		s.setScheduller(this);				
		
		longTransactionQueue.wait(s);
		synchronized (this) {
			queue.add(s);
			logger.debug(Messages.getString("queryScheduler.added",s.getQueryNumber()));
			notifyAll();	
		}		
	}
	
	public synchronized void remove(AbstractQueryManager s) {		
		executingQueries.remove(s);
		if(s.getClass().equals(UpdateQueryManager.class)) {
			connectionManager.invalidMetaData();
			executingUpdate.set(false);
		}
		logger.debug(Messages.getString("queryScheduler.remove",s.getQueryNumber()));			
		
		notifyAll();	
	}	
	
	private void executeNextInQueue() throws Exception {
		AbstractQueryManager s;

		//Update isolation
		while(executingUpdate.get()) {
			logger.debug(Messages.getString("queryScheduler.waitingForUpdateEnd"));
			wait();
		}			
		while((((AbstractQueryManager)queue.peek()).getClass().equals(UpdateQueryManager.class)) && 
				(pendingQueries() > 0)) {
			logger.debug(Messages.getString("queryScheduler.waitingForPending"));
			wait();
		}					  
		s = (AbstractQueryManager)queue.poll();
		executingQueries.add(s);
		if(s.getClass().equals(UpdateQueryManager.class))  
			executingUpdate.set(true);					
		
		logger.debug(Messages.getString("queryScheduler.dispatching",s.getQueryNumber()));
		s.go();				
	}
			
	public void run() {
		while(!requestShutdown) {
			try {
				logger.debug(Messages.getString("queryScheduler.running"));
				synchronized (this) {					
					while(queue.size() != 0) 
						executeNextInQueue();
					
					logger.debug(Messages.getString("queryScheduler.waitingForMore"));
					wait();
				}
			} catch (Exception e) { 
				logger.error(e);
				e.printStackTrace();
			}
		}
	}
	
	//******************/
	
	public ResultSet dump() throws SQLException {
		CachedRowSetImpl rs = new CachedRowSetImpl();
		RowSetMetaDataImpl meta = new RowSetMetaDataImpl();
		meta.setColumnCount(2);
		meta.setColumnName(1,"QUEUE_TYPE");
		meta.setColumnType(1,Types.VARCHAR);
		meta.setColumnName(2,"REQUEST");
		meta.setColumnType(2,Types.VARCHAR);		
		rs.setMetaData(meta);
		
		synchronized (queue) {
			Iterator<AbstractQueryManager> it = queue.iterator();
			while(it.hasNext()) {
				AbstractQueryManager s = (AbstractQueryManager) it.next();
				rs.moveToInsertRow();
				rs.updateString(1,"QUEUE");
				rs.updateString(2,s.getSql());
				rs.insertRow();
				rs.moveToCurrentRow();
			}
			it = executingQueries.iterator();
			while(it.hasNext()) {
				AbstractQueryManager s = (AbstractQueryManager) it.next();
				rs.moveToInsertRow();
				rs.updateString(1,"EXECUTING_QUERIES");
				rs.updateString(2,s.getSql());
				rs.insertRow();
				rs.moveToCurrentRow();
			}	
		}			
		return rs;
	}
	
	public int executeUpdate(AbstractQueryManager s) throws RemoteException, SQLException {
		//Isto e thread-safe?		
		put(s);
		int count = -1;
		try {
			count = ((UpdateQueryManager)s).executeUpdate();
			logger.debug(Messages.getString("queryScheduler.queryExecuted",s.getQueryNumber()));
		} catch (SQLException e) {
			logger.error(Messages.getString("queryScheduler.queryError",new Object[]{s.getQueryNumber(),e.getMessage()}));
			remove(s);
			throw e;
		}
		remove(s);		
		return count;
	}	
	
	public ResultSet executeQuery(AbstractQueryManager s) throws RemoteException, SQLException {
		//Isto e thread-safe?
		put(s);
		ResultSet rs = null;
		try {		
			rs = ((SelectQueryManager)s).executeQuery();
			logger.debug(Messages.getString("queryScheduler.queryExecuted",s.getQueryNumber()));			
		} catch (SQLException e) {
			logger.error(Messages.getString("queryScheduler.queryError",new Object[]{s.getQueryNumber(),e.getMessage()}));
			remove(s);
			throw e;
		}
		remove(s);
		return rs;		
	}

	public void beginTransaction() {
		longTransactionQueue.block();		
	}

	public void endTransaction() {
		longTransactionQueue.unblock();		
	}
}
