/*
 * Created on 08/03/2005
 */
package org.pargres.util;

import java.sql.Connection;
import java.sql.DriverManager;

import org.pargres.commons.logger.Logger;

/**
 * @author Bernardo
 */
public class HsqlDatabase {

	private Logger logger = Logger.getLogger(HsqlDatabase.class);

	private int port;

	private Connection con;

	public HsqlDatabase(int port) {
		this.port = port;
	}

	public void start() throws Exception {
		try {

			Class.forName("org.hsqldb.jdbcDriver");
			con = DriverManager.getConnection("jdbc:hsqldb:mem:testdb" + port);
			con
					.createStatement()
					.executeUpdate(
							"CREATE TABLE PARTSUPP(PS_PARTKEY INTEGER NOT NULL,PS_SUPPKEY INTEGER NOT NULL,PS_AVAILQTY INTEGER,PS_SUPPLYCOST DECIMAL(12,2),PS_COMMENT VARCHAR(199))");
			con
					.createStatement()
					.executeUpdate(
							"CREATE TABLE CUSTOMER(C_CUSTKEY INTEGER NOT NULL,C_NAME VARCHAR(25),C_ADDRESS VARCHAR(40),C_NATIONKEY INTEGER,C_PHONE CHAR(15),C_ACCTBAL DECIMAL(12,2),C_MKTSEGMENT CHAR(10),C_COMMENT VARCHAR(117))");
			con
					.createStatement()
					.executeUpdate(
							"CREATE TABLE PART(P_PARTKEY INTEGER NOT NULL,P_NAME VARCHAR(55),P_MFGR CHAR(25),P_BRAND CHAR(10),P_TYPE VARCHAR(25),P_SIZE INTEGER,P_CONTAINER CHAR(10),P_RETAILPRICE DECIMAL(12,2),P_COMMENT VARCHAR(23))");
			con
					.createStatement()
					.executeUpdate(
							"CREATE TABLE SUPPLIER(S_SUPPKEY INTEGER NOT NULL,S_NAME CHAR(25),S_ADRESS VARCHAR(40),S_NATIONKEY INTEGER,S_PHONE CHAR(15),S_ACCTBAL DECIMAL(12,2),S_COMMENT VARCHAR(101))");
			con
					.createStatement()
					.executeUpdate(
							"CREATE TABLE NATION(N_NATIONKEY INTEGER NOT NULL,N_NAME CHAR(25),N_REGIONKEY INTEGER,N_COMMENT VARCHAR(152))");
			con
					.createStatement()
					.executeUpdate(
							"CREATE TABLE REGION(R_REGIONKEY INTEGER NOT NULL,R_NAME CHAR(25),R_COMMENT VARCHAR(152))");
			con
			.createStatement()
			.executeUpdate("INSERT INTO REGION VALUES (1,'AMERICA','')");
			
			con
			.createStatement()
			.executeUpdate("INSERT INTO REGION VALUES (2,'OCEANIA','')");
			
			con
			.createStatement()
			.executeUpdate("INSERT INTO REGION VALUES (3,'OCEANIA','')");			
			
			con
					.createStatement()
					.executeUpdate(
							"CREATE TABLE ORDERS(O_ORDERKEY INTEGER NOT NULL," +
                                                 "O_CUSTKEY INTEGER NOT NULL," +
                                                 "O_ORDERSTATUS CHAR(1)," +
                                                 "O_TOTALPRICE DECIMAL(12,2)," +
                                                 "O_ORDERDATE DATE," +
                                                 "O_ORDERPRIORITY CHAR(15)," +
                                                 "O_CLERK CHAR(15)," +
                                                 "O_SHIPPRIORITY INTEGER," +
                                                 "O_COMMENT VARCHAR(79))");
			con
					.createStatement()
					.executeUpdate(
							"CREATE TABLE LINEITEM(L_ORDERKEY INTEGER NOT NULL," +
												"L_LINENUMBER INTEGER NOT NULL," +
												"L_PARTKEY INTEGER," +
												"L_SUPPKEY INTEGER," +
												"L_QUANTITY DECIMAL(12,2)," +
												"L_EXTENDEDPRICE DECIMAL(12,2)," +
												"L_DISCOUNT DECIMAL(12,2)," +
												"L_TAX DECIMAL(12,2)," +
												"L_RETURNFLAG CHAR(1)," +
												"L_LINESTATUS CHAR(1)," +
												"L_SHIPDATE DATE," +
												"L_COMMITDATE DATE," +
												"L_RECEIPTDATE DATE," +
												"L_SHIPINSTRUCT CHAR(25)," +
												"L_SHIPMODE CHAR(10)," +
												"L_COMMENT VARCHAR(44))");
			logger.debug("UPDATE 1 OK!");
			
			String strShip;
			String shipDate;
			for(int i = 1; i <= 100; i++) {
				
				//con
				//.createStatement()
				//.executeUpdate("INSERT INTO ORDERS VALUES ("+i+", 0, 'T', 10, NULL, NULL, 'T', 0, NULL)");
				
				//50% dos regsistros tem SHIP1 e 50 % SHIP2 
				if ( i%2 == 0 ){
					strShip = "SHIP1";
				}
				else{
					strShip = "SHIP2";
				}
				if (i%3 == 0 )
					shipDate = "2005-08-25";
				else
					shipDate = "2005-09-01";
			
                con.createStatement()
						.executeUpdate(
								"INSERT INTO LINEITEM VALUES("+i+"," +
										"697," +
										"23," +
										"7," +
										"10," +
										"65505.29," +
										"0.09," +
										"0.08," +
										"'N'," +
										"'O'," +
										"'" + shipDate + "'," +
										"'" + shipDate + "'," +
										"'1998-07-06'," +
										"'NONE'," +
										"' "+ strShip  + "'," +
										"'bold dolph')");
				//logger.debug("UPDATE 2 OK: "+i);				
			}
			logger.debug("DATABASE CREATED!");
			Connection con2 = DriverManager
					.getConnection("jdbc:hsqldb:mem:testdb" + port
							+ ";ifexists=true");
			if (con2.createStatement().executeQuery("SELECT * FROM LINEITEM") == null)
				throw new Exception("HSQLDB ERROR!");
			con2.close();			
		} catch (Exception e) {
			logger.error(e);
			System.out.println(e.getMessage());
			throw new Exception("HSQLDB ERROR!");
		}
	}

	public void stop() {
		try {
			if (!con.isClosed())
				con.createStatement().execute("SHUTDOWN");
				con = null;
		} catch (Exception e) {
			System.err.println("HSQLDB Error: " + e);
			e.printStackTrace();
		}
		// hsqldbServer.stop();
		// hsqldbServer = null;
	}
}
