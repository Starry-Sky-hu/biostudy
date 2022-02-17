##################################################################
# @Author: huyong
# @Created Time : Sun 07 Nov 2021 01:37:39 PM CST

# @File Name: dat2fasta.py
# @Description: This is a script converts uniport dat file to fasta file
# @Usage: python dat2fasta.py input output
##################################################################

import sys

print("Usage: python dat2fasta.py input output\n")

dat_file = sys.argv[1]
fasta_file = sys.argv[2]

with open(dat_file, "r") as f:
	dat_data = f.readlines()

i = 0
header = ""
sequence = list()

while i < len(dat_data):
	if dat_data[i][0]+dat_data[i][1] == "ID":
		ID = dat_data[i].split()
		header = ">" + ID[1] + "\n"
		#header = ">" + ID[1] + "|" + ID[2].replace(';','') + "|" + ID[3] + ID[4].replace('.','') + "\n"
	if dat_data[i][0]+dat_data[i][1] == "SQ":
		#header = ">" + dat_data[i][5:]
		i = i + 1
		while dat_data[i][0]+dat_data[i][1] != "//":
			sequence.append(dat_data[i].replace(' ', ''))
			i = i + 1
		with open(fasta_file, "a") as f:
			f.writelines(header)
			f.writelines(sequence)
			header = ""
			sequence = list()
	i = i + 1



