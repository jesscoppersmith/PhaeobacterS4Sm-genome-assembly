# PhaeobacterS4Sm-genome-assembly
Scripts and pipeline for bacterial genome assembly

## About the data
### Sample Collection and Strains
### DNA Extraction
### Sequencing

## Contents

### Scripts
- QC
- 01_Assembly-[01_trycycler_assembly_simple.sh](Scripts/01_trycycler_assembly_simple.sh)

## pipeline
Work based on Trycycler assembly pipeline
https://github.com/rrwick/Trycycler/wiki/How-to-run-Trycycler

### Quality Control
Program:
```{bash}

```
### Subsetting data
Trycycler used to subset PacBio HiFi reads into 24 read_subsets
```bash
module load Trycycler

trycycler subsample --reads "$reads" --threads "$threads" \
 --out_dir read_subsets --count 24 --genome_size "$genome_size"
```
### assembly
Three programs used to create 24 Assemblies - Canu, Flye, raven

#### canu

canu_trim.py script from Trycycler used to remove overlaps

```bash
module load Trycycler
module load canu

for i in 01 04 07 10 13 16 19 22; do
    canu -p canu -d canu_temp -fast genomeSize="$genome_size" useGrid=false maxThreads="$threads" -pacbio read_subsets/sample_"$i".fastq
    /home/jcoppersmith/data/src/s4_longread_assembly_20221013/canu_trim.py canu_temp/canu.contigs.fasta > assemblies/assembly_"$i".fasta
    rm -rf canu_temp
done
```

#### flye
```bash

module load Flye

for i in 02 05 08 11 14 17 20 23; do
    flye --pacbio-hifi read_subsets/sample_"$i".fastq --threads "$threads" --out-dir flye_temp
    cp flye_temp/assembly.fasta assemblies/assembly_"$i".fasta
    cp flye_temp/assembly_graph.gfa assemblies/assembly_"$i".gfa
    rm -r flye_temp
done
```
#### raven
```bash
module load raven

for i in 03 06 09 12 15 18 21 24; do
    raven --threads "$threads" --disable-checkpoints --graphical-fragment-assembly assemblies/assembly_"$i".gfa read_subsets/sample_"$i".fastq > assemblies/assembly_"$i".fasta
done
```

#### Results
| Assembler | assembly name | file name                    | total length(bp) | number of contigs |
|-----------|---------------|------------------------------|------------------|-------------------|
| Canu      | A:            | assemblies/assembly_01.fasta | 5,184,524        | 48                |
| Flye      | B:            | assemblies/assembly_02.fasta | 4,404,889        | 5                 |
| Raven     | C:            | assemblies/assembly_03.fasta | 8,086,628        | 93                |
| Canu      | D:            | assemblies/assembly_04.fasta | 4,996,471        | 39                |
| Flye      | E:            | assemblies/assembly_05.fasta | 4,403,801        | 5                 |
| Raven     | F:            | assemblies/assembly_06.fasta | 8,063,069        | 89                |
| Canu      | G:            | assemblies/assembly_07.fasta | 5,056,983        | 47                |
| Flye      | H:            | assemblies/assembly_08.fasta | 4,404,885        | 5                 |
| Raven     | I:            | assemblies/assembly_09.fasta | 8,185,013        | 96                |
| Canu      | J:            | assemblies/assembly_10.fasta | 5,088,603        | 43                |
| Flye      | K:            | assemblies/assembly_11.fasta | 4,404,884        | 5                 |
| Raven     | L:            | assemblies/assembly_12.fasta | 8,063,015        | 94                |
| Canu      | M:            | assemblies/assembly_13.fasta | 4,956,313        | 42                |
| Flye      | N:            | assemblies/assembly_14.fasta | 4,404,890        | 5                 |
| Raven     | O:            | assemblies/assembly_15.fasta | 8,138,657        | 92                |
| Canu      | P:            | assemblies/assembly_16.fasta | 5,042,752        | 43                |
| Flye      | Q:            | assemblies/assembly_17.fasta | 4,404,885        | 5                 |
| Raven     | R:            | assemblies/assembly_18.fasta | 8,045,231        | 94                |
| Canu      | S:            | assemblies/assembly_19.fasta | 5,150,055        | 45                |
| Flye      | T:            | assemblies/assembly_20.fasta | 4,404,885        | 5                 |
| Raven     | U:            | assemblies/assembly_21.fasta | 8,155,179        | 92                |
| Canu      | V:            | assemblies/assembly_22.fasta | 4,869,775        | 31                |
| Flye      | W:            | assemblies/assembly_23.fasta | 4,404,885        | 5                 |
| Raven     | X:            | assemblies/assembly_24.fasta | 8,231,199        | 89                |

### clustering

Trycycler used to cluster created contigs. Default setting resulted in more than 600 clusters, and a more stringent coverage cutoff was used.

```bash
trycycler cluster --assemblies assemblies/*.fasta --reads "$reads" --threads "$threads" --out_dir trycycler --min_contig_depth 0.8
```
