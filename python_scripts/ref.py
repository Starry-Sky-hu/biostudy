## this is script to get Reverse Complement sequence
## input is one line 
import sys

tr_dict = {
		'a':'t', 'g':'c', 'c':'g', 't':'a', 'n':'n',
		'A':'T', "G":'C', 'C':'G', 'T':'A', 'N':'N'
}

reverseComplement = lambda s: "".join([tr_dict[c] for c in s])[::-1]

ori_file = sys.argv[1]
rev_file = sys.argv[2]

with open(ori_file, 'r') as f:
	ori = f.readlines()

for i in range(len(ori)):
	if ">" in ori[i]:
		with open(rev_file, 'a') as f:
			f.writelines(ori[i])
	else:
		with open(rev_file, 'a') as f:
			f.writelines(reverseComplement(ori[i].strip()) + '\n')

