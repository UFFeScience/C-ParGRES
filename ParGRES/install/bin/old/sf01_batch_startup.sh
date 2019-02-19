./do_all.sh "killall postmaster"
./do_all.sh "killall java"
./do_all.sh "~/pgsql/bin/postmaster -D /scratch/db/tpch/ -i &>/dev/null &"
sleep 1
./do_all.sh "cd pargres; ./sf01_run_nqp.sh 3001 &>/dev/null &"
#rsh node1 "cd pargres;./run_cqp.sh config/ConfigurationFile4Nodes.txt &>/dev/null &"
echo END!