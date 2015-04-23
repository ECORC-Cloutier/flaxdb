#Author: Douglas Huang
#Modified: April 23, 2015
#Function: Prints all the read lengths for each scaffold and finds the maximum length and total read count; useful for debugging
#Instructions: Use the input scaffold .fasta file as the command-line argument

from Bio import SeqIO
import sys

file = sys.argv[1]
file_read = open(file, "r")

records = list(SeqIO.parse(file_read, "fasta"))
file_read.close()

max_len = 0
total_reads = 0

for sequence in records:
    curr_len = len(sequence.seq)
    print curr_len
    total_reads += 1
    if curr_len > max_len:
        max_len = curr_len
    #if curr_len == 303562720: #faulty sequence in scaffold34
        #print sequence.id
        #print sequence.name

print("Maxmimum Length: "+str(max_len))
print("Total Reads: "+str(total_reads))
