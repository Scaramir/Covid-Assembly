# TODO: Varaint calling before consensus generation
# https://github.com/rki-mf1/2023-SC2-Data-Science/blob/main/day-sc2-seq-and-assembly/hands-on.md#variant-calling

# TODO: adjust according to this: https://github.com/rki-mf1/2023-SC2-Data-Science/blob/main/day-sc2-seq-and-assembly/hands-on.md#consensus-generation

# Rule for generating a consensus sequence from the VCF file
rule generate_consensus:
    input:
        ref = reference_genome,
        vcf = "output/variant_calling/{sample}.annotate.vcf.gz",
        vcf_idx = "output/variant_calling/{sample}.annotate.vcf.gz.tbi"
    output:
        fasta = "output/consensus/{sample}_consensus.fasta"
    log:
        "results/log/consensus/{sample}_consensus.log"
    conda:
        "../envs/consensus.yaml"
    benchmark: 
        benchmark_dir / "consensus.txt"
    shell:
        """
        bcftools consensus -f {input.ref} {input.vcf} -o {output.fasta} 2>> {log}
        sed -i 's/MN908947.3/Consensus-{wildcards.sample}/g' {output.fasta}
        """

# Rule for compressing and indexing the VCF file
rule compress_index_vcf:
    input:
        vcf = "output/variant_calling/{sample}.annotate.vcf"
    output:
        vcf_gz = "output/variant_calling/{sample}.annotate.vcf.gz",
        vcf_gz_tbi = "output/variant_calling/{sample}.annotate.vcf.gz.tbi"
    log:
        "results/log/consensus/{sample}_compress_index.log"
    conda:
        "../envs/consensus.yaml"
    benchmark: 
        benchmark_dir / "compress_index.txt"
    shell:
        """
        bgzip -f {input.vcf}
        tabix -f -p vcf {output.vcf_gz} 2>> {log}
        """

# TODO: use pangolin for lineage assignment/annotation
# TODO: use president to perform QC on the consensus sequences
# TODO: think about performing MSA on the consensus sequences and then generating 
#       a phylogenetic tree from that MSA to see how much the sequences differ from each other