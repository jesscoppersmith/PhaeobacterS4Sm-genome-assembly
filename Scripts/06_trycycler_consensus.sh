#!/bin/bash
#SBATCH --job-name="trycycler-consensus"
#SBATCH --time 100:00:00  # walltime limit (HH:MM:SS) # Upped from 4 -- 2023-04-18
#SBATCH --array=0
#SBATCH --nodes=1   # number of nodes
#SBATCH --cpus-per-task=16
#SBATCH --mem=24G   # maximum memory used per node # upped from 6G -- 2021-06-01
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=jcoppersmith@uri.edu

####################
# BEFORE YOU BEGIN #
####################

source variables.sh

#########
# Setup #
#########

threads=16
genome_size="4500000"
reads=/data/marine_diseases_lab/jessica/1tb_upload_attempt_20220111/fastq/m64247_211116_212612.demux.bc1003_BAK8A_OA--bc1003_BAK8A_OA.bam.fastq

echo "script started running at: "; date
echo "Running on host:"; hostname

echo "*** trycycler Consensus started running at: "; date

module load Trycycler
module list

trycycler consensus --cluster_dir trycycler/cluster_001 --threads "$threads" --verbose
trycycler consensus --cluster_dir trycycler/cluster_002 --threads "$threads" --verbose
trycycler consensus --cluster_dir trycycler/cluster_003 --threads "$threads" --verbose
trycycler consensus --cluster_dir trycycler/cluster_004 --threads "$threads" --verbose

echo "script finished at: "; date
