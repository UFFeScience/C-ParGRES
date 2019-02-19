basepath=/home/ubuntu/pargres/git/ParGRES
libpath=$basepath/lib
binpath=$basepath/bin
configpath=$basepath/config

port=8050
maxmemory=2048m

cd $binpath

java -Xmx$maxmemory -cp $basepath:$binpath:$libpath/log4j-1.2.9.jar:$libpath/pargres-jdbc-client.jar:$libpath/junit.jar:$libpath/commons-cli-1.0.jar org.pargres.console.Console -listnodes
