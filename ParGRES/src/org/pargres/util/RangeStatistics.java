/*
 * RelationStatistics.java
 *
 * Created on 9 fevrier 2004, 13:40
 */

package org.pargres.util;

/**
 *
 * @author  lima 
 */

import java.io.Serializable;

public class RangeStatistics implements Serializable {
    
    /**
	 * 
	 */
	private static final long serialVersionUID = 3978143257505314360L;
	private float a_meanNumTuplesPerValue;
    //private int a_minNumTuplesPerValue;
    //private int a_maxNumTuplesPerValue;
    private long a_numTableTuples; // number of tuples on the table
    private float a_maxSizeRatio; // informed during object creation
    
    /** Creates a new instance of RelationStatistics */
    public RangeStatistics( float meanNumTuplesPerValue, 
							//int minNumTuplesPerValue, 
                            //int maxNumTuplesPerValue, 
                            long numTableTuples,
                            float maxSizeRatio ) {
        a_meanNumTuplesPerValue = meanNumTuplesPerValue;
        //a_minNumTuplesPerValue = minNumTuplesPerValue;
        //a_maxNumTuplesPerValue = maxNumTuplesPerValue;
        a_numTableTuples = numTableTuples;
        a_maxSizeRatio = maxSizeRatio;
    }
    
    public float getMeanNumTuplesPerValue() {
        return a_meanNumTuplesPerValue;
    }
    /*
    public int getMinNumTuplesPerValue() {
        return a_minNumTuplesPerValue;
    }
    
    public int getMaxNumTuplesPerValue() {
        return a_maxNumTuplesPerValue;
    }
    */
    public long getTotalNumberOfTuples() {
        return a_numTableTuples;
    }
    
	public float getMaxSizeRatio() {
        return a_maxSizeRatio;
    }
}
