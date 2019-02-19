/*
 * ResultComposer.java
 *
 * Created on 17 decembre 2003, 11:32
 */

package org.pargres.resultcomposer;

/**
 *
 * @author  lima
 */

import java.rmi.RemoteException;
import java.rmi.server.UnicastRemoteObject;
import java.sql.ResultSet;
import java.sql.SQLException;

import org.pargres.cqp.queryplanner.QueryInfo;
import org.pargres.grouper.Grouper;
import org.pargres.grouper.GrouperImpl;
import org.pargres.grouper.ResultSetQueue;
import org.pargres.grouper.ResultSetQueueImpl;
import org.pargres.grouper.SortedResultSetQueue;


abstract public class ResultComposerEngine extends UnicastRemoteObject
		implements ResultComposer, Runnable {
    
	protected ResultSetQueue resultQueue;
	protected boolean finishingRequested;
	private boolean finished;
	protected Grouper grouper;
    protected boolean distributedComposition;
    protected boolean distributedSort;
    protected int id;
    private QueryInfo qi;
    

	/** Creates a new instance of ResultComposer */
	public ResultComposerEngine(double id, QueryInfo qi, int numlqts, double grouperId, boolean distributedSort) throws RemoteException, SQLException {
		if (!distributedSort)
		    this.resultQueue = new ResultSetQueueImpl();
        else
            this.resultQueue = new SortedResultSetQueue();

        this.grouper = new GrouperImpl(qi, numlqts, grouperId);
		this.finishingRequested = false;
		this.finished = false;
        this.distributedComposition = qi.isDistributedComposition();
        this.distributedSort = distributedSort;
        this.qi = qi;
	}

	// To be implemented by subclasses.
	public abstract void run();

	public void start() throws RemoteException {
		Thread t = new Thread(this);
		t.start();
	}

	public synchronized void addResult(ResultSet q) throws RemoteException {
		resultQueue.push(id, q);
		notifyAll();
	}

	public synchronized void finish() throws RemoteException {
		finishingRequested = true;
		notifyAll();
	}

	protected synchronized void acceptResults() throws InterruptedException {
		// keep processing while there is no order to stop or while there are results to be processed
        if (qi.isDistributedSort()){
            while (!finishingRequested)
                wait();
        }    
        while (!finishingRequested || !resultQueue.isEmpty()) {
			if (resultQueue.isEmpty()) {
				wait();
			} else {
				ResultSet result = resultQueue.pop();
				grouper.insert(result);
			}
		}
		notifyAll();
	}

	protected synchronized void setFinished() {
		finished = true;
		notifyAll();
	}

	public boolean finished() throws RemoteException {
		return finished;
	}
}
