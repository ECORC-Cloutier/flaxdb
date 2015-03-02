#!/bin/bash

for file in *consensus.fasta
do
    python scaffold_search.py $file
done
