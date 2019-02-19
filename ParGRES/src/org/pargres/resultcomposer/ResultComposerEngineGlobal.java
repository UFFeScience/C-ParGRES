/*
 * ResultComposerEngine_Global.java
 *
 * Created on 25 mai 2004, 16:20
 */

package org.pargres.resultcomposer;

import java.rmi.RemoteException;
import java.sql.ResultSet;
import java.sql.SQLException;

import org.pargres.commons.logger.Logger;
import org.pargres.commons.translation.Messages;
import org.pargres.cqp.queryplanner.QueryInfo;

public class ResultComposerEngineGlobal extends ResultComposerEngine implements
        ResultComposerGlobal {

    private static final long serialVersionUID = 3258417231091480112L;
    private Logger logger = Logger.getLogger(ResultComposerEngineGlobal.class);
    // indicates if results have already been consumed. If 'yes', the Thread can
    // be finished
    protected boolean resultsConsumed;
    private int numLocalComposersFinished;

    /** Creates a new instance of ResultComposerEngine_Global */
    public ResultComposerEngineGlobal(int numlqts, QueryInfo qi)
            throws RemoteException, SQLException {
        super(0, qi, numlqts, numlqts, qi.isDistributedSort());
        this.resultsConsumed = false;
        this.numLocalComposersFinished = 0;
    }

    public void run() {
        try {
            logger.debug(Messages.getString("resultComposerEngineGlobal.init"));
            acceptResults();
            setFinished();
            waitForResultConsumption();
            logger.debug(Messages.getString("resultComposerEngineGlobal.finishing"));
        } catch (Exception e) {
            logger.debug("ResultComposer Exception: " + e.getMessage());
            e.printStackTrace();
        }
    }

    public synchronized ResultSet getResult() throws RemoteException,
            InterruptedException, Exception {
        if (this.resultsConsumed)
            throw new IllegalThreadStateException(
                    "ResultComposer Exception (getResult): results have already been consumed!");
        else {
            ResultSet result;

            while (!finished()) {
                wait();
            }
            result = grouper.finish();
            grouper.clear();
            resultsConsumed = true;
            notifyAll();
            return result;
        }
    }

    protected synchronized void waitForResultConsumption()
            throws InterruptedException {
        logger.debug(Messages.getString("resultComposerEngineGlobal.waitingForResults"));
        while (!resultsConsumed)
            wait();
        logger.debug(Messages.getString("resultComposerEngineGlobal.resultsConsumed"));
        notifyAll();
    }

    public synchronized void addFinishedLocalComposer() throws RemoteException {
        ++numLocalComposersFinished;
        notifyAll();
    }

    public synchronized int getNumFinishedLocalComposers() throws RemoteException {
        return numLocalComposersFinished;
    }

}
