/*
 * Grouper.java
 *
 * Created on 12 decembre 2003, 15:32
 */

package org.pargres.grouper;

import java.sql.ResultSet;

/**
 * 
 * @author lima
 */

public abstract class Grouper {
    protected double id;
    public static final int RANGE = 0;
    public static final int HASH = 1;

    public abstract void insert(ResultSet result);

    public abstract ResultSet getAggregatedResult();

    public abstract ResultSet getAggregatedResult(int node, int method);

    public abstract int size();

    public abstract void clear();

    public abstract ResultSet finish();
}
