basepath=/home/ubuntu/pargres/git/ParGRES
libpath=$basepath/lib
binpath=$basepath/bin
configpath=$basepath/config

port=8050
maxmemory=256m

cd $binpath

if [ "$#" -lt 1 ]
then
  echo  "Please insert at least one argument"
  exit
fi

for host in "$@"
do
  java -Xmx$maxmemory -cp $basepath:$binpath:$libpath/log4j-1.2.9.jar:$libpath/pargres-jdbc-client.jar:$libpath/junit.jar:$libpath/commons-cli-1.0.jar org.pargres.console.Console -addnode $host:3001
done
