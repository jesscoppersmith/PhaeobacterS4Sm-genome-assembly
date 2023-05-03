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

echo "script started running at: "; date
echo "Running on host:"; hostname

#module load Trycycler
#module list

# Change as appropriate for your system and genome:
threads=16
genome_size="4500000"

#########
# Subsample #
#########

#trycycler subsample --reads /data/marine_diseases_lab/jessica/1tb_upload_attempt_20220111/fastq/m64247_211116_212612.demux.bc1003_BAK8A_OA--bc1003_BAK8A_OA.bam.fastq \
 #--out_dir read_subsets --count 24 --genome_size "$genome_size"

 #########
 # Assemblies #
 #########

#mkdir assemblies

echo "*** canu started running at: "; date

module purge
module load Trycycler
module load canu
module list

for i in 01; do
    canu -p canu -d canu_temp -fast genomeSize="$genome_size" useGrid=false maxThreads="$threads" -pacbio read_subsets/sample_"$i".fastq
    /home/jcoppersmith/data/src/s4_longread_assembly_20221013/canu_trim.py canu_temp/canu.contigs.fasta > assemblies/assembly_"$i".fasta
    rm -rf canu_temp
done

echo "script finished at: "; date
