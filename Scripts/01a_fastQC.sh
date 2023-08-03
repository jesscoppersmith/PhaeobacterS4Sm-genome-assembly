#!/bin/bash
#SBATCH --job-name="FastQC"
#SBATCH --time 100:00:00  # walltime limit (HH:MM:SS) # Upped from 4 -- 2023-04-18
#SBATCH --array=0
#SBATCH --nodes=1   # number of nodes
#SBATCH --cpus-per-task=16
#SBATCH --mem=24G   # maximum memory used per node # upped from 6G -- 2021-06-01
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=jcoppersmith@uri.edu
#SBATCH --output="slurm-%x-%j.out"

####################
# BEFORE YOU BEGIN #
####################


#########
# Setup #
#########

echo "script started running at: "; date
echo "Running on host:"; hostname

# Change as appropriate for your system and genome:

reads=/data/marine_diseases_lab/jessica/1tb_upload_attempt_20220111/fastq/m64247_211116_212612.demux.bc1003_BAK8A_OA--bc1003_BAK8A_OA.bam.fastq
output=/data/marine_diseases_lab/jessica/1tb_upload_attempt_20220111/FastQC_out

#########
# Subsample #
#########
echo "script started running at: "; date
echo "Running on host:"; hostname

module purge
module load FastQC
module list

fastqc -o $output -f $reads

echo "script finished at: "; date
