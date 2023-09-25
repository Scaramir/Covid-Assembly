# Rule for primer clipping on Illumina samples using BAMclipper
rule bamclipper_illumina:
    input:
        bam = "output/mapping/minimap2-illumina.sorted.bam",
        bedpe = "data/primer_scheme/cleanplex-corrected.amplicons.bedpe"
    output:
        bam = "output/primer_clipping/illumina_clipped.bam"
    log:
        "results/log/primer_clipping/illumina_bamclipper.log"
    conda:
        "../envs/primer_clipping.yaml"
    shell:
        """
        bamclipper.sh -b {input.bam} -p {input.bedpe} -n 4 -o {output.bam} 2>> {log}
        """

# Rule for primer clipping on Nanopore samples using BAMclipper
rule bamclipper_nanopore:
    input:
        bam = "output/mapping/minimap2-nanopore.sorted.bam",
        bedpe = "data/primer_scheme/nCoV-2019.bedpe"
    output:
        bam = "output/primer_clipping/nanopore_clipped.bam"
    log:
        "results/log/primer_clipping/nanopore_bamclipper.log"
    conda:
        "../envs/primer_clipping.yaml"
    shell:
        """
        bamclipper.sh -b {input.bam} -p {input.bedpe} -n 4 -o {output.bam} 2>> {log}
        """
