#!/bin/bash

if [ $# -gt 0 ]; then
	file_name=$1
else
	echo "Please include file name
./generate_greasy_jobs.sh  c_glabrata_2015-01-09.genes"
	exit 1
fi

mainPATH=/home/uchorostecki/lab/uchorostecki
programPATH=/home/uchorostecki/lab/uchorostecki/software

tg_path=/home/uchorostecki/users/tg
myPATH=$mainPATH/projects/MULTI-FOLDS/multiple_conformations

rm $programPATH/MultiFolds/jobs/$file_name.txt
touch $programPATH/MultiFolds/jobs/$file_name.txt
for gene_name in $(cat $programPATH/MultiFolds/genes/$file_name ); do
	echo "./multifolds_cluster.sh "$gene_name" 180 60 > "$gene_name"_180_60.out 2> "$gene_name"_180_60.error" >> $programPATH/MultiFolds/jobs/$file_name.txt
	echo $gene_name
done


