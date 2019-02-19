package org.pargres.parser;
import java.util.ArrayList;

import org.pargres.commons.Range;
import org.pargres.commons.util.ParserException;
import org.pargres.commons.util.ParserSilentException;
import org.pargres.jdbc.PargresDatabaseMetaData;

/*
 * This class represents parser information about a query  
 */

public class Q {
	
	private String query;
	private String error;
	private String fromInnerQuery;
	private String fromOuterQueryText;
	private String fromSubqueryAlias;
    private String vpTable;
    private String vpAttribute;
	private ArrayList<String> fromSelectAliasTextList;
	private boolean isFromClauseInnerSelect;
	private ArrayList<Range> rangeList;
	private Parser parser;
	private ParserIni parserIni;
	private boolean isPartitionable;
	private ArrayList<String> returnList = new ArrayList<String>(0);
	private ArrayList<String> returnAliasTextList;
	private boolean setVpQueryWasCalled = false;
	private PargresDatabaseMetaData meta;
	
	public Q(String query, ArrayList<Range> rangeList, PargresDatabaseMetaData meta) throws ParserException, ParserSilentException {
		/* 
		 * parser
		 * 
		 * preencher lista de colunas presentes na consulta
		 * 
		 * listar de colunas do group by
		 * 
		 * compositores
		 */	
		this.meta = meta;
		this.query = query;
		this.rangeList = rangeList;
		//parser = new Parser(query,meta);
		parserIni = new ParserIni(query,meta);		
		error = parserIni.getErrorIni();
		if( !(error.equals("")) )
				throw(new ParserException(error));
		this.isFromClauseInnerSelect = parserIni.isFromClauseInnerSelect();
		if(this.isFromClauseInnerSelect) {
			fromSelectAliasTextList = parserIni.getFromSelectAliasTextList();
			fromOuterQueryText = parserIni.getFromOuterQueryText();
			fromSubqueryAlias = parserIni.getFromSubqueryAlias();
			fromInnerQuery = parserIni.getFromSubqueryText();
			parserIni = new ParserIni(fromInnerQuery,meta);
			error = parserIni.getErrorIni();
			if( !(error.equals("")) )
				throw(new ParserException(error));
		}
		processLists();
	}
	/*
	 * indica se query pode ser particionada virtualmente
	 */
	public boolean isPartitionable(){
		return this.isPartitionable;
	}	
	
	/* 
	 * fornece lista de tabelas de query candidatas a fragmentacao
	 */
	public ArrayList<String> getPartitionableTables(){
		return returnList;
	}
		
	public void processLists() {	  	  	
	  	for(int i=0; i<parserIni.getTableList().size();i++){
	  		for(int j=0;j<rangeList.size();j++){
	  			if( (parserIni.getTableList().get(i)).toUpperCase().equals((rangeList.get(j)).getTableName().toUpperCase()) )
	  				returnList.add(parserIni.getTableList().get(i).toUpperCase());
	  		}
	  	}
		if(returnList.size()!=0) 
			this.isPartitionable=true;
		else
			this.isPartitionable=false;
	  }
	
	public ArrayList<String> getAttributesQuery() throws ParserException{
		if(!setVpQueryWasCalled)
			throw(new ParserException("O metodo \"Q.setVpQuery(String table)\" deve ser executado antes de \"Q.getAttributesQuery()\"."));
		return parser.getWhereAttList();
	}
	
	/*
	 * fornece versao vp de acordo com a tabela escolhida para fragmentacao
	 */
	public void setVpQuery(String table) throws ParserException, ParserSilentException {		
		setVpQueryWasCalled = true;
        vpTable = table;
        vpAttribute = null;
		for(int i = 0; i < rangeList.size(); i++) {
			if(rangeList.get(i).getTableName().toUpperCase().equals(table.toUpperCase())) {
				vpAttribute = rangeList.get(i).getField();
				break;
			}
		}		
		if(returnList.contains(table.toUpperCase())){
			if(isFromClauseInnerSelect)
				parser = new Parser(fromInnerQuery,meta,parserIni,rangeList,table,vpAttribute);
			else
				parser = new Parser(this.query,this.meta,parserIni,rangeList,table,vpAttribute);
			
			error = parser.getError();
			if( !(error.equals("")) )
					throw(new ParserException(error));			
		}
		else throw(new ParserException("A tabela "+table+" nao e candidata a fragmentacao para esta consulta."));		
	}
	
	public String getVpQuery() throws ParserException{
		if(!setVpQueryWasCalled)
			throw(new ParserException("O metodo \"Q.setVpQuery(String table)\" deve ser executado antes de \"Q.getVpQuery()\"."));
		return parser.getVpQuery();
	}
		
	public Object[] getVpGroupByList() throws ParserException{
		if(!setVpQueryWasCalled)
			throw(new ParserException("O metodo \"Q.setVpQuery(String table)\" deve ser executado antes de \"Q.getVpGroupByList()\"."));		
		return parser.getGroupByList();
    }
	
	public ArrayList<Column> getQvpColumnsList() throws ParserException{
	   	if(!setVpQueryWasCalled)
			throw(new ParserException("O metodo \"Q.setVpQuery(String table)\" deve ser executado antes de \"Q.getQvpColumnsList()\"."));
		return parser.getQvpColumnsList();
    }
	
	public int getSelectAggregationFunctionCount() throws ParserException{
		if(!setVpQueryWasCalled)
			throw(new ParserException("O metodo \"Q.setVpQuery(String table)\" deve ser executado antes de \"Q.getSelectAggregationFunctionCount()\"."));
		return parser.getSelectAggregationFunctionCount();
	}
	
	public Object[][] getSelectCompositor() throws ParserException{
		if(!setVpQueryWasCalled)
			throw(new ParserException("O metodo \"Q.setVpQuery(String table)\" deve ser executado antes de \"Q.getSelectCompositor()\"."));
	    return parser.getSelectCompositor();
	}
	
	public ArrayList<String> getAliasTextList() throws ParserException{
		if(!setVpQueryWasCalled)
			throw(new ParserException("O metodo \"Q.setVpQuery(String table)\" deve ser executado antes de \"Q.getAliasCompositor()\"."));
	    if(isFromClauseInnerSelect){
			returnAliasTextList = parser.getAliasTextList();
			for(int i=0; i<fromSelectAliasTextList.size();i++){
				returnAliasTextList.set(i, fromSelectAliasTextList.get(i));
			}
			return returnAliasTextList;
	    }
	    else
			return parser.getAliasTextList();
    }
	
	public Object[] getHavingCompositor() throws ParserException{
		if(!setVpQueryWasCalled)
			throw(new ParserException("O metodo \"Q.setVpQuery(String table)\" deve ser executado antes de \"Q.getHavingCompositor()\"."));
        return parser.getHavingCompositor();
    }	
	public OrderByRef[] getOrderByIndexList() throws ParserException{
		if(!setVpQueryWasCalled)
				throw(new ParserException("O metodo \"Q.setVpQuery(String table)\" deve ser executado antes de \"Q.getOrderByIndexList()\"."));
	     return parser.getOrderByIndexList();
	}
	
    public ArrayList<String> getGroupByTextList() throws ParserException{
		   	if(!setVpQueryWasCalled)
				throw(new ParserException("O metodo \"Q.setVpQuery(String table)\" deve ser executado antes de \"Q.getGroupByTextList()\"."));
			return parser.getGroupByTextList();
	}

    public ArrayList<String> getOrderByTextList() throws ParserException{
	   	if(!setVpQueryWasCalled)
			throw(new ParserException("O metodo \"Q.setVpQuery(String table)\" deve ser executado antes de \"Q.getOrderByTextList()\"."));
		return parser.getOrderByTextList();
    }	
	
	public ArrayList<String> getSelectTextList() throws ParserException{
		   	if(!setVpQueryWasCalled)
				throw(new ParserException("O metodo \"Q.setVpQuery(String table)\" deve ser executado antes de \"Q.getSelectTextList()\"."));
			return parser.getSelectTextList();
	 }
	
	public int getQvpCount() throws ParserException{
		if(!setVpQueryWasCalled)
			throw(new ParserException("O metodo \"Q.setVpQuery(String table)\" deve ser executado antes de \"Q.getQvpCount()\"."));
		return parser.getQvpCount();
	}	
	
	public String getLimitText() throws ParserException{
		if(!setVpQueryWasCalled)
			throw(new ParserException("O metodo \"Q.setVpQuery(String table)\" deve ser executado antes de \"Q.getLimitText()\"."));
		return parser.getLimitText();
	}	

	public String getAllOrDistinctText() throws ParserException{
		if(!setVpQueryWasCalled)
			throw(new ParserException("O metodo \"Q.setVpQuery(String table)\" deve ser executado antes de \"Q.getAllOrDistinctText()\"."));
		return parser.getAllOrDistinctText();
	}
	
	public String getFromOuterQueryText(){
		return fromOuterQueryText;
	}
	
	public String getFromSubqueryAlias(){
		return fromSubqueryAlias;
	}
	
	public boolean isFromClauseInnerSelect() {
		return isFromClauseInnerSelect;
	}
	public ArrayList<Range> getRangeList(){
		return this.rangeList;
	}
    public String getVpTable() {
        return vpTable;
    }
    public String getVpAttribute() {
        return vpAttribute;
    }
}
