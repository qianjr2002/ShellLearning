#!/bin/bash

output_file="net.csv"
echo "IP Address,Status" > $output_file

for i in {1..255}; do
    ip="192.168.1.$i"
    if ping -c 1 -w 1 $ip > /dev/null 2>&1; then
        echo "$ip,1" >> $output_file
    else
        echo "$ip,0" >> $output_file
    fi
done

echo "结果已保存到 $output_file"
