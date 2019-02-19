/*
 * GlobalQueryTaskEngine.java
 *
 * Created on 14 novembre 2003, 14:47
 */

package org.pargres.globalquerytask;

/**
 * 
 * @author lima
 */

import java.rmi.RemoteException;
import java.rmi.server.UnicastRemoteObject;
import java.sql.ResultSet;
import java.util.ArrayList;

import org.pargres.commons.logger.Logger;
import org.pargres.commons.translation.Messages;
import org.pargres.cqp.queryplanner.QueryInfo;
import org.pargres.localquerytask.LocalQueryTask;
import org.pargres.nodequeryprocessor.NodeQueryProcessor;
import org.pargres.resultcomposer.ResultComposerGlobal;
import org.pargres.util.LocalQueryTaskStatistics;
import org.pargres.util.Range;
import org.pargres.util.SystemResourceStatistics;


public class GlobalQueryTaskEngine extends UnicastRemoteObject implements
		GlobalQueryTask {

	private static final long serialVersionUID = 3257288045500904500L;
	private Logger logger = Logger.getLogger(GlobalQueryTaskEngine.class);
	private ArrayList<LocalQueryTaskStatistics> localTaskStatistics;
	private ArrayList<SystemResourceStatistics> systemResourceStatistics;
	private int numLocalQueryTasksFinished;
	private int numIntervalsFinished;
	private NodeQueryProcessor localnqp;
	private ArrayList<NodeQueryProcessor> nqps = new ArrayList<NodeQueryProcessor>();
	private String query;
	private Range range;
	private boolean getStatistics;
	private boolean getSystemResourceStatistics;
	private boolean localResultComposition;
	private int queryExecutionStrategy;
	private ArrayList<LocalQueryTask> lqts;
	// For dynamic load balancing
	private boolean performDynLoadBal;
	// for predefined partition sizes
	private int[] predefinedPartitionSizes; // used to simulate skew
	private QueryInfo queryInfo;
	private Exception exception;

	/** Creates a new instance of Task */
	public GlobalQueryTaskEngine(NodeQueryProcessor localnqp,
			ArrayList<NodeQueryProcessor> nqp, String query, Range range,
			boolean getStatistics, boolean localResultComposition,
			int queryExecutionStrategy,
			boolean performDynamicLoadBalancing,
			int[] predefinedPartitionSizes,
			boolean getSystemResourceStatistics, QueryInfo qi) throws RemoteException {
		this.localnqp = localnqp;
		this.nqps = nqp;
		this.query = query;
		this.range = range;
		this.getStatistics = getStatistics;
		this.localResultComposition = localResultComposition;
		this.queryExecutionStrategy = queryExecutionStrategy;
		this.performDynLoadBal = performDynamicLoadBalancing;
		this.predefinedPartitionSizes = predefinedPartitionSizes;
		this.getSystemResourceStatistics = getSystemResourceStatistics;
		this.queryInfo = qi;
	}

	public ResultSet start() throws RemoteException, InterruptedException,
			Exception {
		int numIntervalsLocalTask; // number of intervals in a local query task
		int numLocalTasks;
		int countLocalTasks;
		int begin, end; // Where each interval begins and ends
		int size = 0; // interval's size
		ResultComposerGlobal resultComposer;
		ResultSet result;

		// Create Global ResultComposer
		logger.debug(Messages.getString("globalQueryTaskEngine.createGRC"));

		resultComposer = this.localnqp.newGlobalResultComposer(this.nqps.size(), this.queryInfo);
		resultComposer.start();

		// Start Local Query Tasks
		logger.debug(Messages.getString("globalQueryTaskEngine.createLQTs"));		

		numLocalTasks = this.nqps.size();
		numIntervalsLocalTask = this.range.getNumVPs() / numLocalTasks;
		this.numIntervalsFinished = 0;
		if (this.getStatistics) {
			this.localTaskStatistics = new ArrayList<LocalQueryTaskStatistics>(numLocalTasks);
		} else
			this.localTaskStatistics = null;

		if (this.getSystemResourceStatistics) {
			this.systemResourceStatistics = new ArrayList<SystemResourceStatistics>(numLocalTasks);
		} else
			this.systemResourceStatistics = null;

		if (this.predefinedPartitionSizes == null)
			size = (this.range.getOriginalLastValue() - this.range
					.getFirstValue())
					/ numLocalTasks;

		// Creating Local Query Task objects
		this.lqts = new ArrayList<LocalQueryTask>(numLocalTasks);
		for (countLocalTasks = 0, begin = this.range.getFirstValue(); countLocalTasks < numLocalTasks; countLocalTasks++) {
			//LocalQueryTaskStatistics statistics;

			if (countLocalTasks == numLocalTasks - 1)
				end = this.range.getOriginalLastValue();
			else {
				if (this.predefinedPartitionSizes != null)
					size = this.predefinedPartitionSizes[countLocalTasks];
				end = begin + size;
			}

			logger.debug(Messages.getString("globalQueryTaskEngine.createLQT",new Object[]{countLocalTasks,begin,end}));
			
			LocalQueryTask newLqt = this.nqps.get(countLocalTasks)
					.newLocalQueryTask(countLocalTasks, this, resultComposer,
							this.query, new Range(countLocalTasks, begin, end,
									this.range.getAllArgumentsFirstValue(),
									this.range.getAllArgumentsLastValue(),
									numIntervalsLocalTask, this.range
											.getStatistics()),
							this.queryExecutionStrategy, numLocalTasks,
							this.localResultComposition,
							this.performDynLoadBal, this.getStatistics,
							this.getSystemResourceStatistics, this.queryInfo);
			this.lqts.add(newLqt);
			begin = end;
		}

		// Starting Local Query Tasks threads
		for (countLocalTasks = 0; countLocalTasks < numLocalTasks; countLocalTasks++)
			lqts.get(countLocalTasks).start();

		// Wait for intervals finishing
		logger.debug(Messages.getString("globalQueryTaskEngine.waitingForIntervals"));
		
		// long beginWaitingIntervals = System.currentTimeMillis();
		synchronized (this) {
			while (this.numIntervalsFinished < numLocalTasks && exception == null) {
				wait(100);
			}
		}
		
		if(exception != null)
			throw exception;		
		// System.out.println( "Time waiting for interval processing: " +
		// (System.currentTimeMillis() - beginWaitingIntervals) );

		// All vps were processed.
		// Finish LQTs.
		this.numLocalQueryTasksFinished = 0;

		for(LocalQueryTask lqt : lqts)
			lqt.finish();
			

		// Wait for lqts finishing
		// long beginWaitingLQTs = System.currentTimeMillis();
		logger.debug(Messages.getString("globalQueryTaskEngine.waitingForLQTs"));
		
		synchronized (this) {
			while (this.numLocalQueryTasksFinished < numLocalTasks && exception == null) {
				wait(100);
			}
		}
		if(exception != null)
			throw exception;
		// System.out.println( "Time waiting for LQTs finishing: " +
		// (System.currentTimeMillis() - beginWaitingLQTs) );

		// Local Query Tasks Finished. Return results.
		logger.debug(Messages.getString("globalQueryTaskEngine.getFinalResult"));
		
		resultComposer.finish();

		// long beginGettingResults = System.currentTimeMillis();
		result = resultComposer.getResult();
		// System.out.println("Time to get final result: " +
		// (System.currentTimeMillis() - beginGettingResults) + " ms");

		//result.setStatistics(this.localTaskStatistics,
		//		this.systemResourceStatistics);

		logger.debug(Messages.getString("globalQueryTaskEngine.finished"));
		

		return result;
	}

	public void getLQTReferences(int[] id, LocalQueryTask[] reference)
			throws RemoteException {
		if (id.length != reference.length)
			throw new IllegalArgumentException(
					"GlobalQueryTaskEngine.getLQTReferences(): 'id' and 'reference' arrays must have the same size!");
		for (int i = 0; i < id.length; i++)
			reference[i] = getLQTReference(id[i]);
	}

	public LocalQueryTask getLQTReference(int id) throws RemoteException {
		if ((id >= 0) && id < (this.lqts.size()))
			return this.lqts.get(id);
		else
			return null;
	}

	public synchronized void localQueryTaskFinished(int localTaskId,
			LocalQueryTaskStatistics statistics,
			SystemResourceStatistics resourceStatistics, Exception exception) throws RemoteException {
		this.numLocalQueryTasksFinished++;
		this.exception = exception;
		if (this.localTaskStatistics != null) {
			this.localTaskStatistics.set(localTaskId,statistics);

		}
		if (this.systemResourceStatistics != null) {
			this.systemResourceStatistics.set(localTaskId,resourceStatistics);
		}

		notifyAll();
	}

	public synchronized void localIntervalFinished(int localTaskId)
			throws RemoteException {
		this.numIntervalsFinished++;
		logger.debug(Messages.getString("globalQueryTaskEngine.intervalFinished",localTaskId));
		
		notifyAll();
	}
}
