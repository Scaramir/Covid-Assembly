# FASTQ Quality Control for Illumina and Nanopore

# Rule for FastQC on Illumina samples
# TODO: Does not work
rule fastqc_illumina:
    input:
        R1 = config["illumina_samples"] + "/illumina.R1.fastq.gz",
        R2 = config["illumina_samples"] + "/illumina.R2.fastq.gz"
    output:
        html1 = results_dir / "qc/illumina_R1_fastqc.html",
        html2 = results_dir / "qc/illumina_R2_fastqc.html"
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
        R1 = lambda wildcards: [illumina_samples_df.at[wildcards.sample, "R1"]],
        R2 = lambda wildcards: [illumina_samples_df.at[wildcards.sample, "R2"]]
    output:
        R1 = results_dir / "qc/{sample}_clean_reads.R1.fastq.gz",
        R2 = results_dir / "qc/{sample}_clean_reads.R2.fastq.gz",
        html = results_dir / "qc/{sample}_fastp.html",
        json = results_dir / "qc/{sample}_fastp.json"
    log:
        "results/log/qc/{sample}_illumina_fastp.log"
    conda:
        "../envs/qc.yaml"
    benchmark:
        benchmark_dir / "qc" / "{sample}_fastp_illumina.txt"
    shell:
        """
        fastp -i {input.R1} -I {input.R2} -o {output.R1} -O {output.R2} -h {output.html} -j {output.json} --thread 4 --qualified_quality_phred 20 --length_required 50 2>> {log}
        """

# Rule for NanoPlot on Nanopore samples
rule nanoplot_nanopore:
    input:
        fastq = lambda wildcards: [nanopore_samples_df.at[wildcards.sample, "R1"]]
    output:
        directory(results_dir / "qc/nanoplot/raw/{sample}")
    log:
        "results/log/qc/{sample}_nanoplot.log"
    conda:
        "../envs/qc.yaml"
    benchmark:
        benchmark_dir / "qc" / "{sample}_nanoplot.txt"
    shell:
        """
        NanoPlot -t 4 --fastq {input.fastq} -o {output} 2>> {log}
        """

# Rule for length filtering with Filtlong on Nanopore samples
rule filtlong_nanopore:
    input:
        fastq = lambda wildcards: [nanopore_samples_df.at[wildcards.sample, "R1"]]
    output:
        fastq = results_dir / "qc/{sample}_clean_reads.fastq.gz"
    log:
        "results/log/qc/{sample}_filtlong.log"
    conda:
        "../envs/qc.yaml"
    benchmark:
        benchmark_dir / "qc" / "{sample}_filtlong.txt"
    params: 
        outdir = results_dir / "qc/nanoplot/clean/{sample}"
    shell:
        """
        filtlong --min_length 800 --max_length 1400 {input.fastq} | gzip - > {output.fastq} 2>> {log}
        NanoPlot -t 4 --fastq {output.fastq} --title "Filtered reads" --color darkslategrey --N50 --loglength -o {params.outdir} 2>> {log}
        """


# Rule for length filtering with fastp on Nanopore samples
rule fastpfilter_nanopore:
    input:
        fastq = lambda wildcards: [nanopore_samples_df.at[wildcards.sample, "R1"]]
    output:
        fastq = results_dir / "qc/{sample}_clean_reads_fastpnanopore.fastq.gz",
        html = results_dir / "qc/{sample}_fastp.html"
    log:
        "results/log/qc/{sample}_fastpfilter.log"
    conda:
        "../envs/qc.yaml"
    benchmark:
        benchmark_dir / "qc" / "{sample}_fastp_nanopore.txt"
    params: 
        outdir = results_dir / "qc/nanoplot/clean/{sample}"
    shell:
        """
        fastp -i {input.fastq} -o {output.fastq} -h {output.html} --length_required 800 --length_limit 1400 2>> {log}
        NanoPlot -t 4 --fastq {output.fastq} --title "Filtered reads" --color darkslategrey --N50 --loglength -o {params.outdir} 2>> {log}
        """
