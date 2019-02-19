/*
 * QueryProcessor.java
 *
 * Created on 17 novembre 2003, 15:50
 */

package org.pargres.cqp;

/**
 * 
 * @author lima
 */

import java.io.FileNotFoundException;
import java.io.IOException;
import java.net.MalformedURLException;
import java.rmi.NotBoundException;
import java.rmi.Remote;
import java.rmi.RemoteException;
import java.sql.ResultSet;

import org.pargres.commons.util.PargresException;
import org.pargres.cqp.queryplanner.QueryInfo;
import org.pargres.nodequeryprocessor.NodeQueryProcessor;
import org.pargres.util.Range;
import org.pargres.util.SystemResourceStatistics;


public interface ClusterQueryProcessor extends Remote {
    public String getObjectName() throws RemoteException;

    public void start(String configFileName) throws InterruptedException,
            IllegalArgumentException, FileNotFoundException, IOException,
            IndexOutOfBoundsException, NotBoundException,
            MalformedURLException, RemoteException, PargresException;

    public ResultSet executeQueryWithAVP(String query, Range range,
            int numNQPs, int[] partitionSizes, boolean getStatistics,
            boolean localResultComposition,
            boolean performDynamicLoadBalancing,
            boolean getSystemResourceStatistics, QueryInfo qi)
            throws IllegalStateException, RemoteException,
            InterruptedException, IllegalArgumentException, Exception;

    public ResultSet executeQueryWithFGVP(String query, Range range,
            int numNQPs, int[] partitionSizes, boolean getStatistics,
            boolean localResultComposition,
            boolean performDynamicLoadBalancing,
            boolean getSystemResourceStatistics) throws IllegalStateException,
            RemoteException, InterruptedException, IllegalArgumentException,
            Exception;

    public SystemResourceStatistics[] getGlobalSystemResourceStatistics()
            throws RemoteException;

    public void shutdown() throws RemoteException, NotBoundException,
            MalformedURLException;

    public boolean quotedDateIntervals() throws RemoteException;

    public void setClusterSize(int size) throws RemoteException;

    public int getClusterSize() throws RemoteException;

    public NodeQueryProcessor getNQP(int i) throws RemoteException;

    public void addNode(String host, int port) throws PargresException,
            RemoteException;

    public void dropNode(int nodeId) throws RemoteException;

    public String getNodesList() throws RemoteException;
}
