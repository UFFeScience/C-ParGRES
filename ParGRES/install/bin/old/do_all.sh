nodes=(node9 node11 node12 node13 node14 node15 node16)

for node in ${nodes[@]}
do 
	(
		ssh $node "$1"
    ) &
	echo Node $node OK!
done
echo [CLUSTER] Waiting for end of threads...
wait
echo [CLUSTER] Done!