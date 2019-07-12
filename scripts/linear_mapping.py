#!/usr/bin/python

import os
import glob
import argparse



parser = argparse.ArgumentParser(description='Convert nextPARS to SHAPE-like scores')


parser.add_argument('--path', help='PATH to nextPARS score directory')

args = parser.parse_args()


def linear_mapping(items):
	
	import numpy as np
	# multiplied by -1
	a = np.array(items)
	b = -a
	items = list(b)
	
	mx = max(items)
	mn = min(items)

	# Map 0s in tab to '-999' value
	# Linearly mapped to [0,1]
	res = list(map(lambda x: (x - mn)/(mx-mn) if x!=0 else -999, items))
	
	return res
	
	# TODO
	# Scores >0.65 were then assigned a SHAPE reactivity of 1; 
	# scores <0.35 were assigned a reactivity of 0; 
	# scores >0.35 and <0.65 were linearly mapped to (0,1). 



path = args.path
 
ext = '.score.outfile'

for filename in glob.glob(os.path.join(path, '*' + ext)):
	print (filename)
	name = os.path.basename(filename)
	outfile = path + '/' + name.replace(ext,".SHAPE")
	
	res = list()

	with open(filename, 'r') as f:
		for line in f:
			nline = line.rstrip().split("\t")
			gene_name = nline[0]
			values = list(map(float,nline[1].split(";")[:-1]))

			k = 1
			for l in linear_mapping(values):
				res.append([k,l])
				k=k+1
		
		mfile = open(outfile,"w") 

		for number, letter in res:
			mfile.write("\n".join(["%s %s" % (number, letter)]) + "\n")


		
