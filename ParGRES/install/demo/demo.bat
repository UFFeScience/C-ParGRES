set HOME=..\..
set MIN=/B
start %MIN% java -cp %HOME%\config;%HOME%\lib\hsqldb.jar org.hsqldb.Server -database.0 ../utils/hsqldb/9001 -port 9001
start %MIN% java -cp %HOME%\config;%HOME%\lib\hsqldb.jar org.hsqldb.Server -database.0 ../utils/hsqldb/9002 -port 9002
pause
start %MIN% java -cp %HOME%\config;%HOME%\build\pargres-server.jar;%HOME%\lib\hsqldb.jar;%HOME%\lib\log4j-1.2.9.jar org.pargres.nodequeryprocessor.NodeQueryProcessorEngine 3671 org.hsqldb.jdbcDriver jdbc:hsqldb:hsql://localhost:9001 sa "" 0
start %MIN% java -cp %HOME%\config;%HOME%\build\pargres-server.jar;%HOME%\lib\hsqldb.jar;%HOME%\lib\log4j-1.2.9.jar org.pargres.nodequeryprocessor.NodeQueryProcessorEngine 3672 org.hsqldb.jdbcDriver jdbc:hsqldb:hsql://localhost:9002 sa "" 0
pause
start %MIN% java -cp %HOME%\config;%HOME%\build\pargres-server.jar;%HOME%\lib\hsqldb.jar;%HOME%\lib\log4j-1.2.9.jar org.pargres.cqp.connection.ConnectionManagerImpl 8050 %HOME%\config\ConfigurationFile2NodesLocal.txt