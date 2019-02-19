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

public class TestMySql {
    
    /** Creates a new instance of TestMySql */
    public TestMySql() {
    }
    
    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        String host, port, dbname, user, pass, query;
        
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
            Class.forName("com.mysql.jdbc.Driver").newInstance();
            
            Connection conn = DriverManager.getConnection("jdbc:mysql://" + host + ":" + port + "/" + 
                                                          dbname + "?autoReconnect=true", user, pass );
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery( query );
            ResultSetMetaData rsmd = rs.getMetaData();
            
            while( rs.next() ) {
                System.out.print( "( " );
                for( int i = 1; i <= rsmd.getColumnCount(); i++ ) 
                    System.out.print( "'" + rs.getString( i ).trim() + "' " );
                System.out.println( ") " );
            }
            
            rs.close();
            stmt.close();
            conn.close();
        } catch (Exception e) {
            System.err.println("TestMySql exception: " + e.getMessage());
            e.printStackTrace();
        }
        
    }
    
}
