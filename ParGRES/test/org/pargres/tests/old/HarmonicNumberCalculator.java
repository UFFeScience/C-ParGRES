/*
 * HarmonicNumberCalculator.java
 *
 * Created on 9 juin 2004, 19:20
 */

package org.pargres.tests.old;

/**
 *
 * @author  lima
 */
public class HarmonicNumberCalculator {
    
    /** Creates a new instance of HarmonicNumberCalculator */
    public HarmonicNumberCalculator() {
    }
    
    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        if( args.length != 1) {
            System.out.println( "usage: java tests.HarmonicNumberCalculator N" );
            return;
        }
        double N = Double.parseDouble( args[0] );        
        System.out.println( "Hn (n=" + N + ") = " + calculateHarmonicNumber( N ) );
    }
    
    public static double calculateHarmonicNumber( double N ) {
        double Hn = 1.0;
        for( double base = 2.0; base <= N; base++ )
            Hn += 1.0 / base;
        return Hn;
    }
    
}
