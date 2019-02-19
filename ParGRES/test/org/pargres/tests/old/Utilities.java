/*
 * Util.java
 *
 * Created on 9 juin 2004, 13:00
 */

/**
 *
 * @author  lima
 */

package org.pargres.tests.old;

public class Utilities {
    
    /** Creates a new instance of Util */
    public Utilities() {
    }
    
    public static String createResultFileName( int numQuery, String technique, int numExecutions, int tpchScaleFactor, int numNodes ) {
        return  technique.trim() + "_query" + (numQuery < 10 ? "0" + numQuery : "" + numQuery ) +
                "_" + numNodes + "nodes_" + numExecutions + "exec_tpchSF" + tpchScaleFactor + ".txt";
    }
}
