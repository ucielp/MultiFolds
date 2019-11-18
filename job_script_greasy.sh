#!/bin/bash
#SBATCH --job-name=multi_folds_greasy
#SBATCH --workdir=.
#SBATCH --output=greasy-%j.out
#SBATCH --error=greasy-%j.err
#SBATCH --ntasks=96 #This will determine with the number of CPUs how many jobs are running at the same time. The bigger this is, the more resources you’re asking for and the longer it will take to enter.
#SBATCH --time=48:00:00

module load gcc/7.2.0
module load impi/2018.0
module load mkl/2018.0
# module load python/2.7.13_ML
module load python/2.7.14
module load R/3.5.1


FILE=temperatures.genes.greasy

/apps/GREASY/2.2/INTEL/IMPI/bin/greasy $FILE
 
