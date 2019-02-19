#!/bin/bash

command=$1
first=$2
last=$3
nodename=parasol

while [ $first -le $last ]
do
     if [ $first -le 9 ]; then
         number="0"$first
       else
         number=$first
     fi       
     ssh $nodename$number $command
     echo $nodename $number "OK!"
     
  let "first+=1"
done

