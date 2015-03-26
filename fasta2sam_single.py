#This script does the actual conversion from .fasta to .sam. 
#Arbitrary values are set for the CIGAR, QUAL, TLEN, RNEXT, and FLAG fields. 

from Bio import SeqIO
import sys

name = sys.argv[1]
ind = name.index(".")
base = name[:ind]

file_read = open(name,"r")
file_write = open(base+".sam","w")

records = list(SeqIO.parse(file_read,"fasta")) #must be stored as list for multiple operations because iterator cannot be reset

max_len = 0 #used to create the template length

for sequence in records:
    curr_len = len(sequence.seq)
    if curr_len > max_len:
        max_len = curr_len

file_write.write("@SQ\tSN:"+base+"\tLN:"+str(max_len)+"\n") 

for record in records:
    raw_seq = str(record.seq).split("N")
    qname = record.id
    gap_count = 0 #count gaps to see where next read starts after gap
    last_end = 0 #store end position of previous read
    counter = 0 #needed to flag the start and end read
    max_count = 0
    count = raw_seq
    for item in count: #count the number of gapped reads
        if len(item) > 0:
            max_count+=1
    for item in raw_seq:
        if len(item) > 0:
            counter+=1
            if counter == 1:
                flag = 65 #flag for starting read
            elif counter == max_count:
                flag = 129 #flag for end read
            else:
                flag = 193 #flag for in-between read
            start = gap_count + last_end + 1 #sam format is 1-based index
            end = start + len(item) #end is actually start of gap, meaning actual end position + 1
            file_write.write(qname+"\t"+str(flag)+"\t"+base+"\t"+str(start)+"\t"+"255"+"\t"+str(len(item))+"M"+"\t"+"="+"\t"+str(end)+"\t"+"0"+"\t"+item+"\t"+"*"+"\n")
            last_end = end
            gap_count = 0
        else:
            gap_count += 1

file_read.close()
file_write.close()
