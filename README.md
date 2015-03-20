# Flax Database Project

These scripts require Biopython and Samtools.

**Workflow**
-
1.  Run scaffold_search.py to parse through the consensus.fasta files and create a separate .fasta file for each scaffold.

2. Put fastatobam.sh, or fastatobam_parallel.sh if you have GNU parallel, and fasta2sam_single.py into the directory of scaffold.fasta files. This will create a .sam, .bam, sorted .bam for each scaffold .fasta file and place the files in groups of 1000 (in new directories). 

3. Run make_consensus.sh, or alternatively make_consensus_parallel with GNU parallel, in the parent directory of the group directories to merge each group of .bam files together. The script will then take these newly produced files and merge them all together in a separate directory to create the final .bam file, as well as an index file. 
