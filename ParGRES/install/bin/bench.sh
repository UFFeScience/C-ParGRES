# a consulta 9 demora mto!
#qnumbers=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21)
qnumbers=(4 18 19 20 21)

function repeat {
        for i in `seq 1 $1`;
        do
        	echo :: Running Q$2
           ./console.sh -execfile ../queries/q$2.sql
         	echo :: Q$2 Done!
        done
}

function query {
        for qnumber in ${qnumbers[@]}
        do
           repeat 10 $qnumber
        done
}

query