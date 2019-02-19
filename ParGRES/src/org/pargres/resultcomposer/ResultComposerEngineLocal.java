/*
 * ResultComposerEngine_Local.java
 *
 * Created on 25 mai 2004, 16:28
 */

package org.pargres.resultcomposer;

import java.rmi.RemoteException;
import java.sql.ResultSet;
import java.sql.SQLException;

import org.pargres.commons.logger.Logger;
import org.pargres.commons.translation.Messages;
import org.pargres.cqp.queryplanner.QueryInfo;
import org.pargres.grouper.Grouper;
import org.pargres.localquerytask.LocalQueryTask;

public class ResultComposerEngineLocal extends ResultComposerEngine implements
        ResultComposerLocal {

    private Logger logger = Logger.getLogger(ResultComposerEngineLocal.class);
    private static final long serialVersionUID = 3256719589399344441L;
    // private final int TUPLES_THRESHOLD = 10000;
    private ResultComposerGlobal globalResultComposer;
    private int numlqts;
    private double id;
    private int resultsSent;
    private LocalQueryTask lqt;

    /** Creates a new instance of ResultComposerEngine_Local */
    public ResultComposerEngineLocal(double id, ResultComposerGlobal global,
            int numlqts, QueryInfo qi, LocalQueryTask lqt)
            throws RemoteException, SQLException {
        super(id, qi, numlqts, id, false);
        this.globalResultComposer = global;
        this.id = id;
        this.numlqts = numlqts;
        this.resultsSent = 0;
        this.lqt = lqt;
    }

    public void run() {
        try {
            logger.debug(Messages.getString("resultComposerEngineLocal.init",
                    id));
            long begin = System.currentTimeMillis();
            synchronized (this) {
                while (!finishingRequested || !resultQueue.isEmpty()) {
                    if (resultQueue.isEmpty()) {
                        wait();
                    } else {
                        ResultSet result = resultQueue.pop();
                        grouper.insert(result);
                        // if (this.grouper.size() > TUPLES_THRESHOLD)
                        // sendResultsToGlobalComposer();
                    }
                }
                notifyAll();
            }
            long end = System.currentTimeMillis();
            logger.debug(Messages.getString(
                    "resultComposerEngineLocal.finishLRC", new Object[] { id,
                            (end - begin) }));
            sendResultsToGlobalComposer();
            setFinished();
            if (distributedComposition)
                for (int i = 0; i < numlqts; ++i)
                    lqt.getGroupResultComposerDistributed(i).finishDistribution();
            else if (distributedSort)
                for (int i = 0; i < numlqts; ++i)
                    lqt.getSortResultComposerDistributed(i).finishDistribution();
            
        } catch (Exception e) {
            logger.error("ResultComposer Exception: " + e.getMessage());
            e.printStackTrace();
        }
    }

    public synchronized void sendResultsToGlobalComposer()
            throws RemoteException {
        ResultSet result;

        // if (result.size() > 0)
        if (!(distributedComposition || distributedSort)) {
            // send results to master
            result = grouper.getAggregatedResult();
            if (result != null)
                globalResultComposer.addResult(result);
        } else {
            logger.debug(Messages.getString(
                    "resultComposerEngineLocal.sendingResults", id));
            // send results to node responsible for the groups
            for (int i = 0; (i < numlqts) && (resultsSent < grouper.size()); ++i) {
                if (distributedComposition){
                    result = grouper.getAggregatedResult(i, Grouper.HASH);
                    if (result != null)
                        lqt.getGroupResultComposerDistributed(i).addResult(result);
                }    
                else{
                    result = grouper.getAggregatedResult(i, Grouper.RANGE);
                    if (result != null)
                        lqt.getSortResultComposerDistributed(i).addResult(result);
                }
            }
        }
        grouper.clear();
        notifyAll();
    }

    public double getId() {
        return this.id;
    }

}
