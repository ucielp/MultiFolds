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
	echo "./multifolds_cluster.sh "$gene_name" 23 180 60 > "$gene_name"_23_180_60.out 2> "$gene_name"_23_180_60.error" >> $programPATH/MultiFolds/jobs/$file_name.greasy
	echo $gene_name
done
for gene_name in $(cat $programPATH/MultiFolds/genes/$file_name ); do
	echo "./multifolds_cluster.sh "$gene_name" 37 180 60 > "$gene_name"_37_180_60.out 2> "$gene_name"_37_180_60.error" >> $programPATH/MultiFolds/jobs/$file_name.greasy
	echo $gene_name
done
for gene_name in $(cat $programPATH/MultiFolds/genes/$file_name ); do
	echo "./multifolds_cluster.sh "$gene_name" 55 180 60 > "$gene_name"_55_180_60.out 2> "$gene_name"_55_180_60.error" >> $programPATH/MultiFolds/jobs/$file_name.greasy
	echo $gene_name
done


