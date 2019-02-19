/*
 * TestIntervalTree.java
 *
 * Created on 31 mai 2004, 00:38
 */

package org.pargres.tests.old;

/**
 *
 * @author  Alex
 */

import java.io.*;

import org.pargres.util.IntervalTree;


public class TestIntervalTree {
    
    /** Creates a new instance of TestIntervalTree */
    public TestIntervalTree() {
    }
    
    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        try{ 
            if( args.length != 2 ) {
                System.out.println( "usage: tests.TestIntervalTree interval_beginning interval_end" );
                return;
            }

            int beginning = Integer.parseInt( args[0] );
            int end = Integer.parseInt( args[1] );
            IntervalTree tree = new IntervalTree( beginning, end );
            BufferedReader reader = new BufferedReader( new InputStreamReader( System.in ) );

            do {
                tree.print( System.out );
                System.out.print( "Beginning: " );
                beginning = Integer.parseInt( reader.readLine() );
                if( beginning < 0 )
                    break;
                else {
                    System.out.print( "End      : " );
                    end = Integer.parseInt( reader.readLine() );
                    if( end < 0 ) 
                        break;
                    else {
                        tree.removeInterval( beginning, end );
                    }
                }
                if( tree.isEmpty() ) {
                    System.out.println( "Tree is empty!" );
                    break;
                }
            } while( true );
        } catch( Exception e ) {
            System.err.println("TestIntervalTree exception: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
