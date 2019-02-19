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

public class LQT_Message_Stack {

    LinkedList<LQT_Message> a_list;

    /** Creates a new instance of LQT_Message_Queue */
    public LQT_Message_Stack() {
      a_list = new LinkedList<LQT_Message>();
    }

    public synchronized void push( LQT_Message msg ) {
      a_list.addLast( msg ); // finish messages are prioritary
      notifyAll();
    }

    public synchronized LQT_Message pop() throws InterruptedException {
      while( a_list.size() == 0 )
	wait();
      return (LQT_Message) a_list.removeLast();
    }

    public synchronized int size() {
      int vsize = a_list.size();
      notifyAll();
      return vsize;
    }
}
