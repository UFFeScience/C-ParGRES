/*
 * TpchSF1_NonUniform_Postgres.java
 *
 * Created on 2 juin 2004, 18:54
 */

package org.pargres.tpch;

/**
 *
 * @author  lima
 */
public class TpchSF1_NonUniform_Postgres extends Tpch {
    
    /** Creates a new instance of TpchSF1_NonUniform_Postgres */
    public TpchSF1_NonUniform_Postgres() {
        super( 1 );
    }
    
    public TpchTableStatistics getTableStatistics(String tableName) {
        TpchTableStatistics statistics;
        
        if( tableName.equals( "Lineitem" ) )
            statistics = new TpchTableStatistics( "Lineitem", 6001215, "l_orderkey", 1824, 173999939, 1, 7, 0.03449, 0.015 );
        else if( tableName.equals( "Orders" ) )
            statistics = new TpchTableStatistics( "Orders", 1500000, "o_orderkey", 1824, 173999939, 1, 1, 0.00862, 0.903 );
        else
            throw new IllegalArgumentException( "TpchSF1Postgres Exception: No statistics for table " + tableName );
        
        return statistics;
    }
    
    public int[] getZipfSkewedPartitionSizes(int numPartitions) {
        return null;
    }
    
}
