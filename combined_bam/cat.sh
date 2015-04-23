#!/bin/bash

#Author: Douglas Huang
#Modified: April 23, 2015
#Function: Concatenates .fastq files for a combined .bam file
#Insturctions: See README
#Notes: If not working, do concatenation manually with the procedure outlined in the README

for dir in /*x*
do
	cd $dir
	cat *_1.fastq > ${dir}_1.fastq &
	cat *_2.fastq > ${dir}_2.fastq &
	cd ..
done
wait
