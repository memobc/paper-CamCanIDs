#!/bin/tcsh
#SBATCH --partition=partial_nodes  
#SBATCH --job-name=mriqc_test # Job name  
#SBATCH --ntasks 1 --cpus-per-task 1 # 1 cpu on single node  
#SBATCH --mem=8gb # Job memory request  
#SBATCH --time=02:00:00 # Time limit hrs:min:sec  
#SBATCH --mail-type=BEGIN,END,FAIL. # Mail events (NONE, BEGIN, END, FAIL, ALL)  
#SBATCH --mail-user=kurkela@bc.edu # Where to send mail

# parameters
set subject=CC110033
set bids_root=/
set mriqc_out=$bids_root/derivatives/mriqc/sub-$subject

# body
module load singularity
echo load singularity
cd ~/Desktop/
echo changedir
singularity run /usr/public/mriqc/22.0.6/mriqc.simg $bids_root $mriqc_out participant --participant-label CC110033 --n_proc 1 --fd_thres 0.2
echo mriqc run
