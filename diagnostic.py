#script checks all read lengths and finds the maximum length

from Bio import SeqIO
import sys

file = sys.argv[1]
file_read = open(file, "r")

records = list(SeqIO.parse(file_read, "fasta"))
file_read.close()

max_len = 0

for sequence in records:
    curr_len = len(sequence.seq)
    print curr_len
    if curr_len > max_len:
        max_len = curr_len
    #if curr_len == 303562720:
        #print sequence.id
        #print sequence.name

print("Maxmimum Length: "+str(max_len))
