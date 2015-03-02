from Bio import SeqIO
import sys
import re

file_name = sys.argv[1]
ind = file_name.index(".")
base = file_name[:ind]

scaffold_list = open("scaffold_list.txt", "a+")
existing_scaffolds = scaffold_list.readlines() 

file_read = open(file_name, "r")

for seq_record in SeqIO.parse(file_read, "fasta"):
    curr_id = str(seq_record.id)
    curr_seq = str(seq_record.seq)
    if curr_id not in existing_scaffolds:
        write_seq = re.sub("(.{70})", "\\1\n", curr_seq, 0, re.DOTALL)
        fasta_write = open(curr_id+".fasta", "w")
        print("New: "+curr_id+"\n")
        fasta_write.write(">"+str(base)+"\n"+str(write_seq)+"\n")
        fasta_write.close()
        existing_scaffolds.append(curr_id)
        scaffold_list.write(curr_id+"\n")
    else:
        write_seq = re.sub("(.{70})", "\\1\n", curr_seq, 0, re.DOTALL)
        fasta_write = open(curr_id+".fasta", "a")
        fasta_write.write(">"+str(base)+"\n"+str(write_seq)+"\n")
        print("Old: "+curr_id+"\n")
        fasta_write.close()

file_read.close()
scaffold_list.close()
