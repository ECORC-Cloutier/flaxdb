#!/bin/bash

#Author: Douglas Huang
#Modified: April 23, 2015
#Function: Converts .fasta to .bam and organizes output for next step
#Instructions: See README
#Notes: This script is the GNU parallel version of fastatobam.sh.
#It converts scaffold.fasta files into a sorted .bam file and divides the resulting files into groups of 1000.
#The 1000 grouping is for merging .bam files; samtools has a limited memory space to do the merge so only a maximum of 1000 files per merge can be used before overloading. Though the sorting step can be separated, it is more convenient if done here.
#First, the script converts the file to .sam, then .bam, and finally sorts the new .bam file.
#The resulting files are sorted into groups of 1000 and placed into their respective directories. 

fastatobam() 
{
    file=$1
    base=${file%%.*}
    python fasta2sam_single.py $file
    samtools view -bS ${base}.sam > ${base}.bam
    samtools sort ${base}.bam ${base}_sorted
    #samtools index ${base}_sorted.bam
}

export -f fastatobam

parallel fastatobam {} ::: *.fasta

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
