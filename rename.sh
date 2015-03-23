!/bin/bash

for file in *.fasta
do
    newname=${file%%.*}.fasta
    mv $file $newname
done

while IFS=, read col1 col2
do
    query=${col1%%.*}.fasta
    replace=${col2}.fasta
    echo $query
    echo $replace
    find -name ${query} -exec mv {} $replace \;
done < flax_rename.csv
    
