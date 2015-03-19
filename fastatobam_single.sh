#!/bin/bash

file=$1
base=${file%%.*}

python fasta2sam_single.py $file

samtools view -bS ${base}.sam > ${base}.bam

samtools sort ${base}.bam ${base}_sorted

#samtools index ${base}_sorted.bam
