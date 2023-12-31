# Rule for mapping Illumina samples with minimap2
rule minimap2:
    input:
        ref = reference_genome,
        R1 = lambda wildcards: results_dir / "qc"/ "{wildcards.sample}_clean_reads.R1.fastq.gz" if wildcards.sample in illumina_samples_df.index else results_dir / "qc" / "{wildcards.sample}_clean_reads.fastq.gz",
        R2 = lambda wildcards: results_dir / "qc"/ "{wildcards.sample}_clean_reads.R2.fastq.gz" if wildcards.sample in illumina_samples_df.index else []
    output:
        results_dir / "mapping" / "minimap2-{sample}.sam"
    log:
        results_dir / "log" / "mapping" / "minimap2-{sample}.log"
    conda:
        envs_dir / "mapping.yaml"
    benchmark:
        benchmark_dir / "mapping" / "minimap2-{sample}.txt"
    threads: 
        config["num_threads"]
    shell:
        """
        minimap2 -x sr -t 4 -a -o {output} {input.ref} {input.R1} {input.R2} 2>> {log}
        """

# Rule for processing SAM files to sorted and indexed BAM
rule process_sam_to_bam:
    input:
        sam = results_dir / "mapping" / "minimap2-{sample}.sam"
    output:
        bam = results_dir / "mapping" / "minimap2-{sample}.sorted.bam",
        bai = results_dir / "mapping" / "minimap2-{sample}.sorted.bam.bai"
    log:
        results_dir / "log" / "mapping" / "minimap2-{sample}_sam_processing.log"
    conda:
        envs_dir / "mapping.yaml"
    benchmark:
        benchmark_dir / "mapping" / "minimap2-{sample}_sam_processing.txt"
    threads: 
        config["num_threads"]
    shell:
        """
        samtools view -bS {input.sam} | samtools sort -o {output.bam}
        samtools index {output.bam} {output.bai}
        """
