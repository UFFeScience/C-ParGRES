LIB=../lib
HOME=../
java -Xmx512m -cp $HOME:$LIB/log4j-1.2.9.jar:$LIB/pargres-jdbc-client.jar:$LIB/junit.jar:$LIB/commons-cli-1.0.jar org.pargres.console.Console "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9"