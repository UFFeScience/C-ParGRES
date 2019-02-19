/*
 * ClusterQueryProcessorEngine.java
 *
 * Created on 17 novembre 2003, 16:11
 */

package org.pargres.cqp;

/**
 * 
 * @author lima
 */

import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.net.MalformedURLException;
import java.rmi.Naming;
import java.rmi.NotBoundException;
import java.rmi.RemoteException;
import java.rmi.registry.LocateRegistry;
import java.rmi.server.UnicastRemoteObject;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.LinkedList;

import org.pargres.commons.util.PargresException;
import org.pargres.cqp.queryplanner.QueryInfo;
import org.pargres.globalquerytask.GlobalQueryTask;
import org.pargres.nodequeryprocessor.NqpAllocator;
import org.pargres.nodequeryprocessor.NodeQueryProcessor;
import org.pargres.util.MyRMIRegistry;
import org.pargres.util.Node;
import org.pargres.util.Range;
import org.pargres.util.SystemResourceStatistics;


public class CQP_Scheduler_Engine extends UnicastRemoteObject implements
        ClusterQueryProcessor {

    private static final long serialVersionUID = 3258408434998194487L;
    private final boolean debug = false;
    private final int STATE_NOT_STARTED = 0;
    private final int STATE_STARTED = 1;
    // indicates if the object has already been STARTED or NOT.
    private int a_state;
    private Node[] a_nodes;
    private int a_TotalNumberOfNQPs;
    private static boolean a_shutdown_requested;
    private String a_objectName;
    // for multi-query load balancing
    private NodeQueryProcessor[] a_nqp; // array of nqps
    private NqpAllocator a_nqpAllocator;
    // to make tests easier
    int a_currentClusterSize;

    /** Creates a new instance of ClusterQueryProcessorEngine */
    public CQP_Scheduler_Engine(String objectName) throws RemoteException {
        a_shutdown_requested = false;
        a_nodes = null;
        a_objectName = objectName;
        a_state = STATE_NOT_STARTED;
    }

    public String getObjectName() throws RemoteException {
        return a_objectName;
    }

    /**
     * @param args
     *            the command line arguments
     */
    public static void main(String[] args) {
        int portNumber;
        String configFileName;

        if (args.length < 2) {
            System.out.println("usage: java dbcluster.CQP_Scheduler_Engine "
                    + "query_processor_port_number ConfigFileName");
            return;
        }

        portNumber = Integer.parseInt(args[0]);
        configFileName = args[1].trim();

        try {
            LocateRegistry.createRegistry(portNumber);
            ClusterQueryProcessor qProc = new CQP_Scheduler_Engine(
                    "//localhost:" + portNumber + "/ClusterQueryProcessor");
            qProc.start(configFileName);
            Naming.rebind(qProc.getObjectName(), qProc);
            System.out.println("CQP_Scheduler_Engine is Running on port "
                    + portNumber);
            synchronized (qProc) {
                while (!a_shutdown_requested) {
                    qProc.wait();
                }
                qProc.notifyAll();
            }
            System.gc();
            System.exit(0);
        } catch (Exception e) {
            System.err.println("CQP_Scheduler_Engine Exception: "
                    + e.getMessage());
            e.printStackTrace();
        }
    }

    public synchronized void start(String configFileName)
            throws InterruptedException, IllegalArgumentException,
            FileNotFoundException, IOException, IndexOutOfBoundsException,
            NotBoundException, MalformedURLException, RemoteException {
        if (a_state == STATE_STARTED) {
            // System.out.println(getClass().getName()
            // + " - start(): Already Started!");*/
        } else {
            LinkedList<Node> nodeList = new LinkedList<Node>(); // list to store
            // Node objects
            String line;
            int lineCount = 1;

            a_TotalNumberOfNQPs = 0;
            // Opening configuration File
            BufferedReader configReader = new BufferedReader(new FileReader(
                    configFileName));
            while ((line = configReader.readLine()) != null) {
                line = line.trim();
                if (line.length() > 0) { // non-empty line
                    if (line.charAt(0) != '#') {
                        char fieldSeparator = ':';
                        int separatorIndex;
                        String nodeName;
                        Node node;
                        LinkedList<NodeQueryProcessor> nqpList; // list to store
                        // NQPs from one
                        // node
                        NodeQueryProcessor[] nqpArray;

                        nodeName = null;
                        node = null;
                        nqpList = null;
                        nqpArray = null;
                        // non-comment line
                        // get nodeName
                        separatorIndex = line.indexOf(fieldSeparator);
                        if ((separatorIndex <= 0)) {

                            // no node address
                            throw new IllegalArgumentException("Line "
                                    + lineCount + ": node address not informed");
                        } else if (separatorIndex == line.length() - 1) {

                            // no port number
                            throw new IllegalArgumentException("Line "
                                    + lineCount + ": no port number");
                        } else {
                            nodeName = line.substring(0, separatorIndex).trim();
                            // getting port numbers and connecting to NQPs
                        }
                        while ((separatorIndex != -1)
                                && (separatorIndex < line.length() - 1)) {
                            int nextSeparatorIndex;
                            String portNumber;
                            NodeQueryProcessor nqp;
                            final int MAX_NQP_BINDING_ATTEMPTS = 5;
                            final int SLEEP_TIME = 500; // milliseconds
                            int nqp_binding_attempts;
                            boolean nqpBound;

                            nextSeparatorIndex = line.indexOf(fieldSeparator,
                                    separatorIndex + 1);
                            if (nextSeparatorIndex == -1) {

                                // last line field
                                portNumber = line.substring(separatorIndex + 1)
                                        .trim();
                            } else {
                                portNumber = line.substring(separatorIndex + 1,
                                        nextSeparatorIndex).trim();
                            }
                            if (portNumber.length() == 0) {
                                throw new IllegalArgumentException("Line "
                                        + lineCount + ": empty port number");
                            }
                            if (nqpList == null) {
                                nqpList = new LinkedList<NodeQueryProcessor>();
                            }
                            nqp_binding_attempts = 1;
                            nqpBound = false;
                            while (!nqpBound) {
                                try {
                                    /*
                                     * System.out .println("Connecting to " +
                                     * "//" + nodeName + ":" + portNumber +
                                     * "/NodeQueryProcessor. Attempt number: " +
                                     * nqp_binding_attempts);
                                     */
                                    nqp = (NodeQueryProcessor) MyRMIRegistry
                                            .lookup(nodeName, Integer
                                                    .parseInt(portNumber), "//"
                                                    + nodeName + ":"
                                                    + portNumber
                                                    + "/NodeQueryProcessor");
                                    nqpList.add(nqp);
                                    nqpBound = true;
                                    /*
                                     * System.out.println("Connected to " + "//" +
                                     * nodeName + ":" + portNumber +
                                     * "/NodeQueryProcessor");
                                     */
                                } catch (NotBoundException e) {
                                    if (nqp_binding_attempts == MAX_NQP_BINDING_ATTEMPTS) {
                                        throw new NotBoundException(
                                                "Binding to //"
                                                        + nodeName
                                                        + ":"
                                                        + portNumber
                                                        + "/NodeQueryProcessor not possible after "
                                                        + MAX_NQP_BINDING_ATTEMPTS
                                                        + " attempts.");
                                    } else {
                                        Thread.sleep(SLEEP_TIME);
                                        nqp_binding_attempts++;
                                    }
                                }
                            }
                            separatorIndex = nextSeparatorIndex;
                        }
                        nqpArray = new NodeQueryProcessor[nqpList.size()];
                        a_TotalNumberOfNQPs += nqpList.size();
                        for (int i = 0; i < nqpArray.length; i++) {
                            nqpArray[i] = (NodeQueryProcessor) nqpList
                                    .removeFirst();
                        }
                        node = new Node(nodeName, nqpArray);
                        nodeList.add(node);
                    }
                }
                lineCount++;
            }
            a_nodes = new Node[nodeList.size()];
            a_nqp = new NodeQueryProcessor[a_TotalNumberOfNQPs];
            for (int i = 0, idxnqp = 0; i < a_nodes.length; i++) {
                a_nodes[i] = (Node) nodeList.removeFirst();
                for (int j = 0; j < a_nodes[i].getNumNQPs(); j++, idxnqp++) {
                    a_nqp[idxnqp] = a_nodes[i].getNQP(j);
                }
            }
            a_nqpAllocator = new NqpAllocator(a_nqp, 0);
            a_currentClusterSize = a_nqp.length;
            configReader.close();
            a_state = STATE_STARTED;
            System.out.println(getClass().getName() + " - start(): Started!");
        }
        notifyAll();
    }

    public ResultSet executeQueryWithAVP(String query, Range range,
            int numNQPs, int[] partitionSizes, boolean getStatistics,
            boolean localResultComposition,
            boolean performDynamicLoadBalancing,
            boolean getSystemResourceStatistics, QueryInfo qi)
            throws IllegalStateException, RemoteException,
            InterruptedException, IllegalArgumentException, Exception {
        return executeQuery(query, range, numNQPs, partitionSizes,
                getStatistics, localResultComposition,
                GlobalQueryTask.QE_STRATEGY_AVP, performDynamicLoadBalancing,
                getSystemResourceStatistics, qi);
    }

    public ResultSet executeQueryWithFGVP(String query, Range range,
            int numNQPs, int[] partitionSizes, boolean getStatistics,
            boolean localResultComposition,
            boolean performDynamicLoadBalancing,
            boolean getSystemResourceStatistics) throws IllegalStateException,
            RemoteException, InterruptedException, IllegalArgumentException,
            Exception {
        return executeQuery(query, range, numNQPs, partitionSizes,
                getStatistics, localResultComposition,
                GlobalQueryTask.QE_STRATEGY_FGVP, performDynamicLoadBalancing,
                getSystemResourceStatistics, null);
    }

    private ResultSet executeQuery(String query, Range range, int numNQPs,
            int[] partitionSizes, boolean getStatistics,
            boolean localResultComposition, int queryExecutionStrategy,
            boolean performDynamicLoadBalancing,
            boolean getSystemResourceStatistics, QueryInfo qi)
            throws IllegalStateException, RemoteException,
            InterruptedException, IllegalArgumentException, Exception {    	
        int[] allocatedNQP_id;
        int id_nqp_gqt; // NQP where GQT will run
        ResultSet result;

        if (a_state != STATE_STARTED) {
            throw new IllegalStateException(
                    "ClusterQueryProcessor not Started!");
        }

        if (numNQPs > a_TotalNumberOfNQPs) {
            throw new IllegalArgumentException(numNQPs
                    + " NodeQueryProcessors were requested but only "
                    + a_TotalNumberOfNQPs + " are available");
        }

        if (range.getNumVPs() < numNQPs) {
            throw new IllegalArgumentException(
                    "As "
                            + numNQPs
                            + " NodeQueryProcessors will be used, there must be at least "
                            + numNQPs + " intervals");
        }

        allocatedNQP_id = new int[numNQPs];

        id_nqp_gqt = a_nqpAllocator
                .allocateNQPsForQueryProcessing(allocatedNQP_id);
        // get NQP objects references
        ArrayList<NodeQueryProcessor> allocatedNQP = new ArrayList<NodeQueryProcessor>(numNQPs);
        
        for (int i = 0; i < allocatedNQP_id.length; i++)
            allocatedNQP.set(i,a_nqp[allocatedNQP_id[i]]);

        GlobalQueryTask globalTask = a_nqp[id_nqp_gqt].newGlobalQueryTask(
                a_nqp[id_nqp_gqt], allocatedNQP, query, range, partitionSizes,
                getStatistics, localResultComposition, queryExecutionStrategy,
                performDynamicLoadBalancing, getSystemResourceStatistics, null);

        result = globalTask.start();
        if (debug) {
            System.out.print("Allocated nodes : {" + id_nqp_gqt + "} ");
            for (int i = 0; i < allocatedNQP_id.length; i++) {
                System.out.print(allocatedNQP_id[i] + " ");
            }
            System.out.println();
        }
        a_nqpAllocator.disposeNQPs(id_nqp_gqt, allocatedNQP_id);

        return result;
    }

    public synchronized void shutdown() throws RemoteException,
            NotBoundException, MalformedURLException {
        System.out.println("Shuting down...");
        if (a_state == STATE_STARTED) {
            System.out.println("Disconnecting from NodeQueryProcessors...");
            for (int i = 0; i < a_nodes.length; i++) {
                System.out.println("Node " + a_nodes[i].getAddress());
                a_nodes[i] = null;
            }
            a_nodes = null;
        }
        System.out.println("Unbinding...");
        Naming.unbind(a_objectName);
        System.out.println("Exit.");
        a_shutdown_requested = true;
        notifyAll();
    }

    public boolean quotedDateIntervals() throws RemoteException {
        return a_nodes[0].getNQP(0).quotedDateIntervals();
    }

    public SystemResourceStatistics[] getGlobalSystemResourceStatistics()
            throws RemoteException {
        SystemResourceStatistics[] statistics = new SystemResourceStatistics[a_TotalNumberOfNQPs];

        for (int nodenum = 0; nodenum < a_nodes.length; nodenum++) {
            if (a_nodes[nodenum].getNumNQPs() > 0) {
                statistics[nodenum] = a_nodes[nodenum].getNQP(0)
                        .getSystemResourceStatistics();
            }
        }
        return statistics;
    }

    public synchronized void setClusterSize(int size) throws RemoteException {
        if (size > a_nqp.length)
            throw new IllegalArgumentException(
                    "CQP_Scheduler_Engine Exception: Cannot change size to "
                            + size + " because there are only " + a_nqp.length
                            + " NQPs.");

        NodeQueryProcessor[] nqp = new NodeQueryProcessor[size];
        for (int i = 0; i < size; i++)
            nqp[i] = a_nqp[i];
        a_currentClusterSize = size;
        a_nqpAllocator = new NqpAllocator(nqp, 0);
        notifyAll();
    }

    public int getClusterSize() throws RemoteException {
        return a_currentClusterSize;
    }

    public NodeQueryProcessor getNQP(int i) throws RemoteException {
        return a_nqp[i];
    }

    public void addNode(String host, int port) throws PargresException,
            RemoteException {
        // TODO Auto-generated method stub

    }

    public void dropNode(int nodeId) throws RemoteException {
        // TODO Auto-generated method stub

    }

    public String getNodesList() throws RemoteException {
        // TODO Auto-generated method stub
        return null;
    }
}
