/*
 * TpcHStatistics.java
 *
 * Created on 25 mars 2004, 15:12
 */

package org.pargres.tpch;

/**
 *
 * @author  lima
 */
public class TpchTableStatistics {
    
    private String a_tableName;
    private long a_cardinality;
    private String a_vpAttribute;
    private long a_minVpAttValue;
    private long a_maxVpAttValue;
    private long a_minTuplesPerVpAttValue;
    private long a_maxTuplesPerVpAttValue;
    private double a_meanTuplesPerVpAttValue;
    private double a_maxSizeFractionForVPIndexScan;
    
    /** Creates a new instance of TpcHStatistics */
    public TpchTableStatistics( String tableName, long cardinality, String vpAttribute, 
                                long minVpAttValue, long maxVpAttValue,
                                long minTuplesPerVpAttValue, long maxTuplesPerVpAttValue, 
                                double meanTuplesPerVpAttValue, double maxSizeFractionForVPIndexScan) {
        a_tableName = tableName;
        a_cardinality = cardinality;
        a_vpAttribute = vpAttribute;
        a_minVpAttValue = minVpAttValue;
        a_maxVpAttValue = maxVpAttValue;
        a_minTuplesPerVpAttValue = minTuplesPerVpAttValue;
        a_maxTuplesPerVpAttValue = maxTuplesPerVpAttValue;
        a_meanTuplesPerVpAttValue = meanTuplesPerVpAttValue;
        a_maxSizeFractionForVPIndexScan = maxSizeFractionForVPIndexScan;
    }
    
    public String getTableName() { 
        return a_tableName;
    }
    
    public long getCardinality() {
        return a_cardinality;        
    }

    public String getVpAttribute() {
        return a_vpAttribute;
    }
    
    public long getMinVpAttributeValue() {
        return a_minVpAttValue;
    }
    
    public long getMaxVpAttributeValue() {
        return a_maxVpAttValue;
    }
    
    public long getMinTuplesPerVpAttributeValue() {
        return a_minTuplesPerVpAttValue;
    }

    public long getMaxTuplesPerVpAttributeValue() {
        return a_maxTuplesPerVpAttValue;
    }

    public double getMeanTuplesPerVpAttributeValue() {
        return a_meanTuplesPerVpAttValue;
    }
    
    public double maxSizeFractionForVPIndexScan() {
        return a_maxSizeFractionForVPIndexScan;
    }
}
