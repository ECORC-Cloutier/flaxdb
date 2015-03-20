#!/bin/bash

#This is the sorting method used to create directories of 1000 files each.
#The 1000 grouping is for merging .bam files; samtools has a limited memory space to do the merge so only a maximum of 1000 files per merge can be used.
#It is NOT used in the workflow becasue it is already included in fastatobam.sh and fastatobam_parallel.sh.
#The flow of control actually makes the first directory have 999 files and the rest 1000. 

parentdir=~/flaxdb-data #set the parent directory to store group directories
counter=0
foldernum=1

mkdir ${parentdir}/consensus_1 #create initial directory
dir=${parentdir}/consensus_1 #store current directory name

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
            mkdir ${parentdir}/consensus_${foldernum} #create new directory when counter is a multiple of 1000
            dir=${parentdir}/consensus_${foldernum} #store new directory name
            mv $file $dir
        else
            mv $file $dir
        fi
    fi
done    
