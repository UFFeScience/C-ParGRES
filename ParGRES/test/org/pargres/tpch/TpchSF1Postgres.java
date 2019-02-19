/*
 * TpchSF1.java
 *
 * Created on 25 mars 2004, 16:07
 */

package org.pargres.tpch;

/**
 *
 * @author  lima
 */

public class TpchSF1Postgres extends Tpch {
    
    public TpchSF1Postgres() {
        super( 1 );
    }
    
    public TpchTableStatistics getTableStatistics(String tableName) throws IllegalArgumentException {
        TpchTableStatistics statistics;
        
        if( tableName.equals( "Lineitem" ) )
            statistics = new TpchTableStatistics( "Lineitem", 6001215, "l_orderkey", 1, 6000000, 1, 7, 1.0002025, 0.015 );
        else if( tableName.equals( "Orders" ) )
            statistics = new TpchTableStatistics( "Orders", 1500000, "o_orderkey", 1, 6000000, 1, 1, 0.25, 0.903 );
        else
            throw new IllegalArgumentException( "TpchSF1Postgres Exception: No statistics for table " + tableName );
        
        return statistics;
    }
    
    public int[] getZipfSkewedPartitionSizes(int numPartitions) {
        int []partitionSizes;
        int countCheck;
        partitionSizes = new int[numPartitions];
        switch( numPartitions ) {
            case 1: {
                partitionSizes[0] = 6000000;
                break;
            }
            case 2: {
                partitionSizes[0] = 2543665;
                partitionSizes[1] = 3456335;
                break;
            }
            case 4: {
                partitionSizes[0] = 1941992;
                partitionSizes[1] = 601673;
                partitionSizes[2] = 1263300;
                partitionSizes[3] = 2193035;
                break;
            }
            case 8: {
                partitionSizes[0] = 438584;
                partitionSizes[1] = 1503408;
                partitionSizes[2] = 224548;
                partitionSizes[3] = 377125;
                partitionSizes[4] = 495831;
                partitionSizes[5] = 767469;
                partitionSizes[6] = 1292888;
                partitionSizes[7] = 900147;
                break;
            }
            case 16: {
                partitionSizes[0]  = 286721;
                partitionSizes[1]  = 151863;
                partitionSizes[2]  = 236613;
                partitionSizes[3]  = 1266795;
                partitionSizes[4]  = 131620;
                partitionSizes[5]  = 92928;
                partitionSizes[6]  = 242260;
                partitionSizes[7]  = 134865;
                partitionSizes[8]  = 135712;
                partitionSizes[9]  = 360119;
                partitionSizes[10] = 241183;
                partitionSizes[11] = 526286;
                partitionSizes[12] = 433646;
                partitionSizes[13] = 859242;
                partitionSizes[14] = 293951;
                partitionSizes[15] = 606196;
                break;
            }
            case 32: {
                partitionSizes[0]  = 152491;
                partitionSizes[1]  = 134230;
                partitionSizes[2]  = 54508;
                partitionSizes[3]  = 97355;
                partitionSizes[4]  = 40139;
                partitionSizes[5]  = 196474;
                partitionSizes[6]  = 168612;
                partitionSizes[7]  = 1098183;
                partitionSizes[8]  = 93158;
                partitionSizes[9]  = 38462;
                partitionSizes[10] = 45839;
                partitionSizes[11] = 47089;
                partitionSizes[12] = 58293;
                partitionSizes[13] = 183967;
                partitionSizes[14] = 72825;
                partitionSizes[15] = 62040;
                partitionSizes[16] = 57048;
                partitionSizes[17] = 78664;
                partitionSizes[18] = 276892;
                partitionSizes[19] = 83227;
                partitionSizes[20] = 70956;
                partitionSizes[21] = 170227;
                partitionSizes[22] = 176436;
                partitionSizes[23] = 349850;
                partitionSizes[24] = 245467;
                partitionSizes[25] = 188179;
                partitionSizes[26] = 306288;
                partitionSizes[27] = 552954;
                partitionSizes[28] = 167564;
                partitionSizes[29] = 126387;
                partitionSizes[30] = 502937;
                partitionSizes[31] = 103259;
                break;
            }
            default:
                throw new IllegalArgumentException( "TpchSF1Postgres.getZipfSkewedPartitionSizes(): not supported number of skewed partition sizes -> " + numPartitions );
        }
        // checagem
        countCheck = 0;
        for( int i = 0; i < partitionSizes.length; i++ )
            countCheck += partitionSizes[i];
        if( countCheck != 6000000 )
            throw new RuntimeException( "TpchSF1Postgres.getZipfSkewedPartitionSizes(): Check failed!" );
        return partitionSizes;
    }
    
}
