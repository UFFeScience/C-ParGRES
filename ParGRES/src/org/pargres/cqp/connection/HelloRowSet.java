package org.pargres.cqp.connection;

import java.sql.SQLException;
import java.sql.Types;

import javax.sql.rowset.RowSetMetaDataImpl;

import org.pargres.commons.util.JdbcUtil;

import com.sun.rowset.CachedRowSetImpl;

public class HelloRowSet extends CachedRowSetImpl {

	/**
	 * 
	 */
	private static final long serialVersionUID = 3257006544703927857L;

	public HelloRowSet() throws SQLException {
		super();
		RowSetMetaDataImpl meta = new RowSetMetaDataImpl();
		meta.setColumnCount(1);
		meta.setColumnName(1, "DUMMY");
		meta.setColumnType(1, Types.VARCHAR);
		this.setMetaData(meta);
		this.moveToInsertRow();
		this.updateString(1, JdbcUtil.TEST_QUERY_RESPONSE);
		this.insertRow();
		this.moveToCurrentRow();
	}
}
