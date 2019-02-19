/*
 * MathUtilities.java
 *
 * Created on 10 juin 2004, 13:32
 */

package org.pargres.util;

/**
 *
 * @author  lima
 */
public class MathUtilities {
    
    /** Creates a new instance of MathUtilities */
    public MathUtilities() {
    }

    public static double[] calculateZipfDistribution( double N ) {
        double c = 1 / calculateHarmonicNumber( N );
        double []dist = new double[ (int)N ];
        
        for( int i=0; i<dist.length; i++ )
            dist[i] = c / ((double)(i) + 1.0);
        return dist;
    }    
    
    public static double calculateHarmonicNumber( double N ) {
        double Hn = 1.0;
        for( double base = 2.0; base <= N; base++ )
            Hn += 1.0 / base;
        return Hn;
    }
    
}
