#When placed into the directory of consensus.fasta files and given a .csv files of properly named genotypes, this script will replace each consensus file names with their corresponding proper names.
#!/bin/bash

for file in *.fasta #remove extraneous words from genotype file name
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
    find -name ${query} -exec mv {} $replace \; #matching the genotype file name with the proper name
done < flax_rename.csv #.csv containing proper names
    
