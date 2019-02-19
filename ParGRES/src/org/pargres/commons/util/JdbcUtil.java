package org.pargres.commons.util;

public class JdbcUtil {
	public static final String TEST_QUERY = "select count(*) from REGION";
	public static final String TEST_QUERY_RESPONSE = "select version from pargres dual";
	public static final String LAZY_INTER_QUERY = "select 'lazy', R_REGIONKEY from REGION";
	public static final String LAZY_INTRA_QUERY = "select 'lazy', L_ORDERKEY from LINEITEM";
	public static final String LAZY_UPDATE = "update lazy from pargres dual";
	public static final String BEGIN_TRANSACTION = "begin transaction";
	public static final String COMMIT = "commit";
	public static final String ROLLBACK = "rollback";
	//public static final String select_INTER_STATEMENT = "select INTER";
	//public static final String select_INTRA_STATEMENT = "select INTRA";

}
