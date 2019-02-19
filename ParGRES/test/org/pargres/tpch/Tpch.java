/*
 * Tpch.java
 *
 * Created on 25 mars 2004, 16:03
 */

package org.pargres.tpch;

/**
 *
 * @author  lima
 */
public abstract class Tpch {

  public static final int NUM_TPCH_QUERIES = 22;

  private int a_scaleFactor;

  /** Creates a new instance of Tpch */
  public Tpch( int scaleFactor ) {
    a_scaleFactor = scaleFactor;
  }

  public int getScaleFactor() {
    return a_scaleFactor;
  }

  public abstract TpchTableStatistics getTableStatistics( String tableName );

  public abstract int[] getZipfSkewedPartitionSizes( int numPartitions );

}
