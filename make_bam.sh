#!/bin/bash

for file in *.fasta
do
    echo -e "@SQ\tSN:${file%%.*}\tLN:1250000" >> consensus.sam #length derived from trial-by-error. Don't know why it works!
done

for file in *.fasta
do
    python fasta2sam_multi.py $file
done
echo "consensus.sam created. Starting .sam to .bam conversion..."
samtools view -bS consensus.sam > consensus.bam
echo "consensus.bam created. Starting .bam sort..."
samtools sort consensus.bam consensus_sorted
echo "consensus.bam sorted. Starting .bai creation..."
samtools index consensus_sorted.bam
echo "consensus.bai created."
