/*
 * PartitionTunerStartSmall.java
 *
 * Created on 6 fevrier 2004, 14:35
 */

package org.pargres.util;

/**
 *
 * @author  lima
 */

import java.io.PrintStream;

 
/**
    Tune starting with only one key. At each iteraction, double. Stops when the estimated time is worse. 
    Only one size is tested at each time
 */

public class PartitionTunerMeanTime extends PartitionTuner {

    /**
	 * 
	 */
	private static final long serialVersionUID = 3691042054025197108L;
	// PartitionTuner States
    private final int INITIAL = 0;
    private final int SEARCHING = 1;
    private final int SET = 2;
    private final int RESTARTING = 3;
    
    private final int NUMBER_OF_EXECUTIONS = 2; // number of executions to test each different size
    private final int INITIAL_NUMBER_OF_KEYS = 1024; // number of keys to the first size that will be tested

    private final float INITIAL_SIZE_GROWTH_TAX = (float) 1.0;
    private final float RESTART_SIZE_GROWTH_TAX = INITIAL_SIZE_GROWTH_TAX * (float) 0.2; 
    private final float REDUCTION_IN_SIZE_GROWTH_TAX = (float) 0.75;
    private final float MIN_SIZE_GROWTH_TAX = (float) 0.1;
    private final float SIZE_REDUCTION_WHILE_RESTARTING = (float) 0.05;
    
    private final int MAX_CHANCES_FOR_SET = 3;

    
    private final float MEANTIME_GROWTH_TOLERANCE = (float) 0.25; // to be applied over the "size increasing tax" being used
    private final float MEANTIME_SET_TOLERANCE = (float) 0.1; // to be used while evaluating current size
    
    private RangeStatistics a_rangeStatistics; // to help calculating partition sizes in terms of number of key values and ratio

    private int a_state; // To store tuner state

    private int a_currentNumKeys; // currently used size (in terms of keys)
    private float a_meanTimeCurrentNumKeys; // execution time of the best number of keys
    //private int a_greatestNumKeys; // greatest number of keys already tested
    private float a_sizeGrowthTax; // growth tax currently being used
    private int a_numTimesSetWorse; // number of times the mean exec time was worse than when it was SET
    //private float a_meanExecTimeBeforeRestart; // mean execution time before RESTARTING state
    
    // for max size
    private int a_maxNumberOfKeys; // to establish a limit over the partition size
    private int a_numTimesMaxWouldNotBeRespected; // only statistics
    
    // for re-search
    private int a_numGreatestWasMet; // statistics
    private int a_numReTunings; // statistics
    private int a_numSets; // statistics
    
    // Public  Methods ----------------------------------------------
    
    /** Creates a new instance of PartitionTuner */
    public PartitionTunerMeanTime(RangeStatistics rangeStatistics) {
        a_state = INITIAL;
        a_rangeStatistics = rangeStatistics;

        a_maxNumberOfKeys = calculateNumberOfKeys( a_rangeStatistics.getMaxSizeRatio() );
        a_numTimesMaxWouldNotBeRespected = 0;
        a_numGreatestWasMet = 0;
        a_numReTunings = 0;        
    }
    
    public boolean stillTuning() {
        return true; // always tuning
    }

    // Called by QueryExecutor when finished testing one size
    // When using many QueryExecutors, make this method SYNCHRONIZED
    public void setSizeResults( PartitionSize size ) throws IllegalThreadStateException {

        switch( a_state ) {
            case INITIAL: {
                throw new IllegalThreadStateException( "Some object is trying to set results before first test" );
            }
            case SEARCHING: {
                if( a_currentNumKeys == 0 ) {
                    a_currentNumKeys = size.numberOfKeys(); // first set operation
                    a_meanTimeCurrentNumKeys = size.getMeanExecutionTime();
                    a_sizeGrowthTax = INITIAL_SIZE_GROWTH_TAX;
                    if( a_currentNumKeys == a_maxNumberOfKeys ) {
                        a_state = SET; // Max size. Cannot grow.
                        a_numTimesSetWorse = 0;
                    }
                }
                else if( size.getMeanExecutionTime() <= (a_meanTimeCurrentNumKeys * (1.0 + MEANTIME_GROWTH_TOLERANCE * a_sizeGrowthTax ) ) ) {
                    // Size is better than best. Change best. Continue searching.
                    a_currentNumKeys = size.numberOfKeys();
                    a_meanTimeCurrentNumKeys = size.getMeanExecutionTime();
                    if( a_currentNumKeys == a_maxNumberOfKeys ) {
                        a_state = SET; // Max size. Cannot grow.
                        a_numTimesSetWorse = 0;
                    }
                } else {
                    // Size is worse than best. Reduce growth tax.
                    a_sizeGrowthTax = a_sizeGrowthTax * ((float)1.0 - REDUCTION_IN_SIZE_GROWTH_TAX);
                    if( a_sizeGrowthTax < MIN_SIZE_GROWTH_TAX ) {
                        a_state = SET;
                        a_numTimesSetWorse = 0;
                    }
                }
                break;
            }
            case SET: {                
                if( size.numberOfKeys() != a_currentNumKeys )
                    throw new IllegalArgumentException( "Size was expected to be equal to current. current = " + a_currentNumKeys + ". Size = " + size.numberOfKeys() );
                a_numSets++;
                if( size.getMeanExecutionTime() > (a_meanTimeCurrentNumKeys * (1.0 + MEANTIME_SET_TOLERANCE) ) ) {
                    a_numTimesSetWorse++;
                    //if( a_numTimesSetWorse == 1 )
                    //    a_meanExecTimeBeforeRestart = a_meanTimeCurrentNumKeys;
                    if (a_numTimesSetWorse > MAX_CHANCES_FOR_SET) {
                        a_state = RESTARTING; // Best size is going worse. Re-Start tuning.
                        a_numReTunings++;
                        a_numTimesSetWorse = 0;
                    }
                }
                else {
                    a_numTimesSetWorse = 0;
                    if( size.getMeanExecutionTime() < a_meanTimeCurrentNumKeys )
                        a_meanTimeCurrentNumKeys = size.getMeanExecutionTime();
                }
                break;
            }
            case RESTARTING: {
                a_currentNumKeys = size.numberOfKeys(); // first set operation
                a_meanTimeCurrentNumKeys = size.getMeanExecutionTime();
                if( a_currentNumKeys == a_maxNumberOfKeys ) { 
                    a_state = SET; // Max size. Cannot grow.
                    a_numTimesSetWorse = 0;
                }   
                else {
                    a_state = SEARCHING;
                    a_sizeGrowthTax = RESTART_SIZE_GROWTH_TAX;
                }
                break;
            }
            default: 
                throw new IllegalThreadStateException( "PartitionTuner at an unknown state: " + a_state );
        }
    }
    
    // Called by QueryExecutor when demanding a new partition size tu use
    // When using many QueryExecutors, make this method SYNCHRONIZED
    public PartitionSize getPartitionSize() throws IllegalThreadStateException {
        PartitionSize size = null;
        switch( a_state ) {
            case INITIAL: {
                a_currentNumKeys = 0;
                a_meanTimeCurrentNumKeys = 0;
                //a_greatestNumKeys = 0;
                size = new PartitionSize( calculateRatio( INITIAL_NUMBER_OF_KEYS ), INITIAL_NUMBER_OF_KEYS, NUMBER_OF_EXECUTIONS );
                a_state = SEARCHING;
                break;
            }
            case SET: {
                size = new PartitionSize( calculateRatio( a_currentNumKeys ), a_currentNumKeys, 1 );
                break;
            }
            case SEARCHING: {
                int numkeys;
                numkeys = (int)Math.ceil( (double)a_currentNumKeys * (1.0 + a_sizeGrowthTax) );
                if( numkeys > a_maxNumberOfKeys ) {
                    numkeys = a_maxNumberOfKeys;
                    a_numTimesMaxWouldNotBeRespected++;                            
                }
                size = new PartitionSize( calculateRatio( numkeys ), numkeys, NUMBER_OF_EXECUTIONS );
                break;
            }
            case RESTARTING: {
                int numkeys;
                numkeys = (int)Math.ceil( (double)a_currentNumKeys / (1.0 + SIZE_REDUCTION_WHILE_RESTARTING ) );
                if( numkeys < 1 )
                    numkeys = 1;
                size = new PartitionSize( calculateRatio( numkeys ), numkeys, NUMBER_OF_EXECUTIONS );
                break;                
            }
            default: 
                throw new IllegalThreadStateException( "PartitionTuner at an unknown state: " + a_state );
        }
        
        /*
        if( size.numberOfKeys() > a_greatestNumKeys )
            a_greatestNumKeys = size.numberOfKeys();
         */
        
        return size;
    }
    
    public void printTuningStatistics( PrintStream out ) {
        out.println( "Upper limit for the number of keys: " + a_maxNumberOfKeys );
        out.println( "Number of Re-Searchs do to greatest size being met: " + a_numGreatestWasMet );
        out.println( "Number of Re-Tuning operations: " + a_numReTunings );
        out.println( "Number of SET states: " + a_numSets );
        out.println( "The limit would not be respected " + a_numTimesMaxWouldNotBeRespected + " times.");
        
    }
       
    // Private Methods ----------------------------------------------
    
    private float calculateRatio( int numberOfKeys ) {
        return (float) ((((float)numberOfKeys) * a_rangeStatistics.getMeanNumTuplesPerValue() ) / a_rangeStatistics.getTotalNumberOfTuples() );
    } 
    
    private int calculateNumberOfKeys( float ratio ) {
        return (int) ((ratio * a_rangeStatistics.getTotalNumberOfTuples() ) / a_rangeStatistics.getMeanNumTuplesPerValue());
    }
    
    public void reset() {
        a_state = INITIAL;
    }
    
}
