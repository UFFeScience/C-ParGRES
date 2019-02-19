/*
 * LQT_Message_Queue.java
 *
 * Created on 31 mai 2004, 17:59
 */

package org.pargres.localquerytask;

/**
 *
 * @author  Alex
 */

import java.util.LinkedList;

public class LQT_Message_Queue {

    LinkedList<LQT_Message> a_list;

    /** Creates a new instance of LQT_Message_Queue */
    public LQT_Message_Queue() {
	a_list = new LinkedList<LQT_Message>();
    }

    public synchronized void addMessage( LQT_Message msg ) {
	if( (msg.getType() == LQT_Message.MSG_FINISH) || (msg.getType() == LQT_Message.MSG_HELPACCEPTED) )
	    a_list.addFirst( msg ); // finish messages are prioritary
	else
	    a_list.addLast( msg );
	notifyAll();
    }

    public synchronized LQT_Message getMessage() throws InterruptedException {
	while( a_list.size() == 0 )
	    wait();
	return (LQT_Message) a_list.removeFirst();
    }

    public synchronized int size() {
	int vsize = a_list.size();
	notifyAll();
	return vsize;
    }
}
