The following is a pipeline created by Dr. Frank You of Agriculture and Agri-Food Canada to combine two .bam files together. You can contact him at Frank.you@agr.gc.ca. The source code can be used to run on any dataset, but the instructions below are specifically for use with Dr. Sylvie Cloutier's flax research. 

Requried Tools
--------------
1. picard-tools
2. samtools
3. BWA (version 0.6.2 or older)

Scripts
--------
1. bam2fastq_pipeline.pl - used to convert from .bam to .fastq
2. rename_fq_reads_pipeline.pl - used to rename .fastq files/reads
3. bwa_mapping_pipeline.pl - maps sequences to a genome
4. correct_pacbio_pipeline.pl - maps sequences from PacBio to a genome

General Overview 
----------------
1.Convert from .bam to .fastq (if necessary). 
2.Rename the reads (this is important if different genotypes are being combined because without renaming, reads fromd ifferent genotypes cannot be distinguished).
3. Concatenate .fastq files of two genotypes into one. If there are paired reads, cat them into separate files.
4. Perform mapping.  

Detailed Procedure
------------------

To start off, you will need either the .bam or .fastq files, placed into separate folders. If you have several files/genotypes to process, I recommend doing them individually. You will also need the reference genome in .fasta format (it is Lu_v1109.scaffold_fold.fa for the flax research). All the scripts have command line options, which are in fact mandatory for indiciating file locations. To see them, just run the script without any options.

1. Convert any .bam files to .fastq with bam2fastq_pipeline.pl. Use the command "perl bam2fastq_pipeline -d /path/to/bam" where /path/to/bam is the path to the directory of bam files. Two files will be outputted for paired end reads. 

2. Rename the .fastq files (and their reads inside) with their proper genotype name. The list of proper names must be a text file containing two tab-delimited columns, for the .bam file name and genotype name respectively. For the flax research, this file is provided as "namelist.txt". Use the command "perl rename_fq_reads_pipeline.pl -i namelist.txt -d /path/to/fastq" where namelist.txt is for the list of proper names and /path/to/fastq is the path to the directory fo .fastq files.

3. Combine the .fastq files for the genotypes that you want to merge. For paired reads (which is the case for the flax data), merge two _1 files into one and two _2 files into another. Create a new directory with the name of the combination and place the files in there. You must use the naming convention of joining the two genotype names together with an "x" (i.e. DLxMD) for the combination name. If you are dealing with the flax data, run the cat.sh shell script "bash cat.sh" in the parent directory (which contains all the combination directories). Otherwise, the command used is "cat fileA.fastq fileB.fastq > fileAxFileB.fastq". With paired reads, "cat fileA_1.fastq fileB_1.fastq > fileAxFileB_1.fastq" and "cat fileA_2.fastq fileB_2.fastq > fileAxFileB_2.fastq" For example, if you want to merge Avantgarde and CDC Bethune, use the commands "cat  IX0021_D0VY6ACXX_7_TTCGAA_Avantgarde_1.fastq IX0021_D0VY6ACXX_7_TGAATG_CDCBethune_1.fastq > CDCBethunexAvantgarde_1.fastq" and "cat IX0021_D0VY6ACXX_7_TTCGAA_Avantgarde_2.fastq IX0021_D0VY6ACXX_7_TGAATG_CDCBethune_2.fastq > CDCBethunexAvantgarde_2.fastq". It is recommended that you follow the output naming convention of using the genotype names together with an "x" to indicate a combination and keeping the original number suffix (_1 or _2).

4. Map the .fastq files to a reference genome to create the final combined .bam file. Either bwa_mapping_pipeline.pl or correct_pacbio_pipeline.pl can be used, depending on your data set. For the flax research, use the command "perl bwa_mapping_pipeline.pl -r Lu_v1109.scaffold_fold.fa -f /path/to/fastq_renamed -t solexa -p NUM_THREADS -s p" where NUM_THREADS is the number of threads/CPU cores on your computer and /path/to/fastq_renamed is the path to the directory of renamed .fastq files. 

