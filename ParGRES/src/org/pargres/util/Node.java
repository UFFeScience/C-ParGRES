/*
 * Node.java
 *
 * Created on 11 fevrier 2004, 16:21
 */

package org.pargres.util;

import java.util.concurrent.atomic.AtomicLong;

import org.pargres.nodequeryprocessor.NodeQueryProcessor;

/**
 *
 * @author  lima
 */
public class Node {
    
    private String a_address;
    private NodeQueryProcessor []a_nqp;
    private AtomicLong load = new AtomicLong();
    
    /** Creates a new instance of Node */
    public Node( String address, NodeQueryProcessor []nqp ) {
        a_address = address;
        a_nqp = nqp;
    }

    public String getAddress() { 
        return a_address;
    }
    
    public NodeQueryProcessor getNQP ( int num ) throws ArrayIndexOutOfBoundsException {
        if( a_nqp == null )
            throw new ArrayIndexOutOfBoundsException( "There is no NodeQueryProcessor on node " + a_address );            
        if( num < 0 || num > a_nqp.length )
            throw new ArrayIndexOutOfBoundsException( num );
        return a_nqp[ num ];
    }
    
    public int getNumNQPs() {
        if( a_nqp == null )
            return 0;
        else
            return a_nqp.length;
    }

	public void incLoad() {
		load.incrementAndGet();
	}

	public void decLoad() {
		load.decrementAndGet();
	}
	
	public long getLoad() {
		return load.get();
	}
    
}
