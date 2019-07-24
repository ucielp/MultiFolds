#!/bin/bash

#SBATCH --job-name=MF03
#SBATCH --nodes=1 #number of requested nodes
#SBATCH --ntasks=1 #number of processes to start
#SBATCH --ntasks-per-node=1 #number of tasks assigned to a node
#SBATCH --cpus-per-task=1 #specify how many threads each process would open
#SBATCH -t 2-0 # Maximum execution time (D-HH:MM)

module load gcc/7.2.0
module load impi/2018.0
module load mkl/2018.0
# module load python/2.7.13_ML
module load python/2.7.14
module load R/3.5.1

./multifolds_cluster.sh hSRA 180 60 > hSRA_180_60.out 2> hSRA_180_60.error
./multifolds_cluster.sh mSRA 180 60 > mSRA_180_60.out 2> mSRA_180_60.error
./multifolds_cluster.sh ROX2 180 60 > ROX2_180_60.out 2> ROX2_180_60.error
./multifolds_cluster.sh smHotair 180 60 > smHotair_180_60.out 2> smHotair_180_60.error
./multifolds_cluster.sh hSRA 181 61 > hSRA_181_61.out 2> hSRA_181_61.error
./multifolds_cluster.sh mSRA 181 61 > mSRA_181_61.out 2> mSRA_181_61.error
./multifolds_cluster.sh ROX2 181 61 > ROX2_181_61.out 2> ROX2_181_61.error
