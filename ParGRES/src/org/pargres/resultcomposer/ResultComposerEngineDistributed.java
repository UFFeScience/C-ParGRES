package org.pargres.resultcomposer;

import java.rmi.RemoteException;
import java.sql.ResultSet;
import java.sql.SQLException;

import org.pargres.commons.logger.Logger;
import org.pargres.commons.translation.Messages;
import org.pargres.cqp.queryplanner.QueryInfo;
import org.pargres.grouper.Grouper;
import org.pargres.localquerytask.LocalQueryTask;

public class ResultComposerEngineDistributed extends ResultComposerEngine
        implements ResultComposerDistributed {

    private static final long serialVersionUID = 7656070220213847710L;
    private Logger logger = Logger
            .getLogger(ResultComposerEngineDistributed.class);
    // indicates if results have already been consumed. If 'yes', the Thread can
    // be finished
    ResultComposerGlobal global;
    int numlrcFinished;
    int numlqts;
    boolean requestFinished;
    private LocalQueryTask lqt;

    public ResultComposerEngineDistributed(double id,
            ResultComposerGlobal global, int numlqts, QueryInfo qi, LocalQueryTask lqt)
            throws RemoteException, SQLException {
        super(id, qi, numlqts, id, false);
        this.global = global;
        this.numlrcFinished = 0;
        this.numlqts = numlqts;
        this.requestFinished = false;
        this.lqt = lqt;
    }

    public void run() {
        try {
            logger.debug(Messages.getString(
                    "resultComposerEngineDistributed.init", id));
            acceptDistributedResults();
            setFinished();
            // waitForResultConsumption();
            sendResultsToGlobalComposer();
            logger.debug(Messages.getString(
                    "resultComposerEngineDistributed.finishing", id));
        } catch (Exception e) {
            logger.debug("ResultComposer Exception: " + e.getMessage());
            e.printStackTrace();
        }
    }

    public synchronized void sendResultsToGlobalComposer()
            throws RemoteException, InterruptedException {
        ResultSet result;

        while (!finished())
            wait();
        if (!distributedSort) {
            result = grouper.getAggregatedResult();
            logger.debug(Messages.getString(
                    "resultComposerEngineDistributed.sending", id));
            if (result != null)
                global.addResult(result);
        } else {
            for (int i = 0; i < numlqts; ++i) {
                result = grouper.getAggregatedResult(i, Grouper.RANGE);
                if (result != null)
                    lqt.getSortResultComposerDistributed(i).addResult(result);
            }
        }
        grouper.clear();
        notifyAll();
    }

    private synchronized void acceptDistributedResults()
            throws InterruptedException {
        // keep processing while there is no order to stop or while there are
        // results to be processed
        while (!requestFinished || !resultQueue.isEmpty()) {
            if (resultQueue.isEmpty()) {
                wait();
            } else {
                ResultSet result = resultQueue.pop();
                grouper.insert(result);
            }
        }
        notifyAll();
    }

    public synchronized void finishDistribution() throws RemoteException {
        numlrcFinished++;
        logger.debug(Messages.getString(
                "resultComposerEngineDistributed.finishDistribution",
                new Object[] { id, numlrcFinished, numlqts }));
        if (numlrcFinished == numlqts)
            requestFinished = true;
        notifyAll();
    }

}
