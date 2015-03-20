#!/bin/bash

#This script is the GNU parallel version of make_consensus.sh.
#It iterates through a directory containing the directories of 1000 scaffold.bam files, merges each group together, and moves it to a new directory.
#In the new directory, the final .bam file is created and indexed. 

dir=~/flaxdb-data/consensus #path to the desired directory to store merged consensus files

make_consensus() 
{
    file=$1
    cd $file
    samtools merge -f ${file}.bam *.bam
    cp ${file}.bam $dir
    cd ..
}

export -f make_consensus

parallel make_consensus {} ::: consensus_*

cd $dir
samtools merge consensus_merged.bam *.bam #creates the final merged .bam file
samtools index consensus_merged.bam
