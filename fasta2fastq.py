from Bio import SeqIO
import sys

file_name = sys.argv[1]
ind = file_name.index(".")
base = file_name[:ind]
file_read = open(file_name, "r")
file_write = open(base+".fastq", "w")

for seq_record in SeqIO.parse(file_read, "fasta"):
    seq_record.letter_annotations["phred_quality"] = [40] * len(seq_record)
    SeqIO.write(seq_record, file_write, "fastq")

file_read.close()
file_write.close() 
    
