#!/bin/bash

counter=0
foldernum=1

mkdir ~/flaxdb-data/consensus_1
dir=~/flaxdb-data/consensus_1

for file in *sorted.bam
do
    counter=$((counter+1))
    if [ $counter -lt 1000 ] 
    then
        mv $file $dir
    else
        if [ `expr $counter % 1000` -eq 0 ]
        then
            foldernum=$((foldernum+1))
            mkdir ~/flaxdb-data/consensus_${foldernum}
            dir=~/flaxdb-data/consensus_${foldernum}
            mv $file $dir
        else
            mv $file $dir
        fi
    fi
done    
