from Bio import SeqIO
import sys

file = sys.argv[1]
ind = file.index(".")
base = file[:ind]

file_read = open(file, "r")

scaffold_record = []

for seq_record in SeqIO.parse(file_read, "fasta"):
    curr_id = seq_record.id
    curr_seq = seq_record.seq
    if curr_id not in scaffold_record:
        fasta_write = open(curr_id+".fasta", "w")
        fasta_write.wrte(">"+base+"\n"+curr_seq+"\n")
        fasta_write.close()
        scaffold_record.append(curr_id)
    else:
        fasta_write = open(curr_id+".fasta", "a")
        fasta_write.wrte(">"+base+"\n"+curr_seq+"\n")
        fasta_write.close()

file_read.close()
