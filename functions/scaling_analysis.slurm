#!/bin/bash
#SBATCH --job-name=memoryability   # create a short name for your job
#SBATCH --nodes=1                  # node count
#SBATCH --ntasks=1                 # total number of tasks across all nodes
#SBATCH --cpus-per-task=5          # cpu-cores per task (>1 if multi-threaded tasks)
#SBATCH --mem-per-cpu=4G           # memory per cpu-core (4G is default)
#SBATCH --time=00:30:00            # total run time limit (HH:MM:SS)
#SBATCH --output=/mmfs1/scratch/kurkela/output/null_perms_%a.out

cd /mmfs1/data/kurkela/Desktop/CamCan/code
module load matlab
matlab -nodisplay -nosplash -r "run_scaling($SLURM_CPUS_PER_TASK)"
