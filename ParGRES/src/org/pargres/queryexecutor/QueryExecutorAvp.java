/*
 * LocalQueryTaskEngine_AVP.java
 *
 * Created on 24 mai 2004, 16:04
 *
 * Implements AVP algorithm.
 */

package org.pargres.queryexecutor;

/**
 * 
 * @author lima
 */

import java.rmi.RemoteException;
import java.sql.ResultSet;
import java.sql.SQLException;

import org.pargres.commons.logger.Logger;
import org.pargres.commons.translation.Messages;
import org.pargres.connection.DBConnectionEngine;
import org.pargres.connection.DBConnectionPoolEngine;
import org.pargres.localquerytask.LocalQueryTask;
import org.pargres.resultcomposer.ResultComposer;
import org.pargres.util.LocalQueryTaskStatistics;
import org.pargres.util.PartitionSize;
import org.pargres.util.PartitionTuner;
import org.pargres.util.PartitionTunerMT_NonUniform;
import org.pargres.util.Range;


public class QueryExecutorAvp extends QueryExecutor {

    private Logger logger = Logger.getLogger(QueryExecutorAvp.class);
    private PartitionTuner partitionTuner;
    private PartitionSize currentPartitionSize;
    private int nextRangeValue;
    private Preview preview;

    /** Creates a new instance of QueryExecutor_AVP */
    public QueryExecutorAvp(LocalQueryTask lqt, DBConnectionPoolEngine dbpool,
            ResultComposer resultComposer, String query, Range range,
            LocalQueryTaskStatistics lqtStatistics) throws RemoteException {
        super(lqt, dbpool, resultComposer, query, range, lqtStatistics);
        // a_partitionTuner = new PartitionTunerMeanTime(
        // a_range.getStatistics() );
        this.partitionTuner = new PartitionTunerMT_NonUniform(this.range
                .getStatistics());
        this.currentPartitionSize = null;
        if (this.lqtStatistics != null)
            this.lqtStatistics.setPartitionTuner(this.partitionTuner);
        
        preview = new Preview(range.getFirstValue(),range.getOriginalLastValue());
    }

    protected boolean getQueryLimits(int[] limits) {
        switch (state) {
        case ST_STARTING_RANGE: {
            limits[0] = range.getFirstValue();
            state = ST_PROCESSING_RANGE;
            currentPartitionSize = partitionTuner.getPartitionSize();
            break;
        }
        case ST_PROCESSING_RANGE: {
            limits[0] = nextRangeValue;
            if (partitionTuner.stillTuning()) {
                if (currentPartitionSize.getNumPerformedExecutions() >= currentPartitionSize
                        .getNumExpectedExecutions()) {
                    // Number of expected executions was reached.
                    // Send feedback to partition tuner.
                    partitionTuner.setSizeResults(currentPartitionSize);
                    // Ask a new partition size.
                    currentPartitionSize = partitionTuner.getPartitionSize();
                }
            }
            break;
        }
        default: {
            throw new IllegalThreadStateException(
                    "LocalQueryTaskEngine_AVP Exception: getQueryLimits() should not be called while in state "
                            + state + "!");
        }
        }
        limits[1] = range.getNextValue(currentPartitionSize.numberOfKeys());
        nextRangeValue = limits[1];
        if (limits[0] == limits[1]) {
            state = ST_RANGE_PROCESSED;

            /*
             * if ( a_partitionTuner.stillTuning() ) { if(
             * a_currentPartitionSize.getNumPerformedExecutions() > 0 ) { //
             * Executions were performed. // Send feedback to partition tuner.
             * a_partitionTuner.setSizeResults( a_currentPartitionSize ); // Ask
             * a new partition size. a_currentPartitionSize =
             * a_partitionTuner.getPartitionSize(); } }
             */
            partitionTuner.reset();
            return false;
        } else if (limits[0] < limits[1])
            return true;
        else
            throw new IllegalThreadStateException(
                    "LocalQueryTaskEngine_AVP Exception: lower limit superior to upper!");
    }

    protected ResultSet executeSubQuery(DBConnectionEngine dbconn,
            LocalQueryTaskStatistics statistics, String query, int[] limit) throws SQLException,
            RemoteException {

        long queryStart = System.currentTimeMillis();
        //result = dbconn.executePreparedStatement();
        
		String mysql = query;		
        while(mysql.indexOf("?") > -1) {
        	mysql = mysql.replaceFirst("\\?",limit[0]+"");
        	mysql = mysql.replaceFirst("\\?",limit[1]+"");
        }              
                        
        ResultSet result = dbconn.getConnection().createStatement().executeQuery(mysql);         

        long queryElapsedTime = System.currentTimeMillis() - queryStart;
        currentPartitionSize.setExecTime(queryElapsedTime);
        preview.setRange(nextRangeValue);
        logger.debug(Messages.getString("queryExecutorAvp.elapsedTime",new Object[]{queryElapsedTime,preview}));
        if (statistics != null)
            statistics.queryFinished(queryElapsedTime);
        return result;
    }

    class Preview {
    	private long init;
    	private int rangeBegin;
    	private int rangeEnd;
    	private int actual;
    	
    	public Preview(int rangeBegin, int rangeEnd) {
    		this.rangeBegin = rangeBegin;
    		this.rangeEnd = rangeEnd;
    		actual = rangeBegin;
    		init = System.currentTimeMillis();
    	}
    	
    	public void setRange(int range) {
    		actual = range;
    	}
    	
    	public String toString() {
    		float tr = (rangeEnd-rangeBegin+1);
    		float at = System.currentTimeMillis()-init;
    		float ar = actual-rangeBegin+1;
    		long total = (long)((tr * at)/ar);
    		return "Estimated time: "+at+"/"+total+" ms";
    	}
    }
}
