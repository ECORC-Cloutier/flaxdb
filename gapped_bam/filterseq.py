#Author: Douglas Huang
#Modified: April 24, 2015
#Function: Filter unwanted reference sequences
#Instructions: Integrated with findgaps.sh. For independent processing. use input .fasta as command-line argument

from Bio import SeqIO
import sys

file_name = sys.argv[1]

ind = file_name.index(".")
base = file_name[:ind]

input_file = open(file_name, "r")
output_fasta = open(base + "_significant.fasta", "w")
output_csv = open(base + "_significant.csv", "w")

for record in SeqIO.parse(input_file, "fasta"):
	seq_name = str(record.id)
	sequence = str(record.seq)
	significant_base = 0
	for base in sequence:
		if base != "N": #filter for only significant bases
			significant_base += 1
	if significant_base > 100: #threshold for siginificant sequence
		SeqIO.write(record, output_fasta, "fasta")
		output_csv.write(seq_name + "," + sequence + "\n")

input_file.close()
output_fasta.close()
output_csv.close()
