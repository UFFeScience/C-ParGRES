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

import java.net.MalformedURLException;
import java.rmi.NotBoundException;
import java.rmi.RemoteException;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;

import javax.sql.rowset.RowSetMetaDataImpl;

import org.pargres.commons.logger.Logger;
import org.pargres.commons.translation.Messages;
import org.pargres.commons.util.PargresException;
import org.pargres.cqp.querymanager.UpdateLogger;
import org.pargres.cqp.queryplanner.QueryInfo;
import org.pargres.globalquerytask.GlobalQueryTask;
import org.pargres.globalquerytask.GlobalQueryTaskEngine;
import org.pargres.jdbc.PargresRowSet;
import org.pargres.nodequeryprocessor.NodeQueryProcessor;
import org.pargres.nodequeryprocessor.NqpAllocator;
import org.pargres.util.MyRMIRegistry;
import org.pargres.util.Node;
import org.pargres.util.Range;
import org.pargres.util.SystemResourceStatistics;


public class ClusterQueryProcessorEngine /* implements ClusterQueryProcessor */{

    private static final long serialVersionUID = 1L;
    private Logger logger = Logger.getLogger(ClusterQueryProcessorEngine.class);
    private final int STATE_NOT_STARTED = 0;
    private final int STATE_STARTED = 1;
    private int state; // indicates if the object has already been STARTED or NOT.
    private ArrayList<Node> nodes = new ArrayList<Node>();
    private String objectName;
    private UpdateLogger updateLogger = new UpdateLogger();
    private NqpAllocator nqpAllocator = new NqpAllocator();

    public boolean isStarted() {
        return state == STATE_STARTED;
    }

    /** Creates a new instance of ClusterQueryProcessorEngine */
    public ClusterQueryProcessorEngine()
            throws RemoteException {
        // this.port = portNumber;
        // shutdownRequested = false;
        // this.objectName = "//localhost:" + portNumber
        // + "/ClusterQueryProcessor";
        state = STATE_NOT_STARTED;

        try {
            // MyRMIRegistry.bind(portNumber, objectName, this);
            //this.start(configFileName);
            state = STATE_STARTED;
        } catch (Exception e) {
            logger.error("ClusterQueryProcessorEngine Exception: "
                    + e.getMessage());
            e.printStackTrace();
        }
    }

    public String getObjectName() throws RemoteException {
        return objectName;
    }

    /*
     * public static void main(String[] args) { int portNumber; String
     * configFileName;
     * 
     * if (args.length < 2) { System.out .println("usage: java
     * dbcluster.ClusterQueryProcessorEngine " + "query_processor_port_number
     * ConfigFileName"); return; }
     * 
     * portNumber = Integer.parseInt(args[0]); configFileName = args[1].trim();
     * 
     * try { new ClusterQueryProcessorEngine( configFileName); } catch
     * (Exception e) { System.err.println(e); e.printStackTrace(); } }
     */

  /*  public synchronized void start(String configFileName)
            throws InterruptedException, IllegalArgumentException,
            FileNotFoundException, IOException, IndexOutOfBoundsException,
            NotBoundException, MalformedURLException, RemoteException,
            PargresException {
        if (state == STATE_STARTED)
        	logger.info(Messages.getString("clusterQueryProcessorEngine.alreadyStarted",getClass().getName()));
        else {
            // LinkedList<Node> nodeList = new LinkedList<Node>(); // list to
            // store
            // Node
            // objects
            String line;
            int lineCount = 1;
            
            // Opening configuration File
            Reader r = new FileReader(configFileName);
            BufferedReader configReader = new BufferedReader(r);
            while ((line = configReader.readLine()) != null) {
                line = line.trim();
                if (line.length() > 0) // non-empty line
                    if (line.charAt(0) != '#') {
                        char fieldSeparator = ':';
                        int separatorIndex;
                        String nodeName;
                        // Node node;
                        // LinkedList<NodeQueryProcessor> nqpList; // list to
                        // store NQPs from one node
                        // NodeQueryProcessor[] nqpArray;

                        nodeName = null;
                        // node = null;
                        // nqpList = null;
                        // nqpArray = null;
                        // non-comment line
                        // get nodeName
                        separatorIndex = line.indexOf(fieldSeparator);
                        if ((separatorIndex <= 0))
                            // no node address
                            throw new IllegalArgumentException("Line "
                                    + lineCount + ": node address not informed");
                        else if (separatorIndex == line.length() - 1)
                            // no port number
                            throw new IllegalArgumentException("Line "
                                    + lineCount + ": no port number");
                        else
                            nodeName = line.substring(0, separatorIndex).trim();
                        // getting port numbers and connecting to NQPs
                        while ((separatorIndex != -1)
                                && (separatorIndex < line.length() - 1)) {
                            int nextSeparatorIndex;
                            String portNumber;

                            nextSeparatorIndex = line.indexOf(fieldSeparator,
                                    separatorIndex + 1);
                            if (nextSeparatorIndex == -1)
                                // last line field
                                portNumber = line.substring(separatorIndex + 1)
                                        .trim();
                            else
                                portNumber = line.substring(separatorIndex + 1,
                                        nextSeparatorIndex).trim();
                            if (portNumber.length() == 0)
                                throw new IllegalArgumentException("Line "
                                        + lineCount + ": empty port number");
                           
                            
                            addNode(nodeName, Integer.parseInt(portNumber));

                           
                            separatorIndex = nextSeparatorIndex;

                        }
                   
                    }
                lineCount++;
            }

            state = STATE_STARTED;
            // System.out.println(getClass().getName() + " - start():
            // Started!");
            configReader.close();
        }
    }*/

    public void addNode(String nodeName, int portNumber)
            throws PargresException, RemoteException {
        try {
            NodeQueryProcessor nqp = null;
            final int MAX_NQP_BINDING_ATTEMPTS = 5;
            final int SLEEP_TIME = 500; // milliseconds
            int nqp_binding_attempts = 1;
            boolean nqpBound = false;

            while (!nqpBound) {
                try {
                    logger.debug(Messages.getString("clusterQueryProcessorEngine.addingNode",new Object[]{nodeName,portNumber,nqp_binding_attempts}));
                    nqp = (NodeQueryProcessor) MyRMIRegistry.lookup(nodeName,
                            portNumber, "//" + nodeName + ":" + portNumber
                                    + "/NodeQueryProcessor");
                    nqpBound = true;
                    logger.info(Messages.getString("clusterQueryProcessorEngine.nodeConnected",new Object[]{nodeName,portNumber}));

                } catch (NotBoundException e) {
                    if (nqp_binding_attempts == MAX_NQP_BINDING_ATTEMPTS)
                        throw new NotBoundException("Binding to //" + nodeName
                                + ":" + portNumber
                                + "/NodeQueryProcessor not possible after "
                                + MAX_NQP_BINDING_ATTEMPTS + " attempts.");
                    else {
                        Thread.sleep(SLEEP_TIME);
                        nqp_binding_attempts++;
                    }
                }
            }
            NodeQueryProcessor[] nqpArray = new NodeQueryProcessor[1];
            nqpArray[0] = nqp;
            nodes.add(new Node(nodeName + ":" + portNumber, nqpArray));
            updateLogger.logAddNode(nodeName + ":" + portNumber);
            nqpAllocator.addNode(nqp);
        } catch (Exception e) {
            logger.error(e);
            throw new PargresException("Failed to add node");
        }
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
                GlobalQueryTask.QE_STRATEGY_AVP,
                performDynamicLoadBalancing, getSystemResourceStatistics, qi);
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
                GlobalQueryTask.QE_STRATEGY_FGVP,
                performDynamicLoadBalancing, getSystemResourceStatistics, null);
    }

    private ResultSet executeQuery(String query, Range range, int numNQPs,
            int[] partitionSizes, boolean getStatistics,
            boolean localResultComposition, 
            int queryExecutionStrategy, boolean performDynamicLoadBalancing,
            boolean getSystemResourceStatistics, QueryInfo qi)
            throws PargresException {
        try {
           
            int allocatedNQPs;
            ResultSet result;

            if (state != STATE_STARTED)
                throw new IllegalStateException(
                        "ClusterQueryProcessor not Started!");

            if (numNQPs > getClusterSize())
                throw new IllegalArgumentException(numNQPs
                        + " NodeQueryProcessors were requested but only "
                        + getClusterSize() + " are available");

            if (range.getNumVPs() < numNQPs)
                throw new IllegalArgumentException(
                        "As "
                                + numNQPs
                                + " NodeQueryProcessors will be used, there must be at least "
                                + numNQPs + " intervals");

            ArrayList<NodeQueryProcessor> nqpsUsed = new ArrayList<NodeQueryProcessor>();
            
            int leastLoadedNode = -1;
            long minLoad = Long.MAX_VALUE;
            allocatedNQPs = 0;
            
            for (int i = 0; (i < nodes.size()) && (allocatedNQPs < numNQPs); i++) {
                for (int j = 0; (j < nodes.get(i).getNumNQPs())
                        && (allocatedNQPs < numNQPs); j++) {
                    nqpsUsed.add(nodes.get(i).getNQP(j));
                    allocatedNQPs++;
                    
                    if(nodes.get(i).getLoad() < minLoad) {
                    	leastLoadedNode = i;
                    	minLoad = nodes.get(i).getLoad();
                    }
                    	
                }
            }
            logger.debug(Messages.getString("clusterQueryProcessorEngine.creatingGlobaQueryTask"));
            
            Node node = nodes.get(leastLoadedNode);
            NodeQueryProcessor nqp = node.getNQP(0);
            
            node.incLoad();
            
            GlobalQueryTask globalTask = new GlobalQueryTaskEngine(nqp, 
            		nqpsUsed, query, range, getStatistics,
                    localResultComposition, queryExecutionStrategy,
                    performDynamicLoadBalancing, partitionSizes,
                    getSystemResourceStatistics, qi);
            result = globalTask.start();
            
            node.decLoad();
            
            return result;
        } catch (Exception e) {
            e.printStackTrace();
            throw new PargresException(e.getMessage());
        }
        //IllegalStateException, RemoteException,
        //InterruptedException, IllegalArgumentException, Exception			
    }

    public synchronized void shutdown() throws RemoteException,
            NotBoundException, MalformedURLException {
    	logger.info(Messages.getString("clusterQueryProcessorEngine.shutdown"));
        if (state == STATE_STARTED) {
            logger.info(Messages.getString("clusterQueryProcessorEngine.disconnecting"));
            int nodeSize = nodes.size();
            for (int i = 0; i < nodeSize; i++)
                dropNode(0);
        }
        //System.out.println("Unbinding...");

        //MyRMIRegistry.unbind(port, objectName, this);

        logger.info(Messages.getString("clusterQueryProcessorEngine.exit"));
        //shutdownRequested = true;
        notifyAll();
    }

    public boolean quotedDateIntervals() throws RemoteException {
        return nodes.get(0).getNQP(0).quotedDateIntervals();
    }

    public ArrayList<NodeQueryProcessor> getNodeQueryProcessorList() {
        ArrayList<NodeQueryProcessor> list = new ArrayList<NodeQueryProcessor>();
        for (Node node : nodes)
            list.add(node.getNQP(0));
        return list;
    }

    public SystemResourceStatistics[] getGlobalSystemResourceStatistics()
            throws RemoteException {
        SystemResourceStatistics[] statistics = new SystemResourceStatistics[getClusterSize()];

        for (int nodenum = 0; nodenum < nodes.size(); nodenum++) {
            if (nodes.get(nodenum).getNumNQPs() > 0) {
                statistics[nodenum] = nodes.get(nodenum).getNQP(0)
                        .getSystemResourceStatistics();
            }
        }
        return statistics;
    }

    public synchronized void setClusterSize(int size) throws RemoteException {
        throw new RuntimeException(
                "ClusterQueryProcessor Exception: function setClusterSize() is not implemented!");
    }

    public int getClusterSize() throws RemoteException {
        return nodes.size();
    }

    public NodeQueryProcessor getNQP(int i) throws RemoteException {
        return nodes.get(i).getNQP(0);
    }

    public void dropNodeByNodeId(int nodeId) throws RemoteException {
        // Generics were not used to possible modification in collection
        for (int i = 0; i < nodes.size(); i++) {
            Node node = nodes.get(0);
            if (node.getNQP(0).getNodeId() == nodeId) {
                nodes.remove(node);
                updateLogger.logDropNode(node.getAddress());
                return;
            }
        }
    }

    public void dropNode(int nodeId) throws RemoteException {
        //TODO: Refazer isso		
        Node node = nodes.remove(nodeId);
        updateLogger.logDropNode(node.getAddress());
        try {
            // node.getNQP(0).shutdown();
        } catch (Exception e) {
            logger.error(e);
            e.printStackTrace();
        }
    }

    public ResultSet getNodesList() throws SQLException, RemoteException {
		PargresRowSet rs = new PargresRowSet();
		
		RowSetMetaDataImpl meta = new RowSetMetaDataImpl();
		meta.setColumnCount(1);
		meta.setColumnName(1, "DUMMY");
		meta.setColumnType(1, Types.VARCHAR);
		rs.setMetaData(meta);
		
        int i = 0;
        for (Node node : nodes) {        	
        	String item = i + ":" + node.getAddress().toString();
        	if(i != nodes.size() - 1)
        		item += ";";
            
            i++;
            
			rs.moveToInsertRow();
			rs.updateString(1, item);
			rs.insertRow();
			rs.moveToCurrentRow();	            
        }
        return rs;
    }

}
