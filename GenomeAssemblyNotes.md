# Genome assembly

*Phaeobacter inhibins* S4sm

The data:  
- PacBio long reads with HiFi
- Maybe? Illumina short reads - NCBI S4Sm. Only have assembled contigs on NCBI....

## Spades

Must be used primarily with short reads

https://github.com/ablab/spades/blob/spades_3.15.4/README.md#sec1.2

```{bash}
module load SPAdes/3.15.3-GCC-11.2.0

spades.py -o spades_output \
  -1 <file1> \
  -2 <file2> \
  --pacbio <file>
```


## HiCanu

Longer than expected assembly with high rates of duplication
Likely not good for bacteria, especially S4?

https://canu.readthedocs.io/en/latest/quick-start.html#assembling-pacbio-hifi-with-hicanu

```{bash}
canu -assemble \
  -p S4sm \
  -d S4sm \
  genomeSize=4.5m \
  -pacbio-hifi "data/1tb_upload_attempt_20220111/fastq/m64247_211116_212612.demux.bc1003_BAK8A_OA--bc1003_BAK8A_OA.bam.fastq"
```


## Flye

https://github.com/fenderglass/Flye/blob/flye/docs/USAGE.md

```{bash}
module load Flye/2.9.1-Gcc-11.2.0

flye --pacbio-hifi /data/marine_diseases_lab/jessica/1tb_upload_attempt_20220111/fastq/m64247_211116_212612.demux.bc1003_BAK8A_OA--bc1003_BAK8A_OA.bam.fastq \
  --genome-size 4.5m \
  --out-dir flye-output-S4Sm
```


## Unicycler
