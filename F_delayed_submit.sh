#!/bin/bash

id=`sbatch D_cbpm_nullsim.slurm 1`
id_alt=`echo "$id" | tail -c 7`
echo "i:1 jobid:$id_alt"

for n in {2..100}
do
    id=`sbatch --depend=after:$id_alt D_cbpm_nullsim.slurm $n`;
    id_alt=`echo "$id" | tail -c 7`
    echo "i $n jobid $id_alt"
done
