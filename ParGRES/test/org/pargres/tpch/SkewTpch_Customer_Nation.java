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

import java.sql.*;

public class SkewTpch_Customer_Nation {
    
    private static final int NUM_NATIONS = 25;
    private static final int NUM_RANGE_LIMITS = 24;
    private static NationRealStatistics []a_statistics;
    
    /** Creates a new instance of SkewTpch_Customer_Nation */
    public SkewTpch_Customer_Nation() {
    }
    
    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        try {
            double []probabilities;
            double []probRangeLimits;
            int mincust, maxcust;
            int numKeysUpdate = 500;
            String dbname, username;

            if( args.length != 2 ) {
                System.out.println( "usage: java tpch.SkewTpch_Customer_Nation dbname username" );
                return;
            }
            
            Class.forName("org.postgresql.Driver").newInstance();

            dbname = args[0].trim();
            username = args[1].trim();
            
            Connection conn = DriverManager.getConnection("jdbc:postgresql://localhost:3669/" + dbname, username, "" );
            conn.setAutoCommit( false );
            Statement stmt = conn.createStatement(ResultSet.TYPE_FORWARD_ONLY, ResultSet.CONCUR_UPDATABLE);
            ResultSet rs;

            probabilities = generateNationProbabilities();
            // generate probability range limits
            probRangeLimits = new double[ NUM_RANGE_LIMITS ];
            probRangeLimits[0] = probabilities[0];
            for( int i = 1; i < NUM_RANGE_LIMITS; i++ )
                probRangeLimits[i] = probRangeLimits[i-1] + probabilities[i];

            rs = stmt.executeQuery( "select min( c_custkey ) as mincust, max( c_custkey ) as maxcust from customer" );
            rs.next();
            mincust = rs.getInt( "mincust" );
            maxcust = rs.getInt( "maxcust" );
            
            for( int custkey = mincust; custkey <= maxcust; custkey += numKeysUpdate ) {
                System.out.println( "From " + custkey + " to " + (custkey + numKeysUpdate) );                
                rs = stmt.executeQuery( "select c_custkey, c_nationkey from customer " + 
                                        "where c_custkey >= " + custkey + 
                                        "  and c_custkey < " + (custkey + numKeysUpdate) );
                while( rs.next() ) {
                    double random;
                    //boolean found;
                    int nation = 0;

                    random = Math.random();
                    
                    /*
                    found = false;
                    for( int i = 0; (i < NUM_RANGE_LIMITS) && !found; i++ ) {
                        if( random < probRangeLimits[ i ] ) {
                            nation = i;
                            found = true;
                        }
                    }
                    if( !found ) {
                        nation = NUM_RANGE_LIMITS;
                    }
                     */
                    nation = binSearch( probRangeLimits, random );
                    rs.updateInt( "c_nationkey", nation );
                    rs.updateRow();
                }
                conn.commit();
            }
            conn.commit();
            rs.close();
            stmt.close();
            conn.close();
            System.out.println( "Finished" );
        } catch( Exception e ) {
            System.err.println("Exception: " + e.getMessage());
            e.printStackTrace();            
        }
    }
    
    private static double[] generateNationProbabilities() {
        double sum;
        double []probabilities;
        
        a_statistics = new NationRealStatistics[ NUM_NATIONS ];
        a_statistics[0] = new NationRealStatistics(0, "ALGERIA", 32818500);
        a_statistics[1] = new NationRealStatistics(1, "ARGENTINA", 38740807);
        a_statistics[2] = new NationRealStatistics(2, "BRAZIL", 182032604);
        a_statistics[3] = new NationRealStatistics(3, "CANADA", 32207113);
        a_statistics[4] = new NationRealStatistics(4, "EGYPT", 74718797);
        a_statistics[5] = new NationRealStatistics(5, "ETHIOPIA", 66557553);
        a_statistics[6] = new NationRealStatistics(6, "FRANCE", 60180529);
        a_statistics[7] = new NationRealStatistics(7, "GERMANY", 82398326);
        a_statistics[8] = new NationRealStatistics(8, "INDIA", 1027015247);
        a_statistics[9] = new NationRealStatistics(9, "INDONESIA", 234893453);
        a_statistics[10] = new NationRealStatistics(10, "IRAN", 68278826);
        a_statistics[11] = new NationRealStatistics(11, "IRAQ", 24683313);
        a_statistics[12] = new NationRealStatistics(12, "JAPAN", 127214499);
        a_statistics[13] = new NationRealStatistics(13, "JORDAN", 5460265);
        a_statistics[14] = new NationRealStatistics(14, "KENYA", 31639091);
        a_statistics[15] = new NationRealStatistics(15, "MOROCCO", 31689265);
        a_statistics[16] = new NationRealStatistics(16, "MOZAMBIQUE", 17479266);
        a_statistics[17] = new NationRealStatistics(17, "PERU", 28409897);
        a_statistics[18] = new NationRealStatistics(18, "CHINA", 1286975468);
        a_statistics[19] = new NationRealStatistics(19, "ROMANIA", 22271839);
        a_statistics[20] = new NationRealStatistics(20, "SAUDI ARABIA", 24293844);
        a_statistics[21] = new NationRealStatistics(21, "VIETNAM", 81624716);
        a_statistics[22] = new NationRealStatistics(22, "RUSSIA", 144526278);
        a_statistics[23] = new NationRealStatistics(23, "UNITED KINGDOM", 60094648);
        a_statistics[24] = new NationRealStatistics(24, "UNITED STATES", 290342554);
        
        sum = 0.0;
        for( int i = 0; i < NUM_NATIONS; i++ ) {
            sum += a_statistics[i].getPopulation();
        }
        
        probabilities = new double[ NUM_NATIONS ];
        for( int i = 0; i < NUM_NATIONS; i++ ) {
            probabilities[i] = a_statistics[i].getPopulation() / sum;
        }
        return probabilities;
    }
    
    private static int binSearch( double []array, double key ) throws java.io.IOException {
        if( key > array[ array.length - 1 ] )
            return array.length;
        else { 
            int start, end, middle;
            int position = -1;
            //BufferedReader reader = new BufferedReader( new InputStreamReader( System.in ) );

            start = 0;
            end = array.length - 1;
            //System.out.println( "Searching " + key );
            do {
                middle = start + (end - start) / 2;
                //System.out.println( start + " - " + middle + " - " + end );
                //System.out.println( array[start] + " - " + array[middle] + " - " + array[end] );
                if( key < array[ middle ] ) {
                    if( middle == 0 )
                        position = middle;
                    else if( key >= array[ middle - 1 ] )
                        position = middle;
                    else
                        end = middle;
                }
                else if( middle == array.length - 1 ) {
                    position = middle;
                }
                else if( key < array[ middle + 1 ] ) {
                    position = middle + 1;
                }
                else
                    start = middle;
                //reader.readLine();
            } while( (position == -1) && (start <= end) );
            if( position == -1 )
                position = array.length;
            //System.out.println( "Position = " + position );
            return position;
        }
    }
}
