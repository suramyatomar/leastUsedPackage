#!/bin/bash

# Get all files in the system excluding the ones in /mnt as they are data files
locate / |grep -v "/mnt/" > all_files

for file in `cat all_files`
do
    if [[ -f $file ]]
    then
        # If the entry is a file query the system to see what package it belongs to
        var=$(dpkg-query -S $file 2> /dev/null|awk -F ":" '{print $1}')
      
        if [[ ! -z "$var" ]]
        then
           echo -n "$var | " >> out ; /usr/bin/stat "$file" |grep "Access: " |grep -v "Uid"| awk '{print $2}' >> out
        fi
    fi
done

# Now that we have all the package and last used detail for each file we need to process 
# Sort the file with the first column

sort -n -k 1 out > out_1

# group by the package name and get the max value of date
for i in `awk -F "|" '{if(!seen[$1]++)print $1}' out_1`; do awk -v i="$i" '$0 ~ i {x=$0}END{print x}' out_1; done > unsorted

# Sort the final result file
sort unsorted > final_result

