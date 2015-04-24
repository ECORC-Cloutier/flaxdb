# Gapped BAM

These scripts output a list (both in .csv and .fasta) of all reference sequences that corresponds to gaps in an alignment. It requires BedTools.

Operation
-

    bash findgaps.sh input.bam reference_genome.fasta

where input.bam is your input .bam file and reference_genome.fasta is your reference genome. The .bam file *MUST* be sorted and its headers *MUST* be identical to those of the reference .fasta file. The Python code is called by the shell script (to do the filtering) and therefore must always be present with it.
