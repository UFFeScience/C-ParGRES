package org.pargres.cqp.querymanager;

import java.rmi.RemoteException;
import java.sql.SQLException;
import java.util.ArrayList;

import org.pargres.commons.logger.Logger;
import org.pargres.commons.translation.Messages;
import org.pargres.commons.util.PargresException;
import org.pargres.nodequeryprocessor.NodeQueryProcessor;


public class UpdateManager {
	private Logger logger = Logger.getLogger(UpdateManager.class);	
	private ArrayList<NodeQueryProcessor> nodeQueryProcessors;
	private ArrayList<Integer> nodesToDrop;
	private UpdateLogger updateLogger = new UpdateLogger();
	private String sql;

	public UpdateManager(ArrayList<NodeQueryProcessor> nodeQueryProcessors, String sql) {
		this.nodeQueryProcessors = nodeQueryProcessors;
		this.sql = sql;
	}
	
	public int executeUpdate() throws SQLException,RemoteException {
		ArrayList<UpdateWorker> updateWorkers = new ArrayList<UpdateWorker>();
		ArrayList<Thread> threads = new ArrayList<Thread>();
		int clusterSize = nodeQueryProcessors.size();
		
		logger.debug(Messages.getString("updateManager.threadscreated",clusterSize));
		int i = 0;
		for(NodeQueryProcessor nodeQueryProcessor : nodeQueryProcessors) {
			UpdateWorker updateWorker = new UpdateWorker(i,nodeQueryProcessor,sql);
			updateWorkers.add(updateWorker);
			threads.add(new Thread(updateWorker));
			i++;
		}
		
		for(Thread thread : threads) 
			thread.start();
		
		for(Thread thread : threads)
			try {
				thread.join();		
			} catch (Exception e) {
				System.err.println(e);
				e.printStackTrace();
			}
			
		ResultDiff resultDiff = new ResultDiff();
		for(UpdateWorker updateWorker : updateWorkers) 
			resultDiff.add(updateWorker.getNodeQueryProcessor().getNodeId(),updateWorker.getUpdateCount(),updateWorker.getException());
		resultDiff.compare();
		
		nodesToDrop = resultDiff.getNodesToDrop();
		
		if(resultDiff.hasError())
			throw resultDiff.getException();
		else {
			updateLogger.logUpdate(sql);
			return resultDiff.getUpdateCount();			
		}				
	}

	class UpdateWorker implements Runnable {
		private NodeQueryProcessor nodeQueryProcessor;
		private String sql;		
		private int updateCount = - 1;
		private SQLException exception = null;
		private int nodeId;
		
		public UpdateWorker(int nodeId, NodeQueryProcessor nodeQueryProcessor, String sql) {
			this.nodeQueryProcessor = nodeQueryProcessor;
			this.sql = sql;
			this.nodeId = nodeId;
		}
		
		public int getUpdateCount() {
			return updateCount;
		}
		
		public SQLException getException() {
			return exception;
		}		
		
		public void run() {
			try {
				updateCount = nodeQueryProcessor.executeUpdate(sql);				
			} catch (SQLException e) {
				exception = e;
				logger.error(Messages.getString("updateManager.errorOnNode",nodeId));
				logger.error(Messages.getString("updateManager.workerexception",e.getMessage()));
			//	e.printStackTrace();				
			} catch (RemoteException e) {
				logger.error(Messages.getString("updateManager.errorOnNode",nodeId));
				exception = new PargresException("Communication exception!");
				logger.error(Messages.getString("updateManager.workerexception",e.getMessage()));
			//	e.printStackTrace();
			}
		}

		public NodeQueryProcessor getNodeQueryProcessor() {
			return nodeQueryProcessor;
		}
	}
	
	class UpdateResult {
		private Exception e = null;
		private int updateCount = -1;
		
		public UpdateResult(Exception e) {
			this.e = e;
		}
		
		public UpdateResult(int updateCount) {
			this.updateCount = updateCount;
		}		
		
		public boolean isException() {
			return e != null;
		}

		@Override
		public boolean equals(Object arg0) {
			if(!arg0.getClass().equals(UpdateResult.class))
				return false;
			UpdateResult ur = (UpdateResult) arg0;
			return ur.e.equals(e) && (ur.updateCount == updateCount);
		}

		public Exception getException() {
			return e;
		}

		public int getUpdateCount() {
			return updateCount;
		}	
		
	}

	public ArrayList<Integer> getNodesToDrop() {
		return nodesToDrop;
	}
}
