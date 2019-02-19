/*
 * Created on 11/03/2005
 */
package org.pargres.cqp.queryplanner;


/**
 * @author Bernardo
 */
public class QueryUtil {
	//public static int NUM_NQP = -1;
    public static boolean quotedDateInterval = true;
	public static String Q0_ORIGINAL = new String( "SELECT SUM(L_QUANTITY) FROM LINEITEM");	
    public static String Q0 = new String( "select 'X', sum( l_quantity ) from lineitem " +
    									"where l_orderkey >= ? and l_orderkey < ?;" );
	
    public static String Q1_ORIGINAL = "SELECT L_RETURNFLAG, L_LINESTATUS, SUM(L_QUANTITY) AS SUM_QTY, SUM(L_EXTENDEDPRICE) AS SUM_BASE_PRICE, SUM(L_EXTENDEDPRICE * (1 - L_DISCOUNT)) AS SUM_DISC_PRICE, SUM(L_EXTENDEDPRICE * (1 - L_DISCOUNT) * (1 + L_TAX)) AS SUM_CHARGE, SUM(L_QUANTITY) AS AVG_QTY_1, COUNT(L_QUANTITY) AS AVG_QTY_2, SUM(L_EXTENDEDPRICE) AS AVG_PRICE_1, COUNT(L_EXTENDEDPRICE) AS AVG_PRICE_2, SUM(L_DISCOUNT) AS AVG_DISC_1, COUNT(L_DISCOUNT) AS AVG_DISC_2, COUNT(*) AS COUNT_ORDER FROM LINEITEM WHERE L_SHIPDATE <= DATE '1998-12-01' - INTERVAL '90 DAY' GROUP BY L_RETURNFLAG,L_LINESTATUS";
	
	public static String Q1 = new String( "select l_returnflag, l_linestatus, " +
            "sum(l_quantity) as sum_qty, " +
            "sum(l_extendedprice) as sum_base_price, " +
            "sum(l_extendedprice * (1 - l_discount)) as sum_disc_price, " +
            "sum(l_extendedprice * (1 - l_discount) * (1 + l_tax)) as sum_charge, " +
            "sum(l_quantity) as avg_qty_1, " + // originaly "avg(l_quantity) as avg_qty, " +
            "count(l_quantity) as avg_qty_2, " + // originaly "avg(l_quantity) as avg_qty, " +
            "sum(l_extendedprice) as avg_price_1, " + // originaly  "avg(l_extendedprice) as avg_price, " +
            "count(l_extendedprice) as avg_price_2, " + // originaly  "avg(l_extendedprice) as avg_price, " +
            "sum(l_discount) as avg_disc_1, " + // originaly "avg(l_discount) as avg_disc, " +
            "count(l_discount) as avg_disc_2, " + // originaly "avg(l_discount) as avg_disc, " +
            "count(*) as count_order " +
            "from lineitem " +
            "where l_shipdate <= date '1998-12-01' - interval " + (quotedDateInterval ? "'90 day' " : "90 day ") +
            "  and l_orderkey >= ? and l_orderkey < ? " +
            "group by l_returnflag,	l_linestatus;" );	
    
	/*
    public QueryAvpDetail getQuery(String query) {
        
        
        ClusterQueryProcessor cqp;
        QueryResult result;
        int numQueries = 3;
        int count;
        int queryNum;
        int numQEsPerJob;
        int[] resultValueTypeCodes = null;
        int resultGroupIdSize = 0;
        String cqpaddress, cqpport;
        int tpchScaleFactor;
        int numVirtualPartitions;
        int numNQPs = NUM_NQP;
        int numExecutions, countExec;
        float totalExecutionTime = 0;
        Range range;
        RangeStatistics rangeStat;
        int []argsFirstVal;
        int []argsLastVal;
        int rangeIni = 0, rangeEnd = 0;
        Tpch tpchInstance;
        TpchTableStatistics tpchStat;
        boolean performLoadBalancing = true;
        boolean getSystemResourceStatistics = false;
        long numBlocksRead, numBlocksWritten;

        
        numVirtualPartitions = NUM_NQP; // in traditional VP, each NQP works with only one partition

        tpchInstance = new TpchSF1Postgres();

        if(Q0_ORIGINAL.equals(query)) {
			query = Q0;
            argsFirstVal = new int[1];
            argsFirstVal[0] = 1;
            argsLastVal = new int[1];
            argsLastVal[0] = 2;
            tpchStat = tpchInstance.getTableStatistics( "Lineitem" );
            if( rangeIni == 0 && rangeEnd == 0 ) {
                rangeIni = (int) tpchStat.getMinVpAttributeValue();
                rangeEnd = (int) tpchStat.getMaxVpAttributeValue() + 1;
            }
            rangeStat = new RangeStatistics( (float)tpchStat.getMeanTuplesPerVpAttributeValue(), 
											//(int)tpchStat.getMinTuplesPerVpAttributeValue(),
                                             //(int)tpchStat.getMaxTuplesPerVpAttributeValue(), 
											tpchStat.getCardinality(),
                                             (float)tpchStat.maxSizeFractionForVPIndexScan() );
            range = new Range( -1, rangeIni, rangeEnd, argsFirstVal, argsLastVal, numVirtualPartitions, rangeStat );
            resultValueTypeCodes = new int[1];
            resultValueTypeCodes[0] = Summarizer.typeCode;
            resultGroupIdSize = 1;
        } else if (Q1_ORIGINAL.equals(query)) { 
			query = Q1;            
            argsFirstVal = new int[1];
            argsFirstVal[0] = 1;
            argsLastVal = new int[1];
            argsLastVal[0] = 2;
            tpchStat = tpchInstance.getTableStatistics( "Lineitem" );
            if( rangeIni == 0 && rangeEnd == 0 ) {
                rangeIni = (int) tpchStat.getMinVpAttributeValue();
                rangeEnd = (int) tpchStat.getMaxVpAttributeValue() + 1;
            }
            rangeStat = new RangeStatistics( (float)tpchStat.getMeanTuplesPerVpAttributeValue(), 
											//(int)tpchStat.getMinTuplesPerVpAttributeValue(),
                                            //(int)tpchStat.getMaxTuplesPerVpAttributeValue(), 
											 tpchStat.getCardinality(),
                                             (float)(1.0 / numNQPs) );
                                             //(float)tpchStat.maxSizeFractionForVPIndexScan() );
            range = new Range( -1, rangeIni, rangeEnd, argsFirstVal, argsLastVal, numVirtualPartitions, rangeStat );
            resultValueTypeCodes = new int[11];
            resultValueTypeCodes[0] = Summarizer.typeCode;
            resultValueTypeCodes[1] = Summarizer.typeCode;
            resultValueTypeCodes[2] = Summarizer.typeCode;
            resultValueTypeCodes[3] = Summarizer.typeCode;
            resultValueTypeCodes[4] = Summarizer.typeCode;
            resultValueTypeCodes[5] = Summarizer.typeCode;
            resultValueTypeCodes[6] = Summarizer.typeCode;
            resultValueTypeCodes[7] = Summarizer.typeCode;
            resultValueTypeCodes[8] = Summarizer.typeCode;
            resultValueTypeCodes[9] = Summarizer.typeCode;
            resultValueTypeCodes[10] = Summarizer.typeCode;
            resultGroupIdSize = 2;
        } else {
            return null;
        }
        QueryAvpDetail queryAvpDetail = new QueryAvpDetail();
        queryAvpDetail.setQuery(query);
        queryAvpDetail.setRange(range);
        queryAvpDetail.setNumNQPs(numNQPs);
        queryAvpDetail.setPartitionSizes(null);
        queryAvpDetail.setGetStatistics(true);
        queryAvpDetail.setLocalResultComposition(true);
        queryAvpDetail.setInitialResultComposerCapacity(11);
        queryAvpDetail.setResultValueTypeCodes(resultValueTypeCodes);
        queryAvpDetail.setResultGroupIdSize(resultGroupIdSize);
        queryAvpDetail.setPerformDynamicLoadBalancing(performLoadBalancing);
        queryAvpDetail.setGetSystemResourceStatistics(getSystemResourceStatistics);
        return queryAvpDetail;
    }*/
}
