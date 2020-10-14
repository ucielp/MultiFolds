#!/usr/bin/python3

from pandas import *
import argparse


def slidingWindow(sequence,winSize,stepSize):

	# Verify the inputs
	try: it = iter(sequence)
	except TypeError:
		raise Exception("**ERROR** sequence must be iterable.")
	if stepSize > winSize:
		raise Exception("**ERROR** stepSize must not be larger than winSize.")
	 # if winSize > len(sequence):
		# raise Exception("**ERROR** winSize must not be larger than sequence length.")

	# HACK
	# numOfPieces = ((len(sequence)-winSize)//stepSize)+1
	numOfPieces = max (((len(sequence)-winSize)//stepSize)+1,0)
	# Do the work
	for i in range(0,numOfPieces*stepSize+1,stepSize):
		if i+winSize > len(sequence):
			end = len(sequence)
		else:
			end = i+winSize
		yield (sequence[i:end],(i,end))


def process_tab(tab_file,window,step):
	df = read_csv(tab_file,header=None,delimiter=';')
	df = df[df.columns[:-1]]
	for row in df.iterrows():
		name = row[1][0]
		scores_ints = (row[1][1:]).tolist()
		scores = [str(int) for int in scores_ints]

		mygenerator = slidingWindow(scores,window,step)
			
		out_file = name  + '.score.outfile'

		with open(out_file,"w") as f:
			for i in mygenerator:
				seq_name = name  + "_" +  str(i[1][0]) + "_" + str(i[1][1])
				seq_win = ",".join(i[0]).replace(',',';')
				f.write(seq_name + "\t")
				f.write(seq_win + ";\n")
			
def main():
	parser = argparse.ArgumentParser()
	
	parser.add_argument("-i","--input", dest="infile",  help = "input tab file", required = True)
	parser.add_argument("-w","--window", dest="window", default=120, help="Define window size" )
	parser.add_argument("-s","--step", dest="step", default=60,  help = "Define step size")
	args = parser.parse_args()

	out_file = args.infile + ".outfile"
	process_tab(args.infile,int(args.window),int(args.step))


if __name__ == "__main__":
	main()

