from Bio import SeqIO
import sys

file_name = sys.argv[1]
ind = file_name.index(".")
base = file_name[:ind]
file_read = open(file_name, "r")
file_write = open(base+".fastq", "w")

for seq_record in SeqIO.parse(file_read, "fasta"):
    write_seq = str(seq_record.seq)
    write_id = str(seq_record.id)
    qual_len = len(write_seq)
    file_write.write("@"+write_id+"\n"+write_seq+"\n"+"+"+"\n"+("~"*qual_len)+"\n")

file_read.close()
file_write.close()

