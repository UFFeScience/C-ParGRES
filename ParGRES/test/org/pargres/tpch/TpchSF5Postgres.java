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

public class TpchSF5Postgres extends Tpch {

    public TpchSF5Postgres() {
	super( 5 );
    }

    public TpchTableStatistics getTableStatistics(String tableName) throws IllegalArgumentException {
	TpchTableStatistics statistics;

	if( tableName.equals( "Lineitem" ) )
	    statistics = new TpchTableStatistics( "Lineitem", 29999795, "l_orderkey", 1, 30000000, 1, 7, 0.9999, 0.012 );
	else if( tableName.equals( "Orders" ) )
	    statistics = new TpchTableStatistics( "Orders", 7500000, "o_orderkey", 1, 30000000, 1, 1, 0.25, 0.93 );
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
		partitionSizes[0] = 30000000;
		break;
	    }
	    case 2: {
	      partitionSizes[0]  = 10911997;
	      partitionSizes[1]  = 19088003;
	      break;
	    }
	    case 4: {
	      partitionSizes[0]  = 9310655;
	      partitionSizes[1]  = 1601342;
	      partitionSizes[2]  = 2710084;
	      partitionSizes[3]  = 16377919;
	      break;
	    }
	    case 8: {
	      partitionSizes[0]  = 8698904;
	      partitionSizes[1]  = 611751;
	      partitionSizes[2]  = 719940;
	      partitionSizes[3]  = 881402;
	      partitionSizes[4]  = 1130336;
	      partitionSizes[5]  = 1579748;
	      partitionSizes[6]  = 2812207;
	      partitionSizes[7]  = 13565712;
	      break;
	    }
	    case 16: {
	      partitionSizes[0]  = 7034885;
	      partitionSizes[1]  = 1664019;
	      partitionSizes[2]  = 296617;
	      partitionSizes[3]  = 315134;
	      partitionSizes[4]  = 343281;
	      partitionSizes[5]  = 376659;
	      partitionSizes[6]  = 417739;
	      partitionSizes[7]  = 463663;
	      partitionSizes[8]  = 527294;
	      partitionSizes[9]  = 603042;
	      partitionSizes[10] = 710981;
	      partitionSizes[11] = 868767;
	      partitionSizes[12] = 1120786;
	      partitionSizes[13] = 1691421;
	      partitionSizes[14] = 3905523;
	      partitionSizes[15] = 9660189;
	      break;
	    }
	    case 32: {
	      partitionSizes[0] = 5355957;
	      partitionSizes[1] = 1678928;
	      partitionSizes[2] = 1369757;
	      partitionSizes[3] = 294262;
	      partitionSizes[4] = 143992;
	      partitionSizes[5] = 152625;
	      partitionSizes[6] = 153910;
	      partitionSizes[7] = 161224;
	      partitionSizes[8] = 167974;
	      partitionSizes[9] = 175307;
	      partitionSizes[10] = 184170;
	      partitionSizes[11] = 192489;
	      partitionSizes[12] = 203085;
	      partitionSizes[13] = 214654;
	      partitionSizes[14] = 221401;
	      partitionSizes[15] = 242262;
	      partitionSizes[16] = 257558;
	      partitionSizes[17] = 269736;
	      partitionSizes[18] = 286149;
	      partitionSizes[19] = 316893;
	      partitionSizes[20] = 340165;
	      partitionSizes[21] = 370816;
	      partitionSizes[22] = 414901;
	      partitionSizes[23] = 453866;
	      partitionSizes[24] = 541840;
	      partitionSizes[25] = 578946;
	      partitionSizes[26] = 743689;
	      partitionSizes[27] = 947732;
	      partitionSizes[28] = 1185662;
	      partitionSizes[29] = 2719861;
	      partitionSizes[30] = 4544376;
	      partitionSizes[31] = 5115813;
	      break;
	    }
	    case 64: {
	      partitionSizes[0]  = 4935617;
	      partitionSizes[1]  = 420340;
	      partitionSizes[2]  = 621688;
	      partitionSizes[3]  = 1057240;
	      partitionSizes[4]  = 506571;
	      partitionSizes[5]  = 863186;
	      partitionSizes[6]  = 68390;
	      partitionSizes[7]  = 225872;
	      partitionSizes[8]  = 71365;
	      partitionSizes[9]  = 72627;
	      partitionSizes[10] = 76754;
	      partitionSizes[11] = 75871;
	      partitionSizes[12] = 74999;
	      partitionSizes[13] = 78911;
	      partitionSizes[14] = 79512;
	      partitionSizes[15] = 81712;
	      partitionSizes[16] = 82696;
	      partitionSizes[17] = 85278;
	      partitionSizes[18] = 86493;
	      partitionSizes[19] = 88814;
	      partitionSizes[20] = 90663;
	      partitionSizes[21] = 93507;
	      partitionSizes[22] = 96678;
	      partitionSizes[23] = 95811;
	      partitionSizes[24] = 102149;
	      partitionSizes[25] = 100936;
	      partitionSizes[26] = 105317;
	      partitionSizes[27] = 109337;
	      partitionSizes[28] = 108407;
	      partitionSizes[29] = 112994;
	      partitionSizes[30] = 121424;
	      partitionSizes[31] = 120838;
	      partitionSizes[32] = 125228;
	      partitionSizes[33] = 132330;
	      partitionSizes[34] = 131774;
	      partitionSizes[35] = 137962;
	      partitionSizes[36] = 136377;
	      partitionSizes[37] = 149772;
	      partitionSizes[38] = 155548;
	      partitionSizes[39] = 161345;
	      partitionSizes[40] = 163689;
	      partitionSizes[41] = 176476;
	      partitionSizes[42] = 178325;
	      partitionSizes[43] = 192491;
	      partitionSizes[44] = 207937;
	      partitionSizes[45] = 206964;
	      partitionSizes[46] = 223670;
	      partitionSizes[47] = 230196;
	      partitionSizes[48] = 261351;
	      partitionSizes[49] = 280489;
	      partitionSizes[50] = 291227;
	      partitionSizes[51] = 287719;
	      partitionSizes[52] = 363668;
	      partitionSizes[53] = 380021;
	      partitionSizes[54] = 436985;
	      partitionSizes[55] = 510747;
	      partitionSizes[56] = 596382;
	      partitionSizes[57] = 589280;
	      partitionSizes[58] = 999039;
	      partitionSizes[59] = 1720822;
	      partitionSizes[60] = 2561982;
	      partitionSizes[61] = 1982394;
	      partitionSizes[62] = 4021223;
	      partitionSizes[63] = 1094590;
	      break;
	    }
	    default:
		throw new IllegalArgumentException( "TpchSF5Postgres.getZipfSkewedPartitionSizes(): not supported number of skewed partition sizes -> " + numPartitions );
	}
	// checagem
	countCheck = 0;
	for( int i = 0; i < partitionSizes.length; i++ )
	    countCheck += partitionSizes[i];
	if( countCheck != 30000000 )
	    throw new RuntimeException( "TpchSF5Postgres.getZipfSkewedPartitionSizes(): Check failed!" );
	return partitionSizes;
    }
}
