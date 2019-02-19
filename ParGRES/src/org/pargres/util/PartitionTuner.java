/*
 * PartitionTuner.java
 *
 * Created on 6 fevrier 2004, 14:35
 */

package org.pargres.util;

/**
 *
 * @author  lima
 */

import java.io.PrintStream;
import java.io.Serializable;

public abstract class PartitionTuner implements Serializable {
    
    // Called by QueryExecutor when finished testing one size
    public abstract void setSizeResults( PartitionSize size );
    
    // Called by QueryExecutor when demanding a new partition size tu use
    public abstract PartitionSize getPartitionSize() throws IllegalThreadStateException;
    
    public abstract boolean stillTuning();
    
    public abstract void printTuningStatistics( PrintStream out );
    
    public abstract void reset();
}
