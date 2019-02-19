/*
 * NQP_LoadInfo.java
 *
 * Created on 3 juin 2004, 00:37
 */

package org.pargres.nodequeryprocessor;

/**
 *
 * @author  Alex
 */


public class NqpLoadInfo implements Comparable {
    
    private int a_load;
    private int a_nqpId;
    private NodeQueryProcessor a_nqp;
    
    /** Creates a new instance of NQP_LoadInfo */
    public NqpLoadInfo( int nqpId, NodeQueryProcessor nqp, int initialLoad ) {
        a_nqpId = nqpId;
        a_nqp = nqp;
        a_load = initialLoad;
    }
    
    public int compareTo( Object o ) {
        NqpLoadInfo other = (NqpLoadInfo)o;
        int diff;
        
        diff = a_load - other.a_load;
        if( diff == 0 ) {
            diff = a_nqpId - other.a_nqpId;
            return diff;
        }
        return diff;
    }
    
    public int getNQP_Id() {
        return a_nqpId;
    }
    
    public int getLoad() {
        return a_load;
    }
    
    public NodeQueryProcessor getNQP() {
        return a_nqp;
    }
    
    public void increaseLoad( int inc ) {
        a_load += inc;
    }

    public void decreaseLoad( int dec ) {
        a_load -= dec;
        if( a_load < 0 )
            throw new IllegalArgumentException( "NQP_LoadInfo.decreaseLoad(): negative load value after decreasing: " + a_load );
    }
    
    public String toString() {
        return "( Load = " + a_load + ", Id_NQP = " + a_nqpId + " )";
    }
}
