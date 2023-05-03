#!/bin/bash
#SBATCH --job-name="trycycler"
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

echo "script started running at: "; date
echo "Running on host:"; hostname

# Change as appropriate for your system and genome:
threads=16
genome_size="4500000"
reads=/data/marine_diseases_lab/jessica/1tb_upload_attempt_20220111/fastq/m64247_211116_212612.demux.bc1003_BAK8A_OA--bc1003_BAK8A_OA.bam.fastq


echo "input file: ";$reads

#########
# Subsample #
#########

module load Trycycler
module list

trycycler subsample --reads "$reads" --threads "$threads" \
 --out_dir read_subsets --count 24 --genome_size "$genome_size"

 #########
 # Assemblies #
 #########

mkdir assemblies

echo "*** canu started running at: "; date

module purge
module load Trycycler
module load canu
module list

for i in 01 04 07 10 13 16 19 22; do
    canu -p canu -d canu_temp -fast genomeSize="$genome_size" useGrid=false maxThreads="$threads" -pacbio read_subsets/sample_"$i".fastq
    /home/jcoppersmith/data/src/s4_longread_assembly_20221013/canu_trim.py canu_temp/canu.contigs.fasta > assemblies/assembly_"$i".fasta
    rm -rf canu_temp
done

echo "*** flye started running at: "; date

module purge
module load Flye
module list

for i in 02 05 08 11 14 17 20 23; do
    flye --pacbio-hifi read_subsets/sample_"$i".fastq --threads "$threads" --out-dir flye_temp
    cp flye_temp/assembly.fasta assemblies/assembly_"$i".fasta
    cp flye_temp/assembly_graph.gfa assemblies/assembly_"$i".gfa
    rm -r flye_temp
done


echo "*** raven started running at: "; date

module purge
module load raven
module list

for i in 03 06 09 12 15 18 21 24; do
    raven --threads "$threads" --disable-checkpoints --graphical-fragment-assembly assemblies/assembly_"$i".gfa read_subsets/sample_"$i".fastq > assemblies/assembly_"$i".fasta
done

#########
# Clusters #
#########


echo "*** trycycler clustering started running at: "; date

module load Trycycler
module list

trycycler cluster --assemblies assemblies/*.fasta --reads "$reads" --threads "$threads" --out_dir trycycler

echo "script finished at: "; date
