#!/bin/bash

#Author: Douglas Huang
#Modified: April 23, 2015
#Function: Get a list of all the reference genome sequences corresponding to gaps in the alignment
#Instructions: Use the input .bam file as the first command-line argument and the reference genome .fasta file as the second argument

write_name=${1%%.*} 
ref_genome=$2

#generate a coordinate list of read coverage per position
bedtools genomecov -ibam $1 -bga > ${write_name}_coverage_coordinates.csv 

#filter out all entries greater than 1 (to find only gaps)
awk '$4 < 1 {print $1 "\t" $2 "\t" $3}' ${write_name}_coverage_coordinates.csv > ${write_name}_gap_coordinates.csv 

#create temporary .fasta of all reference sequences corresponding to gaps
bedtools getfasta -fi $2 -bed ${write_name}_gap_coordinates.csv -fo ${write_name}_gap_sequences.fasta 

#filter to find only signifcant gaps
python filterseq.py ${write_name}_gap_sequences.fasta 

#remove intermediate files
rm $2.fai 
rm ${write_name}_coverage_coordinates.csv
rm ${write_name}_gap_coordinates.csv
rm ${write_name}_gap_sequences.fasta  
