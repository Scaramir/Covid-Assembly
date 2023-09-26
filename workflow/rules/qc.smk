# FASTQ Quality Control for Illumina and Nanopore

# Rule for FastQC on Illumina samples
# TODO: Does not work
rule fastqc_illumina:
    input:
        R1 = config["illumina_samples"] + "/illumina.R1.fastq.gz",
        R2 = config["illumina_samples"] + "/illumina.R2.fastq.gz"
    output:
        html1 = "output/qc/illumina_R1_fastqc.html",
        html2 = "output/qc/illumina_R2_fastqc.html"
    log:
        "results/log/qc/illumina_fastqc.log"
    conda:
        "../envs/qc.yaml"
    benchmark:
        benchmark_dir / "qc" / "fastqc_illumina.txt"
    shell:
        """
        fastqc -t 4 {input.R1} -o output/qc 2>> {log}
        fastqc -t 4 {input.R2} -o output/qc 2>> {log}
        """

# Rule for quality trimming with fastp on Illumina samples
rule fastp_illumina:
    input:
        R1 = config["illumina_samples"] + "/illumina.R1.fastq.gz",
        R2 = config["illumina_samples"] + "/illumina.R2.fastq.gz"
    output:
        R1 = "output/qc/clean_reads.R1.fastq.gz",
        R2 = "output/qc/clean_reads.R2.fastq.gz",
        html = "output/qc/fastp.html"
    log:
        "results/log/qc/illumina_fastp.log"
    conda:
        "../envs/qc.yaml"
    benchmark:
        benchmark_dir / "qc" / "fastp_illumina.txt"
    shell:
        """
        fastp -i {input.R1} -I {input.R2} -o {output.R1} -O {output.R2} -h output/qc/fastp.html --thread 4 --qualified_quality_phred 20 --length_required 50 2>> {log}
        """

# Rule for NanoPlot on Nanopore samples
rule nanoplot_nanopore:
    input:
        fastq = config["nanopore_samples"] + "/nanopore.fastq.gz",
    output:
        html = "output/qc/nanoplot/raw/NanoPlot-report.html"
    log:
        "results/log/qc/nanoplot.log"
    conda:
        "../envs/qc.yaml"
    benchmark:
        benchmark_dir / "qc" / "nanoplot_nanopore.txt"
    shell:
        """
        NanoPlot -t 4 --fastq {input.fastq} -o output/qc/nanoplot/raw 2>> {log}
        """

# Rule for length filtering with Filtlong on Nanopore samples
rule filtlong_nanopore:
    input:
        fastq = config["nanopore_samples"] + "/nanopore.fastq.gz",
    output:
        fastq = "output/qc/clean_reads_nanopore.fastq.gz"
    log:
        "results/log/qc/filtlong.log"
    conda:
        "../envs/qc.yaml"
    benchmark:
        benchmark_dir / "qc" / "filtlong_nanopore.txt"
    shell:
        """
        filtlong --min_length 800 --max_length 1400 {input.fastq} | gzip - > {output.fastq} 2>> {log}
        NanoPlot -t 4 --fastq {output.fastq} --title "Filtered reads" --color darkslategrey --N50 --loglength -o output/qc/nanoplot/clean 2>> {log}
        """

# Rule for length filtering with Filtlong on Nanopore samples
rule fastpfilter_nanopore:
    input:
        fastq = config["nanopore_samples"] + "/nanopore.fastq.gz",
    output:
        fastq = "output/qc/clean_reads_nanopore.fastq.gz"
    log:
        "results/log/qc/filtlong.log"
    conda:
        "../envs/qc.yaml"
    benchmark:
        benchmark_dir / "qc" / "fastp_nanopore.txt"
    shell:
        """
        fastp -i {input.fastq} -o {output.fastq} -h results/qc/fastp.html --length_required 800 --length_limit 1400 2>> {log}
        NanoPlot -t 4 --fastq {output.fastq} --title "Filtered reads" --color darkslategrey --N50 --loglength -o output/qc/nanoplot/clean 2>> {log}
        """
