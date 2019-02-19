%{  
  import java.io.*;
  import java.util.ArrayList;
  import java.sql.ResultSet;  
  import org.pargres.jdbc.PargresDatabaseMetaData;
  import org.pargres.commons.util.ParserSilentException;
  import org.pargres.commons.util.ParserException;  
%}  


%token  TK_SELECT   TK_ALL   TK_DISTINCT   TK_USER   TK_INDICATOR   TK_NAME    TK_APPROXNUM   TK_INTNUM 
%token  TK_DATE TK_INTERVAL1  TK_INTERVAL2  TK_COMENTARIO  TK_EXISTS TK_PLIC  TK_STRING TK_CONCATENATION
%token  TK_AVG   TK_MIN   TK_MAX   TK_SUM   TK_COUNT   TK_INTO   TK_FROM   TK_WHERE   TK_OR   TK_AND    
%token  TK_NOT   TK_NULL   TK_IS   TK_BETWEEN   TK_LIKE   TK_ESCAPE   TK_DIFERENTE   TK_MENOR_IG TK_VERTBAR
%token  TK_MAIOR_IG   TK_GROUP   TK_BY   TK_HAVING   TK_ORDER   TK_ASC   TK_DESC   TK_AS TK_IN TK_LIMIT
%token  TK_NULLIF  TK_COALESCE  TK_CASE TK_END TK_WHEN TK_THEN TK_NULL TK_ELSE TK_TRUE  TK_FALSE
%token  TK_ANY TK_ALL TK_SOME TK_EXTRACT TK_SUBSTRING TK_FOR

%%

Select : Select_ini Selection Select_tail ';'{
            $$.sval = $1.sval +" "+ $2.sval + " "+ $3.sval +";";
            fromOuterQueryText = $$.sval;
         }
       ;
       
Select_ini : TK_SELECT {$$.sval = $1.sval;}
           ;
       
Select_tail : Into Table_exp {$$.sval = $1.sval+" "+ $2.sval;}
            | Table_exp {$$.sval = $1.sval;}
            ;

All_or_distinct : TK_ALL{$$.sval = $1.sval;}                
                | TK_DISTINCT {$$.sval = $1.sval;}
                ;

Selection : All_or_distinct Selection_term {$$.sval = $1.sval+" "+$2.sval;}
          | Selection_term {$$.sval = $1.sval;}
          ;

Selection_term : Wildcard {$$.sval = $1.sval;}
               | Scalar_exp_list_ini {$$.sval = $1.sval;}
               ;

Wildcard : '*' {$$.sval = "*";}
         ;

Scalar_exp_list_ini : Scalar_exp_list {$$.sval = $1.sval;}
                    ;

Scalar_exp_list : Scalar_exp_ini {$$.sval = $1.sval;}
                | Scalar_exp_ini ',' Scalar_exp_list {$$.sval = $1.sval+", "+$3.sval;}
                ;
                
Scalar_exp_ini : Scalar_exp_as {$$.sval = $1.sval;}
               ;

Scalar_exp_as : Scalar_condition TK_AS Name {
 		if(onlyText == 0) {
 		   selectAliasLevelList.get(subqueryLevel).add(new String($3.sval));
 	        }
 		$$.sval = $1.sval+" as "+$3.sval;
 	      }
              | Scalar_condition {
 		if(onlyText == 0) {
 		   selectAliasLevelList.get(subqueryLevel).add("");
 	        }
                $$.sval = $1.sval;
 	      }
              ;

Scalar_condition : Scalar_condition_term {$$.sval = $1.sval;}
                 | Scalar_condition_term TK_OR Scalar_condition {$$.sval = $1.sval +" or "+ $3.sval;}
                 ;
	
Scalar_condition_term : Scalar_Not_tag {$$.sval = $1.sval;}
            	      | Scalar_Not_tag TK_AND Scalar_condition_term{$$.sval = $1.sval + " and " + $3.sval;}
            	      ;


Scalar_Not_tag : Scalar_predicate {$$.sval = $1.sval;}
               | TK_NOT Scalar_predicate {$$.sval = "not" + $2.sval;}
               ;
               
Scalar_predicate : Test_for_null {$$.sval = $1.sval;}
          /***   | Existence_test subquery    
                 |     <in predicate>
                 |     <quantified comparison predicate>
		 |     <exists predicate>
		 |     <unique predicate>
		 |     <match predicate>
		 |     <overlaps predicate>
		 |     <similar predicate>
		 |     <distinct predicate>
	         |     <type predicate> 

	  ***/
	  | Existence_test {$$.sval = $1.sval;}
          | Scalar_relational_exp {$$.sval = $1.sval;}
          ;

Scalar_relational_exp : Scalar_exp {$$.sval = $1.sval;}
               	      | Scalar_exp Comparison Scalar_relational_rvalue{$$.sval = $1.sval+" "+ $2.sval+" "+$3.sval;}
                      | Scalar_relational_predicate {$$.sval = $1.sval;}
                      ;

Scalar_relational_predicate : Scalar_between_predicate{$$.sval = $1.sval;}
                            | Scalar_like_predicate{$$.sval = $1.sval;}
                            | Scalar_in_predicate {$$.sval = $1.sval;}
                            ;


Scalar_relational_rvalue : Scalar_exp {$$.sval = $1.sval;}
                  	 | Any_all_some  '(' Subquery ')' {$$.sval = $1.sval+" ("+ $3.sval +")" ;}
                         | '(' Subquery ')'{$$.sval = "("+$2.sval+")";}
                         ;
                  

Scalar_exp : Scalar_term {$$.sval = $1.sval;}
           | Scalar_term '+' Scalar_exp {$$.sval = $1.sval +" + "+ $3.sval;}
           | Scalar_term '-' Scalar_exp  {$$.sval = $1.sval +" - "+ $3.sval;}
           ;

Scalar_term : Scalar_concatenation_op {$$.sval = $1.sval;}
            | Scalar_concatenation_op '*' Scalar_term   {$$.sval = $1.sval +" * "+ $3.sval;}            
            | Scalar_concatenation_op '/' Scalar_term {$$.sval = $1.sval +" / "+ $3.sval;}
            ;

Scalar_concatenation_op : Scalar_factor_unary_op {$$.sval = $1.sval;}
			| Scalar_factor_unary_op TK_VERTBAR Scalar_concatenation_op {
			     $$.sval = $1.sval +" "+$2.sval+" "+ $3.sval;
			  }
			;


Scalar_factor_unary_op : Scalar_factor  {$$.sval = $1.sval;}
                       | '+' Scalar_factor {$$.sval = "+"+$2.sval;}
                       | '-' Scalar_factor {$$.sval = "-"+$2.sval;}
                       ;

Scalar_factor : Function_ref_selection {
                $$.sval = $1.sval;
                if(onlyText == 0) {
                   existsAggregationSelect.set(subqueryLevel,true);
                }                
              }                              
              | Column_ref {$$.sval = $1.sval;}
              | '(' Scalar_condition ')' {$$.sval = "("+$2.sval+")";}
              | Literal_selection {$$.sval = $1.sval;}
              | Case_expression {$$.sval = $1.sval;}
              | Numeric_value_function {$$.sval = $1.sval;}
              | String_value_function {$$.sval = $1.sval;}
              ;              

Scalar_between_predicate : Scalar_exp TK_BETWEEN Scalar_exp TK_AND Scalar_exp {
 			      $$.sval = $1.sval +" "+$2.sval+" "+ $3.sval+" "+ $4.sval+" "+ $5.sval;
 			   }
                         | Scalar_exp TK_NOT TK_BETWEEN Scalar_exp TK_AND Scalar_exp {
                              $$.sval = $1.sval +" "+$2.sval+" "+ $3.sval+" "+ $4.sval+" "+ $5.sval+" "+ $6.sval;
                           }
                         ;

Scalar_like_predicate : Scalar_exp TK_LIKE Scalar_exp {$$.sval = $1.sval +" "+$2.sval+" "+ $3.sval;}
                      | Scalar_exp TK_LIKE Scalar_exp Search_escape {$$.sval = $1.sval +" "+$2.sval+" "+ $3.sval+" "+ $4.sval;}
                      | Scalar_exp TK_NOT TK_LIKE Scalar_exp {$$.sval = $1.sval +" "+$2.sval+" "+ $3.sval+" "+ $4.sval;}
                      | Scalar_exp TK_NOT TK_LIKE Scalar_exp Search_escape {$$.sval = $1.sval +" "+$2.sval+" "+ $3.sval+" "+ $4.sval+" "+ $5.sval;}
                      ;               


/************************************************************************************************/
/**				          SCALAR IN PREDICATE   	                       **/
/************************************************************************************************/


Scalar_in_predicate : Scalar_exp TK_IN '(' Subquery_ini Selection Select_tail ')' {
			$$.sval = $1.sval +" in ("+$4.sval+" "+ $5.sval+" "+ $6.sval+")";
			subqueryLevel--;
		      }
		    | Scalar_exp TK_NOT TK_IN '(' Subquery_ini Selection Select_tail ')' {
		        $$.sval = $1.sval +" not in ("+$5.sval+" "+ $6.sval+" "+ $7.sval+")";
		        subqueryLevel--;
		      }
		    | Scalar_exp TK_IN '(' Scalar_in_value_list ')' {
		        $$.sval = $1.sval +" in ("+$4.sval+")";
		      }
		    | Scalar_exp TK_NOT TK_IN '(' Scalar_in_value_list ')' {
		        $$.sval = $1.sval +" not in ("+$5.sval+")";
		      }
                    ;		   
		   
Scalar_in_value_list : Scalar_condition {$$.sval = $1.sval;}
	      	     | Scalar_condition ',' Scalar_in_value_list {$$.sval = $1.sval+", "+ $3.sval;}
	      	     ;

/************************************************************************************************/
/**         			        		                                       **/
/************************************************************************************************/

Parameter_ref : Parameter Parameter_tail {$$.sval = $1.sval+" "+$2.sval;}
              | Parameter {$$.sval = $1.sval;}
              ;

Parameter_tail : TK_INDICATOR Parameter {$$.sval = $1.sval+" "+$2.sval;}
               | Parameter {$$.sval = $1.sval;}
               ;

Parameter : ':' Name {$$.sval = ":"+$2.sval;}
          ;

Name : TK_NAME {$$.sval = $1.sval;}
     ;
     
Literal_selection : String {$$.sval = $1.sval;}
                  | Approxnum {$$.sval = $1.sval;}
                  | Intnum {$$.sval = $1.sval;}
                  | TK_DATE String {$$.sval = $1.sval+" "+ $2.sval;}
                  | Interval {$$.sval = $1.sval;}
                  | Boolean {$$.sval = $1.sval;}
                  | Null {$$.sval = $1.sval;}
                  ;     

Literal : String {$$.sval = $1.sval;}
        | Approxnum {$$.sval = $1.sval;}
        | Intnum {$$.sval = $1.sval;}
        | TK_DATE String {$$.sval = $1.sval + " " + $2.sval;} 
        | Interval {$$.sval = $1.sval;}
        | Boolean{$$.sval = $1.sval;}
        | Null {$$.sval = $1.sval;}
        ;


String :  TK_STRING   {$$.sval = $1.sval ;}
       ; 
       
Approxnum : TK_APPROXNUM {$$.sval = $1.sval;}
          ;
          
Intnum : TK_INTNUM {$$.sval = $1.sval;}
       ;

Boolean : TK_TRUE {$$.sval = $1.sval;}
        | TK_FALSE {$$.sval = $1.sval;}
        ;

Null : TK_NULL {$$.sval = $1.sval;}
     ;
     

Interval : TK_INTERVAL1 {$$.sval = $1.sval;}
         | TK_INTERVAL2 {$$.sval = $1.sval;}
         ;

/************************************************************************************************/
/**				          FUNCTION REF SELECTIN                                **/
/************************************************************************************************/
         
Function_ref_selection : Function_name '(' Function_parameters ')' {$$.sval = $1.sval+"("+$3.sval+")";}
                       ;                       
                       
Function_name : TK_AVG {$$.sval = $1.sval;}
              | TK_MIN {$$.sval = $1.sval;}
              | TK_MAX {$$.sval = $1.sval;}
              | TK_SUM {$$.sval = $1.sval;}
              | TK_COUNT {$$.sval = $1.sval;}
              ;              
              
Function_parameters : Wildcard {$$.sval = $1.sval;}
                    | Distinct_literal Column_ref {$$.sval = $1.sval+" "+ $2.sval;}
                    | All_literal Function_Scalar_exp {$$.sval = $1.sval+" "+ $2.sval;}
                    | Function_Scalar_exp {$$.sval = $1.sval;}
                    ;
             
Function_Scalar_exp : Function_Scalar_term {$$.sval = $1.sval;}
                    | Function_Scalar_term '+' Function_Scalar_exp {$$.sval = $1.sval +" + "+ $3.sval;}
		    | Function_Scalar_term '-' Function_Scalar_exp {$$.sval = $1.sval +" - "+ $3.sval;}
                    ;

Function_Scalar_term : Function_concatenation_op {$$.sval = $1.sval;}
                     | Function_concatenation_op '*' Function_Scalar_term {$$.sval = $1.sval +" * "+ $3.sval;}
                     | Function_concatenation_op '/' Function_Scalar_term {$$.sval = $1.sval +" / "+ $3.sval;}
                     ;

Function_concatenation_op : Function_Scalar_factor_unary_op {$$.sval = $1.sval;}
			  | Function_Scalar_factor_unary_op TK_VERTBAR Function_concatenation_op {
			       $$.sval = $1.sval + " " +$2.sval + " " + $3.sval;
			    }
			  ;

Function_Scalar_factor_unary_op : '+' Function_Scalar_factor {$$.sval = "+" + $2.sval;}
                                | '-' Function_Scalar_factor  {$$.sval = "-" + $2.sval;}
                                | Function_Scalar_factor {$$.sval = $1.sval;}
                                ;

Function_Scalar_factor : Column_ref  {$$.sval = $1.sval;}
                       | '(' Function_Scalar_exp ')' {$$.sval = "("+$2.sval+")";}                         
                       | Literal {$$.sval = $1.sval;}
                       | Case_expression {$$.sval = $1.sval;}     
                       | Numeric_value_function {$$.sval = $1.sval;}
                       | String_value_function {$$.sval = $1.sval;}
                       ;
                       
/************************************************************************************************/
/**				          NUMERIC VALUE FUNCTION                               **/
/************************************************************************************************/

Numeric_value_function : Extract_expression {$$.sval = $1.sval;}
     		       /*
     		       | position expression
     		       | length expression
     		       | cardinality expression
     		       | absolute value expression
     		       | modulus expression
     		       */
     		       ;
     		       
Extract_expression : TK_EXTRACT '(' Extract_field TK_FROM Extract_source ')' { 
		        $$.sval = $1.sval + "( " + $3.sval + " " + $4.sval + " " + $5.sval + " )";	        	 
		   }
		   ;

Extract_field : Name {$$.sval = $1.sval;}
	      ;

Extract_source : Function_Scalar_exp {$$.sval = $1.sval;}
 	       ;

/************************************************************************************************/
/**				          STRING VALUE FUNCTION                                **/
/************************************************************************************************/

String_value_function : Character_substring_function {$$.sval = $1.sval;}		       
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
			 	$$.sval = $1.sval + "( " + $3.sval + " " + $4.sval + " "  + $5.sval + " )";	        	 
			      }
			     | TK_SUBSTRING '(' Function_Scalar_exp TK_FROM TK_INTNUM TK_FOR TK_INTNUM ')' {
			 	$$.sval = $1.sval + "( " + $3.sval + " " + $4.sval + " "  + $5.sval + " " +
			    		  $6.sval + " "  + $7.sval +" )";	        	 
			      }
			     ;
            
/************************************************************************************************/
/**				                                       			       **/
/************************************************************************************************/

Distinct_literal : TK_DISTINCT {$$.sval = $1.sval;}
                 ; 
                 
Column_ref  : Name {$$.sval = $1.sval;}
            | Name '.' Wildcard {$$.sval = $1.sval + ".*";}
            | Name '.' Name {$$.sval = $1.sval + "." + $3.sval;}                 
            ; 

All_literal : TK_ALL {$$.sval = $1.sval;}
            ;

Into : TK_INTO Target_list {$$.sval = $1.sval+" "+ $2.sval;}
     ;

Any_all_some : TK_ANY {$$.sval = $1.sval;}
	     | TK_ALL {$$.sval = $1.sval;}
	     | TK_SOME {$$.sval = $1.sval;}
	     ;

Target_list : Target {$$.sval = $1.sval;}
            | Target ',' Target_list {$$.sval = $1.sval +", "+ $3.sval;}
            ;

Target : Parameter_ref {$$.sval = $1.sval;}
       ;

/************************************************************************************************/
/**         			    Case Expression Clause    		                       **/
/************************************************************************************************/

Case_expression : Case_abbreviation {$$.sval = $1.sval;}
                | Case_specification {$$.sval = $1.sval;}
	        ;
	       
Case_abbreviation : Nullif '(' Value_expression ',' Value_expression ')' {
 		       $$.sval = $1.sval +"("+ $3.sval +", "+ $5.sval +")";
 		    }
                  | Coalesce '(' Coalesce_value_expression_list ')' {
                        $$.sval = $1.sval +"("+ $3.sval+")";
                    }
                  ;
                  
Nullif : TK_NULLIF {$$.sval = $1.sval;}
       ;

Coalesce : TK_COALESCE {$$.sval = $1.sval;}
         ;

Case : TK_CASE {$$.sval = $1.sval;}
     ;	

Coalesce_value_expression_list : Value_expression {$$.sval = $1.sval;}
	              | Value_expression ',' Coalesce_value_expression_list {
	                    $$.sval = $1.sval +", "+ $3.sval;
	                }
	              ;

Case_specification : Simple_case {$$.sval = $1.sval;}
  	           | Searched_case {$$.sval = $1.sval;}
  	           ;

Simple_case : Case  Value_expression Simple_when_clause_list TK_END {
 	          $$.sval = $1.sval +" "+ $2.sval +" "+ $3.sval +" "+ $4.sval;
 	      }
 	    | Case  Value_expression Simple_when_clause_list Else_clause TK_END {
 	         $$.sval = $1.sval +" "+ $2.sval +" "+ $3.sval +" "+ $4.sval + " "+ $5.sval;
 	      }
 	    ;

Simple_when_clause_list : Simple_when_clause {$$.sval = $1.sval;}
			| Simple_when_clause Simple_when_clause_list {$$.sval = $1.sval +" "+ $2.sval;}
			;

Simple_when_clause : TK_WHEN Value_expression TK_THEN Value_expression {
		        $$.sval = $1.sval +" "+ $2.sval +" "+ $3.sval +" "+ $4.sval;
		     }
		   ;
		   
Else_clause : TK_ELSE Value_expression {$$.sval = $1.sval +" "+ $2.sval;}
            ;

Searched_case : Case Searched_when_clause_list TK_END {
		   $$.sval = $1.sval +" "+ $2.sval +" "+ $3.sval;
		}
	      | Case Searched_when_clause_list Else_clause TK_END {
	           $$.sval = $1.sval +" "+ $2.sval +" "+ $3.sval +" "+ $4.sval;
	        }
	      ;

Searched_when_clause_list : Searched_when_clause {$$.sval = $1.sval;}
			  | Searched_when_clause Searched_when_clause_list {
			       $$.sval = $1.sval +" "+ $2.sval;
			    }
		    	  ;
Searched_when_clause : TK_WHEN Scalar_condition TK_THEN Value_expression {
 		          $$.sval = $1.sval +" "+ $2.sval +" "+ $3.sval +" "+ $4.sval;
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

Value_expression : Scalar_condition {$$.sval = $1.sval;}
		 ;


/************************************************************************************************/
/**         			    Table Expression Clause    		                       **/
/************************************************************************************************/

Table_exp : From_clause Opt_where_group_having_order {$$.sval = $1.sval +" "+ $2.sval;}
          | From_clause {$$.sval = $1.sval;}
          ;

Opt_where_group_having_order : Where_clause Opt_group_having_order {$$.sval = $1.sval +" "+ $2.sval;}
                             | Where_clause {$$.sval = $1.sval;}
                             | Opt_group_having_order {$$.sval = $1.sval;}
                             ;

Opt_group_having_order : Group_by_clause Opt_having_order {$$.sval = $1.sval +" "+ $2.sval;}
                       | Group_by_clause {$$.sval = $1.sval;}
                       | Opt_having_order {$$.sval = $1.sval;}
                       ;   

Opt_having_order : Having_clause Order_by_clause_limit {$$.sval = $1.sval +" "+ $2.sval;}
                 | Having_clause {$$.sval = $1.sval;}
                 | Order_by_clause_limit {$$.sval = $1.sval;}
                 ;

Order_by_clause_limit : Order_by_clause Limit_clause {$$.sval = $1.sval +" "+ $2.sval;}
		      | Order_by_clause {$$.sval = $1.sval;}
		      | Limit_clause {$$.sval = $1.sval;}
		      ;

Limit_clause : TK_LIMIT Intnum {$$.sval = "\n" + $1.sval +" "+ $2.sval;}
	     ;                 
                 
/************************************************************************************************/
/**					Group by Clause    		                       **/
/************************************************************************************************/

                 

Group_by_clause : TK_GROUP TK_BY Group_by_ref_list_Ini {$$.sval = "\n"+$1.sval +" "+ $2.sval +" "+ $3.sval;}
                ;                

Group_by_ref_list_Ini : Column_ref_list {$$.sval = $1.sval;}
		   ;
		   
Column_ref_list : Column_ref_pre {$$.sval = $1.sval;}
                | Column_ref_pre ',' Column_ref_list {$$.sval = $1.sval + ", " + $3.sval; }
                ; 
                
Column_ref_pre : Group_by_Scalar_exp{
                 if(onlyText == 0) {
		    groupByLevelList.get(subqueryLevel).add(new String($1.sval));
		 }
                 $$.sval = $1.sval;
	       }
               ;               

Group_by_Scalar_exp : Group_by_Scalar_term {$$.sval = $1.sval;}          
                    | Group_by_Scalar_term '+' Group_by_Scalar_exp { $$.sval = $1.sval + " + " + $3.sval;}
		    | Group_by_Scalar_term '-' Group_by_Scalar_exp { $$.sval = $1.sval + " - " + $3.sval;}
                    ;

Group_by_Scalar_term : Group_by_concatenation_op {$$.sval = $1.sval;}
                     | Group_by_concatenation_op '*' Group_by_Scalar_term {$$.sval = $1.sval + " * " + $3.sval;}
                     | Group_by_concatenation_op '/' Group_by_Scalar_term {$$.sval = $1.sval + " / " + $3.sval;}
                     ;

Group_by_concatenation_op : Group_by_Scalar_factor_unary_op {$$.sval = $1.sval;}
			  | Group_by_Scalar_factor_unary_op TK_VERTBAR Group_by_concatenation_op {
			       $$.sval = $1.sval + " || " + $3.sval;
			    }
			  ;

Group_by_Scalar_factor_unary_op : '+' Group_by_Scalar_factor {$$.sval = "+" + $2.sval;}                                
                                | '-' Group_by_Scalar_factor {$$.sval = "-" + $2.sval;}                                
                                | Group_by_Scalar_factor {$$.sval = $1.sval;}
                                ;

Group_by_Scalar_factor : Column_ref {$$.sval = $1.sval;}                             
                       | '(' Group_by_Scalar_exp ')' {$$.sval = "(" + $2.sval + ")";} 
                       | Literal {$$.sval = $1.sval;}
                       ;                        

/************************************************************************************************/
/**					Order by Clause    		                       **/
/************************************************************************************************/


Order_by_clause : TK_ORDER TK_BY Ordering_spec_list {$$.sval = "\n" + $1.sval +" "+ $2.sval +" "+ $3.sval;}
		;
		
Ordering_spec_list : Ordering_spec {$$.sval = $1.sval;}
                   | Ordering_spec ',' Ordering_spec_list {$$.sval = $1.sval +", "+ $3.sval;}
                   ;
                   
Ordering_spec : Intnum {$$.sval = $1.sval;}
              | Intnum Asc_desc {$$.sval = $1.sval +" "+ $2.sval;}
              | Column_ref {$$.sval = $1.sval;}
              | Column_ref Asc_desc {$$.sval = $1.sval +" "+ $2.sval;}
              ;

Asc_desc : TK_ASC {$$.sval = $1.sval;}
         | TK_DESC {$$.sval = $1.sval;}
         ; 
	

/************************************************************************************************/
/**					From Clause    		                               **/ 
/************************************************************************************************/

	
	
From_clause : TK_FROM Table_ref_list {$$.sval = "\n" + $1.sval +" "+ $2.sval;}
            ;

Table_ref_list : Table_ref {$$.sval = $1.sval;}
               | Table_ref ',' Table_ref_list {
               	    if(isFromClauseInnerSelect && (subqueryLevel == 0) && (fromSubqueryLevel == 0))
               	    	throw(new ParserSilentException("InterQuery : From subquery must be unique in the FROM clause. Line : "+line+" Column : "+column));                    
                    $$.sval = $1.sval +", "+ $3.sval;
                 }
               ;

Table_ref : Table {$$.sval = $1.sval;}
          | '(' From_subquery ')' {
            myYyerror("Subquery in From must have an alias");
            $$.sval ="("+ $2.sval+")";            
             }
           | '(' From_subquery ')' Name {
            //$$.sval ="("+ $2.sval+") " + $4.sval;
            fromSubqueryAlias = $4.sval;
            $$.sval = $4.sval;
            }
          | '(' From_subquery ')' TK_AS Name {
            fromSubqueryAlias = $5.sval;
            $$.sval = $5.sval;
            }
          | '(' From_subquery ')' '(' Name_list ')' {
                myYyerror("Subquery in From must have an alias");
                $$.sval ="("+ $2.sval+") (" + $5.sval +")";	
            }
          | '(' From_subquery ')' Name '(' Name_list ')' {
                fromSubqueryAlias = $4.sval;
                $$.sval = $4.sval;
            }
          | '(' From_subquery ')' TK_AS Name '(' Name_list ')' {
                fromSubqueryAlias = $5.sval;
                $$.sval = $5.sval;
            }
          
          ;
          
Table : Q_table {
        if(onlyText == 0) {
           if(subqueryLevel==0){
	   	tableList.add(new String($1.sval));
	        tableList.trimToSize();
           }
	   verifyTableExistence($1.sval);
           verifyDualReferencedTable($1.sval,subqueryLevel);          
           fromTableAlias.get(subqueryLevel).add( new Table($1.sval , $1.sval) );
           fromTableAlias.get(subqueryLevel).trimToSize();           
        }
	$$.sval = $1.sval;
      }
      | Q_table Name {
        if(onlyText == 0) {
           if(subqueryLevel==0){
	   	tableList.add(new String($1.sval));
	        tableList.trimToSize();
           }
      	   verifyTableExistence($1.sval);
      	   verifyDualReferencedTable($2.sval,subqueryLevel);           
           fromTableAlias.get(subqueryLevel).add( new Table($1.sval , $2.sval) );
           fromTableAlias.get(subqueryLevel).trimToSize();          
        }
        $$.sval = $1.sval+" "+ $2.sval;
      }
      | Q_table TK_AS Name {
        if(onlyText == 0) {
           if(subqueryLevel==0){
	   	tableList.add(new String($1.sval));
	        tableList.trimToSize();
           }
      	   verifyTableExistence($1.sval);
      	   verifyDualReferencedTable($3.sval,subqueryLevel);
      	   fromTableAlias.get(subqueryLevel).add( new Table($1.sval , $3.sval) );
           fromTableAlias.get(subqueryLevel).trimToSize();
        }
        $$.sval = $1.sval+" as "+ $3.sval;
        
      }
      ;

Q_table : Name {$$.sval = $1.sval;}
        | Name '.' Name {
             $$.sval = $1.sval +"."+ $3.sval;
          }
        | Name '.' Name '.' Name {
             $$.sval = $1.sval + "." + $3.sval + "." + $5.sval;
          }
        ;


From_subquery : From_subquery_ini Selection Select_tail {
		   onlyText--;
		   fromSubqueryLevel--;
		   $$.sval = $1.sval +" "+ $2.sval + " " + $3.sval;
		   fromSubqueryText = $$.sval +";";
	 	}
              ;

From_subquery_ini : TK_SELECT {
		    if(fromSubqueryLevel>0)
		    	throw(new ParserSilentException("InterQuery : So far, only one FROM subquery level is treated. Line : "+line+" Column :"+column));
               	    if(subqueryLevel>0)
               	    	throw(new ParserSilentException("InterQuery : So far, only outerquery FROM subquery is treated. Line : "+line+" Column :"+column));
 		    $$.sval = $1.sval;
 		    fromSubqueryLevel++;
		    onlyText++;
		    isFromClauseInnerSelect=true;
		  }
            	  ;
              
Name_list : Name_ini {
 	       $$.sval = $1.sval;
 	    }
	  | Name_ini ',' Name_list {
	       $$.sval = $1.sval + ", " + $3.sval;
	    }
	  ;

Name_ini : Name {
	      fromSelectAliasTextList.add($1.sval);
	      fromSelectAliasTextList.trimToSize();
 	      $$.sval = $1.sval;
	   }
	 ;

/************************************************************************************************/
/**					 Where Clause    		                       **/
/************************************************************************************************/


Where_clause :TK_WHERE Where_condition {$$.sval = "\n" + $1.sval +" "+ $2.sval;}
             ;
             
Where_condition :  Where_term {$$.sval = $1.sval;}
                 | Where_term TK_OR Where_condition {$$.sval = $1.sval +" or "+ $3.sval;}
                 ;

Where_term :  Where_Not_tag {$$.sval = $1.sval;}
            | Where_Not_tag TK_AND Where_term {$$.sval = $1.sval +" and "+ $3.sval;}
            ;


Where_Not_tag : Where_Predicate {$$.sval = $1.sval;}
              | TK_NOT Where_Predicate {$$.sval = $1.sval +" "+ $2.sval;}
              ;
               
Where_Predicate : Test_for_null {$$.sval = $1.sval;}
                | Existence_test {$$.sval = $1.sval;}
                | Where_Relational_exp {$$.sval = $1.sval;}
                ;
             
Where_Relational_exp : Where_scalar_exp  {$$.sval = $1.sval;}
                     | Where_scalar_exp Comparison Where_Relational_rvalue {
                          $$.sval = $1.sval + " " + $2.sval + " " + $3.sval;
                       } 
                     | Where_Relational_predicate {$$.sval = $1.sval;}
                     ;

Where_Relational_rvalue : Where_scalar_exp {$$.sval = $1.sval;}
                  	 | Any_all_some  '(' Subquery ')' {$$.sval = $1.sval +" ("+ $3.sval + ")";}
                         | '(' Subquery ')' {$$.sval = "("+$2.sval +")" ;}
                  	 ;
                  
Where_scalar_exp : Where_scalar_term {$$.sval = $1.sval;}
                 | Where_scalar_term '+' Where_scalar_exp {$$.sval = $1.sval +" + "+ $3.sval;}
                 | Where_scalar_term '-' Where_scalar_exp {$$.sval = $1.sval +" - "+ $3.sval;}
                 ;

Where_scalar_term : Where_concatenation_op {$$.sval = $1.sval;}
                  | Where_concatenation_op '*' Where_scalar_term{$$.sval = $1.sval +" * "+ $3.sval;}
                  | Where_concatenation_op '/' Where_scalar_term{$$.sval = $1.sval +" / "+ $3.sval;}
                  ;

Where_concatenation_op : Where_scalar_factor_unary_op {$$.sval = $1.sval;}
		       | Where_scalar_factor_unary_op TK_VERTBAR Where_concatenation_op {
		            $$.sval = $1.sval +" "+$2.sval+" "+ $3.sval;
		         }
		       ;

Where_scalar_factor_unary_op : Where_scalar_factor {$$.sval = $1.sval;}
                             | '-' Where_scalar_factor {$$.sval = "-"+ $2.sval;}
                             | '+' Where_scalar_factor {$$.sval = "+"+ $2.sval;}                      
                             ;
  
Where_scalar_factor :  Column_ref {$$.sval = $1.sval;}                          
          	    | '(' Where_condition ')' {$$.sval = "("+ $2.sval +")";}                                   
           	    | Literal {$$.sval = $1.sval;}
           	    | Numeric_value_function {$$.sval = $1.sval;}
           	    | String_value_function {$$.sval = $1.sval;}
            	    ; 
              
Where_Relational_predicate : Where_Between_predicate  {$$.sval = $1.sval;}                    
                           | Where_Like_predicate {$$.sval = $1.sval;}
                           | Where_in_predicate {$$.sval = $1.sval;}
                           ;      
                     
Where_Between_predicate : Where_scalar_exp TK_BETWEEN Where_scalar_exp TK_AND Where_scalar_exp {
			     $$.sval = $1.sval +" "+$2.sval+" "+ $3.sval+" "+ $4.sval+" "+ $5.sval;
			  }
                  | Where_scalar_exp TK_NOT TK_BETWEEN Where_scalar_exp TK_AND Where_scalar_exp {
                       $$.sval = $1.sval +" "+$2.sval+" "+ $3.sval+" "+ $4.sval+" "+ $5.sval+" "+ $6.sval;
                    }
                  ;
                  
Where_Like_predicate : Where_scalar_exp TK_LIKE Where_scalar_exp {$$.sval = $1.sval +" "+$2.sval+" "+ $3.sval;}
                     | Where_scalar_exp TK_LIKE Where_scalar_exp Where_escape {
                          $$.sval = $1.sval +" "+$2.sval+" "+ $3.sval+" "+ $4.sval;
                       }
                     | Where_scalar_exp TK_NOT TK_LIKE Where_scalar_exp {
                          $$.sval = $1.sval +" "+$2.sval+" "+ $3.sval+" "+ $4.sval;
                       }
                     | Where_scalar_exp TK_NOT TK_LIKE Where_scalar_exp Where_escape {
                          $$.sval = $1.sval +" "+$2.sval+" "+ $3.sval+" "+ $4.sval+" "+ $5.sval;
                       }
                     ;

Where_escape : TK_ESCAPE Column_ref {$$.sval = $1.sval +" "+$2.sval;}
             | TK_ESCAPE Literal {$$.sval = $1.sval +" "+$2.sval;}
             ;

/************************************************************************************************/
/**				          EXISTS SUBQUERY   	                               **/
/************************************************************************************************/
           
Existence_test : TK_EXISTS '(' Subquery ')' {$$.sval = $1.sval +" ("+$3.sval+")";}
               ;

/************************************************************************************************/
/**				          WHERE IN PREDICATE   	                               **/
/************************************************************************************************/


Where_in_predicate : Where_scalar_exp TK_IN '(' Subquery_ini Selection Select_tail ')' {
		        $$.sval = $1.sval + " in (" + $4.sval + " " + $5.sval + " " + $6.sval +")";
		        subqueryLevel--;
		     }		   
		   | Where_scalar_exp TK_NOT TK_IN '(' Subquery_ini Selection Select_tail ')'{
		        $$.sval = $1.sval + " not in (" + $5.sval + " " + $6.sval + " " + $7.sval + ")";
		        subqueryLevel--;
		     }
		   | Where_scalar_exp  TK_IN '(' In_value_list ')' {
		        $$.sval = $1.sval + " in (" + $4.sval + ")";
		     }
		   | Where_scalar_exp TK_NOT TK_IN '(' In_value_list ')' {
		        $$.sval = $1.sval + " not in (" + $5.sval + ")";
		     }
                   ;		   
		   
In_value_list : Where_scalar_exp {$$.sval = $1.sval;}
	      | Where_scalar_exp ',' In_value_list {$$.sval = $1.sval +", "+$3.sval;}
	      ;	      


/************************************************************************************************/
/**					Having Clause    		                       **/
/************************************************************************************************/
                       

Having_clause : TK_HAVING Scalar_condition {$$.sval = "\n"+ $1.sval +" "+$2.sval;}
              ;                       

Test_for_null : Column_ref TK_IS TK_NULL {$$.sval = $1.sval + " " + $2.sval + " " + $3.sval;}
              | Column_ref TK_IS TK_NOT TK_NULL {$$.sval = $1.sval + " " + $2.sval+ " " + $3.sval + " " + $4.sval;}
              ;

Comparison : '=' {$$.sval = "=";}
           | TK_DIFERENTE {$$.sval = $1.sval;}
           | '<' {$$.sval = "<";}
           | '>' {$$.sval = ">";}
           | TK_MENOR_IG {$$.sval = $1.sval;}
           | TK_MAIOR_IG {$$.sval = $1.sval;}
           ;
               
Search_escape : TK_ESCAPE Column_ref {$$.sval = $1.sval + " " + $2.sval;}                            
              | TK_ESCAPE Literal {$$.sval = $1.sval + " " + $2.sval;}
              ;  

/************************************************************************************************/
/**					     SUBQUERY    		                       **/
/************************************************************************************************/

Subquery : Subquery_ini Selection Select_tail {
	      $$.sval = $1.sval +" "+$2.sval+ " " +$3.sval;
	      subqueryLevel--;
	   }
	 ;

Subquery_ini : TK_SELECT {
                  $$.sval = $1.sval;
                  subqueryLevel++;
                  existsAggregationSelect.add(false);
                  fromTableAlias.add(new ArrayList<Table>(0));
                  groupByLevelList.add(new ArrayList<String>(0));
                  selectAliasLevelList.add(new ArrayList<String>(0));
               }
             ;

%% 

  private LexIni lexer;  
  private String error;
  private String errorIni;
  public int line;
  public int column;
  private boolean isFromClauseInnerSelect = false;
  private int subqueryLevel = 0;
  private int fromSubqueryLevel = 0;
  private int onlyText = 0;
  private ArrayList<String> fromSelectAliasTextList = new ArrayList<String>(0);
  private ArrayList <String> tableList = new ArrayList<String>(0); 
  private ArrayList <Boolean> existsAggregationSelect = new ArrayList<Boolean>(0);
  private ArrayList <ArrayList<Table>> fromTableAlias = new ArrayList<ArrayList<Table>>(0);
  private ArrayList <ArrayList<String>> groupByLevelList = new ArrayList<ArrayList<String>>(0);
  private ArrayList <ArrayList<String>> selectAliasLevelList = new ArrayList<ArrayList<String>>(0);
  private PargresDatabaseMetaData meta;
  private ParserIni fromParserIni;
  private String fromSubqueryAlias;
  private String fromSubqueryText;
  private String fromOuterQueryText;
  
  
  public void verifyDualReferencedTable(String tableOrAlias, int fromTableAliasLevel){
  	for(int j=0;j<fromTableAlias.get(fromTableAliasLevel).size(); j++){  				
		if(fromTableAlias.get(fromTableAliasLevel).get(j).alias.toLowerCase().equals(tableOrAlias.toLowerCase())){
		      	myYyerror("Table name " + new String(tableOrAlias) + " specified more than once" );
		      	break;
		}	      			
	}
  }
  
  
  private void verifyTableExistence(String table) {
    	try {
    		ResultSet columnList = meta.getColumns(null,null,table.toUpperCase(),null);
    		if(!columnList.next()) 
    			myYyerror("Relation " + new String(table) + " does not exists" );
    	} catch (Exception e) {
    		myYyerror(e.toString());    		
    	  }    		
  }
  
  
  public String getErrorIni(){  	
      	return errorIni;
    }
  
  public String getError(){  	
        return error;
  }
    
  public ArrayList<String> getTableList(){
      	return tableList;
  }
  
  public ArrayList <ArrayList<Table>> getFromTableAlias(){
  	return fromTableAlias;
  }
  
  public ArrayList <ArrayList<String>> getGroupByLevelList(){
  	return groupByLevelList;
  }
  
  public ArrayList <ArrayList<String>> getSelectAliasLevelList(){
  	return selectAliasLevelList;
  }
    
  public ArrayList <Boolean> getExistsAggregationSelect(){
  	return existsAggregationSelect;  
  }

  public boolean isFromClauseInnerSelect(){
  	return isFromClauseInnerSelect;  
  } 
  
  public ArrayList<String> getFromSelectAliasTextList(){
        return fromSelectAliasTextList;
  }
  
  public String getFromSubqueryAlias(){
  	return fromSubqueryAlias;
  }
  
  public String getFromSubqueryText(){
  	return fromSubqueryText;
  }

  public String getFromOuterQueryText(){
  	return fromOuterQueryText;
  }
  
  private int yylex () {
  
    int yyl_return = -1;
    try {
      yylval = new ParserIniVal("");
      yyl_return = lexer.yylex();
    }
    catch (IOException e) {
      yyerror("IO error :"+e);
    }
    return yyl_return;
    
  }
  public void yyerror (String error){
  
  	this.errorIni += "\nError: " + error + "\nLine: " + line + "\nColumn: " + column;
  
  } 

  public void myYyerror (String error) {
  
 	 this.error += "\nError: " + error + "\nLine: " + line + "\nColumn: " + column ;
 	 this.errorIni += "\nError: " + error + "\nLine: " + line + "\nColumn: " + column;
    
  }
  
  public ParserIni(String in, PargresDatabaseMetaData meta) throws ParserSilentException, ParserException{
  
      this.meta = meta;
      this.error="";      
      this.errorIni="";      
      existsAggregationSelect.add(false);
      fromTableAlias.add(new ArrayList<Table>(0));
      groupByLevelList.add(new ArrayList<String>(0));
      selectAliasLevelList.add(new ArrayList<String>(0));
      
      lexer = new LexIni(new StringReader(in), this); 
      this.yyparse(); 
      
  }