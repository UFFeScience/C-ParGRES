/*
 * Task.java
 *
 * Created on 14 novembre 2003, 14:47
 */

package org.pargres.globalquerytask;

/**
 * 
 * @author lima
 */

import java.rmi.Remote;
import java.rmi.RemoteException;
import java.sql.ResultSet;

import org.pargres.localquerytask.LocalQueryTask;
import org.pargres.util.LocalQueryTaskStatistics;
import org.pargres.util.SystemResourceStatistics;


public interface GlobalQueryTask extends Remote {
    static public final int QE_STRATEGY_FGVP = 0;

    static public final int QE_STRATEGY_AVP = 1;

    public ResultSet start() throws RemoteException, InterruptedException,
            Exception;

    public void localIntervalFinished(int localTaskId) throws RemoteException;

    public void localQueryTaskFinished(int localTaskId,
            LocalQueryTaskStatistics statistics,
            SystemResourceStatistics resourceStatistics, Exception exception) throws RemoteException;

    public void getLQTReferences(int[] id, LocalQueryTask[] reference)
            throws RemoteException;

    public LocalQueryTask getLQTReference(int id) throws RemoteException;
}
