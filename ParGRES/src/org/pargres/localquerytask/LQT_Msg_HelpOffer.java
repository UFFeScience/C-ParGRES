/*
 * LQT_Msg_HelpOffer.java
 *
 * Created on 31 mai 2004, 17:33
 */

package org.pargres.localquerytask;

/**
 *
 * @author  Alex
 */
public class LQT_Msg_HelpOffer extends LQT_Msg_Help {
    
    private int a_idHelper; // id of the LQT offering help
    private int a_senderPosition; // position of the neighbor that sent the message
    
    /** Creates a new instance of LQT_Msg_HelpOffer */
    public LQT_Msg_HelpOffer( int idSender, int idHelper, int senderPosition, int offerNumber ) {
        super( idSender, offerNumber );
        a_idHelper = idHelper;
        a_senderPosition = senderPosition;
    }
    
    public int getType() {
        return MSG_HELPOFFER;
    }
    
    public int getIdHelper() {
        return a_idHelper;
    }
    
    public int getSenderPosition() {
        return a_senderPosition;
    }
}
