#!/bin/bash

let isPrime=1

echo "input a number: "
read n

if [ ${n} -le 1 ]
then
  let isPrime=2
fi
for ((i=2;i<n;i++))
do
  let tmp=$(($n%$i))
  if [ $tmp -eq 0 ]
  then let isPrime=0
  break
  fi
done

# echo $isPrime

if [ $isPrime -eq 2 ]
then 
  echo "error!"
elif [ $isPrime -eq 1 ] 
then
  echo $n" is prime!"
else
  echo $n" is not prime!"
fi