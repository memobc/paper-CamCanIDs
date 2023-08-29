#!/bin/bash
#SBATCH --job-name=nullsim       # create a short name for your job
#SBATCH --nodes=1                # node count
#SBATCH --ntasks=1               # total number of tasks across all nodes
#SBATCH --cpus-per-task=12       # cpu-cores per task (>1 if multi-threaded tasks)
#SBATCH --mem-per-cpu=4G         # memory per cpu-core (4G is default)
#SBATCH --time=00:40:00          # total run time limit (HH:MM:SS)

cd /mmfs1/data/kurkela/Desktop/CamCan/code
module load matlab
matlab -nodisplay -nosplash -r "D_cbpm_nullsim('memoryability', 'VisPeri_exclude', 'gsr', 0.01, 'age+sex+fd', $1);"
