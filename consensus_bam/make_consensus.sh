#!/bin/bash

#This script iterates through a directory containing the directories of 1000 scaffold.bam files, merges each group together, and moves it to a new directory.
#In the new directory, the final .bam file is created and indexed.

dir=~/flaxdb-data/consensus #path to the desired directory to store merged consensus files
mkdir $dir

for file in consensus_*
do
    cd $file
    samtools merge -f ${file}.bam *.bam #creates a merged .bam for each 1000 file group
    cp ${file}.bam $dir
    cd ..
done

cd $dir
samtools merge consensus_merged.bam *.bam #creates the final merged .bam file
samtools index consensus_merged.bam

