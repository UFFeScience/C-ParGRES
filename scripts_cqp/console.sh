basepath=/home/ubuntu/pargres/git/ParGRES
libpath=$basepath/lib
binpath=$basepath/bin
configpath=$basepath/config

host=localhost
port=8050
maxmemory=128m
maxlines=100

cd $binpath

java -Xmx$maxmemory -cp $basepath:$binpath:$libpath/log4j-1.2.9.jar:$libpath/pargres-jdbc-client.jar:$libpath/junit.jar:$libpath/commons-cli-1.0.jar org.pargres.console.Console -h $host -p $port -r $maxlines -execfile $1
