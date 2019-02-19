/*
 * Range.java
 *
 * Created on 12 janvier 2004, 13:28
 */

package org.pargres.util;

import java.io.Serializable;

/**
 * 
 * @author lima
 */
public class Range implements Serializable {

    private static final long serialVersionUID = 4051322344863578417L;

    private int idOwner;
    private int firstValue;
    // last value initially supplied. It can change due to dynamic load
    // balancing
    private int originalLastValue;
    // current last value. Can be different from the one initially supplied due
    // to dynamic load balancing
    private int currentLastValue;
    // last processed value + 1
    private int currentValue;
    // query arguments that must receive the first value
    private int[] argumentFirstValue;
    // query arguments that must receive the last value
    private int[] argumentLastValue;
    // Number of virtual partitions into which this interval should be divided
    private int numVPs;
    // Virtual partition size. Calculated according to a_numVPs
    private int vpSize;
    // Used for partition size modulation. Not to be changed by Range.
    private RangeStatistics statistics;

    /** Creates a new instance of Range */
    public Range(int idOwner, int firstValue, int lastValue,
            int[] argumentFirstValue, int[] argumentLastValue, int numVPs,
            RangeStatistics statistics) {
        if (firstValue > lastValue) {
            throw new IllegalThreadStateException("Invalid range ("
                    + firstValue + "," + lastValue + ").");
        }
        this.idOwner = idOwner;
        this.firstValue = firstValue;
        this.originalLastValue = lastValue;
        this.currentLastValue = this.originalLastValue;
        this.currentValue = this.firstValue;
        this.argumentFirstValue = argumentFirstValue;
        this.argumentLastValue = argumentLastValue;
        this.numVPs = numVPs;
        this.vpSize = (this.originalLastValue - this.firstValue) / this.numVPs;
        this.statistics = statistics;
    }

    public Range(int idOwner, int firstValue, int lastValue,
            int[] argumentFirstValue, int[] argumentLastValue, int numVPs) {
        this(idOwner, firstValue, lastValue, argumentFirstValue,
                argumentLastValue, numVPs, null);
    }

    public int getFirstValue() {
        return firstValue;
    }

    public int getOriginalLastValue() {
        return originalLastValue;
    }

    public synchronized int getCurrentLastValue() {
        return currentLastValue;
    }

    public int getNumberArgumentsFirstValue() {
        return argumentFirstValue.length;
    }

    public int getArgumentFirstValue(int argNumber) {
        return argumentFirstValue[argNumber];
    }

    public int[] getAllArgumentsFirstValue() {
        return argumentFirstValue;
    }

    public int getNumberArgumentsLastValue() {
        return argumentLastValue.length;
    }

    public int getArgumentLastValue(int argNumber) {
        return argumentLastValue[argNumber];
    }

    public int[] getAllArgumentsLastValue() {
        return argumentLastValue;
    }

    public int getNumVPs() {
        return numVPs;
    }

    public int getVPSize() {
        return vpSize;
    }

    public RangeStatistics getStatistics() {
        return statistics;
    }

    public synchronized int getNextValue(int intervalSize) {
        if (currentValue < currentLastValue) {
            currentValue += intervalSize;
            if (currentValue > currentLastValue)
                currentValue = currentLastValue;
        } else if (currentValue > currentLastValue) {
            // a_currentValue > a_currentLastValue
            throw new IllegalThreadStateException(
                    "LocalQueryInterval Exception: Current value ("
                            + currentValue
                            + ") is greater then current last value ("
                            + currentLastValue
                            + "). It can cause errors on final result");
        }
        // if( a_currentValue == a_currentLastValue ) --> Interval limit
        // reached. Cannot continue growing. Return the same value.
        notifyAll();
        return currentValue;
    }

    public synchronized void reset(int idOwner, int firstValue, int lastValue) {
        this.idOwner = idOwner;
        this.firstValue = firstValue;
        this.originalLastValue = lastValue;
        this.currentLastValue = this.originalLastValue;
        this.currentValue = this.firstValue;
        this.vpSize = (this.originalLastValue - this.firstValue) / this.numVPs;
        notifyAll();
    }

    public synchronized Range cutTail(float fraction) {
        // Cut a fraction of the not processed interval starting from its end
        Range tail;

        if (currentValue == currentLastValue) {
            // there is nothing else to be done!
            tail = null;
        } else {
            int newIntervalFirstValue, newIntervalLastValue;

            newIntervalFirstValue = currentLastValue
                    - (int) Math.ceil((currentLastValue - currentValue)
                            * fraction);
            if (newIntervalFirstValue == currentLastValue)
                tail = null;
            else {
                if (newIntervalFirstValue < currentValue) {
                    // all non-processed interval was caught
                    newIntervalFirstValue = currentValue;
                }
                newIntervalLastValue = currentLastValue;
                currentLastValue = newIntervalFirstValue;
                tail = new Range(idOwner, newIntervalFirstValue,
                        newIntervalLastValue, argumentFirstValue,
                        argumentLastValue, numVPs, statistics);
                if (currentValue == currentLastValue)
                    if (firstValue == currentLastValue) {
                        // This situation can occurr when a node received an
                        // interval and, before starting processing it,
                        // received help. The interval was so small that it has
                        // been entirely given to another node.
                        System.out
                                .println("I think this interval has not been processed here: First Value = "
                                        + firstValue
                                        + "; Current Value = "
                                        + currentValue
                                        + "; Current Last Value = "
                                        + currentLastValue
                                        + "; Original Last Value = "
                                        + originalLastValue);
                    }
            }
        }
        notifyAll();
        return tail;
    }

    public synchronized float getUnprocessedFraction() {
        // return the fraction of the interval that still needs to be processed
        float fraction = (float) (currentLastValue - currentValue)
                / (float) (currentLastValue - firstValue);
        notifyAll();
        return fraction;
    }

    public int getIdOwner() {
        return idOwner;
    }

	public void setFirstValue(int firstValue) {
		this.firstValue = firstValue;
	}

	public void setOriginalLastValue(int originalLastValue) {
		this.originalLastValue = originalLastValue;
	}

}
