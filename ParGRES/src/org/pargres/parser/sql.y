%{
  import java.io.*;
  import java.util.ArrayList;
  import java.util.Date;
  import java.text.ParseException;
  import java.text.SimpleDateFormat;
  import java.lang.Double;
  import java.sql.ResultSet;
  import org.pargres.jdbc.PargresDatabaseMetaData;
  import org.pargres.commons.Range;
  import java.sql.Types;
  import org.pargres.commons.logger.Logger;
  import org.pargres.commons.util.ParserSilentException;
  import org.pargres.commons.translation.Messages;

%}
%token  TK_SELECT  TK_ALL  TK_DISTINCT  TK_USER  TK_INDICATOR  TK_NAME  TK_APPROXNUM  TK_INTNUM
%token  TK_DATE  TK_INTERVAL1 TK_INTERVAL2 TK_COMENTARIO  TK_EXISTS  TK_PLIC TK_STRING TK_CONCATENATION
%token  TK_AVG   TK_MIN   TK_MAX   TK_SUM   TK_COUNT   TK_INTO   TK_FROM   TK_WHERE   TK_OR   TK_AND
%token  TK_NOT   TK_NULL   TK_IS   TK_BETWEEN   TK_LIKE   TK_ESCAPE   TK_DIFERENTE   TK_MENOR_IG TK_VERTBAR
%token  TK_MAIOR_IG   TK_GROUP   TK_BY   TK_HAVING   TK_ORDER   TK_ASC   TK_DESC   TK_AS TK_IN TK_LIMIT
%token  TK_NULLIF  TK_COALESCE  TK_CASE TK_END TK_WHEN TK_THEN TK_NULL TK_ELSE TK_TRUE  TK_FALSE
%token  TK_ANY TK_ALL TK_SOME TK_EXTRACT TK_SUBSTRING TK_FOR

%%

Select : TK_SELECT Selection Select_tail ';'{
	 if(this.isFromClauseInnerSelect){
	    if(subqueryLevel==0 && isSelectExp==0 && isFunctionParameter==0){
               	((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + ((Tokens)($2.obj)).text +
            	                          ((Tokens)($3.obj)).text + ";";
            	this.vpQuery = ((Tokens)($$.obj)).text;
            }
	 }
	 else {
	    if(onlyText == 0) {
	    	if(subqueryLevel==0 && isSelectExp==0 && isFunctionParameter==0){
            		((Tokens)($$.obj)).text=((Tokens)($1.obj)).text + printColumnList(qvpColumnsList) +
            	                        	((Tokens)($3.obj)).text + ";";
            		this.vpQuery = ((Tokens)($$.obj)).text;
            	}
            	else
               		((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + ((Tokens)($2.obj)).text +
            	                         	  ((Tokens)($3.obj)).text + ";";
            }
            else {
               	((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + ((Tokens)($2.obj)).text +
            	                          ((Tokens)($3.obj)).text + ";";
            }
         }
       }
       ;

Select_tail : Into Table_exp {
                 ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + ((Tokens)($2.obj)).text;
                 if(onlyText == 0) {
                 	((Tokens)($$.obj)).compositorText = ((Tokens)($2.obj)).compositorText;
                 	((Tokens)($$.obj)).isJoinPartitionable = ((Tokens)($2.obj)).isJoinPartitionable;
                 	((Tokens)($$.obj)).isInPartitionable = ((Tokens)($2.obj)).isInPartitionable;
                 }
              }
            | Table_exp {
                 ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
                 if(onlyText == 0) {
                 	((Tokens)($$.obj)).compositorText = ((Tokens)($1.obj)).compositorText;
                 	((Tokens)($$.obj)).isJoinPartitionable = ((Tokens)($1.obj)).isJoinPartitionable;
                 	((Tokens)($$.obj)).isInPartitionable = ((Tokens)($1.obj)).isInPartitionable;
                 }
              }
            ;

All_or_distinct : TK_ALL {
                     ((Tokens)($$.obj)).text=" "+((Tokens)($1.obj)).text;
                  }
                | TK_DISTINCT {
                     ((Tokens)($$.obj)).text=" "+((Tokens)($1.obj)).text;
                  }
                ;

Selection : All_or_distinct Selection_term {
	    if(onlyText == 0) {
 	       if(subqueryLevel==0 && isSelectExp==0 && isFunctionParameter==0) {
 	       		((Tokens)($$.obj)).text = ((Tokens)($2.obj)).text;
 	       		allOrDistinct = ((Tokens)($1.obj)).text;
 	       }
 	       else {
 	       		((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + ((Tokens)($2.obj)).text;
 	       }
               ((Tokens)($$.obj)).type = ((Tokens)($2.obj)).type;
               ((Tokens)($$.obj)).selectColumnCount = ((Tokens)($2.obj)).selectColumnCount;
               ((Tokens)($$.obj)).isUniqueColumn = ((Tokens)($2.obj)).isUniqueColumn;
 	    }
 	    else {
 	       		((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + ((Tokens)($2.obj)).text;
 	    }
 	  }
          | Selection_term {
            if(onlyText == 0) {
 	       if(subqueryLevel==0 && isSelectExp==0 && isFunctionParameter==0) {
 	       		allOrDistinct = " ";
               }
               ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
               ((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
               ((Tokens)($$.obj)).selectColumnCount = ((Tokens)($1.obj)).selectColumnCount;
               ((Tokens)($$.obj)).isUniqueColumn = ((Tokens)($1.obj)).isUniqueColumn;
            }
            else
               ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
          }
          ;

Selection_term : Wildcard {
		 if(onlyText == 0) {
	            if(subqueryLevel==0 && isSelectExp==0 && isFunctionParameter==0){
                    	//qColumnCount++;
                    	addWildCardToColumnsList( (Tokens)($$.obj) );
                        ((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;

                    	//qColumnsList.add( ((Tokens)($$.obj)).clone() );
                    	//addColumnsList( (Tokens)($1.obj),qvpColumnsList );
	 	    }
	 	    else {
	 	    	addWildCardToColumnsList( (Tokens)($$.obj), subqueryLevel );
	 	    }
                    ((Tokens)($$.obj)).isUniqueColumn = false;
	         }
	         else {
	            ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
	         }
	       }
               | Scalar_exp_list_ini {
                 if(onlyText == 0) {
                    ((Tokens)($$.obj)).text=" "+((Tokens)($1.obj)).text;
	            ((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
 	            ((Tokens)($$.obj)).selectColumnCount = ((Tokens)($1.obj)).selectColumnCount;
 	            ((Tokens)($$.obj)).isUniqueColumn = ((Tokens)($1.obj)).isUniqueColumn;
                 }
                 else {
                    ((Tokens)($$.obj)).text=" "+((Tokens)($1.obj)).text;
                 }
               }
               ;

Wildcard : '*' {
	   if(onlyText == 0) {
              ((Tokens)($$.obj)).text = "*";
              ((Tokens)($$.obj)).type = Const.WILDCARD;
              ((Tokens)($$.obj)).alias = "";
   	      ((Tokens)($$.obj)).columnRefTable = null;
 	      ((Tokens)($$.obj)).columnRefField = null;
 	   }
 	   else {
               ((Tokens)($$.obj)).text = "*";
	   }
         }
         ;

Scalar_exp_list_ini : Scalar_exp_list{
                      if(onlyText == 0) {
			 ((Tokens)($$.obj)).text=((Tokens)($1.obj)).text;
          		 ((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
                         ((Tokens)($$.obj)).selectColumnCount = ((Tokens)($1.obj)).selectColumnCount;
			 ((Tokens)($$.obj)).isUniqueColumn = ((Tokens)($1.obj)).isUniqueColumn;
			 if(subqueryLevel==0 && isSelectExp==0 && isFunctionParameter==0){
                            	selectCompositor = selectCompTemp.toArray(selectCompositor);
                            	selectCompTemp.clear();
                            	selectCompTemp.trimToSize();
		    	 }
		      }
		      else {
			 ((Tokens)($$.obj)).text=((Tokens)($1.obj)).text;
		      }
                    }
                    ;

Scalar_exp_list : Scalar_exp_ini {
		  if(onlyText == 0) {
		     ((Tokens)($$.obj)).text=((Tokens)($1.obj)).text;
	             ((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
	             ((Tokens)($$.obj)).selectColumnCount = 1;
	             ((Tokens)($$.obj)).isUniqueColumn = ((Tokens)($1.obj)).isUniqueColumn;
		  }
		  else {
		     ((Tokens)($$.obj)).text=((Tokens)($1.obj)).text;
		  }
		}
                | Scalar_exp_ini ',' Scalar_exp_list {
                  if(onlyText == 0) {
                     ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + "," + ((Tokens)($3.obj)).text;
               	     ((Tokens)($$.obj)).type = Const.NONE;
                     ((Tokens)($$.obj)).selectColumnCount = ((Tokens)($1.obj)).selectColumnCount +
                     					    ((Tokens)($3.obj)).selectColumnCount;
                     ((Tokens)($$.obj)).isUniqueColumn = false;
                  }
                  else {
                     ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + "," + ((Tokens)($3.obj)).text;
                  }
                }
                ;

Scalar_exp_ini : Scalar_exp_as {
               if(onlyText == 0) {
                  if(((Tokens)($1.obj)).aggregationFunction!=Const.NONE){
                  	if(columnsNotInGroupError)
                  		yyerror("The column(s)" + columnsNotInGroup.substring(0,columnsNotInGroup.length() - 1) + " must appear in the GROUP BY clause" );

                  	if(subqueryLevel==0 && isSelectExp==0 && isFunctionParameter==0){
                 		qvpColumnsList = new ArrayList<Column>(qvpColumnsListTemp);
			}
                  }
                  else {
                        if(subqueryLevel==0 && isSelectExp==0 && isFunctionParameter==0){
                  	   int typeTemp;
                  	   boolean isConst;
                  	   if( constVerify(((Tokens)($1.obj)).type)) {
                  	  	   isConst = true;
                  		   typeTemp = ((Tokens)($1.obj)).type-1;
                  	   	   qvpColumnsList.add( new Column(((Tokens)($1.obj)).text, typeTemp,
                  		       ((Tokens)($1.obj)).aggregationFunction, getTypeText((Tokens)($1.obj)),
                  		                                               isConst) );
                  		                                               
                  	    	   qvpColumnsListTemp = new ArrayList<Column>(qvpColumnsList);
                  	   	   ((Tokens)($1.obj)).compositor.clear();
                  	   	   ((Tokens)($1.obj)).compositor.trimToSize();
                  	   	   ((Tokens)($1.obj)).compositor.add(new ColumnIndex(qvpColumnsList.size()-1));
                    	   }
                  	   else {
                  		   isConst = false;
                  		   typeTemp = ((Tokens)($1.obj)).type;
                  		   qvpColumnsList.add( new Column(((Tokens)($1.obj)).text, typeTemp,
                  		      ((Tokens)($1.obj)).aggregationFunction, getTypeText((Tokens)($1.obj)),
                  		   	                               	       isConst) );
                  	   	   qvpColumnsListTemp = new ArrayList<Column>(qvpColumnsList);
                  	   	   ((Tokens)($1.obj)).compositorText = Const.COLUMN_PREFIX + (qvpColumnsList.size()-1);
                  	  	   ((Tokens)($1.obj)).compositor.clear();
                  	   	   ((Tokens)($1.obj)).compositor.trimToSize();
                  	   	   ((Tokens)($1.obj)).compositor.add(new ColumnIndex(qvpColumnsList.size()-1));
                  	   }
			}
                  	if(existsAggregationSelect.get(subqueryLevel)){
				if(mustIncludeInGroupBy(((Tokens)($1.obj)).text, subqueryLevel))
					if(columnsNotInGroupError)
						yyerror("The column(s)" + columnsNotInGroup.substring(0,columnsNotInGroup.length() - 1) + " must appear in the GROUP BY clause");
		  	}
                  }
                  ((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
		  ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
                  columnsNotInGroupError = false;
                  columnsNotInGroup = "";
                  ((Tokens)($$.obj)).selectColumnCount = 1;
                  ((Tokens)($$.obj)).isUniqueColumn = ((Tokens)($1.obj)).isUniqueColumn;
                  //qColumnCount++;
                  if(subqueryLevel==0 && isSelectExp==0 && isFunctionParameter==0){
                  	aliasTextList.add(((Tokens)($1.obj)).alias);
                  	aliasTextList.trimToSize();
                  	selectCompositorText.add( new String ( ((Tokens)($1.obj)).compositorText ) );
                  	selectTextList.trimToSize();
                  	selectTextList.add(new String(((Tokens)($1.obj)).compositorText));
                  	selectCompositorText.trimToSize();
                  	selectCompTemp.add( ((Tokens)($1.obj)).compositor.toArray() );
                  	selectCompTemp.trimToSize();
                  	qColumnsList.add( ((Tokens)($1.obj)).clone() );
                  	qColumnsList.trimToSize();
                  }
               }
               else {
		  ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
               }
             }
            ;

Scalar_exp_as : Scalar_condition TK_AS Name {
	      if(this.isFromClauseInnerSelect){
		  ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " as " + ((Tokens)($3.obj)).text;
                  ((Tokens)($$.obj)).alias ="";
		  ((Tokens)($$.obj)).typeSize = ((Tokens)($1.obj)).typeSize;
		  ((Tokens)($$.obj)).typePrecision = ((Tokens)($1.obj)).typePrecision;
		  ((Tokens)($$.obj)).typeLength = ((Tokens)($1.obj)).typeLength;
                  ((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
		  ((Tokens)($$.obj)).aggregationFunction=((Tokens)($1.obj)).aggregationFunction;
 		  ((Tokens)($$.obj)).compositorText = ((Tokens)($1.obj)).compositorText;
                  ((Tokens)($$.obj)).compositor= new ArrayList<Object>(((Tokens)($1.obj)).compositor);
                  ((Tokens)($$.obj)).isUniqueColumn = ((Tokens)($1.obj)).isUniqueColumn;
	      }
	      else {
		if(onlyText == 0) {
		  if(subqueryLevel==0 && isSelectExp==0 && isFunctionParameter==0){
                  	((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
                  	((Tokens)($$.obj)).alias =((Tokens)($3.obj)).text;
		  }
		  else {
		  	((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " as " + ((Tokens)($3.obj)).text;
                  	((Tokens)($$.obj)).alias ="";
		  }
		  ((Tokens)($$.obj)).typeSize = ((Tokens)($1.obj)).typeSize;
		  ((Tokens)($$.obj)).typePrecision = ((Tokens)($1.obj)).typePrecision;
		  ((Tokens)($$.obj)).typeLength = ((Tokens)($1.obj)).typeLength;
                  ((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
		  ((Tokens)($$.obj)).aggregationFunction=((Tokens)($1.obj)).aggregationFunction;
 		  ((Tokens)($$.obj)).compositorText = ((Tokens)($1.obj)).compositorText;
                  ((Tokens)($$.obj)).compositor= new ArrayList<Object>(((Tokens)($1.obj)).compositor);
                  ((Tokens)($$.obj)).isUniqueColumn = ((Tokens)($1.obj)).isUniqueColumn;
                }
                else {
 		  	((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " as " + ((Tokens)($3.obj)).text;
               }
              }
             }

              | Scalar_condition {
		if(onlyText == 0) {
		  ((Tokens)($$.obj)).typeSize = ((Tokens)($1.obj)).typeSize;
		  ((Tokens)($$.obj)).typePrecision = ((Tokens)($1.obj)).typePrecision;
		  ((Tokens)($$.obj)).typeLength = ((Tokens)($1.obj)).typeLength;
                  ((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
		  ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
		  ((Tokens)($$.obj)).aggregationFunction=((Tokens)($1.obj)).aggregationFunction;
 		  ((Tokens)($$.obj)).alias = ((Tokens)($1.obj)).text;
                  ((Tokens)($$.obj)).compositorText = ((Tokens)($1.obj)).compositorText;
		  ((Tokens)($$.obj)).compositor= new ArrayList<Object>(((Tokens)($1.obj)).compositor);
		  ((Tokens)($$.obj)).isUniqueColumn = ((Tokens)($1.obj)).isUniqueColumn;
  		  ((Tokens)($$.obj)).columnRefTable = ((Tokens)($1.obj)).columnRefTable;
 		  ((Tokens)($$.obj)).columnRefField = ((Tokens)($1.obj)).columnRefField;
                }
                else {
		  ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
                }
              }
              ;

Scalar_condition : Scalar_condition_term {
		   if(onlyText == 0) {
		      ((Tokens)($$.obj)).typeSize = ((Tokens)($1.obj)).typeSize;
	 	      ((Tokens)($$.obj)).typePrecision = ((Tokens)($1.obj)).typePrecision;
	 	      ((Tokens)($$.obj)).typeLength = ((Tokens)($1.obj)).typeLength;
                      ((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
	  	      ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
 	  	      ((Tokens)($$.obj)).aggregationFunction=((Tokens)($1.obj)).aggregationFunction;
 		      ((Tokens)($$.obj)).alias = ((Tokens)($1.obj)).text;
                      ((Tokens)($$.obj)).compositorText = ((Tokens)($1.obj)).compositorText;
	 	      ((Tokens)($$.obj)).compositor= new ArrayList<Object>(((Tokens)($1.obj)).compositor);
		      ((Tokens)($$.obj)).isUniqueColumn = ((Tokens)($1.obj)).isUniqueColumn;
  		      ((Tokens)($$.obj)).columnRefTable = ((Tokens)($1.obj)).columnRefTable;
 		      ((Tokens)($$.obj)).columnRefField = ((Tokens)($1.obj)).columnRefField;
                   }
                   else {
	  	      ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
                   }
                 }
                 | Scalar_condition_term TK_OR Scalar_condition {
                   if(onlyText == 0) {
                      ((Tokens)($$.obj)).compositorText =  ((Tokens)($1.obj)).compositorText + " or " +
	                                                   ((Tokens)($3.obj)).compositorText;
                      ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " " + ((Tokens)($2.obj)).text + " " +
                                                ((Tokens)($3.obj)).text;
                      getResultLogicOpType( (Tokens)($1.obj), (Tokens)($3.obj), (Tokens)($$.obj) );
          	      if( (((Tokens)($$.obj)).aggregationFunction=((Tokens)($1.obj)).aggregationFunction) == Const.NONE)
	      	      	    ((Tokens)($$.obj)).aggregationFunction=((Tokens)($3.obj)).aggregationFunction;

		      ((Tokens)($$.obj)).compositor=new ArrayList<Object>(addCompositor(Const.OR,(Tokens)$1.obj,(Tokens)$3.obj));
                      ((Tokens)($$.obj)).isUniqueColumn = false;
                      ((Tokens)($$.obj)).columnRefTable = null;
		      ((Tokens)($$.obj)).columnRefField = null;
		      if(havingCase!=0 && !this.isFromClauseInnerSelect)
		      	throw(new ParserSilentException("InterQuery : Expression not treated yet. Line : "+line+" Column : "+column ));

                   }
                   else {
                      ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " " + ((Tokens)($2.obj)).text + " " +
                                                ((Tokens)($3.obj)).text;
                  }
                 }
                 ;

Scalar_condition_term : Scalar_Not_tag {
	       if(onlyText == 0) {
		  ((Tokens)($$.obj)).typeSize = ((Tokens)($1.obj)).typeSize;
		  ((Tokens)($$.obj)).typePrecision = ((Tokens)($1.obj)).typePrecision;
		  ((Tokens)($$.obj)).typeLength = ((Tokens)($1.obj)).typeLength;
                  ((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
		  ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
		  ((Tokens)($$.obj)).aggregationFunction=((Tokens)($1.obj)).aggregationFunction;
 		  ((Tokens)($$.obj)).alias = ((Tokens)($1.obj)).text;
                  ((Tokens)($$.obj)).compositorText = ((Tokens)($1.obj)).compositorText;
		  ((Tokens)($$.obj)).compositor= new ArrayList<Object>(((Tokens)($1.obj)).compositor);
		  ((Tokens)($$.obj)).isUniqueColumn = ((Tokens)($1.obj)).isUniqueColumn;
  		  ((Tokens)($$.obj)).columnRefTable = ((Tokens)($1.obj)).columnRefTable;
 		  ((Tokens)($$.obj)).columnRefField = ((Tokens)($1.obj)).columnRefField;
              }
              else {
		  ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
              }
            }
            | Scalar_Not_tag TK_AND Scalar_condition_term {
              if(onlyText == 0) {
                 ((Tokens)($$.obj)).compositorText = ((Tokens)($1.obj)).compositorText + " and " +
	                                             ((Tokens)($3.obj)).compositorText;
                 ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " " + ((Tokens)($2.obj)).text + " " +
                                           ((Tokens)($3.obj)).text;
                 getResultLogicOpType( (Tokens)($1.obj), (Tokens)($3.obj), (Tokens)($$.obj) );
          	 if( (((Tokens)($$.obj)).aggregationFunction=((Tokens)($1.obj)).aggregationFunction) == Const.NONE)
	      	 	((Tokens)($$.obj)).aggregationFunction=((Tokens)($3.obj)).aggregationFunction;

                 ((Tokens)($$.obj)).compositor=new ArrayList<Object>(addCompositor(Const.AND,(Tokens)$1.obj,(Tokens)$3.obj));
                 ((Tokens)($$.obj)).isUniqueColumn = false;
                 ((Tokens)($$.obj)).columnRefTable = null;
		 ((Tokens)($$.obj)).columnRefField = null;
              }
              else {
                 ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " " + ((Tokens)($2.obj)).text + " " +
                                           ((Tokens)($3.obj)).text;
              }
            }
            ;


Scalar_Not_tag : Scalar_predicate {
		 if(onlyText == 0) {
		  ((Tokens)($$.obj)).typeSize = ((Tokens)($1.obj)).typeSize;
		  ((Tokens)($$.obj)).typePrecision = ((Tokens)($1.obj)).typePrecision;
		  ((Tokens)($$.obj)).typeLength = ((Tokens)($1.obj)).typeLength;
                  ((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
		  ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
		  ((Tokens)($$.obj)).aggregationFunction=((Tokens)($1.obj)).aggregationFunction;
 		  ((Tokens)($$.obj)).alias = ((Tokens)($1.obj)).text;
                  ((Tokens)($$.obj)).compositorText = ((Tokens)($1.obj)).compositorText;
		  ((Tokens)($$.obj)).compositor= new ArrayList<Object>(((Tokens)($1.obj)).compositor);
		  ((Tokens)($$.obj)).isUniqueColumn = ((Tokens)($1.obj)).isUniqueColumn;
  		  ((Tokens)($$.obj)).columnRefTable = ((Tokens)($1.obj)).columnRefTable;
 		  ((Tokens)($$.obj)).columnRefField = ((Tokens)($1.obj)).columnRefField;
                 }
                 else {
		  ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
                 }
               }
               | TK_NOT Scalar_predicate {
                 if(onlyText == 0) {
                    ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " " + ((Tokens)($2.obj)).text;
                    getResultLogicOpType( (Tokens)($2.obj), (Tokens)($$.obj) );
                    ((Tokens)($$.obj)).compositor=new ArrayList<Object>(addCompositor(Const.NOT,(Tokens)$2.obj));
                    ((Tokens)($$.obj)).compositorText = "not " + ((Tokens)($2.obj)).compositorText;
                    ((Tokens)($$.obj)).isUniqueColumn = false;
                    ((Tokens)($$.obj)).columnRefTable = null;
		    ((Tokens)($$.obj)).columnRefField = null;
                  }
                  else {
                     ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " " + ((Tokens)($2.obj)).text;
                 }
               }
               ;

Scalar_predicate : Test_for_null {
		   if(onlyText == 0) {
		  	((Tokens)($$.obj)).typeSize = ((Tokens)($1.obj)).typeSize;
		  	((Tokens)($$.obj)).typePrecision = ((Tokens)($1.obj)).typePrecision;
		  	((Tokens)($$.obj)).typeLength = ((Tokens)($1.obj)).typeLength;
                  	((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
		  	((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
		  	((Tokens)($$.obj)).aggregationFunction=((Tokens)($1.obj)).aggregationFunction;
 		  	((Tokens)($$.obj)).alias = ((Tokens)($1.obj)).text;
                  	((Tokens)($$.obj)).compositorText = ((Tokens)($1.obj)).compositorText;
		  	((Tokens)($$.obj)).compositor= new ArrayList<Object>(((Tokens)($1.obj)).compositor);
		  	((Tokens)($$.obj)).isUniqueColumn = false;
  		  	((Tokens)($$.obj)).columnRefTable = ((Tokens)($1.obj)).columnRefTable;
 		  	((Tokens)($$.obj)).columnRefField = ((Tokens)($1.obj)).columnRefField;
                   }
                   else {
 		  	((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
                  }
                 }
                 | Existence_test {
	           if(onlyText == 0) {
	                if(subqueryLevel==0 && isSelectExp==0 && isFunctionParameter==0){
		   	     addColumnsList( (Tokens)($1.obj),qvpColumnsListTemp );
                        }
		  	((Tokens)($$.obj)).typeSize = ((Tokens)($1.obj)).typeSize;
		  	((Tokens)($$.obj)).typePrecision = ((Tokens)($1.obj)).typePrecision;
		  	((Tokens)($$.obj)).typeLength = ((Tokens)($1.obj)).typeLength;
                  	((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
		  	((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
		  	((Tokens)($$.obj)).aggregationFunction=((Tokens)($1.obj)).aggregationFunction;
 		  	((Tokens)($$.obj)).alias = ((Tokens)($1.obj)).text;
                  	((Tokens)($$.obj)).compositorText = ((Tokens)($1.obj)).compositorText;
		  	((Tokens)($$.obj)).compositor= new ArrayList<Object>(((Tokens)($1.obj)).compositor);
		  	((Tokens)($$.obj)).isUniqueColumn = false;
  		  	((Tokens)($$.obj)).columnRefTable = ((Tokens)($1.obj)).columnRefTable;
 		  	((Tokens)($$.obj)).columnRefField = ((Tokens)($1.obj)).columnRefField;
		     	if(!this.isFromClauseInnerSelect)
		     		throw(new ParserSilentException("InterQuery : Exists subquery in the Select clause. Line : " + line + " Column : " + column));
                   }
                   else {
		  	((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
                   }
                 }
          /***
                 |     <quantified comparison predicate>
		 |     <exists predicate>
		 |     <unique predicate>
		 |     <match predicate>
		 |     <overlaps predicate>
		 |     <similar predicate>
		 |     <distinct predicate>
	         |     <type predicate>

	  ***/
          | Scalar_relational_exp {
	    if(onlyText == 0) {
		  ((Tokens)($$.obj)).typeSize = ((Tokens)($1.obj)).typeSize;
		  ((Tokens)($$.obj)).typePrecision = ((Tokens)($1.obj)).typePrecision;
		  ((Tokens)($$.obj)).typeLength = ((Tokens)($1.obj)).typeLength;
                  ((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
		  ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
		  ((Tokens)($$.obj)).aggregationFunction=((Tokens)($1.obj)).aggregationFunction;
 		  ((Tokens)($$.obj)).alias = ((Tokens)($1.obj)).text;
                  ((Tokens)($$.obj)).compositorText = ((Tokens)($1.obj)).compositorText;
		  ((Tokens)($$.obj)).compositor= new ArrayList<Object>(((Tokens)($1.obj)).compositor);
		  ((Tokens)($$.obj)).isUniqueColumn = ((Tokens)($1.obj)).isUniqueColumn;
  		  ((Tokens)($$.obj)).columnRefTable = ((Tokens)($1.obj)).columnRefTable;
 		  ((Tokens)($$.obj)).columnRefField = ((Tokens)($1.obj)).columnRefField;
            }
            else {
		  ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
            }
          }
          ;

Scalar_relational_exp : Scalar_exp {
		      if(onlyText == 0) {
		  	((Tokens)($$.obj)).typeSize = ((Tokens)($1.obj)).typeSize;
		  	((Tokens)($$.obj)).typePrecision = ((Tokens)($1.obj)).typePrecision;
		  	((Tokens)($$.obj)).typeLength = ((Tokens)($1.obj)).typeLength;
                  	((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
		  	((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
		  	((Tokens)($$.obj)).aggregationFunction=((Tokens)($1.obj)).aggregationFunction;
 		  	((Tokens)($$.obj)).alias = ((Tokens)($1.obj)).text;
                  	((Tokens)($$.obj)).compositorText = ((Tokens)($1.obj)).compositorText;
		  	((Tokens)($$.obj)).compositor= new ArrayList<Object>(((Tokens)($1.obj)).compositor);
		  	((Tokens)($$.obj)).isUniqueColumn = ((Tokens)($1.obj)).isUniqueColumn;
  		  	((Tokens)($$.obj)).columnRefTable = ((Tokens)($1.obj)).columnRefTable;
 		  	((Tokens)($$.obj)).columnRefField = ((Tokens)($1.obj)).columnRefField;
                      }
                      else {
		  	((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
                      }
                    }

               | Scalar_exp Comparison Scalar_relational_rvalue {
                 if(onlyText == 0) {
                   ((Tokens)($$.obj)).compositorText = ((Tokens)($1.obj)).compositorText + " " +
                                                       ((Tokens)($2.obj)).text + " " +
                                                       ((Tokens)($3.obj)).compositorText;
                   ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " " + ((Tokens)($2.obj)).text + " " +
                                             ((Tokens)($3.obj)).text;
                   getResultRelationalOpType( (Tokens)($1.obj), (Tokens)($3.obj), (Tokens)($$.obj) );
          	   if( (((Tokens)($$.obj)).aggregationFunction=((Tokens)($1.obj)).aggregationFunction) == Const.NONE)
	      	   	((Tokens)($$.obj)).aggregationFunction=((Tokens)($3.obj)).aggregationFunction;
                   ((Tokens)($$.obj)).compositor=new ArrayList<Object>(addCompositor(((Tokens)($2.obj)).operator,(Tokens)$1.obj,(Tokens)$3.obj));
                   ((Tokens)($$.obj)).isUniqueColumn = false;
                   ((Tokens)($$.obj)).columnRefTable = null;
		   ((Tokens)($$.obj)).columnRefField = null;
                 }
                 else {
                   ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " " + ((Tokens)($2.obj)).text + " " +
                                             ((Tokens)($3.obj)).text;
                 }
               }

               | Scalar_relational_predicate {
		 if(onlyText == 0) {
		  ((Tokens)($$.obj)).typeSize = ((Tokens)($1.obj)).typeSize;
		  ((Tokens)($$.obj)).typePrecision = ((Tokens)($1.obj)).typePrecision;
		  ((Tokens)($$.obj)).typeLength = ((Tokens)($1.obj)).typeLength;
                  ((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
		  ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
		  ((Tokens)($$.obj)).aggregationFunction=((Tokens)($1.obj)).aggregationFunction;
 		  ((Tokens)($$.obj)).alias = ((Tokens)($1.obj)).text;
                  ((Tokens)($$.obj)).compositorText = ((Tokens)($1.obj)).compositorText;
		  ((Tokens)($$.obj)).compositor= new ArrayList<Object>(((Tokens)($1.obj)).compositor);
		  ((Tokens)($$.obj)).isUniqueColumn = false;
  		  ((Tokens)($$.obj)).columnRefTable = ((Tokens)($1.obj)).columnRefTable;
 		  ((Tokens)($$.obj)).columnRefField = ((Tokens)($1.obj)).columnRefField;
                }
                else {
		  ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
                }
               }
               ;

Scalar_relational_predicate : Scalar_between_predicate {
                  	if(onlyText == 0) {
                  	 ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
		   	 ((Tokens)($$.obj)).typeSize = ((Tokens)($1.obj)).typeSize;
		   	 ((Tokens)($$.obj)).typePrecision = ((Tokens)($1.obj)).typePrecision;
		  	 ((Tokens)($$.obj)).typeLength = ((Tokens)($1.obj)).typeLength;
		   	 ((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
		   	 ((Tokens)($$.obj)).aggregationFunction=((Tokens)($1.obj)).aggregationFunction;
		  	 ((Tokens)($$.obj)).compositorText = ((Tokens)($1.obj)).compositorText;
		  	 ((Tokens)($$.obj)).compositor= new ArrayList<Object>(((Tokens)($1.obj)).compositor);
                         ((Tokens)($$.obj)).columnRefTable = null;
                         ((Tokens)($$.obj)).columnRefField = null;
                       }
                       else {
                  	 ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
                       }
                     }
                     | Scalar_like_predicate {
                       if(onlyText == 0) {
                	((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
		  	((Tokens)($$.obj)).typeSize = ((Tokens)($1.obj)).typeSize;
		  	((Tokens)($$.obj)).typePrecision = ((Tokens)($1.obj)).typePrecision;
		  	((Tokens)($$.obj)).typeLength = ((Tokens)($1.obj)).typeLength;
			((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
			((Tokens)($$.obj)).aggregationFunction=((Tokens)($1.obj)).aggregationFunction;
			((Tokens)($$.obj)).compositorText = ((Tokens)($1.obj)).compositorText;
		   	((Tokens)($$.obj)).compositor= new ArrayList<Object>(((Tokens)($1.obj)).compositor);
                        ((Tokens)($$.obj)).columnRefTable = null;
                        ((Tokens)($$.obj)).columnRefField = null;
                       }
                       else {
                   	((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
                      }
                     }
                     | Scalar_in_predicate {
                       if(onlyText == 0) {
	                if(subqueryLevel==0 && isSelectExp==0 && isFunctionParameter==0){
		   	     addColumnsList( (Tokens)($1.obj),qvpColumnsListTemp );
                        }
                  	((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
		  	((Tokens)($$.obj)).typeSize = ((Tokens)($1.obj)).typeSize;
		  	((Tokens)($$.obj)).typePrecision = ((Tokens)($1.obj)).typePrecision;
		  	((Tokens)($$.obj)).typeLength = ((Tokens)($1.obj)).typeLength;
			((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
			((Tokens)($$.obj)).aggregationFunction=((Tokens)($1.obj)).aggregationFunction;
			((Tokens)($$.obj)).compositorText = ((Tokens)($1.obj)).compositorText;
		   	((Tokens)($$.obj)).compositor= new ArrayList<Object>(((Tokens)($1.obj)).compositor);
                        ((Tokens)($$.obj)).columnRefTable = null;
                        ((Tokens)($$.obj)).columnRefField = null;
                       }
                       else {
                  	((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
                       }
                      }
                     ;


Scalar_relational_rvalue : Scalar_exp {
		if(onlyText == 0) {
		  ((Tokens)($$.obj)).typeSize = ((Tokens)($1.obj)).typeSize;
		  ((Tokens)($$.obj)).typePrecision = ((Tokens)($1.obj)).typePrecision;
		  ((Tokens)($$.obj)).typeLength = ((Tokens)($1.obj)).typeLength;
                  ((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
		  ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
		  ((Tokens)($$.obj)).aggregationFunction=((Tokens)($1.obj)).aggregationFunction;
 		  ((Tokens)($$.obj)).alias = ((Tokens)($1.obj)).text;
                  ((Tokens)($$.obj)).compositorText = ((Tokens)($1.obj)).compositorText;
		  ((Tokens)($$.obj)).compositor= new ArrayList<Object>(((Tokens)($1.obj)).compositor);
		  ((Tokens)($$.obj)).isUniqueColumn = ((Tokens)($1.obj)).isUniqueColumn;
  		  ((Tokens)($$.obj)).columnRefTable = ((Tokens)($1.obj)).columnRefTable;
 		  ((Tokens)($$.obj)).columnRefField = ((Tokens)($1.obj)).columnRefField;
                }
                else {
		  ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
                }
              }
                  | Any_all_some  '(' Subquery ')' {
                    if(onlyText == 0) {
                    	if(!this.isFromClauseInnerSelect)
                    	   throw new ParserSilentException("InterQuery : Relational operation involving Subquery. Line : "+line+" Column : "+column);
                    }
                    else {
		       ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " (" + ((Tokens)($3.obj)).text + ")";
                    }
                  }
                  | '(' Subquery ')' {
                    if(onlyText == 0) {
                    	if(!this.isFromClauseInnerSelect)
                    	   throw new ParserSilentException("InterQuery : Relational operation involving Subquery. Line : "+line+" Column : "+column);
                    }
                    else {
		       ((Tokens)($$.obj)).text = "(" + ((Tokens)($2.obj)).text + ")";
                    }
                  }

                  ;

Scalar_exp : Scalar_term {
 	     if(onlyText == 0) {
		((Tokens)($$.obj)).typeSize = ((Tokens)($1.obj)).typeSize;
		((Tokens)($$.obj)).typePrecision = ((Tokens)($1.obj)).typePrecision;
		((Tokens)($$.obj)).typeLength = ((Tokens)($1.obj)).typeLength;
	        ((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
		((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
	        ((Tokens)($$.obj)).aggregationFunction=((Tokens)($1.obj)).aggregationFunction;
 		((Tokens)($$.obj)).compositorText = ((Tokens)($1.obj)).compositorText;
	        ((Tokens)($$.obj)).compositor= new ArrayList<Object>(((Tokens)($1.obj)).compositor);
	        ((Tokens)($$.obj)).isUniqueColumn = ((Tokens)($1.obj)).isUniqueColumn;
  		((Tokens)($$.obj)).columnRefTable = ((Tokens)($1.obj)).columnRefTable;
 		((Tokens)($$.obj)).columnRefField = ((Tokens)($1.obj)).columnRefField;
             }
             else {
		((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
             }
           }
           | Scalar_term '+' Scalar_exp {
	     if(onlyText == 0) {
	      ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " + " + ((Tokens)($3.obj)).text;
              getResultPlusType( (Tokens)($1.obj), (Tokens)($3.obj), (Tokens)($$.obj) );

	      if( (((Tokens)($$.obj)).aggregationFunction=((Tokens)($1.obj)).aggregationFunction) == Const.NONE)
	      	   ((Tokens)($$.obj)).aggregationFunction=((Tokens)($3.obj)).aggregationFunction;
 	      ((Tokens)($$.obj)).compositorText = ((Tokens)($1.obj)).compositorText +" + "+
                                                  ((Tokens)($3.obj)).compositorText;
              ((Tokens)($$.obj)).compositor = new ArrayList<Object>(addCompositor(Const.PLUS,(Tokens)$1.obj,(Tokens)$3.obj));
              ((Tokens)($$.obj)).isUniqueColumn = false;
  	      ((Tokens)($$.obj)).columnRefTable = null;
 	      ((Tokens)($$.obj)).columnRefField = null;
            }
            else {
 	      ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " + " + ((Tokens)($3.obj)).text;
            }
           }

           | Scalar_term '-' Scalar_exp {
	     if(onlyText == 0) {
	      ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " - " + ((Tokens)($3.obj)).text;
	      getResultMinusType( (Tokens)($1.obj), (Tokens)($3.obj), (Tokens)($$.obj) );
	      if( (((Tokens)($$.obj)).aggregationFunction=((Tokens)($1.obj)).aggregationFunction) == Const.NONE)
	      	   ((Tokens)($$.obj)).aggregationFunction=((Tokens)($3.obj)).aggregationFunction;
 	      ((Tokens)($$.obj)).compositorText = ((Tokens)($1.obj)).compositorText +" - "+
	                                          ((Tokens)($3.obj)).compositorText;
	      ((Tokens)($$.obj)).compositor = new ArrayList<Object>(addCompositor(Const.MINUS,(Tokens)$1.obj,(Tokens)$3.obj));
	      ((Tokens)($$.obj)).isUniqueColumn = false;
              ((Tokens)($$.obj)).columnRefTable = null;
   	      ((Tokens)($$.obj)).columnRefField = null;
	    }
	    else {
	      ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " - " + ((Tokens)($3.obj)).text;
	    }
	   }
           ;

Scalar_term : Scalar_concatenation_op {
	      if(onlyText == 0) {
		((Tokens)($$.obj)).typeSize = ((Tokens)($1.obj)).typeSize;
		((Tokens)($$.obj)).typePrecision = ((Tokens)($1.obj)).typePrecision;
		((Tokens)($$.obj)).typeLength = ((Tokens)($1.obj)).typeLength;
                ((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
		((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
		((Tokens)($$.obj)).aggregationFunction = ((Tokens)($1.obj)).aggregationFunction;
		((Tokens)($$.obj)).compositorText = ((Tokens)($1.obj)).compositorText;
		((Tokens)($$.obj)).compositor= new ArrayList<Object>(((Tokens)($1.obj)).compositor);
		((Tokens)($$.obj)).isUniqueColumn = ((Tokens)($1.obj)).isUniqueColumn;
  		((Tokens)($$.obj)).columnRefTable = ((Tokens)($1.obj)).columnRefTable;
 		((Tokens)($$.obj)).columnRefField = ((Tokens)($1.obj)).columnRefField;
              }
              else {
		((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
              }
            }
            | Scalar_concatenation_op '*' Scalar_term {
              if(onlyText == 0) {
                ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " * " +
                                          ((Tokens)($3.obj)).text;
                getResultMultiplicationType( (Tokens)($1.obj), (Tokens)($3.obj), (Tokens)($$.obj) );
                if( (((Tokens)($$.obj)).aggregationFunction=((Tokens)($1.obj)).aggregationFunction) == Const.NONE)
	      	     ((Tokens)($$.obj)).aggregationFunction=((Tokens)($3.obj)).aggregationFunction;
 		((Tokens)($$.obj)).compositorText = ((Tokens)($1.obj)).compositorText +" * "+
                                                    ((Tokens)($3.obj)).compositorText;
       		((Tokens)($$.obj)).compositor = new ArrayList<Object>(addCompositor(Const.MULTIPLICATION,(Tokens)$1.obj,(Tokens)$3.obj));
       		((Tokens)($$.obj)).isUniqueColumn = false;
  		((Tokens)($$.obj)).columnRefTable = null;
 		((Tokens)($$.obj)).columnRefField = null;
              }
              else {
                  ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " * " + ((Tokens)($3.obj)).text;
              }
            }

            | Scalar_concatenation_op '/' Scalar_term {
	      if(onlyText == 0) {
	        ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " / " + ((Tokens)($3.obj)).text;
	        getResultDivisionType( (Tokens)($1.obj), (Tokens)($3.obj), (Tokens)($$.obj) );
  	        if( (((Tokens)($$.obj)).aggregationFunction=((Tokens)($1.obj)).aggregationFunction) == Const.NONE)
	      	     ((Tokens)($$.obj)).aggregationFunction=((Tokens)($3.obj)).aggregationFunction;
 		((Tokens)($$.obj)).compositorText = ((Tokens)($1.obj)).compositorText +" / "+
                                                    ((Tokens)($3.obj)).compositorText;
                ((Tokens)($$.obj)).compositor = new ArrayList<Object>(addCompositor(Const.DIVISION,(Tokens)$1.obj,(Tokens)$3.obj));
                ((Tokens)($$.obj)).isUniqueColumn = false;
  		((Tokens)($$.obj)).columnRefTable = null;
 		((Tokens)($$.obj)).columnRefField = null;
	      }
	      else {
	        ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " / " + ((Tokens)($3.obj)).text;
	      }
	    }
            ;

Scalar_concatenation_op : Scalar_factor_unary_op {
		 	  if(onlyText == 0) {
		 	    ((Tokens)($$.obj)).typeSize = ((Tokens)($1.obj)).typeSize;
		 	    ((Tokens)($$.obj)).typePrecision = ((Tokens)($1.obj)).typePrecision;
		 	    ((Tokens)($$.obj)).typeLength = ((Tokens)($1.obj)).typeLength;
  			    ((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
			    ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
			    ((Tokens)($$.obj)).aggregationFunction=((Tokens)($1.obj)).aggregationFunction;
			    ((Tokens)($$.obj)).compositorText = ((Tokens)($1.obj)).compositorText;
		            ((Tokens)($$.obj)).compositor= new ArrayList<Object>(((Tokens)($1.obj)).compositor);
		            ((Tokens)($$.obj)).isUniqueColumn = ((Tokens)($1.obj)).isUniqueColumn;
  		            ((Tokens)($$.obj)).columnRefTable = ((Tokens)($1.obj)).columnRefTable;
 		            ((Tokens)($$.obj)).columnRefField = ((Tokens)($1.obj)).columnRefField;
			 }
			 else {
			    ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
			 }
			}
			| Scalar_factor_unary_op TK_VERTBAR Scalar_concatenation_op{
	         	  if(onlyText == 0) {
	        		((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text +
	        					  ((Tokens)($2.obj)).text +
	                    		                  ((Tokens)($3.obj)).text;
	        		getResultConcatenationType( (Tokens)($1.obj),(Tokens)($3.obj),(Tokens)($$.obj) );
  	        		if( (((Tokens)($$.obj)).aggregationFunction=((Tokens)($1.obj)).aggregationFunction) == Const.NONE)
	      			     ((Tokens)($$.obj)).aggregationFunction=((Tokens)($3.obj)).aggregationFunction;
 				((Tokens)($$.obj)).compositorText = ((Tokens)($1.obj)).compositorText +" || "+
                		                                    ((Tokens)($3.obj)).compositorText;
                		((Tokens)($$.obj)).compositor = new ArrayList<Object>(addCompositor(Const.CONCATENATION,(Tokens)$1.obj,(Tokens)$3.obj));
                		((Tokens)($$.obj)).isUniqueColumn = false;
  		                ((Tokens)($$.obj)).columnRefTable = null;
 		                ((Tokens)($$.obj)).columnRefField = null;
	    		  }
	    		  else {
	        		((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text +  ((Tokens)($2.obj)).text +
	                    		                  ((Tokens)($3.obj)).text;
	    		  }
	    		}
			;

Scalar_factor_unary_op : Scalar_factor {
		 	 if(onlyText == 0) {
		 	    ((Tokens)($$.obj)).typeSize = ((Tokens)($1.obj)).typeSize;
		 	    ((Tokens)($$.obj)).typePrecision = ((Tokens)($1.obj)).typePrecision;
		 	    ((Tokens)($$.obj)).typeLength = ((Tokens)($1.obj)).typeLength;
  			    ((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
			    ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
			    ((Tokens)($$.obj)).aggregationFunction=((Tokens)($1.obj)).aggregationFunction;
			    ((Tokens)($$.obj)).compositorText = ((Tokens)($1.obj)).compositorText;
		            ((Tokens)($$.obj)).compositor= new ArrayList<Object>(((Tokens)($1.obj)).compositor);
		            ((Tokens)($$.obj)).isUniqueColumn = ((Tokens)($1.obj)).isUniqueColumn;
		            ((Tokens)($$.obj)).columnRefTable = ((Tokens)($1.obj)).columnRefTable;
  		            ((Tokens)($$.obj)).columnRefField = ((Tokens)($1.obj)).columnRefField;
  		         }
  		         else {
			    ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
  		         }
  		       }
                       | '+' Scalar_factor {
                          if(onlyText == 0) {
                            ((Tokens)($$.obj)).text = "+" + ((Tokens)($2.obj)).text;
                            getResultSignType( (Tokens)($2.obj),(Tokens)($$.obj) );
                            ((Tokens)($$.obj)).aggregationFunction=((Tokens)($2.obj)).aggregationFunction;
			    ((Tokens)($$.obj)).compositorText="+"+((Tokens)($2.obj)).compositorText;
                            ((Tokens)($$.obj)).compositor = new ArrayList<Object>(addCompositor(Const.UNARY_PLUS,(Tokens)$2.obj));
                            ((Tokens)($$.obj)).isUniqueColumn = false;
  		            ((Tokens)($$.obj)).columnRefTable = null;
 		            ((Tokens)($$.obj)).columnRefField = null;
                         }
                         else {
                         }
                            ((Tokens)($$.obj)).text = "+" + ((Tokens)($2.obj)).text;
                       }

                       | '-' Scalar_factor {
                         if(onlyText == 0) {
                            ((Tokens)($$.obj)).text = "-" + ((Tokens)($2.obj)).text;
                            getResultSignType( (Tokens)($2.obj), (Tokens)($$.obj) );
                            ((Tokens)($$.obj)).aggregationFunction=((Tokens)($2.obj)).aggregationFunction;
			    ((Tokens)($$.obj)).compositorText = "-" + ((Tokens)($2.obj)).compositorText;
                            ((Tokens)($$.obj)).compositor = new ArrayList<Object>(addCompositor(Const.UNARY_MINUS,(Tokens)$2.obj));
                            ((Tokens)($$.obj)).isUniqueColumn = false;
  		            ((Tokens)($$.obj)).columnRefTable = null;
 		            ((Tokens)($$.obj)).columnRefField = null;
                         }
                         else {
                            ((Tokens)($$.obj)).text = "-" + ((Tokens)($2.obj)).text;
                         }
                       }
                       ;

Scalar_factor : Function_ref_selection {
		if(onlyText == 0) {
		   if(subqueryLevel==0 && isSelectExp==0 && isFunctionParameter==0){
		   	selectAggregationFunctionCount++;
                   }
		   ((Tokens)($$.obj)).typeSize = ((Tokens)($1.obj)).typeSize;
 		   ((Tokens)($$.obj)).typePrecision = ((Tokens)($1.obj)).typePrecision;
 		   ((Tokens)($$.obj)).typeLength = ((Tokens)($1.obj)).typeLength;
                   ((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
                   ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
                   ((Tokens)($$.obj)).aggregationFunction=((Tokens)($1.obj)).aggregationFunction;
		   ((Tokens)($$.obj)).compositorText = ((Tokens)($1.obj)).compositorText;
		   ((Tokens)($$.obj)).compositor= new ArrayList<Object>(((Tokens)($1.obj)).compositor);
		   ((Tokens)($$.obj)).isUniqueColumn = false;
		   ((Tokens)($$.obj)).columnRefTable = ((Tokens)($1.obj)).columnRefTable;
 		   ((Tokens)($$.obj)).columnRefField = ((Tokens)($1.obj)).columnRefField;
                }
                else {
                   ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
                }
              }

              | Column_ref {
                if(onlyText == 0) {
                 if(isFunctionParameter==0){
              	 	if( (columnsNotInGroupError = mustIncludeInGroupBy((Tokens)($1.obj), subqueryLevel)) )
              	 		columnsNotInGroup += " " + ((Tokens)($1.obj)).text + ",";
                 }
                 if(subqueryLevel==0 && isSelectExp==0 && isFunctionParameter==0){
                 	addColumnsList( ((Tokens)($1.obj)),qvpColumnsListTemp );
                 }
		 ((Tokens)($$.obj)).typeSize = ((Tokens)($1.obj)).typeSize;
		 ((Tokens)($$.obj)).typePrecision = ((Tokens)($1.obj)).typePrecision;
		 ((Tokens)($$.obj)).typeLength = ((Tokens)($1.obj)).typeLength;
                 ((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
                 ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
                 ((Tokens)($$.obj)).aggregationFunction=((Tokens)($1.obj)).aggregationFunction;
		 ((Tokens)($$.obj)).compositorText = ((Tokens)($1.obj)).compositorText;
		 ((Tokens)($$.obj)).compositor= new ArrayList<Object>(((Tokens)($1.obj)).compositor);
		 ((Tokens)($$.obj)).isUniqueColumn = true;
		 ((Tokens)($$.obj)).columnRefTable = ((Tokens)($1.obj)).columnRefTable;
 		 ((Tokens)($$.obj)).columnRefField = ((Tokens)($1.obj)).columnRefField;
               }
               else {
                  ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
               }
              }

              | '(' Scalar_condition ')' {
		if(onlyText == 0) {
		   ((Tokens)($$.obj)).type = ((Tokens)($2.obj)).type;
  		   ((Tokens)($$.obj)).typeSize = ((Tokens)($2.obj)).typeSize;
 		   ((Tokens)($$.obj)).typePrecision = ((Tokens)($2.obj)).typePrecision;
 		   ((Tokens)($$.obj)).typeLength = ((Tokens)($2.obj)).typeLength;
                   ((Tokens)($$.obj)).text="(" + ((Tokens)($2.obj)).text + ")";
                   ((Tokens)($$.obj)).aggregationFunction=((Tokens)($2.obj)).aggregationFunction;
		   ((Tokens)($$.obj)).compositorText = "("+((Tokens)($2.obj)).compositorText+")";
                   ((Tokens)($$.obj)).compositor= new ArrayList<Object>(((Tokens)($2.obj)).compositor);
                   ((Tokens)($$.obj)).isUniqueColumn = ((Tokens)($2.obj)).isUniqueColumn;
		   ((Tokens)($$.obj)).columnRefTable = ((Tokens)($2.obj)).columnRefTable;
 		   ((Tokens)($$.obj)).columnRefField = ((Tokens)($2.obj)).columnRefField;
                }
                else {
                   ((Tokens)($$.obj)).text="(" + ((Tokens)($2.obj)).text + ")";
                }
              }

              | Literal_selection {
		if(onlyText == 0) {
		   ((Tokens)($$.obj)).typeSize = ((Tokens)($1.obj)).typeSize;
		   ((Tokens)($$.obj)).typePrecision = ((Tokens)($1.obj)).typePrecision;
		   ((Tokens)($$.obj)).typeLength = ((Tokens)($1.obj)).typeLength;
                   ((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
		   ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
		   ((Tokens)($$.obj)).aggregationFunction = ((Tokens)($1.obj)).aggregationFunction;
		   ((Tokens)($$.obj)).compositorText = ((Tokens)($1.obj)).text;
		   ((Tokens)($$.obj)).compositor= new ArrayList<Object>(((Tokens)($1.obj)).compositor);
		   ((Tokens)($$.obj)).isUniqueColumn = false;
		   ((Tokens)($$.obj)).columnRefTable = ((Tokens)($1.obj)).columnRefTable;
 		   ((Tokens)($$.obj)).columnRefField = ((Tokens)($1.obj)).columnRefField;
	       }
	       else {
		   ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
	       }
	      }
	      | Case_expression {
	        if(onlyText == 0) {
	           if(subqueryLevel==0 && isSelectExp==0 && isFunctionParameter==0){
		   	addColumnsList( (Tokens)($1.obj),qvpColumnsListTemp );
                   }                   
		   ((Tokens)($$.obj)).typeSize = ((Tokens)($1.obj)).typeSize;
		   ((Tokens)($$.obj)).typePrecision = ((Tokens)($1.obj)).typePrecision;
		   ((Tokens)($$.obj)).typeLength = ((Tokens)($1.obj)).typeLength;
	           ((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
		   ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
	           ((Tokens)($$.obj)).aggregationFunction = ((Tokens)($1.obj)).aggregationFunction;
	           ((Tokens)($$.obj)).compositorText = ((Tokens)($1.obj)).compositorText;
		   ((Tokens)($$.obj)).compositor= new ArrayList<Object>(((Tokens)($1.obj)).compositor);
		   ((Tokens)($$.obj)).isUniqueColumn = false;
		   ((Tokens)($$.obj)).columnRefTable = null;
 		   ((Tokens)($$.obj)).columnRefField = null;
		   if(havingCase!=0 && !this.isFromClauseInnerSelect)
		   	throw(new ParserSilentException("InterQuery : Case in the Having clause. Line : "+line+" Column : "+column));
	        }
	        else {
		   ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
	        }
	      }
	      | Numeric_value_function {
	        if(onlyText == 0) {
	           if(subqueryLevel==0 && isSelectExp==0 && isFunctionParameter==0){
		   	addColumnsList( (Tokens)($1.obj),qvpColumnsListTemp );
                   }
		   ((Tokens)($$.obj)).typeSize = ((Tokens)($1.obj)).typeSize;
		   ((Tokens)($$.obj)).typePrecision = ((Tokens)($1.obj)).typePrecision;
		   ((Tokens)($$.obj)).typeLength = ((Tokens)($1.obj)).typeLength;
	           ((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
		   ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
	           ((Tokens)($$.obj)).aggregationFunction = ((Tokens)($1.obj)).aggregationFunction;
	           ((Tokens)($$.obj)).compositorText = ((Tokens)($1.obj)).compositorText;
		   ((Tokens)($$.obj)).compositor= new ArrayList<Object>(((Tokens)($1.obj)).compositor);
		   ((Tokens)($$.obj)).isUniqueColumn = false;
		   ((Tokens)($$.obj)).columnRefTable = null;
 		   ((Tokens)($$.obj)).columnRefField = null;
	        }
	        else {
		   ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
	        }
	      }
	      | String_value_function {
	        if(onlyText == 0) {
	           if(subqueryLevel==0 && isSelectExp==0 && isFunctionParameter==0){
		   	addColumnsList( (Tokens)($1.obj),qvpColumnsListTemp );
                   }
		   ((Tokens)($$.obj)).typeSize = ((Tokens)($1.obj)).typeSize;
		   ((Tokens)($$.obj)).typePrecision = ((Tokens)($1.obj)).typePrecision;
		   ((Tokens)($$.obj)).typeLength = ((Tokens)($1.obj)).typeLength;
	           ((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
		   ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
	           ((Tokens)($$.obj)).aggregationFunction = ((Tokens)($1.obj)).aggregationFunction;
	           ((Tokens)($$.obj)).compositorText = ((Tokens)($1.obj)).compositorText;
		   ((Tokens)($$.obj)).compositor= new ArrayList<Object>(((Tokens)($1.obj)).compositor);
		   ((Tokens)($$.obj)).isUniqueColumn = false;
		   ((Tokens)($$.obj)).columnRefTable = null;
 		   ((Tokens)($$.obj)).columnRefField = null;
	        }
	        else {
		   ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
	        }
	      }
	      
              ;

Scalar_between_predicate : Scalar_exp TK_BETWEEN Scalar_exp TK_AND Scalar_exp {
		   if(onlyText == 0) {
                     if( (((Tokens)($$.obj)).aggregationFunction=((Tokens)($1.obj)).aggregationFunction) == Const.NONE)
	      	     	  if( (((Tokens)($$.obj)).aggregationFunction=((Tokens)($3.obj)).aggregationFunction) == Const.NONE)
	      	  		 ((Tokens)($$.obj)).aggregationFunction=((Tokens)($5.obj)).aggregationFunction;

                     Tokens tokenTemp1 = new Tokens();
                     Tokens tokenTemp2 = new Tokens();

                     tokenTemp1.compositor = new ArrayList<Object>(addCompositor(Const.GREATER_EQUAL,(Tokens)$1.obj,(Tokens)$3.obj));
                     tokenTemp2.compositor = new ArrayList<Object>(addCompositor(Const.LESS_EQUAL,(Tokens)$1.obj,(Tokens)$5.obj));
                     ((Tokens)($$.obj)).compositor = new ArrayList<Object>(addCompositor(Const.AND,tokenTemp1,tokenTemp2));

                     ((Tokens)($$.obj)).compositorText = ((Tokens)($1.obj)).compositorText + " >= "+
                                                         ((Tokens)($3.obj)).compositorText + " and " +
                                                         ((Tokens)($1.obj)).compositorText + " <= " +
                                                         ((Tokens)($5.obj)).compositorText;
                     ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " " +  ((Tokens)($2.obj)).text + " " +
                                               ((Tokens)($3.obj)).text + " " +  ((Tokens)($4.obj)).text + " " +
                                               ((Tokens)($5.obj)).text;
                     getResultRelationalOpType((Tokens)($1.obj),(Tokens)($3.obj),(Tokens)($5.obj),(Tokens)($$.obj));
                     ((Tokens)($$.obj)).columnRefTable = null;
                     ((Tokens)($$.obj)).columnRefField = null;
                   }
                   else {
                     ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " " + ((Tokens)($2.obj)).text + " " +
                                               ((Tokens)($3.obj)).text + " " +  ((Tokens)($4.obj)).text + " " +
                                               ((Tokens)($5.obj)).text;
                   }
                 }

                  | Scalar_exp TK_NOT TK_BETWEEN Scalar_exp TK_AND Scalar_exp {

                   if(onlyText == 0) {
                     if( (((Tokens)($$.obj)).aggregationFunction=((Tokens)($1.obj)).aggregationFunction) == Const.NONE)
		     	  if( (((Tokens)($$.obj)).aggregationFunction=((Tokens)($4.obj)).aggregationFunction) == Const.NONE)
	      	  		((Tokens)($$.obj)).aggregationFunction=((Tokens)($6.obj)).aggregationFunction;

                     Tokens tokenTemp1 = new Tokens();
		     Tokens tokenTemp2 = new Tokens();

		     tokenTemp1.compositor = new ArrayList<Object>(addCompositor(Const.LESS,(Tokens)$1.obj,(Tokens)$4.obj));
		     tokenTemp2.compositor = new ArrayList<Object>(addCompositor(Const.GREATER,(Tokens)$1.obj,(Tokens)$6.obj));
		     ((Tokens)($$.obj)).compositor = new ArrayList<Object>(addCompositor(Const.OR,tokenTemp1,tokenTemp2));

                     ((Tokens)($$.obj)).compositorText = ((Tokens)($1.obj)).compositorText + " < "+
                                                         ((Tokens)($4.obj)).compositorText + " or " +
                                                         ((Tokens)($1.obj)).compositorText + " > " +
                                                         ((Tokens)($6.obj)).compositorText;
                   ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " " + ((Tokens)($2.obj)).text + " " +
                                             ((Tokens)($3.obj)).text + " " + ((Tokens)($4.obj)).text + " " +
                                             ((Tokens)($5.obj)).text + " " + ((Tokens)($6.obj)).text;
                     getResultRelationalOpType((Tokens)($1.obj),(Tokens)($3.obj),(Tokens)($5.obj),(Tokens)($$.obj));
                        ((Tokens)($$.obj)).columnRefTable = null;
                        ((Tokens)($$.obj)).columnRefField = null;
                   }
                   else {
                      ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " " + ((Tokens)($2.obj)).text + " " +
                                                ((Tokens)($3.obj)).text + " " + ((Tokens)($4.obj)).text + " " +
                                                ((Tokens)($5.obj)).text + " " + ((Tokens)($6.obj)).text;
                  }
                 }
                 ;

Scalar_like_predicate : Scalar_exp TK_LIKE Scalar_exp {
                     if(onlyText == 0) {
                       ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " " +  ((Tokens)($2.obj)).text + " " +
                                                 ((Tokens)($3.obj)).text;
	      	       getResultLikeType( (Tokens)($1.obj),(Tokens)($3.obj),(Tokens)($$.obj) );
                       if( (((Tokens)($$.obj)).aggregationFunction=((Tokens)($1.obj)).aggregationFunction) == Const.NONE)
	      	  		((Tokens)($$.obj)).aggregationFunction=((Tokens)($3.obj)).aggregationFunction;

                      ((Tokens)($$.obj)).compositorText = ((Tokens)($1.obj)).compositorText + " " +
                                                 	  ((Tokens)($2.obj)).text + " " +
                                                 	  ((Tokens)($3.obj)).compositorText;
                        ((Tokens)($$.obj)).columnRefTable = null;
                        ((Tokens)($$.obj)).columnRefField = null;
                     }
                     else {
                       ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " " + ((Tokens)($2.obj)).text + " " +
                                                 ((Tokens)($3.obj)).text;
                     }
                  }

               | Scalar_exp TK_LIKE Scalar_exp Search_escape {
                     if(onlyText == 0) {
                       ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " " + ((Tokens)($2.obj)).text + " " +
                                                 ((Tokens)($3.obj)).text + " " + ((Tokens)($4.obj)).text;
	      	       getResultLikeType( (Tokens)($1.obj),(Tokens)($3.obj),(Tokens)($$.obj) );
                       if( (((Tokens)($$.obj)).aggregationFunction=((Tokens)($1.obj)).aggregationFunction) == Const.NONE)
	      	  		((Tokens)($$.obj)).aggregationFunction=((Tokens)($3.obj)).aggregationFunction;

                       ((Tokens)($$.obj)).compositorText = ((Tokens)($1.obj)).compositorText + " " +
                                                 	   ((Tokens)($2.obj)).text + " " +
                                                 	   ((Tokens)($3.obj)).compositorText + " " +
                                                 	   ((Tokens)($4.obj)).compositorText;
                        ((Tokens)($$.obj)).columnRefTable = null;
                        ((Tokens)($$.obj)).columnRefField = null;
                    }
                    else {
                       ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " " + ((Tokens)($2.obj)).text + " " +
                                                 ((Tokens)($3.obj)).text + " " + ((Tokens)($4.obj)).text;
                    }
               }
               | Scalar_exp TK_NOT TK_LIKE Scalar_exp {
                    if(onlyText == 0) {
                       ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " " + ((Tokens)($2.obj)).text + " " +
                                                 ((Tokens)($3.obj)).text + " " + ((Tokens)($4.obj)).text;
	      	       getResultLikeType( (Tokens)($1.obj),(Tokens)($4.obj),(Tokens)($$.obj) );
                       if( (((Tokens)($$.obj)).aggregationFunction=((Tokens)($1.obj)).aggregationFunction) == Const.NONE)
	      	  		((Tokens)($$.obj)).aggregationFunction=((Tokens)($4.obj)).aggregationFunction;

                       ((Tokens)($$.obj)).compositorText = ((Tokens)($1.obj)).compositorText + " " +
                                                 	   ((Tokens)($2.obj)).text + " " +
                                                	   ((Tokens)($3.obj)).text + " " +
                                                	   ((Tokens)($4.obj)).compositorText;
                       ((Tokens)($$.obj)).columnRefTable = null;
                       ((Tokens)($$.obj)).columnRefField = null;
                    }
                    else {
                       ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " " + ((Tokens)($2.obj)).text + " " +
                                                 ((Tokens)($3.obj)).text + " " + ((Tokens)($4.obj)).text;
                    }
                 }
               | Scalar_exp TK_NOT TK_LIKE Scalar_exp Search_escape {
		    if(onlyText == 0) {
		       ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " " + ((Tokens)($2.obj)).text + " " +
		                                 ((Tokens)($3.obj)).text + " " + ((Tokens)($4.obj)).text + " " +
                                                 ((Tokens)($5.obj)).text;
	      	       getResultLikeType( (Tokens)($1.obj),(Tokens)($4.obj),(Tokens)($$.obj) );
                       if( (((Tokens)($$.obj)).aggregationFunction=((Tokens)($1.obj)).aggregationFunction) == Const.NONE)
	      	  		((Tokens)($$.obj)).aggregationFunction=((Tokens)($4.obj)).aggregationFunction;

		       ((Tokens)($$.obj)).compositorText = ((Tokens)($1.obj)).compositorText + " " +
		                                 	   ((Tokens)($2.obj)).text + " " +
		                                 	   ((Tokens)($3.obj)).text + " " +
                                                 	   ((Tokens)($4.obj)).compositorText + " " +
                                                 	   ((Tokens)($5.obj)).compositorText;
                       ((Tokens)($$.obj)).columnRefTable = null;
                       ((Tokens)($$.obj)).columnRefField = null;
                    }
                    else {
		       ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " " + ((Tokens)($2.obj)).text + " " +
		                                 ((Tokens)($3.obj)).text + " " + ((Tokens)($4.obj)).text + " " +
                                                 ((Tokens)($5.obj)).text;
                    }
                 }
               ;


/************************************************************************************************/
/**				          SCALAR IN PREDICATE   	                       **/
/************************************************************************************************/


Scalar_in_predicate : Scalar_exp TK_IN '(' Subquery_ini Selection Select_tail ')' {
		      if(onlyText == 0) {
			((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text+" in ("+((Tokens)($4.obj)).text + " " +
			                          ((Tokens)($5.obj)).text + ((Tokens)($6.obj)).text + ")";
		        if(((Tokens)($5.obj)).selectColumnCount>1)
		           yyerror("Subquery has too many columns : "+ new String(((Tokens)($$.obj)).text));
		        else {
		           if((((Tokens)($$.obj)).type=getResultInPredicateType(((Tokens)($1.obj)).type,((Tokens)($5.obj)).type))==Const.NONE)
		       	 	   yyerror("Type mismatch in the operation : "+ new String(((Tokens)($$.obj)).text));
		     	}
		     	((Tokens)($$.obj)).type = Const.BOOLEAN;
		        subqueryLevel--;
		     	isPartitionable = false;
		     	if(!this.isFromClauseInnerSelect) {
		     		if(havingCase==0)
		     			throw(new ParserSilentException("InterQuery : IN subquery in the Select clause. Line : "+line+" Column : "+ column));
		     		else
		     			throw(new ParserSilentException("InterQuery : IN subquery in the Having clause. Line : "+line+" Column : "+ column));
		     	}
		     }
		     else {
			((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text+" in ("+((Tokens)($4.obj)).text + " " +
						  ((Tokens)($5.obj)).text + ((Tokens)($6.obj)).text + ")";
		     }
		   }
		   | Scalar_exp TK_NOT TK_IN '(' Subquery_ini Selection Select_tail ')' {
		      if(onlyText == 0) {
		        ((Tokens)($$.obj)).isJoinPartitionable = false;
		        ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " not in (" +
		        			  ((Tokens)($5.obj)).text + " " +  ((Tokens)($6.obj)).text +
              				          ((Tokens)($7.obj)).text + ")";
		        if(((Tokens)($6.obj)).selectColumnCount>1)
		           yyerror("Subquery has too many columns : "+ new String(((Tokens)($$.obj)).text));
		        else {
		           if((((Tokens)($$.obj)).type=getResultInPredicateType(((Tokens)($1.obj)).type,((Tokens)($6.obj)).type))==Const.NONE)
		       	 	   yyerror("Type mismatch in the operation: "+ new String(((Tokens)($$.obj)).text));
		     	}
		     	((Tokens)($$.obj)).type = Const.BOOLEAN;
		        subqueryLevel--;
		     	isPartitionable = false;
		     	if(!this.isFromClauseInnerSelect) {
		     		if(havingCase==0)
		     		 	throw(new ParserSilentException("InterQuery : NOT IN subquery in the Select clause. Line : "+line+" Column : "+ column));
		     		else
		     		 	throw(new ParserSilentException("InterQuery : IN subquery in the Having clause. Line : "+line+" Column : "+ column));
		     	}
		     }
		     else {
		        ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " not in (" + ((Tokens)($5.obj)).text +
		        		          " " +  ((Tokens)($6.obj)).text + ((Tokens)($7.obj)).text + ")";
		     }
		   }
		   | Scalar_exp TK_IN '(' Scalar_in_value_list ')' {
		      if(onlyText == 0) {
		        ((Tokens)($$.obj)).isJoinPartitionable = false;
		        ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " in (" + ((Tokens)($4.obj)).text + ")";
		        if((((Tokens)($$.obj)).type=getResultInPredicateType(((Tokens)($1.obj)).type,((Tokens)($4.obj)).type))==Const.NONE)
		       		yyerror("Type mismatch in the operation : "+ new String(((Tokens)($$.obj)).text));
		        ((Tokens)($$.obj)).type = Const.BOOLEAN;
		     	isPartitionable = false;
		     }
		     else {
		        ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " in (" + ((Tokens)($4.obj)).text + ")";
		     }
		   }
		   | Scalar_exp TK_NOT TK_IN '(' Scalar_in_value_list ')' {
		      if(onlyText == 0) {
		        ((Tokens)($$.obj)).isJoinPartitionable = false;
		        ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " not in (" + ((Tokens)($5.obj)).text + ")";
		        if((((Tokens)($$.obj)).type=getResultInPredicateType(((Tokens)($1.obj)).type,((Tokens)($5.obj)).type))==Const.NONE)
		       		yyerror("Type mismatch in the operation : "+ new String(((Tokens)($$.obj)).text));

		        ((Tokens)($$.obj)).type = Const.BOOLEAN;
		     	isPartitionable = false;
		     }
		     else {
		        ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " not in (" + ((Tokens)($5.obj)).text + ")";
		     }
		   }
                   ;

Scalar_in_value_list : Scalar_condition {
		 if(onlyText == 0) {
		   ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
		   ((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
	        }
	        else {
		   ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
	        }
	      }
	      | Scalar_condition ',' Scalar_in_value_list {
		 if(onlyText == 0) {
		   ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + "," + ((Tokens)($3.obj)).text;
		   ((Tokens)($$.obj)).type = getResultInPredicateType( ((Tokens)($1.obj)).type ,
	                                                               ((Tokens)($3.obj)).type );
	         }
	         else {
		   ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + "," + ((Tokens)($3.obj)).text;
	         }
	      }
	      ;

/************************************************************************************************/
/**         			            LITERAL		                               **/
/************************************************************************************************/

Parameter_ref : Parameter Parameter_tail {
                   ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + ((Tokens)($2.obj)).text;
                }
              | Parameter { ((Tokens)($$.obj)).text=((Tokens)($1.obj)).text; }
              ;

Parameter_tail : TK_INDICATOR Parameter{
                    ((Tokens)($$.obj)).text=" "+((Tokens)($1.obj)).text+" "+((Tokens)($2.obj)).text;
                 }
               | Parameter {((Tokens)($$.obj)).text=((Tokens)($1.obj)).text;}
               ;

Parameter : ':' Name {((Tokens)($$.obj)).text = ":" + ((Tokens)($2.obj)).text;}
          ;

Name : TK_NAME {((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;}
     ;

Literal_selection : String {
		   if(onlyText == 0) {
		     ((Tokens)($$.obj)).typeSize = ((Tokens)($1.obj)).typeSize;
		     ((Tokens)($$.obj)).typePrecision = 0;
		     ((Tokens)($$.obj)).typeLength = ((Tokens)($1.obj)).typeLength;
                     ((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
		     ((Tokens)($$.obj)).aggregationFunction=((Tokens)($1.obj)).aggregationFunction;
                     ((Tokens)($$.obj)).text=((Tokens)($1.obj)).text;
                     if(subqueryLevel==0 && isSelectExp==0 && isFunctionParameter==0){
                     	((Tokens)($$.obj)).compositor.clear();
                     	((Tokens)($$.obj)).compositor.add(((Tokens)($1.obj)).text.substring(1,((Tokens)($1.obj)).text.length() - 1));
                     	((Tokens)($$.obj)).compositor.trimToSize();
                     }
		     ((Tokens)($$.obj)).columnRefTable = ((Tokens)($1.obj)).columnRefTable;
		     ((Tokens)($$.obj)).columnRefField = ((Tokens)($1.obj)).columnRefField;
                   }
                   else {
                     ((Tokens)($$.obj)).text=((Tokens)($1.obj)).text;
                   }
                  }
                  | Approxnum {
		   if(onlyText == 0) {
		     ((Tokens)($$.obj)).typeSize = ((Tokens)($1.obj)).typeSize;
		     ((Tokens)($$.obj)).typePrecision = ((Tokens)($1.obj)).typePrecision;
		     ((Tokens)($$.obj)).typeLength = ((Tokens)($1.obj)).typeLength;
                     ((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
		     ((Tokens)($$.obj)).aggregationFunction=((Tokens)($1.obj)).aggregationFunction;
                     ((Tokens)($$.obj)).text=((Tokens)($1.obj)).text;
                     if(subqueryLevel==0 && isSelectExp==0 && isFunctionParameter==0){
                     	((Tokens)($$.obj)).compositor.clear();
                     	((Tokens)($$.obj)).compositor.add(new Double(((Tokens)($1.obj)).text));
                     	((Tokens)($$.obj)).compositor.trimToSize();
                     }
		     ((Tokens)($$.obj)).columnRefTable = ((Tokens)($1.obj)).columnRefTable;
		     ((Tokens)($$.obj)).columnRefField = ((Tokens)($1.obj)).columnRefField;
                    }
                    else {
                     ((Tokens)($$.obj)).text=((Tokens)($1.obj)).text;
                    }
                  }
                  | Intnum {
		   if(onlyText == 0) {
		     ((Tokens)($$.obj)).typeSize = ((Tokens)($1.obj)).typeSize;
		     ((Tokens)($$.obj)).typePrecision = 0;
		     ((Tokens)($$.obj)).typeLength = ((Tokens)($1.obj)).typeLength;
                     ((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
		     ((Tokens)($$.obj)).aggregationFunction=((Tokens)($1.obj)).aggregationFunction;
                     ((Tokens)($$.obj)).text=((Tokens)($1.obj)).text;
                     if(subqueryLevel==0 && isSelectExp==0 && isFunctionParameter==0){
                     	((Tokens)($$.obj)).compositor.clear();
                     	((Tokens)($$.obj)).compositor.add(new Integer(((Tokens)($1.obj)).text));
                     	((Tokens)($$.obj)).compositor.trimToSize();
                     }
		     ((Tokens)($$.obj)).columnRefTable = ((Tokens)($1.obj)).columnRefTable;
		     ((Tokens)($$.obj)).columnRefField = ((Tokens)($1.obj)).columnRefField;
                   }
                   else {
                     ((Tokens)($$.obj)).text=((Tokens)($1.obj)).text;
                   }
                  }
                  | TK_DATE String {
                      if(onlyText == 0) {
                        ((Tokens)($$.obj)).text=((Tokens)($1.obj)).text + " " + ((Tokens)($2.obj)).text ;
                        ((Tokens)($$.obj)).type = Const.CONST_DATE;
		 	((Tokens)($$.obj)).typePrecision = 0;
		 	((Tokens)($$.obj)).typeLength = ((Tokens)($2.obj)).typeLength;
		        ((Tokens)($$.obj)).aggregationFunction=((Tokens)($2.obj)).aggregationFunction;
                        //if(subqueryLevel==0 && isSelectExp==0 && isFunctionParameter==0)
                        //verificacao do formato da data
                        SimpleDateFormat formato = new SimpleDateFormat();
			formato.applyPattern("yyyy-MM-dd");
			String dataConteudo=((Tokens)($2.obj)).text.substring(1,((Tokens)($2.obj)).text.length() - 1);
                        try {
		 		((Tokens)($$.obj)).typeSize = 10;
				Date data = new Date();
				data = formato.parse(dataConteudo);
				((Tokens)($$.obj)).compositor.clear();
				((Tokens)($$.obj)).compositor.add(data);
				((Tokens)($$.obj)).compositor.trimToSize();
		        }
		        catch (ParseException e1) {
				// TODO Auto-generated catch block
				yyerror("Invalid DATE type format : "+ new String(((Tokens)($$.obj)).text));
		        }
		       ((Tokens)($$.obj)).columnRefTable = ((Tokens)($1.obj)).columnRefTable;
		       ((Tokens)($$.obj)).columnRefField = ((Tokens)($1.obj)).columnRefField;
		     }
		     else {
                        ((Tokens)($$.obj)).text=((Tokens)($1.obj)).text + " " + ((Tokens)($2.obj)).text ;
		     }
		  }
                  | Interval{
                     if(onlyText == 0) {
                       ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
		       ((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
		       ((Tokens)($$.obj)).typeSize = ((Tokens)($1.obj)).typeSize;
		       ((Tokens)($$.obj)).typePrecision = ((Tokens)($1.obj)).typePrecision;
		       ((Tokens)($$.obj)).aggregationFunction=((Tokens)($1.obj)).aggregationFunction;
		       ((Tokens)($$.obj)).compositorText = ((Tokens)($1.obj)).text;
		       ((Tokens)($$.obj)).compositor= new ArrayList<Object>(((Tokens)($1.obj)).compositor);
		       ((Tokens)($$.obj)).columnRefTable = ((Tokens)($1.obj)).columnRefTable;
 		       ((Tokens)($$.obj)).columnRefField = ((Tokens)($1.obj)).columnRefField;
                    }
                    else {
                       ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
                    }
                  }
                  | Boolean {
                     if(onlyText == 0) {
                       ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
                       ((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
		       ((Tokens)($$.obj)).typeSize = ((Tokens)($1.obj)).typeSize;
		       ((Tokens)($$.obj)).typePrecision = ((Tokens)($1.obj)).typePrecision;
		       ((Tokens)($$.obj)).typeLength = ((Tokens)($1.obj)).typeLength;
                       ((Tokens)($$.obj)).aggregationFunction=((Tokens)($1.obj)).aggregationFunction;
                       ((Tokens)($$.obj)).compositorText = ((Tokens)($1.obj)).text;
		       ((Tokens)($$.obj)).compositor= new ArrayList<Object>(((Tokens)($1.obj)).compositor);
		       ((Tokens)($$.obj)).columnRefTable = ((Tokens)($1.obj)).columnRefTable;
 		       ((Tokens)($$.obj)).columnRefField = ((Tokens)($1.obj)).columnRefField;
                    }
                    else {
                       ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
                    }
                  }
      		  | Null {
      		     if(onlyText == 0) {
      		       ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
		       ((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
		       ((Tokens)($$.obj)).typeSize = ((Tokens)($1.obj)).typeSize;
		       ((Tokens)($$.obj)).typePrecision = ((Tokens)($1.obj)).typePrecision;
		       ((Tokens)($$.obj)).typeLength = ((Tokens)($1.obj)).typeLength;
      		       ((Tokens)($$.obj)).aggregationFunction = ((Tokens)($1.obj)).aggregationFunction;
                       ((Tokens)($$.obj)).compositorText = ((Tokens)($1.obj)).text;
		       ((Tokens)($$.obj)).compositor= new ArrayList<Object>(((Tokens)($1.obj)).compositor);
		       ((Tokens)($$.obj)).columnRefTable = ((Tokens)($1.obj)).columnRefTable;
 		       ((Tokens)($$.obj)).columnRefField = ((Tokens)($1.obj)).columnRefField;
      		    }
      		    else {
       		       ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
     		    }
      		  }
                  ;

Literal : String {
           if(onlyText == 0) {
             ((Tokens)($$.obj)).text=((Tokens)($1.obj)).text;
             ((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
	     ((Tokens)($$.obj)).aggregationFunction=((Tokens)($1.obj)).aggregationFunction;
	     ((Tokens)($$.obj)).columnRefTable = ((Tokens)($1.obj)).columnRefTable;
	     ((Tokens)($$.obj)).columnRefField = ((Tokens)($1.obj)).columnRefField;
          }
          else {
             ((Tokens)($$.obj)).text=((Tokens)($1.obj)).text;
          }
        }
        | Approxnum {
          if(onlyText == 0) {
             ((Tokens)($$.obj)).text=((Tokens)($1.obj)).text;
             ((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
             ((Tokens)($$.obj)).aggregationFunction = ((Tokens)($1.obj)).aggregationFunction;
	     ((Tokens)($$.obj)).columnRefTable = ((Tokens)($1.obj)).columnRefTable;
	     ((Tokens)($$.obj)).columnRefField = ((Tokens)($1.obj)).columnRefField;
          }
          else {
             ((Tokens)($$.obj)).text=((Tokens)($1.obj)).text;
          }
        }
        | Intnum {
          if(onlyText == 0) {
             ((Tokens)($$.obj)).text=((Tokens)($1.obj)).text;
             ((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
             ((Tokens)($$.obj)).aggregationFunction = ((Tokens)($1.obj)).aggregationFunction;
	     ((Tokens)($$.obj)).columnRefTable = ((Tokens)($1.obj)).columnRefTable;
	     ((Tokens)($$.obj)).columnRefField = ((Tokens)($1.obj)).columnRefField;
          }
          else {
             ((Tokens)($$.obj)).text=((Tokens)($1.obj)).text;
          }
        }
        | TK_DATE String {
          if(onlyText == 0) {
             ((Tokens)($$.obj)).text=((Tokens)($1.obj)).text + " " + ((Tokens)($2.obj)).text;
             ((Tokens)($$.obj)).type = Const.CONST_DATE;
             ((Tokens)($$.obj)).aggregationFunction = ((Tokens)($2.obj)).aggregationFunction;
	     ((Tokens)($$.obj)).columnRefTable = ((Tokens)($1.obj)).columnRefTable;
	     ((Tokens)($$.obj)).columnRefField = ((Tokens)($1.obj)).columnRefField;
             SimpleDateFormat formato = new SimpleDateFormat();
		formato.applyPattern("yyyy-MM-dd");
		String dataConteudo=((Tokens)($2.obj)).text.substring(1,((Tokens)($2.obj)).text.length() - 1);
             try {
		Date data = new Date();
		data = formato.parse(dataConteudo);
		((Tokens)($$.obj)).compositor.clear();
		((Tokens)($$.obj)).compositor.add(data);
		((Tokens)($$.obj)).compositor.trimToSize();
	     }
	     catch (ParseException e1) {
	     	// TODO Auto-generated catch block
	     	yyerror("Invalid DATE type format: "+ new String(((Tokens)($$.obj)).text));
	     }
          }
          else {
              ((Tokens)($$.obj)).text=((Tokens)($1.obj)).text + " " + ((Tokens)($2.obj)).text;
         }
        }
        | Interval{
          if(onlyText == 0) {
             ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
	     ((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
             ((Tokens)($$.obj)).aggregationFunction = ((Tokens)($1.obj)).aggregationFunction;
	     ((Tokens)($$.obj)).columnRefTable = ((Tokens)($1.obj)).columnRefTable;
	     ((Tokens)($$.obj)).columnRefField = ((Tokens)($1.obj)).columnRefField;
          }
          else {
             ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
          }
        }
        | Boolean{
          if(onlyText == 0) {
             ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
	     ((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
             ((Tokens)($$.obj)).aggregationFunction = ((Tokens)($1.obj)).aggregationFunction;
	     ((Tokens)($$.obj)).columnRefTable = ((Tokens)($1.obj)).columnRefTable;
	     ((Tokens)($$.obj)).columnRefField = ((Tokens)($1.obj)).columnRefField;
          }
          else {
             ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
          }
        }
        | Null {
          if(onlyText == 0) {
             ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
	     ((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
             ((Tokens)($$.obj)).aggregationFunction = ((Tokens)($1.obj)).aggregationFunction;
	     ((Tokens)($$.obj)).columnRefTable = ((Tokens)($1.obj)).columnRefTable;
	     ((Tokens)($$.obj)).columnRefField = ((Tokens)($1.obj)).columnRefField;
          }
          else {
             ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
          }
        }
        ;


String : TK_STRING {
         if(onlyText == 0) {
            ((Tokens)($$.obj)).text=((Tokens)($1.obj)).text;
            ((Tokens)($$.obj)).type = Const.CONST_STRING;
            ((Tokens)($$.obj)).typeSize = ((Tokens)($1.obj)).text.length()-2;
	    ((Tokens)($$.obj)).typePrecision = 0;
	    ((Tokens)($$.obj)).typeLength = ((Tokens)($1.obj)).text.length()-2;
            ((Tokens)($$.obj)).aggregationFunction = Const.NONE;
            ((Tokens)($$.obj)).columnRefTable = null;
	    ((Tokens)($$.obj)).columnRefField = null;
         }
         else {
            ((Tokens)($$.obj)).text=((Tokens)($1.obj)).text;
         }
       }
       ;

Approxnum : TK_APPROXNUM {
            if(onlyText == 0) {
             ((Tokens)($$.obj)).text=((Tokens)($1.obj)).text;
             ((Tokens)($$.obj)).type = Const.CONST_DOUBLE;
	     ((Tokens)($$.obj)).typeSize = 0;
	     ((Tokens)($$.obj)).typePrecision = 0;
             ((Tokens)($$.obj)).typeLength = ((Tokens)($1.obj)).text.length();
             ((Tokens)($$.obj)).aggregationFunction = Const.NONE;
             ((Tokens)($$.obj)).columnRefTable = null;
	     ((Tokens)($$.obj)).columnRefField = null;
            }
            else {
             ((Tokens)($$.obj)).text=((Tokens)($1.obj)).text;
            }
          }
          ;

Intnum : TK_INTNUM {
         if(onlyText == 0) {
            ((Tokens)($$.obj)).text=((Tokens)($1.obj)).text;
            ((Tokens)($$.obj)).type = Const.CONST_INTEGER;
	    ((Tokens)($$.obj)).typeSize = 0;
	    ((Tokens)($$.obj)).typePrecision = 0;
	    ((Tokens)($$.obj)).typeLength = ((Tokens)($1.obj)).text.length();
            ((Tokens)($$.obj)).aggregationFunction = Const.NONE;
            ((Tokens)($$.obj)).columnRefTable = null;
	    ((Tokens)($$.obj)).columnRefField = null;
         }
         else {
            ((Tokens)($$.obj)).text=((Tokens)($1.obj)).text;
         }
       }
       ;

Boolean : TK_TRUE {
          if(onlyText == 0) {
            ((Tokens)($$.obj)).text=((Tokens)($1.obj)).text;
            ((Tokens)($$.obj)).type = Const.CONST_BOOLEAN;
	    ((Tokens)($$.obj)).typeSize = 0;
	    ((Tokens)($$.obj)).typePrecision = 0;
	    ((Tokens)($$.obj)).typeLength = 0;
            ((Tokens)($$.obj)).aggregationFunction = Const.NONE;
            if(subqueryLevel==0 && isSelectExp==0 && isFunctionParameter==0){
	     	((Tokens)($$.obj)).compositor.clear();
	        ((Tokens)($$.obj)).compositor.add(new Boolean(true));
	        ((Tokens)($$.obj)).compositor.trimToSize();
	    }
	    ((Tokens)($$.obj)).columnRefTable = null;
	    ((Tokens)($$.obj)).columnRefField = null;
          }
          else {
            ((Tokens)($$.obj)).text=((Tokens)($1.obj)).text;
          }
        }
        | TK_FALSE {
          if(onlyText == 0) {
            ((Tokens)($$.obj)).text=((Tokens)($1.obj)).text;
            ((Tokens)($$.obj)).type = Const.CONST_BOOLEAN;
	    ((Tokens)($$.obj)).typeSize = 0;
	    ((Tokens)($$.obj)).typePrecision = 0;
	    ((Tokens)($$.obj)).typeLength = 0;
            ((Tokens)($$.obj)).aggregationFunction = Const.NONE;
            if(subqueryLevel==0 && isSelectExp==0 && isFunctionParameter==0){
	     	((Tokens)($$.obj)).compositor.clear();
	        ((Tokens)($$.obj)).compositor.add(new Boolean(false));
	        ((Tokens)($$.obj)).compositor.trimToSize();
	    }
	    ((Tokens)($$.obj)).columnRefTable = null;
	    ((Tokens)($$.obj)).columnRefField = null;
         }
         else {
            ((Tokens)($$.obj)).text=((Tokens)($1.obj)).text;
         }
       }
       ;

Null : TK_NULL {
       if(onlyText == 0) {
            ((Tokens)($$.obj)).text=((Tokens)($1.obj)).text;
            ((Tokens)($$.obj)).type = Const.CONST_NULL;
	    ((Tokens)($$.obj)).typeSize = 0;
	    ((Tokens)($$.obj)).typePrecision = 0;
	    ((Tokens)($$.obj)).typeLength = ((Tokens)($1.obj)).text.length();
            ((Tokens)($$.obj)).aggregationFunction = Const.NONE;
            ((Tokens)($$.obj)).columnRefTable = null;
	    ((Tokens)($$.obj)).columnRefField = null;
       }
       else {
            ((Tokens)($$.obj)).text=((Tokens)($1.obj)).text;
       }
     }
     ;

Interval : TK_INTERVAL1 {
           if(onlyText == 0) {
              ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text ;
              ((Tokens)($$.obj)).type = Const.CONST_INTEGER;
	      ((Tokens)($$.obj)).typeSize = 0;
	      ((Tokens)($$.obj)).typePrecision = 0;
	      ((Tokens)($$.obj)).typeLength = 0;
              ((Tokens)($$.obj)).aggregationFunction = Const.NONE;
              ((Tokens)($$.obj)).columnRefTable = null;
	      ((Tokens)($$.obj)).columnRefField = null;
           }
           else {
              ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text ;
           }
         }
           | TK_INTERVAL2 {
             if(onlyText == 0) {
              ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text ;
              ((Tokens)($$.obj)).type = Const.CONST_INTEGER;
	      ((Tokens)($$.obj)).typeSize = 0;
	      ((Tokens)($$.obj)).typePrecision = 0;
	      ((Tokens)($$.obj)).typeLength = 0;
              ((Tokens)($$.obj)).aggregationFunction = Const.NONE;
              ((Tokens)($$.obj)).columnRefTable = null;
	      ((Tokens)($$.obj)).columnRefField = null;
             }
             else {
              ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text ;
             }
           }
         ;
/************************************************************************************************/
/**				          FUNCTION REF 	                                       **/
/************************************************************************************************/


Function_ref_selection : Function_ini '(' Function_parameters ')' {
                       if(onlyText == 0) {
                         isFunctionParameter--;
                         if( ( ((Tokens)($1.obj)).text.toLowerCase() ).equals("avg") ){
                           ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + "(" + ((Tokens)($3.obj)).text + ")" ;

                           ((Tokens)($$.obj)).type = getResultAggregationFunctionType((Tokens)($3.obj),Const.AVG,(Tokens)($$.obj));
                           ((Tokens)($$.obj)).aggregationFunction = Const.AVG;
                           if(subqueryLevel==0 && isSelectExp==0 && isFunctionParameter==0){
                           	ArrayList<Object> compositorTemp =new ArrayList<Object>(0);
                           	String sumCompositor;

                           	((Tokens)($$.obj)).text="sum"+"("+((Tokens)($3.obj)).text+")";
                           	((Tokens)($$.obj)).aggregationFunction = Const.SUM;
                                ((Tokens)($$.obj)).type = getResultAggregationFunctionType( (Tokens)($3.obj),
                               				 	        	  	     Const.SUM,
                               				      	 	 		    (Tokens)($$.obj) );
                           	addColumnsList( (Tokens)($$.obj),qvpColumnsListTemp );
                           	sumCompositor = ((Tokens)($$.obj)).compositorText;
                           	compositorTemp.add(new Operator(4));
                           	compositorTemp.addAll(((Tokens)($$.obj)).compositor);
                           	((Tokens)($$.obj)).compositor.clear();
                           	((Tokens)($$.obj)).compositor.trimToSize();

                           	((Tokens)($$.obj)).text="count"+"("+((Tokens)($3.obj)).text+")";
                           	((Tokens)($$.obj)).aggregationFunction = Const.COUNT;
                                ((Tokens)($$.obj)).type = getResultAggregationFunctionType( (Tokens)($3.obj),
                               				 	        	  	     Const.COUNT,
                               				      	 	 		    (Tokens)($$.obj) );
                           	addColumnsList( ((Tokens)($$.obj)),qvpColumnsListTemp );
                           	compositorTemp.addAll(((Tokens)($$.obj)).compositor);
                           	((Tokens)($$.obj)).compositor = new ArrayList<Object>(compositorTemp);
                           	((Tokens)($$.obj)).compositor.trimToSize();

                           	((Tokens)($$.obj)).compositorText = sumCompositor + " / " +
                                                          ((Tokens)($$.obj)).compositorText;
                           	((Tokens)($$.obj)).text="avg(" + ((Tokens)($3.obj)).text + ")";
                           }
                          }
                          else {
                           ((Tokens)($$.obj)).text=((Tokens)($1.obj)).text + "(" + ((Tokens)($3.obj)).text + ")";
                           ((Tokens)($$.obj)).type = getResultAggregationFunctionType( (Tokens)($3.obj) ,
			              					  ((Tokens)($1.obj)).aggregationFunction,
			              					  (Tokens)($$.obj) );
                           ((Tokens)($$.obj)).aggregationFunction = ((Tokens)($1.obj)).aggregationFunction;

                           if(subqueryLevel==0 && isSelectExp==0 && isFunctionParameter==0){
                           	addColumnsList( ((Tokens)($$.obj)),qvpColumnsListTemp );
                           }
                          }
  		          ((Tokens)($$.obj)).columnRefTable = null;
 		          ((Tokens)($$.obj)).columnRefField = null;
                        }
                        else {
                           ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + "(" + ((Tokens)($3.obj)).text + ")" ;
                        }
                      }
                      ;

Function_ini : Function_name {
 	       if(onlyText == 0) {
 	          isFunctionParameter++;
 	          ((Tokens)($$.obj)).aggregationFunction = ((Tokens)($1.obj)).aggregationFunction;
		  ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
 	       }
 	       else {
		  ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
 	       }
 	     }
 	     ;
Function_name : TK_AVG {
                   ((Tokens)($$.obj)).aggregationFunction = Const.AVG;
		   ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
                }
              | TK_MIN {
                   ((Tokens)($$.obj)).aggregationFunction = Const.MIN;
                   ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
		}
              | TK_MAX {
                   ((Tokens)($$.obj)).aggregationFunction = Const.MAX;
                   ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
		}
              | TK_SUM {
                   ((Tokens)($$.obj)).aggregationFunction = Const.SUM;
                   ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
		}
              | TK_COUNT {
                   ((Tokens)($$.obj)).aggregationFunction = Const.COUNT;
                   ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
		}
              ;


Function_parameters : Wildcard { 
 		      if(onlyText == 0) {
 		         ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
			 ((Tokens)($$.obj)).typeSize = 0;
			 ((Tokens)($$.obj)).typePrecision = 0;
 		         ((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
  		         ((Tokens)($$.obj)).columnRefTable = ((Tokens)($1.obj)).columnRefTable;
 		         ((Tokens)($$.obj)).columnRefField = ((Tokens)($1.obj)).columnRefField;
 		      }
 		      else {
 		         ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
 		      }
 		    }
                    | Distinct_literal Column_ref {
                      if(onlyText == 0) {
                         ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " " + ((Tokens)($2.obj)).text;
			 ((Tokens)($$.obj)).typeSize = ((Tokens)($2.obj)).typeSize;
			 ((Tokens)($$.obj)).typePrecision = ((Tokens)($2.obj)).typePrecision;
                         ((Tokens)($$.obj)).type = ((Tokens)($2.obj)).type;
  		         ((Tokens)($$.obj)).columnRefTable = ((Tokens)($2.obj)).columnRefTable;
 		         ((Tokens)($$.obj)).columnRefField = ((Tokens)($2.obj)).columnRefField;
                      }
                      else {
                         ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " " + ((Tokens)($2.obj)).text;
                      }
                    }
                    | All_literal Function_Scalar_exp {
                      if(onlyText == 0) {
                         ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " " + ((Tokens)($2.obj)).text;
			 ((Tokens)($$.obj)).typeSize = ((Tokens)($2.obj)).typeSize;
			 ((Tokens)($$.obj)).typePrecision = ((Tokens)($2.obj)).typePrecision;
                         ((Tokens)($$.obj)).type = ((Tokens)($2.obj)).type;
  		         ((Tokens)($$.obj)).columnRefTable = ((Tokens)($2.obj)).columnRefTable;
 		         ((Tokens)($$.obj)).columnRefField = ((Tokens)($2.obj)).columnRefField;
                      }
                      else {
                         ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " " + ((Tokens)($2.obj)).text;
                      }
                    }
                    | Function_Scalar_exp {
                      if(onlyText == 0) {
                         ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
			 ((Tokens)($$.obj)).typeSize = ((Tokens)($1.obj)).typeSize;
			 ((Tokens)($$.obj)).typePrecision = ((Tokens)($1.obj)).typePrecision;
                         ((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
  		         ((Tokens)($$.obj)).columnRefTable = ((Tokens)($1.obj)).columnRefTable;
 		         ((Tokens)($$.obj)).columnRefField = ((Tokens)($1.obj)).columnRefField;
                      }
                      else {
                         ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
                      }
                    }
                    ;


Function_Scalar_exp : Function_Scalar_term {
   		      if(onlyText == 0) {
   			 ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
			 ((Tokens)($$.obj)).typeSize = ((Tokens)($1.obj)).typeSize;
			 ((Tokens)($$.obj)).typePrecision = ((Tokens)($1.obj)).typePrecision;
   		         ((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
  		         ((Tokens)($$.obj)).columnRefTable = ((Tokens)($1.obj)).columnRefTable;
 		         ((Tokens)($$.obj)).columnRefField = ((Tokens)($1.obj)).columnRefField;
   		      }
   		      else {
   			 ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
   		      }
   		    }
                    | Function_Scalar_term '+' Function_Scalar_exp {
		      if(onlyText == 0) {
		        ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " + " + ((Tokens)($3.obj)).text;
		        getResultPlusType( (Tokens)($1.obj), (Tokens)($3.obj), (Tokens)($$.obj) );
  		        ((Tokens)($$.obj)).columnRefTable = null;
 		        ((Tokens)($$.obj)).columnRefField = null;
		      }
		      else {
		        ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " + " + ((Tokens)($3.obj)).text;
		      }
		    }
		    | Function_Scalar_term '-' Function_Scalar_exp {
	              if(onlyText == 0) {
	                ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " - " + ((Tokens)($3.obj)).text;
	                getResultMinusType( (Tokens)($1.obj), (Tokens)($3.obj), (Tokens)($$.obj) );
  		        ((Tokens)($$.obj)).columnRefTable = null;
 		        ((Tokens)($$.obj)).columnRefField = null;
	              }
	              else {
	                ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " - " + ((Tokens)($3.obj)).text;
	              }
	            }
                    ;

Function_Scalar_term : Function_concatenation_op {
                       if(onlyText == 0) {
                          ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
			  ((Tokens)($$.obj)).typeSize = ((Tokens)($1.obj)).typeSize;
			  ((Tokens)($$.obj)).typePrecision = ((Tokens)($1.obj)).typePrecision;
                          ((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
  		          ((Tokens)($$.obj)).columnRefTable = ((Tokens)($1.obj)).columnRefTable;
 		          ((Tokens)($$.obj)).columnRefField = ((Tokens)($1.obj)).columnRefField;
                       }
                       else {
                          ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
                       }
                     }
                     | Function_concatenation_op '*' Function_Scalar_term {
                      if(onlyText == 0) {
                        ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " * " + ((Tokens)($3.obj)).text;
                        getResultMultiplicationType( (Tokens)($1.obj), (Tokens)($3.obj), (Tokens)($$.obj) );
  		        ((Tokens)($$.obj)).columnRefTable = null;
 		        ((Tokens)($$.obj)).columnRefField = null;
                      }
                      else {
                        ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " * " + ((Tokens)($3.obj)).text;
                      }
                     }
                     | Function_concatenation_op '/' Function_Scalar_term {
		      if(onlyText == 0) {
		        ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " / " + ((Tokens)($3.obj)).text;
		         getResultDivisionType( (Tokens)($1.obj), (Tokens)($3.obj), (Tokens)($$.obj) );
  		        ((Tokens)($$.obj)).columnRefTable = null;
 		        ((Tokens)($$.obj)).columnRefField = null;
                      }
                      else {
		        ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " / " + ((Tokens)($3.obj)).text;
                      }
                     }
                     ;

Function_concatenation_op : Function_Scalar_factor_unary_op {
			  if(onlyText == 0) {
			    ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
		 	    ((Tokens)($$.obj)).typeSize = ((Tokens)($1.obj)).typeSize;
		 	    ((Tokens)($$.obj)).typePrecision = ((Tokens)($1.obj)).typePrecision;
  			    ((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
  		            ((Tokens)($$.obj)).columnRefTable = ((Tokens)($1.obj)).columnRefTable;
 		            ((Tokens)($$.obj)).columnRefField = ((Tokens)($1.obj)).columnRefField;
			  }
			  else {
			    ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
			  }
			}
			| Function_Scalar_factor_unary_op TK_VERTBAR Function_concatenation_op{
	        	  if(onlyText == 0) {
	        		((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + ((Tokens)($2.obj)).text +
	                    		                  ((Tokens)($3.obj)).text;
	        		getResultConcatenationType( (Tokens)($1.obj),(Tokens)($3.obj),(Tokens)($$.obj) );
  		                ((Tokens)($$.obj)).columnRefTable = null;
 		                ((Tokens)($$.obj)).columnRefField = null;
	    		  }
	    		  else {
	        		((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + ((Tokens)($2.obj)).text +
	                    		                  ((Tokens)($3.obj)).text;
	    		  }
	    		}
			;

Function_Scalar_factor_unary_op : '+' Function_Scalar_factor {
                                  if(onlyText == 0) {
                                     ((Tokens)($$.obj)).text = "+ " + ((Tokens)($2.obj)).text;
                                     getResultSignType( (Tokens)($2.obj),(Tokens)($$.obj) );
  		        	     ((Tokens)($$.obj)).columnRefTable = null;
 		         	     ((Tokens)($$.obj)).columnRefField = null;
                                  }
                                  else {
                                     ((Tokens)($$.obj)).text = "+ " + ((Tokens)($2.obj)).text;
                                  }
                                }

                                | '-' Function_Scalar_factor {
                                  if(onlyText == 0) {
                                     ((Tokens)($$.obj)).text = "- " + ((Tokens)($2.obj)).text;
                                     getResultSignType( (Tokens)($2.obj), (Tokens)($$.obj) );
  			             ((Tokens)($$.obj)).columnRefTable = null;
 		 	             ((Tokens)($$.obj)).columnRefField = null;
                                  }
                                  else {
                                     ((Tokens)($$.obj)).text = "- " + ((Tokens)($2.obj)).text;
                                  }
                                }

                                | Function_Scalar_factor {
                                  if(onlyText == 0) {
                                     ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
			 	     ((Tokens)($$.obj)).typeSize = ((Tokens)($1.obj)).typeSize;
				     ((Tokens)($$.obj)).typePrecision = ((Tokens)($1.obj)).typePrecision;
                                     ((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
	   		             ((Tokens)($$.obj)).columnRefTable = ((Tokens)($1.obj)).columnRefTable;
	 		             ((Tokens)($$.obj)).columnRefField = ((Tokens)($1.obj)).columnRefField;
                                  }
                                  else {
                                     ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
                                  }
                                }
                                ;

Function_Scalar_factor : Column_ref {
                         if(onlyText == 0) {
                            ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
			    ((Tokens)($$.obj)).typeSize = ((Tokens)($1.obj)).typeSize;
			    ((Tokens)($$.obj)).typePrecision = ((Tokens)($1.obj)).typePrecision;
                            ((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
  		            ((Tokens)($$.obj)).columnRefTable = ((Tokens)($1.obj)).columnRefTable;
 		            ((Tokens)($$.obj)).columnRefField = ((Tokens)($1.obj)).columnRefField;
                         }
                         else {
                            ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
                         }
                       }
                       | '(' Function_Scalar_exp ')' {
                         if(onlyText == 0) {
                            ((Tokens)($$.obj)).text="(" + ((Tokens)($2.obj)).text + ")";
			    ((Tokens)($$.obj)).typeSize = ((Tokens)($2.obj)).typeSize;
			    ((Tokens)($$.obj)).typePrecision = ((Tokens)($2.obj)).typePrecision;
                            ((Tokens)($$.obj)).type = ((Tokens)($2.obj)).type;
  		            ((Tokens)($$.obj)).columnRefTable = ((Tokens)($2.obj)).columnRefTable;
 		            ((Tokens)($$.obj)).columnRefField = ((Tokens)($2.obj)).columnRefField;
                         }
                         else {
                            ((Tokens)($$.obj)).text="(" + ((Tokens)($2.obj)).text + ")";
                         }
                       }
                       | Literal {
                  	 if(onlyText == 0) {
                  	    ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
			    ((Tokens)($$.obj)).typeSize = ((Tokens)($1.obj)).typeSize;
			    ((Tokens)($$.obj)).typePrecision = ((Tokens)($1.obj)).typePrecision;
                  	    ((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
  		            ((Tokens)($$.obj)).columnRefTable = ((Tokens)($1.obj)).columnRefTable;
 		            ((Tokens)($$.obj)).columnRefField = ((Tokens)($1.obj)).columnRefField;
		         }
		         else {
                  	    ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
		         }
		       }
		       | Case_expression {
		       	 if(onlyText == 0) {
		       	    ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
		       	    ((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
			    ((Tokens)($$.obj)).typeSize = ((Tokens)($1.obj)).typeSize;
			    ((Tokens)($$.obj)).typePrecision = ((Tokens)($1.obj)).typePrecision;
		            ((Tokens)($$.obj)).columnRefTable = null;
		            ((Tokens)($$.obj)).columnRefField = null;
	       	         }
	       	         else {
		       	    ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
	       	         }
	       	       }
		       | Numeric_value_function {	       	       
		       	 if(onlyText == 0) {
		       	    ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
		       	    ((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
			    ((Tokens)($$.obj)).typeSize = ((Tokens)($1.obj)).typeSize;
			    ((Tokens)($$.obj)).typePrecision = ((Tokens)($1.obj)).typePrecision;
		            ((Tokens)($$.obj)).columnRefTable = null;
		            ((Tokens)($$.obj)).columnRefField = null;
	       	         }
	       	         else {
		       	    ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
	       	         }
	       	       }
		       | String_value_function {	       	       
		       	 if(onlyText == 0) {
		       	    ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
		       	    ((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
			    ((Tokens)($$.obj)).typeSize = ((Tokens)($1.obj)).typeSize;
			    ((Tokens)($$.obj)).typePrecision = ((Tokens)($1.obj)).typePrecision;
		            ((Tokens)($$.obj)).columnRefTable = null;
		            ((Tokens)($$.obj)).columnRefField = null;
	       	         }
	       	         else {
		       	    ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
	       	         }
	       	       }
 	       	       
                       ;

/************************************************************************************************/
/**				          NUMERIC VALUE FUNCTION                               **/
/************************************************************************************************/

Numeric_value_function : Extract_expression {
	        	    if(onlyText == 0) {
			       ((Tokens)($$.obj)).typeSize = ((Tokens)($1.obj)).typeSize;
			       ((Tokens)($$.obj)).typePrecision = ((Tokens)($1.obj)).typePrecision;
			       ((Tokens)($$.obj)).typeLength = ((Tokens)($1.obj)).typeLength;
	        	       ((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
			       ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
	        	       ((Tokens)($$.obj)).aggregationFunction = Const.NONE;
	        	       ((Tokens)($$.obj)).columnRefTable = null;
			       ((Tokens)($$.obj)).columnRefField = null;
			       ((Tokens)($$.obj)).isUniqueColumn = false;
	        	    }
	        	    else {
			       ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
	        	    }			    
		       }
     		       /*
     		       | position expression
     		       | length expression
     		       | cardinality expression
     		       | absolute value expression
     		       | modulus expression
     		       */
     		       ;
     		       
Extract_expression : TK_EXTRACT '(' Extract_field TK_FROM Extract_source ')' { 
			 ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + "( " + ((Tokens)($3.obj)).text + " " +
			    			   ((Tokens)($4.obj)).text + " "  + ((Tokens)($5.obj)).text + " )";	        	 
	        	 if(onlyText == 0) {
			    getResultExtractType( (Tokens)($5.obj),(Tokens)($$.obj) );
	        	 }
		   }
		   ;

Extract_field : Name {((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;}
	      ;

Extract_source : Function_Scalar_exp {
                   if(onlyText == 0) {
                      ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
		      ((Tokens)($$.obj)).typeSize = ((Tokens)($1.obj)).typeSize;
		      ((Tokens)($$.obj)).typePrecision = ((Tokens)($1.obj)).typePrecision;
                      ((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
                   }
                   else {
                      ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
                   }		     
 	       }
 	       ;

/************************************************************************************************/
/**				          STRING VALUE FUNCTION                                **/
/************************************************************************************************/

String_value_function : Character_substring_function {
	        	    if(onlyText == 0) {
			       ((Tokens)($$.obj)).typeSize = ((Tokens)($1.obj)).typeSize;
			       ((Tokens)($$.obj)).typePrecision = ((Tokens)($1.obj)).typePrecision;
			       ((Tokens)($$.obj)).typeLength = ((Tokens)($1.obj)).typeLength;
	        	       ((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
			       ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
	        	       ((Tokens)($$.obj)).aggregationFunction = Const.NONE;
	        	       ((Tokens)($$.obj)).columnRefTable = null;
			       ((Tokens)($$.obj)).columnRefField = null;
			       ((Tokens)($$.obj)).isUniqueColumn = false;
	        	    }
	        	    else {
			       ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
	        	    }			    
		       }
     		      /*
     		      |     <regular expression substring function>
                      |     <fold>
                      |     <form-of-use conversion>
                      |     <character translation>
                      |     <trim function>
                      |     <character overlay function>
                      |     <specific type method> 
		      */
		      ;
		      
Character_substring_function : TK_SUBSTRING '(' Function_Scalar_exp TK_FROM TK_INTNUM ')' {
			 	((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + "( " + ((Tokens)($3.obj)).text + " " +
			    			   	  ((Tokens)($4.obj)).text + " "  + ((Tokens)($5.obj)).text + " )";	        	 
	        	 	if(onlyText == 0) {
			 	   getResultSubstringType( (Tokens)($3.obj),(Tokens)($$.obj) );
	        	 	}			     
			      }
			     | TK_SUBSTRING '(' Function_Scalar_exp TK_FROM TK_INTNUM TK_FOR TK_INTNUM ')' {
			 	((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + "( " + ((Tokens)($3.obj)).text + " " +
			    			   	  ((Tokens)($4.obj)).text + " "  + ((Tokens)($5.obj)).text + " " +
			    			   	  ((Tokens)($6.obj)).text + " "  + ((Tokens)($7.obj)).text +" )";	        	 
	        	 	if(onlyText == 0) {
			 	   getResultSubstringType( (Tokens)($3.obj),(Tokens)($$.obj) );
	        	 	}			      
			      }
			     ;

/************************************************************************************************/
/**				                                       			       **/
/************************************************************************************************/

Distinct_literal : TK_DISTINCT {((Tokens)($$.obj)).text=((Tokens)($1.obj)).text;}
                 ;


Column_ref  : Name {
       	      if(onlyText == 0) {
       		 ((Tokens)($$.obj)).type = getColumnType( ((Tokens)($1.obj)).text ,subqueryLevel,(Tokens)($1.obj) );
       		 ((Tokens)($$.obj)).aggregationFunction = Const.NONE;
       		 ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
       		 ((Tokens)($$.obj)).columnRefTable = getColumnRefTable(((Tokens)($1.obj)).text,subqueryLevel);
       		 ((Tokens)($$.obj)).columnRefField = ((Tokens)($1.obj)).text;
       		 ((Tokens)($$.obj)).typeSize = ((Tokens)($1.obj)).typeSize;
       		 ((Tokens)($$.obj)).typePrecision = ((Tokens)($1.obj)).typePrecision;
       		 ((Tokens)($$.obj)).typeLength = ((Tokens)($1.obj)).typeLength;
              }
              else {
       		 ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
              }
            }
            | Name '.' Wildcard {
	      if(onlyText == 0) {
		 if(findTable(((Tokens)($1.obj)).text,subqueryLevel)==null)
		 	yyerror("Table " + new String(((Tokens)($1.obj)).text) + " does not referred in FROM clause");
		 else {
		 	((Tokens)($$.obj)).columnRefTable = getColumnRefTable( ((Tokens)($1.obj)).text,
		 	 						       ((Tokens)($3.obj)).text,
		 							       subqueryLevel );
                 	((Tokens)($$.obj)).columnRefField = ((Tokens)($3.obj)).text;
                 }
                 ((Tokens)($$.obj)).type = Const.INTEGER;
       		 ((Tokens)($$.obj)).aggregationFunction = Const.NONE;
       		 ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + "." + ((Tokens)($3.obj)).text;
 	         if(!this.isFromClauseInnerSelect)
 	      	   throw(new ParserSilentException("InterQuery : Wildcard. Line : "+line+" Column : " + column));
              }
              else {
        		 ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + "." + ((Tokens)($3.obj)).text;
             }
            }
            | Name '.' Name {
              if(onlyText == 0) {
                 if(findTable(((Tokens)($1.obj)).text,subqueryLevel)==null)
		 	yyerror("Table " + new String(((Tokens)($1.obj)).text) + " does not referred in FROM clause");
		 else {
		 	((Tokens)($$.obj)).columnRefTable = getColumnRefTable( ((Tokens)($1.obj)).text,
		 	 						       ((Tokens)($3.obj)).text,
		 							       subqueryLevel );
                 	((Tokens)($$.obj)).columnRefField = ((Tokens)($3.obj)).text;
                 }
       		 ((Tokens)($$.obj)).type = getColumnType(((Tokens)($1.obj)).text,((Tokens)($3.obj)).text,subqueryLevel,(Tokens)($$.obj) );
       		 ((Tokens)($$.obj)).aggregationFunction = Const.NONE;
       		 ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + "." + ((Tokens)($3.obj)).text;
              }
              else {
       		 ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + "." + ((Tokens)($3.obj)).text;
              }
            }
            ;

All_literal : TK_ALL {((Tokens)($$.obj)).text=((Tokens)($1.obj)).text;}
            ;


Into : TK_INTO Target_list {
          ((Tokens)($$.obj)).text = " " + ((Tokens)($1.obj)).text + " " + ((Tokens)($2.obj)).text;
       }
     ;

Any_all_some : TK_ANY {((Tokens)($$.obj)).text=((Tokens)($1.obj)).text;}
	     | TK_ALL {((Tokens)($$.obj)).text=((Tokens)($1.obj)).text;}
	     | TK_SOME {((Tokens)($$.obj)).text=((Tokens)($1.obj)).text;}
	     ;

Target_list : Target {((Tokens)($$.obj)).text=((Tokens)($1.obj)).text;}
            | Target ',' Target_list {
                 ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + "," + ((Tokens)($3.obj)).text;
              }
            ;

Target : Parameter_ref {((Tokens)($$.obj)).text=((Tokens)($1.obj)).text;}
       ;


/************************************************************************************************/
/**         			    Case Expression Clause    		                       **/
/************************************************************************************************/


Case_expression : Case_abbreviation {
		  if(onlyText == 0) {
		     ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
		     ((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
		     ((Tokens)($$.obj)).typeSize = ((Tokens)($1.obj)).typeSize;
		     ((Tokens)($$.obj)).typePrecision = ((Tokens)($1.obj)).typePrecision;
		     ((Tokens)($$.obj)).typeLength = ((Tokens)($1.obj)).typeLength;
		     ((Tokens)($$.obj)).aggregationFunction =((Tokens)($1.obj)).aggregationFunction;
		     isSelectExp--;
		  }
		  else {
		     ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
		  }
		}
                | Case_specification {
		  if(onlyText == 0) {
		     ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
		     ((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
		     ((Tokens)($$.obj)).typeSize = ((Tokens)($1.obj)).typeSize;
		     ((Tokens)($$.obj)).typePrecision = ((Tokens)($1.obj)).typePrecision;
		     ((Tokens)($$.obj)).typeLength = ((Tokens)($1.obj)).typeLength;
		     ((Tokens)($$.obj)).aggregationFunction =((Tokens)($1.obj)).aggregationFunction;
		     isSelectExp--;
		  }
		  else {
		     ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
		  }
		}
	        ;

Case_abbreviation : Nullif '(' Value_expression ',' Value_expression ')' {
		    if(onlyText == 0) {
		       ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + "(" + ((Tokens)($3.obj)).text + "," +
 	       				         ((Tokens)($5.obj)).text + ")";
		       getResultNullIfType( (Tokens)($3.obj), (Tokens)($5.obj), (Tokens)($$.obj) );
		       if( ((((Tokens)($5.obj)).aggregationFunction != Const.NONE) ||
		           (((Tokens)($3.obj)).aggregationFunction != Const.NONE)) && !this.isFromClauseInnerSelect ) {
		     	   throw(new ParserSilentException("InterQuery : Aggregation function in the NullIf clause. Line : "+line+" Column : "+column));
	      	       }
		    }
		    else {
		       ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + "(" + ((Tokens)($3.obj)).text + "," +
 	       				         ((Tokens)($5.obj)).text + ")";
		    }
		  }
                  | Coalesce '(' Coalesce_value_expression_list ')' {
		    if(onlyText == 0) {
		       ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + "(" + ((Tokens)($3.obj)).text + ")";
		       if( (((Tokens)($$.obj)).type = ((Tokens)($3.obj)).type) == Const.NONE )
		       		yyerror("Type mismatch in the operation : "+ new String(((Tokens)($$.obj)).text));
		       else {
		      	   ((Tokens)($$.obj)).typeSize = ((Tokens)($1.obj)).typeSize;
		    	   ((Tokens)($$.obj)).typePrecision = ((Tokens)($1.obj)).typePrecision;

		       }
		       if( (((Tokens)($3.obj)).aggregationFunction != Const.NONE) && !this.isFromClauseInnerSelect) {
		       		isPartitionable = false;
		     	        throw(new ParserSilentException("InterQuery : Aggregation function in the Coalesce clause. Line : "+line+" Column : "+column));
		       }
		       ((Tokens)($$.obj)).aggregationFunction = ((Tokens)($3.obj)).aggregationFunction;
		    }
		    else {
		       ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + "(" + ((Tokens)($3.obj)).text + ")";
		    }
		  }
                  ;

Nullif : TK_NULLIF {
         if(onlyText == 0) {
            isSelectExp++;
            ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
         }
         else {
            ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
         }
       }
       ;

Coalesce : TK_COALESCE {
           if(onlyText == 0) {
            isSelectExp++;
            ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
           }
           else {
            ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
           }
       }
       ;

Case : TK_CASE {
       if(onlyText == 0) {
	  isSelectExp++;
          ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
       }
       else {
          ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
       }
     }
     ;

Coalesce_value_expression_list : Value_expression {
		   	 if(onlyText == 0) {
		   	   ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
		           ((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
		      	   ((Tokens)($$.obj)).typeSize = ((Tokens)($1.obj)).typeSize;
		    	   ((Tokens)($$.obj)).typePrecision = ((Tokens)($1.obj)).typePrecision;
		           ((Tokens)($$.obj)).aggregationFunction =((Tokens)($1.obj)).aggregationFunction;
  		        }
  		        else {
 		   	   ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
 		        }
  		      }
	              | Value_expression ',' Coalesce_value_expression_list {
		   	if(onlyText == 0) {
		   	   ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + "," + ((Tokens)($3.obj)).text;
		           getResultCoalesceType( (Tokens)($1.obj), (Tokens)($3.obj), (Tokens)($$.obj));

		           if((((Tokens)($$.obj)).aggregationFunction=((Tokens)($1.obj)).aggregationFunction)==Const.NONE)
		           	((Tokens)($$.obj)).aggregationFunction = ((Tokens)($3.obj)).aggregationFunction;
		           ((Tokens)($$.obj)).aggregationFunction = ((Tokens)($1.obj)).aggregationFunction;
  		        }
  		        else {
		   	   ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + "," + ((Tokens)($3.obj)).text;
  		        }
  		      }
	              ;

Case_specification : Simple_case {
		     if(onlyText == 0) {
		  	((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
		  	((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
		      	((Tokens)($$.obj)).typeSize = ((Tokens)($1.obj)).typeSize;
		    	((Tokens)($$.obj)).typePrecision = ((Tokens)($1.obj)).typePrecision;
		     }
		     else {
		  	((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
		     }
		   }
  	           | Searched_case {
		     if(onlyText == 0) {
		  	((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
		  	((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
		      	((Tokens)($$.obj)).typeSize = ((Tokens)($1.obj)).typeSize;
		        ((Tokens)($$.obj)).typePrecision = ((Tokens)($1.obj)).typePrecision;
		     }
		     else {
		  	((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
		     }
		   }
  	           ;

Simple_case : Case  Value_expression Simple_when_clause_list TK_END {
	      if(onlyText == 0) {
	         ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " " + ((Tokens)($2.obj)).text + " " +
	         			   ((Tokens)($3.obj)).text + " " + ((Tokens)($4.obj)).text;
		 ((Tokens)($$.obj)).type = ((Tokens)($3.obj)).type;
		 ((Tokens)($$.obj)).caseWhenType = getCaseWhenType( ((Tokens)($2.obj)).caseWhenType ,
	                                                            ((Tokens)($3.obj)).caseWhenType );
		 if((((Tokens)($$.obj)).aggregationFunction=((Tokens)($2.obj)).aggregationFunction)==Const.NONE) {
		     ((Tokens)($$.obj)).aggregationFunction = ((Tokens)($3.obj)).aggregationFunction;
		 }
		 if( ((Tokens)($$.obj)).caseWhenType == Const.NONE )
		 	yyerror("Type mismatch in the WHEN clause : "+ new String(((Tokens)($$.obj)).text));

		 if( ((Tokens)($$.obj)).type == Const.NONE )
		 	yyerror("Invalid returned type : "+ new String(((Tokens)($$.obj)).text));

		 if( ((((Tokens)($2.obj)).aggregationFunction != Const.NONE) ||
		     (((Tokens)($3.obj)).aggregationFunction != Const.NONE)) && !this.isFromClauseInnerSelect  ) {
		 	isPartitionable = false;
 	     	        throw(new ParserSilentException("InterQuery : Aggregation function in the Case clause. Line : "+line+" Column : "+column));
	         }
	      }
	      else {
	         ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " " + ((Tokens)($2.obj)).text + " " +
	         			   ((Tokens)($3.obj)).text + " " + ((Tokens)($4.obj)).text;
	      }
	    }
 	    | Case  Value_expression Simple_when_clause_list Else_clause TK_END {
	      if(onlyText == 0) {
	         ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " " + ((Tokens)($2.obj)).text + " " +
	         			   ((Tokens)($3.obj)).text + " " + ((Tokens)($4.obj)).text + " " +
	         			   ((Tokens)($5.obj)).text;
		 getResultCaseType( (Tokens)($3.obj), (Tokens)($4.obj), (Tokens)($$.obj) );
		 ((Tokens)($$.obj)).caseWhenType = getCaseWhenType( ((Tokens)($2.obj)).caseWhenType ,
	                                                    	    ((Tokens)($3.obj)).caseWhenType );
		 if((((Tokens)($$.obj)).aggregationFunction=((Tokens)($2.obj)).aggregationFunction)==Const.NONE) {
		    if((((Tokens)($$.obj)).aggregationFunction=((Tokens)($3.obj)).aggregationFunction)==Const.NONE)
		        ((Tokens)($$.obj)).aggregationFunction=((Tokens)($4.obj)).aggregationFunction;
		 }
		 if( ((Tokens)($$.obj)).caseWhenType == Const.NONE )
		 	yyerror("Type mismatch in the WHEN clause : "+ new String(((Tokens)($$.obj)).text));

		 if( ((Tokens)($$.obj)).type == Const.NONE )
		 	yyerror("Invalid returned type : "+ new String(((Tokens)($$.obj)).text));

		 if( ((((Tokens)($2.obj)).aggregationFunction != Const.NONE) ||
		     (((Tokens)($3.obj)).aggregationFunction != Const.NONE) ||
		     (((Tokens)($4.obj)).aggregationFunction != Const.NONE)) && !this.isFromClauseInnerSelect ) {
		 	isPartitionable = false;
		     	throw(new ParserSilentException("InterQuery : Aggregation function in the Case clause. Line : "+line+" Column : "+column));
	         }
	      }
	      else {
	         ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " " + ((Tokens)($2.obj)).text + " " +
	         			   ((Tokens)($3.obj)).text + " " + ((Tokens)($4.obj)).text + " " +
	         			   ((Tokens)($5.obj)).text;
	      }
	    }
 	    ;

Simple_when_clause_list : Simple_when_clause {
			  if(onlyText == 0) {
			     ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
			     ((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
			     ((Tokens)($$.obj)).typeSize = ((Tokens)($1.obj)).typeSize;
			     ((Tokens)($$.obj)).typePrecision = ((Tokens)($1.obj)).typePrecision;
			     ((Tokens)($$.obj)).caseWhenType = ((Tokens)($1.obj)).caseWhenType;
			     ((Tokens)($$.obj)).aggregationFunction =((Tokens)($1.obj)).aggregationFunction;
			  }
			   else {
			     ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
			   }
			}
			| Simple_when_clause Simple_when_clause_list {
	  		  if(onlyText == 0) {
	  		     ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " " + ((Tokens)($2.obj)).text;
			     getResultCaseType( (Tokens)($1.obj), (Tokens)($2.obj), (Tokens)($$.obj) );
			     ((Tokens)($$.obj)).caseWhenType = getCaseWhenType( ((Tokens)($1.obj)).caseWhenType ,
	                                                                        ((Tokens)($2.obj)).caseWhenType );
			     if( (((Tokens)($$.obj)).aggregationFunction=((Tokens)($1.obj)).aggregationFunction) == Const.NONE)
	      	     		  ((Tokens)($$.obj)).aggregationFunction=((Tokens)($2.obj)).aggregationFunction;
			  }
			  else {
	  		     ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " " + ((Tokens)($2.obj)).text;
			  }
			}
			;

Simple_when_clause : TK_WHEN Value_expression TK_THEN Value_expression {
		     if(onlyText == 0) {
		        ((Tokens)($$.obj)).text = "when "+((Tokens)($2.obj)).text+" then "+((Tokens)($4.obj)).text;
 		        ((Tokens)($$.obj)).type = ((Tokens)($4.obj)).type;
			((Tokens)($$.obj)).typeSize = ((Tokens)($4.obj)).typeSize;
			((Tokens)($$.obj)).typePrecision = ((Tokens)($4.obj)).typePrecision;
 		        ((Tokens)($$.obj)).caseWhenType = ((Tokens)($2.obj)).caseWhenType;
 		        if( (((Tokens)($$.obj)).aggregationFunction=((Tokens)($2.obj)).aggregationFunction) == Const.NONE)
	      	             ((Tokens)($$.obj)).aggregationFunction=((Tokens)($4.obj)).aggregationFunction;
		     }
		     else {
		        ((Tokens)($$.obj)).text = "when "+((Tokens)($2.obj)).text+" then "+((Tokens)($4.obj)).text;
		     }
		   }
		   ;

Else_clause : TK_ELSE Value_expression {
	      if(onlyText == 0) {
		  ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " " + ((Tokens)($2.obj)).text;
		  ((Tokens)($$.obj)).type = ((Tokens)($2.obj)).type;
		  ((Tokens)($$.obj)).typeSize = ((Tokens)($2.obj)).typeSize;
		  ((Tokens)($$.obj)).typePrecision = ((Tokens)($2.obj)).typePrecision;
		  ((Tokens)($$.obj)).aggregationFunction = ((Tokens)($2.obj)).aggregationFunction;
	      }
	      else {
		  ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " " + ((Tokens)($2.obj)).text;
	      }
	    }
            ;

Searched_case : Case Searched_when_clause_list TK_END {
	       if(onlyText == 0) {
	         ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " " + ((Tokens)($2.obj)).text + " " +
	         			   ((Tokens)($3.obj)).text ;
		 ((Tokens)($$.obj)).type = ((Tokens)($2.obj)).type;
		 ((Tokens)($$.obj)).caseWhenType = ((Tokens)($2.obj)).caseWhenType;
		 ((Tokens)($$.obj)).aggregationFunction = ((Tokens)($2.obj)).aggregationFunction;
		 if( (((Tokens)($$.obj)).caseWhenType != Const.BOOLEAN) &&
		     (((Tokens)($$.obj)).caseWhenType != Const.CONST_BOOLEAN))
		 	yyerror("CASE/WHEN parameters must be BOOLEAN : "+ new String(((Tokens)($$.obj)).text));

		 if( ((Tokens)($$.obj)).type == Const.NONE )
		 	yyerror("Invalid returned type : "+ new String(((Tokens)($$.obj)).text));

		 if( (((Tokens)($2.obj)).aggregationFunction != Const.NONE) && !this.isFromClauseInnerSelect) {
		 	isPartitionable = false;
		     	throw(new ParserSilentException("InterQuery : Aggregation function in the Case clause. Line : "+line+" Column : "+column));
	         }
	      }
	      else {
	         ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " " + ((Tokens)($2.obj)).text + " " +
	         			   ((Tokens)($3.obj)).text ;
	      }
	    }

	      | Case Searched_when_clause_list Else_clause TK_END {
	        if(onlyText == 0) {
	         ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " " + ((Tokens)($2.obj)).text + " " +
	         			   ((Tokens)($3.obj)).text + " " + ((Tokens)($4.obj)).text ;
		 getResultCaseType( (Tokens)($2.obj), (Tokens)($3.obj), (Tokens)($$.obj) );
		 ((Tokens)($$.obj)).caseWhenType = ((Tokens)($2.obj)).caseWhenType;
		 if((((Tokens)($$.obj)).aggregationFunction=((Tokens)($2.obj)).aggregationFunction)==Const.NONE)
		     ((Tokens)($$.obj)).aggregationFunction=((Tokens)($3.obj)).aggregationFunction;

		 if( (((Tokens)($$.obj)).caseWhenType != Const.BOOLEAN) &&
		     (((Tokens)($$.obj)).caseWhenType != Const.CONST_BOOLEAN))
		 	yyerror("CASE/WHEN parameters must be BOOLEAN : "+ new String(((Tokens)($$.obj)).text));

		 if( ((Tokens)($$.obj)).type == Const.NONE )
		 	yyerror("Invalid returned type : "+ new String(((Tokens)($$.obj)).text));

		 if( ((((Tokens)($2.obj)).aggregationFunction != Const.NONE) ||
		     (((Tokens)($3.obj)).aggregationFunction != Const.NONE)) && !this.isFromClauseInnerSelect  ) {
		 	isPartitionable = false;
		     	throw(new ParserSilentException("InterQuery : Aggregation function in the Case clause. Line : "+line+" Column : "+column));
	         }
	       }
	       else {
	         ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " " + ((Tokens)($2.obj)).text + " " +
	         			   ((Tokens)($3.obj)).text + " " + ((Tokens)($4.obj)).text ;
	       }
	      }
	      ;

Searched_when_clause_list : Searched_when_clause {
			    if(onlyText == 0) {
			       ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
			       ((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
			       ((Tokens)($$.obj)).typeSize = ((Tokens)($1.obj)).typeSize;
			       ((Tokens)($$.obj)).typePrecision = ((Tokens)($1.obj)).typePrecision;
			       ((Tokens)($$.obj)).caseWhenType = ((Tokens)($1.obj)).caseWhenType;
			       ((Tokens)($$.obj)).aggregationFunction =((Tokens)($1.obj)).aggregationFunction;
			    }
			    else {
			       ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
			    }
			  }
			  | Searched_when_clause Searched_when_clause_list {
	  		    if(onlyText == 0) {
	  		       ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text+ " " + ((Tokens)($2.obj)).text;
			       getResultCaseType( (Tokens)($1.obj), (Tokens)($2.obj), (Tokens)($$.obj) );
			       ((Tokens)($$.obj)).caseWhenType = ((Tokens)($1.obj)).caseWhenType;
			       if( (((Tokens)($$.obj)).caseWhenType == Const.BOOLEAN) ||
			           (((Tokens)($$.obj)).caseWhenType == Const.CONST_BOOLEAN)  )
			            ((Tokens)($$.obj)).caseWhenType = ((Tokens)($2.obj)).caseWhenType;

			       if( (((Tokens)($$.obj)).aggregationFunction=((Tokens)($1.obj)).aggregationFunction) == Const.NONE)
	      	     		    ((Tokens)($$.obj)).aggregationFunction=((Tokens)($2.obj)).aggregationFunction;
			    }
			    else {
	  		       ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text+ " " + ((Tokens)($2.obj)).text;
			    }
			  }
		    	  ;

Searched_when_clause : TK_WHEN Scalar_condition TK_THEN Value_expression {
		       if(onlyText == 0) {
		          ((Tokens)($$.obj)).text = "when "+((Tokens)($2.obj)).text+" then "+((Tokens)($4.obj)).text;
 		          ((Tokens)($$.obj)).type = ((Tokens)($4.obj)).type;
			  ((Tokens)($$.obj)).typeSize = ((Tokens)($4.obj)).typeSize;
			  ((Tokens)($$.obj)).typePrecision = ((Tokens)($4.obj)).typePrecision;
 		          ((Tokens)($$.obj)).caseWhenType = ((Tokens)($2.obj)).type;
 		          if( (((Tokens)($$.obj)).aggregationFunction=((Tokens)($2.obj)).aggregationFunction) == Const.NONE)
	      	               ((Tokens)($$.obj)).aggregationFunction=((Tokens)($4.obj)).aggregationFunction;
		       }
		       else {
		          ((Tokens)($$.obj)).text = "when "+((Tokens)($2.obj)).text+" then "+((Tokens)($4.obj)).text;
		       }
		     }
		     ;

/*Cast_specification : TK_CAST '(' Cast_operand TK_AS Cast_target ')'
		   ;

Cast_operand : Value_expression
             | Implicitly_typed_value_specification
             ;

Cast_target : Domain_name
            | Data_type
            ;

*/

Value_expression : Scalar_condition {
		   if(onlyText == 0) {
		      ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
		      ((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
		      ((Tokens)($$.obj)).typeSize = ((Tokens)($1.obj)).typeSize;
		      ((Tokens)($$.obj)).typePrecision = ((Tokens)($1.obj)).typePrecision;
 		      ((Tokens)($$.obj)).caseWhenType = ((Tokens)($1.obj)).type;
		      ((Tokens)($$.obj)).aggregationFunction =((Tokens)($1.obj)).aggregationFunction;
		   }
		   else {
		      ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
		   }
		 }
		 ;


/************************************************************************************************/
/**         			    Table Expression Clause    		                       **/
/************************************************************************************************/


Table_exp : From_clause Opt_where_group_having_order {
            if(onlyText == 0) {
               ((Tokens)($$.obj)).compositorText ="\n"+((Tokens)($1.obj)).text +((Tokens)($2.obj)).compositorText;
               ((Tokens)($$.obj)).text = "\n" + new String(((Tokens)($1.obj)).text )+ ((Tokens)($2.obj)).text;
               ((Tokens)($$.obj)).isJoinPartitionable = ((Tokens)($2.obj)).isJoinPartitionable;
               ((Tokens)($$.obj)).isInPartitionable = ((Tokens)($2.obj)).isInPartitionable;
            }
            else {
               ((Tokens)($$.obj)).text ="\n" + new String(((Tokens)($1.obj)).text )+ ((Tokens)($2.obj)).text;
            }
          }
          | From_clause {
          if(onlyText == 0) {
            ((Tokens)($$.obj)).compositorText = "\n"+((Tokens)($1.obj)).text + "\nwhere 1#1 >= ? and 1#1 < ?";
            if(subqueryLevel==0 && isSelectExp==0 && isFunctionParameter==0 && !this.isFromClauseInnerSelect) {
               ((Tokens)($$.obj)).text = "\n" + ((Tokens)($1.obj)).text +"\nwhere " + findAlias(vpTable,0) + "." +
                                      vpAttribute + " >= ? and "+ findAlias(vpTable,0) + "." + vpAttribute + " < ?";
               qvpCount++;
            }
            else {
               ((Tokens)($$.obj)).text = "\n" + ((Tokens)($1.obj)).text;
               ((Tokens)($$.obj)).isJoinPartitionable = false;
               ((Tokens)($$.obj)).isInPartitionable = false;
            }
          }
          else {
               ((Tokens)($$.obj)).text = "\n" + ((Tokens)($1.obj)).text;
          }
        }
        ;

Opt_where_group_having_order : Where_clause Opt_group_having_order {
                               if(onlyText == 0) {
                                  ((Tokens)($$.obj)).compositorText = ((Tokens)($1.obj)).compositorText+((Tokens)($2.obj)).text;
                                  ((Tokens)($$.obj)).text =((Tokens)($1.obj)).text + ((Tokens)($2.obj)).text;
                                  ((Tokens)($$.obj)).isJoinPartitionable = ((Tokens)($1.obj)).isJoinPartitionable;
                                  ((Tokens)($$.obj)).isInPartitionable = ((Tokens)($1.obj)).isInPartitionable;
                               }
                               else {
                                  ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + ((Tokens)($2.obj)).text;
                               }
                             }
                             | Where_clause {
                               if(onlyText == 0) {
                                  ((Tokens)($$.obj)).compositorText = ((Tokens)($1.obj)).compositorText;
                                  ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
                                  ((Tokens)($$.obj)).isJoinPartitionable = ((Tokens)($1.obj)).isJoinPartitionable;
                                  ((Tokens)($$.obj)).isInPartitionable = ((Tokens)($1.obj)).isInPartitionable;
                               }
                               else {
                                  ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
                               }
                             }
                             | Opt_group_having_order {
		            if(onlyText == 0) {
		              ((Tokens)($$.obj)).compositorText ="\nwhere 1#1 >= ? and 1#1 < ?"+((Tokens)($1.obj)).text;
                               if(subqueryLevel==0 && isSelectExp==0 && isFunctionParameter==0 && !this.isFromClauseInnerSelect) {
                                  ((Tokens)($$.obj)).text = "\nwhere " +  findAlias(vpTable,0) + "." + vpAttribute +
                                  		            " >= ? and "+ findAlias(vpTable,0) + "." + vpAttribute +
                                  		            " < ?"+ ((Tokens)($1.obj)).text;
                               	  qvpCount++;
                               }
                               else {
                                  ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
                                  ((Tokens)($$.obj)).isJoinPartitionable = false;
                                  ((Tokens)($$.obj)).isInPartitionable = false;
                               }
                            }
                            else {
                                  ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
                            }
                           }
                           ;

Opt_group_having_order : Group_by_clause Opt_having_order {
                            ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + ((Tokens)($2.obj)).text; }
                       | Group_by_clause {((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;}
                       | Opt_having_order {((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;}
                       ;

Opt_having_order : Having_clause Order_by_clause_limit {
                      ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + ((Tokens)($2.obj)).text;
                   }
                 | Having_clause {
                      ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
                   }
                 | Order_by_clause_limit {((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;}
                 ;

Order_by_clause_limit : Order_by_clause Limit_clause {
		           ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + ((Tokens)($2.obj)).text;
		        }
		      | Order_by_clause {((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;}
		      | Limit_clause {((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;}
		      ;

Limit_clause : TK_LIMIT Intnum {
	     if(this.isFromClauseInnerSelect){
	           ((Tokens)($$.obj)).text = " " + ((Tokens)($1.obj)).text + " " + ((Tokens)($2.obj)).text;
	     }
	     else { 	       
 	       if(onlyText == 0) {
 		  if(subqueryLevel==0 && isSelectExp==0 && isFunctionParameter==0) {
	          	limitText = new String( " " + ((Tokens)($1.obj)).text + " " + ((Tokens)($2.obj)).text);
	          	((Tokens)($$.obj)).text = "";
	          }
	          else
	                ((Tokens)($$.obj)).text = " " + ((Tokens)($1.obj)).text + " " + ((Tokens)($2.obj)).text;
	       }
	       else {
	                ((Tokens)($$.obj)).text = " " + ((Tokens)($1.obj)).text + " " + ((Tokens)($2.obj)).text;
	       }
	     }
	    }
	    ;

/************************************************************************************************/
/**					Group by Clause    		                       **/
/************************************************************************************************/



Group_by_clause : TK_GROUP TK_BY Group_by_ref_list_Ini {
                     ((Tokens)($$.obj)).text = "\n"+ ((Tokens)($1.obj)).text + " " +
                                                     ((Tokens)($2.obj)).text + " " +
                                                     ((Tokens)($3.obj)).text;
                  }
                ;

Group_by_ref_list_Ini : Column_ref_list {
			if(onlyText == 0) {
			   if(subqueryLevel==0 && isSelectExp==0 && isFunctionParameter==0){
                           	groupByList = ((Tokens)($1.obj)).compositor.toArray();
                           	qvpColumnsListTemp = new ArrayList<Column>(qvpColumnsList);
                           }
                           ((Tokens)($$.obj)).text=((Tokens)($1.obj)).text;
                        }
                        else {
                           ((Tokens)($$.obj)).text=((Tokens)($1.obj)).text;
                        }
                   }
		   ;

Column_ref_list : Column_ref_pre {((Tokens)($$.obj)).text=((Tokens)($1.obj)).text;}
                | Column_ref_pre ',' Column_ref_list {
                     ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + "," + ((Tokens)($3.obj)).text;
                  }
                ;

Column_ref_pre : Group_by_Scalar_exp {
                 if(onlyText == 0) {
                     ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
                     if(subqueryLevel==0 && isSelectExp==0 && isFunctionParameter==0)
                         groupByTextList.add(new String(((Tokens)($1.obj)).compositorText) );
                 }
                 else {
                     ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
                 }
               }
               ;

Group_by_Scalar_exp : Group_by_Scalar_term {
		      if(onlyText == 0) {
		         ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
		         ((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
		         ((Tokens)($$.obj)).compositorText = ((Tokens)($1.obj)).compositorText;
		      }
		      else {
		         ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
		      }
		    }
                    | Group_by_Scalar_term '+' Group_by_Scalar_exp {
		      if(onlyText == 0) {
		        ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " + " + ((Tokens)($3.obj)).text;
		        ((Tokens)($$.obj)).compositorText = ((Tokens)($1.obj)).compositorText + " + " +
		                                  ((Tokens)($3.obj)).compositorText;
                        getResultPlusType( (Tokens)($1.obj), (Tokens)($3.obj), (Tokens)($$.obj) );

		      }
		      else {
		        ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " + " + ((Tokens)($3.obj)).text;
		      }
		    }
		    | Group_by_Scalar_term '-' Group_by_Scalar_exp {
	              if(onlyText == 0) {
	                ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " - " +
	                                          ((Tokens)($3.obj)).text;
	                ((Tokens)($$.obj)).compositorText = ((Tokens)($1.obj)).compositorText + " - " +
	                                          ((Tokens)($3.obj)).compositorText;
                        getResultMinusType( (Tokens)($1.obj), (Tokens)($3.obj), (Tokens)($$.obj) );
	              }
	              else {
	                ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " - " +
	                                          ((Tokens)($3.obj)).text;
	              }
	            }
                    ;

Group_by_Scalar_term : Group_by_concatenation_op {
                       if(onlyText == 0) {
                          ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
                          ((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
                          ((Tokens)($$.obj)).compositorText = ((Tokens)($1.obj)).compositorText;
                       }
                       else {
                          ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
                       }
                     }
                     | Group_by_concatenation_op '*' Group_by_Scalar_term {
                       if(onlyText == 0) {
                         ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " * " + ((Tokens)($3.obj)).text;
                         ((Tokens)($$.obj)).compositorText = ((Tokens)($1.obj)).compositorText + " * " +
                                                             ((Tokens)($3.obj)).compositorText;
                         getResultMultiplicationType( (Tokens)($1.obj), (Tokens)($3.obj), (Tokens)($$.obj) );
                       }
                       else {
                         ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " * " + ((Tokens)($3.obj)).text;
                       }
                     }
                     | Group_by_concatenation_op '/' Group_by_Scalar_term {
                       if(onlyText == 0) {
                         ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " / " + ((Tokens)($3.obj)).text;
                         ((Tokens)($$.obj)).compositorText = ((Tokens)($1.obj)).compositorText + " / " +
                                                   ((Tokens)($3.obj)).compositorText;
                         getResultDivisionType( (Tokens)($1.obj), (Tokens)($3.obj), (Tokens)($$.obj) );
                       }
                       else {
                         ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " / " + ((Tokens)($3.obj)).text;
                       }
                     }
                     ;

Group_by_concatenation_op : Group_by_Scalar_factor_unary_op {
 			    if(onlyText == 0) {
 			      ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
 			      ((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
			      ((Tokens)($$.obj)).compositorText = ((Tokens)($1.obj)).compositorText;
			    }
			    else {
 			      ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
			    }
			  }
			  | Group_by_Scalar_factor_unary_op TK_VERTBAR Group_by_concatenation_op{
	                    if(onlyText == 0) {
	        		((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + ((Tokens)($2.obj)).text +
	                    		                  ((Tokens)($3.obj)).text;
	        		getResultConcatenationType( (Tokens)($1.obj),(Tokens)($3.obj),(Tokens)($$.obj) );
				((Tokens)($$.obj)).compositorText = ((Tokens)($1.obj)).compositorText +" || "+
                		                                    ((Tokens)($3.obj)).compositorText;
	    		    }
	    		    else {
	        		((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text +  ((Tokens)($2.obj)).text +
	                    		                  ((Tokens)($3.obj)).text;
	    		    }
	    		  }
			  ;

Group_by_Scalar_factor_unary_op : '+' Group_by_Scalar_factor {
                                  if(onlyText == 0) {
                                     ((Tokens)($$.obj)).text = "+ " + ((Tokens)($2.obj)).text;
                                     ((Tokens)($$.obj)).compositorText = "+ " + ((Tokens)($2.obj)).compositorText;
 	                             getResultSignType( (Tokens)($2.obj), (Tokens)($$.obj) );
                                  }
                                  else {
                                     ((Tokens)($$.obj)).text = "+ " + ((Tokens)($2.obj)).text;
                                  }
                                }
                                | '-' Group_by_Scalar_factor {
                                  if(onlyText == 0) {
                                     ((Tokens)($$.obj)).text = "- " + ((Tokens)($2.obj)).text;
                                     ((Tokens)($$.obj)).compositorText = "- " + ((Tokens)($2.obj)).compositorText;
                            	     getResultSignType( (Tokens)($2.obj), (Tokens)($$.obj) );
                                  }
                                  else {
                                     ((Tokens)($$.obj)).text = "- " + ((Tokens)($2.obj)).text;
                                  }
                                }
                                | Group_by_Scalar_factor {
                                  if(onlyText == 0) {
                                     ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
                                     ((Tokens)($$.obj)).compositorText = ((Tokens)($1.obj)).compositorText;
                                     ((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
                                  }
                                  else {
                                     ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
                                  }
                                }
                                ;

Group_by_Scalar_factor : Column_ref {
			 if(onlyText == 0) {
			    ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
			    if(subqueryLevel==0 && isSelectExp==0 && isFunctionParameter==0){
                 	    	addColumnsList( ((Tokens)($1.obj)),qvpColumnsList );
                 	    }
			    ((Tokens)($$.obj)).compositorText = ((Tokens)($1.obj)).compositorText;
			    ((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
		         }
		         else {
			    ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
		         }
		       }
                       | '(' Group_by_Scalar_exp ')' {
                         if(onlyText == 0) {
                            ((Tokens)($$.obj)).text="(" + ((Tokens)($2.obj)).text + ")";
                            ((Tokens)($$.obj)).compositorText = "("+((Tokens)($2.obj)).compositorText+")";
                            ((Tokens)($$.obj)).type = ((Tokens)($2.obj)).type;
                         }
                         else {
                            ((Tokens)($$.obj)).text="(" + ((Tokens)($2.obj)).text + ")";
                         }
                       }
                       | Literal {
                  	 if(onlyText == 0) {
                  	    ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
                  	    ((Tokens)($$.obj)).compositorText = ((Tokens)($1.obj)).text;
		  	    ((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
		         }
		         else {
                  	    ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
		         }
		       }
                       ;


/************************************************************************************************/
/**					Order by Clause    		                       **/
/************************************************************************************************/

Order_by_clause : TK_ORDER TK_BY Ordering_spec_list {
  	       if(this.isFromClauseInnerSelect){
                    ((Tokens)($$.obj)).text = "\n"+ ((Tokens)($1.obj)).text + " " + ((Tokens)($2.obj)).text +
                                              " " + ((Tokens)($3.obj)).text;
                     orderByIndexList = orderByIndexListTemp.toArray(orderByIndexList);
  	       }
  	       else {
                  if(onlyText == 0) {
                     if(subqueryLevel==0 && isSelectExp==0 && isFunctionParameter==0){
                     	((Tokens)($$.obj)).text = "";
                     	qvpColumnsListTemp = new ArrayList<Column>(qvpColumnsList);
                     }
                     else ((Tokens)($$.obj)).text = "\n"+ ((Tokens)($1.obj)).text + " " + ((Tokens)($2.obj)).text +
                                                    " " + ((Tokens)($3.obj)).text;
                     orderByIndexList = orderByIndexListTemp.toArray(orderByIndexList);
                 }
                 else {
                    ((Tokens)($$.obj)).text = "\n"+ ((Tokens)($1.obj)).text + " " + ((Tokens)($2.obj)).text +
                                              " " + ((Tokens)($3.obj)).text;
                 }
               }
              }
 	      ;

Ordering_spec_list : Ordering_spec_ini {((Tokens)($$.obj)).text=((Tokens)($1.obj)).text;}
                   | Ordering_spec_ini ',' Ordering_spec_list {
                       ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + "," + ((Tokens)($3.obj)).text;
                     }
                   ;

Ordering_spec_ini : Ordering_spec {
                    if(onlyText == 0) {
                   	if(existsAggregationSelect.get(subqueryLevel)) {
		        	if(isFunctionParameter==0) {
		        		if(columnsNotInGroupError)
		   				yyerror("The column(s)" + columnsNotInGroup.substring(0,columnsNotInGroup.length() - 1) + " must appear in the GROUP BY clause" );
		   	        }
		   	}
		   	columnsNotInGroupError = false;
                  	columnsNotInGroup = "";
                       ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
		    }
		    else {
                       ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
		    }
		   }
		   ;

Ordering_spec : Intnum {
                if(onlyText == 0) {
                   if(new Integer(((Tokens)($1.obj)).text) > qColumnsList.size() )
                   	yyerror("The ORDER BY position " + new String(((Tokens)($1.obj)).text) + " does not exists in the SELECT clause list.");
                   if(subqueryLevel==0 && isSelectExp==0 && isFunctionParameter==0){
                   	orderByTextList.add( new String (((Tokens)($1.obj)).text) );
                   ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
                   }
                }
                else {
                   ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
                }
              }
              | Intnum Asc_desc {
                if(onlyText == 0) {
                   if(new Integer(((Tokens)($1.obj)).text) > qColumnsList.size() )
                   	yyerror("The ORDER BY position " + new String(((Tokens)($1.obj)).text) + " does not exists in the SELECT clause list.");
                   if(subqueryLevel==0 && isSelectExp==0 && isFunctionParameter==0){
                   	orderByTextList.add( new String (((Tokens)($1.obj)).text+((Tokens)($2.obj)).text) );
                   }
                   ((Tokens)($$.obj)).text=((Tokens)($1.obj)).text+((Tokens)($2.obj)).text;
                }
                else {
                   ((Tokens)($$.obj)).text=((Tokens)($1.obj)).text+((Tokens)($2.obj)).text;
                }
              }
              | Order_by_column_ref {
                if(onlyText == 0) {
                  if(subqueryLevel==0 && isSelectExp==0 && isFunctionParameter==0){
		   	orderByTextList.add( new String (((Tokens)($1.obj)).compositorText) );
                  }
                  ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
                }
                else {
                  ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
                }
              }
              | Order_by_column_ref Asc_desc {
                if(onlyText == 0) {
                   if(subqueryLevel==0 && isSelectExp==0 && isFunctionParameter==0){
                   	orderByTextList.add( new String(((Tokens)($1.obj)).compositorText + ((Tokens)($2.obj)).text) );
                   }
                   ((Tokens)($$.obj)).text=((Tokens)($1.obj)).text+((Tokens)($2.obj)).text;
                }
                else {
                   ((Tokens)($$.obj)).text=((Tokens)($1.obj)).text+((Tokens)($2.obj)).text;
                }
              }
              ;

Asc_desc : TK_ASC {
              ((Tokens)($$.obj)).text=" " + ((Tokens)($1.obj)).text;
              ((Tokens)($$.obj)).type = Const.ASC;
           }
         | TK_DESC {
              ((Tokens)($$.obj)).text=" " + ((Tokens)($1.obj)).text;
              ((Tokens)($$.obj)).type = Const.DESC;
           }
         ;


Order_by_column_ref : Name {
		if(onlyText == 0) {
		 ((Tokens)($$.obj)).aggregationFunction = Const.NONE;
       		 ((Tokens)($$.obj)).columnRefTable = getColumnRefTable(((Tokens)($1.obj)).text,subqueryLevel);
       		 ((Tokens)($$.obj)).columnRefField = ((Tokens)($1.obj)).text;
       		 ((Tokens)($$.obj)).typeSize = ((Tokens)($1.obj)).typeSize;
       		 ((Tokens)($$.obj)).typePrecision = ((Tokens)($1.obj)).typePrecision;

                 int selectAliasIndex;
                 if( ( selectAliasIndex = verifySelectAliasRef( ((Tokens)($1.obj)).text,subqueryLevel) ) != -1 ) {
                 	((Tokens)($$.obj)).compositorText = Const.COLUMN_PREFIX +  selectAliasIndex;
       		        ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
                 }
                 else {
       		 	((Tokens)($$.obj)).type = getColumnType( ((Tokens)($1.obj)).text ,subqueryLevel,(Tokens)($1.obj) );
       		 	if(subqueryLevel==0 && isSelectExp==0 && isFunctionParameter==0){
		   		addColumnsList( ((Tokens)($1.obj)),qvpColumnsList);
		   	}
	     		((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
	       		((Tokens)($$.obj)).compositorText = ((Tokens)($1.obj)).compositorText;
		   	if(isFunctionParameter==0) {
		   		if( (columnsNotInGroupError=mustIncludeInGroupBy( (Tokens)($$.obj), subqueryLevel)) )
              	 			columnsNotInGroup += " " + new String(((Tokens)($$.obj)).text + ",");
       		 	}
       		 }
               }
               else {
	     		((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
               }
            }

            | Name '.' Wildcard {
	      if(onlyText == 0) {
		 if(findTable(((Tokens)($1.obj)).text,subqueryLevel)==null)
		 	yyerror("Table " + new String(((Tokens)($1.obj)).text) + " does not referred in FROM clause");
		 else {
		 	((Tokens)($$.obj)).columnRefTable = getColumnRefTable( ((Tokens)($1.obj)).text,
		 	 						       ((Tokens)($3.obj)).text,
		 							       subqueryLevel );
                 	((Tokens)($$.obj)).columnRefField = ((Tokens)($3.obj)).text;
                 }
                 ((Tokens)($$.obj)).type = Const.INTEGER;
       		 ((Tokens)($$.obj)).aggregationFunction = Const.NONE;
       		 ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + "." + ((Tokens)($3.obj)).text;
       		 if(subqueryLevel==0 && isSelectExp==0 && isFunctionParameter==0){
		 	addColumnsList( ((Tokens)($$.obj)),qvpColumnsList);
		 }
		 if(isFunctionParameter==0) {
		 	if( (columnsNotInGroupError=mustIncludeInGroupBy( (Tokens)($$.obj), subqueryLevel)) )
              	 		columnsNotInGroup += " " + new String(((Tokens)($$.obj)).text + "," );
                 }
 	      	if(!this.isFromClauseInnerSelect)
 	         throw(new ParserSilentException("InterQuery : Wildcard. Line : "+line+" Column : "+column));

              }
              else {
       		 ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + "." + ((Tokens)($3.obj)).text;
              }
            }
            | Name '.' Name {
              if(onlyText == 0) {
                 if(findTable(((Tokens)($1.obj)).text,subqueryLevel)==null)
		 	yyerror("Table " + new String(((Tokens)($1.obj)).text) + " does not referred in FROM clause");
		 else {
		 	((Tokens)($$.obj)).columnRefTable = getColumnRefTable( ((Tokens)($1.obj)).text,
		 	 						       ((Tokens)($3.obj)).text,
		 							       subqueryLevel );
                 	((Tokens)($$.obj)).columnRefField = ((Tokens)($3.obj)).text;
                 }
       		 ((Tokens)($$.obj)).type = getColumnType(((Tokens)($1.obj)).text,((Tokens)($3.obj)).text,subqueryLevel,(Tokens)($$.obj) );
       		 ((Tokens)($$.obj)).aggregationFunction = Const.NONE;
       		 ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + "." + ((Tokens)($3.obj)).text;
       		 if(subqueryLevel==0 && isSelectExp==0 && isFunctionParameter==0){
		   	addColumnsList( ((Tokens)($$.obj)),qvpColumnsList);
		 }
		 if(isFunctionParameter==0) {
		 	if( (columnsNotInGroupError=mustIncludeInGroupBy( (Tokens)($$.obj), subqueryLevel)) )
              	 		columnsNotInGroup += " " + new String(((Tokens)($$.obj)).text + "," );
                 }
              }
              else {
       		 ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + "." + ((Tokens)($3.obj)).text;
              }
            }
            ;

/************************************************************************************************/
/**					From Clause    		                               **/
/************************************************************************************************/



From_clause : TK_FROM Table_ref_list {
                 ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " " + ((Tokens)($2.obj)).text;
              }
            ;

Table_ref_list : Table_ref {((Tokens)($$.obj)).text=((Tokens)($1.obj)).text;}
               | Table_ref ',' Table_ref_list {
               	    if(isFromClauseInnerSelect && (subqueryLevel == 0) && (fromSubqueryLevel == 0))
               	    	throw(new ParserSilentException("InterQuery : From subquery must be unique in the FROM clause. Line : "+line+" Column : "+column));
                    ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + "," + ((Tokens)($3.obj)).text;
                 }
               ;

Table_ref : Table {((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;}
          | '(' From_subquery ')' {
               ((Tokens)($$.obj)).text = "("  + ((Tokens)($2.obj)).text + ")";
            }
          | '(' From_subquery ')' Name {
               ((Tokens)($$.obj)).text = "(" + ((Tokens)($2.obj)).text + ") " + ((Tokens)($4.obj)).text;
            }
          | '(' From_subquery ')' TK_AS Name {
               ((Tokens)($$.obj)).text = "(" + ((Tokens)($2.obj)).text + ") as " + ((Tokens)($5.obj)).text;
            }
          | '(' From_subquery ')' '(' Name_list ')' {
               ((Tokens)($$.obj)).text = "("  + ((Tokens)($2.obj)).text + ")";
            }
          | '(' From_subquery ')' Name '(' Name_list ')' {
               ((Tokens)($$.obj)).text = "(" + ((Tokens)($2.obj)).text + ") " + ((Tokens)($4.obj)).text;
            }
          | '(' From_subquery ')' TK_AS Name '(' Name_list ')' {
               ((Tokens)($$.obj)).text = "(" + ((Tokens)($2.obj)).text + ") as " + ((Tokens)($5.obj)).text;
            }
          ;

Table : Q_table {
        if(onlyText == 0) {
           ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
        }
        else {
           ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
        }
      }
      | Q_table Name {
        if(onlyText == 0) {
           ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " " + ((Tokens)($2.obj)).text;
        }
        else {
           ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " " + ((Tokens)($2.obj)).text;
        }
      }
      | Q_table TK_AS Name {
        if(onlyText == 0) {
           ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " as " + ((Tokens)($3.obj)).text;
        }
        else {
           ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " as " + ((Tokens)($3.obj)).text;
        }
      }
      ;

Q_table : Name {((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;}
        | Name '.' Name {
             ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text +"."+ ((Tokens)($3.obj)).text;
          }
        | Name '.' Name '.' Name {
             ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + "." +  ((Tokens)($3.obj)).text + "." +
                                       ((Tokens)($5.obj)).text;
          }
        ;

From_subquery : From_subquery_ini Selection Select_tail {
		   ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + "." +  ((Tokens)($2.obj)).text + "." +
                                       	     ((Tokens)($3.obj)).text;
	           onlyText--;
	           fromSubqueryLevel--;
	      }
              ;

From_subquery_ini : TK_SELECT {
		    onlyText++;
		    if(fromSubqueryLevel>0)
		    	throw(new ParserSilentException("InterQuery : So far, only one FROM subquery level is treated. Line : "+line+" Column :"+column));
		    fromSubqueryLevel++;
               	    ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;               	    
               	    if(subqueryLevel>0)
               	    	throw(new ParserSilentException("InterQuery : So far, only outerquery FROM subquery is treated. Line : "+line+" Column :"+column));
               	  }
	          ;
	          
Name_list : Name {((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;}
	  | Name ',' Name_list {((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + ", " + ((Tokens)($3.obj)).text;}
	  ;
/************************************************************************************************/
/**					 Where Clause    		                       **/
/************************************************************************************************/


Where_clause :TK_WHERE Where_condition {
	 if(this.isFromClauseInnerSelect){
	      ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " " + ((Tokens)($2.obj)).text;
              if( (((Tokens)($2.obj)).type!=Const.BOOLEAN) && (((Tokens)($2.obj)).type!=Const.CONST_BOOLEAN) )
                    yyerror("The WHERE clause expression "+ new String(((Tokens)($2.obj)).text) + " must be BOOLEAN.");
	 }
	 else {
            if(onlyText == 0) {
              ((Tokens)($1.obj)).compositorText = "\nwhere 1#1 >= ? and 1#1 < ? and (" + ((Tokens)($2.obj)).text +")";
	      if(subqueryLevel==0 && isSelectExp==0 && isFunctionParameter==0) {
	         if(!((Tokens)($2.obj)).isInPartitionable){
              	 	((Tokens)($$.obj)).text ="\n" + ((Tokens)($1.obj)).text + " " + findAlias(vpTable,0) + "." +
              	 			 vpAttribute + " >= ? and "+ findAlias(vpTable,0) + "." + vpAttribute +
				                   " < ? and (" + ((Tokens)($2.obj)).text+")";

                 }
                 else {
                 	((Tokens)($$.obj)).text = "\n" + ((Tokens)($1.obj)).text + " " +findAlias(vpTable,0) + "." +
                 			 vpAttribute + " >= ? and "+ findAlias(vpTable,0) + "." + vpAttribute +
                 			 " < ? and " + subqueryVpa +" >= ? and " + subqueryVpa + " < ? and (" +
		 	   	          ((Tokens)($2.obj)).text+")";
                 	qvpCount++;
                 }
                 qvpCount++;
                 ((Tokens)($$.obj)).isJoinPartitionable = false;
              }
              else {
              	 if(((Tokens)($2.obj)).isJoinPartitionable){
              	 	((Tokens)($$.obj)).text = "\n" + ((Tokens)($1.obj)).text + " " + subqueryVpa +" >= ? and "+
              	 			          subqueryVpa + " < ? and (" + ((Tokens)($2.obj)).text+")";
		 	((Tokens)($1.obj)).compositorText = "\nwhere 1#1 >= ? and 1#1 < ? and (" + subqueryVpa +
              	 			" >= ? and " + subqueryVpa + " < ? and (" + ((Tokens)($2.obj)).text+"))";
		 	qvpCount++;
		 }
		 else {
                	((Tokens)($$.obj)).text ="\n" + ((Tokens)($1.obj)).text + " " +((Tokens)($2.obj)).text;
			if(!((Tokens)($2.obj)).isInPartitionable && !this.isFromClauseInnerSelect)
				throw(new ParserSilentException("InterQuery :No vpa join in the Subquery. Line : "+line+" Column :"+column));
                 }
                 ((Tokens)($$.obj)).isJoinPartitionable = ((Tokens)($2.obj)).isJoinPartitionable;
                 ((Tokens)($$.obj)).isInPartitionable = ((Tokens)($2.obj)).isInPartitionable;
              }
              if( (((Tokens)($2.obj)).type!=Const.BOOLEAN) && (((Tokens)($2.obj)).type!=Const.CONST_BOOLEAN) )
                    yyerror("The WHERE clause expression "+ new String(((Tokens)($2.obj)).text) + " must be BOOLEAN.");

            }
            else {
		     ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " " + ((Tokens)($2.obj)).text;
            }
          }
        }
        ;

Where_condition :  Where_term {
                   if(onlyText == 0) {
                     ((Tokens)($$.obj)).alias = ((Tokens)($1.obj)).alias;
		     ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
		     ((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
		     ((Tokens)($$.obj)).isJoinPartitionable = ((Tokens)($1.obj)).isJoinPartitionable;
		     ((Tokens)($$.obj)).isInPartitionable = ((Tokens)($1.obj)).isInPartitionable;
		     ((Tokens)($$.obj)).isUniqueColumn = ((Tokens)($1.obj)).isUniqueColumn;
		     ((Tokens)($$.obj)).columnRefTable = ((Tokens)($1.obj)).columnRefTable;
 		     ((Tokens)($$.obj)).columnRefField = ((Tokens)($1.obj)).columnRefField;
		   }
		   else {
		     ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
		   }
		 }
                 | Where_term TK_OR Where_condition {
                   if(onlyText == 0) {
                      ((Tokens)($$.obj)).text=((Tokens)($1.obj)).text + " " +  ((Tokens)($2.obj)).text + " " +
                                              ((Tokens)($3.obj)).text;
                      getResultLogicOpType( (Tokens)($1.obj), (Tokens)($3.obj), (Tokens)($$.obj) );
                      ((Tokens)($$.obj)).isJoinPartitionable = ((Tokens)($1.obj)).isJoinPartitionable &&
                       					       ((Tokens)($3.obj)).isJoinPartitionable;
                      ((Tokens)($$.obj)).isInPartitionable = ((Tokens)($1.obj)).isInPartitionable &&
                       					     ((Tokens)($3.obj)).isInPartitionable;
                      ((Tokens)($$.obj)).isUniqueColumn = false;
                      ((Tokens)($$.obj)).columnRefTable = null;
		      ((Tokens)($$.obj)).columnRefField = null;
                   }
                   else {
                       ((Tokens)($$.obj)).text=((Tokens)($1.obj)).text + " " +  ((Tokens)($2.obj)).text + " " +
                                               ((Tokens)($3.obj)).text;
                  }
                 }
                 ;

Where_term :  Where_Not_tag {
              if(onlyText == 0) {
                   ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
		   ((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
		   ((Tokens)($$.obj)).isJoinPartitionable = ((Tokens)($1.obj)).isJoinPartitionable;
		   ((Tokens)($$.obj)).isInPartitionable = ((Tokens)($1.obj)).isInPartitionable;
		   ((Tokens)($$.obj)).isUniqueColumn = ((Tokens)($1.obj)).isUniqueColumn;
		   ((Tokens)($$.obj)).columnRefTable = ((Tokens)($1.obj)).columnRefTable;
 		   ((Tokens)($$.obj)).columnRefField = ((Tokens)($1.obj)).columnRefField;
	      }
	      else {
                   ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
	      }
	    }
            | Where_Not_tag TK_AND Where_term {
              if(onlyText == 0) {
                ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " " + ((Tokens)($2.obj)).text + " " +
                                          ((Tokens)($3.obj)).text;
                getResultLogicOpType( (Tokens)($1.obj), (Tokens)($3.obj),(Tokens)($$.obj) );
                ((Tokens)($$.obj)).isJoinPartitionable = ((Tokens)($1.obj)).isJoinPartitionable ||
                       			  	         ((Tokens)($3.obj)).isJoinPartitionable;
                ((Tokens)($$.obj)).isInPartitionable = ((Tokens)($1.obj)).isInPartitionable ||
                       			  	       ((Tokens)($3.obj)).isInPartitionable;
                ((Tokens)($$.obj)).isUniqueColumn = false;
                ((Tokens)($$.obj)).columnRefTable = null;
		((Tokens)($$.obj)).columnRefField = null;
              }
              else {
                ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " " + ((Tokens)($2.obj)).text + " " +
                                          ((Tokens)($3.obj)).text;
             }
            }
            ;

Where_Not_tag : Where_Predicate {
                if(onlyText == 0) {
                   ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
		   ((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
		   ((Tokens)($$.obj)).isJoinPartitionable = ((Tokens)($1.obj)).isJoinPartitionable;
		   ((Tokens)($$.obj)).isInPartitionable = ((Tokens)($1.obj)).isInPartitionable;
		   ((Tokens)($$.obj)).isUniqueColumn = ((Tokens)($1.obj)).isUniqueColumn;
		   ((Tokens)($$.obj)).columnRefTable = ((Tokens)($1.obj)).columnRefTable;
 		   ((Tokens)($$.obj)).columnRefField = ((Tokens)($1.obj)).columnRefField;
	        }
	        else {
                   ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
	        }
	      }
              | TK_NOT Where_Predicate {
                if(onlyText == 0) {
                   ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " " + ((Tokens)($2.obj)).text;
                   getResultLogicOpType( (Tokens)($2.obj), (Tokens)($$.obj) );
                   ((Tokens)($$.obj)).isJoinPartitionable = false;
                   ((Tokens)($$.obj)).isInPartitionable = false;
                   ((Tokens)($$.obj)).isUniqueColumn = false;
                   ((Tokens)($$.obj)).columnRefTable = null;
		   ((Tokens)($$.obj)).columnRefField = null;
                }
                else {
                   ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " " + ((Tokens)($2.obj)).text;
                }
              }
              ;

Where_Predicate : Test_for_null {
                  if(onlyText == 0) {
                     ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
		     ((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
		     ((Tokens)($$.obj)).isJoinPartitionable = false;
		     ((Tokens)($$.obj)).isInPartitionable = false;
		     ((Tokens)($$.obj)).isUniqueColumn = false;
		     ((Tokens)($$.obj)).columnRefTable = ((Tokens)($1.obj)).columnRefTable;
 		     ((Tokens)($$.obj)).columnRefField = ((Tokens)($1.obj)).columnRefField;
		  }
		  else {
                     ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
		  }
		}
                | Existence_test {
		  if(onlyText == 0) {
		     ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
		     ((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
		     ((Tokens)($$.obj)).isJoinPartitionable = false;
		     ((Tokens)($$.obj)).isInPartitionable = false;
		     ((Tokens)($$.obj)).isUniqueColumn = false;
		     ((Tokens)($$.obj)).columnRefTable = ((Tokens)($1.obj)).columnRefTable;
 		     ((Tokens)($$.obj)).columnRefField = ((Tokens)($1.obj)).columnRefField;
		  }
		  else {
		     ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
		  }
		}
                | Where_relational_exp {
                  if(onlyText == 0) {
                     ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
		     ((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
		     ((Tokens)($$.obj)).isJoinPartitionable = ((Tokens)($1.obj)).isJoinPartitionable;
		     ((Tokens)($$.obj)).isInPartitionable = ((Tokens)($1.obj)).isInPartitionable;
		     ((Tokens)($$.obj)).isUniqueColumn = ((Tokens)($1.obj)).isUniqueColumn;
		     ((Tokens)($$.obj)).columnRefTable = ((Tokens)($1.obj)).columnRefTable;
 		     ((Tokens)($$.obj)).columnRefField = ((Tokens)($1.obj)).columnRefField;
		  }
		  else {
                     ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
		  }
		}
                ;

Where_relational_exp : Where_scalar_exp {
                       if(onlyText == 0) {
                  	 ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
		 	 ((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
		 	 ((Tokens)($$.obj)).isJoinPartitionable = false;
		 	 ((Tokens)($$.obj)).isInPartitionable = ((Tokens)($1.obj)).isInPartitionable;
		 	 ((Tokens)($$.obj)).isUniqueColumn = ((Tokens)($1.obj)).isUniqueColumn;
		  	 ((Tokens)($$.obj)).columnRefTable = ((Tokens)($1.obj)).columnRefTable;
 		  	 ((Tokens)($$.obj)).columnRefField = ((Tokens)($1.obj)).columnRefField;
		       }
		       else {
                  	 ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
		       }
		     }

                     | Where_scalar_exp Comparison Where_Relational_rvalue {
                     if(onlyText == 0) {
                       if( ((Tokens)($1.obj)).isJoinPartitionable && (subqueryLevel!=0) &&
                           ((Tokens)($3.obj)).isJoinPartitionable && ((Tokens)($2.obj)).text.equals("=") &&
                           ((Tokens)($1.obj)).columnRefTable != null &&
                           ((Tokens)($3.obj)).columnRefTable != null ){

                           if((((Tokens)($1.obj)).columnRefTable.tableLevel < ((Tokens)($3.obj)).columnRefTable.tableLevel) &&
                               (((Tokens)($3.obj)).columnRefTable.tableLevel == subqueryLevel) &&
                                isVpAttribute((Tokens)($3.obj)) && isVpAttribute((Tokens)($1.obj))  ) {

                               		((Tokens)($$.obj)).isJoinPartitionable = true;
                               		subqueryVpa = new String(((Tokens)($3.obj)).text);
                               }
                           else {
                           	if((((Tokens)($3.obj)).columnRefTable.tableLevel < ((Tokens)($1.obj)).columnRefTable.tableLevel) &&
                               	   (((Tokens)($1.obj)).columnRefTable.tableLevel == subqueryLevel) &&
                                    isVpAttribute((Tokens)($1.obj)) && isVpAttribute((Tokens)($3.obj)) ) {

                           		((Tokens)($$.obj)).isJoinPartitionable = true;
                           		subqueryVpa = new String(((Tokens)($1.obj)).text);
                           	}
                           	else ((Tokens)($$.obj)).isJoinPartitionable = false;
                           }
                       }
                       else ((Tokens)($$.obj)).isJoinPartitionable = false;

                       ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " " + ((Tokens)($2.obj)).text + " " +
                                                 ((Tokens)($3.obj)).text;
                       getResultRelationalOpType((Tokens)($1.obj),(Tokens)($3.obj),(Tokens)($$.obj));
                       ((Tokens)($$.obj)).isUniqueColumn = false;
                     }
                     else {
                       ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " " +  ((Tokens)($2.obj)).text + " " +
                                                 ((Tokens)($3.obj)).text;
                     }
                   }

                     | Where_Relational_predicate {
                       if(onlyText == 0) {
                          ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
		          ((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
		          ((Tokens)($$.obj)).isJoinPartitionable = ((Tokens)($1.obj)).isJoinPartitionable;
		          ((Tokens)($$.obj)).isInPartitionable = ((Tokens)($1.obj)).isInPartitionable;
		          ((Tokens)($$.obj)).isUniqueColumn = false;
		  	  ((Tokens)($$.obj)).columnRefTable = ((Tokens)($1.obj)).columnRefTable;
 		  	  ((Tokens)($$.obj)).columnRefField = ((Tokens)($1.obj)).columnRefField;
		       }
		       else {
                          ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
		       }
		     }
                     ;

Where_Relational_rvalue : Where_scalar_exp {
                     	  if(onlyText == 0) {
                     	     ((Tokens)($$.obj)).columnRefTable = ((Tokens)($1.obj)).columnRefTable;
		      	     ((Tokens)($$.obj)).columnRefField = ((Tokens)($1.obj)).columnRefField;
                     	     ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
		   	     ((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
		   	     ((Tokens)($$.obj)).isJoinPartitionable = ((Tokens)($1.obj)).isJoinPartitionable;
		   	     ((Tokens)($$.obj)).isInPartitionable = ((Tokens)($1.obj)).isInPartitionable;
		   	     ((Tokens)($$.obj)).isUniqueColumn = ((Tokens)($1.obj)).isUniqueColumn;
		   	  }
		   	  else {
                     	     ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
		   	  }
		   	}
                        | Any_all_some '(' Subquery ')' {
                          if(onlyText == 0 && !this.isFromClauseInnerSelect) {                          	
                          	   throw new ParserSilentException("InterQuery : Relational operation involving Subquery. Line : "+line+" Column : "+column);
                          }
                          else {
                     	   ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " (" + ((Tokens)($3.obj)).text + ")";
                          }
                        }
                        | '(' Subquery ')' {
                          if(onlyText == 0 && !this.isFromClauseInnerSelect) {                          	
                          	   throw new ParserSilentException("InterQuery : Relational operation involving Subquery. Line : "+line+" Column : "+column);
                           }
                           else {
                      	   ((Tokens)($$.obj)).text = "(" + ((Tokens)($2.obj)).text + ")";
                         }
                        }
                        ;

Where_scalar_exp : Where_scalar_term {
                   if(onlyText == 0) {
                      ((Tokens)($$.obj)).columnRefTable = ((Tokens)($1.obj)).columnRefTable;
		      ((Tokens)($$.obj)).columnRefField = ((Tokens)($1.obj)).columnRefField;
                      ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
		      ((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
		      ((Tokens)($$.obj)).isJoinPartitionable = ((Tokens)($1.obj)).isJoinPartitionable;
		      ((Tokens)($$.obj)).isInPartitionable = ((Tokens)($1.obj)).isInPartitionable;
		      ((Tokens)($$.obj)).isUniqueColumn = ((Tokens)($1.obj)).isUniqueColumn;
		   }
		   else {
                      ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
		   }
		 }
                 | Where_scalar_term '+' Where_scalar_exp {
	           if(onlyText == 0) {
	              ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " + " + ((Tokens)($3.obj)).text;
                      getResultPlusType( (Tokens)($1.obj), (Tokens)($3.obj), (Tokens)($$.obj) );
	              ((Tokens)($$.obj)).isJoinPartitionable = false;
	              ((Tokens)($$.obj)).isInPartitionable = false;
	              ((Tokens)($$.obj)).isUniqueColumn = false;
                      ((Tokens)($$.obj)).columnRefTable = null;
		      ((Tokens)($$.obj)).columnRefField = null;

	           }
	           else {
	              ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " + " + ((Tokens)($3.obj)).text;
	           }
	         }
                 | Where_scalar_term '-' Where_scalar_exp {
	           if(onlyText == 0) {
	              ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " - " + ((Tokens)($3.obj)).text;
                      getResultMinusType( (Tokens)($1.obj), (Tokens)($3.obj), (Tokens)($$.obj) );
	              ((Tokens)($$.obj)).isJoinPartitionable = false;
	              ((Tokens)($$.obj)).isInPartitionable = false;
	              ((Tokens)($$.obj)).isUniqueColumn = false;
	              ((Tokens)($$.obj)).columnRefTable = null;
		      ((Tokens)($$.obj)).columnRefField = null;
	           }
	           else {
	              ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " - " + ((Tokens)($3.obj)).text;
	           }
	         }
                 ;

Where_scalar_term : Where_concatenation_op {
		    if(onlyText == 0) {
		      ((Tokens)($$.obj)).columnRefTable = ((Tokens)($1.obj)).columnRefTable;
		      ((Tokens)($$.obj)).columnRefField = ((Tokens)($1.obj)).columnRefField;
		      ((Tokens)($$.obj)).isJoinPartitionable = ((Tokens)($1.obj)).isJoinPartitionable;
		      ((Tokens)($$.obj)).isInPartitionable = ((Tokens)($1.obj)).isInPartitionable;
                      ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
		      ((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
		      ((Tokens)($$.obj)).isUniqueColumn = ((Tokens)($1.obj)).isUniqueColumn;
		    }
		    else {
                      ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
		    }
		  }
                  | Where_concatenation_op '*' Where_scalar_term {
                    if(onlyText == 0) {
                       ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " * " + ((Tokens)($3.obj)).text;
                       getResultMultiplicationType( (Tokens)($1.obj), (Tokens)($3.obj), (Tokens)($$.obj) );
                       ((Tokens)($$.obj)).isJoinPartitionable = false;
                       ((Tokens)($$.obj)).isInPartitionable = false;
                       ((Tokens)($$.obj)).isUniqueColumn = false;
                       ((Tokens)($$.obj)).columnRefTable = null;
		       ((Tokens)($$.obj)).columnRefField = null;
                    }
                    else {
                       ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " * " + ((Tokens)($3.obj)).text;
                    }
                  }
                  | Where_concatenation_op '/' Where_scalar_term {
		    if(onlyText == 0) {
		       ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " / " + ((Tokens)($3.obj)).text;
                       getResultDivisionType( (Tokens)($1.obj), (Tokens)($3.obj), (Tokens)($$.obj) );
                       ((Tokens)($$.obj)).isJoinPartitionable = false;
                       ((Tokens)($$.obj)).isInPartitionable = false;
                       ((Tokens)($$.obj)).isUniqueColumn = false;
                       ((Tokens)($$.obj)).columnRefTable = null;
		       ((Tokens)($$.obj)).columnRefField = null;
                    }
                    else {
		       ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " / " + ((Tokens)($3.obj)).text;
                    }
                  }
                  ;

Where_concatenation_op : Where_scalar_factor_unary_op {
  		         if(onlyText == 0) {
  		            ((Tokens)($$.obj)).columnRefTable = ((Tokens)($1.obj)).columnRefTable;
 		            ((Tokens)($$.obj)).columnRefField = ((Tokens)($1.obj)).columnRefField;
			    ((Tokens)($$.obj)).isJoinPartitionable = ((Tokens)($1.obj)).isJoinPartitionable;
			    ((Tokens)($$.obj)).isInPartitionable = ((Tokens)($1.obj)).isInPartitionable;
 			    ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
 			    ((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
		            ((Tokens)($$.obj)).isUniqueColumn = ((Tokens)($1.obj)).isUniqueColumn;
			 }
			 else {
 			    ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
			 }
			}
			| Where_scalar_factor_unary_op TK_VERTBAR Where_concatenation_op{
	                  if(onlyText == 0) {
	        		((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text +  ((Tokens)($2.obj)).text +
	                    		                  ((Tokens)($3.obj)).text;
	        		getResultConcatenationType( (Tokens)($1.obj),(Tokens)($3.obj),(Tokens)($$.obj) );
                		((Tokens)($$.obj)).isJoinPartitionable = false;
                		((Tokens)($$.obj)).isInPartitionable = false;
                		((Tokens)($$.obj)).isUniqueColumn = false;
  		                ((Tokens)($$.obj)).columnRefTable = null;
 		                ((Tokens)($$.obj)).columnRefField = null;
	    		  }
	    		  else {
	        		((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + ((Tokens)($2.obj)).text +
	                    		                  ((Tokens)($3.obj)).text;
	    		  }
	    		}
			;

Where_scalar_factor_unary_op : Where_scalar_factor {
		  	       if(onlyText == 0) {
		  		 ((Tokens)($$.obj)).columnRefTable = ((Tokens)($1.obj)).columnRefTable;
		  	 	 ((Tokens)($$.obj)).columnRefField = ((Tokens)($1.obj)).columnRefField;
		  		 ((Tokens)($$.obj)).isJoinPartitionable = ((Tokens)($1.obj)).isJoinPartitionable;
		  		 ((Tokens)($$.obj)).isInPartitionable = ((Tokens)($1.obj)).isInPartitionable;
                         	 ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
		   		 ((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
		   		 ((Tokens)($$.obj)).isUniqueColumn = ((Tokens)($1.obj)).isUniqueColumn;
		   	       }
		   	       else {
                         	 ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
		   	       }
		   	     }
                             | '-' Where_scalar_factor {
                               if(onlyText == 0) {
                                  ((Tokens)($$.obj)).text = "-" + ((Tokens)($2.obj)).text;
 	                          getResultSignType( (Tokens)($2.obj), (Tokens)($$.obj) );
                                  ((Tokens)($$.obj)).isJoinPartitionable = false;
                                  ((Tokens)($$.obj)).isInPartitionable = false;
                                  ((Tokens)($$.obj)).isUniqueColumn = false;
                                  ((Tokens)($$.obj)).columnRefTable = null;
		      		  ((Tokens)($$.obj)).columnRefField = null;
                               }
                               else {
                                   ((Tokens)($$.obj)).text = "-" + ((Tokens)($2.obj)).text;
                              }
                             }

                             | '+' Where_scalar_factor {
                                if(onlyText == 0) {
                                   ((Tokens)($$.obj)).text = "+" + ((Tokens)($2.obj)).text;
                                   getResultSignType( (Tokens)($2.obj), (Tokens)($$.obj) );
                                   ((Tokens)($$.obj)).isJoinPartitionable = false;
                                   ((Tokens)($$.obj)).isInPartitionable = false;
                                   ((Tokens)($$.obj)).isUniqueColumn = false;
                                   ((Tokens)($$.obj)).columnRefTable = null;
		      		   ((Tokens)($$.obj)).columnRefField = null;
                                }
                                else {
                                   ((Tokens)($$.obj)).text = "+" + ((Tokens)($2.obj)).text;
                                }
                             }
                             ;

Where_scalar_factor : Column_ref {
                      if(onlyText == 0) {
                   	((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
		  	((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
		  	((Tokens)($$.obj)).columnRefTable = ((Tokens)($1.obj)).columnRefTable;
		  	((Tokens)($$.obj)).columnRefField = ((Tokens)($1.obj)).columnRefField;
		  	((Tokens)($$.obj)).isInPartitionable = false;
		  	((Tokens)($$.obj)).isJoinPartitionable = true;
		  	((Tokens)($$.obj)).isUniqueColumn = true;
		      }
		      else {
                   	((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
		      }
		    }

          	    | '(' Where_condition ')' {
          	      if(onlyText == 0) {
          	         ((Tokens)($$.obj)).text="(" + ((Tokens)($2.obj)).text + ")";
          	         ((Tokens)($$.obj)).type = ((Tokens)($2.obj)).type;
		  	 ((Tokens)($$.obj)).columnRefTable = ((Tokens)($2.obj)).columnRefTable;
 		  	 ((Tokens)($$.obj)).columnRefField = ((Tokens)($2.obj)).columnRefField;
          	         ((Tokens)($$.obj)).isJoinPartitionable = ((Tokens)($2.obj)).isJoinPartitionable;
          	         ((Tokens)($$.obj)).isInPartitionable = ((Tokens)($2.obj)).isInPartitionable;
          	         ((Tokens)($$.obj)).isUniqueColumn = ((Tokens)($2.obj)).isUniqueColumn;
          	      }
          	      else {
            	         ((Tokens)($$.obj)).text="(" + ((Tokens)($2.obj)).text + ")";
        	      }
          	    }

           	    | Literal {
                      if(onlyText == 0) {
                  	 ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
		  	 ((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
		  	 ((Tokens)($$.obj)).columnRefTable = ((Tokens)($1.obj)).columnRefTable;
 		  	 ((Tokens)($$.obj)).columnRefField = ((Tokens)($1.obj)).columnRefField;
 		  	 ((Tokens)($$.obj)).isJoinPartitionable = false;
 		  	 ((Tokens)($$.obj)).isInPartitionable = false;
		  	 ((Tokens)($$.obj)).isUniqueColumn = false;
		      }
		      else {
                  	 ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
		      }
		    }
		    | Numeric_value_function {
                      if(onlyText == 0) {
                  	 ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
		  	 ((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
		  	 ((Tokens)($$.obj)).columnRefTable = ((Tokens)($1.obj)).columnRefTable;
 		  	 ((Tokens)($$.obj)).columnRefField = ((Tokens)($1.obj)).columnRefField;
 		  	 ((Tokens)($$.obj)).isJoinPartitionable = false;
 		  	 ((Tokens)($$.obj)).isInPartitionable = false;
		  	 ((Tokens)($$.obj)).isUniqueColumn = false;
		      }
		      else {
                  	 ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
		      }		      
		    }
		    | String_value_function {
                      if(onlyText == 0) {
                  	 ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
		  	 ((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
		  	 ((Tokens)($$.obj)).columnRefTable = ((Tokens)($1.obj)).columnRefTable;
 		  	 ((Tokens)($$.obj)).columnRefField = ((Tokens)($1.obj)).columnRefField;
 		  	 ((Tokens)($$.obj)).isJoinPartitionable = false;
 		  	 ((Tokens)($$.obj)).isInPartitionable = false;
		  	 ((Tokens)($$.obj)).isUniqueColumn = false;
		      }
		      else {
                  	 ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
		      }		      
		    }
		    
            	    ;

Where_Relational_predicate : Where_Between_predicate {
                   	     if(onlyText == 0) {
                   		((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
		   		((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
		   	        ((Tokens)($$.obj)).isJoinPartitionable = false;
		   	        ((Tokens)($$.obj)).isInPartitionable = false;
                                ((Tokens)($$.obj)).columnRefTable = null;
		      		((Tokens)($$.obj)).columnRefField = null;
		   	     }
		   	     else {
                   		((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
		   	     }
		   	   }
                           | Where_Like_predicate {
                   	     if(onlyText == 0) {
                   		((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
		   		((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
		   		((Tokens)($$.obj)).isJoinPartitionable = false;
		   		((Tokens)($$.obj)).isInPartitionable = false;
                                ((Tokens)($$.obj)).columnRefTable = null;
		      		((Tokens)($$.obj)).columnRefField = null;
		   	     }
		   	     else {
                   		((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
		   	     }
		   	   }
                           | Where_in_predicate {
                   	     if(onlyText == 0) {
                   		((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
		   		((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
		   		((Tokens)($$.obj)).isJoinPartitionable = ((Tokens)($1.obj)).isJoinPartitionable;
                                ((Tokens)($$.obj)).isInPartitionable = ((Tokens)($1.obj)).isInPartitionable;
                                ((Tokens)($$.obj)).columnRefTable = null;
		      		((Tokens)($$.obj)).columnRefField = null;
                             }
                             else {
                   		((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
                             }
                           }
                           ;

Where_Between_predicate : Where_scalar_exp TK_BETWEEN Where_scalar_exp TK_AND Where_scalar_exp {
                          if(onlyText == 0) {
                            ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text+" " +((Tokens)($2.obj)).text + " " +
                                                      ((Tokens)($3.obj)).text+" "+((Tokens)($4.obj)).text + " " +
                                                      ((Tokens)($5.obj)).text;
                             getResultRelationalOpType((Tokens)($1.obj),(Tokens)($3.obj),(Tokens)($5.obj),(Tokens)($$.obj));
                             ((Tokens)($$.obj)).columnRefTable = null;
		             ((Tokens)($$.obj)).columnRefField = null;
                          }
                          else {
                            ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text +" "+((Tokens)($2.obj)).text + " " +
                                                      ((Tokens)($3.obj)).text +" "+((Tokens)($4.obj)).text + " " +
                                                      ((Tokens)($5.obj)).text;
                         }
                        }

                  | Where_scalar_exp TK_NOT TK_BETWEEN Where_scalar_exp TK_AND Where_scalar_exp {
                   if(onlyText == 0) {
                     ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " " + ((Tokens)($2.obj)).text + " " +
                                               ((Tokens)($3.obj)).text + " " + ((Tokens)($4.obj)).text + " " +
                                               ((Tokens)($5.obj)).text + " " + ((Tokens)($6.obj)).text;
                     getResultRelationalOpType((Tokens)($1.obj),(Tokens)($3.obj),(Tokens)($5.obj),(Tokens)($$.obj));
                     ((Tokens)($$.obj)).columnRefTable = null;
		     ((Tokens)($$.obj)).columnRefField = null;
                    }
                    else {
                     ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " " + ((Tokens)($2.obj)).text + " " +
                                               ((Tokens)($3.obj)).text + " " + ((Tokens)($4.obj)).text + " " +
                                               ((Tokens)($5.obj)).text + " " + ((Tokens)($6.obj)).text;
                   }
                  }
                  ;

Where_Like_predicate : Where_scalar_exp TK_LIKE Where_scalar_exp {
                       if(onlyText == 0) {
                          ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " " + ((Tokens)($2.obj)).text + " " +
                                                    ((Tokens)($3.obj)).text;
	      	           getResultLikeType( (Tokens)($1.obj),(Tokens)($3.obj),(Tokens)($$.obj) );
                          ((Tokens)($$.obj)).columnRefTable = null;
		          ((Tokens)($$.obj)).columnRefField = null;
                       }
                       else {
                          ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " " + ((Tokens)($2.obj)).text + " " +
                                                    ((Tokens)($3.obj)).text;
                       }
                     }
                     | Where_scalar_exp TK_LIKE Where_scalar_exp Where_escape {
                       if(onlyText == 0) {
                          ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " " + ((Tokens)($2.obj)).text + " " +
                                                    ((Tokens)($3.obj)).text + " " + ((Tokens)($4.obj)).text;
	      	          getResultLikeType( (Tokens)($1.obj),(Tokens)($3.obj),(Tokens)($$.obj) );
                          ((Tokens)($$.obj)).columnRefTable = null;
		          ((Tokens)($$.obj)).columnRefField = null;
                       }
                       else {
                          ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " " + ((Tokens)($2.obj)).text + " " +
                                                    ((Tokens)($3.obj)).text + " " + ((Tokens)($4.obj)).text;
                       }
                     }
                     | Where_scalar_exp TK_NOT TK_LIKE Where_scalar_exp {
                       if(onlyText == 0) {
                          ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " " + ((Tokens)($2.obj)).text + " " +
                                                    ((Tokens)($3.obj)).text + " " + ((Tokens)($4.obj)).text;
	      	          getResultLikeType( (Tokens)($1.obj),(Tokens)($4.obj),(Tokens)($$.obj) );
                          ((Tokens)($$.obj)).columnRefTable = null;
		          ((Tokens)($$.obj)).columnRefField = null;
                       }
                       else {
                          ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " " + ((Tokens)($2.obj)).text + " " +
                                                    ((Tokens)($3.obj)).text + " " + ((Tokens)($4.obj)).text;
                      }
                     }
		     | Where_scalar_exp TK_NOT TK_LIKE Where_scalar_exp Where_escape {
		       if(onlyText == 0) {
		          ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " " + ((Tokens)($2.obj)).text + " " +
		                                    ((Tokens)($3.obj)).text + " " + ((Tokens)($4.obj)).text + " " +
                                                    ((Tokens)($5.obj)).text;
	      	          getResultLikeType( (Tokens)($1.obj),(Tokens)($4.obj),(Tokens)($$.obj) );
                          ((Tokens)($$.obj)).columnRefTable = null;
		          ((Tokens)($$.obj)).columnRefField = null;
                       }
                       else {
 		          ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " " + ((Tokens)($2.obj)).text + " " +
		                                    ((Tokens)($3.obj)).text + " " + ((Tokens)($4.obj)).text + " " +
                                                    ((Tokens)($5.obj)).text;
                      }
                     }
                     ;

Where_escape : TK_ESCAPE Column_ref {
              if(onlyText == 0) {
            	((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " " + ((Tokens)($2.obj)).text;
		getResultEscapeType( (Tokens)($2.obj), (Tokens)($$.obj) );
                ((Tokens)($$.obj)).columnRefTable = null;
		((Tokens)($$.obj)).columnRefField = null;
	      }
	      else {
            	((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " " + ((Tokens)($2.obj)).text;
	      }
	     }
             | TK_ESCAPE Literal {
               if(onlyText == 0) {
                ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " " + ((Tokens)($2.obj)).text;
		getResultEscapeType( (Tokens)($2.obj), (Tokens)($$.obj) );
                ((Tokens)($$.obj)).columnRefTable = null;
		((Tokens)($$.obj)).columnRefField = null;
               }
               else {
                ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " " + ((Tokens)($2.obj)).text;
               }
           }
           ;


/************************************************************************************************/
/**				          EXISTS SUBQUERY   	                               **/
/************************************************************************************************/

Existence_test : TK_EXISTS '(' Subquery ')' {
	         if(onlyText == 0) {
	            ((Tokens)($$.obj)).text = "\n"+((Tokens)($1.obj)).text + "(" + ((Tokens)($3.obj)).text + ")";
		    ((Tokens)($$.obj)).type = Const.BOOLEAN;
		    ((Tokens)($$.obj)).typeSize = 0;
		    ((Tokens)($$.obj)).typePrecision = 0;
		    ((Tokens)($$.obj)).typeLength = 0;
		    ((Tokens)($$.obj)).alias = "Exists";
                    ((Tokens)($$.obj)).isInPartitionable = ((Tokens)($3.obj)).isJoinPartitionable;
                    ((Tokens)($$.obj)).isJoinPartitionable = false;
                    ((Tokens)($$.obj)).columnRefTable = null;
		    ((Tokens)($$.obj)).columnRefField = null;
	         }
	         else {
	            ((Tokens)($$.obj)).text = "\n"+((Tokens)($1.obj)).text + "(" + ((Tokens)($3.obj)).text + ")";
	         }
	       }
	       ;

/************************************************************************************************/
/**				          WHERE IN PREDICATE   	                               **/
/************************************************************************************************/


Where_in_predicate : Where_scalar_exp TK_IN '(' Subquery_ini Selection Select_tail ')' {
		     if(onlyText == 0) {
			((Tokens)($$.obj)).isInPartitionable = false;
			String textTemp = ((Tokens)($1.obj)).text + " in (" + ((Tokens)($4.obj)).text + " " +
		        	 	  ((Tokens)($5.obj)).text + ((Tokens)($6.obj)).text + ")";
		        if(((Tokens)($5.obj)).selectColumnCount>1)
		           yyerror("Subquery has too many columns : "+ new String(((Tokens)($$.obj)).text));
		        else {
		           if((((Tokens)($$.obj)).type=getResultInPredicateType(((Tokens)($1.obj)).type,((Tokens)($5.obj)).type))==Const.NONE)
		       	 	   yyerror("Type mismatch in the operation : "+ new String(((Tokens)($$.obj)).text));
		     	}
		     	if( ((Tokens)($1.obj)).isUniqueColumn && ((Tokens)($5.obj)).isUniqueColumn &&
		     	    ((Tokens)($1.obj)).columnRefTable != null &&
		     	    ((Tokens)($5.obj)).columnRefTable != null ){

		     	   if( isVpAttribute((Tokens)($1.obj)) && isVpAttribute((Tokens)($5.obj)) &&
                               ((Tokens)($1.obj)).columnRefTable.tableLevel < ((Tokens)($5.obj)).columnRefTable.tableLevel &&
                               ((Tokens)($5.obj)).columnRefTable.tableLevel == subqueryLevel ) {
                                 //inserir a sub faixa em select_tail

             //caso onde no where dentro do in jah se tem uma juncao q permite a introducao de faixa
             //entao nao preciso incluir uma nova faixa(na verdade trocar a faixa q ja existe pela em questao)
             //(otimizacao poderia decidir qual tem a maior cardinalidade para fazer esta escolha)
		     	         //if(!((Tokens)($6.obj)).isJoinPartitionable) {
                                    String indexTemp = new String( ((Tokens)($6.obj)).compositorText.replaceAll(" 1#1 ", new String(" " + findAlias(((Tokens)($5.obj)).columnRefTable.name,subqueryLevel)+"."+((Tokens)($5.obj)).columnRefField + " ")));
		              	    textTemp = ((Tokens)($1.obj)).text + " in (" + ((Tokens)($4.obj)).text + " " +
		              	    	       ((Tokens)($5.obj)).text + indexTemp + ")";
              	                    qvpCount++;
              	                 //}
              			 if( ((Tokens)($1.obj)).columnRefTable.tableLevel == (subqueryLevel-1) ) {
                                 	((Tokens)($$.obj)).isInPartitionable = true;
                                 	subqueryVpa = new String(((Tokens)($1.obj)).text);
                                 }
                                 else {
                                     ((Tokens)($$.obj)).isInPartitionable = false;
                                     if(!this.isFromClauseInnerSelect)
                                 	throw(new ParserSilentException("InterQuery : No vpa join in the IN subquery. Line : "+line+" Column : "+column));
                                 }

                           }
                           else {
                                ((Tokens)($$.obj)).isInPartitionable = false;
                                if(!this.isFromClauseInnerSelect)
		     	        	throw(new ParserSilentException("InterQuery : No vpa join in the IN subquery. Line : "+line+" Column : "+column));
		     	   }
		     	}
		     	else {
                             ((Tokens)($$.obj)).isInPartitionable = false;
                             if(!this.isFromClauseInnerSelect)
		      	     	  throw(new ParserSilentException("InterQuery : No vpa join in the IN subquery. Line : "+line+" Column : "+column));
		     	}

		        ((Tokens)($$.obj)).text = textTemp;
		     	((Tokens)($$.obj)).type = Const.BOOLEAN;
		        subqueryLevel--;
		     }
		     else {
			((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " in (" +
		        		          ((Tokens)($4.obj)).text + " " +  ((Tokens)($5.obj)).text +
              				          ((Tokens)($6.obj)).text + ")";
		     }
		   }
		   | Where_scalar_exp TK_NOT TK_IN '(' Subquery_ini Selection Select_tail ')' {
		     if(onlyText == 0) {
		        ((Tokens)($$.obj)).isInPartitionable = false;
		        ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " not in (" +
		        			  ((Tokens)($5.obj)).text + " " +
		        			  ((Tokens)($6.obj)).text +
              				          ((Tokens)($7.obj)).text + ")";
		        if(((Tokens)($6.obj)).selectColumnCount>1)
		           yyerror("Subquery has too many columns : "+ new String(((Tokens)($$.obj)).text));
		        else {
		           if((((Tokens)($$.obj)).type=getResultInPredicateType(((Tokens)($1.obj)).type,((Tokens)($6.obj)).type))==Const.NONE)
		       	 	   yyerror("Type mismatch in the operation : "+ new String(((Tokens)($$.obj)).text));
		     	}
		     	((Tokens)($$.obj)).type = Const.BOOLEAN;
		        subqueryLevel--;
		     	if(!this.isFromClauseInnerSelect)
		     		throw(new ParserSilentException("InterQuery : NOT IN subquery. Line : "+line+" Column : "+column));
		     }
		     else {
		        ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " not in (" +
		        			  ((Tokens)($5.obj)).text + " " +
		        			  ((Tokens)($6.obj)).text +  ((Tokens)($7.obj)).text + ")";
		     }
		   }
		   | Where_scalar_exp  TK_IN '(' In_value_list ')' {
		     if(onlyText == 0) {
		        ((Tokens)($$.obj)).isInPartitionable = false;
		        ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " in (" + ((Tokens)($4.obj)).text + ")";
		        if((((Tokens)($$.obj)).type=getResultInPredicateType(((Tokens)($1.obj)).type,((Tokens)($4.obj)).type))==Const.NONE)
		       		yyerror("Type mismatch in the operation : "+ new String(((Tokens)($$.obj)).text));
		        ((Tokens)($$.obj)).type = Const.BOOLEAN;
		        ((Tokens)($$.obj)).isInPartitionable = false;
		     }
		     else {
		        ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " in (" + ((Tokens)($4.obj)).text + ")";
		     }
		   }
		   | Where_scalar_exp TK_NOT TK_IN '(' In_value_list ')' {
		     if(onlyText == 0) {
		        ((Tokens)($$.obj)).isInPartitionable = false;
		        ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " not in (" + ((Tokens)($5.obj)).text + ")";
		        if((((Tokens)($$.obj)).type=getResultInPredicateType(((Tokens)($1.obj)).type,((Tokens)($5.obj)).type))==Const.NONE)
		       		yyerror("Type mismatch in the operation : "+ new String(((Tokens)($$.obj)).text));

		        ((Tokens)($$.obj)).type = Const.BOOLEAN;
		        ((Tokens)($$.obj)).isInPartitionable = false;
		     }
		     else {
		        ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " not in (" + ((Tokens)($5.obj)).text + ")";
		     }
		   }
                   ;

In_value_list : Where_scalar_exp {
		if(onlyText == 0) {
		   ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
		   ((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
	        }
	        else {
		   ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
	        }
	      }
	      | Where_scalar_exp ',' In_value_list {
		if(onlyText == 0) {
		   ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + "," + ((Tokens)($3.obj)).text;
		   ((Tokens)($$.obj)).type = getResultInPredicateType( ((Tokens)($1.obj)).type ,
	                                                               ((Tokens)($3.obj)).type );
	        }
	        else {
		   ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + "," + ((Tokens)($3.obj)).text;
	        }
	      }
	      ;


/************************************************************************************************/
/**					Having  Clause    		                       **/
/************************************************************************************************/


Having_clause : Having_clause_ini Scalar_condition {
	    if(this.isFromClauseInnerSelect){
                  if(((Tokens)($1.obj)).aggregationFunction!=Const.NONE){
                  	if(columnsNotInGroupError)
                  		yyerror("The column(s)" + columnsNotInGroup.substring(0,columnsNotInGroup.length() - 1) + " must appear in the GROUP BY clause" );

                  	if(subqueryLevel==0 && isSelectExp==0 && isFunctionParameter==0){
                 		qvpColumnsList = new ArrayList<Column>(qvpColumnsListTemp);
			}
                  }
                  else {
                        if(subqueryLevel==0 && isSelectExp==0 && isFunctionParameter==0){
                  	   int typeTemp;
                  	   boolean isConst;
                  	   if( constVerify(((Tokens)($1.obj)).type)) {
                  	  	   isConst = true;
                  		   typeTemp = ((Tokens)($1.obj)).type-1;
                  	   	   qvpColumnsList.add( new Column(((Tokens)($1.obj)).text, typeTemp,
                  		       ((Tokens)($1.obj)).aggregationFunction, getTypeText((Tokens)($1.obj)),
                  		                                               isConst) );
                  	    	   qvpColumnsListTemp = new ArrayList<Column>(qvpColumnsList);
                  	   	   ((Tokens)($1.obj)).compositor.clear();
                  	   	   ((Tokens)($1.obj)).compositor.trimToSize();
                  	   	   ((Tokens)($1.obj)).compositor.add(new ColumnIndex(qvpColumnsList.size()-1));
                    	   }
                  	   else {
                  		   isConst = false;
                  		   typeTemp = ((Tokens)($1.obj)).type;
                  		   qvpColumnsList.add( new Column(((Tokens)($1.obj)).text, typeTemp,
                  		      ((Tokens)($1.obj)).aggregationFunction, getTypeText((Tokens)($1.obj)),
                  		   	                               	       isConst) );
                  	   	   qvpColumnsListTemp = new ArrayList<Column>(qvpColumnsList);
                  	   	   ((Tokens)($1.obj)).compositorText = Const.COLUMN_PREFIX + (qvpColumnsList.size()-1);
                  	  	   ((Tokens)($1.obj)).compositor.clear();
                  	   	   ((Tokens)($1.obj)).compositor.trimToSize();
                  	   	   ((Tokens)($1.obj)).compositor.add(new ColumnIndex(qvpColumnsList.size()-1));
                  	   }
			}
                  	if(existsAggregationSelect.get(subqueryLevel)){
				if(mustIncludeInGroupBy(((Tokens)($1.obj)).text, subqueryLevel))
					if(columnsNotInGroupError)
						yyerror("The column(s)" + columnsNotInGroup.substring(0,columnsNotInGroup.length() - 1) + " must appear in the GROUP BY clause" );
		  	}
                  }
                  ((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
		  ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
                  columnsNotInGroupError = false;
                  columnsNotInGroup = "";
                  havingCase--;
                  if(subqueryLevel==0 && isSelectExp==0 && isFunctionParameter==0){
                   	((Tokens)($$.obj)).text = "";//nao tem Having em Qvp
                        havingCompositorText = new String(((Tokens)($2.obj)).compositorText);
		        havingCompositor = ((Tokens)($1.obj)).compositor.toArray();
                        selectCompTemp.trimToSize();
                  }
                  else {
                        ((Tokens)($$.obj)).text = "\n"+ ((Tokens)($1.obj)).text+" "+((Tokens)($2.obj)).text;
                  }
                  if( (((Tokens)($2.obj)).type!=Const.BOOLEAN) && (((Tokens)($2.obj)).type!=Const.CONST_BOOLEAN) )
                      yyerror("The HAVING expression "+ new String(((Tokens)($2.obj)).text) + " must be BOOLEAN.");
                  
                  ((Tokens)($$.obj)).text = "\n"+ ((Tokens)($1.obj)).text+" "+((Tokens)($2.obj)).text;
	    }
	    else {

                if(onlyText == 0) {
                  if(((Tokens)($1.obj)).aggregationFunction!=Const.NONE){
                  	if(columnsNotInGroupError)
                  		yyerror("The column(s)" + columnsNotInGroup.substring(0,columnsNotInGroup.length() - 1) + " must appear in the GROUP BY clause" );

                  	if(subqueryLevel==0 && isSelectExp==0 && isFunctionParameter==0){
                 		qvpColumnsList = new ArrayList<Column>(qvpColumnsListTemp);
			}
                  }
                  else {
                        if(subqueryLevel==0 && isSelectExp==0 && isFunctionParameter==0){
                  	   int typeTemp;
                  	   boolean isConst;
                  	   if( constVerify(((Tokens)($1.obj)).type)) {
                  	  	   isConst = true;
                  		   typeTemp = ((Tokens)($1.obj)).type-1;
                  	   	   qvpColumnsList.add( new Column(((Tokens)($1.obj)).text, typeTemp,
                  		       ((Tokens)($1.obj)).aggregationFunction, getTypeText((Tokens)($1.obj)),
                  		                                               isConst) );
                  	    	   qvpColumnsListTemp = new ArrayList<Column>(qvpColumnsList);
                  	   	   ((Tokens)($1.obj)).compositor.clear();
                  	   	   ((Tokens)($1.obj)).compositor.trimToSize();
                  	   	   ((Tokens)($1.obj)).compositor.add(new ColumnIndex(qvpColumnsList.size()-1));
                    	   }
                  	   else {
                  		   isConst = false;
                  		   typeTemp = ((Tokens)($1.obj)).type;
                  		   qvpColumnsList.add( new Column(((Tokens)($1.obj)).text, typeTemp,
                  		      ((Tokens)($1.obj)).aggregationFunction, getTypeText((Tokens)($1.obj)),
                  		   	                               	       isConst) );
                  	   	   qvpColumnsListTemp = new ArrayList<Column>(qvpColumnsList);
                  	   	   ((Tokens)($1.obj)).compositorText = Const.COLUMN_PREFIX + (qvpColumnsList.size()-1);
                  	  	   ((Tokens)($1.obj)).compositor.clear();
                  	   	   ((Tokens)($1.obj)).compositor.trimToSize();
                  	   	   ((Tokens)($1.obj)).compositor.add(new ColumnIndex(qvpColumnsList.size()-1));
                  	   }
			}
                  	if(existsAggregationSelect.get(subqueryLevel)){
				if(mustIncludeInGroupBy(((Tokens)($1.obj)).text, subqueryLevel))
					if(columnsNotInGroupError)
						yyerror("The column(s)" + columnsNotInGroup.substring(0,columnsNotInGroup.length() - 1) + " must appear in the GROUP BY clause" );
		  	}
                  }
                  ((Tokens)($$.obj)).type = ((Tokens)($1.obj)).type;
                  columnsNotInGroupError = false;
                  columnsNotInGroup = "";
                  havingCase--;
                  if(subqueryLevel==0 && isSelectExp==0 && isFunctionParameter==0){
                   	((Tokens)($$.obj)).text = "";//nao tem Having em Qvp
                        havingCompositorText = new String(((Tokens)($2.obj)).compositorText);
		        havingCompositor = ((Tokens)($1.obj)).compositor.toArray();
                        selectCompTemp.trimToSize();
                  }
                  else {
                        ((Tokens)($$.obj)).text = "\n"+ ((Tokens)($1.obj)).text+" "+((Tokens)($2.obj)).text;
                  }
                  if( (((Tokens)($2.obj)).type!=Const.BOOLEAN) && (((Tokens)($2.obj)).type!=Const.CONST_BOOLEAN) )
                      yyerror("The HAVING expression "+ new String(((Tokens)($2.obj)).text) + " must be BOOLEAN.");                   
                }
                else {
                        ((Tokens)($$.obj)).text = "\n"+ ((Tokens)($1.obj)).text+" "+((Tokens)($2.obj)).text;
                }
             }
          }
          ;
Having_clause_ini : TK_HAVING {
		    if(onlyText == 0) {
		    	havingCase++;
		    	((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
		    }
		    else {
		    	((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
                    }
		  }
		  ;


Test_for_null : Column_ref TK_IS TK_NULL {
                if(onlyText == 0) {
                   ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " " + ((Tokens)($2.obj)).text + " " +
                                             ((Tokens)($3.obj)).text ;
                   ((Tokens)($$.obj)).type = Const.BOOLEAN;
                   ((Tokens)($$.obj)).aggregationFunction = Const.NONE;
                   ((Tokens)($$.obj)).compositorText=((Tokens)($1.obj)).compositorText + " is null";
                   ((Tokens)($$.obj)).compositor=new ArrayList<Object>(addCompositor(Const.IS_NULL,(Tokens)$1.obj));
                   ((Tokens)($$.obj)).columnRefTable = null;
		   ((Tokens)($$.obj)).columnRefField = null;
                }
                else {
                   ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " " + ((Tokens)($2.obj)).text + " " +
                                             ((Tokens)($3.obj)).text ;
               }
              }
              | Column_ref TK_IS TK_NOT TK_NULL {
                if(onlyText == 0) {
                   ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " " + ((Tokens)($2.obj)).text + " " +
                                             ((Tokens)($3.obj)).text + " " + ((Tokens)($4.obj)).text;
                   ((Tokens)($$.obj)).type = Const.BOOLEAN;
                   ((Tokens)($$.obj)).aggregationFunction = Const.NONE;
                   ((Tokens)($$.obj)).compositorText=((Tokens)($1.obj)).compositorText + " is not null";
                   ((Tokens)($$.obj)).compositor=new ArrayList<Object>(addCompositor(Const.IS_NOT_NULL,(Tokens)$1.obj));
                   ((Tokens)($$.obj)).columnRefTable = null;
		   ((Tokens)($$.obj)).columnRefField = null;
                }
                else {
                   ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " " + ((Tokens)($2.obj)).text + " " +
                                             ((Tokens)($3.obj)).text + " " + ((Tokens)($4.obj)).text;
               }
              }
              ;

Comparison : '=' {
                ((Tokens)($$.obj)).text = "=";
                ((Tokens)($$.obj)).operator = Const.EQUAL;
             }
           | TK_DIFERENTE {
                ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
                ((Tokens)($$.obj)).operator = Const.DIFFERENT;
             }
           | '<' {
                ((Tokens)($$.obj)).text = "<";
                ((Tokens)($$.obj)).operator = Const.LESS;
             }
           | '>' {
                ((Tokens)($$.obj)).text = ">";
                ((Tokens)($$.obj)).operator = Const.GREATER;
             }
           | TK_MENOR_IG {
                ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
                ((Tokens)($$.obj)).operator = Const.LESS_EQUAL;
             }
           | TK_MAIOR_IG {
                ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
                ((Tokens)($$.obj)).operator = Const.GREATER_EQUAL;
             }
           ;

Search_escape : TK_ESCAPE Column_ref {
          if(onlyText == 0) {
            if(isFunctionParameter==0) {
            	if( (columnsNotInGroupError = mustIncludeInGroupBy( (Tokens)($2.obj), subqueryLevel)) )
            	  	 	columnsNotInGroup += " " + new String(((Tokens)($2.obj)).text + "," );
            }
            if(subqueryLevel==0 && isSelectExp==0 && isFunctionParameter==0)
            	addColumnsList( ((Tokens)($2.obj)), qvpColumnsListTemp );

            ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " " + ((Tokens)($2.obj)).text;
            ((Tokens)($$.obj)).compositorText = ((Tokens)($1.obj)).text + " " + ((Tokens)($2.obj)).compositorText;
	    getResultEscapeType( (Tokens)($2.obj), (Tokens)($$.obj) );
            ((Tokens)($$.obj)).columnRefTable = null;
 	    ((Tokens)($$.obj)).columnRefField = null;
         }
         else {
            ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " " + ((Tokens)($2.obj)).text;
         }
       }
       | TK_ESCAPE Literal {
         if(onlyText == 0) {
            ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " " + ((Tokens)($2.obj)).text;
            ((Tokens)($$.obj)).compositorText = ((Tokens)($1.obj)).text + " " + ((Tokens)($2.obj)).text;
	    getResultEscapeType( (Tokens)($2.obj), (Tokens)($$.obj) );
            ((Tokens)($$.obj)).columnRefTable = null;
	    ((Tokens)($$.obj)).columnRefField = null;
         }
         else {
            ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text + " " + ((Tokens)($2.obj)).text;
         }
       }
       ;

/************************************************************************************************/
/**					     SUBQUERY    		                       **/
/************************************************************************************************/


Subquery : Subquery_ini Selection Select_tail{
           if(onlyText == 0) {
              ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text+" "+((Tokens)($2.obj)).text+((Tokens)($3.obj)).text;
              ((Tokens)($$.obj)).type = ((Tokens)($2.obj)).type;
              ((Tokens)($$.obj)).isJoinPartitionable = ((Tokens)($3.obj)).isJoinPartitionable;
              ((Tokens)($$.obj)).isInPartitionable = ((Tokens)($3.obj)).isInPartitionable;
              ((Tokens)($$.obj)).selectColumnCount = ((Tokens)($2.obj)).selectColumnCount;
              subqueryLevel--;
           }
           else {
              ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text+" "+((Tokens)($2.obj)).text+((Tokens)($3.obj)).text;
           }
         }
         ;

Subquery_ini : TK_SELECT {
	       if(onlyText == 0) {
	           subqueryLevel++;
	           ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
	       }
	       else {
	           ((Tokens)($$.obj)).text = ((Tokens)($1.obj)).text;
	       }
	     }
	     ;



%%

  private Logger logger = Logger.getLogger(Parser.class);
  public int line;
  public int column;
  private Yylex lexer;
  private int subqueryLevel = 0;
  private int fromSubqueryLevel = 0;
  private int onlyText = 0;
  private int havingCase = 0;
  private int qvpCount = 0;
  private boolean isPartitionable = true;
  private boolean isFromClauseInnerSelect = false;
  private int isSelectExp = 0;
  private int isFunctionParameter = 0;
  private int selectAggregationFunctionCount = 0;
  private ColumnIndex qvpColumnCount = new ColumnIndex(-1);
  private ArrayList <Boolean> existsAggregationSelect = new ArrayList<Boolean>(0);
  private boolean columnsNotInGroupError = false;
  private String  columnsNotInGroup = "";
  private String limitText = "";
  private String vpQuery;
  private String allOrDistinct;
  private String subqueryVpa;
  private String vpTable;
  private String vpAttribute;
  private String error;
  private String inQuery;
  private ArrayList <String> groupByTextList = new ArrayList<String>(0);
  private Object[] groupByList = new Object[0]; //tabelas da clausula group by
  private ArrayList <String> orderByTextList = new ArrayList<String>(0);
  private ArrayList <ArrayList<String>> groupByLevelList = new ArrayList<ArrayList<String>>(0);
  private ArrayList <ArrayList<String>> selectAliasLevelList = new ArrayList<ArrayList<String>>(0);
  private OrderByRef[] orderByIndexList = new OrderByRef[0]; //tabelas da clausula order by
  private ArrayList <OrderByRef> orderByIndexListTemp = new ArrayList<OrderByRef>(0);
  private ArrayList <Tokens> qColumnsList = new ArrayList<Tokens>(0);    //lista de colunas do select de q
  private ArrayList <Column> qvpColumnsList = new ArrayList<Column>(0);    //lista de colunas do select de qvp
  private ArrayList <Column> qvpColumnsListTemp = new ArrayList<Column>(0);    //lista de colunas do select de qvp
  private ArrayList <ArrayList<Table>> fromTableAlias = new ArrayList<ArrayList<Table>>(0);
  private ArrayList <String> selectTextList = new ArrayList<String>(0);
  private ArrayList <Object> selectCompColumn = new ArrayList<Object>(0);
  private ArrayList <Object[]> selectCompTemp = new ArrayList <Object[]>(0);
  private Object[][] selectCompositor = new Object[0][0];
  private ArrayList <String> selectCompositorText = new ArrayList<String>(0);
  private Object[] havingCompositor = new Object[0];
  private String havingCompositorText;
  private ArrayList<String> aliasTextList = new ArrayList<String>(0);
  private ArrayList<String> whereAttList = new ArrayList<String>(0);
  private PargresDatabaseMetaData meta;
  ArrayList<Range> rangeList;

  private int[][] plusOrMinusResultType =
  {     	  /*NONE*/    /*CHAR*/     /*CSTR*/   /*VARCHAR*/ /*LONGVARCHAR*/ /*DOUB*/      /*CDOUB*/   	    /*DECIMAL*/    /*NUMERIC*/    /*FLOAT*/       /*REAL*/      /*INT*/    	    /*CINT*/             /*SMALLINT*/     /*TINYINT*/    	/*BIGINT*/ 	    /*DATE*/    /*CDAT*/   	      /*TIME*/    /*CTIM*/    	/*TIMESTAMP*/    /*BOOL*/    /*CBOO*/    /*NULL*/       /*CNUL*/    	    /*WILD*/
/*NONE*/	 {Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,     Const.NONE,   Const.NONE,   	    Const.NONE,    Const.NONE,    Const.NONE,     Const.NONE,   Const.NONE,	    Const.NONE,	   	 Const.NONE,      Const.NONE,    	Const.NONE,	    Const.NONE, Const.NONE,	      Const.NONE, Const.NONE, 	Const.NONE, 	Const.NONE, Const.NONE, Const.NONE,    Const.NONE, 	    Const.NONE}, /*NONE*/
/*CHAR*/	 {Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,     Const.NONE,   Const.NONE,   	    Const.NONE,    Const.NONE,    Const.NONE,     Const.NONE,   Const.NONE,	    Const.NONE,          Const.NONE,      Const.NONE,    	Const.NONE,	    Const.NONE, Const.NONE,	      Const.NONE, Const.NONE, 	Const.NONE, 	Const.NONE, Const.NONE, Const.NONE,    Const.NONE, 	    Const.NONE}, /*CHAR*/
/*CSTR*/	 {Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,     Const.NONE,   Const.NONE,         Const.NONE,    Const.NONE,    Const.NONE,     Const.NONE,   Const.NONE,	    Const.NONE,          Const.NONE,      Const.NONE,    	Const.NONE,	    Const.NONE, Const.NONE,	      Const.NONE, Const.NONE, 	Const.NONE, 	Const.NONE, Const.NONE, Const.NONE,    Const.NONE, 	    Const.NONE}, /*CSTR*/
/*VARCHAR*/	 {Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,     Const.NONE,   Const.NONE,    	    Const.NONE,    Const.NONE,    Const.NONE,     Const.NONE,   Const.NONE,	    Const.NONE,          Const.NONE,      Const.NONE,    	Const.NONE,	    Const.NONE, Const.NONE,	      Const.NONE, Const.NONE, 	Const.NONE, 	Const.NONE, Const.NONE, Const.NONE,    Const.NONE, 	    Const.NONE}, /*VARCHAR*/
/*LONGVARCHAR*/  {Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,     Const.NONE,   Const.NONE,	    Const.NONE,    Const.NONE,    Const.NONE,     Const.NONE,   Const.NONE,	    Const.NONE,          Const.NONE,      Const.NONE,    	Const.NONE,	    Const.NONE, Const.NONE,	      Const.NONE, Const.NONE, 	Const.NONE, 	Const.NONE, Const.NONE, Const.NONE,    Const.NONE, 	    Const.NONE}, /*LONGVARCHAR*/
/*DOUB*/	 {Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,     Const.DOUBLE, Const.DOUBLE,       Const.DOUBLE,  Const.DOUBLE,  Const.DOUBLE,   Const.DOUBLE, Const.DOUBLE,  	    Const.DOUBLE,	 Const.DOUBLE,    Const.DOUBLE,  	Const.DOUBLE,       Const.NONE, Const.NONE,	      Const.NONE, Const.NONE, 	Const.NONE, 	Const.NONE, Const.NONE, Const.DOUBLE,  Const.DOUBLE, 	    Const.NONE}, /*DOUB*/
/*CDOUB*/	 {Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,     Const.DOUBLE, Const.CONST_DOUBLE, Const.DOUBLE,  Const.DOUBLE,  Const.DOUBLE,   Const.DOUBLE, Const.DOUBLE,       Const.CONST_DOUBLE,  Const.DOUBLE,    Const.DOUBLE,  	Const.DOUBLE,  	    Const.NONE, Const.NONE,	      Const.NONE, Const.NONE, 	Const.NONE, 	Const.NONE, Const.NONE, Const.DOUBLE,  Const.CONST_DOUBLE,  Const.NONE}, /*CDOUB*/
/*DECIMAL*/	 {Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,     Const.DOUBLE, Const.DOUBLE,       Const.DECIMAL, Const.DECIMAL, Const.DOUBLE,   Const.DOUBLE, Const.DOUBLE,       Const.DOUBLE,	 Const.DOUBLE,    Const.DOUBLE,  	Const.DOUBLE,	    Const.NONE, Const.NONE,	      Const.NONE, Const.NONE, 	Const.NONE, 	Const.NONE, Const.NONE, Const.DECIMAL, Const.DECIMAL, 	    Const.NONE}, /*DECIMAL*/
/*NUMERIC*/	 {Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,     Const.DOUBLE, Const.DOUBLE,       Const.DECIMAL, Const.DECIMAL, Const.DOUBLE,   Const.DOUBLE, Const.DOUBLE,       Const.DOUBLE,	 Const.DOUBLE,    Const.DOUBLE,  	Const.DOUBLE,	    Const.NONE, Const.NONE,	      Const.NONE, Const.NONE, 	Const.NONE, 	Const.NONE, Const.NONE, Const.NUMERIC, Const.NUMERIC, 	    Const.NONE}, /*NUMERIC*/
/*FLOAT*/	 {Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,     Const.DOUBLE, Const.DOUBLE,       Const.DOUBLE,  Const.DOUBLE,  Const.FLOAT,    Const.DOUBLE, Const.FLOAT,        Const.FLOAT,	 Const.FLOAT,     Const.FLOAT,   	Const.DOUBLE,	    Const.NONE, Const.NONE,	      Const.NONE, Const.NONE, 	Const.NONE, 	Const.NONE, Const.NONE, Const.FLOAT,   Const.FLOAT, 	    Const.NONE}, /*FLOAT*/
/*REAL*/	 {Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,     Const.DOUBLE, Const.DOUBLE,       Const.DOUBLE,  Const.DOUBLE,  Const.DOUBLE,   Const.REAL,   Const.REAL,	    Const.REAL,	   	 Const.REAL,      Const.REAL,    	Const.DOUBLE,	    Const.NONE, Const.NONE,	      Const.NONE, Const.NONE, 	Const.NONE, 	Const.NONE, Const.NONE, Const.REAL,    Const.REAL, 	    Const.NONE}, /*REAL*/
/*INT*/ 	 {Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,     Const.DOUBLE, Const.DOUBLE, 	    Const.DOUBLE,  Const.DOUBLE,  Const.FLOAT,    Const.REAL,   Const.INTEGER,      Const.INTEGER,	 Const.INTEGER,   Const.INTEGER, 	Const.BIGINT,	    Const.DATE, Const.DATE,	      Const.NONE, Const.NONE, 	Const.NONE, 	Const.NONE, Const.NONE, Const.INTEGER, Const.INTEGER,       Const.NONE}, /*INT*/
/*CINT*/	 {Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,     Const.DOUBLE, Const.CONST_DOUBLE, Const.DOUBLE,  Const.DOUBLE,  Const.FLOAT,    Const.REAL,   Const.INTEGER,      Const.CONST_INTEGER, Const.INTEGER,   Const.INTEGER, 	Const.BIGINT,	    Const.DATE, Const.CONST_DATE,     Const.NONE, Const.NONE,   Const.NONE, 	Const.NONE, Const.NONE, Const.INTEGER, Const.CONST_INTEGER, Const.NONE}, /*CINT*/
/*SMALLINT*/ 	 {Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,     Const.DOUBLE, Const.DOUBLE, 	    Const.DOUBLE,  Const.DOUBLE,  Const.FLOAT,    Const.REAL,   Const.INTEGER,      Const.INTEGER,	 Const.SMALLINT,  Const.SMALLINT,	Const.BIGINT,	    Const.DATE, Const.DATE,	      Const.NONE, Const.NONE, 	Const.NONE, 	Const.NONE, Const.NONE, Const.SMALLINT,Const.SMALLINT,      Const.NONE}, /*SMALLINT*/
/*TINYINT*/ 	 {Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,     Const.DOUBLE, Const.DOUBLE, 	    Const.DOUBLE,  Const.DOUBLE,  Const.FLOAT,    Const.REAL,   Const.INTEGER,      Const.INTEGER,	 Const.SMALLINT,  Const.TINYINT, 	Const.BIGINT,	    Const.DATE, Const.DATE,	      Const.NONE, Const.NONE, 	Const.NONE, 	Const.NONE, Const.NONE, Const.TINYINT, Const.TINYINT,       Const.NONE}, /*TINYINT*/
/*BIGINT*/ 	 {Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,     Const.DOUBLE, Const.DOUBLE, 	    Const.DOUBLE,  Const.DOUBLE,  Const.DOUBLE,   Const.DOUBLE, Const.BIGINT,       Const.BIGINT,	 Const.BIGINT,    Const.BIGINT,  	Const.BIGINT,	    Const.DATE, Const.DATE,	      Const.NONE, Const.NONE, 	Const.NONE, 	Const.NONE, Const.NONE, Const.BIGINT,  Const.BIGINT,        Const.NONE}, /*BIGINT*/
/*DATE*/	 {Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,     Const.NONE,   Const.NONE, 	    Const.NONE,    Const.NONE,    Const.NONE,     Const.NONE,   Const.DATE,	    Const.DATE,	   	 Const.DATE,      Const.DATE,    	Const.DATE,	    Const.NONE, Const.NONE,	      Const.NONE, Const.NONE, 	Const.NONE, 	Const.NONE, Const.NONE, Const.NONE,    Const.NONE, 	    Const.NONE}, /*DATE*/
/*CDAT*/	 {Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,     Const.NONE,   Const.NONE, 	    Const.NONE,    Const.NONE,    Const.NONE,     Const.NONE,   Const.DATE,	    Const.CONST_DATE,    Const.DATE,      Const.DATE,    	Const.DATE,	    Const.NONE, Const.NONE,	      Const.NONE, Const.NONE, 	Const.NONE, 	Const.NONE, Const.NONE, Const.NONE,    Const.NONE, 	    Const.NONE}, /*CDAT*/
/*TIME*/	 {Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,     Const.NONE,   Const.NONE, 	    Const.NONE,    Const.NONE,    Const.NONE,     Const.NONE,   Const.TIME,	    Const.TIME,	  	 Const.TIME,      Const.TIME,    	Const.TIME,	    Const.NONE, Const.NONE,	      Const.NONE, Const.NONE, 	Const.NONE, 	Const.NONE, Const.NONE, Const.NONE,    Const.NONE, 	    Const.NONE}, /*TIME*/
/*CTIM*/	 {Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,     Const.NONE,   Const.NONE, 	    Const.NONE,    Const.NONE,    Const.NONE,     Const.NONE,   Const.TIME,	    Const.CONST_TIME,    Const.TIME,      Const.TIME,    	Const.TIME,	    Const.NONE, Const.NONE,	      Const.NONE, Const.NONE, 	Const.NONE, 	Const.NONE, Const.NONE, Const.NONE,    Const.NONE, 	    Const.NONE}, /*CTIM*/
/*TIMESTAMP*/	 {Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,     Const.NONE,   Const.NONE, 	    Const.NONE,    Const.NONE,    Const.NONE,     Const.NONE,   Const.TIMESTAMP,    Const.TIMESTAMP,	 Const.TIMESTAMP, Const.TIMESTAMP,      Const.TIMESTAMP,    Const.NONE, Const.NONE,	      Const.NONE, Const.NONE, 	Const.NONE, 	Const.NONE, Const.NONE, Const.NONE,    Const.NONE, 	    Const.NONE}, /*TIMESTAMP*/
/*BOOL*/	 {Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,     Const.NONE,   Const.NONE, 	    Const.NONE,    Const.NONE,    Const.NONE,     Const.NONE,   Const.NONE,	    Const.NONE,          Const.NONE,      Const.NONE,    	Const.NONE,	    Const.NONE, Const.NONE,	      Const.NONE, Const.NONE, 	Const.NONE, 	Const.NONE, Const.NONE, Const.NONE,    Const.NONE, 	    Const.NONE}, /*BOOL*/
/*CBOO*/	 {Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,     Const.NONE,   Const.NONE, 	    Const.NONE,    Const.NONE,    Const.NONE,     Const.NONE,   Const.NONE,	    Const.NONE, 	 Const.NONE,      Const.NONE,    	Const.NONE,	    Const.NONE, Const.NONE,	      Const.NONE, Const.NONE, 	Const.NONE, 	Const.NONE, Const.NONE, Const.NONE,    Const.NONE, 	    Const.NONE}, /*CBOO*/
/*NULL*/	 {Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,     Const.DOUBLE, Const.DOUBLE, 	    Const.DECIMAL, Const.NUMERIC, Const.FLOAT,    Const.REAL,   Const.INTEGER,      Const.INTEGER,       Const.SMALLINT,  Const.TINYINT, 	Const.BIGINT, 	    Const.NONE, Const.NONE,	      Const.NONE, Const.NONE, 	Const.NONE, 	Const.NONE, Const.NONE, Const.NONE,    Const.NONE, 	    Const.NONE}, /*NULL*/
/*CNUL*/	 {Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,     Const.DOUBLE, Const.CONST_DOUBLE, Const.DECIMAL, Const.NUMERIC, Const.FLOAT,    Const.REAL,   Const.INTEGER,      Const.CONST_INTEGER, Const.SMALLINT,  Const.TINYINT, 	Const.BIGINT,	    Const.NONE, Const.NONE,	      Const.NONE, Const.NONE, 	Const.NONE, 	Const.NONE, Const.NONE, Const.NONE,    Const.NONE, 	    Const.NONE}, /*CNUL*/
/*WILD*/	 {Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,     Const.NONE,   Const.NONE, 	    Const.NONE,    Const.NONE,    Const.NONE,     Const.NONE,   Const.NONE,         Const.NONE,          Const.NONE,      Const.NONE,    	Const.NONE,   	    Const.NONE, Const.NONE,	      Const.NONE, Const.NONE, 	Const.NONE, 	Const.NONE, Const.NONE, Const.NONE,    Const.NONE, 	    Const.NONE} /*WILD*/
   };

  private int[][] multiplicationResultType =
    {   	   /*NONE*/    /*CHAR*/     /*CSTR*/   /*VARCHAR*/ /*LONGVARCHAR*/  /*DOUB*/      /*CDOUB*/   		 /*DECIMAL*/   /*NUMERIC*/   /*FLOAT*/     /*REAL*/      /*INT*/        /*CINT*/             /*SMALLINT*/    /*TINYINT*/     /*BIGINT*/     /*DATE*/    /*CDAT*/    /*TIME*/    /*CTIM*/     /*TIMESTAMP*/   /*BOOL*/    /*CBOO*/    /*NULL*/        /*CNUL*/    	   /*WILD*/
/*NONE*/ 	  {Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,      Const.NONE,   Const.NONE, 		 Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,    Const.NONE, 	     Const.NONE,     Const.NONE,     Const.NONE,    Const.NONE, Const.NONE, Const.NONE, Const.NONE,  Const.NONE,     Const.NONE, Const.NONE, Const.NONE,     Const.NONE, 	   Const.NONE}, /*NONE*/
/*CHAR*/	  {Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,      Const.NONE,   Const.NONE, 	 	 Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,    Const.NONE, 	     Const.NONE,     Const.NONE,     Const.NONE,    Const.NONE, Const.NONE, Const.NONE, Const.NONE,  Const.NONE,     Const.NONE, Const.NONE, Const.NONE,     Const.NONE, 	   Const.NONE}, /*CHAR*/
/*CSTR*/	  {Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,      Const.NONE,   Const.NONE, 	 	 Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,    Const.NONE, 	     Const.NONE,     Const.NONE,     Const.NONE,    Const.NONE, Const.NONE, Const.NONE, Const.NONE,  Const.NONE,     Const.NONE, Const.NONE, Const.NONE,     Const.NONE, 	   Const.NONE}, /*CSTR*/
/*VARCHAR*/	  {Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,      Const.NONE,   Const.NONE, 	 	 Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,    Const.NONE, 	     Const.NONE,     Const.NONE,     Const.NONE,    Const.NONE, Const.NONE, Const.NONE, Const.NONE,  Const.NONE,     Const.NONE, Const.NONE, Const.NONE,     Const.NONE, 	   Const.NONE}, /*VARCHAR*/
/*LONGVARCHAR*/   {Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,      Const.NONE,   Const.NONE, 	         Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,    Const.NONE, 	     Const.NONE,     Const.NONE,     Const.NONE,    Const.NONE, Const.NONE, Const.NONE, Const.NONE,  Const.NONE,     Const.NONE, Const.NONE, Const.NONE,     Const.NONE, 	   Const.NONE}, /*LONGVARCHAR*/
/*DOUB*/ 	  {Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,      Const.DOUBLE, Const.DOUBLE, 	 Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE,  Const.DOUBLE, 	     Const.DOUBLE,   Const.DOUBLE,   Const.DOUBLE,  Const.NONE, Const.NONE, Const.NONE, Const.NONE,  Const.NONE,     Const.NONE, Const.NONE, Const.DOUBLE,   Const.DOUBLE,         Const.NONE}, /*DOUB*/
/*CDOUB*/	  {Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,      Const.DOUBLE, Const.CONST_DOUBLE,    Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE,  Const.CONST_DOUBLE,  Const.DOUBLE,   Const.DOUBLE,   Const.DOUBLE,  Const.NONE, Const.NONE, Const.NONE, Const.NONE,  Const.NONE,     Const.NONE, Const.NONE, Const.DOUBLE,   Const.CONST_DOUBLE,   Const.NONE}, /*CDOUB*/
/*DECIMAL*/ 	  {Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,      Const.DOUBLE, Const.DOUBLE, 	 Const.DECIMAL,Const.DECIMAL,Const.DOUBLE, Const.DOUBLE, Const.DOUBLE,  Const.DOUBLE, 	     Const.DOUBLE,   Const.DOUBLE,   Const.DOUBLE,  Const.NONE, Const.NONE, Const.NONE, Const.NONE,  Const.NONE,     Const.NONE, Const.NONE, Const.DECIMAL,  Const.DECIMAL,        Const.NONE}, /*DECIMAL*/
/*NUMERIC*/ 	  {Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,      Const.DOUBLE, Const.DOUBLE, 	 Const.DECIMAL,Const.DECIMAL,Const.DOUBLE, Const.DOUBLE, Const.DOUBLE,  Const.DOUBLE, 	     Const.DOUBLE,   Const.DOUBLE,   Const.DOUBLE,  Const.NONE, Const.NONE, Const.NONE, Const.NONE,  Const.NONE,     Const.NONE, Const.NONE, Const.NUMERIC,  Const.NUMERIC,        Const.NONE}, /*NUMERIC*/
/*FLOAT*/ 	  {Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,      Const.DOUBLE, Const.DOUBLE, 	 Const.DOUBLE, Const.DOUBLE, Const.FLOAT,  Const.DOUBLE, Const.FLOAT,   Const.FLOAT, 	     Const.FLOAT,    Const.FLOAT,    Const.DOUBLE,  Const.NONE, Const.NONE, Const.NONE, Const.NONE,  Const.NONE,     Const.NONE, Const.NONE, Const.FLOAT,    Const.FLOAT,          Const.NONE}, /*FLOAT*/
/*REAL*/ 	  {Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,      Const.DOUBLE, Const.DOUBLE, 	 Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.REAL,   Const.REAL,    Const.REAL, 	     Const.REAL,     Const.REAL,     Const.DOUBLE,  Const.NONE, Const.NONE, Const.NONE, Const.NONE,  Const.NONE,     Const.NONE, Const.NONE, Const.REAL,     Const.REAL,           Const.NONE}, /*REAL*/
/*INT*/ 	  {Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,      Const.DOUBLE, Const.DOUBLE, 	 Const.DOUBLE, Const.DOUBLE, Const.FLOAT,  Const.REAL,   Const.INTEGER, Const.INTEGER, 	     Const.INTEGER,  Const.INTEGER,  Const.INTEGER, Const.NONE, Const.NONE, Const.NONE, Const.NONE,  Const.NONE,     Const.NONE, Const.NONE, Const.INTEGER,  Const.INTEGER,        Const.NONE}, /*INT*/
/*CINT*/	  {Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,      Const.DOUBLE, Const.CONST_DOUBLE,    Const.DOUBLE, Const.DOUBLE, Const.FLOAT,  Const.REAL,   Const.INTEGER, Const.CONST_INTEGER, Const.INTEGER,  Const.INTEGER,  Const.INTEGER, Const.NONE, Const.NONE, Const.NONE, Const.NONE,  Const.NONE,     Const.NONE, Const.NONE, Const.INTEGER,  Const.CONST_INTEGER,  Const.NONE}, /*CINT*/
/*SMALLINT*/ 	  {Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,      Const.DOUBLE, Const.DOUBLE, 	 Const.DOUBLE, Const.DOUBLE, Const.FLOAT,  Const.REAL,   Const.INTEGER, Const.INTEGER, 	     Const.SMALLINT, Const.SMALLINT, Const.INTEGER, Const.NONE, Const.NONE, Const.NONE, Const.NONE,  Const.NONE,     Const.NONE, Const.NONE, Const.SMALLINT, Const.SMALLINT,       Const.NONE}, /*SMALLINT*/
/*TINYINT*/ 	  {Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,      Const.DOUBLE, Const.DOUBLE, 	 Const.DOUBLE, Const.DOUBLE, Const.FLOAT,  Const.REAL,   Const.INTEGER, Const.INTEGER, 	     Const.SMALLINT, Const.TINYINT,  Const.INTEGER, Const.NONE, Const.NONE, Const.NONE, Const.NONE,  Const.NONE,     Const.NONE, Const.NONE, Const.TINYINT,  Const.TINYINT,        Const.NONE}, /*TINYINT*/
/*BIGINT*/ 	  {Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,      Const.DOUBLE, Const.DOUBLE, 	 Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.BIGINT,  Const.BIGINT, 	     Const.BIGINT,   Const.BIGINT,   Const.INTEGER, Const.NONE, Const.NONE, Const.NONE, Const.NONE,  Const.NONE,     Const.NONE, Const.NONE, Const.BIGINT,   Const.BIGINT,         Const.NONE}, /*BIGINT*/
/*DATE*/	  {Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,      Const.NONE,   Const.NONE, 		 Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,    Const.NONE, 	     Const.NONE,     Const.NONE,     Const.NONE,    Const.NONE, Const.NONE, Const.NONE, Const.NONE,  Const.NONE,     Const.NONE, Const.NONE, Const.NONE,     Const.NONE,           Const.NONE}, /*DATE*/
/*CDAT*/	  {Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,      Const.NONE,   Const.NONE, 		 Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,    Const.NONE,	     Const.NONE,     Const.NONE,     Const.NONE,    Const.NONE, Const.NONE, Const.NONE, Const.NONE,  Const.NONE,     Const.NONE, Const.NONE, Const.NONE,     Const.NONE, 	   Const.NONE}, /*CDAT*/
/*TIME*/	  {Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,      Const.NONE,   Const.NONE, 		 Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,    Const.NONE,	     Const.NONE,     Const.NONE,     Const.NONE,    Const.NONE, Const.NONE, Const.NONE, Const.NONE,  Const.NONE,     Const.NONE, Const.NONE, Const.NONE,     Const.NONE, 	   Const.NONE}, /*TIME*/
/*CTIM*/	  {Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,      Const.NONE,   Const.NONE, 		 Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,    Const.NONE,   	     Const.NONE,     Const.NONE,     Const.NONE,    Const.NONE, Const.NONE, Const.NONE, Const.NONE,  Const.NONE,     Const.NONE, Const.NONE, Const.NONE,     Const.NONE, 	   Const.NONE}, /*CTIM*/
/*TIMESTAMP*/	  {Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,      Const.NONE,   Const.NONE, 		 Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,    Const.NONE,	     Const.NONE,     Const.NONE,     Const.NONE,    Const.NONE, Const.NONE, Const.NONE, Const.NONE,  Const.NONE,     Const.NONE, Const.NONE, Const.NONE,     Const.NONE, 	   Const.NONE}, /*TIMESTAMP*/
/*BOOL*/	  {Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,      Const.NONE,   Const.NONE, 		 Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,    Const.NONE,	     Const.NONE,     Const.NONE,     Const.NONE,    Const.NONE, Const.NONE, Const.NONE, Const.NONE,  Const.NONE,     Const.NONE, Const.NONE, Const.NONE,     Const.NONE, 	   Const.NONE}, /*BOOL*/
/*CBOO*/	  {Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,      Const.NONE,   Const.NONE, 		 Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,    Const.NONE,	     Const.NONE,     Const.NONE,     Const.NONE,    Const.NONE, Const.NONE, Const.NONE, Const.NONE,  Const.NONE,     Const.NONE, Const.NONE, Const.NONE,     Const.NONE, 	   Const.NONE}, /*CBOO*/
/*NULL*/	  {Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,      Const.DOUBLE, Const.DOUBLE, 	 Const.DECIMAL,Const.NUMERIC,Const.FLOAT,  Const.REAL,   Const.INTEGER, Const.INTEGER,       Const.SMALLINT, Const.TINYINT,  Const.BIGINT,  Const.NONE, Const.NONE, Const.NONE, Const.NONE,  Const.NONE,     Const.NONE, Const.NONE, Const.NONE,     Const.NONE, 	   Const.NONE}, /*NULL*/
/*CNUL*/	  {Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,      Const.DOUBLE, Const.CONST_DOUBLE,    Const.DECIMAL,Const.NUMERIC,Const.FLOAT,  Const.REAL,   Const.INTEGER, Const.CONST_INTEGER, Const.SMALLINT, Const.TINYINT,  Const.BIGINT,  Const.NONE, Const.NONE, Const.NONE, Const.NONE,  Const.NONE,     Const.NONE, Const.NONE, Const.NONE,     Const.NONE, 	   Const.NONE}, /*CNUL*/
/*WILD*/	  {Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,      Const.NONE,   Const.NONE, 		 Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,    Const.NONE,          Const.NONE,     Const.NONE,     Const.NONE,    Const.NONE, Const.NONE, Const.NONE, Const.NONE,  Const.NONE,     Const.NONE, Const.NONE, Const.NONE,     Const.NONE, 	   Const.NONE}  /*WILD*/
   };

  private int[][] divisionResultType =
    {   	    /*NONE*/    /*CHAR*/     /*CSTR*/  /*VARCHAR*/     /*LONGVARCHAR*/  /*DOUB*/      /*CDOUB*/   	  /*DECIMAL*/   /*NUMERIC*/   /*FLOAT*/     /*REAL*/      /*INT*/        	/*CINT*/              /*SMALLINT*/   /*TINYINT*/    /*BIGINT*/     /*DATE*/    /*CDAT*/    /*TIME*/    /*CTIM*/    /*TIMESTAMP*/  /*BOOL*/    /*CBOO*/    /*NULL*/       /*CNUL*/    	      /*WILD*/
/*NONE*/	  {Const.NONE, Const.NONE, Const.NONE, Const.NONE,     Const.NONE,      Const.NONE,   Const.NONE, 	  Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,    	Const.NONE,	      Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,    Const.NONE, Const.NONE, Const.NONE,    Const.NONE, 	      Const.NONE}, /*NONE*/
/*CHAR*/	  {Const.NONE, Const.NONE, Const.NONE, Const.NONE,     Const.NONE,      Const.NONE,   Const.NONE, 	  Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,    	Const.NONE,	      Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,    Const.NONE, Const.NONE, Const.NONE,    Const.NONE, 	      Const.NONE}, /*CHAR*/
/*CSTR*/	  {Const.NONE, Const.NONE, Const.NONE, Const.NONE,     Const.NONE,      Const.NONE,   Const.NONE, 	  Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,    	Const.NONE,	      Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,    Const.NONE, Const.NONE, Const.NONE,    Const.NONE, 	      Const.NONE}, /*CSTR*/
/*VARCHAR*/	  {Const.NONE, Const.NONE, Const.NONE, Const.NONE,     Const.NONE,      Const.NONE,   Const.NONE, 	  Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,    	Const.NONE,	      Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,    Const.NONE, Const.NONE, Const.NONE,    Const.NONE, 	      Const.NONE}, /*VARCHAR*/
/*LONGVARCHAR*/   {Const.NONE, Const.NONE, Const.NONE, Const.NONE,     Const.NONE,      Const.NONE,   Const.NONE, 	  Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,    	Const.NONE,	      Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,    Const.NONE, Const.NONE, Const.NONE,    Const.NONE, 	      Const.NONE}, /*LONGVARCHAR*/
/*DOUB*/  	  {Const.NONE, Const.NONE, Const.NONE, Const.NONE,     Const.NONE,      Const.DOUBLE, Const.DOUBLE, 	  Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE,  	Const.DOUBLE,	      Const.DOUBLE,  Const.DOUBLE,  Const.DOUBLE,  Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,    Const.NONE, Const.NONE, Const.DOUBLE,  Const.DOUBLE,        Const.NONE}, /*DOUB*/
/*CDOUB*/	  {Const.NONE, Const.NONE, Const.NONE, Const.NONE,     Const.NONE,      Const.DOUBLE, Const.CONST_DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE,  	Const.CONST_DOUBLE,   Const.DOUBLE,  Const.DOUBLE,  Const.DOUBLE,  Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,    Const.NONE, Const.NONE, Const.DOUBLE,  Const.CONST_DOUBLE,  Const.NONE}, /*CDOUB*/
/*DECIMAL*/  	  {Const.NONE, Const.NONE, Const.NONE, Const.NONE,     Const.NONE,      Const.DOUBLE, Const.DOUBLE, 	  Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE,  	Const.DOUBLE,	      Const.DOUBLE,  Const.DOUBLE,  Const.DOUBLE,  Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,    Const.NONE, Const.NONE, Const.DOUBLE,  Const.DOUBLE,        Const.NONE}, /*DECIMAL*/
/*NUMERIC*/  	  {Const.NONE, Const.NONE, Const.NONE, Const.NONE,     Const.NONE,      Const.DOUBLE, Const.DOUBLE, 	  Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE,  	Const.DOUBLE,	      Const.DOUBLE,  Const.DOUBLE,  Const.DOUBLE,  Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,    Const.NONE, Const.NONE, Const.DOUBLE,  Const.DOUBLE,        Const.NONE}, /*NUMERIC*/
/*FLOAT*/  	  {Const.NONE, Const.NONE, Const.NONE, Const.NONE,     Const.NONE,      Const.DOUBLE, Const.DOUBLE, 	  Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE,  	Const.DOUBLE,	      Const.DOUBLE,  Const.DOUBLE,  Const.DOUBLE,  Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,    Const.NONE, Const.NONE, Const.DOUBLE,  Const.DOUBLE,        Const.NONE}, /*FLOAT*/
/*REAL*/  	  {Const.NONE, Const.NONE, Const.NONE, Const.NONE,     Const.NONE,      Const.DOUBLE, Const.DOUBLE, 	  Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE,  	Const.DOUBLE,	      Const.DOUBLE,  Const.DOUBLE,  Const.DOUBLE,  Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,    Const.NONE, Const.NONE, Const.DOUBLE,  Const.DOUBLE,	      Const.NONE}, /*REAL*/
/*INT*/ 	  {Const.NONE, Const.NONE, Const.NONE, Const.NONE,     Const.NONE,      Const.DOUBLE, Const.DOUBLE, 	  Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE,  	Const.DOUBLE,	      Const.DOUBLE,  Const.DOUBLE,  Const.DOUBLE,  Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,    Const.NONE, Const.NONE, Const.DOUBLE,  Const.DOUBLE,        Const.NONE}, /*INT*/
/*CINT*/	  {Const.NONE, Const.NONE, Const.NONE, Const.NONE,     Const.NONE,      Const.DOUBLE, Const.CONST_DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE,  	Const.CONST_DOUBLE,   Const.DOUBLE,  Const.DOUBLE,  Const.DOUBLE,  Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,    Const.NONE, Const.NONE, Const.DOUBLE,  Const.CONST_DOUBLE,  Const.NONE}, /*CINT*/
/*SMALLINT*/ 	  {Const.NONE, Const.NONE, Const.NONE, Const.NONE,     Const.NONE,      Const.DOUBLE, Const.DOUBLE, 	  Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE,  	Const.DOUBLE,	      Const.DOUBLE,  Const.DOUBLE,  Const.DOUBLE,  Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,    Const.NONE, Const.NONE, Const.DOUBLE,  Const.DOUBLE,        Const.NONE}, /*SMALLINT*/
/*TINYINT*/ 	  {Const.NONE, Const.NONE, Const.NONE, Const.NONE,     Const.NONE,      Const.DOUBLE, Const.DOUBLE, 	  Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE,  	Const.DOUBLE,	      Const.DOUBLE,  Const.DOUBLE,  Const.DOUBLE,  Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,    Const.NONE, Const.NONE, Const.DOUBLE,  Const.DOUBLE,        Const.NONE}, /*TINYINT*/
/*BIGINT*/ 	  {Const.NONE, Const.NONE, Const.NONE, Const.NONE,     Const.NONE,      Const.DOUBLE, Const.DOUBLE, 	  Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE,  	Const.DOUBLE,	      Const.DOUBLE,  Const.DOUBLE,  Const.DOUBLE,  Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,    Const.NONE, Const.NONE, Const.DOUBLE,  Const.DOUBLE,        Const.NONE}, /*BIGINT*/
/*DATE*/	  {Const.NONE, Const.NONE, Const.NONE, Const.NONE,     Const.NONE,      Const.NONE,   Const.NONE, 	  Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,    	Const.NONE, 	      Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,    Const.NONE, Const.NONE, Const.NONE,    Const.NONE,          Const.NONE}, /*DATE*/
/*CDAT*/	  {Const.NONE, Const.NONE, Const.NONE, Const.NONE,     Const.NONE,      Const.NONE,   Const.NONE, 	  Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,    	Const.NONE, 	      Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,    Const.NONE, Const.NONE, Const.NONE,    Const.NONE, 	      Const.NONE}, /*CDAT*/
/*TIME*/	  {Const.NONE, Const.NONE, Const.NONE, Const.NONE,     Const.NONE,      Const.NONE,   Const.NONE, 	  Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,    	Const.NONE, 	      Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,    Const.NONE, Const.NONE, Const.NONE,    Const.NONE, 	      Const.NONE}, /*TIME*/
/*CTIM*/	  {Const.NONE, Const.NONE, Const.NONE, Const.NONE,     Const.NONE,      Const.NONE,   Const.NONE, 	  Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,    	Const.NONE, 	      Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,    Const.NONE, Const.NONE, Const.NONE,    Const.NONE, 	      Const.NONE}, /*CTIM*/
/*TIMESTAMP*/	  {Const.NONE, Const.NONE, Const.NONE, Const.NONE,     Const.NONE,      Const.NONE,   Const.NONE, 	  Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,    	Const.NONE, 	      Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,    Const.NONE, Const.NONE, Const.NONE,    Const.NONE, 	      Const.NONE}, /*TIMESTAMP*/
/*BOOL*/	  {Const.NONE, Const.NONE, Const.NONE, Const.NONE,     Const.NONE,      Const.NONE,   Const.NONE, 	  Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,    	Const.NONE,	      Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,    Const.NONE, Const.NONE, Const.NONE,    Const.NONE, 	      Const.NONE}, /*BOOL*/
/*CBOO*/	  {Const.NONE, Const.NONE, Const.NONE, Const.NONE,     Const.NONE,      Const.NONE,   Const.NONE, 	  Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE, 	  	Const.NONE,	      Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,    Const.NONE, Const.NONE, Const.NONE,    Const.NONE, 	      Const.NONE}, /*CBOO*/
/*NULL*/	  {Const.NONE, Const.NONE, Const.NONE, Const.NONE,     Const.NONE,      Const.DOUBLE, Const.DOUBLE, 	  Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, 	Const.DOUBLE,         Const.DOUBLE,  Const.DOUBLE,  Const.DOUBLE,  Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,    Const.NONE, Const.NONE, Const.NONE,    Const.NONE, 	      Const.NONE}, /*NULL*/
/*CNUL*/	  {Const.NONE, Const.NONE, Const.NONE, Const.NONE,     Const.NONE,      Const.DOUBLE, Const.CONST_DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE,         Const.CONST_DOUBLE,   Const.DOUBLE,  Const.DOUBLE,  Const.DOUBLE,  Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,    Const.NONE, Const.NONE, Const.NONE,    Const.NONE, 	      Const.NONE}, /*CNUL*/
/*WILD*/	  {Const.NONE, Const.NONE, Const.NONE, Const.NONE,     Const.NONE,      Const.NONE,   Const.NONE, 	  Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,    	Const.NONE,           Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,    Const.NONE, Const.NONE, Const.NONE,    Const.NONE, 	      Const.NONE}  /*WILD*/
   };

   private int[] signResultType =
       /*NONE*/    /*CHAR*/     /*CSTR*/   /*VARCHAR*/ /*LONGVARCHAR*/  /*DOUB*/      /*CDOUB*/   	  /*DECIMAL*/    /*NUMERIC*/    /*FLOAT*/     /*REAL*/      /*INT*/        /*CINT*/             /*SMALLINT*/    /*TINYINT*/    /*BIGINT*/     /*DATE*/    /*CDAT*/    /*TIME*/    /*CTIM*/    /*TIMESTAMP*/    /*BOOL*/    /*CBOO*/    /*NULL*/    /*CNUL*/    /*WILD*/
      {Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,      Const.DOUBLE, Const.CONST_DOUBLE, Const.DECIMAL, Const.NUMERIC, Const.FLOAT,  Const.REAL,   Const.INTEGER, Const.CONST_INTEGER, Const.SMALLINT, Const.TINYINT, Const.BIGINT,  Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,      Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE};

   private int[] avgResultType  =
       /*NONE*/    /*CHAR*/     /*CSTR*/   /*VARCHAR*/ /*LONGVARCHAR*/ /*DOUB*/      /*CDOUB*/     /*DECIMAL*/   /*NUMERIC*/   /*FLOAT*/     /*REAL*/      /*INT*/       /*CINT*/      /*SMALLINT*/  /*TINYINT*/   /*BIGINT*/    /*DATE*/    /*CDAT*/    /*TIME*/    /*CTIM*/    /*TIMESTAMP*/    /*BOOL*/    /*CBOO*/    /*NULL*/    /*CNUL*/    /*WILD*/
      {Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,     Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE};

   private int[] sumResultType  =
       /*NONE*/    /*CHAR*/     /*CSTR*/   /*VARCHAR*/ /*LONGVARCHAR*/  /*DOUB*/      /*CDOUB*/     /*DECIMAL*/   /*NUMERIC*/   /*FLOAT*/     /*REAL*/      /*INT*/        /*CINT*/       /*SMALLINT*/   /*TINYINT*/    /*BIGINT*/     /*DATE*/    /*CDAT*/    /*TIME*/    /*CTIM*/    /*TIMESTAMP*/    /*BOOL*/    /*CBOO*/    /*NULL*/    /*CNUL*/    /*WILD*/
      {Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,      Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.BIGINT, Const.BIGINT,   Const.BIGINT,  Const.BIGINT,  Const.BIGINT,  Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,      Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE};

   private int[] countResultType  =
       /*NONE*/    /*CHAR*/      /*CSTR*/      /*VARCHAR*/    /*LONGVARCHAR*/ /*DOUB*/      /*CDOUB*/     /*DECIMAL*/   /*NUMERIC*/   /*FLOAT*/     /*REAL*/      /*INT*/       /*CINT*/      /*SMALLINT*/  /*TINYINT*/   /*BIGINT*/    /*DATE*/      /*CDAT*/      /*TIME*/      /*CTIM*/      /*TIMESTAMP*/ /*BOOL*/      /*CBOO*/      /*NULL*/      /*CNUL*/      /*WILD*/
      {Const.NONE, Const.BIGINT, Const.BIGINT, Const.BIGINT, Const.BIGINT,    Const.BIGINT, Const.BIGINT, Const.BIGINT, Const.BIGINT, Const.BIGINT, Const.BIGINT, Const.BIGINT, Const.BIGINT, Const.BIGINT, Const.BIGINT, Const.BIGINT, Const.BIGINT, Const.BIGINT, Const.BIGINT, Const.BIGINT, Const.BIGINT, Const.BIGINT, Const.BIGINT, Const.BIGINT, Const.BIGINT, Const.BIGINT};

   private int[] minResultType  =
       /*NONE*/    /*CHAR*/        /*CSTR*/      /*VARCHAR*/    /*LONGVARCHAR*/       /*DOUB*/      /*CDOUB*/     /*DECIMAL*/    /*NUMERIC*/    /*FLOAT*/     /*REAL*/      /*INT*/        /*CINT*/       /*SMALLINT*/    /*TINYINT*/    /*BIGINT*/     /*DATE*/    /*CDAT*/    /*TIME*/    /*CTIM*/    /*TIMESTAMP*/      /*BOOL*/    /*CBOO*/    /*NULL*/       /*CNUL*/       /*WILD*/
      {Const.NONE, Const.VARCHAR, Const.VARCHAR, Const.VARCHAR, Const.LONGVARCHAR,    Const.DOUBLE, Const.DOUBLE, Const.DECIMAL, Const.NUMERIC, Const.FLOAT,  Const.REAL,   Const.INTEGER, Const.INTEGER, Const.SMALLINT, Const.TINYINT, Const.BIGINT,  Const.DATE, Const.DATE, Const.TIME, Const.TIME, Const.TIMESTAMP,   Const.NONE, Const.NONE, Const.VARCHAR, Const.VARCHAR, Const.NONE};

   private int[] maxResultType  =
       /*NONE*/    /*CHAR*/         /*CSTR*/     /*VARCHAR*/    /*LONGVARCHAR*/       /*DOUB*/      /*CDOUB*/     /*DECIMAL*/    /*NUMERIC*/    /*FLOAT*/     /*REAL*/      /*INT*/        /*CINT*/       /*SMALLINT*/    /*TINYINT*/    /*BIGINT*/     /*DATE*/    /*CDAT*/       /*TIME*/    /*CTIM*/     /*TIMESTAMP*/       /*BOOL*/    /*CBOO*/    /*NULL*/       /*CNUL*/       /*WILD*/
      {Const.NONE, Const.VARCHAR, Const.VARCHAR, Const.VARCHAR, Const.LONGVARCHAR,    Const.DOUBLE, Const.DOUBLE, Const.DECIMAL, Const.NUMERIC, Const.FLOAT,  Const.REAL,  Const.INTEGER, Const.INTEGER, Const.SMALLINT, Const.TINYINT, Const.BIGINT,  Const.DATE, Const.DATE,    Const.TIME, Const.TIME,  Const.TIMESTAMP,    Const.NONE, Const.NONE, Const.VARCHAR, Const.VARCHAR, Const.NONE};

   private int[] extractResultType =
       /*NONE*/     /*CHAR*/     /*CSTR*/     /*VARCHAR*/  /*LONGVARCHAR*/  /*DOUB*/     /*CDOUB*/    /*DECIMAL*/  /*NUMERIC*/  /*FLOAT*/    /*REAL*/      /*INT*/      /*CINT*/     /*SMALLINT*/  /*TINYINT*/  /*BIGINT*/   /*DATE*/       /*CDAT*/             /*TIME*/       /*CTIM*/             /*TIMESTAMP*/  /*BOOL*/     /*CBOO*/     /*NULL*/     /*CNUL*/     /*WILD*/
      {Const.NONE,  Const.NONE,  Const.NONE,  Const.NONE,  Const.NONE,      Const.NONE,  Const.NONE,  Const.NONE,  Const.NONE,  Const.NONE,  Const.NONE,   Const.NONE,  Const.NONE,  Const.NONE,   Const.NONE,  Const.NONE,  Const.DOUBLE,  Const.CONST_DOUBLE,  Const.DOUBLE,  Const.CONST_DOUBLE,  Const.DOUBLE,  Const.NONE,  Const.NONE,  Const.NONE,  Const.NONE,  Const.NONE};

  private int[][] logicOpResultType =
   {    	   /*NONE*/    /*CHAR*/     /*CSTR*/   /*VARCHAR*/ /*LONGVARCHAR*/ /*DOUB*/    /*CDOUB*/   /*DECIMAL*/ /*NUMERIC*/ /*FLOAT*/   /*REAL*/    /*INT*/     /*CINT*/    /*SMALLINT*/   /*TINYINT*/    /*BIGINT*/    /*DATE*/    /*CDAT*/    /*TIME*/    /*CTIM*/    /*TIMESTAMP*/     /*BOOL*/       /*CBOO*/    	       /*NULL*/       /*CNUL*/    	   /*WILD*/
/*NONE*/	  {Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,     Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,    Const.NONE,    Const.NONE,   Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, 	Const.NONE,    Const.NONE, 	       Const.NONE,    Const.NONE,	   Const.NONE}, /*NONE*/
/*CHAR*/	  {Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,     Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,    Const.NONE,    Const.NONE,   Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, 	Const.NONE,    Const.NONE, 	       Const.NONE,    Const.NONE,	   Const.NONE}, /*CHAR*/
/*CSTR*/	  {Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,     Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,    Const.NONE,    Const.NONE,   Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, 	Const.NONE,    Const.NONE, 	       Const.NONE,    Const.NONE,	   Const.NONE}, /*CSTR*/
/*VARCHAR*/ 	  {Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,     Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,    Const.NONE,    Const.NONE,   Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, 	Const.NONE,    Const.NONE, 	       Const.NONE,    Const.NONE,	   Const.NONE}, /*VARCHAR*/
/*LONGVARCHAR*/   {Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,     Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,    Const.NONE,    Const.NONE,   Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, 	Const.NONE,    Const.NONE, 	       Const.NONE,    Const.NONE,	   Const.NONE}, /*LONGVARCHAR*/
/*DOUB*/ 	  {Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,     Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,    Const.NONE,    Const.NONE,   Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, 	Const.NONE,    Const.NONE, 	       Const.NONE,    Const.NONE,	   Const.NONE}, /*DOUB*/
/*CDOUB*/ 	  {Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,     Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,    Const.NONE,    Const.NONE,   Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, 	Const.NONE,    Const.NONE, 	       Const.NONE,    Const.NONE,	   Const.NONE}, /*CDOUB*/
/*DECIMAL*/ 	  {Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,     Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,    Const.NONE,    Const.NONE,   Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, 	Const.NONE,    Const.NONE, 	       Const.NONE,    Const.NONE,	   Const.NONE}, /*DECIMAL*/
/*NUMERIC*/ 	  {Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,     Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,    Const.NONE,    Const.NONE,   Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, 	Const.NONE,    Const.NONE, 	       Const.NONE,    Const.NONE,	   Const.NONE}, /*NUMERIC*/
/*FLOAT*/ 	  {Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,     Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,    Const.NONE,    Const.NONE,   Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, 	Const.NONE,    Const.NONE, 	       Const.NONE,    Const.NONE,	   Const.NONE}, /*FLOAT*/
/*REAL*/ 	  {Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,     Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,    Const.NONE,    Const.NONE,   Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, 	Const.NONE,    Const.NONE, 	       Const.NONE,    Const.NONE,	   Const.NONE}, /*REAL*/
/*INT*/ 	  {Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,     Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,    Const.NONE,    Const.NONE,   Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, 	Const.NONE,    Const.NONE, 	       Const.NONE,    Const.NONE,	   Const.NONE}, /*INT*/
/*CINT*/	  {Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,     Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,    Const.NONE,    Const.NONE,   Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, 	Const.NONE,    Const.NONE, 	       Const.NONE,    Const.NONE,	   Const.NONE}, /*CINT*/
/*SMALLINT*/ 	  {Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,     Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,    Const.NONE,    Const.NONE,   Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, 	Const.NONE,    Const.NONE, 	       Const.NONE,    Const.NONE,	   Const.NONE}, /*SMALLINT*/
/*TINYINT*/ 	  {Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,     Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,    Const.NONE,    Const.NONE,   Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, 	Const.NONE,    Const.NONE, 	       Const.NONE,    Const.NONE,	   Const.NONE}, /*TINYINT*/
/*BIGINT*/ 	  {Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,     Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,    Const.NONE,    Const.NONE,   Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, 	Const.NONE,    Const.NONE, 	       Const.NONE,    Const.NONE,	   Const.NONE}, /*BIGINT*/
/*DATE*/	  {Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,     Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,    Const.NONE,    Const.NONE,   Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, 	Const.NONE,    Const.NONE, 	       Const.NONE,    Const.NONE, 	   Const.NONE}, /*DATE*/
/*CDAT*/	  {Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,     Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,    Const.NONE,    Const.NONE,   Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, 	Const.NONE,    Const.NONE,	       Const.NONE,    Const.NONE, 	   Const.NONE}, /*CDAT*/
/*TIME*/	  {Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,     Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,    Const.NONE,    Const.NONE,   Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, 	Const.NONE,    Const.NONE,	       Const.NONE,    Const.NONE,          Const.NONE}, /*TIME*/
/*CTIM*/	  {Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,     Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,    Const.NONE,    Const.NONE,   Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, 	Const.NONE,    Const.NONE,             Const.NONE,    Const.NONE,          Const.NONE}, /*CTIM*/
/*TIMESTAMP*/	  {Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,     Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,    Const.NONE,    Const.NONE,   Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, 	Const.NONE,    Const.NONE,	       Const.NONE,    Const.NONE,          Const.NONE}, /*TIMESTAMP*/
/*BOOL*/	  {Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,     Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,    Const.NONE,    Const.NONE,   Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, 	Const.BOOLEAN, Const.BOOLEAN,          Const.BOOLEAN, Const.BOOLEAN,       Const.NONE}, /*BOOL*/
/*CBOO*/	  {Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,     Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,    Const.NONE,    Const.NONE,   Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, 	Const.BOOLEAN, Const.CONST_BOOLEAN,    Const.BOOLEAN, Const.CONST_BOOLEAN, Const.NONE}, /*CBOO*/
/*NULL*/	  {Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,     Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,    Const.NONE,    Const.NONE,   Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, 	Const.BOOLEAN, Const.BOOLEAN,          Const.BOOLEAN, Const.BOOLEAN,       Const.NONE}, /*NULL*/
/*CNUL*/	  {Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,     Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,    Const.NONE,    Const.NONE,   Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, 	Const.BOOLEAN, Const.CONST_BOOLEAN,    Const.BOOLEAN, Const.BOOLEAN,       Const.NONE}, /*CNUL*/
/*WILD*/	  {Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,     Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,    Const.NONE,    Const.NONE,   Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, 	Const.NONE,    Const.NONE,             Const.NONE,    Const.NONE, 	   Const.NONE}  /*WILD*/
   };

   private int[] logicUnaryOpResultType =
      /*NONE*/   /*CHAR*/     /*CSTR*/    /*VARCHAR*/   /*LONGVARCHAR*/  /*DOUB*/    /*CDOUB*/   /*DECIMAL*/ /*NUMERIC*/ /*FLOAT*/   /*REAL*/    /*INT*/     /*CINT*/    /*SMALLINT*/ /*TINYINT*/  /*BIGINT*/  /*DATE*/    /*CDAT*/    /*TIME*/    /*CTIM*/    /*TIMESTAMP*/    /*BOOL*/       /*CBOO*/       /*NULL*/    /*CNUL*/     /*WILD*/
     {Const.NONE, Const.NONE, Const.NONE,  Const.NONE,  Const.NONE,      Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,  Const.NONE,  Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,      Const.BOOLEAN, Const.BOOLEAN, Const.NONE, Const.NONE, Const.NONE};

   private int[][] relationalOpResultType =
   {    	   /*NONE*/    /*CHAR*/        /*CSTR*/            /*VARCHAR*/    /*LONGVARCHAR*/   /*DOUB*/       /*CDOUB*/            /*DECIMAL*/    /*NUMERIC*/    /*FLOAT*/      /*REAL*/       /*INT*/        /*CINT*/      	/*SMALLINT*/   /*TINYINT*/    /*BIGINT*/     /*DATE*/       /*CDAT*/   	         /*TIME*/       /*CTIM*/       	     /*TIMESTAMP*/  /*BOOL*/       /*CBOO*/    	 	 /*NULL*/       /*CNUL*/    	        /*WILD*/
/*NONE*/	  {Const.NONE, Const.NONE,    Const.NONE,   	   Const.NONE,    Const.NONE,       Const.NONE,    Const.NONE,          Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,          Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,	         Const.NONE,    Const.NONE,	     Const.NONE,    Const.NONE,    Const.NONE, 	  	 Const.NONE,    Const.NONE, 	    	Const.NONE},/*NONE*/
/*CHAR*/	  {Const.NONE, Const.BOOLEAN, Const.BOOLEAN, 	   Const.BOOLEAN, Const.BOOLEAN,    Const.NONE,    Const.NONE,          Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,          Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,	         Const.NONE,    Const.NONE,	     Const.NONE,    Const.NONE,    Const.NONE, 	 	 Const.BOOLEAN, Const.BOOLEAN, 		Const.NONE},/*CHAR*/
/*CSTR*/	  {Const.NONE, Const.BOOLEAN, Const.BOOLEAN,	   Const.BOOLEAN, Const.BOOLEAN,    Const.NONE,    Const.NONE,          Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,          Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,	         Const.NONE,    Const.NONE,	     Const.NONE,    Const.NONE,    Const.NONE, 	 	 Const.BOOLEAN, Const.CONST_BOOLEAN,    Const.NONE},/*CSTR*/
/*VARCHAR*/	  {Const.NONE, Const.BOOLEAN, Const.BOOLEAN, 	   Const.BOOLEAN, Const.BOOLEAN,    Const.NONE,    Const.NONE,          Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,          Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,	         Const.NONE,    Const.NONE,	     Const.NONE,    Const.NONE,    Const.NONE, 	 	 Const.BOOLEAN, Const.BOOLEAN, 		Const.NONE},/*VARCHAR*/
/*LONGVARCHAR*/   {Const.NONE, Const.BOOLEAN, Const.BOOLEAN, 	   Const.BOOLEAN, Const.BOOLEAN,    Const.NONE,    Const.NONE,          Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,          Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,	         Const.NONE,    Const.NONE,	     Const.NONE,    Const.NONE,    Const.NONE, 	 	 Const.BOOLEAN, Const.BOOLEAN, 		Const.NONE},/*LONGVARCHAR*/
/*DOUB*/ 	  {Const.NONE, Const.NONE,    Const.NONE, 	   Const.NONE,    Const.NONE,       Const.BOOLEAN, Const.BOOLEAN,       Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN,       Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN,       Const.BOOLEAN, Const.BOOLEAN,       Const.BOOLEAN, Const.NONE,    Const.NONE, 	 	 Const.BOOLEAN, Const.BOOLEAN, 		Const.NONE},/*DOUB*/
/*CDOUB*/	  {Const.NONE, Const.NONE,    Const.NONE, 	   Const.NONE,    Const.NONE,       Const.BOOLEAN, Const.CONST_BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.CONST_BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.CONST_BOOLEAN, Const.BOOLEAN, Const.CONST_BOOLEAN, Const.BOOLEAN, Const.NONE,    Const.NONE, 	 	 Const.BOOLEAN, Const.CONST_BOOLEAN,    Const.NONE},/*CDOUB*
/*DECIMAL*/ 	  {Const.NONE, Const.NONE,    Const.NONE, 	   Const.NONE,    Const.NONE,       Const.BOOLEAN, Const.BOOLEAN,       Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN,       Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN,       Const.BOOLEAN, Const.BOOLEAN,       Const.BOOLEAN, Const.NONE,    Const.NONE, 	 	 Const.BOOLEAN, Const.BOOLEAN, 		Const.NONE},/*DECIMAL*/
/*NUMERIC*/ 	  {Const.NONE, Const.NONE,    Const.NONE, 	   Const.NONE,    Const.NONE,       Const.BOOLEAN, Const.BOOLEAN,       Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN,       Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN,       Const.BOOLEAN, Const.BOOLEAN,       Const.BOOLEAN, Const.NONE,    Const.NONE, 	 	 Const.BOOLEAN, Const.BOOLEAN, 		Const.NONE},/*NUMERIC*/
/*FLOAT*/ 	  {Const.NONE, Const.NONE,    Const.NONE, 	   Const.NONE,    Const.NONE,       Const.BOOLEAN, Const.BOOLEAN,       Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN,       Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN,       Const.BOOLEAN, Const.BOOLEAN,       Const.BOOLEAN, Const.NONE,    Const.NONE, 	 	 Const.BOOLEAN, Const.BOOLEAN, 		Const.NONE},/*FLOAT*/
/*REAL*/ 	  {Const.NONE, Const.NONE,    Const.NONE, 	   Const.NONE,    Const.NONE,       Const.BOOLEAN, Const.BOOLEAN,       Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN,       Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN,       Const.BOOLEAN, Const.BOOLEAN,       Const.BOOLEAN, Const.NONE,    Const.NONE, 	 	 Const.BOOLEAN, Const.BOOLEAN, 		Const.NONE},/*REAL*/
/*INT*/ 	  {Const.NONE, Const.NONE,    Const.NONE, 	   Const.NONE,    Const.NONE,       Const.BOOLEAN, Const.BOOLEAN,       Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN,       Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN,       Const.BOOLEAN, Const.BOOLEAN,       Const.BOOLEAN, Const.NONE,    Const.NONE, 	 	 Const.BOOLEAN, Const.BOOLEAN, 		Const.NONE},/*INT*/
/*CINT*/	  {Const.NONE, Const.NONE,    Const.NONE, 	   Const.NONE,    Const.NONE,       Const.BOOLEAN, Const.CONST_BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.CONST_BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.CONST_BOOLEAN, Const.BOOLEAN, Const.CONST_BOOLEAN, Const.BOOLEAN, Const.NONE,    Const.NONE, 	 	 Const.BOOLEAN, Const.CONST_BOOLEAN,    Const.NONE},/*CINT*/
/*SMALLINT*/ 	  {Const.NONE, Const.NONE,    Const.NONE, 	   Const.NONE,    Const.NONE,       Const.BOOLEAN, Const.BOOLEAN,       Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN,       Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN,       Const.BOOLEAN, Const.BOOLEAN,       Const.BOOLEAN, Const.NONE,    Const.NONE, 	 	 Const.BOOLEAN, Const.BOOLEAN, 		Const.NONE},/*SMALLINT*/
/*TINYINT*/ 	  {Const.NONE, Const.NONE,    Const.NONE, 	   Const.NONE,    Const.NONE,       Const.BOOLEAN, Const.BOOLEAN,       Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN,       Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN,       Const.BOOLEAN, Const.BOOLEAN,       Const.BOOLEAN, Const.NONE,    Const.NONE, 	 	 Const.BOOLEAN, Const.BOOLEAN, 		Const.NONE},/*TINYINT*/
/*BIGINT*/ 	  {Const.NONE, Const.NONE,    Const.NONE, 	   Const.NONE,    Const.NONE,       Const.BOOLEAN, Const.BOOLEAN,       Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN,       Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN,       Const.BOOLEAN, Const.BOOLEAN,       Const.BOOLEAN, Const.NONE,    Const.NONE, 	 	 Const.BOOLEAN, Const.BOOLEAN, 		Const.NONE},/*BIGINT*/
/*DATE*/	  {Const.NONE, Const.NONE,    Const.NONE, 	   Const.NONE,    Const.NONE,       Const.BOOLEAN, Const.BOOLEAN,       Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN,       Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN,       Const.BOOLEAN, Const.BOOLEAN,       Const.BOOLEAN, Const.NONE,    Const.NONE, 	 	 Const.BOOLEAN, Const.BOOLEAN, 		Const.NONE},/*DATE*/
/*CDAT*/	  {Const.NONE, Const.NONE,    Const.NONE, 	   Const.NONE,    Const.NONE,       Const.BOOLEAN, Const.CONST_BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.CONST_BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.CONST_BOOLEAN, Const.BOOLEAN, Const.CONST_BOOLEAN, Const.BOOLEAN, Const.NONE,    Const.NONE, 	 	 Const.BOOLEAN, Const.CONST_BOOLEAN,    Const.NONE},/*CDAT*/
/*TIME*/	  {Const.NONE, Const.NONE,    Const.NONE,	   Const.NONE,    Const.NONE,       Const.BOOLEAN, Const.BOOLEAN,       Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN,       Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN,       Const.BOOLEAN, Const.BOOLEAN,       Const.BOOLEAN, Const.NONE,    Const.NONE, 	 	 Const.BOOLEAN, Const.BOOLEAN, 		Const.NONE},/*TIME*/
/*CTIM*/	  {Const.NONE, Const.NONE,    Const.NONE,    	   Const.NONE,    Const.NONE,       Const.BOOLEAN, Const.CONST_BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.CONST_BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.CONST_BOOLEAN, Const.BOOLEAN, Const.CONST_BOOLEAN, Const.BOOLEAN, Const.NONE,    Const.NONE, 	 	 Const.BOOLEAN, Const.CONST_BOOLEAN,    Const.NONE},/*CTIM*/
/*TIMESTAMP*/	  {Const.NONE, Const.NONE,    Const.NONE,	   Const.NONE,    Const.NONE,       Const.BOOLEAN, Const.BOOLEAN,       Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN,       Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN,       Const.BOOLEAN, Const.BOOLEAN,       Const.BOOLEAN, Const.NONE,    Const.NONE, 	 	 Const.BOOLEAN, Const.BOOLEAN, 		Const.NONE},/*TIMESTAMP*/
/*BOOL*/	  {Const.NONE, Const.NONE,    Const.NONE,          Const.NONE,    Const.NONE,       Const.NONE,    Const.NONE, 	        Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE, 	        Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,	         Const.NONE,    Const.NONE,	     Const.NONE,    Const.BOOLEAN, Const.BOOLEAN,        Const.BOOLEAN, Const.BOOLEAN, 		Const.NONE},/*BOOL*/
/*CBOO*/	  {Const.NONE, Const.NONE,    Const.NONE,          Const.NONE,    Const.NONE,       Const.NONE,    Const.NONE,	        Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,	    	Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,	         Const.NONE,    Const.NONE,	     Const.NONE,    Const.BOOLEAN, Const.BOOLEAN,        Const.BOOLEAN, Const.CONST_BOOLEAN,    Const.NONE},/*CBOO*/
/*NULL*/	  {Const.NONE, Const.BOOLEAN, Const.BOOLEAN,       Const.BOOLEAN, Const.BOOLEAN,    Const.BOOLEAN, Const.BOOLEAN,       Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN,       Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN,       Const.BOOLEAN, Const.BOOLEAN,       Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN,        Const.BOOLEAN, Const.BOOLEAN,	        Const.NONE},/*NULL*/
/*CNUL*/	  {Const.NONE, Const.BOOLEAN, Const.CONST_BOOLEAN, Const.BOOLEAN, Const.BOOLEAN,    Const.BOOLEAN, Const.CONST_BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.CONST_BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.CONST_BOOLEAN, Const.BOOLEAN, Const.CONST_BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.CONST_BOOLEAN,  Const.BOOLEAN, Const.CONST_BOOLEAN,    Const.NONE},/*CNUL*/
/*WILD*/	  {Const.NONE, Const.NONE,    Const.NONE,          Const.NONE,    Const.NONE,       Const.NONE,    Const.NONE, 	        Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE, 	    	Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,	         Const.NONE,    Const.NONE,	     Const.NONE,    Const.NONE,    Const.NONE,	         Const.NONE,    Const.NONE,    		Const.NONE} /*WILD*/
   };

   private int[][] nullIfResultType =
   {     	   /*NONE*/    /*CHAR*/           /*CSTR*/            /*VARCHAR*/        /*LONGVARCHAR*/       /*DOUB*/        /*CDOUB*/       /*DECIMAL*/     /*NUMERIC*/     /*FLOAT*/       /*REAL*/        /*INT*/         /*CINT*/        /*SMALLINT*/    /*TINYINT*/     /*BIGINT*/      /*DATE*/       /*CDAT*/       /*TIME*/       /*CTIM*/       /*TIMESTAMP*/  /*BOOL*/        /*CBOO*/        /*NULL*/             /*CNUL*/            /*WILD*/
/*NONE*/ 	  {Const.NONE, Const.NONE,        Const.NONE,         Const.NONE,        Const.NONE,           Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,     Const.NONE,     Const.NONE,         Const.NONE,         Const.NONE}, /*NONE*/
/*CHAR*/ 	  {Const.NONE, Const.VARCHAR,     Const.VARCHAR,      Const.VARCHAR,     Const.VARCHAR,        Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,     Const.NONE,     Const.VARCHAR,      Const.VARCHAR,      Const.NONE}, /*CHAR*/
/*CSTR*/ 	  {Const.NONE, Const.VARCHAR,     Const.VARCHAR,      Const.VARCHAR,     Const.VARCHAR,        Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,     Const.NONE,     Const.VARCHAR,      Const.VARCHAR,      Const.NONE}, /*CSTR*/
/*VARCHAR*/	  {Const.NONE, Const.VARCHAR,     Const.VARCHAR,      Const.VARCHAR,     Const.VARCHAR,        Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,     Const.NONE,     Const.VARCHAR,      Const.VARCHAR,      Const.NONE}, /*VARCHAR*/
/*LONGVARCHAR*/   {Const.NONE, Const.LONGVARCHAR, Const.LONGVARCHAR,  Const.LONGVARCHAR, Const.LONGVARCHAR,    Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,     Const.NONE,     Const.LONGVARCHAR,  Const.LONGVARCHAR,  Const.NONE}, /*LONGVARCHAR*/
/*DOUB*/ 	  {Const.NONE, Const.NONE,        Const.NONE,         Const.NONE,        Const.NONE,           Const.DOUBLE,   Const.DOUBLE,   Const.DOUBLE,   Const.DOUBLE,   Const.DOUBLE,   Const.DOUBLE,   Const.DOUBLE,   Const.DOUBLE,   Const.DOUBLE,   Const.DOUBLE,   Const.DOUBLE,   Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,     Const.NONE,     Const.DOUBLE,       Const.DOUBLE,       Const.NONE}, /*DOUB*/
/*CDOUB*/	  {Const.NONE, Const.NONE,        Const.NONE,         Const.NONE,        Const.NONE,           Const.DOUBLE,   Const.DOUBLE,   Const.DOUBLE,   Const.DOUBLE,   Const.DOUBLE,   Const.DOUBLE,   Const.DOUBLE,   Const.DOUBLE,   Const.DOUBLE,   Const.DOUBLE,   Const.DOUBLE,   Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,     Const.NONE,     Const.DOUBLE,       Const.DOUBLE,       Const.NONE}, /*CDOUB*/
/*DECIMAL*/ 	  {Const.NONE, Const.NONE,        Const.NONE,         Const.NONE,        Const.NONE,           Const.DECIMAL,  Const.DECIMAL,  Const.DECIMAL,  Const.DECIMAL,  Const.DECIMAL,  Const.DECIMAL,  Const.DECIMAL,  Const.DECIMAL,  Const.DECIMAL,  Const.DECIMAL,  Const.DECIMAL,  Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,     Const.NONE,     Const.DECIMAL,      Const.DECIMAL,      Const.NONE}, /*DECIMAL*/
/*NUMERIC*/ 	  {Const.NONE, Const.NONE,        Const.NONE,         Const.NONE,        Const.NONE,           Const.NUMERIC,  Const.NUMERIC,  Const.NUMERIC,  Const.NUMERIC,  Const.NUMERIC,  Const.NUMERIC,  Const.NUMERIC,  Const.NUMERIC,  Const.NUMERIC,  Const.NUMERIC,  Const.NUMERIC,  Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,     Const.NONE,     Const.NUMERIC,      Const.NUMERIC,      Const.NONE}, /*NUMERIC*/
/*FLOAT*/ 	  {Const.NONE, Const.NONE,        Const.NONE,         Const.NONE,        Const.NONE,           Const.FLOAT,    Const.FLOAT,    Const.FLOAT,    Const.FLOAT,    Const.FLOAT,    Const.FLOAT,    Const.FLOAT,    Const.FLOAT,    Const.FLOAT,    Const.FLOAT,    Const.FLOAT,    Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,     Const.NONE,     Const.FLOAT,        Const.FLOAT,        Const.NONE}, /*FLOAT*/
/*REAL*/ 	  {Const.NONE, Const.NONE,        Const.NONE,         Const.NONE,        Const.NONE,           Const.REAL,     Const.REAL,     Const.REAL,     Const.REAL,     Const.REAL,     Const.REAL,     Const.REAL,     Const.REAL,     Const.REAL,     Const.REAL,     Const.REAL,     Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,     Const.NONE,     Const.REAL,         Const.REAL,         Const.NONE}, /*REAL*/
/*INT*/ 	  {Const.NONE, Const.NONE,        Const.NONE,         Const.NONE,        Const.NONE,           Const.INTEGER,  Const.INTEGER,  Const.INTEGER,  Const.INTEGER,  Const.INTEGER,  Const.INTEGER,  Const.INTEGER,  Const.INTEGER,  Const.INTEGER,  Const.INTEGER,  Const.INTEGER,  Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,     Const.NONE,     Const.INTEGER,      Const.INTEGER,      Const.NONE}, /*INT*/
/*CINT*/	  {Const.NONE, Const.NONE,        Const.NONE,         Const.NONE,        Const.NONE,           Const.INTEGER,  Const.INTEGER,  Const.INTEGER,  Const.INTEGER,  Const.INTEGER,  Const.INTEGER,  Const.INTEGER,  Const.INTEGER,  Const.INTEGER,  Const.INTEGER,  Const.INTEGER,  Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,     Const.NONE,     Const.INTEGER,      Const.INTEGER,      Const.NONE}, /*CINT*/
/*SMALLINT*/ 	  {Const.NONE, Const.NONE,        Const.NONE,         Const.NONE,        Const.NONE,           Const.SMALLINT, Const.SMALLINT, Const.SMALLINT, Const.SMALLINT, Const.SMALLINT, Const.SMALLINT, Const.SMALLINT, Const.SMALLINT, Const.SMALLINT, Const.SMALLINT, Const.SMALLINT, Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,     Const.NONE,     Const.SMALLINT,     Const.SMALLINT,     Const.NONE}, /*SMALLINT*/
/*TINYINT*/ 	  {Const.NONE, Const.NONE,        Const.NONE,         Const.NONE,        Const.NONE,           Const.TINYINT,  Const.TINYINT,  Const.TINYINT,  Const.TINYINT,  Const.TINYINT,  Const.TINYINT,  Const.TINYINT,  Const.TINYINT,  Const.TINYINT,  Const.TINYINT,  Const.TINYINT,  Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,     Const.NONE,     Const.TINYINT,      Const.TINYINT,      Const.NONE}, /*TINYINT*/
/*BIGINT*/ 	  {Const.NONE, Const.NONE,        Const.NONE,         Const.NONE,        Const.NONE,           Const.BIGINT,   Const.BIGINT,   Const.BIGINT,   Const.BIGINT,   Const.BIGINT,   Const.BIGINT,   Const.BIGINT,   Const.BIGINT,   Const.BIGINT,   Const.BIGINT,   Const.BIGINT,   Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,     Const.NONE,     Const.BIGINT,       Const.BIGINT,       Const.NONE}, /*BIGINT*/
/*DATE*/	  {Const.NONE, Const.NONE,        Const.NONE,         Const.NONE,        Const.NONE,           Const.VARCHAR,  Const.VARCHAR,  Const.VARCHAR,  Const.VARCHAR,  Const.VARCHAR,  Const.VARCHAR,  Const.VARCHAR,  Const.VARCHAR,  Const.VARCHAR,  Const.VARCHAR,  Const.VARCHAR,  Const.VARCHAR, Const.VARCHAR, Const.VARCHAR, Const.VARCHAR, Const.VARCHAR, Const.NONE,     Const.NONE,     Const.DATE,         Const.DATE,         Const.NONE}, /*DATE*/
/*CDAT*/	  {Const.NONE, Const.NONE,        Const.NONE,         Const.NONE,        Const.NONE,           Const.VARCHAR,  Const.VARCHAR,  Const.VARCHAR,  Const.VARCHAR,  Const.VARCHAR,  Const.VARCHAR,  Const.VARCHAR,  Const.VARCHAR,  Const.VARCHAR,  Const.VARCHAR,  Const.VARCHAR,  Const.VARCHAR, Const.VARCHAR, Const.VARCHAR, Const.VARCHAR, Const.VARCHAR, Const.NONE,     Const.NONE,     Const.DATE,         Const.DATE,         Const.NONE}, /*CDAT*/
/*TIME*/	  {Const.NONE, Const.NONE,        Const.NONE,         Const.NONE,        Const.NONE,           Const.VARCHAR,  Const.VARCHAR,  Const.VARCHAR,  Const.VARCHAR,  Const.VARCHAR,  Const.VARCHAR,  Const.VARCHAR,  Const.VARCHAR,  Const.VARCHAR,  Const.VARCHAR,  Const.VARCHAR,  Const.VARCHAR, Const.VARCHAR, Const.VARCHAR, Const.VARCHAR, Const.VARCHAR, Const.NONE,     Const.NONE,     Const.TIME,         Const.TIME,         Const.NONE}, /*TIME*/
/*CTIM*/	  {Const.NONE, Const.NONE,        Const.NONE,         Const.NONE,        Const.NONE,           Const.VARCHAR,  Const.VARCHAR,  Const.VARCHAR,  Const.VARCHAR,  Const.VARCHAR,  Const.VARCHAR,  Const.VARCHAR,  Const.VARCHAR,  Const.VARCHAR,  Const.VARCHAR,  Const.VARCHAR,  Const.VARCHAR, Const.VARCHAR, Const.VARCHAR, Const.VARCHAR, Const.VARCHAR, Const.NONE,     Const.NONE,     Const.TIME,         Const.TIME,         Const.NONE}, /*CTIM*/
/*TIMESTAMP*/	  {Const.NONE, Const.NONE,        Const.NONE,         Const.NONE,        Const.NONE,           Const.VARCHAR,  Const.VARCHAR,  Const.VARCHAR,  Const.VARCHAR,  Const.VARCHAR,  Const.VARCHAR,  Const.VARCHAR,  Const.VARCHAR,  Const.VARCHAR,  Const.VARCHAR,  Const.VARCHAR,  Const.VARCHAR, Const.VARCHAR, Const.VARCHAR, Const.VARCHAR, Const.VARCHAR, Const.NONE,     Const.NONE,     Const.TIMESTAMP,    Const.TIMESTAMP,    Const.NONE}, /*TIMESTAMP*/
/*BOOL*/	  {Const.NONE, Const.NONE,        Const.NONE,         Const.NONE,        Const.NONE,           Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,      Const.NONE}, /*BOOL*/
/*CBOO*/	  {Const.NONE, Const.NONE,        Const.NONE,         Const.NONE,        Const.NONE,           Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,      Const.NONE}, /*CBOO*/
/*NULL*/	  {Const.NONE, Const.VARCHAR,     Const.VARCHAR,      Const.VARCHAR,     Const.VARCHAR,        Const.VARCHAR,  Const.VARCHAR,  Const.VARCHAR,  Const.VARCHAR,  Const.VARCHAR,  Const.VARCHAR,  Const.VARCHAR,  Const.VARCHAR,  Const.VARCHAR,  Const.VARCHAR,  Const.VARCHAR,  Const.VARCHAR, Const.VARCHAR, Const.VARCHAR, Const.VARCHAR, Const.VARCHAR, Const.VARCHAR,  Const.VARCHAR,  Const.VARCHAR,      Const.VARCHAR,      Const.NONE}, /*NULL*/
/*CNUL*/	  {Const.NONE, Const.VARCHAR,     Const.VARCHAR,      Const.VARCHAR,     Const.VARCHAR,        Const.VARCHAR,  Const.VARCHAR,  Const.VARCHAR,  Const.VARCHAR,  Const.VARCHAR,  Const.VARCHAR,  Const.VARCHAR,  Const.VARCHAR,  Const.VARCHAR,  Const.VARCHAR,  Const.VARCHAR,  Const.VARCHAR, Const.VARCHAR, Const.VARCHAR, Const.VARCHAR, Const.VARCHAR, Const.VARCHAR,  Const.VARCHAR,  Const.VARCHAR,      Const.VARCHAR,      Const.NONE}, /*CNUL*/
/*WILD*/	  {Const.NONE, Const.NONE,        Const.NONE,         Const.NONE,        Const.NONE,           Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.BOOLEAN,  Const.BOOLEAN,  Const.NONE,         Const.NONE,         Const.NONE}  /*WILD*/
   };

   private int[][] coalesceResultType =
   {     	   /*NONE*/    /*CHAR*/     	   /*CSTR*/          /*VARCHAR*/    	/*LONGVARCHAR*/       /*DOUB*/      /*CDOUB*/     /*DECIMAL*/    /*NUMERIC*/    /*FLOAT*/     /*REAL*/      /*INT*/        /*CINT*/       /*SMALLINT*/    /*TINYINT*/     /*BIGINT*/     /*DATE*/      /*CDAT*/      /*TIME*/           /*CTIM*/           /*TIMESTAMP*/      /*BOOL*/       /*CBOO*/       /*NULL*/      	    /*CNUL*/            /*WILD*/
/*NONE*/   	  {Const.NONE, Const.NONE,  	  Const.NONE,        Const.NONE,        Const.NONE,           Const.NONE,   Const.NONE,   Const.NONE,    Const.NONE,    Const.NONE,   Const.NONE,   Const.NONE,    Const.NONE,    Const.NONE,     Const.NONE,     Const.NONE,    Const.NONE,   Const.NONE,   Const.NONE,        Const.NONE,        Const.NONE,        Const.NONE,    Const.NONE,    Const.NONE,             Const.NONE,         Const.NONE },/*NONE*/
/*CHAR*/   	  {Const.NONE, Const.VARCHAR, 	  Const.VARCHAR,     Const.VARCHAR,     Const.LONGVARCHAR,    Const.NONE,   Const.NONE,   Const.NONE,    Const.NONE,    Const.NONE,   Const.NONE,   Const.NONE,    Const.NONE,    Const.NONE,     Const.NONE,     Const.NONE,    Const.NONE,   Const.NONE,   Const.NONE,        Const.NONE,        Const.NONE,        Const.NONE,    Const.NONE,    Const.VARCHAR,	    Const.VARCHAR,      Const.NONE },/*CHAR*/
/*CSTR*/   	  {Const.NONE, Const.VARCHAR, 	  Const.VARCHAR,     Const.VARCHAR,     Const.LONGVARCHAR,    Const.NONE,   Const.NONE,   Const.NONE,    Const.NONE,    Const.NONE,   Const.NONE,   Const.NONE,    Const.NONE,    Const.NONE,     Const.NONE,     Const.NONE,    Const.NONE,   Const.NONE,   Const.NONE,        Const.NONE,        Const.NONE,        Const.NONE,    Const.NONE,    Const.VARCHAR,	    Const.VARCHAR,      Const.NONE },/*CSTR*/
/*VARCHAR*/  	  {Const.NONE, Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,     Const.LONGVARCHAR,    Const.NONE,   Const.NONE,   Const.NONE,    Const.NONE,    Const.NONE,   Const.NONE,   Const.NONE,    Const.NONE,    Const.NONE,     Const.NONE,     Const.NONE,    Const.NONE,   Const.NONE,   Const.NONE,        Const.NONE,        Const.NONE,        Const.NONE,    Const.NONE,    Const.VARCHAR,	    Const.VARCHAR,      Const.NONE },/*VARCHAR*/
/*LONGVARCHAR*/   {Const.NONE, Const.LONGVARCHAR, Const.LONGVARCHAR, Const.LONGVARCHAR, Const.LONGVARCHAR,    Const.NONE,   Const.NONE,   Const.NONE,    Const.NONE,    Const.NONE,   Const.NONE,   Const.NONE,    Const.NONE,    Const.NONE,     Const.NONE,     Const.NONE,    Const.NONE,   Const.NONE,   Const.NONE,        Const.NONE,        Const.NONE,        Const.NONE,    Const.NONE,    Const.LONGVARCHAR,      Const.LONGVARCHAR,  Const.NONE },/*LONGVARCHAR*/
/*DOUB*/ 	  {Const.NONE, Const.NONE,  	  Const.NONE, 	     Const.NONE,        Const.NONE,           Const.DOUBLE, Const.DOUBLE, Const.DOUBLE,  Const.DOUBLE,  Const.DOUBLE, Const.DOUBLE, Const.DOUBLE,  Const.DOUBLE,  Const.DOUBLE,   Const.DOUBLE,   Const.DOUBLE,  Const.NONE,   Const.NONE,   Const.NONE,        Const.NONE,        Const.NONE,        Const.NONE,    Const.NONE,    Const.DOUBLE, 	    Const.DOUBLE,       Const.NONE },/*DOUB*/
/*CDOUB*/	  {Const.NONE, Const.NONE,  	  Const.NONE,	     Const.NONE,        Const.NONE,           Const.DOUBLE, Const.DOUBLE, Const.DOUBLE,  Const.DOUBLE,  Const.DOUBLE, Const.DOUBLE, Const.DOUBLE,  Const.DOUBLE,  Const.DOUBLE,   Const.DOUBLE,   Const.DOUBLE,  Const.NONE,   Const.NONE,   Const.NONE,        Const.NONE,        Const.NONE,        Const.NONE,    Const.NONE,    Const.DOUBLE, 	    Const.DOUBLE,       Const.NONE },/*CDOUB*/
/*DECIMAL*/ 	  {Const.NONE, Const.NONE,  	  Const.NONE, 	     Const.NONE,        Const.NONE,           Const.DOUBLE, Const.DOUBLE, Const.DECIMAL, Const.DECIMAL, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE,  Const.DOUBLE,  Const.DOUBLE,   Const.DOUBLE,   Const.DOUBLE,  Const.NONE,   Const.NONE,   Const.NONE,        Const.NONE,        Const.NONE,        Const.NONE,    Const.NONE,    Const.DECIMAL, 	    Const.DECIMAL,      Const.NONE },/*DECIMAL*/
/*NUMERIC*/ 	  {Const.NONE, Const.NONE,  	  Const.NONE, 	     Const.NONE,        Const.NONE,           Const.DOUBLE, Const.DOUBLE, Const.DECIMAL, Const.NUMERIC, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE,  Const.DOUBLE,  Const.DOUBLE,   Const.DOUBLE,   Const.DOUBLE,  Const.NONE,   Const.NONE,   Const.NONE,        Const.NONE,        Const.NONE,        Const.NONE,    Const.NONE,    Const.NUMERIC, 	    Const.NUMERIC,      Const.NONE },/*NUMERIC*/
/*FLOAT*/ 	  {Const.NONE, Const.NONE,  	  Const.NONE, 	     Const.NONE,        Const.NONE,           Const.DOUBLE, Const.DOUBLE, Const.DOUBLE,  Const.DOUBLE,  Const.DOUBLE, Const.DOUBLE, Const.DOUBLE,  Const.DOUBLE,  Const.DOUBLE,   Const.DOUBLE,   Const.DOUBLE,  Const.NONE,   Const.NONE,   Const.NONE,        Const.NONE,        Const.NONE,        Const.NONE,    Const.NONE,    Const.FLOAT, 	    Const.FLOAT,        Const.NONE },/*FLOAT*/
/*REAL*/ 	  {Const.NONE, Const.NONE,  	  Const.NONE, 	     Const.NONE,        Const.NONE,           Const.DOUBLE, Const.DOUBLE, Const.DOUBLE,  Const.DOUBLE,  Const.DOUBLE, Const.DOUBLE, Const.DOUBLE,  Const.DOUBLE,  Const.DOUBLE,   Const.DOUBLE,   Const.DOUBLE,  Const.NONE,   Const.NONE,   Const.NONE,        Const.NONE,        Const.NONE,        Const.NONE,    Const.NONE,    Const.REAL, 	    Const.REAL,         Const.NONE },/*REAL*/
/*INT*/  	  {Const.NONE, Const.NONE,  	  Const.NONE,	     Const.NONE,        Const.NONE,           Const.DOUBLE, Const.DOUBLE, Const.DOUBLE,  Const.DOUBLE,  Const.DOUBLE, Const.DOUBLE, Const.INTEGER, Const.INTEGER, Const.INTEGER,  Const.INTEGER,  Const.BIGINT,  Const.NONE,   Const.NONE,   Const.NONE,        Const.NONE,        Const.NONE,        Const.NONE,    Const.NONE,    Const.INTEGER,	    Const.INTEGER,      Const.NONE },/*INT*/
/*CINT*/ 	  {Const.NONE, Const.NONE,  	  Const.NONE,	     Const.NONE,    	Const.NONE,           Const.DOUBLE, Const.DOUBLE, Const.DOUBLE,  Const.DOUBLE,  Const.DOUBLE, Const.DOUBLE, Const.INTEGER, Const.INTEGER, Const.INTEGER,  Const.INTEGER,  Const.BIGINT,  Const.NONE,   Const.NONE,   Const.NONE,        Const.NONE,        Const.NONE,        Const.NONE,    Const.NONE,    Const.INTEGER,	    Const.INTEGER,      Const.NONE },/*CINT*/
/*SMALLINT*/  	  {Const.NONE, Const.NONE,  	  Const.NONE,	     Const.NONE,        Const.NONE,           Const.DOUBLE, Const.DOUBLE, Const.DOUBLE,  Const.DOUBLE,  Const.DOUBLE, Const.DOUBLE, Const.INTEGER, Const.INTEGER, Const.SMALLINT, Const.SMALLINT, Const.BIGINT,  Const.NONE,   Const.NONE,   Const.NONE,        Const.NONE,        Const.NONE,        Const.NONE,    Const.NONE,    Const.SMALLINT,	    Const.SMALLINT,     Const.NONE },/*SMALLINT*/
/*TINYINT*/  	  {Const.NONE, Const.NONE,  	  Const.NONE,	     Const.NONE,        Const.NONE,           Const.DOUBLE, Const.DOUBLE, Const.DOUBLE,  Const.DOUBLE,  Const.DOUBLE, Const.DOUBLE, Const.INTEGER, Const.INTEGER, Const.SMALLINT, Const.TINYINT,  Const.BIGINT,  Const.NONE,   Const.NONE,   Const.NONE,        Const.NONE,        Const.NONE,        Const.NONE,    Const.NONE,    Const.TINYINT,	    Const.TINYINT,      Const.NONE },/*TINYINT*/
/*BIGINT*/  	  {Const.NONE, Const.NONE,  	  Const.NONE,	     Const.NONE,        Const.NONE,           Const.DOUBLE, Const.DOUBLE, Const.DOUBLE,  Const.DOUBLE,  Const.DOUBLE, Const.DOUBLE, Const.BIGINT,  Const.BIGINT,  Const.BIGINT,   Const.BIGINT,   Const.BIGINT,  Const.NONE,   Const.NONE,   Const.NONE,        Const.NONE,        Const.NONE,        Const.NONE,    Const.NONE,    Const.BIGINT,	    Const.BIGINT,       Const.NONE },/*BIGINT*/
/*DATE*/ 	  {Const.NONE, Const.NONE,  	  Const.NONE,	     Const.NONE,    	Const.NONE,           Const.NONE,   Const.NONE,   Const.NONE,    Const.NONE,    Const.NONE,   Const.NONE,   Const.NONE,    Const.NONE,    Const.NONE,     Const.NONE,     Const.NONE,    Const.DATE,   Const.DATE,   Const.NONE,        Const.NONE,        Const.NONE,        Const.NONE,    Const.NONE,    Const.DATE,   	    Const.DATE,         Const.NONE },/*DATE*/
/*CDAT*/ 	  {Const.NONE, Const.NONE,  	  Const.NONE,	     Const.NONE,    	Const.NONE,           Const.NONE,   Const.NONE,   Const.NONE,    Const.NONE,    Const.NONE,   Const.NONE,   Const.NONE,    Const.NONE,    Const.NONE,     Const.NONE,     Const.NONE,    Const.DATE,   Const.DATE,   Const.NONE,        Const.NONE,        Const.NONE,        Const.NONE,    Const.NONE,    Const.DATE,   	    Const.DATE,         Const.NONE },/*CDAT*/
/*TIME*/ 	  {Const.NONE, Const.NONE,  	  Const.NONE,	     Const.NONE,    	Const.NONE,           Const.NONE,   Const.NONE,   Const.NONE,    Const.NONE,    Const.NONE,   Const.NONE,   Const.NONE,    Const.NONE,    Const.NONE,     Const.NONE,     Const.NONE,    Const.NONE,   Const.NONE,   Const.TIME,        Const.TIME,        Const.TIMESTAMP,   Const.NONE,    Const.NONE,    Const.TIME,   	    Const.TIME,         Const.NONE },/*TIME*/
/*CTIM*/ 	  {Const.NONE, Const.NONE,  	  Const.NONE,	     Const.NONE,    	Const.NONE,           Const.NONE,   Const.NONE,   Const.NONE,    Const.NONE,    Const.NONE,   Const.NONE,   Const.NONE,    Const.NONE,    Const.NONE,     Const.NONE,     Const.NONE,    Const.NONE,   Const.NONE,   Const.TIME,        Const.TIME,        Const.TIMESTAMP,   Const.NONE,    Const.NONE,    Const.TIME,   	    Const.TIME,         Const.NONE },/*CTIM*/
/*TIMESTAMP*/ 	  {Const.NONE, Const.NONE,  	  Const.NONE,	     Const.NONE,    	Const.NONE,           Const.NONE,   Const.NONE,   Const.NONE,    Const.NONE,    Const.NONE,   Const.NONE,   Const.NONE,    Const.NONE,    Const.NONE,     Const.NONE,     Const.NONE,    Const.NONE,   Const.NONE,   Const.TIMESTAMP,   Const.TIMESTAMP,   Const.TIMESTAMP,   Const.NONE,    Const.NONE,    Const.TIMESTAMP,   	    Const.TIMESTAMP,    Const.NONE },/*TIMESTAMP*/
/*BOOL*/ 	  {Const.NONE, Const.NONE,  	  Const.NONE,	     Const.NONE,    	Const.NONE,           Const.NONE,   Const.NONE,   Const.NONE,    Const.NONE,    Const.NONE,   Const.NONE,   Const.NONE,    Const.NONE,    Const.NONE,     Const.NONE,     Const.NONE,    Const.NONE,   Const.NONE,   Const.NONE,        Const.NONE,        Const.NONE,        Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN,	    Const.BOOLEAN,      Const.NONE },/*BOOL*/
/*CBOO*/ 	  {Const.NONE, Const.NONE,  	  Const.NONE,	     Const.NONE,    	Const.NONE,           Const.NONE,   Const.NONE,   Const.NONE,    Const.NONE,    Const.NONE,   Const.NONE,   Const.NONE,    Const.NONE,    Const.NONE,     Const.NONE,     Const.NONE,    Const.NONE,   Const.NONE,   Const.NONE,        Const.NONE,        Const.NONE,        Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN,	    Const.BOOLEAN,      Const.NONE },/*CBOO*/
/*NULL*/ 	  {Const.NONE, Const.VARCHAR,	  Const.VARCHAR,     Const.VARCHAR, 	Const.LONGVARCHAR,    Const.DOUBLE, Const.DOUBLE, Const.DECIMAL, Const.NUMERIC, Const.FLOAT,  Const.REAL,   Const.INTEGER, Const.INTEGER, Const.INTEGER,  Const.INTEGER,  Const.INTEGER, Const.DATE,   Const.DATE,   Const.TIME,        Const.TIME,        Const.TIME,        Const.BOOLEAN, Const.BOOLEAN, Const.VARCHAR,	    Const.VARCHAR,      Const.NONE },/*NULL*/
/*CNUL*/ 	  {Const.NONE, Const.VARCHAR,	  Const.VARCHAR,     Const.VARCHAR, 	Const.LONGVARCHAR,    Const.DOUBLE, Const.DOUBLE, Const.DECIMAL, Const.NUMERIC, Const.FLOAT,  Const.REAL,   Const.INTEGER, Const.INTEGER, Const.INTEGER,  Const.INTEGER,  Const.INTEGER, Const.DATE,   Const.DATE,   Const.TIME,        Const.TIME,        Const.TIME,        Const.BOOLEAN, Const.BOOLEAN, Const.VARCHAR,	    Const.VARCHAR,      Const.NONE },/*CNUL*/
/*WILD*/ 	  {Const.NONE, Const.NONE,  	  Const.NONE,        Const.NONE,    	Const.NONE,           Const.NONE,   Const.NONE,   Const.NONE,    Const.NONE,    Const.NONE,   Const.NONE,   Const.NONE,    Const.NONE,    Const.NONE,     Const.NONE,     Const.NONE,    Const.NONE,   Const.NONE,   Const.NONE,        Const.NONE,        Const.NONE,        Const.NONE,    Const.NONE,    Const.NONE,   	    Const.NONE,         Const.NONE } /*WILD*/
   };

   private int[][] caseResultType =
   {       	   /*NONE*/    /*CHAR*/            /*CSTR*/          /*VARCHAR*/        /*LONGVARCHAR*/      /*DOUB*/      /*CDOUB*/     /*DECIMAL*/   /*NUMERIC*/   /*FLOAT*/     /*REAL*/      /*INT*/        /*CINT*/       /*SMALLINT*/   /*TINYINT*/    /*BIGINT*/     /*DATE*/    /*CDAT*/    /*TIME*/    /*CTIM*/    /*TIMESTAMP*/    /*BOOL*/       /*CBOO*/       /*NULL*/             /*CNUL*/            /*WILD*/
/*NONE*/  	  {Const.NONE, Const.NONE,        Const.NONE,        Const.NONE,        Const.NONE,          Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,      Const.NONE,    Const.NONE,    Const.NONE,         Const.NONE,         Const.NONE },/*NONE*/
/*CHAR*/  	  {Const.NONE, Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,     Const.LONGVARCHAR,   Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,      Const.NONE,    Const.NONE,    Const.VARCHAR,      Const.VARCHAR,      Const.NONE },/*CHAR*/
/*CSTR*/  	  {Const.NONE, Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,     Const.LONGVARCHAR,   Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,      Const.NONE,    Const.NONE,    Const.VARCHAR,      Const.VARCHAR,      Const.NONE },/*CSTR*/
/*VARCHAR*/   	  {Const.NONE, Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,     Const.LONGVARCHAR,   Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,      Const.NONE,    Const.NONE,    Const.VARCHAR,      Const.VARCHAR,      Const.NONE },/*VARCHAR*/
/*LONGVARCHAR*/   {Const.NONE, Const.LONGVARCHAR, Const.LONGVARCHAR, Const.LONGVARCHAR, Const.LONGVARCHAR,   Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,      Const.NONE,    Const.NONE,    Const.LONGVARCHAR,  Const.LONGVARCHAR,  Const.NONE },/*LONGVARCHAR*/
/*DOUB*/ 	  {Const.NONE, Const.NONE,        Const.NONE,        Const.NONE,        Const.NONE,          Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE,  Const.DOUBLE,  Const.DOUBLE,  Const.DOUBLE,  Const.DOUBLE,  Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,      Const.NONE,    Const.NONE,    Const.DOUBLE,       Const.DOUBLE,       Const.NONE },/*DOUB*/
/*CDOUB*/	  {Const.NONE, Const.NONE,        Const.NONE,        Const.NONE,        Const.NONE,          Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE,  Const.DOUBLE,  Const.DOUBLE,  Const.DOUBLE,  Const.DOUBLE,  Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,      Const.NONE,    Const.NONE,    Const.DOUBLE,       Const.DOUBLE,       Const.NONE },/*CDOUB*/
/*DECIMAL*/ 	  {Const.NONE, Const.NONE,        Const.NONE,        Const.NONE,        Const.NONE,          Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE,  Const.DOUBLE,  Const.DOUBLE,  Const.DOUBLE,  Const.DOUBLE,  Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,      Const.NONE,    Const.NONE,    Const.DOUBLE,       Const.DOUBLE,       Const.NONE },/*DECIMAL*/
/*NUMERIC*/ 	  {Const.NONE, Const.NONE,        Const.NONE,        Const.NONE,        Const.NONE,          Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE,  Const.DOUBLE,  Const.DOUBLE,  Const.DOUBLE,  Const.DOUBLE,  Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,      Const.NONE,    Const.NONE,    Const.DOUBLE,       Const.DOUBLE,       Const.NONE },/*NUMERIC*/
/*FLOAT*/ 	  {Const.NONE, Const.NONE,        Const.NONE,        Const.NONE,        Const.NONE,          Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE,  Const.DOUBLE,  Const.DOUBLE,  Const.DOUBLE,  Const.DOUBLE,  Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,      Const.NONE,    Const.NONE,    Const.DOUBLE,       Const.DOUBLE,       Const.NONE },/*FLOAT*/
/*REAL*/ 	  {Const.NONE, Const.NONE,        Const.NONE,        Const.NONE,        Const.NONE,          Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE,  Const.DOUBLE,  Const.DOUBLE,  Const.DOUBLE,  Const.DOUBLE,  Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,      Const.NONE,    Const.NONE,    Const.DOUBLE,       Const.DOUBLE,       Const.NONE },/*REAL*/
/*INT*/ 	  {Const.NONE, Const.NONE,        Const.NONE,        Const.NONE,        Const.NONE,          Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.INTEGER, Const.INTEGER, Const.INTEGER, Const.INTEGER, Const.INTEGER, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,      Const.NONE,    Const.NONE,    Const.INTEGER,      Const.INTEGER,      Const.NONE },/*INT*/
/*CINT*/	  {Const.NONE, Const.NONE,        Const.NONE,        Const.NONE,        Const.NONE,          Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.INTEGER, Const.INTEGER, Const.INTEGER, Const.INTEGER, Const.INTEGER, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,      Const.NONE,    Const.NONE,    Const.INTEGER,      Const.INTEGER,      Const.NONE },/*CINT*/
/*SMALLINT*/ 	  {Const.NONE, Const.NONE,        Const.NONE,        Const.NONE,        Const.NONE,          Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.INTEGER, Const.INTEGER, Const.INTEGER, Const.INTEGER, Const.INTEGER, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,      Const.NONE,    Const.NONE,    Const.INTEGER,      Const.INTEGER,      Const.NONE },/*SMALLINT*/
/*TINYINT*/ 	  {Const.NONE, Const.NONE,        Const.NONE,        Const.NONE,        Const.NONE,          Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.INTEGER, Const.INTEGER, Const.INTEGER, Const.INTEGER, Const.INTEGER, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,      Const.NONE,    Const.NONE,    Const.INTEGER,      Const.INTEGER,      Const.NONE },/*TINYINT*/
/*BIGINT*/ 	  {Const.NONE, Const.NONE,        Const.NONE,        Const.NONE,        Const.NONE,          Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.INTEGER, Const.INTEGER, Const.INTEGER, Const.INTEGER, Const.INTEGER, Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,      Const.NONE,    Const.NONE,    Const.INTEGER,      Const.INTEGER,      Const.NONE },/*BIGINT*/
/*DATE*/	  {Const.NONE, Const.NONE,        Const.NONE,        Const.NONE,        Const.NONE,          Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.DATE, Const.DATE, Const.NONE, Const.NONE, Const.NONE,      Const.NONE,    Const.NONE,    Const.DATE,         Const.DATE,         Const.NONE },/*DATE*/
/*CDAT*/	  {Const.NONE, Const.NONE,        Const.NONE,        Const.NONE,        Const.NONE,          Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.DATE, Const.DATE, Const.NONE, Const.NONE, Const.NONE,      Const.NONE,    Const.NONE,    Const.DATE,         Const.DATE,         Const.NONE },/*CDAT*/
/*TIME*/	  {Const.NONE, Const.NONE,        Const.NONE,        Const.NONE,        Const.NONE,          Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE, Const.NONE, Const.TIME, Const.TIME, Const.TIMESTAMP, Const.NONE,    Const.NONE,    Const.TIME,         Const.TIME,         Const.NONE },/*TIME*/
/*CTIM*/	  {Const.NONE, Const.NONE,        Const.NONE,        Const.NONE,        Const.NONE,          Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE, Const.NONE, Const.TIME, Const.TIME, Const.TIMESTAMP, Const.NONE,    Const.NONE,    Const.TIME,         Const.TIME,         Const.NONE },/*CTIM*/
/*TIMESTAMP*/	  {Const.NONE, Const.NONE,        Const.NONE,        Const.NONE,        Const.NONE,          Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE, Const.NONE, Const.TIME, Const.TIME, Const.TIMESTAMP, Const.NONE,    Const.NONE,    Const.TIMESTAMP,    Const.TIMESTAMP,    Const.NONE },/*TIMESTAMP*/
/*BOOL*/	  {Const.NONE, Const.NONE,        Const.NONE,        Const.NONE,        Const.NONE,          Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,      Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN,      Const.BOOLEAN,      Const.NONE },/*BOOL*/
/*CBOO*/	  {Const.NONE, Const.NONE,        Const.NONE,        Const.NONE,        Const.NONE,          Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,      Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN,      Const.BOOLEAN,      Const.NONE },/*CBOO*/
/*NULL*/	  {Const.NONE, Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,     Const.LONGVARCHAR,   Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.INTEGER, Const.INTEGER, Const.INTEGER, Const.INTEGER, Const.INTEGER, Const.DATE, Const.DATE, Const.TIME, Const.TIME, Const.TIMESTAMP, Const.BOOLEAN, Const.BOOLEAN, Const.VARCHAR,      Const.VARCHAR,      Const.NONE },/*NULL*/
/*CNUL*/	  {Const.NONE, Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,     Const.LONGVARCHAR,   Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.DOUBLE, Const.INTEGER, Const.INTEGER, Const.INTEGER, Const.INTEGER, Const.INTEGER, Const.DATE, Const.DATE, Const.TIME, Const.TIME, Const.TIMESTAMP, Const.BOOLEAN, Const.BOOLEAN, Const.VARCHAR,      Const.VARCHAR,      Const.NONE },/*CNUL*/
/*WILD*/	  {Const.NONE, Const.NONE,        Const.NONE,        Const.NONE,        Const.NONE,          Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE,    Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,      Const.NONE,    Const.NONE,    Const.NONE,         Const.NONE,         Const.NONE } /*WILD*/
   };

   private int[] substringResultType =
       /*NONE*/     /*CHAR*/        /*CSTR*/             /*VARCHAR*/     /*LONGVARCHAR*/    /*DOUB*/      /*CDOUB*/    /*DECIMAL*/  /*NUMERIC*/  /*FLOAT*/    /*REAL*/    /*INT*/     /*CINT*/    /*SMALLINT*/ /*TINYINT*/  /*BIGINT*/   /*DATE*/    /*CDAT*/    /*TIME*/    /*CTIM*/    /*TIMESTAMP*/  /*BOOL*/    /*CBOO*/    /*NULL*/    /*CNUL*/    /*WILD*/
      {Const.NONE,  Const.VARCHAR,  Const.CONST_STRING,  Const.VARCHAR,  Const.LONGVARCHAR, Const.NONE,   Const.NONE,  Const.NONE,  Const.NONE,  Const.NONE,  Const.NONE, Const.NONE, Const.NONE, Const.NONE,  Const.NONE,  Const.NONE,  Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,    Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE };

   private int[][] concatenationResultType =
   {              /*NONE*/     /*CHAR*/             /*CSTR*/              /*VARCHAR*/          /*LONGVARCHAR*/      /*DOUB*/           /*CDOUB*/   	    /*DECIMAL*/        /*NUMERIC*/        /*FLOAT*/          /*REAL*/           /*INT*/              /*CINT*/                 /*SMALLINT*/       /*TINYINT*/        /*BIGINT*/         /*DATE*/             /*CDAT*/                 /*TIME*/             /*CTIM*/                  /*TIMESTAMP*/       /*BOOL*/      /*CBOO*/     /*NULL*/             /*CNUL*/                 /*WILD*/
/*NONE*/         {Const.NONE,  Const.NONE,          Const.NONE,           Const.NONE,          Const.NONE,          Const.NONE,        Const.NONE,          Const.NONE,        Const.NONE,        Const.NONE,        Const.NONE,        Const.NONE,          Const.NONE,              Const.NONE,        Const.NONE,        Const.NONE,        Const.NONE,          Const.NONE,              Const.NONE,          Const.NONE,               Const.NONE,         Const.NONE,   Const.NONE,  Const.NONE,          Const.NONE,              Const.NONE }, /*NONE*/
/*CHAR*/         {Const.NONE,  Const.VARCHAR,       Const.VARCHAR,        Const.VARCHAR,       Const.LONGVARCHAR,   Const.VARCHAR,     Const.VARCHAR,       Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,       Const.VARCHAR,           Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,       Const.VARCHAR,           Const.VARCHAR,       Const.VARCHAR,            Const.VARCHAR,      Const.NONE,   Const.NONE,  Const.VARCHAR,       Const.VARCHAR,           Const.NONE }, /*CHAR*/
/*CSTR*/         {Const.NONE,  Const.VARCHAR,       Const.CONST_STRING,   Const.VARCHAR,       Const.LONGVARCHAR,   Const.VARCHAR,     Const.CONST_STRING,  Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,       Const.CONST_STRING,      Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,       Const.CONST_STRING,      Const.VARCHAR,       Const.CONST_STRING,       Const.VARCHAR,      Const.NONE,   Const.NONE,  Const.VARCHAR,       Const.CONST_STRING,      Const.NONE }, /*CSTR*/
/*VARCHAR*/      {Const.NONE,  Const.VARCHAR,       Const.VARCHAR,        Const.VARCHAR,       Const.LONGVARCHAR,   Const.VARCHAR,     Const.VARCHAR,       Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,       Const.VARCHAR,           Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,       Const.VARCHAR,           Const.VARCHAR,       Const.VARCHAR,            Const.VARCHAR,      Const.NONE,   Const.NONE,  Const.VARCHAR,       Const.VARCHAR,           Const.NONE }, /*VARCHAR*/
/*LONGVARCHAR*/  {Const.NONE,  Const.LONGVARCHAR,   Const.LONGVARCHAR,    Const.LONGVARCHAR,   Const.LONGVARCHAR,   Const.LONGVARCHAR, Const.LONGVARCHAR,   Const.LONGVARCHAR, Const.LONGVARCHAR, Const.LONGVARCHAR, Const.LONGVARCHAR, Const.LONGVARCHAR,   Const.LONGVARCHAR,       Const.LONGVARCHAR, Const.LONGVARCHAR, Const.LONGVARCHAR, Const.LONGVARCHAR,   Const.LONGVARCHAR,       Const.LONGVARCHAR,   Const.LONGVARCHAR,        Const.LONGVARCHAR,  Const.NONE,   Const.NONE,  Const.LONGVARCHAR,   Const.LONGVARCHAR,       Const.NONE }, /*LONGVARCHAR*/
/*DOUB*/         {Const.NONE,  Const.VARCHAR,       Const.VARCHAR,        Const.VARCHAR,       Const.LONGVARCHAR,   Const.VARCHAR,     Const.VARCHAR,       Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,       Const.VARCHAR,           Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,       Const.VARCHAR,           Const.VARCHAR,       Const.VARCHAR,            Const.VARCHAR,      Const.NONE,   Const.NONE,  Const.VARCHAR,       Const.VARCHAR,           Const.NONE }, /*DOUB*/
/*CDOUB*/        {Const.NONE,  Const.VARCHAR,       Const.CONST_STRING,   Const.VARCHAR,       Const.LONGVARCHAR,   Const.VARCHAR,     Const.CONST_STRING,  Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,       Const.CONST_STRING,      Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,       Const.CONST_STRING,      Const.VARCHAR,       Const.CONST_STRING,       Const.VARCHAR,      Const.NONE,   Const.NONE,  Const.VARCHAR,       Const.CONST_STRING,      Const.NONE }, /*CDOUB*/
/*DECIMAL*/      {Const.NONE,  Const.VARCHAR,       Const.VARCHAR,        Const.VARCHAR,       Const.LONGVARCHAR,   Const.VARCHAR,     Const.VARCHAR,       Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,       Const.VARCHAR,           Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,       Const.VARCHAR,           Const.VARCHAR,       Const.VARCHAR,            Const.VARCHAR,      Const.NONE,   Const.NONE,  Const.VARCHAR,       Const.VARCHAR,           Const.NONE }, /*DECIMAL*/
/*NUMERIC*/      {Const.NONE,  Const.VARCHAR,       Const.VARCHAR,        Const.VARCHAR,       Const.LONGVARCHAR,   Const.VARCHAR,     Const.VARCHAR,       Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,       Const.VARCHAR,           Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,       Const.VARCHAR,           Const.VARCHAR,       Const.VARCHAR,            Const.VARCHAR,      Const.NONE,   Const.NONE,  Const.VARCHAR,       Const.VARCHAR,           Const.NONE }, /*NUMERIC*/
/*FLOAT*/        {Const.NONE,  Const.VARCHAR,       Const.VARCHAR,        Const.VARCHAR,       Const.LONGVARCHAR,   Const.VARCHAR,     Const.VARCHAR,       Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,       Const.VARCHAR,           Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,       Const.VARCHAR,           Const.VARCHAR,       Const.VARCHAR,            Const.VARCHAR,      Const.NONE,   Const.NONE,  Const.VARCHAR,       Const.VARCHAR,           Const.NONE }, /*FLOAT*/
/*REAL*/         {Const.NONE,  Const.VARCHAR,       Const.VARCHAR,        Const.VARCHAR,       Const.LONGVARCHAR,   Const.VARCHAR,     Const.VARCHAR,       Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,       Const.VARCHAR,           Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,       Const.VARCHAR,           Const.VARCHAR,       Const.VARCHAR,            Const.VARCHAR,      Const.NONE,   Const.NONE,  Const.VARCHAR,       Const.VARCHAR,           Const.NONE }, /*REAL*/
/*INT*/          {Const.NONE,  Const.VARCHAR,       Const.VARCHAR,        Const.VARCHAR,       Const.LONGVARCHAR,   Const.VARCHAR,     Const.VARCHAR,       Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,       Const.VARCHAR,           Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,       Const.VARCHAR,           Const.VARCHAR,       Const.VARCHAR,            Const.VARCHAR,      Const.NONE,   Const.NONE,  Const.VARCHAR,       Const.VARCHAR,           Const.NONE }, /*INT*/
/*CINT*/         {Const.NONE,  Const.VARCHAR,       Const.CONST_STRING,   Const.VARCHAR,       Const.LONGVARCHAR,   Const.VARCHAR,     Const.CONST_STRING,  Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,       Const.CONST_STRING,      Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,       Const.CONST_STRING,      Const.VARCHAR,       Const.CONST_STRING,       Const.VARCHAR,      Const.NONE,   Const.NONE,  Const.VARCHAR,       Const.CONST_STRING,      Const.NONE }, /*CINT*/
/*SMALLINT*/     {Const.NONE,  Const.VARCHAR,       Const.VARCHAR,        Const.VARCHAR,       Const.LONGVARCHAR,   Const.VARCHAR,     Const.VARCHAR,       Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,       Const.VARCHAR,           Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,       Const.VARCHAR,           Const.VARCHAR,       Const.VARCHAR,            Const.VARCHAR,      Const.NONE,   Const.NONE,  Const.VARCHAR,       Const.VARCHAR,           Const.NONE }, /*SMALLINT*/
/*TINYINT*/      {Const.NONE,  Const.VARCHAR,       Const.VARCHAR,        Const.VARCHAR,       Const.LONGVARCHAR,   Const.VARCHAR,     Const.VARCHAR,       Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,       Const.VARCHAR,           Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,       Const.VARCHAR,           Const.VARCHAR,       Const.VARCHAR,            Const.VARCHAR,      Const.NONE,   Const.NONE,  Const.VARCHAR,       Const.VARCHAR,           Const.NONE }, /*TINYINT*/
/*BIGINT*/       {Const.NONE,  Const.VARCHAR,       Const.VARCHAR,        Const.VARCHAR,       Const.LONGVARCHAR,   Const.VARCHAR,     Const.VARCHAR,       Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,       Const.VARCHAR,           Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,       Const.VARCHAR,           Const.VARCHAR,       Const.VARCHAR,            Const.VARCHAR,      Const.NONE,   Const.NONE,  Const.VARCHAR,       Const.VARCHAR,           Const.NONE }, /*BIGINT*/
/*DATE*/         {Const.NONE,  Const.VARCHAR,       Const.VARCHAR,        Const.VARCHAR,       Const.LONGVARCHAR,   Const.VARCHAR,     Const.VARCHAR,       Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,       Const.VARCHAR,           Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,       Const.VARCHAR,           Const.VARCHAR,       Const.VARCHAR,            Const.VARCHAR,      Const.NONE,   Const.NONE,  Const.VARCHAR,       Const.VARCHAR,           Const.NONE }, /*DATE*/
/*CDAT*/         {Const.NONE,  Const.VARCHAR,       Const.CONST_STRING,   Const.VARCHAR,       Const.LONGVARCHAR,   Const.VARCHAR,     Const.CONST_STRING,  Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,       Const.CONST_STRING,      Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,       Const.CONST_STRING,      Const.VARCHAR,       Const.CONST_STRING,       Const.VARCHAR,      Const.NONE,   Const.NONE,  Const.VARCHAR,       Const.CONST_STRING,      Const.NONE }, /*CDAT*/
/*TIME*/         {Const.NONE,  Const.VARCHAR,       Const.VARCHAR,        Const.VARCHAR,       Const.LONGVARCHAR,   Const.VARCHAR,     Const.VARCHAR,       Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,       Const.VARCHAR,           Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,       Const.VARCHAR,           Const.VARCHAR,       Const.VARCHAR,            Const.VARCHAR,      Const.NONE,   Const.NONE,  Const.VARCHAR,       Const.VARCHAR,           Const.NONE }, /*TIME*/
/*CTIM*/         {Const.NONE,  Const.VARCHAR,       Const.CONST_STRING,   Const.VARCHAR,       Const.LONGVARCHAR,   Const.VARCHAR,     Const.CONST_STRING,  Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,       Const.CONST_STRING,      Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,       Const.CONST_STRING,      Const.VARCHAR,       Const.CONST_STRING,       Const.VARCHAR,      Const.NONE,   Const.NONE,  Const.VARCHAR,       Const.CONST_STRING,      Const.NONE }, /*CTIM*/
/*TIMESTAMP*/    {Const.NONE,  Const.VARCHAR,       Const.VARCHAR,        Const.VARCHAR,       Const.LONGVARCHAR,   Const.VARCHAR,     Const.VARCHAR,       Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,       Const.VARCHAR,           Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,       Const.VARCHAR,           Const.VARCHAR,       Const.VARCHAR,            Const.VARCHAR,      Const.NONE,   Const.NONE,  Const.VARCHAR,       Const.VARCHAR,           Const.NONE }, /*TIMESTAMP*/
/*BOOL*/         {Const.NONE,  Const.NONE,          Const.NONE,           Const.NONE,          Const.NONE,          Const.NONE,        Const.NONE,          Const.NONE,        Const.NONE,        Const.NONE,        Const.NONE,        Const.NONE,          Const.NONE,              Const.NONE,        Const.NONE,        Const.NONE,        Const.NONE,          Const.NONE,              Const.NONE,          Const.NONE,               Const.NONE,         Const.NONE,   Const.NONE,  Const.NONE,          Const.NONE,              Const.NONE }, /*BOOL*/
/*CBOO*/         {Const.NONE,  Const.NONE,          Const.NONE,           Const.NONE,          Const.NONE,          Const.NONE,        Const.NONE,          Const.NONE,        Const.NONE,        Const.NONE,        Const.NONE,        Const.NONE,          Const.NONE,              Const.NONE,        Const.NONE,        Const.NONE,        Const.NONE,          Const.NONE,              Const.NONE,          Const.NONE,               Const.NONE,         Const.NONE,   Const.NONE,  Const.NONE,          Const.NONE,              Const.NONE }, /*CBOO*/
/*NULL*/         {Const.NONE,  Const.VARCHAR,       Const.VARCHAR,        Const.VARCHAR,       Const.LONGVARCHAR,   Const.VARCHAR,     Const.VARCHAR,       Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,       Const.VARCHAR,           Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,       Const.VARCHAR,           Const.VARCHAR,       Const.VARCHAR,            Const.VARCHAR,      Const.NONE,   Const.NONE,  Const.VARCHAR,       Const.VARCHAR,           Const.NONE }, /*NULL*/
/*CNUL*/         {Const.NONE,  Const.VARCHAR,       Const.CONST_STRING,   Const.VARCHAR,       Const.LONGVARCHAR,   Const.VARCHAR,     Const.CONST_STRING,  Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,       Const.CONST_STRING,      Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,     Const.VARCHAR,       Const.CONST_STRING,      Const.VARCHAR,       Const.CONST_STRING,       Const.VARCHAR,      Const.NONE,   Const.NONE,  Const.VARCHAR,       Const.CONST_STRING,      Const.NONE }, /*CNUL*/
/*WILD*/         {Const.NONE,  Const.NONE,          Const.NONE,           Const.NONE,          Const.NONE,          Const.NONE,        Const.NONE,          Const.NONE,        Const.NONE,        Const.NONE,        Const.NONE,        Const.NONE,          Const.NONE,              Const.NONE,        Const.NONE,        Const.NONE,        Const.NONE,          Const.NONE,              Const.NONE,          Const.NONE,               Const.NONE,         Const.NONE,   Const.NONE,  Const.NONE,          Const.NONE,              Const.NONE }  /*WILD*/
   };

   private int[][] likeResultType =
   {     	  /*NONE*/    /*CHAR*/        /*CSTR*/      	  /*VARCHAR*/     /*LONGVARCHAR*/   /*DOUB*/   	    /*CDOUB*/   	/*DECIMAL*/   	/*NUMERIC*/   	/*FLOAT*/   	/*REAL*/   	/*INT*/         /*CINT*/            /*SMALLINT*/    /*TINYINT*/     /*BIGINT*/      /*DATE*/        /*CDAT*/            /*TIME*/        /*CTIM*/            /*TIMESTAMP*/   /*BOOL*/      /*CBOO*/     /*NULL*/        /*CNUL*/           /*WILD*/
/*NONE*/ 	 {Const.NONE, Const.NONE,     Const.NONE,         Const.NONE,     Const.NONE,       Const.NONE,     Const.NONE,         Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,         Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,         Const.NONE,     Const.NONE,         Const.NONE,     Const.NONE,   Const.NONE,  Const.NONE,     Const.NONE,         Const.NONE }, /*NONE*/
/*CHAR*/  	 {Const.NONE, Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,    Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.NONE,   Const.NONE,  Const.BOOLEAN,  Const.BOOLEAN,      Const.NONE }, /*CHAR*/
/*CSTR*/ 	 {Const.NONE, Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,    Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.NONE,   Const.NONE,  Const.BOOLEAN,  Const.BOOLEAN,      Const.NONE }, /*CSTR*/
/*VARCHAR*/  	 {Const.NONE, Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,    Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.NONE,   Const.NONE,  Const.BOOLEAN,  Const.BOOLEAN,      Const.NONE }, /*VARCHAR*/
/*LONGVARCHAR*/  {Const.NONE, Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,    Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.NONE,   Const.NONE,  Const.BOOLEAN,  Const.BOOLEAN,      Const.NONE }, /*LONGVARCHAR*/
/*DOUB*/ 	 {Const.NONE, Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,    Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.NONE,   Const.NONE,  Const.BOOLEAN,  Const.BOOLEAN,      Const.NONE }, /*DOUB*/
/*CDOUB*/	 {Const.NONE, Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,    Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.NONE,   Const.NONE,  Const.BOOLEAN,  Const.BOOLEAN,      Const.NONE }, /*CDOUB*/
/*DECIMAL*/ 	 {Const.NONE, Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,    Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.NONE,   Const.NONE,  Const.BOOLEAN,  Const.BOOLEAN,      Const.NONE }, /*DECIMAL*/
/*NUMERIC*/ 	 {Const.NONE, Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,    Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.NONE,   Const.NONE,  Const.BOOLEAN,  Const.BOOLEAN,      Const.NONE }, /*NUMERIC*/
/*FLOAT*/ 	 {Const.NONE, Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,    Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.NONE,   Const.NONE,  Const.BOOLEAN,  Const.BOOLEAN,      Const.NONE }, /*FLOAT*/
/*REAL*/ 	 {Const.NONE, Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,    Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.NONE,   Const.NONE,  Const.BOOLEAN,  Const.BOOLEAN,      Const.NONE }, /*REAL*/
/*INT*/  	 {Const.NONE, Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,    Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.NONE,   Const.NONE,  Const.BOOLEAN,  Const.BOOLEAN,      Const.NONE }, /*INT*/
/*CINT*/ 	 {Const.NONE, Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,    Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.NONE,   Const.NONE,  Const.BOOLEAN,  Const.BOOLEAN,      Const.NONE }, /*CINT*/
/*SMALLINT*/  	 {Const.NONE, Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,    Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.NONE,   Const.NONE,  Const.BOOLEAN,  Const.BOOLEAN,      Const.NONE }, /*SMALLINT*/
/*TINYINT*/  	 {Const.NONE, Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,    Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.NONE,   Const.NONE,  Const.BOOLEAN,  Const.BOOLEAN,      Const.NONE }, /*TINYINT*/
/*BIGINT*/  	 {Const.NONE, Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,    Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.NONE,   Const.NONE,  Const.BOOLEAN,  Const.BOOLEAN,      Const.NONE }, /*BIGINT*/
/*DATE*/ 	 {Const.NONE, Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,    Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.NONE,   Const.NONE,  Const.BOOLEAN,  Const.BOOLEAN,      Const.NONE }, /*DATE*/
/*CDAT*/ 	 {Const.NONE, Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,    Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.NONE,   Const.NONE,  Const.BOOLEAN,  Const.BOOLEAN,      Const.NONE }, /*CDAT*/
/*TIME*/ 	 {Const.NONE, Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,    Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.NONE,   Const.NONE,  Const.BOOLEAN,  Const.BOOLEAN,      Const.NONE }, /*TIME*/
/*CTIM*/ 	 {Const.NONE, Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,    Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.NONE,   Const.NONE,  Const.BOOLEAN,  Const.BOOLEAN,      Const.NONE }, /*CTIM*/
/*TIMESTAMP*/ 	 {Const.NONE, Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,    Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.NONE,   Const.NONE,  Const.BOOLEAN,  Const.BOOLEAN,      Const.NONE }, /*TIMESTAMP*/
/*BOOL*/ 	 {Const.NONE, Const.NONE,     Const.NONE,   	  Const.NONE,     Const.NONE,       Const.NONE,     Const.NONE,         Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,         Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,         Const.NONE,     Const.NONE,         Const.NONE,     Const.NONE,   Const.NONE,  Const.NONE,     Const.NONE,         Const.NONE }, /*BOOL*/
/*CBOO*/ 	 {Const.NONE, Const.NONE,     Const.NONE,   	  Const.NONE,     Const.NONE,       Const.NONE,     Const.NONE,         Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,         Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,         Const.NONE,     Const.NONE,         Const.NONE,     Const.NONE,   Const.NONE,  Const.NONE,     Const.NONE,         Const.NONE }, /*CBOO*/
/*NULL*/ 	 {Const.NONE, Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,    Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.NONE,   Const.NONE,  Const.BOOLEAN,  Const.BOOLEAN,      Const.NONE }, /*NULL*/
/*CNUL*/ 	 {Const.NONE, Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,    Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.BOOLEAN,      Const.BOOLEAN,  Const.NONE,   Const.NONE,  Const.BOOLEAN,  Const.BOOLEAN,      Const.NONE }, /*CNUL*/
/*WILD*/ 	 {Const.NONE, Const.NONE,     Const.NONE,         Const.NONE,     Const.NONE,       Const.NONE,     Const.NONE,         Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,         Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,     Const.NONE,         Const.NONE,     Const.NONE,         Const.NONE,     Const.NONE,   Const.NONE,  Const.NONE,     Const.NONE,         Const.NONE }  /*WILD*/
   };

   private int[] escapeResultType =
       /*NONE*/    /*CHAR*/        /*CSTR*/      /*VARCHAR*/    /*LONGVARCHAR*/  /*DOUB*/      /*CDOUB*/    /*DECIMAL*/   /*NUMERIC*/   /*FLOAT*/     /*REAL*/      /*INT*/      /*CINT*/        /*SMALLINT*/ /*TINYINT*/  /*BIGINT*/   /*DATE*/    /*CDAT*/    /*TIME*/    /*CTIM*/    /*TIMESTAMP*/    /*BOOL*/    /*CBOO*/    /*NULL*/       /*CNUL*/       /*WILD*/
      {Const.NONE, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN, Const.BOOLEAN,   Const.NONE,   Const.NONE,  Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,   Const.NONE,  Const.BOOLEAN,  Const.NONE,  Const.NONE,  Const.NONE,  Const.NONE, Const.NONE, Const.NONE, Const.NONE, Const.NONE,      Const.NONE, Const.NONE, Const.BOOLEAN, Const.BOOLEAN, Const.NONE};


/*************************************************************************************************/
/*                                        PUBLIC METHODS					 */
/*************************************************************************************************/

  public boolean isPartitionable(){
    	return isPartitionable;
  }

  public String getAllOrDistinctText(){
    	return allOrDistinct;
  }

  /*
  public void setVpQuery(String table,String attribute) {

  	//if(findAlias(table,0)==null) nao precisa pois findAlias nunca dara null para table pois table ja esta no fromTables
	String partitionableTable = findAlias(table,0) + "." + attribute ;
        vpQuery = vpQuery.replaceAll(" 1#1 ", " " + partitionableTable + " ");
        vpQueryIndexed = vpQuery;
  }
  */

  public String getVpQuery(){
  	return vpQuery;
  }

  public String getError(){
    	return error;
  }


  public Object[] getGroupByList(){
      	return groupByList;
  }

  public ArrayList<Tokens> getQColumnsList(){
      	return qColumnsList;
  }

  public ArrayList<Column> getQvpColumnsList(){
      	return qvpColumnsList;
  }

  public Object[][] getSelectCompositor(){
      	return selectCompositor;
  }

  public Object[] getHavingCompositor(){
        return havingCompositor;
  }

  public ArrayList<String> getAliasTextList(){
        return aliasTextList;
  }

  public ArrayList<String> getWhereAttList(){
        return whereAttList;
  }

  public ArrayList<String> getGroupByTextList(){
        return groupByTextList;
  }

  public ArrayList<String> getOrderByTextList(){
        return orderByTextList;
  }

  public String getLimitText(){
        return limitText;
  }
  public ArrayList<String> getSelectTextList(){
        return selectTextList;
  }

  public int getSelectAggregationFunctionCount(){
  	return selectAggregationFunctionCount;
  }

  public OrderByRef[] getOrderByIndexList(){
        return orderByIndexList;
  }

  public int getQvpCount(){
    	return qvpCount;
  }


/*************************************************************************************************/
/*                                        PRIVATE METHODS					 */
/*************************************************************************************************/


//add TOKENS elements from fromList to toList without repetitions

  private void addToList(ArrayList <String> fromList, ArrayList <String> toList){

    int i,j;
    boolean found=false;
    String temp = new String();

    if( toList.isEmpty() ) {

      if( !(fromList.isEmpty()) )
        toList=fromList;
    }

    else {

      if ( !toList.get(0).equals("*") ){

        for(i=0;i<fromList.size();i++){

           temp=fromList.get(i);

           for(j=0;j<toList.size();j++){

             if( temp.toLowerCase().equals(toList.get(j).toLowerCase()) ){
      	       found = true;
      	       break;
       	     }
           }

           if(!found)
             toList.add(temp);
           found = false;
        }
      }
    }
  }


// add a token in columnsList without repetition and refresh the token.compositor with the correct columnsList reference

  private void addColumnsList( Tokens token, ArrayList<Column> columnsList ){

    int i;
    boolean found=false;
    String temp;

    if( columnsList.isEmpty() ) {

     // count.index++;
      columnsList.add( new Column(new String(token.text), token.type, token.aggregationFunction, getTypeText(token),false) );
      token.compositorText = Const.COLUMN_PREFIX+ "0" ;
      token.compositor.clear();
      token.compositor.add(new ColumnIndex(0));
      token.compositor.trimToSize();
    }
    else{

     for(i=0;i<columnsList.size();i++){

       temp = columnsList.get(i).getText();

       if(temp.toLowerCase().equals(token.text.toLowerCase()) ){
          found = true;
          token.compositorText = Const.COLUMN_PREFIX+ i;
          token.compositor.clear();
          token.compositor.add(new ColumnIndex(i));
          token.compositor.trimToSize();
          break;
       }
     }

     if(!found){

      // count.index++;
       columnsList.add( new Column(new String(token.text), token.type, token.aggregationFunction, getTypeText(token),false) );
       token.compositor.clear();
       token.compositor.add(new ColumnIndex(columnsList.size()-1));
       token.compositor.trimToSize();
       token.compositorText = Const.COLUMN_PREFIX+ (columnsList.size()-1);
     }

    }

  }


  private void addWildCardToColumnsList(Tokens token) {

    Tokens tempToken = new Tokens();
    boolean entryTest =false;
    String table, tableOrAlias, field;
    String tokenTextList =" ";
    tempToken.selectColumnCount = 0;

    for(int j = 0; j<fromTableAlias.get(0).size(); j++){

  	table = fromTableAlias.get(0).get(j).table;
  	tableOrAlias = fromTableAlias.get(0).get(j).alias;
	try {
		ResultSet columnList = meta.getColumns(null,null,table.toUpperCase(),null);
	  	while(columnList.next()) {
	  		entryTest = true;
	  		field = columnList.getString("COLUMN_NAME");
	  		tempToken.text = tableOrAlias.toUpperCase() + "." + field;
	  		tempToken.alias = tableOrAlias + "." + field;
	  		tempToken.type = convertToConstType( columnList.getInt("DATA_TYPE") );
	  		tempToken.typeSize = columnList.getInt("COLUMN_SIZE");
	  		tempToken.typePrecision = columnList.getInt("DECIMAL_DIGITS");
		 	tempToken.columnRefTable = getColumnRefTable( tableOrAlias, field, 0 );
                 	tempToken.columnRefField = field;
              	 	if( (columnsNotInGroupError = mustIncludeInGroupBy(tempToken, 0)) )
              	 		columnsNotInGroup += " " + tempToken.text +",";
	  		qvpColumnsList.add(new Column(tempToken.text, tempToken.type, Const.NONE,
	  		                              getTypeText(tempToken), false) );
			tempToken.selectColumnCount++;
			tokenTextList += fromTableAlias.get(0).get(j).alias+"."+columnList.getString("COLUMN_NAME")+", ";
                  	tempToken.compositorText = Const.COLUMN_PREFIX + (qvpColumnsList.size()-1);
                  	tempToken.compositor.clear();
                  	tempToken.compositor.trimToSize();
                  	tempToken.compositor.add(new ColumnIndex(qvpColumnsList.size()-1));
                  	aliasTextList.add(new String( tempToken.alias ) );
                  	aliasTextList.trimToSize();
                  	selectCompositorText.add(new String(tempToken.compositorText));
                  	selectTextList.trimToSize();
                  	selectTextList.add(new String(tempToken.compositorText));
                  	selectCompositorText.trimToSize();
                  	selectCompTemp.add(tempToken.compositor.toArray());
                  	selectCompTemp.trimToSize();
                  	qColumnsList.add(tempToken.clone());
                  	qColumnsList.trimToSize();
	  	}
	}
	catch (Exception e) {		
	  	yyerror(e.toString());
	}
    }
    token.text = tokenTextList;
    token.selectColumnCount = tempToken.selectColumnCount;
    if(entryTest) {
            if(existsAggregationSelect.get(0)){
            	if(columnsNotInGroupError)
            		yyerror("The column(s)" + columnsNotInGroup.substring(0,columnsNotInGroup.length() - 1) + " must appear in the GROUP BY clause" );
            }
    	    token.text = token.text.substring(0,token.text.length() - 1);
    	    selectCompositor = selectCompTemp.toArray(selectCompositor);
	    selectCompTemp.clear();
	    selectCompTemp.trimToSize();
            columnsNotInGroupError = false;
            columnsNotInGroup = "";
	    
    }
  }


  private void addWildCardToColumnsList(Tokens token, int wildcardLevel) {

    boolean entryTest = false;
    String table, tableOrAlias, field;
    String tokenTextList =" ";
    Tokens tempToken = new Tokens();
    tempToken.selectColumnCount = 0;

    for(int j = 0; j<fromTableAlias.get(wildcardLevel).size(); j++){
  	table = fromTableAlias.get(wildcardLevel).get(j).table;
  	tableOrAlias = fromTableAlias.get(wildcardLevel).get(j).alias;
	try {
		ResultSet columnList = meta.getColumns(null,null,table.toUpperCase(),null);
	  	while(columnList.next()) {
	  		entryTest = true;
	  		tempToken.selectColumnCount++;
	  		tempToken.type = convertToConstType( columnList.getInt("DATA_TYPE") );
	  		tempToken.typeSize = columnList.getInt("COLUMN_SIZE");
	  		tempToken.typePrecision = columnList.getInt("DECIMAL_DIGITS");
	  		field = columnList.getString("COLUMN_NAME");
		 	tempToken.columnRefTable = getColumnRefTable( tableOrAlias, field, wildcardLevel );
                 	tempToken.columnRefField = field;
              	 	if( (columnsNotInGroupError = mustIncludeInGroupBy(tempToken, wildcardLevel)) )
              	 		columnsNotInGroup += " " + tableOrAlias.toUpperCase() + "." + field + ",";
	  	}
	}
	catch (Exception e) {
	  	yyerror(e.toString());
	}
    }
    token.selectColumnCount = tempToken.selectColumnCount;
    token.text = " *";
    if(entryTest) {
        if(existsAggregationSelect.get(wildcardLevel)){
        	if(columnsNotInGroupError)
        		yyerror("The column(s)" + columnsNotInGroup.substring(0,columnsNotInGroup.length() - 1) + " must appear in the GROUP BY clause" );
        }        
        columnsNotInGroupError = false;
        columnsNotInGroup = "";
    	if(tempToken.selectColumnCount==1) {
    		token.type = tempToken.type;
    		token.typeSize = tempToken.typeSize;
    		token.typePrecision = tempToken.typePrecision;
    	}
    	else {
    		token.type = Const.WILDCARD;
    		token.typeSize = 0;
    		token.typePrecision = 0;
    	}
    }
  }


  private ArrayList<Object> addCompositor(int operator, Tokens token1, Tokens token2){

  	ArrayList<Object> temp = new ArrayList<Object>(0);
  	temp.add(new Operator(operator));
	temp.addAll(token1.compositor);
	temp.addAll(token2.compositor);
        temp.trimToSize();
        return temp;
  }


  private ArrayList<Object> addCompositor(int operator, Tokens token1){

    	ArrayList<Object> temp = new ArrayList<Object>(0);
    	temp.add(new Operator(operator));
  	temp.addAll(token1.compositor);
        temp.trimToSize();
        return temp;
  }


  //returns the correspondent table name of an ALIAS

   private String findTable(String alias,int fromTableAliasLevel){

    	for(int j=0; j<fromTableAlias.get(fromTableAliasLevel).size(); j++){
		if(fromTableAlias.get(fromTableAliasLevel).get(j).alias.toLowerCase().equals(alias.toLowerCase()))
	        	return fromTableAlias.get(fromTableAliasLevel).get(j).table;
    	}

    	for(int i=fromTableAliasLevel-1; i>=0; i--){
    		for(int j=0; j<fromTableAlias.get(i).size(); j++){
    			if(fromTableAlias.get(i).get(j).alias.toLowerCase().equals(alias.toLowerCase()))
    				return fromTableAlias.get(i).get(j).table;
    		}
    	}
    	return null;
  }

  //returns the correspondent alias name of a table name

  private String findAlias(String table,int fromTableAliasLevel){

      	for(int j=0;j<fromTableAlias.get(fromTableAliasLevel).size(); j++){
	      	if(fromTableAlias.get(fromTableAliasLevel).get(j).table.toLowerCase().equals(table.toLowerCase()))
	      		return fromTableAlias.get(fromTableAliasLevel).get(j).alias;
      	}
      	for(int i=fromTableAliasLevel-1; i>=0; i--){
      		for(int j=0;j<fromTableAlias.get(i).size(); j++){
      			if(fromTableAlias.get(i).get(j).table.toLowerCase().equals(table.toLowerCase()))
      				return fromTableAlias.get(i).get(j).alias;
      		}
      	}
      	return null;
  }


  private String printColumnList(ArrayList <Column> columnList){
    int i;
    //String outString=" "+ columnList.get(0).getText();
    String outString=" ";

    for(i=0;i<columnList.size();i++){
      if(i == 0)
      	outString += columnList.get(0).getText();
      else
      	outString += ", " + columnList.get(i).getText();
    }
    return outString;

  }


/*************************************************************************************************/
/*                                        RESULT OPERATION METHODS			    	 */
/*************************************************************************************************/


  private void getResultConcatenationType(Tokens operate1, Tokens operate2, Tokens token){

  	if((token.type = concatenationResultType[operate1.type-Const.NONE][operate2.type-Const.NONE])!=Const.NONE) {
  		token.typeSize = operate1.typeLength + operate2.typeLength;
  		token.typeLength = operate1.typeLength + operate2.typeLength;
  		token.typePrecision = 0;
  	}
  	else
  		yyerror("Type mismatch in the operation : " + new String(token.text));
  }

  private void getResultEscapeType(Tokens operate, Tokens token){

    	if(((token.typeSize = escapeResultType[operate.type-Const.NONE])==Const.NONE) || (operate.typeLength != 1))
    		yyerror("Invalid string in the Escape clause : " + new String(token.text));
  }

  private void getResultLikeType(Tokens operate1, Tokens operate2, Tokens token){

  	if((token.type = likeResultType[operate1.type-Const.NONE][operate2.type-Const.NONE])!=Const.NONE) {
  		token.typeSize = 0;
  		token.typePrecision = 0;
  		token.typeLength = 0;
  	}
  	else {
  		yyerror("Type mismatch in the operation : " + new String(token.text));
  	}
  }

  private void getResultCaseType (Tokens operate1,Tokens operate2, Tokens token){

    	token.type = caseResultType[operate1.type-Const.NONE][operate2.type-Const.NONE];
    	if(operate1.typeSize == operate2.typeSize){
    		token.typeSize = operate1.typeSize;
    		if(operate1.typePrecision >= operate2.typePrecision) {
    			token.typePrecision = operate1.typePrecision;
    			token.typeLength = operate1.typeLength;
    		}
    		else {
    			token.typePrecision = operate2.typePrecision;
    			token.typeLength = operate2.typeLength;
    		}
    	}
    	else {
    		if(operate1.typeSize > operate2.typeSize){
    			token.typeSize = operate1.typeSize;
    			token.typePrecision = operate1.typePrecision;
    			token.typeLength = operate1.typeLength;
    		}
    		else {
    			token.typeSize = operate2.typeSize;
			token.typePrecision = operate2.typePrecision;
			token.typeLength = operate2.typeLength;
		}
    	}
  }

  private int getCaseWhenType (int operate1,int operate2){

    	return caseResultType[operate1-Const.NONE][operate2-Const.NONE];
  }

  private void getResultCoalesceType(Tokens operate1,Tokens operate2, Tokens token){

    	token.type = coalesceResultType[operate1.type-Const.NONE][operate2.type-Const.NONE];
    	if(operate1.typeSize == operate2.typeSize){
    		token.typeSize = operate1.typeSize;
    		if(operate1.typePrecision >= operate2.typePrecision) {
    			token.typePrecision = operate1.typePrecision;
    			token.typeLength =  operate1.typeLength;
    		}
    		else {
    			token.typePrecision = operate2.typePrecision;
    			token.typeLength = operate2.typeLength;
    		}
    	}
    	else {
    		if(operate1.typeSize > operate2.typeSize){
    			token.typeSize = operate1.typeSize;
    			token.typePrecision = operate1.typePrecision;
    			token.typeLength = operate1.typeLength;
    		}
    		else {
    			token.typeSize = operate2.typeSize;
			token.typePrecision = operate2.typePrecision;
			token.typeLength = operate2.typeLength;
		}
    	}

  }


  private int getResultInPredicateType(int operate1,int operate2){

    	return coalesceResultType[operate1-Const.NONE][operate2-Const.NONE];
  }


  private void getResultNullIfType(Tokens operate1,Tokens operate2, Tokens token){

  	if((token.type = nullIfResultType[operate1.type-Const.NONE][operate2.type-Const.NONE])!=Const.NONE){
  		token.typeSize = operate1.typeSize;
  		token.typePrecision = operate1.typePrecision;
  		token.typeLength = operate1.typeLength;
  	}
  	else
  		yyerror("Type mismatch in the operation  : " + new String(token.text));
  }


  private void getResultSignType(Tokens operate, Tokens token){
    	if((token.type = signResultType[operate.type-Const.NONE])!=Const.NONE) {
  		token.typeSize = operate.typeSize;
  		token.typePrecision = operate.typePrecision;
  		token.typeLength = operate.typeLength;
  	}

    	else
    		yyerror("Type mismatch in the +/- unary operation : " + new String(token.text));

  }

  private void getResultPlusType(Tokens operate1,Tokens operate2, Tokens token){
  	if((token.type = plusOrMinusResultType[operate1.type-Const.NONE][operate2.type-Const.NONE])!=Const.NONE) {
    		if(operate1.typeSize == operate2.typeSize){
    			token.typeSize = operate1.typeSize;
    			if(operate1.typePrecision >= operate2.typePrecision) {
    				token.typePrecision = operate1.typePrecision;
    				token.typeLength =  operate1.typeLength;
    			}
    			else {
    				token.typePrecision = operate2.typePrecision;
    				token.typeLength = operate2.typeLength;
    			}
    		}
    		else {
    			if(operate1.typeSize > operate2.typeSize){
    				token.typeSize = operate1.typeSize;
    				token.typePrecision = operate1.typePrecision;
    				token.typeLength = operate1.typeLength;
    			}
    			else {
    				token.typeSize = operate2.typeSize;
				token.typePrecision = operate2.typePrecision;
				token.typeLength = operate2.typeLength;
			}
    		}
  	}
  	else
  		yyerror("Type mismatch in the add operation : " + new String(token.text));
  }


  private void getResultMinusType(Tokens operate1,Tokens operate2, Tokens token){
    	if((token.type = plusOrMinusResultType[operate1.type-Const.NONE][operate2.type-Const.NONE])!=Const.NONE) {
    		if(operate1.typeSize == operate2.typeSize){
    			token.typeSize = operate1.typeSize;
    			if(operate1.typePrecision >= operate2.typePrecision) {
    				token.typePrecision = operate1.typePrecision;
    				token.typeLength =  operate1.typeLength;
    			}
    			else {
    				token.typePrecision = operate2.typePrecision;
    				token.typeLength = operate2.typeLength;
    			}
    		}
    		else {
    			if(operate1.typeSize > operate2.typeSize){
    				token.typeSize = operate1.typeSize;
    				token.typePrecision = operate1.typePrecision;
    				token.typeLength = operate1.typeLength;
    			}
    			else {
    				token.typeSize = operate2.typeSize;
				token.typePrecision = operate2.typePrecision;
				token.typeLength = operate2.typeLength;
			}
    		}
    	}
    	else
    		yyerror("Type mismatch in the minus operation : " + new String(token.text));
  }


  private void getResultMultiplicationType(Tokens operate1,Tokens operate2, Tokens token){

    	if((token.type = multiplicationResultType[operate1.type-Const.NONE][operate2.type-Const.NONE])!=Const.NONE) {
    		if(operate1.typeSize == operate2.typeSize){
    			token.typeSize = operate1.typeSize;
    			if(operate1.typePrecision >= operate2.typePrecision) {
    				token.typePrecision = operate1.typePrecision;
    				token.typeLength =  operate1.typeLength;
    			}
    			else {
    				token.typePrecision = operate2.typePrecision;
    				token.typeLength = operate2.typeLength;
    			}
    		}
    		else {
    			if(operate1.typeSize > operate2.typeSize){
    				token.typeSize = operate1.typeSize;
    				token.typePrecision = operate1.typePrecision;
    				token.typeLength = operate1.typeLength;
    			}
    			else {
    				token.typeSize = operate2.typeSize;
				token.typePrecision = operate2.typePrecision;
				token.typeLength = operate2.typeLength;
			}
    		}
    	}
    	else
    		yyerror("Type mismatch in the multiplication operation : " + new String(token.text));
  }


  private void getResultDivisionType(Tokens operate1,Tokens operate2, Tokens token){
    	if((token.type = divisionResultType[operate1.type-Const.NONE][operate2.type-Const.NONE])!=Const.NONE) {
    		if(operate1.typeSize == operate2.typeSize){
    			token.typeSize = operate1.typeSize;
    			if(operate1.typePrecision >= operate2.typePrecision) {
    				token.typePrecision = operate1.typePrecision;
    				token.typeLength =  operate1.typeLength;
    			}
    			else {
    				token.typePrecision = operate2.typePrecision;
    				token.typeLength = operate2.typeLength;
    			}
    		}
    		else {
    			if(operate1.typeSize > operate2.typeSize){
    				token.typeSize = operate1.typeSize;
    				token.typePrecision = operate1.typePrecision;
    				token.typeLength = operate1.typeLength;
    			}
    			else {
    				token.typeSize = operate2.typeSize;
				token.typePrecision = operate2.typePrecision;
				token.typeLength = operate2.typeLength;
			}
    		}
    	}
    	else
    		yyerror("Type mismatch in the division operation : " + new String(token.text));
  }

  private void getResultLogicOpType(Tokens operate1,Tokens operate2, Tokens token){
      	if((token.type = logicOpResultType[operate1.type-Const.NONE][operate2.type-Const.NONE])!=Const.NONE){
    		token.typeSize = 0;
		token.typePrecision = 0;
		token.typeLength = 0;
      	}
      	else
      		yyerror("Type mismatch in the logic operation : " + new String(token.text));
  }

  private void getResultLogicOpType(Tokens operate, Tokens token){
      	if((token.type = logicUnaryOpResultType[operate.type-Const.NONE])!=Const.NONE) {
    		token.typeSize = 0;
		token.typePrecision = 0;
		token.typeLength = 0;
      	}
      	else
      		yyerror("Type mismatch in the logic operation : " + new String(token.text));
  }

  private void getResultRelationalOpType(Tokens operate1,Tokens operate2, Tokens token){
      	if((token.type = relationalOpResultType[operate1.type-Const.NONE][operate2.type-Const.NONE])!=Const.NONE){
    		token.typeSize = 0;
		token.typePrecision = 0;
		token.typeLength = 0;
      	}
      	else
      		yyerror("Type mismatch in the relational operation : " + new String(token.text));
  }

  private void getResultRelationalOpType(Tokens operate1,Tokens operate2,Tokens operate3, Tokens token){
      	int reurnedType;
      	if((reurnedType = relationalOpResultType[operate1.type-Const.NONE][operate2.type-Const.NONE])==Const.NONE){
      		token.type = reurnedType;
      		yyerror("Type mismatch in the relational operation : " + new String(token.text) +
      		         "\nTypes : " + getTypeText(operate1) + " " + getTypeText(operate2)+ " " +
      		         getTypeText(operate3));
        }
      	else {
      		if((token.type = relationalOpResultType[operate1.type-Const.NONE][operate3.type-Const.NONE])==Const.NONE)
      			yyerror("Type mismatch in the relational operation : " + new String(token.text) +
      		         	"\nTypes : " + getTypeText(operate1) + " " + getTypeText(operate2)+ " " +
      		         	getTypeText(operate3));
      	}
    	token.typeSize = 0;
	token.typePrecision = 0;
	token.typeLength = 0;

  }


  private int getResultAggregationFunctionType(Tokens parameters, int aggregationFunction, Tokens token){
        int typeReturned;
        int[] functionResultArray=null;
        switch (aggregationFunction){
            case Const.AVG:
            	functionResultArray = avgResultType;
            	break;
            case Const.SUM:
            	functionResultArray = sumResultType;
            	break;
            case Const.COUNT:
		functionResultArray = countResultType;
            	break;
            case Const.MIN:
		functionResultArray = minResultType;
            	break;
            case Const.MAX:
		functionResultArray = maxResultType;
            	break;
            default : return Const.NONE;
        }

        if((typeReturned = functionResultArray[parameters.type-Const.NONE])==Const.NONE)
        	yyerror("Invalid parameter type in the aggregation function : " + new String(token.text));
        else {
    		token.typeSize = parameters.typeSize;
		token.typePrecision = parameters.typePrecision;
		token.typeLength = parameters.typeLength;
        }
        return typeReturned;
  }

  private void getResultExtractType(Tokens operate, Tokens token){
    	if((token.type = extractResultType[operate.type-Const.NONE])!=Const.NONE) {
  		token.typeSize = 0;
  		token.typePrecision = 0;
  		token.typeLength = 20;
  	}

    	else
    		yyerror("Type mismatch in the operation : " + new String(token.text));
  }

  private void getResultSubstringType(Tokens operate, Tokens token){
    	if((token.type = substringResultType[operate.type-Const.NONE])!=Const.NONE) {
  		token.typeSize = operate.typeSize;
  		token.typePrecision = 0;
  		token.typeLength = operate.typeLength;
  	}

    	else
    		yyerror("Type mismatch in the operation : " + new String(token.text));
  }


/*************************************************************************************************/
/*                                        GENERAL METHODS					 */
/*************************************************************************************************/


   private int verifySelectAliasRef(String selectAlias, int selectAliasLevel) {

   	for(int i = 0; i<selectAliasLevelList.get(selectAliasLevel).size(); i++){
   		if(selectAlias.toUpperCase().equals(selectAliasLevelList.get(selectAliasLevel).get(i).toUpperCase()))
   			return i;
   	}
   	return -1;
   }


  private int getColumnType(String tableOrAlias, String attribute, int tableOrAliasLevel, Tokens token) {
     if(findTable(tableOrAlias,tableOrAliasLevel)!=null) {
  	try {
  		ResultSet columnList = meta.getColumns(null,null,findTable(tableOrAlias,tableOrAliasLevel).toUpperCase(),null);

  		while(columnList.next()) {
  			if(columnList.getString("COLUMN_NAME").toUpperCase().equals(attribute.toUpperCase())) {
	  			token.typeSize = columnList.getInt("COLUMN_SIZE");
	  			token.typePrecision = columnList.getInt("DECIMAL_DIGITS");
	  			token.typeLength = getTypeLength(columnList.getInt("DATA_TYPE"),columnList.getInt("COLUMN_SIZE"), columnList.getInt("DECIMAL_DIGITS"));
  				return convertToConstType( columnList.getInt("DATA_TYPE") );
  			}
  	        }
  	        yyerror( new String(attribute) + " is not a " + new String(tableOrAlias) +" field");
  	        return Const.NONE;
  	} catch (Exception e) {
  		yyerror(e.toString());
  		return Const.NONE;
  	  }
     }
     else
      return Const.NONE;
  }



  private int getColumnType(String attribute, int tableOrAliasLevel, Tokens token) {

  	int foundAttribute = 0;
  	int returnedType = Const.NONE;
  	String table;
  	for(int j = 0; j<fromTableAlias.get(tableOrAliasLevel).size(); j++){
	  	table = fromTableAlias.get(tableOrAliasLevel).get(j).table;
	  	try {
	  		ResultSet columnList = meta.getColumns(null,null,table.toUpperCase(),null);
	  		while(columnList.next()) {
	  			if(columnList.getString("COLUMN_NAME").toUpperCase().equals(attribute.toUpperCase())) {
	  				token.typeSize = columnList.getInt("COLUMN_SIZE");
	  				token.typePrecision = columnList.getInt("DECIMAL_DIGITS");
	  				token.typeLength = getTypeLength(columnList.getInt("DATA_TYPE"),columnList.getInt("COLUMN_SIZE"), columnList.getInt("DECIMAL_DIGITS"));
	  				returnedType = convertToConstType( columnList.getInt("DATA_TYPE"));
	  				foundAttribute++;
	  			}
	  		}
	  	}
	  	catch (Exception e) {
	  		yyerror(e.toString());
	  		return Const.NONE;
	  	}
  	}
	if(foundAttribute > 1){
		yyerror("Ambiguity. " + new String(attribute) + " is field of too many tables");
		return Const.NONE;
	}
	if(foundAttribute == 1)
		return returnedType;
	else{//if(foundAttribute == 0)
  	    for(int i=tableOrAliasLevel-1;i>=0; i--){
  		for(int j = 0; j<fromTableAlias.get(i).size(); j++){
  			table = fromTableAlias.get(i).get(j).table;
  			try {
  				ResultSet columnList = meta.getColumns(null,null,table.toUpperCase(),null);
  				while(columnList.next()) {
  					if(columnList.getString("COLUMN_NAME").toUpperCase().equals(attribute.toUpperCase())) {
	  					token.typeSize = columnList.getInt("COLUMN_SIZE");
	  					token.typePrecision = columnList.getInt("DECIMAL_DIGITS");
	  					token.typeLength = getTypeLength(columnList.getInt("DATA_TYPE"),columnList.getInt("COLUMN_SIZE"), columnList.getInt("DECIMAL_DIGITS"));
	  					returnedType = convertToConstType( columnList.getInt("DATA_TYPE"));
  						foundAttribute++;
  					}
  			        }
  			}
  			catch (Exception e) {
  				yyerror(e.toString());
  				return Const.NONE;
  		  	}
  		}
  	    }
  	}
  	if(foundAttribute == 0){
  		yyerror("The column " + new String(attribute) + " does not exists");
  		return Const.NONE;
  	}
  	else //if(foundAttribute >= 1)
		return returnedType;


  }


   private ColumnRefTable getColumnRefTable(String tableOrAlias, String attribute, int tableOrAliasLevel) {
       if(findTable(tableOrAlias,tableOrAliasLevel)!=null) {
    	for(int j=0; j<fromTableAlias.get(tableOrAliasLevel).size(); j++){
			if(fromTableAlias.get(tableOrAliasLevel).get(j).alias.toLowerCase().equals(tableOrAlias.toLowerCase()))
		        	return new ColumnRefTable(fromTableAlias.get(tableOrAliasLevel).get(j).table,
		        	                          tableOrAliasLevel);
	    	}

	    	for(int i=tableOrAliasLevel-1; i>=0; i--){
	    		for(int j=0; j<fromTableAlias.get(i).size(); j++){
	    			if(fromTableAlias.get(i).get(j).alias.toLowerCase().equals(tableOrAlias.toLowerCase()))
	    				return new ColumnRefTable(fromTableAlias.get(i).get(j).table,i);
	    		}
	    	}
    	return null;
       }
       else
        return null;
  }


  private ColumnRefTable getColumnRefTable(String attribute,int tableOrAliasLevel) {

    	int foundAttribute = 0;
    	String table;
    	for(int j = 0; j<fromTableAlias.get(tableOrAliasLevel).size(); j++){
  	  	table = fromTableAlias.get(tableOrAliasLevel).get(j).table;
  	  	try {
  	  		ResultSet columnList = meta.getColumns(null,null,table.toUpperCase(),null);
  	  		while(columnList.next()) {
  	  			if(columnList.getString("COLUMN_NAME").toUpperCase().equals(attribute.toUpperCase())) {
  	  			return new ColumnRefTable(table,tableOrAliasLevel);
  	  			}
  	  		}
  	  	}
  	  	catch (Exception e) {
  	  	return null;
  	  	}
    	}
    	for(int i=tableOrAliasLevel-1;i>=0; i--){
    		for(int j = 0; j<fromTableAlias.get(i).size(); j++){
    			table = fromTableAlias.get(i).get(j).table;
    			try {
    				ResultSet columnList = meta.getColumns(null,null,table.toUpperCase(),null);
    				while(columnList.next()) {
    					if(columnList.getString("COLUMN_NAME").toUpperCase().equals(attribute.toUpperCase())) {
    					return new ColumnRefTable(table,i);
    					}
    			        }
    			}
    			catch (Exception e) {
    				return null;
    		  	}
    		}
    	}
    	return null;
  }

  private boolean constVerify(int type) {
  	boolean isConst = false;
  	switch(type){
  		case Const.CONST_BOOLEAN:
  			isConst = true;
  			break;
  		case Const.CONST_STRING:
  			isConst = true;
  			break;
  		case Const.CONST_DATE:
  			isConst = true;
  			break;
  		case Const.CONST_DOUBLE:
  			isConst = true;
  			break;
  		case Const.CONST_INTEGER:
  			isConst = true;
  			break;
  		case Const.CONST_NULL:
  			isConst = true;
  			break;
  		case Const.CONST_TIME:
  			isConst = true;
  			break;
  		default :
  			isConst = false;
  			break;
  	}
  	return isConst;
  }


  private int convertToConstType(int sqlType) throws ParserSilentException{
  	int returnedType;
  	switch(sqlType){
 		case Types.CHAR:
  			returnedType = Const.CHAR;
  			break;
  		case Types.VARCHAR:
  			returnedType = Const.VARCHAR;
  			break;
  		case Types.LONGVARCHAR:
  			returnedType = Const.LONGVARCHAR;
  			break;
  		case Types.DATE:
  			returnedType = Const.DATE;
  			break;
   		case Types.TIME:
  			returnedType = Const.TIME;
  			break;
  		case Types.TIMESTAMP:
  			returnedType = Const.TIMESTAMP;
  			break;
 		case Types.DECIMAL:
  			returnedType = Const.DECIMAL;
  			break;
  		case Types.DOUBLE:
  			returnedType = Const.DOUBLE;
  			break;
  		case Types.FLOAT:
  			returnedType = Const.FLOAT;
  			break;
  		case Types.INTEGER:
  			returnedType = Const.INTEGER;
  			break;
  		case Types.BIGINT:
  			returnedType = Const.BIGINT;
  			break;
   		case Types.NUMERIC:
  			returnedType = Const.NUMERIC;
  			break;
  		case Types.REAL:
  			returnedType = Const.REAL;
  			break;
  		case Types.SMALLINT:
  			returnedType = Const.SMALLINT;
  			break;
  		case Types.TINYINT:
  			returnedType = Const.TINYINT;
  			break;
  		case Types.BOOLEAN:
  			returnedType = Const.BOOLEAN;
  			break;
   	 	case Types.NULL:
  			returnedType = Const.NULL;
  			break;
	        default :
  			returnedType = Const.NONE;
  			yyerror("java.SQL.Types = " + sqlType + " not treated");
  			if(true)
  				throw new ParserSilentException("java.SQL.Types = " + sqlType + " not treated");
  			break;
  	}
  	return returnedType;
  }

  private int getTypeLength(int sqlType, int typeSize, int typePrecision) throws ParserSilentException{
    	int returnedLength;
    	switch(sqlType){
   		case Types.CHAR:
    			returnedLength = typeSize;
    			break;
    		case Types.VARCHAR:
    			returnedLength = typeSize;
    			break;
    		case Types.LONGVARCHAR:
    			returnedLength = typeSize;
    			break;
    		case Types.DATE:
    			returnedLength = 10;
    			break;
     		case Types.TIME:
    			returnedLength = 14;
    			break;
    		case Types.TIMESTAMP:
    			returnedLength = 26;
    			break;
   		case Types.DECIMAL:
    			returnedLength = typeSize + typePrecision + 1;
    			break;
    		case Types.DOUBLE:
    			returnedLength = 20;
    			break;
    		case Types.FLOAT:
    			if(typeSize==0 || typeSize >=25)
    				returnedLength = 20;
    			else
    				returnedLength = 11;
    			break;
    		case Types.INTEGER:
    			returnedLength = 11;
    			break;
    		case Types.BIGINT:
    			returnedLength = 20;
    			break;
     		case Types.NUMERIC:
    			returnedLength = typeSize + typePrecision + 1;
    			break;
    		case Types.REAL:
    			returnedLength = 11;
    			break;
    		case Types.SMALLINT:
    			returnedLength = 6;
    			break;
    		case Types.TINYINT:
    			returnedLength = 3;
    			break;
    		case Types.BOOLEAN:
    			returnedLength = 1;
    			break;
     	 	case Types.NULL:
    			returnedLength = 4;
    			break;
  	        default :
    			returnedLength = Const.NONE;
    			yyerror("java.SQL.Types = " + sqlType + " not treated");
    			if(true)
    				throw new ParserSilentException("java.SQL.Types = " + sqlType + " not treated");
    			break;
    	}
    	return returnedLength;
  }

  private boolean mustIncludeInGroupBy(String text,int groupByLevel){
  	for(int i = 0; i< groupByLevelList.get(groupByLevel).size(); i++){
  		if(semanticMatch(text,groupByLevelList.get(groupByLevel).get(i)))
  			return false;//nao precisa ser incluido
  	}
  	return true;
  }
  
  private boolean mustIncludeInGroupBy(Tokens columnRef, int groupByLevel){

  	if(columnRef.columnRefTable==null)
  		return true;
  	if(groupByLevel != columnRef.columnRefTable.tableLevel)
  		return false;
  	else { //if this column is referred in the from clause of the actual subquery level
  		for(int i = 0; i< groupByLevelList.get(groupByLevel).size(); i++){
  			if(semanticMatch(columnRef.columnRefField,groupByLevelList.get(groupByLevel).get(i)) ||
  			   semanticMatch(findAlias(columnRef.columnRefTable.name,groupByLevel) + "." + columnRef.columnRefField,groupByLevelList.get(groupByLevel).get(i))
  			   )
  				return false;
  		}
  	}
  	return true;
  }


  private boolean isVpAttribute(Tokens token){

	for(int i=0;i<rangeList.size();i++){
	  	if( (token.columnRefTable.name.toUpperCase().equals((rangeList.get(i)).getTableName().toUpperCase())) &&
	  	    (token.columnRefField.toUpperCase().equals((rangeList.get(i)).getField().toUpperCase())) )
	  		return true;
	}
	return false;
  }


  private boolean semanticMatch(String str1, String str2){
  	String[] str1Splited = str1.split(" ");
  	String[] str2Splited = str2.split(" ");
  	int found = 0;
  	for(int i =0; i< str1Splited.length; i++){
	  	if(!(str2.toLowerCase().contains(str1Splited[i].toLowerCase())))
	  		return false;
	}
	for(int j =0; j< str2Splited.length; j++){
		if(!(str1.toLowerCase().contains(str2Splited[j].toLowerCase())))
			return false;
	}
  	return true;
  }


  private String getTypeText(Tokens token) {
  	String typeText;
  	switch(token.type){
  		case Const.BOOLEAN:
  			typeText = "BOOLEAN";
  			token.typePrecision = 0;
  			token.typeSize = 0;
  			break;
  		case Const.CONST_BOOLEAN:
  			typeText = "BOOLEAN";
  			token.typePrecision = 0;
  			token.typeSize = 0;
  			break;
  		case Const.CONST_STRING:
  			typeText = "VARCHAR";
  			token.typePrecision = 0;
  			break;
  		case Const.CHAR:
  			typeText = "CHARACTER";
  			token.typePrecision = 0;
  			break;
  		case Const.DATE:
  			typeText = "DATE";
  			token.typePrecision = 0;
  			token.typeSize = 0;
  			break;
  		case Const.CONST_DATE:
  			typeText = "DATE";
  			token.typePrecision = 0;
  			token.typeSize = 0;
  			break;
  		case Const.DECIMAL:
  			typeText = "DECIMAL";
  			break;
  		case Const.DOUBLE:
  			typeText = "DOUBLE";
  			token.typePrecision = 0;
  			token.typeSize = 0;
  			break;
  		case Const.CONST_DOUBLE:
  			typeText = "DOUBLE";
  			token.typePrecision = 0;
  			token.typeSize = 0;
  			break;
  		case Const.FLOAT:
  			typeText = "FLOAT";
  			token.typePrecision = 0;
  			break;
  		case Const.INTEGER:
  			typeText = "INTEGER";
  			token.typePrecision = 0;
  			token.typeSize = 0;
  			break;
  		case Const.CONST_INTEGER:
  			typeText = "INTEGER";
  			token.typePrecision = 0;
  			token.typeSize = 0;
  			break;
  		case Const.LONGVARCHAR:
  			typeText = "LONGVARCHAR";
  			token.typePrecision = 0;
  			break;
  		case Const.NULL:
  			typeText = "NULL";
  			token.typePrecision = 0;
  			token.typeSize = 0;
  			break;
  		case Const.CONST_NULL:
  			typeText = "NULL";
  			token.typePrecision = 0;
  			token.typeSize = 0;
  			break;
  		case Const.NUMERIC:
  			typeText = "NUMERIC";
  			break;
  		case Const.REAL:
  			typeText = "REAL";
  			token.typePrecision = 0;
  			token.typeSize = 0;
  			break;
  		case Const.SMALLINT:
  			typeText = "SMALLINT";
  			token.typePrecision = 0;
  			token.typeSize = 0;
  			break;
  		case Const.TINYINT:
  			typeText = "TINYINT";
  			token.typePrecision = 0;
  			token.typeSize = 0;
  			break;
  		case Const.BIGINT:
  			typeText = "BIGINT";
  			token.typePrecision = 0;
  			token.typeSize = 0;
  			break;
  		case Const.TIME:
  			typeText = "TIME";
  			token.typePrecision = 0;
  			token.typeSize = 0;
  			break;
  		case Const.CONST_TIME:
  			typeText = "TIME";
  			token.typePrecision = 0;
  			token.typeSize = 0;
  			break;
  		case Const.TIMESTAMP:
  			typeText = "TIMESTAMP";
  			token.typePrecision = 0;
  			token.typeSize = 0;
  			break;
  		case Const.VARCHAR:
  			typeText = "VARCHAR";
  			token.typePrecision = 0;
  			break;
  		case Const.WILDCARD:
  			typeText = "";
  			token.typePrecision = 0;
  			token.typeSize = 0;
  			break;
  		default :
  			typeText = "NONE";
  			token.typePrecision = 0;
  			token.typeSize = 0;
  			yyerror(token.text + " type not treated");
  			break;
  	}
  	if(token.typePrecision != 0)
  		typeText += "(" + token.typeSize + "," + token.typePrecision + ")";
  	else if(token.typeSize != 0)
  		 typeText += "(" + token.typeSize + ")";
  	return typeText;
  }


  private int yylex () {

    int yyl_return = -1;
    try {
      yylval = new ParserVal(new Tokens());
      yyl_return = lexer.yylex();
    }
    catch (IOException e) {
      yyerror("IO error :"+e);
    }
    return yyl_return;

  }


  public void yyerror (String error) {

    this.error += "\nError Parser: " + error + "\nLine: " + line + "\nColumn: " + column;

  }



/*************************************************************************************************/
/*                                        CONSTRUCTORS   					 */
/*************************************************************************************************/


  public Parser(String in, PargresDatabaseMetaData meta, ParserIni parserIni, ArrayList<Range> rangeList,
                String vpTable, String vpAttribute) throws ParserSilentException {

      this.meta = meta;
      this.error = "";
      this.inQuery = in;
      this.rangeList = rangeList;
      this.vpTable = vpTable;
      this.vpAttribute = vpAttribute;
      this.fromTableAlias = new ArrayList<ArrayList<Table>>(parserIni.getFromTableAlias());
      this.error = parserIni.getError();
      this.groupByLevelList = parserIni.getGroupByLevelList();
      this.selectAliasLevelList = parserIni.getSelectAliasLevelList();
      this.existsAggregationSelect = new ArrayList<Boolean>(parserIni.getExistsAggregationSelect());
      //this.isFromClauseInnerSelect = parserIni.isFromClauseInnerSelect();
      lexer = new Yylex(new StringReader(in), this);
      this.yyparse();

      if(this.error.equals("")){
      	int b;
      	String aliasTemp;
      	logger.debug("\n"+this.vpQuery+"\n");
      	//logger.debug(printCommaList(groupByList));
      	//addToList(groupByList,qvpColumnsList);

      	for(b=0;b<selectCompositorText.size();b++){
      		logger.debug( Messages.getString("parser.compositorText",new Object[]{ b, selectCompositorText.get(b)}));
      	}
      	for(b=0;b<groupByTextList.size();b++){
      		logger.debug( Messages.getString("parser.groupByText",new Object[] { b, groupByTextList.get(b)}) );
      	}
      	for(b=0;b<orderByTextList.size();b++){
      		logger.debug( Messages.getString("parser.orderByText", new Object[] { b, orderByTextList.get(b)}) );
      	}
      	for(b=0;b<aliasTextList.size();b++){
      		logger.debug( Messages.getString("parser.alias",new Object[] { b, aliasTextList.get(b)}) );
      	}
      	for(b=0;b<qvpColumnsList.size();b++){
      		logger.debug( Messages.getString("parser.qvpTextType", new Object[] { b, qvpColumnsList.get(b).getTypeText()}) );
      	}
      	if(this.havingCompositorText!=null)
      		logger.debug( Messages.getString("parser.havingCompositor", this.havingCompositorText));
      	if(!this.limitText.equals(""))
      		logger.debug(Messages.getString("parser.limit",this.limitText));
      	}

  }


  /******************************Operators identifiers *******************************************

  Arithmetic::		Logic:: 	Relational :   Other :
  + : 1			OR : 7     	= : 10	       is null : 16
  - : 2			AND : 8		<> : 11        Is not null : 17
  * : 3     		NOT : 9		< : 12
  / : 4					> : 13
  +(unario) : 5				<= : 14
  -(unario) : 6 			>= : 15



  ************************************************************************************************/
