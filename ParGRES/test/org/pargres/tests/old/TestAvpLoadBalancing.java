/*
 * TestNode.java
 *
 * Created on 13 novembre 2003, 15:08
 */

package org.pargres.tests.old;

/**
 *
 * @author  lima
 */



import java.io.FileOutputStream;
import java.io.PrintStream;
import java.sql.ResultSet;

import org.pargres.commons.logger.Logger;
import org.pargres.console.ResultSetPrinter;
import org.pargres.cqp.ClusterQueryProcessor;
import org.pargres.tpch.Tpch;
import org.pargres.tpch.TpchSF1Postgres;
import org.pargres.tpch.TpchSF1_NonUniform_Postgres;
import org.pargres.tpch.TpchSF5Postgres;
import org.pargres.tpch.TpchTableStatistics;
import org.pargres.util.MyRMIRegistry;
import org.pargres.util.Range;
import org.pargres.util.RangeStatistics;

public class TestAvpLoadBalancing {
    private static Logger logger = Logger.getLogger(TestAvpLoadBalancing.class);
    
    String cqpAddress;
    int cqpPort;
    int tpchScaleFactor;
    int numVirtualPartitions;
    int numNQPs;
    int numExecutions;
    int queryNum;
    int numQEsPerJob;    
    boolean hasSystemResourceStatistics;
    
    /** Creates a new instance of TestNode */
    public TestAvpLoadBalancing(String cqpAddress,int cqpPort,int tpchScaleFactor,int numNQPs,
            int numVirtualPartitions,int numQEsPerJob,int queryNum,int numExecutions, boolean hasSystemResourceStatistics) {
        this.cqpAddress = cqpAddress;
        this.cqpPort = cqpPort;
        this.tpchScaleFactor = tpchScaleFactor;
        this.numNQPs = numNQPs;
        this.numVirtualPartitions = numVirtualPartitions;
        this.numQEsPerJob = numQEsPerJob;
        this.queryNum = queryNum;
        this.numExecutions = numExecutions;
        this.hasSystemResourceStatistics = hasSystemResourceStatistics;
        
    }

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        if( args.length != 7 ) {
            System.out.println("usage: java tests.TestAVP_LoadBalancing " +
                                "node_address port TpchScaleFactor numNQPs idQuery numberOfExecutions SYSMON|NO_SYSMON" );
            return;
        }

        String cqpAddress = args[0].trim();
        int cqpPort = Integer.parseInt( args[1] );
        int tpchScaleFactor = Integer.parseInt( args[2] );
        int numNQPs = Integer.parseInt( args[3] );
        int numVirtualPartitions = numNQPs; // in traditional VP, each NQP works with only one partition
        int numQEsPerJob = 1; // Always equal to one. To have more than one, modify PartitionTuner
        int queryNum = Integer.parseInt( args[4] );
        int numExecutions = Integer.parseInt( args[5] );
        boolean getSystemResourceStatistics;
        
        if( args[6].equals( "SYSMON" ) )
            getSystemResourceStatistics = true;
          else if( args[6].equals( "NO_SYSMON" ) )
            getSystemResourceStatistics = false;
          else
            throw new IllegalArgumentException( "Invalid option: " + args[7] );
        
        try {
      //  TestAvpLoadBalancing t = 
        	new TestAvpLoadBalancing(cqpAddress,cqpPort,tpchScaleFactor,numNQPs,
                numVirtualPartitions,numQEsPerJob,queryNum,numExecutions,getSystemResourceStatistics);
        } catch (Exception e) {
            logger.error(e);
        }
    }
    
    public void run() {
        ClusterQueryProcessor cqp;
        ResultSet result = null;
        @SuppressWarnings("unused") String query;
        int countExec;        
        float totalExecutionTime = 0;        
        /*int numQueries = 3;
        int count;
        int[] resultValueTypeCodes = null;
        int resultGroupIdSize = 0;
        */
        Range range;
        RangeStatistics rangeStat;
        int []argsFirstVal;
        int []argsLastVal;
        int rangeIni = 0, rangeEnd = 0;
        Tpch tpchInstance;
        TpchTableStatistics tpchStat;
        //boolean performLoadBalancing = true;
        long numBlocksRead, numBlocksWritten;



        try {
            long begin, end, firstExecutionTime = 0;
            int maxResultTuplesToShow = 10;
            boolean quotedDateInterval;


            cqp = (ClusterQueryProcessor) MyRMIRegistry.lookup(cqpAddress,cqpPort,"//"+ cqpAddress + ":" + cqpPort + "/ClusterQueryProcessor");
            quotedDateInterval = cqp.quotedDateIntervals();

            switch( tpchScaleFactor ) {
                case 1 :
                    tpchInstance = new TpchSF1Postgres();
                    break;
                case 1001 :
                    tpchInstance = new TpchSF1_NonUniform_Postgres();
                    break;
                case 5 :
                    tpchInstance = new TpchSF5Postgres();
                    break;
                default :
                    throw new IllegalArgumentException( "Statistics for TPC-H with scale factor " + tpchScaleFactor + " are not available." );
            }

            switch( queryNum ) {
                case 0: query = new String( "select 'X', sum( l_quantity ) from lineitem " +
                                             "where l_orderkey >= ? and l_orderkey < ?;" );
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
                                                          tpchStat.getCardinality(),
                                                         (float)tpchStat.maxSizeFractionForVPIndexScan() );
                        range = new Range( -1, rangeIni, rangeEnd, argsFirstVal, argsLastVal, numVirtualPartitions, rangeStat );
                        break;
                case 1: // TPC-H Query 1
                        query = new String( "select l_returnflag, l_linestatus, " +
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
                                                          tpchStat.getCardinality(),
                                                         (float)(1.0 / numNQPs) );
                                                         //(float)tpchStat.maxSizeFractionForVPIndexScan() );
                        range = new Range( -1, rangeIni, rangeEnd, argsFirstVal, argsLastVal, numVirtualPartitions, rangeStat );
                        break;
                case 3: // TPC-H Query 3
                        query = new String( "select l_orderkey, " +
                                            "o_orderdate, " +
                                            "o_shippriority, " +
                                            "sum(l_extendedprice * (1 - l_discount)) as revenue " +
                                            "from customer, orders, lineitem " +
                                            "where c_mktsegment = 'BUILDING' " +
                                            " and c_custkey = o_custkey " +
                                            " and l_orderkey = o_orderkey " +
                                            " and o_orderdate < date '1995-03-15' " +
                                            " and l_shipdate > date '1995-03-15' " +
                                            " and o_orderkey >= ? and o_orderkey < ? " +
                                            " and l_orderkey >= ? and l_orderkey < ? " +
                                            "group by l_orderkey, o_orderdate, o_shippriority; " );
                        argsFirstVal = new int[2];
                        argsFirstVal[0] = 1;
                        argsFirstVal[1] = 3;
                        argsLastVal = new int[2];
                        argsLastVal[0] = 2;
                        argsLastVal[1] = 4;
                        tpchStat = tpchInstance.getTableStatistics( "Lineitem" );
                        if( rangeIni == 0 && rangeEnd == 0 ) {
                            rangeIni = (int) tpchStat.getMinVpAttributeValue();
                            rangeEnd = (int) tpchStat.getMaxVpAttributeValue() + 1;
                        }
                        rangeStat = new RangeStatistics( (float)tpchStat.getMeanTuplesPerVpAttributeValue(), 
                                                          tpchStat.getCardinality(),
                                                         (float)(1.0 / numNQPs) );
                                                         //(float)tpchStat.maxSizeFractionForVPIndexScan() );
                        range = new Range( -1, rangeIni, rangeEnd, argsFirstVal, argsLastVal, numVirtualPartitions, rangeStat );
                        break;

                case 4: // TPC-H Query 4
                        query = new String( "select o_orderpriority, count(*) as order_count " +
                                            "from orders " +
                                            "where o_orderdate >= date '1993-07-01' " +
                                            "and o_orderdate < date '1993-07-01' + interval " + (quotedDateInterval ? "'3 month' " : "3 month ") +
                                            "and o_orderkey >= ? and o_orderkey < ? " +
                                            "and exists ( select * " +
                                                        " from lineitem " +
                                                        " where l_orderkey = o_orderkey " +
                                                        " and l_commitdate < l_receiptdate " +
                                                        " and l_orderkey >= ? and l_orderkey < ? ) " +
                                            "group by o_orderpriority;" );
                        argsFirstVal = new int[2];
                        argsFirstVal[0] = 1;
                        argsFirstVal[1] = 3;
                        argsLastVal = new int[2];
                        argsLastVal[0] = 2;
                        argsLastVal[1] = 4;
                        tpchStat = tpchInstance.getTableStatistics( "Lineitem" );
                        if( rangeIni == 0 && rangeEnd == 0 ) {
                            rangeIni = (int) tpchStat.getMinVpAttributeValue();
                            rangeEnd = (int) tpchStat.getMaxVpAttributeValue() + 1;
                        }
                        rangeStat = new RangeStatistics( (float)tpchStat.getMeanTuplesPerVpAttributeValue(), 
                                                          tpchStat.getCardinality(),
                                                         (float)(1.0 / numNQPs) );
                                                         //(float)tpchStat.maxSizeFractionForVPIndexScan() / numNQPs );
                        range = new Range( -1, rangeIni, rangeEnd, argsFirstVal, argsLastVal, numVirtualPartitions, rangeStat );
                        break;

                case 5: // TPC-H Query 5
                        query = new String( "select n_name, sum(l_extendedprice * (1 - l_discount)) as revenue " +
                                            "from customer, orders, lineitem, supplier, nation, region " +
                                            "where c_custkey = o_custkey " +
                                            "and l_orderkey = o_orderkey " +
                                            "and l_suppkey = s_suppkey " +
                                            "and c_nationkey = s_nationkey " +
                                            "and s_nationkey = n_nationkey " +
                                            "and n_regionkey = r_regionkey " +
                                            "and r_name = 'ASIA' " +
                                            "and o_orderdate >= date '1994-01-01' " +
                                            "and o_orderdate < date '1994-01-01' + interval " + (quotedDateInterval ? "'1 year' " : "1 year ") +
                                            "and o_orderkey >= ? and o_orderkey < ? " +
                                            "and l_orderkey >= ? and l_orderkey < ? " +
                                            "group by n_name; " );
                        argsFirstVal = new int[2];
                        argsFirstVal[0] = 1;
                        argsFirstVal[1] = 3;
                        argsLastVal = new int[2];
                        argsLastVal[0] = 2;
                        argsLastVal[1] = 4;
                        tpchStat = tpchInstance.getTableStatistics( "Lineitem" );
                        if( rangeIni == 0 && rangeEnd == 0 ) {
                            rangeIni = (int) tpchStat.getMinVpAttributeValue();
                            rangeEnd = (int) tpchStat.getMaxVpAttributeValue() + 1;
                        }
                        rangeStat = new RangeStatistics( (float)tpchStat.getMeanTuplesPerVpAttributeValue(), 
                                                          tpchStat.getCardinality(),
                                                         (float)(1.0 / numNQPs) );
                                                         //(float)tpchStat.maxSizeFractionForVPIndexScan() / numNQPs );
                        range = new Range( -1, rangeIni, rangeEnd, argsFirstVal, argsLastVal, numVirtualPartitions, rangeStat );
                        break;

                case 51: // TPC-H Query 5 modified to use some temporary tables
                        query = new String( "select n_name, sum(l_extendedprice * (1 - l_discount)) as revenue " +
                                            "from c_temp, orders, lineitem, s_temp " +
                                            "where c_custkey = o_custkey " +
                                            "and l_orderkey = o_orderkey " +
                                            "and l_suppkey = s_suppkey " +
                                            "and c_nationkey = s_nationkey " +
                                            "and o_orderdate >= date '1994-01-01' " +
                                            "and o_orderdate < date '1994-01-01' + interval " + (quotedDateInterval ? "'1 year' " : "1 year ") +
                                            "and o_orderkey >= ? and o_orderkey < ? " +
                                            "and l_orderkey >= ? and l_orderkey < ? " +
                                            "group by n_name; " );
                        argsFirstVal = new int[2];
                        argsFirstVal[0] = 1;
                        argsFirstVal[1] = 3;
                        argsLastVal = new int[2];
                        argsLastVal[0] = 2;
                        argsLastVal[1] = 4;
                        tpchStat = tpchInstance.getTableStatistics( "Lineitem" );
                        if( rangeIni == 0 && rangeEnd == 0 ) {
                            rangeIni = (int) tpchStat.getMinVpAttributeValue();
                            rangeEnd = (int) tpchStat.getMaxVpAttributeValue() + 1;
                        }
                        rangeStat = new RangeStatistics( (float)tpchStat.getMeanTuplesPerVpAttributeValue(), 
                                                          tpchStat.getCardinality(),
                                                         (float)(1.0 / numNQPs) );
                                                         //(float)tpchStat.maxSizeFractionForVPIndexScan() );
                        range = new Range( -1, rangeIni, rangeEnd, argsFirstVal, argsLastVal, numVirtualPartitions, rangeStat );
                        break;

                case 6: // TPC-H Query 6
                        query = new String( "select 'X', sum(l_extendedprice * l_discount) as revenue " +
                                            "from lineitem " +
                                            "where l_shipdate >= date '1994-01-01' " +
                                            "and l_shipdate < date '1994-01-01' + interval " + (quotedDateInterval ? "'1 year' " : "1 year ") +
                                            "and l_discount between .06 - 0.01 and .06 + 0.01 " +
                                            "and l_quantity < 24 " +
                                            "and l_orderkey >= ? and l_orderkey < ? " );
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
                                                          tpchStat.getCardinality(),
                                                         (float)(1.0 / numNQPs) );
                                                         //(float)tpchStat.maxSizeFractionForVPIndexScan() );
                        range = new Range( -1, rangeIni, rangeEnd, argsFirstVal, argsLastVal, numVirtualPartitions, rangeStat );
                        break;

                case 10: // TPC-H Query 10
                        query = new String( "select c_custkey, " +
                                            "c_name, " +
                                            "c_acctbal, " +
                                            "c_phone, " +
                                            "n_name, " +
                                            "c_address, " +
                                            "c_comment, " +
                                            "sum(l_extendedprice * (1 - l_discount)) as revenue " +
                                            "from customer, orders, lineitem, nation " +
                                            "where c_custkey = o_custkey " +
                                            "and l_orderkey = o_orderkey " +
                                            "and o_orderdate >= date '1993-10-01' " +
                                            "and o_orderdate < date '1993-10-01' + interval " + (quotedDateInterval ? "'3 month' " : "3 month ") +
                                            "and l_returnflag = 'R' " +
                                            "and c_nationkey = n_nationkey " +
                                            "and o_orderkey >= ? and o_orderkey < ? " +
                                            "and l_orderkey >= ? and l_orderkey < ? " +
                                            "group by c_custkey, c_name, c_acctbal, c_phone, n_name, c_address, c_comment; " );
                        argsFirstVal = new int[2];
                        argsFirstVal[0] = 1;
                        argsFirstVal[1] = 3;
                        argsLastVal = new int[2];
                        argsLastVal[0] = 2;
                        argsLastVal[1] = 4;
                        tpchStat = tpchInstance.getTableStatistics( "Lineitem" );
                        if( rangeIni == 0 && rangeEnd == 0 ) {
                            rangeIni = (int) tpchStat.getMinVpAttributeValue();
                            rangeEnd = (int) tpchStat.getMaxVpAttributeValue() + 1;
                        }
                        rangeStat = new RangeStatistics( (float)tpchStat.getMeanTuplesPerVpAttributeValue(), 
                                                          tpchStat.getCardinality(),
                                                         (float)(1.0 / numNQPs) );
                                                         //(float)tpchStat.maxSizeFractionForVPIndexScan() );
                        range = new Range( -1, rangeIni, rangeEnd, argsFirstVal, argsLastVal, numVirtualPartitions, rangeStat );
                        break;

                case 12: // TPC-H Query 12
                        query = new String( "select l_shipmode, " +
                                            "sum(case " +
                                                "when o_orderpriority = '1-URGENT' " +
                                                "or o_orderpriority = '2-HIGH' " +
                                                "then 1 " +
                                                "else 0 " +
                                            "end) as high_line_count, " +
                                            "sum(case " +
                                            "   when o_orderpriority <> '1-URGENT' " +
                                            "   and o_orderpriority <> '2-HIGH' " +
                                            "   then 1 " +
                                            "   else 0 " +
                                            "end) as low_line_count " +
                                            "from orders, lineitem " +
                                            "where o_orderkey = l_orderkey " +
                                            "and l_shipmode in ('MAIL', 'SHIP') " +
                                            "and l_commitdate < l_receiptdate " +
                                            "and l_shipdate < l_commitdate " +
                                            "and l_receiptdate >= date '1994-01-01' " +
                                            "and l_receiptdate < date '1994-01-01' + interval " + (quotedDateInterval ? "'1 year' " : "1 year ") +
                                            "and o_orderkey >= ? and o_orderkey < ? " +
                                            "and l_orderkey >= ? and l_orderkey < ? " +
                                            "group by l_shipmode; " );
                        argsFirstVal = new int[2];
                        argsFirstVal[0] = 1;
                        argsFirstVal[1] = 3;
                        argsLastVal = new int[2];
                        argsLastVal[0] = 2;
                        argsLastVal[1] = 4;
                        tpchStat = tpchInstance.getTableStatistics( "Lineitem" );
                        if( rangeIni == 0 && rangeEnd == 0 ) {
                            rangeIni = (int) tpchStat.getMinVpAttributeValue();
                            rangeEnd = (int) tpchStat.getMaxVpAttributeValue() + 1;
                        }
                        rangeStat = new RangeStatistics( (float)tpchStat.getMeanTuplesPerVpAttributeValue(), 
                                                          tpchStat.getCardinality(),
                                                         (float)(1.0 / numNQPs) );
                                                         //(float)tpchStat.maxSizeFractionForVPIndexScan() );
                        range = new Range( -1, rangeIni, rangeEnd, argsFirstVal, argsLastVal, numVirtualPartitions, rangeStat );
                        break;

                case 121: // TPC-H Query 12 without derived partitioning
                        query = new String( "select l_shipmode, " +
                                            "sum(case " +
                                                "when o_orderpriority = '1-URGENT' " +
                                                "or o_orderpriority = '2-HIGH' " +
                                                "then 1 " +
                                                "else 0 " +
                                            "end) as high_line_count, " +
                                            "sum(case " +
                                            "   when o_orderpriority <> '1-URGENT' " +
                                            "   and o_orderpriority <> '2-HIGH' " +
                                            "   then 1 " +
                                            "   else 0 " +
                                            "end) as low_line_count " +
                                            "from orders, lineitem " +
                                            "where o_orderkey = l_orderkey " +
                                            "and l_shipmode in ('MAIL', 'SHIP') " +
                                            "and l_commitdate < l_receiptdate " +
                                            "and l_shipdate < l_commitdate " +
                                            "and l_receiptdate >= date '1994-01-01' " +
                                            "and l_receiptdate < date '1994-01-01' + interval " + (quotedDateInterval ? "'1 year' " : "1 year ") +
                                            "and l_orderkey >= ? and l_orderkey < ? " +
                                            "group by l_shipmode; " );
                        argsFirstVal = new int[2];
                        argsFirstVal[0] = 1;
                        argsLastVal = new int[2];
                        argsLastVal[0] = 2;
                        tpchStat = tpchInstance.getTableStatistics( "Lineitem" );
                        if( rangeIni == 0 && rangeEnd == 0 ) {
                            rangeIni = (int) tpchStat.getMinVpAttributeValue();
                            rangeEnd = (int) tpchStat.getMaxVpAttributeValue() + 1;
                        }
                        rangeStat = new RangeStatistics( (float)tpchStat.getMeanTuplesPerVpAttributeValue(), 
                                                          tpchStat.getCardinality(),
                                                         (float)(1.0 / numNQPs) );
                                                         //(float)tpchStat.maxSizeFractionForVPIndexScan() );
                        range = new Range( -1, rangeIni, rangeEnd, argsFirstVal, argsLastVal, numVirtualPartitions, rangeStat );
                        break;

                case 14: // TPC-H Query 14
                        query = new String( "select 'X', " +
                                            "100.00 * sum(case " +
                                                "when p_type like 'PROMO%' " +
                                                "then l_extendedprice * (1 - l_discount) " +
                                                "else 0 " +
                                            "end) as promo_revenue_numerator, " +
                                            " sum(l_extendedprice) as promo_revenue_denominator_factor1, " +
                                            " sum(1 - l_discount) as promo_revenue_denominator_factor2 " +
                                            "from lineitem, part " +
                                            "where l_partkey = p_partkey " +
                                            "and l_shipdate >= date '1995-09-01' " +
                                            "and l_shipdate < date '1995-09-01' + interval " + (quotedDateInterval ? "'1 month' " : "1 month ") +
                                            "and l_orderkey >= ? and l_orderkey < ?; " );
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
                                                          tpchStat.getCardinality(),
                                                         (float)(1.0 / numNQPs) );
                                                         //(float)tpchStat.maxSizeFractionForVPIndexScan() / numNQPs );
                        range = new Range( -1, rangeIni, rangeEnd, argsFirstVal, argsLastVal, numVirtualPartitions, rangeStat );
                        break;

                case 18: // TPC-H Query 18
                        query = new String( "select c_name, c_custkey, o_orderkey, o_orderdate, o_totalprice, sum(l_quantity) " +
                                            "from customer, orders, lineitem " +
                                            "where o_orderkey in ( select l_orderkey from lineitem " +
                                                                   "where l_orderkey >= ? and l_orderkey < ? " +
                                                                   "group by l_orderkey " +
                                                                   "having sum(l_quantity) > 300 ) " +
                                            "and c_custkey = o_custkey " +
                                            "and o_orderkey = l_orderkey " +
                                            "and o_orderkey >= ? and o_orderkey < ? " +
                                            "and l_orderkey >= ? and l_orderkey < ? " +
                                            "group by c_name, c_custkey, o_orderkey, o_orderdate, o_totalprice; " );
                        argsFirstVal = new int[3];
                        argsFirstVal[0] = 1;
                        argsFirstVal[1] = 3;
                        argsFirstVal[2] = 5;
                        argsLastVal = new int[3];
                        argsLastVal[0] = 2;
                        argsLastVal[1] = 4;
                        argsLastVal[2] = 6;
                        tpchStat = tpchInstance.getTableStatistics( "Lineitem" );
                        if( rangeIni == 0 && rangeEnd == 0 ) {
                            rangeIni = (int) tpchStat.getMinVpAttributeValue();
                            rangeEnd = (int) tpchStat.getMaxVpAttributeValue() + 1;
                        }
                        rangeStat = new RangeStatistics( (float)tpchStat.getMeanTuplesPerVpAttributeValue(), 
                                                          tpchStat.getCardinality(),
                                                         (float)(1.0 / numNQPs) );
                                                         //(float)tpchStat.maxSizeFractionForVPIndexScan() / numNQPs );
                        range = new Range( -1, rangeIni, rangeEnd, argsFirstVal, argsLastVal, numVirtualPartitions, rangeStat );
                        break;

                case 21: // TPC-H Query 21
                        query = new String( "select s_name, count(*) as numwait " +
                                            "from supplier, lineitem l1, orders, nation " +
                                            "where s_suppkey = l1.l_suppkey " +
                                            "and o_orderkey = l1.l_orderkey " +
                                            "and o_orderstatus = 'F' " +
                                            "and l1.l_receiptdate > l1.l_commitdate " +
                                            "and exists ( select * from lineitem l2 " +
                                                         "where l2.l_orderkey = l1.l_orderkey " +
                                                         "and l2.l_suppkey <> l1.l_suppkey " +
                                                         "and l2.l_orderkey >= ? and l2.l_orderkey < ? ) " +
                                            "and not exists ( select * from lineitem l3 " +
                                                              "where l3.l_orderkey = l1.l_orderkey " +
                                                              "and l3.l_suppkey <> l1.l_suppkey " +
                                                              "and l3.l_receiptdate > l3.l_commitdate " +
                                                              "and l3.l_orderkey >= ? and l3.l_orderkey < ? ) " +
                                            "and s_nationkey = n_nationkey " +
                                            "and n_name = 'SAUDI ARABIA' " +
                                            "and o_orderkey >= ? and o_orderkey < ? " +
                                            "and l1.l_orderkey >= ? and l1.l_orderkey < ? " +
                                            "group by s_name; " );
                        argsFirstVal = new int[4];
                        argsFirstVal[0] = 1;
                        argsFirstVal[1] = 3;
                        argsFirstVal[2] = 5;
                        argsFirstVal[3] = 7;
                        argsLastVal = new int[4];
                        argsLastVal[0] = 2;
                        argsLastVal[1] = 4;
                        argsLastVal[2] = 6;
                        argsLastVal[3] = 8;
                        tpchStat = tpchInstance.getTableStatistics( "Lineitem" );
                        if( rangeIni == 0 && rangeEnd == 0 ) {
                            rangeIni = (int) tpchStat.getMinVpAttributeValue();
                            rangeEnd = (int) tpchStat.getMaxVpAttributeValue() + 1;
                        }
                        rangeStat = new RangeStatistics( (float)tpchStat.getMeanTuplesPerVpAttributeValue(), 
                                                          tpchStat.getCardinality(),
                                                         (float)(1.0 / numNQPs) );
                                                         //(float)tpchStat.maxSizeFractionForVPIndexScan() );
                        range = new Range( -1, rangeIni, rangeEnd, argsFirstVal, argsLastVal, numVirtualPartitions, rangeStat );
                        break;

                default: System.out.println("Invalid Query Id: " + queryNum );
                         return;
            }

            String resultsFileName = Utilities.createResultFileName( queryNum, "AVP_LoadBalancing", numExecutions, tpchScaleFactor, numNQPs );
            PrintStream resultsFile = new PrintStream( new FileOutputStream( resultsFileName ) );

            System.out.println( "------------------------------------------------------------" );
            System.out.println( "Limits: " + range.getFirstValue() + " to " + range.getOriginalLastValue() );
            resultsFile.println( "------------------------------------------------------------" );
            resultsFile.println( "File: " + resultsFileName );
            resultsFile.println( "Limits: " + range.getFirstValue() + " to " + range.getOriginalLastValue() );
            for( countExec = 0; countExec < numExecutions; countExec++ ) {
                System.out.println( "------------------------------------------------------------" );
                System.out.println( "Execution Number: " + (countExec + 1) );
                resultsFile.println( "------------------------------------------------------------" );
                resultsFile.println( "Execution Number: " + (countExec + 1) );
                begin = System.currentTimeMillis();
 /*               result = cqp.executeQueryWithAVP( query, range, numNQPs, null, true,
                                                  true, 11, resultValueTypeCodes, resultGroupIdSize, performLoadBalancing,
						  hasSystemResourceStatistics, null );*/
                end = System.currentTimeMillis();
                ResultSetPrinter.print(result, maxResultTuplesToShow);
               
                numBlocksRead = 0;
                numBlocksWritten = 0;
                if( hasSystemResourceStatistics ) {
                  resultsFile.println("Total number of blocks read from disk = " + numBlocksRead );
                  resultsFile.println("Total number of blocks written to disk = " + numBlocksWritten );
                  System.out.println("Total number of blocks read from disk = " + numBlocksRead );
                  System.out.println("Total number of blocks written to disk = " + numBlocksWritten );
                }
                else {
                  resultsFile.println("IO has NOT been measured");
                  System.out.println("IO has NOT been measured");
                }
                //resultsFile.println( "There were " + result.size() + " tuples on the result." );
                resultsFile.println( "Elapsed time = " + (end - begin) + " milisseconds." );
                if( countExec > 0 ) // Ignore first execution
                    totalExecutionTime += (end - begin);
                else
                    firstExecutionTime = end - begin;
                result = null;
                System.gc();
                System.out.println( "Finished execution number: " + (countExec + 1) );
                System.out.println( "------------------------------------------------------------" );
                resultsFile.println( "------------------------------------------------------------" );
            }
            System.out.println( "Finished!" );
            resultsFile.println( "First execution time: " + firstExecutionTime + " ms" );
            resultsFile.println( "Mean execution time (ignoring first execution): " + (totalExecutionTime / ((float)numExecutions-1)) + " ms");
            System.out.println( "First execution time: " + firstExecutionTime + " ms" );
            System.out.println( "Mean execution time (ignoring first execution): " + (totalExecutionTime / ((float)numExecutions-1)) + " ms");

            resultsFile.close();
        } catch (Exception e) {
            System.err.println("TestAVP_LoadBalancing exception: " + e.getMessage());
            e.printStackTrace();
        }
    }

}
