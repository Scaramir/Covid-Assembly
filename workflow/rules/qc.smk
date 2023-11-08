# FASTQ Quality Control for Illumina and Nanopore

# Rule for FastQC on Illumina samples
rule fastqc_illumina:
    input:
        # The following line would be for use with illumina + nanopore samples
        # expand(["{R1}", "{R2}"], R1=list(illumina_samples_df.R1) + list(nanopore_samples_df.R1), R2=list(illumina_samples_df.R2) + [] * len(nanopore_samples_df))
        expand(["{R1}", "{R2}"], R1=list(illumina_samples_df.R1), R2=list(illumina_samples_df.R2))
    output:
        # The following line would be for use with illumina + nanopore samples
        # html = expand([results_dir / "qc/fastqc/{sample}.R{i}_fastqc.html"], sample=illumina_samples_df.index.tolist() + nanopore_samples_df.index.tolist(), i=["1","2"]),
        html = results_dir / "qc" / "fastqc" / "test.txt"
    log:
        results_dir / "log" / "qc" / "illumina_fastqc.log"
    conda:
        envs_dir / "qc.yaml"
    benchmark:
        benchmark_dir / "qc" / "fastqc_illumina.txt"
    threads: 
        config["num_threads"]
    params:
        outdir = results_dir / "qc" / "fastqc"
    shell:
        """
        mkdir -p {params.outdir}
        fastqc --quiet -t 4 {input} -o {params.outdir} 2> {log}
        touch {output.html}
        """

# Rule for quality trimming with fastp on Illumina samples
rule fastp_illumina:
    input:
        R1 = lambda wildcards: [illumina_samples_df.at[wildcards.sample, "R1"]],
        R2 = lambda wildcards: [illumina_samples_df.at[wildcards.sample, "R2"]]
    output:
        R1 = results_dir / "qc" / "{sample}_clean_reads.R1.fastq.gz",
        R2 = results_dir / "qc" / "{sample}_clean_reads.R2.fastq.gz",
        html = results_dir / "qc" / "{sample}_fastp.html",
        json = results_dir / "qc" / "{sample}_fastp.json"
    log:
        results_dir / "log" / "qc" / "{sample}_illumina_fastp.log"
    conda:
        envs_dir / "qc.yaml"
    benchmark:
        benchmark_dir / "qc" / "{sample}_fastp_illumina.txt"
    threads: 
        config["num_threads"]
    shell:
        """
        fastp -i {input.R1} -I {input.R2} -o {output.R1} -O {output.R2} -h {output.html} -j {output.json} --thread 4 --qualified_quality_phred 20 --length_required 50 2>> {log}
        """

# Rule for NanoPlot on Nanopore samples
rule nanoplot_nanopore:
    input:
        fastq = lambda wildcards: [nanopore_samples_df.at[wildcards.sample, "R1"]]
    output:
        directory(results_dir / "qc" / "nanoplot" / "raw" / "{sample}")
    log:
        results_dir / "log" / "qc" / "{sample}_nanoplot.log"
    conda:
        envs_dir / "qc.yaml"
    benchmark:
        benchmark_dir / "qc" / "{sample}_nanoplot.txt"
    threads: 
        config["num_threads"]
    shell:
        """
        NanoPlot -t 4 --fastq {input.fastq} -o {output} 2>> {log}
        """

# Rule for length filtering with Filtlong on Nanopore samples
rule filtlong_nanopore:
    input:
        fastq = lambda wildcards: [nanopore_samples_df.at[wildcards.sample, "R1"]]
    output:
        fastq = results_dir / "qc" / "{sample}_clean_reads.fastq.gz"
    log:
        results_dir / "log" / "qc" / "{sample}_filtlong.log"
    conda:
        envs_dir / "qc.yaml"
    benchmark:
        benchmark_dir / "qc" / "{sample}_filtlong.txt"
    threads: 
        config["num_threads"]
    params: 
        outdir = str(results_dir / "qc" / "nanoplot" / "clean" / "{sample}")
    shell:
        """
        filtlong --min_length 400 --max_length 700 {input.fastq} | gzip - > {output.fastq} 2>> {log}
        NanoPlot -t 4 --fastq {output.fastq} --title "Filtered reads" --color darkslategrey --N50 --loglength -o {params.outdir} 2>> {log}
        """

# Rule for length filtering with fastp on Nanopore samples
rule fastpfilter_nanopore:
    input:
        fastq = lambda wildcards: [nanopore_samples_df.at[wildcards.sample, "R1"]]
    output:
        fastq = results_dir / "qc" / {sample}_clean_reads_fastpnanopore.fastq.gz",
        html = results_dir / "qc" / {sample}_fastp.html"
    log:
        results_dir / "log" / "qc" / {sample}_fastpfilter.log"
    conda:
        envs_dir / "qc.yaml"
    benchmark:
        benchmark_dir / "qc" / "{sample}_fastp_nanopore.txt"
    threads: 
        config["num_threads"]        
    params: 
        outdir = results_dir / "qc" / "nanoplot" / "clean" / "{sample}"
    shell:
        """
        fastp -i {input.fastq} -o {output.fastq} -h {output.html} --length_required 400 --length_limit 700 2>> {log}
        NanoPlot -t 4 --fastq {output.fastq} --title "Filtered reads" --color darkslategrey --N50 --loglength -o {params.outdir} 2>> {log}
        """
