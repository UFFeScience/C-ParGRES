/*
 * TestConfigFile.java
 *
 * Created on 16 fevrier 2004, 16:49
 */

package org.pargres.tests.old;

/**
 *
 * @author  lima
 */

import java.io.FileReader;
import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.IOException;

public class TestConfigFile {
    
    /** Creates a new instance of TestConfigFile */
    public TestConfigFile() {
    }
    
    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        try { 
            
            readFile( args[ 0 ] );
            
        } catch( Exception e ) {
            System.err.println("Exception: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    public static void readFile( String fileName ) throws FileNotFoundException, IOException {
        String line;
        int lineCount = 1;

        // Opening configuration File
        BufferedReader configReader = new BufferedReader( new FileReader( fileName ) );
        while( (line = configReader.readLine()) != null ) {
            line = line.trim();
            if( line.length() > 0 ) // non-empty line
                if( line.charAt( 0 ) != '#' ) { 
                    char fieldSeparator = ':';
                    int separatorIndex;
                    String nodeName;

                    nodeName = null;
                    // non-comment line
                    // get nodeName
                    separatorIndex = line.indexOf( fieldSeparator );
                    if( (separatorIndex <= 0) )
                        // no node address
                        throw new IllegalArgumentException( "Line " + lineCount + ": node address not informed" );
                    else if( separatorIndex == line.length() - 1 ) 
                        // no port number 
                        throw new IllegalArgumentException( "Line " + lineCount + ": no port number" );
                    else
                        nodeName = line.substring( 0, separatorIndex).trim();
                    System.out.println( "Node Name: " + nodeName );
                    // getting port numbers 
                    while( (separatorIndex != -1) && (separatorIndex < line.length()-1) ) {
                        int nextSeparatorIndex;
                        String portNumber;

                        nextSeparatorIndex = line.indexOf( fieldSeparator, separatorIndex + 1 );
                        if( nextSeparatorIndex == -1 )
                            // last line field
                            portNumber = line.substring( separatorIndex + 1 ).trim();
                        else
                            portNumber = line.substring( separatorIndex + 1, nextSeparatorIndex ).trim();
                        if( portNumber.length() == 0 )
                            throw new IllegalArgumentException( "Line " + lineCount + ": empty port number" );
                        System.out.println( "URL: " + "//"+ nodeName + ":"+ portNumber + "/NodeQueryProcessor" );
                        separatorIndex = nextSeparatorIndex;
                    }
                    System.out.println( "--------------------------" );
                }
            lineCount++;
        }
        configReader.close();
    }
    
}
