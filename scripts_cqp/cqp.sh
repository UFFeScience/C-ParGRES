basepath=/home/ubuntu/pargres/git/ParGRES
outfile=/home/ubuntu/saidas_pargres/cqp.out
libpath=$basepath/lib
binpath=$basepath/bin
configpath=$basepath/config
configpath=$basepath/config

port=8000
maxmemory=3072m

cd $binpath

java -Xdebug -Xrunjdwp:transport=dt_socket,address=$port,server=y,suspend=n -Xmx$maxmemory -Dlog4j.debug -cp $basepath:$binpath:$libpath/hsqldb.jar:$libpath/log4j-1.2.9.jar:$libpath/pargres-server.jar:$libpath/postgresql-42.0.0.jre6.jar org.pargres.cqp.connection.ConnectionManagerImpl 8050 $configpath/PargresConfig.xml
