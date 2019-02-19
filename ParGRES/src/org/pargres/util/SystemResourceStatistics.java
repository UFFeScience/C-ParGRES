/*
 * SystemResources.java
 *
 * Created on September 29, 2004, 12:38 PM
 */

package org.pargres.util;

/**
 *
 * @author  assis
 */

import java.io.Serializable;
import java.io.PrintStream;

public class SystemResourceStatistics implements Serializable {

    /**
	 * 
	 */
	private static final long serialVersionUID = 3258417209549599027L;
	private double a_numBlocksReadFromDisk;
    private double a_numBlocksWrittenIntoDisk;

    /** Creates a new instance of SystemResources */
    public SystemResourceStatistics() {
        a_numBlocksReadFromDisk = -1;
        a_numBlocksWrittenIntoDisk = -1;
    }

    public void setNumberOfBlocksRead( double numBlocks ) {
        a_numBlocksReadFromDisk = numBlocks;
    }

    public double getNumberOfBlocksRead() {
        return a_numBlocksReadFromDisk;
    }

    public void setNumberOfBlocksWritten( double numBlocks ) {
        a_numBlocksWrittenIntoDisk = numBlocks;
    }

    public double getNumberOfBlocksWritten() {
        return a_numBlocksWrittenIntoDisk;
    }

    public void print( PrintStream out ) {
      out.println(getClass().getName() + ": number of blocks read from disk - " + getNumberOfBlocksRead() );
      out.println(getClass().getName() + ": number of blocks written to disk - " + getNumberOfBlocksWritten() );
    }

}
