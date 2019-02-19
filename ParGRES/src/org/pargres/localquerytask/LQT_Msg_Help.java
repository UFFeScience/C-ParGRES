/*
 * LQT_Msg_Help.java
 *
 * Created on 31 mai 2004, 17:43
 */

package org.pargres.localquerytask;

/**
 *
 * @author  Alex
 */
abstract public class LQT_Msg_Help extends LQT_Message {

    private int a_offerNumber;
    
    /** Creates a new instance of LQT_Msg_Help */
    public LQT_Msg_Help( int idSender, int offerNumber ) {
        super( idSender );
        a_offerNumber = offerNumber;
    }
    
    public int getOfferNumber() {
        return a_offerNumber;
    }
}
