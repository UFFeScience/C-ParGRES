/**
 * 
 */
package org.pargres.performance;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

/**
 * @author kinder
 * 
 */
public class HSQLDBOrderTest {

    /**
     * @param args
     * @throws SQLException
     * @throws ClassNotFoundException
     */
    public static void main(String[] args) throws SQLException,
            ClassNotFoundException {

        int N = 100000;

        Class.forName("org.hsqldb.jdbcDriver");
        System.out.println("no de registros inseridos " + N);

        Connection con = DriverManager.getConnection("jdbc:hsqldb:mem:tempdb",
                "sa", "");

        Statement stmt = con.createStatement();
        String tableName = "teste";
        stmt.executeUpdate("create table " + tableName
                + "(a1 int, a2 varchar(30), a3 date)");

        for (int i = 1; i <= N; ++i) {
            stmt.executeUpdate("insert into " + tableName
                    + " values ("+ i + ",'gfhgfjhgfg', '2005-08-08')");
        }

        ResultSet rs = stmt.executeQuery("select a1, a2, a3  from teste");

        while (rs.next())
            System.out.println(rs.getInt(1));

        stmt.close();
        con.close();
    }
}
