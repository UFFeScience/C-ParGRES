/*
 * NationRealStatistics.java
 *
 * Created on 6 juin 2004, 21:04
 */

package org.pargres.tpch;

/**
 *
 * @author  Alex
 */
public class NationRealStatistics {
    
    int a_id;
    String a_name;
    double a_population;
    
    /** Creates a new instance of NationRealStatistics */
    public NationRealStatistics( int id, String name, double population ) {
        a_id = id;
        a_name = name;
        a_population = population;
    }
    
    public int getId() {
        return a_id;
    }
    
    public String getName() {
        return a_name;
    }
    
    public double getPopulation() {
        return a_population;
    }
}
