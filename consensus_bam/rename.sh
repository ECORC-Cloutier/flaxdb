#!/bin/bash

#Author: Douglas Huang
#Modified: April 23, 2015
#Function: Renames .fasta files with proper genotype names
#Instructions: Place into directory of consensus .fasta files with a .csv file of filename vs. genotype (comma separated)

for file in *.fasta 
do
    newname=${file%%.*}.fasta #remove extraneous words from genotype file name (optional depending on naming format)
    mv $file $newname
done

while IFS=, read col1 col2
do
    query=${col1%%.*}.fasta
    replace=${col2}.fasta
    echo $query
    echo $replace
    find -name ${query} -exec mv {} $replace \; #matching the genotype file name with the proper name
done < flax_rename.csv #.csv containing proper names
    
