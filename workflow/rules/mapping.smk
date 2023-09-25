# Rule for mapping Illumina samples with minimap2
rule minimap2_illumina:
    input:
        ref = config["ref"] + "/reference.fasta",
        R1 = "output/qc/clean_reads.R1.fastq.gz",
        R2 = "output/qc/clean_reads.R2.fastq.gz"
    output:
        "output/mapping/minimap2-illumina.sam"
    log:
        "results/log/mapping/minimap2-illumina.log"
    conda:
        "../envs/mapping.yaml"
    shell:
        """
        minimap2 -x sr -t 4 -a -o {output} {input.ref} {input.R1} {input.R2} 2>> {log}
        """

# Rule for mapping Nanopore samples with minimap2
rule minimap2_nanopore:
    input:
        ref = config["ref"] + "/reference.fasta",
        fastq = "output/qc/clean_reads_nanopore.fastq.gz"
    output:
        "output/mapping/minimap2-nanopore.sam"
    log:
        "results/log/mapping/minimap2-nanopore.log"
    conda:
        "../envs/mapping.yaml"
    shell:
        """
        minimap2 -x map-ont -t 4 -a -o {output} {input.ref} {input.fastq} 2>> {log}
        """

# Rule for processing SAM files to sorted and indexed BAM
rule process_sam_to_bam:
    input:
        sam = "output/mapping/{sample}.sam"
    output:
        bam = "output/mapping/{sample}.sorted.bam",
        bai = "output/mapping/{sample}.sorted.bam.bai"
    log:
        "results/log/mapping/{sample}_sam_processing.log"
    conda:
        "../envs/mapping.yaml"
    shell:
        """
        samtools view -bS {input.sam} | samtools sort -o {output.bam}
        samtools index {output.bam} {output.bai}
        """
