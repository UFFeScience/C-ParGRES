/*
 * Created on 11/03/2005
 */
package org.pargres.cqp.queryplanner;

import java.io.Serializable;

import org.pargres.util.Range;


/**
 * @author Bernardo
 */
public class QueryAvpDetail implements Serializable{
	private static final long serialVersionUID = 6891857693793731608L;
	/**
     * @return Returns the getStatistics.
     */
    public boolean isGetStatistics() {
        return getStatistics;
    }
    /**
     * @param getStatistics The getStatistics to set.
     */
    public void setGetStatistics(boolean getStatistics) {
        this.getStatistics = getStatistics;
    }
    /**
     * @return Returns the getSystemResourceStatistics.
     */
    public boolean isGetSystemResourceStatistics() {
        return getSystemResourceStatistics;
    }
    /**
     * @param getSystemResourceStatistics The getSystemResourceStatistics to set.
     */
    public void setGetSystemResourceStatistics(
            boolean getSystemResourceStatistics) {
        this.getSystemResourceStatistics = getSystemResourceStatistics;
    }
    
    /**
     * @return Returns the localResultComposition.
     */
    public boolean isLocalResultComposition() {
        return localResultComposition;
    }
    /**
     * @param localResultComposition The localResultComposition to set.
     */
    public void setLocalResultComposition(boolean localResultComposition) {
        this.localResultComposition = localResultComposition;
    }
    /**
     * @return Returns the numNQPs.
     */
    public int getNumNQPs() {
        return numNQPs;
    }
    /**
     * @param numNQPs The numNQPs to set.
     */
    public void setNumNQPs(int numNQPs) {
        this.numNQPs = numNQPs;
    }
    /**
     * @return Returns the partitionSizes.
     */
    public int[] getPartitionSizes() {
        return partitionSizes;
    }
    /**
     * @param partitionSizes The partitionSizes to set.
     */
    public void setPartitionSizes(int[] partitionSizes) {
        this.partitionSizes = partitionSizes;
    }
    /**
     * @return Returns the performDynamicLoadBalancing.
     */
    public boolean isPerformDynamicLoadBalancing() {
        return performDynamicLoadBalancing;
    }
    /**
     * @param performDynamicLoadBalancing The performDynamicLoadBalancing to set.
     */
    public void setPerformDynamicLoadBalancing(
            boolean performDynamicLoadBalancing) {
        this.performDynamicLoadBalancing = performDynamicLoadBalancing;
    }
    /**
     * @return Returns the query.
     */
    public String getQuery() {
        return query;
    }
    /**
     * @param query The query to set.
     */
    public void setQuery(String query) {
        this.query = query;
    }
    /**
     * @return Returns the range.
     */
    public Range getRange() {
        return range;
    }
    /**
     * @param range The range to set.
     */
    public void setRange(Range range) {
        this.range = range;
    }
   
    String query;
    Range range;
    int numNQPs;
    int []partitionSizes;
    boolean getStatistics;
    boolean localResultComposition;
    boolean performDynamicLoadBalancing;
    boolean getSystemResourceStatistics; 
}
