# Project 2 - SARS-CoV-2 genome assembly from Illumina & Nanopore data
#### Project 2 from SC2 @ FUB
#### Jule Brenningmeyer, Maximilian Otto

Let's put our code and resulting plots and slides here.

And make use of a .gitignore to only upload code :)

## Environment

```bash

# download the repository to the current working directory using git 
git clone https://github.com/Scaramir/Covid-Assembly.git

cd Covid-Assembly/
```

## Data

```bash

mkdir data

# Illumina and nanopore data
wget --no-check-certificate https://osf.io/yz4ad/download -O data/sc2-nanopore-illumina-reads.tar.gz
tar -xzvf data/sc2-nanopore-illumina-reads.tar.gz -C data/

# Reference data
wget "https://www.ncbi.nlm.nih.gov/sviewer/viewer.fcgi?id=NC_045512.2&db=nuccore&report=fasta&retmode=text&withmarkup=on&tool=portal&log$=seqview&maxdownloadsize=1000000" -O data/NC_045512.2.fasta

# Python Script to Convert bed to bedpe files
mkdir scripts
wget --no-check-certificate https://osf.io/3295h/download -O scripts/primerbed2bedpe.py

# primer scheme folder
mkdir data/primer_scheme

# Illumina
# Download the primer BED scheme for Cleanplex scheme that was used
wget --no-check-certificate https://osf.io/4nztj/download -O data/primer_scheme/cleanplex.amplicons.bedpe
# V3
wget https://raw.githubusercontent.com/artic-network/artic-ncov2019/master/primer_schemes/nCoV-2019/V3/nCoV-2019.scheme.bed -O data/primer_scheme/V3-nCoV-2019.scheme.bed

# Nanopore
# First, we download the primer BED scheme for the ARTIC V1200 scheme
wget --no-check-certificate https://osf.io/3ks9b/download -O data/primer_scheme/nCoV-2019.bed
# ARTIC V4.1 primer kit
wget https://raw.githubusercontent.com/artic-network/artic-ncov2019/master/primer_schemes/nCoV-2019/V4.1/SARS-CoV-2.scheme.bed -O data/primer_scheme/V4.1-SARS-CoV-2.scheme.bed

```

To perform quality control using FastQC, just run snakemake like this: 
```bash
snakemake --cores 8 --use-conda -p fastqc_illumina
```