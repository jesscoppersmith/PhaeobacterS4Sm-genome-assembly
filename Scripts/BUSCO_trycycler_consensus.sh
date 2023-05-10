#!/bin/bash
#SBATCH --job-name="BUSCO"
#SBATCH --time 100:00:00  # walltime limit (HH:MM:SS) # Upped from 4 -- 2023-04-18
#SBATCH --cpus-per-task=16
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=jcoppersmith@uri.edu



echo "script started running at: "; date
echo "Running on host:"; hostname
echo "*** BUSCO started running at: "; date

module load BUSCO

busco -m genome -i /data/marine_diseases_lab/jessica/src/s4_longread_assembly_20221013/trycycler/consensus.fasta -o BUSCO_trycycler-consensus --auto-lineage-prok -f -c 16

echo "script finished at: "; date
