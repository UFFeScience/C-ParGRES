package org.pargres.jdbc;

import java.io.InputStream;
import java.io.Reader;
import java.io.Serializable;
import java.math.BigDecimal;
import java.net.URL;
import java.sql.Array;
import java.sql.Blob;
import java.sql.Clob;
import java.sql.Date;
import java.sql.Ref;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.SQLWarning;
import java.sql.Statement;
import java.sql.Time;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Map;

import javax.sql.RowSetMetaData;

import org.pargres.commons.util.PargresException;

import com.sun.rowset.CachedRowSetImpl;
import java.sql.NClob;
import java.sql.RowId;
import java.sql.SQLXML;

public class PargresRowSet extends CachedRowSetImpl implements Serializable {
	/**
	 * 
	 */
	private static final long serialVersionUID = 3616727158455022136L;
	//private Logger logger = Logger.getLogger(PargresRowSet.class);

	public PargresRowSet() throws SQLException {
		super();
	}

	public synchronized PargresRowSet cloneThis() throws PargresException {
		try {
			PargresRowSet rs = new PargresRowSet();
			rs.setShowDeleted(false); 
			rs.populateThis(this);			
			return rs;
		} catch (Exception e) {
			e.printStackTrace();
			System.err.println(e);
			throw new PargresException(e.getMessage());
		}
	}
	
	public void populateThis(PargresRowSet rs) throws PargresException {
		try {		
			rs.beforeFirst();	
			populate(rs);
			rs.beforeFirst();				
		} catch (SQLException e) {
			e.printStackTrace();
			System.err.println(e);
			throw new PargresException(e.getMessage());
		}			
	}
	

	public void populate(ResultSet rs) throws PargresException {
		try {
			RowSetMetaData meta = new PargresRowSetMetaData(rs.getMetaData());
			//DAR UMA OLHADA NISSO!
			//this.beforeFirst();
			//this.setMetaData(meta);
			/*while(rs.next()) {
				this.moveToInsertRow();
				for(int i = 1; i <= meta.getColumnCount(); i++) {
					//Object o = rs.getObject(i);
					this.setString(i,"1");
					//if(o != null)
					//	this.setObject(i,rs.getObject(i));
				}
				this.insertRow();
			}*/
			this.beforeFirst();
			super.populate(new FixItResultSet(rs, meta));

			//if(!super.isBeforeFirst())
			beforeFirst();
			//rs.beforeFirst();

		} catch (Exception e) {
			e.printStackTrace();
			System.err.println(e);
			throw new PargresException(e.getMessage());
		}
	}

	/*
	private void selfTest() throws PargresException {
		try {
			if (!isBeforeFirst())
				throw new PargresException("Rowset not in before first record!");
			while (!next()) {
			}
			beforeFirst();
		} catch (Exception e) {
			logger.error("Self test error: " + e);
			e.printStackTrace();
			throw new PargresException(e.getMessage());
		}
	}
	*/
	
	public PargresRowSet filter(ArrayList<String> fields, ArrayList<Object> values) throws SQLException {
		PargresRowSet rs = this.cloneThis();
		rs.setShowDeleted(false);
		rs.beforeFirst();
		int filtered = 0;
		int count = 0;
		while(rs.next()) {
			 boolean ok = true;
			 
			 for(int i = 0; i < fields.size(); i++) {
				 String rsValue = rs.getString(fields.get(i));				 
				 if(values.get(i) == null) {
					 //Do nothing
				 } else if(rsValue == null) {
					 ok = false;
				 } else {
					 if(values.get(i).getClass().equals(String.class)) {
						 //String
						 String value = (String)values.get(i);
						 if(value.equals("%"))
							 break;
						 ok = ok && rsValue.toUpperCase().equals(value.toUpperCase());
					 } else {
						 //Array de String
						 String[] value = (String[])values.get(i);
						 boolean lok = true;
						 for(int j = 0; j < value.length; j++) {
							 lok = rsValue.toUpperCase().equals(value[j].toUpperCase());
							 if(lok)
								 break;
						 }
						 ok = ok && lok;
					 }
				 }
			 }
			 
			 if(!ok) { 
				 rs.deleteRow();
				 filtered++;
			 } 
			 count++;
			 
		}

		rs.beforeFirst();
		System.out.println("Filtering Rows: "+filtered+"/"+count);
		return rs;
	}	

	class FixItResultSet implements ResultSet {
		private ResultSet rs;

		private ResultSetMetaData meta;

		public FixItResultSet(ResultSet rs, ResultSetMetaData meta) {
			this.rs = rs;
			this.meta = meta;
		}

		public boolean absolute(int arg0) throws SQLException {

			return rs.absolute(arg0);
		}

		public void afterLast() throws SQLException {

			rs.afterLast();
		}

		public void beforeFirst() throws SQLException {

			rs.beforeFirst();
		}

		public void cancelRowUpdates() throws SQLException {

			rs.cancelRowUpdates();
		}

		public void clearWarnings() throws SQLException {

			rs.clearWarnings();
		}

		public void close() throws SQLException {

			rs.close();
		}

		public void deleteRow() throws SQLException {

			rs.deleteRow();
		}

		public int findColumn(String arg0) throws SQLException {

			return rs.findColumn(arg0);
		}

		public boolean first() throws SQLException {

			return rs.first();
		}

		public Array getArray(String arg0) throws SQLException {

			return rs.getArray(arg0);
		}

		public Array getArray(int arg0) throws SQLException {

			return rs.getArray(arg0);
		}

		public InputStream getAsciiStream(String arg0) throws SQLException {

			return rs.getAsciiStream(arg0);
		}

		public InputStream getAsciiStream(int arg0) throws SQLException {

			return rs.getAsciiStream(arg0);
		}

		public BigDecimal getBigDecimal(String arg0) throws SQLException {

			return rs.getBigDecimal(arg0);
		}

		@Deprecated
		public BigDecimal getBigDecimal(String arg0, int arg1)
				throws SQLException {

			return rs.getBigDecimal(arg0, arg1);
		}

		public BigDecimal getBigDecimal(int arg0) throws SQLException {

			return rs.getBigDecimal(arg0);
		}

		@Deprecated
		public BigDecimal getBigDecimal(int arg0, int arg1) throws SQLException {

			return rs.getBigDecimal(arg0, arg1);
		}

		public InputStream getBinaryStream(String arg0) throws SQLException {

			return rs.getBinaryStream(arg0);
		}

		public InputStream getBinaryStream(int arg0) throws SQLException {

			return rs.getBinaryStream(arg0);
		}

		public Blob getBlob(String arg0) throws SQLException {

			return rs.getBlob(arg0);
		}

		public Blob getBlob(int arg0) throws SQLException {

			return rs.getBlob(arg0);
		}

		public boolean getBoolean(String arg0) throws SQLException {

			return rs.getBoolean(arg0);
		}

		public boolean getBoolean(int arg0) throws SQLException {

			return rs.getBoolean(arg0);
		}

		public byte getByte(String arg0) throws SQLException {

			return rs.getByte(arg0);
		}

		public byte getByte(int arg0) throws SQLException {

			return rs.getByte(arg0);
		}

		public byte[] getBytes(String arg0) throws SQLException {

			return rs.getBytes(arg0);
		}

		public byte[] getBytes(int arg0) throws SQLException {

			return rs.getBytes(arg0);
		}

		public Reader getCharacterStream(String arg0) throws SQLException {

			return rs.getCharacterStream(arg0);
		}

		public Reader getCharacterStream(int arg0) throws SQLException {

			return rs.getCharacterStream(arg0);
		}

		public Clob getClob(String arg0) throws SQLException {

			return rs.getClob(arg0);
		}

		public Clob getClob(int arg0) throws SQLException {

			return rs.getClob(arg0);
		}

		public int getConcurrency() throws SQLException {

			return rs.getConcurrency();
		}

		public String getCursorName() throws SQLException {

			return rs.getCursorName();
		}

		public Date getDate(String arg0) throws SQLException {

			return rs.getDate(arg0);
		}

		public Date getDate(String arg0, Calendar arg1) throws SQLException {

			return rs.getDate(arg0, arg1);
		}

		public Date getDate(int arg0) throws SQLException {

			return rs.getDate(arg0);
		}

		public Date getDate(int arg0, Calendar arg1) throws SQLException {

			return rs.getDate(arg0, arg1);
		}

		public double getDouble(String arg0) throws SQLException {

			return rs.getDouble(arg0);
		}

		public double getDouble(int arg0) throws SQLException {

			return rs.getDouble(arg0);
		}

		public int getFetchDirection() throws SQLException {

			return rs.getFetchDirection();
		}

		public int getFetchSize() throws SQLException {

			return rs.getFetchSize();
		}

		public float getFloat(String arg0) throws SQLException {

			return rs.getFloat(arg0);
		}

		public float getFloat(int arg0) throws SQLException {

			return rs.getFloat(arg0);
		}

		public int getInt(String arg0) throws SQLException {

			return rs.getInt(arg0);
		}

		public int getInt(int arg0) throws SQLException {

			return rs.getInt(arg0);
		}

		public long getLong(String arg0) throws SQLException {

			return rs.getLong(arg0);
		}

		public long getLong(int arg0) throws SQLException {

			return rs.getLong(arg0);
		}

		public ResultSetMetaData getMetaData() throws SQLException {
			return meta;
		}

		public Object getObject(String arg0) throws SQLException {

			return rs.getObject(arg0);
		}

		public Object getObject(String arg0, Map<String, Class<?>> arg1)
				throws SQLException {

			return rs.getObject(arg0, arg1);
		}

		public Object getObject(int arg0) throws SQLException {

			return rs.getObject(arg0);
		}

		public Object getObject(int arg0, Map<String, Class<?>> arg1)
				throws SQLException {

			return rs.getObject(arg0, arg1);
		}

		public Ref getRef(String arg0) throws SQLException {

			return rs.getRef(arg0);
		}

		public Ref getRef(int arg0) throws SQLException {

			return rs.getRef(arg0);
		}

		public int getRow() throws SQLException {

			return rs.getRow();
		}

		public short getShort(String arg0) throws SQLException {

			return rs.getShort(arg0);
		}

		public short getShort(int arg0) throws SQLException {

			return rs.getShort(arg0);
		}

		public Statement getStatement() throws SQLException {

			return rs.getStatement();
		}

		public String getString(String arg0) throws SQLException {

			return rs.getString(arg0);
		}

		public String getString(int arg0) throws SQLException {

			return rs.getString(arg0);
		}

		public Time getTime(String arg0) throws SQLException {

			return rs.getTime(arg0);
		}

		public Time getTime(String arg0, Calendar arg1) throws SQLException {

			return rs.getTime(arg0, arg1);
		}

		public Time getTime(int arg0) throws SQLException {

			return rs.getTime(arg0);
		}

		public Time getTime(int arg0, Calendar arg1) throws SQLException {

			return rs.getTime(arg0, arg1);
		}

		public Timestamp getTimestamp(String arg0) throws SQLException {

			return rs.getTimestamp(arg0);
		}

		public Timestamp getTimestamp(String arg0, Calendar arg1)
				throws SQLException {

			return rs.getTimestamp(arg0, arg1);
		}

		public Timestamp getTimestamp(int arg0) throws SQLException {

			return rs.getTimestamp(arg0);
		}

		public Timestamp getTimestamp(int arg0, Calendar arg1)
				throws SQLException {

			return rs.getTimestamp(arg0, arg1);
		}

		public int getType() throws SQLException {

			return rs.getType();
		}

		public URL getURL(String arg0) throws SQLException {

			return rs.getURL(arg0);
		}

		public URL getURL(int arg0) throws SQLException {

			return rs.getURL(arg0);
		}

		@Deprecated
		public InputStream getUnicodeStream(String arg0) throws SQLException {

			return rs.getUnicodeStream(arg0);
		}

		@Deprecated
		public InputStream getUnicodeStream(int arg0) throws SQLException {

			return rs.getUnicodeStream(arg0);
		}

		public SQLWarning getWarnings() throws SQLException {

			return rs.getWarnings();
		}

		public void insertRow() throws SQLException {

			rs.insertRow();
		}

		public boolean isAfterLast() throws SQLException {

			return rs.isAfterLast();
		}

		public boolean isBeforeFirst() throws SQLException {

			return rs.isBeforeFirst();
		}

		public boolean isFirst() throws SQLException {

			return rs.isFirst();
		}

		public boolean isLast() throws SQLException {

			return rs.isLast();
		}

		public boolean last() throws SQLException {

			return rs.last();
		}

		public void moveToCurrentRow() throws SQLException {

			rs.moveToCurrentRow();
		}

		public void moveToInsertRow() throws SQLException {

			rs.moveToInsertRow();
		}

		public boolean next() throws SQLException {

			return rs.next();
		}

		public boolean previous() throws SQLException {

			return rs.previous();
		}

		public void refreshRow() throws SQLException {

			rs.refreshRow();
		}

		public boolean relative(int arg0) throws SQLException {

			return rs.relative(arg0);
		}

		public boolean rowDeleted() throws SQLException {

			return rs.rowDeleted();
		}

		public boolean rowInserted() throws SQLException {

			return rs.rowInserted();
		}

		public boolean rowUpdated() throws SQLException {

			return rs.rowUpdated();
		}

		public void setFetchDirection(int arg0) throws SQLException {

			rs.setFetchDirection(arg0);
		}

		public void setFetchSize(int arg0) throws SQLException {

			rs.setFetchSize(arg0);
		}

		public void updateArray(String arg0, Array arg1) throws SQLException {

			rs.updateArray(arg0, arg1);
		}

		public void updateArray(int arg0, Array arg1) throws SQLException {

			rs.updateArray(arg0, arg1);
		}

		public void updateAsciiStream(String arg0, InputStream arg1, int arg2)
				throws SQLException {

			rs.updateAsciiStream(arg0, arg1, arg2);
		}

		public void updateAsciiStream(int arg0, InputStream arg1, int arg2)
				throws SQLException {

			rs.updateAsciiStream(arg0, arg1, arg2);
		}

		public void updateBigDecimal(String arg0, BigDecimal arg1)
				throws SQLException {

			rs.updateBigDecimal(arg0, arg1);
		}

		public void updateBigDecimal(int arg0, BigDecimal arg1)
				throws SQLException {

			rs.updateBigDecimal(arg0, arg1);
		}

		public void updateBinaryStream(String arg0, InputStream arg1, int arg2)
				throws SQLException {

			rs.updateBinaryStream(arg0, arg1, arg2);
		}

		public void updateBinaryStream(int arg0, InputStream arg1, int arg2)
				throws SQLException {

			rs.updateBinaryStream(arg0, arg1, arg2);
		}

		public void updateBlob(String arg0, Blob arg1) throws SQLException {

			rs.updateBlob(arg0, arg1);
		}

		public void updateBlob(int arg0, Blob arg1) throws SQLException {

			rs.updateBlob(arg0, arg1);
		}

		public void updateBoolean(String arg0, boolean arg1)
				throws SQLException {

			rs.updateBoolean(arg0, arg1);
		}

		public void updateBoolean(int arg0, boolean arg1) throws SQLException {

			rs.updateBoolean(arg0, arg1);
		}

		public void updateByte(String arg0, byte arg1) throws SQLException {

			rs.updateByte(arg0, arg1);
		}

		public void updateByte(int arg0, byte arg1) throws SQLException {

			rs.updateByte(arg0, arg1);
		}

		public void updateBytes(String arg0, byte[] arg1) throws SQLException {

			rs.updateBytes(arg0, arg1);
		}

		public void updateBytes(int arg0, byte[] arg1) throws SQLException {

			rs.updateBytes(arg0, arg1);
		}

		public void updateCharacterStream(String arg0, Reader arg1, int arg2)
				throws SQLException {

			rs.updateCharacterStream(arg0, arg1, arg2);
		}

		public void updateCharacterStream(int arg0, Reader arg1, int arg2)
				throws SQLException {

			rs.updateCharacterStream(arg0, arg1, arg2);
		}

		public void updateClob(String arg0, Clob arg1) throws SQLException {

			rs.updateClob(arg0, arg1);
		}

		public void updateClob(int arg0, Clob arg1) throws SQLException {

			rs.updateClob(arg0, arg1);
		}

		public void updateDate(String arg0, Date arg1) throws SQLException {

			rs.updateDate(arg0, arg1);
		}

		public void updateDate(int arg0, Date arg1) throws SQLException {

			rs.updateDate(arg0, arg1);
		}

		public void updateDouble(String arg0, double arg1) throws SQLException {

			rs.updateDouble(arg0, arg1);
		}

		public void updateDouble(int arg0, double arg1) throws SQLException {

			rs.updateDouble(arg0, arg1);
		}

		public void updateFloat(String arg0, float arg1) throws SQLException {

			rs.updateFloat(arg0, arg1);
		}

		public void updateFloat(int arg0, float arg1) throws SQLException {

			rs.updateFloat(arg0, arg1);
		}

		public void updateInt(String arg0, int arg1) throws SQLException {

			rs.updateInt(arg0, arg1);
		}

		public void updateInt(int arg0, int arg1) throws SQLException {

			rs.updateInt(arg0, arg1);
		}

		public void updateLong(String arg0, long arg1) throws SQLException {

			rs.updateLong(arg0, arg1);
		}

		public void updateLong(int arg0, long arg1) throws SQLException {

			rs.updateLong(arg0, arg1);
		}

		public void updateNull(String arg0) throws SQLException {

			rs.updateNull(arg0);
		}

		public void updateNull(int arg0) throws SQLException {

			rs.updateNull(arg0);
		}

		public void updateObject(String arg0, Object arg1) throws SQLException {

			rs.updateObject(arg0, arg1);
		}

		public void updateObject(String arg0, Object arg1, int arg2)
				throws SQLException {

			rs.updateObject(arg0, arg1, arg2);
		}

		public void updateObject(int arg0, Object arg1) throws SQLException {

			rs.updateObject(arg0, arg1);
		}

		public void updateObject(int arg0, Object arg1, int arg2)
				throws SQLException {

			rs.updateObject(arg0, arg1, arg2);
		}

		public void updateRef(String arg0, Ref arg1) throws SQLException {

			rs.updateRef(arg0, arg1);
		}

		public void updateRef(int arg0, Ref arg1) throws SQLException {

			rs.updateRef(arg0, arg1);
		}

		public void updateRow() throws SQLException {

			rs.updateRow();
		}

		public void updateShort(String arg0, short arg1) throws SQLException {

			rs.updateShort(arg0, arg1);
		}

		public void updateShort(int arg0, short arg1) throws SQLException {

			rs.updateShort(arg0, arg1);
		}

		public void updateString(String arg0, String arg1) throws SQLException {

			rs.updateString(arg0, arg1);
		}

		public void updateString(int arg0, String arg1) throws SQLException {

			rs.updateString(arg0, arg1);
		}

		public void updateTime(String arg0, Time arg1) throws SQLException {

			rs.updateTime(arg0, arg1);
		}

		public void updateTime(int arg0, Time arg1) throws SQLException {

			rs.updateTime(arg0, arg1);
		}

		public void updateTimestamp(String arg0, Timestamp arg1)
				throws SQLException {

			rs.updateTimestamp(arg0, arg1);
		}

		public void updateTimestamp(int arg0, Timestamp arg1)
				throws SQLException {

			rs.updateTimestamp(arg0, arg1);
		}

		public boolean wasNull() throws SQLException {

			return rs.wasNull();
		}

        @Override
        public RowId getRowId(int columnIndex) throws SQLException {
            throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
        }

        @Override
        public RowId getRowId(String columnLabel) throws SQLException {
            throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
        }

        @Override
        public void updateRowId(int columnIndex, RowId x) throws SQLException {
            throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
        }

        @Override
        public void updateRowId(String columnLabel, RowId x) throws SQLException {
            throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
        }

        @Override
        public int getHoldability() throws SQLException {
            throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
        }

        @Override
        public boolean isClosed() throws SQLException {
            throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
        }

        @Override
        public void updateNString(int columnIndex, String nString) throws SQLException {
            throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
        }

        @Override
        public void updateNString(String columnLabel, String nString) throws SQLException {
            throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
        }

        @Override
        public void updateNClob(int columnIndex, NClob nClob) throws SQLException {
            throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
        }

        @Override
        public void updateNClob(String columnLabel, NClob nClob) throws SQLException {
            throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
        }

        @Override
        public NClob getNClob(int columnIndex) throws SQLException {
            throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
        }

        @Override
        public NClob getNClob(String columnLabel) throws SQLException {
            throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
        }

        @Override
        public SQLXML getSQLXML(int columnIndex) throws SQLException {
            throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
        }

        @Override
        public SQLXML getSQLXML(String columnLabel) throws SQLException {
            throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
        }

        @Override
        public void updateSQLXML(int columnIndex, SQLXML xmlObject) throws SQLException {
            throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
        }

        @Override
        public void updateSQLXML(String columnLabel, SQLXML xmlObject) throws SQLException {
            throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
        }

        @Override
        public String getNString(int columnIndex) throws SQLException {
            throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
        }

        @Override
        public String getNString(String columnLabel) throws SQLException {
            throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
        }

        @Override
        public Reader getNCharacterStream(int columnIndex) throws SQLException {
            throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
        }

        @Override
        public Reader getNCharacterStream(String columnLabel) throws SQLException {
            throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
        }

        @Override
        public void updateNCharacterStream(int columnIndex, Reader x, long length) throws SQLException {
            throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
        }

        @Override
        public void updateNCharacterStream(String columnLabel, Reader reader, long length) throws SQLException {
            throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
        }

        @Override
        public void updateAsciiStream(int columnIndex, InputStream x, long length) throws SQLException {
            throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
        }

        @Override
        public void updateBinaryStream(int columnIndex, InputStream x, long length) throws SQLException {
            throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
        }

        @Override
        public void updateCharacterStream(int columnIndex, Reader x, long length) throws SQLException {
            throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
        }

        @Override
        public void updateAsciiStream(String columnLabel, InputStream x, long length) throws SQLException {
            throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
        }

        @Override
        public void updateBinaryStream(String columnLabel, InputStream x, long length) throws SQLException {
            throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
        }

        @Override
        public void updateCharacterStream(String columnLabel, Reader reader, long length) throws SQLException {
            throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
        }

        @Override
        public void updateBlob(int columnIndex, InputStream inputStream, long length) throws SQLException {
            throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
        }

        @Override
        public void updateBlob(String columnLabel, InputStream inputStream, long length) throws SQLException {
            throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
        }

        @Override
        public void updateClob(int columnIndex, Reader reader, long length) throws SQLException {
            throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
        }

        @Override
        public void updateClob(String columnLabel, Reader reader, long length) throws SQLException {
            throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
        }

        @Override
        public void updateNClob(int columnIndex, Reader reader, long length) throws SQLException {
            throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
        }

        @Override
        public void updateNClob(String columnLabel, Reader reader, long length) throws SQLException {
            throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
        }

        @Override
        public void updateNCharacterStream(int columnIndex, Reader x) throws SQLException {
            throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
        }

        @Override
        public void updateNCharacterStream(String columnLabel, Reader reader) throws SQLException {
            throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
        }

        @Override
        public void updateAsciiStream(int columnIndex, InputStream x) throws SQLException {
            throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
        }

        @Override
        public void updateBinaryStream(int columnIndex, InputStream x) throws SQLException {
            throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
        }

        @Override
        public void updateCharacterStream(int columnIndex, Reader x) throws SQLException {
            throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
        }

        @Override
        public void updateAsciiStream(String columnLabel, InputStream x) throws SQLException {
            throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
        }

        @Override
        public void updateBinaryStream(String columnLabel, InputStream x) throws SQLException {
            throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
        }

        @Override
        public void updateCharacterStream(String columnLabel, Reader reader) throws SQLException {
            throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
        }

        @Override
        public void updateBlob(int columnIndex, InputStream inputStream) throws SQLException {
            throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
        }

        @Override
        public void updateBlob(String columnLabel, InputStream inputStream) throws SQLException {
            throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
        }

        @Override
        public void updateClob(int columnIndex, Reader reader) throws SQLException {
            throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
        }

        @Override
        public void updateClob(String columnLabel, Reader reader) throws SQLException {
            throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
        }

        @Override
        public void updateNClob(int columnIndex, Reader reader) throws SQLException {
            throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
        }

        @Override
        public void updateNClob(String columnLabel, Reader reader) throws SQLException {
            throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
        }

        @Override
        public <T> T getObject(int columnIndex, Class<T> type) throws SQLException {
            throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
        }

        @Override
        public <T> T getObject(String columnLabel, Class<T> type) throws SQLException {
            throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
        }

        @Override
        public <T> T unwrap(Class<T> iface) throws SQLException {
            throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
        }

        @Override
        public boolean isWrapperFor(Class<?> iface) throws SQLException {
            throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
        }
                
	}
}
