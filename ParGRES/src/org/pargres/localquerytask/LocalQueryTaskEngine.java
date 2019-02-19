/*
 * LocalQueryTaskEngine.java
 *
 * Created on 14 novembre 2003, 14:56
 */

package org.pargres.localquerytask;

/**
 * 
 * @author lima
 */

import java.rmi.RemoteException;
import java.rmi.server.UnicastRemoteObject;

import org.pargres.commons.logger.Logger;
import org.pargres.commons.translation.Messages;
import org.pargres.connection.DBConnectionPoolEngine;
import org.pargres.cqp.queryplanner.QueryInfo;
import org.pargres.globalquerytask.GlobalQueryTask;
import org.pargres.queryexecutor.QueryExecutor;
import org.pargres.queryexecutor.QueryExecutorAvp;
import org.pargres.queryexecutor.QueryExecutorFgvp;
import org.pargres.resultcomposer.ResultComposer;
import org.pargres.resultcomposer.ResultComposerDistributed;
import org.pargres.resultcomposer.ResultComposerEngineDistributed;
import org.pargres.resultcomposer.ResultComposerEngineLocal;
import org.pargres.resultcomposer.ResultComposerGlobal;
import org.pargres.resultcomposer.ResultComposerLocal;
import org.pargres.util.IntervalTree;
import org.pargres.util.LocalQueryTaskStatistics;
import org.pargres.util.Range;
import org.pargres.util.SystemResourceStatistics;
import org.pargres.util.SystemResourcesMonitor;

public class LocalQueryTaskEngine extends UnicastRemoteObject implements
        LocalQueryTask, Runnable {

    private static final long serialVersionUID = 3257288036978274359L;
    private Logger logger = Logger.getLogger(LocalQueryTaskEngine.class);
    // Neighbors constants
    static private final int NUMBER_OF_NEIGHBORS = 4;
    static private final int NEIGHBOR_ABSENT = -1;
    // It is important to keep the order
    static private final int NEIGHBOR_NORTH = 0;
    static private final int NEIGHBOR_EAST = 1;
    static private final int NEIGHBOR_SOUTH = 2;
    static private final int NEIGHBOR_WEST = 3;
    // States
    static private final int ST_INITIAL = 0;
    static private final int ST_PROCESSING_QUERY = 1;
    static private final int ST_IDLE = 2;
    static private final int ST_FINISHING = 3;
    static private final int ST_FINISHED = 4;
    static private final int ST_ERROR = 5;
    private int id;
    private int state;
    private Range range;
    private GlobalQueryTask globalTask;
    private DBConnectionPoolEngine dbpool;
    private ResultComposerGlobal globalResultComposer;
    private ResultComposerLocal localResultComposer;
    private String query;
    // indicates if local result composition must be made
    private boolean localResultComposition;
    // indicates if statistics must be get
    private boolean getStatistics;
    // private boolean finishRequested;
    private int queryExecutionStrategy;
    // used to store what needs to be processed, concerning the first interval
    // assigned to this LQT by GQT
    private IntervalTree intervalNotProcessed;
    private LQT_Message_Queue messageQueue;
    private QueryExecutor qe;
    private LocalQueryTaskStatistics statistics;
    // to avoid deadlock
    // private boolean a_blocked; // NOT USED - check
    // For dynamic load balance
    private static final float HELP_WORKLOAD_FRACTION = (float) 0.5;
    // number of LQTs in the grid
    private int numlqts;
    // references to all lqts
    private LocalQueryTask[] lqt;
    // identifiers from all neighbors
    private int[] idNeighbor;
    // to indicate if dynamic load balancing
    private boolean performDynLoadBal;
    // must be performed
    private int numNodesPerLine;
    private int numGridLines;
    // line occupied by the node if it was in a grid
    private int line;
    // column occupied by the node if it was in a grid
    private int column;
    // indicates if this lqt is responsible to transmit messages came from East
    // to the last line
    private boolean respForEastMsgLastLine;
    // indicates how many help refuses must arriving before repeating help
    // offering private int a_idRangeOwner
    private int numRefusesForHelpReoffer;
    // id of the LQT responsible for the range
    // being processed
    // id of the last help offer made
    private int numLastHelpOffer;
    // number of refuses to the last help offer received
    private int numRefusesReceived;
    // to get system resources
    private SystemResourcesMonitor localMonitor;
    private QueryInfo queryInfo;
    private ResultComposerDistributed groupResultComposerDistributed;
    private ResultComposerDistributed sortResultComposerDistributed;

    /** Creates a new instance of Job */
    public LocalQueryTaskEngine(int id, GlobalQueryTask globalTask,
            DBConnectionPoolEngine dbpool,
            ResultComposerGlobal globalResultComposer, String query,
            Range range, int queryExecutionStrategy, int numlqts,
            boolean localResultComposition,
            boolean performDynamicLoadBalancing, boolean getStatistics,
            SystemResourcesMonitor localMonitor, QueryInfo qi)
            throws RemoteException {
        this.id = id;
        this.state = ST_INITIAL;
        this.globalTask = globalTask;
        this.dbpool = dbpool;
        this.globalResultComposer = globalResultComposer;
        this.localResultComposer = null;
        this.query = query;
        this.range = range;
        this.localResultComposition = localResultComposition;
        this.getStatistics = getStatistics;
        this.queryExecutionStrategy = queryExecutionStrategy;
        this.intervalNotProcessed = null;
        this.numlqts = numlqts;
        this.performDynLoadBal = performDynamicLoadBalancing;
        this.messageQueue = new LQT_Message_Queue();
        this.lqt = null;
        this.idNeighbor = null;
        this.numLastHelpOffer = 0;
        this.qe = null;
        // a_blocked = false;
        // initialize Local Query Tasks array
        this.lqt = new LocalQueryTask[this.numlqts];
        for (int i = 0; i < this.numlqts; i++)
            this.lqt[i] = null;
        this.statistics = null;
        this.localMonitor = localMonitor;
        this.queryInfo = qi;
    }

    public void start() throws RemoteException {
        Thread t = new Thread(this);
        t.start();
    }

    public void run() {
        try {
            ResultComposer resultComposer;
            SystemResourceStatistics initialResourceStatistics, finalResourceStatistics;

            // Calculate logical grid
            if (performDynLoadBal)
                enterGrid();

            // Create interval tree
            this.intervalNotProcessed = new IntervalTree(range.getFirstValue(),
                    range.getOriginalLastValue());

            // get system resources information
            if (localMonitor != null)
                initialResourceStatistics = localMonitor.getStatistics();
            else
                initialResourceStatistics = null;

            // initiate statistics collector, if needed
            if (getStatistics) {
                statistics = new LocalQueryTaskStatistics(performDynLoadBal);
                statistics.setIntervalLimits(range.getFirstValue(), range
                        .getOriginalLastValue());
                statistics.begin();
            } else
                statistics = null;

            // Set result composer
            if (localResultComposition) {
                // Create distributed composer for group, if needed
                if (queryInfo.isDistributedComposition()) {
                    groupResultComposerDistributed = new ResultComposerEngineDistributed(
                            id, globalResultComposer, numlqts, queryInfo, this);
                    groupResultComposerDistributed.start();
                }

                // Create distributed composer for sort, if needed
                if (queryInfo.isDistributedSort()) {
                    sortResultComposerDistributed = new ResultComposerEngineDistributed(
                            id, globalResultComposer, numlqts, queryInfo, this);
                    sortResultComposerDistributed.start();
                }

                // Create local ResultComposer, if needed
                localResultComposer = new ResultComposerEngineLocal(id,
                        globalResultComposer, numlqts, queryInfo, this);
                localResultComposer.start();
                resultComposer = localResultComposer;
            } else
                resultComposer = globalResultComposer;

            // Create and start QueryExecutor
            switch (queryExecutionStrategy) {
            case GlobalQueryTask.QE_STRATEGY_FGVP: {
                qe = new QueryExecutorFgvp(this, dbpool, resultComposer, query,
                        range, statistics);
                break;
            }
            case GlobalQueryTask.QE_STRATEGY_AVP: {
                qe = new QueryExecutorAvp(this, dbpool, resultComposer, query,
                        range, statistics);
                break;
            }
            default:
                throw new IllegalArgumentException(
                        "LocalQueryTaskException (run): Invalid query execution strategy ("
                                + queryExecutionStrategy + ")!");
            }

            // change state
            state = ST_PROCESSING_QUERY;

            qe.start();

            do {
                LQT_Message msg;

                msg = messageQueue.getMessage();
                switch (msg.getType()) {
                case LQT_Message.MSG_FINISH: {
                    treatFinishMessage();
                    break;
                }
                case LQT_Message.MSG_HELPOFFER: {
                    treatHelpOffer((LQT_Msg_HelpOffer) msg);
                    break;
                }
                case LQT_Message.MSG_HELPACCEPTED: {
                    treatHelpAcceptedMessage((LQT_Msg_HelpAccepted) msg);
                    break;
                }
                case LQT_Message.MSG_HELPNOTACCEPTED: {
                    treatHelpNotAcceptedMessage((LQT_Msg_HelpNotAccepted) msg);
                    break;
                }
                case LQT_Message.MSG_INTERVALFINISHED: {
                    treatIntervalFinishedMessage((LQT_Msg_IntervalFinished) msg);
                    break;
                }
                default:
                    throw new IllegalArgumentException(
                            "LocalQueryTaskEngine.run(): invalid message type: "
                                    + msg.getType());
                }
            } while (state != ST_FINISHING);

            if (statistics != null)
                statistics.endQueryProcessing();

            // finish local result composer
            if (localResultComposition)
                resultComposer.finish();

            // Finish QueryExecutor
            qe.finish();

            // wait local result composer to finish its work
            // this is separated from the "finish()" call to take advantage of
            // multitasking
            if (localResultComposition) {
                synchronized (resultComposer) {
                    while (!resultComposer.finished())
                        resultComposer.wait();
                }
            }
            // wait distributed result composer to finish its work
            // this is separated from the "finish()" call to take advantage of
            // multitasking
            if (queryInfo.isDistributedComposition()) {
                logger.debug(Messages.getString("localQueryTaskEngine.waiting",
                        id));
                synchronized (groupResultComposerDistributed) {
                    while (!groupResultComposerDistributed.finished())
                        // System.out.println("AAAAAAAAA");
                        groupResultComposerDistributed.wait();
                }
                logger.debug(Messages
                        .getString("localQueryTaskEngine.done", id));
            }
            if (queryInfo.isDistributedSort()) {
                logger.debug(Messages.getString("localQueryTaskEngine.waiting",
                        id));
                synchronized (sortResultComposerDistributed) {
                    while (!sortResultComposerDistributed.finished())
                        // System.out.println("AAAAAAAAA");
                        sortResultComposerDistributed.wait();
                }
                logger.debug(Messages
                        .getString("localQueryTaskEngine.done", id));
            }

            // Finish Statistics
            if (statistics != null)
                statistics.end();

            // get system resources information
            if (localMonitor != null) {
                finalResourceStatistics = localMonitor.getStatistics();
                finalResourceStatistics
                        .setNumberOfBlocksRead(finalResourceStatistics
                                .getNumberOfBlocksRead()
                                - initialResourceStatistics
                                        .getNumberOfBlocksRead());
                finalResourceStatistics
                        .setNumberOfBlocksWritten(finalResourceStatistics
                                .getNumberOfBlocksWritten()
                                - initialResourceStatistics
                                        .getNumberOfBlocksWritten());
            } else
                finalResourceStatistics = null;

            state = ST_FINISHED;

            // Notify Task
            globalTask.localQueryTaskFinished(id, statistics,
                    finalResourceStatistics, qe.getException());

        } catch (Exception e) {
            logger.error(Messages.getString("localQueryTaskEngine.exception", e
                    .getMessage()));
            e.printStackTrace();
            try {
                globalTask.localQueryTaskFinished(id, statistics, null, e);
                state = ST_ERROR;
            } catch (RemoteException re) {
                e.printStackTrace();
            }
        }
    }

    public int getId() throws RemoteException {
        return id;
    }

    public void finish() throws RemoteException {
        if ((state != ST_FINISHING) && (state != ST_FINISHED)) {
            LQT_Msg_Finish msg = new LQT_Msg_Finish();
            messageQueue.addMessage(msg);
        }
    }

    public void intervalFinished(int idLQT, int intervalBeginning,
            int intervalEnd) throws RemoteException {
        if ((state != ST_FINISHING) && (state != ST_FINISHED)) {
            LQT_Msg_IntervalFinished msg = new LQT_Msg_IntervalFinished(idLQT,
                    intervalBeginning, intervalEnd);
            this.messageQueue.addMessage(msg);
        }
    }

    public void offerHelp(int idSender, int idHelper, int senderPosition,
            int offerNumber) throws RemoteException {
        if ((state != ST_FINISHING) && (state != ST_FINISHED)) {
            LQT_Msg_HelpOffer msg = new LQT_Msg_HelpOffer(idSender, idHelper,
                    senderPosition, offerNumber);
            messageQueue.addMessage(msg);
            if (getStatistics) {
                statistics.helpOfferMsgReceived();
            }
        }
    }

    public void refuseHelp(int idSender, int offerNumber)
            throws RemoteException {
        if ((state != ST_FINISHING) && (state != ST_FINISHED)) {
            LQT_Msg_HelpNotAccepted msg = new LQT_Msg_HelpNotAccepted(idSender,
                    offerNumber);
            messageQueue.addMessage(msg);
        }
    }

    public void acceptHelp(int idSender, int offerNumber)
            throws RemoteException {
        if ((state != ST_FINISHING) && (state != ST_FINISHED)) {
            LQT_Msg_HelpAccepted msg = new LQT_Msg_HelpAccepted(idSender,
                    offerNumber);
            messageQueue.addMessage(msg);
        }
    }

    // To be called by Query Executor when the entire range has been processed
    public synchronized void rangeProcessed() throws RemoteException,
            InterruptedException {
        // a_blocked = true;
        if (state != ST_PROCESSING_QUERY) {
            notifyAll();
            // a_blocked = false;
            throw new IllegalStateException(
                    "LocalQueryTaskEngine.rangeProcessed(): called while in state "
                            + state);
        }
        if (range.getFirstValue() < range.getCurrentLastValue()) {
            getLQT(range.getIdOwner()).intervalFinished(id,
                    range.getFirstValue(), range.getCurrentLastValue());
            // Occasionaly, a_range.getFirstValue() can be equal to
            // a_range.getCurrentLastValue()
            // This situation can occurr when a node received an interval and,
            // before starting processing it,
            // received help. The interval was so small that it has been
            // entirely given to another node.
            if (getStatistics) {
                if (id == range.getIdOwner())
                    statistics.ownedRangeProcessed();
                else
                    statistics.notOwnedRangeProcessed();
            }

        }
        state = ST_IDLE;
        if (statistics != null)
            statistics.idle();
        // a_range = null;
        if (performDynLoadBal) {
            sendOfferHelpToNeighbors();
            if (getStatistics) {
                statistics.newBroadcast();
            }
        }
        // a_blocked = false;
        notifyAll();
    }

    // Calculate grid information and obtain references to neighbors.
    private void enterGrid() throws RemoteException {
        // Neighbors will be calculated as if nodes were in a grid.
        idNeighbor = new int[NUMBER_OF_NEIGHBORS];
        numNodesPerLine = (int) Math.ceil(Math.sqrt(numlqts));
        numGridLines = (int) Math.ceil((float) numlqts
                / (float) numNodesPerLine);
        // line occupied by the node if it was in a grid
        line = (int) Math.floor(id / numNodesPerLine);
        // column occupied by the node if it was in a grid
        column = id % numNodesPerLine;

        // Calculate neighbors North
        if (line > 0)
            idNeighbor[NEIGHBOR_NORTH] = (line - 1) * numNodesPerLine + column;
        else
            idNeighbor[NEIGHBOR_NORTH] = NEIGHBOR_ABSENT;

        // East
        if (column < (numNodesPerLine - 1)) {
            idNeighbor[NEIGHBOR_EAST] = line * numNodesPerLine + (column + 1);
            if (idNeighbor[NEIGHBOR_EAST] >= numlqts) {
                // Grid is not a square.
                idNeighbor[NEIGHBOR_EAST] = NEIGHBOR_ABSENT;
            }
        } else
            idNeighbor[NEIGHBOR_EAST] = NEIGHBOR_ABSENT;

        // South
        if (line < (numGridLines - 1)) {
            idNeighbor[NEIGHBOR_SOUTH] = (line + 1) * numNodesPerLine + column;
            if (idNeighbor[NEIGHBOR_SOUTH] >= numlqts) {
                // Grid is not a square.
                idNeighbor[NEIGHBOR_SOUTH] = NEIGHBOR_ABSENT;
                respForEastMsgLastLine = false;
            } else if ((idNeighbor[NEIGHBOR_SOUTH] == numlqts - 1)
                    && (idNeighbor[NEIGHBOR_EAST] != NEIGHBOR_ABSENT))
                respForEastMsgLastLine = true;
            else
                respForEastMsgLastLine = false;
        } else {
            idNeighbor[NEIGHBOR_SOUTH] = NEIGHBOR_ABSENT;
            respForEastMsgLastLine = false;
        }

        // West
        if (column > 0)
            idNeighbor[NEIGHBOR_WEST] = line * numNodesPerLine + (column - 1);
        else
            idNeighbor[NEIGHBOR_WEST] = NEIGHBOR_ABSENT;

        // obtain references to neighbors
        /*
         * LocalQueryTask []neighborlqt = new LocalQueryTask[
         * NUMBER_OF_NEIGHBORS ]; a_globalTask.getLQTReferences( idNeighbor,
         * neighborlqt ); for( int i = 0; i < neighborlqt.length; i++ ) if(
         * neighborlqt[i] != null ) a_lqt[ idNeighbor[i] ] = neighborlqt[i];
         */

        // own reference
        lqt[id] = this;

        // determine how many help refuse messages must arrive before repeating
        // help offering
        if ((column == 0) || (column == numNodesPerLine - 1)) {
            if ((column == 0) && (id == numlqts - 1))
                numRefusesForHelpReoffer = numGridLines - 1;
            else
                numRefusesForHelpReoffer = numGridLines;
        } else if (id == numlqts - 1) {
            numRefusesForHelpReoffer = (2 * numGridLines) - 1;
        } else {
            numRefusesForHelpReoffer = 2 * numGridLines;
            if (numlqts - (numNodesPerLine * (numGridLines - 1)) == 1) {
                // Only one node in the last line. One less message is needed.
                numRefusesForHelpReoffer--;
            }
        }
    }

    private LocalQueryTask getLQT(int id) throws RemoteException {
        if (lqt[id] == null)
            lqt[id] = globalTask.getLQTReference(id);
        return lqt[id];
    }

    private synchronized void treatFinishMessage() {
        // a_blocked = true;
        if (state != ST_IDLE) {
            // a_blocked = false;
            throw new IllegalStateException(
                    "LocalQueryTaskEngine.treatFinishMessage(): request to finish while object state = "
                            + state + "!");
        }
        state = ST_FINISHING;
        // a_blocked = false;
        notifyAll();
    }

    private synchronized void treatIntervalFinishedMessage(
            LQT_Msg_IntervalFinished msg) throws RemoteException {
        // a_blocked = true;
        if (intervalNotProcessed.isEmpty()) {
            notifyAll();
            // a_blocked = false;
            throw new IllegalThreadStateException(
                    "LocalQueryTaskEngine.treatIntervalFinishedMessage(): 'interval finished' message arrived but it has already been completely processed!");
        }
        intervalNotProcessed.removeInterval(msg.getIntervalBeginning(), msg
                .getIntervalEnd());
        if (intervalNotProcessed.isEmpty()) {
            // interval under responsibility of this LQT is already finished
            globalTask.localIntervalFinished(id);
        }
        logger.debug(Messages.getString(
                "localQueryTaskEngine.intervalProcessed", new Object[] {
                        msg.getIntervalBeginning(), msg.getIntervalEnd(),
                        msg.getIdSender() }));
        System.out.println("To be processed: ");
        // TODO: Como imprimir isso
        intervalNotProcessed.print(System.out);
        // a_blocked = false;
        notifyAll();
    }

    private synchronized void treatHelpAcceptedMessage(LQT_Msg_HelpAccepted msg)
            throws RemoteException {
        if (state == ST_IDLE) {
            // Still idle. Help.
            Range newRange;

            newRange = getLQT(msg.getIdSender()).getPartOfRange();
            if (newRange != null) {
                range.reset(newRange.getIdOwner(), newRange.getFirstValue(),
                        newRange.getOriginalLastValue());
                state = ST_PROCESSING_QUERY;
                qe.newRange(range);
                if (statistics != null) {
                    statistics.notIdle();
                    statistics.helpOfferGiven();
                }
            }
            // TODO: Completar aqui o internationalization
            logger.debug(Messages.getString("localQueryTaskEngine.helping", msg
                    .getIdSender()));
            if (newRange != null)
                logger.debug(" processing interval( " + range.getFirstValue()
                        + " - " + range.getOriginalLastValue()
                        + ") which is originally from " + range.getIdOwner());
            else
                logger.debug(" but he had no more intervals to process");
        } else {
            if (getStatistics) {
                statistics.helpAcceptanceMsgDespised();
            }
            logger.debug(msg.getIdSender()
                    + " accepted a help offer but I cannot help any more");
        }
        notifyAll();
    }

    private synchronized void treatHelpNotAcceptedMessage(
            LQT_Msg_HelpNotAccepted msg) throws RemoteException {
        // a_blocked = true;
        logger.debug(Messages.getString("localQueryTaskEngine.refuseToHelp",
                new Object[] { msg.getOfferNumber(), msg.getIdSender() }));
        if (msg.getOfferNumber() == numLastHelpOffer) {
            numRefusesReceived++;
            if (numRefusesReceived == numRefusesForHelpReoffer) {
                logger.debug(Messages
                        .getString("localQueryTaskEngine.resendingOffer"));
                if (state == ST_IDLE) {
                    sendOfferHelpToNeighbors();
                    if (getStatistics) {
                        statistics.broadcastRestarted();
                    }
                }
            } else if (numRefusesReceived > numRefusesForHelpReoffer) {
                // a_blocked = false;
                throw new IllegalThreadStateException(
                        "LocalQueryTaskEngine.treatHelpNotAcceptedMessage(): "
                                + numRefusesForHelpReoffer
                                + " refuses were expected but "
                                + numRefusesReceived + " were received!");
            }
        } else {
            logger.debug(Messages.getString("localQueryTaskEngine.ignored"));
        }
        // a_blocked = false;
        notifyAll();
    }

    private synchronized void sendOfferHelpToNeighbors() throws RemoteException {
        // a_blocked = true;
        numLastHelpOffer++;
        if (idNeighbor[NEIGHBOR_NORTH] != NEIGHBOR_ABSENT)
            getLQT(idNeighbor[NEIGHBOR_NORTH]).offerHelp(id, id,
                    NEIGHBOR_SOUTH, numLastHelpOffer);
        if (idNeighbor[NEIGHBOR_EAST] != NEIGHBOR_ABSENT)
            getLQT(idNeighbor[NEIGHBOR_EAST]).offerHelp(id, id, NEIGHBOR_WEST,
                    numLastHelpOffer);
        if (idNeighbor[NEIGHBOR_SOUTH] != NEIGHBOR_ABSENT)
            getLQT(idNeighbor[NEIGHBOR_SOUTH]).offerHelp(id, id,
                    NEIGHBOR_NORTH, numLastHelpOffer);
        if (idNeighbor[NEIGHBOR_WEST] != NEIGHBOR_ABSENT)
            getLQT(idNeighbor[NEIGHBOR_WEST]).offerHelp(id, id, NEIGHBOR_EAST,
                    numLastHelpOffer);
        numRefusesReceived = 0;
        logger.debug(Messages.getString("localQueryTaskEngine.helpOffer",
                numLastHelpOffer));
        // a_blocked = false;
        notifyAll();
    }

    private synchronized void treatHelpOffer(LQT_Msg_HelpOffer msg)
            throws RemoteException {
        // a_blocked = true;
        if (state == ST_IDLE) {
            logger.debug(Messages.getString(
                    "localQueryTaskEngine.propagateOffer", new Object[] {
                            msg.getOfferNumber(), msg.getIdHelper(),
                            msg.getIdSender() }));
            propagateHelpOffer(msg);
            if (getStatistics) {
                statistics.helpOfferForwarded();
            }
        } else if (state == ST_PROCESSING_QUERY) {
            logger.debug(Messages.getString("localQueryTaskEngine.acceptOffer",
                    new Object[] { msg.getOfferNumber(), msg.getIdHelper(),
                            msg.getIdSender() }));
            getLQT(msg.getIdHelper()).acceptHelp(this.id, msg.getOfferNumber());
            if (getStatistics) {
                statistics.helpOfferAcceptanceSent();
            }
            logger.debug(Messages.getString(
                    "localQueryTaskEngine.acceptanceMsg", msg.getIdHelper()));
        }
        // a_blocked = false;
        notifyAll();
    }

    // Must be called by a synchronized method
    private void propagateHelpOffer(LQT_Msg_HelpOffer msg)
            throws RemoteException {
        switch (msg.getSenderPosition()) {
        case NEIGHBOR_NORTH: {
            if (idNeighbor[NEIGHBOR_SOUTH] != NEIGHBOR_ABSENT)
                getLQT(idNeighbor[NEIGHBOR_SOUTH])
                        .offerHelp(id, msg.getIdHelper(), NEIGHBOR_NORTH,
                                msg.getOfferNumber());
            if ((idNeighbor[NEIGHBOR_WEST] == NEIGHBOR_ABSENT)
                    && (idNeighbor[NEIGHBOR_EAST] == NEIGHBOR_ABSENT)) {
                // This node is the only one in the last line. Send a refusing
                // message.
                getLQT(msg.getIdHelper()).refuseHelp(id, msg.getOfferNumber());
                logger.debug(Messages.getString(
                        "localQueryTaskEngine.refusing", new Object[] {
                                msg.getOfferNumber(), msg.getIdHelper(),
                                msg.getIdSender() }));
            } else {
                if (column < numNodesPerLine / 2) {
                    // Node is in the west part. Start propagating to east.
                    if (idNeighbor[NEIGHBOR_EAST] != NEIGHBOR_ABSENT)
                        getLQT(idNeighbor[NEIGHBOR_EAST]).offerHelp(id,
                                msg.getIdHelper(), NEIGHBOR_WEST,
                                msg.getOfferNumber());
                    if (this.idNeighbor[NEIGHBOR_WEST] != NEIGHBOR_ABSENT)
                        getLQT(idNeighbor[NEIGHBOR_WEST]).offerHelp(id,
                                msg.getIdHelper(), NEIGHBOR_EAST,
                                msg.getOfferNumber());
                } else {
                    // Node is in the east part. Start propagating to west.
                    if (idNeighbor[NEIGHBOR_WEST] != NEIGHBOR_ABSENT)
                        getLQT(idNeighbor[NEIGHBOR_WEST]).offerHelp(id,
                                msg.getIdHelper(), NEIGHBOR_EAST,
                                msg.getOfferNumber());
                    if (idNeighbor[NEIGHBOR_EAST] != NEIGHBOR_ABSENT)
                        getLQT(idNeighbor[NEIGHBOR_EAST]).offerHelp(id,
                                msg.getIdHelper(), NEIGHBOR_WEST,
                                msg.getOfferNumber());
                }
            }
            break;
        }
        case NEIGHBOR_SOUTH: {
            if (idNeighbor[NEIGHBOR_NORTH] != NEIGHBOR_ABSENT)
                getLQT(idNeighbor[NEIGHBOR_NORTH])
                        .offerHelp(id, msg.getIdHelper(), NEIGHBOR_SOUTH,
                                msg.getOfferNumber());
            if (column < numNodesPerLine / 2) {
                // Node is in the west part. Start propagating to east.
                if (idNeighbor[NEIGHBOR_EAST] != NEIGHBOR_ABSENT)
                    getLQT(idNeighbor[NEIGHBOR_EAST]).offerHelp(id,
                            msg.getIdHelper(), NEIGHBOR_WEST,
                            msg.getOfferNumber());
                if (this.idNeighbor[NEIGHBOR_WEST] != NEIGHBOR_ABSENT)
                    getLQT(idNeighbor[NEIGHBOR_WEST]).offerHelp(id,
                            msg.getIdHelper(), NEIGHBOR_EAST,
                            msg.getOfferNumber());
            } else {
                // Node is in the east part. Start propagating to west.
                if (idNeighbor[NEIGHBOR_WEST] != NEIGHBOR_ABSENT)
                    getLQT(idNeighbor[NEIGHBOR_WEST]).offerHelp(id,
                            msg.getIdHelper(), NEIGHBOR_EAST,
                            msg.getOfferNumber());
                if (idNeighbor[NEIGHBOR_EAST] != NEIGHBOR_ABSENT)
                    getLQT(idNeighbor[NEIGHBOR_EAST]).offerHelp(id,
                            msg.getIdHelper(), NEIGHBOR_WEST,
                            msg.getOfferNumber());
            }
            break;
        }
        case NEIGHBOR_WEST: {
            if (idNeighbor[NEIGHBOR_EAST] != NEIGHBOR_ABSENT)
                getLQT(idNeighbor[NEIGHBOR_EAST]).offerHelp(id,
                        msg.getIdHelper(), NEIGHBOR_WEST, msg.getOfferNumber());
            else {
                // No one else to propagate the offer. Send a refusing message.
                getLQT(msg.getIdHelper()).refuseHelp(id, msg.getOfferNumber());
                logger.debug(Messages.getString(
                        "localQueryTaskEngine.refusing", new Object[] {
                                msg.getOfferNumber(), msg.getIdHelper(),
                                msg.getIdSender() }));
            }
            break;
        }
        case NEIGHBOR_EAST: {
            // If this node is reponsible for east messages arriving at last
            // line, propagate to south
            if (respForEastMsgLastLine)
                getLQT(idNeighbor[NEIGHBOR_SOUTH])
                        .offerHelp(id, msg.getIdHelper(), NEIGHBOR_NORTH,
                                msg.getOfferNumber());

            if (this.idNeighbor[NEIGHBOR_WEST] != NEIGHBOR_ABSENT)
                getLQT(this.idNeighbor[NEIGHBOR_WEST]).offerHelp(id,
                        msg.getIdHelper(), NEIGHBOR_EAST, msg.getOfferNumber());
            else {
                // No one else to propagate the offer. Send a refusing message.
                getLQT(msg.getIdHelper()).refuseHelp(id, msg.getOfferNumber());
                logger.debug(Messages.getString(
                        "localQueryTaskEngine.refusing", new Object[] {
                                msg.getOfferNumber(), msg.getIdHelper(),
                                msg.getIdSender() }));
            }
            break;
        }
        default:
            throw new IllegalArgumentException(
                    "LocalQueryTaskEngine.propagateHelpOffer(): invalid neighbor position ("
                            + msg.getSenderPosition() + ").");
        }
    }

    // getPartOfRange() - called by who is giving help
    public Range getPartOfRange() throws RemoteException {
        Range range = this.range.cutTail(HELP_WORKLOAD_FRACTION);
        if (getStatistics) {
            statistics.helpOfferReceived();
        }
        return range;
    }

    public ResultComposerDistributed getGroupResultComposerDistributed() {
        return groupResultComposerDistributed;
    }

    public ResultComposerDistributed getSortResultComposerDistributed() {
        return sortResultComposerDistributed;
    }

    public synchronized ResultComposerDistributed getGroupResultComposerDistributed(
            int id) throws RemoteException {
        return getLQT(id).getGroupResultComposerDistributed();
    }

    public synchronized ResultComposerDistributed getSortResultComposerDistributed(
            int id) throws RemoteException {
        return getLQT(id).getSortResultComposerDistributed();
    }
}
