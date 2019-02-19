package org.pargres.jdbc.specifics;

import java.io.Serializable;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.ArrayList;

import org.pargres.commons.Range;


public abstract class AbstractDatabase implements Serializable {
    public static final int PARTITIONED_COLUMNS = 0;
    public static final int ORDER_BY_COLUMNS = 1;

    public static AbstractDatabase getDatabaseSpecifics(String value) {
        if(value.equals("PostgreSQL"))
			return new PostgreSQLDatabase();
		else
			return new GenericDatabase();
	}
	
    abstract public ArrayList<Range> loadPartitionedColumns(DatabaseProperties prop, String tableName, Connection con, int type) throws SQLException;
}
