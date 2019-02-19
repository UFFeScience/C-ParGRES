package org.pargres.grouper;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;

import org.pargres.commons.Range;
import org.pargres.commons.logger.Logger;
import org.pargres.commons.translation.Messages;
import org.pargres.console.ResultSetPrinter;
import org.pargres.cqp.queryplanner.QueryInfo;
import org.pargres.jdbc.PargresRowSet;
import org.pargres.parser.Column;
import org.pargres.parser.Const;

/**
 * @author kinder
 * 
 */
public class GrouperImpl extends Grouper {

    private Logger logger = Logger.getLogger(GrouperImpl.class);
    private QueryInfo queryInfo;
    private Column[] columns;
    private Statement stmt;
    private Connection con;
    private String insertStatement;
    private String query;
    private String hashValues;
    private int size;
    private int numlqts;
    private String[][] rangeList;
    private String[] orderByColumns;

    public GrouperImpl(QueryInfo qi, int numlqts, double id)
            throws SQLException {

        this.queryInfo = qi;
        this.columns = this.queryInfo.getVpColumns();
        this.size = 0;
        this.id = id;
        this.numlqts = numlqts;

        if (queryInfo.isDistributedSort()) {
            String field;
            int index = 0;
            String fieldName = columns[index].getText();
            Column[] columns = queryInfo.getVpColumns();
            Range range = null;
            double begin = 0;
            double end = 0;
            double rangeSize = 0;
            double rangeLimit = 0;
            rangeList = new String[numlqts + 1][2];

            if (queryInfo.getOrderByRangeList().size() == 0)
                queryInfo.setDistributedSort(false);
            else {
                orderByColumns = new String[queryInfo.getOrderByRangeList()
                        .size()];
                for (int i = 0; i < queryInfo.getOrderByTextList().size(); ++i) {
                    field = queryInfo.getOrderByTextList().get(i);
                    index = Integer.parseInt(field.substring(3, 4));
                    fieldName = columns[index].getText();
                    orderByColumns[0] = field;
                    range = queryInfo.getOrderByRangeList().get(i);
                    if (range.getField().toUpperCase().equals(
                            fieldName.toUpperCase())) {
                        begin = Double.parseDouble(range.getRangeMin());
                        rangeSize = range.getCardinality();
                        // rangeSize = (range.getRangeEnd() - begin) /
                        // queryInfo.getQueryAvpDetail().getNumNQPs();
                        rangeLimit = begin + rangeSize;
                        for (int j = 0; j < numlqts; ++j) {
                            rangeList[j][0] = Double.toString(begin);
                            if ((j + 1) == numlqts)
                                rangeList[j][1] = range.getRangeMax() + 1;
                            else
                                rangeList[j][1] = Double.toString(rangeLimit);
                            begin = rangeLimit + 1;
                            rangeLimit = begin + rangeSize - 1;
                        }

                    } else
                        queryInfo.setDistributedSort(false);
                }
            }
        }

        String createStatement = "create table " + Const.GROUPER_TABLE_NAME
                + "(";
        this.insertStatement = "insert into  " + Const.GROUPER_TABLE_NAME + "(";
        this.query = "select ";

        try {
            for (int i = 0; i < columns.length; ++i) {
                if (!columns[i].isConst()) {
                    createStatement = createStatement + Const.COLUMN_PREFIX + i
                            + " " + columns[i].getTypeText() + ",";

                    this.insertStatement = insertStatement
                            + Const.COLUMN_PREFIX + i + ",";
                }
                switch (columns[i].getAggregationFunction()) {
                case Const.SUM:
                    query = query + "SUM(" + Const.COLUMN_PREFIX + i + ") as "
                            + Const.COLUMN_PREFIX + i + ",";
                    break;
                case Const.MAX:
                    query = query + "MAX(" + Const.COLUMN_PREFIX + i + ") as "
                            + Const.COLUMN_PREFIX + i + ",";
                    break;
                case Const.MIN:
                    query = query + "MIN(" + Const.COLUMN_PREFIX + i + ") as "
                            + Const.COLUMN_PREFIX + i + ",";
                    break;
                case Const.COUNT:
                    query = query + "SUM(" + Const.COLUMN_PREFIX + i + ") as "
                            + Const.COLUMN_PREFIX + i + ",";
                    break;
                case Const.NONE:
                    if (!columns[i].isConst())
                        query = query + Const.COLUMN_PREFIX + i + ",";
                    else
                        query = query + columns[i].getText() + ",";
                    break;
                default:
                    throw new ClassNotFoundException(
                            "Agreggation class inexistent");
                }
            }

            String groupBy = "";
            hashValues = "";
            for (String s : qi.getGroupByTextList()) {
                groupBy = groupBy + s + ",";
                hashValues = hashValues + s + "||";
            }

            if (groupBy != "")
                groupBy = groupBy.substring(0, groupBy.length() - 1);

            if (hashValues != "")
                hashValues = hashValues.substring(0, hashValues.length() - 2);

            createStatement = createStatement.substring(0, createStatement
                    .length() - 1)
                    + ")";

            query = query.substring(0, query.length() - 1);
            query = query + " from " + Const.GROUPER_TABLE_NAME;
            if (groupBy != "")
                query = query + " group by " + groupBy;

            insertStatement = insertStatement.substring(0, insertStatement
                    .length() - 1)
                    + ") values (";

            Class.forName("org.hsqldb.jdbcDriver");
            con = DriverManager.getConnection("jdbc:hsqldb:mem:tempdb" + id
                    + this.hashCode(), "sa", "");
            // con.setAutoCommit(false);
            stmt = con.createStatement();
            stmt.executeUpdate(createStatement);
        } catch (ClassNotFoundException e) {
            logger.error(e.getMessage());
            e.printStackTrace();
        } catch (SQLException e) {
            logger.error(e.getMessage());
            // e.printStackTrace();
            throw e;
        }
    }

    public void insert(ResultSet result) {
        String insert = null;
        try {
            while (result.next()) {
                ResultSetMetaData meta = result.getMetaData();
                String valuesList = "";
                for (int i = 1; i <= meta.getColumnCount(); ++i) {
                    if (!columns[i - 1].isConst())
                        if (result.getString(i) == null)
                            valuesList = valuesList + result.getString(i) + ",";
                        else
                            valuesList = valuesList + "'" + result.getString(i)
                                    + "',";
                }

                valuesList = valuesList.substring(0, valuesList.length() - 1);
                insert = this.insertStatement + valuesList + ")";
                stmt.executeUpdate(insert);
                size++;
            }
        } catch (SQLException e) {
            logger.error(insert);
            logger.error(query);
            logger.error(e.getMessage());
            e.printStackTrace();
        }
    }

    @Override
    public ResultSet getAggregatedResult() {
        ResultSet rs;
        PargresRowSet prs = null;
        try {
            rs = stmt.executeQuery(query);
            prs = new PargresRowSet();
            prs.populate(rs);
            rs.close();
            logger.debug(Messages.getString(
                    "globalQueryTaskEngine.grouperSize", new Object[] {
                            this.id, prs.size() }));
            if (prs.size() == 0)
                prs = null;
        } catch (SQLException e) {
            logger.error(e.getMessage());
            e.printStackTrace();
        }

        return prs;
    }

    public ResultSet getAggregatedResult(int node, int method) {

        ResultSet rs;
        PargresRowSet prs = null;

        try {

            switch (method) {
            case HASH:
                rs = stmt.executeQuery("select * from (" + query + ") where "
                        + "\"org.pargres.util.Hash.code\"(" + hashValues + ","
                        + numlqts + " ) = " + node);
                break;

            case RANGE:
                String s = "select * from (" + query + ") where ";

                for (int i = 0; i < orderByColumns.length; ++i) {
                    s = s.concat(orderByColumns[i] + " >= "
                            + rangeList[node][0] + " and " + orderByColumns[i]
                            + "< " + rangeList[node][1] + " and ");
                }

                s = s.substring(0, s.length() - 4);
                rs = stmt.executeQuery(s);

                break;
            default:
                throw new IllegalArgumentException(Messages.getString(
                        "grouperImpl.gettingAgregatedResult", id));
            }
            prs = new PargresRowSet();
            prs.populate(rs);
            if (prs.size() == 0)
                prs = null;
            rs.close();
        } catch (SQLException e) {
            logger.error(e.getMessage());
            e.printStackTrace();
        }

        return prs;
    }

    @Override
    public void clear() {
        try {
            stmt.executeUpdate("Drop table " + Const.GROUPER_TABLE_NAME);
            stmt.close();
            con.close();
            logger.debug(Messages.getString(
                    "globalQueryTaskEngine.grouperDropped", id));
        } catch (SQLException e) {
            logger.error(e.getMessage());
            e.printStackTrace();
        }
    }

    @Override
    public ResultSet finish() {
        String columnList = "";
        String orderBy = "";
        ArrayList<String> alias;

        alias = queryInfo.getAliasTextList();
        int i = 0;
        for (String s : queryInfo.getSelectTextList()) {
            columnList = columnList + s + " as \"" + alias.get(i) + "\",";
            ++i;
        }

        for (String s : queryInfo.getOrderByTextList()) {
            orderBy = orderBy + s + ",";
        }
        columnList = columnList.substring(0, columnList.length() - 1);

        String select;
        if (queryInfo.isDistributedComposition())
            select = "select " + columnList + " from "
                    + Const.GROUPER_TABLE_NAME;
        else
            select = "select " + columnList + " from " + "( " + query + ")";

        if (orderBy != "") {
            orderBy = orderBy.substring(0, orderBy.length() - 1);
            select = select + " order by " + orderBy;
        }
        select = select + " " + queryInfo.getLimitText();
        PargresRowSet prs = null;
        try {
            prs = new PargresRowSet();
            ResultSet rs = this.stmt.executeQuery(select);
            prs.populate(rs);
        } catch (SQLException e) {
            logger.error(e.getMessage());
            e.printStackTrace();
        }

        return prs;
    }

    @Override
    public int size() {
        return this.size;
    }
}
