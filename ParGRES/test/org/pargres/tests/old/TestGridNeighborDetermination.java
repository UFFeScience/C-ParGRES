/*
 * TestGridNeighborDetermination.java
 *
 * Created on 31 mai 2004, 02:05
 */

package org.pargres.tests.old;

/**
 *
 * @author  Alex
 */

import java.io.*;

public class TestGridNeighborDetermination {
    
    /** Creates a new instance of TestGridNeighborDetermination */
    public TestGridNeighborDetermination() {
    }
    
    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        try{ 
            if( args.length != 1 ) {
                System.out.println( "usage: tests.TestIntervalTree number_of_nodes" );
                return;
            }
            
            BufferedReader reader = new BufferedReader( new InputStreamReader( System.in ) );
            boolean a_respForEastMsgLastLine;
            int a_numlqts = Integer.parseInt( args[0] );
            int a_numNodesPerLine = (int) Math.ceil( Math.sqrt( a_numlqts ) );
            int a_numGridLines = (int) Math.ceil( (float)a_numlqts / (float)a_numNodesPerLine );

            System.out.println( "Number of Nodes : " + a_numlqts );
            System.out.println( "Nodes per line  : " + a_numNodesPerLine );
            System.out.println( "Number of lines : " + a_numGridLines );
            reader.readLine();
            
            for( int a_id = 0; a_id < a_numlqts; a_id++ ) {
                int a_line = (int) Math.floor( a_id / a_numNodesPerLine );   // line occupied by the node if it was in a grid
                int a_column = a_id % a_numNodesPerLine; // column occupied by the node if it was in a grid
                int a_numRefusesForHelpReoffer;
                
                int neighbor, neighborEast;
                
                System.out.println( "----------------------------------------" );
                System.out.println( "Node  : " + a_id + " - (" + a_line + "," + a_column + ")" );
                
                // Calculate neighbors
                // North
                System.out.print( "North : " );
                if( a_line > 0 )
                    neighbor = ( a_line - 1 ) * a_numNodesPerLine + a_column;
                else
                    neighbor = -1;
                System.out.println( neighbor );

                // East
                System.out.print( "East : " );
                if( a_column < (a_numNodesPerLine - 1) ) {
                    neighbor = a_line * a_numNodesPerLine + (a_column + 1);
                    if( neighbor >= a_numlqts ) {
                        // Grid is not a square.
                        neighbor = -1;
                    }
                }
                else
                    neighbor = -1;
                neighborEast = neighbor;
                System.out.println( neighbor );

                // South
                System.out.print( "South : " );
                if( a_line < (a_numGridLines - 1) ) {
                    neighbor = ( a_line + 1 ) * a_numNodesPerLine + a_column;                
                    if( neighbor >= a_numlqts ) {
                        // Grid is not a square.
                        neighbor = -1;
                        a_respForEastMsgLastLine = false; 
                    }
                    else 
                        if( (neighbor == a_numlqts - 1) && (neighborEast != -1 ) )
                            a_respForEastMsgLastLine = true;
                        else
                            a_respForEastMsgLastLine = false;
                }
                else {
                    neighbor = -1;
                    a_respForEastMsgLastLine = false;
                }
                System.out.println( neighbor );

                // West
                System.out.print( "West  : " );
                if( a_column > 0 )
                    neighbor = a_line * a_numNodesPerLine + (a_column - 1);
                else
                    neighbor = -1;            
                System.out.println( neighbor );
                
                if( a_respForEastMsgLastLine )
                    System.out.println( "Responsible for messages from West on last line!" );
                
                // determine how many help refuse messages must arrive before repeating help offering
                if( (a_column == 0) || (a_column == a_numNodesPerLine - 1) ) {
                    if( (a_column == 0) && (a_id == a_numlqts - 1) )
                        a_numRefusesForHelpReoffer = a_numGridLines - 1;
                    else
                        a_numRefusesForHelpReoffer = a_numGridLines;
                }
                else if( a_id == a_numlqts - 1 ) {
                    a_numRefusesForHelpReoffer = (2 * a_numGridLines) - 1;
                }
                else {
                    a_numRefusesForHelpReoffer = 2 * a_numGridLines;
                    if( a_numlqts - (a_numNodesPerLine * (a_numGridLines - 1) ) == 1 ) {
                        // Only one node in the last line. One less message is needed.
                        a_numRefusesForHelpReoffer--;
                    }
                }
                System.out.println( "Number of refuses for help reoffering: " + a_numRefusesForHelpReoffer );
                
                reader.readLine();
            }
        } catch( Exception e ) {
            System.err.println("TestGridNeighborDetermination exception: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
