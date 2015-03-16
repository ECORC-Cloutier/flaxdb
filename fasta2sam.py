from Bio import SeqIO
import sys

name = sys.argv[1]
ind = name.index(".")
base = name[:ind]

file_read = open(name,"r")
file_write = open(base+".sam","w")

file_write.write("@SQ SN:"+base+" LN:unknown")

for record in SeqIO.parse(file_read,"fasta"):
    raw_seq = str(record.seq).split("N")
    qname = record.id
    for index, item in enumerate(raw_seq):
        if len(item) > 0:
            file_write.write(qname+"\t"+"*"+"\t"+base+"\t"+str(index+1)+"\t"+"255"+"\t"+"*"+"\t"+"="+"\t"+str(index)+str(len(item))+"\t"+item+"\t"+"*"+"\n")
            
file_read.close()
file_write.close()
