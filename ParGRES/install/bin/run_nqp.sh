LIB=../lib
HOME=../
java -Xdebug -Xrunjdwp:transport=dt_socket,address=8002,server=y,suspend=n -Xmx512m -cp $HOME:$LIB/hsqldb.jar:$LIB/log4j-1.2.9.jar:$LIB/pargres-server.jar:$LIB/postgresql-8.0-310.jdbc3.jar org.pargres.nodequeryprocessor.NodeQueryProcessorEngine $1 org.postgresql.Driver jdbc:postgresql://localhost:5432/$2 tpch '' 0