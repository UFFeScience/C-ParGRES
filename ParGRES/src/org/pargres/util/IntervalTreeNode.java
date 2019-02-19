/*
 * IntervalTreeNode.java
 *
 * Created on 30 mai 2004, 20:29
 */

package org.pargres.util;

/**
 *
 * @author  Alex
 */

import java.io.PrintStream;

public class IntervalTreeNode {
    
    static private final int ITN_INTERMEDIATE = 0;
    static private final int ITN_LEAF = 1;

    protected int beginning;
    protected int end;
    protected int nodeType;
    
    // used when node is intermediate
    protected IntervalTreeNode leftSon;
    protected IntervalTreeNode rightSon;
    
    /** Creates a new instance of IntervalTreeNode */
    public IntervalTreeNode( int pbeginning, int pend ) {
        if( !validInterval( pbeginning, pend ) )
            throw new IllegalArgumentException( "IntervalNodeTree.removeInterval: invalid interval (" + pbeginning + "," + pend + ") !" );            
        beginning = pbeginning;
        end = pend;
        nodeType = ITN_LEAF;
        leftSon = null;
        rightSon = null;
    }
    
    // Remove a sub interval from this one.
    // Returns: 1, if this interval still have subintervals to be processed
    //          0, if this interval has entirely been processed
    public int removeInterval( int rbeginning, int rend ) {
        if( !validInterval( rbeginning, rend ) )
            throw new IllegalArgumentException( "IntervalNodeTree.removeInterval: invalid interval (" + rbeginning + "," + rend + ") !" );
        if( !internalInterval( rbeginning, rend ) )
            throw new IllegalArgumentException( "IntervalNodeTree.removeInterval: can't remove (" + rbeginning + "," + rend + ") from (" + beginning + "," + end + ") !" );
        if( nodeType == ITN_LEAF ) {
            if( beginning == rbeginning ) {
                if( end == rend )
                    return 0; // interval has entirely been processed
                else {
                    // rend < end
                    beginning = rend;
                    return 1;
                }
            }
            else if( end == rend ) {
                end = rbeginning;
                return 1;
            }
            else {
                // Interval to be removed is entirely inside this interval. Split.
                nodeType = ITN_INTERMEDIATE;
                leftSon = new IntervalTreeNode( beginning, rbeginning );
                rightSon = new IntervalTreeNode( rend, end );
                return 1;
            }
        }
        else {
            // intermediate node
            if( rend <= leftSon.end ) {
                // remove from left
                if( leftSon.removeInterval( rbeginning, rend ) == 0 ) {
                    // Left son has entirely been processed.
                    // Get values from right son
                    nodeType = rightSon.nodeType;
                    beginning = rightSon.beginning;
                    end = rightSon.end;
                    leftSon = rightSon.leftSon;
                    rightSon = rightSon.rightSon;
                }
            }
            else {
                // remove from right
                if( rightSon.removeInterval( rbeginning, rend ) == 0 ) {
                    // Right son has entirely been processed.
                    // Get values from left son
                    nodeType = leftSon.nodeType;
                    beginning = leftSon.beginning;
                    end = leftSon.end;
                    rightSon = leftSon.rightSon;
                    leftSon = leftSon.leftSon;
                }
            }
            return 1;
        }
    }
    
    private boolean validInterval( int pbeginning, int pend ) {
        if( pbeginning >= pend )
            return false;
        else
            return true;        
    }
    
    private boolean internalInterval( int pbeginning, int pend ) {
        if( (beginning <= pbeginning) && (end >= pend) )
            return true;
        else
            return false;
    }
    
    public void print( PrintStream p, String prefix ) {
        if( nodeType == ITN_INTERMEDIATE ) {
            p.println( prefix + "->" );
            leftSon.print( p, prefix + "\t" );
            rightSon.print( p, prefix + "\t" );
        }
        else
            p.println( prefix + "( " + beginning + " - " + end + " )" );
    }
}
