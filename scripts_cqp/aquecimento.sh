datetime=$(date +"%Y%m%d%H%M")

consulta1='select count(*) from cd2010adomi'
consulta2='select count(*) from cd2010apess'
consulta3='select d.codufcenso, count(*), sum(d.pesodomi) from cd2010adomi d where d.codufcenso in (11, 12, 13, 22, 51) group by d.codufcenso'
consulta4='select p.codufcenso, count(*), sum(p.pesopess) from cd2010apess p where p.codufcenso in (11, 12, 13, 22, 51) group by p.codufcenso'

#ssh -o StrictHostKeyChecking=no -i "PG-Key-pargres.pem" ubuntu@ec2-35-164-107-154.us-west-2.compute.amazonaws.com
#sudo su postgres


echo "Início da execução do aquecimento: $(date)"

echo "Executando consulta 1: $consulta1"
SECONDS=0
psql -U postgres -d censo2010a -c "$consulta1"
tempo_consulta=$SECONDS
tempo_rodada=$(($tempo_rodada + $tempo_consulta))
echo "Tempo consulta 1: $tempo_consulta segundos."

echo "Executando consulta 2: $consulta2"
SECONDS=0
psql -U postgres -d censo2010a -c "$consulta2"
tempo_consulta=$SECONDS
tempo_rodada=$(($tempo_rodada + $tempo_consulta))
echo "Tempo consulta 2: $tempo_consulta segundos."

echo "Executando consulta 3: $consulta3"
SECONDS=0
psql -U postgres -d censo2010a -c "$consulta3"
tempo_consulta=$SECONDS
tempo_rodada=$(($tempo_rodada + $tempo_consulta))
echo "Tempo consulta 3: $tempo_consulta segundos."


echo "Executando consulta 4: $consulta4"
SECONDS=0
psql -U postgres -d censo2010a -c "$consulta4"
tempo_consulta=$SECONDS
tempo_rodada=$(($tempo_rodada + $tempo_consulta))
echo "Tempo consulta 4: $tempo_consulta segundos."

echo "Tempo da rodada: $tempo_rodada segundos."

exit
