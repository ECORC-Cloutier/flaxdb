# Flax Database Project

These scripts require Biopython and Samtools.

scaffold_search.py parses through the consensus.fasta files and create a separate .fasta file for each scaffold.

fasta2sam_single.py creates a .sam file from a scaffold.fasta file, following the SAM file format and using arbitrary data for FLAG, CIGAR, and QUAL. The reference template length, @SQ LN:, is the length of the longest sequence in the scaffold, plus 10 base pairs, for padding.

Similarly, fasta2sam_multi.py (*still in testing!*) generates .sam files from .fasta, but deposits all the scaffolds into one, large, .sam file. It must be used in conjuction with the shell script, make_bam.sh, which is needed to populate the header of the .sam file first. make_bam.sh also converts .sam to .bam, sorts it, and outputs a .bai file as well. 
