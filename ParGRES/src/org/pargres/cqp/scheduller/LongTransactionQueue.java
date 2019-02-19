/*
 * @author <a href="mailto:bmiranda@cos.ufrj.br">Bernardo Miranda</a>
 * Pargres Project <http://pargres.nacad.ufrj.br>
 */
package org.pargres.cqp.scheduller;

import java.util.LinkedList;

import org.pargres.commons.logger.Logger;
import org.pargres.commons.translation.Messages;

public class LongTransactionQueue {
	private Logger logger = Logger.getLogger(QueryScheduler.class);	
	
	private Thread blockingThread = null;
	private LinkedList<Thread> queue = new LinkedList<Thread>();

	public synchronized void wait(Schedullable s) {
		logger.debug(Messages.getString("longTransactionQueue.wait",s.queryNumber));
			try {
				Thread t = Thread.currentThread();
				queue.add(t);
				while(isBlocked(t)) {
					logger.debug(Messages.getString("longTransactionQueue.blocked",new Object[]{s.queryNumber,t.getId()}));
					this.wait();
					if(t.getId() == queue.peek().getId())
						break;
					else
						logger.debug(Messages.getString("longTransactionQueue.notYet",s.queryNumber));
				}
				logger.debug(Messages.getString("longTransactionQueue.passed",new Object[]{s.queryNumber,t.getId()}));
				queue.poll();
			} catch (Exception e) {
				logger.error(e);
				e.printStackTrace();				
			}
	}
	
	public synchronized boolean isBlocked(Thread t) {
		if(blockingThread == null) {
			logger.debug(Messages.getString("longTransactionQueue.blockingIsNull"));
			return false;		
		}
		if(blockingThread.getId() == t.getId()) {
			logger.debug(Messages.getString("longTransactionQueue.blockingIsSame"));			
			return false;		
		}
		return true;
	}

	public synchronized void unblock() {
		//while(queue.size() != 0) {
			blockingThread = null;		
			this.notifyAll();
			Thread.yield();
		//}
		//Thread.yield();
		logger.debug(Messages.getString("longTransactionQueue.unblock",Thread.currentThread().getId()));		
	}

	public synchronized void block() {		
		blockingThread = Thread.currentThread();
		logger.debug(Messages.getString("longTransactionQueue.block",+blockingThread.getId()));		
	}	
}
