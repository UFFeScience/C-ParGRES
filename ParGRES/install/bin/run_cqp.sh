LIB=../lib
HOME=../
java -Xdebug -Xrunjdwp:transport=dt_socket,address=8001,server=y,suspend=n -Xmx512m -Dlog4j.debug -cp $HOME:$LIB/hsqldb.jar:$LIB/log4j-1.2.9.jar:$LIB/pargres-server.jar:$LIB/postgresql-8.0-310.jdbc3.jar org.pargres.cqp.connection.ConnectionManagerImpl 8050 $1