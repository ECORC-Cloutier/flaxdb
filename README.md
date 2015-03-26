# Flax Project

These scripts require Biopython and SAMtools. Information on SAM file creation can be found in SAM_creation_protocol.txt.

**Workflow**
-
1. Run scaffold_search.py (using a shell script) to parse through the consensus.fasta files and create a separate .fasta file for each scaffold. Make sure to remove the consensus.fasta files after use.

2. Put fastatobam.sh (or if you have GNU Parallel, fastatobam_parallel.sh) and fasta2sam_single.py into the directory of scaffold.fasta files. This will create a .sam, .bam, sorted .bam for each scaffold .fasta file and place the files in groups of 1000 (in new directories). 

3. Run make_consensus.sh (or alternatively, make_consensus_parallel with GNU parallel) in the parent directory of the group directories to merge each group of .bam files together. These merged files will themselves be mereged to create the final .bam file. 

**OPTIONAL**: rename.sh takes flax_rename.csv and renames all the consensus files to their proper labels. This naming trickles down to the .bam file, so when you view the sequences and hover over them, the proper name will show up.
