/*
 * @author <a href="mailto:bmiranda@cos.ufrj.br">Bernardo Miranda</a>
 * Pargres Project <http://pargres.nacad.ufrj.br>
 */
package org.pargres.jdbc;

import java.io.Serializable;
import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.ResultSet;
import java.sql.RowIdLifetime;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;

import org.pargres.commons.Range;
import org.pargres.commons.util.PargresException;
import org.pargres.jdbc.specifics.AbstractDatabase;
import org.pargres.jdbc.specifics.DatabaseProperties;

public class PargresDatabaseMetaData implements DatabaseMetaData,Serializable {
	/**
	 * 
	 */
	private static final long serialVersionUID = 3544671767583864117L;

	private PargresRowSet tables;

	private PargresRowSet schemas;

	private PargresRowSet catalogs;

	private PargresRowSet tableTypes;

	private HashMap<String, PargresRowSet> columns = new HashMap<String, PargresRowSet>();

	private HashMap<String, PargresRowSet> indexInfo = new HashMap<String, PargresRowSet>();
	
	private AbstractDatabase databaseSpecifics;
	
	private DatabaseProperties prop;
    
    private DatabaseProperties sortProperties;
	
	private ArrayList<Range> rangeList = new ArrayList<Range>();
    
    private ArrayList<Range> orderByRangeList = new ArrayList<Range>();
	
	public PargresDatabaseMetaData(DatabaseProperties prop, DatabaseProperties sort, DatabaseMetaData meta)
			throws PargresException {
		try {
			databaseSpecifics = AbstractDatabase.getDatabaseSpecifics(meta.getDatabaseProductName());
			this.prop = prop;
            this.sortProperties = sort;
			tables = new PargresRowSet();
			tables.populate(meta.getTables(null, null, null, null));
			schemas = new PargresRowSet();
			schemas.populate(meta.getSchemas());
			catalogs = new PargresRowSet();
			catalogs.populate(meta.getCatalogs());
			tableTypes = new PargresRowSet();
			tableTypes.populate(meta.getCatalogs());
			tables.beforeFirst();			
			while (tables.next()) {
				PargresRowSet rs = new PargresRowSet();	
				rs.populate(meta.getColumns(null, null, tables.getString("TABLE_NAME"), null));
				columns.put(tables.getString("TABLE_NAME").toLowerCase(),rs);
			}
			tables.beforeFirst();
			while (tables.next()) {
				PargresRowSet rs = new PargresRowSet();
				rs.populate(meta.getIndexInfo(null, null, tables
						.getString("TABLE_NAME"), false, false));				
				indexInfo.put(tables.getString("TABLE_NAME"), rs);
				
				loadPartitionedColumns(tables.getString("TABLE_NAME"), meta.getConnection());
                loadOrderByColumns(tables.getString("TABLE_NAME"), meta.getConnection());
			}
			tables.beforeFirst();
			
			System.out.println("DatabaseMetaData loaded!");
		} catch (Exception e) {
			System.err.println(e.getMessage());			
			e.printStackTrace();
			throw new PargresException(e.getMessage());
		}
	}
	
	public void dump() {
		/*System.out.print("DATABASE METADATA TABLES DUMP: ");
		for(String key : columns.keySet()) {
			System.out.print(key+" ,");
		}
		System.out.print("\n");*/
	}
	
	public ArrayList<String> getTables() throws SQLException {
		ResultSet rs = getTables(null, null, null, new String[] { "TABLE" });
		ArrayList<String> list = new ArrayList<String>();
		while (rs.next()) {
			list.add(rs.getString("TABLE_NAME"));
		}
		return list;
		/*
		 * ArrayList<String> list = new ArrayList<String>();
		 * list.add("customer"); list.add("lineitem"); list.add("nation");
		 * list.add("orders"); list.add("part"); list.add("partsupp");
		 * list.add("region"); return list;
		 */
	}

	public ArrayList<String> getPartitionableTables() throws SQLException {
		ArrayList<String> tables = getTables();
		ArrayList<String> list = new ArrayList<String>();
		for (int i = 0; i < tables.size(); i++) {
			String tableName = tables.get(i);
			if (getPartitionedColumns(tableName).size() > 0) {
				list.add(tableName);
			}
		}
		return list;
	}

	public ArrayList<Range> getRangeList() {
		return rangeList;
	}	
   
    public ArrayList<Range> getOrderByRangeList() {
        return orderByRangeList;
    }   

    public ArrayList<Range> getPartitionedColumns(String tableName)
			throws SQLException {
		Iterator<Range> it = rangeList.iterator();
		ArrayList<Range> list = new ArrayList<Range>();
		while(it.hasNext()) {
			Range range = (Range)it.next();
			if(range.getTableName().equals(tableName.toLowerCase()))
				list.add(range);
		}
		return list;
	}
	
	public void loadPartitionedColumns(String tableName, Connection con) throws SQLException {
		rangeList.addAll(databaseSpecifics.loadPartitionedColumns(prop, tableName,con, AbstractDatabase.PARTITIONED_COLUMNS));
	}
    
    public void loadOrderByColumns(String tableName, Connection con) throws SQLException {
        orderByRangeList.addAll(databaseSpecifics.loadPartitionedColumns(sortProperties, tableName,con, AbstractDatabase.ORDER_BY_COLUMNS));
    }

	public ResultSet getTables(String arg0, String arg1, String arg2,
			String[] arg3) throws SQLException {

		ArrayList<String> fields = new ArrayList<String>();
		ArrayList<Object> values = new ArrayList<Object>();
		fields.add("TABLE_CAT");
		fields.add("TABLE_SCHEM");
		fields.add("TABLE_NAME");
		fields.add("TABLE_TYPE");
		values.add(arg0);
		values.add(arg1);
		values.add(arg2);
		values.add(arg3);
		PargresRowSet rs = tables.filter(fields, values);
		return rs;
	}

	public Connection getConnection() throws SQLException {
		return null;
	}

	public ResultSet getSchemas() throws SQLException {
		return schemas.cloneThis();
	}

	public ResultSet getCatalogs() throws SQLException {
		return catalogs.cloneThis();
	}

	public ResultSet getTableTypes() throws SQLException {

		return tableTypes.cloneThis();
	}

	public ResultSet getColumns(String arg0, String arg1, String arg2,
			String arg3) throws SQLException {
		// TODO: Fazer o Filtro!
		PargresRowSet rs = columns.get(arg2.toLowerCase());
		if(rs == null) {
			System.out.println("Table not found: "+arg2);
			return new PargresRowSet();			
		} else
			return rs.cloneThis();
	}

	public String getDatabaseProductName() throws SQLException {

		return null;
	}

	public String getDatabaseProductVersion() throws SQLException {

		return null;
	}

	public String getDriverName() throws SQLException {

		return null;
	}

	public String getDriverVersion() throws SQLException {

		return null;
	}

	public int getDriverMajorVersion() {

		return 0;
	}

	public int getDriverMinorVersion() {

		return 0;
	}

	public int getDatabaseMajorVersion() throws SQLException {

		return 0;
	}

	public int getDatabaseMinorVersion() throws SQLException {

		return 0;
	}

	public int getJDBCMajorVersion() throws SQLException {

		return 0;
	}

	public int getJDBCMinorVersion() throws SQLException {

		return 0;
	}

	/** * METHODS BELOW NOT IMPLEMENTED ** */

	public boolean allProceduresAreCallable() throws SQLException {

		return false;
	}

	public boolean allTablesAreSelectable() throws SQLException {

		return false;
	}

	public String getURL() throws SQLException {

		return null;
	}

	public String getUserName() throws SQLException {

		return null;
	}

	public boolean isReadOnly() throws SQLException {

		return false;
	}

	public boolean nullsAreSortedHigh() throws SQLException {

		return false;
	}

	public boolean nullsAreSortedLow() throws SQLException {

		return false;
	}

	public boolean nullsAreSortedAtStart() throws SQLException {

		return false;
	}

	public boolean nullsAreSortedAtEnd() throws SQLException {

		return false;
	}

	public boolean usesLocalFiles() throws SQLException {

		return false;
	}

	public boolean usesLocalFilePerTable() throws SQLException {

		return false;
	}

	public boolean supportsMixedCaseIdentifiers() throws SQLException {

		return false;
	}

	public boolean storesUpperCaseIdentifiers() throws SQLException {

		return false;
	}

	public boolean storesLowerCaseIdentifiers() throws SQLException {

		return false;
	}

	public boolean storesMixedCaseIdentifiers() throws SQLException {

		return false;
	}

	public boolean supportsMixedCaseQuotedIdentifiers() throws SQLException {

		return false;
	}

	public boolean storesUpperCaseQuotedIdentifiers() throws SQLException {

		return false;
	}

	public boolean storesLowerCaseQuotedIdentifiers() throws SQLException {

		return false;
	}

	public boolean storesMixedCaseQuotedIdentifiers() throws SQLException {

		return false;
	}

	public String getIdentifierQuoteString() throws SQLException {

		return null;
	}

	public String getSQLKeywords() throws SQLException {

		return null;
	}

	public String getNumericFunctions() throws SQLException {

		return null;
	}

	public String getStringFunctions() throws SQLException {

		return null;
	}

	public String getSystemFunctions() throws SQLException {

		return null;
	}

	public String getTimeDateFunctions() throws SQLException {

		return null;
	}

	public String getSearchStringEscape() throws SQLException {

		return null;
	}

	public String getExtraNameCharacters() throws SQLException {

		return null;
	}

	public boolean supportsAlterTableWithAddColumn() throws SQLException {

		return false;
	}

	public boolean supportsAlterTableWithDropColumn() throws SQLException {

		return false;
	}

	public boolean supportsColumnAliasing() throws SQLException {

		return false;
	}

	public boolean nullPlusNonNullIsNull() throws SQLException {

		return false;
	}

	public boolean supportsConvert() throws SQLException {

		return false;
	}

	public boolean supportsConvert(int arg0, int arg1) throws SQLException {

		return false;
	}

	public boolean supportsTableCorrelationNames() throws SQLException {

		return false;
	}

	public boolean supportsDifferentTableCorrelationNames() throws SQLException {

		return false;
	}

	public boolean supportsExpressionsInOrderBy() throws SQLException {

		return false;
	}

	public boolean supportsOrderByUnrelated() throws SQLException {

		return false;
	}

	public boolean supportsGroupBy() throws SQLException {

		return false;
	}

	public boolean supportsGroupByUnrelated() throws SQLException {

		return false;
	}

	public boolean supportsGroupByBeyondSelect() throws SQLException {

		return false;
	}

	public boolean supportsLikeEscapeClause() throws SQLException {

		return false;
	}

	public boolean supportsMultipleResultSets() throws SQLException {

		return false;
	}

	public boolean supportsMultipleTransactions() throws SQLException {

		return false;
	}

	public boolean supportsNonNullableColumns() throws SQLException {

		return false;
	}

	public boolean supportsMinimumSQLGrammar() throws SQLException {

		return false;
	}

	public boolean supportsCoreSQLGrammar() throws SQLException {

		return false;
	}

	public boolean supportsExtendedSQLGrammar() throws SQLException {

		return false;
	}

	public boolean supportsANSI92EntryLevelSQL() throws SQLException {

		return false;
	}

	public boolean supportsANSI92IntermediateSQL() throws SQLException {

		return false;
	}

	public boolean supportsANSI92FullSQL() throws SQLException {

		return false;
	}

	public boolean supportsIntegrityEnhancementFacility() throws SQLException {

		return false;
	}

	public boolean supportsOuterJoins() throws SQLException {

		return false;
	}

	public boolean supportsFullOuterJoins() throws SQLException {

		return false;
	}

	public boolean supportsLimitedOuterJoins() throws SQLException {

		return false;
	}

	public String getSchemaTerm() throws SQLException {

		return null;
	}

	public String getProcedureTerm() throws SQLException {

		return null;
	}

	public String getCatalogTerm() throws SQLException {

		return null;
	}

	public boolean isCatalogAtStart() throws SQLException {

		return false;
	}

	public String getCatalogSeparator() throws SQLException {

		return null;
	}

	public boolean supportsSchemasInDataManipulation() throws SQLException {

		return false;
	}

	public boolean supportsSchemasInProcedureCalls() throws SQLException {

		return false;
	}

	public boolean supportsSchemasInTableDefinitions() throws SQLException {

		return false;
	}

	public boolean supportsSchemasInIndexDefinitions() throws SQLException {

		return false;
	}

	public boolean supportsSchemasInPrivilegeDefinitions() throws SQLException {

		return false;
	}

	public boolean supportsCatalogsInDataManipulation() throws SQLException {

		return false;
	}

	public boolean supportsCatalogsInProcedureCalls() throws SQLException {

		return false;
	}

	public boolean supportsCatalogsInTableDefinitions() throws SQLException {

		return false;
	}

	public boolean supportsCatalogsInIndexDefinitions() throws SQLException {

		return false;
	}

	public boolean supportsCatalogsInPrivilegeDefinitions() throws SQLException {

		return false;
	}

	public boolean supportsPositionedDelete() throws SQLException {

		return false;
	}

	public boolean supportsPositionedUpdate() throws SQLException {

		return false;
	}

	public boolean supportsSelectForUpdate() throws SQLException {

		return false;
	}

	public boolean supportsStoredProcedures() throws SQLException {

		return false;
	}

	public boolean supportsSubqueriesInComparisons() throws SQLException {

		return false;
	}

	public boolean supportsSubqueriesInExists() throws SQLException {

		return false;
	}

	public boolean supportsSubqueriesInIns() throws SQLException {

		return false;
	}

	public boolean supportsSubqueriesInQuantifieds() throws SQLException {

		return false;
	}

	public boolean supportsCorrelatedSubqueries() throws SQLException {

		return false;
	}

	public boolean supportsUnion() throws SQLException {

		return false;
	}

	public boolean supportsUnionAll() throws SQLException {

		return false;
	}

	public boolean supportsOpenCursorsAcrossCommit() throws SQLException {

		return false;
	}

	public boolean supportsOpenCursorsAcrossRollback() throws SQLException {

		return false;
	}

	public boolean supportsOpenStatementsAcrossCommit() throws SQLException {

		return false;
	}

	public boolean supportsOpenStatementsAcrossRollback() throws SQLException {

		return false;
	}

	public int getMaxBinaryLiteralLength() throws SQLException {

		return 0;
	}

	public int getMaxCharLiteralLength() throws SQLException {

		return 0;
	}

	public int getMaxColumnNameLength() throws SQLException {

		return 0;
	}

	public int getMaxColumnsInGroupBy() throws SQLException {

		return 0;
	}

	public int getMaxColumnsInIndex() throws SQLException {

		return 0;
	}

	public int getMaxColumnsInOrderBy() throws SQLException {

		return 0;
	}

	public int getMaxColumnsInSelect() throws SQLException {

		return 0;
	}

	public int getMaxColumnsInTable() throws SQLException {

		return 0;
	}

	public int getMaxConnections() throws SQLException {

		return 0;
	}

	public int getMaxCursorNameLength() throws SQLException {

		return 0;
	}

	public int getMaxIndexLength() throws SQLException {

		return 0;
	}

	public int getMaxSchemaNameLength() throws SQLException {

		return 0;
	}

	public int getMaxProcedureNameLength() throws SQLException {

		return 0;
	}

	public int getMaxCatalogNameLength() throws SQLException {

		return 0;
	}

	public int getMaxRowSize() throws SQLException {

		return 0;
	}

	public boolean doesMaxRowSizeIncludeBlobs() throws SQLException {

		return false;
	}

	public int getMaxStatementLength() throws SQLException {

		return 0;
	}

	public int getMaxStatements() throws SQLException {

		return 0;
	}

	public int getMaxTableNameLength() throws SQLException {

		return 0;
	}

	public int getMaxTablesInSelect() throws SQLException {

		return 0;
	}

	public int getMaxUserNameLength() throws SQLException {

		return 0;
	}

	public int getDefaultTransactionIsolation() throws SQLException {

		return 0;
	}

	public boolean supportsTransactions() throws SQLException {

		return false;
	}

	public boolean supportsTransactionIsolationLevel(int arg0)
			throws SQLException {

		return false;
	}

	public boolean supportsDataDefinitionAndDataManipulationTransactions()
			throws SQLException {

		return false;
	}

	public boolean supportsDataManipulationTransactionsOnly()
			throws SQLException {

		return false;
	}

	public boolean dataDefinitionCausesTransactionCommit() throws SQLException {

		return false;
	}

	public boolean dataDefinitionIgnoredInTransactions() throws SQLException {

		return false;
	}

	public ResultSet getProcedures(String arg0, String arg1, String arg2)
			throws SQLException {

		return null;
	}

	public ResultSet getProcedureColumns(String arg0, String arg1, String arg2,
			String arg3) throws SQLException {

		return null;
	}

	public ResultSet getColumnPrivileges(String arg0, String arg1, String arg2,
			String arg3) throws SQLException {

		return null;
	}

	public ResultSet getTablePrivileges(String arg0, String arg1, String arg2)
			throws SQLException {

		return null;
	}

	public ResultSet getBestRowIdentifier(String arg0, String arg1,
			String arg2, int arg3, boolean arg4) throws SQLException {

		return null;
	}

	public ResultSet getVersionColumns(String arg0, String arg1, String arg2)
			throws SQLException {

		return null;
	}

	public ResultSet getPrimaryKeys(String arg0, String arg1, String arg2)
			throws SQLException {

		return null;
	}

	public ResultSet getImportedKeys(String arg0, String arg1, String arg2)
			throws SQLException {

		return null;
	}

	public ResultSet getExportedKeys(String arg0, String arg1, String arg2)
			throws SQLException {

		return null;
	}

	public ResultSet getCrossReference(String arg0, String arg1, String arg2,
			String arg3, String arg4, String arg5) throws SQLException {

		return null;
	}

	public ResultSet getTypeInfo() throws SQLException {

		return null;
	}

	public ResultSet getIndexInfo(String arg0, String arg1, String arg2,
			boolean arg3, boolean arg4) throws SQLException {
		ArrayList<String> fields = new ArrayList<String>();
		ArrayList<Object> values = new ArrayList<Object>();
		fields.add("TABLE_CAT");
		fields.add("TABLE_SCHEM");
		// fields.add("TABLE_NAME");
		// fields.add("NON_UNIQUE");
		values.add(arg0);
		values.add(arg1);
		values.add(arg2);
		// TODO: Problemas aqui com os booleanos
		// values.add(arg3);
		// values.add(arg4);
		PargresRowSet rs = indexInfo.get(arg2);
		return rs.filter(fields, values);
	}

	public boolean supportsResultSetType(int arg0) throws SQLException {

		return false;
	}

	public boolean supportsResultSetConcurrency(int arg0, int arg1)
			throws SQLException {

		return false;
	}

	public boolean ownUpdatesAreVisible(int arg0) throws SQLException {

		return false;
	}

	public boolean ownDeletesAreVisible(int arg0) throws SQLException {

		return false;
	}

	public boolean ownInsertsAreVisible(int arg0) throws SQLException {

		return false;
	}

	public boolean othersUpdatesAreVisible(int arg0) throws SQLException {

		return false;
	}

	public boolean othersDeletesAreVisible(int arg0) throws SQLException {

		return false;
	}

	public boolean othersInsertsAreVisible(int arg0) throws SQLException {

		return false;
	}

	public boolean updatesAreDetected(int arg0) throws SQLException {

		return false;
	}

	public boolean deletesAreDetected(int arg0) throws SQLException {

		return false;
	}

	public boolean insertsAreDetected(int arg0) throws SQLException {

		return false;
	}

	public boolean supportsBatchUpdates() throws SQLException {

		return false;
	}

	public ResultSet getUDTs(String arg0, String arg1, String arg2, int[] arg3)
			throws SQLException {

		return null;
	}

	public boolean supportsSavepoints() throws SQLException {

		return false;
	}

	public boolean supportsNamedParameters() throws SQLException {

		return false;
	}

	public boolean supportsMultipleOpenResults() throws SQLException {

		return false;
	}

	public boolean supportsGetGeneratedKeys() throws SQLException {

		return false;
	}

	public ResultSet getSuperTypes(String arg0, String arg1, String arg2)
			throws SQLException {

		return null;
	}

	public ResultSet getSuperTables(String arg0, String arg1, String arg2)
			throws SQLException {

		return null;
	}

	public ResultSet getAttributes(String arg0, String arg1, String arg2,
			String arg3) throws SQLException {

		return null;
	}

	public boolean supportsResultSetHoldability(int arg0) throws SQLException {

		return false;
	}

	public int getResultSetHoldability() throws SQLException {

		return 0;
	}

	public int getSQLStateType() throws SQLException {

		return 0;
	}

	public boolean locatorsUpdateCopy() throws SQLException {

		return false;
	}

	public boolean supportsStatementPooling() throws SQLException {

		return false;
	}

	public boolean forceNewPartitionLimits(String table, String field, long first, long last) {
		for(Range range : rangeList) {
			if(range.getTableName().equals(table)) {
				range.setRangeInit(first);
				range.setRangeEnd(first);
				System.out.println("Force new partition limits SUCCESS!");
				return true;
			}
		}
		System.out.println("Force new partition limits FAILED!");
		return false;
	}

    @Override
    public RowIdLifetime getRowIdLifetime() throws SQLException {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }

    @Override
    public ResultSet getSchemas(String catalog, String schemaPattern) throws SQLException {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }

    @Override
    public boolean supportsStoredFunctionsUsingCallSyntax() throws SQLException {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }

    @Override
    public boolean autoCommitFailureClosesAllResultSets() throws SQLException {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }

    @Override
    public ResultSet getClientInfoProperties() throws SQLException {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }

    @Override
    public ResultSet getFunctions(String catalog, String schemaPattern, String functionNamePattern) throws SQLException {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }

    @Override
    public ResultSet getFunctionColumns(String catalog, String schemaPattern, String functionNamePattern, String columnNamePattern) throws SQLException {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }

    @Override
    public ResultSet getPseudoColumns(String catalog, String schemaPattern, String tableNamePattern, String columnNamePattern) throws SQLException {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }

    @Override
    public boolean generatedKeyAlwaysReturned() throws SQLException {
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
