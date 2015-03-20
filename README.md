# Flax Database Project

These scripts require Biopython and Samtools.

**Workflow**
-
1.  Run scaffold_search.py to parse through the consensus.fasta files and create a separate .fasta file for each scaffold.

2. Run fastatobam.sh, or fastatobam_parallel.sh if you have GNU parallel. This will create a .sam, .bam, sorted .bam for each scaffold .fasta file and place the files in groups of 1000 (in new directories). 

3. Run make_consensus.sh, or alternatively make_consensus_parallel with GNU parallel to merge each group of .bam files together. The script will then take these newly produced files and merge them all together in a separate directory to create the final .bam file. 
