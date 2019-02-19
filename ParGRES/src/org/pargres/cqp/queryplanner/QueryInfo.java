/*
 * Created on 02/05/2005
 *
 */
package org.pargres.cqp.queryplanner;

import java.io.Serializable;
import java.util.ArrayList;

import org.pargres.commons.Range;
import org.pargres.jdbc.PargresDatabaseMetaData;
import org.pargres.parser.Column;

/**
 * @author bmiranda
 *
 */
public class QueryInfo implements Serializable {
	private static final long serialVersionUID = 6350617367418666108L;
	public static final int UPDATE_QUERY = 1;
	public static final int INTER_QUERY = 2;
	public static final int INTRA_QUERY = 3;
	
	private String sql;
	private int queryType;
	private QueryAvpDetail queryAvpDetail = null;
	private ArrayList<Column> vpColumns;
	private int numVpAggregationColumns;
    private ArrayList<String> groupByTextList;  
    private ArrayList<String> selectTextList;
    private ArrayList<String> orderByTextList;
    private ArrayList<String> aliasTextList;
    private boolean distributedComposition;
    private boolean distributedSort;
    private String limitText;
    private String vpTable;
    private String vpAttribute;
    private ArrayList<Range> orderByRangeList;
        
    public QueryAvpDetail getQueryAvpDetail() {
		return queryAvpDetail;
	}
	public void setQueryAvpDetail(QueryAvpDetail queryAvpDetail) {
		this.queryAvpDetail = queryAvpDetail;
	}
	/**
	 * @return Returns the queryType.
	 */
	public int getQueryType() {
		return queryType;
	}
	
	public String getQueryTypeName() {
		if(queryType == UPDATE_QUERY)
			return "UPDATE_QUERY";
		else if(queryType == INTER_QUERY)
			return "INTER_QUERY";
		else if(queryType == INTRA_QUERY)
			return "INTRA_QUERY";
		else 
			return "UNKNOWN";
	}	
	/**
	 * @param queryType The queryType to set.
	 */
	public void setQueryType(int queryType) {
		this.queryType = queryType;
	}
	/**
	 * @return Returns the sql.
	 */
	public String getSql() {
		return sql;
	}
	/**
	 * @param sql The sql to set.
	 */
	public void setSql(String sql) {
		this.sql = sql;	
	}

	public int getNumVpAggregationColumns() {
		return numVpAggregationColumns;
	}
	public void setNumVpAggregationColumns(int numVpAggregationColumns) {
		this.numVpAggregationColumns = numVpAggregationColumns;
	}
	public Column[] getVpColumns() {
		Column[] columns = new Column[vpColumns.size()];
		return vpColumns.toArray(columns);
	}
	public void setVpColumns(ArrayList<Column> vpColumns) {
		this.vpColumns = vpColumns;
	}
    public ArrayList<String> getGroupByTextList() {
        return groupByTextList;
    }
    public void setGroupByTextList(ArrayList<String> groupByTextList) {
        this.groupByTextList = groupByTextList;
    }
    public ArrayList<String> getSelectTextList() {
        return selectTextList;
    }
    public void setSelectTextList(ArrayList<String> selectTextList) {
        this.selectTextList = selectTextList;
    }
    public ArrayList<String> getOrderByTextList() {
        return orderByTextList;
    }
    public void setOrderByTextList(ArrayList<String> orderByTextList) {
        this.orderByTextList = orderByTextList;
    }
    public boolean isDistributedComposition() {
        return distributedComposition;
    }
    public void setDistributedComposition(boolean distributedComposition) {
        this.distributedComposition = distributedComposition;
    }
    public ArrayList<String> getAliasTextList() {
        return aliasTextList;
    }
    public void setAliasTextList(ArrayList<String> aliasTextList) {
        this.aliasTextList = aliasTextList;
    }
    public String getLimitText() {
        return limitText;
    }
    public void setLimitText(String limitText) {
        this.limitText = limitText;
    }
    public boolean isDistributedSort() {
        return distributedSort;
    }
    public void setDistributedSort(boolean distributedSort) {
        this.distributedSort = distributedSort;
    }
    public String getVpTable() {
        return vpTable;
    }
    public void setVpTable(String vpTable) {
        this.vpTable = vpTable;
    }
    public String getVpAttribute() {
        return vpAttribute;
    }
    public void setVpAttribute(String vpAttribute) {
        this.vpAttribute = vpAttribute;
    }
    public ArrayList<Range> getOrderByRangeList() {
        return orderByRangeList;
    }
    public void setOrderByRangeList(ArrayList<Range> range) {
        this.orderByRangeList = range;
    }
}
