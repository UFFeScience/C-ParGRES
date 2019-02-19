/*
 * TestDDL.java
 *
 * Created on 5 mars 2004, 14:46
 */

package org.pargres.tests.old;

/**
 *
 * @author  lima
 */

import java.sql.*;

public class TestDDL {
    
    /** Creates a new instance of TestDDL */
    public TestDDL() {
    }
    
    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        try{ 
            Class.forName( "org.postgresql.Driver" );
            Connection conn = DriverManager.getConnection( "jdbc:postgresql://localhost:3669/tpch_sf1", "lima", "" );
            System.out.println( "Connected." );
            conn.setAutoCommit( false );
            Statement stmt = conn.createStatement();
            stmt.addBatch( "create table t ( a integer, b character varying (30), primary key (a) );" );
            System.out.println( "Table Created." );
            stmt.addBatch( "create index idx_t on t(b);" );
            System.out.println( "Index Created." );
            stmt.addBatch( "insert into t(a,b) values (1, 'primeira linha');" );
            stmt.addBatch( "insert into t(a,b) values (2, 'segunda linha');" );
            stmt.addBatch( "insert into t(a,b) values (3, 'terceira linha');" );
            System.out.println( "Rows Inserted." );
            stmt.executeBatch();
            conn.commit();
            System.out.println( "Commit." );
            stmt.clearBatch();
            
            ResultSet rs = stmt.executeQuery( "select * from t;" );
            while( rs.next() )
                System.out.println( "(" + rs.getInt( "a" ) + "," + rs.getString( "b" ).trim() + ")" );
            rs.close();
            
            stmt.execute( "drop table t;" );
            conn.commit();
            System.out.println( "Table t droped." );
            
            stmt.close();
            conn.close();
            System.out.println( "Connection closed." );
        } catch (Exception e) {
            System.err.println("NodeQueryProcessorEngine Exception: " + e.getMessage());
            e.printStackTrace();
        }  finally { 
            System.gc();
            System.exit(0);
        }
    }
    
}
