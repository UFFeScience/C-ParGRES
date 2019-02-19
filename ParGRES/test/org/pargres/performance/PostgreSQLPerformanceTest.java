package org.pargres.performance;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Statement;

public class PostgreSQLPerformanceTest {

    /**
     * @param args
     * @throws ClassNotFoundException 
     * @throws SQLException 
     */
    public static void main(String[] args) throws ClassNotFoundException, SQLException {
       /* String sql = "select l_orderkey, sum(l_extendedprice * (1 - l_discount)), o_orderdate, o_shippriority " +
                "from customer,orders,lineitem " +
                "where lineitem.l_orderkey >= ? and lineitem.l_orderkey < ? and c_mktsegment = 'AUTOMOBILE' and c_custkey = o_custkey and l_orderkey = o_orderkey and o_orderdate < date '1995-03-19' and l_shipdate > date '1995-03-19' " +
                "group by l_orderkey,o_orderdate,o_shippriority";
     */
      /*  String sql = "select " + 
        "100.00 * sum(case " +
         "       when p_type like 'PROMO%' " +
         "           then l_extendedprice * (1 - l_discount) " +
         "       else 0 " +
         "   end) / sum(l_extendedprice * (1 - l_discount)) as promo_revenue " +
        "from " +
        "    lineitem, " +
        "    part " +
        "where " +
        "    l_partkey = p_partkey " +
        "    and l_shipdate >= date '1995-01-01' " +
        "    and l_shipdate < date '1995-01-01' + interval '1 month' " +
        "    and l_orderkey >= ? and l_orderkey < ?"; 
        */
        
        /*String sql = "select " + 
        "n_name, " + 
        "sum(l_extendedprice * (1 - l_discount)) as revenue " + 
    "from " + 
    "    customer, " +  
    "    orders, " + 
    "    lineitem, " + 
    "    supplier, " + 
    "    nation, " + 
    "    region " +  
    "where  " + 
    "    c_custkey = o_custkey " + 
    "    and l_orderkey = o_orderkey " + 
    "    and l_suppkey = s_suppkey " + 
    "    and c_nationkey = s_nationkey " + 
    "    and s_nationkey = n_nationkey " + 
    "    and n_regionkey = r_regionkey " + 
    "    and r_name = 'MIDDLE EAST' " + 
    "    and o_orderdate >= date '1993-01-01' " + 
    "    and o_orderdate < date '1993-01-01' + interval '1 year' " +
    " and l_orderkey >= ? and l_orderkey < ? " +
   " group by " + 
   "     n_name " + 
   " order by " + 
   "     revenue desc; ";*/
        
        String sql = "selecfsgt * from lineitem";
        
        int value1 = 1;
        int value2 = 2560;
        
        Class.forName("org.postgresql.Driver");
        Connection con = DriverManager.getConnection(
                "jdbc:postgresql://localhost:9001/tpch_sf5", "tpch", "");
        
        boolean prepare = true;
        String sql1; 
        
         for (int i = 0; i <= 24000000; ++i){
             long begin = System.currentTimeMillis();
           
             if (prepare){
                 PreparedStatement st = con.prepareStatement(sql);
                 st.setInt(1, value1);
                 st.setInt(2, value2);
                 st.executeQuery();
             }else{
                 Statement st = con.createStatement();
                 sql1 = sql;
                 sql1 = sql1.replaceFirst("\\?", Integer.toString(value1));
                 sql1 = sql1.replaceFirst("\\?", Integer.toString(value2));
                 st.executeQuery(sql1);
             }
             
             System.out.println(System.currentTimeMillis() - begin);
             value1 += 1025;
             value2 += 1025;
         }
    }

}
