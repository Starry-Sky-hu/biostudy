import os
import sys

o_gff3 = sys.argv[1]
r_gff3 = sys.argv[2]
name_list = sys.argv[3]

with open(o_gff3, 'r') as f:
	gff = f.readlines()

with open(name_list, 'r') as f:
	gene_name = f.readlines()

for i in range(len(gff)):
	for j in range(len(gene_name)):
		gff[i] = gff[i].replace(gene_name[j].split()[1], gene_name[j].split()[0])

with open(r_gff3, 'w') as f:
	f.writelines(gff)
