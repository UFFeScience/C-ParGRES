/*
 * ResultComposer_Local.java
 *
 * Created on 2 juin 2004, 14:07
 */

package org.pargres.resultcomposer;

import java.rmi.RemoteException;
import java.lang.InterruptedException;

public interface ResultComposerLocal extends ResultComposer {
	public void sendResultsToGlobalComposer() throws RemoteException,
			InterruptedException, Exception;
}
