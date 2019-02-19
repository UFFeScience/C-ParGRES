basepath=/home/ubuntu/pargres/git/ParGRES
outfile=/home/ubuntu/saidas_pargres/nqp.out
libpath=$basepath/lib
binpath=$basepath/bin
configpath=$basepath/config

port=8001
nodeport=3001
maxmemory=2048m
database=censo2010a

die() { status=$1; shift; echo "FATAL: $*"; exit $status; }
EC2_INSTANCE_ID="`wget -q -O - http://169.254.169.254/latest/meta-data/instance-id || die \"wget instance-id has failed: $?\"`"

echo "Inciando NQP:" > $outfile
echo "instance_id="$EC2_INSTANCE_ID | tee -a  $outfile
cd $binpath
java -Xdebug -Xrunjdwp:transport=dt_socket,address=$port,server=y,suspend=n -Xmx$maxmemory -cp $basepath:$binpath:$libpath/hsqldb.jar:$libpath/log4j-1.2.9.jar:$libpath/pargres-server.jar:$libpath/postgresql-42.0.0.jre6.jar org.pargres.nodequeryprocessor.NodeQueryProcessorEngine $nodeport org.postgresql.Driver jdbc:postgresql://localhost:5432/$database postgres postgres 0

echo "Finalizando NQP:" >> $outfile