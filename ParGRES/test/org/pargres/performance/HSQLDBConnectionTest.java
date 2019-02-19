/**
 * 
 */
package org.pargres.performance;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Statement;

/**
 * @author kinder
 * 
 */
public class HSQLDBConnectionTest {

    /**
     * @param args
     * @throws SQLException
     * @throws ClassNotFoundException
     */
    public static void main(String[] args) throws SQLException,
            ClassNotFoundException {

        double tempoClose = 0;
        double tempoInsercao = 0;
        int N = 100000;
        int repeticoes = 50;

        boolean temporary = true;
        
        boolean autocommit = false;

        Class.forName("org.hsqldb.jdbcDriver");
        System.out.println("no de registros inseridos " + N);
        System.out.println("no de repeticoes " + repeticoes);
        System.out.println("temporary " + temporary);
        System.out.println("autocommit " + autocommit);

        if (!temporary) {
            Connection con = DriverManager.getConnection(
                    "jdbc:hsqldb:mem:tempdb", "sa", "");
            if (!autocommit)
                con.setAutoCommit(false);
            Statement stmt = con.createStatement();
            for (int j = 1; j <= repeticoes; ++j) {
                String tableName = "teste" + j;
                stmt.executeUpdate("create table " + tableName
                        + "(a1 int, a2 varchar(30), a3 date)");

                long begin = System.currentTimeMillis();
                for (int i = 1; i <= N; ++i) {
                    stmt.executeUpdate("insert into " + tableName
                            + " values (3, 'gfhgfjhgfg', '2005-08-08')");
                }
                long end = System.currentTimeMillis();
                tempoInsercao = tempoInsercao + (end - begin);

                if (j % 10 == 0)
                    System.out.println(j);
                begin = System.currentTimeMillis();
                stmt.executeUpdate("drop table " + tableName);
                end = System.currentTimeMillis();

                tempoClose = tempoClose + (end - begin);
            }
            stmt.close();
            con.close();

            System.out.println("Tempo medio Insercao: " + tempoInsercao / repeticoes);
            System.out.println("Tempo medio drop: " + tempoClose / repeticoes);
        } else {
            for (int j = 1; j <= repeticoes; ++j) {
                Connection con1 = DriverManager.getConnection(
                        "jdbc:hsqldb:mem:tempdb", "sa", "");
                if (!autocommit)
                    con1.setAutoCommit(false);
                Statement stmt1 = con1.createStatement();

                String tableName = "teste" + j;
                stmt1.executeUpdate("create global temporary table "
                        + tableName + "(a1 int, a2 varchar(30), a3 date)");

                long begin = System.currentTimeMillis();
                for (int i = 1; i <= N; ++i) {
                    stmt1.executeUpdate("insert into " + tableName
                            + " values (3, 'gfhgfjhgfg', '2005-08-08')");
                }
                long end = System.currentTimeMillis();
                tempoInsercao = tempoInsercao + (end - begin);

                if (j % 10 == 0)
                    System.out.println(j);

                begin = System.currentTimeMillis();
                stmt1.close();
                con1.close();
                end = System.currentTimeMillis();

                tempoClose = tempoClose + (end - begin);
            }

            System.out.println("Tempo medio Insercao: " + tempoInsercao / repeticoes);
            System.out.println("Tempo medio drop: " + tempoClose / repeticoes);
        }
    }

}
