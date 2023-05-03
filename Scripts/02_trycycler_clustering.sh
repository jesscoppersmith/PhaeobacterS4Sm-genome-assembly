#!/bin/bash
#SBATCH --job-name="trycycler"
#SBATCH --time 100:00:00  # walltime limit (HH:MM:SS) # Upped from 4 -- 2023-04-18
#SBATCH --array=0
#SBATCH --nodes=1   # number of nodes
#SBATCH --cpus-per-task=4
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


echo "*** trycycler clustering started running at: "; date

module load Trycycler
module list

trycycler cluster --assemblies assemblies/*.fasta --reads "$reads" --threads "$threads" --out_dir trycycler --min_contig_depth 0.8

echo "script finished at: "; date
