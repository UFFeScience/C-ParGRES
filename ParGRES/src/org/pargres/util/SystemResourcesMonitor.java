/*
 * Monitor.java
 *
 * Created on September 22, 2004, 2:34 PM
 */

package org.pargres.util;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;

import org.pargres.commons.logger.Logger;

/**
 *
 * @author  assis
 */

public class SystemResourcesMonitor implements Runnable{

	private Logger logger = Logger.getLogger(SystemResourcesMonitor.class);
    private final int sampleInterval = 1; // vmstat sample interval in seconds
    private final String monitorCommand = "vmstat -n " + sampleInterval;
    private static BufferedReader reader;
    private static Process proc;
    private static String vmstatLine="";
    private static boolean terminationRequested;
    private static double blocksReadCounter;
    private static double blocksWrittenCounter;
    private static boolean firstReading;

    /** Creates a new instance of Monitor */
    public SystemResourcesMonitor() throws IOException {
    	if(true)return;
        terminationRequested = false;
        proc=Runtime.getRuntime().exec( monitorCommand );
        reader=new BufferedReader(new InputStreamReader(proc.getInputStream()));
        //dispose header lines and first result line
        reader.readLine();
        reader.readLine();
        reader.readLine();
        blocksReadCounter = 0;
        blocksWrittenCounter = 0;
        firstReading = true;
    }

    protected void finalize() throws Throwable {
        if ( proc!=null ) {
            proc.destroy();
            proc=null;
        }
    }

    public void start() {
        Thread t = new Thread( this );
        t.start();
    }

    public void run() {
    	if(true)return;    	
        String vmstatLine;
        while( !terminationRequested ) {
            try {
                Thread.sleep( sampleInterval * 1000 );
                synchronized (this) {
                    vmstatLine = getVmstatOutput();
                    if( vmstatLine == null )
                        throw new RuntimeException("Could not read vmstat output!");
                    int length = vmstatLine.length();
                    if( firstReading ) {
                        // does not consider the first reading
                        firstReading = false;
                    }
                    else {
                      if( length < 76 )
                        throw new RuntimeException("Invalid size for vmstat output line: " + length );
                      blocksReadCounter += getBlocksRead( vmstatLine ) * sampleInterval;
                      blocksWrittenCounter += getBlocksWritten( vmstatLine ) * sampleInterval;
                      notifyAll();
                    }
                }
                //System.out.println( blocksReadCounter );
            } catch( Throwable e ) {
                logger.error( "dbcluster.SystemResourcesMonitor Exception: " + e.getMessage() );
                e.printStackTrace();
                return;
            }
        }
        if ( proc!=null ) {
            proc.destroy();
            proc=null;
        }
    }

    public synchronized void finish() {
        if (!terminationRequested)
            terminationRequested = true;
        notifyAll();
    }

    public synchronized void resetCounters() {
        blocksReadCounter = 0;
        blocksWrittenCounter = 0;
        notifyAll();
    }

    public synchronized SystemResourceStatistics getStatistics() {
        SystemResourceStatistics stat = new SystemResourceStatistics();
        stat.setNumberOfBlocksRead( blocksReadCounter );
        stat.setNumberOfBlocksWritten( blocksWrittenCounter );
        notifyAll();
        return stat;
    }

    private static String getVmstatOutput() throws IOException {
        while(reader.ready())
            vmstatLine=reader.readLine();
        return vmstatLine;
    }

    private static long getBlocksRead( String vmstatLine ) throws NumberFormatException, IOException {
        String bi = vmstatLine.substring( 45, 51 );
        return Integer.parseInt( bi.trim() );

    }

    private static long getBlocksWritten( String vmstatLine ) throws NumberFormatException, IOException {
        String bi = vmstatLine.substring( 51, 57 );
        return Integer.parseInt( bi.trim() );

    }

}
