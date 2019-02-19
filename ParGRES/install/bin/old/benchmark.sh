LIB=../../lib
HOME=../../

java -Xmx512m -cp $LIB/commons-cli-1.0.jar:$LIB/log4j-1.2.9.jar:$HOME:$LIB/pargres-server.jar:$LIB/pargres-jdbc-client.jar:$LIB/postgresql-8.0-310.jdbc3.jar org.pargres.benchmark.Benchmark