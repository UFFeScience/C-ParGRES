/*
 * ZipfDistributionCalculator.java
 *
 * Created on 9 juin 2004, 19:40
 */

package org.pargres.tests.old;

/**
 *
 * @author  lima
 */
public class ZipfDistributionCalculator {
    
    /** Creates a new instance of ZipfDistributionCalculator */
    public ZipfDistributionCalculator() {
    }
    
    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        if( args.length != 3) {
            System.out.println( "usage: java tests.ZipfDistributionCalculator Number_of_Values ResultOrder[ORIGINAL|RANDOM] Number_of_Final_Values" );
            return;
        }
        double N = Double.parseDouble( args[0] );
        String resultOrder = args[1].trim();
        if( !resultOrder.equals( "ORIGINAL" ) )
            if( !resultOrder.equals( "RANDOM" ) ) {
                System.out.println( "Invalid result order: " + resultOrder );
                return;
            }
        int numFinalValues = Integer.parseInt( args[2] );
        if( (int)N % numFinalValues != 0 ) {
            System.out.println( "The number of final values must be a divisor of the number of values" );
            return;
        }
        double []dist = determineZipfDistribution(N);
        System.out.println( "Zipf distribution:" );
        for( int i = 0; i < dist.length; i++ )
            System.out.println( "pn (n=" + i + ") = " + dist[i] );
        if( resultOrder.equals( "RANDOM" ) ) {
            dist = mix( dist, 23 );
            System.out.println( "Mixed:" );
            for( int i = 0; i < dist.length; i++ )
                System.out.println( "pn (n=" + i + ") = " + dist[i] );
        }
        
        if( numFinalValues != N ) {
            double validationSum;
            int groupSize = (int)N / numFinalValues;
            double []grouped = new double[ numFinalValues ];
            System.out.println( "Group Size = " + groupSize );
            for( int g = 0; g < grouped.length; g++ ) {
                double sum;
                sum = 0;
                for( int i = 0; i < groupSize; i++ )
                    sum += dist[g*groupSize+i];
                grouped[g] = sum;
            }
            validationSum = 0.0;
            System.out.println( "Grouped:" );
            for( int i = 0; i < grouped.length; i++ ) {
                System.out.println( "grouped[" + i + "] = " + grouped[i] );
                validationSum += grouped[i];
            }
            System.out.println( "Validation Sum = " + validationSum );
        }
    }

    public static double[] determineZipfDistribution( double N ) {
        double c = 1 / calculateHarmonicNumber( N );
        double []dist = new double[ (int)N ];
        
        for( int i=0; i<dist.length; i++ )
            dist[i] = c / ((double)(i) + 1.0);
        return dist;
    }
        
    private static double calculateHarmonicNumber( double N ) {
        double Hn = 1.0;
        for( double base = 2.0; base <= N; base++ )
            Hn += 1.0 / base;
        return Hn;
    }
    
    private static double[] mix( double[] in, int numTurns ) {
        double []out;
        double []temp;
        int toMix;
        
        out = new double[ in.length ];
        temp = new double[ in.length ];
        for( int i = 0; i < in.length; i++ )
            out[i] = in[i];
        
        for( int turn = 0; turn < numTurns; turn++ ) {
            for( int i = 0; i < out.length; i++ )
                temp[i] = out[i];
            toMix = temp.length;
            while( toMix > 0 ) {
                int position;            
                position = ((int)(Math.random() * 10.0)) % toMix;
                out[out.length - toMix] = temp[position];
                temp[position] = temp[toMix-1];
                toMix--;
            }
        }
        return out;
    }
    
}
