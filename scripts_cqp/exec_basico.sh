datetime=$(date +"%Y%m%d%H%M")
lote=$1
arq_saida=/home/ubuntu/saidas_pargres/${lote}_${datetime}.out
arq_tempo=/home/ubuntu/saidas_pargres/${lote}_${datetime}.time

L1="Q12.sql Q04.sql Q02.sql Q05.sql Q09.sql Q13.sql Q10.sql Q11.sql Q07.sql Q08.sql Q03.sql Q06.sql Q14.sql Q01.sql" 
L2="Q01.sql Q10.sql Q11.sql Q12.sql Q07.sql Q08.sql Q13.sql Q03.sql Q06.sql Q14.sql Q02.sql Q05.sql Q09.sql Q04.sql" 
L3="Q14.sql Q13.sql Q07.sql Q08.sql Q12.sql Q01.sql Q03.sql Q06.sql Q04.sql Q10.sql Q11.sql Q02.sql Q05.sql Q09.sql"
L4="Q04.sql Q12.sql Q03.sql Q06.sql Q14.sql Q02.sql Q05.sql Q09.sql Q01.sql Q13.sql Q10.sql Q11.sql Q07.sql Q08.sql" 
LTESTE1="Q01.sql Q04.sql" 
LTESTE2="Q03.sql Q06.sql" 


num_rodadas=$2
echo $lote

path_consultas=/home/ubuntu/queries/queries_bme/postgres
sqls=`ls -v $path_consultas/*.sql | xargs -n1 basename`

if [ "$lote" == "BME" ]; then
    path_consultas=/home/ubuntu/queries/queries_bme/postgres
elif [ "$lote" == "TABULADOR" ]; then
    path_consultas=/home/ubuntu/queries/queries_tabulador/postgres
elif [ "$lote" == "T3459" ]; then
    path_consultas=/home/ubuntu/queries/queries_tabulador/postgres/T3459/T3459_dividida
elif [ "$lote" == "T3525" ]; then
    path_consultas=/home/ubuntu/queries/queries_tabulador/postgres/T3525/T3525_dividida
elif [ "$lote" == "T3534" ]; then
    path_consultas=/home/ubuntu/queries/queries_tabulador/postgres/T3534/T3534_dividida
elif [ "$lote" == "BME_lote1" ]; then
    sqls=$L1
elif [ "$lote" == "BME_lote2" ]; then
    sqls=$L2
elif [ "$lote" == "BME_lote3" ]; then
    sqls=$L3
elif [ "$lote" == "BME_lote4" ]; then
    sqls=$L4
elif [ "$lote" == "BME_TESTE1" ]; then
    sqls=$LTESTE1
elif [ "$lote" == "BME_TESTE2" ]; then
    sqls=$LTESTE2
else
    sqls=$lote
fi


tempo_lote=0
echo "Início da execução do lote [$lote] em: $(date)" | tee -a $arq_saida $arq_tempo

for rodada in $(seq 1 $num_rodadas); do
    
	tempo_rodada=0
	echo "Início da rodada [$rodada] em: $(date)" | tee -a $arq_saida $arq_tempo
    
	for sqlfile in $sqls
	do
        echo "************************************************************ $sqlfile ********************************************************" | tee -a $arq_saida $arq_tempo
        SECONDS=0
    	./console.sh $path_consultas/$sqlfile >> $arq_saida
        tempo_consulta=$SECONDS
        tempo_rodada=$(($tempo_rodada + $tempo_consulta))
        echo "Tempo $sqlfile: $tempo_consulta segundos." | tee -a $arq_saida $arq_tempo
        echo -e "*****************************************************************************************************************************\n" | tee -a $arq_saida $arq_tempo
		
        echo "Pausa de 5 segundos..."
		sleep 5
        echo "Prosseguindo..."
    done
	
    tempo_lote=$(($tempo_lote + $tempo_rodada))
	echo "Tempo da rodada [$rodada]: $tempo_rodada segundos." | tee -a $arq_saida $arq_tempo
    echo -e "*****************************************************************************************************************************\n" | tee -a $arq_saida $arq_tempo
	
    echo "Pausa de 30 segundos..."
	sleep 10
    echo "20..."
	sleep 10
    echo "10..."
	sleep 5
    echo "5..."
	sleep 5
    echo "Prosseguindo..."
done

echo "Tempo do lote [$lote]: $tempo_lote segundos." 2>&1 | tee -a $arq_saida >> $arq_tempo
echo "Final em: $(date)" | tee -a $arq_saida >> $arq_tempo
