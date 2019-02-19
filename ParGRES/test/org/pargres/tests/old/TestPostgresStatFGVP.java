/*
 * TestMySql.java
 *
 * Created on 16 mars 2004, 16:03
 */

package org.pargres.tests.old;

/**
 *
 * @author  lima
 */

import java.sql.*;

public class TestPostgresStatFGVP {
    
    /** Creates a new instance of TestMySql */
    public TestPostgresStatFGVP() {
    }
    
    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        String host, port, dbname, user, pass, query;
        long startTime, endTime;
        long rowcount;
        
        if( args.length != 6 ) {
            System.out.println( "usage: java tests.TestMySql host port dbname user pass query" );
            return;
        }
        
        host = args[0].trim();
        port = args[1].trim(); 
        dbname = args[2].trim();
        user = args[3].trim();
        pass = args[4].trim();
        query = args[5].trim();
        
        try {
            Class.forName("org.postgresql.Driver").newInstance();
            
            Connection conn = DriverManager.getConnection("jdbc:postgresql://" + host + ":" + port + "/" + 
                                                          dbname, user, pass );
            Statement stmt = conn.createStatement();
            
            // Reseting DBMS statistics
            stmt.execute( "select pg_stat_reset();" );
            
            // Executing query
            startTime = System.currentTimeMillis();
            ResultSet rs = stmt.executeQuery( query );
            endTime = System.currentTimeMillis();
            
            // Showing results
            ResultSetMetaData rsmd = rs.getMetaData();
            rowcount = 0;
            while( rs.next() ) {
                System.out.print( "( " );
                for( int i = 1; i <= rsmd.getColumnCount(); i++ ) 
                    System.out.print( "'" + rs.getString( i ).trim() + "' " );
                System.out.println( ") " );
                rowcount++;
            }             
            System.out.println( "Number of tuples: " + rowcount );
            rs.close();
            
            // Getting statistics cache statistics
            rs = stmt.executeQuery( "select relid, relname, heap_blks_read, heap_blks_hit,idx_blks_read, idx_blks_hit " + 
                                    "from pg_statio_user_tables " + 
                                    "where heap_blks_read <> 0 or heap_blks_hit <> 0 or idx_blks_read <> 0 or idx_blks_hit <> 0 " +
                                    "order by relname;");
            while( rs.next() ) {
                System.out.println( "--------------------------" );
                System.out.println( "Table: " + rs.getString( "relname" ) );
                System.out.print( "heap_blks_read = " + rs.getString( "heap_blks_read" ) );
                System.out.print( ", heap_blks_hit = " + rs.getString( "heap_blks_hit" ) );
                System.out.print( ", idx_blks_read = " + rs.getString( "idx_blks_read" ) );
                System.out.println( ", idx_blks_hit = " + rs.getString( "idx_blks_hit" ) );
            }
            rs.close();
            System.out.println( "--------------------------" );
            System.out.println( "Elapsed time: " + (endTime - startTime) + " ms." );
            stmt.close();
            conn.close();
        } catch (Exception e) {
            System.err.println("TestMySql exception: " + e.getMessage());
            e.printStackTrace();
        }
        
    }
    
}
