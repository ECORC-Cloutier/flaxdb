from Bio import SeqIO
import sys

name = sys.argv[1]
ind = name.index(".")
base = name[:ind]

file_read = open(name,"r")
file_write = open(base+".sam","w")

file_write.write("@SQ\tSN:"+base+"\tLN:unknown\n")

for record in SeqIO.parse(file_read,"fasta"):
    raw_seq = str(record.seq).split("N")
    qname = record.id
    gap_count = 0
    last_end = 0
    for item in raw_seq:
        if len(item) > 0:
            start = gap_count + last_end + 1
            end = start + len(item)
            file_write.write(qname+"\t"+"3"+"\t"+base+"\t"+str(start)+"\t"+"255"+"\t"+str(len(item))+"M"+"\t"+"="+"\t"+str(end)+"\t"+"0"+"\t"+item+"\t"+"*"+"\n")
            last_end = end
            gap_count = 0
        else:
            gap_count += 1

file_read.close()
file_write.close()
