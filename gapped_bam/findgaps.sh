#Author: Douglas Huang
#Modified: April 21, 2015
#Function: Get a list of all the reference genome sequences corresponding to gaps in the alignment
#Instructions: Use the input .bam file as the first command-line argument and the reference genome .fasta file as the second argument

#!/bin/bash

write_name=${1%%.*}
ref_genome=$2

bedtools genomecov -ibam $1 -bga > ${write_name}_coverage_coordinates.csv #generates a list of read coverage per position for entire genome
awk '$4 < 1 {print $1 "\t" $2 "\t" $3}' ${write_name}_coverage_coordinates.csv > ${write_name}_gap_coordinates.csv #filters out all entries greater than 1 (to find only gaps) and converts to .bed file
bedtools getfasta -tab -fi $2 -bed ${write_name}_gap_coordinates.csv -fo ${write_name}_gap_sequences.csv #creates .csv file of all gapped sequences
bedtools getfasta -fi $2 -bed ${write_name}_gap_coordinates.csv -fo ${write_name}_gap_sequences.fasta #creates .fasta file of all gapped sequences
