/**
 * 
 */
package org.pargres.resultcomposer;

import java.rmi.RemoteException;

/**
 * @author kinder
 * 
 */
public interface ResultComposerDistributed extends ResultComposer {
    public void sendResultsToGlobalComposer() throws RemoteException,
            InterruptedException, Exception;

    public void finishDistribution() throws RemoteException;
}
