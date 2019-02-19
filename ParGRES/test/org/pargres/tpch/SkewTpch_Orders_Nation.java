/*
 * SkewTpch_Customer_Nation.java
 *
 * Created on 6 juin 2004, 20:50
 */

package org.pargres.tpch;

/**
 *
 * @author  Alex
 */


public class SkewTpch_Orders_Nation {
    
    /*private static final int NUM_NATIONS = 25;
    private static final int NUM_RANGE_LIMITS = 24;
    private static NationRealStatistics []a_statistics;
    */
    
    /** Creates a new instance of SkewTpch_Customer_Nation */
    public SkewTpch_Orders_Nation() {
    }
    
    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        //Connection conn= null;
        /*
        try {
            int numKeysUpdate = 500;
            int oldkey;
            int newkey;
            String dbname, username;

            if( args.length != 2 ) {
                System.out.println( "usage: java tpch.SkewTpch_Orders_Nation dbname username" );
                return;
            }
            
            Class.forName("org.postgresql.Driver").newInstance();

            dbname = args[0].trim();
            username = args[1].trim();

            BufferedReader reader = new BufferedReader( new InputStreamReader( System.in ) );

            System.out.println( "Check if the following components were REMOVED from table ORDERS: " );
            System.out.println( "PRIMARY KEYS " );
            System.out.println( "FOREIGN KEYS " );
            System.out.println( "INDEXES" );
            System.out.println( "When everything is ok, hit [ENTER] and I will start!" );
            reader.readLine();

            System.out.println( "Connecting..." );
            conn = DriverManager.getConnection("jdbc:postgresql://localhost:3669/" + dbname, username, "" );
            System.out.println( "Connected!" );

            conn.setAutoCommit( false );
            Statement stmt = conn.createStatement();
            stmt.setFetchSize( numKeysUpdate );
            
            ResultSet rs;
            rs = stmt.executeQuery( "select o_orderkey," ); 
            for( int key = minkey; key <= maxkey; key += numKeysUpdate ) {
                int numKeysRetrieved;
                
                System.out.println( "From " + key + " to " + (key + numKeysUpdate) );                
                rs = stmt.executeQuery( "select o_orderkey, c_nationkey from orders, customer " + 
                                        "where o_custkey = c_custkey and o_orderkey >= " + key + 
                                        "  and o_orderkey < " + (key + numKeysUpdate) );
                numKeysRetrieved = 0;
                while( rs.next() ) {
                    double random;
                    int nation;

                    random = Math.random();
                    nation = binSearch( probRangeLimits, random );
                    oldOrderKey[ numKeysRetrieved ] = rs.getInt( 1 );
                    newOrderKey[ numKeysRetrieved ] = nationsRange * rs.getInt( 2 ) + oldOrderKey[ numKeysRetrieved ];
                    numKeysRetrieved++;
                }
                for( int countKeys = 0, countBatch = 0; countKeys < numKeysRetrieved; countKeys++ ) {
                    if( countBatch ==  batchSize ) {
                        stmt.executeBatch();
                        stmt.clearBatch();
                        countBatch = 0;
                    }
                    stmt.addBatch( "update orders set o_orderkey = " + newOrderKey[countKeys] + " where o_orderkey = " + oldOrderKey[countKeys] );
                    stmt.addBatch( "update lineitem set l_orderkey = " + newOrderKey[countKeys] + " where l_orderkey = " + oldOrderKey[countKeys] );
                }
                stmt.executeBatch();
                stmt.clearBatch();
                conn.commit();
                System.out.println( "Commit OK!" );                
            }
            conn.commit();
            rs.close();
            stmt.close();
            conn.close();
            System.out.println( "Finished!" );
        } catch( Exception e ) {
            System.err.println("Exception: " + e.getMessage());
            e.printStackTrace();            
        } finally {
            System.out.println( "Disconnecting..." );
            if( conn != null ) {
                try {
                    conn.close();
                } catch( Exception e ) {
                    System.err.println("Exception: " + e.getMessage());
                    e.printStackTrace();            
                } 
            }
            System.out.println( "Disconnected!" );
        }
         **/
    }
    

}
