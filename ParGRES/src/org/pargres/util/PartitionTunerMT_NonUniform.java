/*
 * PartitionTunerStartSmall.java
 *
 * Created on 6 fevrier 2004, 14:35
 */

package org.pargres.util;

/**
 *
 * @author  lima
 */

import java.io.PrintStream;

/**
 Tune starting with only one key. At each iteraction, double. Stops when the estimated time is worse. 
 Only one size is tested at each time
 */

public class PartitionTunerMT_NonUniform extends PartitionTuner {

    private static final long serialVersionUID = 3907211554917987381L;

    //private final boolean debug = false;
    //private Logger logger = Logger.getLogger(PartitionTunerMT_NonUniform.class);

    // PartitionTuner States
    private final int INITIAL = 0;
    private final int SEARCHING = 1;
    private final int SET = 2;
    private final int RESTARTING = 3;
    private final int TRAVERSING_LOW_DENSITY_REGION = 4;

    private final int NUMBER_OF_EXECUTIONS = 1; // number of executions to test each different size
    private final int INITIAL_NUMBER_OF_KEYS = 1024; // number of keys to the first size that will be tested

    private final float INITIAL_SIZE_GROWTH_TAX = (float) 1.0;
    private final float RESTART_SIZE_GROWTH_TAX = INITIAL_SIZE_GROWTH_TAX
            * (float) 0.2;
    private final float REDUCTION_IN_SIZE_GROWTH_TAX = (float) 0.75;
    private final float MIN_SIZE_GROWTH_TAX = (float) 0.1;
    private final float SIZE_REDUCTION_WHILE_RESTARTING = (float) 0.05;

    private final int MAX_CHANCES_FOR_SET = 3;

    private final float MEANTIME_GROWTH_TOLERANCE = (float) 0.25; // to be applied over the "size increasing tax" being used
    private final float MEANTIME_SET_TOLERANCE = (float) 0.1; // to be used while evaluating current size

    private RangeStatistics rangeStatistics; // to help calculating partition sizes in terms of number of key values and ratio

    private int state; // To store tuner state

    private int currentNumKeys; // currently used size (in terms of keys)
    private float meanTimeCurrentNumKeys; // execution time of the best number of keys
    //private int a_greatestNumKeys; // greatest number of keys already tested
    private float sizeGrowthTax; // growth tax currently being used
    private int numTimesSetWorse; // number of times the mean exec time was worse than when it was SET
    //private float a_meanExecTimeBeforeRestart; // mean execution time before RESTARTING state

    // for max size
    private int maxNumberOfKeys; // to establish a limit over the partition size
    private int numTimesMaxWouldNotBeRespected; // only statistics

    // for re-search
    private int numReTunings; // statistics
    private int numSets; // statistics

    // Non-uniform regions support
    private final int LOW_DENSITY_DETECTION_THRESHOLD = 3;
    /* LOW_DENSITY_DETECTION_THRESHOLD - used for low-density detection. 
     * Determines how many times a size growth may not be followed by a 
     * reasonable growth in mean execution time before considering 
     * a low-density region has been reached.
     */
    private final float MEANTIME_LOW_DENSITY_TOLERANCE = (float) 0.01; // to be used while evaluating current size in low-density regions
    private int lowDensityCounter; // Counter used in conjunction with LOW_DENSITY_DETECTION_THRESHOLD to detect low-density regions.
    private int numLowDensityDetections;
    private int numIterInsideLowDensityRegion;

    // Public  Methods ----------------------------------------------

    /** Creates a new instance of PartitionTuner */
    public PartitionTunerMT_NonUniform(RangeStatistics rangeStatistics) {
        state = INITIAL;
        this.rangeStatistics = rangeStatistics;

        maxNumberOfKeys = calculateNumberOfKeys(this.rangeStatistics
                .getMaxSizeRatio());
        numTimesMaxWouldNotBeRespected = 0;
        numReTunings = 0;
        numLowDensityDetections = 0;
        numIterInsideLowDensityRegion = 0;
    }

    public boolean stillTuning() {
        return true; // always tuning
    }

    // Called by QueryExecutor when finished testing one size
    // When using many QueryExecutors, make this method SYNCHRONIZED
    public void setSizeResults(PartitionSize size)
            throws IllegalThreadStateException {

        switch (state) {
        case INITIAL: {
            throw new IllegalThreadStateException(
                    "Some object is trying to set results before first test");
        }
        case SEARCHING: {
            if (currentNumKeys == 0) {
                currentNumKeys = size.numberOfKeys(); // first set operation
                meanTimeCurrentNumKeys = size.getMeanExecutionTime();
                sizeGrowthTax = INITIAL_SIZE_GROWTH_TAX;
                lowDensityCounter = 0;
                if (currentNumKeys == maxNumberOfKeys) {
                    state = SET; // Max size. Cannot grow.
                    numTimesSetWorse = 0;
                }
            } else if (size.getMeanExecutionTime() <= (meanTimeCurrentNumKeys * (1.0 + MEANTIME_GROWTH_TOLERANCE
                    * sizeGrowthTax))) {
                // Size is better than best. 
                if (size.getMeanExecutionTime() <= meanTimeCurrentNumKeys) {
                    // Size has grown but execution time has been reduced. Maybe, we entered a low-density region.
                    // If we keep growing, there is the risk of reaching a normal region with a big partition size.
                    // Increment counter.
                    currentNumKeys = size.numberOfKeys();
                    //meanTimeCurrentNumKeys = size.getMeanExecutionTime();
                    lowDensityCounter++;
                    if (lowDensityCounter > LOW_DENSITY_DETECTION_THRESHOLD) {
                        state = TRAVERSING_LOW_DENSITY_REGION;
                        numLowDensityDetections++;
                    }
                } else {
                    //Change best. Continue searching.
                    currentNumKeys = size.numberOfKeys();
                    meanTimeCurrentNumKeys = size.getMeanExecutionTime();
                    lowDensityCounter = 0;
                    if (currentNumKeys == maxNumberOfKeys) {
                        state = SET; // Max size. Cannot grow.
                        numTimesSetWorse = 0;
                    }
                }
            } else {
                // Size is worse than best. Reduce growth tax.
                sizeGrowthTax = sizeGrowthTax
                        * ((float) 1.0 - REDUCTION_IN_SIZE_GROWTH_TAX);
                if (sizeGrowthTax < MIN_SIZE_GROWTH_TAX) {
                    state = SET;
                    numTimesSetWorse = 0;
                }
                lowDensityCounter = 0;
            }
            break;
        }
        case SET: {
            if (size.numberOfKeys() != currentNumKeys)
                throw new IllegalArgumentException(
                        "SET: Size was expected to be equal to current. current = "
                                + currentNumKeys + ". Size = "
                                + size.numberOfKeys());
            numSets++;
            if (size.getMeanExecutionTime() > (meanTimeCurrentNumKeys * (1.0 + MEANTIME_SET_TOLERANCE))) {
                numTimesSetWorse++;
                //if( numTimesSetWorse == 1 )
                //    a_meanExecTimeBeforeRestart = meanTimeCurrentNumKeys;
                if (numTimesSetWorse > MAX_CHANCES_FOR_SET) {
                    state = RESTARTING; // Best size is going worse. Re-Start tuning.
                    numReTunings++;
                    numTimesSetWorse = 0;
                }
            } else {
                numTimesSetWorse = 0;
                if (size.getMeanExecutionTime() < meanTimeCurrentNumKeys)
                    meanTimeCurrentNumKeys = size.getMeanExecutionTime();
            }
            break;
        }
        case RESTARTING: {
            currentNumKeys = size.numberOfKeys(); // first set operation
            meanTimeCurrentNumKeys = size.getMeanExecutionTime();
            if (currentNumKeys == maxNumberOfKeys) {
                state = SET; // Max size. Cannot grow.
                numTimesSetWorse = 0;
            } else {
                state = SEARCHING;
                sizeGrowthTax = RESTART_SIZE_GROWTH_TAX;
                lowDensityCounter = 0;
            }
            break;
        }
        case TRAVERSING_LOW_DENSITY_REGION: {
            if (size.numberOfKeys() != currentNumKeys)
                throw new IllegalArgumentException(
                        "TRAVERSING_LOW_DENSITY_REGION: Size was expected to be equal to current. current = "
                                + currentNumKeys
                                + ". Size = "
                                + size.numberOfKeys());
            numIterInsideLowDensityRegion++;
            if (size.getMeanExecutionTime() > meanTimeCurrentNumKeys
                    * (1.0 + MEANTIME_LOW_DENSITY_TOLERANCE)) {
                //a_state = RESTARTING; // Best size is going worse. Re-Start tuning.
                state = INITIAL; // Best size is going worse. Re-Start tuning.
            }
            break;
        }
        default:
            throw new IllegalThreadStateException(
                    "PartitionTuner at an unknown state: " + state);
        }
    }

    // Called by QueryExecutor when demanding a new partition size tu use
    // When using many QueryExecutors, make this method SYNCHRONIZED
    public PartitionSize getPartitionSize() throws IllegalThreadStateException {
        PartitionSize size = null;

        /*(
            switch (state) {
            case INITIAL: {
                logger.debug(Messages"State = INITIAL");
                break;
            }
            case SET: {
            	logger.debug("State = SET");
                break;
            }
            case SEARCHING: {
            	logger.debug("State = SEARCHING");
                break;
            }
            case RESTARTING: {
            	logger.debug("State = RESTARTING");
                break;
            }
            case TRAVERSING_LOW_DENSITY_REGION: {
            	logger.debug("State = TRAVERSING_LOW_DENSITY_REGION");
                break;
            }
            }*/

        switch (state) {
        case INITIAL: {
            currentNumKeys = 0;
            meanTimeCurrentNumKeys = 0;
            //a_greatestNumKeys = 0;
            size = new PartitionSize(calculateRatio(INITIAL_NUMBER_OF_KEYS),
                    INITIAL_NUMBER_OF_KEYS, NUMBER_OF_EXECUTIONS);
            state = SEARCHING;
            break;
        }
        case SET: {
            size = new PartitionSize(calculateRatio(currentNumKeys),
                    currentNumKeys, 1);
            break;
        }
        case SEARCHING: {
            int numkeys;
            numkeys = (int) Math.ceil((double) currentNumKeys
                    * (1.0 + sizeGrowthTax));
            if (numkeys > maxNumberOfKeys) {
                numkeys = maxNumberOfKeys;
                numTimesMaxWouldNotBeRespected++;
            }
            size = new PartitionSize(calculateRatio(numkeys), numkeys,
                    NUMBER_OF_EXECUTIONS);
            break;
        }
        case RESTARTING: {
            int numkeys;
            numkeys = (int) Math.ceil((double) currentNumKeys
                    / (1.0 + SIZE_REDUCTION_WHILE_RESTARTING));
            if (numkeys < 1)
                numkeys = 1;
            size = new PartitionSize(calculateRatio(numkeys), numkeys,
                    NUMBER_OF_EXECUTIONS);
            break;
        }
        case TRAVERSING_LOW_DENSITY_REGION: {
            size = new PartitionSize(calculateRatio(currentNumKeys),
                    currentNumKeys, 1);
            break;
        }
        default:
            throw new IllegalThreadStateException(
                    "PartitionTuner at an unknown state: " + state);
        }

        return size;
    }

    public void printTuningStatistics(PrintStream out) {
        out.println("Upper limit for the number of keys: " + maxNumberOfKeys);
        out.println("Number of Re-Tuning operations: " + numReTunings);
        out.println("Number of SET states: " + numSets);
        out.println("The limit would not be respected "
                + numTimesMaxWouldNotBeRespected + " times.");
        out.println("Number of times a low-density region has been detected: "
                + numLowDensityDetections);
        out.println("Number of iteractions inside a low-density region: "
                + numIterInsideLowDensityRegion);
    }

    // Private Methods ----------------------------------------------

    private float calculateRatio(int numberOfKeys) {
        return (float) ((((float) numberOfKeys) * rangeStatistics
                .getMeanNumTuplesPerValue()) / rangeStatistics
                .getTotalNumberOfTuples());
    }

    private int calculateNumberOfKeys(float ratio) {
        return (int) ((ratio * rangeStatistics.getTotalNumberOfTuples()) / rangeStatistics
                .getMeanNumTuplesPerValue());
    }

    public void reset() {
        state = INITIAL;
    }

}
