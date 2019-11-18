#!/bin/bash

if [ $# -gt 2 ]; then
	mol_name=$1
	temp=$2
	window=$3
	step=$4
else
	echo "Please include molecule name, temperature, window size and step size
/multifolds.sh ROX2 23 180 60 > ROX2_23_180_60.out 2> ROX2_180_60.error"
	exit 1
fi

mainPATH=/home/uchorostecki/lab/uchorostecki
programPATH=/home/uchorostecki/lab/uchorostecki/software

tg_path=/home/uchorostecki/users/tg
myPATH=$mainPATH/projects/MULTI-FOLDS/multiple_conformations/$temp'_degrees'

cd $myPATH

dir_name=$mol_name"_"$temp"_"$window"_"$step
mkdir $dir_name/; mkdir $dir_name/seq/; mkdir $dir_name/tab; mkdir $dir_name/res; mkdir $dir_name/final

fasta_file='C_parapsilosis_plus_individual_genes.fa'

#################
### TAB FILES ###
#################

#~ # OPTION 1
#~ # cp $programPATH/nextPARS/data/$mol_name/* $mol_name/tab/.
#~ # cp $programPATH/nextPARS/data/SEQS/PROBES/$mol_name.fa $mol_name/seq/.

#~ # OPTION 2 - OLD
#~ cd $tg_path/tgabaldon/PROJECTS/NONCODEVOL/DATA/TAB_FILES/our_data/c_glabrata/2015-01-09
#~ grep $mol_name PolyA-2015-01-09a_V1.tab_temp > $myPATH/$dir_name/tab/PolyA-2015-01-09a_V1.tab
#~ grep $mol_name PolyA-2015-01-09b_S1.tab_temp > $myPATH/$dir_name/tab/PolyA-2015-01-09b_S1.tab
#~ grep $mol_name PolyA-2015-01-09c_V1.tab_temp > $myPATH/$dir_name/tab/PolyA-2015-01-09c_V1.tab
#~ grep $mol_name PolyA-2015-01-09d_S1.tab_temp > $myPATH/$dir_name/tab/PolyA-2015-01-09d_S1.tab

#~ # OPTION 2 
cd $mainPATH/projects/MULTI-FOLDS/nextPARS/temperatures/processing/tab_files/$temp'_degrees'/
pwd

i=1
for tab_file_name in $(ls *temp); do 
	if [[ $tab_file_name == *"V1"* ]]; then
		grep $mol_name $tab_file_name > $myPATH/$dir_name/tab/$i'-'$temp'_V1.tab'
		((i=i+1))
	elif [[ $tab_file_name == *"S1"* ]]; then
		grep $mol_name $tab_file_name > $myPATH/$dir_name/tab/$i'-'$temp'_S1.tab'
		((i=i+1))
	fi
done; 

# old
# cd $tg_path/tgabaldon/PROJECTS/NONCODEVOL/DATA/SEQS/GENOMES/C_GLABRATA
# myvar=$mol_name
# awk -v myvar="$myvar" '/^>/ { p = ($0 ~ /'$myvar'/)} p' C_glabrata_CBS138_current_chromosomes.fasta > $myPATH/$dir_name/seq/$mol_name.fa


cd $mainPATH/projects/MULTI-FOLDS/nextPARS/temperatures/processing/DB/

grep -A 1 $mol_name\$ $fasta_file > $myPATH/$dir_name/seq/$mol_name.fa

length=$(cat $myPATH/$dir_name/seq/$mol_name.fa | awk '$0 ~ ">" {print c; c=0; } $0 !~ ">" {c+=length($0);} END { print c; }')

#####################################
####### get_combined_score ##########
####### Without classifier ##########  
#####################################

cd $programPATH/nextPARS/bin

# Check 
# sudo python2.7 -m pip install argparse numpy biopython datetime pysam termcolor pandas keras tensorflow dask h5py
source activate pythonDos

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

cd $myPATH/$dir_name/seq
python $programPATH/MultiFolds/scripts/sliding_windows.py -i $mol_name.fa -w $window -s $step

mv $myPATH/$dir_name/seq/$mol_name.outfile $myPATH/$dir_name/res/$mol_name.fa

cd $myPATH/$dir_name/res
python $programPATH/MultiFolds/scripts/sliding_windows_nextPARSE_score.py -i $mol_name.RNN_NP_ONLY.csv -w $window -s $step


#####################################
#######   linear mapping  ##########
#####################################

cd $myPATH/$dir_name/res

time python $programPATH/MultiFolds/scripts/linear_mapping.py \
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

if (( $length > $b ))
	then
		new_splited_file="$mol_name"_"$a"_"$b".SHAPE
		mv $splited_file $new_splited_file
	else
		new_splited_file="$mol_name"_"$a"_"${length:1:${#length}-1}".SHAPE
		mv $splited_file $new_splited_file
	fi
	((a=a+$step))
	((b=b+$step))
	
done;


cd $myPATH/$dir_name/res

mv $myPATH/$dir_name/res/*\_*.SHAPE ../final/.
mv $myPATH/$dir_name/res/*\_*.fa ../final/.



#####################################
#######   	Rsample		   ##########
#####################################

export DATAPATH=$programPATH/RNAstructure/data_tables/

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

cd $programPATH/RNAstructure/exe
for ct_file in $(ls $myPATH/$dir_name/final/*.ct ); do
	
	ct_f=$(basename -- "$ct_file")
	path=$(dirname "${ct_file}")
	filename=$(basename $ct_file .ct)

	./ct2dot $path/$filename.ct 1 $path/$filename.bracket

done
