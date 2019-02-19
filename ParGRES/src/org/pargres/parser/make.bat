@echo off
cd C:\Documents and Settings\Marcelo Nunes\My Documents\workspace\marcelo_pargres\Pargres\src\org\pargres\parser
@echo on
yacc -d -Jpackage=org.pargres.parser sql.y
yacc -Jpackage=org.pargres.parser -Jclass=ParserIni parser_ini.y
@echo off
set JFLEX_HOME=C:\Docume~1\Marcel~1\MyDocu~1\jflex
set CLPATH=%JAVA_HOME%\lib\classes.zip;%JFLEX_HOME%\lib\JFlex.jar
java -classpath %CLPATH% JFlex.Main sql.flex
java -classpath %CLPATH% JFlex.Main parser_ini.flex


