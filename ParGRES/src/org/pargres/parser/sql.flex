package org.pargres.parser;

%%

%byaccj
%line
%column 

%{
  private Parser yyparser;   

  public Yylex(java.io.Reader r, Parser yyparser) {
    this(r);
    this.yyparser = yyparser;
  }
%}

FOR = (F|f)(O|o)(R|r)
SUBSTRING = (S|s)(U|u)(B|b)(S|s)(T|t)(R|r)(I|i)(N|n)(G|g) 
EXTRACT = (E|e)(X|x)(T|t)(R|r)(A|a)(C|c)(T|t)
NULLIF = (N|n)(U|u)(L|l)(L|l)(I|i)(F|f)
COALESCE = (C|c)(O|o)(A|a)(L|l)(E|e)(S|s)(C|c)(E|e) 
CASE = (C|c)(A|a)(S|s)(E|e) 
END = (E|e)(N|n)(D|d)
WHEN = (W|w)(H|h)(E|e)(N|n) 
THEN = (T|t)(H|h)(E|e)(N|n) 
ELSE = (E|e)(L|l)(S|s)(E|e) 
TRUE  = (T|t)(R|r)(U|u)(E|e) 
FALSE = (F|f)(A|a)(L|l)(S|s)(E|e) 

DATE = (D|d)(A|a)(T|t)(E|e)
ESCAPE = (E|e)(S|s)(C|c)(A|a)(P|p)(E|e)
BETWEEN = (B|b)(E|e)(T|t)(W|w)(E|e)(E|e)(N|n)
LIKE = (L|l)(I|i)(K|k)(E|e)
IS = (I|i)(S|s)
IN = (I|i)(N|n)
EXISTS = (E|e)(X|x)(I|i)(S|s)(T|t)(S|s)
NULL = (N|n)(U|u)(L|l)(L|l)
NOT = (N|n)(O|o)(T|t)
AND = (A|a)(N|n)(D|d)
OR = (O|o)(R|r)
AS = (A|a)(S|s)
ASC = (A|a)(S|s)(C|c)
DESC = (D|d)(E|e)(S|s)(C|c)
ORDER = (O|o)(R|r)(D|d)(E|e)(R|r)
GROUP =(G|g)(R|r)(O|o)(U|u)(P|p)
BY = (B|b)(Y|y)
HAVING = (H|h)(A|a)(V|v)(I|i)(N|n)(G|g)
LIMIT = (L|l)(I|i)(M|m)(I|i)(T|t)
WHERE = (W|w)(H|h)(E|e)(R|r)(E|e)
FROM = (F|f)(R|r)(O|o)(M|m)
SELECT = (S|s)(E|e)(L|l)(E|e)(C|c)(T|t)
INTO = (I|i)(N|n)(T|t)(O|o)
COUNT = (C|c)(O|o)(U|u)(N|n)(T|t)
MIN = (M|m)(I|i)(N|n)
MAX = (M|m)(A|a)(X|x)
AVG = (A|a)(V|v)(G|g)
SUM = (S|s)(U|u)(M|m)
INDICATOR = (I|i)(N|n)(D|d)(I|i)(C|c)(A|a)(T|t)(O|o)(R|r)
USER = (U|u)(S|s)(E|e)(R|r)
DISTINCT = (D|d)(I|i)(S|s)(T|t)(I|i)(N|n)(C|c)(T|t)
ALL = (A|a)(L|l)(L|l)
ANY = [Aa][Nn][Yy]
SOME =[Ss][Oo][Mm][Ee]

INTNUM = [0-9]+ 
APPROXNUM = ([0-9]*\.[0-9]+)([eE][-+]?[0-9]+)?|([0-9]+)
NAME = [A-Za-z][A-Za-z0-9_#]*
STR = \'[^\']* \'

/*
DATE_TYPE = [0-9]{4}\-([0][1-9]|[1][012])\-([012][0-9]|[3][01])
*/
/*
SECOND = (S|s)(E|e)(C|c)(O|o)(N|n)(D|d) 
MINUTE = (M|m)(I|i)(N|n)(U|u)(T|t)(E|e)
HOUR = (H|h)(O|o)(U|u)(R|r)
DAY = (D|d)(A|a)(Y|y)
WEEK = (W|w)(E|e)(E|e)(K|k)
MONTH = (M|m)(O|o)(N|n)(T|t)(H|h)
YEAR = (Y|y)(E|e)(A|a)(R|r)
DECADE = (D|d)(E|e)(C|c)(A|a)(D|d)(E|e)
CENTURY = (C|c)(E|e)(N|n)(T|t)(U|u)(R|r)(Y|y)
MILLENNIUM = (M|m)(I|i)(L|l)(L|l)(E|e)(N|n)(N|n)(I|i)(U|u)(M|m)
UNITY = [(SECOND) | (MINUTE) | (HOUR) | (DAY) | (WEEK) | (MONTH) | (YEAR) | (DECADE) | (CENTURY) | (MILLENNIUM)] 
INTERVAL = (I|i)(N|n)(T|t)(E|e)(R|r)(V|v)(A|a)(L|l) 
*/
INTERVAL1 =  (I|i)(N|n)(T|t)(E|e)(R|r)(V|v)(A|a)(L|l) [ \t]* [\'] [ \t]* [0-9]+ [ \t]+ ((S|s)(E|e)(C|c)(O|o)(N|n)(D|d) | (M|m)(I|i)(N|n)(U|u)(T|t)(E|e) | (H|h)(O|o)(U|u)(R|r) | (D|d)(A|a)(Y|y) | (W|w)(E|e)(E|e)(K|k) | (M|m)(O|o)(N|n)(T|t)(H|h) | (Y|y)(E|e)(A|a)(R|r) | (D|d)(E|e)(C|c)(A|a)(D|d)(E|e) | (C|c)(E|e)(N|n)(T|t)(U|u)(R|r)(Y|y) | (M|m)(I|i)(L|l)(L|l)(E|e)(N|n)(N|n)(I|i)(U|u)(M|m)) [ \t]* [\'] 
INTERVAL2 =  (I|i)(N|n)(T|t)(E|e)(R|r)(V|v)(A|a)(L|l) [ \t]* [\'] [ \t]* [0-9]+ [ \t]* [\'] [ \t]* ((S|s)(E|e)(C|c)(O|o)(N|n)(D|d) | (M|m)(I|i)(N|n)(U|u)(T|t)(E|e) | (H|h)(O|o)(U|u)(R|r) | (D|d)(A|a)(Y|y) | (W|w)(E|e)(E|e)(K|k) | (M|m)(O|o)(N|n)(T|t)(H|h) | (Y|y)(E|e)(A|a)(R|r) | (D|d)(E|e)(C|c)(A|a)(D|d)(E|e) | (C|c)(E|e)(N|n)(T|t)(U|u)(R|r)(Y|y) | (M|m)(I|i)(L|l)(L|l)(E|e)(N|n)(N|n)(I|i)(U|u)(M|m))  
CADEIA = \-\-[^(\n|\r|\r\n)]* (\n|\r|\r\n)
NL  = \n | \r | \r\n



%%

"||"        {this.yyparser.line = yyline + 1; this.yyparser.column = yycolumn + 1;
              Tokens c = new Tokens();
              c.text = yytext();this.yyparser.yylval = new ParserVal(c);  return Parser.TK_VERTBAR;}              


[ \t]+ { }

{NL}         { }
              
{SELECT}     {this.yyparser.line = yyline + 1; this.yyparser.column = yycolumn + 1;              
              Tokens c = new Tokens();
              c.text = yytext();
              this.yyparser.yylval = new ParserVal(c); return Parser.TK_SELECT;}
              
{ALL}        {this.yyparser.line = yyline + 1; this.yyparser.column = yycolumn + 1;
              Tokens c = new Tokens();
              c.text = yytext();
              this.yyparser.yylval = new ParserVal(c); return Parser.TK_ALL;}

{ANY}        {this.yyparser.line = yyline + 1; this.yyparser.column = yycolumn + 1;
              Tokens c = new Tokens();
              c.text = yytext();
              this.yyparser.yylval = new ParserVal(c); return Parser.TK_ANY;}

{SOME}       {this.yyparser.line = yyline + 1; this.yyparser.column = yycolumn + 1;
              Tokens c = new Tokens();
              c.text = yytext();
              this.yyparser.yylval = new ParserVal(c); return Parser.TK_SOME;}
              
{DISTINCT}   {this.yyparser.line = yyline + 1; this.yyparser.column = yycolumn + 1;
              Tokens c = new Tokens();
              c.text = yytext();
              this.yyparser.yylval = new ParserVal(c); return Parser.TK_DISTINCT;}
              
{USER}       {this.yyparser.line = yyline + 1; this.yyparser.column = yycolumn + 1;
              Tokens c = new Tokens();
              c.text = yytext();
              this.yyparser.yylval = new ParserVal(c); return Parser.TK_USER;}
              
{INDICATOR}  {this.yyparser.line = yyline + 1; this.yyparser.column = yycolumn + 1;
              Tokens c = new Tokens();
              c.text = yytext();
              this.yyparser.yylval = new ParserVal(c); return Parser.TK_INDICATOR;}
              
{AVG}        {this.yyparser.line = yyline + 1; this.yyparser.column = yycolumn + 1;
              Tokens c = new Tokens();
              c.text = yytext();
              this.yyparser.yylval = new ParserVal(c); return Parser.TK_AVG;}
              
{MIN}        {this.yyparser.line = yyline + 1; this.yyparser.column = yycolumn + 1;
              Tokens c = new Tokens();
              c.text = yytext();
              this.yyparser.yylval = new ParserVal(c); return Parser.TK_MIN;}
              
{MAX}        {this.yyparser.line = yyline + 1; this.yyparser.column = yycolumn + 1;
              Tokens c = new Tokens();
              c.text = yytext();
              this.yyparser.yylval = new ParserVal(c); return Parser.TK_MAX;}
              
{SUM}        {this.yyparser.line = yyline + 1; this.yyparser.column = yycolumn + 1;
              Tokens c = new Tokens();
              c.text = yytext();
              this.yyparser.yylval = new ParserVal(c); return Parser.TK_SUM;}
              
{COUNT}      {this.yyparser.line = yyline + 1; this.yyparser.column = yycolumn + 1;
              Tokens c = new Tokens();
              c.text = yytext();
              this.yyparser.yylval = new ParserVal(c); return Parser.TK_COUNT;}
              
{INTO}       {this.yyparser.line = yyline + 1; this.yyparser.column = yycolumn + 1;
              Tokens c = new Tokens();
              c.text = yytext();
              this.yyparser.yylval = new ParserVal(c); return Parser.TK_INTO;}
              
{FROM}       {this.yyparser.line = yyline + 1; this.yyparser.column = yycolumn + 1;
              Tokens c = new Tokens();
              c.text = yytext();
              this.yyparser.yylval = new ParserVal(c); return Parser.TK_FROM;}
              
{WHERE}      {this.yyparser.line = yyline + 1; this.yyparser.column = yycolumn + 1;
              Tokens c = new Tokens();
              c.text = yytext();
              this.yyparser.yylval = new ParserVal(c); return Parser.TK_WHERE;}
              
{GROUP}      {this.yyparser.line = yyline + 1; this.yyparser.column = yycolumn + 1;
              Tokens c = new Tokens();
              c.text = yytext();
              this.yyparser.yylval = new ParserVal(c); return Parser.TK_GROUP;}
              
{BY}         {this.yyparser.line = yyline + 1; this.yyparser.column = yycolumn + 1;
              Tokens c = new Tokens();
              c.text = yytext();
              this.yyparser.yylval = new ParserVal(c); return Parser.TK_BY;}
              
{HAVING}     {this.yyparser.line = yyline + 1; this.yyparser.column = yycolumn + 1;
              Tokens c = new Tokens();
              c.text = yytext();
              this.yyparser.yylval = new ParserVal(c); return Parser.TK_HAVING;}

{LIMIT}      {this.yyparser.line = yyline + 1; this.yyparser.column = yycolumn + 1;
              Tokens c = new Tokens();
              c.text = yytext();
              this.yyparser.yylval = new ParserVal(c); return Parser.TK_LIMIT;}

              
{ORDER}      {this.yyparser.line = yyline + 1; this.yyparser.column = yycolumn + 1;
              Tokens c = new Tokens();
              c.text = yytext();
              this.yyparser.yylval = new ParserVal(c); return Parser.TK_ORDER;}
              
{ASC}       {this.yyparser.line = yyline + 1; this.yyparser.column = yycolumn + 1;
              Tokens c = new Tokens();
              c.text = yytext();
              this.yyparser.yylval = new ParserVal(c); return Parser.TK_ASC;}
              
{DESC}       {this.yyparser.line = yyline + 1; this.yyparser.column = yycolumn + 1;
              Tokens c = new Tokens();
              c.text = yytext();
              this.yyparser.yylval = new ParserVal(c); return Parser.TK_DESC;}
              
{AS}         {this.yyparser.line = yyline + 1; this.yyparser.column = yycolumn + 1;
              Tokens c = new Tokens();
              c.text = yytext();
              this.yyparser.yylval = new ParserVal(c); return Parser.TK_AS;}
              
{OR}         {this.yyparser.line = yyline + 1; this.yyparser.column = yycolumn + 1;
              Tokens c = new Tokens();
              c.text = yytext();
              this.yyparser.yylval = new ParserVal(c); return Parser.TK_OR;}

{AND}        {this.yyparser.line = yyline + 1; this.yyparser.column = yycolumn + 1;
              Tokens c = new Tokens();
              c.text = yytext();
              this.yyparser.yylval = new ParserVal(c); return Parser.TK_AND;}

{NOT}        {this.yyparser.line = yyline + 1; this.yyparser.column = yycolumn + 1;
              Tokens c = new Tokens();
              c.text = yytext();
              this.yyparser.yylval = new ParserVal(c); return Parser.TK_NOT;}

{NULL}       {this.yyparser.line = yyline + 1; this.yyparser.column = yycolumn + 1;
              Tokens c = new Tokens();
              c.text = yytext();
              this.yyparser.yylval = new ParserVal(c); return Parser.TK_NULL;}

{IS}         {this.yyparser.line = yyline + 1; this.yyparser.column = yycolumn + 1;
              Tokens c = new Tokens();
              c.text = yytext();
              this.yyparser.yylval = new ParserVal(c); return Parser.TK_IS;}

{IN}         {this.yyparser.line = yyline + 1; this.yyparser.column = yycolumn + 1;
              Tokens c = new Tokens();
              c.text = yytext();
              this.yyparser.yylval = new ParserVal(c); return Parser.TK_IN;}
              
{EXISTS}     {this.yyparser.line = yyline + 1; this.yyparser.column = yycolumn + 1;
              Tokens c = new Tokens();
              c.text = yytext();
              this.yyparser.yylval = new ParserVal(c); return Parser.TK_EXISTS;}

{BETWEEN}    {this.yyparser.line = yyline + 1; this.yyparser.column = yycolumn + 1;
              Tokens c = new Tokens();
              c.text = yytext();
              this.yyparser.yylval = new ParserVal(c); return Parser.TK_BETWEEN;}

{LIKE}       {this.yyparser.line = yyline + 1; this.yyparser.column = yycolumn + 1;
              Tokens c = new Tokens();
              c.text = yytext();
              this.yyparser.yylval = new ParserVal(c); return Parser.TK_LIKE;}

{ESCAPE}     {this.yyparser.line = yyline + 1; this.yyparser.column = yycolumn + 1;
              Tokens c = new Tokens();
              c.text = yytext();
              this.yyparser.yylval = new ParserVal(c); return Parser.TK_ESCAPE;}
              
{DATE}       {this.yyparser.line = yyline + 1; this.yyparser.column = yycolumn + 1;
              Tokens c = new Tokens();
              c.text = yytext();
              this.yyparser.yylval = new ParserVal(c); return Parser.TK_DATE;}      

{FALSE}      {this.yyparser.line = yyline + 1; this.yyparser.column = yycolumn + 1;
              Tokens c = new Tokens();
              c.text = yytext();
              this.yyparser.yylval = new ParserVal(c); return Parser.TK_FALSE;}      

{TRUE}       {this.yyparser.line = yyline + 1; this.yyparser.column = yycolumn + 1;
              Tokens c = new Tokens();
              c.text = yytext();
              this.yyparser.yylval = new ParserVal(c); return Parser.TK_TRUE;}      

{ELSE}       {this.yyparser.line = yyline + 1; this.yyparser.column = yycolumn + 1;
              Tokens c = new Tokens();
              c.text = yytext();
              this.yyparser.yylval = new ParserVal(c); return Parser.TK_ELSE;}      

{THEN}       {this.yyparser.line = yyline + 1; this.yyparser.column = yycolumn + 1;
              Tokens c = new Tokens();
              c.text = yytext();
              this.yyparser.yylval = new ParserVal(c); return Parser.TK_THEN;}

{WHEN}       {this.yyparser.line = yyline + 1; this.yyparser.column = yycolumn + 1;
              Tokens c = new Tokens();
              c.text = yytext();
              this.yyparser.yylval = new ParserVal(c); return Parser.TK_WHEN;}  

{END}        {this.yyparser.line = yyline + 1; this.yyparser.column = yycolumn + 1;
              Tokens c = new Tokens();
              c.text = yytext();
              this.yyparser.yylval = new ParserVal(c); return Parser.TK_END;}      

{CASE}       {this.yyparser.line = yyline + 1; this.yyparser.column = yycolumn + 1;
              Tokens c = new Tokens();
              c.text = yytext();
              this.yyparser.yylval = new ParserVal(c); return Parser.TK_CASE;} 

{COALESCE}   {this.yyparser.line = yyline + 1; this.yyparser.column = yycolumn + 1;
              Tokens c = new Tokens();
              c.text = yytext();
              this.yyparser.yylval = new ParserVal(c); return Parser.TK_COALESCE;}      

{NULLIF}     {this.yyparser.line = yyline + 1; this.yyparser.column = yycolumn + 1;
              Tokens c = new Tokens();
              c.text = yytext();
              this.yyparser.yylval = new ParserVal(c); return Parser.TK_NULLIF;}  

{EXTRACT}    {this.yyparser.line = yyline + 1; this.yyparser.column = yycolumn + 1;
              Tokens c = new Tokens();
              c.text = yytext();
              this.yyparser.yylval = new ParserVal(c); return Parser.TK_EXTRACT;}              

{SUBSTRING}  {this.yyparser.line = yyline + 1; this.yyparser.column = yycolumn + 1;
              Tokens c = new Tokens();
              c.text = yytext();
              this.yyparser.yylval = new ParserVal(c); return Parser.TK_SUBSTRING;}

{FOR}        {this.yyparser.line = yyline + 1; this.yyparser.column = yycolumn + 1;
              Tokens c = new Tokens();
              c.text = yytext();
              this.yyparser.yylval = new ParserVal(c); return Parser.TK_FOR;}

"<>"         {this.yyparser.line = yyline + 1; this.yyparser.column = yycolumn + 1;
              Tokens c = new Tokens();
              c.text = yytext();
              this.yyparser.yylval = new ParserVal(c); return Parser.TK_DIFERENTE;}

"<="         {this.yyparser.line = yyline + 1; this.yyparser.column = yycolumn + 1;
              Tokens c = new Tokens();
              c.text = yytext();
              this.yyparser.yylval = new ParserVal(c); return Parser.TK_MENOR_IG;}

">="         {this.yyparser.line = yyline + 1; this.yyparser.column = yycolumn + 1;
              Tokens c = new Tokens();
              c.text = yytext();
              this.yyparser.yylval = new ParserVal(c); return Parser.TK_MAIOR_IG;}
/*
{SECOND}     {this.yyparser.line = yyline + 1; this.yyparser.column = yycolumn + 1;
              Tokens c = new Tokens();
              c.text = yytext();
              this.yyparser.yylval = new ParserVal(c); return Parser.TK_SECOND;}              
              
{MINUTE}     {this.yyparser.line = yyline + 1; this.yyparser.column = yycolumn + 1;
              Tokens c = new Tokens();
              c.text = yytext();
              this.yyparser.yylval = new ParserVal(c); return Parser.TK_MINUTE;}              
              
{HOUR}       {this.yyparser.line = yyline + 1; this.yyparser.column = yycolumn + 1;
              Tokens c = new Tokens();
              c.text = yytext();
              this.yyparser.yylval = new ParserVal(c); return Parser.TK_HOUR;}
              
{DAY}        {this.yyparser.line = yyline + 1; this.yyparser.column = yycolumn + 1;
              Tokens c = new Tokens();
              c.text = yytext();
              this.yyparser.yylval = new ParserVal(c); return Parser.TK_DAY;}              
     
{WEEK}       {this.yyparser.line = yyline + 1; this.yyparser.column = yycolumn + 1;
              Tokens c = new Tokens();
              c.text = yytext();
              this.yyparser.yylval = new ParserVal(c); return Parser.TK_WEEK;}              

{MONTH}     {this.yyparser.line = yyline + 1; this.yyparser.column = yycolumn + 1;
              Tokens c = new Tokens();
              c.text = yytext();
              this.yyparser.yylval = new ParserVal(c); return Parser.TK_MONTH;}              

{YEAR}      {this.yyparser.line = yyline + 1; this.yyparser.column = yycolumn + 1;
              Tokens c = new Tokens();
              c.text = yytext();
              this.yyparser.yylval = new ParserVal(c); return Parser.TK_YEAR;}              
 
{DECADE}    {this.yyparser.line = yyline + 1; this.yyparser.column = yycolumn + 1;
              Tokens c = new Tokens();
              c.text = yytext();
              this.yyparser.yylval = new ParserVal(c); return Parser.TK_DECADE;}
              
{CENTURY}    {this.yyparser.line = yyline + 1; this.yyparser.column = yycolumn + 1;
              Tokens c = new Tokens();
              c.text = yytext();
              this.yyparser.yylval = new ParserVal(c); return Parser.TK_CENTURY;}
              
{MILLENNIUM} {this.yyparser.line = yyline + 1; this.yyparser.column = yycolumn + 1;
              Tokens c = new Tokens();
              c.text = yytext();
              this.yyparser.yylval = new ParserVal(c); return Parser.TK_MILLENNIUM;}
*/

{INTERVAL1}   {this.yyparser.line = yyline + 1; this.yyparser.column = yycolumn + 1;
              Tokens c = new Tokens();
              c.text = yytext();
              this.yyparser.yylval = new ParserVal(c); return Parser.TK_INTERVAL1;} 

{INTERVAL2}   {this.yyparser.line = yyline + 1; this.yyparser.column = yycolumn + 1;
              Tokens c = new Tokens();
              c.text = yytext();
              this.yyparser.yylval = new ParserVal(c); return Parser.TK_INTERVAL2;} 

{INTNUM}     {this.yyparser.line = yyline + 1; this.yyparser.column = yycolumn + 1;
              Tokens c = new Tokens();
              c.text = yytext();
              this.yyparser.yylval = new ParserVal(c); return Parser.TK_INTNUM;}

{APPROXNUM}  {this.yyparser.line = yyline + 1; this.yyparser.column = yycolumn + 1;
              Tokens c = new Tokens();
              c.text = yytext();
              this.yyparser.yylval = new ParserVal(c); return Parser.TK_APPROXNUM;}
              
/*
{DATE_TYPE}   {this.yyparser.line = yyline + 1; this.yyparser.column = yycolumn + 1;
              Tokens c = new Tokens();
              c.text = yytext();
              this.yyparser.yylval = new ParserVal(c); return Parser.TK_DATE_TYPE;}                 
*/

{NAME}       {this.yyparser.line = yyline + 1; this.yyparser.column = yycolumn + 1;
              Tokens c = new Tokens();
              c.text = yytext();
              this.yyparser.yylval = new ParserVal(c); return Parser.TK_NAME;}
              
{STR}        {this.yyparser.line = yyline + 1; this.yyparser.column = yycolumn + 1;
              Tokens c = new Tokens();
              c.text = yytext();
              this.yyparser.yylval = new ParserVal(c); return Parser.TK_STRING;}
              
"'"         {this.yyparser.line = yyline + 1; this.yyparser.column = yycolumn + 1;
              Tokens c = new Tokens();
              c.text = yytext();
              this.yyparser.yylval = new ParserVal(c); return Parser.TK_PLIC;}              


              
{CADEIA}      {}
              
"+" | 
"-" | 
"*" |
"/" |  
"(" | 
")" |
"," |
"." |
":" |
"=" |
"<" |
";" |
">"   { return (int) yycharat(0); }




.	     {this.yyparser.yyerror("Parser Syntax lex error"); return -1;}
