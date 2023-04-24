#!/bin/bash
#SBATCH --job-name="trycycler"
#SBATCH --time 100:00:00  # walltime limit (HH:MM:SS) # Upped from 4 -- 2023-04-18
#SBATCH --array=0
#SBATCH --nodes=1   # number of nodes
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

module load Trycycler
module list

# Change as appropriate for your system and genome:
threads=16
nextdenovo_dir=$EBROOTNEXTDENOVO
nextpolish_dir=$EBROOTNEXTPOLISH
genome_size="4500000"

#########
# Subsample #
#########

trycycler subsample --reads /data/marine_diseases_lab/jessica/1tb_upload_attempt_20220111/fastq/m64247_211116_212612.demux.bc1003_BAK8A_OA--bc1003_BAK8A_OA.bam.fastq \
 --out_dir read_subsets --count 24 --genome_size "$genome_size"

 #########
 # Assemblies #
 #########

mkdir assemblies

echo "*** canu started running at: "; date

module purge
module load canu
module list

for i in 01 07 13 19; do
    canu -p canu -d canu_temp -fast genomeSize="$genome_size" useGrid=false minThreads="$threads" maxThreads="$threads" -pacbio read_subsets/sample_"$i".fastq
    canu_trim.py canu_temp/canu.contigs.fasta > assemblies/assembly_"$i".fasta
    rm -rf canu_temp
done

echo "*** flye started running at: "; date

module purge
module load Flye
module list

for i in 02 08 14 20; do
    flye --pacbio-hifi read_subsets/sample_"$i".fastq --threads "$threads" --out-dir flye_temp
    cp flye_temp/assembly.fasta assemblies/assembly_"$i".fasta
    cp flye_temp/assembly_graph.gfa assemblies/assembly_"$i".gfa
    rm -r flye_temp
done

echo "*** miniasm started running at: "; date

module purge
module load miniasm
module list

for i in 03 09 15 21; do
    miniasm_and_minipolish.sh read_subsets/sample_"$i".fastq "$threads" > assemblies/assembly_"$i".gfa
    any2fasta assemblies/assembly_"$i".gfa > assemblies/assembly_"$i".fasta
done


echo "*** raven started running at: "; date

module purge
module load raven
module list

for i in 06 12 18 24; do
    raven --threads "$threads" --disable-checkpoints --graphical-fragment-assembly assemblies/assembly_"$i".gfa read_subsets/sample_"$i".fastq > assemblies/assembly_"$i".fasta
done

echo "*** necat started running at: "; date

module purge
module load NECAT
module list

for i in 04 10 16 22; do
    necat.pl config config.txt
    realpath read_subsets/sample_"$i".fastq > read_list.txt
    sed -i "s/PROJECT=/PROJECT=necat/" config.txt
    sed -i "s/ONT_READ_LIST=/ONT_READ_LIST=read_list.txt/" config.txt
    sed -i "s/GENOME_SIZE=/GENOME_SIZE="$genome_size"/" config.txt
    sed -i "s/THREADS=4/THREADS="$threads"/" config.txt
    necat.pl bridge config.txt
    cp necat/6-bridge_contigs/polished_contigs.fasta assemblies/assembly_"$i".fasta
    rm -r necat config.txt read_list.txt
done

echo "*** nextdenovo started running at: "; date

module purge
module load NextDenovo
module load NextPolish
module list

for i in 05 11 17 23; do
    echo read_subsets/sample_"$i".fastq > input.fofn
    cp "$nextdenovo_dir"/doc/run.cfg nextdenovo_run.cfg
    sed -i "s/genome_size = 1g/genome_size = "$genome_size"/" nextdenovo_run.cfg
    sed -i "s/parallel_jobs = 20/parallel_jobs = 1/" nextdenovo_run.cfg
    sed -i "s/read_type = clr/read_type = ont/" nextdenovo_run.cfg
    sed -i "s/pa_correction = 3/pa_correction = 1/" nextdenovo_run.cfg
    sed -i "s/correction_options = -p 15/correction_options = -p "$threads"/" nextdenovo_run.cfg
    sed -i "s/-t 8/-t "$threads"/" nextdenovo_run.cfg
    "$nextdenovo_dir"/nextDenovo nextdenovo_run.cfg
    cp 01_rundir/03.ctg_graph/nd.asm.fasta nextdenovo_temp.fasta
    rm -r 01_rundir nextdenovo_run.cfg input.fofn
    echo read_subsets/sample_"$i".fastq > lgs.fofn
    cat "$nextpolish_dir"/doc/run.cfg | grep -v "sgs" | grep -v "hifi" > nextpolish_run.cfg
    sed -i "s/parallel_jobs = 6/parallel_jobs = 1/" nextpolish_run.cfg
    sed -i "s/multithread_jobs = 5/multithread_jobs = "$threads"/" nextpolish_run.cfg
    sed -i "s|genome = ./raw.genome.fasta|genome = nextdenovo_temp.fasta|" nextpolish_run.cfg
    sed -i "s|-x map-ont|-x map-ont -t "$threads"|" nextpolish_run.cfg
    "$nextpolish_dir"/nextPolish nextpolish_run.cfg
    cp 01_rundir/genome.nextpolish.fasta assemblies/assembly_"$i".fasta
    rm -r 01_rundir pid*.log.info nextpolish_run.cfg lgs.fofn nextdenovo_temp.fasta
done


echo "script finished at: "; date
