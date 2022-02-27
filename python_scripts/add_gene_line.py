## add gene lint to gff file


import os
import copy
import sys

o_gff3 = sys.argv[1]
r_gff3 = sys.argv[2]

with open(o_gff3, 'r') as f:
	gff = f.readlines()

for i in range(len(gff)):
	if gff[i].split('\t')[2] == 'mRNA':
		n = 1
		gene_line = gff[i].split('\t')[0:8]
		while n < len(gene_line):
			gene_line.insert(n, '\t')
			n += 2
		mRNA_line = copy.deepcopy(gene_line)
		gene_line[4]='gene'
		gene_line.append('\t')
		gene_line.append(gff[i].split('\t')[8].split(';')[0][0:12] + ';')
		gene_line.append(gff[i].split('\t')[8].split(';')[1] + ';')
		
		mRNA_line.append('\t')
		mRNA_line.append(gff[i].split('\t')[8].split(';')[0])
		mRNA_line.append(';Parent')
		mRNA_line.append(gff[i].split('\t')[8].split(';')[0][2:12] + ';')

		with open(r_gff3, 'a') as f:
			f.writelines(gene_line)
			f.writelines(os.linesep)
			f.writelines(mRNA_line)
			f.writelines(os.linesep)
	else:
		with open(r_gff3, 'a') as f:
			f.writelines(gff[i])

