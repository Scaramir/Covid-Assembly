# FASTQ Quality Control for Illumina and Nanopore

# Rule for FastQC on Illumina samples
rule fastqc_illumina:
    input:
        R1 = "SARSCoV2-illumina.R1.fastq.gz",
        R2 = "SARSCoV2-illumina.R2.fastq.gz"
    output:
        html1 = "output/qc/illumina_R1_fastqc.html",
        html2 = "output/qc/illumina_R2_fastqc.html"
    log:
        "results/log/qc/illumina_fastqc.log"
    conda:
        "../envs/qc.yaml"
    shell:
        """
        fastqc -t 4 {input.R1} -o output/qc 2> {log}
        fastqc -t 4 {input.R2} -o output/qc 2> {log}
        """

# Rule for quality trimming with fastp on Illumina samples
rule fastp_illumina:
    input:
        R1 = "SARSCoV2-illumina.R1.fastq.gz",
        R2 = "SARSCoV2-illumina.R2.fastq.gz"
    output:
        R1 = "output/qc/clean_reads.R1.fastq.gz",
        R2 = "output/qc/clean_reads.R2.fastq.gz"
    log:
        "results/log/qc/illumina_fastp.log"
    conda:
        "../envs/qc.yaml"
    shell:
        """
        fastp -i {input.R1} -I {input.R2} -o {output.R1} -O {output.R2} --thread 4 --qualified_quality_phred 20 --length_required 50 2> {log}
        fastqc -t 2 {output.R1} {output.R2} -o output/qc 2> {log}
        """

# Rule for NanoPlot on Nanopore samples
rule nanoplot_nanopore:
    input:
        fastq = "SARSCoV2-nanopore.fastq.gz"
    output:
        html = "output/qc/nanoplot/raw_summary.html"
    log:
        "results/log/qc/nanoplot.log"
    conda:
        "../envs/qc.yaml"
    shell:
        """
        NanoPlot -t 4 --fastq {input.fastq} -o output/qc/nanoplot/raw 2> {log}
        """

# Rule for length filtering with Filtlong on Nanopore samples
rule filtlong_nanopore:
    input:
        fastq = "SARSCoV2-nanopore.fastq.gz"
    output:
        fastq = "output/qc/clean_reads_nanopore.fastq.gz"
    log:
        "results/log/qc/filtlong.log"
    conda:
        "../envs/qc.yaml"
    shell:
        """
        filtlong --min_length 800 --max_length 1400 {input.fastq} | gzip - > {output.fastq} 2> {log}
        NanoPlot -t 4 --fastq {output.fastq} --title "Filtered reads" --color darkslategrey --N50 --loglength -o output/qc/nanoplot/clean 2> {log}
        """
