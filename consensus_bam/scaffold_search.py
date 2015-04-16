#This script parses a consensus.fasta file for scaffold sequences and creates a new .fasta file for each scaffold. 
#If the scaffold.fasta file already exists, it simply appends to it.

from Bio import SeqIO
import sys

file_name = sys.argv[1]
ind = file_name.index(".")
base = file_name[:ind]

file_read = open(file_name, "r")

for seq_record in SeqIO.parse(file_read, "fasta"):
    curr_id = str(seq_record.id)
    curr_seq = str(seq_record.seq)
    seq_record.id = base
    fasta_write = open(curr_id+".fasta", "a")
    SeqIO.write(seq_record, fasta_write, "fasta")
    fasta_write.close()

file_read.close()
