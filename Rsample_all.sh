#!/bin/bash

if [ $# -gt 2 ]; then
	mol_name=$1
	window=$2
	step=$3
else
	echo "Please include molecule name, window size and step size
/Rsample_all.sh PRC2_mHotair 180 60 > PRC2_mHotair.out 2> PRC2_mHotair.error"
	exit 1
fi

mainPATH=/home/uchorostecki/lab/uchorostecki
programPATH=/home/uchorostecki/lab/programs

tg_path=/home/uchorostecki/users/tg
myPATH=$mainPATH/projects/MULTI-FOLDS/multiple_conformations

cd $myPATH

dir_name=$mol_name"_"$window"_"$step
mkdir $dir_name/; mkdir $dir_name/seq/; mkdir $dir_name/tab; mkdir $dir_name/res; mkdir $dir_name/final

#~ # OPTION 1
#~ # cp $programPATH/nextPARS/data/$mol_name/* $mol_name/tab/.
#~ # cp $programPATH/nextPARS/data/SEQS/PROBES/$mol_name.fa $mol_name/seq/.

#~ # OPTION 2
cd $tg_path/tgabaldon/PROJECTS/NONCODEVOL/DATA/TAB_FILES/our_data/c_glabrata/2015-01-09
grep $mol_name PolyA-2015-01-09a_V1.tab_temp > $myPATH/$dir_name/tab/PolyA-2015-01-09a_V1.tab
grep $mol_name PolyA-2015-01-09b_S1.tab_temp > $myPATH/$dir_name/tab/PolyA-2015-01-09b_S1.tab
grep $mol_name PolyA-2015-01-09c_V1.tab_temp > $myPATH/$dir_name/tab/PolyA-2015-01-09c_V1.tab
grep $mol_name PolyA-2015-01-09d_S1.tab_temp > $myPATH/$dir_name/tab/PolyA-2015-01-09d_S1.tab

cd $tg_path/tgabaldon/PROJECTS/NONCODEVOL/DATA/SEQS/GENOMES/C_GLABRATA
myvar=$mol_name
awk -v myvar="$myvar" '/^>/ { p = ($0 ~ /'$myvar'/)} p' C_glabrata_CBS138_current_chromosomes.fasta > $myPATH/$dir_name/seq/$mol_name.fa


#####################################
####### get_combined_score ##########
####### Without classifier ##########  
#####################################

cd $programPATH/nextPARS/bin

# Check 
# sudo python2.7 -m pip install argparse numpy biopython datetime pysam termcolor pandas keras tensorflow dask h5py
time python  get_combined_score.py \
	-i $mol_name \
	-inDir $myPATH/$dir_name/tab \
	-f $myPATH/$dir_name/seq/$mol_name.fa \
	--nP_only $myPATH/$dir_name/res/$mol_name.RNN_NP_ONLY.csv 


# En el mismo directorio donde tengo esto *.RNN_NP_ONLY.csv muevo el que no tiene el clasificador (para tenerlo a mano)
mv $programPATH/nextPARS/bin/$mol_name.RNN.tab $myPATH/$dir_name/res/$mol_name.RNN.tab

#####################################
#######   sliding windows  ##########
#####################################

# TODO: # Corregir el nombre de la ventana, porque le pone nombre hasta el final pero debería ser hasta casi el final
		
cd $myPATH/$dir_name/seq
python $mainPATH/projects/MULTI-FOLDS/scripts/sliding_windows.py -i $mol_name.fa -w $window -s $step

mv $myPATH/$dir_name/seq/$mol_name.outfile $myPATH/$dir_name/res/$mol_name.fa

cd $myPATH/$dir_name/res
python $mainPATH/projects/MULTI-FOLDS/scripts/sliding_windows_nextPARSE_score.py -i $mol_name.RNN_NP_ONLY.csv -w $window -s $step


#####################################
#######   linear mapping  ##########
#####################################

cd $myPATH/$dir_name/res

time python $mainPATH/projects/MULTI-FOLDS/scripts/linear_mapping.py \
	--path $myPATH/$dir_name/res

while read line
do
    if [[ ${line:0:1} == '>' ]]
    then
        #outfile=${line:1:11}.fa
        outfile=${line:1}.fa
        echo $line > $outfile
    else
        echo $line >> $outfile
    fi
done < $mol_name.fa


split -l $window $mol_name.SHAPE splited_

a=0
b=$window

for splited_file in $(ls $myPATH/$dir_name/res/splited_* ); do
	

	new_splited_file="$mol_name"_"$a"_"$b".SHAPE
	mv $splited_file $new_splited_file
	
	((a=a+$step))
	((b=b+$step))
	
done;


cd $myPATH/$dir_name/res

mv $myPATH/$dir_name/res/*\_*.SHAPE ../final/.
mv $myPATH/$dir_name/res/*\_*.fa ../final/.



#####################################
#######   	Rsample		   ##########
#####################################

cd $programPATH/RNAstructure/exe
	
for shape_file in $(ls $myPATH/$dir_name/final/*SHAPE ); do

	cd $programPATH/RNAstructure/exe

	shape_f=$(basename -- "$shape_file")
	path=$(dirname "${shape_file}")
	filename=$(basename $shape_file .SHAPE)
	
	
	time ./Rsample-smp \
		$path\/$filename.fa \
		$path\/$shape_f \
		$path\/$filename.out
		
		
	time ./stochastic-smp \
		$path\/$filename.out \
		$path\/$filename.ct
	
	cd $myPATH/$dir_name/final
	time Rscript --vanilla $programPATH/RNAstructure/manual/Text/resources/RsampleCluster.R $filename.ct

done;
