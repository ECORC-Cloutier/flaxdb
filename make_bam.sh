#!/bin/bash

for file in *.fasta
do
    echo -e "@SQ\tSN:${file%%.*}\tLN:1250000" >> consensus.sam #length derived from trial-by-error. Don't know why it works!
done

for file in *.fasta
do
    echo -e "Processing ${file}...\n"
    python fasta2sam_multi.py $file
done

#.sam is first converted to .bam, then sorted, and finally .bai is created
echo -e "consensus.sam created. Starting .sam to .bam conversion...\n"
samtools view -bS consensus.sam > consensus.bam

echo -e "consensus.bam created. Starting .bam sort...\n"
samtools sort consensus.bam consensus_sorted

echo -e "consensus.bam sorted. Starting .bai creation...\n"
samtools index consensus_sorted.bam

echo "consensus.bai created. Process complete."
