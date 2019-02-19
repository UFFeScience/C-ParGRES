#!/bin/bash

if [ "$#" -ne 2 ]; then
        echo "USAGE: ./start_all2.sh first_node last_node"
        exit
fi

first=$1
last=$2

echo Killing java...
./do_ssh.sh "killall java" $first $last
echo
echo Stopping postgres...
./do_ssh.sh "~/pgsql/bin/pg_ctl stop -D /local/bmiranda/tpch/" $first $last
echo
echo Starting postgres...
./do_ssh.sh "~/pgsql/bin/postmaster -D /local/bmiranda/tpch/ -i &>/dev/null &" $first $last
sleep 1
echo
echo Running nqps...
./do_ssh.sh "cd ~/pargres-0.1/bin;~/pargres-0.1/bin/run_nqp.sh 3001 tpch_sf5 &>/dev/null &" $first $last
