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
wget --no-check-certificate https://www.ncbi.nlm.nih.gov/nuccore/NC_045512.2?report=fasta -O data/reference.fasta

# Illumina
# Download the primer BED scheme for Cleanplex scheme that was used
wget --no-check-certificate https://osf.io/4nztj/download -O data/primer_scheme/cleanplex.amplicons.bedpe

# Nanopore
# First, we download the primer BED scheme for the ARTIC V1200 scheme
wget --no-check-certificate https://osf.io/3ks9b/download -O data/primer_scheme/nCoV-2019.bed

```
