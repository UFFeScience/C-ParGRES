/*
 * LQT_Message.java
 *
 * Created on 31 mai 2004, 17:26
 */

package org.pargres.localquerytask;

/**
 *
 * @author  Alex
 */

abstract public class LQT_Message {

    // Message types
    static public final int MSG_HELPOFFER = 0;
    static public final int MSG_HELPNOTACCEPTED = 1;
    static public final int MSG_INTERVALFINISHED = 2;
    static public final int MSG_FINISH = 3;
    static public final int MSG_HELPACCEPTED = 4;

    private int a_idSender;

    /** Creates a new instance of LQT_Message */
    public LQT_Message( int idSender ) {
	a_idSender = idSender;
    }

    abstract public int getType();

    public int getIdSender() {
	return a_idSender;
    }
}
