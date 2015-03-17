from Bio import SeqIO
import sys

name = sys.argv[1]
ind = name.index(".")
base = name[:ind]

file_read = open(name,"r")
file_write = open(base+".sam","w")

file_write.write("@SQ SN:"+base+" LN:unknown"+"\n")

last_index = 0
gap_count = 0

for record in SeqIO.parse(file_read,"fasta"):
    raw_seq = str(record.seq).split("N")
    qname = record.id
    for item in raw_seq:
        if len(item) > 0:
            end = last_index+gap_count+len(item)
            file_write.write(qname+"\t"+"*"+"\t"+base+"\t"+str(last_index+1)+"\t"+"255"+"\t"+"*"+"\t"+"="+"\t"+str(end)+"\t"+"0"+"\t"+item+"\t"+"*"+"\n")
            gap_count = 0
            last_index = end
        else:
            gap_count+=1
            
file_read.close()
file_write.close()
