#!/usr/bin/python3

from Bio import SeqIO
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
 
	numOfPieces = ((len(sequence)-winSize)//stepSize)+1
	# Do the work
	for i in range(0,numOfPieces*stepSize+1,stepSize):
		if i+winSize > len(sequence):
			end = len(sequence)
		else:
			end = i+winSize
		yield (sequence[i:end],(i,end))


def process_fasta(fasta_file,window,step):
	
	for seq_record in SeqIO.parse(fasta_file, "fasta"):
		mygenerator = slidingWindow(seq_record.seq,window,step)
		out_file = seq_record.id.split("|")[0]  + '.outfile'

		with open(out_file,"w") as f:
			for i in mygenerator:
				seq_name = seq_record.id  + "_" +  str(i[1][0]) + "_" + str(i[1][1])
				seq_win = str(i[0])
				f.write(">" + seq_name + "\n")
				f.write(seq_win + "\n")
			
def main():
	parser = argparse.ArgumentParser()
	
	parser.add_argument("-i","--input", dest="infile",  help = "input fasta file", required = True)
	parser.add_argument("-w","--window", dest="window", default=120, help="Define window size" )
	parser.add_argument("-s","--step", dest="step", default=60,  help = "Define step size")
	args = parser.parse_args()

	out_file = args.infile + ".outfile"
	process_fasta(args.infile,int(args.window),int(args.step))


if __name__ == "__main__":
	main()

